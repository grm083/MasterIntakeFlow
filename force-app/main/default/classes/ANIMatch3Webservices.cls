/*************************************************************
@Name: ANIMatchWebservices
@Author: Accenture
@CreateDate: 10/28/2020
@Description: Apex webservice to get Contact information
@UsedBy: SDT-17483
**************************************************************/
@RestResource(urlMapping='/ANIMatch/V3/*')
global with sharing class ANIMatch3Webservices {
    
    /**
* @description Get Contact information & Location Information, return Contact information & Location Information
**/
    @HttpPost
    global static void getContact(){
        
        //Initialize RestContext
        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        
        ANIMatchResponse aniMatchOutboundResp = new ANIMatchResponse();       
        Set<Id> supplierIds = new Set<Id>();
        Set<Id> setOfSupplierIds = new Set<Id>();
        Set<Id> searchContactsIdSet = new Set<Id>();
        Map<String, List<AccountContactRelation>> contactsByLocation = new Map<String, List<AccountContactRelation>>();         
        Map<String, List<AccountContactRelation>> contactBySupplier = new Map<String, List<AccountContactRelation>>();
        Map<String, List<AccountContactRelation>> relatedLocAccForCont = new Map<String, List<AccountContactRelation>>(); 
        Map<String, List<AccountContactRelation>> relatedClientAccForCont = new Map<String, List<AccountContactRelation>>();
        Map<String, List<AccountContactRelation>> relatedSupplierAccForCont = new Map<String, List<AccountContactRelation>>();      
        List<ErrorsWrapper> errorList = new List<ErrorsWrapper>();
        List<LocationWrapper> locWrapper = new List<LocationWrapper>();
        String isSupplierVal = Constant_Util.STR_FALSE;
        String isCaseContact = Constant_Util.STR_FALSE;
        Integer count = 0;
        Integer countOfLocAndClient = 0;
        Integer supplierCount = 0;      
        
        try {
            //Get request body
            String jsonRequest = inboundRequest.requestBody.toString();
            
            //Convert request body to data structure, deserialize JSON
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            
            //Get values from map
            String ani = string.valueOf(requestDataMap.get(Constant_Util.ANI));
            String connectionId = string.valueOf(requestDataMap.get(Constant_Util.CONNECTION_ID));
            String varShippingCountry = string.ValueOf(requestDataMap.get(Constant_Util.STR_SHIPPING_COUNTRY));
            String varShippingPostalCode = string.ValueOf(requestDataMap.get(Constant_Util.STR_SHIPPING_POSTAL_CODE));
            String varShippingState = string.ValueOf(requestDataMap.get(Constant_Util.STR_SHIPPING_STATE));
            String varShippingCity = string.ValueOf(requestDataMap.get(Constant_Util.STR_SHIPPING_CITY));
            String varShippingStreet = string.ValueOf(requestDataMap.get(Constant_Util.STR_SHIPPING_STREET));
            String locationId = string.ValueOf(requestDataMap.get(Constant_Util.STR_LOCATION_CODE));
            String lastReferenceNumber = null;
            LocWrapper objLW = null;
            SelfServiceEligibilityWrapper selfServiceEligibility = null;
            Integer locWrapperSize = 0;
            Integer locationCount = 0;
            Set<String> locAccIds = new Set<String>();
            Map<Id, Contact> searchContactMap = new Map<Id, Contact>();
            List<AccountContactRelation> newACRList = new List<AccountContactRelation>();

            if(!String.isBlank(ani) && ani != 'null'){
                String orderByCondition = ' Order BY Account.CreatedDate DESC ';
                String recordLimit = System.Label.RecordsLimits;
                String query;
                String activeStatus = Constant_Util.ACTIVE;
                String locationRT = Constant_Util.LOCATION; // Location
                String vendorRT = Constant_Util.VENDOR;  //Vendor       
                Id locRecTypeId = Schema.getGlobalDescribe().get(Constant_Util.ACCOUNT).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.LOCATION).getRecordTypeId();
                for(Account objLoc : Database.query('SELECT Id, Phone,Account.Status__c FROM Account WHERE RecordTypeId =: locRecTypeId and Phone =: ani AND Status__c =: activeStatus Order BY CreatedDate DESC ' + recordLimit)){
                    locAccIds.add(objLoc.Id);
                }
                locationCount = locAccIds.size();
                //Contact with Phone Number
                if(locationCount != 0) {
                    if(locationCount != 0){
                        contact con = null;
                        isCaseContact = [SELECT Count() FROM Contact WHERE Contact_Status__c = : Constant_Util.ACTIVE and (Phone=:ani OR MobilePhone =:ani OR ANI__c =: ani)]  == 1 ? Constant_Util.STR_TRUE : Constant_Util.STR_FALSE;
                        //Search Contacts related to Locations found with the Contact Phone No.
                        query = 'SELECT AccountId,Account.RecordType.DeveloperName, ContactId, Contact.name, Contact.Phone, Contact.ANI__c, Contact.MobilePhone,Contact.Email, Contact.Account_Title__r.Name, Contact.Preferred_Method__c, Contact.AccountId  FROM AccountContactRelation WHERE AccountId IN :locAccIds AND Account.RecordType.DeveloperName !=: vendorRT AND Account.Status__c =: activeStatus AND Contact.Contact_Status__c =: activeStatus '+ orderByCondition + recordLimit;                    
                        for(AccountContactRelation acr : Database.query(query)){
                        	if(acr.ContactId != null && (ani == acr.Contact.Phone || ani == acr.Contact.MobilePhone || ani == acr.Contact.ANI__c)){
                               if(!searchContactMap.containsKey(acr.ContactId)){
                                   if(contactsByLocation.containsKey(acr.AccountId)){
                                       contactsByLocation.get(acr.AccountId).add(acr);
                                   } else {
                                       contactsByLocation.put(acr.AccountId, new List<AccountContactRelation>{acr});
                                   }
                                   searchContactMap.put(acr.ContactId, acr.contact);
                               }
                           }
						}
                    }
                } else {
                    List<Contact> conList = Database.query('SELECT Id, Name, Account_Title__r.Name, Email, Phone,ANI__c,MobilePhone,Preferred_Method__c, AccountId FROM Contact WHERE Contact_Status__c =:activeStatus and (Phone=:ani OR MobilePhone =:ani OR ANI__c =: ani) ' + recordLimit);
                    searchContactMap = new Map<Id, Contact>(conList);
                    searchContactsIdSet = searchContactMap.keySet();
                    
                    //Functionality to make isCaseContact True/False based on the logic as described in the JIRA ticket SDT-10629
                    if(searchContactsIdSet.size() == 1){
                        query = 'SELECT ContactId,AccountId,Account.RecordType.DeveloperName FROM AccountContactRelation WHERE ContactId IN :searchContactsIdSet AND Account.Status__c =:activeStatus '+ orderByCondition + recordLimit;
                        for(AccountContactRelation acrel : Database.query(query)){
							if(Constant_Util.LOCATION.equals(acrel.Account.RecordType.DeveloperName)){
								if(relatedLocAccForCont != null && !relatedLocAccForCont.isEmpty() && relatedLocAccForCont.containsKey(acrel.AccountId)){
									relatedLocAccForCont.get(acrel.AccountId).add(acrel);
								} else {
									relatedLocAccForCont.put(acrel.AccountId, new List<AccountContactRelation>{acrel});
								}
							} else if(Constant_Util.CLIENT.equals(acrel.Account.RecordType.DeveloperName)){
								if(relatedClientAccForCont != null && !relatedClientAccForCont.isEmpty() && relatedClientAccForCont.containsKey(acrel.AccountId)){
									relatedClientAccForCont.get(acrel.AccountId).add(acrel);
								} else {
									relatedClientAccForCont.put(acrel.AccountId, new List<AccountContactRelation>{acrel});
								}
							} else if(Constant_Util.VENDOR.equals(acrel.Account.RecordType.DeveloperName)){
								//Store the setOfSupplierIds.
								setOfSupplierIds.add(acrel.AccountId);
								if(relatedSupplierAccForCont != null && !relatedSupplierAccForCont.isEmpty() && relatedSupplierAccForCont.containsKey(acrel.AccountId)){
									relatedSupplierAccForCont.get(acrel.AccountId).add(acrel);
								} else {
									relatedSupplierAccForCont.put(acrel.AccountId, new List<AccountContactRelation>{acrel});
								}
							}
						}
                        
                        countOfLocAndClient = relatedLocAccForCont.size() + relatedClientAccForCont.size();
                        if(setOfSupplierIds.isEmpty() && countOfLocAndClient>0){
                            isCaseContact = Constant_Util.STR_TRUE;
                        }
                    }
                    
                    //Contact with  Phone Number
                    if(searchContactsIdSet.size() != 0){ 
                        //Search Contacts related to Location with the Contact Phone No.                    
                        // Create a Map of Supplier Id and ACR
                        query = 'SELECT ContactId,AccountId,Account.RecordType.DeveloperName FROM AccountContactRelation WHERE ContactId IN :searchContactsIdSet AND (Account.RecordType.DeveloperName =: locationRT or Account.RecordType.DeveloperName =: vendorRT) AND Account.Status__c =:activeStatus '+ orderByCondition + recordLimit;
                        for(AccountContactRelation acr : Database.query(query)){
							if(Constant_Util.LOCATION.equals(acr.Account.RecordType.DeveloperName)){
								locAccIds.add(acr.AccountId);
								if(contactsByLocation != null && !contactsByLocation.isEmpty() && contactsByLocation.containsKey(acr.AccountId)){
								  contactsByLocation.get(acr.AccountId).add(acr);
								} else {
								  contactsByLocation.put(acr.AccountId, new List<AccountContactRelation>{acr});
								}
							} else if(Constant_Util.VENDOR.equals(acr.Account.RecordType.DeveloperName)){
								// Store the SupplierIds.
								supplierIds.add(acr.AccountId);
								if(contactBySupplier != null && !contactBySupplier.isEmpty() && contactBySupplier.containsKey(acr.AccountId)){
								  contactBySupplier.get(acr.AccountId).add(acr);
								} else {
								  newACRList.add(acr);
								  contactBySupplier.put(acr.AccountId, new List<AccountContactRelation>{acr});
								}
							}
						}
                        
                        //Search Contacts related to Supplier with the Phone No.
                        count = contactsByLocation.size() + contactBySupplier.size();
                        locationCount = contactsByLocation.size();
                        supplierCount = contactBySupplier.size();
                        if(count == contactBySupplier.size() && contactBySupplier.size() != 0){
                            isSupplierVal = Constant_Util.STR_TRUE;
                        }
                    }
                }
                system.debug('locAccIds size *** : ' + locAccIds.size());
                //if the number of locations returned is greater than 3, just return the count of the locations
                if(!locAccIds.IsEmpty()){                
                    Map<Id, Account> locationDetailsMap = new Map<Id, Account>(
                        [SELECT Id, Name, AccountNumber, RecordType.Name, Common_Name__c,Is_Location_Service_Channel_Enabled__c, ShippingPostalCode, 
                         ShippingState, ShippingStreet, ShippingCountry, ShippingCity, Phone, Customer_Location_Code__c, 
                         ParentId, Parent.Name, Parent.AccountNumber, Parent.Primary_Segment__c, Status__c, Self_Service_Eligible__c,
                         Parent.Self_Service_Eligible__c,Parent.Self_Service_Eligible_picklist__c,Self_Service_Eligible_picklist__c,
                         Parent.Is_Service_Channel__c,parent.IsPricingEligible__c
                         FROM Account WHERE Id IN :locAccIds AND Status__c =: Constant_Util.ACTIVE ORDER BY CreatedDate DESC ]);
                    
                    Map<String,String> lastReferenceNumberByLocationId = getReferenceNumberByCaseLocation(locAccIds);
                    
                    List<ContactWrapper> conWrapper = new List<ContactWrapper>();
                    Account loctemp = null;
                    Account loc = null;
                    ContactWrapper newContactWrapper = null;
                    LocationWrapper newLocationWrapper = null;
                    AccountsWrapper accs = null;
                    Contact con = null;
                    for(Id locId : locAccIds){
                        loctemp = locationDetailsMap.get(locId);
                        //Is_Location_Service_Channel_Enabled__c API name changing line 191
                        loc = new Account(Id = loctemp.id, Common_Name__c = loctemp.Common_Name__c, Name = loctemp.Name,Is_Location_Service_Channel_Enabled__c=!loctemp.Is_Location_Service_Channel_Enabled__c, 
                                          AccountNumber = loctemp.AccountNumber,ShippingPostalCode = loctemp.ShippingPostalCode,
                                          ShippingState = loctemp.ShippingState, ShippingStreet = loctemp.ShippingStreet,
                                          ShippingCountry = loctemp.ShippingCountry, ShippingCity = loctemp.ShippingCity,  
                                          Phone = loctemp.Phone, Customer_Location_Code__c = loctemp.Customer_Location_Code__c
                                         );
                        conWrapper = new List<ContactWrapper>();
						selfServiceEligibility = new SelfServiceEligibilityWrapper();
                        if(contactsByLocation != null && contactsByLocation.size() > 0 && contactsByLocation.containskey(locId)){
                            
                            for(AccountContactRelation objACR : contactsByLocation.get(locId)){
                                if(objACR.ContactId != null){
                                    con = searchContactMap.get(objACR.ContactId);
                                    if(con != null){
                                        con.Email = con.Email != null ? con.Email : Constant_Util.EMPTY_STRING;   
                                        newContactWrapper = new ContactWrapper(con, isCaseContact);
                                        conWrapper.add(newContactWrapper);     
                                    }
                                }
                            }
                        } 
                        Account acc = new Account(Id = loctemp.ParentId, Name = loctemp.Parent.Name, 
                                                  AccountNumber = loctemp.Parent.AccountNumber,
                                                  Primary_Segment__c = loctemp.Parent.Primary_Segment__c,
                                                 Is_Service_Channel__c = loctemp.Parent.Is_Service_Channel__c,
                                                 IsPricingEligible__c = loctemp.Parent.IsPricingEligible__c);
                        
                        if(!String.isBlank(loctemp.Parent.Self_Service_Eligible_picklist__c) && loctemp.Parent.Self_Service_Eligible_picklist__c != null ) {
                            string tmplist = loctemp.Parent.Self_Service_Eligible_picklist__c;
                            selfServiceEligibility.isSelfServiceEligiblePickup = String.valueof(tmplist.contains('Pickup Self Service Eligible'));
                            selfServiceEligibility.isSelfServiceEligibleStatus = String.valueof(tmplist.contains('Status Self Service Eligible'));
                            selfServiceEligibility.IsSelfServiceEligibleNewService = String.valueof(tmplist.contains('New Service Self Service Eligible'));
                        }
                        else{
                            selfServiceEligibility.isSelfServiceEligiblePickup = 'false';
                            selfServiceEligibility.isSelfServiceEligibleStatus = 'false';
                            selfServiceEligibility.IsSelfServiceEligibleNewService = 'false';
                        }
                        lastReferenceNumber = !lastReferenceNumberByLocationId.IsEmpty() && lastReferenceNumberByLocationId.containsKey(loc.Id) ? lastReferenceNumberByLocationId.get(loc.Id) : null;
                        objLW = new LocWrapper(loc, lastReferenceNumber);
                        accs = new AccountsWrapper(acc,selfServiceEligibility);
                        newLocationWrapper = new LocationWrapper(objLW, conWrapper, accs); 
                        locWrapper.add(newLocationWrapper);                        
                    }
                }
                //Create a Wrapper for the Supplier Id
                if(supplierIds.size()>0){
                    List<Account> supplierAccountList = Database.query('SELECT Id, Name, AccountNumber, RecordType.Name, Common_Name__c, ShippingPostalCode,' 
                         +'ShippingState, ShippingStreet, ShippingCountry, ShippingCity, Phone, Customer_Location_Code__c,' 
                         +'ParentId, Parent.Name, Parent.AccountNumber, Parent.Primary_Segment__c, Status__c, Self_Service_Eligible__c,'
                         +'Primary_Segment__c, Parent.Self_Service_Eligible__c,Is_Service_Channel__c,Parent.Is_Service_Channel__c FROM Account WHERE ' 
                         +'Id IN :supplierIds AND Status__c =: activeStatus '+ recordLimit);
                    Map<Id, Account> supplierDetailsMap = new Map<Id, Account>(supplierAccountList);
                    List<ContactWrapper> conWrapper = new List<ContactWrapper>();
                    Account supplierAcc = null; 
                    Account loc = null;
                    ContactWrapper newContactWrapper = null;
                    LocationWrapper newLocationWrapper = null;
                    AccountsWrapper accs = null;
                    conWrapper = new List<ContactWrapper>();
                    
                    for(String objAccountId : contactBySupplier.keySet()){
                        supplierAcc = supplierDetailsMap.get(objAccountId);
                        for(AccountContactRelation objACR : contactBySupplier.get(objAccountId)){  
                            if(objACR.ContactId != null){                                
                                Contact con = searchContactMap.get(objACR.ContactId);
                                if(con != null){
                                    con.Email = con.Email != null ? con.Email : Constant_Util.EMPTY_STRING ;   
                                    newContactWrapper = new ContactWrapper(con,'false');
                                    conWrapper.add(newContactWrapper);     
                                }
                            }
                        } 
                        
                        //Populate the Supplier Account
                        Account acc = new Account(Id = supplierAcc.Id, Name = supplierAcc.Name,AccountNumber = supplierAcc.AccountNumber, 
                                                  Primary_Segment__c = supplierAcc.Primary_Segment__c,
                                                 Is_Service_Channel__c = supplierAcc.Is_Service_Channel__c);
                        objLW = new LocWrapper(loc, lastReferenceNumber);
                        selfServiceEligibility = new SelfServiceEligibilityWrapper();
                        accs = new AccountsWrapper(acc,selfServiceEligibility);
                        newLocationWrapper = new LocationWrapper(objLW, conWrapper, accs); 
                        locWrapper.add(newLocationWrapper);
                    }
                }
                locWrapperSize = locationCount; 
            }  
            else if(!string.isBlank(locationId) && locationId != null && locationId !='null'){
                locWrapper = getByLocationCode(locationId);
                locWrapperSize = locWrapper.size();
            }
            else if(string.isNotBlank(varShippingCountry) || string.isNotBlank(varShippingPostalCode) || 
                    string.isNotBlank(varShippingState) || string.isNotBlank(varShippingCity) || 
					string.isNotBlank(varShippingStreet)){
                system.debug('Start Time DBQuery : ' + system.now());        
				locWrapper = getByLocationAddress(varShippingCountry,
												  varShippingPostalCode, varShippingState,
												  varShippingCity, varShippingStreet);
				locWrapperSize = locWrapper.size();
                system.debug('End Time DBQuery : ' + system.now());        
			}
            aniMatchOutboundResp.RecordCount = locWrapperSize;
            aniMatchOutboundResp.IsSupplier = isSupplierVal;
            aniMatchOutboundResp.Locations = new List<LocationWrapper>();
            aniMatchOutboundResp.Locations.addAll(locWrapper);            
            //Populate response values
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(aniMatchOutboundResp));
            outboundResponse.statusCode = 200;
        }
        
        catch (Exception e) {
            system.debug('@@ Exception'+ e.getStackTraceString());
            // create Exeception log
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            //Populate response values
            ErrorsWrapper errorDetails = new ErrorsWrapper(e.getTypeName(), e.getMessage()); 
            errorList.add(errorDetails);
            aniMatchOutboundResp.Problem =  new ErrorMessageWrapper(Constant_Util.EXCEPTION_OCCURRED, 
                                                                    Constant_Util.KEYWORD_EXCEPTION, errorList);
            
            //outboundResponse.responseBody = Blob.valueOf(e.getMessage());
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(aniMatchOutboundResp));     
            outboundResponse.statusCode = 400;
        } 
    }
    
    /* @Created By : Nandhini
* @Description :- Created for the Search by the Location Code.
* 
*/
    global static List<LocationWrapper> getByLocationCode(String locationId ){
        String lastReferenceNumber = null;
        List<LocationWrapper> loctnWrapper = new List<LocationWrapper>();
        //Is_Location_Service_Channel_Enabled__c API name changing 327
        List<Account> accList= [SELECT Id, Name, AccountNumber, RecordType.Name,Is_Location_Service_Channel_Enabled__c, Common_Name__c, ShippingPostalCode, 
                                ShippingState, ShippingStreet, ShippingCountry, ShippingCity, Phone, Customer_Location_Code__c, 
                                ParentId, Parent.Name, Parent.AccountNumber, Parent.Primary_Segment__c, Status__c, 
                                Parent.Self_Service_Eligible__c,Parent.Self_Service_Eligible_picklist__c,Self_Service_Eligible_picklist__c,
                                Parent.Is_Service_Channel__c,parent.IsPricingEligible__c,Is_Service_Channel__c
                                FROM Account WHERE Name =: locationId AND Status__c =: Constant_Util.ACTIVE LIMIT 49999]; 
        
        if(accList!= null && !accList.isEmpty()){
            List<ContactWrapper> conWrapper = new List<ContactWrapper>();
            Account loc = new Account();
            ContactWrapper newContactWrapper = null;
            LocationWrapper newLocationWrapper = null;
			LocWrapper objLW = null;
            AccountsWrapper accs = null;
            SelfServiceEligibilityWrapper selfServiceEligibility = new SelfServiceEligibilityWrapper();
            Set<String> accIds = new Set<String>();
            for(Account acc : accList){
                accIds.add(String.valueOf(acc.id));
            }
            
            Map<String,String> lastReferenceNumberByLocationId = getReferenceNumberByCaseLocation(accIds);
            for(account locationVal : accList){
                conWrapper = new List<ContactWrapper>();                        
                //put the location
                ////Is_Location_Service_Channel_Enabled__c API name changing 351
                loc = new Account(Id = locationVal.id, Common_Name__c = locationVal.Common_Name__c,Is_Location_Service_Channel_Enabled__c=!locationVal.Is_Location_Service_Channel_Enabled__c, Name = locationVal.Name, 
                                  AccountNumber = locationVal.AccountNumber,ShippingPostalCode = locationVal.ShippingPostalCode,
                                  ShippingState = locationVal.ShippingState, ShippingStreet = locationVal.ShippingStreet,
                                  ShippingCountry = locationVal.ShippingCountry, ShippingCity = locationVal.ShippingCity,  
                                  Phone = locationVal.Phone, Customer_Location_Code__c = locationVal.Customer_Location_Code__c);
                
                Account acc = new Account(Id = locationVal.ParentId, Name = locationVal.Parent.Name, 
                                          AccountNumber = locationVal.Parent.AccountNumber,
                                          Primary_Segment__c = locationVal.Parent.Primary_Segment__c,
                                         Is_Service_Channel__c = locationVal.Parent.Is_Service_Channel__c,
                                         IsPricingEligible__c = locationVal.Parent.IsPricingEligible__c);                
                 
                
                objLW = new LocWrapper(loc, !lastReferenceNumberByLocationId.IsEmpty() && lastReferenceNumberByLocationId.containsKey(locationVal.Id) ? lastReferenceNumberByLocationId.get(locationVal.Id) : null);
                
                if(!String.isBlank(locationVal.Parent.Self_Service_Eligible_picklist__c) && locationVal.Parent.Self_Service_Eligible_picklist__c != null ) {
                    string tmplist = locationVal.Parent.Self_Service_Eligible_picklist__c;
                    selfServiceEligibility.isSelfServiceEligiblePickup = String.valueof(tmplist.contains('Pickup Self Service Eligible'));
                    selfServiceEligibility.isSelfServiceEligibleStatus = String.valueof(tmplist.contains('Status Self Service Eligible'));
                    selfServiceEligibility.IsSelfServiceEligibleNewService = String.valueof(tmplist.contains('New Service Self Service Eligible'));

                }
                else{
                    selfServiceEligibility.isSelfServiceEligiblePickup = 'false';
                    selfServiceEligibility.isSelfServiceEligibleStatus = 'false';
                    selfServiceEligibility.IsSelfServiceEligibleNewService = 'false';
                }
                accs = new AccountsWrapper(acc,selfServiceEligibility);
                newLocationWrapper = new LocationWrapper(objLW, conWrapper, accs); 
                loctnWrapper.add(newLocationWrapper);
            }
        }
        return loctnWrapper;
    }
    
    /* @Created By : Niranjan
	* @Description :- Created for the Search by the Location Address.
	* 
	*/
    global static List<LocationWrapper> getByLocationAddress(String varShippingCountry,
                                                             String varShippingPostalCode,String varShippingState, 
                                                             String varShippingCity, String varShippingStreet){
		 Map<Id,Account> locationmap = new Map<Id,Account>();
         Set<String> locationCode = new Set<String>();
         String lastReferenceNumber = null;
         Integer statusCode = 200;
         String sucessStatus = 'OK';                                                        
		 List<LocationWrapper> loctnWrapper = new List<LocationWrapper>();
             // Elastic Search API Callout
             HttpResponse elasticResponse = ANIMatch3Webservices.callElasticSearchAPI(varShippingCountry,
                                                             varShippingPostalCode,varShippingState, 
                                                             varShippingCity, varShippingStreet);
			 if(elasticResponse.getStatusCode() == statusCode && elasticResponse.getStatus() == sucessStatus){
                 String responseBody = elasticResponse.getBody();
            	 system.debug('responseBody :: ' + responseBody);
                 ElasticResponseWrapper responseWrapper = ElasticResponseWrapper.parse(responseBody);
                 ElasticResponseWrapper.HitsWrap hitWrapList = responseWrapper.hits;
                 List<ElasticResponseWrapper.Hits> hitSourceList = new List<ElasticResponseWrapper.Hits>();
                 hitSourceList.addAll(hitWrapList.hits);
                 system.debug('hitSourceList :: ' + hitSourceList);
                 if(hitSourceList!=null && !hitSourceList.isEmpty()){
                     List<ElasticResponseWrapper.Source> sourceList = new List<ElasticResponseWrapper.Source>();
                     for(ElasticResponseWrapper.Hits wrap : hitSourceList ){
                         if(wrap.source!=null){
                             sourceList.add(wrap.source);
                         }
                     }
                     for(ElasticResponseWrapper.Source source : sourceList){
                         if(!String.isBlank(source.LocationCode) && !String.isBlank(source.LocationAddressLine1) && !String.isBlank(source.LocationPostalCode) ){
                             locationCode.add(source.LocationCode);
                         }
                     }
                 }    
                             
		 /* Started SDT-21851 ZipCode Optional */
         List<Account> accountList = new List<Account>();
         if(locationCode!=null && !locationCode.isEmpty()){
             //Is_Location_Service_Channel_Enabled__c API name changing 429
            accountList = [SELECT Id, Name, AccountNumber, RecordType.Name, Common_Name__c,Is_Location_Service_Channel_Enabled__c, ShippingPostalCode, 
            ShippingState, ShippingStreet, ShippingCountry, ShippingCity, Phone, Customer_Location_Code__c, 
            ParentId, Parent.Name, Parent.AccountNumber, Parent.Primary_Segment__c, Status__c, Parent.Self_Service_Eligible__c,
            Parent.Self_Service_Eligible_picklist__c,Parent.Is_Service_Channel__c,Self_Service_Eligible_picklist__c,
            Parent.IsPricingEligible__c
            FROM Account where 
            Name =: locationCode AND Status__c =: Constant_Util.ACTIVE
            AND RecordType.DeveloperName =: Constant_Util.LOCATION LIMIT 49999];
         }
		 if(accountList!=null && !accountList.isEmpty()){ // Ended SDT-21851 Code Changes
            for(Account acc : accountList){
                locationmap.put(acc.Id,acc);
		 	}
		 
		 if(locationmap != null && !locationmap.isEmpty()){                    
			 List<ContactWrapper> conWrapper = new List<ContactWrapper>();
			 Account loctemp = new Account();
			 Account loc = new Account();
			 ContactWrapper newContactWrapper = null;
			 LocationWrapper newLocationWrapper = null;
             SelfServiceEligibilityWrapper selfServiceEligibility = null;
			 LocWrapper objLW = null;
             AccountsWrapper accs = null;
			 Set<String> accIds = new Set<String>();
			 accIds.addAll( (Set<String>)JSON.deserialize(JSON.serialize(locationmap.keySet()), Set<String>.class));
			 Map<String,String> lastReferenceNumberByLocationId = getReferenceNumberByCaseLocation(accIds);
             
			 for(account locationVal : locationmap.values()){
                 conWrapper = new List<ContactWrapper>(); 
				 selfServiceEligibility = new SelfServiceEligibilityWrapper();
				 //put the location
				 ////Is_Location_Service_Channel_Enabled__c API name changing 461
				 loc = new Account(Id = locationVal.id, Common_Name__c = locationVal.Common_Name__c,Is_Location_Service_Channel_Enabled__c=!locationVal.Is_Location_Service_Channel_Enabled__c, Name = locationVal.Name, 
								   AccountNumber = locationVal.AccountNumber,ShippingPostalCode = locationVal.ShippingPostalCode,
								   ShippingState = locationVal.ShippingState, ShippingStreet = locationVal.ShippingStreet,
								   ShippingCountry = locationVal.ShippingCountry, ShippingCity = locationVal.ShippingCity,  
								   Phone = locationVal.Phone, Customer_Location_Code__c = locationVal.Customer_Location_Code__c);
				 
				 Account acc = new Account(Id = locationVal.ParentId, Name = locationVal.Parent.Name, 
										   AccountNumber = locationVal.Parent.AccountNumber,
                                           Primary_Segment__c = locationVal.Parent.Primary_Segment__c,
                                          Is_Service_Channel__c = locationVal.Parent.Is_Service_Channel__c,
                                          IsPricingEligible__c = locationVal.Parent.IsPricingEligible__c);
				 
                if(!String.isBlank(locationVal.Parent.Self_Service_Eligible_picklist__c) && locationVal.Parent.Self_Service_Eligible_picklist__c != null ) {
                    string tmplist = locationVal.Parent.Self_Service_Eligible_picklist__c;
                    selfServiceEligibility.isSelfServiceEligiblePickup = String.valueof(tmplist.contains('Pickup Self Service Eligible'));
                    selfServiceEligibility.isSelfServiceEligibleStatus = String.valueof(tmplist.contains('Status Self Service Eligible'));
                    selfServiceEligibility.IsSelfServiceEligibleNewService = String.valueof(tmplist.contains('New Service Self Service Eligible'));

                }
                else{
                    selfServiceEligibility.isSelfServiceEligiblePickup = 'false';
                    selfServiceEligibility.isSelfServiceEligibleStatus = 'false';
                    selfServiceEligibility.IsSelfServiceEligibleNewService = 'false';
                }
				 objLW = new LocWrapper(loc, !lastReferenceNumberByLocationId.IsEmpty() && lastReferenceNumberByLocationId.containsKey(locationVal.Id) ? lastReferenceNumberByLocationId.get(locationVal.Id) : null);
                 accs = new AccountsWrapper(acc,selfServiceEligibility);
                 newLocationWrapper = new LocationWrapper(objLW, conWrapper, accs); 
				 loctnWrapper.add(newLocationWrapper);
             
			 	}
         	  }
		    }
           }else{
                System.debug('The status code expected: ' + elasticResponse.getStatusCode() + 'status : ' + elasticResponse.getStatus());
           }
		 return loctnWrapper;
	}
    
    /* 
	* @Author	: Yogesh Sharma  
	* @Param 	: Locations
	* @Return Type: Last Reference Number  
	* @Description: Get Last Reference Number using Case Location 
	*/
    public static Map<String,String> getReferenceNumberByCaseLocation(Set<String> locations){
        Map<String,String> getLastReferenceNumberByLocation = new Map<String,String>();
        try{
            //To fetch last 30 days (Configurable) case records
            Date noOfDays = System.today().adddays(integer.valueOf(system.label.Last_Ref_Num_days));
            List<Case> caseList = [SELECT Id, CaseNumber, Reference_Number__c, Case_Type__c, Case_Sub_Type__c,
                                   Case_Reason__c, Location__c  FROM Case WHERE createddate <= TODAY AND 
                                   createddate >=: noOfDays AND Status !=: Constant_Util.CLOSED 
                                   AND Location__c IN : locations ORDER BY CaseNumber DESC LIMIT 49999];
            List<String> ivrPromptkeys = new List<String>();
            if(caseList != null && caseList.size() > 0){ 
                for(Case ca : caseList){
                    ivrPromptkeys.add(ca.Case_Type__c + Constant_Util.UNDERSCORE + ca.Case_Sub_Type__c + Constant_Util.UNDERSCORE + ca.Case_Reason__c);
                }
                
                Map<String,String> getIVRPromptByCaseTypeSubTypeReason = GetIVRCasePrompt.getIVRPrompt(ivrPromptkeys);
                if(!getIVRPromptByCaseTypeSubTypeReason.isEmpty()){
                    String lastReferenceNumber = null;
                    for(Case ca : caseList){
                        String key = ca.Case_Type__c + Constant_Util.UNDERSCORE + ca.Case_Sub_Type__c + Constant_Util.UNDERSCORE + ca.Case_Reason__c;
                        key = key.toLowerCase(); 
                        String ivrPrompt = getIVRPromptByCaseTypeSubTypeReason.get(key);
                        if(String.isNotBlank(ivrPrompt) && !ivrPrompt.equalsIgnoreCase(Constant_Util.STRING_NULL_NULL)){
                            if(getLastReferenceNumberByLocation.get(ca.Location__c) == NULL){
                                getLastReferenceNumberByLocation.put(ca.Location__c,ca.Reference_Number__c);
                            }
                        } 
                    } 
                } 
            }	
        }catch(Exception e){ System.debug('Exception-->'+e.getMessage() + 'At Line Number -->'+e.getLineNumber());}
        return getLastReferenceNumberByLocation; 
    } 
    
    /* 
	* @Author	: Arvind Kumar  
	* @Param 	: Location Adderess
	* @Return Type: Location Response  
	* @Description: Get Location address and retrieve the full location details
    * @Date : 5/Sep/2022
	*/
    public static HttpResponse callElasticSearchAPI(String varShippingCountry,
                                                             String varShippingPostalCode,String varShippingState, 
                                                             String varShippingCity, String varShippingStreet){
        String strResponse;
        String CONTENT_TYPE ='Content-Type';
        String X_API_KEY ='X-API-Key';
        String recordSize = '1';
        varShippingStreet = String.isNotBlank(varShippingStreet) ? varShippingStreet : '';
        varShippingCity = String.isNotBlank(varShippingCity) ? varShippingCity : '';
        varShippingState = String.isNotBlank(varShippingState) ? varShippingState : '';
        varShippingPostalCode = String.isNotBlank(varShippingPostalCode) ? varShippingPostalCode : '';                                                         
        List<Integration_Request_URLs__mdt> elasticMetaData = [Select DeveloperName, Client_Key__c, Content_Type__c, End_Point__c, Method__c, Timeout__c from Integration_Request_URLs__mdt where DeveloperName = 'Elastic_Search_IVR_API'];                                                         
        String requestBody = '{ "LocationCode":"","CompanyName":"","LocationName":"", "LocationAddressLine1":"'+varShippingStreet+'", "LocationAddressLine2":"", "LocationCityName":"'+varShippingCity+'", "LocationStateProvinceAbbreviation":"", "StateProvinceName":"'+varShippingState+'", "LocationPostalCode":"'+varShippingPostalCode+'", "size":"'+recordSize+'" }';                                                        
        System.debug('requestBody : '+requestBody);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(elasticMetaData[0].End_Point__c);
        request.setMethod(elasticMetaData[0].Method__c);
        request.setHeader(CONTENT_TYPE, elasticMetaData[0].Content_Type__c);
        request.setHeader(X_API_KEY, elasticMetaData[0].Client_Key__c);
        // Set the body as a JSON object
        request.setBody(requestBody);
        request.setTimeout(Integer.valueof(elasticMetaData[0].Timeout__c));                                                         
        HttpResponse response = http.send(request);
        return response;
    }
    
    /**
	* @description class for ANIMatchResponse
	*/
    global with sharing class ANIMatchResponse{
        public Integer RecordCount {get;set;}
        public String IsSupplier {get;set;}
        public List<LocationWrapper> Locations {get;set;}
        public ErrorMessageWrapper Problem {get;set;}
        
        /**
		* @description Constructor
		*/
        public ANIMatchResponse(){            
            this.RecordCount = 0;
            this.IsSupplier = Constant_Util.STR_FALSE;
        }
    }
    
    /**
	* @description class for LocationWrapper
	*/    
    global with sharing class LocationWrapper{
        public LocWrapper LocationWrap {get;set;}
        public List<ContactWrapper> Contacts {get;set;}
        public AccountsWrapper Accounts {get;set;}
        
        /**
		* @description Constructor
		*/
        public LocationWrapper(LocWrapper loc, List<ContactWrapper> cons, AccountsWrapper accs){
            this.LocationWrap = loc;
            this.Contacts = cons;
            this.Accounts = accs;
        }
    }
    
    /**
	* @description class for LocationWrapper
	*/    
    global with sharing class LocWrapper{
        public Account Location {get;set;}
        public String LastRefNum {get;set;} 
        
        /**
		* @description Constructor
		*/
        public LocWrapper(Account loc, String  LastRefNum){
            this.Location = loc;
            this.LastRefNum = LastRefNum;
            
        }
    }
    
    /**
    * @description class for AccountsWrapper
    */    
    global with sharing class AccountsWrapper{
        public Account Account {get;set;}
        public SelfServiceEligibilityWrapper SelfServiceEligibility {get;set;}
        
		/**
		* @description Constructor
		*/
        public AccountsWrapper(Account acc,SelfServiceEligibilityWrapper sse){
            this.Account = acc;
            this.SelfServiceEligibility = sse;
            
        }
    }
    
     /**
	* @description class for ContactWrapper
	*/
    global with sharing class ContactWrapper{        
        public Contact Contact {get;set;}
        public String IsCaseContact {get;set;}
        
        /**
		* @description Constructor for ContactWrapper
		*/
        public ContactWrapper(Contact con,String IsCaseContact){
            this.Contact = con;
            this.IsCaseContact = isCaseContact;
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
    
    /**
    * @description class for SelfServiceEligibilityWrapper
        SDT-9784
    */
    global with sharing class SelfServiceEligibilityWrapper{
        public String isSelfServiceEligiblePickup {get;set;}
        public String isSelfServiceEligibleStatus {get;set;}
        public String IsSelfServiceEligibleNewService {get;set;}
        
    }
}