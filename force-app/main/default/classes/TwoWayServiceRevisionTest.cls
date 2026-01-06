/*
* @Name          TwoWayServiceRevisionTest
* @Author        Aliasgher
* @Vendor        TCS
* @Date          05/03/2023
* @LastModifiedDate 
* @LastModifiedBy   
* @Description    This class is created to test Service revision (update portal) functionality.
* Assumptions    Taken service channel case with case type pickup for all the test methods
*/
@isTest (SeeAllData = FALSE)
global class TwoWayServiceRevisionTest {

    private static final string SYS_ADMIN = 'System Administrator';
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    private static final string CASETYPE_PICKUP = 'Pickup';
    private static final string EMPTY_AND_RETURN = 'Empty and Return';
    private static final string SC_FIRSTName  = 'Service';
    private static final string SC_LASTName  = 'Channel';
    private static final string TEST_NAME ='Test';
    private static final String LOCATION = 'Location';
    private static final String NUM_123 = '123';
    private static final String ACC_NUMBER = '1236';
    private static final String CONTACT = 'Contact';
    private static final string DUMPSTER = 'Dumpster';
    private static final string OPEN = 'Open';
    private static final string SCHEDULED = 'Scheduled';
    private static final string TRASH = 'Trash';
    private static final string Yards_30 = '30 Yards';
    private static final string PHONE_NINE = '9999999999';
	private static final string STR_STATUS = 'Active';
    private static final string NAISC_31 = '31';
    private static final string COMMERCIAL = 'Commercial'; 

    /*
     * @MethodName    setup
     * @Author        Aliasgher
     * @Vendor        TCS
     * @description   This method will be used to setup inital required data to test methods.
    */
    @testSetup
    public static void setup(){
        List<Account> acclist = new List<Account>();
        List<Case> caseList = new List<Case>();
        
        //create quote and update quote status to cost configured in setup method
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.LastName = 'AdminUserForTest';
        Database.insert(usr); 
        Profile csrProfile = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
            test.startTest();

            Id recordTypeid = TestDataFactory.getRecordType('Client','Account');
            Account clientAccount = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,AccountNumber=ACC_NUMBER,
                                        RecordTypeid = recordTypeid, 
                                        IsPricingEligible__c = true, NAICS_Code__c = NAISC_31);
            acclist.Add(clientAccount);
            
            
            Account locAccount = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id,
            RecordTypeid = TestDataFactory.getRecordType('Location','Account'),
            IsPricingEligible__c = false, NAICS_Code__c = null, AccountNumber = '8');
            acclist.Add(locAccount);
            Database.insert(acclist);
            
            
            Account vendorAccount = new Account(Name = Constant_Util.KEYWORD_TEST, phone = PHONE_NINE, OwnerId = usr.id, AccountNumber=ACC_NUMBER,
            RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'),
            IsPricingEligible__c = false, NAICS_Code__c = null);
            vendorAccount.Parent= locAccount;
            insert vendorAccount;

            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, clientAccount.Id);
            locationlist[0].AccountNumber = '8';
            locationlist[0].Status__c = STR_STATUS;
            locationlist[0].ParentId = clientAccount.id;
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(SC_FIRSTName,SC_LASTName, clientAccount, usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].Equipment_Type__c = DUMPSTER;
            productlist[0].ProductTypeSelected__c = DUMPSTER;
            productlist[0].Family = COMMERCIAL;
            productlist[0].Container_Size__c = Yards_30;
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, clientAccount, conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Material_Type__c = TRASH;
            assetlist[0].End_Date__c  = system.today();
            assetlist[0].Supplier__c = vendorAccount.id; //Stand for WM Vendor
            assetlist[0].Sensitivity_Code__c = null; //Stand for Open Market
            assetlist[0].Occurrence_Type__c = SCHEDULED;
            Database.insert(assetlist);
                        
            caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, clientAccount, conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].RecordTypeId = TestDataFactory.getRecordType('Pickup Case','Case');
            caselist[0].Case_Type__c = CASETYPE_PICKUP;
            caselist[0].Case_Sub_Type__c = EMPTY_AND_RETURN;
            caselist[0].Origin = 'Service Channel';
            caselist[0].Status = 'Open';

            caselist[1].RecordTypeId = TestDataFactory.getRecordType('Pickup Case','Case');
            caselist[1].Case_Type__c = CASETYPE_PICKUP;
            caselist[1].Case_Sub_Type__c = EMPTY_AND_RETURN;
            caselist[1].Origin = 'Officetrax';
            caselist[1].Status = 'Open';

            Database.insert(caselist);
            System.debug('@@@@@@@@-Case Insert :' + caselist);
        }
    }

    //Mocking framework for http callout
    global class intakeStatusMock implements HttpCalloutMock {
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json = '{"data":{"serviceStatus":"COMPLETED/NO CHARGE","serviceDate":"2024-05-15T00:00:00","serviceStatuses":[{"name":"COMPLETED/NO CHARGE"},{"name":"COMPLETED/PENDING CONFIRMATION"},{"name":"IN PROGRESS/DISPATCH CONFIRMED"},{"name":"IN PROGRESS/INCOMPLETE"},{"name":"IN PROGRESS/VALIDATION REQUIRED"},{"name":"IN PROGRESS/WAITING FOR APPROVAL"},{"name":"OPEN/DECLINED"}]},"problem":null}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }

    //Mocking framework for http callout
    global class intakeProblemMock implements HttpCalloutMock {

        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json = '{"data":null,"problem":{"title":"Bad Request","status":400,"errors":[{"code":"400","message":"Case Number is not valid"}]}}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }

    //Mocking framework for http callout
    global class intakeExceptionMock implements HttpCalloutMock {

        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json = '{"data":null,"problem":{"title":"Bad Request,"status":400,"errors":[{"code":"400","message":"Case Number is not valid"}]}}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }

    /*
	* @MethodName    : getExternalStatusTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the method to get the status list from intake system.
	*/
    @isTest static void getExternalStatusTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeStatusMock());
            TwoWayServiceRevision.responseBodyObjForGetServiceStatus response = UpdatePortal.getExternalStatus(scCase.Id);
            System.debug('@@@~Service Channel Status: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }
    
    /*
	* @MethodName    : getExternalStatus_ProblemTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the method to get the status list from intake system.
	*/
    @isTest static void getExternalStatus_ProblemTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeProblemMock());
            TwoWayServiceRevision.responseBodyObjForGetServiceStatus response = UpdatePortal.getExternalStatus(scCase.Id);
            System.debug('@@@~Service Channel Status: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }

    /*
	* @MethodName    : getExternalStatusTest1
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test the method to get the status list from intake system.
	*/
    @isTest static void getExternalStatusExceptionTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id, CreatedById From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeExceptionMock());
            TwoWayServiceRevision.responseBodyObjForGetServiceStatus response = UpdatePortal.getExternalStatus(scCase.Id);
            System.debug('@@@~Service Channel Status: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }

    //Mocking framework for http callout - Service Revisions History Record
    global class intakeDisplayRecordMock implements HttpCalloutMock {
    
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json = '{"pageIndex":0,"pageSize":2,"count":4,"data":[{"caseNumber":"66620315","referenceNumber":"66620315","serviceDate":"2024-05-10T00:00:00","serviceStatus":null,"processedDate":"2024-05-06T05:13:31.933","userMessage":"Successful","exceptionMessage":"804 / User has no permissions to perform this action.","createDate":"2024-05-06T05:13:30.3","createdBy":"Test User"},{"caseNumber":"66620315","referenceNumber":"66620315","serviceDate":null,"serviceStatus":"IN PROGRESS/DISPATCH CONFIRMED","processedDate":"2024-05-06T05:13:32.85","userMessage":"Update Unsuccessful","exceptionMessage":"502/Work order is not found!","createDate":"2024-05-06T05:13:30.3","createdBy":"Test User"}],"problem":null}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
    
    /*
	* @MethodName    : getServiceRevisionsHistoryRecordTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test to get the previously changed record list from intake system.
	*/
    @isTest static void getServiceRevisionsHistoryRecordTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeDisplayRecordMock());
            TwoWayServiceRevision.DisplayServiceRevisionWrapper response = UpdatePortal.getServiceRevisionsHistoryRecord(scCase.Id, 0 , 10);
            System.debug('@@@~Display Records: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }

    /*
	* @MethodName    : getServiceRevisionsHistoryRecordProblemTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test to get the previously changed record list from intake system.
	*/
    @isTest static void getServiceRevisionsHistoryRecordProblemTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeProblemMock());
            TwoWayServiceRevision.DisplayServiceRevisionWrapper response = UpdatePortal.getServiceRevisionsHistoryRecord(scCase.Id, 0 , 10);
            System.debug('@@@~Display Records: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }

    /*
	* @MethodName    : getServiceRevisionsHistoryRecordExceptionTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test to get the previously changed record list from intake system.
	*/
    @isTest static void getServiceRevisionsHistoryRecordExceptionTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeExceptionMock());
            TwoWayServiceRevision.DisplayServiceRevisionWrapper response = UpdatePortal.getServiceRevisionsHistoryRecord(scCase.Id, 0 , 10);
            System.debug('@@@~Display Records: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }
    
    //Mocking framework for http callout - Service Revisions History Record
    global class intakeUpdateResponseMock implements HttpCalloutMock {

        // Implement this interface method
        global HTTPResponse respond(HTTPRequest req) {
            String json = '{"data":{"isSuccess":true},"problem":null}';
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }

    /*
	* @MethodName    : updateRecordToExSystemTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test to update the service date and status to external intake system.
	*/
    @isTest static void updateRecordToExSystemTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeUpdateResponseMock());
            Datetime serviceDate = Datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 0, 0, 0);
            String serviceStatus = 'COMPLETED/NO CHARGE';
            TwoWayServiceRevision.responseBodyObjForServiceRevision response = UpdatePortal.updateRecordToExSystem(serviceDate, serviceStatus, scCase.Id);
            System.debug('@@@~Display Records: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }

    /*
	* @MethodName    : updateRecordToExSystemProblemTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test to update the service date and status to external intake system.
	*/
    @isTest static void updateRecordToExSystemProblemTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeProblemMock());
            Datetime serviceDate = Datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 0, 0, 0);
            String serviceStatus = 'COMPLETED/NO CHARGE';
            TwoWayServiceRevision.responseBodyObjForServiceRevision response = UpdatePortal.updateRecordToExSystem(serviceDate, serviceStatus, scCase.Id);
            System.debug('@@@~Display Records: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }

    /*
	* @MethodName    : updateRecordToExSystemExceptionTest
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test to update the service date and status to external intake system.
	*/
    @isTest static void updateRecordToExSystemExceptionTest(){
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(currentuser.get(0)){
            // Set mock callout class
            Case scCase = [select Id From Case WHERE Origin = :'Service Channel' LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new intakeExceptionMock());
            Datetime serviceDate = Datetime.newInstance(date.today().year(), date.today().month(), date.today().day(), 0, 0, 0);
            String serviceStatus = 'COMPLETED/NO CHARGE';
            TwoWayServiceRevision.responseBodyObjForServiceRevision response = UpdatePortal.updateRecordToExSystem(serviceDate, serviceStatus, scCase.Id);
            System.debug('@@@~Display Records: ' + response);      
            Test.stopTest();
            system.assert(response != null);            
        }
    }
    
    
     /*
	* @MethodName    : test_getOfficetraxServiceStatus_true
	* @Author        : 
	* @Vendor		 : TCS
	* @description	 : This method will test to code switch to display officetrax status.
	*/
    
     @isTest
    static void test_getOfficetraxServiceStatus_true() {
        Code_Switch__c cs = new Code_Switch__c(
            Name = 'OfficeTraxServiceStatus',
            Switch_Off__c = true 
        );
        insert cs;
 
        
        Test.startTest();
        Boolean result = UpdatePortal.getOfficetraxServiceStatus();
        Test.stopTest();
 
        
        System.assertEquals(true, result, 'Expected true when Switch_Off__c is true');
    }
 
    @isTest
    static void test_getOfficetraxServiceStatus_false() {
        
        Code_Switch__c cs = new Code_Switch__c(
            Name = 'OfficeTraxServiceStatus',
             Switch_Off__c = false
        );
        insert cs;
 
        Test.startTest();
        Boolean result = UpdatePortal.getOfficetraxServiceStatus();
        Test.stopTest();
 
        System.assertEquals(false, result, 'Expected false when Switch_Off__c is false');
    }
    
   // SDT-48584
     @isTest
    static void testReturnADDCommentJson() {
       
        String jsonResult = APICallUtility.returnADDCommentJson();
 
        System.assertNotEquals(null, jsonResult, 'JSON string should not be null');
      
    }
    
     @isTest
    static void testReturnVIEWCommentJson() {
       
        String jsonResult = APICallUtility.returnVIEWCommentJson();
 
        System.assertNotEquals(null, jsonResult, 'JSON string should not be null');
      
    }
    
    @isTest
    static void testReturnVIEWCommentJsonPage() {
        
        String jsonResult = APICallUtility.returnVIEWCommentJsonPage();
        
        System.assertNotEquals(null, jsonResult, 'JSON string should not be null');
        
    }
     @isTest
    static void testReturnGetRecipients() {
        
        String jsonResult = APICallUtility.returnGetRecipients();
        
        System.assertNotEquals(null, jsonResult, 'JSON string should not be null');
        
    }
    
}