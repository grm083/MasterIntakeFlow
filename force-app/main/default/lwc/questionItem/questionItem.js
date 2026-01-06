import { LightningElement, api } from 'lwc';

export default class QuestionItem extends LightningElement {
    @api question;      // Full question object with outcomes
    @api isActive;      // Whether this is the current/active question
    @api index;         // Position in question history (0-based)

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
     * Handle instruction display
     * Auto-advances after brief delay to allow user to read
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
}
