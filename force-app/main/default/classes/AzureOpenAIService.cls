/**
 * Azure OpenAI Service - Handles AI-powered case classification
 *
 * This service integrates with Azure OpenAI (Microsoft Copilot) to predict
 * case classifications based on pre-intake diagnostic questions.
 *
 * Features:
 * - Intelligent case classification with confidence scores
 * - Retry logic for transient failures
 * - Historical pattern analysis
 * - Comprehensive error handling and logging
 * - Configurable via Custom Metadata
 *
 * @author Master Intake Flow Team
 * @date 2026-01-09
 */
public with sharing class AzureOpenAIService {

    // Configuration
    private static final String NAMED_CREDENTIAL = 'callout:Azure_OpenAI_Intake';
    private static final Integer MAX_RETRIES = 2;
    private static final Integer TIMEOUT_MS = 30000; // 30 seconds
    private static final Integer RETRY_DELAY_MS = 1000; // 1 second

    // Cache for configuration to avoid repeated queries
    private static AI_Configuration__mdt configCache;

    /**
     * Main entry point: Classify case based on pre-intake responses
     *
     * @param answers List of pre-intake question/answer pairs
     * @param caseRecord Case record with context information
     * @return ClassificationResult with predicted classification and confidence
     * @throws AzureOpenAIException if classification fails after retries
     */
    public static ClassificationResult classifyCase(
        List<PreIntakeAnswer> answers,
        Case caseRecord
    ) {
        if (answers == null || answers.isEmpty()) {
            throw new AzureOpenAIException('Pre-intake answers are required for classification');
        }

        if (caseRecord == null) {
            throw new AzureOpenAIException('Case record is required for classification');
        }

        try {
            // Build intelligent prompt with context
            String prompt = buildClassificationPrompt(answers, caseRecord);

            // Call Azure OpenAI with retry logic
            String response = callAzureOpenAIWithRetry(prompt);

            // Parse and validate response
            ClassificationResult result = parseClassificationResponse(response);

            // Log successful classification
            logClassification(caseRecord.Id, result, 'SUCCESS');

            return result;

        } catch (Exception e) {
            // Log failure
            logClassification(caseRecord.Id, null, 'FAILURE: ' + e.getMessage());

            // Re-throw as custom exception
            throw new AzureOpenAIException('Classification failed: ' + e.getMessage(), e);
        }
    }

    /**
     * Call Azure OpenAI with retry logic for transient failures
     */
    private static String callAzureOpenAIWithRetry(String userPrompt) {
        Integer attemptNumber = 1;
        Exception lastException = null;

        while (attemptNumber <= MAX_RETRIES) {
            try {
                System.debug('[AzureOpenAIService] Attempt ' + attemptNumber + ' of ' + MAX_RETRIES);
                return callAzureOpenAI(userPrompt);

            } catch (CalloutException e) {
                lastException = e;
                System.debug('[AzureOpenAIService] Attempt ' + attemptNumber + ' failed: ' + e.getMessage());

                // Check if error is retryable
                if (!isRetryableError(e) || attemptNumber >= MAX_RETRIES) {
                    throw e;
                }

                // Wait before retry (exponential backoff)
                Integer delayMs = RETRY_DELAY_MS * attemptNumber;
                System.debug('[AzureOpenAIService] Retrying in ' + delayMs + 'ms...');

                attemptNumber++;

            } catch (Exception e) {
                // Non-retryable error
                throw e;
            }
        }

        // Should never reach here, but just in case
        throw new AzureOpenAIException(
            'Failed after ' + MAX_RETRIES + ' attempts',
            lastException
        );
    }

    /**
     * Determine if an error is retryable (transient failure)
     */
    private static Boolean isRetryableError(Exception e) {
        String message = e.getMessage().toLowerCase();

        // Retry on these conditions
        return message.contains('timeout') ||
               message.contains('503') ||     // Service Unavailable
               message.contains('429') ||     // Rate Limit
               message.contains('500') ||     // Internal Server Error
               message.contains('502') ||     // Bad Gateway
               message.contains('504');       // Gateway Timeout
    }

    /**
     * Make HTTP callout to Azure OpenAI API
     */
    private static String callAzureOpenAI(String userPrompt) {
        // Get configuration
        AI_Configuration__mdt config = getConfiguration();

        // Build request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'messages' => new List<Map<String, String>>{
                new Map<String, String>{
                    'role' => 'system',
                    'content' => buildSystemPrompt()
                },
                new Map<String, String>{
                    'role' => 'user',
                    'content' => userPrompt
                }
            },
            'temperature' => config.Temperature__c,
            'max_tokens' => Integer.valueOf(config.Max_Tokens__c),
            'response_format' => new Map<String, String>{
                'type' => 'json_object'
            }
        };

        // Make HTTP callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + config.API_Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(TIMEOUT_MS);

        System.debug('[AzureOpenAIService] Request endpoint: ' + req.getEndpoint());
        System.debug('[AzureOpenAIService] Request body length: ' + req.getBody().length());

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('[AzureOpenAIService] Response status: ' + res.getStatusCode());
        System.debug('[AzureOpenAIService] Response body length: ' + res.getBody().length());

        // Handle error responses
        if (res.getStatusCode() != 200) {
            String errorMessage = 'Azure OpenAI API error: ' +
                                res.getStatusCode() + ' ' +
                                res.getStatus();

            try {
                // Try to parse error details from response
                Map<String, Object> errorBody =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                if (errorBody.containsKey('error')) {
                    Map<String, Object> error =
                        (Map<String, Object>) errorBody.get('error');
                    errorMessage += ' - ' + error.get('message');
                }
            } catch (Exception e) {
                // If parsing fails, include raw body
                errorMessage += ' - ' + res.getBody();
            }

            throw new CalloutException(errorMessage);
        }

        // Parse response to extract content
        try {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> choices = (List<Object>) responseMap.get('choices');

            if (choices == null || choices.isEmpty()) {
                throw new AzureOpenAIException('No choices returned in API response');
            }

            Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
            Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
            String content = (String) message.get('content');

            System.debug('[AzureOpenAIService] Extracted content: ' + content);

            return content;

        } catch (Exception e) {
            throw new AzureOpenAIException(
                'Failed to parse Azure OpenAI response: ' + e.getMessage(),
                e
            );
        }
    }

    /**
     * Build system prompt that defines AI behavior
     */
    private static String buildSystemPrompt() {
        return 'You are an expert case classification system for a waste management company. ' +
               'Your role is to analyze case intake responses and predict the correct classification. ' +
               'You must return ONLY valid JSON with no additional text. ' +
               'Be precise and consider historical patterns when available. ' +
               'Provide confidence scores between 0.0 and 1.0 based on certainty.';
    }

    /**
     * Build user prompt with case context and answers
     */
    private static String buildClassificationPrompt(
        List<PreIntakeAnswer> answers,
        Case caseRecord
    ) {
        String prompt = '# Case Context:\n';
        prompt += '- Customer: ' + (caseRecord.Client__r?.Name ?? 'Unknown') + '\n';
        prompt += '- Location: ' + (caseRecord.Location__r?.Name ?? 'Unknown') + '\n';

        if (caseRecord.Service_Date__c != null) {
            prompt += '- Service Date: ' + caseRecord.Service_Date__c.format() + '\n';
        }

        prompt += '\n# Pre-Intake Responses:\n';
        Integer questionNum = 1;
        for (PreIntakeAnswer answer : answers) {
            prompt += 'Q' + questionNum + ': ' + answer.questionText + '\n';
            prompt += 'A' + questionNum + ': ' + answer.answerText + '\n\n';
            questionNum++;
        }

        // Add historical patterns if available
        String historicalContext = getHistoricalPatterns(answers);
        if (String.isNotBlank(historicalContext)) {
            prompt += '# Historical Pattern:\n';
            prompt += historicalContext + '\n\n';
        }

        // Add available classifications
        prompt += '# Available Classifications:\n';
        prompt += getAvailableClassifications() + '\n\n';

        // Task instructions
        prompt += '# Task:\n';
        prompt += 'Based on the case context and responses above, predict the most appropriate classification.\n';
        prompt += 'Consider keywords, urgency indicators, and historical patterns.\n\n';

        prompt += 'Return ONLY a JSON object in this exact format (no markdown, no additional text):\n';
        prompt += '{\n';
        prompt += '  "caseType": "string",\n';
        prompt += '  "caseSubType": "string",\n';
        prompt += '  "caseReason": "string",\n';
        prompt += '  "confidence": 0.85,\n';
        prompt += '  "reasoning": "Brief explanation of why this classification was chosen"\n';
        prompt += '}';

        return prompt;
    }

    /**
     * Parse AI response into ClassificationResult
     */
    private static ClassificationResult parseClassificationResponse(String jsonResponse) {
        try {
            // Clean response (remove markdown code blocks if present)
            jsonResponse = jsonResponse.trim();
            if (jsonResponse.startsWith('```json')) {
                jsonResponse = jsonResponse.substring(7);
            }
            if (jsonResponse.startsWith('```')) {
                jsonResponse = jsonResponse.substring(3);
            }
            if (jsonResponse.endsWith('```')) {
                jsonResponse = jsonResponse.substring(0, jsonResponse.length() - 3);
            }
            jsonResponse = jsonResponse.trim();

            Map<String, Object> parsed =
                (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

            ClassificationResult result = new ClassificationResult();
            result.caseType = (String) parsed.get('caseType');
            result.caseSubType = (String) parsed.get('caseSubType');
            result.caseReason = (String) parsed.get('caseReason');
            result.reasoning = (String) parsed.get('reasoning');

            // Parse confidence as Decimal (could be Double from JSON)
            Object confidenceObj = parsed.get('confidence');
            if (confidenceObj instanceof Double) {
                result.confidence = Decimal.valueOf((Double) confidenceObj);
            } else if (confidenceObj instanceof Integer) {
                result.confidence = Decimal.valueOf((Integer) confidenceObj);
            } else {
                result.confidence = 0.0;
            }

            // Validate required fields
            if (String.isBlank(result.caseType) ||
                String.isBlank(result.caseSubType) ||
                String.isBlank(result.caseReason)) {
                throw new AzureOpenAIException('AI response missing required classification fields');
            }

            // Validate confidence range
            if (result.confidence < 0 || result.confidence > 1) {
                System.debug('[AzureOpenAIService] Invalid confidence value, setting to 0.5');
                result.confidence = 0.5;
            }

            return result;

        } catch (Exception e) {
            throw new AzureOpenAIException(
                'Failed to parse classification response: ' + e.getMessage() +
                '\nResponse: ' + jsonResponse,
                e
            );
        }
    }

    /**
     * Get historical classification patterns for similar cases
     */
    private static String getHistoricalPatterns(List<PreIntakeAnswer> answers) {
        try {
            // Extract keywords from answers
            Set<String> keywords = extractKeywords(answers);

            if (keywords.isEmpty()) {
                return '';
            }

            // Build dynamic SOQL with keywords
            String keywordPattern = '%' + String.join(new List<String>(keywords), '%') + '%';

            // Query similar historical cases (limited for performance)
            List<Case> similarCases = [
                SELECT Case_Type__c, Case_Sub_Type__c, Case_Reason__c
                FROM Case
                WHERE Master_Intake_Complete__c = true
                AND (Description LIKE :keywordPattern OR Subject LIKE :keywordPattern)
                AND CreatedDate = LAST_N_DAYS:90
                ORDER BY CreatedDate DESC
                LIMIT 20
            ];

            if (similarCases.isEmpty()) {
                return '';
            }

            // Count classification patterns
            Map<String, Integer> patternCounts = new Map<String, Integer>();
            for (Case c : similarCases) {
                String pattern = c.Case_Type__c + ' > ' +
                               c.Case_Sub_Type__c + ' > ' +
                               c.Case_Reason__c;

                patternCounts.put(
                    pattern,
                    patternCounts.containsKey(pattern)
                        ? patternCounts.get(pattern) + 1
                        : 1
                );
            }

            // Build summary
            String summary = 'In the last 90 days, similar keywords appeared in:\n';
            for (String pattern : patternCounts.keySet()) {
                summary += '- ' + pattern + ' (' + patternCounts.get(pattern) + ' cases)\n';
            }

            return summary;

        } catch (Exception e) {
            System.debug('[AzureOpenAIService] Error getting historical patterns: ' + e.getMessage());
            return ''; // Fail gracefully
        }
    }

    /**
     * Extract keywords from answers for pattern matching
     */
    private static Set<String> extractKeywords(List<PreIntakeAnswer> answers) {
        Set<String> keywords = new Set<String>();

        // Common stop words to exclude
        Set<String> stopWords = new Set<String>{
            'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
            'of', 'with', 'by', 'is', 'are', 'was', 'were', 'be', 'been'
        };

        for (PreIntakeAnswer answer : answers) {
            if (String.isBlank(answer.answerText)) {
                continue;
            }

            // Split into words and filter
            List<String> words = answer.answerText.toLowerCase()
                                                  .replaceAll('[^a-z0-9 ]', ' ')
                                                  .split('\\s+');

            for (String word : words) {
                // Only include words 4+ chars that aren't stop words
                if (word.length() >= 4 && !stopWords.contains(word)) {
                    keywords.add(word);
                }
            }
        }

        return keywords;
    }

    /**
     * Get available classifications from Intake_Process__c records
     */
    private static String getAvailableClassifications() {
        try {
            // Query unique classification combinations
            List<AggregateResult> results = [
                SELECT Case_Type__c type, Case_Sub_Type__c subType, Case_Reason__c reason
                FROM Intake_Process__c
                WHERE Is_Question__c = true
                AND Case_Type__c != null
                AND Case_Sub_Type__c != null
                AND Case_Reason__c != null
                GROUP BY Case_Type__c, Case_Sub_Type__c, Case_Reason__c
                ORDER BY Case_Type__c, Case_Sub_Type__c, Case_Reason__c
                LIMIT 100
            ];

            Set<String> classifications = new Set<String>();
            for (AggregateResult result : results) {
                String classification = result.get('type') + ' > ' +
                                      result.get('subType') + ' > ' +
                                      result.get('reason');
                classifications.add(classification);
            }

            return String.join(new List<String>(classifications), '\n');

        } catch (Exception e) {
            System.debug('[AzureOpenAIService] Error getting classifications: ' + e.getMessage());
            return 'Classifications list unavailable';
        }
    }

    /**
     * Get AI configuration from Custom Metadata
     */
    private static AI_Configuration__mdt getConfiguration() {
        if (configCache == null) {
            try {
                configCache = [
                    SELECT API_Endpoint__c, Temperature__c, Max_Tokens__c
                    FROM AI_Configuration__mdt
                    WHERE DeveloperName = 'Case_Classification'
                    LIMIT 1
                ];
            } catch (Exception e) {
                // Return default configuration if metadata not found
                configCache = new AI_Configuration__mdt(
                    API_Endpoint__c = '/openai/deployments/case-classifier/chat/completions?api-version=2024-02-15-preview',
                    Temperature__c = 0.3,
                    Max_Tokens__c = 500
                );
            }
        }

        return configCache;
    }

    /**
     * Log classification attempt for monitoring and debugging
     */
    private static void logClassification(
        Id caseId,
        ClassificationResult result,
        String status
    ) {
        try {
            // In production, consider logging to a custom object
            // For now, using System.debug
            System.debug('[AzureOpenAIService] Classification Log:');
            System.debug('  Case ID: ' + caseId);
            System.debug('  Status: ' + status);

            if (result != null) {
                System.debug('  Type: ' + result.caseType);
                System.debug('  Sub-Type: ' + result.caseSubType);
                System.debug('  Reason: ' + result.caseReason);
                System.debug('  Confidence: ' + result.confidence);
                System.debug('  Reasoning: ' + result.reasoning);
            }

        } catch (Exception e) {
            // Never fail on logging errors
            System.debug('[AzureOpenAIService] Logging error: ' + e.getMessage());
        }
    }

    // ========== WRAPPER CLASSES ==========

    /**
     * Represents a pre-intake question and answer pair
     */
    public class PreIntakeAnswer {
        @AuraEnabled public String questionText { get; set; }
        @AuraEnabled public String answerText { get; set; }

        public PreIntakeAnswer() {}

        public PreIntakeAnswer(String question, String answer) {
            this.questionText = question;
            this.answerText = answer;
        }
    }

    /**
     * Represents an AI classification result
     */
    public class ClassificationResult {
        @AuraEnabled public String caseType { get; set; }
        @AuraEnabled public String caseSubType { get; set; }
        @AuraEnabled public String caseReason { get; set; }
        @AuraEnabled public Decimal confidence { get; set; }
        @AuraEnabled public String reasoning { get; set; }
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String errorMessage { get; set; }

        public ClassificationResult() {
            this.success = true;
        }
    }

    /**
     * Custom exception for Azure OpenAI errors
     */
    public class AzureOpenAIException extends Exception {}
}
