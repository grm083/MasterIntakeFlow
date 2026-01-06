/**
 * @Class Name          : subStatusPathControllerTest.cls
 * @Description        : Test class to cover subStatusPathController
 * @Author             : Dinesh Kumar S
 * @Group              : Accenture
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 9/29/2019, 12:26:56 AM
**/
@isTest(seeAllData = false)
public with sharing class subStatusPathControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string COMPACTOR = 'COMPACTOR';
    /* method for setting up data*/ 
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[1].Case_Sub_Status__c = Constant_Util.PENDING_CUSTOMER_INFORMATION;

            Database.insert(caselist[1]);
        }
    }
    /**
    * @description : This method covers subStatusPathController.getflowpath method
    * @author Dinesh Kumar S | 9/29/2019 
    * @return void 
    **/
    @isTest static void flowPathTest(){ 
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            case ca = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber from Case LIMIT 1];
            map<String, String> responseHeaders = new Map<String, String>{'Client_Id' => 'abdhb123'};
            SingleRequestMock fakeResponse = new SingleRequestMock(200,
                                                 'Complete',
                                                 '{"controllerValues":{"New":0,"Pending":1,"Open":2,"Closed":3},"defaultValue":null,"eTag":"32113baa7c26132b94de4f20618f257f","url":"/services/data/v46.0/ui-api/object-info/Case/picklist-values/0121I000000JoJxQAK/Case_Sub_Status__c","values":[{"value":"Initial Inbound Interaction","validFor":[0],"label":"Initial Inbound Interaction","attributes":null},{"value":"Pending Customer Information","validFor":[1],"label":"Pending Customer Information","attributes":null},{"value":"Pending Request Approval","validFor":[1],"label":"Pending Request Approval","attributes":null},{"value":"Pending Service Integration","validFor":[2],"label":"Pending Service Integration","attributes":null},{"value":"Service Confirmed","validFor":[3],"label":"Service Confirmed","attributes":null}]}',
                                                 responseHeaders);
            PageReference pageRef = Page.SessionID;
            Test.startTest();
                Test.setCurrentPage(pageRef);
                Test.setMock(HttpCalloutMock.class, fakeResponse);
                string res = subStatusPathController.getflowpath(ca.Id);
                system.assertEquals(res, '{"CurrentCaseType":"Pending Customer Information","caseTypeList":["Pending Customer Information","Pending Request Approval"],"caseType":"Pending"}');
            Test.stopTest();
        }
    }
        /**
    * @description : This method covers subStatusPathController.getflowpath method
    * @author Dinesh Kumar S | 9/29/2019 
    * @return void 
    **/
    @isTest static void exceptionTest(){ 
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            case ca = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,Reference_Number__c, 
                                       PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                       Service_Date__c,SLA_Service_Date_Time__c,CaseNumber from Case LIMIT 1];
            Test.startTest();
                string res = subStatusPathController.getflowpath(ca.Id);
            Test.stopTest();
        }
    }
}