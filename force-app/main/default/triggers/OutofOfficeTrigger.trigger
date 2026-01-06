trigger OutofOfficeTrigger on Out_of_Office__c (before Insert,before update) {
    
    //TriggerDispatcher.dispatch(Out_of_Office__c.sobjectType);
    //Trigger ByPass Logic
    If(!RecurrsiveTriggerHandler.bypassTrigger && !RecurrsiveTriggerHandler.isSkipAssetTrigger){
        RecurrsiveTriggerHandler.getTriggerByPass();
    }
    If(!RecurrsiveTriggerHandler.bypassValidation){
        RecurrsiveTriggerHandler.getByPassValidation();
    }
    //Invokes Before Insert or Update
    If(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.IsBefore && Trigger.IsInsert){
        OutofOfficeTriggerHandler.onBeforeInsert(Trigger.new);   
    }
    If(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.IsBefore && Trigger.IsUpdate){
        OutofOfficeTriggerHandler.onBeforeUpdate(Trigger.new);   
    }
    
}