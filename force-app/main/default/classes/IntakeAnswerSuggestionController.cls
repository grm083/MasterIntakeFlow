/**
 * Controller for AI-powered intake answer suggestions
 * Provides intelligent answer suggestions based on case context
 */
public with sharing class IntakeAnswerSuggestionController {

    /**
     * Suggest an answer for an intake question based on comprehensive case context
     * @param caseId The Case record ID
     * @param questionText The question being asked
     * @param questionType The type of question (picklist, text, etc.)
     * @param picklistOptions Available options for picklist questions
     * @param previousAnswers JSON string of previous Q&A in this session
     * @return AnswerSuggestion wrapper with suggested answer and confidence
     */
    @AuraEnabled
    public static AnswerSuggestion suggestAnswer(
        Id caseId,
        String questionText,
        String questionType,
        String picklistOptions,
        String previousAnswers
    ) {
        try {
            // Query comprehensive case details
            Case caseRecord = [
                SELECT Id, CaseNumber, Subject, Description, Status, Priority,
                       Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
                       Source_System__c, Service_Date__c,
                       // Client
                       Client__c, Client__r.Name, Client__r.Type,
                       // Contact
                       ContactId, Contact.Name, Contact_Title__c,
                       // Location
                       Location__c,
                       Location__r.Name,
                       Location__r.Location_Code__c,
                       Location__r.AccountNumber,
                       Location__r.ShippingStreet,
                       Location__r.ShippingCity,
                       Location__r.ShippingState,
                       Location__r.ShippingPostalCode,
                       Location__r.Primary_Segment__c,
                       Location__r.Customer_Location_Code__c,
                       Location__r.Is_Portal_Customer__c,
                       // Asset
                       AssetId,
                       Asset.Name,
                       Asset.Material_Type__c,
                       Asset.Acorn_SID__c,
                       Asset.Duration__c,
                       Asset.Occurrence_Type__c,
                       Asset.Schedule__c,
                       Asset.Equipment_Owner__c,
                       Asset.Category__c,
                       Asset.ProductFamily,
                       Asset.Supplier__r.Name
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
            ];

            // Call Google Gemini AI to generate suggestion
            String suggestion = GoogleGeminiService.suggestIntakeAnswer(
                caseRecord,
                questionText,
                questionType,
                picklistOptions,
                previousAnswers
            );

            AnswerSuggestion result = new AnswerSuggestion();
            result.success = true;
            result.suggestedAnswer = suggestion;
            result.confidence = 'medium'; // Could be enhanced to parse confidence from AI
            result.reasoning = 'Based on case context and available information';

            return result;

        } catch (Exception e) {
            System.debug('Error generating answer suggestion: ' + e.getMessage());

            AnswerSuggestion result = new AnswerSuggestion();
            result.success = false;
            result.error = 'Unable to generate suggestion: ' + e.getMessage();
            return result;
        }
    }

    /**
     * Wrapper class for answer suggestion response
     */
    public class AnswerSuggestion {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String suggestedAnswer { get; set; }
        @AuraEnabled public String confidence { get; set; }
        @AuraEnabled public String reasoning { get; set; }
        @AuraEnabled public String error { get; set; }

        public AnswerSuggestion() {
            this.success = false;
        }
    }
}
