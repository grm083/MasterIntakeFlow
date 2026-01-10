import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import predictCaseClassification from '@salesforce/apex/IntakeProcessController.predictCaseClassification';
import applyAIClassification from '@salesforce/apex/IntakeProcessController.applyAIClassification';

/**
 * Pre-Classification Component
 *
 * Collects diagnostic answers and uses AI to predict case classification
 */
export default class PreClassification extends LightningElement {
    @api recordId; // Case ID
    @api autoApplyThreshold = 0.80; // Confidence threshold for auto-apply (80%)

    // State management
    @track currentScreen = 'intro'; // intro, questions, processing, results, error
    @track questions = [];
    @track result = {};
    @track errorMessage = '';
    @track isProcessing = false;

    // Computed properties for screen visibility
    get showIntro() { return this.currentScreen === 'intro'; }
    get showQuestions() { return this.currentScreen === 'questions'; }
    get showProcessing() { return this.currentScreen === 'processing'; }
    get showResults() { return this.currentScreen === 'results'; }
    get showError() { return this.currentScreen === 'error'; }

    // Progress indicator steps
    get progressSteps() {
        return [
            { label: 'Questions', value: 'step-1' },
            { label: 'Analysis', value: 'step-2' },
            { label: 'Complete', value: 'step-3' }
        ];
    }

    get currentStepName() {
        if (this.currentScreen === 'questions') return 'step-1';
        if (this.currentScreen === 'processing') return 'step-2';
        if (this.currentScreen === 'results') return 'step-3';
        return 'step-1';
    }

    // Submit button state
    get isSubmitDisabled() {
        return this.isProcessing || !this.areRequiredQuestionsAnswered();
    }

    // Results display
    get confidencePercentage() {
        return this.result.confidence ? Math.round(this.result.confidence * 100) : 0;
    }

    get confidenceBarStyle() {
        const percentage = this.confidencePercentage;
        let color = '#1c8200'; // Green for high confidence

        if (percentage < 60) {
            color = '#c23934'; // Red for low confidence
        } else if (percentage < 80) {
            color = '#ffb75d'; // Orange for medium confidence
        }

        return `width: ${percentage}%; background-color: ${color};`;
    }

    // ========== LIFECYCLE ==========

    connectedCallback() {
        console.log('[PreClassification] Component mounted for case:', this.recordId);
        this.initializeQuestions();
    }

    // ========== INITIALIZATION ==========

    /**
     * Initialize diagnostic questions
     */
    initializeQuestions() {
        this.questions = [
            {
                id: 'q1',
                number: 1,
                text: 'What is the primary issue or request?',
                type: 'radio',
                required: true,
                options: [
                    { label: 'Equipment is broken or malfunctioning', value: 'equipment_issue' },
                    { label: 'Need service or maintenance', value: 'service_request' },
                    { label: 'Billing or account question', value: 'billing_issue' },
                    { label: 'General inquiry or other', value: 'general_inquiry' }
                ],
                answer: ''
            },
            {
                id: 'q2',
                number: 2,
                text: 'Please describe the issue in more detail:',
                type: 'text',
                placeholder: 'E.g., "Compactor is making loud noise and not compacting properly"',
                required: true,
                answer: ''
            },
            {
                id: 'q3',
                number: 3,
                text: 'What is the urgency level?',
                type: 'radio',
                required: true,
                options: [
                    { label: 'Emergency - Immediate attention required', value: 'emergency' },
                    { label: 'Urgent - Needs attention today', value: 'urgent' },
                    { label: 'Standard - Can wait 1-2 days', value: 'standard' },
                    { label: 'Low - No immediate rush', value: 'low' }
                ],
                answer: ''
            },
            {
                id: 'q4',
                number: 4,
                text: 'Is this related to a specific piece of equipment?',
                type: 'combobox',
                required: false,
                options: [
                    { label: 'Compactor', value: 'compactor' },
                    { label: 'Baler', value: 'baler' },
                    { label: 'Container', value: 'container' },
                    { label: 'Roll-off', value: 'rolloff' },
                    { label: 'Cart', value: 'cart' },
                    { label: 'Other/Not applicable', value: 'other' }
                ],
                answer: ''
            },
            {
                id: 'q5',
                number: 5,
                text: 'Any additional context or details?',
                type: 'text',
                placeholder: 'Optional: Any other information that might help...',
                required: false,
                answer: ''
            }
        ];

        // Add computed properties for question types
        this.questions = this.questions.map(q => ({
            ...q,
            isRadio: q.type === 'radio',
            isText: q.type === 'text',
            isCombobox: q.type === 'combobox'
        }));
    }

    /**
     * Check if all required questions are answered
     */
    areRequiredQuestionsAnswered() {
        return this.questions
            .filter(q => q.required)
            .every(q => q.answer && q.answer.trim() !== '');
    }

    // ========== EVENT HANDLERS ==========

    /**
     * User clicks "Get Started" button
     */
    handleStartAssessment() {
        console.log('[PreClassification] Starting assessment');
        this.currentScreen = 'questions';
    }

    /**
     * User clicks "Back" button
     */
    handleBack() {
        this.currentScreen = 'intro';
    }

    /**
     * Handle answer change for any question
     */
    handleAnswerChange(event) {
        const questionId = event.target.dataset.questionId || event.target.name;
        const answer = event.detail.value || event.target.value;

        console.log('[PreClassification] Answer changed:', questionId, answer);

        // Update question answer
        const question = this.questions.find(q => q.id === questionId);
        if (question) {
            question.answer = answer;
        }

        // Trigger reactivity
        this.questions = [...this.questions];
    }

    /**
     * User submits assessment for AI analysis
     */
    async handleSubmitAssessment() {
        console.log('[PreClassification] Submitting assessment');

        // Validate required questions
        if (!this.areRequiredQuestionsAnswered()) {
            this.showToast('Incomplete', 'Please answer all required questions', 'warning');
            return;
        }

        // Switch to processing screen
        this.currentScreen = 'processing';
        this.isProcessing = true;

        try {
            // Build answers JSON
            const answers = this.questions
                .filter(q => q.answer && q.answer.trim() !== '')
                .map(q => ({
                    questionText: q.text,
                    answerText: q.answer
                }));

            console.log('[PreClassification] Calling AI with answers:', answers);

            // Call Apex method
            const result = await predictCaseClassification({
                caseId: this.recordId,
                preIntakeAnswersJSON: JSON.stringify(answers),
                autoApplyThreshold: this.autoApplyThreshold
            });

            console.log('[PreClassification] AI Result:', result);

            if (result.success) {
                this.result = result;
                this.currentScreen = 'results';

                // Show toast for auto-applied
                if (result.autoApplied) {
                    this.showToast('Success', result.message, 'success');
                }
            } else {
                // Show error
                this.errorMessage = result.errorMessage || 'Classification failed';
                this.currentScreen = 'error';
                this.showToast('Error', this.errorMessage, 'error');
            }

        } catch (error) {
            console.error('[PreClassification] Error:', error);
            this.errorMessage = error.body?.message || 'An unexpected error occurred';
            this.currentScreen = 'error';
            this.showToast('Error', this.errorMessage, 'error');

        } finally {
            this.isProcessing = false;
        }
    }

    /**
     * User accepts AI classification
     */
    async handleAcceptClassification() {
        console.log('[PreClassification] User accepted classification');
        this.isProcessing = true;

        try {
            const success = await applyAIClassification({
                caseId: this.recordId,
                caseType: this.result.caseType,
                caseSubType: this.result.caseSubType,
                caseReason: this.result.caseReason,
                confidence: this.result.confidence
            });

            if (success) {
                this.showToast('Success', 'Classification applied successfully', 'success');
                this.result.autoApplied = true; // Update to show continue button
            } else {
                throw new Error('Failed to apply classification');
            }

        } catch (error) {
            console.error('[PreClassification] Error applying classification:', error);
            this.showToast('Error', 'Failed to apply classification', 'error');

        } finally {
            this.isProcessing = false;
        }
    }

    /**
     * User chooses manual classification
     */
    handleManualClassification() {
        console.log('[PreClassification] User chose manual classification');

        // Dispatch event to parent to handle manual flow
        this.dispatchEvent(new CustomEvent('manualclassification', {
            detail: {
                answers: this.questions.map(q => ({
                    questionText: q.text,
                    answerText: q.answer
                }))
            }
        }));
    }

    /**
     * Continue to main intake flow
     */
    handleContinue() {
        console.log('[PreClassification] Continuing to main intake');

        // Dispatch event to parent
        this.dispatchEvent(new CustomEvent('classificationcomplete', {
            detail: {
                classification: {
                    caseType: this.result.caseType,
                    caseSubType: this.result.caseSubType,
                    caseReason: this.result.caseReason
                },
                confidence: this.result.confidence,
                autoApplied: this.result.autoApplied
            }
        }));
    }

    /**
     * Retry after error
     */
    handleRetry() {
        console.log('[PreClassification] Retrying assessment');
        this.currentScreen = 'questions';
        this.errorMessage = '';
    }

    // ========== UTILITY METHODS ==========

    /**
     * Show toast notification
     */
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}
