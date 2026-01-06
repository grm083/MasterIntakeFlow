/*************************************************************
@Name: PersonalQueueTriggerHandler
@Author: WM
@CreateDate: 10/07/2023
@Description: Handler Class to Perform operations on PersonalQueue
@UsedBy: PersonalQueueTrigger
**************************************************************/
public without sharing class PersonalQueueTriggerHandler extends TriggerHandler{

	private Map<Id, Personal_Queue_Info__c> newPersonalQueueMap;
	private Map<Id, Personal_Queue_Info__c> oldPersonalQueueMap;
    private List<Personal_Queue_Info__c> pqList;
    
    public PersonalQueueTriggerHandler() {
        this.newPersonalQueueMap = (Map<Id, Personal_Queue_Info__c>) Trigger.newMap;
        this.oldPersonalQueueMap = (Map<Id, Personal_Queue_Info__c>) Trigger.oldMap;
        this.pqList = (List<Personal_Queue_Info__c>) Trigger.new;
    }
     /*
	* It is invoked on before updating the case
	* @owner : WM
	* @param : 
	*/
    public override void beforeInsert() {
        PersonalQueueTriggerHelper.isWorkflowTeamOrCatUser(newPersonalQueueMap,oldPersonalQueueMap,false,pqList);
    }
    /*
	* It is invoked on after updating the Case.
	* @owner : WM
	* @param : 
	*/
    public override void beforeUpdate(){
        PersonalQueueTriggerHelper.isWorkflowTeamOrCatUser(newPersonalQueueMap,oldPersonalQueueMap,true,pqList);
    }    
}