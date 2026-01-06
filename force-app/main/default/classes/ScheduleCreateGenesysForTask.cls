/******************************************************
* Class : ScheduleCreateGenesysForTask 
* Author : Arvind Kumar
* Version : implementes
* Description : To create Genesys Routing Record from Pending Information Case Task 
*****************************************************/
 //

global class ScheduleCreateGenesysForTask implements Schedulable
{
    List<Task> taskList;
    Map<Id,User> userMap;
    global ScheduleCreateGenesysForTask(List<Task> tskList,Map<Id,User> usrMap){
        taskList = tskList;
        userMap = usrMap;
    }
    
    // call on task - due date
    global static void scheduleGRRecordCreation(List<Task> taskList,Map<Id,User> userMap)
    {
        system.debug('taskList : ' + taskList);
        for(Task tskObj : taskList){
            if(tskObj.Due_Date_Time__c!=null && tskObj.Due_Date_Time__c > = System.now() && !tskObj.Is_GR_byPendingInfoTask__c ){
                
                //schedule next execution after a minute
                DateTime currentDateTime = tskObj.Due_Date_Time__c.addMinutes(1);
                String nextScheduleTime=String.valueof(currentDateTime.second()) +' '+String.valueof(currentDateTime.minute())+' '
                    +String.valueof(currentDateTime.hour())+' '+String.valueof(currentDateTime.day())+' '
                    +String.valueof(currentDateTime.month())+' ? '+String.valueof(currentDateTime.Year());
                ScheduleCreateGenesysForTask schJob = new ScheduleCreateGenesysForTask(taskList,userMap);
                String jobName = 'Every 1 min' + '-' + tskObj.Last_Agent_ID__c + '-' + tskObj.Id; 
                system.schedule( jobName, nextScheduleTime, schJob);
            }
        }
        
    }
    
    // execute schedule class
    global void execute(SchedulableContext sc)
    {
        system.debug('runnn');
        try{
            
            // Create Genesys Routing Record
            createGenesysRoutingByTask(taskList,userMap);
            
            // update Task Record 
            updateTaskAssignIdToGenesys(taskList,userMap);
            
            // Abort the job
            for( CronTrigger cronTriggerItem:[Select Id From CronTrigger where  
                                              NextFireTime= null AND Id = :sc.getTriggerId() Limit 100])
            {
                System.abortJob(cronTriggerItem.id);
            }
        }catch(Exception ex){
            system.debug('Exception'+ex.getStackTraceString());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            // Abort the job
            for( CronTrigger cronTriggerItem:[Select Id From CronTrigger where  
                                              NextFireTime= null AND Id = :sc.getTriggerId() Limit 100])
            {
                System.abortJob(cronTriggerItem.id);
            }
        }
        
        
    }
    
    public static void updateTaskAssignIdToGenesys(List<Task> taskList,Map<Id,User> userMap){
        Generic_Values__mdt objGenericValues = [Select Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER];
        Id genesysUserId = objGenericValues.Id__c;
        List<Task> updateTaskList = new List<Task>();
        for(Task tsk : [Select Id,OwnerId,Status from Task where Id IN : taskList]){
            if(userMap.containsKey(tsk.OwnerId) && userMap.get(tsk.OwnerId).Is_Genesys_User__c && tsk.Status == 'Open'){
                Task updateTask = new Task();
                updateTask.Id = tsk.Id;
                updateTask.OwnerId = genesysUserId;
                updateTask.Is_GR_byPendingInfoTask__c = True;
                updateTaskList.add(updateTask);
            }
        }
        if(updateTaskList != null && !updateTaskList.isEmpty()){
            update updateTaskList;  
        }                   
    }
    
    // Create the genesys routing record from task
    public static void createGenesysRoutingByTask(List<Task> taskList,Map<Id,User> userMap){
        set<Id> caseIdSet = new set<Id>();
        set<string> processSet = new set<string>();
        map<Id,Case> caseIdMap = new map<Id,case>();
        map<string,TaskDesc__mdt> tskdescmap = new map<string,TaskDesc__mdt>();
        Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
        Genesys_Routing__c gr;
        List<Genesys_Routing__c> insertGenesysRouteLst = new List<Genesys_Routing__c>();
        Set<String> lastAgentId = new Set<String>();
        for(Task tskObj : [Select Id,Status,WhatId,Process__c,OwnerId,Last_Agent_ID__c from Task where Id IN : taskList]){
            if(userMap.containsKey(tskObj.OwnerId) && userMap.get(tskObj.OwnerId).Is_Genesys_User__c && tskObj.Status == 'Open' ){
                caseIdSet.add(tskObj.WhatId);
                processSet.add(tskObj.Process__c);
                lastAgentId.add(tskObj.Last_Agent_ID__c);
                system.debug('insert createTaskRouting : ');
            }
        }
        
        if(caseIdSet != null && caseIdSet.size() > 0){
            for(case c : [Select Id,OwnerId,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,
                          Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,
                          Supplier__r.Name,Supplier__r.Vendor_ID__c,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,
                          AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c,Case_Sub_Status__c from case where Id IN: caseIdSet Limit 49999]){
                              caseIdMap.put(c.Id,c);
                          }
        }
        
        if(caseIdMap != null){
            case ca;
            String lastAgentName = [Select UserName from User where Id IN : lastAgentId].UserName;  
            for(Task tsk : taskList){
                ca = caseIdMap.get(tsk.WhatId);
                gr = new Genesys_Routing__c();
                gr.LastAgentId__c = lastAgentName.substringBefore(Constant_Util.AT_SYMBOL);
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
                gr.SFDCServiceFlag__c = string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
                gr.SFDCTaskCaseId__c = tsk.WhatId;
                gr.SFDCTaskDescCode__c = 'PendInfo';
                gr.SFDCTaskDescription__c = tsk.Process__c;		
                gr.SFDCTaskDueDateTime__c = tsk.Due_Date_Time__c;
                insertGenesysRouteLst.add(gr);
            }
            
            try{
                if(insertGenesysRouteLst != null && insertGenesysRouteLst.size() >0){
                    Database.insert(insertGenesysRouteLst,false);
                }
            }catch(Exception ex){
                system.debug('Exception'+ex.getStackTraceString());
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
    }
    
}