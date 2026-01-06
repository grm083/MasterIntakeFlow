trigger CaseHistoryTrackerTrigger on Case_History_Tracker__c (after insert) {
    
    if(Trigger.IsInsert && Trigger.isAfter && (TriggerDispatcher.skipTriggerExecutionMap==null || TriggerDispatcher.skipTriggerExecutionMap.get(Case_History_Tracker__c.sobjectType.getDescribe().getName())==null
       		|| !TriggerDispatcher.skipTriggerExecutionMap.get(Case_History_Tracker__c.sobjectType.getDescribe().getName()))){
        CaseHistoryTrackerTriggerHandler.onAfterInsert(Trigger.New);
        //RecurrsiveTriggerHandler.isSkipCaseHistoryTrackerTrigger = true;
        TriggerDispatcher.skipTriggerExecutionMap.put(Case_History_Tracker__c.sobjectType.getDescribe().getName(),true);
    }
}