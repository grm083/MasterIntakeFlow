trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert && !RecurrsiveTriggerHandler.isSkipContentDocumentLinkTrigger)
    {
        ContentDocumentLinkTriggerHandler.onAfterInsert(Trigger.newMap);
        RecurrsiveTriggerHandler.isSkipContentDocumentLinkTrigger = true;        
    }
}