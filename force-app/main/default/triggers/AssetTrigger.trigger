/*************************************************************
@Name: AssetTrigger
@Author: Satyabrata Nag
@CreateDate: 26/07/2019
@Description: Trigger to Perform operations on Asset
**************************************************************/
trigger AssetTrigger on Asset (before insert,before update) {
	
    	if(System.isFuture()) return;
        //Trigger ByPass Logic
        If(!RecurrsiveTriggerHandler.bypassTrigger && !RecurrsiveTriggerHandler.isSkipAssetTrigger){
            RecurrsiveTriggerHandler.getTriggerByPass();
        }
		If(!RecurrsiveTriggerHandler.bypassValidation){
            RecurrsiveTriggerHandler.getByPassValidation();
        }
        //Invokes Before Insert or Update
        If(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.IsBefore && Trigger.IsInsert){
            AssetTriggerHandler.onBeforeInsert(Trigger.new,Trigger.oldMap);   
        }
    	If(!RecurrsiveTriggerHandler.bypassTrigger && Trigger.IsBefore && Trigger.IsUpdate){
            AssetTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);   
        }
    
        
}