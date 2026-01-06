/*************************************************************
@Name: ContactTrigger
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Trigger to Perform operations on Contact
**************************************************************/
trigger ContactTrigger on Contact (before update,before delete, before insert, after delete, after update) {
        //Trigger ByPass Logic
        If(!RecurrsiveTriggerHandler.bypassValidation){
            RecurrsiveTriggerHandler.getByPassValidation();
        }
        //Invokes Before Update
        If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsUpdate){
            ContactTriggerHandler.onbeforeUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);   
        }
        //Invokes After Update
        If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsDelete){
            ContactTriggerHandler.onbeforeDelete(Trigger.old);   
        }
        //Invokes After Delete
        If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsDelete){
            ContactTriggerHandler.onAfterDelete(Trigger.old);   
        }
        //Invokes After Update
        If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsUpdate){
            ContactTriggerHandler.onAfterUpdate(Trigger.oldMap,Trigger.newMap);   
        }	
		//Invokes Before Insert
        If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsInsert){
            ContactTriggerHandler.onbeforeInsert(Trigger.new,Trigger.newMap);   
        }	
}