import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getQuestions from '@salesforce/apex/IntakeAdminController.getQuestions';
import getQuestionCount from '@salesforce/apex/IntakeAdminController.getQuestionCount';
import getFilterOptions from '@salesforce/apex/IntakeAdminController.getFilterOptions';

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

    // Stats
    @track stats = {
        total: 0,
        orphaned: 0,
        noOutcomes: 0,
        picklist: 0,
        text: 0
    };

    // ========== LIFECYCLE ==========

    connectedCallback() {
        this.loadFilterOptions();
        this.loadQuestions();
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
}
