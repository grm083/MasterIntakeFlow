/*************************************************************
@Name: AccountTitleTriggerHandler
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Handler Class to Perform operations on AccountTitle
@UsedBy: AccountTitleTrigger
**************************************************************/
public without sharing class AccountTitleTriggerHandler extends TriggerHandler {

	private Map<Id, Account_Title__c> newAccTitleMap;
	private Map<Id, Account_Title__c> oldAccTitleMap;
    
    public AccountTitleTriggerHandler() {
        this.newAccTitleMap = (Map<Id, Account_Title__c>) Trigger.newMap;
        this.oldAccTitleMap = (Map<Id, Account_Title__c>) Trigger.oldMap;
    }
     /*
	* It is invoked on before updating the case
	* @owner : Anupreethy
	* @param : Contact List
	*/
    public override void beforeUpdate() {
        AccountTitleTriggerHelper.checkTitleInServiceApprover(newAccTitleMap,oldAccTitleMap,false);
    }
    /*
	* It is invoked on after updating the Case.
	* @owner : Anupreethy
	* @param : Contact List
	*/
    public override void beforeDelete(){
        AccountTitleTriggerHelper.checkTitleInServiceApprover(newAccTitleMap,oldAccTitleMap,true);
    }
    }