/**
 * @description Test class for IntakeProcessController
 * Tests batch fetching, hierarchical question matching, and case updates
 */
@isTest(seeAllData = false)
public class IntakeProcessControllerTest {

    private static final String SYS_ADMIN = 'System Administrator';
    private static final String TEST_CLIENT = 'Test Client';
    private static final String TEST_LOCATION = 'Test Location';
    private static final String TEST_CONTACT = 'Test Contact';
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

            // Create Contact
            List<Contact> contacts = TestDataFactory.createContact(TEST_CONTACT, 'Test', clients[0], testUser);
            insert contacts;

            // Create Product
            List<Product2> products = TestDataFactory.createProduct('Test Product');
            products[0].Family = 'Commercial';
            insert products;

            // Create Asset
            List<Asset> assets = TestDataFactory.createAsset('Test Asset', clients[0], contacts[0],
                                                            products[0], testUser, locations[0]);
            insert assets;

            // Create Case
            List<Case> cases = TestDataFactory.createCase('Test Case', clients[0], contacts[0],
                                                         testUser, locations[0], assets[0]);
            cases[0].Case_Type__c = CASE_TYPE;
            cases[0].Case_Sub_Type__c = CASE_SUBTYPE;
            cases[0].Case_Reason__c = CASE_REASON;
            cases[0].Master_Intake_Complete__c = false;
            insert cases[0];

            // Create Intake Process Records
            createIntakeProcessData(clients[0].Id, locations[0].Id);
        }
    }

    /**
     * Helper method to create Intake Process test data
     */
    private static void createIntakeProcessData(Id clientId, Id locationId) {
        Id questionRecordTypeId = TestDataFactory.getRecordType('Intake Questions', 'Intake_Process__c');
        Id outcomeRecordTypeId = TestDataFactory.getRecordType('Intake Outcomes', 'Intake_Process__c');

        // Question 1 (General)
        Intake_Process__c question1 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'What is your issue?',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 1,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = CASE_REASON
        );
        insert question1;

        // Question 2 (Account-specific)
        Intake_Process__c question2 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'How urgent is this?',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 1,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = CASE_REASON,
            Customer_Account__c = clientId
        );
        insert question2;

        // Question 3 (Next question in sequence)
        Intake_Process__c question3 = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'Do you need immediate service?',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 2,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = CASE_REASON
        );
        insert question3;

        // Outcome 1 for Question 2 (branches to Question 3)
        Intake_Process__c outcome1 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question2.Id,
            Outcome__c = 'Very Urgent',
            Next_Question__c = question3.Id,
            Outcome_Statement__c = 'We will prioritize your request'
        );
        insert outcome1;

        // Outcome 2 for Question 2 (branches to Question 3)
        Intake_Process__c outcome2 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question2.Id,
            Outcome__c = 'Not Urgent',
            Next_Question__c = question3.Id,
            Outcome_Statement__c = 'We will process your request normally'
        );
        insert outcome2;

        // Outcome 3 for Question 3 (terminal - updates case)
        Intake_Process__c outcome3 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'Yes',
            Next_Question__c = null,
            Outcome_Statement__c = 'Your case has been submitted for immediate service',
            Update_Case_Status__c = true,
            Case_Status__c = 'Open',
            Create_Task__c = true,
            Task_Type__c = 'Follow Up',
            Task_Process__c = 'Master Intake'
        );
        insert outcome3;

        // Outcome 4 for Question 3 (terminal - no updates)
        Intake_Process__c outcome4 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'No',
            Next_Question__c = null,
            Outcome_Statement__c = 'Your case has been submitted for regular processing'
        );
        insert outcome4;
    }

    /**
     * Test: initializeIntake with hierarchical matching (Account level)
     */
    @isTest
    static void testInitializeIntake_AccountLevel() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(false, result.cpqEligible, 'Case should not be CPQ eligible');
            System.assertNotEquals(null, result.firstQuestion, 'First question should be returned');
            System.assertEquals('How urgent is this?', result.firstQuestion.questionText,
                              'Should return Account-level question due to hierarchy');
            System.assertNotEquals(null, result.caseContext, 'Case context should be populated');
            System.assertEquals(CASE_TYPE, result.caseContext.caseType, 'Case type should match');

            // Verify batch fetching occurred
            System.assertNotEquals(null, result.nextQuestionsCache, 'Cache should not be null');
            System.assert(result.nextQuestionsCache.size() > 0, 'Cache should contain next questions');
        }
    }

    /**
     * Test: initializeIntake with no questions configured
     */
    @isTest
    static void testInitializeIntake_NoQuestions() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Create a case with unconfigured type
            List<Account> clients = [SELECT Id FROM Account WHERE RecordType.Name = 'Client' LIMIT 1];
            List<Account> locations = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' LIMIT 1];
            List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
            List<Asset> assets = [SELECT Id FROM Asset LIMIT 1];

            Case testCase = new Case(
                Status = 'New',
                ContactId = contacts[0].Id,
                AccountId = locations[0].Id,
                Client__c = clients[0].Id,
                Location__c = locations[0].Id,
                AssetId = assets[0].Id,
                Case_Type__c = 'Unconfigured Type',
                Case_Sub_Type__c = 'Unconfigured SubType',
                Master_Intake_Complete__c = false
            );
            insert testCase;

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(null, result.firstQuestion, 'No question should be returned');
        }
    }

    /**
     * Test: getNextQuestionBatch
     */
    @isTest
    static void testGetNextQuestionBatch() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'Very Urgent'
                LIMIT 1
            ];

            Test.startTest();
            Map<String, IntakeProcessController.QuestionWrapper> cache =
                IntakeProcessController.getNextQuestionBatch(outcome.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, cache, 'Cache should not be null');
            System.assert(cache.size() > 0, 'Cache should contain questions');

            // Verify the question was fetched
            Boolean foundQuestion = false;
            for (IntakeProcessController.QuestionWrapper q : cache.values()) {
                if (q.questionText.contains('Do you need immediate service')) {
                    foundQuestion = true;
                }
            }
            System.assert(foundQuestion, 'Expected question should be in cache');
        }
    }

    /**
     * Test: getNextQuestionBatch with terminal outcome
     */
    @isTest
    static void testGetNextQuestionBatch_TerminalOutcome() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'No'
                AND Next_Question__c = null
                LIMIT 1
            ];

            Test.startTest();
            Map<String, IntakeProcessController.QuestionWrapper> cache =
                IntakeProcessController.getNextQuestionBatch(outcome.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, cache, 'Cache should not be null');
            System.assertEquals(0, cache.size(), 'Cache should be empty for terminal outcome');
        }
    }

    /**
     * Test: completeIntake with task creation
     */
    @isTest
    static void testCompleteIntake_WithTaskCreation() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id, Master_Intake_Complete__c FROM Case LIMIT 1];

            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'Yes'
                AND Create_Task__c = true
                LIMIT 1
            ];

            // Build answers JSON
            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'How urgent is this?', 'answer' => 'Very Urgent'},
                new Map<String, String>{'question' => 'Do you need immediate service?', 'answer' => 'Yes'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(testCase.Id, answersJSON, outcome.Id);
            Test.stopTest();

            // Assertions
            System.assert(result.success, 'Completion should succeed');
            System.assertNotEquals(null, result.commentId, 'Comment should be created');
            System.assertNotEquals(null, result.taskId, 'Task should be created');
            System.assertEquals('Open', result.caseStatus, 'Case status should be updated');

            // Verify case was marked complete
            Case updatedCase = [SELECT Master_Intake_Complete__c FROM Case WHERE Id = :testCase.Id];
            System.assertEquals(true, updatedCase.Master_Intake_Complete__c,
                              'Case should be marked as intake complete');

            // Verify comment was created
            List<Comment__c> comments = [SELECT Id, Comment__c FROM Comment__c WHERE Case__c = :testCase.Id];
            System.assertEquals(1, comments.size(), 'One comment should be created');
            System.assert(comments[0].Comment__c.contains('Master Intake Responses'),
                        'Comment should contain intake responses');

            // Verify task was created
            List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :testCase.Id];
            System.assertEquals(1, tasks.size(), 'One task should be created');
            System.assertEquals('Follow Up', tasks[0].Subject, 'Task subject should match');
        }
    }

    /**
     * Test: completeIntake without task creation
     */
    @isTest
    static void testCompleteIntake_WithoutTaskCreation() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];

            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'No'
                AND Create_Task__c = false
                LIMIT 1
            ];

            // Build answers JSON
            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'Do you need immediate service?', 'answer' => 'No'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(testCase.Id, answersJSON, outcome.Id);
            Test.stopTest();

            // Assertions
            System.assert(result.success, 'Completion should succeed');
            System.assertNotEquals(null, result.commentId, 'Comment should be created');
            System.assertEquals(null, result.taskId, 'No task should be created');
        }
    }

    /**
     * Test: Hierarchical question matching - Location level
     */
    @isTest
    static void testHierarchicalMatching_LocationLevel() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Delete Account-level question to test Location fallback
            delete [SELECT Id FROM Intake_Process__c
                   WHERE Customer_Account__c != null
                   AND RecordType.Name = 'Intake Questions'];

            // Create Location-level question
            List<Account> locations = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' LIMIT 1];
            Id questionRecordTypeId = TestDataFactory.getRecordType('Intake Questions', 'Intake_Process__c');

            Intake_Process__c locationQuestion = new Intake_Process__c(
                RecordTypeId = questionRecordTypeId,
                Question__c = 'Location-specific question',
                Input_Type__c = 'Text',
                Presentation_Order__c = 1,
                Case_Type__c = CASE_TYPE,
                Case_Sub_Type__c = CASE_SUBTYPE,
                Case_Reason__c = CASE_REASON,
                Customer_Location__c = locations[0].Id
            );
            insert locationQuestion;

            Case testCase = [SELECT Id FROM Case LIMIT 1];

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result.firstQuestion, 'Question should be found');
            System.assertEquals('Location-specific question', result.firstQuestion.questionText,
                              'Should return Location-level question');
        }
    }

    /**
     * Test: Hierarchical question matching - General level
     */
    @isTest
    static void testHierarchicalMatching_GeneralLevel() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Delete Account and Location questions to test General fallback
            delete [SELECT Id FROM Intake_Process__c
                   WHERE (Customer_Account__c != null OR Customer_Location__c != null)
                   AND RecordType.Name = 'Intake Questions'];

            Case testCase = [SELECT Id FROM Case LIMIT 1];

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result.firstQuestion, 'Question should be found');
            System.assertEquals('What is your issue?', result.firstQuestion.questionText,
                              'Should return General-level question');
        }
    }

    /**
     * Test: Wrapper classes serialization
     */
    @isTest
    static void testWrappersSerialization() {
        // Test QuestionWrapper
        IntakeProcessController.QuestionWrapper qw = new IntakeProcessController.QuestionWrapper();
        qw.questionId = 'test123';
        qw.questionText = 'Test Question';
        qw.inputType = 'Picklist';
        qw.presentationOrder = 1;
        qw.outcomes = new List<IntakeProcessController.OutcomeWrapper>();

        // Test OutcomeWrapper
        IntakeProcessController.OutcomeWrapper ow = new IntakeProcessController.OutcomeWrapper();
        ow.outcomeId = 'outcome123';
        ow.outcomeText = 'Test Outcome';
        ow.isTerminal = false;
        ow.hasNextQuestion = true;
        ow.nextQuestionId = 'next123';

        // Test ActionWrapper
        IntakeProcessController.ActionWrapper aw = new IntakeProcessController.ActionWrapper();
        aw.updateCaseStatus = true;
        aw.caseStatus = 'Open';
        aw.createTask = true;
        aw.taskType = 'Follow Up';

        ow.actions = aw;
        qw.outcomes.add(ow);

        Test.startTest();
        String serialized = JSON.serialize(qw);
        IntakeProcessController.QuestionWrapper deserialized =
            (IntakeProcessController.QuestionWrapper) JSON.deserialize(
                serialized, IntakeProcessController.QuestionWrapper.class
            );
        Test.stopTest();

        // Assertions
        System.assertEquals(qw.questionId, deserialized.questionId, 'Question ID should match');
        System.assertEquals(qw.questionText, deserialized.questionText, 'Question text should match');
        System.assertEquals(1, deserialized.outcomes.size(), 'Should have one outcome');
        System.assertEquals('Test Outcome', deserialized.outcomes[0].outcomeText, 'Outcome text should match');
    }

    /**
     * Test: Error handling for invalid case ID
     */
    @isTest
    static void testErrorHandling_InvalidCaseId() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Id fakeCaseId = '500000000000000AAA';

            Test.startTest();
            try {
                IntakeProcessController.initializeIntake(fakeCaseId);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error initializing intake'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }
}
