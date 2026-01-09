/**
 * Test class for AzureOpenAIService
 *
 * Provides comprehensive test coverage including:
 * - Successful classification
 * - Error handling and retry logic
 * - Mock HTTP callouts
 * - Edge cases and validation
 */
@isTest
private class AzureOpenAIServiceTest {

    /**
     * Test successful case classification
     */
    @isTest
    static void testSuccessfulClassification() {
        // Setup test data
        Case testCase = createTestCase();

        List<AzureOpenAIService.PreIntakeAnswer> answers = new List<AzureOpenAIService.PreIntakeAnswer>{
            new AzureOpenAIService.PreIntakeAnswer('What is the issue?', 'Compactor is broken'),
            new AzureOpenAIService.PreIntakeAnswer('Is this urgent?', 'Yes, needs immediate repair')
        };

        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new SuccessfulAzureAPIMock());

        Test.startTest();
        AzureOpenAIService.ClassificationResult result =
            AzureOpenAIService.classifyCase(answers, testCase);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Equipment Maintenance', result.caseType);
        System.assertEquals('Compactor', result.caseSubType);
        System.assertEquals('Repair Request', result.caseReason);
        System.assert(result.confidence > 0.8, 'Confidence should be high');
        System.assert(String.isNotBlank(result.reasoning), 'Should have reasoning');
    }

    /**
     * Test retry logic on transient failures
     */
    @isTest
    static void testRetryLogic() {
        Case testCase = createTestCase();

        List<AzureOpenAIService.PreIntakeAnswer> answers = new List<AzureOpenAIService.PreIntakeAnswer>{
            new AzureOpenAIService.PreIntakeAnswer('What is the issue?', 'Need service')
        };

        // Set mock that fails once then succeeds
        Test.setMock(HttpCalloutMock.class, new RetryableFailureMock());

        Test.startTest();
        AzureOpenAIService.ClassificationResult result =
            AzureOpenAIService.classifyCase(answers, testCase);
        Test.stopTest();

        // Should succeed after retry
        System.assertNotEquals(null, result);
        System.assertEquals('Service Request', result.caseType);
    }

    /**
     * Test non-retryable error handling
     */
    @isTest
    static void testNonRetryableError() {
        Case testCase = createTestCase();

        List<AzureOpenAIService.PreIntakeAnswer> answers = new List<AzureOpenAIService.PreIntakeAnswer>{
            new AzureOpenAIService.PreIntakeAnswer('Question', 'Answer')
        };

        // Set mock that returns 400 Bad Request (non-retryable)
        Test.setMock(HttpCalloutMock.class, new BadRequestMock());

        Test.startTest();
        try {
            AzureOpenAIService.classifyCase(answers, testCase);
            System.assert(false, 'Should have thrown exception');
        } catch (AzureOpenAIService.AzureOpenAIException e) {
            System.assert(e.getMessage().contains('400'), 'Should mention 400 error');
        }
        Test.stopTest();
    }

    /**
     * Test validation of empty answers
     */
    @isTest
    static void testEmptyAnswersValidation() {
        Case testCase = createTestCase();
        List<AzureOpenAIService.PreIntakeAnswer> emptyAnswers = new List<AzureOpenAIService.PreIntakeAnswer>();

        Test.startTest();
        try {
            AzureOpenAIService.classifyCase(emptyAnswers, testCase);
            System.assert(false, 'Should have thrown exception');
        } catch (AzureOpenAIService.AzureOpenAIException e) {
            System.assert(e.getMessage().contains('required'), 'Should mention required field');
        }
        Test.stopTest();
    }

    /**
     * Test null case validation
     */
    @isTest
    static void testNullCaseValidation() {
        List<AzureOpenAIService.PreIntakeAnswer> answers = new List<AzureOpenAIService.PreIntakeAnswer>{
            new AzureOpenAIService.PreIntakeAnswer('Question', 'Answer')
        };

        Test.startTest();
        try {
            AzureOpenAIService.classifyCase(answers, null);
            System.assert(false, 'Should have thrown exception');
        } catch (AzureOpenAIService.AzureOpenAIException e) {
            System.assert(e.getMessage().contains('required'), 'Should mention required field');
        }
        Test.stopTest();
    }

    /**
     * Test malformed JSON response handling
     */
    @isTest
    static void testMalformedJSONResponse() {
        Case testCase = createTestCase();

        List<AzureOpenAIService.PreIntakeAnswer> answers = new List<AzureOpenAIService.PreIntakeAnswer>{
            new AzureOpenAIService.PreIntakeAnswer('Question', 'Answer')
        };

        Test.setMock(HttpCalloutMock.class, new MalformedJSONMock());

        Test.startTest();
        try {
            AzureOpenAIService.classifyCase(answers, testCase);
            System.assert(false, 'Should have thrown exception');
        } catch (AzureOpenAIService.AzureOpenAIException e) {
            System.assert(
                e.getMessage().contains('parse'),
                'Should mention parsing error'
            );
        }
        Test.stopTest();
    }

    /**
     * Test wrapper class constructors
     */
    @isTest
    static void testWrapperClasses() {
        // Test PreIntakeAnswer
        AzureOpenAIService.PreIntakeAnswer answer =
            new AzureOpenAIService.PreIntakeAnswer('Question?', 'Answer!');

        System.assertEquals('Question?', answer.questionText);
        System.assertEquals('Answer!', answer.answerText);

        // Test ClassificationResult
        AzureOpenAIService.ClassificationResult result =
            new AzureOpenAIService.ClassificationResult();

        System.assertEquals(true, result.success);
    }

    // ========== HELPER METHODS ==========

    /**
     * Create test case with related data
     */
    private static Case createTestCase() {
        // Create test account for Client
        Account client = new Account(
            Name = 'Test Client'
        );
        insert client;

        // Create test account for Location
        Account location = new Account(
            Name = 'Test Location'
        );
        insert location;

        // Create test case
        Case testCase = new Case(
            Subject = 'Test Case',
            Client__c = client.Id,
            Location__c = location.Id,
            Service_Date__c = Date.today(),
            Status = 'New'
        );
        insert testCase;

        // Reload with relationships
        return [
            SELECT Id, Client__r.Name, Location__r.Name, Service_Date__c
            FROM Case
            WHERE Id = :testCase.Id
        ];
    }

    // ========== MOCK CLASSES ==========

    /**
     * Mock successful Azure OpenAI API response
     */
    private class SuccessfulAzureAPIMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');

            Map<String, Object> responseBody = new Map<String, Object>{
                'choices' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'message' => new Map<String, Object>{
                            'content' => JSON.serialize(new Map<String, Object>{
                                'caseType' => 'Equipment Maintenance',
                                'caseSubType' => 'Compactor',
                                'caseReason' => 'Repair Request',
                                'confidence' => 0.92,
                                'reasoning' => 'Keywords indicate equipment issue requiring repair'
                            })
                        }
                    }
                }
            };

            res.setBody(JSON.serialize(responseBody));
            return res;
        }
    }

    /**
     * Mock retryable failure (503 Service Unavailable)
     */
    private class RetryableFailureMock implements HttpCalloutMock {
        private static Integer callCount = 0;

        public HttpResponse respond(HttpRequest req) {
            callCount++;

            if (callCount == 1) {
                // First call fails with 503
                HttpResponse res = new HttpResponse();
                res.setStatusCode(503);
                res.setStatus('Service Unavailable');
                res.setBody('{"error": {"message": "Service temporarily unavailable"}}');
                return res;
            } else {
                // Second call succeeds
                HttpResponse res = new HttpResponse();
                res.setStatusCode(200);
                res.setStatus('OK');

                Map<String, Object> responseBody = new Map<String, Object>{
                    'choices' => new List<Map<String, Object>>{
                        new Map<String, Object>{
                            'message' => new Map<String, Object>{
                                'content' => JSON.serialize(new Map<String, Object>{
                                    'caseType' => 'Service Request',
                                    'caseSubType' => 'General',
                                    'caseReason' => 'Standard Service',
                                    'confidence' => 0.75,
                                    'reasoning' => 'General service request'
                                })
                            }
                        }
                    }
                };

                res.setBody(JSON.serialize(responseBody));
                return res;
            }
        }
    }

    /**
     * Mock non-retryable error (400 Bad Request)
     */
    private class BadRequestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            res.setBody('{"error": {"message": "Invalid request format"}}');
            return res;
        }
    }

    /**
     * Mock malformed JSON response
     */
    private class MalformedJSONMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');

            Map<String, Object> responseBody = new Map<String, Object>{
                'choices' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'message' => new Map<String, Object>{
                            'content' => 'This is not valid JSON for classification'
                        }
                    }
                }
            };

            res.setBody(JSON.serialize(responseBody));
            return res;
        }
    }
}
