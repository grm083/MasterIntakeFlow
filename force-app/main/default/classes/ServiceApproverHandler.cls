/*************************************************************
@Name: ServiceApproverHandler
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Handler Class to Perform operations on Service Approver
@UsedBy: serviceApproverTrigger
**************************************************************/
public without sharing class ServiceApproverHandler {
    
    /*
    * It is invoked on before inserting the Service Approver
    * @owner : DineshKumar S
    * @param : ServiceApproverList
    */
    public static void onbeforeInsert(List<Service_Approver__c > newsaList, Boolean IsInsert){
    	
       
        ServiceApproverHelper.validateSA(newsaList);
       
     }
    
    /*
    * It is invoked on after the Service Approver is inserted
    * @owner : DineshKumar S
    * @param : ServiceApproverList
    */
    public static void onafterInsert(List<Service_Approver__c > newsaList,Map<Id,Service_Approver__c > newSaMap, Boolean IsInsert){
		
        ServiceApproverHelper.activateBr(newsaList);
        ServiceApproverHelper.activateConSt(newsaList);
        ServiceApproverHelper.updateBusinessRuleAssociationOnContact(newSaMap,Null,IsInsert,false,false);
    }
    /*
    * It is invoked on after the Service Approver is updated
    * @owner : DineshKumar S
    * @param : ServiceApproverList
    */
    public static void onafterupdate(Map<Id,Service_Approver__c > newSaMap, Map<Id,Service_Approver__c > oldSaMap, Boolean IsUpdate){
		
        ServiceApproverHelper.deActivateBr(newSaMap);
        ServiceApproverHelper.updateBusinessRuleAssociationOnContact(newSaMap,oldSaMap,false,IsUpdate,false);
    }
    
    /*
    * It is invoked on after the Service Approver is deleted
    * @owner : DineshKumar S
    * @param : ServiceApproverList
    */
    public static void onafterdelete(Map<Id,Service_Approver__c > oldSaMap, Boolean IsDelete){
		ServiceApproverHelper.updateBusinessRuleAssociationOnContact(Null,oldSaMap,false,false,true);
    }
}