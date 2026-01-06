/*************************************************************
* @Name        :  ViewCommentsTest
* @Author      :  TCS
* @Date        :  09/05/2023
* @Description :  This class is created to test View Comments functionality in the TwoWayCommunication.
**************************************************************/

@isTest(seeAllData=false)
global class ViewCommentsTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string SPECIAL_INS ='Test Special Instructions';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string OTHER ='Other';
    private static final string TEST_NAME ='Test';
    private static final String LOCATION = 'Location';
    private static final String NUM_123 = '123';
    private static final String ACC_NUMBER = '1236';
    private static final String CONTACT_NOT_ONSITE = 'Contact Not Onsite';
    private static final String CONTACT = 'Contact';
    private static final string ROLL_OFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string OPEN_TOP = 'Open Top';
    private static final string DUMPSTER = 'Dumpster';
    private static final string New_Service_Case = 'New Service Case';
    private static final string New_Service = 'New Service';
    private static final string OPEN = 'Open';
    private static final string PERMANENT = 'PERM';
    private static final string ON_CALL = 'On-Call';
    private static final string SCHEDULED = 'Scheduled';
    private static final string TRASH = 'Trash';
    private static final string Yards_30 = '30 Yards';
    private static final string PHONE_NINE = '9999999999';
    private static final string STR_PHONE_THREE = '3333333333';
	private static final string STR_STATUS = 'Active';
	private static final string STR_PHONE_ONE = '1111111111';
	private static final string STR_ACCOUNT_NUMBER = 'Location';
	private static final string STR_COUNTRY_US = 'United States';
	private static final string STR_POSTAL_CODE = '01234';
	private static final string STR_STATE = 'Florida';
	private static final string STR_CITY = 'Test City';
	private static final string STR_STREET = 'Test Street';
    private static final string NAISC_31 = '31';
    private static final string NAISC_44 = '44';
    private static final string NAISC_49 = '49';
    private static final string NAISC_51 = '51';
    private static final string NAISC_1 = '1';
    private static final string ObjectApiName = 'Pricing_Request__c';
    private static final string FieldApiName = 'Material_Code__c';
    private static final string fieldValue = 'Cardboard';
    private static final string dp_FieldApiName = 'Container_Size__c';
    private static final string ControllingfieldValue = 'Open Top';
    private static final string DependentfieldValue = '30 Yards';
    private static final string json_Valid = '{\r\n  \"data\": {\r\n    \"priceQuoteIdentifier\": \"Q215\",\r\n    \"supplierCode\": \"8\",\r\n    \"supplierName\": \"WMI\",\r\n    \"customerCode\": \"HMD\",\r\n    \"customerName\": \"The Home Depot\",\r\n    \"locationCode\": \"HMD002706\",\r\n    \"costSource\": \"WM (SBS|RO|OT|30O|B02860|20200901|050638|5411)\",\r\n    \"pricingMethodDisposalCode\": \"1.0\",\r\n    \"pricingMethodDisposalDescription\": \"Market Based Pricing\",\r\n    \"pricingMethodHaulingCode\": \"1.0\",\r\n    \"pricingMethodHaulingDescription\": \"Market Based Pricing\",\r\n    \"haulCost\": 345.82,\r\n    \"disposalCost\": 30.71,\r\n    \"haulPrice\": null,\r\n    \"disposalPrice\": null,\r\n    \"equipmentUOM\": \"Tons\",\r\n    \"estimatedVolumePerHaul\": 4.00,\r\n    \"applyInvoiceFeesToDisposalCharges\": \"Y\",\r\n    \"applyInvoiceFeesToRentalCharges\": null,\r\n    \"dispositionType\": \"S04264_LF\",\r\n    \"dispositionName\": \"B02860|S04264_LF|129A_WDL|MSW_RO\",\r\n    \"transferSiteCode\": \"NA\",\r\n    \"businessUnit\": \"B02860\",\r\n    \"wasteStreamCode\": \"MSW_RO\",\r\n    \"wasteStreamName\": \"Municipal Solid Waste\",\r\n    \"equipmentCode\": \"30O\",\r\n    \"equipmentName\": \"30 Yard Open Top\",\r\n    \"materialName\": \"MSW - Unspecified\",\r\n    \"materialClassName\": \"MSW_MSWI_Municipal Solid Waste - Industrial\",\r\n    \"zoneCode\": \"GIS543763\",\r\n    \"zoneName\": \"Detroit Central - RO MSW - To Woodland\",\r\n    \"masLibrary\": \"129A_WDL\",\r\n    \"equipmentAvailabilityTypeCode\": \"TEMP\",\r\n    \"zoneContractType\": \"Open Market\",\r\n    \"francisePricingLink\": \"\",\r\n    \"greenPagesLink\": \"\",\r\n    \"serviceCharges\": [\r\n      {\r\n        \"code\": \"FU_RO_TEMP_OPEN\",\r\n        \"name\": \"Fuel Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 10.2100,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"ENV_RO_TEMP_OPEN\",\r\n        \"name\": \"Environmental Fee\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 17.5000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"RCR_RO_TEMP_OPEN\",\r\n        \"name\": \"Regulatory Cost Recovery\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 3.6000,\r\n        \"costValueType\": \"Percent\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      },\r\n      {\r\n        \"code\": \"CSC_RO_TEMP_OPEN\",\r\n        \"name\": \"Container Service Charge\",\r\n        \"componentTypeCode\": null,\r\n        \"componentTypeName\": null,\r\n        \"actionCode\": null,\r\n        \"actionName\": null,\r\n        \"cost\": 108.50,\r\n        \"costValueType\": \"Amount\",\r\n        \"price\": null,\r\n        \"priceValueType\": null\r\n      }\r\n    ]\r\n  },\r\n  \"problem\": null\r\n}';
	private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment'; 

    
    /*
	* @MethodName    : setup
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will be used to setup inital required data to test getStpRule method.
	*/
    @testSetup
    public static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
//test class errors - SDT - 33363
        usr.LastName = 'AdminUserForTest';
        Database.insert(usr);  
        User bypassuser = TestDataFactory.createUser(adminProfile);
        bypassuser.Bypass_Validation__c = true;
        insert bypassuser;
        system.runAs(bypassuser)
        {
            List<Account> acclist = new List<Account>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();
            Id recordTypeid = TestDataFactory.getRecordType('Client','Account');
            Account acclist1 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = true, NAICS_Code__c = NAISC_31);
            acclist.Add(acclist1);
            
            
            Account acclist7 = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,
            RecordTypeid = TestDataFactory.getRecordType('Location','Account'),
            IsPricingEligible__c = false, NAICS_Code__c = null,AccountNumber = '8');
            acclist.Add(acclist7);
            
            Database.insert(acclist);
            
            Account vendorAccount = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
            RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'),
            IsPricingEligible__c = false, NAICS_Code__c = null);
            vendorAccount.Parent=acclist7;
            insert vendorAccount;
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist1.Id);
            System.debug('@@@@@@@@-Pricing Location 0 :' + locationlist);
            locationlist[0].Phone = STR_PHONE_ONE;
            locationlist[0].AccountNumber = '8';
            locationlist[0].Status__c = STR_STATUS;
            locationlist[0].ShippingCountry = STR_COUNTRY_US;
            locationlist[0].ShippingPostalCode = STR_POSTAL_CODE;
            locationlist[0].ShippingState = STR_STATE;
            locationlist[0].ShippingCity = STR_CITY;
            locationlist[0].ShippingStreet = STR_STREET;
            locationlist[0].ParentId = acclist1.id;
            Database.insert(locationlist);
            System.debug('@@@@@@@@-Pricing Location 1 :' + locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist1, usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].Equipment_Type__c = DUMPSTER;
            productlist[0].ProductTypeSelected__c = DUMPSTER;
            productlist[0].Family = COMMERCIAL;
            productlist[0].Container_Size__c = Yards_30;
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist1, conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Material_Type__c = 'Trash';
            //assetlist[0].ProductFamily = 'Commercial';
            assetlist[0].End_Date__c  = system.today();
                 //assetlist[0].Location__r.Status__c = 'Active'; 
                 assetlist[0].Supplier__c = vendorAccount.id; //Stand for WM Vendor
                 assetlist[0].Sensitivity_Code__c = null; //Stand for Open Market
                 assetlist[0].Occurrence_Type__c = 'Scheduled';
            Database.insert(assetlist);
                        
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist1, conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;
            caselist[0].Case_Type__c = 'New Service';
            caselist[0].Case_Sub_Type__c = 'Permanent';
            caselist[0].Case_Reason__c = 'Existing Location';
            caselist[0].LOB__c = 'Rolloff';
            caselist[0].Origin = 'Service Channel';
            caselist[0].Status = 'Open';
            caselist[0].Service_Occurrence_Type_Code__c = ON_CALL;
            caselist[0].Material_Type__c = TRASH;
            caselist[0].Acorn_Issue_Id__c = 27930167;
            caselist[0].Tracking_Number__c = 'T8354994';
caselist[0].Reference_Number__c = '12345';
            caselist[1].RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;
            caselist[1].Case_Type__c = 'New Service';
            caselist[1].Case_Sub_Type__c = 'Permanent';
            caselist[1].Case_Reason__c = 'Existing Location';
            caselist[1].LOB__c = 'Rolloff';
            caselist[1].Origin = NULL;
            caselist[1].Status = 'Open';
            caselist[1].Service_Occurrence_Type_Code__c = ON_CALL;
            caselist[1].Material_Type__c = TRASH;
            //caselist[1].Acorn_Issue_Id__c = 27930167;
            //caselist[1].Tracking_Number__c = 'T8354994';
            caselist[2].RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;
            caselist[2].Case_Type__c = 'New Service';
            caselist[2].Case_Sub_Type__c = 'Permanent';
            caselist[2].Case_Reason__c = 'Existing Location';
            caselist[2].LOB__c = 'Rolloff';
            caselist[2].Origin = 'Officetrax';
            caselist[2].Status = 'Open';
            caselist[2].Service_Occurrence_Type_Code__c = ON_CALL;
            caselist[2].Material_Type__c = TRASH;
            // caselist[2].Acorn_Issue_Id__c = 27930167;
            // caselist[2].Tracking_Number__c = 'T8354994';
			// caselist[2].Reference_Number__c = '12345';
            Database.insert(caselist);
            System.debug('@@@@@@@@-Pricing Case Insert :' + caselist);
    
    }
}   


    /*
	* @MethodName    : getcommentObjectList
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id.
	*/

     @isTest static void getcommentObjectList(){
         //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
         system.runAs(currentuser.get(0)){
             // Set mock callout class
             Case testCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
             Test.setMock(HttpCalloutMock.class, new viewCommentsMock());
             TwoWayService.DisplayCommentsWrapper response = viewComments.getcommentObjectList(testCase.Id,0,10);        
             Test.stopTest();
             system.assert(response != null);
            
     }
     } 
    /* Negative case
	* @MethodName    : getcommentObjectList
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id without case origin.
	*/

     @isTest static void getcommentObjectListWithoutOrigin(){
         //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
         system.runAs(currentuser.get(0)){
             // Set mock callout class
            Case testCase = [select Id,Origin From Case WHERE Origin = NULL LIMIT 1];
             System.debug(testCase.Origin);
             Test.startTest();
           Test.setMock(HttpCalloutMock.class, new viewCommentsMock());
             TwoWayService.DisplayCommentsWrapper response = viewComments.getcommentObjectList(testCase.Id,0,10);        
             Test.stopTest();
             system.assert(response != null);
            
     }
 } 

/* Negative case
	* @MethodName    : getcommentObjectList
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id without case origin.
	*/

    @isTest static void getcommentObjectListResponseNotInFormat(){
         //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
         system.runAs(currentuser.get(0)){
             // Set mock callout class
             Case testCase = [select Id From Case WHERE Origin = NULL LIMIT 1];
             Test.startTest();
             Test.setMock(HttpCalloutMock.class, new viewCommentsMock());
             TwoWayService.DisplayCommentsWrapper response = viewComments.getcommentObjectList(testCase.Id,0,10);        
             Test.stopTest();
             system.assert(response != null);
            
     }
 } 

/*
	* @MethodName    : createComment
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id.
	*/
    @isTest static void createComment(){
        //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        String commentBody = 'This text is for tesitng createComment';
        List<String> emailList = new List<String>{'test@gmail.com','testing1@gmail.com'};
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case testCase = [select Id,Reference_Number__c,CaseNumber From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new addCommentMock());
            TwoWayservice.responseBodyObjForAddComment response = CommentController.createComment(emailList,commentBody,testCase.Id);        
            Test.stopTest();
            system.assert(response != null);            
        }
    } 

    /*
	* @MethodName    : getMap_ServiceChannel
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id.
	*/
     @isTest static void getMap_ServiceChannel(){
         //test class errors - SDT - 33363
         List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
         system.runAs(currentuser.get(0)){
             // Set mock callout class
             Case testCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
             Test.startTest();
             Test.setMock(HttpCalloutMock.class, new sendAlertgetMapMock_ServiceChannel());
             TwoWayService.responseBodyObjForGetRecipients response = SendAlert.getMap(testCase.Id);        
             Test.stopTest();
             system.assert(response != null);            
        }
     }

     /*
	* @MethodName    : getMap_Officetrax
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id.
	*/
    @isTest static void getMap_Officetrax(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case testCase = [select Id From Case WHERE Origin = :'Officetrax' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new sendAlertgetMapMock_Officetrax());
            TwoWayService.responseBodyObjForGetRecipients response = SendAlert.getMap(testCase.Id);        
            Test.stopTest();
            system.assert(response != null);            
       }
    }

    /*
	* @MethodName    : getRecipientsMsg_ServiceChannel
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id.
	*/
    @isTest static void getRecipientsMsg_ServiceChannel(){
    List<String> usernameList = new List<String>{'Hayes,Joseph','Hebert,James'};
    String message = 'This method is for testing the getRecipientsMsg method';
    //test class errors - SDT - 33363
    List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
    system.runAs(currentuser.get(0)){
    // Set mock callout class
    Case testCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new sendAlertgetRecipientMsgMock());
    TwoWayservice.responseBodyObjForAddComment response = SendAlert.getRecipientsMsg(usernameList,null,message,testCase.Id);        
    Test.stopTest();
    system.assert(response != null);            
    }
    } 

    /*
	* @MethodName    : getRecipientsMsg_Officetrax
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the scenario where the action is initiated with a case record id.
	*/
    @isTest static void getRecipientsMsg_Officetrax(){
        List<String> refNumList = new List<String>{'2136','2138'};
        List<String> usernameList = new List<String>{'Waste M Employee 1','Waste M Employee 3'};
        String message = 'This method is for testing the getRecipientsMsg method';
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case testCase = [select Id From Case WHERE Origin = :'Officetrax' LIMIT 1];
            Test.startTest();
            // Test.setMock(HttpCalloutMock.class, new sendAlertgetRecipientMsgMock());
            TwoWayservice.responseBodyObjForAddComment response = SendAlert.getRecipientsMsg(refNumList,usernameList,message,testCase.Id);        
            Test.stopTest();
            system.assert(response != null);            
       }
    } 


    //Mocking framework for http callout
    global class viewCommentsMock implements HttpCalloutMock {
        
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json = '{ "problem": { "title": "string","status": 0,"errors": [{"code": "string","message": "string"}]},"data": [{'+
            '"caseNumber": "string",'+
           '"referenceNumber": "string",'+
            '"caseOrigin": "string",'+
            '"systemOrigin": "string",'+
            '"message": "We are on Page 2 . we need to work fast to finsih the project. THIs will help us to grow",'+
            '"isActionRequired": true,'+
            '"receivedDate": "2023-05-05T14:36:13.715Z",'+
            '"sentDate": "2023-05-05T14:36:13.715Z",'+
            '"partnerReference": "string",'+
            '"wmReference": "string",'+
            '"recipients": [{"user": "string"}]}],'+
            '"pageIndex": 0,'+
            '"pageSize": 0,'+
            '"count": 0}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }

    //Mocking framework for http callout
    global class addCommentMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json ='{"problem": {"title": "string","status": 0,"errors": [{"code": "string","message": "string"}]},"data": {"conversationId": 0}}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }

    //Mocking framework for http callout
    global class sendAlertgetMapMock_ServiceChannel implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json ='{"data": [{"id": 3901462,"userName": "Hayes,Joseph","email": "joseph.hayes@lowes.com"},{"id": 3979518,"userName": "Hebert,James","email": "jim.hebert@lowes.com"}],"problem": null}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }

    //Mocking framework for http callout
    global class sendAlertgetMapMock_Officetrax implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json ='{"data": [{"id": 2136,"userName": "Waste M Employee 1","referenceNumber":"2136"},{"id": 2138,"userName": "Waste M Employee 3","referenceNumber":"2138"}],"problem": null}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    //Mocking framework for http callout
    global class sendAlertgetRecipientMsgMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json ='{"problem": {"title": "string","status": 0,"errors": [{"code": "string","message": "string"}]},"data": {"conversationId": 0}}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    
	 @isTest
    static void testExtractLocation() {
        List<TwoWayService.CommentsData> data = new List<TwoWayService.CommentsData>();
 		//T01
        TwoWayService.CommentsData comment = new TwoWayService.CommentsData();
        comment.message = 'Location: 123 Street\\nCity\\nState';
 		data.clear();
        data.add(comment);
        String result = TwoWayService.extractLocation(data);
        System.assert(result.contains('123 Street'), 'Expected location details not found');
        
        //T02 - Message does not contain 'Location:'
        TwoWayService.CommentsData comment1 = new TwoWayService.CommentsData();
        comment1.message = 'No location info here';
 		data.clear();
        data.add(comment1);
        String result1 = TwoWayService.extractLocation(data);
		System.assertEquals('', result1, 'TC02 failed - Expected empty result');   
    
        // TC03 - Message contains 'Location:' but nothing after it
		TwoWayService.CommentsData comment2 = new TwoWayService.CommentsData();
        comment2.message = 'Location:';
 		data.clear();
        data.add(comment2);
 
        String result2 = TwoWayService.extractLocation(data);
        system.debug('@@@ result2: '+string.isBlank(result2));
	//	System.assert(string.isBlank(result2), 'TC03 failed - Expected empty result');   
       
        // TC04 - Message contains 'Location:' with real newlines
		TwoWayService.CommentsData comment3 = new TwoWayService.CommentsData();
        comment3.message = 'Location: 3990,NC\n 123 Main St\n Building A';
       // comment3.createdBy = 'User D';
 		data.clear();
        data.add(comment3);
        String result3 = TwoWayService.extractLocation(data);
        system.debug('@@@ result3'+result3);
        System.assert(result3.contains('3990,NC'), 'Expected location details not found');
        
        // TC05 - Message contains multiple 'Location:' keywords
		TwoWayService.CommentsData comment4 = new TwoWayService.CommentsData();
        comment4.message = 'Location: First\\nEntry\\nLocation: Second\\nEntry';
          // comment4.createdBy = 'User X';
 		data.clear();
        data.add(comment4);
        String result4 = TwoWayService.extractLocation(data);
        System.assert(result4.contains('First'), 'TC05 failed - Expected to extract from first Location:');
        
       // TC06 - Message contains 'Location:' with extra spaces
        TwoWayService.CommentsData comment5 = new TwoWayService.CommentsData();
        comment5.message = ' Location:   123 Test St\\nSuite B';
            // comment5.createdBy = 'User E';
 		data.clear();
        data.add(comment5);
        String result5 = TwoWayService.extractLocation(data);
        system.debug('@@@ result5   '+result5);
        System.assert(result5.contains('123 Test St'), 'TC06 failed - Address missing');
        
        // TC07 - Message is null or empty
        TwoWayService.CommentsData comment6 = new TwoWayService.CommentsData();
        comment6.message = ' ';
           //comment6.createdBy = 'User F';
 		data.clear();
        data.add(comment6);
        String result6 = TwoWayService.extractLocation(data);
        system.debug('@@@2 result6 '+result6);
        System.assert(string.isBlank(result6), 'TC07 failed - Expected empty output for empty message');

    }

}
