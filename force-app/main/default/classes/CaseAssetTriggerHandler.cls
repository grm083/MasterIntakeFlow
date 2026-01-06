public without sharing class CaseAssetTriggerHandler {

public static void onAfterInsert(Map<Id,SBS_Case_Asset__c> newCaseAssetMap, Map<Id,SBS_Case_Asset__c> oldCaseAssetMap){
        try{
            CaseAssetTriggerHelper.updateCase(newCaseAssetMap, oldCaseAssetMap);
        }
        catch(Exception e){
            System.debug('Exception::::'+e.getStackTraceString());
        }
    }
    public static void onBeforeInsert(List<SBS_Case_Asset__c> caLst) {
        CaseAssetTriggerHelper.populateQuantityOverride(caLst);
    }
    public static void onBeforeUpdate(Map<Id,SBS_Case_Asset__c> oldMap, Map<Id,SBS_Case_Asset__c> newMap) {
        if(!RecurrsiveTriggerHandler.bypassValidation){
            CaseAssetTriggerHelper.validateQuantityOverride(oldMap,newMap);
        }
    }
}