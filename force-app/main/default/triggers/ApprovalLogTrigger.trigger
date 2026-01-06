trigger ApprovalLogTrigger on Approval_Log__c (after insert,after update) {
    
    //If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert && !RecurrsiveTriggerHandler.isSkipApprovalLogTrigger){
    if(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert && 
       (TriggerDispatcher.skipTriggerExecutionMap==null || TriggerDispatcher.skipTriggerExecutionMap.get(Approval_Log__c.sobjectType.getDescribe().getName())==null
       || !TriggerDispatcher.skipTriggerExecutionMap.get(Approval_Log__c.sobjectType.getDescribe().getName()))){
        CreateCaseHistory.createHistoryRecordOnRecordCreate(Trigger.newMap);
        //RecurrsiveTriggerHandler.isSkipApprovalLogTrigger = true;
        TriggerDispatcher.skipTriggerExecutionMap.put(Approval_Log__c.sobjectType.getDescribe().getName(),true);
    }
    //If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsUpdate && !RecurrsiveTriggerHandler.isSkipApprovalLogTrigger){
    if(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsUpdate && (TriggerDispatcher.skipTriggerExecutionMap==null || TriggerDispatcher.skipTriggerExecutionMap.get(Approval_Log__c.sobjectType.getDescribe().getName())==null
       || !TriggerDispatcher.skipTriggerExecutionMap.get(Approval_Log__c.sobjectType.getDescribe().getName()))){
        CreateCaseHistory.createHistoryRecord(Trigger.newMap, Trigger.oldMap);
        //RecurrsiveTriggerHandler.isSkipApprovalLogTrigger = true;
        TriggerDispatcher.skipTriggerExecutionMap.put(Approval_Log__c.sobjectType.getDescribe().getName(),true);
    }
}