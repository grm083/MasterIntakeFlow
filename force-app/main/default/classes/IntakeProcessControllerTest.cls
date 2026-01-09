/**
 * @description Test class for IntakeProcessController
 * Tests batch fetching, hierarchical question matching, and case updates
 * Target: 90%+ code coverage
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

            // Create Case with null reason for testing
            Case caseNullReason = new Case(
                Status = 'New',
                Priority = 'Medium',
                Origin = 'Phone',
                ContactId = contacts[0].Id,
                AccountId = locations[0].Id,
                Client__c = clients[0].Id,
                Location__c = locations[0].Id,
                AssetId = assets[0].Id,
                Case_Type__c = CASE_TYPE,
                Case_Sub_Type__c = CASE_SUBTYPE,
                Case_Reason__c = null,
                Master_Intake_Complete__c = false,
                RecordTypeId = TestDataFactory.getRecordType('Pickup Case', 'Case')
            );
            insert caseNullReason;

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

        // Question 1 (General) - with reason
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

        // Question 1b (General) - without reason (null case reason)
        Intake_Process__c question1b = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'What is your issue without reason?',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 1,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = null
        );
        insert question1b;

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

        // Question 2b (Account-specific) - null reason
        Intake_Process__c question2b = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'How urgent is this without reason?',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 1,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = null,
            Customer_Account__c = clientId
        );
        insert question2b;

        // Question 2c (Location-specific)
        Intake_Process__c question2c = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'Location specific question',
            Input_Type__c = 'Picklist',
            Presentation_Order__c = 1,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = CASE_REASON,
            Customer_Location__c = locationId
        );
        insert question2c;

        // Question 2d (Location-specific) - null reason
        Intake_Process__c question2d = new Intake_Process__c(
            RecordTypeId = questionRecordTypeId,
            Question__c = 'Location specific question null reason',
            Input_Type__c = 'Text',
            Presentation_Order__c = 1,
            Case_Type__c = CASE_TYPE,
            Case_Sub_Type__c = CASE_SUBTYPE,
            Case_Reason__c = null,
            Customer_Location__c = locationId
        );
        insert question2d;

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
            Outcome_Statement__c = 'We will prioritize your request',
            Any_Value__c = false
        );
        insert outcome1;

        // Outcome 2 for Question 2 (branches to Question 3)
        Intake_Process__c outcome2 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question2.Id,
            Outcome__c = 'Not Urgent',
            Next_Question__c = question3.Id,
            Outcome_Statement__c = 'We will process your request normally',
            Any_Value__c = true
        );
        insert outcome2;

        // Outcome 3 for Question 3 (terminal - updates case with task)
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
            Task_Process__c = 'Master Intake',
            Update_Case_Record_Type__c = false,
            Update_Case_Type__c = false,
            Update_Case_Sub_Type__c = false,
            Update_Case_Reason__c = false,
            Team_Name__c = 'Test Team',
            Queue_Assigned__c = 'Test Queue',
            Assign_to_Current_User__c = true
        );
        insert outcome3;

        // Outcome 4 for Question 3 (terminal - no updates)
        Intake_Process__c outcome4 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'No',
            Next_Question__c = null,
            Outcome_Statement__c = 'Your case has been submitted for regular processing',
            Create_Task__c = false,
            Update_Case_Status__c = false
        );
        insert outcome4;

        // Outcome 5 for Question 3 (terminal - updates case type/subtype/reason)
        Intake_Process__c outcome5 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'Maybe',
            Next_Question__c = null,
            Outcome_Statement__c = 'Your case type will be updated',
            Update_Case_Type__c = true,
            Case_Type__c = 'Service',
            Update_Case_Sub_Type__c = true,
            Case_Sub_Type__c = 'General Service',
            Update_Case_Reason__c = true,
            Case_Reason__c = 'Equipment Issue',
            Update_Case_Status__c = true,
            Case_Status__c = 'Pending',
            Create_Task__c = false
        );
        insert outcome5;

        // Outcome 6 for Question 3 - SNP case
        Intake_Process__c outcome6 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'SNP Case',
            Next_Question__c = null,
            Outcome_Statement__c = 'Service Not Performed case',
            Update_Case_Status__c = true,
            Case_Status__c = 'Open',
            Update_Case_Sub_Type__c = true,
            Case_Sub_Type__c = 'Service Not Performed',
            Create_Task__c = false
        );
        insert outcome6;

        // Outcome 7 for Question 3 - Bale case
        Intake_Process__c outcome7 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'Bale Case',
            Next_Question__c = null,
            Outcome_Statement__c = 'Bale case pending approval',
            Update_Case_Status__c = true,
            Case_Status__c = 'Pending',
            Update_Case_Sub_Type__c = true,
            Case_Sub_Type__c = 'Bale(s)',
            Create_Task__c = false
        );
        insert outcome7;

        // Outcome with record type update
        Intake_Process__c outcome8 = new Intake_Process__c(
            RecordTypeId = outcomeRecordTypeId,
            Intake_Question__c = question3.Id,
            Outcome__c = 'Update Record Type',
            Next_Question__c = null,
            Outcome_Statement__c = 'Record type updated',
            Update_Case_Record_Type__c = true,
            Case_Record_Type__c = 'Pickup Case',
            Create_Task__c = false
        );
        insert outcome8;
    }

    /**
     * Test: initializeIntake with hierarchical matching (Account level)
     */
    @isTest
    static void testInitializeIntake_AccountLevel() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

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
     * Test: initializeIntake with null case reason (fallback path)
     */
    @isTest
    static void testInitializeIntake_NullCaseReason() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = null LIMIT 1];

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result, 'Result should not be null');
            // Should find the null-reason questions
            if (result.firstQuestion != null) {
                System.assertNotEquals(null, result.firstQuestion.questionText, 'Question text should be present');
            }
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
     * Test: getNextQuestionBatch error handling
     */
    @isTest
    static void testGetNextQuestionBatch_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Id fakeOutcomeId = 'a0x000000000000AAA'; // Invalid ID

            Test.startTest();
            try {
                IntakeProcessController.getNextQuestionBatch(fakeOutcomeId);
                System.assert(false, 'Should have thrown exception');
            } catch (AuraHandledException e) {
                System.assert(e.getMessage().contains('Error fetching next question'),
                            'Should throw AuraHandledException');
            }
            Test.stopTest();
        }
    }

    /**
     * Test: completeIntake with task creation
     */
    @isTest
    static void testCompleteIntake_WithTaskCreation() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id, Master_Intake_Complete__c FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

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
            System.assert(comments[0].Comment__c.contains('Master Intake Complete'),
                        'Comment should contain intake header');

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
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

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
     * Test: completeIntake with case type/subtype/reason updates
     */
    @isTest
    static void testCompleteIntake_WithCaseTypeUpdates() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'Maybe'
                AND Update_Case_Type__c = true
                LIMIT 1
            ];

            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'Test', 'answer' => 'Maybe'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(testCase.Id, answersJSON, outcome.Id);
            Test.stopTest();

            System.assert(result.success, 'Completion should succeed');

            // Verify case type was updated
            Case updatedCase = [SELECT Case_Type__c, Case_Sub_Type__c, Case_Reason__c
                               FROM Case WHERE Id = :testCase.Id];
            System.assertEquals('Service', updatedCase.Case_Type__c, 'Case type should be updated');
            System.assertEquals('General Service', updatedCase.Case_Sub_Type__c, 'Case subtype should be updated');
        }
    }

    /**
     * Test: completeIntake with Service Not Performed special logic
     */
    @isTest
    static void testCompleteIntake_ServiceNotPerformed() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'SNP Case'
                LIMIT 1
            ];

            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'Test', 'answer' => 'SNP Case'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(testCase.Id, answersJSON, outcome.Id);
            Test.stopTest();

            System.assert(result.success, 'Completion should succeed');
        }
    }

    /**
     * Test: completeIntake with Bale special logic
     */
    @isTest
    static void testCompleteIntake_BaleCase() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'Bale Case'
                LIMIT 1
            ];

            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'Test', 'answer' => 'Bale Case'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(testCase.Id, answersJSON, outcome.Id);
            Test.stopTest();

            System.assert(result.success, 'Completion should succeed');
        }
    }

    /**
     * Test: completeIntake with record type update
     */
    @isTest
    static void testCompleteIntake_RecordTypeUpdate() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'Update Record Type'
                LIMIT 1
            ];

            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'Test', 'answer' => 'Update Record Type'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(testCase.Id, answersJSON, outcome.Id);
            Test.stopTest();

            System.assert(result.success, 'Completion should succeed');
        }
    }

    /**
     * Test: completeIntake with null outcome (no outcome statement)
     */
    @isTest
    static void testCompleteIntake_NullOutcome() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

            // Get an outcome first, then we'll test with it
            Intake_Process__c outcome = [
                SELECT Id
                FROM Intake_Process__c
                WHERE RecordType.Name = 'Intake Outcomes'
                AND Outcome__c = 'No'
                LIMIT 1
            ];

            // Clear the outcome statement
            outcome.Outcome_Statement__c = null;
            update outcome;

            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'Test', 'answer' => 'No'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(testCase.Id, answersJSON, outcome.Id);
            Test.stopTest();

            System.assert(result.success, 'Completion should succeed');
        }
    }

    /**
     * Test: completeIntake error handling
     */
    @isTest
    static void testCompleteIntake_ErrorHandling() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            Id fakeCaseId = '500000000000000AAA';
            Id fakeOutcomeId = 'a0x000000000000AAA';

            List<Map<String, String>> answers = new List<Map<String, String>>{
                new Map<String, String>{'question' => 'Test', 'answer' => 'Yes'}
            };
            String answersJSON = JSON.serialize(answers);

            Test.startTest();
            IntakeProcessController.CompletionWrapper result =
                IntakeProcessController.completeIntake(fakeCaseId, answersJSON, fakeOutcomeId);
            Test.stopTest();

            // Should return error in wrapper
            System.assertEquals(false, result.success, 'Completion should fail');
            System.assertNotEquals(null, result.errorMessage, 'Error message should be populated');
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

            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            // Assertions
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertNotEquals(null, result.firstQuestion, 'Question should be found');
            System.assertEquals('Location specific question', result.firstQuestion.questionText,
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

            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

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
     * Test: Location level with null case reason
     */
    @isTest
    static void testHierarchicalMatching_LocationNullReason() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Delete Account-level questions
            delete [SELECT Id FROM Intake_Process__c
                   WHERE Customer_Account__c != null
                   AND RecordType.Name = 'Intake Questions'];

            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = null LIMIT 1];

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            System.assertNotEquals(null, result, 'Result should not be null');
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
        ow.outcomeStatement = 'Test statement';
        ow.anyValue = true;

        // Test ActionWrapper
        IntakeProcessController.ActionWrapper aw = new IntakeProcessController.ActionWrapper();
        aw.updateCaseStatus = true;
        aw.caseStatus = 'Open';
        aw.createTask = true;
        aw.taskType = 'Follow Up';
        aw.taskProcess = 'Master Intake';
        aw.updateCaseRecordType = true;
        aw.caseRecordType = 'Pickup Case';
        aw.updateCaseType = true;
        aw.caseType = 'Pickup';
        aw.updateCaseSubType = true;
        aw.caseSubType = 'Extra Pickup';
        aw.updateCaseReason = true;
        aw.caseReason = 'Test Reason';
        aw.teamName = 'Test Team';
        aw.queueAssigned = 'Test Queue';
        aw.assignToCurrentUser = true;

        ow.actions = aw;
        qw.outcomes.add(ow);

        // Test CaseContextWrapper
        IntakeProcessController.CaseContextWrapper ccw = new IntakeProcessController.CaseContextWrapper();
        ccw.caseType = 'Pickup';
        ccw.caseSubType = 'Extra Pickup';
        ccw.caseReason = 'Test Reason';
        ccw.caseNumber = '00001234';
        ccw.clientId = 'acc123';
        ccw.locationId = 'loc123';
        ccw.clientName = 'Test Client';
        ccw.locationName = 'Test Location';
        ccw.assetName = 'Test Asset';
        ccw.contactName = 'Test Contact';
        ccw.serviceDate = Date.today();

        // Test InitialDataWrapper
        IntakeProcessController.InitialDataWrapper idw = new IntakeProcessController.InitialDataWrapper();
        idw.cpqEligible = false;
        idw.firstQuestion = qw;
        idw.nextQuestionsCache = new Map<String, IntakeProcessController.QuestionWrapper>();
        idw.caseContext = ccw;

        // Test CompletionWrapper
        IntakeProcessController.CompletionWrapper cw = new IntakeProcessController.CompletionWrapper();
        cw.success = true;
        cw.caseStatus = 'Open';
        cw.commentId = 'comment123';
        cw.taskId = 'task123';
        cw.errorMessage = null;

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

    /**
     * Test: Case context with null relationships
     */
    @isTest
    static void testCaseContextNullRelationships() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Create case without some relationships
            Case testCase = new Case(
                Status = 'New',
                Case_Type__c = 'Unconfigured',
                Case_Sub_Type__c = 'Unconfigured',
                Master_Intake_Complete__c = false
            );
            insert testCase;

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            // Context should still be populated with nulls
            System.assertNotEquals(null, result.caseContext, 'Case context should be populated');
        }
    }

    /**
     * Test: Question with empty outcomes list
     */
    @isTest
    static void testQuestionWithNoOutcomes() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND isActive = true LIMIT 1];

        System.runAs(testUser) {
            // Delete all outcomes for testing
            delete [SELECT Id FROM Intake_Process__c WHERE RecordType.Name = 'Intake Outcomes'];

            Case testCase = [SELECT Id FROM Case WHERE Case_Reason__c = :CASE_REASON LIMIT 1];

            Test.startTest();
            IntakeProcessController.InitialDataWrapper result =
                IntakeProcessController.initializeIntake(testCase.Id);
            Test.stopTest();

            System.assertNotEquals(null, result.firstQuestion, 'Question should be found');
            System.assertEquals(0, result.firstQuestion.outcomes.size(), 'Outcomes list should be empty');
            System.assertEquals(0, result.nextQuestionsCache.size(), 'Cache should be empty');
        }
    }
}
