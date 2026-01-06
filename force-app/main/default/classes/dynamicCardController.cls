public with sharing class dynamicCardController {
	@AuraEnabled
    public static Case getCaseDetails(Id recordId) {
        Case c = [SELECT Id, Location__c, Client__c
                 FROM Case
                 WHERE Id =: recordId];
        return c;
    }
}