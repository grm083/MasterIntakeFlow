/*************************************************************
@Name: ProjectCodeTrigger
@Author: Anupreethy
@CreateDate: 03/07/2019
@Description: Trigger to Perform operations on Project_Code__c
**************************************************************/
trigger ProjectCodeTrigger on Project_Code__c (before insert,after update) {
    //Trigger ByPass Logic
        If(!RecurrsiveTriggerHandler.bypassValidation){
            RecurrsiveTriggerHandler.getByPassValidation();
        }
    // Invokes before Insert
     If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsInsert){
            ProjectCodeTriggerHandler.onBeforeInsert(Trigger.new);   
        }
    
     //Invokes after Update
     If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsUpdate){
            ProjectCodeTriggerHandler.onAfterUpdate(Trigger.new,Trigger.oldMap);   
        }  
}