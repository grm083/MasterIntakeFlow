/*************************************************************
@Name: Contact Notification Preference Trigger
@Author: Devendra Patel
@CreateDate: 07/15/2020
@Description: Trigger to Perform operations on Contact Notification Preference
**************************************************************/
trigger ContactNotificationPreferenceTrigger on Contact_Notification_Preference__c(before Update,  before Insert) {
    
   
    //Invokes Before Insert
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsInsert){
            ContactNotifyPrefTriggerHandler.OnBeforeInsert(Trigger.new);
    }
    //Invokes Before Update
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsUpdate ){
        ContactNotifyPrefTriggerHandler.OnBeforeUpdate(Trigger.new,Trigger.oldMap,Trigger.newMap);
    }
    //Invokes After Insert
    //If(Trigger.IsAfter && Trigger.IsInsert ){
    //    ContactNotifyPrefTriggerHandler.onafterInsert(Trigger.newMap,Trigger.oldMap);
   // }
    //Invokes After Update
   // If(Trigger.IsAfter && Trigger.IsUpdate){
     //   ContactNotifyPrefTriggerHandler.onafterUpdate(Trigger.new,Trigger.newMap,Trigger.oldMap);
   // }
}