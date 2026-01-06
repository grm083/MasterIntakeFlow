/*************************************************************
@Name: subStatusPathController
@Author: DineshKumar S
@CreateDate: 26/09/2019
@Description: Controller Class to Perform operations on SubstatusPathContainer
@UsedBy: CaseTriggerHandler
*************************************************************/
public without sharing class subStatusPathController {

    private static string STATUS = 'Status';
    private static string SUB_STATUS = 'Case_Sub_Status__c'; 
    /**
    * @author : DineshKumar S
    * @CreateDate: 26/09/2019
    * @description : Apex method getcases to display Case Sub Status Path.
    **/
    @AuraEnabled
    public static string getflowpath(Id caseId){
        pathwrapper pw = new pathwrapper();
        try{
            case ca = [Select Id,Status,RecordTypeId,Case_Sub_Status__c from case where Id =: caseId Limit 1];
            Map<String,List<String>> mapOptions = new Map<String,List<String>>();
            map<String,List<String>> picklistvaluemap = DependentPickListValueController.getPicklistValueBasedonRecordType(Constant_Util.KEYWORD_CASE,SUB_STATUS,ca.RecordTypeId);
            pw.caseTypeList = picklistvaluemap.get(ca.Status); 
            pw.CurrentCaseType = ca.Case_Sub_Status__c;
            pw.caseType=ca.Status;
        }catch(Exception excp){
            system.debug('Exception Caught'+excp.getStackTraceString());
            pw = null;
        }
        return Json.serialize(pw);
    }
    Public without sharing class pathwrapper{

         @AuraEnabled public List<String> caseTypeList;
         @AuraEnabled public string CurrentCaseType;
         @AuraEnabled public string caseType;
    }
}