/*************************************************************
@Name: BalePickupCaseService
@Author: Arvind Kumar
@CreateDate: 23/08/2021
@Description: Apex webservice to create Bale Pickup Case
Caller API Hub - Genesys System and CCT Team
@UsedBy: SDT-19323 Bale Pickup Service
@URL: /services/apexrest/CreateBalePickupCase/V1
**************************************************************/

@RestResource(urlMapping='/CreateBalePickupCase/V1')
global with sharing class BalePickupCaseService {
    public static final String BALE_SUBTYPE = 'Bale(s)'; // Case Subtype Assign Default value
    public static final String SALESFORCE_SYSTEM = 'Salesforce'; // Source System 'Salesforce'
    public static final String CORE_SERVICE = 'Core Customer Service'; // Default value for Team Name
    public static final String US_CS_RESOLUTION = 'CS Bale Resolution'; // Default value for Team Queue
    public static final String CANADA_TEAM_QUEUE_WMSSC = 'WMSSC Cust Svc Incomplete'; // Default value for Team Queue Canada
    public static final String UNSPECIFIED = 'Unspecified ';  // Used for Dummy Contact Name
    public static final String INVALID_DATA_ERROR = 'You have entered invalid data'; // Error for Invalid Data
    public static final String INVALID_LOCATION_ERROR = 'You have entered invalid Location Id or Code'; // Error for Invalid Data
    public static final String UNITED_STATES = 'United States'; // Used for ShippingCountry United States
    public static final String CANADA = 'Canada'; // Used for ShippingCountry CANADA)
    public static final String STATUS_NEW = 'New'; // Used for Case Status
    public static final String ACORN_TICKET_COMMENT_RT = 'Acorn Ticket Comment'; // Record Type Name
    
    /*********************************************************
* @Author: Arvind Kumar
* @Method: Post
* @Description: Create Bale Pickup Service Case
* *******************************************************/
    @HttpPost
    global static void createBalePickupCase(){
        //Initialize RestContext
        RestRequest Request = RestContext.request;
        RestResponse Response = RestContext.response;
        
        RESTHelper.createResponse cusResponse = new RESTHelper.createResponse();
        try 
        {
            //Get request body
            String jsonRequest = Request.requestBody.toString();
            RequestData reqData = new RequestData();
            reqData = parse(jsonRequest);
            if(reqData != null && (reqData.LocationId !=null || reqData.LocationCode != null  ) )
            {
                // Get the location account 
                if( reqData.LocationId !=null || reqData.LocationCode != null ){
                    List<Account> acc_loc = [select Id,ParentId,Parent.Name,ShippingCountry from Account  
                                             where ID =:reqData.LocationId OR Name =:reqData.LocationCode ];
                    
                    if(!acc_loc.isEmpty() && acc_loc.size()>0){
                        Boolean IsContactEmpty = false;
                        // If we recieves Contact Id is null from payload then will Get Dummy Contact based on the account parent name 
                        if((reqData.ContactId == null || !reqData.ContactId.startsWith('003'))  && (reqData.Origin == Constant_Util.IVR_Phone || reqData.Origin == Constant_Util.CHAT_Now) ){
                            String whereInput = UNSPECIFIED + acc_loc[0].Parent.Name; //'\'' + UNSPECIFIED +String.escapeSingleQuotes(acc_loc[0].Parent.Name.trim()) + '\'';
                            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Name =:whereInput Limit 1 ];
                            if(!conList.isEmpty() && conList.size()>0){
                                reqData.ContactId = conList[0].Id;
                            }else{
                                IsContactEmpty = true;
                            }
                        }
                        
                        // Bale Pickup Case Creation
                        Case csObj = createBaleCase(reqData, acc_loc[0]);
                        if(csObj!=null){
                            // Insert Case Record
                            insert csObj;
                            
                            List<Case> caseObj = [Select Id, CaseNumber,Reference_Number__c,
                                                  Origin,Last_Customer_Interaction_ID__c,Last_Customer_Interaction_Type__c From Case where Id =: csObj.Id ];
                            
                            // Insert Comment Record related to Case
                            createCommentRecord(caseObj[0],reqData);
                            
                            // Started - Insert Task Related to Case - SDT-21054
                            if(caseObj[0].Origin == Constant_Util.IVR_Phone || caseObj[0].Origin == Constant_Util.CHAT_Now){
                                createInboundCustTask(caseObj[0]);
                            }
                            // End 
                            
                            // Making the create case response
                            ResponseData resData = new ResponseData();
                            resData.ReferenceNumber = caseObj[0].Reference_Number__c; 
                            resData.CaseNumber = caseObj[0].CaseNumber;
                            resData.Id = caseObj[0].Id;
                            
                            cusResponse.Data = resData;
                            cusResponse = RESTHelper.createAcornCreatedResponse(cusResponse);
                            Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));	
                            Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);  
                            
                            // updating case status 'Open' to calculating the SLA Date
                            if( !IsContactEmpty){
                                updateCase(caseObj[0].Id);
                            } 
                        }
                    }else{
                        Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
                        cusResponse = RESTHelper.createAcornErrorResponse(cusResponse, RESTHelper.HTTP_INVALID_MISSING_PARAM, INVALID_LOCATION_ERROR);
                        Response.statusCode = cusResponse.statusCode;
                        Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));
                    }
                }else{
                    Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
                    cusResponse = RESTHelper.createAcornErrorResponse(cusResponse, RESTHelper.HTTP_INVALID_MISSING_PARAM, INVALID_LOCATION_ERROR);
                    Response.statusCode = cusResponse.statusCode;
                    Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));
                }
            }   
            else 
            {
                Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
                cusResponse = RESTHelper.createAcornErrorResponse(cusResponse, RESTHelper.HTTP_INVALID_MISSING_PARAM, INVALID_DATA_ERROR);
                Response.statusCode = cusResponse.statusCode;
                Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));
            }
        }
        catch(Exception ex) {
            system.debug('Exception :: '+ex);
            // Error Log
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            cusResponse = RESTHelper.createAcornErrorResponse(cusResponse, RESTHelper.HTTP_EXCEPTION , ex.getMessage());
            Response.statusCode = cusResponse.statusCode;
            Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));
        }
    }
    
    // Create Bale Pickup Case
    public static case createBaleCase(RequestData reqData, Account acc_loc) {
        
        //Get the Case Pickup Record Type 
        Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByName();
        Id casePickupRecTypeId = caseRecordTypes.get(Constant_Util.Pickup_Case_Rec_Type).getRecordTypeId();
        
        // Assign Case Fields 
        Case csObj = new Case();
        csObj.Status = STATUS_NEW;                          // New status
        csObj.Acorn_SUser_ID__c = reqData.AcornSUserId;     // Acorn user id
        csObj.Case_Type__c = Constant_Util.PICKUP_CSTYPE;   // Pickup
        csObj.Case_Sub_Type__c = BALE_SUBTYPE;              // Bale(s);
        csObj.RecordTypeId = casePickupRecTypeId;           // Pickup Record Id
        csObj.Source_System__c = SALESFORCE_SYSTEM;         // Salesforce
        csObj.Location__c = acc_loc.Id;                    // Account location ID
        csObj.Client__c =  acc_loc.ParentId;                // Account parent ID
        csObj.Origin = reqData.Origin;                      // Origin from Request
        csObj.Last_Customer_Interaction_ID__c = reqData.connectionId;  // connection Id
        csObj.Last_Customer_Interaction_Type__c = reqData.LastCustomerInteractionType; // Interaction Type
        csObj.Case_Comments__c = reqData.Comments;          // Comments from request
        csObj.Quantity_Override__c = reqData.quantity;      // Quantity from request
        csObj.Team_Name__c = CORE_SERVICE;                  // default Value - Core Customer Service
        if(acc_loc.ShippingCountry == UNITED_STATES){
            csObj.Team_Queue__c = US_CS_RESOLUTION;            //(If country on Account is US ) else (If country on Account is Canada )
        }else if(acc_loc.ShippingCountry == CANADA){
            csObj.Team_Queue__c = CANADA_TEAM_QUEUE_WMSSC;                     //(If country on Account is US ) else (If country on Account is Canada )
        }
        csObj.PurchaseOrder_Number__c = reqData.PO;         // Customer PO #
        //system.debug('ContactId : ' + reqData.ContactId);
        csObj.ContactId = String.isNotBlank(reqData.ContactId) ? reqData.ContactId : null;
        csObj.Reference_Number__c = reqData.ReferenceNumber != null ? +reqData.ReferenceNumber : null ;
        if(reqData.ServiceDate != null ){
            date serviceDate = reqData.ServiceDate;         // service date from request
            csObj.Service_Date__c = serviceDate;            // used this field to calculate SLA Date
            // csObj.SLA_Service_Date_Time__c = serviceDate;   // used this field to calculate SLA Date
        }
        
        // Return Bale Pickup Case Record for creation
        return csObj;
    }
    
    // Updating case status 'open'
    public static void updateCase(String caseId) {
        case caseObj = new Case(Id=caseId, Status = 'Open');
// Modified for SDT-33437 Start
        try {
            if(caseObj != null){
        update caseObj;
    }
} catch (DmlException e) {
            System.debug('A DML exception has occurred: ' + e.getMessage());
        }
        // Modified for SDT-33437 End
    }
    
    // Creating Comments Record
    public static void createCommentRecord(Case caseObj,RequestData reqData) {
        Id acornRecordTypeId =Schema.SObjectType.Comment__c.getRecordTypeInfosByName().get(ACORN_TICKET_COMMENT_RT).getRecordTypeId();
        Comment__c insertComment = new Comment__c(Case__c =caseObj.Id,
                                                  RecordTypeId =acornRecordTypeId,
                                                  Case_Number__c =caseObj.CaseNumber, 
                                                  Comment__c =reqData.Comments);
// Modified for SDT-33437 Start
        try {
            if(insertComment != null){
        insert insertComment;
    }
} catch (DmlException e) {
            System.debug('A DML exception has occurred: ' + e.getMessage());
        }
        // Modified for SDT-33437 End
    }
    
    // Started - Insert Task Related to Case - SDT-21054
    public static void createInboundCustTask(Case caseObj){
        Task newtask = new Task();
        newtask.Status = Constant_Util.COMPLETED;
        newtask.Subject = Constant_Util.INBOUND_CUSTOMER_INTERACTION;
        newtask.WhatId = caseObj.Id;
        newtask.OwnerId = UserInfo.getUserId();
        newtask.Interaction_ID__c = caseObj.Last_Customer_Interaction_Id__c;
        newtask.Description__c = caseObj.Last_Customer_Interaction_Id__c;
        newtask.Description = 'MediaType: '+caseObj.Last_Customer_Interaction_Type__c + Constant_Util.NEW_LINE + 'Genesys ID: '+caseObj.Last_Customer_Interaction_ID__c;
        
// Modified for SDT-33437 Start
        try {
            if(newtask != null){
        insert newtask;
    }
} catch (DmlException e) {
            System.debug('A DML exception has occurred: ' + e.getMessage());
        }
        // Modified for SDT-33437 End
    }
    // Ended
    
    // Request wrapper for payload
    public class RequestData {
        public String LocationId;
        public String LocationCode; 
        public Date ServiceDate; //"2018-08-21"
        public String Origin;
        public String ReferenceNumber;
        public String ContactId;
        public String PO;
        public String CreatedById; 
        public Double AcornSUserId;
        public String connectionId; //'GEN10000' 
        public String LastCustomerInteractionType; /// IVR'
        public String Comments;
        public double Quantity;       
    }
    
    // Parsing the Request in wrapper
    public static RequestData parse(String json) {
        return (RequestData) System.JSON.deserialize(json, BalePickupCaseService.RequestData.class);
    }
    
    // Response wrapper for payload
    public class ResponseData {
        public string Id;
        public string ReferenceNumber;
        public string CaseNumber;
    }
    
}