/*************************************************************
@Name: BusinessRuleTriggerHandler
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Handler Class to Perform operations on Business Rule
@UsedBy: businessRuleTrigger
**************************************************************/
public without sharing class BusinessRuleTriggerHandler {
    
    /*
    * It is invoked on before inserting the Business Rule
    * @owner : DineshKumar S
    * @param : BusinessRuleList*/
    public static void onbeforeInsert(List<Business_Rule__c > newbrList){
        
        BusinessRuleTriggerHelper.validateBR(newbrList,false);
        BusinessRuleTriggerHelper.brNotificationRuleUserCheck(newbrList); //SDT-30949
        BusinessRuleTriggerHelper.autoEmailCheck(newbrList); //SDT-31225
        BusinessRuleTriggerHelper.removeEndDateWhileCloning(newbrList); //BRE-310
        
    }
    /*
    * It is invoked on before Updating the Business Rule
    * @owner : Priyadharshini R
    * @param : BusinessRuleList*/
    public static void onbeforeUpdate(List<Business_Rule__c > newbrList){
        
        BusinessRuleTriggerHelper.validateBR(newbrList,true);
        BusinessRuleTriggerHelper.brNotificationRuleUserCheck(newbrList);  //SDT-30949
        BusinessRuleTriggerHelper.autoEmailCheck(newbrList); //SDT-31225
    }
    /*
    * It is invoked on after Updating the Business Rule for SDT-16916
    * @owner : Accenture
    * @param : BusinessRuleList*/
    public static void onAfterUpdate(List<Business_Rule__c > newBRLst){
        BusinessRuleTriggerHelper.deactivateServiceApprovers(newBRLst);
    }
}