/*************************************************************
@Name: WorkOrderWebservices
@Author: Accenture
@CreateDate: 2/25/2019
@Description: Apex webservice to get work order information
@UsedBy: SDT-3248
/services/apexrest/WorkOrder/V1
**************************************************************/
@RestResource(urlMapping='/WorkOrder/V1')
global with sharing class WorkOrderWebservices {
    
@HttpPost
/**
* @description method to get Work Order Details
*/
    global static void getWorkOrderDetails(){
        
        //Initialize RestContext
        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        
        //variable declaration
        WorkOrderResponse woResponseResp = new WorkOrderResponse();
        List<ErrorsWrapper> errorList = new List<ErrorsWrapper>();  
        List<WorkOrderWrapper> workOrderWrapperList = new List<WorkOrderWrapper>();
        
        try {
            //Get request body
            String jsonRequest = inboundRequest.requestBody.toString();
            
            //Convert request body to data structure, deserialize JSON
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            String woIdReq = string.valueOf(requestDataMap.get(Constant_Util.WORK_ORDER_ID));
            
            //use delimiter and convert to list
            List<String> woIdList = woIdReq.split(Constant_Util.COMMA);
            
            if(!String.isBlank(woIdReq)){
                //get work order details:
                Map<Id, WorkOrder> workOrderMap = 
                    new Map<Id, WorkOrder>([SELECT Id, CreatedById, CreatedBy.Acorn_SUser_Id__c, Instructions__c, WorkOrderNumber, 
                                            Service_Date__c, SLA_Service_Date_Time__c, AccountId, Account.Name,
                                            Account.AccountNumber, Account.Location_Code__c,
                                            Customer_Location__r.Location_Code__c,
                                            ContactId, Contact.FirstName, Contact.LastName, Contact.Email, 
                                            Contact.Phone, Is_Override_Duplicate__c,
                                            CaseId, Case.CreatedBy.Acorn_SUser_Id__c, Case.CaseNumber, Case.Description, 
                                            Case.Origin, Case.Case_Type__c, Case.Case_Sub_Type__c, Case.Contact_Title__c, 
                                            Case.Case_Reason__c, Case.PSI__c, Case.Reference_Number__c,   
                                            Case.PurchaseOrder_Number__c, Case.Work_Order_Instructions__c, Case.Tracking_Number__c
                                            FROM WorkOrder WHERE Id IN:woIdList LIMIT 49999]);
                
                List<WorkOrderLineItem> woliList = null;
                List<WorkOrderLineItem> tempWOLIList = null;
                WorkOrderWrapper workOrderWrapper = null;       

                List<WorkOrderLineItem> woLineItemList = new List<WorkOrderLineItem>();

                woLineItemList = [SELECT Id, LineItemNumber, Acorn_SCOD__c, Quantity__c, Acorn_SBID__c, WorkOrderId, New_Client_Price__c,
                                    AssetId, Asset.Quantity__c, Reason_Code__c, Reason_Description__c, Original_Client_Price__c 
                                    FROM WorkOrderLineItem 
                                    WHERE WorkOrderId IN:workOrderMap.keySet() LIMIT 49999];
                
                if(workOrderMap != null){                    
                    for(Id woId : workOrderMap.keySet()){
                        //get the work order line items
                        tempWOLIList = new List<WorkOrderLineItem>();
                        for(WorkOrderLineItem woli : woLineItemList){
                            if(woli.WorkOrderId == woId )	{
								tempWOLIList.add(woli);    
							}
                        }
                        workOrderWrapper = new WorkOrderWrapper(workOrderMap.get(woId), tempWOLIList);
                        workOrderWrapperList.add(workOrderWrapper);
                    }  
                    woResponseResp.RecordCount = workOrderWrapperList.size(); 
                }    
            }   
            //set the response object
            woResponseResp.WorkOrder = workOrderWrapperList;
            
            //Populate response values
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(woResponseResp));
            outboundResponse.statusCode = 200;
            
        }catch (Exception e) {
            ErrorsWrapper errorDetails = new ErrorsWrapper(e.getTypeName(), e.getMessage()); 
            errorList.add(errorDetails);
            woResponseResp.Problem =  new ErrorMessageWrapper(Constant_Util.EXCEPTION_OCCURRED, 
                                                              Constant_Util.KEYWORD_EXCEPTION, errorList);
            
            //outboundResponse.responseBody = Blob.valueOf(e.getMessage());
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(woResponseResp));     
            outboundResponse.statusCode = 400;            
        }
    }
    
    /**
* @description class for WorkOrderResponse
*/
    global with sharing class WorkOrderResponse{
        public Integer RecordCount {get;set;}
        public List<WorkOrderWrapper> WorkOrder {get;set;}
        public ErrorMessageWrapper Problem {get;set;}
        
        /**
* @description Constructor
*/
        public WorkOrderResponse(){            
            this.RecordCount = 0;
        }
    }
    
    /**
* @description class for WorkOrderResponse
*/
    global with sharing class WorkOrderWrapper{
        public WorkOrder WorkOrderHeader {get;set;}
        public List<WorkOrderLineItem> WorkOrderDetails {get;set;}
        
        /**
* @description Constructor
*/
        public WorkOrderWrapper(WorkOrder wo, List<WorkOrderLineItem> woli){            
            this.WorkOrderHeader = wo;
            this.WorkOrderDetails = woli;
        }
    }    
    /**
* @description class for ErrorMessageWrapper
*/
    global with sharing class ErrorMessageWrapper{
        public String Title {get;set;}
        public String Status {get;set;}
        public List<ErrorsWrapper> Errors {get;set;}
        
        /**
* @description Constructor for ErrorMessageWrapper
*/        
        public ErrorMessageWrapper(String title, String status, List<ErrorsWrapper> errors){
            this.Title = title;
            this.Status = status;
            this.Errors = errors;
        }
    }
    
    /**
* @description class for ErrorsWrapper
*/
    global with sharing class ErrorsWrapper{
        public String Code {get;set;}
        public String Message {get;set;}
        
        /**
* @description Constructor for ErrorsWrapper
*/
        public ErrorsWrapper(String code, String message){
            this.Code = code;
            this.Message = message;
        }
    }
  
    /**
	* @description method to Update Work Order and Case Record
	*/
    @HttpPut
    global static list<WorkOrderWebservices.ResponseWrapper> UpdateRecords(String SFDCCaseId, Integer AcornIssueId,
                                              String AcornTrackingNumber, String SFDCWorkOrderId,
                                              Integer AcornWorkOrderId, String AcornWorkOrderNumber, 
                                              List<String> ErrorMessage, String AcornPurchaseOrderNumber,
                                              Boolean IsPurchaseOrderIssued, Boolean IsQuantityUpdateFailed,
                                              Boolean IsPriceUpdateFailed, Boolean IsCostUpdateFailed,
                                              List<WorkOrderLineItem> WorkOrderLineItems){                                              
        
        List<WorkOrderWebservices.ResponseWrapper> resultlist = new List<WorkOrderWebservices.ResponseWrapper>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
		Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
        List<WorkOrderLineItem> woLineItemLst = new List<WorkOrderLineItem>();   
                                                  
        if(SFDCCaseId != null){
            resultlist = updatecase(SFDCCaseId, AcornTrackingNumber, AcornIssueId);  
        }

        if(SFDCWorkOrderId != null){
            system.debug('SFDCWorkOrderId != null');
            resultlist = updateworkOrder(SFDCWorkOrderId, AcornWorkOrderNumber, AcornWorkOrderId,AcornPurchaseOrderNumber,Constant_Util.STATUS_NEW); 
        }

        if(SFDCWorkOrderId != null && WorkOrderLineItems !=null ){
            system.debug('SFDCWorkOrderId != null && WorkOrderLineItems !=null');
            resultlist = updateWorkOrderLineItem(SFDCWorkOrderId, AcornWorkOrderNumber, AcornWorkOrderId,AcornPurchaseOrderNumber,Constant_Util.STATUS_NEW,WorkOrderLineItems); 
        }
		if(IsPriceUpdateFailed != null && IsPriceUpdateFailed){
			resultlist = createtaskforerrorMsg(SFDCCaseId, ErrorMessage, Constant_Util.ACORN_TASK_SUBJECT);
        } 
        if(IsPriceUpdateFailed != null && !IsPriceUpdateFailed)
        {
            if(SFDCWorkOrderId != null)
                {
                    woLineItemLst = [SELECT Id, Acorn_SBID__c, Original_Client_Price__c, New_Client_Price__c,Acorn_WOC__c,
                        Reason_Code__c, Reason_Description__c, Quantity__c, WorkOrder.CaseId, WorkOrder.case.CaseNumber, WorkOrder.Case.Tracking_Number__c,
                        WorkOrder.Acorn_WorkOrder_Number__c, WorkOrder.Vendor_ID__c, WorkOrder.Customer_Location__r.Location_Code__c
                        FROM WorkOrderLineItem WHERE WorkOrderId =: SFDCWorkOrderId];
                }
            if(woLineItemLst != null && !woLineItemLst.isEmpty())
            {
                UpdateQuantityClientPrice.insertCaseComment(woLineItemLst, recordTypeId, acornUserId);
            }
        }
        if(IsPurchaseOrderIssued !=null &&  IsQuantityUpdateFailed != null){
            if(!IsPurchaseOrderIssued && IsQuantityUpdateFailed && AcornWorkOrderNumber !=NULL ){
			    resultlist = updateworkOrder(SFDCWorkOrderId, AcornWorkOrderNumber, AcornWorkOrderId,AcornPurchaseOrderNumber,Constant_Util.WO_STATUS); 
			    system.debug('IsPurchaseOrderIssued != null');
                resultlist = createtaskforerrorMsg(SFDCCaseId, ErrorMessage, Constant_Util.ACORN_TASK_SUBJECT);
		    } 
        }                                          
		
       	if(ErrorMessage.size() > 0 && ErrorMessage[0] != null ){
       	    resultlist =  createtaskforerrorMsg(SFDCCaseId, ErrorMessage, 'Error Message');
        }
 		System.debug('passed error check...');
		return resultlist;
    }
    
    /**
	* @description method to Update Case Records
	*/
    public static list<ResponseWrapper> updatecase(string SFDCCaseId, string AcornTrackingNumber,
                                                   Integer AcornIssueId){
        //variable declaration
        list<case> caselst = new list<case>();
        string jsonstring;
        List<ResponseWrapper> responselist = null;
        list<ResponseWrapper> responseWrapperlist = new list<ResponseWrapper>();
        Case caserecord = new Case();
        try{
            caserecord = [select id, Acorn_Issue_Id__c, Tracking_Number__c from case where Id = :SFDCCaseId];
        }
        catch(Exception e){
            
        }
        
        if(caserecord != null){
            caserecord.Acorn_Issue_Id__c = AcornIssueId;
            caserecord.Tracking_Number__c = AcornTrackingNumber;
            caserecord.Email_Tracking_Number__c = AcornTrackingNumber;
            caselst.add(caserecord);
        }
        if(caselst.size() > 0){
          	Database.saveResult[] updateResult = database.update(caselst, false);
            for(Database.saveResult sr  : updateResult){
                if (sr.isSuccess()) {
                    responseWrapperlist.add(new ResponseWrapper(sr.isSuccess(), null));
                    jsonstring = JSON.serialize(responseWrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                }else{
                    responseWrapperlist.add(new ResponseWrapper(false, String.valueOf(sr.getErrors())));
                    jsonstring = JSON.serialize(responseWrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                }
            }
        }
        return responselist;
    }
    
    /**
	* @description method to Update WorkOrder Records
	*/
    global static list<ResponseWrapper> updateworkOrder(string SFDCWorkOrderId, string AcornWorkOrderNumber,
                                                        Integer acornworkorderId, string AcornPurchaseOrderNumber, string WOStatus){
                                                            System.debug('*** Id' + SFDCWorkOrderId);
        list<WorkOrder> workorderlist = new list<WorkOrder>();
        string jsonstring;
        List<ResponseWrapper> responselist = null;
        list<ResponseWrapper> responsewrapperlist = new list<ResponseWrapper>();
        WorkOrder workOrderrecord = new WorkOrder();
        try{
            workOrderrecord = [select id, Acorn_WorkOrder_Id__c, Acorn_WorkOrder_Number__c from WorkOrder
                               where Id = :SFDCWorkOrderId];
        }
        catch(Exception e){
            
        }
        if(workOrderrecord != null){
            workOrderrecord.Acorn_WorkOrder_Id__c = acornworkorderId;
            workOrderrecord.Acorn_WorkOrder_Number__c = AcornWorkOrderNumber;
			workOrderrecord.Acorn_Purchase_Order_Number__c = AcornPurchaseOrderNumber;
			workOrderrecord.Status = WOStatus;
            workorderlist.add(workOrderrecord);
        }
        if(workorderlist.size() > 0){
            Database.saveResult[] updateResult = database.update(workorderlist, false);
            for(Database.saveResult sr  : updateResult){
                if (sr.isSuccess()) {
                    responsewrapperlist.add(new ResponseWrapper(sr.isSuccess(), null));
                    jsonstring = JSON.serialize(responsewrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                }else{
                    responsewrapperlist.add(new ResponseWrapper(false, String.valueOf(sr.getErrors())));
                    jsonstring = JSON.serialize(responsewrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                } 
            } 
        }
        return responselist;
    }
    
    /**
	* @description method to Update WorkOrder Line Item Records
	*/
    global static list<ResponseWrapper> updateWorkOrderLineItem(string SFDCWorkOrderId, string AcornWorkOrderNumber,
                                                        Integer acornworkorderId, string AcornPurchaseOrderNumber, 
                                                        string WOStatus,List<WorkOrderLineItem> WorkOrderLineItems ){

        list<WorkOrderLineItem> workOrderLineItemlist = new list<WorkOrderLineItem>();
        list<WorkOrderLineItem> workOrderLineItemUpdatelist = new list<WorkOrderLineItem>();
        string jsonstring;
        List<ResponseWrapper> responselist = null;
        list<ResponseWrapper> responsewrapperlist = new list<ResponseWrapper>();
        Map<Id,WorkOrderLineItem> woLineItemRecordsMap = new Map<Id,WorkOrderLineItem>();
        
        workOrderLineItemlist = [SELECT Id, Acorn_SBID__c 
                                 FROM WorkOrderLineItem 
                                 WHERE WorkOrderId  =: SFDCWorkOrderId];

        for(WorkOrderLineItem woLineData : workOrderLineItemlist){
            woLineItemRecordsMap.put(woLineData.Id,woLineData);
        }

        if(woLineItemRecordsMap.size() > 0 ){
            for(WorkOrderLineItem woLineItemData:WorkOrderLineItems){
                if(woLineItemRecordsMap.containskey(woLineItemData.id) && woLineItemData.Acorn_WOC__c != null){
                    WorkOrderLineItem woItem =  woLineItemRecordsMap.get(woLineItemData.id);
                    woItem.Acorn_WOC__c = woLineItemData.Acorn_WOC__c;
                    workOrderLineItemUpdatelist.add(woItem);                    
                }
            }
        }

        if(workOrderLineItemUpdatelist.size() > 0){
          	Database.saveResult[] updateResult = database.update(workOrderLineItemUpdatelist, false);
            for(Database.saveResult sr  : updateResult){
                if (sr.isSuccess()) {
                    responsewrapperlist.add(new ResponseWrapper(sr.isSuccess(), null));
                    jsonstring = JSON.serialize(responsewrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                }else{
                    responsewrapperlist.add(new ResponseWrapper(false, String.valueOf(sr.getErrors())));
                    jsonstring = JSON.serialize(responsewrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                }
            }
        }
        return responselist;
    }

    /**
	* @description method to Create Task for ErrorMessage 
	*/
    
    public static list<ResponseWrapper> createtaskforerrorMsg(string SFDCCaseId, List<string> ErrorMessage, String taskSubject){
        System.debug(ErrorMessage);
        list<task> tasklist = new list<task>();
        list<case> caselst = new list<case>();
        Case caserecord = new Case();
        List<ResponseWrapper> responselist = null;
        list<ResponseWrapper> responsewrapperlist = new list<ResponseWrapper>();
        string jsonstring;
        string smessage;
        try{
          caserecord = [select id, Case_Sub_Status__c, Status from case where Id = :SFDCCaseId];
        }    
        catch(Exception e){
            responsewrapperlist.add(new ResponseWrapper(false, e.getMessage()));
            jsonstring = JSON.serialize(responsewrapperlist);
            responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class); 
        }   
        if(caserecord.id != null){
            if(ErrorMessage != NULL){
               smessage = string.valueOf(ErrorMessage).replace('(', '');
               smessage = smessage.replace(')', ''); 
            }
			id Recrdtypeid = [select Id,DeveloperName from RecordType where SobjectType ='task' 
                              and DeveloperName = 'Integration_Errors_Task'].id;
			Generic_Values__mdt user = [select id, Label, DeveloperName, Id__c from Generic_Values__mdt 
                                        where DeveloperName = 'Salesforce_Support_Team'];
			Task tsk = new Task(Subject=taskSubject, Status='Open', Priority='Normal', WhatID = SFDCCaseId, 
                                ownerid = user.id__c, Description__c = smessage, 
                                Recordtypeid = Recrdtypeid, ActivityDate = system.Today());
            System.debug('creating task');
			tasklist.add(tsk);
			if(tasklist.size() > 0){
				Database.saveResult[] insertResult = Database.insert(tasklist, false);
				for(Database.saveResult sr  : insertResult){
					if (sr.isSuccess()) {
						responsewrapperlist.add(new ResponseWrapper(sr.isSuccess(), null));
						jsonstring = JSON.serialize(responsewrapperlist);
						responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
					}else{
						responsewrapperlist.add(new ResponseWrapper(false, String.valueOf(sr.getErrors())));
						jsonstring = JSON.serialize(responsewrapperlist);
						responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
					}
				}
			}
            caserecord.Case_Sub_Status__c = 'Integration Error';
            caserecord.Status = 'Open';
			caselst.add(caserecord);
			if(caselst.size() > 0){
				database.update(caselst, false);
			}
        }
		
        return responselist;
    }
    
/* @description class for ResponseWrapper
*/
    global with sharing class ResponseWrapper{
        public Boolean IsSuccess {get;set;}
        public string ErrorMessage {get;set;}
        
        /**
* @description Constructor for ResponseWrapper
*/
        public ResponseWrapper(Boolean IsSuccess, string ErrorMessage){
            this.IsSuccess = IsSuccess;
            this.ErrorMessage = ErrorMessage;
        }
    }
	
}