/*************************************************************
@Name: TaskTrigger
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Trigger to Perform operations on Task
**************************************************************/
trigger TaskTrigger on Task (before update, after update, before Insert, after insert) {
	// Adding a flag for BR-270        
If(BusinessRuleUtility.skipTaskTriggerBR==false) return;
  
//SDT 45079 this veriable is getting set/unset from HaulAwayService.createGenesysTask to avoid unintended SOQL calls
If(HaulAwayService.skipTaskTrigger==false) return;
//If(RecurrsiveTriggerHandler.isSkiptaskTrigger) return; commented as part of testing for defect SDT-46899


    List<sObject> triggerNewtaskList = new List<sObject>(); //Added for SDT-33639
    triggerNewtaskList = RecursionCheck.checkRecusrion(Trigger.new);  //Added for SDT-33639        
        
    
    //Trigger ByPass Logic
    If(!RecurrsiveTriggerHandler.bypassValidation && !RecurrsiveTriggerHandler.isSkiptaskTrigger){
        RecurrsiveTriggerHandler.getByPassValidation();
    }
    //Invokes Before Insert
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsInsert){
            TaskTriggerHandler.OnbeforeInsert(triggerNewtaskList);  //Added for SDT-33639 
	}
	//Invokes Before Update
	If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsUpdate ){
        TaskTriggerHandler.OnbeforeUpdate(triggerNewtaskList,Trigger.oldMap,Trigger.newMap);  //Added for SDT-33639 
	}
    //Invokes After Insert
    If(Trigger.IsAfter && Trigger.IsInsert ){
        TaskTriggerHandler.onafterInsert(Trigger.newMap,Trigger.oldMap);
    }
    //Invokes After Update
    If(Trigger.IsAfter && Trigger.IsUpdate){
        TaskTriggerHandler.onafterUpdate(triggerNewtaskList,Trigger.newMap,Trigger.oldMap);  //Added for SDT-33639 
    }
}
