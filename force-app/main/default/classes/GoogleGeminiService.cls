/**
 * Google Gemini Service - Handles AI-powered case classification
 *
 * This service integrates with Google Gemini AI to predict
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
public with sharing class GoogleGeminiService {

    // Configuration
    private static final String NAMED_CREDENTIAL = 'callout:Google_Gemini_API';
    private static final Integer MAX_RETRIES = 1; // Only 1 attempt, no retries to prevent token exhaustion and delays
    private static final Integer TIMEOUT_MS = 30000; // 30 seconds
    private static final Integer RETRY_DELAY_MS = 1000; // 1 second

    // Special user email for personalized messages
    private static final String JACKIE_EMAIL = 'jduran6@wm.com';

    // Cache for configuration to avoid repeated queries
    private static AI_Configuration__mdt configCache;

    /**
     * Main entry point: Classify case based on pre-intake responses
     *
     * @param answers List of pre-intake question/answer pairs
     * @param caseRecord Case record with context information
     * @return ClassificationResult with predicted classification and confidence
     * @throws GoogleGeminiException if classification fails after retries
     */
    public static ClassificationResult classifyCase(
        List<PreIntakeAnswer> answers,
        Case caseRecord
    ) {
        if (answers == null || answers.isEmpty()) {
            throw new GoogleGeminiException('Pre-intake answers are required for classification');
        }

        if (caseRecord == null) {
            throw new GoogleGeminiException('Case record is required for classification');
        }

        try {
            // Build intelligent prompt with context
            String prompt = buildClassificationPrompt(answers, caseRecord);

            // Call Google Gemini with retry logic
            String response = callGeminiWithRetry(prompt);

            // Parse and validate response
            ClassificationResult result = parseClassificationResponse(response);

            // Log successful classification
            logClassification(caseRecord.Id, result, 'SUCCESS');

            return result;

        } catch (Exception e) {
            // Log failure
            logClassification(caseRecord.Id, null, 'FAILURE: ' + e.getMessage());

            // Re-throw as custom exception
            throw new GoogleGeminiException('Classification failed: ' + e.getMessage(), e);
        }
    }

    /**
     * Generate concise case subject line from intake answers
     *
     * @param answers List of intake question/answer pairs (as JSON string from frontend)
     * @param caseRecord Case record with context information
     * @return String subject line (max 255 characters)
     * @throws GoogleGeminiException if generation fails after retries
     */
    public static String generateCaseSubject(
        String answersJSON,
        Case caseRecord
    ) {
        if (String.isBlank(answersJSON)) {
            throw new GoogleGeminiException('Intake answers JSON is required for subject generation');
        }

        // Parse JSON to answer objects
        List<Object> answersRaw = (List<Object>) JSON.deserializeUntyped(answersJSON);
        List<PreIntakeAnswer> answers = new List<PreIntakeAnswer>();

        for (Object answerObj : answersRaw) {
            Map<String, Object> answerMap = (Map<String, Object>) answerObj;
            PreIntakeAnswer answer = new PreIntakeAnswer();
            answer.questionText = (String) answerMap.get('questionText');
            answer.answerText = (String) answerMap.get('answerText');
            answers.add(answer);
        }

        if (answers.isEmpty()) {
            throw new GoogleGeminiException('No valid answers provided for subject generation');
        }

        if (caseRecord == null) {
            throw new GoogleGeminiException('Case record is required for subject generation');
        }

        try {
            // Build subject generation prompt
            String prompt = buildSubjectPrompt(answers, caseRecord);

            // Call Google Gemini with retry logic
            String response = callGeminiWithRetry(prompt);

            // Parse and validate response
            String subject = parseSubjectResponse(response);

            // Log successful generation
            System.debug('[GoogleGeminiService] Generated subject: ' + subject);

            return subject;

        } catch (Exception e) {
            // Log failure
            System.debug('[GoogleGeminiService] Subject generation failed: ' + e.getMessage());

            // Re-throw as custom exception
            throw new GoogleGeminiException('Subject generation failed: ' + e.getMessage(), e);
        }
    }

    /**
     * Call Google Gemini with retry logic for transient failures
     */
    private static String callGeminiWithRetry(String prompt) {
        Integer attemptNumber = 1;
        Exception lastException = null;

        while (attemptNumber <= MAX_RETRIES) {
            try {
                System.debug('[GoogleGeminiService] Attempt ' + attemptNumber + ' of ' + MAX_RETRIES);
                return callGemini(prompt);

            } catch (CalloutException e) {
                lastException = e;
                System.debug('[GoogleGeminiService] Attempt ' + attemptNumber + ' failed: ' + e.getMessage());

                // Check if error is retryable
                if (!isRetryableError(e) || attemptNumber >= MAX_RETRIES) {
                    throw e;
                }

                // Wait before retry (exponential backoff)
                Integer delayMs = RETRY_DELAY_MS * attemptNumber;
                System.debug('[GoogleGeminiService] Retrying in ' + delayMs + 'ms...');

                attemptNumber++;

            } catch (Exception e) {
                // Non-retryable error
                throw e;
            }
        }

        // Should never reach here, but just in case
        throw new GoogleGeminiException(
            'Failed after ' + MAX_RETRIES + ' attempts',
            lastException
        );
    }

    /**
     * Determine if an error is retryable (transient failure)
     * NOTE: MAX_RETRIES is set to 1, so retries are disabled by default to prevent
     * token exhaustion and delays. This method is kept for configuration flexibility.
     */
    private static Boolean isRetryableError(Exception e) {
        String message = e.getMessage().toLowerCase();

        // DO NOT retry on quota/token errors - these will not resolve with retries
        if (message.contains('quota') ||
            message.contains('resource_exhausted') ||
            message.contains('insufficient') ||
            message.contains('429')) {  // Rate Limit / Quota Exceeded
            System.debug('[GoogleGeminiService] Quota/token limit error detected - not retrying');
            return false;
        }

        // Only retry on truly transient network errors (though MAX_RETRIES=1 prevents retries)
        return message.contains('timeout') ||
               message.contains('503') ||     // Service Unavailable
               message.contains('500') ||     // Internal Server Error
               message.contains('502') ||     // Bad Gateway
               message.contains('504');       // Gateway Timeout
    }

    /**
     * Make HTTP callout to Google Gemini API
     */
    private static String callGemini(String prompt) {
        // Get configuration
        AI_Configuration__mdt config = getConfiguration();

        // Build request body for Gemini API
        Map<String, Object> requestBody = new Map<String, Object>{
            'contents' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'parts' => new List<Map<String, String>>{
                        new Map<String, String>{
                            'text' => prompt
                        }
                    }
                }
            },
            'generationConfig' => new Map<String, Object>{
                'temperature' => config.Temperature__c,
                'maxOutputTokens' => Integer.valueOf(config.Max_Tokens__c)
            }
        };

        // Make HTTP callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + config.API_Endpoint__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(TIMEOUT_MS);

        System.debug('[GoogleGeminiService] Request endpoint: ' + req.getEndpoint());
        System.debug('[GoogleGeminiService] Request body length: ' + req.getBody().length());

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('[GoogleGeminiService] Response status: ' + res.getStatusCode());
        System.debug('[GoogleGeminiService] Response body length: ' + res.getBody().length());

        // Handle error responses
        if (res.getStatusCode() != 200) {
            String errorMessage = 'Google Gemini API error: ' +
                                res.getStatusCode() + ' ' +
                                res.getStatus();

            try {
                // Try to parse error details from response
                Map<String, Object> errorBody =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                if (errorBody.containsKey('error')) {
                    Map<String, Object> error =
                        (Map<String, Object>) errorBody.get('error');
                    String apiMessage = (String) error.get('message');
                    errorMessage += ' - ' + apiMessage;

                    // Log specific error for quota/token issues
                    if (res.getStatusCode() == 429 ||
                        (apiMessage != null && (apiMessage.toLowerCase().contains('quota') ||
                                               apiMessage.toLowerCase().contains('resource_exhausted')))) {
                        System.debug('[GoogleGeminiService] QUOTA/TOKEN LIMIT ERROR - AI tokens may be exhausted');
                    }
                }
            } catch (Exception e) {
                // If parsing fails, include raw body
                errorMessage += ' - ' + res.getBody();
            }

            System.debug('[GoogleGeminiService] API Error: ' + errorMessage);
            throw new CalloutException(errorMessage);
        }

        // Parse response to extract content
        try {
            Map<String, Object> responseMap =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> candidates = (List<Object>) responseMap.get('candidates');

            if (candidates == null || candidates.isEmpty()) {
                throw new GoogleGeminiException('No candidates returned in API response');
            }

            Map<String, Object> firstCandidate = (Map<String, Object>) candidates[0];
            Map<String, Object> content = (Map<String, Object>) firstCandidate.get('content');
            List<Object> parts = (List<Object>) content.get('parts');

            if (parts == null || parts.isEmpty()) {
                throw new GoogleGeminiException('No parts in candidate response');
            }

            Map<String, Object> firstPart = (Map<String, Object>) parts[0];
            String text = (String) firstPart.get('text');

            System.debug('[GoogleGeminiService] Extracted content: ' + text);

            return text;

        } catch (Exception e) {
            throw new GoogleGeminiException(
                'Failed to parse Google Gemini response: ' + e.getMessage(),
                e
            );
        }
    }

    /**
     * Build user prompt with case context and answers
     */
    private static String buildClassificationPrompt(
        List<PreIntakeAnswer> answers,
        Case caseRecord
    ) {
        String prompt = 'You are an expert case classification system for a waste management company. ';
        prompt += 'Your role is to analyze case intake responses and predict the correct classification. ';
        prompt += 'You must return ONLY valid JSON with no additional text or markdown.\n\n';

        prompt += '# Case Context:\n';
        prompt += '- Customer: ' + (caseRecord.Client__r?.Name ?? 'Unknown') + '\n';
        prompt += '- Location: ' + (caseRecord.Location__r?.Name ?? 'Unknown') + '\n';

        // Include current case classification values for context
        if (String.isNotBlank(caseRecord.Case_Type__c)) {
            prompt += '- Current Case Type: ' + caseRecord.Case_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Sub_Type__c)) {
            prompt += '- Current Case Sub-Type: ' + caseRecord.Case_Sub_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Reason__c)) {
            prompt += '- Current Case Reason: ' + caseRecord.Case_Reason__c + '\n';
        }

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

        // Add available record types
        prompt += '# Available Record Types:\n';
        prompt += getAvailableRecordTypes() + '\n\n';

        // Task instructions
        prompt += '# Task:\n';
        prompt += 'Based on the case context and responses above:\n';
        prompt += '1. Predict the most appropriate classification (type, subtype, reason, record type)\n';
        prompt += '2. Extract location name if mentioned (e.g., "Main Street location", "Building 5", "Site A")\n';
        prompt += '3. Extract asset/equipment description if mentioned (e.g., "compactor", "front loader", "unit 123")\n';
        prompt += '4. Extract service date if mentioned (e.g., "next week", "tomorrow", "March 15th")\n\n';

        prompt += '# IMPORTANT CLASSIFICATION GUIDELINES:\n';
        prompt += '- An incomplete stronger match is BETTER than a complete weaker match\n';
        prompt += '- If Case Type and Sub-Type are clear but Reason is not, return null for caseReason\n';
        prompt += '- Skilled representatives may directly state classifications (e.g., "needs an empty and return")\n';
        prompt += '- Not all case types have master intake flows - this does not invalidate the classification\n';
        prompt += '- Focus on matching the intent and keywords from the user\'s description\n';
        prompt += '- Consider current case values as context but update if user input suggests different classification\n\n';

        prompt += '# Examples:\n';
        prompt += 'Example 1 - Direct classification statement:\n';
        prompt += 'User: "HMD000257 requires an empty and return of their 40 yard compactor"\n';
        prompt += 'Result: {"caseType": "Pickup", "caseSubType": "Empty and Return", "caseReason": null, "recordType": "Pickup_Case"}\n';
        prompt += 'Reasoning: User directly stated "empty and return" - strong match even without Case Reason.\n\n';

        prompt += 'Example 2 - Incomplete but strong:\n';
        prompt += 'User: "Customer needs equipment serviced"\n';
        prompt += 'Result: {"caseType": "Service Request", "caseSubType": "Maintenance", "caseReason": null, "recordType": "Service_Case"}\n';
        prompt += 'Reasoning: Clear service request, maintenance is appropriate, but no specific reason evident.\n\n';

        prompt += 'Example 3 - Complete and strong:\n';
        prompt += 'User: "Compactor is broken and leaking fluids, needs urgent repair"\n';
        prompt += 'Result: {"caseType": "Service Request", "caseSubType": "Repair", "caseReason": "Equipment Malfunction", "recordType": "Service_Case"}\n';
        prompt += 'Reasoning: All fields have strong matches from user description.\n\n';

        // Add personalization for Jackie Duran
        String jackieInstructions = '';
        if (isJackieDuran()) {
            jackieInstructions = '\n\n# SPECIAL INSTRUCTION FOR THIS USER:\n';
            jackieInstructions += 'The person viewing this classification is Jackie Duran, an amazing training consultant. ';
            jackieInstructions += 'In your "reasoning" field, start with 1-2 sentences of genuine appreciation for Jackie. ';
            jackieInstructions += 'Here are wonderful things about Jackie: ' + getJackiePersonalization() + '\n';
            jackieInstructions += 'After your personalized message, provide your classification reasoning as normal.';
        }

        prompt += jackieInstructions + '\n\n';
        prompt += 'Return ONLY a JSON object in this exact format (no markdown, no code blocks, no additional text):\n';
        prompt += '{\n';
        prompt += '  "caseType": "string (required)",\n';
        prompt += '  "caseSubType": "string (required)",\n';
        prompt += '  "caseReason": "string or null (use null if no strong match)",\n';
        prompt += '  "recordType": "string (DeveloperName from available record types)",\n';
        prompt += '  "locationName": "string or null (extracted location name if mentioned)",\n';
        prompt += '  "assetDescription": "string or null (extracted asset/equipment description if mentioned)",\n';
        prompt += '  "serviceDateString": "string or null (extracted date in natural language if mentioned)",\n';
        prompt += '  "confidence": 0.85,\n';
        prompt += '  "reasoning": "Brief explanation of why this classification was chosen';
        if (isJackieDuran()) {
            prompt += ' (start with personalized message for Jackie as instructed)';
        }
        prompt += '"\n';
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
            result.recordType = (String) parsed.get('recordType');
            result.locationName = (String) parsed.get('locationName');
            result.assetDescription = (String) parsed.get('assetDescription');
            result.serviceDateString = (String) parsed.get('serviceDateString');
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
            // NOTE: caseReason is optional - incomplete strong match is better than complete weak match
            if (String.isBlank(result.caseType) ||
                String.isBlank(result.caseSubType)) {
                throw new GoogleGeminiException('AI response missing required classification fields (caseType and caseSubType are required)');
            }

            // Validate confidence range
            if (result.confidence < 0 || result.confidence > 1) {
                System.debug('[GoogleGeminiService] Invalid confidence value, setting to 0.5');
                result.confidence = 0.5;
            }

            return result;

        } catch (Exception e) {
            throw new GoogleGeminiException(
                'Failed to parse classification response: ' + e.getMessage() +
                '\nResponse: ' + jsonResponse,
                e
            );
        }
    }

    /**
     * Build prompt for subject line generation
     */
    private static String buildSubjectPrompt(
        List<PreIntakeAnswer> answers,
        Case caseRecord
    ) {
        String prompt = 'You are an expert at creating concise, descriptive case subject lines. ';
        prompt += 'Your role is to analyze case intake responses and case details to create a brief subject line. ';
        prompt += 'The subject must be under 255 characters and capture the key issue.\n\n';

        prompt += '# Case Context:\n';
        prompt += '- Customer: ' + (caseRecord.Client__r?.Name ?? 'Unknown') + '\n';
        prompt += '- Location: ' + (caseRecord.Location__r?.Name ?? 'Unknown') + '\n';

        // Add Location Account Number if available
        if (String.isNotBlank(caseRecord.Location__r?.AccountNumber)) {
            prompt += '- Location Account #: ' + caseRecord.Location__r.AccountNumber + '\n';
        }

        // Add Case classification if available
        if (String.isNotBlank(caseRecord.Case_Type__c)) {
            prompt += '- Case Type: ' + caseRecord.Case_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Sub_Type__c)) {
            prompt += '- Case Sub-Type: ' + caseRecord.Case_Sub_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Reason__c)) {
            prompt += '- Case Reason: ' + caseRecord.Case_Reason__c + '\n';
        }

        // Add Asset details if available
        if (caseRecord.AssetId != null) {
            prompt += '- Asset: ' + (caseRecord.Asset?.Name ?? 'Unknown') + '\n';

            if (String.isNotBlank(caseRecord.Asset?.Acorn_SID__c)) {
                prompt += '- Asset SID: ' + caseRecord.Asset.Acorn_SID__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset?.Material_Type__c)) {
                prompt += '- Material Type: ' + caseRecord.Asset.Material_Type__c + '\n';
            }
        }

        if (caseRecord.Service_Date__c != null) {
            prompt += '- Service Date: ' + caseRecord.Service_Date__c.format() + '\n';
        }

        prompt += '\n# Intake Responses:\n';
        Integer questionNum = 1;
        for (PreIntakeAnswer answer : answers) {
            prompt += 'Q' + questionNum + ': ' + answer.questionText + '\n';
            prompt += 'A' + questionNum + ': ' + answer.answerText + '\n\n';
            questionNum++;
        }

        // Task instructions
        prompt += '# Task:\n';
        prompt += 'Based on the case context and intake responses above, create a concise subject line that:\n';
        prompt += '- Captures the main issue or request\n';
        prompt += '- Is under 255 characters\n';
        prompt += '- Is clear and specific\n';
        prompt += '- Includes location account number when available (e.g., "HMD000257", "ESS001000")\n';
        prompt += '- Includes asset details when relevant (equipment type, material type)\n';
        prompt += '- References the case type/reason when appropriate\n';
        prompt += '- Uses professional language\n\n';

        prompt += 'Examples of preferred subject formats:\n';
        prompt += '- "Missed Pickup at HMD000257 on the 8 yard trash dumpster"\n';
        prompt += '- "Repair for ESS001000 on the 34 yard cardboard compactor"\n';
        prompt += '- "Service Request at ABC123456 - Equipment maintenance needed"\n';
        prompt += '- "Delivery Issue for DEF789012 - New 6 yard recycling container"\n';
        prompt += '- "Billing Inquiry for GHI345678 - Invoice discrepancy"\n\n';

        prompt += 'IMPORTANT: When location account number is available, use the format "[Action] at/for [Account#] on/for the [Asset/Equipment]".\n';
        prompt += 'When asset details are provided, include asset description in the subject line.\n\n';

        prompt += 'Return ONLY the subject line text with no quotes, no JSON, no additional text.';

        return prompt;
    }

    /**
     * Parse subject line from AI response
     */
    private static String parseSubjectResponse(String response) {
        // Clean response
        String subject = response.trim();

        // Remove quotes if present
        if (subject.startsWith('"') && subject.endsWith('"')) {
            subject = subject.substring(1, subject.length() - 1);
        }
        if (subject.startsWith('\'') && subject.endsWith('\'')) {
            subject = subject.substring(1, subject.length() - 1);
        }

        // Remove any markdown or code block artifacts
        if (subject.startsWith('```')) {
            Integer firstNewline = subject.indexOf('\n');
            if (firstNewline > 0) {
                subject = subject.substring(firstNewline + 1);
            }
        }
        if (subject.endsWith('```')) {
            subject = subject.substring(0, subject.length() - 3);
        }

        subject = subject.trim();

        // Truncate if exceeds Salesforce limit
        if (subject.length() > 255) {
            subject = subject.substring(0, 252) + '...';
        }

        // Validate not empty
        if (String.isBlank(subject)) {
            throw new GoogleGeminiException('AI returned empty subject line');
        }

        return subject;
    }

    /**
     * Generate subject line from case data using AI
     * This method is called when a case is closed without a subject
     * Analyzes comments, tasks, emails, quotes, and history to generate comprehensive subject
     *
     * @param comments List of Comment__c records for the case
     * @param tasks List of Task records related to the case
     * @param emails List of EmailMessage records related to the case
     * @param quotes List of SBQQ__Quote__c records related to the case
     * @param caseHistory List of CaseHistory records for tracked field changes
     * @param quoteHistory List of SBQQ__QuoteHistory__c records for quote field changes
     * @param caseRecord Case record with context information
     * @return String the generated subject line
     * @throws GoogleGeminiException if subject generation fails
     */
    public static String generateSubjectFromComments(
        List<Comment__c> comments,
        List<Task> tasks,
        List<EmailMessage> emails,
        List<SBQQ__Quote__c> quotes,
        List<CaseHistory> caseHistory,
        List<SBQQ__QuoteHistory__c> quoteHistory,
        Case caseRecord
    ) {
        if (caseRecord == null) {
            throw new GoogleGeminiException('Case record is required for subject generation');
        }

        // Check if we have any data
        Boolean hasData = (comments != null && !comments.isEmpty()) ||
                         (tasks != null && !tasks.isEmpty()) ||
                         (emails != null && !emails.isEmpty()) ||
                         (quotes != null && !quotes.isEmpty()) ||
                         (caseHistory != null && !caseHistory.isEmpty());

        if (!hasData) {
            throw new GoogleGeminiException('No data available for subject generation');
        }

        try {
            // Build subject generation prompt from all available data
            String prompt = buildSubjectFromCommentsPrompt(
                comments,
                tasks,
                emails,
                quotes,
                caseHistory,
                quoteHistory,
                caseRecord
            );

            // Call Google Gemini with retry logic
            String response = callGeminiWithRetry(prompt);

            // Parse and validate response
            String subject = parseSubjectResponse(response);

            // Log successful generation
            System.debug('[GoogleGeminiService] Generated subject from case data: ' + subject);

            return subject;

        } catch (Exception e) {
            // Log failure
            System.debug('[GoogleGeminiService] Subject generation from case data failed: ' + e.getMessage());

            // Re-throw as custom exception
            throw new GoogleGeminiException('Subject generation from case data failed: ' + e.getMessage(), e);
        }
    }

    /**
     * Build prompt for subject line generation from case data
     * Includes comments, tasks, emails, quotes, and history
     */
    private static String buildSubjectFromCommentsPrompt(
        List<Comment__c> comments,
        List<Task> tasks,
        List<EmailMessage> emails,
        List<SBQQ__Quote__c> quotes,
        List<CaseHistory> caseHistory,
        List<SBQQ__QuoteHistory__c> quoteHistory,
        Case caseRecord
    ) {
        String prompt = 'You are an expert at creating concise, descriptive case subject lines. ';
        prompt += 'Your role is to analyze case data including comments, tasks, emails, quotes, and history to create a brief subject line. ';
        prompt += 'The subject must be under 255 characters and capture the key issue and resolution.\n\n';

        prompt += '# Case Context:\n';
        prompt += '- Case Number: ' + caseRecord.CaseNumber + '\n';
        prompt += '- Customer: ' + (caseRecord.Client__r?.Name ?? 'Unknown') + '\n';
        prompt += '- Location: ' + (caseRecord.Location__r?.Name ?? 'Unknown') + '\n';

        // Add Location Account Number if available
        if (String.isNotBlank(caseRecord.Location__r?.AccountNumber)) {
            prompt += '- Location Account #: ' + caseRecord.Location__r.AccountNumber + '\n';
        }

        // Add Case classification if available
        if (String.isNotBlank(caseRecord.Case_Type__c)) {
            prompt += '- Case Type: ' + caseRecord.Case_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Sub_Type__c)) {
            prompt += '- Case Sub-Type: ' + caseRecord.Case_Sub_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Reason__c)) {
            prompt += '- Case Reason: ' + caseRecord.Case_Reason__c + '\n';
        }

        // Add Asset details if available
        if (caseRecord.AssetId != null) {
            prompt += '- Asset: ' + (caseRecord.Asset?.Name ?? 'Unknown') + '\n';

            if (String.isNotBlank(caseRecord.Asset?.Acorn_SID__c)) {
                prompt += '- Asset SID: ' + caseRecord.Asset.Acorn_SID__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset?.Material_Type__c)) {
                prompt += '- Material Type: ' + caseRecord.Asset.Material_Type__c + '\n';
            }
        }

        if (caseRecord.Service_Date__c != null) {
            prompt += '- Service Date: ' + caseRecord.Service_Date__c.format() + '\n';
        }

        prompt += '- Status: ' + caseRecord.Status + '\n';

        // Add Comments section if available
        if (comments != null && !comments.isEmpty()) {
            prompt += '\n# Case Comments:\n';
            prompt += 'Below are the comments documenting the work performed and progress on this case:\n\n';

            Integer commentNum = 1;
            for (Comment__c comment : comments) {
                if (String.isNotBlank(comment.Comment__c)) {
                    prompt += 'Comment ' + commentNum + ' (' + comment.CreatedDate.format('MM/dd/yyyy') + ' by ' + comment.CreatedBy.Name + '):\n';
                    prompt += comment.Comment__c + '\n\n';
                    commentNum++;
                }
            }
        }

        // Add Tasks section if available
        if (tasks != null && !tasks.isEmpty()) {
            prompt += '\n# Tasks:\n';
            prompt += 'Below are the tasks related to this case:\n\n';

            Integer taskNum = 1;
            for (Task task : tasks) {
                prompt += 'Task ' + taskNum + ' (' + task.CreatedDate.format('MM/dd/yyyy') + ' by ' + task.CreatedBy.Name + '):\n';
                prompt += '- Subject: ' + (task.Subject ?? 'No Subject') + '\n';
                prompt += '- Status: ' + (task.Status ?? 'Unknown') + '\n';

                if (task.ActivityDate != null) {
                    prompt += '- Due Date: ' + task.ActivityDate.format() + '\n';
                }

                if (String.isNotBlank(task.Description)) {
                    prompt += '- Description: ' + task.Description + '\n';
                }

                prompt += '\n';
                taskNum++;
            }
        }

        // Add Emails section if available
        if (emails != null && !emails.isEmpty()) {
            prompt += '\n# Emails:\n';
            prompt += 'Below are the emails related to this case:\n\n';

            Integer emailNum = 1;
            for (EmailMessage email : emails) {
                prompt += 'Email ' + emailNum + ' (' + email.MessageDate.format('MM/dd/yyyy') + '):\n';
                prompt += '- From: ' + (email.FromAddress ?? 'Unknown') + '\n';
                prompt += '- To: ' + (email.ToAddress ?? 'Unknown') + '\n';
                prompt += '- Subject: ' + (email.Subject ?? 'No Subject') + '\n';

                // Prefer TextBody, fallback to HtmlBody
                String emailBody = String.isNotBlank(email.TextBody) ? email.TextBody : email.HtmlBody;
                if (String.isNotBlank(emailBody)) {
                    // Limit email body length to prevent token overflow
                    String truncatedBody = emailBody.length() > 500 ? emailBody.substring(0, 500) + '...' : emailBody;
                    prompt += '- Body: ' + truncatedBody + '\n';
                }

                prompt += '\n';
                emailNum++;
            }
        }

        // Add Quotes section if available
        if (quotes != null && !quotes.isEmpty()) {
            prompt += '\n# Quotes:\n';
            prompt += 'Below are the quotes related to this case:\n\n';

            Integer quoteNum = 1;
            for (SBQQ__Quote__c quote : quotes) {
                prompt += 'Quote ' + quoteNum + ' (' + quote.CreatedDate.format('MM/dd/yyyy') + ' by ' + quote.CreatedBy.Name + '):\n';
                prompt += '- Quote Name: ' + quote.Name + '\n';
                prompt += '- Status: ' + (quote.SBQQ__Status__c ?? 'Unknown') + '\n';
                prompt += '- Primary: ' + (quote.SBQQ__Primary__c ? 'Yes' : 'No') + '\n';

                if (quote.SBQQ__LineItemCount__c != null) {
                    prompt += '- Line Items: ' + quote.SBQQ__LineItemCount__c.intValue() + '\n';
                }

                if (quote.SBQQ__NetAmount__c != null) {
                    prompt += '- Net Amount: $' + quote.SBQQ__NetAmount__c.setScale(2) + '\n';
                }

                prompt += '\n';
                quoteNum++;
            }
        }

        // Add Case History section if available
        if (caseHistory != null && !caseHistory.isEmpty()) {
            prompt += '\n# Case History:\n';
            prompt += 'Below are the tracked field changes on this case:\n\n';

            Integer historyNum = 1;
            for (CaseHistory history : caseHistory) {
                prompt += 'Change ' + historyNum + ' (' + history.CreatedDate.format('MM/dd/yyyy') + ' by ' + history.CreatedBy.Name + '):\n';
                prompt += '- Field: ' + history.Field + '\n';
                prompt += '- Old Value: ' + (history.OldValue ?? '(blank)') + '\n';
                prompt += '- New Value: ' + (history.NewValue ?? '(blank)') + '\n\n';
                historyNum++;
            }
        }

        // Add Quote History section if available
        if (quoteHistory != null && !quoteHistory.isEmpty()) {
            prompt += '\n# Quote History:\n';
            prompt += 'Below are the tracked field changes on quotes related to this case:\n\n';

            Integer historyNum = 1;
            for (SBQQ__QuoteHistory__c history : quoteHistory) {
                prompt += 'Change ' + historyNum + ' (' + history.CreatedDate.format('MM/dd/yyyy') + ' by ' + history.CreatedBy.Name + '):\n';
                prompt += '- Field: ' + history.Field + '\n';
                prompt += '- Old Value: ' + (history.OldValue ?? '(blank)') + '\n';
                prompt += '- New Value: ' + (history.NewValue ?? '(blank)') + '\n\n';
                historyNum++;
            }
        }

        // Task instructions
        prompt += '# Task:\n';
        prompt += 'Based on ALL the case data above (context, comments, tasks, emails, quotes, and history), create a concise subject line that:\n';
        prompt += '- Summarizes the main issue and work performed\n';
        prompt += '- Is under 255 characters\n';
        prompt += '- Is clear and specific\n';
        prompt += '- Includes location account number when available (e.g., "HMD000257", "ESS001000")\n';
        prompt += '- Includes asset details when relevant (equipment type, material type)\n';
        prompt += '- References the case type/reason when appropriate\n';
        prompt += '- Captures the outcome or resolution if described in any of the data sources\n';
        prompt += '- Uses professional language\n';
        prompt += '- Synthesizes information from comments, tasks, emails, quotes, and history to provide comprehensive context\n\n';

        prompt += 'Examples of preferred subject formats:\n';
        prompt += '- "Missed Pickup at HMD000257 - Resolved with rescheduled service"\n';
        prompt += '- "Repair completed for ESS001000 on 34 yard cardboard compactor"\n';
        prompt += '- "Service Request at ABC123456 - Equipment maintenance completed"\n';
        prompt += '- "Delivery Issue for DEF789012 - New 6 yard recycling container delivered"\n';
        prompt += '- "Billing Inquiry for GHI345678 - Invoice corrected and reissued"\n';
        prompt += '- "Quote Request at JKL456789 - $15,000 proposal sent for equipment upgrade"\n\n';

        prompt += 'IMPORTANT: When location account number is available, use the format "[Action] at/for [Account#] - [Brief outcome]".\n';
        prompt += 'When asset details are provided, include asset description in the subject line.\n';
        prompt += 'When quotes or pricing are involved, you may reference dollar amounts or proposal status.\n';
        prompt += 'Focus on what was done and the outcome, not just the initial complaint.\n';
        prompt += 'Analyze ALL available data sources to create the most accurate and comprehensive subject line possible.\n\n';

        prompt += 'Return ONLY the subject line text with no quotes, no JSON, no additional text.';

        return prompt;
    }

    /**
     * Generate a 1-paragraph summary of case comments using AI
     * This method is called from LWC components to provide users with a quick overview
     *
     * @param caseId The Case ID to summarize comments for
     * @return String the generated summary (1 paragraph), or null if no comments exist
     * @throws GoogleGeminiException if summary generation fails
     */
    public static String generateCommentSummary(Id caseId) {
        if (caseId == null) {
            throw new GoogleGeminiException('Case ID is required for comment summary generation');
        }

        // Query case with context
        List<Case> cases = [
            SELECT Id, CaseNumber, Client__c, Location__c, Service_Date__c, AssetId,
                   Source_System__c, Status, Subject,
                   Client__r.Name,
                   Location__r.Name, Location__r.AccountNumber,
                   Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
                   Asset.Name, Asset.Acorn_SID__c, Asset.Material_Type__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            throw new GoogleGeminiException('Case not found: ' + caseId);
        }

        Case caseRecord = cases[0];

        // Query all comments for this case
        List<Comment__c> comments = [
            SELECT Id, Comment__c, CreatedDate, CreatedBy.Name
            FROM Comment__c
            WHERE Case__c = :caseId
            ORDER BY CreatedDate ASC
        ];

        if (comments.isEmpty()) {
            return null; // Caller should handle null as "no comments"
        }

        System.debug('[GoogleGeminiService] Generating summary for ' + comments.size() + ' comments');

        try {
            // Build summary prompt
            String prompt = buildCommentSummaryPrompt(comments, caseRecord);

            // Call Google Gemini with retry logic
            String response = callGeminiWithRetry(prompt);

            // Parse response (just trim, no special parsing needed)
            String summary = response.trim();

            // Validate not empty
            if (String.isBlank(summary)) {
                throw new GoogleGeminiException('AI returned empty summary');
            }

            // Log successful generation
            System.debug('[GoogleGeminiService] Generated comment summary: ' + summary.substring(0, Math.min(100, summary.length())) + '...');

            return summary;

        } catch (Exception e) {
            // Log failure
            System.debug('[GoogleGeminiService] Comment summary generation failed: ' + e.getMessage());

            // Re-throw as custom exception
            throw new GoogleGeminiException('Comment summary generation failed: ' + e.getMessage(), e);
        }
    }

    /**
     * Build prompt for comment summary generation
     */
    private static String buildCommentSummaryPrompt(
        List<Comment__c> comments,
        Case caseRecord
    ) {
        String prompt = 'You are an expert at summarizing case histories. ';
        prompt += 'Your role is to analyze case comments and create a concise 1-paragraph summary of events.\n\n';

        prompt += '# Case Context:\n';
        prompt += '- Case Number: ' + caseRecord.CaseNumber + '\n';
        prompt += '- Status: ' + caseRecord.Status + '\n';

        if (String.isNotBlank(caseRecord.Subject)) {
            prompt += '- Subject: ' + caseRecord.Subject + '\n';
        }

        if (String.isNotBlank(caseRecord.Case_Type__c)) {
            prompt += '- Type: ' + caseRecord.Case_Type__c;
            if (String.isNotBlank(caseRecord.Case_Sub_Type__c)) {
                prompt += ' - ' + caseRecord.Case_Sub_Type__c;
            }
            prompt += '\n';
        }

        prompt += '\n# Case Comments:\n';
        prompt += 'Below are the comments documenting the history of this case:\n\n';

        Integer commentNum = 1;
        for (Comment__c comment : comments) {
            if (String.isNotBlank(comment.Comment__c)) {
                prompt += 'Comment ' + commentNum + ' (' + comment.CreatedDate.format('MM/dd/yyyy HH:mm') + ' by ' + comment.CreatedBy.Name + '):\n';
                prompt += comment.Comment__c + '\n\n';
                commentNum++;
            }
        }

        // Task instructions
        prompt += '# Task:\n';
        prompt += 'Based on the comments above, create a concise 1-paragraph summary that:\n';
        prompt += '- Captures the key events and actions taken on this case\n';
        prompt += '- Is written in past tense\n';
        prompt += '- Is no more than 150 words\n';
        prompt += '- Focuses on important milestones and decisions\n';
        prompt += '- Omits minor details and routine updates\n';
        prompt += '- Flows naturally as a single narrative paragraph\n';
        prompt += '- Uses professional language\n\n';

        prompt += 'Examples of good summaries:\n';
        prompt += '- "Customer reported compactor making loud grinding noise. Technician dispatched on 01/05 and diagnosed failed motor bearing. Parts ordered same day and installed on 01/07. Unit tested successfully and returned to service."\n';
        prompt += '- "Missed pickup reported at Main Street location. Route driver confirmed missed due to blocked access. Rescheduled for next day AM service. Pickup completed successfully on 01/06 with no further issues."\n';
        prompt += '- "Billing inquiry regarding duplicate charge on December invoice. Account reviewed and confirmed system error caused double billing. Credit issued on 01/10 and customer notified via email."\n\n';

        // Add personalization for Jackie Duran
        if (isJackieDuran()) {
            prompt += '# SPECIAL INSTRUCTION FOR THIS USER:\n';
            prompt += 'The person reading this summary is Jackie Duran, a wonderful training consultant. ';
            prompt += 'Start your summary with 1-2 sentences of genuine appreciation for Jackie that references her amazing qualities. ';
            prompt += 'Here are some wonderful things about Jackie: ' + getJackiePersonalization() + '\n';
            prompt += 'After your personalized greeting, provide the case summary as instructed above.\n\n';
        }

        prompt += 'Return ONLY the summary paragraph (with Jackie\'s personalized greeting if applicable) with no additional text, no quotes, no formatting.';

        return prompt;
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
            System.debug('[GoogleGeminiService] Error getting historical patterns: ' + e.getMessage());
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
            System.debug('[GoogleGeminiService] Error getting classifications: ' + e.getMessage());
            return 'Classifications list unavailable';
        }
    }

    /**
     * Get available Record Types for Case object
     */
    private static String getAvailableRecordTypes() {
        try {
            List<RecordType> recordTypes = [
                SELECT DeveloperName, Name
                FROM RecordType
                WHERE SObjectType = 'Case'
                AND IsActive = true
                ORDER BY Name
            ];

            Set<String> recordTypeNames = new Set<String>();
            for (RecordType rt : recordTypes) {
                recordTypeNames.add(rt.DeveloperName);
            }

            return String.join(new List<String>(recordTypeNames), ', ');

        } catch (Exception e) {
            System.debug('[GoogleGeminiService] Error getting record types: ' + e.getMessage());
            return 'Master';
        }
    }

    /**
     * Convert Record Type developer name to Record Type ID
     */
    private static Id getRecordTypeId(String recordTypeDeveloperName) {
        try {
            if (String.isBlank(recordTypeDeveloperName)) {
                return null;
            }

            RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Case'
                AND DeveloperName = :recordTypeDeveloperName
                AND IsActive = true
                LIMIT 1
            ];

            return rt.Id;

        } catch (Exception e) {
            System.debug('[GoogleGeminiService] Error finding record type: ' + recordTypeDeveloperName);
            System.debug('[GoogleGeminiService] Error: ' + e.getMessage());
            return null;
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
                    API_Endpoint__c = '/v1beta/models/gemini-2.0-flash-exp:generateContent',
                    Temperature__c = 0.3,
                    Max_Tokens__c = 1500
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
            System.debug('[GoogleGeminiService] Classification Log:');
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
            System.debug('[GoogleGeminiService] Logging error: ' + e.getMessage());
        }
    }

    /**
     * Check if the current user is Jackie Duran
     * @return Boolean true if current user email matches Jackie's email
     */
    private static Boolean isJackieDuran() {
        try {
            User currentUser = [
                SELECT Email
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            return currentUser.Email == JACKIE_EMAIL;
        } catch (Exception e) {
            System.debug('[GoogleGeminiService] Error checking user: ' + e.getMessage());
            return false;
        }
    }

    /**
     * Generate a personalized message for Jackie Duran
     * Returns a delightful, randomized personal message just for Jackie
     * @return String personalized message for Jackie
     */
    private static String getJackiePersonalization() {
        // Random collection of wonderful things about Jackie
        List<String> jackieMessages = new List<String>{
            'Jackie, your effervescent spirit brightens every case you touch! Your wonderful sense of humor makes even the toughest situations manageable.',
            'Hi Jackie! Your patience and attention to detail as a training consultant truly shows in everything you do. You make everyone around you better just by being you!',
            'Jackie, you bring such joy to our team! Your love for baking with your son is as sweet as you are, and we\'re all cheering for the Packers with you (even after that tough playoff game).',
            'Hello Jackie from sunny California to cheese-loving Wisconsin! Your Green Bay roots and dedication to the Packers show your loyalty and heart. Can\'t wait to hear about your Hawaii trip!',
            'Jackie, as someone from the great Green Bay area who loves cheese (as you should!), you know quality when you see it. Your super cute personality and great friendship mean the world to us!',
            'Hi Jackie! Five years of marriage, a July 2nd birthday to celebrate, and Christmas as your favorite holiday - you know how to make every moment special. Your son is lucky to have such a wonderful baking partner!',
            'Jackie, your detail-oriented approach and patient teaching style make you an incredible training consultant. You\'re not just super cute and funny - you\'re genuinely one of the sweetest people ever!',
            'Hello Jackie! While the Packers may have had a tough playoff game, your team spirit never wavers. Just like your love for cheese and baking, you bring authentic Wisconsin warmth to everything you do!',
            'Jackie, you\'re excited for Hawaii and we\'re excited for you! Your effervescent energy, wonderful humor, and caring heart make you such a great friend. Keep being amazing!',
            'Hi Jackie from Green Bay! Your patience, sweetness, and incredible sense of humor light up our organization. You make everyone\'s world better, and that\'s pretty special!'
        };

        // Return a random message
        Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), jackieMessages.size());
        return jackieMessages[randomIndex];
    }

    /**
     * Suggest an answer for an intake question based on comprehensive case context
     * Uses AI to analyze case details and suggest the most appropriate answer
     *
     * @param caseRecord The Case record with all relationships
     * @param questionText The question being asked
     * @param questionType The type of question (picklist, text, etc.)
     * @param picklistOptions Available options for picklist questions (JSON string)
     * @param previousAnswers Previous Q&A in this session (JSON string)
     * @return String the suggested answer
     * @throws GoogleGeminiException if suggestion generation fails
     */
    public static String suggestIntakeAnswer(
        Case caseRecord,
        String questionText,
        String questionType,
        String picklistOptions,
        String previousAnswers
    ) {
        if (caseRecord == null || String.isBlank(questionText)) {
            throw new GoogleGeminiException('Case record and question text are required');
        }

        try {
            // Build comprehensive prompt with all available context
            String prompt = buildAnswerSuggestionPrompt(
                caseRecord,
                questionText,
                questionType,
                picklistOptions,
                previousAnswers
            );

            // Call Google Gemini with retry logic
            String response = callGeminiWithRetry(prompt);

            // Parse and clean response
            String suggestion = response.trim();

            // Log successful generation
            System.debug('[GoogleGeminiService] Generated answer suggestion: ' + suggestion);

            return suggestion;

        } catch (Exception e) {
            System.debug('[GoogleGeminiService] Answer suggestion failed: ' + e.getMessage());
            throw new GoogleGeminiException('Answer suggestion failed: ' + e.getMessage(), e);
        }
    }

    /**
     * Build comprehensive prompt for answer suggestion
     */
    private static String buildAnswerSuggestionPrompt(
        Case caseRecord,
        String questionText,
        String questionType,
        String picklistOptions,
        String previousAnswers
    ) {
        String prompt = 'You are an intelligent assistant helping a customer service representative complete an intake form. ';
        prompt += 'Based on the comprehensive case information provided, suggest the most appropriate answer to the current question.\n\n';

        // Case Context
        prompt += '# Case Information:\n';
        prompt += '- Case Number: ' + caseRecord.CaseNumber + '\n';

        if (String.isNotBlank(caseRecord.Description)) {
            prompt += '- Description: ' + caseRecord.Description + '\n';
        }

        if (String.isNotBlank(caseRecord.Subject)) {
            prompt += '- Subject: ' + caseRecord.Subject + '\n';
        }

        prompt += '- Status: ' + caseRecord.Status + '\n';

        if (String.isNotBlank(caseRecord.Priority)) {
            prompt += '- Priority: ' + caseRecord.Priority + '\n';
        }

        if (String.isNotBlank(caseRecord.Source_System__c)) {
            prompt += '- Source: ' + caseRecord.Source_System__c + '\n';
        }

        // Classification (if available)
        if (String.isNotBlank(caseRecord.Case_Type__c)) {
            prompt += '- Case Type: ' + caseRecord.Case_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Sub_Type__c)) {
            prompt += '- Case Sub-Type: ' + caseRecord.Case_Sub_Type__c + '\n';
        }
        if (String.isNotBlank(caseRecord.Case_Reason__c)) {
            prompt += '- Case Reason: ' + caseRecord.Case_Reason__c + '\n';
        }

        // Client Information
        if (caseRecord.Client__r != null) {
            prompt += '\n# Client Information:\n';
            prompt += '- Client: ' + caseRecord.Client__r.Name + '\n';
            if (String.isNotBlank(caseRecord.Client__r.Type)) {
                prompt += '- Type: ' + caseRecord.Client__r.Type + '\n';
            }
        }

        // Contact Information
        if (caseRecord.ContactId != null) {
            prompt += '\n# Contact Information:\n';
            prompt += '- Contact: ' + (caseRecord.Contact?.Name ?? 'Unknown') + '\n';
            if (String.isNotBlank(caseRecord.Contact_Title__c)) {
                prompt += '- Title: ' + caseRecord.Contact_Title__c + '\n';
            }
        }

        // Location Information
        if (caseRecord.Location__r != null) {
            prompt += '\n# Location Information:\n';
            prompt += '- Location: ' + caseRecord.Location__r.Name + '\n';

            if (String.isNotBlank(caseRecord.Location__r.Location_Code__c)) {
                prompt += '- Location Code: ' + caseRecord.Location__r.Location_Code__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Location__r.AccountNumber)) {
                prompt += '- Account Number: ' + caseRecord.Location__r.AccountNumber + '\n';
            }

            if (String.isNotBlank(caseRecord.Location__r.ShippingStreet)) {
                prompt += '- Address: ' + caseRecord.Location__r.ShippingStreet;
                if (String.isNotBlank(caseRecord.Location__r.ShippingCity)) {
                    prompt += ', ' + caseRecord.Location__r.ShippingCity;
                }
                if (String.isNotBlank(caseRecord.Location__r.ShippingState)) {
                    prompt += ', ' + caseRecord.Location__r.ShippingState;
                }
                if (String.isNotBlank(caseRecord.Location__r.ShippingPostalCode)) {
                    prompt += ' ' + caseRecord.Location__r.ShippingPostalCode;
                }
                prompt += '\n';
            }

            if (String.isNotBlank(caseRecord.Location__r.Primary_Segment__c)) {
                prompt += '- Segment: ' + caseRecord.Location__r.Primary_Segment__c + '\n';
            }

            if (caseRecord.Location__r.Is_Portal_Customer__c != null) {
                prompt += '- Portal Customer: ' + (caseRecord.Location__r.Is_Portal_Customer__c ? 'Yes' : 'No') + '\n';
            }
        }

        // Asset Information
        if (caseRecord.AssetId != null && caseRecord.Asset != null) {
            prompt += '\n# Asset Information:\n';
            prompt += '- Asset: ' + caseRecord.Asset.Name + '\n';

            if (String.isNotBlank(caseRecord.Asset.Material_Type__c)) {
                prompt += '- Material Type: ' + caseRecord.Asset.Material_Type__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset.Acorn_SID__c)) {
                prompt += '- SID: ' + caseRecord.Asset.Acorn_SID__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset.ProductFamily)) {
                prompt += '- Product Family: ' + caseRecord.Asset.ProductFamily + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset.Duration__c)) {
                prompt += '- Duration: ' + caseRecord.Asset.Duration__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset.Occurrence_Type__c)) {
                prompt += '- Occurrence: ' + caseRecord.Asset.Occurrence_Type__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset.Schedule__c)) {
                prompt += '- Schedule: ' + caseRecord.Asset.Schedule__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset.Equipment_Owner__c)) {
                prompt += '- Equipment Owner: ' + caseRecord.Asset.Equipment_Owner__c + '\n';
            }

            if (String.isNotBlank(caseRecord.Asset.Category__c)) {
                prompt += '- Category: ' + caseRecord.Asset.Category__c + '\n';
            }

            if (caseRecord.Asset.Supplier__r != null && String.isNotBlank(caseRecord.Asset.Supplier__r.Name)) {
                prompt += '- Vendor: ' + caseRecord.Asset.Supplier__r.Name + '\n';
            }
        }

        // Service Date
        if (caseRecord.Service_Date__c != null) {
            prompt += '\n# Service Date:\n';
            prompt += '- ' + caseRecord.Service_Date__c.format() + '\n';
        }

        // Previous Answers in Session
        if (String.isNotBlank(previousAnswers) && previousAnswers != '[]') {
            prompt += '\n# Previous Answers in this Intake Session:\n';
            prompt += previousAnswers + '\n';
        }

        // Current Question
        prompt += '\n# Current Question:\n';
        prompt += 'Question: ' + questionText + '\n';
        prompt += 'Question Type: ' + questionType + '\n';

        // Picklist Options
        if (String.isNotBlank(picklistOptions) && picklistOptions != '[]') {
            prompt += '\n# Available Answer Options:\n';
            prompt += picklistOptions + '\n';
        }

        // Instructions
        prompt += '\n# Instructions:\n';
        prompt += 'Based on all the information above, suggest the most appropriate answer to the current question.\n\n';

        if (questionType == 'picklist') {
            prompt += '- You MUST choose one of the available options listed above\n';
            prompt += '- Return ONLY the exact text of the option you choose\n';
            prompt += '- Do not add quotes, explanations, or any additional text\n';
            prompt += '- If no option clearly fits, choose the closest match or return "Unknown" if available\n\n';
        } else {
            prompt += '- Provide a concise, specific answer based on the available information\n';
            prompt += '- Keep your answer brief and to the point (1-2 sentences maximum)\n';
            prompt += '- If information is not available, return "Information not available"\n';
            prompt += '- Return ONLY the answer text with no quotes, explanations, or additional commentary\n\n';
        }

        prompt += 'IMPORTANT: Return ONLY the suggested answer. No explanations, no JSON, no additional text.';

        return prompt;
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
        @AuraEnabled public String recordType { get; set; }
        @AuraEnabled public String locationName { get; set; }
        @AuraEnabled public String assetDescription { get; set; }
        @AuraEnabled public String serviceDateString { get; set; }
        @AuraEnabled public Decimal confidence { get; set; }
        @AuraEnabled public String reasoning { get; set; }
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String errorMessage { get; set; }

        public ClassificationResult() {
            this.success = true;
        }
    }

    /**
     * Custom exception for Google Gemini errors
     */
    public class GoogleGeminiException extends Exception {}
}
