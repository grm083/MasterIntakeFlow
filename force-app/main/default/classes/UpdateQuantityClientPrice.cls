/*************************************************************
@Name: UpdateQuantityClientPrice
@Author: Accenture
@CreateDate: 18/06/2020
@Description: Update quantity, client price to Acorn
@UsedBy: SDT-12298
**************************************************************/
global with sharing class UpdateQuantityClientPrice {

    public static integer MOCK_RESPONSE_CODE;
    public static string MOCK_RESPONSE;
	/*
	* This method is Invoked from the WorkOrderLineItem Trigger 
	* @owner : Accenture
	* @param : List<WorkOrderLineItem> oldMap, Map<Id,WorkOrderLineItem> newMap
    */
    public static void updateWOLineItem(Map<Id,WorkOrderLineItem> oldMap, Map<Id,WorkOrderLineItem> newMap){
    
        set<Id> woLineItemIds = new Set<Id>();
        String jsonOldMap = JSON.serialize(oldMap);
    
        for(WorkOrderLineItem woli : newMap.values()) {
        woLineItemIds.add(woli.Id);
        }
        if(System.IsBatch() == false && System.isFuture() == false){ 
            //since future callout doesn't support list<object>, sending as set<Id>
            sendWoliToAcorn(woLineItemIds,jsonOldMap); 
        }
    }
    
    /*
	* This method is Invoked from the Work Order Process Builder and the Actions on the WorkOrder flow.
	* @owner : Accenture
	* @param : List<WorkOrderLineItem> woLineItemLst
	*/
    @future(callout=true)
    public static void sendWoliToAcorn(Set<Id> woLineItemIds, string jsonOldMap){
        Map<Id,WorkOrderLineItem> oldWOLIMap = (Map<Id, WorkOrderLineItem>) JSON.deserialize(jsonOldMap, Map<Id,WorkOrderLineItem>.class);
        String endpoint = '';
        Map<Id, WorkOrderLineItem> revertWOLIMap = new Map<Id, WorkOrderLineItem>();
        woLiWrapper woliWrap = new woLiWrapper();	
		List<woComponents> woCompLst = new List<woComponents>();
        List<Comment__c> commentLst = new List<Comment__c>();
        Integration_Request_URLs__mdt integrationReqUrl = [SELECT DeveloperName, Client_Key__c, Client_Token__c, Timeout__c, Content_Type__c,End_Point__c, Method__c FROM
                                   Integration_Request_URLs__mdt WHERE DeveloperName =: Constant_Util.UPDATE_QUANTITY_CLIENT_PRICE LIMIT 1];
        List<WorkOrderLineItem> woLineItemLst = [SELECT Id, Acorn_SBID__c, Original_Client_Price__c, New_Client_Price__c,Acorn_WOC__c,
                         Reason_Code__c, Reason_Description__c, Quantity__c, WorkOrder.CaseId, WorkOrder.case.CaseNumber, WorkOrder.Case.Tracking_Number__c,
                         WorkOrder.Acorn_WorkOrder_Number__c, WorkOrder.Vendor_ID__c, WorkOrder.Customer_Location__r.Location_Code__c
                         FROM WorkOrderLineItem WHERE Id IN: woLineItemIds];
        Http h = new Http();
        HttpRequest req = new HttpRequest();
		
        req.setMethod(integrationReqUrl.Method__c);
        req.setHeader('Content-Type',integrationReqUrl.Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',integrationReqUrl.Client_Key__c);
        req.setHeader('Authorization',integrationReqUrl.Client_Token__c);
        req.setTimeout(integrationReqUrl.Timeout__c.intValue());
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
		Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
        List<WorkOrderLineItem> woLiItemLst = new List<WorkOrderLineItem>();
		try {
			for(WorkOrderLineItem woLI : woLineItemLst) {
                WorkOrderLineItem oldWOLI = (WorkOrderLineItem) oldWOLIMap.get(woLI.id);
				if(integrationReqUrl.End_Point__c.contains('{WorkOrderNumber}')){
					endpoint = integrationReqUrl.End_Point__c.replace('{WorkOrderNumber}', string.valueOf(woLI.WorkOrder.Acorn_WorkOrder_Number__c));
				}
                req.setEndpoint(Endpoint);
				woliWrap.locationCode = woLI.WorkOrder.Customer_Location__r.Location_Code__c; 
                woliWrap.supplierCode = woLI.WorkOrder.Vendor_ID__c;
				woComponents woComp = new woComponents();
				woComp.workOrderComponentId = woLI.Acorn_WOC__c;
                woComp.cost = null;
                woComp.costOverrideReasonCode = null;
				woComp.costOverrideReasonDescription = null;
                
                //only send if updated....
                if(woLI.Quantity__c == 0  || woLI.Quantity__c == oldWOLI.Quantity__c){
                    woComp.quantity = null;    
                }else{
                    woComp.quantity = woLI.Quantity__c;
                }
                woComp.price = woLI.New_Client_Price__c;
                woComp.priceOverrideReasonCode = woLI.Reason_Code__c;
                woComp.priceOverrideReasonDescription = woLI.Reason_Description__c;
				woCompLst.add(woComp);
                
				woliWrap.components = new List<woComponents>();
				woliWrap.components.addAll(woCompLst);
                String JSONData = JSON.serialize(woliWrap);
               
                req.setBody(JSONData);
                Integer statusCode;
                string resBody;
                if(!Test.isRunningTest()){
                    httpresponse res = h.send(req);
                    statusCode = res.getStatusCode();
                    resBody = res.getBody();
                    system.debug('@@ resBody:'+ resBody);
                } else{
                    statusCode = MOCK_RESPONSE_CODE;
                    resBody = MOCK_RESPONSE;
                }
				if(statusCode != Constant_Util.STATUS_CODE) {
					revertWOLIMap.put(woLI.Id, woLI);
                    AcornResult re = (AcornResult)JSON.deserialize(resBody, AcornResult.class);
                    new Logger().addLog(Logger.ERROR, re.Problem.Errors[0].Message, '', 'getCalloutResponseContents', 'UpdateQuantityClientPrice', woLI.Id, '', 500, RESTHelper.ErrorMessage.UNHANDLED_ACORN_CALLOUT_EXCEPTION.name(),
                       endpoint, integrationReqUrl.Method__c, 'Outbound', req.getHeader('X-USERID')).saveLogs();
                } else {
					woLiItemLst.add(woLI);
                }
			}
            if(revertWOLIMap.size() > 0){
                revertWOLineItem(revertWOLIMap, oldWOLIMap);
            }
			if(woLiItemLst != null && !woLiItemLst.isEmpty()){
				insertCaseComment(woLiItemLst, recordTypeId, acornUserId);
			}
		} catch (Exception e) {
            System.debug('Exception: ' + e.getStackTraceString());
        }
	}
	public static void revertWOLineItem(Map<Id, WorkOrderLineItem> revertWOLIMap, Map<Id, WorkOrderLineItem> oldWOLIMap) {
        try {
            set<String> workOrderUpdatefields = new set<String>();
            List<WorkOrderLineItem> updatedWOLI = new List<WorkOrderLineItem>();        
            List<WorkOrderLineItem> revertedWOLIHistory = [SELECT Id, Quantity__c, Original_Client_Price__c, New_Client_Price__c, Reason_Code__c, Reason_Description__c, LastModifiedDate, 
                                    (SELECT Field, OldValue, NewValue, CreatedDate FROM Histories  ORDER BY CreatedDate DESC) FROM WorkOrderLineItem WHERE Id in:revertWOLIMap.keySet()];
            for (WorkOrderLineItem woli: revertedWOLIHistory) {
                WorkOrderLineItem revertedWOLI = (WorkOrderLineItem) revertWOLIMap.get(woli.Id);
                List<WorkOrderLineItemHistory> woliHistoryLst = new List<WorkOrderLineItemHistory>();
                if(woli.Histories != null || !woli.Histories.isEmpty()){
                    woliHistoryLst = woli.Histories ;
                } 
                if(Test.isRunningTest()){  //if TEST, create dummy WorkOrderLineItemHistory
                    list<WorkOrderLineItemHistory> ah1 = TestDataFactory.WorkOrderLineItemHistory(woli.id);
                    woliHistoryLst = ah1 ;        
                }
                for (WorkOrderLineItemHistory ch: woliHistoryLst) {
                    WorkOrderLineItem oldWOLI = (WorkOrderLineItem) oldWOLIMap.get(woLI.id);
                    if(woLI.Quantity__c != oldWOLI.Quantity__c && ch.Field == 'Quantity__c' && (workOrderUpdatefields.IsEmpty() || !workOrderUpdatefields.contains(ch.Field))){
                        revertedWOLI.Quantity__c =  Integer.valueOf(ch.OldValue);
                        workOrderUpdatefields.add(ch.Field);
                	}
                    if(woLI.New_Client_Price__c != oldWOLI.New_Client_Price__c && ch.Field == 'New_Client_Price__c' && (workOrderUpdatefields.IsEmpty() || !workOrderUpdatefields.contains(ch.Field))) {
                        revertedWOLI.New_Client_Price__c = Double.valueOf(ch.OldValue);
                        workOrderUpdatefields.add(ch.Field);
                    }
                    if(woLI.Reason_Code__c != oldWOLI.Reason_Code__c && ch.Field == 'Reason_Code__c' && (workOrderUpdatefields.IsEmpty() || !workOrderUpdatefields.contains(ch.Field))){
                        revertedWOLI.Reason_Code__c = String.valueOf(ch.OldValue);
                        workOrderUpdatefields.add(ch.Field);
                    }
                    if(woLI.Reason_Description__c != oldWOLI.Reason_Description__c && ch.Field == 'Reason_Description__c' && (workOrderUpdatefields.IsEmpty() || !workOrderUpdatefields.contains(ch.Field))){
                        revertedWOLI.Reason_Description__c = String.valueOf(ch.OldValue);
                        workOrderUpdatefields.add(ch.Field);
                    }
                }
                updatedWOLI.add(revertedWOLI);
            }
            if(updatedWOLI != null && !updatedWOLI.isEmpty())
                update updatedWOLI;
        } catch (Exception e) {
            System.debug('An error occurred while trying to revert the WOLI: ' + e.getMessage());
        }
    }
	public static void insertCaseComment(List<WorkOrderLineItem> woLILst, Id recordTypeId, Decimal acornUserId){
        List<Comment__c> commentLst = new List<Comment__c>();
		Comment__c myComment;
		for(WorkOrderLineItem woLI : woLILst){
			myComment = new Comment__c();
			myComment.Case__c = woLI.workorder.case.Id;
			myComment.RecordTypeId = recordTypeId;
			myComment.Case_Number__c = woLI.workorder.case.CaseNumber;
			myComment.Acorn_Tracking_Number__c = woLI.workorder.case.Tracking_Number__c != null ? woLI.workorder.case.Tracking_Number__c : Constant_Util.EMPTY_STRING;
			myComment.Workflow_Action__c = '';
			myComment.Acorn_SUser_ID__c = acornUserId;
			myComment.Type__c = Constant_Util.OBJECT_CASE;
			myComment.Communication_Log_Type_Name__c = 'Internal';
			myComment.Workflow_TeamUser__c = System.UserInfo.getName();
			
			string orginialPrice = woLI.Original_Client_Price__c != null ? string.valueOf(woLI.Original_Client_Price__c) : Constant_Util.EMPTY_STRING;
			string NewPrice = woLI.New_Client_Price__c != null ? woLI.New_Client_Price__c +' changed by '+system.now() : Constant_Util.EMPTY_STRING;
			string reasonDesc = woLI.Reason_Description__c != null ? woLI.Reason_Description__c : Constant_Util.EMPTY_STRING;
			
			myComment.Comment__c = 'Name of the agent: '+System.UserInfo.getName()+', Original Price: '+orginialPrice+ ', New Client Price: '
									+NewPrice+', Reason Code: '+woLI.Reason_Code__c +', Reason Description: '+reasonDesc;
			commentLst.add(myComment);
		}
		if(commentLst != null && !commentLst.isEmpty()){
			insert commentLst;
		}
	}
	
	public with sharing class woLiWrapper{
		public String locationCode {get;set;}
        public String supplierCode {get;set;}
		public List<woComponents> components {get;set;}
	}
	public with sharing class woComponents {
		public Decimal workOrderComponentId {get;set;}
        public Decimal quantity {get;set;}
		public Decimal cost {get;set;}
        public String costOverrideReasonCode {get;set;}
		public String costOverrideReasonDescription {get;set;}
		public Decimal price {get;set;}
        public String priceOverrideReasonCode {get;set;}
		public String priceOverrideReasonDescription {get;set;}
	}
    
    public class Errors {
		public String Code;
		public String Message;
	}
    
	public class Problem {
		public String Title;
		public Integer Status;
		public List<Errors> Errors;
	}
    
    Public Class AcornResult {
        public Object Data;
		public Problem Problem;
    }
}