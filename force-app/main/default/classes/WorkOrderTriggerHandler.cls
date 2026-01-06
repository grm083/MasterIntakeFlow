/*************************************************************************************************************************************************************
@ Class:          WorkOrderTriggerHandler
@ Version:        1.0
@ Author:         DineshKumar 
@ Purpose:        Handler Class to Perform operations on WorkOrder
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.27.2019 / Nandhini/ Created the class
**************************************************************************************************************************************************************/
/*@Class Name- WorkOrderTriggerHandler
*@description- This class is used to perform operation on WorkOrders
*/
public without sharing class WorkOrderTriggerHandler{
    public static List<WorkOrder> workOrderNewList = new List<WorkOrder>();
    public static Map<id,WorkOrder> workOrderNewMap = new Map<id,WorkOrder>();
    public static Map<id,WorkOrder> workOrderOldMap = new Map<id,WorkOrder>();
    public static Map<id,WorkOrder> caseUpdateWOMap = new Map<id,WorkOrder>();
    public static List<WorkOrder> acronWOlst = new List<WorkOrder>();
    public static set<id> caseIdSet = new Set<Id>();
    public static set<id> accountIdSet = new Set<Id>();
    public static Map<id,Case> caseWOMap = new Map<id,Case>();
     /*@methodName- beforeInsertMethod
    *@description- Method to do updates before insert
    *@param- TriggerParameters
    *@return- null
    */   
    public static void beforeInsert(TriggerParameters triggerParam){
        if(Constant_UTIL.skipWOTrigger) {
            return;
        }
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        WorkOrder woRecord = new WorkOrder();
        System.debug('before insert');
        for(sObject sobjVal : triggerParam.newList){
            woRecord = (WorkOrder)sobjVal ; 
            if(woRecord.CaseId != null){
                caseIdSet.add(woRecord.CaseId);
            }  
            if(woRecord.Customer_Location__c != null){
                accountIdSet.add(woRecord.Customer_Location__c);  
            }            
        }
        if(caseIdSet != null && !caseIdSet.isEmpty()){
            caseWOMap = getCaseDetails(caseIdSet);
        }
        if(!accountIdSet.isEmpty()){
           accMap = getAccountDetails(accountIdSet); 
        }
        System.debug('caseWOMap ==in work order='+caseWOMap );
        for(sObject sobjVal : triggerParam.newList){
            woRecord = (WorkOrder)sobjVal ; 
           
            system.debug('woRecord.CaseId----'+woRecord.CaseId);
            System.debug('caseWOMap.containsKey(woRecord.CaseId)==in work order='+caseWOMap.containsKey(woRecord.CaseId));
            if(caseWOMap != null && !caseWOMap.isEmpty() && caseWOMap.containsKey(woRecord.CaseId)){
                Case casRecord = (Case) caseWOMap.get(woRecord.CaseId);
                System.debug('casRecord.Work_Order_Instructions__c ==='+casRecord.Work_Order_Instructions__c);
                woRecord.Instructions__c = casRecord.Work_Order_Instructions__c; 
                if(!string.isBlank(casRecord.ContactId)) {
                    woRecord.ContactId = casRecord.ContactId; 
                }    
            }
            if(!accMap.isEmpty() &&  accMap.containsKey(woRecord.Customer_Location__c)){
                woRecord.Client__c = accMap.get(woRecord.Customer_Location__c).ParentId;
				if(Constant_Util.COUNTRY.equalsIgnoreCase(accMap.get(woRecord.Customer_Location__c).ShippingCountry))
				{
					woRecord.CurrencyIsoCode = Constant_Util.COUNTRY_CURRENCY;
				}
            }
        }

        updateDispatchEmail(triggerParam.newList);
        updateDryRunDetail(triggerParam.newList , null);
    }
    /*@methodName- beforeUpdate
    *@description- Method to do updates before insert
    *@param- TriggerParameters
    *@return- null
    */   
    public static void beforeUpdate(TriggerParameters triggerParam){
        if(Constant_UTIL.skipWOTrigger) {
            return;
        }
    	// Added this to prevent ACORN Integration User and others
    	// From executing extraneous callouts to API Hub
    	RecurrsiveTriggerHandler.getByPassValidationForWorkOrder();
        
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        WorkOrder woRecord = new WorkOrder();
        for(sObject sobjVal : triggerParam.newList){
            woRecord = (WorkOrder)sobjVal ; 
            if(woRecord.CaseId != null){
                caseIdSet.add(woRecord.CaseId);
            }
            if(woRecord.Customer_Location__c != null){
                accountIdSet.add(woRecord.Customer_Location__c); 
            }    
        }
        if((caseIdSet != null && !caseIdSet.isEmpty()) && !(Boolean)triggerParam.isInsert){
            caseWOMap = getCaseDetails(caseIdSet);
        }
        if(!accountIdSet.isEmpty()){
            accMap = getAccountDetails(accountIdSet); 
        }
        for(sObject sobjVal : triggerParam.newList){
            woRecord = (WorkOrder)sobjVal ; 
            WorkOrder oldWoRecord = (WorkOrder)triggerParam.OldMap.get(woRecord.id);
            System.debug('beforeUpdate-woRecord'+woRecord);
            System.debug('beforeUpdate-oldWoRecord'+oldWoRecord);
            WorkOrderOldMap.put(oldWoRecord.id,oldWoRecord );
            if(((woRecord.Actual_Service_Date__c != oldWoRecord.Actual_Service_Date__c) || (woRecord.Service_Date__c != oldWoRecord.Service_Date__c ) ||
                (woRecord.Fast_Lane_Ticket__c != oldWoRecord.Fast_Lane_Ticket__c ) || (woRecord.Manifest_Number__c != oldWoRecord.Manifest_Number__c ) ||
                (woRecord.Instructions__c!= oldWoRecord.Instructions__c) || (woRecord.MAS_Case__c!= oldWoRecord.MAS_Case__c) ||
                (woRecord.MAS_Ticket__c != oldWoRecord.MAS_Ticket__c ) || (woRecord.Pickup_DateTime__c!= oldWoRecord.Pickup_DateTime__c) ||
                (woRecord.Profile_Description__c != oldWoRecord.Profile_Description__c ) || (woRecord.Profile_Number__c!= oldWoRecord.Profile_Number__c) ||
                (woRecord.Profile_Generator__c != oldWoRecord.Profile_Generator__c ) || (woRecord.Profile_Purchase_Order__c!= oldWoRecord.Profile_Purchase_Order__c) ||
                (woRecord.Vehicle_Number__c!= oldWoRecord.Vehicle_Number__c) || (woRecord.Return_DateTime__c != oldWoRecord.Return_DateTime__c )
               ) && 
			   !(Constant_Util.CANCELLED.equalsIgnoreCase(woRecord.status) || Constant_Util.REJECTED.equalsIgnoreCase(woRecord.status)|| constant_util.CLOSED.equalsIgnoreCase(woRecord.status))
                           && !Constant_Util.UPDATEVAL.equalsIgnoreCase(woRecord.Integration_Status__c)
                           && !RecurrsiveTriggerHandler.bypassValidation){
                woRecord.Integration_Status__c = Constant_Util.UPDATEVAL;             
                acronWOlst.add(woRecord);
            }
            if(caseWOMap != null && !caseWOMap.isEmpty() && caseWOMap.containsKey(woRecord.CaseId) ){
                Case casRecord = (Case) caseWOMap.get(woRecord.CaseId);
                if(string.isBlank(woRecord.Instructions__c)) {
                    woRecord.Instructions__c = casRecord.Work_Order_Instructions__c!= null ?casRecord.Work_Order_Instructions__c:Constant_Util.EMPTY_STRING; 
                }
                if(!string.isBlank(casRecord.ContactId)) {
                    woRecord.ContactId = casRecord.ContactId; 
                }
            }
            if(!accMap.isEmpty() &&  accMap.containsKey(woRecord.Customer_Location__c)){
                woRecord.Client__c = accMap.get(woRecord.Customer_Location__c).ParentId; 
            }
        }
        updateDispatchEmail(triggerParam.newList);
        updateDryRunDetail(triggerParam.newList , triggerParam.oldMap);
    }
    /*@methodName- afterInsert
    *@description- Method to do updates after insert
    *@param- TriggerParameters
    *@return- null
    */  
    public static void afterInsert(TriggerParameters triggerParam){
        if(Constant_UTIL.skipWOTrigger) {
            return;
        }
        Map<String , List<WorkOrder>> commentWOMap = new Map<String , List<WorkOrder>>();
        for(sObject sobjVal : triggerParam.newList){
            workOrder woRecord = (WorkOrder)sobjVal ; 
            workOrderNewMap.put(woRecord.id,woRecord );            
            if(!string.isBlank(string.valueof(woRecord.Vendor_Account_Id__c)) || !string.isBlank(string.valueof(woRecord.caseId) )){
                caseUpdateWOMap.put(woRecord.id,woRecord);
            }
            if(woRecord.Acorn_WorkOrder_Number__c != null){
                if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION)){
                    commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION , new List<WorkOrder>{woRecord});
                } else {
                    commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION).add(woRecord);
                }
            }    
        }
        if((caseUpdateWOMap!= null && !caseUpdateWOMap.isEmpty()) && (caseWOMap != null && !caseWOMap.isEmpty())){
            WorkOrderTriggerHelper.updateCaseDetail(caseUpdateWOMap,new Map<id,workorder>(),caseWOMap );
        }
        /*if(acronWOIdSet!= null && !acronWOIdSet.isEmpty()){
            UpdateWorkOrder.sendtoAcorn(acronWOIdSet);
        }*/
        if(WorkOrderNewMap != null && !WorkOrderNewMap.isEMpty() && (TriggerDispatcher.skipTriggerExecutionMap==null || TriggerDispatcher.skipTriggerExecutionMap.get(WorkOrder.sobjectType.getDescribe().getName())==null
            || !TriggerDispatcher.skipTriggerExecutionMap.get(WorkOrder.sobjectType.getDescribe().getName()))){
            CreateCaseHistory.createHistoryRecordOnRecordCreate(workOrderNewMap);
            TriggerDispatcher.skipTriggerExecutionMap.put(WorkOrder.sobjectType.getDescribe().getName(),true);
        }
        if(!commentWOMap.isEmpty()){
            WorkOrderTriggerHelper.createCaseComment(commentWOMap );
        }
    }
    /*@methodName- afterUpdate
    *@description- Method to do updates after update
    *@param- TriggerParameters
    *@return- null
    */ 
    public static void afterUpdate(TriggerParameters triggerParam){  
        if(Constant_UTIL.skipWOTrigger) {
            return;
        }
        Map<String , List<WorkOrder>> commentWOMap = new Map<String , List<WorkOrder>>();
        for(sObject sobjVal : triggerParam.newList){
        //System.debug('***Inside test loop- WOHandler****');
            workOrder woRecord = (WorkOrder)sobjVal ; 
            workOrderNewMap.put(woRecord.id,woRecord);
            WorkOrder oldWoRecord = (workOrder)triggerParam.OldMap.get(woRecord.id);
            //WorkOrder oldWoRecord = (workOrder)triggerParam.mostRecentOldMap.get(woRecord.id);            
            workOrderOldMap.put(oldWoRecord.id,oldWoRecord );
            System.debug('woRecord'+woRecord);
            System.debug('oldWoRecord'+oldWoRecord);
            if(woRecord.CaseId != null && caseWOMap != null && !caseWOMap.isEmpty() && caseWOMap.containsKey(woRecord.CaseId)){
                Case caseRecord = (Case) caseWOMap.get(woRecord.CaseId);//  
                if((!string.isBlank(woRecord.Vendor_Account_Id__c ) && woRecord.Vendor_Account_Id__c != oldWoRecord.Vendor_Account_Id__c) 
                || (oldWoRecord != null && oldWoRecord.Acorn_WorkOrder_Number__c!=woRecord.Acorn_WorkOrder_Number__c) || 
                (((!string.isBlank(woRecord.Vendor_Service_Status__c)&& woRecord.Vendor_Service_Status__c != null && woRecord.Vendor_Service_Status__c != oldWoRecord.Vendor_Service_Status__c) && 
                   (!constant_util.CLOSED.equalsIgnoreCase(caseRecord.status) && (woRecord.Service_Date__c!= oldWoRecord.Service_Date__c) || (woRecord.Rescheduled_Date__c!= oldWoRecord.Rescheduled_Date__c)))) 
                ||
                (woRecord.Vendor_Service_Status__c != null && woRecord.Vendor_Service_Status__c.contains(Constant_Util.CONFIRMED_NEGATIVE) && !constant_util.CLOSED.equalsIgnoreCase(caseRecord.status)) 
                ||
                (woRecord.Vendor_Service_Status__c != null && woRecord.Vendor_Service_Status__c.contains(Constant_Util.CONFIRMED_POSITIVE) && !constant_util.CLOSED.equalsIgnoreCase(caseRecord.status)) 
                ||
                (woRecord.Vendor_Service_Status__c != oldWoRecord.Vendor_Service_Status__c  && woRecord.Vendor_Service_Status__c != null && woRecord.Vendor_Service_Status__c.contains(Constant_Util.CONFIRMED_POSITIVE) && constant_util.CLOSED.equalsIgnoreCase(caseRecord.status)) 
                ||
                (!Constant_Util.Pending_Service_Confirmation.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) && ((((woRecord.status != oldWoRecord.status) && (Constant_Util.SENT.equalsIgnoreCase(woRecord.status) ||Constant_Util.RELEASED_FOR_PAYMENT.equalsIgnoreCase(woRecord.status)|| Constant_Util.ACCEPTED.equalsIgnoreCase(woRecord.status) || Constant_Util.WORK_COMPLETE.equalsIgnoreCase(woRecord.status) || Constant_Util.CLOSED.equalsIgnoreCase(woRecord.status))) && 
                         woRecord.Service_Date__c <system.today() && constant_util.OPEN.equalsIgnoreCase(caseRecord.status) && !Constant_Util.Pending_Manual_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) && 
                         (string.isBlank(woRecord.Vendor_Service_Status__c) || Constant_Util.SCHEDULED.equalsIgnoreCase(woRecord.Vendor_Service_Status__c))
                       )
                       || (Constant_Util.SCHEDULED.equalsIgnoreCase(woRecord.Vendor_Service_Status__c) || !string.isBlank(woRecord.MAS_Ticket__c))
                       || (constant_util.OPEN.equalsIgnoreCase(caseRecord.status) && !Constant_Util.Pending_Manual_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)  && Constant_Util.ACCEPTED.equalsIgnoreCase(woRecord.status))
                        )
                )
                || 
                (Constant_Util.CANCELLED.equalsIgnoreCase(woRecord.status)  && constant_util.OPEN.equalsIgnoreCase(caseRecord.status) && !Constant_Util.Request_Canceled.equalsIgnoreCase(caseRecord.Case_Sub_Status__c))
                ||
                (((Constant_UTIL.PENDING_SERVICE_INTEGRATION.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) || caseRecord.Source_System__c=='Acorn') && constant_util.OPEN.equalsIgnoreCase(caseRecord.status))
                          && (Constant_UTIL.ISSUED.equalsIgnoreCase(woRecord.status) ||(Constant_UTIL.SENT.equalsIgnoreCase(woRecord.status) && Constant_UTIL.SCHEDULED.equalsIgnoreCase(woRecord.send_status__c))) && !Constant_UTIL.Pending_Dispatch.equalsIgnoreCase(caseRecord.Case_Sub_Status__c))
                ||
                (woRecord.Vendor_Service_Status__c != oldWoRecord.Vendor_Service_Status__c  && woRecord.Vendor_Service_Status__c != null && woRecord.Vendor_Service_Status__c.contains(Constant_Util.CONFIRMED_NEGATIVE) && constant_util.CLOSED.equalsIgnoreCase(caseRecord.status))
                ||
                ((Constant_UTIL.SENT.equalsIgnoreCase(woRecord.Send_Status__c) || Constant_UTIL.DELIVERED.equalsIgnoreCase(woRecord.Send_Status__c))
                          && (!Constant_Util.ACCEPTED.equalsIgnoreCase(woRecord.status) || !Constant_Util.CANCELLED.equalsIgnoreCase(woRecord.status) || !Constant_Util.CLOSED.equalsIgnoreCase(woRecord.status))
                           && !constant_util.CLOSED.equalsIgnoreCase(caseRecord.status) && caseRecord.Service_Date__c>= System.today() && !Constant_Util.Pending_Service_Confirmation.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)
                                                                                                                                          && !Constant_Util.Pending_Schedule_Confirmation.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)))
                {
                    caseUpdateWOMap.put(woRecord.id,woRecord);
                }  
            }          
            if(Constant_UTIL.REJECTED.equalsIgnoreCase(woRecord.status)){
             	caseUpdateWOMap.put(woRecord.id,woRecord);   
            }

            if(Constant_Util.WORK_COMPLETE.equalsIgnoreCase(woRecord.status) && !Constant_Util.WORK_COMPLETE.equalsIgnoreCase(oldWORecord.status)){
                if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_COMPLETION)){
                    commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_COMPLETION , new List<WorkOrder>{woRecord});
                } else {
                    commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_COMPLETION).add(woRecord);
                }
            }

            if(woRecord.Dry_Run_Root_Cause__c != null && woRecord.Dry_Run_Root_Cause__c != oldWORecord.Dry_Run_Root_Cause__c ){
                if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_DRY_RUN)){
                    commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_DRY_RUN , new List<WorkOrder>{woRecord});
                } else {
                    commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_DRY_RUN).add(woRecord);
                }
            }

            //Not creating cancelled comment if already getting cancelled from Dry Run process
            else  if(Constant_Util.CANCELLED.equalsIgnoreCase(woRecord.status) && !Constant_Util.CANCELLED.equalsIgnoreCase(oldWORecord.status) ){
                if(woRecord.Exception_Reason__c != null || woRecord.Exception_Description__c != null) {
                    if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CANCELLATION)){
                        commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CANCELLATION , new List<WorkOrder>{woRecord});
                    } else {
                        commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CANCELLATION).add(woRecord);
                    }
                } else {
                    if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION)){
                        commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION , new List<WorkOrder>{woRecord});
                    } else {
                        commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION).add(woRecord);
                    }
                }
            }

            
            if(woRecord.Service_Date__c != null && woRecord.Service_Date__c != oldWORecord.Service_Date__c ){
                if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_SERVICE_DATE_CHANGE)){
                    commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_SERVICE_DATE_CHANGE , new List<WorkOrder>{woRecord});
                } else {
                    commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_SERVICE_DATE_CHANGE).add(woRecord);
                }
            }

            if(woRecord.Vendor_Service_Status__c != null && woRecord.Vendor_Service_Status__c != oldWORecord.Vendor_Service_Status__c ){
                if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_VENDOR_STATUS_CHANGE)){
                    commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_VENDOR_STATUS_CHANGE , new List<WorkOrder>{woRecord});
                } else {
                    commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_VENDOR_STATUS_CHANGE).add(woRecord);
                }
            }
			
            if(woRecord.Acorn_WorkOrder_Number__c != null && oldWORecord.Acorn_WorkOrder_Number__c == null){ 
                if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION)){
                    commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION , new List<WorkOrder>{woRecord});
                } else {
                    commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION).add(woRecord);
                }
            }  
              
            if(woRecord.Status != null && woRecord.Status != oldWORecord.Status 
                && !Constant_Util.WORK_COMPLETE.equalsIgnoreCase(woRecord.status)
                && !Constant_Util.CANCELLED.equalsIgnoreCase(woRecord.status)){
                    if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION)){
                        commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION , new List<WorkOrder>{woRecord});
                    } else {
                        commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION).add(woRecord);
                    }
            }  
            
            if(Constant_Util.RESEND.equalsIgnoreCase(woRecord.Integration_Status__c) && woRecord.Integration_Status__c != oldWORecord.Integration_Status__c 
                && Constant_Util.SENT.equalsIgnoreCase(woRecord.status) && Constant_Util.SENT.equalsIgnoreCase(oldWORecord.status)) {
                     if(!commentWOMap.containsKey(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION)){
                        commentWOMap.put(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION , new List<WorkOrder>{woRecord});
                    } else {
                        commentWOMap.get(Constant_Util.COMMENT_TEMPLATE_WORK_ORDER_CREATION).add(woRecord);
                    }
            }
        }
        WorkOrderTriggerHelper.ServiceDateChanges(triggerParam.newList, workOrderOldMap);
        //System.debug('***Inside test loop2- woHandler****');
        if((caseUpdateWOMap!= null && !caseUpdateWOMap.isEmpty()) && (caseWOMap != null && !caseWOMap.isEmpty())){
        //System.debug('***Inside test loop3- woHandler****');
            WorkOrderTriggerHelper.updateCaseDetail(caseUpdateWOMap,workOrderOldMap,caseWOMap );
            
        }
        
        if(workOrderNewMap != null && !workOrderNewMap .isEMpty() && (TriggerDispatcher.skipTriggerExecutionMap==null || TriggerDispatcher.skipTriggerExecutionMap.get(WorkOrder.sobjectType.getDescribe().getName())==null
            || !TriggerDispatcher.skipTriggerExecutionMap.get(WorkOrder.sobjectType.getDescribe().getName()))){
            CreateCaseHistory.createHistoryRecord(workOrderNewMap , workOrderOldMap);
            TriggerDispatcher.skipTriggerExecutionMap.put(WorkOrder.sobjectType.getDescribe().getName(),true);
        }
        if(acronWOlst!= null && !acronWOlst.isEmpty() && !system.isBatch() && !system.isFuture()){
            UpdateWorkOrder.updateWO(acronWOlst);
        }
        if(!commentWOMap.isEmpty()){
           WorkOrderTriggerHelper.createCaseComment(commentWOMap );
        }
    }
    /*@methodName- getCaseDetails
    *@description- Method to query the case results
    *@param- set<id> caseId
    *@return- List<case>
    */ 
    public static Map<id,case> getCaseDetails(set<id> caseIdSet){
        Map<id,Case> caseMap = new Map<Id,Case>();
        if(caseIdSet != null && !caseIdSet.isEmpty()){
            caseMap = new Map<id,case>([SELECT id,status,Supplier__c,Work_Order__c,Work_Order_Instructions__c,User_Input_Work_Order_Instructions__c,Proposed_Service_Date__c,Case_Sub_Status__c,Service_Date__c,Service_date_from_local_time__c,Availability_Confirmed__c,Source_System__c, Client__c,ContactId
                        FROM Case 
                        WHERE id in : caseIdSet
                        LIMIT 10000]);
        }
        return caseMap ;
    }

    /*@methodName- getAccountDetails
    *@description- Method to query the account results
    *@param- set<id> accountIds
    *@return- List<Account>
    */ 
    public static Map<id,Account> getAccountDetails(set<id> accountIds){
        Map<id,Account> accMap = new Map<Id,Account>();
        if(!accountIds.isEmpty()){
            accMap = new Map<id,Account>([SELECT id, ParentId,ShippingCountry
                        FROM Account 
                        WHERE id in : accountIds
                        LIMIT 10000]);
        }
        return accMap ;
    }
    
    /*@methodName- fetchDispatchEmail
    *@description- Method to query AccountContactRelation object related to Vendor Account
    *@param- set<id> accountIds
    *@return- void
    */ 
    public static void updateDispatchEmail(List<sObject> woList){
        if(Constant_UTIL.skipWOTrigger) {
            return;
        }
        Set<Id> vendorIds = new Set<Id>();
        Map<String , String> acrMap = new Map<String , String>();
        for(sObject sobjVal : woList){
            WorkOrder woRecord = (WorkOrder)sobjVal ; 
            if(woRecord.Vendor_Account_Id__c != null){
                vendorIds.add(woRecord.Vendor_Account_Id__c);
            }          
        }
        List<AccountContactRelation> acrList = [Select Id, ContactId, Contact.email, AccountId FROM  AccountContactRelation WHERE AccountId IN :vendorIds AND Roles INCLUDES ('Dispatch') order by createddate desc];
        for(AccountContactRelation acr : acrList){
            if(!acrMap.containsKey(acr.AccountId)){
                acrMap.put(acr.AccountId , acr.Contact.Email);
            }
        }
        for(sObject sobjVal : woList){
            WorkOrder woRecord = (WorkOrder)sobjVal ; 
            if(!acrMap.isEmpty() && acrMap.containsKey(woRecord.Vendor_Account_Id__c)){
                woRecord.Dispatch_Email__c = acrMap.get(woRecord.Vendor_Account_Id__c);
            }          
        }
    }   

        /*@methodName- fetchDispatchEmail
    *@description- Method to query AccountContactRelation object related to Vendor Account
    *@param- set<id> accountIds
    *@return- void
    */ 
    public static void updateDryRunDetail(List<sObject> woList , Map<Id , sObject> oldWOMap){
        for(sObject sobjVal : woList){
            WorkOrder woRecord = (WorkOrder)sobjVal; 
            if(oldWOMap == null){
                if(woRecord.Dry_Run_Cost__c != null) {
                    woRecord.Dry_Run_Cost_in_Currency__c = woRecord.Dry_Run_Cost__c;
                }
                else {
                    woRecord.Dry_Run_Cost__c = woRecord.Dry_Run_Cost_in_Currency__c;
                }
                if(woRecord.Dry_Run_Price__c != null) {
                    woRecord.Dry_Run_Price_in_Currency__c = woRecord.Dry_Run_Price__c;
                }
                else {
                    woRecord.Dry_Run_Price__c = woRecord.Dry_Run_Price_in_Currency__c;
                }
            } else {
                if(oldWOMap.containsKey(woRecord.id)){
                    WorkOrder oldWORecord = (WorkOrder) oldWOMap.get(woRecord.id);
                    if(oldWOMap.containsKey(woRecord.id) && woRecord.Dry_Run_Cost__c != oldWORecord.Dry_Run_Cost__c) {
                        woRecord.Dry_Run_Cost_in_Currency__c = woRecord.Dry_Run_Cost__c;
                    }
                    else if(oldWOMap.containsKey(woRecord.id) && woRecord.Dry_Run_Cost_in_Currency__c != oldWORecord.Dry_Run_Cost_in_Currency__c) {
                        woRecord.Dry_Run_Cost__c = woRecord.Dry_Run_Cost_in_Currency__c;
                    }
                    if(oldWOMap.containsKey(woRecord.id) && woRecord.Dry_Run_Price__c != oldWORecord.Dry_Run_Price__c) {
                        woRecord.Dry_Run_Price_in_Currency__c = woRecord.Dry_Run_Price__c;
                    }
                    else if(oldWOMap.containsKey(woRecord.id) && woRecord.Dry_Run_Price_in_Currency__c != oldWORecord.Dry_Run_Price_in_Currency__c) {
                        woRecord.Dry_Run_Price__c = woRecord.Dry_Run_Price_in_Currency__c;
                    }        
                }   
            }
       }
    }   
}