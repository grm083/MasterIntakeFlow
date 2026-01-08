public with sharing class IntakeProcessController {

    // ========== WRAPPER CLASSES ==========

    public class InitialDataWrapper {
        @AuraEnabled public Boolean cpqEligible { get; set; }
        @AuraEnabled public QuestionWrapper firstQuestion { get; set; }
        @AuraEnabled public Map<String, QuestionWrapper> nextQuestionsCache { get; set; }
        @AuraEnabled public CaseContextWrapper caseContext { get; set; }
    }

    public class CaseContextWrapper {
        @AuraEnabled public String caseType { get; set; }
        @AuraEnabled public String caseSubType { get; set; }
        @AuraEnabled public String caseReason { get; set; }
        @AuraEnabled public String caseNumber { get; set; }
        @AuraEnabled public String clientId { get; set; }
        @AuraEnabled public String locationId { get; set; }
        @AuraEnabled public String clientName { get; set; }
        @AuraEnabled public String locationName { get; set; }
        @AuraEnabled public String assetName { get; set; }
        @AuraEnabled public String contactName { get; set; }
        @AuraEnabled public Date serviceDate { get; set; }
    }

    public class QuestionWrapper {
        @AuraEnabled public String questionId { get; set; }
        @AuraEnabled public String questionText { get; set; }
        @AuraEnabled public String inputType { get; set; }
        @AuraEnabled public Integer presentationOrder { get; set; }
        @AuraEnabled public List<OutcomeWrapper> outcomes { get; set; }
    }

    public class OutcomeWrapper {
        @AuraEnabled public String outcomeId { get; set; }
        @AuraEnabled public String outcomeText { get; set; }
        @AuraEnabled public String nextQuestionId { get; set; }
        @AuraEnabled public Boolean hasNextQuestion { get; set; }
        @AuraEnabled public Boolean isTerminal { get; set; }
        @AuraEnabled public String outcomeStatement { get; set; }
        @AuraEnabled public Boolean anyValue { get; set; }
        @AuraEnabled public ActionWrapper actions { get; set; }
    }

    public class ActionWrapper {
        @AuraEnabled public Boolean updateCaseRecordType { get; set; }
        @AuraEnabled public String caseRecordType { get; set; }
        @AuraEnabled public Boolean updateCaseType { get; set; }
        @AuraEnabled public String caseType { get; set; }
        @AuraEnabled public Boolean updateCaseSubType { get; set; }
        @AuraEnabled public String caseSubType { get; set; }
        @AuraEnabled public Boolean updateCaseReason { get; set; }
        @AuraEnabled public String caseReason { get; set; }
        @AuraEnabled public Boolean updateCaseStatus { get; set; }
        @AuraEnabled public String caseStatus { get; set; }
        @AuraEnabled public String teamName { get; set; }
        @AuraEnabled public String queueAssigned { get; set; }
        @AuraEnabled public Boolean assignToCurrentUser { get; set; }
        @AuraEnabled public Boolean createTask { get; set; }
        @AuraEnabled public String taskType { get; set; }
        @AuraEnabled public String taskProcess { get; set; }
    }

    public class CompletionWrapper {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String caseStatus { get; set; }
        @AuraEnabled public String commentId { get; set; }
        @AuraEnabled public String taskId { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
    }

    // ========== PUBLIC METHODS ==========

    /**
     * Initialize the intake process with batch fetching
     * This is the main entry point - checks CPQ eligibility and loads first question + cache
     */
    @AuraEnabled
    public static InitialDataWrapper initializeIntake(Id caseId) {
        InitialDataWrapper result = new InitialDataWrapper();

        try {
            // 1. Get case context
            Case c = [
                SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
                       CaseNumber, Client__c, Location__c, AssetId, ContactId,
                       Client__r.Name, Location__r.Name, Asset.Name, Contact.Name,
                       Asset.Project_Code__c, Master_Intake_Complete__c, Service_Date__c
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
            ];

            result.caseContext = buildCaseContext(c);

            // 2. Check CPQ eligibility FIRST
            result.cpqEligible = checkCPQEligibility(c);

            if (result.cpqEligible) {
                return result; // Exit early if CPQ eligible
            }

            // 3. Get first question using existing hierarchy logic
            Intake_Process__c firstQuestionRecord = getFirstQuestionRecord(c);

            if (firstQuestionRecord == null) {
                return result; // No questions configured
            }

            // 4. Build question wrapper with all outcomes
            result.firstQuestion = buildQuestionWrapper(firstQuestionRecord);

            // 5. BATCH FETCH: Get all possible next questions from first question's outcomes
            result.nextQuestionsCache = new Map<String, QuestionWrapper>();
            Set<Id> nextQuestionIds = collectNextQuestionIds(result.firstQuestion.outcomes);

            if (!nextQuestionIds.isEmpty()) {
                Map<String, QuestionWrapper> batchCache = batchFetchQuestions(nextQuestionIds);
                result.nextQuestionsCache.putAll(batchCache);
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error initializing intake: ' + e.getMessage());
        }

        return result;
    }

    /**
     * Get the next batch of questions based on selected outcome
     * Returns the immediate next question + all questions it could lead to
     */
    @AuraEnabled
    public static Map<String, QuestionWrapper> getNextQuestionBatch(String outcomeId) {
        Map<String, QuestionWrapper> cache = new Map<String, QuestionWrapper>();

        try {
            // Get the outcome record
            Intake_Process__c outcome = [
                SELECT Next_Question__c
                FROM Intake_Process__c
                WHERE Id = :outcomeId
                LIMIT 1
            ];

            if (outcome.Next_Question__c == null) {
                return cache; // Terminal outcome
            }

            // Get next question record
            Intake_Process__c nextQuestionRecord = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c,
                       Case_Type__c, Case_Sub_Type__c, Case_Reason__c
                FROM Intake_Process__c
                WHERE Id = :outcome.Next_Question__c
                LIMIT 1
            ];

            // Build wrapper
            QuestionWrapper nextQuestion = buildQuestionWrapper(nextQuestionRecord);
            cache.put(nextQuestionRecord.Id, nextQuestion);

            // Batch fetch the questions that could come after this one
            Set<Id> nextQuestionIds = collectNextQuestionIds(nextQuestion.outcomes);

            if (!nextQuestionIds.isEmpty()) {
                Map<String, QuestionWrapper> deepCache = batchFetchQuestions(nextQuestionIds);
                cache.putAll(deepCache);
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error fetching next question: ' + e.getMessage());
        }

        return cache;
    }

    /**
     * Complete the intake process - create comment and execute case updates
     */
    @AuraEnabled
    public static CompletionWrapper completeIntake(
        Id caseId,
        String answersJSON,
        Id finalOutcomeId
    ) {
        CompletionWrapper result = new CompletionWrapper();

        try {
            // Parse answers
            List<Object> answers = (List<Object>) JSON.deserializeUntyped(answersJSON);

            // Get outcome statement
            String outcomeStatement = '';
            if (finalOutcomeId != null) {
                Intake_Process__c outcome = [
                    SELECT Outcome_Statement__c
                    FROM Intake_Process__c
                    WHERE Id = :finalOutcomeId
                    LIMIT 1
                ];
                outcomeStatement = outcome.Outcome_Statement__c != null ? outcome.Outcome_Statement__c : '';
            }

            // Build comment text with HTML formatting
            String commentText = buildCommentFromAnswers(answers, outcomeStatement);

            // Create comment
            result.commentId = createIntakeComment(caseId, commentText);

            // Execute case updates
            result.taskId = executeCaseUpdates(caseId, finalOutcomeId);

            // Get final case status
            Case c = [SELECT Status FROM Case WHERE Id = :caseId LIMIT 1];
            result.caseStatus = c.Status;

            result.success = true;

        } catch (Exception e) {
            result.success = false;
            result.errorMessage = e.getMessage();
        }

        return result;
    }

    // ========== PRIVATE HELPER METHODS ==========

    /**
     * Build case context wrapper
     */
    private static CaseContextWrapper buildCaseContext(Case c) {
        CaseContextWrapper context = new CaseContextWrapper();
        context.caseType = c.Case_Type__c;
        context.caseSubType = c.Case_Sub_Type__c;
        context.caseReason = c.Case_Reason__c;
        context.caseNumber = c.CaseNumber;
        context.clientId = c.Client__c;
        context.locationId = c.Location__c;

        // Populate relationship field names
        context.clientName = (c.Client__r != null) ? c.Client__r.Name : null;
        context.locationName = (c.Location__r != null) ? c.Location__r.Name : null;
        context.assetName = (c.Asset != null) ? c.Asset.Name : null;
        context.contactName = (c.Contact != null) ? c.Contact.Name : null;
        context.serviceDate = c.Service_Date__c;

        return context;
    }

    /**
     * Check CPQ eligibility using metadata
     */
    private static Boolean checkCPQEligibility(Case c) {
        // Query AC_Scope_Controller__mdt for matching case type/subtype/reason
        List<AC_Scope_Controller__mdt> cpqConfig = [
            SELECT Id
            FROM AC_Scope_Controller__mdt
            WHERE Case_Type__c = :c.Case_Type__c
            AND Case_Sub_Type__c = :c.Case_Sub_Type__c
            AND Case_Reason__c = :c.Case_Reason__c
            LIMIT 1
        ];

        // Check if user has permission
        Boolean hasPermission = UserInfo.getUserId() != null; // Placeholder - check actual field
        // TODO: Implement actual check for Update_Asset_Active_User__c

        return !cpqConfig.isEmpty() && hasPermission;
    }

    /**
     * Get first question using hierarchical logic
     * Reuses existing logic from IntakeProcessAuraHandler
     */
    private static Intake_Process__c getFirstQuestionRecord(Case c) {
        String caseReason = c.Case_Reason__c != null ? c.Case_Reason__c : 'Null';

        // Try Account level
        Intake_Process__c question = getAccountQuestion(c.Client__c, c.Case_Type__c, c.Case_Sub_Type__c, caseReason);
        if (question != null) return question;

        // Try Location level
        question = getLocationQuestion(c.Location__c, c.Case_Type__c, c.Case_Sub_Type__c, caseReason);
        if (question != null) return question;

        // Try Role level
        question = getRoleQuestion(c.Case_Type__c, c.Case_Sub_Type__c, caseReason);
        if (question != null) return question;

        // Fallback to General
        return getGeneralQuestion(c.Case_Type__c, c.Case_Sub_Type__c, caseReason);
    }

    private static Intake_Process__c getAccountQuestion(Id clientId, String caseType, String subType, String reason) {
        List<Intake_Process__c> questions = new List<Intake_Process__c>();

        if (reason != 'Null') {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Customer_Account__c = :clientId
                AND Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = :reason
                AND RecordType.Name = 'Intake Questions'
                LIMIT 1
            ];
        } else {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Customer_Account__c = :clientId
                AND Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = null
                AND RecordType.Name = 'Intake Questions'
                LIMIT 1
            ];
        }

        return questions.isEmpty() ? null : questions[0];
    }

    private static Intake_Process__c getLocationQuestion(Id locationId, String caseType, String subType, String reason) {
        List<Intake_Process__c> questions = new List<Intake_Process__c>();

        if (reason != 'Null') {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Customer_Location__c = :locationId
                AND Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = :reason
                AND RecordType.Name = 'Intake Questions'
                LIMIT 1
            ];
        } else {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Customer_Location__c = :locationId
                AND Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = null
                AND RecordType.Name = 'Intake Questions'
                LIMIT 1
            ];
        }

        return questions.isEmpty() ? null : questions[0];
    }

    private static Intake_Process__c getRoleQuestion(String caseType, String subType, String reason) {
        String userRoleId = UserInfo.getUserRoleId();
        if (userRoleId == null) return null;

        UserRole uRole = [SELECT Name FROM UserRole WHERE Id = :userRoleId];
        List<Intake_Process__c> questions = new List<Intake_Process__c>();

        if (reason != 'Null') {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = :reason
                AND RecordType.Name = 'Intake Questions'
                AND User_Role__c = :uRole.Name
                LIMIT 1
            ];
        } else {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = null
                AND RecordType.Name = 'Intake Questions'
                AND User_Role__c = :uRole.Name
                LIMIT 1
            ];
        }

        return questions.isEmpty() ? null : questions[0];
    }

    private static Intake_Process__c getGeneralQuestion(String caseType, String subType, String reason) {
        List<Intake_Process__c> questions = new List<Intake_Process__c>();

        if (reason != 'Null') {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = :reason
                AND RecordType.Name = 'Intake Questions'
                AND User_Role__c = null
                AND Customer_Account__c = null
                AND Customer_Location__c = null
                LIMIT 1
            ];
        } else {
            questions = [
                SELECT Id, Question__c, Input_Type__c, Presentation_Order__c
                FROM Intake_Process__c
                WHERE Presentation_Order__c = 1
                AND Case_Type__c = :caseType
                AND Case_Sub_Type__c = :subType
                AND Case_Reason__c = null
                AND RecordType.Name = 'Intake Questions'
                AND User_Role__c = null
                AND Customer_Account__c = null
                AND Customer_Location__c = null
                LIMIT 1
            ];
        }

        return questions.isEmpty() ? null : questions[0];
    }

    /**
     * Build question wrapper with all outcomes
     */
    private static QuestionWrapper buildQuestionWrapper(Intake_Process__c question) {
        QuestionWrapper wrapper = new QuestionWrapper();
        wrapper.questionId = question.Id;
        wrapper.questionText = question.Question__c;
        wrapper.inputType = question.Input_Type__c;
        wrapper.presentationOrder = Integer.valueOf(question.Presentation_Order__c);

        // Get all outcomes for this question in one query
        List<Intake_Process__c> outcomes = [
            SELECT Id, Outcome__c, Any_Value__c, Next_Question__c, Outcome_Statement__c,
                   Update_Case_Record_Type__c, Case_Record_Type__c,
                   Update_Case_Type__c, Case_Type__c,
                   Update_Case_Sub_Type__c, Case_Sub_Type__c,
                   Update_Case_Reason__c, Case_Reason__c,
                   Update_Case_Status__c, Case_Status__c,
                   Team_Name__c, Queue_Assigned__c, Assign_to_Current_User__c,
                   Create_Task__c, Task_Type__c, Task_Process__c
            FROM Intake_Process__c
            WHERE RecordType.Name = 'Intake Outcomes'
            AND Intake_Question__c = :question.Id
            ORDER BY Outcome__c
        ];

        wrapper.outcomes = new List<OutcomeWrapper>();
        for (Intake_Process__c outcome : outcomes) {
            wrapper.outcomes.add(buildOutcomeWrapper(outcome));
        }

        return wrapper;
    }

    /**
     * Build outcome wrapper with action metadata
     */
    private static OutcomeWrapper buildOutcomeWrapper(Intake_Process__c outcome) {
        OutcomeWrapper wrapper = new OutcomeWrapper();
        wrapper.outcomeId = outcome.Id;
        wrapper.outcomeText = outcome.Outcome__c;
        wrapper.nextQuestionId = outcome.Next_Question__c;
        wrapper.hasNextQuestion = outcome.Next_Question__c != null;
        wrapper.isTerminal = outcome.Next_Question__c == null;
        wrapper.outcomeStatement = outcome.Outcome_Statement__c;
        wrapper.anyValue = outcome.Any_Value__c != null && outcome.Any_Value__c;

        // Build action metadata
        wrapper.actions = new ActionWrapper();
        wrapper.actions.updateCaseRecordType = outcome.Update_Case_Record_Type__c;
        wrapper.actions.caseRecordType = outcome.Case_Record_Type__c;
        wrapper.actions.updateCaseType = outcome.Update_Case_Type__c;
        wrapper.actions.caseType = outcome.Case_Type__c;
        wrapper.actions.updateCaseSubType = outcome.Update_Case_Sub_Type__c;
        wrapper.actions.caseSubType = outcome.Case_Sub_Type__c;
        wrapper.actions.updateCaseReason = outcome.Update_Case_Reason__c;
        wrapper.actions.caseReason = outcome.Case_Reason__c;
        wrapper.actions.updateCaseStatus = outcome.Update_Case_Status__c;
        wrapper.actions.caseStatus = outcome.Case_Status__c;
        wrapper.actions.teamName = outcome.Team_Name__c;
        wrapper.actions.queueAssigned = outcome.Queue_Assigned__c;
        wrapper.actions.assignToCurrentUser = outcome.Assign_to_Current_User__c;
        wrapper.actions.createTask = outcome.Create_Task__c;
        wrapper.actions.taskType = outcome.Task_Type__c;
        wrapper.actions.taskProcess = outcome.Task_Process__c;

        return wrapper;
    }

    /**
     * Collect all unique next question IDs from outcomes
     */
    private static Set<Id> collectNextQuestionIds(List<OutcomeWrapper> outcomes) {
        Set<Id> nextQuestionIds = new Set<Id>();
        for (OutcomeWrapper outcome : outcomes) {
            if (outcome.nextQuestionId != null) {
                nextQuestionIds.add(outcome.nextQuestionId);
            }
        }
        return nextQuestionIds;
    }

    /**
     * Batch fetch multiple questions at once
     */
    private static Map<String, QuestionWrapper> batchFetchQuestions(Set<Id> questionIds) {
        Map<String, QuestionWrapper> cache = new Map<String, QuestionWrapper>();

        if (questionIds.isEmpty()) {
            return cache;
        }

        // Fetch all questions in one query
        Map<Id, Intake_Process__c> questionsById = new Map<Id, Intake_Process__c>([
            SELECT Id, Question__c, Input_Type__c, Presentation_Order__c,
                   Case_Type__c, Case_Sub_Type__c, Case_Reason__c
            FROM Intake_Process__c
            WHERE Id IN :questionIds
        ]);

        // Build wrappers for each
        for (Id questionId : questionsById.keySet()) {
            cache.put(questionId, buildQuestionWrapper(questionsById.get(questionId)));
        }

        return cache;
    }

    /**
     * Build comment text from answer history with HTML formatting
     */
    private static String buildCommentFromAnswers(List<Object> answers, String outcomeStatement) {
        String commentText = '<div style="font-family: Arial, sans-serif; line-height: 1.6;">';

        // Add header
        commentText += '<h3 style="color: #024731; border-bottom: 3px solid #1c8200; padding-bottom: 8px; margin-bottom: 15px;">Master Intake Complete</h3>';

        // Add outcome statement if provided
        if (String.isNotBlank(outcomeStatement)) {
            commentText += '<div style="background-color: #f0f9ed; padding: 12px; border-left: 5px solid #1c8200; margin-bottom: 20px; border-radius: 4px;">';
            commentText += '<strong style="color: #024731; font-size: 16px;">Outcome:</strong><br/>';
            commentText += '<span style="color: #4f4f58;">' + outcomeStatement.escapeHtml4() + '</span>';
            commentText += '</div>';
        }

        // Add questions and answers section
        commentText += '<h4 style="color: #024731; margin-bottom: 12px;">Questions and Answers:</h4>';
        commentText += '<ul style="list-style-type: none; padding-left: 0;">';

        for (Object answerObj : answers) {
            Map<String, Object> answer = (Map<String, Object>) answerObj;
            String question = (String) answer.get('question');
            String response = (String) answer.get('answer');

            commentText += '<li style="margin-bottom: 15px; padding: 10px; background-color: #fafafa; border-left: 3px solid #1c8200; border-radius: 4px;">';
            commentText += '<strong style="color: #024731;">' + question.escapeHtml4() + '</strong><br/>';
            commentText += '<span style="color: #4f4f58; margin-left: 10px;">' + response.escapeHtml4() + '</span>';
            commentText += '</li>';
        }

        commentText += '</ul>';
        commentText += '</div>';

        return commentText;
    }

    /**
     * Create intake comment record
     */
    private static String createIntakeComment(Id caseId, String commentText) {
        Case c = [
            SELECT Id, CaseNumber, Tracking_Number__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        User u = [
            SELECT Id, Acorn_SUser_ID__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        Comment__c comm = new Comment__c();
        comm.Case__c = c.Id;
        comm.Case_Number__c = c.CaseNumber;
        comm.Type__c = 'Case';
        comm.Comment__c = commentText;
        comm.Acorn_SUser_ID__c = u.Acorn_SUser_ID__c;
        comm.Communication_Log_Type_Name__c = 'Internal';
        comm.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Acorn_Ticket_Comment' LIMIT 1].Id;

        if (c.Tracking_Number__c != null) {
            comm.Acorn_Tracking_Number__c = c.Tracking_Number__c;
        }

        insert comm;

        // Mark case as intake complete
        c.Master_Intake_Complete__c = true;
        c.Case_Comments__c = 'Salesforce Generated Case';
        update c;

        return comm.Id;
    }

    /**
     * Execute case updates based on outcome
     * Reuses logic from IntakeProcessAuraHandler.doCaseUpdates
     */
    private static String executeCaseUpdates(Id caseId, Id outcomeId) {
        Case c = [
            SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
                   Status, Team_Name__c, Team_Queue__c, Case_Sub_Status__c, User_Name__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        Intake_Process__c o = [
            SELECT Id, Update_Case_Record_Type__c, Update_Case_Status__c, Update_Case_Type__c,
                   Update_Case_Sub_Type__c, Update_Case_Reason__c, Team_Name__c, Queue_Assigned__c, Case_Status__c,
                   Case_Record_Type__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Task_Type__c, Task_Process__c,
                   Create_Task__c, Outcome_Statement__c, Assign_To_Current_User__c
            FROM Intake_Process__c
            WHERE Id = :outcomeId
            LIMIT 1
        ];

        String taskId = null;

        // Update record type
        if (o.Update_Case_Record_Type__c) {
            c.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = :o.Case_Record_Type__c LIMIT 1].Id;
        }

        // Update team and queue
        if (!String.isBlank(o.Queue_Assigned__c)) {
            c.Team_Name__c = o.Team_Name__c;
            c.Team_Queue__c = o.Queue_Assigned__c;
        }

        // Assign to current user
        if (o.Assign_to_Current_User__c) {
            c.User_Name__c = UserInfo.getUserId();
        }

        // Create task if needed
        Task t = new Task();
        if (o.Create_Task__c) {
            t.WhatId = c.Id;
            t.Subject = o.Task_Type__c;
            t.Process__c = 'Master Intake';
            t.Description = o.Outcome_Statement__c;
            t.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Quick Task' LIMIT 1].Id;
            t.OwnerId = UserInfo.getUserId();
        }

        // Update case
        update c;

        // Insert task if configured
        if (t.WhatId != null) {
            insert t;
            taskId = t.Id;
        }

        // Update case type/sub-type/reason
        if (o.Update_Case_Type__c || o.Update_Case_Sub_Type__c || o.Update_Case_Reason__c) {
            c.Case_Type__c = o.Case_Type__c;
            c.Case_Sub_Type__c = o.Case_Sub_Type__c;
            c.Case_Reason__c = o.Case_Reason__c;
            update c;
        }

        // Update status with special logic
        if (o.Update_Case_Status__c) {
            c.Status = o.Case_Status__c;

            if (c.Case_Sub_Type__c == 'Service Not Performed' && o.Case_Status__c == 'Open') {
                c.Case_Sub_Status__c = 'Pending Service Issue Resolution';
            }

            if (c.Case_Sub_Type__c == 'Bale(s)' && o.Case_Status__c == 'Pending') {
                c.Case_Sub_Status__c = 'Pending Request Approval';
            }

            update c;
        }

        return taskId;
    }
}
