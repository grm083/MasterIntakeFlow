/**
 * @description Helper class to generate Case Subject lines from Comments
 *              when a Case is closed without a Subject
 *
 * @author Claude Code
 * @date 2026-01-11
 */
public with sharing class CaseSubjectGenerator {

    /**
     * Process cases that have been closed without a subject
     * This method is called from CaseTriggerHandler.afterUpdate
     *
     * CRITICAL: This method must NEVER throw exceptions that could block case closure.
     * All errors are caught and logged, allowing the case update to proceed.
     *
     * @param newCaseMap Map of new Case records by ID
     * @param oldCaseMap Map of old Case records by ID
     */
    public static void processClosedCasesWithoutSubject(
        Map<Id, Case> newCaseMap,
        Map<Id, Case> oldCaseMap
    ) {
        try {
            // Find cases that meet the criteria
            List<Id> eligibleCaseIds = new List<Id>();

            for (Id caseId : newCaseMap.keySet()) {
                Case newCase = newCaseMap.get(caseId);
                Case oldCase = oldCaseMap.get(caseId);

                // Check if case meets all criteria
                if (shouldGenerateSubjectFromComments(newCase, oldCase)) {
                    eligibleCaseIds.add(caseId);
                }
            }

            // If no eligible cases, return early
            if (eligibleCaseIds.isEmpty()) {
                System.debug('[CaseSubjectGenerator] No eligible cases found');
                return;
            }

            System.debug('[CaseSubjectGenerator] Found ' + eligibleCaseIds.size() + ' eligible cases');

            // Process eligible cases asynchronously to avoid hitting governor limits
            generateSubjectsAsync(eligibleCaseIds);

        } catch (Exception e) {
            // CRITICAL: Catch all exceptions to prevent blocking case closure
            // Log the error but do not re-throw
            System.debug('[CaseSubjectGenerator] ERROR in processClosedCasesWithoutSubject: ' + e.getMessage());
            System.debug('[CaseSubjectGenerator] Stack trace: ' + e.getStackTraceString());
            // Subject generation is non-critical - allow case update to proceed
        }
    }

    /**
     * Check if a case meets the criteria for subject generation from comments
     *
     * Criteria:
     * - Source_System__c == 'Salesforce'
     * - Subject is null or blank
     * - Status changed from something else to 'Closed'
     *
     * @param newCase The new version of the Case
     * @param oldCase The old version of the Case
     * @return Boolean true if case should have subject generated
     */
    private static Boolean shouldGenerateSubjectFromComments(Case newCase, Case oldCase) {
        // Check Source_System__c is Salesforce
        if (newCase.Source_System__c != 'Salesforce') {
            return false;
        }

        // Check Subject is blank
        if (String.isNotBlank(newCase.Subject)) {
            return false;
        }

        // Check Status changed to Closed
        if (newCase.Status != 'Closed') {
            return false;
        }

        // Check old Status was not Closed (i.e., status changed TO Closed)
        if (oldCase.Status == 'Closed') {
            return false;
        }

        return true;
    }

    /**
     * Asynchronously generate subjects for eligible cases
     * Uses @future to avoid governor limits and allow HTTP callouts
     *
     * @param caseIds List of Case IDs to process
     */
    @future(callout=true)
    public static void generateSubjectsAsync(List<Id> caseIds) {
        try {
            System.debug('[CaseSubjectGenerator] Processing ' + caseIds.size() + ' cases asynchronously');

            // Query cases with all necessary fields
            List<Case> cases = [
                SELECT Id, CaseNumber, Client__c, Location__c, Service_Date__c, AssetId,
                       Source_System__c, Status, Subject,
                       Client__r.Name,
                       Location__r.Name, Location__r.AccountNumber,
                       Case_Type__c, Case_Sub_Type__c, Case_Reason__c,
                       Asset.Name, Asset.Acorn_SID__c, Asset.Material_Type__c
                FROM Case
                WHERE Id IN :caseIds
                AND Source_System__c = 'Salesforce'
                AND Status = 'Closed'
                AND (Subject = null OR Subject = '')
            ];

            if (cases.isEmpty()) {
                System.debug('[CaseSubjectGenerator] No cases found matching criteria');
                return;
            }

            // Process each case
            List<Case> casesToUpdate = new List<Case>();

            for (Case c : cases) {
                try {
                    String generatedSubject = generateSubjectFromComments(c);

                    if (String.isNotBlank(generatedSubject)) {
                        c.Subject = generatedSubject;
                        casesToUpdate.add(c);
                        System.debug('[CaseSubjectGenerator] Generated subject for Case ' + c.CaseNumber + ': ' + generatedSubject);
                    }

                } catch (Exception e) {
                    System.debug('[CaseSubjectGenerator] Error processing Case ' + c.CaseNumber + ': ' + e.getMessage());
                    // Continue processing other cases
                }
            }

            // Update cases with generated subjects
            if (!casesToUpdate.isEmpty()) {
                update casesToUpdate;
                System.debug('[CaseSubjectGenerator] Updated ' + casesToUpdate.size() + ' cases with generated subjects');
            }

        } catch (Exception e) {
            System.debug('[CaseSubjectGenerator] Error in generateSubjectsAsync: ' + e.getMessage());
            System.debug('[CaseSubjectGenerator] Stack trace: ' + e.getStackTraceString());
        }
    }

    /**
     * Generate subject line from case comments using AI
     *
     * @param caseRecord The Case record to generate subject for
     * @return String the generated subject line
     */
    private static String generateSubjectFromComments(Case caseRecord) {
        // Query all comments for this case
        List<Comment__c> comments = [
            SELECT Id, Comment__c, CreatedDate, CreatedBy.Name
            FROM Comment__c
            WHERE Case__c = :caseRecord.Id
            ORDER BY CreatedDate ASC
        ];

        if (comments.isEmpty()) {
            System.debug('[CaseSubjectGenerator] No comments found for Case ' + caseRecord.CaseNumber);
            return null;
        }

        System.debug('[CaseSubjectGenerator] Found ' + comments.size() + ' comments for Case ' + caseRecord.CaseNumber);

        // Call Google Gemini AI to generate subject from comments
        String generatedSubject = GoogleGeminiService.generateSubjectFromComments(comments, caseRecord);

        return generatedSubject;
    }
}
