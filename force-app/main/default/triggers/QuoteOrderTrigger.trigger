trigger QuoteOrderTrigger on Quote_Order__c (after insert, after update) {
    
    If(Trigger.IsAfter && Trigger.IsInsert){
        system.debug('calling onAfterInsert');
        QuoteOrderTriggerHandler.onAfterInsert(Trigger.new);
    }
    
    If(Trigger.IsAfter && Trigger.IsUpdate){
        system.debug('calling onAfterUpdate');
        QuoteOrderTriggerHandler.onAfterUpdate(Trigger.new,Trigger.OldMap);
    }
    
}