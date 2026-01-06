/******************************************************
* Class : ScheduleCreateGenesysForTask 
* Author : Vishnu  
* Version : V1
* Description : To create Genesys Routing Record from Pending Information Case Task 
* CreatedDate : 9/1/2022
* LastModified :9/1/2022
*Jira Item :SDT-25348
*****************************************************/
global class BatchToCreateGenesysForPITasks implements Database.Batchable<sObject>{
    Private Static Final String P1 = 'P1';
    Private Static Final String P2 = 'P2';
    Private Static Final String P3 = 'P3';
    Private Static Final String P4 = 'P4';
    Private Static Final String PENDINGINFO = 'PendInfo';
    Private Static Final String SERVICEFOLLOWUP = 'ServiceFollowup';
     Private Static Final String PENDINGINFORMATION = 'Pending Information';
    Private Static Final String SERVICEFOLLUPSUB = 'Service Follow up';
    Private Static Final String RSISUB = 'Resolve Service Issue';
    Private Static Final String RSIGRTASKCODE = 'SerResoln';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator([select Id, Due_Date_Time__c,Subject,WhatId,Last_Agent_ID__c,Process__c,Status  From Task where  Due_Date_Time__c !=NULL AND  Due_Date_Time__c <: system.now() AND Is_GR_byPendingInfoTask__c = false AND Status ='Open' AND (Process__c = 'Pending Information' OR Process__c ='Service Follow up' OR Process__c ='Resolve Service Issue' ) AND Last_Agent_ID__c != Null AND (subject = 'Pending Information' OR Subject ='Service Follow up' OR Subject ='Resolve Service Issue') ]);}
    public void execute(Database.BatchableContext BC, List<Task> scope){
        createGenesysRoutingforTask(scope);
    }
    public void finish(Database.BatchableContext BC){
        
    }
    // Create the genesys routing record from task
    public static void createGenesysRoutingforTask(List<Task> taskList){
        try{
            List<Genesys_Routing__c> insertGenesysRouteLst = new List<Genesys_Routing__c>();
            Id genesysRoutingRec ;
            Set<Id> grIds = new Set<Id>();
            Map<Id,case> caseIdMap = new Map<Id,case> ();
            Map<Id,case>caseIdMapforPriorityCheck = new Map<Id,Case>();
            Set<Id> lastAgentIdSet = new Set<Id> () ;
            set<Id> caseIdSet = new set<Id>();
            Map<Id,String> caseIdGrPriorityMap = new Map<Id,String> ();
            Map<Id,String> lastAgentNameMap = new Map<Id,String>();
            Map<String,Boolean> userCatagoryIsGenisMap = new Map<String,Boolean>();
            Map<String,CSR_User_Data_Setup__mdt> userMetaDataSetupMap = new Map<String,CSR_User_Data_Setup__mdt> ();
            Map<String,String> userServiceFlagMap = new  Map<String,String> ();
            Map<Id,Task> taskAfterFilter = new Map<Id,Task>();
            for(Task tsk : taskList){
                lastAgentIdSet.add(tsk.Last_Agent_ID__c);
            }
              List<CSR_User_Data_Setup__mdt> sfdcTeamUserDate = CSR_User_Data_Setup__mdt.getAll().values();
            for(CSR_User_Data_Setup__mdt userDataSetup : sfdcTeamUserDate){
                if(userDataSetup.User_categorization_code__c!=null){
                    userMetaDataSetupMap.put(userDataSetup.User_categorization_code__c,userDataSetup);
                    userCatagoryIsGenisMap.put(userDataSetup.User_categorization_code__c,userDataSetup.Is_Genesys_User__c);
                }
            }
            for(user usr  : [Select Id,UserName,User_categorization_code__c from User where Id IN:lastAgentIdSet]){
               
                
                if(usr.User_categorization_code__c!= null && userCatagoryIsGenisMap.containsKey(usr.User_categorization_code__c)){
                    
                    Boolean isGenysis = userCatagoryIsGenisMap.get(usr.User_categorization_code__c);
                    if(isGenysis){
                           lastAgentNameMap.put(usr.Id,usr.UserName.substringBefore(Constant_Util.AT_SYMBOL));
                          // CSR_User_Data_Setup__mdt userDataSetup  =  userMetaDataSetupMap.get(usr.User_categorization_code__c) ;
                          userServiceFlagMap.put(usr.Id,userMetaDataSetupMap.get(usr.User_categorization_code__c).GR_Service_Flag__c);
                            
                    }
                }
             /*   if(usr.Is_Genesys_User__c){
                    lastAgentNameMap.put(usr.Id,usr.UserName.substringBefore(Constant_Util.AT_SYMBOL));
                } */
            }
            //Filter out the task to create Geneysys record
            for(Task tsk : taskList ){
                if(lastAgentNameMap.containsKey(tsk.Last_Agent_ID__c)){
                    taskAfterFilter.put(tsk.Id,tsk);
                    caseIdSet.add(tsk.WhatId);
                }
            }
            if(!caseIdSet.isEmpty() && caseIdSet.size() > 0){
                genesysRoutingRec  = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId(); 
            }
            for(case c : [Select Id,OwnerId,RecordType.Name,CaseNumber,Case_Reason__c,Service_Date__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Location__c,Supplier__c,Client__c,
                          Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,
                          Supplier__r.Name,Supplier__r.Vendor_ID__c,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,
                          AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c,Case_Sub_Status__c,Asset.Supplier__r.Name from case where Id IN: caseIdSet Limit 49999]){
                              caseIdMap.put(c.Id,c);
                             if(c.Service_Date__c != Null || c.Service_Date__c >= date.today()){
                                  caseIdMapforPriorityCheck.put(c.Id,c);
                              }
                          }
            
            if(!caseIdMapforPriorityCheck.isEmpty()){
              caseIdGrPriorityMap = CreatePendingInformationTask.getNoOfBusinessDaysfromCurrentDate(caseIdMapforPriorityCheck);
            }
            
            if(!caseIdMap.isEmpty()){
                for(Task tsk  : taskAfterFilter.values()){
                    Case ca = caseIdMap.get(tsk.WhatId);
                    Genesys_Routing__c gr = new Genesys_Routing__c();
                    if(tsk.subject == PENDINGINFORMATION){
                         gr.SFDCTaskDescCode__c = PENDINGINFO ;
                    }else if(tsk.subject == SERVICEFOLLUPSUB){
                         gr.SFDCTaskDescCode__c = SERVICEFOLLOWUP ;
                    }else if(tsk.subject == RSISUB){
                         gr.SFDCTaskDescCode__c = RSIGRTASKCODE ;  
                    }
                    gr.LastAgentId__c = lastAgentNameMap.get(tsk.Last_Agent_ID__c) ;
                    gr.OwnerId = tsk.Last_Agent_ID__c ;
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
                  //  gr.SFDCServiceFlag__c = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                    gr.SFDCServiceFlag__c = userServiceFlagMap.containsKey(tsk.Last_Agent_ID__c) ? userServiceFlagMap.get(tsk.Last_Agent_ID__c) : null ;
                    gr.SFDCTaskCaseId__c = tsk.WhatId;
                    gr.SFDCTaskDescription__c = tsk.Process__c;		
                    gr.SFDCTaskDueDateTime__c = tsk.Due_Date_Time__c;
                    gr.CreatedById = tsk.Last_Agent_ID__c ;
                    gr.LastModifiedById = tsk.Last_Agent_ID__c ;
                   gr.SFDCRoutePriority__c = (!caseIdGrPriorityMap.isEmpty() && caseIdGrPriorityMap.containskey(tsk.WhatId)) ? caseIdGrPriorityMap.get(tsk.whatId) : 'P2' ;
                    insertGenesysRouteLst.add(gr);
                }
            }
            if(!insertGenesysRouteLst.isEmpty()){
                Database.SaveResult[] srList = Database.insert(insertGenesysRouteLst, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        grIds.add(sr.getId());
                    }
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                if(!grIds.isEmpty()){
                    updateTaskOwnerToGenesysIntegration(grIds);   
                }
            }
        }  catch(Exception ex){
            system.debug('Exception'+ex.getStackTraceString());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    public static void updateTaskOwnerToGenesysIntegration(Set<Id> grIdSet){
        try{
            List<Task> taskListToUpdate = new List<Task>();
            Set<Id> taskIdSet = new Set<Id>();
            for(Genesys_Routing__c gr :[select Id,SFDCObjRecordID__c from Genesys_Routing__c where Id IN:grIdSet ]){
                taskIdSet.add(gr.SFDCObjRecordID__c);
            }
            Generic_Values__mdt objGenericValues = [Select Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER];
            Id genesysUserId = objGenericValues.Id__c;
            for(Task tsk : [Select Id,OwnerId,Is_GR_byPendingInfoTask__c from Task Where Id IN:taskIdSet]){
                tsk.OwnerId = genesysUserId;
                tsk.Is_GR_byPendingInfoTask__c = True;
                taskListToUpdate.add(tsk);
            }
            if(!taskListToUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(taskListToUpdate, false);
            } 
        }catch(Exception ex){
            system.debug('Exception'+ex.getStackTraceString());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
}
