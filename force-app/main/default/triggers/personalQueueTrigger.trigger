/*************************************************************
@Name: personalQueueTrigger
@Author: WM
@CreateDate: 10/07/2023
@Description: Trigger to Perform operations on Personal Queue Info
**************************************************************/
trigger personalQueueTrigger on Personal_Queue_Info__c (before insert,before update) {
    
    //Trigger ByPass Logic
    If(!RecurrsiveTriggerHandler.bypassValidation){
        RecurrsiveTriggerHandler.getByPassValidation();
    }
    //Trigger Framework Change	
        new PersonalQueueTriggerHandler().run();
}