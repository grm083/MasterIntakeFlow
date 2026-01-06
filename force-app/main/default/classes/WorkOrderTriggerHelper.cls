/*************************************************************************************************************************************************************
@ Class:          WorkOrderTriggerHelper 
@ Version:        1.0
@ Author:         DineshKumar 
@ Purpose:        Handler Class to Perform operations on WorkOrder & Case
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.27.2019 / Nandhini/ Created the class
**************************************************************************************************************************************************************/
/*@Class Name- WorkOrderTriggerHelper
*@description- This class is used to Perform operations on WorkOrder & related case
*/
public without sharing class WorkOrderTriggerHelper{
    public static Boolean isCancelGenesys = false;
    /*@methodName- updateCaseDetail
*@description- Method to do updates Case details using workorder
*@param-Map<id,WorkOrder> woMap,Map<id,WorkOrder> oldWoMap,Map<id,Case> caseWOMap
*@return- null
*/   
    public static void updateCaseDetail(Map<id,WorkOrder> woMap,Map<id,WorkOrder> oldWoMap,Map<id,Case> caseWOMap ){
    //System.debug('***Inside test loop- WOHelperr****');
        Set<id> caseIdSet = new set<id>();
        List<case> caseRelatedList = new List<case>();
        set<id> acornCaseIdSet = new set<Id>();
        set<id> woVendorList = new set<Id>();
        List<case> caseupdateList = new List<case>();
        Map<string,string> caseWOIdMap = new Map<string,string>();
        Map<string,string> caseVendorIdMap = new Map<string,string>();
        Map<Id,Account> vendorsMap;
        try{
            for(workOrder woRecord : woMap.values()){
                caseWOIdMap.put(woRecord.caseId,woRecord.Id);
                if(woRecord.Vendor_Account_Id__c!=null){
                    woVendorList.add(woRecord.Vendor_Account_Id__c);
                    caseVendorIdMap.put(woRecord.caseId,woRecord.Vendor_Account_Id__c);
                }
            }
            // soql 101 issue fix - SDT- 40083
            if(!woVendorList.isEmpty()){
                vendorsMap = new Map<Id,Account>([select Id,Contact_Manually_Vendor__c from Account where id in :woVendorList]);
            }
            
            if(caseWOIdMap != null && !caseWOIdMap.isEmpty()){                
                if(caseWOMap != null && !caseWOMap.isEmpty()){
                    for(case caseRecord : caseWOMap.values()){
                        if(String.isBlank(caseRecord.Work_Order__c)){
                            caseRecord.Work_Order__c = caseWOIdMap.get(caseRecord.Id);
                        }
                        workOrder oldWoRecord = new workorder();
                        workOrder woRecord = woMap.get(caseWOIdMap.get(caseRecord.Id));
                        if(woRecord != null){
                        if(oldWoMap != null && !oldWoMap.isEmpty() && oldWoMap.containsKey(caseWOIdMap.get(caseRecord.Id))){
                            oldWoRecord = oldWoMap.get(caseWOIdMap.get(caseRecord.Id));                             
                        }
                        if(!constant_util.CLOSED.equalsIgnoreCase(caseRecord.status) && ((oldWoRecord != null && woRecord.Service_Date__c!= oldWoRecord.Service_Date__c && woRecord.Vendor_Service_Status__c!= oldWoRecord.Vendor_Service_Status__c) || !RecurrsiveTriggerHandler.bypassValidation)){
                            caseRecord.Proposed_Service_Date__c = woRecord.Service_Date__c;
                        }      
                        if(!constant_util.CLOSED.equalsIgnoreCase(caseRecord.status) && ((oldWoRecord != null && woRecord.Rescheduled_Date__c!= oldWoRecord.Rescheduled_Date__c && woRecord.Vendor_Service_Status__c!= oldWoRecord.Vendor_Service_Status__c) || !RecurrsiveTriggerHandler.bypassValidation)){
                            caseRecord.Proposed_Service_Date__c = woRecord.Rescheduled_Date__c!=null?woRecord.Rescheduled_Date__c.Date():null;
                        }
                        if((oldWoRecord == null || (oldWoRecord != null && oldWoRecord.Acorn_WorkOrder_Number__c!=woRecord.Acorn_WorkOrder_Number__c)) && constant_util.OPEN.equalsIgnoreCase(caseRecord.status) &&
                         (vendorsMap!=null && caseVendorIdMap!=null && caseVendorIdMap.get(caseRecord.Id)!=null && vendorsMap.get(caseVendorIdMap.get(caseRecord.Id)).Contact_Manually_Vendor__c) && caseRecord.Service_Date__c>=caseRecord.Service_date_from_local_time__c && !Constant_UTIL.Pending_Manual_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) && !woRecord.Is_Bypass__c){
				caseRecord.Case_Sub_Status__c = Constant_UTIL.Pending_Manual_Dispatch;
                                caseRecord.status = constant_util.OPEN;
                        }
						else
						
						{
							if(((Constant_UTIL.PENDING_SERVICE_INTEGRATION.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) || caseRecord.Source_System__c=='Acorn') && constant_util.OPEN.equalsIgnoreCase(caseRecord.status))
                          && (Constant_UTIL.ISSUED.equalsIgnoreCase(woRecord.status) ||(Constant_UTIL.SENT.equalsIgnoreCase(woRecord.status) && Constant_UTIL.SCHEDULED.equalsIgnoreCase(woRecord.send_status__c))) && !Constant_UTIL.Pending_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) && !(vendorsMap!=null && caseVendorIdMap!=null && caseVendorIdMap.get(caseRecord.Id)!=null && vendorsMap.get(caseVendorIdMap.get(caseRecord.Id)).Contact_Manually_Vendor__c)){
                            caseRecord.Case_Sub_Status__c  = Constant_UTIL.Pending_Dispatch;
                        }
						
						}
						
                        if(woRecord.Vendor_Service_Status__c != null && woRecord.Vendor_Service_Status__c.contains(constant_util.CONFIRMED_NEGATIVE)){//&&  !constant_util.CLOSED.equalsIgnoreCase(caseRecord.status)
                           if(constant_util.OPEN.equalsIgnoreCase(caseRecord.status)){
                                caseRelatedList.add(caseRecord);
                            }
                            caseRecord.Case_Sub_Status__c = constant_util.SERVICE_NOT_PERFORMED;
                            caseRecord.status = constant_util.CLOSED;
                            
                        }
                        if((Constant_UTIL.SENT.equalsIgnoreCase(woRecord.Send_Status__c) || Constant_UTIL.DELIVERED.equalsIgnoreCase(woRecord.Send_Status__c))
                          && (!Constant_Util.ACCEPTED.equalsIgnoreCase(woRecord.status) || !Constant_Util.CANCELLED.equalsIgnoreCase(woRecord.status) || !Constant_Util.CLOSED.equalsIgnoreCase(woRecord.status))
                           && !constant_util.CLOSED.equalsIgnoreCase(caseRecord.status) && caseRecord.Service_Date__c>= System.today() && !Constant_Util.Pending_Service_Confirmation.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)
                                                                                                                                          && !Constant_Util.Pending_Schedule_Confirmation.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)){
                               if(caseRecord.Availability_Confirmed__c){
                                   caseRecord.Case_Sub_Status__c  = Constant_Util.Pending_Service_Confirmation;
                               }else{
                                   caseRecord.Case_Sub_Status__c  = Constant_Util.Pending_Schedule_Confirmation;
                               }
                            caseRecord.status = constant_util.OPEN ;
                        }
                        //Service Confirmed from PB
                        if(woRecord.Vendor_Service_Status__c != null && oldWoRecord.Vendor_Service_Status__c!=woRecord.Vendor_Service_Status__c && woRecord.Vendor_Service_Status__c.contains(constant_util.CONFIRMED_POSITIVE) && (constant_util.CLOSED.equalsIgnoreCase(caseRecord.status)
                        || ((Constant_Util.SENT.equalsIgnoreCase(woRecord.status) ||Constant_Util.RELEASED_FOR_PAYMENT.equalsIgnoreCase(woRecord.status)|| Constant_Util.ACCEPTED.equalsIgnoreCase(woRecord.status) || Constant_Util.WORK_COMPLETE.equalsIgnoreCase(woRecord.status) || Constant_Util.CLOSED.equalsIgnoreCase(woRecord.status)) && 
                                                                                                                                                    constant_util.OPEN.equalsIgnoreCase(caseRecord.status) && !Constant_Util.Pending_Manual_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) 
                                                                                                                                                   ))){                                                                                                                          
                            caseRecord.Case_Sub_Status__c = Constant_Util.SERVICE_CONFIRMED;
                            caseRecord.status = constant_util.CLOSED;
                        }
                        
                        if(oldWoRecord != null && (!Constant_Util.Pending_Service_Confirmation.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) && constant_util.OPEN.equalsIgnoreCase(caseRecord.status) && ((((woRecord.status != oldWoRecord.status) && (Constant_Util.SENT.equalsIgnoreCase(woRecord.status) ||Constant_Util.RELEASED_FOR_PAYMENT.equalsIgnoreCase(woRecord.status)|| Constant_Util.ACCEPTED.equalsIgnoreCase(woRecord.status) || Constant_Util.WORK_COMPLETE.equalsIgnoreCase(woRecord.status) || Constant_Util.CLOSED.equalsIgnoreCase(woRecord.status))) && 
                                                                                                                                                    woRecord.Service_Date__c <system.today() && constant_util.OPEN.equalsIgnoreCase(caseRecord.status) && !Constant_Util.Pending_Manual_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) && 
                                                                                                                                                    (string.isBlank(woRecord.Vendor_Service_Status__c) || Constant_Util.SCHEDULED.equalsIgnoreCase(woRecord.Vendor_Service_Status__c))
                                                                                                                                                   )
                                                                                                                                                   || (Constant_Util.SCHEDULED.equalsIgnoreCase(woRecord.Vendor_Service_Status__c) || !string.isBlank(woRecord.MAS_Ticket__c))
                                                                                                                                                   || (constant_util.OPEN.equalsIgnoreCase(caseRecord.status) && !Constant_Util.Pending_Manual_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)  && Constant_Util.ACCEPTED.equalsIgnoreCase(woRecord.status))
                                                                                                                                                  ))){
                                                                                                                                                      caseRecord.status = constant_util.OPEN ;
                                                                                                                                                      caseRecord.Case_Sub_Status__c  = Constant_Util.Pending_Service_Confirmation;
                                                                                                                                                  }
                        if(oldWoRecord.status!=woRecord.status && Constant_Util.CANCELLED.equalsIgnoreCase(woRecord.status)  && constant_util.OPEN.equalsIgnoreCase(caseRecord.status) &&  !Constant_Util.Request_Canceled.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)){
                            caseRecord.status = constant_util.CLOSED;
                            caseRecord.Case_Sub_Status__c  = Constant_Util.Request_Canceled;
                        }
                       /** if(((Constant_UTIL.PENDING_SERVICE_INTEGRATION.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) || caseRecord.Source_System__c=='Acorn') && constant_util.OPEN.equalsIgnoreCase(caseRecord.status))
                          && (Constant_UTIL.ISSUED.equalsIgnoreCase(woRecord.status) ||(Constant_UTIL.SENT.equalsIgnoreCase(woRecord.status) && Constant_UTIL.SCHEDULED.equalsIgnoreCase(woRecord.send_status__c))) && !Constant_UTIL.Pending_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)){
                            caseRecord.Case_Sub_Status__c  = Constant_UTIL.Pending_Dispatch;
                        }*/
                        if(Constant_UTIL.REJECTED.equalsIgnoreCase(woRecord.status)){
							caseRecord.status = constant_util.CLOSED;
						}
                        caseupdateList.add(caseRecord);
                    }
                    }
                }
            }
            
            if(caseRelatedList != null && !caseRelatedList.isEmpty()){
                CaseCreation.createRelatedCase(caseRelatedList);
            }
            System.debug('caseupdateList---in helpe-'+caseupdateList);
            if(caseupdateList != null && !caseupdateList.isEmpty()){
                if(!System.isBatch() && !System.isFuture() && caseupdateList.size() > 1){
                    SObjectUpdateBatch b = new SObjectUpdateBatch(caseupdateList);
                    Database.executeBatch(b , 10);
                } else {
                    Database.saveResult[] srList = database.update(caseupdateList,false);      
                }              
                //UTIL_LoggingService.logDmlResults(srList,null,caseupdateList,UTIL_ErrorConstants.ERROR_APPLICATION,UTIL_ErrorConstants.WORKORDER_TRIGGER_HELPER,UTIL_ErrorConstants.WORKORDER_UPDATE_CASE_DETAILS,UTIL_ErrorConstants.WORKORDER_TRIGGER,LoggingLevel.ERROR);
            }
        }
        catch(exception excp){
            UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    /**@MethodName ServiceDateChanges
    * Method to update task or close case when service date is changed for SDT-7434.
    **/
    Public Static void ServiceDateChanges(List<WorkOrder> woLst, Map<Id,WorkOrder> oldWoMap){
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id, Date> caseWoMap = New Map<Id, Date>();
        Map<Id, String> caseMap = New Map<Id, String>();
        List<Task> updateTaskLst = new List<Task>();
        List<case> updateCaseLst = new List<case>();
        Id businessHoursId = [SELECT Id, FridayEndTime FROM BusinessHours WHERE Name =: Constant_Util.BUSINESSNAME AND
                                     IsActive = true LIMIT 1].Id;
        Long intervalMilliseconds = Long.valueof(string.valueof((decimal.valueOf(0)*3600000).round(System.RoundingMode.HALF_UP))); 
        DateTime closingBusinessTime = BusinessHours.addGmt(businessHoursId,system.now(),intervalMilliseconds);
        try {
            for(WorkOrder wo : woLst) {
                if(oldWoMap != null && oldWoMap.get(wo.Id).Service_Date__c != null && wo.Service_Date__c != null
                            && wo.Service_Date__c != oldWoMap.get(wo.Id).Service_Date__c && wo.CaseId != null) {          
                    //Obtain Schedule Confirmation Task
                    if(wo.Service_Date__c > system.today().adddays(14) ) {
                        caseMap.put(wo.CaseId, 'OSC');
                        caseIdSet.add(wo.CaseId);
                    }
                    if(wo.Service_Date__c < oldWoMap.get(wo.Id).Service_Date__c && wo.Service_Date__c >= system.today()){
                        if(closingBusinessTime <= system.now()) {
                            if(!caseWoMap.containsKey(wo.CaseId)) {
                                //To update dueDateTime on task
                                caseWoMap.put(wo.CaseId, wo.Service_Date__c);
                            }
                            caseIdSet.add(wo.CaseId);
                        } else {
                            caseIdSet.add(wo.CaseId);
                            //Send cancel genesys
                            isCancelGenesys = true;
                        }   
                    }   
                    if(wo.Service_Date__c < system.today()){
                        caseIdSet.add(wo.CaseId);
                        //Send cancel genesys
                        isCancelGenesys = true;
                    }
                    //All Confirm service Completion related task
                    if(wo.Service_Date__c >= system.today()) {            
                        if(!caseMap.containsKey(wo.CaseId)) {
                            caseMap.put(wo.CaseId, 'CSC');
                        }
                        caseIdSet.add(wo.CaseId);
                    }
                }
            }
            if(caseIdSet.size()>0) {
                String containsProcess = Constant_Util.PERCENTAGE + Constant_Util.CONFIRM_SERVICE_COMPLETION + Constant_Util.PERCENTAGE;
                for(Task tsk : [SELECT Id, WhatId, Process__c, status, Is_Attempt_Created__c FROM Task WHERE WhatId IN: caseIdSet
                                AND status =: Constant_Util.OPEN AND (Process__c =: Constant_Util.Obtain_Schedule_Confirmation
                                OR Process__c LIKE: containsProcess)]) {
                    if(caseWoMap.containsKey(tsk.WhatId)) {
                        tsk.Due_Date_Time__c = system.now().addhours(4);
                    } else {
                        tsk.status = Constant_Util.COMPLETED;
                        tsk.Is_Attempt_Created__c = true;
                        tsk.Description__c = 'This task has been automatically closed as workorder service date is changed';
                    }
                    updateTaskLst.add(tsk);                
                }
            }
            if(updateTaskLst != null && !updateTaskLst.isEmpty()){
                Database.saveResult[] dbsrLst = database.update(updateTaskLst,false);                
                UTIL_LoggingService.logDmlResults(dbsrLst,null,updateTaskLst,UTIL_ErrorConstants.ERROR_APPLICATION,UTIL_ErrorConstants.WORKORDER_TRIGGER_HELPER,UTIL_ErrorConstants.WORKORDER_UPDATE_CASE_DETAILS,UTIL_ErrorConstants.WORKORDER_TRIGGER,LoggingLevel.ERROR);
            }
            case cse = null;
            for(Id caseId : caseMap.KeySet()) {
                if(caseMap.containsKey(caseId)) {
                    cse = new case(Id = caseId);
                    if(caseMap.get(caseId) == 'OSC') {
                        cse.Is_Case_OSC_Created__c = false;
                    }
                    if(caseMap.get(caseId) == 'CSC') {
                        cse.Is_Case_CSC_Created__c = false;
                    }
                    updateCaseLst.add(cse);
                }
            }
            if(updateCaseLst != null && !updateCaseLst.isEmpty()){
                Database.saveResult[] dbsrLst = database.update(updateCaseLst,false);                
                UTIL_LoggingService.logDmlResults(dbsrLst,null,updateCaseLst,UTIL_ErrorConstants.ERROR_APPLICATION,UTIL_ErrorConstants.WORKORDER_TRIGGER_HELPER,UTIL_ErrorConstants.WORKORDER_UPDATE_CASE_DETAILS,UTIL_ErrorConstants.WORKORDER_TRIGGER,LoggingLevel.ERROR);
            }
			  } catch(exception excp){
            UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }

    /**@MethodName createCaseComment
    * Method to create Comment related to Case for SDT-18820
    **/
    public Static void createCaseComment(Map<String , List<WorkOrder>> commentWOMap){
        Map<String , Comment_Log_Detail__mdt> commentLogTemplateData = new Map<String , Comment_Log_Detail__mdt>();
        for(Comment_Log_Detail__mdt c : Comment_Log_Detail__mdt.getAll().values()){
            commentLogTemplateData.put(c.DeveloperName , c);
        }
        Map<String , String> fieldTemplateMap = new Map<String , String>();
        List<Comment__c> commentList = new List<Comment__c>();
        Set<String> dateTimeFields = new Set<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('WorkOrder');
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
        for(Schema.SObjectField field : fieldMap.values()) {
            fieldTemplateMap.put('<' + field.getDescribe().getName() + '>' , field.getDescribe().getName());
            if(field.getDescribe().getType() == Schema.DisplayType.DateTime || field.getDescribe().getType() == Schema.DisplayType.Date){
                dateTimeFields.add('<' + field.getDescribe().getName() + '>');
            }
            
        }
        try {
            for(String key : commentWOMap.keySet()){
                for(WorkOrder wo : commentWOMap.get(key)){
                    String commentBody = commentLogTemplateData.containsKey(key) ? commentLogTemplateData.get(key).Comment__c : '';
                    Comment__c comment = new Comment__c();
                    comment.Case__c = wo.CaseId;
                    for(String field : fieldTemplateMap.keySet()){
                        if(fieldTemplateMap.get(field) != null && commentBody.contains(field)) {
                            String fieldValue = '';
                            if(dateTimeFields.contains(field)){
                                fieldValue = wo.get(fieldTemplateMap.get(field)) != null ? Date.valueOf(wo.get(fieldTemplateMap.get(field))).format() : '';
                            } else {
                                fieldValue = wo.get(fieldTemplateMap.get(field)) != null ? String.valueOf(wo.get(fieldTemplateMap.get(field))) : '';
                            }
                            commentBody = commentBody.replaceAll(field , fieldValue);
                        }   
                    }
                    comment.Comment__c = commentBody;
                    comment.Workflow_Action__c = Constant_Util.WORK_ORDER_ACTION_TYPE;
                    comment.Related_SObject_Id__c = wo.id;
                    comment.Related_SObject_Key__c = wo.Acorn_WorkOrder_Number__c;
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