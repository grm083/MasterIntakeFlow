/*************************************************************
@Name: IndicoWebServices
@Author: WM
@CreateDate: 11/11/2020
@Description: 
/services/apexrest/IndicoEmail/V1
**************************************************************/

@RestResource(urlMapping='/IndicoEmail/V1')
global with sharing class  IndicoWebServices {
	
    @HttpPost
    global static void getIndicoCaseDetails(){
        
          //Initialize RestContext
        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        
        //variable declaration       
       
        string jsonstring, caseType, caseSubType, caseReason;
        Integer responseCode;
        List<ResponseWrapper> responselist = null;
        list<ResponseWrapper> responseWrapperlist = new list<ResponseWrapper>(); 
        List<Case> cseList;
        EmailMessage emailMsg;
        List<Account> locAcc = new List<Account>();
        Id ContactId = null ;
        Boolean isContactNull = false;
        
        //List<IndicoWrapper> indicoWrapperList = new List<IndicoWrapper>();
        
         try {
            //Get request body
            String jsonRequest = inboundRequest.requestBody.toString();
            
            //Convert request body to data structure, deserialize JSON
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
             IndicoWebServicesMetadata FieldsTobeUpdated = new IndicoWebServicesMetadata();
             FieldsTobeUpdated = IndicoWebServicesMetadata.parse(jsonRequest); 
             
            if(FieldsTobeUpdated.Data != null && FieldsTobeUpdated.Data.EmailMessageId != null) {
                emailMsg = [Select id,isIndicoEligible__c,IndicoStatus__c from EmailMessage where id =: FieldsTobeUpdated.Data.EmailMessageId];
            }
			
		if(FieldsTobeUpdated.Data != null)
        {
            if(emailMsg != null && emailMsg.isIndicoEligible__c && emailMsg.IndicoStatus__c == Constant_Util.PENDINGINDICOPROCESSING){
               
                
                //Testing Purpose
                List<SFDCEmailMessage__c> smsg = [Select id,IndicoAPIOutput__c from SFDCEmailMessage__c where SFDCEmailMessageParentId__c=:FieldsTobeUpdated.Data.CaseId ];
                smsg[0].IndicoAPIOutput__c = jsonRequest;
                Database.update(smsg);
                //end
                
            //get case details:
                cseList = 
                [Select id,Status,Location__c, Client__c,isIndicoCaseUpdate__c, ContactId,AssetDetail__c,AssetId,Type, Case_Type__c,Case_Sub_Type__c, Case_Reason__c,RecordTypeId, PurchaseOrder_Number__c, Profile_Number__c, PSI__c  from Case WHERE Id =: FieldsTobeUpdated.Data.CaseId LIMIT 49999];        
                                               
                if(cseList.size()>0 && FieldsTobeUpdated.Data.cases != null && FieldsTobeUpdated.Data.cases.size() > 0 && cseList[0].Status == 'New')
                    {
                            
                    if(FieldsTobeUpdated.Data.cases[0].location != null){
                        locAcc = [select id,Location_Code__c ,Name, ParentId from Account where Location_Code__c =:FieldsTobeUpdated.Data.cases[0].location];
                    }
                        //Update location on Case
                    if(locAcc != null && locAcc.size() > 0 ){
                                cseList[0].Client__c = locAcc[0].ParentId;
                                cseList[0].Location__c = locAcc[0].id;
                                cseList[0].isIndicoCaseUpdate__c = true;
                            }
                         //Update Asset on Case   
                    if(FieldsTobeUpdated.Data.cases[0].assetheader != null && cseList[0].Location__c != null){
                                cseList[0].AssetId = FieldsTobeUpdated.Data.cases[0].assetheader;
                            }
					 else if(FieldsTobeUpdated.Data.cases[0].assetheader == null && FieldsTobeUpdated.Data.cases[0].Location != null){
                            cseList[0].AssetId = null;
                        }		
                        //Update Contact on Case
                        
                            if(String.IsBlank(cseList[0].ContactId)){
                            
                                //Id locationId = FieldsTobeUpdated.Data.cases[0].location;
                                if(!String.IsBlank(FieldsTobeUpdated.Data.cases[0].contact) && locAcc.size() > 0 && validateContact(FieldsTobeUpdated.Data.cases[0].contact,locAcc[0].Id)){                       
                               cseList[0].ContactId = FieldsTobeUpdated.Data.cases[0].contact;
                                    ContactId =  FieldsTobeUpdated.Data.cases[0].contact;
                                }
                            }
                            else if(locAcc.size() > 0 && !String.IsBlank(FieldsTobeUpdated.Data.cases[0].contact)) {
                                
                                validateContact(FieldsTobeUpdated.Data.cases[0].contact,locAcc[0].Id);
                                cseList[0].ContactId = FieldsTobeUpdated.Data.cases[0].contact;
                                ContactId =  FieldsTobeUpdated.Data.cases[0].contact;
                            }
                            else if(locAcc.size() > 0 && String.IsBlank(FieldsTobeUpdated.Data.cases[0].contact)) {
                        
                                Boolean isAvail = CaseController.checkContactAvailableOnLocation(cseList[0].Location__c, cseList[0].ContactId);
                                if(!isAvail){
                                  cseList[0].ContactId = null;
                                    ContactId = null;
                                    isContactNull = true;
                                }
                            }
							
                            if(FieldsTobeUpdated.Data.cases[0].recordType != null){
                        
                                Id rcdTypeID = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(FieldsTobeUpdated.Data.cases[0].recordType).getRecordTypeId();
                                cseList[0].RecordTypeId = rcdTypeID;
                            }
                            //Update Case Type on Case
                            if(String.IsBlank(cseList[0].Case_Type__c) && FieldsTobeUpdated.Data.cases[0].recordType != null && FieldsTobeUpdated.Data.cases[0].caseType != null){
                        caseType = FieldsTobeUpdated.Data.cases[0].caseType;
                            }
                            //Update Case Subtype on Case
                            if(String.IsBlank(cseList[0].Case_Sub_Type__c) && !String.IsBlank(FieldsTobeUpdated.Data.cases[0].casesubType)&& !FieldsTobeUpdated.Data.cases[0].HasSFRule && FieldsTobeUpdated.Data.cases[0].recordType != null){
                        caseSubType = FieldsTobeUpdated.Data.cases[0].casesubType;
                            }
                            //Update Case Reason on Case
                            if(String.IsBlank(cseList[0].Case_Reason__c) && !String.IsBlank(FieldsTobeUpdated.Data.cases[0].casereason)){
                        caseReason = FieldsTobeUpdated.Data.cases[0].casereason;
                            }
                            //Update Purchase Order Number on Case
                            if(String.IsBlank(cseList[0].PurchaseOrder_Number__c) && !String.IsBlank(FieldsTobeUpdated.Data.cases[0].po)){
                                cseList[0].PurchaseOrder_Number__c = FieldsTobeUpdated.Data.cases[0].po;
                            }
                            //Update Profile number on Case
                            if(String.IsBlank(cseList[0].Profile_Number__c) && !String.IsBlank(FieldsTobeUpdated.Data.cases[0].profile)){
                                cseList[0].Profile_Number__c = FieldsTobeUpdated.Data.cases[0].profile;
                            }
                            //Update PSI on Case
                            if(cseList[0].PSI__c == null && FieldsTobeUpdated.Data.cases[0].psi != null){
                                cseList[0].PSI__c = FieldsTobeUpdated.Data.cases[0].psi;
                            }
                    
                            Database.saveResult[] updateResult = Database.update(cseList);
                            for(Database.saveResult sr  : updateResult){
                                if (sr.isSuccess()) {

                            Boolean isCaseTypeFieldsUpdate = true, isServiceDateUpdate = true, isCaseContact = true;
                            
                            if(String.isNotBlank(caseType)|| String.isNotBlank(caseSubType) ||  String.isNotBlank(caseReason))
                            {
                                isCaseTypeFieldsUpdate = updateCaseTypeFields(cseList, caseType, caseSubType, caseReason);
                            }
                                    
                           
                            
                            if(FieldsTobeUpdated.Data.cases[0].serviceDate != null)
                            {
                                isServiceDateUpdate = updateServiceDate(cseList,FieldsTobeUpdated.Data.cases[0].serviceDate);
                                
                            }
                                    
                            if(isCaseTypeFieldsUpdate && isServiceDateUpdate)
                                    {
                                        responseWrapperlist.add(new ResponseWrapper(sr.isSuccess(), null));
                                        jsonstring = JSON.serialize(responseWrapperlist);
                                        responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                                        responseCode = 200;                                         
                                        
                                        //Update the EmailMessage if fields of Case are successfully updated
                               if(emailMsg != null){
                                        emailMsg.isIndicoEligible__c = false;
                                        emailMsg.IndicoStatus__c = Constant_Util.INDICOCompleted;
                                        emailMsg.IndicoErrorMessage__c = null;                                       
                               }    
                                    }
                                }                            
                            }                            
                    }
                    else {
                        
                        // Location and Required fields not exist
                    
                    List<IndicoWebServicesMetadata.ErrorMessage> errorMessageList =  null;
                        String errorMessageAll = '';               
                    
                    if(FieldsTobeUpdated.Data.cases != null && FieldsTobeUpdated.Data.cases.size() > 0)
                    {
                        errorMessageList = FieldsTobeUpdated.Data.cases[0].errorMessage;                                     
                    }
                    
                    if(errorMessageList != null && errorMessageList.size() > 0)
                        {
                            for(IndicoWebServicesMetadata.ErrorMessage err : errorMessageList)
                            {
                                errorMessageAll = err.fieldName + ': ' + err.errormessage + ',';
                            }                    
                        }
                        else {                            
                            errorMessageAll = Constant_Util.INDICONORESPONSE;
                        }
                    
                        responseWrapperlist.add(new ResponseWrapper(false, String.valueOf(errorMessageAll)));
                        jsonstring = JSON.serialize(responseWrapperlist);
                        responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                        responseCode = 400;
                    
                        // Salesforce Action 
                        //Object - EmailMessage 
                        // 1. Change EmailMessage - isIndicoEligible = False
                        // 2. Change Indico Status - Failed Indico Processing
                        // 3. Save ErrorMessage -- Error Message from ErrorMessage 
                  if(emailMsg != null){
                        emailMsg.isIndicoEligible__c = false;
                        emailMsg.IndicoStatus__c = Constant_Util.INDICO_FAILEDPROCESSING;
                        emailMsg.IndicoErrorMessage__c = errorMessageAll;
                    }
                }
                
                }
                else {
                    responseWrapperlist.add(new ResponseWrapper(false, String.valueOf('Updates will not be done after 15 min')));
                    jsonstring = JSON.serialize(responseWrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                    responseCode = 400;
                   
                }
				
		}
		else{
                    
                IndicoWebServicesMetadata.Problem requestProblem =  FieldsTobeUpdated.problem;
                
                if(requestProblem != null)
                {
                    responseWrapperlist.add(new ResponseWrapper(false, String.valueOf(requestProblem)));
                    jsonstring = JSON.serialize(responseWrapperlist);
                    responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
                    responseCode = 400;
                }
            
                // Salesforce Action 
                //Object - EmailMessage 
                // 1. Change EmailMessage - isIndicoEligible = False
                // 2. Change Indico Status - Failed Indico Processing
                // 3. Save ErrorMessage -- Error Message from Problem 
            
            if(emailMsg != null){
                    emailMsg.isIndicoEligible__c = false;
                    emailMsg.IndicoStatus__c = Constant_Util.INDICO_FAILEDPROCESSING;
                    emailMsg.IndicoErrorMessage__c = String.valueOf(requestProblem);
            }
            
            }
        } 
            
         
        catch (Exception e) {     
            responseWrapperlist.add(new ResponseWrapper(false, String.valueOf(e.getMessage())));
            jsonstring = JSON.serialize(responseWrapperlist);
            responselist = (List<ResponseWrapper>)JSON.deserialize(jsonstring, List<ResponseWrapper>.Class);
            responseCode = 400;
            
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
        	outboundResponse.responseBody = Blob.valueOf(JSON.serialize(responselist));     
        	outboundResponse.statusCode = responseCode; 
            // Salesforce Action 
            //Object - EmailMessage 
            // 1. Change EmailMessage - isIndicoEligible = False
            // 2. Change Indico Status - Error Indico Processing
            // 3. Save ErrorMessage -- e.getMessage()
            
            if(emailMsg != null){
            emailMsg.isIndicoEligible__c = false;
            emailMsg.IndicoStatus__c = Constant_Util.INDICOERRORPROCESSING;
            emailMsg.IndicoErrorMessage__c = e.getMessage();
            }
                             
        }      
        
    if(emailMsg != null){
      Database.update(emailMsg);
      updateContact(cseList,ContactId, isContactNull);  
        }
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
        	outboundResponse.responseBody = Blob.valueOf(JSON.serialize(responselist));     
            outboundResponse.statusCode = responseCode; 
            

	}
    
    //Check the relationship of Contact
    public static boolean validateContact(Id ConId, Id locAcc){
        List<AccountContactRelation> accCon = [Select id,ContactId,AccountId from AccountContactRelation where ContactId =: ConId and AccountId =: locAcc];
    
        if(accCon.size()>0){
            return true;
        }
        else {
            AccountContactRelation acr = new AccountContactRelation();
            acr.ContactId = ConId;
            acr.AccountId = locAcc;
            insert acr;
            return true;
    }
 }

    public static Boolean updateCaseTypeFields(List<Case> csTypeLst, String caseType ,String caseSubType , String caseReason){
        
        // List<Case> csService = [Select id,Service_Date__c,Location__c, Client__c, ContactId,AssetDetail__c,AssetId,Type, Case_Type__c,Case_Sub_Type__c, Case_Reason__c  from Case WHERE Id =: caseID LIMIT 1];
        if(!String.isBlank(caseType))
        {
            csTypeLst[0].Case_Type__c = caseType;
        }

        if(!String.isBlank(caseSubType))
        {
            csTypeLst[0].Case_Sub_Type__c = caseSubType;
        }

        if(!String.isBlank(caseReason))
        {
            csTypeLst[0].Case_Reason__c = caseReason;
        }

         Boolean isUpdateSuccessfully = false;
    
         List<Database.SaveResult> resultUpdateCase = Database.update(csTypeLst);
         
         for(Database.saveResult sr  : resultUpdateCase){
             if (sr.isSuccess()) {
                 isUpdateSuccessfully = true;
             }
             else {
                 
                 isUpdateSuccessfully = false;
             }
         }  
         
         return isUpdateSuccessfully;
     }
    
    public static Boolean updateContact(List<Case> csContact, Id contactId, Boolean isContactNull){
        
        Boolean isUpdateSuccessfully = true;
       List<Database.SaveResult> resultUpdateCase;

        if(contactId != null || isContactNull)
        {
            if(contactId != null)
            {
                csContact[0].ContactId = contactId;
            }

            if(isContactNull)
            {
                csContact[0].ContactId = null; 
            }
            
            update csContact;

        }  

        return isUpdateSuccessfully;
    } 
    
    public static Boolean updateServiceDate(List<Case> csService,Date serviceDate){
        
        Boolean isUpdateSuccessfully = true;
       List<Database.SaveResult> resultUpdateCase;

       if(serviceDate != null)
       { 
            csService[0].Service_Date__c = serviceDate;

            resultUpdateCase = Database.update(csService);
            
            for(Database.saveResult sr  : resultUpdateCase){
                if (sr.isSuccess()) {
                    isUpdateSuccessfully = true;
                }
                else {
                    
                    isUpdateSuccessfully = false;
                }
            }
        } 
       
        return isUpdateSuccessfully;
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
* @description class for IndicoResponse
*/
    global with sharing class IndicoResponse{
        public Boolean isSuccess {get;set;}    
        public ErrorMessageWrapper Problem {get;set;}       
	}
    
 }