/**
* @author Accenture
* @date 4/07/2019
* @description : Wrapper class for ETAWindowController clas
**/
public with sharing class StatusWrapper {   
    @AuraEnabled public String serviceDate;
    @AuraEnabled public String assetName;
    @AuraEnabled public String etaWindow;
    @AuraEnabled public String truckPosition;
    @AuraEnabled public String customerPosition;
    @AuraEnabled public String serviceStatus;
    @AuraEnabled public String exceptionReason;
    @AuraEnabled public String serviceStatusDate;
    @AuraEnabled public String rescheduleDate;
    @AuraEnabled public String woNumber;
    @AuraEnabled public String materialTypeName;
    @AuraEnabled public String occurrenceType;
    @AuraEnabled public String imageUrl;
    @AuraEnabled public Integer serviceOfferingDefinitionId;
    @AuraEnabled public String woDescription;
    @AuraEnabled public String vendorCode;
    @AuraEnabled public String vendorName;
    @AuraEnabled public String scheduleType;
    @AuraEnabled public String masUniqueId;
    @AuraEnabled public String vendorAccountNumber;
    @AuraEnabled public Boolean isCurrentService = false;
}