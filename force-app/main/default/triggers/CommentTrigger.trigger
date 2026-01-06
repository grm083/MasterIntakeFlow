trigger CommentTrigger on Comment__c (after insert) {
	If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert && !RecurrsiveTriggerHandler.isSkipCommentTrigger)
    {
        CreateCaseHistory.createHistoryRecordOnRecordCreate(Trigger.newMap);
        RecurrsiveTriggerHandler.isSkipCommentTrigger = true;
    }
}