public with sharing class LocationContainerController  {
    @AuraEnabled
    public static string getIsWorkOrderCreated(string caseRecId) {
        string statusData;
        List<Case> caseData= [SELECT Id, isWorkOrderCreated__c,status from Case where id=:caseRecId];
         for(Case c : caseData){
           statusData = c.status;                                    
         }
        //system.debug('>>>'+createdWorkOrder);
        return statusData ;
    }
}