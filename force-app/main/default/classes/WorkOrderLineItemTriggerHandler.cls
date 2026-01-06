public with sharing class WorkOrderLineItemTriggerHandler {
    Public static Boolean bypassValidation = [SELECT Id, Bypass_Validation__c FROM User WHERE Id = :UserInfo.getUserId()].Bypass_Validation__c;
    public static void onAfterUpdate(Map<Id,WorkOrderLineItem> oldMap, Map<Id,WorkOrderLineItem> newMap) {
        if(!bypassValidation){
            WorkOrderLineItemTriggerHelper.updateAcornWOLineItem(oldMap,newMap);
        }
    }
    public static void onBeforeUpdate(Map<Id,WorkOrderLineItem> oldMap, Map<Id,WorkOrderLineItem> newMap) {
        if(!RecurrsiveTriggerHandler.bypassValidation && !bypassValidation){
            WorkOrderLineItemTriggerHelper.validateQuantityOverride(oldMap,newMap);
        }
    }
}