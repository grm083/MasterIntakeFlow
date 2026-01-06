/*************************************************************
@Name: QuoteLineTrigger
@Author: Arvind Kumar
@CreateDate: 03/June/2021
@Description: Trigger to Perform operations on QuoteLine
**************************************************************/
trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before insert,before update, before delete,after insert,after update) {
	
    
	//added for SDT-31118
    if(RecurrsiveTriggerHandler.isSkipQuoteLineTrigger) return;
	
	
    //Invokes Before Delete
    If(Trigger.IsBefore && Trigger.IsDelete){
        system.debug('calling onBeforeDelete');
        QuoteLineTriggerHandler.onBeforeDelete(Trigger.Old);
        QuoteLineTriggerHandler.onBeforeDelete(Trigger.oldMap);//SDT-30735
    }
   
        // Invoke Before Insert
    If(Trigger.IsBefore && Trigger.IsInsert){
        system.debug('calling onBeforeDelete');
        QuoteLineTriggerHandler.onBeforeInsert(Trigger.new);
    }
    
    // Invoke Before Update
    //Commenting this as part of SDT-28045 and SDT-25550 since the below is not being used anywhere on TriggerHandler
    /*If(Trigger.IsBefore && Trigger.IsUpdate){
        system.debug('calling onBeforeUpdate');
		QuoteLineTriggerHandler.onBeforeupdate(Trigger.new,null,null);
	}*/
   
    If(Trigger.IsAfter && Trigger.IsInsert){
        system.debug('calling IsAfter');
        QuoteLineTriggerHandler.onAfterInsert(Trigger.new);
    }
    

   // Invoke After UPdate
   //Removed !RecurrsiveTriggerHandler.isRecurrsiveQuoteLine for story SDT-28018
   If(Trigger.IsAfter && Trigger.IsUpdate){
    system.debug('calling onAfterUpdate');
    QuoteLineTriggerHandler.onAfterUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
}
    
    If(Trigger.IsBefore && Trigger.IsUpdate){
        QuoteLineTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
    }
    
}