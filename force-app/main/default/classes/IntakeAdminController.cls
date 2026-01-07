/**
 * @description Controller for Intake Admin Dashboard
 * Provides efficient querying and management of Intake_Process__c records
 */
public with sharing class IntakeAdminController {

    /**
     * Wrapper class for question data with enhanced metadata
     */
    public class QuestionWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String questionText { get; set; }
        @AuraEnabled public String inputType { get; set; }
        @AuraEnabled public Decimal presentationOrder { get; set; }
        @AuraEnabled public String caseType { get; set; }
        @AuraEnabled public String caseSubType { get; set; }
        @AuraEnabled public String caseReason { get; set; }
        @AuraEnabled public String userRole { get; set; }
        @AuraEnabled public String customerAccount { get; set; }
        @AuraEnabled public String customerLocation { get; set; }
        @AuraEnabled public Integer outcomeCount { get; set; }
        @AuraEnabled public Boolean hasNextQuestions { get; set; }
        @AuraEnabled public Boolean isOrphaned { get; set; }
        @AuraEnabled public DateTime lastModifiedDate { get; set; }
        @AuraEnabled public String lastModifiedBy { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public String createdBy { get; set; }
    }

    /**
     * Wrapper class for filter options
     */
    public class FilterOptions {
        @AuraEnabled public List<PicklistOption> caseTypes { get; set; }
        @AuraEnabled public List<PicklistOption> caseSubTypes { get; set; }
        @AuraEnabled public List<PicklistOption> inputTypes { get; set; }
        @AuraEnabled public List<PicklistOption> userRoles { get; set; }
    }

    /**
     * Wrapper for picklist options
     */
    public class PicklistOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }

    /**
     * Get all questions with enhanced metadata
     * @param filters JSON string of filter criteria
     * @param sortField Field to sort by
     * @param sortDirection ASC or DESC
     * @param limitRecords Number of records to return
     * @param offsetRecords Offset for pagination
     * @return List of QuestionWrapper objects
     */
    @AuraEnabled(cacheable=false)
    public static List<QuestionWrapper> getQuestions(
        String filters,
        String sortField,
        String sortDirection,
        Integer limitRecords,
        Integer offsetRecords
    ) {
        try {
            // Parse filters
            Map<String, Object> filterMap = filters != null ?
                (Map<String, Object>) JSON.deserializeUntyped(filters) :
                new Map<String, Object>();

            // Build dynamic query
            String query = buildQuestionQuery(filterMap, sortField, sortDirection, limitRecords, offsetRecords);

            // Execute query
            List<Intake_Process__c> questions = Database.query(query);

            // Get outcome counts for each question
            Map<Id, Integer> outcomeCounts = getOutcomeCountsForQuestions(
                new Map<Id, Intake_Process__c>(questions).keySet()
            );

            // Get incoming reference counts (to identify orphaned questions)
            Map<Id, Integer> incomingReferences = getIncomingReferenceCountsForQuestions(
                new Map<Id, Intake_Process__c>(questions).keySet()
            );

            // Build wrapper list
            List<QuestionWrapper> wrappers = new List<QuestionWrapper>();
            for (Intake_Process__c q : questions) {
                wrappers.add(buildQuestionWrapper(q, outcomeCounts, incomingReferences));
            }

            return wrappers;

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching questions: ' + e.getMessage());
        }
    }

    /**
     * Get total count of questions matching filters
     */
    @AuraEnabled(cacheable=false)
    public static Integer getQuestionCount(String filters) {
        try {
            Map<String, Object> filterMap = filters != null ?
                (Map<String, Object>) JSON.deserializeUntyped(filters) :
                new Map<String, Object>();

            String query = buildCountQuery(filterMap);
            return Database.countQuery(query);

        } catch (Exception e) {
            throw new AuraHandledException('Error counting questions: ' + e.getMessage());
        }
    }

    /**
     * Get filter options (picklist values)
     */
    @AuraEnabled(cacheable=true)
    public static FilterOptions getFilterOptions() {
        try {
            FilterOptions options = new FilterOptions();

            // Get distinct Case Types
            options.caseTypes = getDistinctValues('Case_Type__c');

            // Get distinct Case Sub-Types
            options.caseSubTypes = getDistinctValues('Case_Sub_Type__c');

            // Get Input Types from picklist
            options.inputTypes = new List<PicklistOption>();
            Schema.DescribeFieldResult fieldResult = Intake_Process__c.Input_Type__c.getDescribe();
            for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                if (entry.isActive()) {
                    PicklistOption opt = new PicklistOption();
                    opt.label = entry.getLabel();
                    opt.value = entry.getValue();
                    options.inputTypes.add(opt);
                }
            }

            // Get distinct User Roles
            options.userRoles = getDistinctValues('User_Role__c');

            return options;

        } catch (Exception e) {
            throw new AuraHandledException('Error getting filter options: ' + e.getMessage());
        }
    }

    /**
     * Export questions to CSV format
     * Returns all questions matching filters (not paginated) as CSV string
     * @param filters JSON string of filter criteria
     * @param sortField Field to sort by
     * @param sortDirection ASC or DESC
     * @return CSV string with all matching questions
     */
    @AuraEnabled(cacheable=false)
    public static String exportQuestionsToCSV(
        String filters,
        String sortField,
        String sortDirection
    ) {
        try {
            // Parse filters
            Map<String, Object> filterMap = filters != null ?
                (Map<String, Object>) JSON.deserializeUntyped(filters) :
                new Map<String, Object>();

            // Build query without pagination (export all)
            String query = buildQuestionQuery(filterMap, sortField, sortDirection, null, null);

            // Execute query
            List<Intake_Process__c> questions = Database.query(query);

            // Get outcome counts
            Map<Id, Integer> outcomeCounts = getOutcomeCountsForQuestions(
                new Map<Id, Intake_Process__c>(questions).keySet()
            );

            // Get incoming reference counts
            Map<Id, Integer> incomingReferences = getIncomingReferenceCountsForQuestions(
                new Map<Id, Intake_Process__c>(questions).keySet()
            );

            // Build CSV
            StringBuilder csv = new StringBuilder();

            // CSV Header
            csv.append('Name,Question Text,Input Type,Case Type,Case Sub-Type,Case Reason,User Role,');
            csv.append('Customer Account,Customer Location,Presentation Order,Outcome Count,Status,');
            csv.append('Last Modified Date,Last Modified By,Created Date,Created By\n');

            // CSV Rows
            for (Intake_Process__c q : questions) {
                QuestionWrapper wrapper = buildQuestionWrapper(q, outcomeCounts, incomingReferences);

                csv.append(escapeCsvValue(wrapper.name));
                csv.append(escapeCsvValue(wrapper.questionText));
                csv.append(escapeCsvValue(wrapper.inputType));
                csv.append(escapeCsvValue(wrapper.caseType));
                csv.append(escapeCsvValue(wrapper.caseSubType));
                csv.append(escapeCsvValue(wrapper.caseReason));
                csv.append(escapeCsvValue(wrapper.userRole));
                csv.append(escapeCsvValue(wrapper.customerAccount));
                csv.append(escapeCsvValue(wrapper.customerLocation));
                csv.append(wrapper.presentationOrder != null ? String.valueOf(wrapper.presentationOrder) : '');
                csv.append(',');
                csv.append(String.valueOf(wrapper.outcomeCount));
                csv.append(',');
                csv.append(getStatusLabel(wrapper));
                csv.append(',');
                csv.append(wrapper.lastModifiedDate != null ? wrapper.lastModifiedDate.format('yyyy-MM-dd HH:mm:ss') : '');
                csv.append(',');
                csv.append(escapeCsvValue(wrapper.lastModifiedBy));
                csv.append(wrapper.createdDate != null ? wrapper.createdDate.format('yyyy-MM-dd HH:mm:ss') : '');
                csv.append(',');
                csv.append(escapeCsvValue(wrapper.createdBy));
                csv.append('\n');
            }

            return csv.toString();

        } catch (Exception e) {
            throw new AuraHandledException('Error exporting to CSV: ' + e.getMessage());
        }
    }

    /**
     * Get question details with full outcome information
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getQuestionDetails(Id questionId) {
        try {
            // Get question
            Intake_Process__c question = [
                SELECT Id, Name, Question__c, Input_Type__c, Input_Values__c,
                       Presentation_Order__c, Case_Type__c, Case_Sub_Type__c,
                       Case_Reason__c, User_Role__c, Customer_Account__c,
                       Customer_Location__c, CreatedDate, CreatedBy.Name,
                       LastModifiedDate, LastModifiedBy.Name
                FROM Intake_Process__c
                WHERE Id = :questionId
                AND RecordType.Name = 'Intake Questions'
                LIMIT 1
            ];

            // Get outcomes
            List<Intake_Process__c> outcomes = [
                SELECT Id, Name, Outcome__c, Outcome_Statement__c,
                       Any_Value__c, Next_Question__c, Next_Question__r.Question__c,
                       Update_Case_Status__c, Case_Status__c,
                       Update_Case_Type__c, Case_Type__c,
                       Update_Case_Sub_Type__c, Case_Sub_Type__c,
                       Update_Case_Reason__c, Case_Reason__c,
                       Update_Case_Record_Type__c, Case_Record_Type__c,
                       Queue_Assigned__c, Team_Name__c, Assign_to_Current_User__c,
                       Create_Task__c, Task_Type__c, Task_Process__c
                FROM Intake_Process__c
                WHERE Intake_Question__c = :questionId
                AND RecordType.Name = 'Intake Outcomes'
                ORDER BY Outcome__c
            ];

            // Get incoming references (questions that link to this one)
            List<Intake_Process__c> incomingQuestions = [
                SELECT Id, Name, Question__c, Outcome__c
                FROM Intake_Process__c
                WHERE Next_Question__c = :questionId
                AND RecordType.Name = 'Intake Outcomes'
            ];

            Map<String, Object> result = new Map<String, Object>();
            result.put('question', question);
            result.put('outcomes', outcomes);
            result.put('incomingReferences', incomingQuestions);
            result.put('isOrphaned', incomingQuestions.isEmpty());

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error getting question details: ' + e.getMessage());
        }
    }

    // ========== PRIVATE HELPER METHODS ==========

    /**
     * Build dynamic SOQL query for questions
     */
    private static String buildQuestionQuery(
        Map<String, Object> filters,
        String sortField,
        String sortDirection,
        Integer limitRecords,
        Integer offsetRecords
    ) {
        String query = 'SELECT Id, Name, Question__c, Input_Type__c, Presentation_Order__c, ' +
                      'Case_Type__c, Case_Sub_Type__c, Case_Reason__c, User_Role__c, ' +
                      'Customer_Account__c, Customer_Account__r.Name, ' +
                      'Customer_Location__c, Customer_Location__r.Name, ' +
                      'LastModifiedDate, LastModifiedBy.Name, ' +
                      'CreatedDate, CreatedBy.Name ' +
                      'FROM Intake_Process__c ' +
                      'WHERE RecordType.Name = \'Intake Questions\'';

        // Add filters
        if (filters.containsKey('searchTerm') && filters.get('searchTerm') != null) {
            String searchTerm = String.escapeSingleQuotes((String) filters.get('searchTerm'));
            // Enhanced global search - searches across multiple fields
            query += ' AND (Question__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR Name LIKE \'%' + searchTerm + '%\' ' +
                    'OR Case_Type__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR Case_Sub_Type__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR Case_Reason__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR User_Role__c LIKE \'%' + searchTerm + '%\')';
        }

        if (filters.containsKey('caseType') && filters.get('caseType') != null) {
            String caseType = String.escapeSingleQuotes((String) filters.get('caseType'));
            query += ' AND Case_Type__c = \'' + caseType + '\'';
        }

        if (filters.containsKey('caseSubType') && filters.get('caseSubType') != null) {
            String caseSubType = String.escapeSingleQuotes((String) filters.get('caseSubType'));
            query += ' AND Case_Sub_Type__c = \'' + caseSubType + '\'';
        }

        if (filters.containsKey('inputType') && filters.get('inputType') != null) {
            String inputType = String.escapeSingleQuotes((String) filters.get('inputType'));
            query += ' AND Input_Type__c = \'' + inputType + '\'';
        }

        if (filters.containsKey('userRole') && filters.get('userRole') != null) {
            String userRole = String.escapeSingleQuotes((String) filters.get('userRole'));
            query += ' AND User_Role__c = \'' + userRole + '\'';
        }

        // Add sorting
        if (sortField != null && sortDirection != null) {
            query += ' ORDER BY ' + sortField + ' ' + sortDirection;
        } else {
            query += ' ORDER BY Case_Type__c, Case_Sub_Type__c, Presentation_Order__c';
        }

        // Add pagination
        if (limitRecords != null) {
            query += ' LIMIT ' + limitRecords;
        }

        if (offsetRecords != null) {
            query += ' OFFSET ' + offsetRecords;
        }

        return query;
    }

    /**
     * Build count query
     */
    private static String buildCountQuery(Map<String, Object> filters) {
        String query = 'SELECT COUNT() FROM Intake_Process__c ' +
                      'WHERE RecordType.Name = \'Intake Questions\'';

        // Add same filters as main query
        if (filters.containsKey('searchTerm') && filters.get('searchTerm') != null) {
            String searchTerm = String.escapeSingleQuotes((String) filters.get('searchTerm'));
            // Enhanced global search - searches across multiple fields
            query += ' AND (Question__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR Name LIKE \'%' + searchTerm + '%\' ' +
                    'OR Case_Type__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR Case_Sub_Type__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR Case_Reason__c LIKE \'%' + searchTerm + '%\' ' +
                    'OR User_Role__c LIKE \'%' + searchTerm + '%\')';
        }

        if (filters.containsKey('caseType') && filters.get('caseType') != null) {
            String caseType = String.escapeSingleQuotes((String) filters.get('caseType'));
            query += ' AND Case_Type__c = \'' + caseType + '\'';
        }

        if (filters.containsKey('caseSubType') && filters.get('caseSubType') != null) {
            String caseSubType = String.escapeSingleQuotes((String) filters.get('caseSubType'));
            query += ' AND Case_Sub_Type__c = \'' + caseSubType + '\'';
        }

        if (filters.containsKey('inputType') && filters.get('inputType') != null) {
            String inputType = String.escapeSingleQuotes((String) filters.get('inputType'));
            query += ' AND Input_Type__c = \'' + inputType + '\'';
        }

        if (filters.containsKey('userRole') && filters.get('userRole') != null) {
            String userRole = String.escapeSingleQuotes((String) filters.get('userRole'));
            query += ' AND User_Role__c = \'' + userRole + '\'';
        }

        return query;
    }

    /**
     * Get outcome counts for questions
     */
    private static Map<Id, Integer> getOutcomeCountsForQuestions(Set<Id> questionIds) {
        Map<Id, Integer> counts = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT Intake_Question__c, COUNT(Id) cnt
            FROM Intake_Process__c
            WHERE Intake_Question__c IN :questionIds
            AND RecordType.Name = 'Intake Outcomes'
            GROUP BY Intake_Question__c
        ]) {
            counts.put((Id) ar.get('Intake_Question__c'), (Integer) ar.get('cnt'));
        }

        return counts;
    }

    /**
     * Get incoming reference counts (how many outcomes point to this question)
     */
    private static Map<Id, Integer> getIncomingReferenceCountsForQuestions(Set<Id> questionIds) {
        Map<Id, Integer> counts = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT Next_Question__c, COUNT(Id) cnt
            FROM Intake_Process__c
            WHERE Next_Question__c IN :questionIds
            AND RecordType.Name = 'Intake Outcomes'
            GROUP BY Next_Question__c
        ]) {
            counts.put((Id) ar.get('Next_Question__c'), (Integer) ar.get('cnt'));
        }

        return counts;
    }

    /**
     * Get distinct values for a field
     */
    private static List<PicklistOption> getDistinctValues(String fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();
        Set<String> values = new Set<String>();

        String query = 'SELECT ' + fieldName + ' FROM Intake_Process__c ' +
                      'WHERE RecordType.Name = \'Intake Questions\' ' +
                      'AND ' + fieldName + ' != null ' +
                      'ORDER BY ' + fieldName;

        for (Intake_Process__c record : Database.query(query)) {
            String value = (String) record.get(fieldName);
            if (!values.contains(value)) {
                values.add(value);
                PicklistOption opt = new PicklistOption();
                opt.label = value;
                opt.value = value;
                options.add(opt);
            }
        }

        return options;
    }

    /**
     * Build question wrapper with metadata
     */
    private static QuestionWrapper buildQuestionWrapper(
        Intake_Process__c q,
        Map<Id, Integer> outcomeCounts,
        Map<Id, Integer> incomingReferences
    ) {
        QuestionWrapper wrapper = new QuestionWrapper();
        wrapper.id = q.Id;
        wrapper.name = q.Name;
        wrapper.questionText = q.Question__c;
        wrapper.inputType = q.Input_Type__c;
        wrapper.presentationOrder = q.Presentation_Order__c;
        wrapper.caseType = q.Case_Type__c;
        wrapper.caseSubType = q.Case_Sub_Type__c;
        wrapper.caseReason = q.Case_Reason__c;
        wrapper.userRole = q.User_Role__c;
        wrapper.customerAccount = q.Customer_Account__c != null ? q.Customer_Account__r.Name : null;
        wrapper.customerLocation = q.Customer_Location__c != null ? q.Customer_Location__r.Name : null;
        wrapper.outcomeCount = outcomeCounts.containsKey(q.Id) ? outcomeCounts.get(q.Id) : 0;
        wrapper.hasNextQuestions = wrapper.outcomeCount > 0;
        wrapper.isOrphaned = !incomingReferences.containsKey(q.Id) && q.Presentation_Order__c != 1;
        wrapper.lastModifiedDate = q.LastModifiedDate;
        wrapper.lastModifiedBy = q.LastModifiedBy.Name;
        wrapper.createdDate = q.CreatedDate;
        wrapper.createdBy = q.CreatedBy.Name;

        return wrapper;
    }

    /**
     * Escape CSV value - handles commas, quotes, and newlines
     */
    private static String escapeCsvValue(String value) {
        if (value == null) {
            return ',';
        }

        // If value contains comma, quote, or newline, wrap in quotes and escape internal quotes
        if (value.contains(',') || value.contains('"') || value.contains('\n')) {
            value = '"' + value.replace('"', '""') + '"';
        }

        return value + ',';
    }

    /**
     * Get status label for a question
     */
    private static String getStatusLabel(QuestionWrapper wrapper) {
        if (wrapper.isOrphaned) {
            return 'Orphaned';
        }
        if (wrapper.outcomeCount == 0) {
            return 'No Outcomes';
        }
        if (!wrapper.hasNextQuestions) {
            return 'Terminal';
        }
        return 'Active';
    }

    /**
     * StringBuilder helper class for CSV generation
     */
    private class StringBuilder {
        private List<String> buffer = new List<String>();

        public void append(String value) {
            buffer.add(value);
        }

        public override String toString() {
            return String.join(buffer, '');
        }
    }
}
