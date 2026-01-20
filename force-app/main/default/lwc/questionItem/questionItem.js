import { LightningElement, api, track } from 'lwc';
import suggestAnswer from '@salesforce/apex/IntakeAnswerSuggestionController.suggestAnswer';

export default class QuestionItem extends LightningElement {
    @api question;      // Full question object with outcomes
    @api isActive;      // Whether this is the current/active question
    @api index;         // Position in question history (0-based)
    @api caseId;        // Case ID for AI context
    @api previousAnswers; // Previous Q&A in session for AI context

    // AI Suggestion state
    @track aiSuggestion = null;
    @track showSuggestion = false;
    @track isFetchingSuggestion = false;
    @track suggestionError = false;

    // ========== COMPUTED PROPERTIES ==========

    get questionNumber() {
        return this.index + 1;
    }

    get isPicklist() {
        return this.question?.inputType === 'Picklist';
    }

    get isText() {
        return this.question?.inputType === 'Text';
    }

    get isInstruction() {
        return this.question?.inputType === 'Instruction';
    }

    get isCompleted() {
        return this.question?.isComplete === true;
    }

    get isEditable() {
        return this.question?.isEditable === true;
    }

    get canEdit() {
        return this.isCompleted && this.isEditable;
    }

    // Determine if this question has many options (affects UI rendering)
    get hasManyOptions() {
        return this.question?.outcomes?.length > 10;
    }

    get hasModerateOptions() {
        return this.question?.outcomes?.length >= 5 && this.question?.outcomes?.length <= 10;
    }

    get hasFewOptions() {
        return this.question?.outcomes?.length < 5;
    }

    // Convert outcomes to format for lightning components
    get picklistOptions() {
        if (!this.question?.outcomes) return [];

        return this.question.outcomes.map(outcome => ({
            label: outcome.outcomeText,
            value: outcome.outcomeId
        }));
    }

    get radioOptions() {
        if (!this.question?.outcomes) return [];

        return this.question.outcomes.map(outcome => ({
            label: outcome.outcomeText,
            value: outcome.outcomeId
        }));
    }

    // Display the selected answer
    get displayAnswer() {
        return this.question?.answerValue || this.question?.selectedOutcomeText || '';
    }

    // Component state classes
    get containerClass() {
        let classes = ['question-item'];

        if (this.isActive) {
            classes.push('active');
        }

        if (this.isCompleted) {
            classes.push('completed');
        }

        if (!this.isActive && !this.isCompleted) {
            classes.push('pending');
        }

        return classes.join(' ');
    }

    get questionHeaderClass() {
        let classes = ['question-header'];

        if (this.isCompleted) {
            classes.push('slds-text-color_success');
        }

        return classes.join(' ');
    }

    // ========== EVENT HANDLERS ==========

    /**
     * Handle picklist selection (radio or combobox)
     * Auto-advances immediately on selection
     */
    handlePicklistChange(event) {
        const outcomeId = event.detail.value;

        if (!outcomeId) return;

        // Find the selected outcome
        const selectedOutcome = this.question.outcomes.find(
            o => o.outcomeId === outcomeId
        );

        if (!selectedOutcome) {
            console.error('Selected outcome not found:', outcomeId);
            return;
        }

        // Dispatch answer selected event
        this.dispatchAnswerSelected(
            outcomeId,
            selectedOutcome.outcomeText,
            selectedOutcome.outcomeText
        );
    }

    /**
     * Handle text input blur
     * Auto-advances when user tabs/clicks away if value is provided
     */
    handleTextBlur(event) {
        const value = event.target.value?.trim();

        if (!value) {
            // Don't auto-advance on empty input
            return;
        }

        // For text inputs, find the outcome marked as "Any Value"
        // or use the first outcome as default
        const anyValueOutcome = this.question.outcomes.find(
            o => o.anyValue === true
        );

        const selectedOutcome = anyValueOutcome || this.question.outcomes[0];

        if (!selectedOutcome) {
            console.error('No outcome available for text input');
            return;
        }

        // Dispatch answer selected event with user's text value
        this.dispatchAnswerSelected(
            selectedOutcome.outcomeId,
            value,
            value
        );
    }

    /**
     * Handle Enter key in text input
     * Allow users to press Enter to advance (in addition to blur)
     */
    handleTextKeyUp(event) {
        if (event.key === 'Enter') {
            event.target.blur(); // Trigger blur event
        }
    }

    /**
     * Handle instruction display and fetch AI suggestion for active questions
     * Auto-advances after brief delay for instructions
     */
    connectedCallback() {
        if (this.isInstruction && this.isActive) {
            // Auto-advance after 500ms for instructions
            setTimeout(() => {
                if (this.question.outcomes && this.question.outcomes.length > 0) {
                    const outcome = this.question.outcomes[0];
                    this.dispatchAnswerSelected(
                        outcome.outcomeId,
                        'Instruction viewed',
                        'Viewed'
                    );
                }
            }, 500);
        } else if (this.isActive && !this.isInstruction && this.caseId) {
            // Fetch AI suggestion for active questions
            this.fetchAISuggestion();
        }
    }

    /**
     * Handle edit button click
     * Allows user to modify a previously answered question
     */
    handleEditClick() {
        const event = new CustomEvent('editquestion', {
            detail: {
                questionId: this.question.questionId,
                index: this.index
            },
            bubbles: true,
            composed: true
        });

        this.dispatchEvent(event);
    }

    /**
     * Dispatch answer selected event to parent
     */
    dispatchAnswerSelected(outcomeId, outcomeText, answerValue) {
        const event = new CustomEvent('answerselected', {
            detail: {
                questionId: this.question.questionId,
                outcomeId: outcomeId,
                outcomeText: outcomeText,
                answerValue: answerValue,
                index: this.index
            },
            bubbles: true,
            composed: true
        });

        this.dispatchEvent(event);
    }

    // ========== AI SUGGESTION METHODS ==========

    /**
     * Fetch AI suggestion for the current question
     * Uses case context and previous answers to suggest an appropriate response
     */
    async fetchAISuggestion() {
        // Don't fetch if already fetching or suggestion already shown
        if (this.isFetchingSuggestion || this.showSuggestion) {
            return;
        }

        try {
            this.isFetchingSuggestion = true;
            this.suggestionError = false;

            // Prepare picklist options if applicable
            let picklistOptionsJson = '[]';
            if (this.isPicklist && this.question.outcomes) {
                const options = this.question.outcomes.map(o => o.outcomeText);
                picklistOptionsJson = JSON.stringify(options);
            }

            // Prepare previous answers
            const previousAnswersJson = this.previousAnswers ? JSON.stringify(this.previousAnswers) : '[]';

            console.log('[QuestionItem] Fetching AI suggestion for:', this.question.questionText);

            // Call Apex controller
            const result = await suggestAnswer({
                caseId: this.caseId,
                questionText: this.question.questionText,
                questionType: this.question.inputType,
                picklistOptions: picklistOptionsJson,
                previousAnswers: previousAnswersJson
            });

            if (result.success && result.suggestedAnswer) {
                this.aiSuggestion = result.suggestedAnswer;
                this.showSuggestion = true;
                console.log('[QuestionItem] AI suggestion received:', this.aiSuggestion);
            } else {
                console.log('[QuestionItem] AI suggestion not available');
            }

        } catch (error) {
            console.error('[QuestionItem] Error fetching AI suggestion:', error);
            this.suggestionError = true;
            // Silently fail - suggestion is optional feature
        } finally {
            this.isFetchingSuggestion = false;
        }
    }

    /**
     * Handle accepting the AI suggestion
     * Auto-fills the answer with the suggested value
     */
    handleAcceptSuggestion() {
        if (!this.aiSuggestion) return;

        console.log('[QuestionItem] Accepting AI suggestion:', this.aiSuggestion);

        if (this.isPicklist) {
            // For picklist, find the outcome that matches the suggestion
            const matchingOutcome = this.question.outcomes.find(
                o => o.outcomeText.toLowerCase().trim() === this.aiSuggestion.toLowerCase().trim()
            );

            if (matchingOutcome) {
                // Auto-select and advance
                this.dispatchAnswerSelected(
                    matchingOutcome.outcomeId,
                    matchingOutcome.outcomeText,
                    matchingOutcome.outcomeText
                );
            } else {
                console.error('[QuestionItem] Could not find matching option for suggestion');
            }
        } else if (this.isText) {
            // For text input, find the "Any Value" outcome
            const anyValueOutcome = this.question.outcomes.find(o => o.anyValue === true);
            const selectedOutcome = anyValueOutcome || this.question.outcomes[0];

            if (selectedOutcome) {
                // Auto-fill and advance
                this.dispatchAnswerSelected(
                    selectedOutcome.outcomeId,
                    this.aiSuggestion,
                    this.aiSuggestion
                );
            }
        }

        // Hide suggestion after accepting
        this.showSuggestion = false;
    }

    /**
     * Handle dismissing the AI suggestion
     * User wants to answer manually
     */
    handleDismissSuggestion() {
        console.log('[QuestionItem] Dismissing AI suggestion');
        this.showSuggestion = false;
        this.aiSuggestion = null;
    }

    /**
     * Get display text for suggestion based on question type
     */
    get suggestionDisplayText() {
        if (!this.aiSuggestion) return '';

        // Truncate long suggestions for display
        if (this.aiSuggestion.length > 60) {
            return this.aiSuggestion.substring(0, 60) + '...';
        }

        return this.aiSuggestion;
    }

    /**
     * Check if suggestion should be shown
     */
    get shouldShowSuggestion() {
        return this.isActive && this.showSuggestion && this.aiSuggestion && !this.isInstruction;
    }
}
