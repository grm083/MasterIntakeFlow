import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateCommentSummary from '@salesforce/apex/GoogleGeminiService.generateCommentSummary';

export default class CaseCommentSummary extends LightningElement {
    @api recordId; // Case ID passed from record page

    summary = null;
    isLoading = false;
    error = null;
    hasNoComments = false;

    /**
     * Wire to Case record to trigger refresh when case changes
     */
    @wire(getRecord, { recordId: '$recordId', fields: ['Case.Id'] })
    caseRecord;

    /**
     * Load summary when component initializes
     */
    connectedCallback() {
        if (this.recordId) {
            this.loadSummary();
        }
    }

    /**
     * Load or refresh the comment summary
     */
    loadSummary() {
        console.log('[CaseCommentSummary] Loading summary for case:', this.recordId);

        this.isLoading = true;
        this.error = null;
        this.hasNoComments = false;
        this.summary = null;

        generateCommentSummary({ caseId: this.recordId })
            .then(result => {
                console.log('[CaseCommentSummary] Summary result:', result);

                if (result === null || result === '') {
                    // No comments exist
                    this.hasNoComments = true;
                    this.summary = null;
                } else {
                    // Summary generated successfully
                    this.summary = result;
                    this.hasNoComments = false;
                }

                this.error = null;
            })
            .catch(error => {
                console.error('[CaseCommentSummary] Error loading summary:', error);

                this.summary = null;
                this.hasNoComments = false;

                // Parse error message
                let errorMessage = 'Failed to generate comment summary';
                if (error.body?.message) {
                    errorMessage = error.body.message;
                } else if (error.message) {
                    errorMessage = error.message;
                }

                this.error = errorMessage;

                // Show toast notification
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    /**
     * Handle refresh button click
     */
    handleRefresh() {
        console.log('[CaseCommentSummary] Refreshing summary...');
        this.loadSummary();
    }

    /**
     * Computed property: show the summary section
     */
    get showSummary() {
        return !this.isLoading && !this.error && !this.hasNoComments && this.summary;
    }

    /**
     * Computed property: show no comments message
     */
    get showNoComments() {
        return !this.isLoading && !this.error && this.hasNoComments;
    }

    /**
     * Computed property: show error message
     */
    get showError() {
        return !this.isLoading && this.error;
    }
}
