/**
* @author WM- Shilpa Bhatia
* @date 7/14/2019
* @description : Apex class ServiceIssueTaskController 
**/
public with sharing class ServiceIssueTaskController {
    
    @AuraEnabled
    public static string updateServiceClassfication(Id caseRecId , String caseReason){
        
        String status = null;
        List<Task> taskLst = new List<Task>();																																						
        Case caseRec = [SELECT CaseNumber,Status,Case_Sub_Status__c, Tracking_Number__c FROM Case WHERE Id = :caseRecId]; 
        System.debug('caseRec'+caseRec);
        caseRec.Case_Sub_Status__c = 'Pending Service Issue Resolution';
        caseRec.Manual_Invocation__c = 'Yes';
        
        if(Constant_Util.HAULER_REPORTED.equals(caseReason)){
        	caseRec.Service_Classification__c = Constant_Util.STANDARD;
        }else if(Constant_Util.CUSTOMER_REPORTED.equals(caseReason)){
            caseRec.Service_Classification__c = Constant_Util.EMERGENCY;
        }
        for(Task tsk : [SELECT Id, Is_Stop_Task_Creation__c,Process__c, Outcome__c, status FROM Task WHERE
                ((Process__c =: Constant_Util.RESOLVE_SERV_ISSUE AND Attempt__c = 1 AND Outcome__c =: Constant_Util.NO_OR_PENDING_RESPONSE) 
				OR ((Process__c =: Constant_Util.Obtain_Schedule_Confirmation OR Process__c =: Constant_Util.CONFIRM_SERVICE_COMPLETION 
				OR Process__c =: Constant_Util.CONFIRM_SERVICE_COMPLETION_LOCATION OR Process__c =: Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION)
				AND Status =: Constant_Util.OPEN)) AND WhatId =: caseRecId]) {
            if(tsk.Process__c == Constant_Util.RESOLVE_SERV_ISSUE){
                tsk.Is_Stop_Task_Creation__c = true;
                tsk.status =  Constant_Util.COMPLETED;
            }
            if(tsk.Process__c == Constant_Util.Obtain_Schedule_Confirmation || tsk.Process__c == Constant_Util.CONFIRM_SERVICE_COMPLETION ||
                    tsk.Process__c == Constant_Util.CONFIRM_SERVICE_COMPLETION_LOCATION || tsk.Process__c == Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION){
                tsk.Outcome__c = Constant_Util.SERVICE_NOT_PERFORMED;
                tsk.status =  Constant_Util.COMPLETED;
            }
            taskLst.add(tsk);
        }

        try{
            database.update(caseRec);   
            if(taskLst != null && !taskLst.isEmpty()){
                update taskLst;
            }
            status = Constant_Util.SUCCESS;
            
        }Catch(Exception ex){
            status = Constant_Util.Failure;                       
        }
        return status;
        
    } 
}