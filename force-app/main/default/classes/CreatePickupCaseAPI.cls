/*************************************************************
@Name: CreatePickupCaseAPI
@Author: Accenture
@CreateDate: 07/11/2019
@Description: Apex webservice to create Case
@UsedBy: SDT-
/services/apexrest/CreatePickupCase/V1/
**************************************************************/
@RestResource(urlMapping='/CreatePickupCase/V1/*')
global with sharing class CreatePickupCaseAPI 
{

    @HttpPost
    //Create Case Operation 
    global static void createPickupCase()
    {
        //Initialize RestContext
        RestRequest Request = RestContext.request;
        RestResponse Response = RestContext.response;

        RESTHelper.createResponse cusResponse = new RESTHelper.createResponse();
        try 
        {
            case c = new case();
            //Get request body
            String jsonRequest = Request.requestBody.toString();
            //System.debug('jsonReq '+jsonRequest);
            Results rsltData = new Results();
            rsltData = parse(jsonRequest);
            if(rsltData != null && (rsltData.LocationId !=null || rsltData.LocationCode != null  ) && (rsltData.AssetId != null || rsltData.AcornSBID != null) )
            {
                //System.debug('rsltData '+rsltData);
                String Location_Id;
                String Asset_Id;
                Account acc_loc;
                Account acc_parent;
                
                //Get the Case Pickup Record Type 
                Map<String, Schema.RecordTypeInfo> caseRecordTypes = Schema.SObjectType.Case.getRecordTypeInfosByName();
                Id casePickupRecTypeId = caseRecordTypes.get(Constant_Util.Pickup_Case_Rec_Type).getRecordTypeId();
                //Get the Asset Service Header Record Type 
                Map<String, Schema.RecordTypeInfo> assetRecordTypes = Schema.SObjectType.Asset.getRecordTypeInfosByName();
                Id assetServiceHeaderRecTypeId = assetRecordTypes.get(Constant_Util.Service_Header_Rec_Type).getRecordTypeId();

                // Get the location account 
                if( rsltData.LocationCode != null ){
                    acc_loc = [select Id,ParentId,Common_Name__c from Account  where Name =: rsltData.LocationCode ];
                    acc_parent = [select Id,Name from Account  where Id =: acc_loc.ParentId ];
                    Location_Id = acc_loc.Id;
                }
                
                if(rsltData.LocationId != null && rsltData.LocationCode == null){
                    acc_loc = [select Id,ParentId,Common_Name__c from Account  where Id =: rsltData.LocationId];
                    acc_parent = [select Id,Name from Account  where Id =: acc_loc.ParentId ];
                    Location_Id = acc_loc.Id;
                }
                
                // Get Asset Id
                if(rsltData.AssetId == null && rsltData.AcornSBID != null){
                    Asset asset1 = [select Id,Acorn_SID__c from Asset where Location__c  =: Location_Id AND Acorn_SBID__c =:  rsltData.AcornSBID];
                    Asset asset2= [select Id from Asset where Location__c  =: Location_Id AND Acorn_SID__c =:  asset1.Acorn_SID__c AND RecordTypeId =: assetServiceHeaderRecTypeId  ];
                    Asset_Id = asset2.Id;
                }   
                else {
                    Asset_Id = rsltData.AssetId;
                }
                //Get User Id
                if(rsltData.AcornSUserId != null && rsltData.CreatedById == null ){
                    User user = [select Id from user where Acorn_SUser_ID__c =: rsltData.AcornSUserId];
                    rsltData.CreatedById = user.Id;
                }
                // Get Dummy Contact 
                if((rsltData.ContactId == null || rsltData.ContactId.length()==0 || !rsltData.ContactId.startsWith('003'))  && (rsltData.Origin == Constant_Util.IVR_Phone || rsltData.Origin == Constant_Util.CHAT_Now) ){
                    String whereInput = '\'' + 'Unspecified '+String.escapeSingleQuotes(acc_parent.Name.trim()) + '\'';
                    contact con = Database.query('SELECT Id,Name FROM Contact  WHERE Name =  '+whereInput +'limit 1');
                    rsltData.ContactId = con.Id;
                }
                // //create Contact 
                // else if (rsltData.ContactId == null)
                // {
                //     Contact contact = new Contact();
                //     contact.firstname = '';
                //     contact.lastname = '';
                //     contact.phone = '';
                //     contact. // setup the relationship
                // }
                
                // Assign Case Fields 
                c.Status = 'New';
                c.Case_Type__c = Constant_Util.PICKUP_CSTYPE;
                if(rsltData.CaseSubType != null){
                    c.Case_Sub_Type__c = rsltData.CaseSubType;
                }
                c.RecordTypeId = casePickupRecTypeId;
                c.AssetID = Asset_Id; 
                c.Location__c = Location_Id;
                c.Client__c =  acc_loc.ParentId;
                c.Origin = rsltData.Origin;
                c.Last_Customer_Interaction_ID__c = rsltData.connectionId;
                c.Last_Customer_Interaction_Type__c = rsltData.LastCustomerInteractionType;
                if(rsltData.PO != null){
                    c.PurchaseOrder_Number__c = rsltData.PO; // Customer PO #
                }
                else 
                {
                    // override logic 
                    c.Override_PO_Create_Task__c = true;
                }
                if(rsltData.PSI != null){
                    c.PSI__c = rsltData.PSI;
                }
                else{
                    // override logic 
                    c.PSI_Override_Reason__c = 'Other Customer Request';
                    c.PSI_Comments__c = rsltData.Origin;
                }
                if(rsltData.Profile_Number != null)
                {
                    c.Profile_Number__c = rsltData.Profile_Number;
                }
                else{
                    c.Override_Profile_Number_Task__c = true;
                }
                c.ContactId = String.isNotBlank(rsltData.ContactId) ? rsltData.ContactId : null;
                c.User_Input_Work_Order_Instructions__c = rsltData.WorkOrderInstructions;
                
                if(rsltData.ServiceDate != null ){
                    date serviceDate = rsltData.ServiceDate; //date.valueOf(rsltData.ServiceDate);
                    c.Service_Date__c = serviceDate;
                }
                c.Reference_Number__c = rsltData.ReferenceNumber != null ? +rsltData.ReferenceNumber : null ;
                // Modified for SDT-33451 Start
                if(c != null){
                insert c;
}                
				// Modified for SDT-33451 End
                //system.debug('c '+c);

                Case c2 = [select Id , Reference_Number__c,CaseNumber,Last_Customer_Interaction_Type__c,Last_Customer_Interaction_ID__c from case where id =: c.Id];
                //System.debug('c2 '+ c2);
                Data data = new Data();
                    data.ReferenceNumber = c2.Reference_Number__c; 
                    data.CaseNumber = c2.CaseNumber;
                    data.Id = c2.Id;
                
                //cusResponse.Data = c2;
                cusResponse.Data = data;
                cusResponse = RESTHelper.createAcornCreatedResponse(cusResponse);
                Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));	
                Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);  
               // if(c.Origin == Constant_Util.IVR_Phone ){
                    //createIVRTask(c2.id,c2.Last_Customer_Interaction_Type__c,c2.Last_Customer_Interaction_ID__c);
                    createIVRTask(c2.id,c2.Last_Customer_Interaction_ID__c,c2.Last_Customer_Interaction_Type__c); //sdt-32173
                  // createIVRTask(c);
               // }
                // Dup Check
                caseDupCheck(c.id);
                // Update the Case to initiate WorkOrder
                updateCase(c.id);//,  rsltData.CaseSubType);
            
            }   
            else 
            {
                Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
                cusResponse = RESTHelper.createAcornErrorResponse(cusResponse, RESTHelper.HTTP_INVALID_MISSING_PARAM, 'You have entered invalid data');
                Response.statusCode = cusResponse.statusCode;
                Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));
            }
        }
         catch(Exception e) {
             system.debug('EEEEEEE '+e);
            Response.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            cusResponse = RESTHelper.createAcornErrorResponse(cusResponse, RESTHelper.HTTP_EXCEPTION , e.getMessage());
			Response.statusCode = cusResponse.statusCode;
            Response.responseBody = Blob.valueOf(JSON.serialize(cusResponse, true));
        }
    }
    /*
    public static void createIVRTask(Case caseRecord){
        System.enqueueJob(new IVRTaskQueueable(caseRecord));
    } */
    
    @future
    public static void createIVRTask(String caseId, String custInteractionId, String custInteractionType){
        Task t = new Task();
        t.Status = Constant_Util.COMPLETED;
       // t.Subject ='IVR Self-Service Pickup';
        t.Subject = Constant_Util.SELF_Service;
        t.WhatId = caseId;
        t.OwnerId = UserInfo.getUserId();
        t.Interaction_ID__c = custInteractionId; //c.Last_Customer_Interaction_Id__c;
        t.Description__c = custInteractionId; //c.Last_Customer_Interaction_Id__c;
        t.Description = 'MediaType: '+custInteractionType + Constant_Util.NEW_LINE + 'Genesys ID: '+custInteractionId;
// Modified for SDT-33451 Start
        try {
            if(t != null){
        insert t;
        }            
        } catch (DmlException e) {
            //System.debug('A DML exception has occurred: ' + e.getMessage());
            STPExceptionUtil.setStepByStepExceptionObj('updateBRonCase', 'Case Screen',e.getMessage());
        }
        // Modified for SDT-33451 End
        //System.debug('Task inserted: ' + t);
    }
    
    //@future()
    public static void caseDupCheck(String Id){//,string subType){
         List<WorkOrder> woDupList = new List<WorkOrder>();
         woDupList = DuplicateCheckOnCaseController.checkForDuplicate(Id);
         if(!woDupList.isEmpty()){
            string caseComments = 'IVR  Self-Service';
            DuplicateCheckOnCaseController.updateCaseWithComments(Id,true, caseComments,woDupList);
         }
    }
    
    @future()
    public static void updateCase(String Id){//,string subType){
        case c = [select id,status,Case_Sub_Type__c from case where id =:Id];
            c.status = Constant_Util.PENDING;
            //if(subType != null)
              //  c.Case_Sub_Type__c = subType;

        // Modified for SDT-33451 Start
        try {
            if(c != null){
        update c;
}            
        } catch (DmlException e) {
            //System.debug('A DML exception has occurred: ' + e.getMessage());
            STPExceptionUtil.setStepByStepExceptionObj('updateBRonCase', 'Case Screen',e.getMessage());
        }
        // Modified for SDT-33451 End
    }

	public class  Results {
        public String LocationId;
        public String LocationCode; 
        public String AssetId;
        public double AcornSBID;
        public String CaseType;
        public String CaseSubType;
        public String CaseReason; //Case_Reason__c
        public Date ServiceDate; //"2018-08-21"
        public String Origin;
        public String ReferenceNumber;
        public String ContactId;
        public Double PSI;
        public String Profile_Number;
        public String PO;
        public String CreatedById; 
        public Double AcornSUserId;
        public String connectionId; //'GEN10000' 
        public String LastCustomerInteractionType; /// IVR'
        public String WorkOrderInstructions; //Work Order Instructions(User_Input_Work_Order_Instructions__c)
    }    
    public static Results parse(String json) {
		  return (Results) System.JSON.deserialize(json, CreatePickupCaseAPI.Results.class);
	  }

    public class Data {
        public string Id;
        public string ReferenceNumber;
        public string CaseNumber;
    }
}
/*
{
	"LocationId": "0010U00000is3ShQAI",
	"LocationCode": "HMD100",
	"AssetId": "02i0U000003mCrcQAE",
	"AcornSBID": 22222.00,
	"CaseType": "Pickup",
	"CaseSubType": "Empty and Return",
	"CaseReason": "Disposal",
	"ServiceDate": "2018-08-21", 
	"Origin": "IVR Phone",
	"ReferenceNumber": "1000",
	"ContactId": "SFDCId",
	"PSI": 100.00,
	"PO": "PO:HMD1020",
	"CreatedById": "SFDCUserId",
	"AcornSUserId": 2000,
	"connectionId": "GEN10000",
	"LastCustomerInteractionType": "IVR",
	"WorkOrderInstructions": "PICK TIME..."
}
*/