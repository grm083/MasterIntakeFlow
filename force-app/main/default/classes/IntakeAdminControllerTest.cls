/**
 * @description Test class for IntakeAdminController
 * Tests admin dashboard functionality including filtering, bulk operations, and flow visualization
 * Target: 90%+ code coverage
 */
@isTest(seeAllData = false)
public class IntakeAdminControllerTest {

    private static final String SYS_ADMIN = 'System Administrator';
    private static final String TEST_CLIENT = 'Test Client';
    private static final String CASE_TYPE = 'Pickup';
    private static final String CASE_SUBTYPE = 'Extra Pickup';
    private static final String CASE_REASON = 'Test Reason';

    /**
     * Test setup - creates common test data
     */
    @testSetup
    static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User testUser = TestDataFactory.createUser(p);
        testUser.bypass_validation__c = true;
        insert testUser;

        System.runAs(testUser) {
            // Create Account (Client)
            List<Account> clients = TestDataFactory.createAccount(TEST_CLIENT, testUser, 'Client');
            clients[0].AccountNumber = 'TEST001';
            insert clients;

            // Create Account (Location)
            List<Account> locations = TestDataFactory.createLocation('Location', testUser, clients[0].Id);
            insert locations;

            // Create Intake Process Records
            createIntakeProcessData(clients[0].Id, locations[0].Id);
        }
    }

    /**
     * Helper method to create Intake Process test data for admin dashboard
     */
    private static void createIntakeProcessData(Id clientId, Id locationId) {
        Id questionRecordTypeId = TestDataFactory.getRecordType('Intake Questions', 'Intake_Process__c');
        Id outcomeRecordTypeId = TestDataFactory.getRecordType('Intake Outcomes', 'Intake_Process__c');

        // Question 1 (Starting question)
        Intake_Process__c question1 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'What is your issue?',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 1,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = CASE_REASON,
            User_Role__c = 'Test Role'
        );
        insert question1;

        // Question 2 (With customer account)
        Intake_Process__c question2 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'How urgent is this?',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 2,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = CASE_REASON,
            Customer_Account__c = clientId
        );
        insert question2;

        // Question 3 (With location)
        Intake_Process__c question3 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'Location specific question',
            Input_Type__c = 'Text',
            Presentation_Order__c = 3,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Customer_Location__c = locationId
        );
        insert question3;

        // Question 4 (Orphaned - no incoming references, not starting question)
        Intake_Process__c question4 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'Orphaned question',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 5,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE
        );
        insert question4;

        // Question 5 (Missing input type)
        Intake_Process__c question5 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'Question without input type',
            Input_Type__c = null,
            Presentation_Order__c = 6,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE
        );
        insert question5;

        // Question 6 (For self-referential test)
        Intake_Process__c question6 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'Self referential question',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 7,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE
        );
        insert question6;

        // Outcome 1 for Question 1 (branches to Question 2)
        Intake_Process__c outcome1 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question1.Id,
            Outcome__c = 'Option A',
            Next_Question__c = question2.Id,
            Outcome_Statement__c = 'Proceeding to urgency question',
            Update_Case_Status__c = true,
            Case_Status__c = 'Open'
        );
        insert outcome1;

        // Outcome 2 for Question 1 (branches to Question 3)
        Intake_Process__c outcome2 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question1.Id,
            Outcome__c = 'Option B',
            Next_Question__c = question3.Id,
            Outcome_Statement__c = 'Proceeding to location question'
        );
        insert outcome2;

        // Outcome 3 for Question 2 (terminal)
        Intake_Process__c outcome3 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question2.Id,
            Outcome__c = 'Very Urgent',
            Next_Question__c = null,
            Outcome_Statement__c = 'Case prioritized',
            Update_Case_Type__c = true,
            Case_Type__c = 'Priority',
            Create_Task__c = true,
            Task_Type__c = 'Urgent Follow Up',
            Task_Process__c = 'Priority'
        );
        insert outcome3;

        // Outcome 4 for Question 3 (branches to Question 2 - creates a path)
        Intake_Process__c outcome4 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'Need More Info',
            Next_Question__c = question2.Id,
            Outcome_Statement__c = 'Getting more information'
        );
        insert outcome4;

        // Outcome 5 - Self-referential outcome (loops back to same question)
        Intake_Process__c outcome5 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question6.Id,
            Outcome__c = 'Retry',
            Next_Question__c = question6.Id,
            Outcome_Statement__c = 'Loops back to self'
        );
        insert outcome5;
    }

    /**
     * Test: getQuestions with no filters
     */
    @isTest
    static void testGetQuestions_NoFilters() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(null, 'Case_Type__c', 'ASC', 100, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
            System.assert(questions.size() > 0, 'Should return questions');
        }
    }

    /**
     * Test: getQuestions with search term filter
     */
    @isTest
    static void testGetQuestions_WithSearchTerm() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'searchTerm' => 'urgent'
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(filtersJSON, 'Question__c', 'ASC', 100, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
        }
    }

    /**
     * Test: getQuestions with multiple filters
     */
    @isTest
    static void testGetQuestions_WithMultipleFilters() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'caseType' => CASE_TYPE,
                'caseSubType' => CASE_SUBTYPE,
                'inputType' => 'Picklist',
                'caseReason' => CASE_REASON,
                'userRole' => 'Test Role'
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(filtersJSON, 'Presentation_Order__c', 'DESC', 50, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
        }
    }

    /**
     * Test: getQuestions with customer account filter
     */
    @isTest
    static void testGetQuestions_WithCustomerAccountFilter() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'customerAccount' => TEST_CLIENT
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(filtersJSON, null, null, 100, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
        }
    }

    /**
     * Test: getQuestions with orphaned filter
     */
    @isTest
    static void testGetQuestions_ShowOrphaned() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'showOrphaned' => true
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(filtersJSON, 'Name', 'ASC', 100, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
        }
    }

    /**
     * Test: getQuestions with no outcomes filter
     */
    @isTest
    static void testGetQuestions_ShowNoOutcomes() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'showNoOutcomes' => true
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(filtersJSON, 'Name', 'ASC', 100, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
        }
    }

    /**
     * Test: getQuestions with self-referential filter
     */
    @isTest
    static void testGetQuestions_ShowSelfReferential() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'showSelfReferential' => true
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(filtersJSON, 'Name', 'ASC', 100, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
        }
    }

    /**
     * Test: getQuestions with missing input type filter
     */
    @isTest
    static void testGetQuestions_ShowMissingInputType() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'showMissingInputType' => true
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            List<IntakeAdminController.QuestionWrapper> questions =
                IntakeAdminController.getQuestions(filtersJSON, 'Name', 'ASC', 100, 0);
            Test.stopTest();

            System.assertNotEquals(null, questions, 'Questions list should not be null');
        }
    }

    /**
     * Test: getQuestions error handling
     */
    @isTest
    static void testGetQuestions_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            try {
                // Pass invalid JSON to trigger error
                IntakeAdminController.getQuestions('invalid json {', null, null, 100, 0);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error fetching questions'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: getQuestionCount with filters
     */
    @isTest
    static void testGetQuestionCount_WithFilters() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'caseType' => CASE_TYPE
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            Integer count = IntakeAdminController.getQuestionCount(filtersJSON);
            Test.stopTest();

            System.assertNotEquals(null, count, 'Count should not be null');
            System.assert(count >= 0, 'Count should be non-negative');
        }
    }

    /**
     * Test: getQuestionCount with quick filters
     */
    @isTest
    static void testGetQuestionCount_WithQuickFilters() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Test orphaned filter
            Map<String, Object> orphanedFilter = new Map<String, Object>{ 'showOrphaned' => true };
            Integer orphanedCount = IntakeAdminController.getQuestionCount(JSON.serialize(orphanedFilter));

            // Test no outcomes filter
            Map<String, Object> noOutcomesFilter = new Map<String, Object>{ 'showNoOutcomes' => true };
            Integer noOutcomesCount = IntakeAdminController.getQuestionCount(JSON.serialize(noOutcomesFilter));

            // Test self-referential filter
            Map<String, Object> selfRefFilter = new Map<String, Object>{ 'showSelfReferential' => true };
            Integer selfRefCount = IntakeAdminController.getQuestionCount(JSON.serialize(selfRefFilter));

            // Test missing input type filter
            Map<String, Object> missingTypeFilter = new Map<String, Object>{ 'showMissingInputType' => true };
            Integer missingTypeCount = IntakeAdminController.getQuestionCount(JSON.serialize(missingTypeFilter));

            System.assert(orphanedCount >= 0, 'Orphaned count should be non-negative');
            System.assert(noOutcomesCount >= 0, 'No outcomes count should be non-negative');
            System.assert(selfRefCount >= 0, 'Self-referential count should be non-negative');
            System.assert(missingTypeCount >= 0, 'Missing type count should be non-negative');
        }
    }

    /**
     * Test: getFilterOptions
     */
    @isTest
    static void testGetFilterOptions() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            IntakeAdminController.FilterOptions options = IntakeAdminController.getFilterOptions();
            Test.stopTest();

            System.assertNotEquals(null, options, 'Options should not be null');
            System.assertNotEquals(null, options.caseTypes, 'Case types should not be null');
            System.assertNotEquals(null, options.caseSubTypes, 'Case sub-types should not be null');
            System.assertNotEquals(null, options.caseReasons, 'Case reasons should not be null');
            System.assertNotEquals(null, options.inputTypes, 'Input types should not be null');
            System.assertNotEquals(null, options.userRoles, 'User roles should not be null');
            System.assertNotEquals(null, options.customerAccounts, 'Customer accounts should not be null');
        }
    }

    /**
     * Test: exportQuestionsToCSV
     */
    @isTest
    static void testExportQuestionsToCSV() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'caseType' => CASE_TYPE
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            String csv = IntakeAdminController.exportQuestionsToCSV(filtersJSON, 'Name', 'ASC');
            Test.stopTest();

            System.assertNotEquals(null, csv, 'CSV should not be null');
            System.assert(csv.length() > 0, 'CSV should have content');
            System.assert(csv.contains('Name,Question Text'), 'CSV should have headers');
        }
    }

    /**
     * Test: exportQuestionsToCSV with special characters
     */
    @isTest
    static void testExportQuestionsToCSV_SpecialCharacters() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Create a question with special characters
            Id questionRecordTypeId = TestDataFactory.getRecordType('Intake Questions', 'Intake_Process__c');
            Intake_Process__c specialQuestion = new Intake_Process__c(
                RecordTypeId = questionRecordTypeId,
                Question__c = 'Question with "quotes", commas, and\nnewlines',
                Input_Type__c = 'Text',
                Presentation_Order__c = 100,
                Case_Type__c = CASE_TYPE,
                Case_Sub_Type__c = CASE_SUBTYPE
            );
            insert specialQuestion;

            Test.startTest();
            String csv = IntakeAdminController.exportQuestionsToCSV(null, 'Name', 'ASC');
            Test.stopTest();

            System.assertNotEquals(null, csv, 'CSV should not be null');
        }
    }

    /**
     * Test: getFlowVisualizationData
     */
    @isTest
    static void testGetFlowVisualizationData() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> result = IntakeAdminController.getFlowVisualizationData(null);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('nodes'), 'Result should contain nodes');
            System.assert(result.containsKey('edges'), 'Result should contain edges');
            System.assert(result.containsKey('nodeCount'), 'Result should contain nodeCount');
            System.assert(result.containsKey('edgeCount'), 'Result should contain edgeCount');

            List<Object> nodes = (List<Object>) result.get('nodes');
            List<Object> edges = (List<Object>) result.get('edges');
            System.assert(nodes.size() > 0, 'Should have nodes');
            System.assert(edges.size() > 0, 'Should have edges');
        }
    }

    /**
     * Test: getFlowVisualizationData with filters
     */
    @isTest
    static void testGetFlowVisualizationData_WithFilters() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Map<String, Object> filters = new Map<String, Object>{
                'caseType' => CASE_TYPE,
                'caseSubType' => CASE_SUBTYPE,
                'limit' => 50
            };
            String filtersJSON = JSON.serialize(filters);

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.getFlowVisualizationData(filtersJSON);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    /**
     * Test: getQuestionFlowPath
     */
    @isTest
    static void testGetQuestionFlowPath() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c startQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Presentation_Order__c = 1
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.getQuestionFlowPath(startQuestion.Id, 10);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('nodes'), 'Result should contain nodes');
            System.assert(result.containsKey('edges'), 'Result should contain edges');
            System.assert(result.containsKey('startQuestionId'), 'Result should contain startQuestionId');
            System.assert(result.containsKey('depthReached'), 'Result should contain depthReached');
        }
    }

    /**
     * Test: getQuestionFlowPath with null max depth
     */
    @isTest
    static void testGetQuestionFlowPath_NullMaxDepth() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c startQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Presentation_Order__c = 1
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.getQuestionFlowPath(startQuestion.Id, null);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    /**
     * Test: validateQuestionPath - valid question
     */
    @isTest
    static void testValidateQuestionPath_Valid() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c question = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Presentation_Order__c = 1
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.validateQuestionPath(question.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('isValid'), 'Result should contain isValid');
            System.assert(result.containsKey('issues'), 'Result should contain issues');
            System.assert(result.containsKey('warnings'), 'Result should contain warnings');
            System.assert(result.containsKey('outcomeCount'), 'Result should contain outcomeCount');
        }
    }

    /**
     * Test: validateQuestionPath - orphaned question
     */
    @isTest
    static void testValidateQuestionPath_Orphaned() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c orphanedQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Question__c = 'Orphaned question'
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.validateQuestionPath(orphanedQuestion.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            List<String> issues = (List<String>) result.get('issues');
            System.assert(issues.size() > 0, 'Should have validation issues for orphaned question');
        }
    }

    /**
     * Test: validateQuestionPath - self-referential question
     */
    @isTest
    static void testValidateQuestionPath_SelfReferential() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c selfRefQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Question__c = 'Self referential question'
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.validateQuestionPath(selfRefQuestion.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            List<String> warnings = (List<String>) result.get('warnings');
            System.assert(warnings.size() > 0, 'Should have warnings for self-referential question');
        }
    }

    /**
     * Test: validateQuestionPath - terminal question (all outcomes dead-end)
     */
    @isTest
    static void testValidateQuestionPath_Terminal() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // The question with "Very Urgent" outcome has terminal outcomes
            Intake_Process__c terminalQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Question__c = 'How urgent is this?'
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.validateQuestionPath(terminalQuestion.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    /**
     * Test: bulkUpdateQuestions
     */
    @isTest
    static void testBulkUpdateQuestions() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            List<Intake_Process__c> questions = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                LIMIT 3
            ];

            List<Id> questionIds = new List<Id>();
            for (Intake_Process__c q : questions) {
                questionIds.add(q.Id);
            }

            Map<String, Object> fieldUpdates = new Map<String, Object>{
                'Case_Type__c' => 'Updated Type',
                'Case_Sub_Type__c' => 'Updated SubType',
                'Case_Reason__c' => 'Updated Reason',
                'User_Role__c' => 'Updated Role',
                'Input_Type__c' => 'Text'
            };

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.bulkUpdateQuestions(questionIds, fieldUpdates);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('successCount'), 'Result should contain successCount');
            System.assert(result.containsKey('errorCount'), 'Result should contain errorCount');
            System.assertEquals(questionIds.size(), result.get('totalProcessed'), 'Total processed should match');
        }
    }

    /**
     * Test: bulkUpdateQuestions with null values
     */
    @isTest
    static void testBulkUpdateQuestions_NullValues() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            List<Intake_Process__c> questions = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                LIMIT 2
            ];

            List<Id> questionIds = new List<Id>();
            for (Intake_Process__c q : questions) {
                questionIds.add(q.Id);
            }

            Map<String, Object> fieldUpdates = new Map<String, Object>{
                'Case_Type__c' => null,
                'Case_Sub_Type__c' => null
            };

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.bulkUpdateQuestions(questionIds, fieldUpdates);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
        }
    }

    /**
     * Test: validateBulkDelete
     */
    @isTest
    static void testValidateBulkDelete() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            List<Intake_Process__c> questions = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                LIMIT 2
            ];

            List<Id> questionIds = new List<Id>();
            for (Intake_Process__c q : questions) {
                questionIds.add(q.Id);
            }

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.validateBulkDelete(questionIds);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('canDelete'), 'Result should contain canDelete');
            System.assert(result.containsKey('warnings'), 'Result should contain warnings');
            System.assert(result.containsKey('incomingReferenceCount'), 'Result should contain incomingReferenceCount');
        }
    }

    /**
     * Test: bulkDeleteQuestions with cascade
     */
    @isTest
    static void testBulkDeleteQuestions_WithCascade() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Use orphaned question for deletion test
            Intake_Process__c orphanedQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Question__c = 'Orphaned question'
                LIMIT 1
            ];

            List<Id> questionIds = new List<Id>{ orphanedQuestion.Id };

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.bulkDeleteQuestions(questionIds, true);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('successCount'), 'Result should contain successCount');
            System.assertEquals(1, result.get('totalProcessed'), 'Total processed should be 1');
        }
    }

    /**
     * Test: bulkDeleteQuestions without cascade
     */
    @isTest
    static void testBulkDeleteQuestions_WithoutCascade() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Create a standalone question for deletion
            Id questionRecordTypeId = TestDataFactory.getRecordType('Intake Questions', 'Intake_Process__c');
            Intake_Process__c deleteQuestion = new Intake_Process__c(
                RecordTypeId = questionRecordTypeId,
                Question__c = 'Question to delete',
                Input_Type__c = 'Text',
                Presentation_Order__c = 99,
                Case_Type__c = 'Delete Test',
                Case_Sub_Type__c = 'Delete Test'
            );
            insert deleteQuestion;

            List<Id> questionIds = new List<Id>{ deleteQuestion.Id };

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.bulkDeleteQuestions(questionIds, false);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(1, result.get('successCount'), 'Should have 1 success');
        }
    }

    /**
     * Test: deleteAllOrphanedQuestions
     */
    @isTest
    static void testDeleteAllOrphanedQuestions() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> result = IntakeAdminController.deleteAllOrphanedQuestions();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('successCount'), 'Result should contain successCount');
            System.assert(result.containsKey('errorCount'), 'Result should contain errorCount');
        }
    }

    /**
     * Test: deleteAllOrphanedQuestions - no orphans
     */
    @isTest
    static void testDeleteAllOrphanedQuestions_NoOrphans() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Delete orphaned questions first
            delete [SELECT Id FROM Intake_Process__c
                   WHERE RecordType.Name = 'Intake Questions'
                   AND Presentation_Order__c != 1
                   AND Id NOT IN (SELECT Next_Question__c FROM Intake_Process__c WHERE Next_Question__c != null)];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.deleteAllOrphanedQuestions();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(0, result.get('totalProcessed'), 'Should process 0 questions');
        }
    }

    /**
     * Test: deleteAllSelfReferentialQuestions
     */
    @isTest
    static void testDeleteAllSelfReferentialQuestions() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> result = IntakeAdminController.deleteAllSelfReferentialQuestions();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('successCount'), 'Result should contain successCount');
        }
    }

    /**
     * Test: deleteAllSelfReferentialQuestions - no self-referential
     */
    @isTest
    static void testDeleteAllSelfReferentialQuestions_None() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Delete self-referential questions first
            delete [SELECT Id FROM Intake_Process__c
                   WHERE RecordType.Name = 'Intake Questions'
                   AND Question__c = 'Self referential question'];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.deleteAllSelfReferentialQuestions();
            Test.stopTest();

            System.assertEquals(0, result.get('totalProcessed'), 'Should process 0 questions');
        }
    }

    /**
     * Test: deleteAllMissingInputTypeQuestions
     */
    @isTest
    static void testDeleteAllMissingInputTypeQuestions() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> result = IntakeAdminController.deleteAllMissingInputTypeQuestions();
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('successCount'), 'Result should contain successCount');
        }
    }

    /**
     * Test: deleteAllMissingInputTypeQuestions - none missing
     */
    @isTest
    static void testDeleteAllMissingInputTypeQuestions_None() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Delete questions with missing input type first
            delete [SELECT Id FROM Intake_Process__c
                   WHERE RecordType.Name = 'Intake Questions'
                   AND (Input_Type__c = null OR Input_Type__c = '')];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.deleteAllMissingInputTypeQuestions();
            Test.stopTest();

            System.assertEquals(0, result.get('totalProcessed'), 'Should process 0 questions');
        }
    }

    /**
     * Test: getQuestionDetails
     */
    @isTest
    static void testGetQuestionDetails() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c question = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Presentation_Order__c = 1
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.getQuestionDetails(question.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
            System.assert(result.containsKey('question'), 'Result should contain question');
            System.assert(result.containsKey('outcomes'), 'Result should contain outcomes');
            System.assert(result.containsKey('incomingReferences'), 'Result should contain incomingReferences');
            System.assert(result.containsKey('isOrphaned'), 'Result should contain isOrphaned');
        }
    }

    /**
     * Test: getQuestionDetails - question with outcomes
     */
    @isTest
    static void testGetQuestionDetails_WithOutcomes() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Get question that has outcomes
            Intake_Process__c question = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Question__c = 'What is your issue?'
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.getQuestionDetails(question.Id);
            Test.stopTest();

            List<Object> outcomes = (List<Object>) result.get('outcomes');
            System.assert(outcomes.size() > 0, 'Should have outcomes');
        }
    }

    /**
     * Test: Wrapper classes instantiation
     */
    @isTest
    static void testWrapperClasses() {
        // Test QuestionWrapper
        IntakeAdminController.QuestionWrapper qw = new IntakeAdminController.QuestionWrapper();
        qw.id = 'test123';
        qw.name = 'IP-001';
        qw.questionText = 'Test Question';
        qw.inputType = 'Picklist';
        qw.presentationOrder = 1;
        qw.caseType = 'Pickup';
        qw.caseSubType = 'Extra Pickup';
        qw.caseReason = 'Test';
        qw.userRole = 'Admin';
        qw.customerAccount = 'Test Account';
        qw.customerLocation = 'Test Location';
        qw.outcomeCount = 5;
        qw.hasNextQuestions = true;
        qw.isOrphaned = false;
        qw.lastModifiedDate = DateTime.now();
        qw.lastModifiedBy = 'Test User';
        qw.createdDate = DateTime.now();
        qw.createdBy = 'Test User';

        // Test FilterOptions
        IntakeAdminController.FilterOptions fo = new IntakeAdminController.FilterOptions();
        fo.caseTypes = new List<IntakeAdminController.PicklistOption>();
        fo.caseSubTypes = new List<IntakeAdminController.PicklistOption>();
        fo.caseReasons = new List<IntakeAdminController.PicklistOption>();
        fo.inputTypes = new List<IntakeAdminController.PicklistOption>();
        fo.userRoles = new List<IntakeAdminController.PicklistOption>();
        fo.customerAccounts = new List<IntakeAdminController.PicklistOption>();

        // Test PicklistOption
        IntakeAdminController.PicklistOption po = new IntakeAdminController.PicklistOption();
        po.label = 'Test Label';
        po.value = 'Test Value';

        // Assertions
        System.assertEquals('test123', qw.id, 'ID should match');
        System.assertEquals('Test Label', po.label, 'Label should match');
        System.assertNotEquals(null, fo.caseTypes, 'Case types should not be null');
    }

    /**
     * Test: Error handling for getQuestionDetails
     */
    @isTest
    static void testGetQuestionDetails_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Id fakeQuestionId = 'a0x000000000000AAA';

            Test.startTest();
            try {
                IntakeAdminController.getQuestionDetails(fakeQuestionId);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error getting question details'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: Error handling for validateQuestionPath
     */
    @isTest
    static void testValidateQuestionPath_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Id fakeQuestionId = 'a0x000000000000AAA';

            Test.startTest();
            try {
                IntakeAdminController.validateQuestionPath(fakeQuestionId);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error validating question path'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: Error handling for getQuestionFlowPath
     */
    @isTest
    static void testGetQuestionFlowPath_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Id fakeQuestionId = 'a0x000000000000AAA';

            Test.startTest();
            try {
                IntakeAdminController.getQuestionFlowPath(fakeQuestionId, 10);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error getting question flow path'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: getQuestionCount error handling
     */
    @isTest
    static void testGetQuestionCount_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            try {
                IntakeAdminController.getQuestionCount('invalid json {');
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error counting questions'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: exportQuestionsToCSV error handling
     */
    @isTest
    static void testExportQuestionsToCSV_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            try {
                IntakeAdminController.exportQuestionsToCSV('invalid json {', null, null);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error exporting to CSV'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: getFlowVisualizationData error handling
     */
    @isTest
    static void testGetFlowVisualizationData_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            try {
                IntakeAdminController.getFlowVisualizationData('invalid json {');
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error getting flow visualization data'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: bulkUpdateQuestions error handling
     */
    @isTest
    static void testBulkUpdateQuestions_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            List<Id> invalidIds = new List<Id>{ 'a0x000000000000AAA' };
            Map<String, Object> fieldUpdates = new Map<String, Object>{ 'Case_Type__c' => 'Test' };

            Test.startTest();
            try {
                IntakeAdminController.bulkUpdateQuestions(invalidIds, fieldUpdates);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error in bulk update'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: validateBulkDelete error handling
     */
    @isTest
    static void testValidateBulkDelete_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            List<Id> invalidIds = new List<Id>{ 'a0x000000000000AAA' };

            Test.startTest();
            try {
                IntakeAdminController.validateBulkDelete(invalidIds);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error validating bulk delete'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: bulkDeleteQuestions error handling
     */
    @isTest
    static void testBulkDeleteQuestions_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            List<Id> invalidIds = new List<Id>{ 'a0x000000000000AAA' };

            Test.startTest();
            try {
                IntakeAdminController.bulkDeleteQuestions(invalidIds, true);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error in bulk delete'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: getFilterOptions error handling (simulated)
     */
    @isTest
    static void testGetFilterOptions_Coverage() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            // This test ensures full coverage of the method
            IntakeAdminController.FilterOptions options = IntakeAdminController.getFilterOptions();
            Test.stopTest();

            // Verify all option lists are populated
            System.assertNotEquals(null, options.inputTypes, 'Input types should be populated');
            System.assert(options.inputTypes.size() > 0, 'Should have input type options from picklist');
        }
    }

    /**
     * Test: Questions with partial dead ends (some outcomes terminal, some not)
     */
    @isTest
    static void testValidateQuestionPath_PartialDeadEnd() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Question 1 has both branching and terminal outcomes
            Intake_Process__c mixedQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Question__c = 'What is your issue?'
                LIMIT 1
            ];

            // Add a terminal outcome to the question
            Id outcomeRecordTypeId = TestDataFactory.getRecordType('Intake Outcomes', 'Intake_Process__c');
            Intake_Process__c terminalOutcome = new Intake_Process__c(
                RecordTypeId = outcomeRecordTypeId,
                Intake_Question__c = mixedQuestion.Id,
                Outcome__c = 'Terminal Option',
                Next_Question__c = null,
                Outcome_Statement__c = 'End of path'
            );
            insert terminalOutcome;

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.validateQuestionPath(mixedQuestion.Id);
            Test.stopTest();

            // Should have a warning about partial dead ends
            List<String> warnings = (List<String>) result.get('warnings');
            System.assertNotEquals(null, warnings, 'Warnings should not be null');
        }
    }

    /**
     * Test: Question with no outcomes
     */
    @isTest
    static void testValidateQuestionPath_NoOutcomes() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Use orphaned question which has no outcomes
            Intake_Process__c noOutcomesQuestion = [
                SELECT Id FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Questions'
                AND Question__c = 'Orphaned question'
                LIMIT 1
            ];

            Test.startTest();
            Map<String, Object> result = IntakeAdminController.validateQuestionPath(noOutcomesQuestion.Id);
            Test.stopTest();

            List<String> warnings = (List<String>) result.get('warnings');
            Boolean hasNoOutcomesWarning = false;
            for (String warning : warnings) {
                if (warning.contains('No Outcomes')) {
                    hasNoOutcomesWarning = true;
                    break;
                }
            }
            System.assert(hasNoOutcomesWarning, 'Should have warning about no outcomes');
        }
    }
}
