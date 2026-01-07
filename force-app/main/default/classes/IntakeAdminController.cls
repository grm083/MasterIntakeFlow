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

            // Pre-filter for quick filters (orphaned/no outcomes) to avoid subquery issues
            Set<Id> quickFilterIds = null;
            if (filterMap.containsKey('showOrphaned') && filterMap.get('showOrphaned') == true) {
                quickFilterIds = getOrphanedQuestionIds();
            } else if (filterMap.containsKey('showNoOutcomes') && filterMap.get('showNoOutcomes') == true) {
                quickFilterIds = getNoOutcomeQuestionIds();
            }

            // Build dynamic query
            String query = buildQuestionQuery(filterMap, sortField, sortDirection, limitRecords, offsetRecords, quickFilterIds);

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

            // Pre-filter for quick filters (orphaned/no outcomes) to avoid subquery issues
            Set<Id> quickFilterIds = null;
            if (filterMap.containsKey('showOrphaned') && filterMap.get('showOrphaned') == true) {
                quickFilterIds = getOrphanedQuestionIds();
            } else if (filterMap.containsKey('showNoOutcomes') && filterMap.get('showNoOutcomes') == true) {
                quickFilterIds = getNoOutcomeQuestionIds();
            }

            String query = buildCountQuery(filterMap, quickFilterIds);
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
     * Get flow visualization data (all questions and their connections)
     * Returns nodes and edges for visual flow builder
     * @param filters Optional JSON string to filter which questions to include
     * @return Map with nodes and edges arrays
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getFlowVisualizationData(String filters) {
        try {
            Map<String, Object> filterMap = filters != null ?
                (Map<String, Object>) JSON.deserializeUntyped(filters) :
                new Map<String, Object>();

            // Get questions (nodes)
            String nodeQuery = buildFlowNodeQuery(filterMap);
            List<Intake_Process__c> questions = Database.query(nodeQuery);

            // Get outcomes (edges)
            Set<Id> questionIds = new Map<Id, Intake_Process__c>(questions).keySet();
            List<Intake_Process__c> outcomes = [
                SELECT Id, Name, Intake_Question__c, Next_Question__c,
                       Outcome__c, Outcome_Statement__c
                FROM Intake_Process__c
                WHERE Intake_Question__c IN :questionIds
                AND Next_Question__c != null
            ];

            // Get outcome counts and incoming references
            Map<Id, Integer> outcomeCounts = getOutcomeCountsForQuestions(questionIds);
            Map<Id, Integer> incomingReferences = getIncomingReferenceCountsForQuestions(questionIds);

            // Build nodes
            List<Map<String, Object>> nodes = new List<Map<String, Object>>();
            for (Intake_Process__c q : questions) {
                Map<String, Object> node = new Map<String, Object>();
                node.put('id', q.Id);
                node.put('name', q.Name);
                node.put('questionText', q.Question__c);
                node.put('inputType', q.Input_Type__c);
                node.put('caseType', q.Case_Type__c);
                node.put('caseSubType', q.Case_Sub_Type__c);
                node.put('presentationOrder', q.Presentation_Order__c);
                node.put('outcomeCount', outcomeCounts.containsKey(q.Id) ? outcomeCounts.get(q.Id) : 0);
                node.put('incomingCount', incomingReferences.containsKey(q.Id) ? incomingReferences.get(q.Id) : 0);
                node.put('isOrphaned', !incomingReferences.containsKey(q.Id) && q.Presentation_Order__c != 1);
                node.put('isStart', q.Presentation_Order__c == 1);
                nodes.add(node);
            }

            // Build edges
            List<Map<String, Object>> edges = new List<Map<String, Object>>();
            for (Intake_Process__c outcome : outcomes) {
                Map<String, Object> edge = new Map<String, Object>();
                edge.put('id', outcome.Id);
                edge.put('source', outcome.Intake_Question__c);
                edge.put('target', outcome.Next_Question__c);
                edge.put('label', outcome.Outcome__c);
                edge.put('outcomeStatement', outcome.Outcome_Statement__c);
                edges.add(edge);
            }

            // Return result
            Map<String, Object> result = new Map<String, Object>();
            result.put('nodes', nodes);
            result.put('edges', edges);
            result.put('nodeCount', nodes.size());
            result.put('edgeCount', edges.size());

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error getting flow visualization data: ' + e.getMessage());
        }
    }

    /**
     * Get flow path starting from a specific question
     * Traces all possible paths from the given question
     * @param questionId Starting question ID
     * @param maxDepth Maximum depth to traverse (default 50)
     * @return Map with nodes and edges in the path
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getQuestionFlowPath(Id questionId, Integer maxDepth) {
        try {
            if (maxDepth == null || maxDepth <= 0) {
                maxDepth = 50;
            }

            Set<Id> visitedQuestions = new Set<Id>();
            Set<Id> visitedOutcomes = new Set<Id>();
            List<Id> questionsToProcess = new List<Id>{ questionId };
            Integer currentDepth = 0;

            // Breadth-first traversal
            while (!questionsToProcess.isEmpty() && currentDepth < maxDepth) {
                List<Id> nextBatch = new List<Id>();

                // Get outcomes for current batch
                List<Intake_Process__c> outcomes = [
                    SELECT Id, Intake_Question__c, Next_Question__c,
                           Outcome__c, Outcome_Statement__c
                    FROM Intake_Process__c
                    WHERE Intake_Question__c IN :questionsToProcess
                    
                    AND Next_Question__c != null
                ];

                for (Intake_Process__c outcome : outcomes) {
                    visitedOutcomes.add(outcome.Id);
                    if (!visitedQuestions.contains(outcome.Next_Question__c)) {
                        nextBatch.add(outcome.Next_Question__c);
                    }
                }

                visitedQuestions.addAll(questionsToProcess);
                questionsToProcess = nextBatch;
                currentDepth++;
            }

            // Get all visited questions
            List<Intake_Process__c> questions = [
                SELECT Id, Name, Question__c, Input_Type__c, Case_Type__c,
                       Case_Sub_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Id IN :visitedQuestions
                
            ];

            // Get all visited outcomes
            List<Intake_Process__c> pathOutcomes = [
                SELECT Id, Intake_Question__c, Next_Question__c,
                       Outcome__c, Outcome_Statement__c
                FROM Intake_Process__c
                WHERE Id IN :visitedOutcomes
            ];

            // Get outcome counts
            Map<Id, Integer> outcomeCounts = getOutcomeCountsForQuestions(visitedQuestions);
            Map<Id, Integer> incomingReferences = getIncomingReferenceCountsForQuestions(visitedQuestions);

            // Build nodes
            List<Map<String, Object>> nodes = new List<Map<String, Object>>();
            for (Intake_Process__c q : questions) {
                Map<String, Object> node = new Map<String, Object>();
                node.put('id', q.Id);
                node.put('name', q.Name);
                node.put('questionText', q.Question__c);
                node.put('inputType', q.Input_Type__c);
                node.put('caseType', q.Case_Type__c);
                node.put('caseSubType', q.Case_Sub_Type__c);
                node.put('outcomeCount', outcomeCounts.containsKey(q.Id) ? outcomeCounts.get(q.Id) : 0);
                node.put('incomingCount', incomingReferences.containsKey(q.Id) ? incomingReferences.get(q.Id) : 0);
                node.put('isStart', q.Id == questionId);
                nodes.add(node);
            }

            // Build edges
            List<Map<String, Object>> edges = new List<Map<String, Object>>();
            for (Intake_Process__c outcome : pathOutcomes) {
                Map<String, Object> edge = new Map<String, Object>();
                edge.put('id', outcome.Id);
                edge.put('source', outcome.Intake_Question__c);
                edge.put('target', outcome.Next_Question__c);
                edge.put('label', outcome.Outcome__c);
                edge.put('outcomeStatement', outcome.Outcome_Statement__c);
                edges.add(edge);
            }

            Map<String, Object> result = new Map<String, Object>();
            result.put('nodes', nodes);
            result.put('edges', edges);
            result.put('startQuestionId', questionId);
            result.put('depthReached', currentDepth);

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error getting question flow path: ' + e.getMessage());
        }
    }

    /**
     * Validate question paths and detect issues
     * @param questionId Question to validate
     * @return Map with validation results
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> validateQuestionPath(Id questionId) {
        try {
            // Get question
            Intake_Process__c question = [
                SELECT Id, Name, Question__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Id = :questionId
                
                LIMIT 1
            ];

            // Get outcomes
            List<Intake_Process__c> outcomes = [
                SELECT Id, Outcome__c, Next_Question__c
                FROM Intake_Process__c
                WHERE Intake_Question__c = :questionId
                
            ];

            // Get incoming references
            List<Intake_Process__c> incomingRefs = [
                SELECT Id
                FROM Intake_Process__c
                WHERE Next_Question__c = :questionId
                
            ];

            // Validation checks
            List<String> issues = new List<String>();
            List<String> warnings = new List<String>();

            // Check: Orphaned (no incoming references and not a start question)
            if (incomingRefs.isEmpty() && question.Presentation_Order__c != 1) {
                issues.add('Orphaned: No other questions link to this question');
            }

            // Check: No outcomes
            if (outcomes.isEmpty()) {
                warnings.add('No Outcomes: This question has no answer options defined');
            }

            // Check: Dead end outcomes (outcomes with no next question)
            Integer deadEndCount = 0;
            for (Intake_Process__c outcome : outcomes) {
                if (outcome.Next_Question__c == null) {
                    deadEndCount++;
                }
            }
            if (deadEndCount > 0 && deadEndCount < outcomes.size()) {
                warnings.add('Partial Dead End: ' + deadEndCount + ' of ' + outcomes.size() + ' outcomes have no next question');
            } else if (deadEndCount == outcomes.size() && !outcomes.isEmpty()) {
                warnings.add('Terminal Question: All outcomes lead to dead ends (this may be intentional)');
            }

            // Check: Circular reference (outcome points back to same question)
            for (Intake_Process__c outcome : outcomes) {
                if (outcome.Next_Question__c == questionId) {
                    warnings.add('Circular Reference: Outcome "' + outcome.Outcome__c + '" points back to this question');
                }
            }

            Map<String, Object> result = new Map<String, Object>();
            result.put('questionId', questionId);
            result.put('questionName', question.Name);
            result.put('isValid', issues.isEmpty());
            result.put('issues', issues);
            result.put('warnings', warnings);
            result.put('outcomeCount', outcomes.size());
            result.put('incomingCount', incomingRefs.size());
            result.put('deadEndCount', deadEndCount);

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error validating question path: ' + e.getMessage());
        }
    }

    /**
     * Bulk update questions with specified field values
     * @param questionIds List of question IDs to update
     * @param fieldUpdates Map of field API names to new values
     * @return Map with success count, error count, and error messages
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> bulkUpdateQuestions(List<Id> questionIds, Map<String, Object> fieldUpdates) {
        try {
            List<Intake_Process__c> questionsToUpdate = [
                SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
                       User_Role__c, Input_Type__c
                FROM Intake_Process__c
                WHERE Id IN :questionIds
                
            ];

            // Apply field updates
            for (Intake_Process__c q : questionsToUpdate) {
                if (fieldUpdates.containsKey('Case_Type__c') && fieldUpdates.get('Case_Type__c') != null) {
                    q.Case_Type__c = (String) fieldUpdates.get('Case_Type__c');
                }
                if (fieldUpdates.containsKey('Case_Sub_Type__c') && fieldUpdates.get('Case_Sub_Type__c') != null) {
                    q.Case_Sub_Type__c = (String) fieldUpdates.get('Case_Sub_Type__c');
                }
                if (fieldUpdates.containsKey('Case_Reason__c') && fieldUpdates.get('Case_Reason__c') != null) {
                    q.Case_Reason__c = (String) fieldUpdates.get('Case_Reason__c');
                }
                if (fieldUpdates.containsKey('User_Role__c') && fieldUpdates.get('User_Role__c') != null) {
                    q.User_Role__c = (String) fieldUpdates.get('User_Role__c');
                }
                if (fieldUpdates.containsKey('Input_Type__c') && fieldUpdates.get('Input_Type__c') != null) {
                    q.Input_Type__c = (String) fieldUpdates.get('Input_Type__c');
                }
            }

            // Update records
            List<Database.SaveResult> results = Database.update(questionsToUpdate, false);

            // Process results
            Integer successCount = 0;
            Integer errorCount = 0;
            List<String> errorMessages = new List<String>();

            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successCount++;
                } else {
                    errorCount++;
                    String errorMsg = questionsToUpdate[i].Name + ': ';
                    for (Database.Error err : results[i].getErrors()) {
                        errorMsg += err.getMessage() + '; ';
                    }
                    errorMessages.add(errorMsg);
                }
            }

            Map<String, Object> result = new Map<String, Object>();
            result.put('successCount', successCount);
            result.put('errorCount', errorCount);
            result.put('errorMessages', errorMessages);
            result.put('totalProcessed', questionIds.size());

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error in bulk update: ' + e.getMessage());
        }
    }

    /**
     * Validate if questions can be safely deleted
     * @param questionIds List of question IDs to validate
     * @return Map with validation results and warnings
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> validateBulkDelete(List<Id> questionIds) {
        try {
            // Check for incoming references
            List<Intake_Process__c> incomingRefs = [
                SELECT Next_Question__c, Question__r.Name, Outcome__c
                FROM Intake_Process__c
                WHERE Next_Question__c IN :questionIds
                
            ];

            // Count outcomes for each question
            Map<Id, Integer> outcomeCountsMap = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT Intake_Question__c, COUNT(Id) cnt
                FROM Intake_Process__c
                WHERE Intake_Question__c IN :questionIds
                
                GROUP BY Intake_Question__c
            ]) {
                outcomeCountsMap.put((Id) ar.get('Intake_Question__c'), (Integer) ar.get('cnt'));
            }

            // Build warnings
            List<String> warnings = new List<String>();
            Map<Id, List<String>> referencingQuestions = new Map<Id, List<String>>();

            for (Intake_Process__c ref : incomingRefs) {
                if (!referencingQuestions.containsKey(ref.Next_Question__c)) {
                    referencingQuestions.put(ref.Next_Question__c, new List<String>());
                }
                referencingQuestions.get(ref.Next_Question__c).add(ref.Question__r.Name);
            }

            // Calculate total outcomes that will be deleted
            Integer totalOutcomesToDelete = 0;
            for (Integer count : outcomeCountsMap.values()) {
                totalOutcomesToDelete += count;
            }

            // Generate warnings
            if (!incomingRefs.isEmpty()) {
                warnings.add('WARNING: ' + incomingRefs.size() + ' outcomes from other questions reference these questions. Those outcomes will become broken.');
            }
            if (totalOutcomesToDelete > 0) {
                warnings.add('WARNING: ' + totalOutcomesToDelete + ' outcomes will be deleted along with these questions.');
            }

            Map<String, Object> result = new Map<String, Object>();
            result.put('canDelete', true); // Always allow but show warnings
            result.put('warnings', warnings);
            result.put('incomingReferenceCount', incomingRefs.size());
            result.put('outcomesToDeleteCount', totalOutcomesToDelete);
            result.put('referencingQuestions', referencingQuestions);

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error validating bulk delete: ' + e.getMessage());
        }
    }

    /**
     * Bulk delete questions and their outcomes
     * @param questionIds List of question IDs to delete
     * @param deleteCascade If true, also delete related outcomes
     * @return Map with success count and error count
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> bulkDeleteQuestions(List<Id> questionIds, Boolean deleteCascade) {
        try {
            Integer successCount = 0;
            Integer errorCount = 0;
            List<String> errorMessages = new List<String>();

            // Get questions
            List<Intake_Process__c> questionsToDelete = [
                SELECT Id, Name
                FROM Intake_Process__c
                WHERE Id IN :questionIds
                
            ];

            // If cascade delete, also delete outcomes
            if (deleteCascade) {
                List<Intake_Process__c> outcomesToDelete = [
                    SELECT Id
                    FROM Intake_Process__c
                    WHERE Intake_Question__c IN :questionIds
                    
                ];

                if (!outcomesToDelete.isEmpty()) {
                    delete outcomesToDelete;
                }
            }

            // Delete questions
            List<Database.DeleteResult> results = Database.delete(questionsToDelete, false);

            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successCount++;
                } else {
                    errorCount++;
                    String errorMsg = questionsToDelete[i].Name + ': ';
                    for (Database.Error err : results[i].getErrors()) {
                        errorMsg += err.getMessage() + '; ';
                    }
                    errorMessages.add(errorMsg);
                }
            }

            Map<String, Object> result = new Map<String, Object>();
            result.put('successCount', successCount);
            result.put('errorCount', errorCount);
            result.put('errorMessages', errorMessages);
            result.put('totalProcessed', questionIds.size());

            return result;

        } catch (Exception e) {
            throw new AuraHandledException('Error in bulk delete: ' + e.getMessage());
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
                
                ORDER BY Outcome__c
            ];

            // Get incoming references (questions that link to this one)
            List<Intake_Process__c> incomingQuestions = [
                SELECT Id, Name, Question__c, Outcome__c
                FROM Intake_Process__c
                WHERE Next_Question__c = :questionId
                
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
     * Build query for flow visualization nodes
     */
    private static String buildFlowNodeQuery(Map<String, Object> filters) {
        String query = 'SELECT Id, Name, Question__c, Input_Type__c, Presentation_Order__c, ' +
                      'Case_Type__c, Case_Sub_Type__c ' +
                      'FROM Intake_Process__c ' +
                      'WHERE Question__c != null ' +
                      'AND Intake_Question__c = null';

        // Add filters if provided (check for both null and empty strings)
        if (filters.containsKey('caseType') && filters.get('caseType') != null) {
            String caseType = String.valueOf(filters.get('caseType')).trim();
            if (String.isNotBlank(caseType)) {
                caseType = String.escapeSingleQuotes(caseType);
                query += ' AND Case_Type__c = \'' + caseType + '\'';
            }
        }

        if (filters.containsKey('caseSubType') && filters.get('caseSubType') != null) {
            String caseSubType = String.valueOf(filters.get('caseSubType')).trim();
            if (String.isNotBlank(caseSubType)) {
                caseSubType = String.escapeSingleQuotes(caseSubType);
                query += ' AND Case_Sub_Type__c = \'' + caseSubType + '\'';
            }
        }

        // Limit for performance (can be adjusted)
        if (filters.containsKey('limit') && filters.get('limit') != null) {
            query += ' LIMIT ' + filters.get('limit');
        } else {
            query += ' LIMIT 1000'; // Default limit for visualization
        }

        return query;
    }

    /**
     * Build dynamic SOQL query for questions
     */
    private static String buildQuestionQuery(
        Map<String, Object> filters,
        String sortField,
        String sortDirection,
        Integer limitRecords,
        Integer offsetRecords,
        Set<Id> quickFilterIds
    ) {
        String query = 'SELECT Id, Name, Question__c, Input_Type__c, Presentation_Order__c, ' +
                      'Case_Type__c, Case_Sub_Type__c, Case_Reason__c, User_Role__c, ' +
                      'Customer_Account__c, Customer_Account__r.Name, ' +
                      'Customer_Location__c, Customer_Location__r.Name, ' +
                      'LastModifiedDate, LastModifiedBy.Name, ' +
                      'CreatedDate, CreatedBy.Name ' +
                      'FROM Intake_Process__c ' +
                      'WHERE Question__c != null ' +
                      'AND Intake_Question__c = null';

        // Apply quick filter IDs if provided
        if (quickFilterIds != null && !quickFilterIds.isEmpty()) {
            query += ' AND Id IN :quickFilterIds';
        }

        // Add filters (check for both null and empty strings)
        if (filters.containsKey('searchTerm') && filters.get('searchTerm') != null) {
            String searchTerm = String.valueOf(filters.get('searchTerm')).trim();
            if (String.isNotBlank(searchTerm)) {
                searchTerm = String.escapeSingleQuotes(searchTerm);
                // Enhanced global search - searches across multiple fields
                query += ' AND (Question__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR Name LIKE \'%' + searchTerm + '%\' ' +
                        'OR Case_Type__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR Case_Sub_Type__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR Case_Reason__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR User_Role__c LIKE \'%' + searchTerm + '%\')';
            }
        }

        if (filters.containsKey('caseType') && filters.get('caseType') != null) {
            String caseType = String.valueOf(filters.get('caseType')).trim();
            if (String.isNotBlank(caseType)) {
                caseType = String.escapeSingleQuotes(caseType);
                query += ' AND Case_Type__c = \'' + caseType + '\'';
            }
        }

        if (filters.containsKey('caseSubType') && filters.get('caseSubType') != null) {
            String caseSubType = String.valueOf(filters.get('caseSubType')).trim();
            if (String.isNotBlank(caseSubType)) {
                caseSubType = String.escapeSingleQuotes(caseSubType);
                query += ' AND Case_Sub_Type__c = \'' + caseSubType + '\'';
            }
        }

        if (filters.containsKey('inputType') && filters.get('inputType') != null) {
            String inputType = String.valueOf(filters.get('inputType')).trim();
            if (String.isNotBlank(inputType)) {
                inputType = String.escapeSingleQuotes(inputType);
                query += ' AND Input_Type__c = \'' + inputType + '\'';
            }
        }

        if (filters.containsKey('userRole') && filters.get('userRole') != null) {
            String userRole = String.valueOf(filters.get('userRole')).trim();
            if (String.isNotBlank(userRole)) {
                userRole = String.escapeSingleQuotes(userRole);
                query += ' AND User_Role__c = \'' + userRole + '\'';
            }
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
    private static String buildCountQuery(Map<String, Object> filters, Set<Id> quickFilterIds) {
        String query = 'SELECT COUNT() FROM Intake_Process__c ' +
                      'WHERE Question__c != null ' +
                      'AND Intake_Question__c = null';

        // Apply quick filter IDs if provided
        if (quickFilterIds != null && !quickFilterIds.isEmpty()) {
            query += ' AND Id IN :quickFilterIds';
        }

        // Add same filters as main query (check for both null and empty strings)
        if (filters.containsKey('searchTerm') && filters.get('searchTerm') != null) {
            String searchTerm = String.valueOf(filters.get('searchTerm')).trim();
            if (String.isNotBlank(searchTerm)) {
                searchTerm = String.escapeSingleQuotes(searchTerm);
                // Enhanced global search - searches across multiple fields
                query += ' AND (Question__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR Name LIKE \'%' + searchTerm + '%\' ' +
                        'OR Case_Type__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR Case_Sub_Type__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR Case_Reason__c LIKE \'%' + searchTerm + '%\' ' +
                        'OR User_Role__c LIKE \'%' + searchTerm + '%\')';
            }
        }

        if (filters.containsKey('caseType') && filters.get('caseType') != null) {
            String caseType = String.valueOf(filters.get('caseType')).trim();
            if (String.isNotBlank(caseType)) {
                caseType = String.escapeSingleQuotes(caseType);
                query += ' AND Case_Type__c = \'' + caseType + '\'';
            }
        }

        if (filters.containsKey('caseSubType') && filters.get('caseSubType') != null) {
            String caseSubType = String.valueOf(filters.get('caseSubType')).trim();
            if (String.isNotBlank(caseSubType)) {
                caseSubType = String.escapeSingleQuotes(caseSubType);
                query += ' AND Case_Sub_Type__c = \'' + caseSubType + '\'';
            }
        }

        if (filters.containsKey('inputType') && filters.get('inputType') != null) {
            String inputType = String.valueOf(filters.get('inputType')).trim();
            if (String.isNotBlank(inputType)) {
                inputType = String.escapeSingleQuotes(inputType);
                query += ' AND Input_Type__c = \'' + inputType + '\'';
            }
        }

        if (filters.containsKey('userRole') && filters.get('userRole') != null) {
            String userRole = String.valueOf(filters.get('userRole')).trim();
            if (String.isNotBlank(userRole)) {
                userRole = String.escapeSingleQuotes(userRole);
                query += ' AND User_Role__c = \'' + userRole + '\'';
            }
        }

        return query;
    }

    /**
     * Get IDs of orphaned questions (no incoming references and not starting questions)
     */
    private static Set<Id> getOrphanedQuestionIds() {
        Set<Id> orphanedIds = new Set<Id>();

        // Get all question IDs
        Set<Id> allQuestionIds = new Set<Id>();
        for (Intake_Process__c q : [
            SELECT Id, Presentation_Order__c
            FROM Intake_Process__c
            WHERE Question__c != null
            AND Intake_Question__c = null
        ]) {
            // Exclude starting questions (Presentation_Order__c = 1)
            if (q.Presentation_Order__c == null || q.Presentation_Order__c != 1) {
                allQuestionIds.add(q.Id);
            }
        }

        // Get IDs that have incoming references
        Set<Id> referencedIds = new Set<Id>();
        for (Intake_Process__c outcome : [
            SELECT Next_Question__c
            FROM Intake_Process__c
            WHERE Next_Question__c != null
            AND Next_Question__c IN :allQuestionIds
        ]) {
            referencedIds.add(outcome.Next_Question__c);
        }

        // Orphaned = in allQuestionIds but NOT in referencedIds
        for (Id qId : allQuestionIds) {
            if (!referencedIds.contains(qId)) {
                orphanedIds.add(qId);
            }
        }

        return orphanedIds;
    }

    /**
     * Get IDs of questions with no outcomes
     */
    private static Set<Id> getNoOutcomeQuestionIds() {
        Set<Id> noOutcomeIds = new Set<Id>();

        // Get all question IDs
        Set<Id> allQuestionIds = new Set<Id>();
        for (Intake_Process__c q : [
            SELECT Id
            FROM Intake_Process__c
            WHERE Question__c != null
            AND Intake_Question__c = null
        ]) {
            allQuestionIds.add(q.Id);
        }

        // Get IDs that have outcomes
        Set<Id> withOutcomeIds = new Set<Id>();
        for (Intake_Process__c outcome : [
            SELECT Intake_Question__c
            FROM Intake_Process__c
            WHERE Intake_Question__c != null
            AND Intake_Question__c IN :allQuestionIds
        ]) {
            withOutcomeIds.add(outcome.Intake_Question__c);
        }

        // No outcomes = in allQuestionIds but NOT in withOutcomeIds
        for (Id qId : allQuestionIds) {
            if (!withOutcomeIds.contains(qId)) {
                noOutcomeIds.add(qId);
            }
        }

        return noOutcomeIds;
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
                      'WHERE Question__c != null ' +
                      'AND Intake_Question__c = null ' +
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
