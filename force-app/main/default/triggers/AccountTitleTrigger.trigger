/*************************************************************
@Name: AccountTitleTrigger
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Trigger to Perform operations on AccountTitle
**************************************************************/
trigger AccountTitleTrigger on Account_Title__c (before update,before delete) {
        //Trigger ByPass Logic
        If(!RecurrsiveTriggerHandler.bypassValidation){
            RecurrsiveTriggerHandler.getByPassValidation();
        }
		//Trigger Framework Change
        if(!RecurrsiveTriggerHandler.bypassValidation){	
			new AccountTitleTriggerHandler().run();
		}	
}