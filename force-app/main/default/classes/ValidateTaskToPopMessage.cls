/**************************************************
* ClassName:ValidateTaskToPopMessage
* Author:Niranjan 
* Description:This class was created as part of Release1-Sprint3 which changes the task assignment to the logged in user
* CreatedDate:13/8/2019
* **************************************************/
public Without Sharing class ValidateTaskToPopMessage{
    @AuraEnabled
    public static Boolean ValidateToPopUpMsg(Id rec) {    
        Task taskrec; //Task Instance
        Boolean TaskUpdated = false;
        List<Task> tasklist = new List<Task>(); //Task list to have updated records
        List<Task> lsttsk = [Select id,Process__c,Subject,Outcome__c from task where id =: rec];
        if(lsttsk != null && lsttsk.size() >0){
            for(Task objTask : lsttsk){
                if((objTask.Process__c == Constant_Util.Obtain_Schedule_Confirmation && objTask.Outcome__c == Constant_Util.Service_Error) || 
                   (objTask.Process__c == Constant_Util.Manually_Dispatch && objTask.Outcome__c == Constant_Util.Service_Error) ||
                   (objTask.Process__c == Constant_Util.REJECTED_WORK_ORDER && objTask.Outcome__c == Constant_Util.Service_Error) ||
                   (objTask.Process__c == Constant_Util.ESCALATION_REJECTED_WORK_ORDER && objTask.Outcome__c == Constant_Util.Service_Error) ||
                   (objTask.Process__c == Constant_Util.Obtain_Schedule_Confirmation && objTask.Outcome__c == Constant_Util.SERVICE_NOT_PERFORMED) ||
                   (objTask.Process__c == Constant_Util.CONFIRM_SERVICE_COMPLETION && objTask.Outcome__c == Constant_Util.SERVICE_NOT_PERFORMED) ||
                   (objTask.Process__c == Constant_Util.CONFIRM_SERVICE_COMPLETION_LOCATION && objTask.Outcome__c == Constant_Util.SERVICE_NOT_PERFORMED) ||
                  (objTask.Process__c == Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION && objTask.Outcome__c == Constant_Util.SERVICE_NOT_PERFORMED)){
                tasklist.add(objTask);
                      // TaskUpdated = true;
                }
            }
        }   
        if(taskList.size()>0){
            TaskUpdated = true;
        }
        return TaskUpdated;
    }
    @AuraEnabled
    public static List<case> getRelatedCase(string recordId){
        string caseId;
        if(recordId.startswith('500')){
            caseId = recordId;
        }
        else{
            caseId = [SELECT Id, WhatId FROM Task WHERE Id =: recordId].WhatId;
        }
        case caseObj = [SELECT Id, Reference_Number__c, CaseNumber FROM Case WHERE Id =: caseId];
        return [SELECT Id, Reference_Number__c, CaseNumber FROM Case WHERE Reference_Number__c =: caseObj.Reference_Number__c
               AND (Status =: Constant_Util.STATUS_NEW OR Status =: Constant_Util.OPEN)  AND ((Case_Type__c =: Constant_Util.Change_Service 
                 AND Case_Sub_Type__c =: Constant_Util.Change_Correction) OR (Case_Sub_Type__c =:Constant_Util.Service_Not_Performed)) AND Id !=: caseId order by createdDate DESC limit 1];
    }
	@AuraEnabled
    public static case ValidateOutcome(Id recordId) {    
        case caseObj;
        Task tskObj = [SELECT Id,WhatId,Process__c,Outcome__c,Is_a_New_Work_Order_Needed__c FROM Task WHERE Id =: recordId];
		
        if(tskObj.Is_a_New_Work_Order_Needed__c && 
           ((tskObj.Process__c == Constant_Util.RESOLVE_SERV_ISSUE && tskObj.Outcome__c == Constant_Util.SCH_RECOVERY_SERV_RESCHEDULED) ||
           (tskObj.Process__c == Constant_Util.RESOLVE_SERV_ISSUE && tskObj.Outcome__c == Constant_Util.EMER_SERV_REQUIRED) ||
           (tskObj.Process__c == Constant_Util.ESCAL_UNRESP_CON_VENDOR && tskObj.Outcome__c == Constant_Util.SCH_RECOVERY_SERV_RESCHEDULED))){
               caseObj = [SELECT Id, Reference_Number__c, CaseNumber FROM Case WHERE Id =: tskObj.WhatId];                                            
		}
        return caseObj;
    }
}