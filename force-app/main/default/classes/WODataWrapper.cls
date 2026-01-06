public with sharing class WODataWrapper {
    @AuraEnabled public Boolean hideETA;
    @AuraEnabled public String workOrderId;
    @AuraEnabled public Date serviceDate;
    @AuraEnabled public String assetName;
    @AuraEnabled public String serviceStatus;
    @AuraEnabled public String exceptionReason;
    @AuraEnabled public String woNumber;
    @AuraEnabled public String material;
    @AuraEnabled public String occurrence;
    @AuraEnabled public String masNo;
    
    public WODataWrapper(){
        
    }
}