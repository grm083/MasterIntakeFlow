/**
* @author Accenture
* @date 1/31/2019
* @description : Apex class ANIMatchWebservicesTest 
**/
// test class for ANIMatchWebservices
@isTest(SeeAllData=false)
public class ANIMatchWebservicesTest {
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
    private static final string PICKUP = 'Pickup';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string PRODUCT = '8 yrd';
    private static final string COMMERCIAL = 'Commercial';
    private static final string STATUS_INACTIVE = 'InActive';
	private static final string STR_PHONE_THREE = '3333333333';
    private static final string STR_PHONE_FOUR = '1111111123';
	private static final string STR_STATUS = 'Active';
	private static final string STR_PHONE_ONE = '1111111111';
	private static final string STR_ACCOUNT_NUMBER = 'Location';
	private static final string STR_COUNTRY_US = 'United States';
	private static final string STR_POSTAL_CODE = '01234';
	private static final string STR_STATE = 'Florida';
	private static final string STR_CITY = 'Test City';
	private static final string STR_STREET = 'Test Street';
	private static final string STR_SYS_ADMIN = 'System Administrator';
	private static final string STR_RollOff = 'Rolloff';
	private static final string STR_TYPE = 'Pickup';
	private static final string STR_SUB_TYPE = 'Empty and Do NOT Return';
	private static final string STR_REASON = 'Disposal';
    
	private static final string DISTRICT_MANAGER = 'District Manager'; 
	
    /**
    * @description set the test data
    */ 
    @testSetup static void setup() {        
        Profile prf = TestDataFactory.getProfile(STR_SYS_ADMIN);
        User usr = TestDataFactory.createUser(prf);

        Database.insert(usr);
        
        system.runAs(usr){
        	
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            acclist[1].Status__c = Constant_Util.ACTIVE;
            Database.insert(acclist);
            
            list<Account> acclist2 = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            acclist2[0].Phone = STR_PHONE_THREE;
            acclist2[0].Status__c = STR_STATUS;
            acclist2[0].Self_Service_Eligible_picklist__c = 'Pickup Self Service Eligible';
            Database.insert(acclist2);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            List<Account> locationlist2 = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist2.get(0).id);
            locationlist2[0].Phone = STR_PHONE_ONE;
            locationlist2[0].AccountNumber = STR_ACCOUNT_NUMBER;
            locationlist2[0].Status__c = STR_STATUS;
            locationlist2[0].ShippingCountry = STR_COUNTRY_US;
            locationlist2[0].ShippingPostalCode = STR_POSTAL_CODE;
            locationlist2[0].ShippingState = STR_STATE;
            locationlist2[0].ShippingCity = STR_CITY;
            locationlist2[0].ShippingStreet = STR_STREET;
             
            Database.insert(locationlist2);
            
            List<Account> locationlist3 = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist2.get(0).id);
            locationlist3[0].Phone = STR_PHONE_ONE;
            locationlist3[0].AccountNumber = STR_ACCOUNT_NUMBER;
            locationlist3[0].Status__c = STR_STATUS;
            locationlist3[0].ShippingPostalCode = STR_POSTAL_CODE;
            locationlist3[0].ShippingStreet = STR_STREET;
             
            Database.insert(locationlist3);
            Id locId;
            for(Account acc: locationlist3){
                locId = acc.Id;
            }
            list<Account> locationlist4 = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist4[0].Phone = STR_PHONE_FOUR;
            locationlist4[0].AccountNumber = STR_ACCOUNT_NUMBER;
            locationlist4[0].Status__c = STATUS_INACTIVE;
            locationlist4[0].ShippingCountry = STR_COUNTRY_US;
            locationlist4[0].ShippingPostalCode = STR_POSTAL_CODE;
            locationlist4[0].ShippingState = STR_STATE;
            locationlist4[0].ShippingCity = STR_CITY;
            locationlist4[0].ShippingStreet = STR_STREET;
            Database.insert(locationlist4);            

            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            list<Contact> conlist2 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist2);
            list<Account_Title__c> titlelst = TestDataFactory.createAccountTitle(acclist.get(1),DISTRICT_MANAGER);
            Database.insert(titlelst,false); 
            list<Contact> conlist3 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(1), usr);
            conlist3[0].phone = '4446644466';
            conlist3[0].Preferred_Method__c = 'Phone';
            conlist3[0].Account_Title__c = titlelst[0].Id;
            Database.insert(conlist3);

            List<Contact> conlist4 = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                Constant_Util.CONSTANT_LAST, acclist.get(1), usr);
            conlist4[0].phone = '9999999999';
            Database.insert(conlist4);
            
            AccountContactRelation acr = new AccountContactRelation (ContactId = conlist.get(0).Id, 
                                                                     AccountId = locationlist.get(0).Id);
            Database.insert(acr);
            
            AccountContactRelation acr2 = new AccountContactRelation (ContactId = conlist2.get(0).Id, 
                                                                     AccountId = locationlist.get(0).Id);
            Database.insert(acr2);
            
            AccountContactRelation acr3 = new AccountContactRelation (ContactId = conlist2.get(0).Id, 
                                                                     AccountId = locId);
            Database.insert(acr3); 
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            Database.insert(supplieracclist);
            
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            List<product2> productList2 = TestDataFactory.createProduct(PRODUCT);
            productList2[0].Family = STR_RollOff;
            productList2[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productList2);
            
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist2.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist2.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
 			Database.insert(assetlist);
            
            
            List<Asset> assetlist2 = TestDataFactory.createAsset(ASSET_NAME , acclist2.get(0), conlist.get(0), 
                                                                productList2.get(0), usr, locationlist2.get(0));
            assetList2[0].Supplier__c = supplieracclist[0].Id;
 			Database.insert(assetList2);
 			
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acclist2.get(0), conlist.get(0), 
                                                             usr, locationlist2.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            caselist[0].Create_AM_and_PM_Pickups__c = true;
             
			caselist[2].Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
            Database.insert(caselist);
        	
        	List<Case> caseList2 = TestDataFactory.createCase(CASE_NAME, acclist2.get(0), conlist.get(0), 
                                                             usr, locationlist2.get(0), assetlist2.get(0));
        	
        	caseList2[2].Case_Type__c = STR_TYPE;
            caseList2[2].Case_Sub_Type__c = STR_SUB_TYPE;
            caseList2[2].Case_Reason__c = STR_REASON; 
        	
        	Database.insert(caseList2[2]);
        }
        
         
    }
	
        /**
    * @description test method for phone on InActive Location 
    */
    @isTest static void testbyInActiveLocation(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ANI":"1111111123"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
			ANIMatchWebservices.ANIMatchResponse result = null;        
            Test.startTest();
            ANIMatchWebservices.getContact();
            result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString() , ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.assert(result.RecordCount == 0);
        }
    }
    
    /**
    * @description test method for phone on contact 
    */
    @isTest static void testbyContact(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ANI":"9999999999"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            ANIMatchWebservices.ANIMatchResponse result = null; 
            Test.startTest();
            ANIMatchWebservices.getContact();
			result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString(), ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.assert(result.RecordCount == 1);
        }
        
    }
    
    /**
    * @description test method for phone on Account
    */
    @isTest static void testbyAccount(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ANI":"3333333333"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            ANIMatchWebservices.ANIMatchResponse result = null;
            Test.startTest();
            ANIMatchWebservices.getContact();
            result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString() , ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.assert(result.RecordCount == 0);
        }
        
    }
    
    /**
    * @description test method for phone on contact
    */
    @isTest static void testbyLocationANI(){
        User usr = [Select id ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ANI":"1111111111"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            ANIMatchWebservices.ANIMatchResponse result = null;
            Test.startTest();
            ANIMatchWebservices.getContact();
            result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString() , ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.debug('@@ result.RecordCount'+result.RecordCount);
            system.assert(jsonMsg != null);
        }
        
    }

        /**
    * @description test method for phone on contact
    */
    @isTest static void testbyVendorContact(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        Contact con = [SELECT Id,Phone,Preferred_Method__c,Account_Title__c FROM Contact WHERE Phone = '4446644466'];
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1';
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ANI":"4446644466"}';
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            ANIMatchWebservices.ANIMatchResponse result = null;
            Test.startTest();
            ANIMatchWebservices.getContact();
            result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString() , ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.assert(result.IsSupplier == 'true'); 
            system.assert(result.Locations[0].Contacts[0].contact.phone == con.phone);
            system.assert(result.Locations[0].Contacts[0].contact.Preferred_Method__c == con.Preferred_Method__c);
            system.assert(result.Locations[0].Contacts[0].contact.Account_Title__c == con.Account_Title__c);
            system.assert(result.Locations[0].Contacts[0].IsCaseContact == 'false');
        }
        
    }
    
    /**
    * @description test method for phone on location
    */
    @isTest
    static void testbyLocation(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1' ;
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"Location_Code":"Location"}';
            //System.debug('jsonMsg---'+jsonMsg);
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            ANIMatchWebservices.ANIMatchResponse result = null;
            Test.startTest();
            ANIMatchWebservices.getContact();
            result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString() , ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.assert(result.RecordCount == 3);
        }
        
    }
    
      /**
    * @description test method for phone on LocationAddress
    */
    @isTest
    static void testbyLocationaddress(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1' ;
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ShippingCountry" : "United States","ShippingPostalCode" : "01234","ShippingState" : "Florida","ShippingCity" : "Test City","ShippingStreet" : "Test Street"}';                                                             
            //System.debug('jsonMsg---'+jsonMsg);
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            ANIMatchWebservices.ANIMatchResponse result = null;
            Test.startTest();
            ANIMatchWebservices.getContact();
            result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString() , ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.assert(result.IsSupplier == 'false');
        }
        
    }
    
    /**
    * @description test method for phone on LocationAddress
    */
    @isTest
    static void testbyLocationPostalCode(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1' ;
            request.httpMethod = 'POST';
            
            // Set other properties, such as parameters
            String jsonMsg = '{"ShippingCountry" : "United States","ShippingPostalCode" : "01234","ShippingState" : "Florida","ShippingCity" : "TestCity","ShippingStreet" : "Test Street"}';                                                             
            //System.debug('jsonMsg---'+jsonMsg);
            request.requestBody = Blob.valueof(jsonMsg);
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            ANIMatchWebservices.ANIMatchResponse result = null;
            Test.startTest();
            ANIMatchWebservices.getContact();
            result = (ANIMatchWebservices.ANIMatchResponse)JSON.deserialize(res.responseBody.toString() , ANIMatchWebservices.ANIMatchResponse.class);
            Test.StopTest();
            system.assert(result.RecordCount == 2);
        }
    }
    
    
    /**
    * @description test method for phone is not available
    */
    @isTest static void testForException(){
        User usr = [Select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(usr){
            // Set up a test request
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            res.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            // Set request properties
            request.requestUri = '/services/apexrest/ANIMatch/V1';
            request.httpMethod = 'POST';
            
            // Finally, assign the request to RestContext if used
            RestContext.request = request;
            RestContext.response = res;
            Test.startTest();
            ANIMatchWebservices.getContact();
            Test.StopTest();
            system.assert(request.requestBody == null);
        }
    }
}