import LightningModal from 'lightning/modal';
import { api, track } from 'lwc';
import initializeIntake from '@salesforce/apex/IntakeProcessController.initializeIntake';
import getNextQuestionBatch from '@salesforce/apex/IntakeProcessController.getNextQuestionBatch';
import completeIntake from '@salesforce/apex/IntakeProcessController.completeIntake';

/**
 * Master Intake Form - Modal dialog component
 *
 * This component opens as a modal dialog to provide a focused intake experience.
 *
 * DEBUGGING:
 * - Open browser DevTools Console (F12)
 * - All log messages are prefixed with [MasterIntakeForm]
 * - Look for errors (red) and warnings (yellow)
 * - Check "Initialization complete" message for final state
 * - Verify "showQuestions getter" returns true when questions should display
 */
export default class MasterIntakeForm extends LightningModal {
    // Record ID is passed as a parameter when opening the modal
    @api recordId;

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
        console.log('[MasterIntakeForm] connectedCallback - Component mounted');
        console.log('[MasterIntakeForm] recordId:', this.recordId);
        this.loadIntakeData();
    }

    renderedCallback() {
        console.log('[MasterIntakeForm] renderedCallback - Component rendered');
        console.log('[MasterIntakeForm] Visible sections:', {
            showLoading: this.showLoading,
            showCPQScreen: this.showCPQScreen,
            showQuestions: this.showQuestions,
            showAnswerSummary: this.showAnswerSummary,
            showError: this.showError
        });
    }

    // ========== INITIALIZATION ==========

    async loadIntakeData() {
        console.log('[MasterIntakeForm] loadIntakeData - Starting initialization');
        console.log('[MasterIntakeForm] Case ID:', this.recordId);

        try {
            this.state.isLoading = true;
            console.log('[MasterIntakeForm] Loading state set to true');

            console.log('[MasterIntakeForm] Calling initializeIntake Apex method...');
            const data = await initializeIntake({ caseId: this.recordId });
            console.log('[MasterIntakeForm] Received data from Apex:', JSON.stringify(data, null, 2));

            // Store case context
            this.state.caseContext = data.caseContext;
            this.state.cpqCheckComplete = true;
            console.log('[MasterIntakeForm] Case context:', this.state.caseContext);

            // Check CPQ eligibility FIRST
            if (data.cpqEligible) {
                console.log('[MasterIntakeForm] Case is CPQ eligible - showing CPQ screen');
                this.state.cpqEligible = true;
                this.state.isLoading = false;
                return;
            }
            console.log('[MasterIntakeForm] Case is NOT CPQ eligible - proceeding with questions');

            // Check if there are questions configured
            if (!data.firstQuestion) {
                console.error('[MasterIntakeForm] No first question returned from Apex');
                console.error('[MasterIntakeForm] Case Type:', data.caseContext?.caseType);
                console.error('[MasterIntakeForm] Case Sub-Type:', data.caseContext?.caseSubType);
                console.error('[MasterIntakeForm] Case Reason:', data.caseContext?.caseReason);
                this.state.error = 'No intake questions configured for this case type.';
                this.state.isLoading = false;
                return;
            }

            console.log('[MasterIntakeForm] First question received:', {
                id: data.firstQuestion.questionId,
                text: data.firstQuestion.questionText,
                inputType: data.firstQuestion.inputType,
                outcomesCount: data.firstQuestion.outcomes?.length
            });

            // Store first question in history
            const firstQuestion = {
                ...data.firstQuestion,
                isComplete: false,
                isEditable: false,
                isActive: true,
                selectedOutcomeId: null,
                selectedOutcomeText: null,
                answerValue: null
            };

            this.state.questionHistory = [firstQuestion];
            this.state.currentQuestionId = firstQuestion.questionId;
            this.updateActiveStates();
            console.log('[MasterIntakeForm] Question history initialized with first question');
            console.log('[MasterIntakeForm] Current question ID:', this.state.currentQuestionId);

            // Cache next questions
            if (data.nextQuestionsCache) {
                console.log('[MasterIntakeForm] Caching next questions. Keys:', Object.keys(data.nextQuestionsCache));
                Object.keys(data.nextQuestionsCache).forEach(key => {
                    this.state.nextQuestionCache.set(key, data.nextQuestionsCache[key]);
                });
                console.log('[MasterIntakeForm] Cache size:', this.state.nextQuestionCache.size);
            } else {
                console.log('[MasterIntakeForm] No nextQuestionsCache in response');
            }

            this.state.isLoading = false;
            console.log('[MasterIntakeForm] Initialization complete. State:', {
                cpqEligible: this.state.cpqEligible,
                questionHistoryLength: this.state.questionHistory.length,
                currentQuestionId: this.state.currentQuestionId,
                cacheSize: this.state.nextQuestionCache.size,
                isLoading: this.state.isLoading,
                error: this.state.error
            });

        } catch (error) {
            console.error('[MasterIntakeForm] Error in loadIntakeData:', error);
            console.error('[MasterIntakeForm] Error message:', error.body?.message || error.message);
            console.error('[MasterIntakeForm] Error stack:', error.stack);
            console.error('[MasterIntakeForm] Full error object:', JSON.stringify(error, null, 2));

            this.state.error = error.body?.message || 'Error loading intake data';
            this.state.isLoading = false;
            // Error displayed inline via showError getter
        }
    }

    // ========== ANSWER HANDLING ==========

    handleAnswerSelected(event) {
        console.log('[MasterIntakeForm] handleAnswerSelected - Answer selected');
        const { questionId, outcomeId, outcomeText, answerValue } = event.detail;
        console.log('[MasterIntakeForm] Answer details:', {
            questionId,
            outcomeId,
            outcomeText,
            answerValue
        });

        // Find question in history
        const questionIndex = this.state.questionHistory.findIndex(
            q => q.questionId === questionId
        );

        if (questionIndex === -1) {
            console.error('[MasterIntakeForm] Question not found in history:', questionId);
            return;
        }

        console.log('[MasterIntakeForm] Found question at index:', questionIndex);

        // Update question with answer
        const question = this.state.questionHistory[questionIndex];
        question.selectedOutcomeId = outcomeId;
        question.selectedOutcomeText = outcomeText;
        question.answerValue = answerValue;
        question.isComplete = true;
        question.isEditable = true;

        console.log('[MasterIntakeForm] Updated question with answer');

        // Find the selected outcome
        const outcome = question.outcomes.find(o => o.outcomeId === outcomeId);

        if (!outcome) {
            console.error('[MasterIntakeForm] Outcome not found:', outcomeId);
            return;
        }

        console.log('[MasterIntakeForm] Selected outcome:', {
            outcomeId: outcome.outcomeId,
            outcomeText: outcome.outcomeText,
            isTerminal: outcome.isTerminal,
            hasNextQuestion: outcome.hasNextQuestion,
            nextQuestionId: outcome.nextQuestionId
        });

        // Check if this is the end of the flow
        if (outcome.isTerminal) {
            console.log('[MasterIntakeForm] Terminal outcome - completing intake');
            this.handleIntakeComplete(outcome);
            return;
        }

        // Load next question
        console.log('[MasterIntakeForm] Loading next question:', outcome.nextQuestionId);
        this.loadNextQuestion(outcome.nextQuestionId, questionIndex);
    }

    async loadNextQuestion(nextQuestionId, afterIndex) {
        console.log('[MasterIntakeForm] loadNextQuestion - Starting');
        console.log('[MasterIntakeForm] Next question ID:', nextQuestionId);
        console.log('[MasterIntakeForm] After index:', afterIndex);

        try {
            // Remove any questions after this point (in case of edit)
            this.state.questionHistory = this.state.questionHistory.slice(0, afterIndex + 1);
            console.log('[MasterIntakeForm] Trimmed question history to:', this.state.questionHistory.length);

            // Check cache first
            let nextQuestion = this.state.nextQuestionCache.get(nextQuestionId);
            console.log('[MasterIntakeForm] Cache lookup result:', nextQuestion ? 'FOUND' : 'NOT FOUND');

            if (!nextQuestion) {
                // Not in cache, fetch it
                console.log('[MasterIntakeForm] Fetching question from server...');
                this.state.isLoading = true;

                const selectedOutcomeId = this.state.questionHistory[afterIndex].selectedOutcomeId;
                console.log('[MasterIntakeForm] Selected outcome ID:', selectedOutcomeId);

                const batchData = await getNextQuestionBatch({
                    outcomeId: selectedOutcomeId
                });

                console.log('[MasterIntakeForm] Received batch data. Keys:', Object.keys(batchData));

                // Add to cache
                Object.keys(batchData).forEach(key => {
                    this.state.nextQuestionCache.set(key, batchData[key]);
                });
                console.log('[MasterIntakeForm] Updated cache size:', this.state.nextQuestionCache.size);

                nextQuestion = this.state.nextQuestionCache.get(nextQuestionId);
                this.state.isLoading = false;

                if (!nextQuestion) {
                    console.error('[MasterIntakeForm] Question still not found after fetch!');
                    console.error('[MasterIntakeForm] Looking for:', nextQuestionId);
                    console.error('[MasterIntakeForm] Available keys:', Array.from(this.state.nextQuestionCache.keys()));
                    throw new Error('Next question not found in batch data');
                }
            }

            console.log('[MasterIntakeForm] Next question details:', {
                id: nextQuestion.questionId,
                text: nextQuestion.questionText,
                inputType: nextQuestion.inputType,
                outcomesCount: nextQuestion.outcomes?.length
            });

            // Add to history
            const newQuestion = {
                ...nextQuestion,
                isComplete: false,
                isEditable: false,
                isActive: true,
                selectedOutcomeId: null,
                selectedOutcomeText: null,
                answerValue: null
            };

            this.state.questionHistory = [...this.state.questionHistory, newQuestion];
            this.state.currentQuestionId = nextQuestionId;
            this.updateActiveStates();
            console.log('[MasterIntakeForm] Added question to history. New length:', this.state.questionHistory.length);
            console.log('[MasterIntakeForm] Current question ID:', this.state.currentQuestionId);

            // Scroll to new question
            this.scrollToBottom();

        } catch (error) {
            this.state.isLoading = false;
            console.error('[MasterIntakeForm] Error in loadNextQuestion:', error);
            console.error('[MasterIntakeForm] Error message:', error.message);
            console.error('[MasterIntakeForm] Error stack:', error.stack);
            this.state.error = 'Failed to load next question';
        }
    }

    // ========== EDIT HANDLING ==========

    handleEditQuestion(event) {
        console.log('[MasterIntakeForm] handleEditQuestion - Edit requested');
        const { questionId } = event.detail;
        console.log('[MasterIntakeForm] Question ID to edit:', questionId);

        // Find question index
        const questionIndex = this.state.questionHistory.findIndex(
            q => q.questionId === questionId
        );

        if (questionIndex === -1) {
            console.error('[MasterIntakeForm] Question not found for edit:', questionId);
            return;
        }

        console.log('[MasterIntakeForm] Found question at index:', questionIndex);

        // Remove all questions after this one
        this.state.questionHistory = this.state.questionHistory.slice(0, questionIndex + 1);
        console.log('[MasterIntakeForm] Trimmed history to:', this.state.questionHistory.length);

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
        this.updateActiveStates();

        console.log('[MasterIntakeForm] Question cleared and reactivated');

        // Scroll to edited question
        setTimeout(() => {
            this.scrollToQuestion(questionIndex);
        }, 100);
    }

    // ========== COMPLETION HANDLING ==========

    handleIntakeComplete(finalOutcome) {
        console.log('[MasterIntakeForm] handleIntakeComplete - All questions answered');
        console.log('[MasterIntakeForm] Final outcome:', {
            outcomeId: finalOutcome.outcomeId,
            outcomeText: finalOutcome.outcomeText,
            outcomeStatement: finalOutcome.outcomeStatement
        });

        this.state.allQuestionsAnswered = true;
        this.state.finalOutcome = finalOutcome;
        this.state.currentQuestionId = null;

        // Show summary screen
        this.state.showSummary = true;
        console.log('[MasterIntakeForm] Showing summary screen');

        // Scroll to top of summary
        setTimeout(() => {
            this.scrollToTop();
        }, 100);
    }

    handleBackFromSummary() {
        console.log('[MasterIntakeForm] handleBackFromSummary - Returning to questions');
        this.state.showSummary = false;
        this.state.allQuestionsAnswered = false;

        // Re-activate last question
        if (this.state.questionHistory.length > 0) {
            const lastQuestion = this.state.questionHistory[this.state.questionHistory.length - 1];
            lastQuestion.isComplete = false;
            lastQuestion.isEditable = false;
            this.state.currentQuestionId = lastQuestion.questionId;
            this.updateActiveStates();
            console.log('[MasterIntakeForm] Re-activated last question:', lastQuestion.questionId);
        }
    }

    async handleFinalSubmit(event) {
        console.log('[MasterIntakeForm] handleFinalSubmit - Submitting intake');
        try {
            this.state.isLoading = true;

            const additionalComments = event.detail.additionalComments || '';
            console.log('[MasterIntakeForm] Additional comments:', additionalComments);

            // Build answers JSON
            const answers = this.state.questionHistory.map(q => ({
                question: q.questionText,
                answer: q.answerValue || q.selectedOutcomeText
            }));

            console.log('[MasterIntakeForm] Built answers array. Count:', answers.length);

            // Add additional comments if provided
            if (additionalComments.trim()) {
                answers.push({
                    question: 'Additional Comments',
                    answer: additionalComments
                });
            }

            console.log('[MasterIntakeForm] Calling completeIntake Apex method...');
            const result = await completeIntake({
                caseId: this.recordId,
                answersJSON: JSON.stringify(answers),
                finalOutcomeId: this.state.finalOutcome.outcomeId
            });

            console.log('[MasterIntakeForm] Received completion result:', result);

            if (result.success) {
                console.log('[MasterIntakeForm] Intake completed successfully');
                console.log('[MasterIntakeForm] Comment ID:', result.commentId);
                console.log('[MasterIntakeForm] Task ID:', result.taskId);

                // Close the modal and signal success
                // Launcher will display success toast
                setTimeout(() => {
                    console.log('[MasterIntakeForm] Closing modal and refreshing...');
                    this.close('success');
                }, 500);

            } else {
                console.error('[MasterIntakeForm] Completion failed:', result.errorMessage);
                throw new Error(result.errorMessage);
            }

        } catch (error) {
            this.state.isLoading = false;
            console.error('[MasterIntakeForm] Error in handleFinalSubmit:', error);
            console.error('[MasterIntakeForm] Error message:', error.body?.message || error.message);
            console.error('[MasterIntakeForm] Error stack:', error.stack);
            this.state.error = error.body?.message || 'Failed to complete intake';
        }
    }

    // ========== MODAL CONTROL ==========

    /**
     * Handle modal close button click
     */
    handleClose() {
        console.log('[MasterIntakeForm] handleClose - Closing modal');
        this.close('cancelled');
    }

    // ========== UTILITY METHODS ==========

    /**
     * Update isActive property on all questions based on currentQuestionId
     * This is needed because LWC doesn't support conditional expressions in templates
     */
    updateActiveStates() {
        console.log('[MasterIntakeForm] updateActiveStates - Updating question active states');
        this.state.questionHistory.forEach(question => {
            question.isActive = (question.questionId === this.state.currentQuestionId);
        });
        console.log('[MasterIntakeForm] Active question ID:', this.state.currentQuestionId);
    }

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

    // ========== GETTERS ==========

    get showCPQScreen() {
        const result = this.state.cpqCheckComplete && this.state.cpqEligible;
        console.log('[MasterIntakeForm] showCPQScreen getter:', {
            result,
            cpqCheckComplete: this.state.cpqCheckComplete,
            cpqEligible: this.state.cpqEligible
        });
        return result;
    }

    get showQuestions() {
        const result = !this.state.cpqEligible &&
               this.state.questionHistory.length > 0 &&
               !this.state.showSummary;
        console.log('[MasterIntakeForm] showQuestions getter:', {
            result,
            cpqEligible: this.state.cpqEligible,
            questionHistoryLength: this.state.questionHistory.length,
            showSummary: this.state.showSummary
        });
        return result;
    }

    get showAnswerSummary() {
        const result = this.state.showSummary;
        console.log('[MasterIntakeForm] showAnswerSummary getter:', result);
        return result;
    }

    get showError() {
        const result = this.state.error !== null;
        console.log('[MasterIntakeForm] showError getter:', {
            result,
            error: this.state.error
        });
        return result;
    }

    get showLoading() {
        const result = this.state.isLoading && !this.showQuestions && !this.showCPQScreen;
        console.log('[MasterIntakeForm] showLoading getter:', {
            result,
            isLoading: this.state.isLoading,
            showQuestions: this.showQuestions,
            showCPQScreen: this.showCPQScreen
        });
        return result;
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
