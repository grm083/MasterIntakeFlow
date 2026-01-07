import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getQuestions from '@salesforce/apex/IntakeAdminController.getQuestions';
import getQuestionCount from '@salesforce/apex/IntakeAdminController.getQuestionCount';
import getFilterOptions from '@salesforce/apex/IntakeAdminController.getFilterOptions';
import exportQuestionsToCSV from '@salesforce/apex/IntakeAdminController.exportQuestionsToCSV';
import bulkUpdateQuestions from '@salesforce/apex/IntakeAdminController.bulkUpdateQuestions';
import validateBulkDelete from '@salesforce/apex/IntakeAdminController.validateBulkDelete';
import bulkDeleteQuestions from '@salesforce/apex/IntakeAdminController.bulkDeleteQuestions';

const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'questionUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'name' },
            target: '_blank'
        },
        sortable: true
    },
    {
        label: 'Question Text',
        fieldName: 'questionText',
        type: 'text',
        wrapText: true,
        sortable: true
    },
    {
        label: 'Input Type',
        fieldName: 'inputType',
        type: 'text',
        sortable: true
    },
    {
        label: 'Case Type',
        fieldName: 'caseType',
        type: 'text',
        sortable: true
    },
    {
        label: 'Case Sub-Type',
        fieldName: 'caseSubType',
        type: 'text',
        sortable: true
    },
    {
        label: 'Outcomes',
        fieldName: 'outcomeCount',
        type: 'number',
        sortable: true,
        cellAttributes: {
            alignment: 'center'
        }
    },
    {
        label: 'Status',
        fieldName: 'statusLabel',
        type: 'text',
        cellAttributes: {
            class: { fieldName: 'statusClass' }
        }
    },
    {
        label: 'Last Modified',
        fieldName: 'lastModifiedDate',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit'
        },
        sortable: true
    }
];

export default class IntakeAdminDashboard extends NavigationMixin(LightningElement) {
    // Data
    @track questions = [];
    @track filteredQuestions = [];
    columns = COLUMNS;

    // Filter options
    @track filterOptions = {
        caseTypes: [],
        caseSubTypes: [],
        inputTypes: [],
        userRoles: []
    };

    // Filter values
    @track filters = {
        searchTerm: '',
        caseType: '',
        caseSubType: '',
        inputType: '',
        userRole: '',
        showOrphaned: false,
        showNoOutcomes: false
    };

    // UI State
    @track isLoading = true;
    @track error = null;
    @track totalRecords = 0;
    @track pageSize = 50;
    @track pageNumber = 1;
    @track sortedBy = 'caseType';
    @track sortedDirection = 'asc';
    @track isExporting = false;

    // Stats
    @track stats = {
        total: 0,
        orphaned: 0,
        noOutcomes: 0,
        picklist: 0,
        text: 0
    };

    // Phase 2: Saved Searches & History
    @track savedSearches = [];
    @track searchHistory = [];
    @track showSavedSearchModal = false;
    @track savedSearchName = '';
    searchTimeout;

    // Phase 4: Bulk Operations
    @track selectedRows = [];
    @track showBulkEditModal = false;
    @track showBulkDeleteModal = false;
    @track bulkEditFields = {
        caseType: '',
        caseSubType: '',
        caseReason: '',
        userRole: '',
        inputType: ''
    };
    @track deleteValidation = null;
    @track isBulkProcessing = false;

    // ========== LIFECYCLE ==========

    connectedCallback() {
        this.loadFilterOptions();
        this.loadQuestions();
        this.loadSavedSearches();
        this.loadSearchHistory();
    }

    // ========== DATA LOADING ==========

    async loadFilterOptions() {
        try {
            const options = await getFilterOptions();
            this.filterOptions = options;
        } catch (error) {
            console.error('Error loading filter options:', error);
        }
    }

    async loadQuestions() {
        try {
            this.isLoading = true;
            this.error = null;

            // Build filter JSON
            const filterJson = JSON.stringify(this.filters);

            // Calculate offset
            const offset = (this.pageNumber - 1) * this.pageSize;

            // Fetch questions
            const questions = await getQuestions({
                filters: filterJson,
                sortField: this.sortedBy,
                sortDirection: this.sortedDirection,
                limitRecords: this.pageSize,
                offsetRecords: offset
            });

            // Get total count
            const totalCount = await getQuestionCount({
                filters: filterJson
            });

            this.totalRecords = totalCount;

            // Process questions for display
            this.questions = questions.map(q => ({
                ...q,
                questionUrl: `/lightning/r/Intake_Process__c/${q.id}/view`,
                statusLabel: this.getStatusLabel(q),
                statusClass: this.getStatusClass(q)
            }));

            // Calculate stats
            this.calculateStats(questions);

            this.isLoading = false;

        } catch (error) {
            console.error('Error loading questions:', error);
            this.error = error.body?.message || error.message;
            this.isLoading = false;
            this.showToast('Error', this.error, 'error');
        }
    }

    // ========== FILTERING ==========

    handleSearchChange(event) {
        this.filters.searchTerm = event.target.value;
        this.debounceSearch();
    }

    handleCaseTypeChange(event) {
        this.filters.caseType = event.target.value;
        this.resetToFirstPage();
        this.loadQuestions();
    }

    handleCaseSubTypeChange(event) {
        this.filters.caseSubType = event.target.value;
        this.resetToFirstPage();
        this.loadQuestions();
    }

    handleInputTypeChange(event) {
        this.filters.inputType = event.target.value;
        this.resetToFirstPage();
        this.loadQuestions();
    }

    handleUserRoleChange(event) {
        this.filters.userRole = event.target.value;
        this.resetToFirstPage();
        this.loadQuestions();
    }

    handleClearFilters() {
        this.filters = {
            searchTerm: '',
            caseType: '',
            caseSubType: '',
            inputType: '',
            userRole: '',
            showOrphaned: false,
            showNoOutcomes: false
        };
        this.resetToFirstPage();
        this.loadQuestions();
    }

    // Quick filters
    handleShowOrphaned() {
        // Filter client-side for orphaned questions
        this.filteredQuestions = this.questions.filter(q => q.isOrphaned);
        this.showToast('Info', `Found ${this.filteredQuestions.length} orphaned questions`, 'info');
    }

    handleShowNoOutcomes() {
        // Filter client-side for questions with no outcomes
        this.filteredQuestions = this.questions.filter(q => q.outcomeCount === 0);
        this.showToast('Info', `Found ${this.filteredQuestions.length} questions with no outcomes`, 'info');
    }

    // Debounced search
    debounceSearch() {
        clearTimeout(this.searchTimeout);
        this.searchTimeout = setTimeout(() => {
            this.resetToFirstPage();
            this.loadQuestions();
            this.addToSearchHistory();
        }, 500);
    }

    // ========== SORTING ==========

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.loadQuestions();
    }

    // ========== PAGINATION ==========

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.loadQuestions();
        }
    }

    handleNext() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber++;
            this.loadQuestions();
        }
    }

    handleFirstPage() {
        this.pageNumber = 1;
        this.loadQuestions();
    }

    handleLastPage() {
        this.pageNumber = this.totalPages;
        this.loadQuestions();
    }

    resetToFirstPage() {
        this.pageNumber = 1;
    }

    // ========== PHASE 2: EXPORT TO CSV ==========

    async handleExportToCSV() {
        try {
            this.isExporting = true;

            // Build filter JSON
            const filterJson = JSON.stringify(this.filters);

            // Call Apex to generate CSV
            const csvData = await exportQuestionsToCSV({
                filters: filterJson,
                sortField: this.sortedBy,
                sortDirection: this.sortedDirection
            });

            // Create download link
            const blob = new Blob([csvData], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `intake_questions_${this.getTimestamp()}.csv`;
            link.click();
            window.URL.revokeObjectURL(url);

            this.showToast('Success', 'Questions exported successfully', 'success');
            this.isExporting = false;

        } catch (error) {
            console.error('Error exporting to CSV:', error);
            this.showToast('Error', 'Failed to export questions: ' + (error.body?.message || error.message), 'error');
            this.isExporting = false;
        }
    }

    getTimestamp() {
        const now = new Date();
        return `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}_` +
               `${String(now.getHours()).padStart(2, '0')}${String(now.getMinutes()).padStart(2, '0')}${String(now.getSeconds()).padStart(2, '0')}`;
    }

    // ========== PHASE 2: SAVED SEARCHES ==========

    loadSavedSearches() {
        try {
            const saved = localStorage.getItem('intakeAdminSavedSearches');
            if (saved) {
                this.savedSearches = JSON.parse(saved);
            }
        } catch (error) {
            console.error('Error loading saved searches:', error);
        }
    }

    handleSaveSearch() {
        this.showSavedSearchModal = true;
    }

    handleSavedSearchNameChange(event) {
        this.savedSearchName = event.target.value;
    }

    handleSaveSearchConfirm() {
        if (!this.savedSearchName || this.savedSearchName.trim() === '') {
            this.showToast('Error', 'Please enter a name for this search', 'error');
            return;
        }

        const newSearch = {
            id: Date.now().toString(),
            name: this.savedSearchName,
            filters: JSON.parse(JSON.stringify(this.filters)),
            sortedBy: this.sortedBy,
            sortedDirection: this.sortedDirection,
            createdDate: new Date().toISOString()
        };

        this.savedSearches = [...this.savedSearches, newSearch];
        localStorage.setItem('intakeAdminSavedSearches', JSON.stringify(this.savedSearches));

        this.showToast('Success', `Search "${this.savedSearchName}" saved successfully`, 'success');
        this.savedSearchName = '';
        this.showSavedSearchModal = false;
    }

    handleCancelSaveSearch() {
        this.savedSearchName = '';
        this.showSavedSearchModal = false;
    }

    handleLoadSavedSearch(event) {
        const searchId = event.target.dataset.id;
        const search = this.savedSearches.find(s => s.id === searchId);

        if (search) {
            this.filters = JSON.parse(JSON.stringify(search.filters));
            this.sortedBy = search.sortedBy;
            this.sortedDirection = search.sortedDirection;
            this.resetToFirstPage();
            this.loadQuestions();
            this.showToast('Info', `Loaded search "${search.name}"`, 'info');
        }
    }

    handleDeleteSavedSearch(event) {
        const searchId = event.target.dataset.id;
        this.savedSearches = this.savedSearches.filter(s => s.id !== searchId);
        localStorage.setItem('intakeAdminSavedSearches', JSON.stringify(this.savedSearches));
        this.showToast('Success', 'Saved search deleted', 'success');
    }

    // ========== PHASE 2: SEARCH HISTORY ==========

    loadSearchHistory() {
        try {
            const history = localStorage.getItem('intakeAdminSearchHistory');
            if (history) {
                this.searchHistory = JSON.parse(history);
            }
        } catch (error) {
            console.error('Error loading search history:', error);
        }
    }

    addToSearchHistory() {
        if (!this.filters.searchTerm || this.filters.searchTerm.trim() === '') {
            return;
        }

        // Check if this search term already exists in history
        const exists = this.searchHistory.some(h => h.searchTerm === this.filters.searchTerm);
        if (exists) {
            return;
        }

        const historyItem = {
            id: Date.now().toString(),
            searchTerm: this.filters.searchTerm,
            timestamp: new Date().toISOString()
        };

        // Add to beginning of array and keep only last 10
        this.searchHistory = [historyItem, ...this.searchHistory].slice(0, 10);
        localStorage.setItem('intakeAdminSearchHistory', JSON.stringify(this.searchHistory));
    }

    handleLoadSearchFromHistory(event) {
        const searchTerm = event.target.dataset.term;
        this.filters.searchTerm = searchTerm;
        this.resetToFirstPage();
        this.loadQuestions();
    }

    handleClearSearchHistory() {
        this.searchHistory = [];
        localStorage.removeItem('intakeAdminSearchHistory');
        this.showToast('Success', 'Search history cleared', 'success');
    }

    // ========== PHASE 3: FLOW VISUALIZER ==========

    handleViewFlow() {
        // Dispatch custom event to navigate to flow visualizer
        // This will be handled by the Lightning App to navigate to the Flow tab
        const event = new CustomEvent('viewflow', {
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(event);

        this.showToast('Info', 'Opening Flow Visualizer...', 'info');
    }

    // ========== PHASE 4: BULK OPERATIONS ==========

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRows = selectedRows.map(row => row.id);
    }

    handleBulkEdit() {
        if (this.selectedRows.length === 0) {
            this.showToast('Warning', 'Please select at least one question', 'warning');
            return;
        }
        this.showBulkEditModal = true;
    }

    handleBulkDelete() {
        if (this.selectedRows.length === 0) {
            this.showToast('Warning', 'Please select at least one question', 'warning');
            return;
        }
        this.validateDelete();
    }

    async validateDelete() {
        try {
            this.isBulkProcessing = true;
            const validation = await validateBulkDelete({ questionIds: this.selectedRows });
            this.deleteValidation = validation;
            this.showBulkDeleteModal = true;
            this.isBulkProcessing = false;
        } catch (error) {
            console.error('Error validating delete:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
            this.isBulkProcessing = false;
        }
    }

    handleBulkEditFieldChange(event) {
        const field = event.target.dataset.field;
        this.bulkEditFields[field] = event.target.value;
    }

    async handleConfirmBulkEdit() {
        try {
            this.isBulkProcessing = true;

            // Build field updates map (only include non-empty values)
            const fieldUpdates = {};
            if (this.bulkEditFields.caseType) fieldUpdates.Case_Type__c = this.bulkEditFields.caseType;
            if (this.bulkEditFields.caseSubType) fieldUpdates.Case_Sub_Type__c = this.bulkEditFields.caseSubType;
            if (this.bulkEditFields.caseReason) fieldUpdates.Case_Reason__c = this.bulkEditFields.caseReason;
            if (this.bulkEditFields.userRole) fieldUpdates.User_Role__c = this.bulkEditFields.userRole;
            if (this.bulkEditFields.inputType) fieldUpdates.Input_Type__c = this.bulkEditFields.inputType;

            if (Object.keys(fieldUpdates).length === 0) {
                this.showToast('Warning', 'Please select at least one field to update', 'warning');
                this.isBulkProcessing = false;
                return;
            }

            const result = await bulkUpdateQuestions({
                questionIds: this.selectedRows,
                fieldUpdates: fieldUpdates
            });

            this.showBulkEditModal = false;
            this.isBulkProcessing = false;
            this.selectedRows = [];

            // Reset form
            this.bulkEditFields = {
                caseType: '',
                caseSubType: '',
                caseReason: '',
                userRole: '',
                inputType: ''
            };

            this.showToast(
                'Success',
                `Updated ${result.successCount} questions${result.errorCount > 0 ? '. ' + result.errorCount + ' errors occurred.' : ''}`,
                result.errorCount > 0 ? 'warning' : 'success'
            );

            // Reload data
            this.loadQuestions();

        } catch (error) {
            console.error('Error in bulk edit:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
            this.isBulkProcessing = false;
        }
    }

    async handleConfirmBulkDelete() {
        try {
            this.isBulkProcessing = true;

            const result = await bulkDeleteQuestions({
                questionIds: this.selectedRows,
                deleteCascade: true
            });

            this.showBulkDeleteModal = false;
            this.isBulkProcessing = false;
            this.selectedRows = [];
            this.deleteValidation = null;

            this.showToast(
                'Success',
                `Deleted ${result.successCount} questions${result.errorCount > 0 ? '. ' + result.errorCount + ' errors occurred.' : ''}`,
                result.errorCount > 0 ? 'warning' : 'success'
            );

            // Reload data
            this.loadQuestions();

        } catch (error) {
            console.error('Error in bulk delete:', error);
            this.showToast('Error', error.body?.message || error.message, 'error');
            this.isBulkProcessing = false;
        }
    }

    handleCancelBulkEdit() {
        this.showBulkEditModal = false;
        this.bulkEditFields = {
            caseType: '',
            caseSubType: '',
            caseReason: '',
            userRole: '',
            inputType: ''
        };
    }

    handleCancelBulkDelete() {
        this.showBulkDeleteModal = false;
        this.deleteValidation = null;
    }

    // ========== HELPERS ==========

    getStatusLabel(question) {
        if (question.isOrphaned) return 'Orphaned';
        if (question.outcomeCount === 0) return 'No Outcomes';
        if (!question.hasNextQuestions) return 'Terminal';
        return 'Active';
    }

    getStatusClass(question) {
        if (question.isOrphaned) return 'slds-text-color_error';
        if (question.outcomeCount === 0) return 'slds-text-color_warning';
        return 'slds-text-color_success';
    }

    calculateStats(questions) {
        this.stats = {
            total: this.totalRecords,
            orphaned: questions.filter(q => q.isOrphaned).length,
            noOutcomes: questions.filter(q => q.outcomeCount === 0).length,
            picklist: questions.filter(q => q.inputType === 'Picklist').length,
            text: questions.filter(q => q.inputType === 'Text').length
        };
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    // ========== GETTERS ==========

    get hasQuestions() {
        return this.questions && this.questions.length > 0;
    }

    get hasFilters() {
        return this.filters.searchTerm ||
               this.filters.caseType ||
               this.filters.caseSubType ||
               this.filters.inputType ||
               this.filters.userRole;
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    get isPreviousDisabled() {
        return this.pageNumber <= 1;
    }

    get isNextDisabled() {
        return this.pageNumber >= this.totalPages;
    }

    get paginationLabel() {
        const start = (this.pageNumber - 1) * this.pageSize + 1;
        const end = Math.min(this.pageNumber * this.pageSize, this.totalRecords);
        return `${start}-${end} of ${this.totalRecords}`;
    }

    get caseTypeOptions() {
        return [
            { label: '-- All Case Types --', value: '' },
            ...this.filterOptions.caseTypes
        ];
    }

    get caseSubTypeOptions() {
        return [
            { label: '-- All Sub-Types --', value: '' },
            ...this.filterOptions.caseSubTypes
        ];
    }

    get inputTypeOptions() {
        return [
            { label: '-- All Input Types --', value: '' },
            ...this.filterOptions.inputTypes
        ];
    }

    get userRoleOptions() {
        return [
            { label: '-- All User Roles --', value: '' },
            ...this.filterOptions.userRoles
        ];
    }

    get hasSavedSearches() {
        return this.savedSearches && this.savedSearches.length > 0;
    }

    get hasSearchHistory() {
        return this.searchHistory && this.searchHistory.length > 0;
    }

    get canSaveSearch() {
        return this.hasFilters || this.filters.searchTerm;
    }

    get hasSelectedRows() {
        return this.selectedRows && this.selectedRows.length > 0;
    }

    get selectedRowCount() {
        return this.selectedRows ? this.selectedRows.length : 0;
    }

    get bulkEditTitle() {
        return `Bulk Edit ${this.selectedRowCount} Question${this.selectedRowCount !== 1 ? 's' : ''}`;
    }

    get bulkDeleteTitle() {
        return `Bulk Delete ${this.selectedRowCount} Question${this.selectedRowCount !== 1 ? 's' : ''}`;
    }

    get hasDeleteWarnings() {
        return this.deleteValidation && this.deleteValidation.warnings && this.deleteValidation.warnings.length > 0;
    }
}
