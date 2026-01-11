import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import predictCaseClassification from '@salesforce/apex/IntakeProcessController.predictCaseClassification';
import applyAIClassification from '@salesforce/apex/IntakeProcessController.applyAIClassification';
import MasterIntakeFormModal from 'c/masterIntakeForm';

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
                text: 'Please describe the issue or request:',
                type: 'text',
                placeholder: 'E.g., "Compactor is making loud noise and not compacting properly" or "Need to schedule pickup for next week"',
                required: true,
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
     * User chooses manual classification - Opens Master Intake Form modal
     */
    async handleManualClassification() {
        console.log('[PreClassification] User chose manual classification - opening intake modal');

        try {
            // Open Master Intake Form modal for manual classification
            const result = await MasterIntakeFormModal.open({
                size: 'large',
                description: 'Master Intake Flow',
                recordId: this.recordId
            });

            console.log('[PreClassification] Modal closed with result:', result);

            // If intake was completed successfully, show success toast and refresh
            if (result === 'success') {
                console.log('[PreClassification] Intake completed successfully');

                // Show success toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Master Intake completed successfully',
                        variant: 'success'
                    })
                );

                // Refresh the page to show updated case
                setTimeout(() => {
                    console.log('[PreClassification] Refreshing page...');
                    eval("$A.get('e.force:refreshView').fire();");
                }, 500);
            }

            // Dispatch event to parent to handle manual flow
            this.dispatchEvent(new CustomEvent('manualclassification', {
                detail: {
                    answers: this.questions.map(q => ({
                        questionText: q.text,
                        answerText: q.answer
                    })),
                    intakeCompleted: result === 'success'
                }
            }));

        } catch (error) {
            console.error('[PreClassification] Error opening modal:', error);

            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to open Master Intake Flow',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    /**
     * Continue to main intake flow - Opens Master Intake Form modal
     */
    async handleContinue() {
        console.log('[PreClassification] Continuing to main intake - opening modal');

        try {
            // Open Master Intake Form modal
            const result = await MasterIntakeFormModal.open({
                size: 'large',
                description: 'Master Intake Flow',
                recordId: this.recordId
            });

            console.log('[PreClassification] Modal closed with result:', result);

            // If intake was completed successfully, show success toast and refresh
            if (result === 'success') {
                console.log('[PreClassification] Intake completed successfully');

                // Show success toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Master Intake completed successfully',
                        variant: 'success'
                    })
                );

                // Refresh the page to show updated case
                setTimeout(() => {
                    console.log('[PreClassification] Refreshing page...');
                    eval("$A.get('e.force:refreshView').fire();");
                }, 500);
            }

            // Dispatch event to parent (for any additional handling)
            this.dispatchEvent(new CustomEvent('classificationcomplete', {
                detail: {
                    classification: {
                        caseType: this.result.caseType,
                        caseSubType: this.result.caseSubType,
                        caseReason: this.result.caseReason
                    },
                    confidence: this.result.confidence,
                    autoApplied: this.result.autoApplied,
                    intakeCompleted: result === 'success'
                }
            }));

        } catch (error) {
            console.error('[PreClassification] Error opening modal:', error);

            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to open Master Intake Flow',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
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
