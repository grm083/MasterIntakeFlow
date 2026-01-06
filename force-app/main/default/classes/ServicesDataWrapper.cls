public with sharing class ServicesDataWrapper {
    @AuraEnabled public String AssetId;
    @AuraEnabled public Boolean hideETA;
    @AuraEnabled public String frequency;
    @AuraEnabled public Date caseServiceDate;
    @AuraEnabled public String assetName;
    @AuraEnabled public String serviceStatus;
    @AuraEnabled public String exceptionReason;
    @AuraEnabled public String material;
    @AuraEnabled public String occurrence;
    @AuraEnabled public String masNo;
    
    public ServicesDataWrapper(){
        
    }
}