/*************************************************************
@Name: BusinessRuleTrigger
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Trigger to Perform operations on Business Rule
**************************************************************/
trigger BusinessRuleTrigger on Business_Rule__c (before insert,before update, after update) {
    //Trigger ByPass Logic
    If(!RecurrsiveTriggerHandler.bypassTrigger){
        RecurrsiveTriggerHandler.getTriggerByPass();
    }
    //Invokes Before Insert
    If(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.IsBefore && Trigger.IsInsert){
        BusinessRuleTriggerHandler.onbeforeInsert(Trigger.New);   
    }
    
    //Invokes Before Update
    If(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.IsBefore && Trigger.IsUpdate){
        BusinessRuleTriggerHandler.onbeforeUpdate(Trigger.New);   
    }
    //Invokes after Update
    If(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.IsAfter && Trigger.IsUpdate){
        BusinessRuleTriggerHandler.onAfterUpdate(Trigger.New);   
    }
}
