trigger CaseCommentTrigger on CaseComment (after insert) {
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert && !RecurrsiveTriggerHandler.isSkipCaseCommentTrigger)
    {
        CreateCaseHistory.createHistoryRecordOnRecordCreate(Trigger.newMap);
        RecurrsiveTriggerHandler.isSkipCaseCommentTrigger = true;
    }
}