/*************************************************************
@Name: ContactTrigger
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Trigger to Perform operations on User
**************************************************************/
trigger UserTrigger on User (before update) {
        //Trigger ByPass Logic
        If(!RecurrsiveTriggerHandler.bypassValidation){
            RecurrsiveTriggerHandler.getByPassValidation();
        }
        //Invokes Before Update
        If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsUpdate){
            UserTriggerHandler.onbeforeUpdate(Trigger.newMap,Trigger.oldMap);   
        }
}