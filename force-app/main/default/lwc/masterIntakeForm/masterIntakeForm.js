import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initializeIntake from '@salesforce/apex/IntakeProcessController.initializeIntake';
import getNextQuestionBatch from '@salesforce/apex/IntakeProcessController.getNextQuestionBatch';
import completeIntake from '@salesforce/apex/IntakeProcessController.completeIntake';

export default class MasterIntakeForm extends LightningElement {
    @api recordId; // Case ID from record page

    // State object
    @track state = {
        // CPQ
        cpqEligible: false,
        cpqCheckComplete: false,

        // Case context
        caseContext: null,

        // Question flow
        questionHistory: [],
        currentQuestionId: null,
        nextQuestionCache: new Map(),

        // Completion
        allQuestionsAnswered: false,
        finalOutcome: null,
        showSummary: false,

        // UI state
        isLoading: true,
        error: null
    };

    // ========== LIFECYCLE HOOKS ==========

    connectedCallback() {
        this.loadIntakeData();
    }

    // ========== INITIALIZATION ==========

    async loadIntakeData() {
        try {
            this.state.isLoading = true;

            const data = await initializeIntake({ caseId: this.recordId });

            // Store case context
            this.state.caseContext = data.caseContext;
            this.state.cpqCheckComplete = true;

            // Check CPQ eligibility FIRST
            if (data.cpqEligible) {
                this.state.cpqEligible = true;
                this.state.isLoading = false;
                return;
            }

            // Check if there are questions configured
            if (!data.firstQuestion) {
                this.state.error = 'No intake questions configured for this case type.';
                this.state.isLoading = false;
                return;
            }

            // Store first question in history
            const firstQuestion = {
                ...data.firstQuestion,
                isComplete: false,
                isEditable: false,
                selectedOutcomeId: null,
                selectedOutcomeText: null,
                answerValue: null
            };

            this.state.questionHistory = [firstQuestion];
            this.state.currentQuestionId = firstQuestion.questionId;

            // Cache next questions
            if (data.nextQuestionsCache) {
                Object.keys(data.nextQuestionsCache).forEach(key => {
                    this.state.nextQuestionCache.set(key, data.nextQuestionsCache[key]);
                });
            }

            this.state.isLoading = false;

        } catch (error) {
            this.state.error = error.body?.message || 'Error loading intake data';
            this.state.isLoading = false;
            this.showErrorToast('Error', this.state.error);
        }
    }

    // ========== ANSWER HANDLING ==========

    handleAnswerSelected(event) {
        const { questionId, outcomeId, outcomeText, answerValue } = event.detail;

        // Find question in history
        const questionIndex = this.state.questionHistory.findIndex(
            q => q.questionId === questionId
        );

        if (questionIndex === -1) {
            console.error('Question not found in history:', questionId);
            return;
        }

        // Update question with answer
        const question = this.state.questionHistory[questionIndex];
        question.selectedOutcomeId = outcomeId;
        question.selectedOutcomeText = outcomeText;
        question.answerValue = answerValue;
        question.isComplete = true;
        question.isEditable = true;

        // Find the selected outcome
        const outcome = question.outcomes.find(o => o.outcomeId === outcomeId);

        if (!outcome) {
            console.error('Outcome not found:', outcomeId);
            return;
        }

        // Check if this is the end of the flow
        if (outcome.isTerminal) {
            this.handleIntakeComplete(outcome);
            return;
        }

        // Load next question
        this.loadNextQuestion(outcome.nextQuestionId, questionIndex);
    }

    async loadNextQuestion(nextQuestionId, afterIndex) {
        try {
            // Remove any questions after this point (in case of edit)
            this.state.questionHistory = this.state.questionHistory.slice(0, afterIndex + 1);

            // Check cache first
            let nextQuestion = this.state.nextQuestionCache.get(nextQuestionId);

            if (!nextQuestion) {
                // Not in cache, fetch it
                this.state.isLoading = true;

                const batchData = await getNextQuestionBatch({
                    outcomeId: this.state.questionHistory[afterIndex].selectedOutcomeId
                });

                // Add to cache
                Object.keys(batchData).forEach(key => {
                    this.state.nextQuestionCache.set(key, batchData[key]);
                });

                nextQuestion = this.state.nextQuestionCache.get(nextQuestionId);
                this.state.isLoading = false;

                if (!nextQuestion) {
                    throw new Error('Next question not found in batch data');
                }
            }

            // Add to history
            const newQuestion = {
                ...nextQuestion,
                isComplete: false,
                isEditable: false,
                selectedOutcomeId: null,
                selectedOutcomeText: null,
                answerValue: null
            };

            this.state.questionHistory = [...this.state.questionHistory, newQuestion];
            this.state.currentQuestionId = nextQuestionId;

            // Scroll to new question
            this.scrollToBottom();

        } catch (error) {
            this.state.isLoading = false;
            this.showErrorToast('Error', 'Failed to load next question');
            console.error('Error loading next question:', error);
        }
    }

    // ========== EDIT HANDLING ==========

    handleEditQuestion(event) {
        const { questionId } = event.detail;

        // Find question index
        const questionIndex = this.state.questionHistory.findIndex(
            q => q.questionId === questionId
        );

        if (questionIndex === -1) {
            console.error('Question not found for edit:', questionId);
            return;
        }

        // Remove all questions after this one
        this.state.questionHistory = this.state.questionHistory.slice(0, questionIndex + 1);

        // Clear the answer on this question
        const question = this.state.questionHistory[questionIndex];
        question.selectedOutcomeId = null;
        question.selectedOutcomeText = null;
        question.answerValue = null;
        question.isComplete = false;
        question.isEditable = false;

        this.state.currentQuestionId = questionId;
        this.state.allQuestionsAnswered = false;
        this.state.showSummary = false;

        // Scroll to edited question
        setTimeout(() => {
            this.scrollToQuestion(questionIndex);
        }, 100);
    }

    // ========== COMPLETION HANDLING ==========

    handleIntakeComplete(finalOutcome) {
        this.state.allQuestionsAnswered = true;
        this.state.finalOutcome = finalOutcome;
        this.state.currentQuestionId = null;

        // Show summary screen
        this.state.showSummary = true;

        // Scroll to top of summary
        setTimeout(() => {
            this.scrollToTop();
        }, 100);
    }

    handleBackFromSummary() {
        this.state.showSummary = false;
        this.state.allQuestionsAnswered = false;

        // Re-activate last question
        if (this.state.questionHistory.length > 0) {
            const lastQuestion = this.state.questionHistory[this.state.questionHistory.length - 1];
            lastQuestion.isComplete = false;
            lastQuestion.isEditable = false;
            this.state.currentQuestionId = lastQuestion.questionId;
        }
    }

    async handleFinalSubmit(event) {
        try {
            this.state.isLoading = true;

            const additionalComments = event.detail.additionalComments || '';

            // Build answers JSON
            const answers = this.state.questionHistory.map(q => ({
                question: q.questionText,
                answer: q.answerValue || q.selectedOutcomeText
            }));

            // Add additional comments if provided
            if (additionalComments.trim()) {
                answers.push({
                    question: 'Additional Comments',
                    answer: additionalComments
                });
            }

            const result = await completeIntake({
                caseId: this.recordId,
                answersJSON: JSON.stringify(answers),
                finalOutcomeId: this.state.finalOutcome.outcomeId
            });

            if (result.success) {
                this.showSuccessToast('Success', 'Intake completed successfully');

                // Refresh the page to hide component and show updated case
                setTimeout(() => {
                    // Use NavigationMixin or force refresh
                    eval("$A.get('e.force:refreshView').fire();");
                }, 1000);

            } else {
                throw new Error(result.errorMessage);
            }

        } catch (error) {
            this.state.isLoading = false;
            this.showErrorToast('Error', error.body?.message || 'Failed to complete intake');
            console.error('Error completing intake:', error);
        }
    }

    // ========== UTILITY METHODS ==========

    scrollToBottom() {
        setTimeout(() => {
            const container = this.template.querySelector('.question-stack');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }, 100);
    }

    scrollToTop() {
        setTimeout(() => {
            const container = this.template.querySelector('.intake-container');
            if (container) {
                container.scrollTop = 0;
            }
        }, 100);
    }

    scrollToQuestion(index) {
        setTimeout(() => {
            const questions = this.template.querySelectorAll('c-question-item');
            if (questions && questions[index]) {
                questions[index].scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        }, 100);
    }

    showSuccessToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'success'
            })
        );
    }

    showErrorToast(title, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    // ========== GETTERS ==========

    get showCPQScreen() {
        return this.state.cpqCheckComplete && this.state.cpqEligible;
    }

    get showQuestions() {
        return !this.state.cpqEligible &&
               this.state.questionHistory.length > 0 &&
               !this.state.showSummary;
    }

    get showAnswerSummary() {
        return this.state.showSummary;
    }

    get showError() {
        return this.state.error !== null;
    }

    get showLoading() {
        return this.state.isLoading && !this.showQuestions && !this.showCPQScreen;
    }

    get caseContextDisplay() {
        if (!this.state.caseContext) return '';

        const parts = [];
        if (this.state.caseContext.caseType) parts.push(this.state.caseContext.caseType);
        if (this.state.caseContext.caseSubType) parts.push(this.state.caseContext.caseSubType);
        if (this.state.caseContext.caseReason) parts.push(this.state.caseContext.caseReason);

        return parts.join(' → ');
    }

    get completedCount() {
        return this.state.questionHistory.filter(q => q.isComplete).length;
    }

    get questionCountDisplay() {
        const completed = this.completedCount;
        return completed === 1 ? '1 question answered' : `${completed} questions answered`;
    }
}
