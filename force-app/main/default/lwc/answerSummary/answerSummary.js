import { LightningElement, api } from 'lwc';

export default class AnswerSummary extends LightningElement {
    @api questions;      // Array of all answered questions
    @api finalOutcome;   // The final outcome object
    @api isLoading;      // Whether submission is in progress

    additionalComments = '';

    // ========== COMPUTED PROPERTIES ==========

    get hasQuestions() {
        return this.questions && this.questions.length > 0;
    }

    get questionSummaryList() {
        if (!this.hasQuestions) return [];

        return this.questions.map((q, index) => ({
            id: q.questionId,
            number: index + 1,
            question: q.questionText,
            answer: q.answerValue || q.selectedOutcomeText || 'No answer provided'
        }));
    }

    get outcomeStatement() {
        return this.finalOutcome?.outcomeStatement || 'Your intake has been completed.';
    }

    get hasActions() {
        return this.finalOutcome?.actions && this.hasAnyAction;
    }

    get hasAnyAction() {
        if (!this.finalOutcome?.actions) return false;

        const actions = this.finalOutcome.actions;
        return actions.updateCaseStatus ||
               actions.updateCaseRecordType ||
               actions.assignToQueue ||
               actions.createTask ||
               actions.assignToCurrentUser;
    }

    get actionsList() {
        if (!this.hasActions) return [];

        const actions = this.finalOutcome.actions;
        const list = [];

        if (actions.updateCaseRecordType && actions.caseRecordType) {
            list.push({
                id: 'recordType',
                icon: 'utility:change_record_type',
                label: 'Update Case Record Type',
                value: actions.caseRecordType
            });
        }

        if (actions.updateCaseStatus && actions.caseStatus) {
            list.push({
                id: 'status',
                icon: 'utility:change_request',
                label: 'Update Case Status',
                value: actions.caseStatus
            });
        }

        if (actions.queueAssigned) {
            list.push({
                id: 'queue',
                icon: 'utility:routing_offline',
                label: 'Assign to Queue',
                value: actions.queueAssigned
            });
        }

        if (actions.teamName) {
            list.push({
                id: 'team',
                icon: 'utility:groups',
                label: 'Assign to Team',
                value: actions.teamName
            });
        }

        if (actions.assignToCurrentUser) {
            list.push({
                id: 'user',
                icon: 'utility:user',
                label: 'Assign Case',
                value: 'Current User'
            });
        }

        if (actions.createTask && actions.taskType) {
            list.push({
                id: 'task',
                icon: 'utility:task',
                label: 'Create Task',
                value: actions.taskType
            });
        }

        return list;
    }

    get submitButtonLabel() {
        return this.isLoading ? 'Submitting...' : 'Complete Intake';
    }

    get submitButtonDisabled() {
        return this.isLoading;
    }

    // ========== EVENT HANDLERS ==========

    handleCommentsChange(event) {
        this.additionalComments = event.target.value;
    }

    handleBackClick() {
        const event = new CustomEvent('back', {
            bubbles: true,
            composed: true
        });

        this.dispatchEvent(event);
    }

    handleSubmitClick() {
        const event = new CustomEvent('submit', {
            detail: {
                additionalComments: this.additionalComments
            },
            bubbles: true,
            composed: true
        });

        this.dispatchEvent(event);
    }

    handleEditQuestion(event) {
        const questionId = event.currentTarget.dataset.questionId;

        const editEvent = new CustomEvent('editquestion', {
            detail: {
                questionId: questionId
            },
            bubbles: true,
            composed: true
        });

        this.dispatchEvent(editEvent);
    }
}
