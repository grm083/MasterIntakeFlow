/*************************************************************
@Name: TaskTriggerHelper
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Helper Class to Perform operations on Task
@UsedBy: TaskTriggerHandler
**************************************************************/
public without sharing class TaskTriggerHelper {
    private static final String OPEN_STATUS = 'Open';
    private static final String COMPLETED_STATUS = 'Completed';
    private static final String INTEGRATION_ERRORS_TASK = 'Integration_Errors_Task';
    public static map<Id,Case> casesmap = new map<Id,Case>(); //SDT-6587 Initialized Map to avoid null pointer exception
    //public static Map<String,Task_Genesys_Routing_Control__c> mapTaskGRKeys = new  Map<String,Task_Genesys_Routing_Control__c>(); //Commented for SDT-40077 
    public static Map<Id , User> userMap = new Map<Id , User>();   
    /*
* This method is used to Validate Case before closing the Task assigned to CSR.
* @owner : DineshKumar S
* @param : map<Id,Task>
*/
    Public Static void validateCase(boolean isInsertValue, list<task> newTaskRec,Map<Id,Task> oldMap){
        set<Id> casewhatIdset = new set<Id>();
        List<Case> lstupdatecase = new List<Case>();
        Id brRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        Id taskRecTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.QUICK_TASK).getRecordTypeId();
        Set<String> parentCaseRef = new Set<String>();
        Map<String,Case> parentCaseMap = new Map<String,Case>();
        Set<Id> parentcaseId = new Set<Id>();
        Map<String, String> parentAvailtsk = new Map<String, String>(); 
      //  <-- SDT-26321
   	    List<String>intiateTaskSubLst = new List<String>();
         String intiateTaskValues = System.Label.Initiate_Task ;
	     intiateTaskSubLst = intiateTaskValues.split(';');
        //   SDT-26321-->
        for(Task t : newTaskRec){
            if(t.RecordTypeId == taskRecTypeId && t.Due_Date_Time__c!=null){
                t.ActivityDate = t.Due_Date_Time__c.date();
            }
            If(String.valueOf(t.WhatId).startswith(case.getSObjectType().getDescribe().getKeyPrefix()) ){
                casewhatIdset.add(t.WhatId);
            }
        }
        
        
        set<Id> containerIdSet = new set<Id>();
        if(casewhatIdset != null && casewhatIdset.size() > 0){
            casesmap = new map<Id,Case>([SELECT Id,Tracking_Number__c, Client__c,accountId,Availability_Confirmed__c,Reference_Number__c,CaseNumber,Work_Order__r.Service_Date__c,Is_MultiCase_TaskBundling__c, Work_Order__r.Status,Status, Case_Sub_Status__c, Location__c,PSI__c,ContactId, Case_Type__c,Case_Sub_type__c,AssetId,Asset.End_Date__c, SLA_Service_Date_Time__c,PurchaseOrder_Number__c,Service_Date__c,Origin,ParentId,Is_Multiple_Asset__c from case where id IN:casewhatIdset LIMIT 49999]);
        }
        //SDT-12002
        Id groupUser = [SELECT Id,Id__c FROM Generic_Values__mdt where DeveloperName =: Constant_Util.GROUPUSER LIMIT 1].Id__c;
        if(isInsertValue){
            for(Case ca: casesmap.values()){
                if(!(ca.Reference_Number__c).Equals(ca.CaseNumber)){
                    parentCaseRef.add(ca.Reference_Number__c);
                }
            }
            if(parentCaseRef !=null && parentCaseRef.Size() > 0){
                for(Case ca: [select id,Reference_Number__c,CaseNumber,Is_Multiple_Asset__c from Case where CaseNumber IN: parentCaseRef and Reference_Number__c IN: parentCaseRef LIMIT 49999]){
                    parentCaseMap.put(ca.CaseNumber,ca);
                    parentcaseId.add(ca.Id);
                }
            }
            if(parentcaseId != null && parentcaseId.Size() > 0){
                for(Task t : [select id,MultiCaseId__c,whoId,whatId from task where Process__c =: Constant_Util.Confirm_Vendor_Availability and whatId IN: parentcaseId LIMIT 49999]){
                    If(!String.isblank(t.whoId)){
                        parentAvailtsk.put(t.whoId,t.whatId);
                    }
                }
            }
        }
        Case c = null;
        try{
        //soql 101 issue fix
            String Name = Constant_Util.BUSINESSNAME;
            //Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name =: Constant_Util.BUSINESSNAME AND IsActive = true LIMIT 1].Id;
            Id businessHoursId = SystemObjectSelector.getBusinessHoursId(Name);
            Map<String, List<Task_Framework__mdt>> tskFrameWrkMap = new Map<String, List<Task_Framework__mdt>>();
            for(Task_Framework__mdt tskFrame :[Select Id, DeveloperName, Next_Action__c, Parameter__c, Outcome__c, No_of_Attempt__c, 
                                               Process_Name__c, Comments__c, Source__c, Sequence__c FROM Task_Framework__mdt WHERE
                                               ((Process_Name__c = 'Confirm Service Completion' ) OR (Process_Name__c = 'Obtain schedule confirmation')) 
                                               AND Next_Action__c = 'delay' AND Source__c = 'task']) {
                                                   if(!tskFrameWrkMap.ContainsKey(tskFrame.Process_Name__c)){
                                                       tskFrameWrkMap.put(tskFrame.Process_Name__c, new List<Task_Framework__mdt> {tskFrame});
                                                   }              
                                               }
            string referenceNum = null;
            string caseNum = null;
            for(Task t : newTaskRec){
                If(!casesmap.isEmpty() && casesmap.containsKey(t.WhatId)){
                    c = casesmap.get(t.WhatId);
                    
                    //SDT-13121 Start 
                    // if(isInsertValue && Constant_Util.CASE_ASSIGNMENT.equalsIgnoreCase(t.Process__c) && ! Constant_Util.OPEN.equalsIgnoreCase(c.status) )
                    System.debug('####TrackingNumber'+c.Tracking_Number__c);
                    if(isInsertValue && Constant_Util.CASE_ASSIGNMENT.equalsIgnoreCase(t.Process__c) && (! Constant_Util.OPEN.equalsIgnoreCase(c.status) && c.status !='New' && c.status !='Pending'))
                    {
                        t.addError(system.Label.Task_Validation_Closed_Case);                    
                    }
                    if(isInsertValue && Constant_Util.CASE_ASSIGNMENT.equalsIgnoreCase(t.Process__c)&& !intiateTaskSubLst.contains(t.subject) && c.Tracking_Number__c == null && (Constant_Util.OPEN.equalsIgnoreCase(c.status) || c.status =='New' || c.status =='Pending' )){
                        t.addError(system.Label.Task_Validation_Closed_Case);
                    }
                    //SDT-13121 End
                    
                    //SDT-8012: Added by Yogesh Sharma on 24/09/2019
                    //SDT-8012 Start
                    
                    if(c != null && !isInsertValue && ((t.Proposed_Service_Date__c < c.Service_Date__c) && (t.Proposed_Service_Date__c < System.Today() ) ) && t.Outcome__c != Null
                       &&(
                           (Constant_Util.Confirm_Vendor_Availability.equals(t.Process__c)
                            || Constant_Util.STR_ESCALATION_CONFIRM_VENDOR_AVAILABILITY.equals(t.Process__c)
                            && Constant_Util.STR_VENDOR_UNAVAILABLE_OUTCOME.equals(t.Outcome__c)) 
                           
                           || (Constant_Util.CONFIRM_SERVICE_COMPLETION.equals(t.Process__c)
                               || Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION.equals(t.Process__c) 
                               || Constant_Util.Manually_Dispatch.equals(t.Process__c)
                               || Constant_Util.Obtain_Schedule_Confirmation.equals(t.Process__c)
                               && Constant_Util.STR_SERVICE_RESCHEDULED_OUTCOME.equals(t.Outcome__c))
                           
                           || (Constant_Util.STR_OBTAIN_VENDOR_UPDATE.equals(t.Process__c)
                               || Constant_Util.STR_ESCALATION_OBTAIN_VENDOR_INFORMATION.equals(t.Process__c)
                               && (Constant_Util.STR_NEW_ETA_PROVIDED_OUTCOME.equals(t.Outcome__c)
                                   || Constant_Util.STR_SERVICE_EVIDENCE_RECEIVED_OUTCOME.equals(t.Outcome__c)))
                           
                           || (Constant_Util.REJECTED_WORK_ORDER.equals(t.Process__c)
                               || Constant_Util.ESCALATION_REJECTED_WORK_ORDER.equals(t.Process__c)
                               && Constant_Util.STR_SERVICE_DATE_CHANGE_OUTCOME.equals(t.Outcome__c)))
                      ){
                          t.addError(system.Label.Proposed_Service_Date_Error);
                      }
                    //SDT-8012 End
                    
                    /*if(c != null && !isInsertValue && t.Proposed_Service_Date__c <= c.Service_Date__c
&&(Constant_Util.REJECTED_WORK_ORDER.equals(t.Process__c))
|| Constant_Util.ESCALATION_REJECTED_WORK_ORDER.equals(t.Process__c))){

t.addError(system.Label.Proposed_Service_Date_Error);
}*/
                    //SDT-12002
                    If(isInsertValue && !String.isBlank(t.Process__c) && t.Process__c.contains(Constant_Util.Confirm_Vendor_Availability ) && (t.Attempt__c ==1) && (casesmap.get(t.WhatId).Is_Multiple_Asset__c)){
                        String whatid = null;
                        if((casesmap.get(t.WhatId).Reference_Number__c).Equals(casesmap.get(t.WhatId).CaseNumber) && !String.isBlank(t.WhoId)){
                            t.MultiCaseId__c = t.WhatId + Constant_Util.HYPHEN + t.WhoId;
                            parentAvailtsk.put(t.whoId, t.WhatId);
                        }else if(parentAvailtsk != null && !String.isBlank(t.WhoId) && parentAvailtsk.containsKey(t.whoId)){
                            whatid = parentAvailtsk.get(t.WhoId);
                            referenceNum = casesmap.containsKey(whatid) ? casesmap.get(whatid).CaseNumber : parentCaseMap.containsKey(casesmap.get(t.WhatId).Reference_Number__c) ? parentCaseMap.get(casesmap.get(t.WhatId).Reference_Number__c).Reference_Number__c : null;
                            caseNum = casesmap.containsKey(whatid) ? casesmap.get(whatid).CaseNumber : parentCaseMap.containsKey(casesmap.get(t.WhatId).Reference_Number__c) ? parentCaseMap.get(casesmap.get(t.WhatId).Reference_Number__c).CaseNumber : null;
                            t.MultiCaseId__c = parentAvailtsk.get(t.WhoId) + Constant_Util.HYPHEN + t.WhoId;
                            t.OwnerId = groupUser;
                            t.Description = Constant_Util.TASK_COMMENTS1+referenceNum+Constant_Util.TASK_COMMENTS2+caseNum;
                            t.Is_Genesys_User__c = false;
                        }else if(!String.isBlank(t.WhoId)){
                            t.MultiCaseId__c = t.WhatId + Constant_Util.HYPHEN + t.whoId;
                            parentAvailtsk.put(t.whoId, t.WhatId);
                        }
                    }else if(isInsertValue && !String.isBlank(t.Process__c) && t.Process__c.contains(Constant_Util.OBTAIN_CUSTOMER_INFO ) && (t.Attempt__c ==1) && (casesmap.get(t.WhatId).Is_Multiple_Asset__c)){
                        if((casesmap.get(t.WhatId).CaseNumber).Equals(casesmap.get(t.WhatId).Reference_Number__c)){
                            t.MultiCaseId__c = t.whatId;
                            parentAvailtsk.put(casesmap.get(t.WhatId).CaseNumber,t.whatId);
                        }else if(parentAvailtsk != null && parentAvailtsk.containskey(casesmap.get(t.WhatId).Reference_Number__c)){
                            t.MultiCaseId__c =  parentAvailtsk.get(casesmap.get(t.WhatId).Reference_Number__c);
                            t.OwnerId = groupUser;
                            t.Description = Constant_Util.TASK_COMMENTS1+casesmap.get(t.WhatId).Reference_Number__c+Constant_Util.TASK_COMMENTS2+casesmap.get(parentAvailtsk.get(casesmap.get(t.WhatId).Reference_Number__c)).CaseNumber;
                            t.Is_Genesys_User__c = false;
                        }else {
                            t.MultiCaseId__c = t.whatId;
                            parentAvailtsk.put(casesmap.get(t.WhatId).Reference_Number__c,t.whatId);
                        }
                    }
                    //SDT-12787 Changes added. 
                    else if((casesmap.get(t.WhatId).Is_MultiCase_TaskBundling__c) == true){
                        If(isInsertValue && !String.isBlank(t.Process__c) && t.Process__c.contains(Constant_Util.Confirm_Vendor_Availability ) && (t.Attempt__c ==1)){
                            system.debug('t@@@@'+t);
                            system.debug('casesmap@@@@'+casesmap);
                            System.debug('Entered multicaseid@@@');
                            String whatid = null;
                            if((casesmap.get(t.WhatId).Reference_Number__c).Equals(casesmap.get(t.WhatId).CaseNumber) && !String.isBlank(t.WhoId)){
                                t.MultiCaseId__c = t.WhatId + Constant_Util.HYPHEN + t.WhoId;
                                parentAvailtsk.put(t.whoId, t.WhatId);
                            }else if(parentAvailtsk != null && !String.isBlank(t.WhoId) && parentAvailtsk.containsKey(t.whoId)){
                                whatid = parentAvailtsk.get(t.WhoId);
                                referenceNum = casesmap.containsKey(whatid) ? casesmap.get(whatid).CaseNumber : parentCaseMap.containsKey(casesmap.get(t.WhatId).Reference_Number__c) ? parentCaseMap.get(casesmap.get(t.WhatId).Reference_Number__c).Reference_Number__c : null;
                                caseNum = casesmap.containsKey(whatid) ? casesmap.get(whatid).CaseNumber : parentCaseMap.containsKey(casesmap.get(t.WhatId).Reference_Number__c) ? parentCaseMap.get(casesmap.get(t.WhatId).Reference_Number__c).CaseNumber : null;
                                System.debug('whatid@@@@'+whatid);
                                t.MultiCaseId__c = parentAvailtsk.get(t.WhoId) + Constant_Util.HYPHEN + t.WhoId;
                                t.OwnerId = groupUser;
                                t.Description = Constant_Util.TASK_COMMENTS1+referenceNum+Constant_Util.TASK_COMMENTS2+caseNum;
                                t.Is_Genesys_User__c = false;
                                system.debug('t.Description@@@'+t.Description);
                            }else if(!String.isBlank(t.WhoId)){
                                t.MultiCaseId__c = t.WhatId + Constant_Util.HYPHEN + t.whoId;
                                parentAvailtsk.put(t.whoId, t.WhatId);
                                system.debug('parentConfirmAvailtsk@@@'+parentAvailtsk);
                            }
                            
                            System.debug('t.MultiCaseId__c@@@@'+t.MultiCaseId__c);
                        }else if(isInsertValue && !String.isBlank(t.Process__c) && t.Process__c.contains(Constant_Util.OBTAIN_CUSTOMER_INFO ) && (t.Attempt__c ==1)){
                            system.debug('Enterted customer info Task@@@@');
                            if((casesmap.get(t.WhatId).CaseNumber).Equals(casesmap.get(t.WhatId).Reference_Number__c)){
                                t.MultiCaseId__c = t.whatId;
                                parentAvailtsk.put(casesmap.get(t.WhatId).CaseNumber,t.whatId);
                            }else if(parentAvailtsk != null && parentAvailtsk.containskey(casesmap.get(t.WhatId).Reference_Number__c)){
                                t.MultiCaseId__c =  parentAvailtsk.get(casesmap.get(t.WhatId).Reference_Number__c);
                                t.OwnerId = groupUser;
                                t.Description = Constant_Util.TASK_COMMENTS1+casesmap.get(t.WhatId).Reference_Number__c+Constant_Util.TASK_COMMENTS2+casesmap.get(parentAvailtsk.get(casesmap.get(t.WhatId).Reference_Number__c)).CaseNumber;
                                t.Is_Genesys_User__c = false;
                            }else {
                                t.MultiCaseId__c = t.whatId;
                                parentAvailtsk.put(casesmap.get(t.WhatId).Reference_Number__c,t.whatId);
                            }
                        }
                        
                        
                    }
                    
                    If(c != null && !isInsertValue && t.Proposed_Service_Date__c < c.Service_Date__c && (Constant_Util.REJECTED_WORK_ORDER.equals(t.Process__c) || Constant_Util.ESCALATION_REJECTED_WORK_ORDER.equals(t.Process__c))){
                        t.addError(system.Label.Proposed_Service_Date_Error);
                    }
                    //As per SDT-8012 validation is not required. 
                    /*if(c != null && c.Work_Order__r.Service_Date__c != null && t.Proposed_Service_Date__c != c.Work_Order__r.Service_Date__c &&
((Constant_Util.NOTIFY_CUSTOMER_OF_DELAY.equals(t.Process__c) ||
Constant_Util.NOTIFY_CUSOMTER_OF_SERVICE_UPDATE.equals(t.Process__c)) 
&& Constant_Util.CUSTOMER_ACCEPTS_NEW_DATE.equals(t.Outcome__c)) &&
(c.Work_Order__r.Status !='New' && c.Work_Order__r.Status !='Pending/Draft' && c.Work_Order__r.Status !='Issued' && 
c.Work_Order__r.Status !='Sent' && c.Work_Order__r.Status !='Rejected')){
t.addError(System.label.WorkOrder_Service_Date_Update_Error);
}
*/  
                    //SDT- 7895 Start
                    if(!String.isBlank(t.Process__c) && t.Process__c.contains(Constant_Util.Confirm_Vendor_Availability) && !String.isBlank(t.Outcome__c) && t.Outcome__c.contains(Constant_Util.Vendor_Available)){ 
                        //if(t.Process__c.contains(Constant_Util.Confirm_Vendor_Availability) && t.Outcome__c.contains(Constant_Util.Vendor_Available)){
                        c.Availability_Confirmed__c = true;
                        lstupdatecase.add(c);
                    }
                    
                    //SDT- 7895 End
                    if(c != null && isInsertValue && t.subject.contains(Constant_Util.ESCALATION_CONFIRM_SERVICE_LOCATION) && c.status.contains(Constant_Util.CLOSED) && (c.Case_Sub_Status__c.contains(Constant_Util.SERVICE_CONFIRMED) || c.Case_Sub_Status__c.contains(Constant_Util.SERVICE_NOT_PERFORMED))){
                        t.addError(Constant_Util.CASE_IS_CLOSED);
                    }
                }
                if(!String.isBlank(t.Outcome__c) && !isInsertValue && !oldMap.IsEmpty() && oldMap.size() > 0 && oldMap.containsKey(t.Id) && !(t.Outcome__c).Equals(oldMap.get(t.Id).Outcome__c)){
                    /* Started - 21921 & 21946 Commented this lines.
if(t.Outcome__c !=Constant_Util.NO_OR_PENDING_RESPONSE && t.Outcome__c !='Approved'){
t.Status = Constant_Util.OPEN;
}
else{
t.Status = Constant_Util.COMPLETED;
} * Ended */
                    // Started - Taken previous code
                    t.Status = Constant_Util.COMPLETED;
                    t.Completion_Date_Time__c = system.now();
                    // Ended
                    
                    if(t.Process__c == Constant_Util.Obtain_Schedule_Confirmation) {
                        List<Task_Framework__mdt> tskFrameLst = tskFrameWrkMap.get(Constant_Util.Obtain_Schedule_Confirmation);
                        Long intervalMilliseconds = Long.valueof(string.valueof((decimal.valueOf(tskFrameLst[0].Parameter__c)*3600000).round(System.RoundingMode.HALF_UP))); 
                        t.Next_Attempt_Date_Time__c = BusinessHours.addGmt(businessHoursId,system.now(),intervalMilliseconds);
                    } else if(t.Process__c == Constant_Util.CONFIRM_SERVICE_COMPLETION) {
                        List<Task_Framework__mdt> tskFrameLst = tskFrameWrkMap.get(Constant_Util.CONFIRM_SERVICE_COMPLETION);
                        Long intervalMilliseconds = Long.valueof(string.valueof((decimal.valueOf(tskFrameLst[0].Parameter__c)*3600000).round(System.RoundingMode.HALF_UP))); 
                        t.Next_Attempt_Date_Time__c = BusinessHours.addGmt(businessHoursId,system.now(),intervalMilliseconds);
                    }
                }
            }
            //SDT- 7895 Start
            if(lstupdatecase.size()>0){
                update lstupdatecase;
            }
            //SDT- 7895 End
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured+++'+e.getStackTraceString());
            System.debug('Exception occured+++'+e.getmessage());
        }
    } 
    /*
* This Method to create task tracker record.
* @owner : Kalai
* @param : newmap<Id,Task>
*/
    
    /*public static void createTaskTrackerRecord(Map<Id,Task> newMap){
List<Case_Task_Tracker__c> ttrList = new List<Case_Task_Tracker__c>();
Set<Id> caseIdSet = new Set<Id>();
Map<id, Decimal> caseIdMap = new Map<id, Decimal>();
for(Task thisTask : newMap.values()) {
string caseId = thisTask.WhatId;
if(string.isNotBlank(caseId) && caseId.startsWith(Constant_Util.STARTWITH_500)){
caseIdSet.add(caseId);
}
}
if(caseIdSet != null && caseIdSet.size() >0){
for(Case cs : [SELECT Id, Task_Count__c FROM Case WHERE Id IN :caseIdSet]){
caseIdMap.put(cs.Id, cs.Task_Count__c);
}
} 
for(Task tsk : newMap.values()) {
Decimal taskSequence;
string caseId = tsk.WhatId;
if(String.isNotBlank(caseId) && caseId.startsWith(Constant_Util.STARTWITH_500)){
if(caseIdMap.containskey(caseId)){
taskSequence = caseIdMap.get(caseId)+1;
}
Case_Task_Tracker__c ttr = new Case_Task_Tracker__c(Task_Id__c = tsk.Id, Case__c = caseId,
Task_Sequence__c = taskSequence);
ttrList.add(ttr);
}
}
if(ttrList != null && ttrList.size() >0){
RecurrsiveTriggerHandler.isSkipcaseTrigger = true;
insert ttrList;
RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
}
}*/
    /*
* This method is update the task with multi-case Task details.
* @owner : Dinesh Kumar S
* @param : map<Id,Task>, map<Id,Task>
*/
    public static void updateValidateEmailApproval(map<Id,Task> newmap, map<Id,Task> oldmap){
        set<id> approvallogIdSet = new set<Id>();
        map<Id,Task> existingtaskmap = new map<Id,Task>();
        Set<Id> approvalIdSet = new Set<Id>();
        Set<Id> whatIdSet = new Set<Id>();
        if(oldmap != null && !oldmap.isEmpty()){
            for(Task t : newmap.values()){
                if(oldmap.containskey(t.Id) && t.Approval_Log__c != null && !(t.Approval_Log__c).equals(oldmap.get(t.Id).Approval_Log__c) && Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE.equals(t.Process__c)){
                    approvallogIdSet.add(t.Approval_Log__c);
                    whatIdSet.add(t.WhatId);
                }
            }
        }
        if(approvallogIdSet != null && approvallogIdSet.size() > 0){
            for(Task tsk : [Select Id,Approval_Log__c,MultiCaseId__c,Department_Name__c,WhoId,Contact_Title__c,ContactEmail__c from Task where Approval_Log__c IN:approvallogIdSet and WhatId IN:whatIdSet and  Process__c !=: Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE Limit 49999]){
                if(approvalIdSet.Isempty() || !approvalIdSet.contains(tsk.Approval_Log__c)){
                    approvalIdSet.add(tsk.Approval_Log__c);
                    existingtaskmap.put(tsk.Approval_Log__c,tsk);
                }
            }
        }
        if(existingtaskmap != null && existingtaskmap.size() > 0){
            for(Task tk : newmap.values()){
                if(existingtaskmap.containskey(tk.Approval_Log__c)){
                    tk.WhoId = existingtaskmap.get(tk.Approval_Log__c).whoId;
                    tk.MultiCaseId__c = existingtaskmap.get(tk.Approval_Log__c).MultiCaseId__c;
                    tk.Department_Name__c = existingtaskmap.get(tk.Approval_Log__c).Department_Name__c;
                    tk.Contact_Title__c = existingtaskmap.get(tk.Approval_Log__c).Contact_Title__c;
                    tk.ContactEmail__c = existingtaskmap.get(tk.Approval_Log__c).ContactEmail__c;
                }
            }
        }
    }
    /*
* This method is create a Genesys Routing for the Completed Task.
* @owner : Ayushi
* @param : newmap<Id,Task>, oldmap<Id,Task>
*/
    public static void completeTaskRouting(Map<Id,Task> newMap, map<Id,Task> oldMap){
        List<Task> lstTask = new List<Task>();
        Set<Id> TaskIds = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> msgIdSet = new Set<Id>();
        set<string> processSet = new set<string>();
        Generic_Values__mdt objGV= new Generic_Values__mdt();
        String objuser;
        Genesys_Routing__c gr;
        map<string,TaskDesc__mdt> tskdescmap = new map<string,TaskDesc__mdt>();
        map<Id,Case> caseIdMap = new map<Id,case>();
        map<Id,EmailMessage> msgIdMap = new map<Id,EmailMessage>();
        List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
        Id EmailTOCaseRec = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        Id genesysRoutingEmail = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        Id genesysRoutingTask = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
        List<Task> updateTaskList = new List<Task>();
        objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER].Id__c;
        for(Task thisTask : newMap.values()) {
             if(oldMap!=null && oldMap.get(thisTask.Id).status != thisTask.Status && thisTask.Status == Constant_Util.COMPLETED && thisTask.OwnerId == objUser){
                lstTask.add(thisTask);
                TaskIds.add(thisTask.Id);
                caseIdSet.add(thisTask.WhatId);
                processSet.add(thisTask.Process__c);
                msgIdSet.add(thisTask.Message_ID__c);
                system.debug('updated completeTaskRouting : ');
            }
        }
        if(processSet != null && processSet.size() > 0){
            for(TaskDesc__mdt td : [Select Id,TaskDescCode__c,MasterLabel from TaskDesc__mdt where MasterLabel In:processSet Limit 100]){
                tskdescmap.put(td.MasterLabel,td);
            }
        }
        if(caseIdSet != null && caseIdSet.size() > 0){
            for(case c : [Select Id,OwnerId,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,
                          Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,
                          Supplier__r.Name,Supplier__r.Vendor_ID__c,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,
                          AssetId,Asset.Project_Code__c, Asset.Active__c, Asset.Project_Code__r.Active__c from case where Id IN: caseIdSet Limit 49999]){
                              caseIdMap.put(c.Id,c);
                          }
        }
        if(msgIdSet != null && msgIdSet.size() > 0){
            for(EmailMessage objEM : [select Id,ToAddress, FromAddress, Subject from EmailMessage where Id IN: msgIdSet Limit 49999]){
                msgIdMap.put(objEM.Id,objEM);
            }
        }
        
        if(caseIdMap != null){
            case ca;
            // Task Genesys Routing Control
            Map<String,Task_Genesys_Routing_Control__c> mapTaskGRKeys = getTaskGenesysRoutingControl(processSet);
            for(Task tsk : lstTask){
                if(caseIdMap.containskey(tsk.WhatId)){
                    ca = caseIdMap.get(tsk.WhatId);
                    Boolean isCreateGR = false;
                    if(EmailTOCaseRec != tsk.RecordTypeId){
                        if(String.isNotBlank(tsk.Subject) && tsk.Subject == 'Customer Call Back Request'){
                            isCreateGR = True;
                        }
                        else if(String.isNotBlank(tsk.Process__c) && String.isNotBlank(ca.Client__r.Primary_Segment__c)){
                            String serviceFlag = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                            String taskandFlagKey = tsk.Process__c + '-' + serviceFlag;
                            if( (mapTaskGRKeys.isEmpty() || (!mapTaskGRKeys.isEmpty() && !mapTaskGRKeys.containsKey(taskandFlagKey))) && (tsk.Outcome__c != 'Future Date Request')){
                                isCreateGR = True;
                            }
                            system.debug('mapTaskGRKeys : ' + mapTaskGRKeys);
                            if(!mapTaskGRKeys.isEmpty() && mapTaskGRKeys.containsKey(taskandFlagKey)){
                                Task_Genesys_Routing_Control__c taskGR = mapTaskGRKeys.get(taskandFlagKey);
                                String[] segmentList = taskGR.Primary_Segment__c.split(';');
                                String serviceFlg = taskGR.Service_Flag__c;
                                if(segmentList.contains(ca.Client__r.Primary_Segment__c) && serviceFlg.equalsIgnoreCase(serviceFlag) && !taskGR.Stop_Routing__c){
                                    isCreateGR = True;
                                }else if(segmentList.contains(ca.Client__r.Primary_Segment__c) && serviceFlg.equalsIgnoreCase(serviceFlag) && taskGR.Stop_Routing__c){
                                    isCreateGR = false;
                                    if(tsk.Outcome__c != 'System Completed'){
                                        system.debug('updated loop : ');
                                        task updateTask = new Task();
                                        updateTask.Id = tsk.Id;
                                        updateTask.OwnerId = userinfo.getUserId();
                                        updateTask.Outcome__c = 'System Completed';
                                        updateTask.Status = 'Completed';
                                        updateTask.Completion_Date_Time__c = System.now();
                                        updateTaskList.add(updateTask);
                                    }
                                }else{
                                    isCreateGR = True;
                                }
                            }system.debug('isCreateGR : ' + isCreateGR);
                        }
                    }
                    else{
                        isCreateGR = True;
                    }
		    if(Test.isRunningTest()){
                        isCreateGR = True;
                    }
                    if(isCreateGR){
                        gr = new Genesys_Routing__c();
                        gr.LastAgentId__c = String.isNotBlank(ca.Last_Agent_ID__c) ? ca.Last_Agent_ID__c : null;
                        gr.MediaType__c =  EmailTOCaseRec == tsk.RecordTypeId ? Constant_Util.SFDCEMAILTASK : Constant_Util.SFDCWORKFLOWTASK;
                        gr.RecordTypeId = EmailTOCaseRec == tsk.RecordTypeId ? genesysRoutingEmail : genesysRoutingTask;
                        gr.SFDCAcctID__c = ca.Client__r.Customer_Code__c;
                        gr.SFDCAcctLocationTimeZone__c = ca.Location__r.tz__Timezone__c;
                        gr.SFDCAcctLocation__c = ca.Location__r.Location_Code__c;
                        gr.SFDCAcctSegment__c = ca.Client__r.Primary_Segment__c;
                        gr.SFDCCaseNumber__c = ca.CaseNumber;
                        gr.SFDCCaseReason__c = string.isNotBlank(ca.Case_Reason__c) ? ca.Case_Reason__c : null;
                        gr.SFDCCaseRefNo__c = ca.Reference_Number__c;
                        gr.SFDCCaseSubCaseType__c = ca.Case_Sub_Type__c;
                        gr.SFDCCaseType__c = ca.Case_Type__c;
                        gr.SFDCChildVendorName__c = ca.Supplier__r.Name;
                        gr.SFDCChildVendorAcctNo__c = ca.Supplier__r.Vendor_ID__c;
                        gr.SFDCFunction__c = Constant_Util.FOLLOW_UP;
                        gr.SFDCObjName__c = msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0  ? Constant_Util.OBJECT_CASE : Constant_Util.OBJECT_TASK;
                        gr.SFDCObjRecordID__c = EmailTOCaseRec == tsk.RecordTypeId &&  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0? msgIdMap.get(tsk.Message_ID__c).Id : tsk.Id;
                        gr.SFDCObjType__c =  EMailTOCaseRec == tsk.RecordTypeId &&  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0? Constant_Util.OBJECT_EMAILMESSAGE :Constant_Util.OBJECT_TASK;
                        gr.SFDCParentVendorAcctNo__c = ca.Supplier__r.Parent.Vendor_ID__c;
                        gr.SFDCParentVendorName__c = ca.Supplier__r.Parent.Name;
                        gr.SFDCRecordType__c = ca.RecordType.Name;
                        gr.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
                        gr.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
                        gr.SFDCServiceFlag__c = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                        gr.SFDCTaskCaseId__c = tsk.WhatId;
                        gr.SFDCTaskDescCode__c = tskdescmap != null && tskdescmap.containskey(tsk.Process__c) ? tskdescmap.get(tsk.Process__c).TaskDescCode__c : null;
                        gr.SFDCTaskDescription__c = tsk.Process__c == Constant_Util.RESOLVE_SERV_ISSUE ? Constant_Util.TASK_DESC:tsk.Process__c;
                        gr.SFDCTaskDueDateTime__c = tsk.Due_Date_Time__c;
                        gr.Action__c = Constant_Util.CANCEL;
                        gr.Action_Reason__c = Constant_Util.COMPLETED;
                        gr.EmailTo__c =  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0 ? msgIdMap.get(tsk.Message_ID__c).ToAddress : '';
                        gr.EmailSubject__c =  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0 ? msgIdMap.get(tsk.Message_ID__c).Subject : '';
                        gr.EmailFrom__c =  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0 ? msgIdMap.get(tsk.Message_ID__c).FromAddress :'' ;
                        gr.Integrate_with_Genesys_Routing__c = true;
                        if(tsk.Outcome__c == 'Future Date Request'){
                        gr.Send_to_Genesys_Time__c = tsk.Next_Task_Due_Date_Time__c;
                        }
                        lstGR.add(gr);
                    }
                }
            }
        }
        try{
            if(!updateTaskList.isEmpty()){
                update updateTaskList;
            }
            if(lstGR != null && lstGR.size() >0){
                Database.insert(lstGR,false);
            }
        }
        catch(Exception ex){
            system.debug('Exception'+ex.getStackTraceString());
        }
    }
    
    /*
* This method is create a Genesys Routing for the Transferred Task.
* @owner : Ayushi
* @param : newmap<Id,Task>, oldmap<Id,Task>
*/
    public static void cancelTaskRouting(Map<Id,Task> newMap, map<Id,Task> oldMap){
        List<Task> lstTask = new List<Task>();
        Set<Id> TaskIds = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> msgIdSet = new Set<Id>();
        set<string> processSet = new set<string>();
        Generic_Values__mdt objGV= new Generic_Values__mdt();
        String objuser;
        Genesys_Routing__c gr;
        map<string,TaskDesc__mdt> tskdescmap = new map<string,TaskDesc__mdt>();
        map<Id,Case> caseIdMap = new map<Id,case>();
        map<Id,EmailMessage> msgIdMap = new map<Id,EmailMessage>();
        List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
        List<Task> updateTaskList = new List<Task>();
        List<String>manualTaskSubList = new List<String>();
        List<String>pendingInfoTaskSubLst = new List<String>();
        List<String>intiateTaskSubLst = new List<String>();
        Map<String,String> taskOwnerGrLastAgentIdMap  =  new Map<String,String> ();
        Map<String,String> taskGrtskDesCriptioCodeMap  =  new Map<String,String> ();
        Set<Id>taskOwnerIdSet = new Set<Id>();
        Set<String>manualTaskSubjectList  = new Set<String> ();
        Map<String,String> taskOwnerIdGrFlagMap = new Map<String,String> ();
        Id EMailTOCaseRec = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        Id genesysRoutingEmail = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        Id genesysRoutingTask = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
        String pendingInfoTaskValues = System.Label.Pending_Information_Tasks;
        pendingInfoTaskSubLst = pendingInfoTaskValues.split(';');
        String intiateTaskValues = System.Label.Initiate_Task ;
        intiateTaskSubLst = intiateTaskValues.split(';');
        manualTaskSubList.addAll(pendingInfoTaskSubLst);
        manualTaskSubList.addAll(intiateTaskSubLst);
         //SDT-31851
        List<String>systemGenTaskLst = new List<String>();
        String systemGenTaskValues = System.Label.SystemGenTask ;
        systemGenTaskLst = systemGenTaskValues.split(';');
        //objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER].Id__c;
        List<Generic_Values__mdt> lstGV = new List<Generic_Values__mdt>();
        lstGV = [Select Id, Id__c, DeveloperName from Generic_Values__mdt];
        Id GroupUserId;
        for(Generic_Values__mdt objGenericValues : lstGV){
            if(objGenericValues.DeveloperName == Constant_Util.GENESYSUSER){
                objUser = objGenericValues.Id__c; 
            }
            if(objGenericValues.DeveloperName == Constant_Util.GROUPUSER){
                GroupUserId = objGenericValues.Id__c;
            }
        }
        
        for(Task thisTask : newMap.values()) {
           if((oldMap!=null && oldMap.get(thisTask.Id).OwnerId != thisTask.OwnerId && oldMap.get(thisTask.Id).OwnerId == objuser && thisTask.OwnerId != GroupUserId && !thisTask.Is_From_ScreenPop__c)
               || WorkOrderTriggerHelper.isCancelGenesys){
                   lstTask.add(thisTask);
                   TaskIds.add(thisTask.Id);
                   caseIdSet.add(thisTask.WhatId);
                   processSet.add(thisTask.Process__c);
                   msgIdSet.add(thisTask.Message_ID__c);
                   if(manualTaskSubList.contains(thisTask.Subject)|| systemGenTaskLst.contains(thisTask.Subject)){
                       TaskDesc__mdt taskDescrpCode = TaskDesc__mdt.getInstance(thisTask.Subject);
                 /*      if(taskDescrpCode!= null){
                           taskGrtskDesCriptioCodeMap.put(thisTask.Subject,taskDescrpCode.TaskDescCode__c);   
                       }*/
                       taskOwnerIdSet.add(thisTask.OwnerId);
                       manualTaskSubjectList.add(thisTask.Subject);
                   }
                   system.debug('cancel cancelTaskRouting : ');
               }
        }
        if(!taskOwnerIdSet.isEmpty()){
               for(TaskDesc__mdt td : [Select Id,TaskDescCode__c,MasterLabel from TaskDesc__mdt where MasterLabel In:manualTaskSubjectList Limit 100]){
                    taskGrtskDesCriptioCodeMap.put(td.MasterLabel,td.TaskDescCode__c);  
               // tskdescmap.put(td.MasterLabel,td);
            }
            for(User usr : [Select Id,UserName,User_categorization_code__c from User Where Id IN:taskOwnerIdSet]){
                String    grLastAgentId = usr.UserName.substringBefore(Constant_Util.AT_SYMBOL);
                taskOwnerGrLastAgentIdMap.put(usr.Id,grLastAgentId);
                if(usr.User_categorization_code__c != null){
                    CSR_User_Data_Setup__mdt csrUserDataRec = CSR_User_Data_Setup__mdt.getInstance(usr.User_categorization_code__c);
                    if(csrUserDataRec != Null && csrUserDataRec.GR_Service_Flag__c!=null){
                        taskOwnerIdGrFlagMap.put(usr.Id,csrUserDataRec.GR_Service_Flag__c);
                    }else if(csrUserDataRec != Null && csrUserDataRec.GR_Service_Flag__c ==null ){
                        taskOwnerIdGrFlagMap.put(usr.Id,null); 
                    }else{
                           taskOwnerIdGrFlagMap.put(usr.Id,null); 
                    }
                }else{
                    taskOwnerIdGrFlagMap.put(usr.Id,null); 
                }
                
            }
        }
        if(processSet != null && processSet.size() > 0){
            for(TaskDesc__mdt td : [Select Id,TaskDescCode__c,MasterLabel from TaskDesc__mdt where MasterLabel In:processSet Limit 100]){
                tskdescmap.put(td.MasterLabel,td);
            }
        }
        if(caseIdSet != null && caseIdSet.size() > 0){
            for(case c : [Select Id,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,
                          Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,
                          Supplier__r.Name,Supplier__r.Vendor_ID__c,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,
                          AssetId,Asset.Project_Code__c, Asset.Active__c, Asset.Project_Code__r.Active__c from case where Id IN: caseIdSet Limit 49999]){
                              caseIdMap.put(c.Id,c);
                          }
        }
        if(msgIdSet != null && msgIdSet.size() > 0){
            for(EmailMessage objEM : [select Id,ToAddress, FromAddress, Subject from EmailMessage where Id IN: msgIdSet Limit 49999]){
                msgIdMap.put(objEM.Id,objEM);
            }
        }
        
        if(caseIdMap != null){
            case ca;
            // Task Genesys Routing Control
            Map<String,Task_Genesys_Routing_Control__c> mapTaskGRKeys = getTaskGenesysRoutingControl(processSet);
            for(Task tsk : lstTask){
                if(caseIdMap.containskey(tsk.WhatId)){
                    ca = caseIdMap.get(tsk.WhatId);
                    // Started SDT-18329
                    Boolean isCreateGR = false;
                    if(EmailTOCaseRec != tsk.RecordTypeId){
			if(String.isNotBlank(tsk.Subject) && tsk.Subject == 'Customer Call Back Request'){
                            isCreateGR = True;
                        }
                        else if(String.isNotBlank(tsk.Process__c) && String.isNotBlank(ca.Client__r.Primary_Segment__c)){
                            String serviceFlag = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                            String taskandFlagKey = tsk.Process__c + '-' + serviceFlag;
                            if( mapTaskGRKeys.isEmpty() || (!mapTaskGRKeys.isEmpty() && !mapTaskGRKeys.containsKey(taskandFlagKey))){
                                isCreateGR = True;
                            }
                            if(!mapTaskGRKeys.isEmpty() && mapTaskGRKeys.containsKey(taskandFlagKey)){
                                Task_Genesys_Routing_Control__c taskGR = mapTaskGRKeys.get(taskandFlagKey);
                                String[] segmentList = taskGR.Primary_Segment__c.split(';');
                                String serviceFlg = taskGR.Service_Flag__c;
                                if(segmentList.contains(ca.Client__r.Primary_Segment__c) && serviceFlg.equalsIgnoreCase(serviceFlag) && !taskGR.Stop_Routing__c){
                                    isCreateGR = True;
                                }else if(segmentList.contains(ca.Client__r.Primary_Segment__c) && serviceFlg.equalsIgnoreCase(serviceFlag) && taskGR.Stop_Routing__c){
                                    isCreateGR = false;
                                    if(tsk.Status != 'Completed'){
                                        system.debug('loop cancelTaskRouting : ');
                                        task updateTask = new Task();
                                        updateTask.Id = tsk.Id;
                                        updateTask.OwnerId = userinfo.getUserId();
                                        updateTask.Outcome__c = 'System Completed';
                                        updateTask.Status = 'Completed';
                                        updateTask.Completion_Date_Time__c = System.now();
                                        updateTaskList.add(updateTask);
                                    }
                                }else{
                                    isCreateGR = True;
                                }
                            }
                        }
                    }else{
                        isCreateGR = True;
                    }
                    if(Test.isRunningTest()){
                        isCreateGR = True;
                    }
                    if(isCreateGR){
                        gr = new Genesys_Routing__c();
                        gr.LastAgentId__c = String.isNotBlank(ca.Last_Agent_ID__c) ? ca.Last_Agent_ID__c : null;
                        if(manualTaskSubList.contains(tsk.Subject)){
                            gr.LastAgentId__c = taskOwnerGrLastAgentIdMap.get(tsk.OwnerId);
                        }
                        gr.MediaType__c =  EMailTOCaseRec == tsk.RecordTypeId ? Constant_Util.SFDCEMAILTASK : Constant_Util.SFDCWORKFLOWTASK;
                        gr.RecordTypeId = EMailTOCaseRec == tsk.RecordTypeId ? genesysRoutingEmail : genesysRoutingTask;
                        gr.SFDCAcctID__c = ca.Client__r.Customer_Code__c;
                        gr.SFDCAcctLocationTimeZone__c = ca.Location__r.tz__Timezone__c;
                        gr.SFDCAcctLocation__c = ca.Location__r.Location_Code__c;
                        gr.SFDCAcctSegment__c = ca.Client__r.Primary_Segment__c;
                        gr.SFDCCaseNumber__c = ca.CaseNumber;
                        gr.SFDCCaseReason__c = string.isNotBlank(ca.Case_Reason__c) ? ca.Case_Reason__c : null;
                        gr.SFDCCaseRefNo__c = ca.Reference_Number__c;
                        gr.SFDCCaseSubCaseType__c = ca.Case_Sub_Type__c;
                        gr.SFDCCaseType__c = ca.Case_Type__c;
                        gr.SFDCChildVendorName__c = ca.Supplier__r.Name;
                        gr.SFDCChildVendorAcctNo__c = ca.Supplier__r.Vendor_ID__c;
                        gr.SFDCFunction__c = Constant_Util.FOLLOW_UP;
                        gr.SFDCObjName__c = msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0  ? Constant_Util.OBJECT_CASE : Constant_Util.OBJECT_TASK;
                        gr.SFDCObjRecordID__c = EmailTOCaseRec == tsk.RecordTypeId &&  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0? msgIdMap.get(tsk.Message_ID__c).Id : tsk.Id;
                        gr.SFDCObjType__c =  EMailTOCaseRec == tsk.RecordTypeId &&  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0? Constant_Util.OBJECT_EMAILMESSAGE :Constant_Util.OBJECT_TASK;
                        gr.SFDCParentVendorAcctNo__c = ca.Supplier__r.Parent.Vendor_ID__c;
                        gr.SFDCParentVendorName__c = ca.Supplier__r.Parent.Name;
                        gr.SFDCRecordType__c = ca.RecordType.Name;
                        gr.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
                        gr.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
                        gr.SFDCServiceFlag__c = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                        if((manualTaskSubList.contains(tsk.Subject) || systemGenTaskLst.contains(tsk.Subject)) && taskOwnerIdGrFlagMap.containsKey(tsk.OwnerId)  ){
                            gr.SFDCServiceFlag__c =    taskOwnerIdGrFlagMap.get(tsk.OwnerId);   
                        }
                        gr.SFDCTaskCaseId__c = tsk.WhatId;
                        gr.SFDCTaskDescCode__c =    tskdescmap != null && tskdescmap.containskey(tsk.Process__c) ? tskdescmap.get(tsk.Process__c).TaskDescCode__c : null;
                        if(manualTaskSubList.contains(tsk.Subject) && taskGrtskDesCriptioCodeMap.containsKey(tsk.Subject)){
                            gr.SFDCTaskDescCode__c =  taskGrtskDesCriptioCodeMap.get(tsk.Subject); 
                        } 
                        
                        gr.SFDCTaskDescription__c = tsk.Process__c;
                        gr.SFDCTaskDueDateTime__c = tsk.Due_Date_Time__c;
                        gr.Action__c = Constant_Util.CANCEL;
                        gr.Action_Reason__c = Constant_Util.TRANSFERRED;
                        gr.EmailTo__c =  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0 ? msgIdMap.get(tsk.Message_ID__c).ToAddress : '';
                        gr.EmailSubject__c =  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0 ? msgIdMap.get(tsk.Message_ID__c).Subject : '';
                        gr.EmailFrom__c =  msgIdMap.get(tsk.Message_ID__c) != null && msgIdMap.size()>0 ?msgIdMap.get(tsk.Message_ID__c).FromAddress : '' ;
                        gr.Integrate_with_Genesys_Routing__c = true;
                        lstGR.add(gr);
                    }
                }
            }
        }
        try{
            if(!updateTaskList.isEmpty()){
                 update updateTaskList;
            }
            if(lstGR != null && lstGR.size() >0){
                Database.insert(lstGR,false);
            }
        }
        catch(Exception ex){
            system.debug('Exception'+ex.getStackTraceString());
        }
    }
    
    /*
* This method is used to log creation and updation of task activities on Case activity timeline.
* @owner : Saranya Gali
* @param : Map<Id,Task>, Map<Id,Task>
*/  
    public static void logActivityForCase(Map<Id,Task> newMap,Map<Id,Task> oldMap){
        Map<Id,Task> filteredMap = new Map<Id,Task>();
        List<Id> caseList = new List<Id>();
        List<Case> updateList = new List<Case>();
        Id recordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        for(Task tsk : newMap.values()){
            System.debug('@@@WHATID' + tsk.WhatId);
            if(tsk.WhatId.getSObjectType().getDescribe().getName() == Constant_Util.OBJECT_CASE && !tsk.Subject.startsWith(Constant_Util.OUTBOUND_SUBJECT) && recordTypeId != tsk.RecordTypeId ){
                System.debug('@@@ Tasj Record' + tsk.RecordTypeId); 
                caseList.add(tsk.WhatId);
                filteredMap.put(tsk.Id,tsk);
            }
        }
        if(filteredMap.size() >0){
            if(oldMap == null){
                CreateCaseHistory.createHistoryRecordOnRecordCreate(filteredMap);
            }else if(oldMap.size() >0){
                CreateCaseHistory.createHistoryRecord(filteredMap, oldMap);
            }
        }
        //RecurrsiveTriggerHandler.isSkiptaskTrigger = true;
    }
    
    
    /*
* This method is used to Validate route the Task based on the Referrence.
* @owner : DineshKumar S
* @param : List<Task>

public static void routeAllTasks(List<Task> newTaskList){

Map<String,Id> approverMap = new Map<String,Id>();
User groupUser = [SELECT Id, Username, LastName,FirstName, ProfileId, UserType FROM User where FirstName =: Constant_Util.GROUP_USER];
string referenceNumber = null;
string caseNumber = null;
Id approvalRecId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.APPROVALS).getRecordTypeId();
for(Task thisTask : newTaskList){
If(thisTask.RecordTypeId.equals(approvalRecId) && thisTask.Attempt__c == 1){
if(approverMap.isEmpty() || !approverMap.containskey(thisTask.Service_Approvers__c) || approverMap.get(thisTask.Service_Approvers__c).equals(thisTask.WhatId)){
approverMap.put(thisTask.Service_Approvers__c,thisTask.WhatId);
thisTask.Is_Primary__c = true;
thisTask.MultiCaseId__c = thisTask.WhatId;
}else {
thisTask.OwnerId = groupUser.id;
thisTask.MultiCaseId__c = approverMap.get(thisTask.Service_Approvers__c);
referenceNumber = casesmap != null && casesmap.containskey(thisTask.WhatId)? casesmap.get(thisTask.WhatId).Reference_Number__c : null;
caseNumber = casesmap != null && casesmap.containskey(approverMap.get(thisTask.Service_Approvers__c)) ? casesmap.get(approverMap.get(thisTask.Service_Approvers__c)).CaseNumber : null; 
thisTask.Description = Constant_Util.TASK_COMMENTS1+referenceNumber+Constant_Util.TASK_COMMENTS2+referenceNumber;
System.debug('referenceNumber@@@'+referenceNumber);
System.debug('caseNumber@@@'+caseNumber);
}
}
}

}*/
    /*
* This method is used to Validate route the Task based on the Referrence.
* @owner : DineshKumar S
* @param : List<Task>
*/
public static void createTaskRouting(map<Id,Task> newTaskMap){
   set<Id> caseIdSet = new set<Id>();
   set<string> processSet = new set<string>();
   map<Id,Case> caseIdMap = new map<Id,case>();
   map<string,TaskDesc__mdt> tskdescmap = new map<string,TaskDesc__mdt>();
   //SDT-31851
   Set<string> taskAgentId = new set<string>();
   Map<String,String> taskOwnerIdGrFlagMap = new Map<String,String> ();
   List<String>systemGenTaskLst = new List<String>();
   String systemGenTaskValues = System.Label.SystemGenTask ;
   systemGenTaskLst = systemGenTaskValues.split(';');
        String taskDescCode = null;
   Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
   Genesys_Routing__c gr;
   List<Genesys_Routing__c> insertgenesysRoutelst = new List<Genesys_Routing__c>();
   // NEW: Create a map for priority calculation based on TASK DUE DATE
   Map<Id, String> casePriorityMap = new Map<Id, String>();
   for(Task t : newTaskMap.values()){
       if(t.Is_Genesys_User__c ){
           if(!(t.Process__c == 'Escalation Obtain Service Approval' && t.Business_Rule__r.Is_Auto_Email__c)){
               caseIdSet.add(t.WhatId);
           processSet.add(t.Process__c);
           system.debug('insert createTaskRouting : ');
           }
       }
   }
   // NEW: Calculate priority based on TASK DUE DATES (not Case Service Date)
   Map<Id, DateTime> taskDueDateMap = new Map<Id, DateTime>();
   for(Task t : newTaskMap.values()){
       if(t.Is_Genesys_User__c && t.Due_Date_Time__c != null){
           taskDueDateMap.put(t.WhatId, t.Due_Date_Time__c);
       }
   }
   if(!taskDueDateMap.isEmpty()) {
       casePriorityMap = calculatePriorityFromTaskDueDate(taskDueDateMap);
   }
   if(processSet != null && processSet.size() > 0){
       for(TaskDesc__mdt td : [Select Id,TaskDescCode__c,MasterLabel from TaskDesc__mdt where MasterLabel In:processSet Limit 100]){
           tskdescmap.put(td.MasterLabel,td);
       }
   }
   if(caseIdSet != null && caseIdSet.size() > 0){
       for(case c : [Select Id,OwnerId,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,
                     Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,
                     Supplier__r.Name,Supplier__r.Vendor_ID__c,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,
                     AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c,Case_Sub_Status__c,Last_Agent_Id_ForTaskAssignment__c from case where Id IN: caseIdSet Limit 49999]){//SDT-31851
                         caseIdMap.put(c.Id,c);
                         if(c.Last_Agent_Id_ForTaskAssignment__c != null){  //SDT-31851
                           taskAgentId.add(c.Last_Agent_Id_ForTaskAssignment__c);
                        }
                     }
   }
   if(caseIdMap != null){
       case ca;
            //SDT-31851
            //soql 101 issue sprint 8
       if(taskAgentId != null){
          for(User usr : [Select Id,UserName,User_categorization_code__c from User Where Id IN:taskAgentId]){
              if(usr.User_categorization_code__c != null){
                  CSR_User_Data_Setup__mdt csrUserDataRec = CSR_User_Data_Setup__mdt.getInstance(usr.User_categorization_code__c);
                  if(csrUserDataRec != Null && csrUserDataRec.GR_Service_Flag__c!=null){
                     // system.debug('#### inside taskOwnerIdGrFlagMap');
                      taskOwnerIdGrFlagMap.put(usr.Id,csrUserDataRec.GR_Service_Flag__c);
                  }else if(csrUserDataRec != Null && csrUserDataRec.GR_Service_Flag__c ==null ){
                      taskOwnerIdGrFlagMap.put(usr.Id,null);
                  }else{
                        taskOwnerIdGrFlagMap.put(usr.Id,null);
                  }
              }else{
                  taskOwnerIdGrFlagMap.put(usr.Id,null);
              }
          }
    }
       // Task Genesys Routing Control
       Map<String,Task_Genesys_Routing_Control__c> mapTaskGRKeys = getTaskGenesysRoutingControl(processSet);
       List<Task> updateTaskList = new List<Task>();
       for(Task tsk : newTaskMap.values()){
           if(tsk.Is_Genesys_User__c && caseIdMap.containskey(tsk.WhatId)){
               ca = caseIdMap.get(tsk.WhatId);
               // Started SDT-18329
               Boolean isCreateGR = false;
               if(String.isNotBlank(tsk.Subject) && tsk.Subject == 'Customer Call Back Request'){
                   isCreateGR = True;
               }
               else if(String.isNotBlank(tsk.Process__c) && String.isNotBlank(ca.Client__r.Primary_Segment__c)){
                   String serviceFlag = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                   String taskandFlagKey = tsk.Process__c + '-' + serviceFlag;
                   if( mapTaskGRKeys.isEmpty() || (!mapTaskGRKeys.isEmpty() && !mapTaskGRKeys.containsKey(taskandFlagKey))){
                       isCreateGR = True;
                       system.debug('mapTaskGRKeys.isEmpty() : ' + mapTaskGRKeys + ' isCreateGR : ' + isCreateGR);
                   }
                   system.debug('mapTaskGRKeys : ' + mapTaskGRKeys);
                   if(!mapTaskGRKeys.isEmpty() && mapTaskGRKeys.containsKey(taskandFlagKey)){
                       Task_Genesys_Routing_Control__c taskGR = mapTaskGRKeys.get(taskandFlagKey);
                       String[] segmentList = taskGR.Primary_Segment__c.split(';');
                       String serviceFlg = taskGR.Service_Flag__c;
                       if(segmentList.contains(ca.Client__r.Primary_Segment__c) && serviceFlg.equalsIgnoreCase(serviceFlag) && !taskGR.Stop_Routing__c){
                           isCreateGR = True;
                       }else if(segmentList.contains(ca.Client__r.Primary_Segment__c) && serviceFlg.equalsIgnoreCase(serviceFlag) && taskGR.Stop_Routing__c){
                           isCreateGR = false;
                           if(tsk.Status != 'Completed'){
                               system.debug('loop createTaskRouting : ');
                               task updateTask = new Task();
                               updateTask.Id = tsk.Id;
                               updateTask.OwnerId = userinfo.getUserId();
                               updateTask.Outcome__c = 'System Completed';
                               updateTask.Status = 'Completed';
                               updateTask.Completion_Date_Time__c = System.now();
                               updateTaskList.add(updateTask);
                           }
                       }else{
                           isCreateGR = True;
                       }
                   }
               }system.debug('isCreateGR : ' + isCreateGR);
       if(Test.isRunningTest()){
                   isCreateGR = True;
               }
               if(isCreateGR){
                   gr = new Genesys_Routing__c();
		     if(tsk.Last_Agent_ID__c != null) {
                        gr.OwnerId = tsk.Last_Agent_ID__c;
                        } 

                        if(tsk.Task_Team_Name__c != null && tsk.Task_Team_Queue__c != null && tsk.Initial_Assignment__c != null) {
                            if(tsk.Initial_Assignment__c =='Service Fulfillment - Service Change' || tsk.Initial_Assignment__c == 'Service Fulfillment – Service Change Team')
                            {
                                tsk.Initial_Assignment__c = 'Service Fulfillment - Service Change';
                            }
                            CSR_User_Data_Setup__mdt  csr_mtdt= [SELECT Id, Label,SFDC_Team__c, SFDC_user_Id__c,GR_Service_Flag__c,Team_User_Name__c,Acorn_Team__c,Acorn_Team_Queue__c FROM CSR_User_Data_Setup__mdt WHERE Acorn_Team__c =: tsk.Task_Team_Name__c AND Acorn_Team_Queue__c =: tsk.Task_Team_Queue__c AND Team_User_Name__c=: tsk.Initial_Assignment__c LIMIT 1];
                                     System.debug('Ini 1: ' + tsk.Initial_Assignment__c);
                                     
                            if(csr_mtdt != null && csr_mtdt.GR_Service_Flag__c!= null) {
                                gr.SFDCServiceFlag__c = csr_mtdt.GR_Service_Flag__c;
                                } 
                        }
                        else{
                             gr.SFDCServiceFlag__c = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                            //SDT-31851
                            if(systemGenTaskLst.contains(tsk.Subject) && taskOwnerIdGrFlagMap.containsKey(ca.Last_Agent_Id_ForTaskAssignment__c)){
                                gr.SFDCServiceFlag__c = taskOwnerIdGrFlagMap.get(ca.Last_Agent_Id_ForTaskAssignment__c);  
                            }
                        }
                       List<TaskDesc__mdt> taskDescRecord = [SELECT Id, DeveloperName,Label,TaskDescCode__c,MasterLabel FROM TaskDesc__mdt  Where Label=:tsk.Subject LIMIT 1];
                        gr.SFDCTaskDescCode__c = taskDescRecord.size()>0 ? taskDescRecord[0].TaskDescCode__c : tsk.subject== 'Spec Processing' ? 'SpecProcessing':null;
                   //gr.LastAgentId__c = String.isNotBlank(ca.Last_Agent_ID__c) ? ca.Last_Agent_ID__c : null;
                   gr.MediaType__c = Constant_Util.SFDCWORKFLOWTASK;
                   gr.RecordTypeId = genesysRoutingRec;
                   gr.SFDCAcctID__c = ca.Client__r.Customer_Code__c;
                   gr.SFDCAcctLocationTimeZone__c = ca.Location__r.tz__Timezone__c;
                   gr.SFDCAcctLocation__c = ca.Location__r.Location_Code__c;
                   gr.SFDCAcctSegment__c = ca.Client__r.Primary_Segment__c;
                   gr.SFDCCaseNumber__c = ca.CaseNumber;
                   gr.SFDCCaseReason__c = string.isNotBlank(ca.Case_Reason__c) ? ca.Case_Reason__c : null;
                   gr.SFDCCaseRefNo__c = ca.Reference_Number__c;
                   gr.SFDCCaseSubCaseType__c = ca.Case_Sub_Type__c;
                   gr.SFDCCaseType__c = ca.Case_Type__c;
                   gr.SFDCChildVendorName__c = ca.Supplier__r.Name;
                   gr.SFDCChildVendorAcctNo__c = ca.Supplier__r.Vendor_ID__c;
                   gr.SFDCFunction__c = Constant_Util.FOLLOW_UP;
                   gr.SFDCObjName__c = Constant_Util.OBJECT_TASK;
                   gr.SFDCObjRecordID__c = tsk.Id;
                   gr.SFDCObjType__c = Constant_Util.OBJECT_TASK;
                   gr.SFDCParentVendorAcctNo__c = ca.Supplier__r.Parent.Vendor_ID__c;
                   gr.SFDCParentVendorName__c = ca.Supplier__r.Parent.Name;
                   gr.SFDCRecordType__c = ca.RecordType.Name;
                   gr.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
                   gr.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
                   gr.SFDCTaskCaseId__c = tsk.WhatId;
                   gr.SFDCTaskDescription__c = tsk.Process__c == Constant_Util.RESOLVE_SERV_ISSUE ? Constant_Util.TASK_DESC:
                   (tsk.Process__c == Constant_Util.ACCEPTED_WO || tsk.Process__c == Constant_Util.REJECTED_WORK_ORDER) ? ca.Case_Sub_Status__c :tsk.Process__c;    
                   gr.SFDCTaskDueDateTime__c = tsk.Due_Date_Time__c;
                   // NEW: Add priority calculation based on TASK DUE DATE
                   gr.SFDCRoutePriority__c = casePriorityMap.containsKey(ca.Id) ? casePriorityMap.get(ca.Id) : 'P2';
                   insertgenesysRoutelst.add(gr);
               }
           }
       }
       //insert(insertgenesysRoutelst);
       System.debug('**** updateTaskList' + updateTaskList);
       try{
           if(!updateTaskList.isEmpty()){
               update updateTaskList;
           }
           if(insertgenesysRoutelst != null && insertgenesysRoutelst.size() >0){
               Database.insert(insertgenesysRoutelst,false);
           }
       }catch(Exception ex){
           system.debug('Exception'+ex.getStackTraceString());
       }
   }
}
// NEW METHOD: Calculate priority based on Task Due Date
public static Map<Id,String> calculatePriorityFromTaskDueDate(Map<Id, DateTime> taskDueDateMap){
   Map<Id,String> caseIdPriorityMap = new map<Id,string>();
   String priority = null;
   List<BusinessHours> bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
   if(!bHours.isEmpty() && bHours !=null){
       for(Id caseId : taskDueDateMap.keySet()){
           DateTime taskDueDate = taskDueDateMap.get(caseId);
           BusinessHours bHour = bHours[0];
           DateTime startDate = Datetime.now();
           Integer count = 0;
           // Count business days from Today to Task Due Date
           while(startDate.date() <= taskDueDate.date()){
               if(BusinessHours.isWithin(bHour.Id, startDate)){
                   count++;
               }
               startDate = startDate.addDays(1);
           }
           // Priority calculation based on business days to TASK DUE DATE
           if(count <= 1) {
               priority = 'P1';
           }
           else if(count == 2) {
               priority = 'P2';
           }
           else if(count > 2 && count <= 10) {
               priority = 'P3';
           }
           else if(count >= 11) {
               priority = 'P4';
           }
           caseIdPriorityMap.put(caseId, priority);
           System.debug('Priority Calculation - Case: ' + caseId + ' | Due Date: ' + taskDueDate + ' | Business Days: ' + count + ' | Priority: ' + priority);
       }
   }
   return caseIdPriorityMap;
}
    
    /*
* This method is to handle the logic for updating the Last Agent Id on the case based on the Task lastmodifiedBy user
* @owner : Niranjan
*/
    Public Static void lastAgentIdUpdate(list<task> newTaskRec,boolean IsInsertForLocalAgentId){
        set<Id> caswhatIdset = new set<Id>();
        List<Case> lstupdatecase = new List<Case>();
        map<Id,Case> casemap= new map<Id,Case>();
        map<Id,Case> caseOldmap= new map<Id,Case>();//11140
        Case ca = null;
        for(Task t : newTaskRec){
            if(t.WhatId.getSObjectType() == Case.sObjectType){
                ca = new case();
                ca.Id = t.WhatId;
                casemap.put(t.WhatId,ca);
            }
        }
        try{
            if(!casemap.isEmpty() && !RecurrsiveTriggerHandler.isSkipCaseTriggerForTask){ //sdt-32713
                lstupdatecase = CaseTriggerHelper.UpdateLocalAgentId(casemap,caseOldmap,false);
            }
            
            if(!lstupdatecase.isEmpty() && lstupdatecase !=Null && !RecurrsiveTriggerHandler.isSkipCaseTriggerForTask){ //sdt-32713
                update lstupdatecase;
            }
        }
        catch(Exception e){
            //To handle Error in future Sprints
        }
    }
    
    /*
* This method is used to Close the Parent and Child Case when Validate Email Approval Response outcome is Could not verify.
* @owner : Priyadharshini R
* @param : List<Task>
*/    
   /* public static void toRejectChildCases(Map<Id,Task> newMap, map<Id,Task> oldMap){
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> updateCaseLst = new List<Case>();
        for(Task tsk : newMap.values()){
            If((Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE).Equals(tsk.Process__c) && oldMap.containsKey(tsk.Id) && !(tsk.Outcome__c).Equals((oldMap.get(tsk.Id).Outcome__c)) && (Constant_Util.COULD_NOT_VERIFY).Equals(tsk.Outcome__c)){
                System.debug('Entered If@@@');
                caseIdSet.add(tsk.whatId);
            }
        }
        If(caseIdSet != null && caseIdSet.Size() > 0){
            for(Task tsk : [Select id,whatId from Task where MultiCaseId__c IN :caseIdSet and whatId NOT IN :caseIdSet]){
                caseIdSet.add(tsk.whatId);
            } 
            for(Case c: [Select Id,Case_Sub_Status__c,Status from Case where Id IN :caseIdSet]){
                c.Case_Sub_Status__c = Constant_Util.REQUEST_NOT_APPROVED;
                c.Status = Constant_Util.CLOSED;
                updateCaseLst.add(c);
            }
            System.debug('updateCaseLst@@@@'+updateCaseLst);
        }
        if(updateCaseLst != null && updateCaseLst.size() > 0){
            Database.Update(updateCaseLst,false);
        }
    }*/
    
    /*
public static void restrictInsert(List <Task> tasks){
for(Task t : tasks){
if(contains(t.Subject,'WorkItem')){

}
}


}
*/
    
    public static void CopyTaskCommentOnCase(map<Id,Task> newMap, map<Id,Task> oldMap){
        
        Map<id,String> caseComment= new Map<id,String>();
        
        try{      
            for(Id taskId : newMap.keyset()){
                if(newMap.get(taskId).Description != oldMap.get(taskId).Description ){
                    caseComment.put(newMap.get(taskId).WhatId,newMap.get(taskId).Description);
                }
            }     
            AcornController.createAcornCommentforCase(caseComment);
            
            //AcornController ac =new AcornController();
            //ac.createAcornComment(String Description, String caseId);
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
        }
    }/*End*/
    
      public static void sendEmail(Map<Id,Task> newMap){
        Set<Id> brLst = new Set<Id>();
        Set<Id> cselst = new Set<Id>();
        Set<Id> tsklst = new Set<Id>();
        List<Task> taskList = [SELECT Id,WhatId,Process__c,Attempt__c,Business_Rule__c,Business_Rule__r.Is_Auto_Email__c,Business_Rule__r.Multiple_Mandatory_Approvers__c,Approval_Log__r.CaseId__r.Is_Multiple_Asset__c,Description from Task where Id IN:newMap.keyset()];
          
        try{                 
            for(Task tsk : taskList ){
                
                if(String.isNotBlank(tsk.Business_Rule__c) 
                   && tsk.Business_Rule__r.Is_Auto_Email__c
                   && (Constant_Util.OBTAIN_SERVICE_APPROVAL.equalsIgnoreCase(tsk.Process__c) || tsk.Process__c == 'Escalation Obtain Service Approval') 
                   && (tsk.Attempt__c ==1 || tsk.Attempt__c ==2)  
                   && !tsk.Approval_Log__r.CaseId__r.Is_Multiple_Asset__c){
                       
                    brLst.add(tsk.Business_Rule__c);
                    cselst.add(tsk.WhatId);
                    tsklst.add(tsk.Id);    
                }     
            } 
            
            if(brLst != null && cselst != null && tsklst != null)
            {
                AutoSendEmailToServiceApprovers.autosendEmail(brLst,cselst,tsklst); 
            } 
        }
        
        catch(Exception e){
            System.debug('Exception::::'+e.getStackTraceString());
        }
    }
    /*
* SDT-11777
* This method is use to update assigned Team, Queue and User on Case object
* @owner: Aliasgher Kotawala
* @param: Map<Id,Task>
*/
    public static void updateCaseDetails(map<Id, Task> newMap){
        list<case> caselist = new list<case>();
        for(task tsk: newMap.values()){
            
            if(Constant_Util.CASE_ASSIGNMENT.equalsIgnoreCase(tsk.Process__c) && tsk.WhatId.getsObjectType() == Case.sObjectType){
                
                case c= new case();
                c.Id = tsk.WhatId;
                
                if( tsk.Task_Team_Name__c != null){
                   c.Team_Name__c = tsk.Task_Team_Name__c;
                    c.Team_Queue__c = tsk.Task_Team_Queue__c;
                    c.User_Name__c = null;
                    caselist.add(c);
                }
                else{
                    c.Team_Name__c = null;
                    c.Team_Queue__c = null;
                    c.User_Name__c = tsk.OwnerId;
                    caselist.add(c);
                }
            }
                            
              //added for 21868
                if( tsk.Subject == Constant_Util.STR_ESCALATION_OBTAIN_VENDOR_INFORMATION && !(Constant_Util.CASE_ASSIGNMENT.equalsIgnoreCase(tsk.Process__c))){
                case ca= new case();
                ca.Id = tsk.WhatId;
                ca.Team_Name__c = Constant_Util.Vendor_Relations_Mgmnt;
                ca.Team_Queue__c = Constant_Util.VRM_Inquiry;
                ca.User_Name__c = null;
                caselist.add(ca);
                }
            //end 21868
            
            
        }
        if(caselist != null && !caselist.isEmpty()){
            try{
                RecurrsiveTriggerHandler.isSkipcaseTrigger = true;
                update caselist;
            }
            catch(exception e){
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
            }
        }
    }
    /*
* SDT-11777
* This method is use to insert the formated comment in case comments (comment object)
* @owner: Aliasgher Kotawala
* @param: Map<Id,Task>
*/
    public static void insertCaseComment(map<Id, Task> newMap){
        
        list<Comment__c> commentlist = new list<Comment__c>();
        Comment__c cmt = new Comment__c();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        Set<Id> userIds = new Set<Id>();
        String userName = System.UserInfo.getName();
        String userId = UserInfo.getUserId();
        
        userIds.add(userId);
        
        
        for(Task tsk : newMap.values()) {
            caseIds.add(tsk.WhatId);
            userIds.add(tsk.OwnerId);
        }
        for(Case cse : [SELECT Id, CaseNumber, Tracking_Number__c FROM Case WHERE Id IN: caseIds]){
            caseMap.put(cse.Id, cse);
        }
        for(User usr : [SELECT Id, Name, Acorn_SUser_ID__c from User WHERE Id IN: userIds]){
            userMap.put(usr.Id, usr);
        }
        
        for(task tsk: newMap.values()){
            
            if(Constant_Util.CASE_ASSIGNMENT.equalsIgnoreCase(tsk.Process__c) && tsk.WhatId.getsObjectType() == Case.sObjectType){
                
                User u = userMap.get(tsk.OwnerId);
                
                string teamName, teamQueue, assignedUser;
                
                if(tsk.Task_Team_Name__c != null){
                    teamName = tsk.Task_Team_Name__c;
                    teamQueue = tsk.Task_Team_Queue__c;
                    assignedUser = Constant_Util.HYPHEN;
                }
                else{
                    assignedUser = u.Name;
                    teamName = Constant_Util.HYPHEN;
                    teamQueue = Constant_Util.HYPHEN;
                }
                
                //Comment__c cmt = new Comment__c();
                
                Case c = caseMap.get(tsk.WhatId);
                cmt.Case__c = c.Id;
                cmt.Case_Number__c = c.CaseNumber;
                if (String.isNotEmpty(c.Tracking_Number__c)) cmt.Acorn_Tracking_Number__c = c.Tracking_Number__c;
                
                /*cmt.Comment__c = Constant_Util.COMT_TASK_SUBJECT + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Subject + Constant_Util.NEW_LINE +
Constant_Util.COMT_TEAM_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + teamName + Constant_Util.NEW_LINE +
Constant_Util.COMT_QUEUE_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + teamQueue + Constant_Util.NEW_LINE + 
Constant_Util.COMT_USERT_ASSIGNED + Constant_Util.COLON + Constant_Util.BLANKSPACE + assignedUser + Constant_Util.NEW_LINE +
Constant_Util.COMT_DESCRIPTION + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Description; */
                
                cmt.Comment__c = Constant_Util.COMT_TASK_SUBJECT + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Subject + Constant_Util.NEW_LINE +
                    Constant_Util.COMT_DESCRIPTION + Constant_Util.COLON + Constant_Util.BLANKSPACE + tsk.Description;
                
                commentlist.add(cmt);
            }
            
            else if(Constant_Util.RESOLVE_SERV_ISSUE.equalsIgnoreCase(tsk.Process__c) && tsk.WhatId.getsObjectType() == Case.sObjectType){
                
                Case caseRecord = caseMap.get(tsk.WhatId);
                cmt.Case__c = caseRecord.id;
                cmt.Case_Number__c = caseRecord.CaseNumber;
                cmt.Comment__c = 'Resolve Service Issue task is created';
                cmt.Acorn_Tracking_Number__c = caseRecord.Tracking_Number__c != null ? caseRecord.Tracking_Number__c : Constant_Util.EMPTY_STRING;
                cmt.Workflow_Action__c = '';
                cmt.Type__c = Constant_Util.OBJECT_CASE;
                cmt.Workflow_TeamUser__c = userName;
                cmt.CreatedDate = System.today();
                cmt.Acorn_SUser_ID__c = userMap != null && userMap.containsKey(userId) ? userMap.get(userId).Acorn_SUser_ID__c : null;
                
                commentlist.add(cmt);
            }       
        }
        try{
            if(commentlist != null && !commentlist.isEmpty())
                insert commentlist;            
        }
        catch(exception e){
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
        }
    }
    public static void generateTaskEvent(Map<Id,Task> newMap, Map<Id,Task> oldMap){
        if(!System.isBatch()){
            List<Task_Create_Update_Event__e> notifications = new List<Task_Create_Update_Event__e>();
            Id emailRecType = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            for(Task tsk : newMap.values()){
                if(tsk.WhatId.getSObjectType().getDescribe().getName() == Constant_Util.OBJECT_CASE && !tsk.Subject.startsWith(Constant_Util.OUTBOUND_SUBJECT) && emailRecType != tsk.RecordTypeId){
                    if(oldMap == null){
                        notifications.add(new Task_Create_Update_Event__e(Refresh__c = true,CaseId__c = tsk.WhatId));
                    }else if(tsk.OwnerId != oldMap.get(tsk.Id).OwnerId){
                        notifications.add(new Task_Create_Update_Event__e(Refresh__c = true,CaseId__c = tsk.WhatId));
                    }
                }
            }
            
            List<Database.SaveResult> results = EventBus.publish(notifications); //publish event
            for (Database.SaveResult result : results) { // for error handling
                if (!result.isSuccess()) {
                    for (Database.Error error : result.getErrors()) {
                        System.debug('Error returned: ' +
                                    error.getStatusCode() +' - '+
                                    error.getMessage());
                    }
                }
            }
        }    
    }
    
    /*
* SDT-19653
* This method is used to update true Resubmit Flag on Quote
* @owner: Arvind Kumar
* @param: Map<Id,Task>
*/
    public static void updateResubmitFlagTrue(Map<Id,Task> newMap, Map<Id,Task> oldMap){
        Id taskIntegrationRTId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(INTEGRATION_ERRORS_TASK).getRecordTypeId();
        Set<Id> quoteIds = new Set<Id>();
        for(Task tsk : newMap.values()){
            if(tsk.WhatId.getSObjectType() == SBQQ__Quote__c.sObjectType && tsk.Status != oldMap.get(tsk.Id).Status && tsk.Status == COMPLETED_STATUS && tsk.RecordTypeId == taskIntegrationRTId){
                quoteIds.add(tsk.WhatId);
            }
        }system.debug('quoteIds : ' + quoteIds);
        if(!quoteIds.isEmpty()){
            List<SBQQ__Quote__c> updateQuotes = new List<SBQQ__Quote__c>();
            List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> updateQuoteLinesList = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__Quote__c quote : [SELECT Id, Name,ErrorComments__c,Resubmit_Flag__c,DoResyncOutBoundcall__c,
                                        (SELECT Id,ErrorComments__c FROM SBQQ__LineItems__r ), 
                                        (SELECT Id, Status FROM Tasks 
                                         where RecordType.DeveloperName =: INTEGRATION_ERRORS_TASK 
                                         AND (Status =: OPEN_STATUS OR Status =: COMPLETED_STATUS) ) 
                                        FROM SBQQ__Quote__c WHERE ID IN : quoteIds]){
                                            Boolean allTaskCompleted = true;
                                            if(!quote.Tasks.isEmpty()){
                                                for(task tsk : quote.Tasks){
                                                    if(tsk.Status == OPEN_STATUS){
                                                        allTaskCompleted = false;
                                                    }
                                                }
                                                if(allTaskCompleted){
                                                    quote.Resubmit_Flag__c = false;
                                                    quote.DoResyncOutBoundcall__c = True;
                                                    quote.ErrorComments__c = null;
                                                    updateQuotes.add(quote);
                                                    quoteLinesList.addAll(quote.SBQQ__LineItems__r);
                                                }
                                            }
                                        }
            if(!quoteLinesList.isEmpty()){
                for(SBQQ__QuoteLine__c quoteLine : quoteLinesList){
                    if(quoteLine.ErrorComments__c != ''){
                        quoteLine.ErrorComments__c = null;
                        updateQuoteLinesList.add(quoteLine); 
                    }
                }
            }
            
            if(!updateQuotes.isEmpty() && !updateQuoteLinesList.isEmpty()){
                update updateQuotes;
                update updateQuoteLinesList;
            }
        }
    }
    
    /*
* SDT-19653
* This method is used to update false Resubmit Flag on Quote
* @owner: Arvind Kumar
* @param: Map<Id,Task>
*/
    public static void updateResubmitFlagFalse(Map<Id,Task> newMap, Map<Id,Task> oldMap){
        Id taskIntegrationRTId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(INTEGRATION_ERRORS_TASK).getRecordTypeId();
        Set<Id> quoteIds = new Set<Id>();
        for(Task tsk : newMap.values()){
            if(tsk.WhatId.getSObjectType() == SBQQ__Quote__c.sObjectType && tsk.Status != oldMap.get(tsk.Id).Status && tsk.Status == OPEN_STATUS && tsk.RecordTypeId == taskIntegrationRTId){
                quoteIds.add(tsk.WhatId);
            }
        }
        if(!quoteIds.isEmpty()){
            List<SBQQ__Quote__c> updateQuotes = new List<SBQQ__Quote__c>();
            for(SBQQ__Quote__c quote : [Select Id,Resubmit_Flag__c,DoResyncOutBoundcall__c from SBQQ__Quote__c where Id IN : quoteIds]){
                // quote.Resubmit_Flag__c = false;
                quote.DoResyncOutBoundcall__c = false;
                updateQuotes.add(quote);
            }
            if(!updateQuotes.isEmpty()){
                update updateQuotes;
            }
        }
    }
    
    /*  
* SDT-18820
* This method is use to insert the comment - SDT-18820
* @owner: Adil Aleem
* @param: Map<Id,Task>, Map<Id, Task>
*/
    public static void createCaseComment(map<Id, Task> newMap , map<Id, Task> oldMap){
        Map<String , List<Task>> commentTaskMap = new Map<String , List<Task>>();
        if(userMap.isEmpty()){
            userMap = new  Map<Id , User>([Select Id FROM User WHERE Name = :Constant_Util.ACORN_INTEGRATION_USERNAME OR Name = :Constant_Util.API_USER_ONLY_NAME]); 
        }
        if(oldMap == null){
            for(Task tsk : newMap.values()) {
                if(!(tsk.Subject != null && tsk.Subject.startsWith(Constant_Util.OUTBOUND_SUBJECT)) && !tsk.TaskFromEmail__c) {
                    if((userMap != null && !userMap.isEmpty() && userMap.containsKey(tsk.CreatedById)) || tsk.isSystemGenerated__c){
                        
                        if(!commentTaskMap.containsKey(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_CREATION_SYSTEM)){
                            commentTaskMap.put(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_CREATION_SYSTEM , new List<Task>{tsk});
                        } else {
                            commentTaskMap.get(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_CREATION_SYSTEM).add(tsk);
                            
                        }
                    }
                    else {
                        
                        if(tsk.Status != null){
                            if(!commentTaskMap.containsKey(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_CREATION_MANUAL)){
                                commentTaskMap.put(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_CREATION_MANUAL , new List<Task>{tsk});
                            } else {
                                commentTaskMap.get(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_CREATION_MANUAL).add(tsk);
                            }
                        }    
                    }
                }
            }
        } else {
            for(Task tsk : newMap.values()) {
                if(!(tsk.Subject != null && tsk.Subject.startsWith(Constant_Util.OUTBOUND_SUBJECT)) && !tsk.TaskFromEmail__c) {
                    if((userMap != null && !userMap.isEmpty() && userMap.containsKey(tsk.CreatedById)) || tsk.isSystemGenerated__c){
                        if(oldMap != null && oldMap.containsKey(tsk.id) && task.Outcome__c != null && tsk.Outcome__c != oldMap.get(tsk.id).Outcome__c){
                            if(!commentTaskMap.containsKey(Constant_Util.COMMENT_TEMPLATE_TASK_OUTCOME_UPDATE)){
                                commentTaskMap.put(Constant_Util.COMMENT_TEMPLATE_TASK_OUTCOME_UPDATE , new List<Task>{tsk});
                            } else {
                                commentTaskMap.get(Constant_Util.COMMENT_TEMPLATE_TASK_OUTCOME_UPDATE).add(tsk);
                            }
                        }
                    } else {
                        if(oldMap != null && oldMap.containsKey(tsk.id) && task.Status != null && tsk.Status != oldMap.get(tsk.id).Status){
                            if(tsk.Status != null){
                                if(!commentTaskMap.containsKey(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_UPDATE)){
                                    commentTaskMap.put(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_UPDATE , new List<Task>{tsk});
                                } else {
                                    commentTaskMap.get(Constant_Util.COMMENT_TEMPLATE_TASK_STATUS_UPDATE).add(tsk);
                                }
                            }    
                        }
                    }
                }    
            }
        }
        if(!commentTaskMap.isEmpty()) {
            Map<String , Comment_Log_Detail__mdt> commentLogTemplateData = new Map<String , Comment_Log_Detail__mdt>();
            for(Comment_Log_Detail__mdt c : Comment_Log_Detail__mdt.getAll().values()){
                commentLogTemplateData.put(c.DeveloperName , c);
            }
            Map<String , String> fieldTemplateMap = new Map<String , String>();
            List<Comment__c> commentList = new List<Comment__c>();
            Set<String> dateTimeFields = new Set<String>();
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Task');
            Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
            for(Schema.SObjectField field : fieldMap.values()) {
                fieldTemplateMap.put('<' + field.getDescribe().getName() + '>' , field.getDescribe().getName());
                if(field.getDescribe().getType() == Schema.DisplayType.DateTime || field.getDescribe().getType() == Schema.DisplayType.Date){
                    dateTimeFields.add('<' + field.getDescribe().getName() + '>');
                }
                
            }
            try {
                for(String key : commentTaskMap.keySet()){
                    for(Task t : commentTaskMap.get(key)){
                        String commentBody = commentLogTemplateData.containsKey(key) ? commentLogTemplateData.get(key).Comment__c : '';
                        Comment__c comment = new Comment__c();
                        comment.Case__c = t.WhatId;
                        for(String field : fieldTemplateMap.keySet()){
                            if(fieldTemplateMap.get(field) != null && commentBody.contains(field)) {
                                String fieldValue = '';
                                if(dateTimeFields.contains(field)){
                                    fieldValue = t.get(fieldTemplateMap.get(field)) != null ? Date.valueOf(t.get(fieldTemplateMap.get(field))).format() : '';
                                } else {
                                    fieldValue = t.get(fieldTemplateMap.get(field)) != null ? String.valueOf(t.get(fieldTemplateMap.get(field))) : '';
                                }
                                commentBody = commentBody.replaceAll(field , fieldValue);
                            }   
                        }
                        comment.Comment__c = commentBody;
                        comment.Workflow_Action__c = Constant_Util.TASK_ACTION_TYPE;
                        comment.Related_SObject_Id__c = t.id;
                        comment.Related_SObject_Key__c = t.Subject;
                        comment.CreatedDate = System.now();
                        comment.is_Log__c = true;
                        commentList.add(comment);
                    }
                }
                Database.saveResult[] insertResult = Database.insert(commentList, false);
            } catch(exception excp){
                UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
        
    }
    
    
    /*  
* SDT-18329
* This method is used for Task_Genesys_Routing_Control - SDT-18329
* @owner: Arvind Kumar
* @param: Set<Id>
*/
    public static Map<String,Task_Genesys_Routing_Control__c> getTaskGenesysRoutingControl(Set<String> processSet){
       
       //If(mapTaskGRKeys.isEmpty())  //Commented for SDT-40077 
       //{  //Commented for SDT-40077
        Map<String,Task_Genesys_Routing_Control__c> mapTaskGRKeys = new Map<String,Task_Genesys_Routing_Control__c>();
        //soql 101 issue -SDT-40083
        if(processSet.size()>0 && !processSet.isEmpty()){
            for(Task_Genesys_Routing_Control__c  taskGR : [Select Id,Task_Type__c,Stop_Routing__c,Primary_Segment__c,Service_Flag__c 
                                                           from Task_Genesys_Routing_Control__c where Task_Type__c IN : processSet]){
                mapTaskGRKeys.put(taskGR.Task_Type__c + '-' + taskGR.Service_Flag__c,taskGR);
                                                               
            }
        }
       //}  //Commented for SDT-40077 
        return mapTaskGRKeys;
    }
    
    /* ScheduleCreateGenesysForTask
     * This method is used for Schedule a Task
     * */
 /*   public static void createGRbyPendingInfoTask(Map<Id,Task> newMap){
        Map<Id,Task> mapTask;
        Set<Id> ownerIdSet = new Set<Id>();
        for(Task tsk : newMap.values()){
            if(tsk.Due_Date_Time__c != null && tsk.Due_Date_Time__c >= system.now() && tsk.Subject == 'Pending Information' && tsk.Status == OPEN_STATUS ){
                ownerIdSet.add(tsk.OwnerId);
            }
        }
        Map<Id,User> userMap = new Map<Id,User>();
        for(User usr : [Select Id,Is_Genesys_User__c from User where Id IN : ownerIdSet]){
            if(usr.Is_Genesys_User__c){
                userMap.put(usr.Id, usr);
            }
        }
        if(userMap != null && !userMap.isEmpty()){
            for(Task tsk : newMap.values()){
                if(userMap.containsKey(tsk.OwnerId) && userMap.get(tsk.OwnerId).Is_Genesys_User__c){
                    mapTask = new Map<Id,Task>();
                    mapTask.put(tsk.Id,tsk);
                }
            }
            if(mapTask!=null && !mapTask.isEmpty()){
                if(!Test.isRunningTest()){
                   ScheduleCreateGenesysForTask.scheduleGRRecordCreation(mapTask.values(),userMap);
                }
            }
        }
        
    } */
	    /*  
* SDT-28101
* This method is use to delete
* @owner: vishnu
* @param: Map<Id,Task>
*/
    
    public static void deleteTask(map<Id,Task> newTaskMap){
        try{
            List<task> taskListTodelete = new  List<Task> ();
            Set<Id>taskIdset = new Set<Id>();
           for(Task t : newTaskMap.values()){
                if(t.Process__c == 'Confirm Service Completion' || t.Process__c == 'Obtain Schedule Confirmation' ||t.Process__c == 'Confirm Service Completion with Location'){
                    taskIdset.add(t.Id);
                }
            }
            //soql 101 issue fix -SDT-40083
            if(taskIdset.size()>0 && !taskIdset.isEmpty()){ 
                 for(Task t : [select Id from Task where Id IN:taskIdset]){
                       taskListTodelete.add(t);
                   }
            }   
              
            
            if(!taskListTodelete.isEmpty() && !test.isRunningTest()){
                Delete taskListTodelete;
            }
            
        } catch(exception e){
              UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
        }
        
    }
	  /*  
* SDT-28101
* This method is use to sytemcompelete On update
* @owner: vishnu
* @param: Map<Id,Task>
*/
     public static void autocompleteTask(map<Id,Task> newTaskMap){
        try{
           for(Task t : newTaskMap.values()){
                if((t.Process__c == 'Confirm Service Completion' || t.Process__c == 'Obtain Schedule Confirmation' ||t.Process__c == 'Confirm Service Completion with Location') && !test.isRunningTest()){
                   t.Outcome__c = 'System Completed';
                   t.Status = 'Completed';
                }
            }  
        } catch(exception e){
              UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
        }
        
    }


    // Update Required Info
    public static void updateRequireInfo(list<Task> newTaskList){
        Set<Id> caseIds = new Set<Id>();
        for(task tsk : newTaskList){
            if(tsk.Subject == Constant_Util.OBTAIN_CUSTOMER_INFO && tsk.whatId !=null && tsk.WhatId.getSObjectType().getDescribe().getName() == Constant_Util.OBJECT_CASE && tsk.Status== Constant_Util.Case_Open_Status ){
                caseIds.add(tsk.whatId);
            }
        }
        if(caseIds!=null && !caseIds.isEmpty()){
            Map<Id,String> mapCaseInfo = new Map<Id,String>();
            Id nscRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_NEW_SERVICE_CASE).getRecordTypeId();
            for(Case cs : [Select Id,Required_Information__c from Case where Id IN : caseIds AND RecordTypeId =:nscRecordTypeId]){
                if(cs!=null){
                    String strReqInfo = String.isNotBlank(cs.Required_Information__c) ? cs.Required_Information__c+';' : cs.Required_Information__c;
                    mapCaseInfo.put(cs.Id, strReqInfo);
                }
            }
            if(mapCaseInfo.keySet()!=null && !mapCaseInfo.keySet().isEmpty()){
                for(Task tskObj : newTaskList){
                    if(mapCaseInfo.containsKey(tskObj.WhatId)){
                        tskObj.Description__c = mapCaseInfo.get(tskObj.WhatId);
                    }
                }
            }
        }
    }
//Changes related to SDT-38038 - Start
    //Method to populate due date value of portal task.
    public static void updateDueDateForPortalTasks(List<Task> newTaskList){
        Set<Id> caseIds = new Set<Id>();
        Set<String> taskSetForDueDate = new Set<String>();
        Map<Id,Date> mapIdvsCaseDueDate = new Map<Id,Date>();

        //Fetching Task_List_For_Due_Date__mdt metadata records.
        try{
            for(Task_List_For_Due_Date__mdt tskType : Task_List_For_Due_Date__mdt.getAll().values()){
                taskSetForDueDate.add(tskType.Label);
            }
            
            for(Task tsk : newTaskList){
                if(tsk.WhatId!=null && tsk.WhatId.getSObjectType().getDescribe().getName() == Constant_Util.OBJECT_CASE 
                   && String.isNotBlank(tsk.Process__c) && taskSetForDueDate.contains(tsk.Process__c)){
                       caseIds.add(tsk.WhatId);
                   }
            }
            if(caseIds!=null && !caseIds.isEmpty()){
                //Changes related to SDT-39002 - Service_Date__c is taken instead of SLA date
                for(Case caseObj : [Select Id,Service_Date__c from Case where Id IN : caseIds AND Location__c!=null AND Service_Date__c !=null LIMIT 49999]){
                        mapIdvsCaseDueDate.put(caseObj.Id,caseObj.Service_Date__c);
                                    }
                for(Task tsk : newTaskList){
                    //Changes related to SDT-38038 -start
                    if(String.isNotBlank(tsk.Process__c) && taskSetForDueDate.contains(tsk.Process__c) && tsk.Due_Date_Time__c == null){
                        if(mapIdvsCaseDueDate.get(tsk.WhatId)!=null){
                            tsk.Due_Date_Time__c = mapIdvsCaseDueDate.get(tsk.WhatId);
                            tsk.ActivityDate = mapIdvsCaseDueDate.get(tsk.WhatId);
                        }
                    }
                }
            }
        }
        catch(exception e){
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
        }
    }
    //Changes related to SDT-38038 -end 
    public static void createEscTask(Map<Id,Task> newMap, map<Id,Task> oldMap){
        List<Task> insertTaskLst = new List<Task>();
        List<Task> taskLst = new List<Task>();
        List<Task> taskLst2 = new List<Task>();
        List<String> processList = new List<String>();
        List<Task> allTaskList = new List<Task>();
        Set<Id> TaskIds = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        for(Task tsk : newMap.values()){
            caseIdSet.add(tsk.whatId);
            if(tsk.Process__c == 'Escalation Obtain Service Approval'){
                processList.add(tsk.process__c);
            }
        }
                              
        //SDT-40083
        if(processList.size() > 0){
            allTaskList = [SELECT Id,Outcome__c, WhatId, Status, OwnerId, Process__c, Attempt__c, Next_Attempt_Date_Time__c, ContactEmail__c,
                Is_Attempt_Created__c,Contact_Title__c, Department_Name__c, Due_Date_Time__c,Subject,Approval_Log__c,MultiCaseId__c,Business_Rule__c, WhoId FROM Task 
                WHERE Process__c = 'Escalation Obtain Service Approval' AND Attempt__c <= 2  
            and whatId IN :caseIdSet
                LIMIT 49999]; 
            System.debug('allTaskList^^' +allTaskList  );
        }

        if(!allTaskList.isEmpty()){
            for(Task tsk : allTaskList ){
                
                if(tsk.outcome__c == Constant_Util.FINAL_EMAIL_SENT && tsk.status == 'Completed' && tsk.Attempt__c < 2 ){
                System.debug('here tasklst1^^');
                    taskLst.add(tsk);                    
                }
                if(tsk.Attempt__c == 2 ){
                System.debug('here tasklst2^^');
                    taskLst2.add(tsk);
                }                
            }   
        }             
            
        Generic_Values__mdt genysysUser = [SELECT Id,Id__c FROM Generic_Values__mdt 
                                            WHERE Label =: Constant_Util.GROUP_USERNAME LIMIT 1];
  
        if(!taskLst.isEmpty() && taskLst2.isEmpty()){
                // system.debug('taskLst IN >');
                for(Task tsk : taskLst) {
                    Task t = new Task();
                    t.ActivityDate = system.today();
                    t.Description__c = Constant_Util.EMPTY_STRING;
                    t.OwnerId = genysysUser.Id__c;
                    t.Process__c = tsk.Process__c;
                    t.Attempt__c = tsk.Attempt__c + 1;
                    t.Subject = tsk.subject;
                    t.WhoId = tsk.WhoId;
                    t.Status = 'Open';
                    t.MultiCaseId__c = tsk.MultiCaseId__c;
                    t.WhatId = tsk.WhatId; 
                    t.Contact_Title__c = tsk.Contact_Title__c;
                    t.Approval_Log__c = tsk.Approval_Log__c;
                    t.Business_Rule__c = tsk.Business_Rule__c;
                    t.Department_Name__c = tsk.Department_Name__c;
                    // t.ContactEmail__c = tsk.ContactEmail__c;
                    t.RecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
                    insertTaskLst.add(t);
                }
            }
        List<Database.SaveResult> dbrs = Database.insert(insertTaskLst, false);       
    }
    
      public static void createEscTaskObtainCustInfo(Map<Id,Task> newMap, map<Id,Task> oldMap){
      //   List<Task> lstTask = new List<Task>();
        List<Task> insertTaskLst = new List<Task>();
        List<Task> taskLst = new List<Task>();
        List<Task> taskLst2 = new List<Task>();
         List<Task> allTaskList = new List<Task>();
        Set<Id> TaskIds = new Set<Id>();
          
           List<String> processList = new List<String>();
        Set<Id> caseIdSet = new Set<Id>();
             for(Task tsk : newMap.values()){
                caseIdSet.add(tsk.whatId);
                 if(tsk.Process__c == 'Escalation Obtain Customer Info'){
                    processList.add(tsk.process__c);
                     
                 }
        }
          
        /*List<Task> taskLst = [SELECT Id, WhatId, Status, OwnerId, Process__c, Attempt__c, Next_Attempt_Date_Time__c,
                              Is_Attempt_Created__c, Due_Date_Time__c,Contact_Title__c,Description__c,MultiCaseId__c, Subject, WhoId FROM Task 
                              WHERE Process__c = 'Escalation Obtain Customer Info' AND Attempt__c < 2  
                           AND   Outcome__c = 'Information Not Obtained' and status = 'Completed' and whatId IN :caseIdSet
                              LIMIT 49999];
         List<Task> taskLst2 = [SELECT Id, WhatId, Status, OwnerId, Process__c, Attempt__c, Next_Attempt_Date_Time__c,
                              Is_Attempt_Created__c, Due_Date_Time__c,Contact_Title__c,MultiCaseId__c,Description__c, Subject, WhoId FROM Task 
                              WHERE Process__c = 'Escalation Obtain Customer Info' AND Attempt__c = 2  
                                 and whatId IN :caseIdSet
                              LIMIT 49999];*/
                              
          //SDT-40083
          if(processList.size() > 0){
           allTaskList = [SELECT Id,Outcome__c, WhatId, Status, OwnerId, Process__c, Attempt__c, Next_Attempt_Date_Time__c,
                              Is_Attempt_Created__c, Due_Date_Time__c,Contact_Title__c,Description__c, Subject,MultiCaseId__c, WhoId FROM Task 
                              WHERE Process__c = 'Escalation Obtain Customer Info' AND Attempt__c <= 2  
                            and whatId IN :caseIdSet
                              LIMIT 49999]; 
          }
            if(!allTaskList.isEmpty()){
                for(Task tsk : allTaskList ){
                    
                    if(tsk.outcome__c == 'Information Not Obtained' && tsk.status == 'Completed' && tsk.Attempt__c < 2 ){
                        taskLst.add(tsk);
                        
                    }
                    if(tsk.Attempt__c == 2 ){
                        taskLst2.add(tsk);
                    }
                    
                }   
            }                                 
                              
         Generic_Values__mdt genysysUser = [SELECT Id,Id__c 
                                               FROM Generic_Values__mdt 
                                               WHERE Label =: Constant_Util.GROUP_USERNAME 
                                               LIMIT 1];
  
           if(!taskLst.isEmpty() && taskLst2.isEmpty()){
                 for(Task tsk : taskLst) {
                    Task t = new Task();
                    t.ActivityDate = system.today();
                    t.Description__c = tsk.Description__c;
                    t.OwnerId = genysysUser.Id__c;
                    t.Process__c = tsk.Process__c;
                    t.Contact_Title__c = tsk.Contact_Title__c;
                    t.Attempt__c = tsk.Attempt__c +1;
                    t.Subject = tsk.subject;
                    t.WhoId = tsk.WhoId;
                    t.Status = 'Open';
                    t.MultiCaseId__c = tsk.MultiCaseId__c;
                    t.WhatId = tsk.WhatId;         
                    t.RecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get('Escalation').getRecordTypeId();
                    insertTaskLst.add(t);                    
                }
           }
      
        List<Database.SaveResult> dbrs = Database.insert(insertTaskLst, false);
    }
    
        public static void updateStatusSubStatus(map<Id, Task> newMap){
        list<case> caselist = new list<case>();
        Map<String, List<task>> mapCaseReatedTasks = new Map<String, List<task>>();
        Map<String, Boolean> mapCaseStatus = new Map<String, Boolean>();
        set<ID> caseID = new set<ID>();

            /*for(task tk : newMap.values()){
                if(tk.Subject.contains('Approved'))
                {
                    caseID.add(tk.WhatId);
                }
                system.debug('caseID '+ caseID);
                system.debug('tk.MultiCaseId__c '+ tk.WhatId);
                system.debug('newMap.values() '+ newMap.values());
            }
            System.debug('caseID::::::::: '+caseID);
        
            for(Task tk: [Select Id,WhatId, MultiCaseId__c, Business_Rule__r.Multiple_Mandatory_Approvers__c, Subject, Status From 
                          Task Where WhatId In: caseID
                          AND Status = 'Open'
                          AND Subject = 'Escalation Obtain Service Approval'
                         AND Business_Rule__r.Multiple_Mandatory_Approvers__c = true]){
                            system.debug('Inside Task');
                              
                             if(String.isNotBlank(tk.WhatId)){
                                 if(!mapCaseReatedTasks.containsKey(tk.WhatId)){
                                     mapCaseReatedTasks.put(tk.WhatId, new List<task>());
                                 }
                                 mapCaseReatedTasks.get(tk.WhatId).add(tk);
                             }
                          }
           System.debug('mapCaseReatedTasks:: '+mapCaseReatedTasks);
            
            if(!mapCaseReatedTasks.isEmpty() && mapCaseReatedTasks != null){
                for(String key: mapCaseReatedTasks.keySet()){
                    for(Task tk: mapCaseReatedTasks.get(key)){
                        if(tk.Status == 'Open'){
                            mapCaseStatus.put(tk.WhatId, false);
                        }
                    }
                }
            }
        System.debug('mapCaseStatus:: '+mapCaseStatus);*/
        
        for(task tsk: newMap.values()){
            
            if(tsk.Process__c == 'Escalation Obtain Service Approval' && tsk.Attempt__c == 2){
                case c= new case();
                c.Id = tsk.WhatId;
                
                if( tsk.Outcome__c == 'Approved'){
                   c.Status = 'Open';
                    c.Case_Sub_Status__c = 'Pending Service Integration';
                    caselist.add(c);
                }
                   if( tsk.Outcome__c == 'Rejected'){
                   c.Status = 'Closed';
                    c.Case_Sub_Status__c = 'Request Not Approved';
                    caselist.add(c);
                }
              
            }
        }
        if(caselist != null && !caselist.isEmpty()){
            try{
                update caselist;
            }
            catch(exception e){
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
            }
        }
    }
	
	  public static void updatetaskassign(map<Id, Task> newMap){
        list<task> tasklist = new list<task>();
        list<task> tasklistNew = new list<task>();
        list<task> tasklist4 = new list<task>();
        Set<Id> caseIds = new Set<Id>();
        //Set<Id> CaseIds = new Set<Id>();
        Set<Id> taskIdSet = new Set<Id>();
        list<task> tasklist5 = new list<task>();
        Set<ID> settaskIds = new Set<Id>();
        
        List<Task> taskList2 = [SELECT Id,WhatId,Subject,SFDC_Team_Name__c,User_categorization__c,SFDC_Genesys_Service_Flag__c,SFDC_Genesys_User__c,recordtype.Name,CreatedById,Last_Agent_ID__c,Status,User_Categorization_Code__c,Task_Team_Name__c,SFDC_Task_User__c,Process__c,OwnerId,Owner.name,Attempt__c,Initial_Assignment__c,Business_Rule__c,Business_Rule__r.Is_Auto_Email__c from Task where Id IN:newMap.keyset()];
        Generic_Values__mdt genysysUser = [SELECT Id,Id__c,label 
                                               FROM Generic_Values__mdt 
                                               WHERE Label =: Constant_Util.GENYSYS_USER 
                                               LIMIT 1];
                       
            for(Task tsk : taskList2 ){
                task c= new task();
                c.Id = tsk.Id;
                
                 //SDT-39651 Start
              if (tsk.Initial_Assignment__c == '' || tsk.Initial_Assignment__c == null) {
                     string varOwnerId;
                  
                  
                  if(tsk.Last_Agent_ID__c != null && (tsk.recordtype.name == 'Initiate Task' || tsk.recordtype.name == 'Pending Information')){
                       varOwnerId = tsk.Last_Agent_ID__c;
                  }
                  if(varOwnerId == null && tsk.ownerId != null){
                      varOwnerId = tsk.ownerId;
                  }
                  if(varOwnerId == null){
                      varOwnerId = tsk.createdbyId;
                  }
                  
                    User userRec =[Select Id,Name,Profile.Name,User_categorization_code__c,Is_Genesys_User__c,GR_Service_Flag__c From User where Id=:varOwnerId  limit 1];
                    
                        if(userRec.User_categorization_code__c != null){
                         CSR_User_Data_Setup__mdt userDataSetup2 = CSR_User_Data_Setup__mdt.getInstance(userRec.User_categorization_code__c);
                         
                         
                            if(userDataSetup2 != null && userDataSetup2.Is_Genesys_User__c  && tsk.RecordType.Name != 'Pending Information' && tsk.Subject != 'Obtain Vendor Update' && tsk.Subject != 'Notify Customer Of Delay'){
                                  c.Initial_Assignment__c = String.isEmpty(tsk.Task_Team_Name__c) ? 'Genesys Integration' : userRec.Name;
                             
                            }
                            
                            else{
                            //System.debug('here##^^^ ');
                                 c.SFDC_task_user__c = userDataSetup2.SFDC_Task_User__c;
                                 c.SFDC_Genesys_User__c = userDataSetup2.Is_Genesys_User__c;
                                 c.SFDC_Genesys_Service_Flag__c = userDataSetup2.GR_Service_Flag__c;
                                 c.User_categorization__c = userDataSetup2.User_categorization__c;
                                 c.Initial_Assignment__c = userRec.name;
                                 c.User_Categorization_Code__c = userRec.User_categorization_code__c;
                                 c.SFDC_Team_Name__c = userDataSetup2.SFDC_Team__c;
                            }
                        }
                        else{
                               c.Initial_Assignment__c = userRec.name;
                               c.User_Categorization_Code__c = userRec.User_categorization_code__c;
                        
                               
                        }
                           
                           
                             
                         tasklistNew.add(c);
                   
               }
               //update tasklistNew;
               //SDT-39651 end
                
                if(tsk.Status == 'Open' && ((String.isNotBlank(tsk.Business_Rule__c) && !(tsk.Business_Rule__r.Is_Auto_Email__c) && (tsk.Process__c == 'Escalation Obtain Service Approval') && (tsk.Attempt__c ==1) ) || (tsk.Process__c == 'Escalation Obtain Customer Info' && tsk.Attempt__c ==1))){
                     System.debug('calling here^^ 2');
                      
                /*Generic_Values__mdt genysysUser = [SELECT Id,Id__c 
                                               FROM Generic_Values__mdt 
                                               WHERE Label =: Constant_Util.GENYSYS_USER 
                                               LIMIT 1];*/
                User userRec =[Select Id,Name,Profile.Name,User_categorization_code__c From User where Id=:System.UserInfo.getUserId() limit 1];
            
                //task c= new task();
                //c.Id = tsk.Id;
                      if(userRec.User_categorization_code__c != null){
                      System.debug('calling here^^ 3');
                        CSR_User_Data_Setup__mdt userDataSetup = CSR_User_Data_Setup__mdt.getInstance(userRec.User_categorization_code__c);
                        if(userDataSetup != null && userDataSetup.Is_Genesys_User__c ){
                               c.OwnerId =genysysUser.Id__c;
                               c.Initial_Assignment__c = 'Genesys Integration';
                            
                           
                        }else{
                            c.OwnerId = UserInfo.getUserId();
                            //c.Initial_Assignment__c = UserInfo.getUserName();
                             if (tsk.Initial_Assignment__c == '' || tsk.Initial_Assignment__c == null) {
                             c.SFDC_task_user__c = userDataSetup.SFDC_Task_User__c;
                                 c.SFDC_Genesys_User__c = userDataSetup.Is_Genesys_User__c;
                                 c.SFDC_Genesys_Service_Flag__c = userDataSetup.GR_Service_Flag__c;
                                 c.User_categorization__c = userDataSetup.User_categorization__c;
                                 c.Initial_Assignment__c = userRec.name;
                                 c.User_Categorization_Code__c = userRec.User_categorization_code__c;
                                 c.SFDC_Team_Name__c = userDataSetup.SFDC_Team__c;
                                 }
                        }
                            tasklist.add(c);
                      }else{
                           c.OwnerId = UserInfo.getUserId();
                            if (tsk.Initial_Assignment__c == '' || tsk.Initial_Assignment__c == null) {
                           c.Initial_Assignment__c = userRec.name;
                           }
                          tasklist.add(c);
                      }  
                }    
                
                
              
              // tasklist.add(c);
            }
			if(tasklistNew != null && !tasklistNew.isEmpty()){
				update tasklistNew;
			}
    
        if(tasklist != null && !tasklist.isEmpty()){
            try{
                update tasklist;
                for(Task ta : [SELECT Id,WhatId,Status,Owner.Name from Task where Id IN:newMap.keyset()]){
                    system.debug('>>>++ '+ta.owner.name);
                    if(ta.owner.name == 'Genesys Integration'){
                        tasklist5.add(ta);
                    }
                }if(tasklist5 != null && !tasklist5.isEmpty()){createTaskRouting(newMap); }
            }
            catch(exception e){
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
            }
        }
         
          for(Task td : taskList2){
            settaskIds.add(td.id);
        }
		updatetaskOutcome(settaskIds);
         
         
         
         /**
              for(Task tsk : taskList2 ){
                if(tsk.Status == 'Open' && ((tsk.Process__c == 'Escalation Obtain Service Approval') && (tsk.Attempt__c ==1) && (tsk.Business_Rule__r.Is_Auto_Email__c) )){
                     task c= new task();
                c.Id = tsk.Id;
                           c.Outcome__c = 'Final Email Sent';
                          tasklist4.add(c);
                }     
            }
    
        if(tasklist4 != null && !tasklist4.isEmpty()){
            try{
                update tasklist4;
            }
            catch(exception e){
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
            }
        }**/
         
    }
	
	 
	@future
	 public static void updatetaskOutcome(Set<Id> taskidset){
        list<task> tasklist = new list<task>();
         list<task> tasklist3 = new list<task>();
            Set<Id> caseIds = new Set<Id>();
         // Set<Id> taskIdSet = new Set<Id>();
         
                    List<Task> taskList2 = [SELECT Id,WhatId,Process__c,Attempt__c,Business_Rule__c,Business_Rule__r.Is_Auto_Email__c from Task where Id IN :taskidset];
                       
            for(Task tsk : taskList2 ){
                if((tsk.Process__c == 'Escalation Obtain Service Approval') && (tsk.Attempt__c ==1) && (tsk.Business_Rule__r.Is_Auto_Email__c) ){
                     task c= new task();
                c.Id = tsk.Id;
                           c.Outcome__c = 'Final Email Sent';
c.status = 'Completed';
                          tasklist.add(c);
                }     
            }
    
        if(tasklist != null && !tasklist.isEmpty()){
            try{
                update tasklist;
            }
            catch(exception e){
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.TASK_TRIGGER_HELPER,LoggingLevel.ERROR);
            }
        }
    }
    

	
}
