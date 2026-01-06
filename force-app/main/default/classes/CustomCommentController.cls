public class CustomCommentController {
	
    @AuraEnabled
    //Changes related to SDT-18095 - changed return type
    public static Case getCaseId(Id recordId) {
        String caseId;
        //Changes related to SDT-18095
        Case caseRec = new Case();
        String sObjectType = recordId.getsobjectType().getDescribe().getName();
        switch on sObjectType {
            when 'Case' {
                //Changes related to SDT-18095 -- caseId = recordId;
                caseRec = [SELECT Id,Tracking_Number__c,Case_Record_Type__c FROM Case where Id =:recordId];
            }
            when 'SBQQ__Quote__c' {
                SBQQ__Quote__c q = [SELECT Id, SBQQ__Opportunity2__r.Case__c
                                   FROM SBQQ__Quote__c
                                   WHERE Id =: recordId
                                   LIMIT 1];
                //Changes related to SDT-18095 -- caseId = q.SBQQ__Opportunity2__r.Case__c;
                caseRec.Id = q.SBQQ__Opportunity2__r.Case__c;
            }
            when else {
                //Changes related to SDT-18095
                caseRec.Id = recordId;
            }
        }        
        //Changes related to SDT-18095        
        return caseRec;
    }
}