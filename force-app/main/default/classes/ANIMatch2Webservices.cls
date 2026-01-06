/*************************************************************
@Name: ANIMatch2Webservices
@Author: Accenture
@CreateDate: 12/06/2019
@Description: Apex ANIMatch2Webservices to get Contact information
**************************************************************/

@RestResource(urlMapping='/ANIMatch/V2/*')
global with sharing class ANIMatch2Webservices {
    
    /**
* @description Get Contact information & Location Information, return Contact information & Location Information
**/
    @HttpPost
    global static void getContact(){
        
        //Initialize RestContext
        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        
        ANIMatchResponse aniMatchOutboundResp = new ANIMatchResponse();       
        List<ErrorsWrapper> errorList = new List<ErrorsWrapper>();  
        List<LocationWrapper> locWrapper = new List<LocationWrapper>();
        Map<String, List<AccountContactRelation>> contactsByLocation = new Map<String, List<AccountContactRelation>>();    
        
        try {
            //Get request body
            String jsonRequest = inboundRequest.requestBody.toString();
            
            //Convert request body to data structure, deserialize JSON
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            //System.debug('jsonRequest: ' + jsonRequest ) ;
            
            //Get values from map
            String ani = string.valueOf(requestDataMap.get(Constant_Util.ANI));
            String connectionId = string.valueOf(requestDataMap.get(Constant_Util.CONNECTION_ID));
            
            if(!String.isBlank(ani)){
                //Construct Contact Response
                Map<Id, Contact> searchContactMap = new Map<Id, Contact> ([SELECT Id, Name, Account_Title__r.Name, Email, Phone, 
                                                                           MobilePhone,Preferred_Method__c, AccountId
                                                                           FROM Contact WHERE Phone=:ani OR MobilePhone =:ani
                                                                          LIMIT 49999]);
                Set<Id> searchContactsIdSet = searchContactMap.keySet();
                //System.debug('***searchContactsIdSet: ' + searchContactsIdSet) ;
                
                List<AccountContactRelation> searchAccountContactRelation = new List<AccountContactRelation>() ; 
                if(searchContactsIdSet.size() != 0){
                    searchAccountContactRelation = [SELECT ContactId,AccountId FROM AccountContactRelation 
                                                    WHERE ContactId IN :searchContactsIdSet
                                                    AND Account.RecordType.DeveloperName =: Constant_Util.LOCATION 
                                                    AND Account.Status__c =: Constant_Util.ACTIVE];
                }else{
                    searchAccountContactRelation = [SELECT ContactId,AccountId FROM AccountContactRelation 
                                                    WHERE Account.Phone=:ani
                                                    AND Account.RecordType.DeveloperName =: Constant_Util.LOCATION
                                                    AND Account.Status__c =: Constant_Util.ACTIVE];
                }           
                //System.debug('***searchAccountContactRelation: ' + searchAccountContactRelation) ;
                
                // Constructed Map of Location Account and searchedContacts
                List<AccountContactRelation> newACRList = new List<AccountContactRelation>();
                if(searchAccountContactRelation != null && searchAccountContactRelation.size()>0){
                    for(AccountContactRelation acr : searchAccountContactRelation){
                        newACRList = new List<AccountContactRelation>();
                        if(contactsByLocation.containsKey(acr.AccountId)){
                            contactsByLocation.get(acr.AccountId).add(acr);
                        }else{
                            newACRList.add(acr);
                            contactsByLocation.put(acr.AccountId, newACRList);
                        }
                    }
                }else{
                    for(Account locAcc : [SELECT Id, Phone FROM Account WHERE Phone=:ani 
                                          AND RecordType.DeveloperName =: Constant_Util.LOCATION AND 
                                          Account.Status__c =: Constant_Util.ACTIVE]){
                        contactsByLocation.put(locAcc.Id, newACRList);
                    }
                }
                
                //if the number of locations returned is greater than 3, just return the count of the locations
                if(contactsByLocation.keySet().size()<=3){                
                    //Construct Location
                    Map<Id, Account> locationDetailsMap = new Map<Id, Account>(
                        [SELECT Id, Name, AccountNumber, RecordType.Name, Common_Name__c, ShippingPostalCode, 
                         ShippingState, ShippingStreet, ShippingCountry, ShippingCity, Phone, Customer_Location_Code__c, 
                         ParentId, Parent.Name, Parent.AccountNumber, Parent.Primary_Segment__c, Status__c
                         FROM Account WHERE Id IN :contactsByLocation.keyset() AND Status__c =: Constant_Util.ACTIVE]);         
                    
                    List<ContactWrapper> conWrapper = new List<ContactWrapper>();
                    Account loctemp = null;
                    Account loc = null;
                    ContactWrapper newContactWrapper = null;
                    LocationWrapper newLocationWrapper = null;
                    
                    for(String locId : contactsByLocation.keySet()){
                        conWrapper = new List<ContactWrapper>();
                        
                        //put the location
                        loctemp = locationDetailsMap.get(locId);
                        loc = new Account(Id = loctemp.id, Common_Name__c = loctemp.Common_Name__c, Name = loctemp.Name, 
                                                  AccountNumber = loctemp.AccountNumber,ShippingPostalCode = loctemp.ShippingPostalCode,
                                                  ShippingState = loctemp.ShippingState, ShippingStreet = loctemp.ShippingStreet,
                                                  ShippingCountry = loctemp.ShippingCountry, ShippingCity = loctemp.ShippingCity,  
                                                  Phone = loctemp.Phone, Customer_Location_Code__c = loctemp.Customer_Location_Code__c);
                        //Pass Contacts
                        for(AccountContactRelation objACR : contactsByLocation.get(locId)){  
                            if(objACR.ContactId != null){                                
                                Contact con = searchContactMap.get(objACR.ContactId);
                                if(con != null){
                                    con.Email = con.Email != null ? con.Email : Constant_Util.EMPTY_STRING ;   
                                    newContactWrapper = new ContactWrapper(con);
                                    conWrapper.add(newContactWrapper);     
                                }
                            }
                        } 
                        
                        //put the address
                        Account acc = new Account(Id = loctemp.ParentId, Name = loctemp.Parent.Name, 
                                                  AccountNumber = loctemp.Parent.AccountNumber,
                                                  Primary_Segment__c = loctemp.Parent.Primary_Segment__c);
                        newLocationWrapper = new LocationWrapper(loc, conWrapper, acc); 
                        locWrapper.add(newLocationWrapper);
                    }
                }  
            }
            aniMatchOutboundResp.RecordCount = locWrapper.size() == 0 ? contactsByLocation.keySet().size() : locWrapper.size();
            aniMatchOutboundResp.Locations = new List<LocationWrapper>();
            aniMatchOutboundResp.Locations.addAll(locWrapper);
            //system.debug('aniMatchOutboundResp: '+aniMatchOutboundResp);
            
            //Populate response values
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(aniMatchOutboundResp));
            outboundResponse.statusCode = 200;
        }
        catch (Exception e) {
            //Populate response values
            //System.debug('***Exception: ' + e) ;
            //System.debug('***Exception: ' + e.getStackTraceString()) ;
            ErrorsWrapper errorDetails = new ErrorsWrapper(e.getTypeName(), e.getMessage()); 
            errorList.add(errorDetails);
            aniMatchOutboundResp.Problem =  new ErrorMessageWrapper(Constant_Util.EXCEPTION_OCCURRED, 
                                                                    Constant_Util.KEYWORD_EXCEPTION, errorList);
            
            //outboundResponse.responseBody = Blob.valueOf(e.getMessage());
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(aniMatchOutboundResp));     
            outboundResponse.statusCode = 400;
        }
        //System.debug('outboundResponse: ' + outboundResponse) ;      
    }
    
    /**
* @description class for ANIMatchResponse
*/
    global with sharing class ANIMatchResponse{
        public Integer RecordCount {get;set;}
        public List<LocationWrapper> Locations {get;set;}
        public ErrorMessageWrapper Problem {get;set;}
        
        /**
* @description Constructor
*/
        public ANIMatchResponse(){            
            this.RecordCount = 0;
        }
    }
    
    /**
* @description class for LocationWrapper
*/    
    global with sharing class LocationWrapper{
        public Account Location {get;set;}
        public List<ContactWrapper> Contacts {get;set;}
        public Account Account {get;set;}
        
        /**
* @description Constructor
*/
        public LocationWrapper(Account loc, List<ContactWrapper> cons, Account acc){
            this.Location = loc;
            this.Contacts = cons;
            this.Account = acc;
        }
    }
    
    /**
* @description class for ContactWrapper
*/
    global with sharing class ContactWrapper{        
        public Contact Contact {get;set;}
        
        /**
* @description Constructor for ContactWrapper
*/
        public ContactWrapper(Contact con){
            this.Contact = con;
            this.Contact.Phone = this.contact.Phone != null ? this.contact.Phone : Constant_Util.EMPTY_STRING;
            this.Contact.MobilePhone = this.contact.MobilePhone != null ? this.contact.MobilePhone : Constant_Util.EMPTY_STRING;
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
}