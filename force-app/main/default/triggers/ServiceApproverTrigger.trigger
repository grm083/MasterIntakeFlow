/*************************************************************
@Name: ServiceApproverTrigger
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Trigger to Perform operations on Service Approver
**************************************************************/
trigger ServiceApproverTrigger on Service_Approver__c(before insert,after insert,after update,after delete) {
    
    //Trigger ByPass Logic
    If(!RecurrsiveTriggerHandler.bypassValidation){
        RecurrsiveTriggerHandler.getByPassValidation();
    }
    system.debug('***bypassValidation '+ RecurrsiveTriggerHandler.bypassValidation);
    //Invokes Before Insert
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsInsert){
        system.debug('*** inside Before Insert'+ RecurrsiveTriggerHandler.bypassValidation);
        ServiceApproverHandler.onbeforeInsert(Trigger.New, Trigger.IsInsert);   
    }  
    //Invokes After Insert
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert){
        system.debug('*** inside IsAfter Update'+ RecurrsiveTriggerHandler.bypassValidation);
        ServiceApproverHandler.onafterInsert(Trigger.New,Trigger.newmap,Trigger.IsInsert);
    }  
    //Invokes After Update
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.Isupdate){
        system.debug('*** inside IsAfter Update'+ RecurrsiveTriggerHandler.bypassValidation);
        ServiceApproverHandler.onafterUpdate(Trigger.newMap, Trigger.oldmap,Trigger.Isupdate);
    }  
    
    //Invokes After Delete
    System.debug('>>>RecurrsiveTriggerHandler.bypassValidation'+RecurrsiveTriggerHandler.bypassValidation);
    System.debug('>>>Trigger.IsAfter'+Trigger.IsAfter);
    System.debug('>>>Trigger.Isdelete'+Trigger.Isdelete);
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.Isdelete){
        system.debug('*** inside IsAfter Delete'+ RecurrsiveTriggerHandler.bypassValidation);
        ServiceApproverHandler.onafterDelete(Trigger.oldmap,Trigger.Isdelete);
    }  
}
