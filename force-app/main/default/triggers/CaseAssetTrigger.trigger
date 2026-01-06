trigger CaseAssetTrigger on SBS_Case_Asset__c (before insert, before update, after insert) {
    //Trigger ByPass Logic
    If(!RecurrsiveTriggerHandler.bypassTrigger){
        RecurrsiveTriggerHandler.getTriggerByPass();
    }
    if(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.isAfter && Trigger.isInsert){
        CaseAssetTriggerHandler.onAfterInsert(Trigger.newMap, Trigger.OldMap);
        //RecurrsiveTriggerHandler.isSkipcaseTrigger = true;
        System.debug('Recursive Trigger: '+RecurrsiveTriggerHandler.isSkipcaseTrigger);
    }
    if(Trigger.IsBefore && Trigger.isInsert){
        CaseAssetTriggerHandler.onBeforeInsert(Trigger.new);
    }
    if(Trigger.IsBefore && Trigger.IsUpdate){
        CaseAssetTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
}