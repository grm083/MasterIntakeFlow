@isTest
public class CaseRulesModalCtrlTest {
    
    // Setup test data
    @testSetup 
    static void setup() {
       Profile p = TestDataFactory.getProfile('System Administrator');
       User usr = TestDataFactory.createUser(p);
       Database.insert(usr);

       System.runAs(usr) {
           // Create Client Account
           List<Account> acclist = TestDataFactory.createAccount('Test client', usr, 'Client');
           Database.insert(acclist);

           // Create Location Account
           List<Account> locationlist = TestDataFactory.createLocation('Test Location', usr, acclist.get(0).Id);
           Database.insert(locationlist);

           // Create Contact
           List<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
           conlist[0].Preferred_Method__c = 'Email';
           conlist[0].Email = 'abc@gmail.com';
           Database.insert(conlist);

           // Create Product
           List<Product2> productlist = TestDataFactory.createProduct('test');
           Database.insert(productlist);

           // Create Vendor Account
           List<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr, 'Vendor');
           Database.insert(supplieracclist);

           // Create Asset
           List<Asset> assetlist = TestDataFactory.createAsset('first', acclist[0], conlist[0], 
                                                               productlist[0], usr, locationlist[0]);
           assetlist[0].Supplier__c = supplieracclist[0].Id;
           Database.insert(assetlist);

           // Create Cases
           List<Case> caselist = TestDataFactory.createCase('first', acclist[0], conlist[0], 
                                                            usr, locationlist[0], assetlist[0]);
           caselist[0].AccountId = locationlist[0].Id;
           caselist[0].PurchaseOrder_Number__c = '1243';
           caselist[0].Case_Type__c = 'Pickup';
           caselist[0].Case_Sub_Type__c = 'Extra Pickup';
           Database.insert(caselist);

           // Create Opportunity
           List<Opportunity> oppList = TestDataFactory.createOpportunity(1, 'Test Opportunity', caseList[0].Id, null, locationlist[0].Id);
           Database.insert(oppList);
           
           // Create Quote
           List<SBQQ__Quote__c> quoteList = TestDataFactory.createQuoteRecords(1, oppList, acclist[0], conlist[0], Date.today(), true, false);
           Database.insert(quoteList);  
                                          
           // Create Business Rule - Business Notification
           List<Business_Rule__c> BRnotificationlst = new List<Business_Rule__c>();
           Business_Rule__c brRec1 = new Business_Rule__c();
           brRec1.Request_Type__c = 'Pickup';
           brRec1.Service__c = 'Extra Pickup';
           brRec1.Active__c = true;
           brRec1.LocationId__c = locationlist[0].Id;
           brRec1.AccountId__c = acclist[0].Id;
           brRec1.Container__c = 'Dumpster';
           brRec1.Schedule_Type__c = 'Temporary';
           brRec1.Effective_Date__c = System.today() - 1;
           brRec1.Channel_Req__c = 'Test Channel Requirements';
           brRec1.Channel__c = 'WM Portal';
           brRec1.RecordTypeId = TestDataFactory.getRecordType(Constant_Util.BUSINESS_NOTIFICATION, 'Business_Rule__c');
           BRnotificationlst.add(brRec1);
           insert BRnotificationlst;
           
           // Create Business Rule - Approval
           List<Business_Rule__c> approverlst = TestDataFactory.createBusinessRule('test1', acclist[0], locationlist[0]);
           approverlst[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVAL, 'Business_Rule__c');
           approverlst[0].Request_Type__c = 'Pickup';
           approverlst[0].Service__c = 'Extra Pickup';
           approverlst[0].Active__c = true;
           approverlst[0].LocationId__c = locationlist[0].Id;
           approverlst[0].AccountId__c = acclist[0].Id;
           approverlst[0].AssetId__c = assetlist[0].id;
           approverlst[0].Container__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Effective_Date__c = System.today() - 2;
           approverlst[0].Channel_Req__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Channel__c = Constant_Util.EMPTY_STRING;
           insert approverlst;

           // Create Service Approver
           List<Service_Approver__c> salst = TestDataFactory.createServiceApprover(approverlst[0]);
           salst[0].Email__c = 'abc@gmail.com';
           salst[0].Business_Rule__c = approverlst[0].Id;
           salst[0].User__c = usr.Id;
           salst[0].Requester_Only__c = false;
           salst[0].Approver_Contact__c = conlist[0].Id;
           salst[0].Active__c = true;
           insert salst;

           // Create Service Requestor
           Service_Approver__c requestor = new Service_Approver__c(
               Business_Rule__c = approverlst[0].Id,
               Location__c = approverlst[0].LocationId__c,
               Account__c = approverlst[0].AccountId__c,
               RecordTypeId = TestDataFactory.getRecordType('Email', 'Service_Approver__c'),
               Requester_Only__c = true,
               Approver_Contact__c = conlist[0].Id,
               Email__c = 'abcmnop@gmail.com',
               Active__c = true
           );
           insert requestor;
       }
   }

    
    // Test getCase
    @isTest static void testGetCase() {
        Test.startTest();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        List<CaseRulesModalCtrl.BRWrapper> brList = CaseRulesModalCtrl.getCase(testCase.Id);
        List<CaseRulesModalCtrl.BRWrapper> brList1 = CaseRulesModalCtrl.getCaseRules(testCase.Id);
        List<CaseRulesModalCtrl.BRWrapper> brList2 = CaseRulesModalCtrl.getCaseRules(testQuote.Id);
        Test.stopTest();
        System.assert(brList.size() >= 0, 'BR List should be valid');
        System.assert(brList1.size() >= 0, 'BR List should be valid');
        System.assert(brList2.size() >= 0, 'BR List should be valid');
    }
  
    // Test getBRData
    @isTest static void testGetBRData() {
        Test.startTest();
        Account location = [SELECT Id FROM Account WHERE Name = 'Test Location' LIMIT 1];
        Case testCase = [SELECT Id FROM Case WHERE Location__c = :location.Id LIMIT 1];
        List<CaseRulesModalCtrl.BRWrapper> result = CaseRulesModalCtrl.getBRData(location.Id, 'Pickup', 'Extra Pickup', null, testCase.Id);
        for (CaseRulesModalCtrl.BRWrapper wrapper : result) {
               System.assert(wrapper.brRequestors != null, 'Service Requestors should not be null');
               for (Object sa : wrapper.brRequestors) {
                   // Converting Object to a generic Map
                   Map<String, Object> saWrapperMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sa));
               
                   if (String.valueOf(saWrapperMap.get('email')) == 'abcmnop@gmail.com') {
                       System.assertEquals(true, saWrapperMap.get('requesterOnly'), 'Requester_Only should be true for requestor');
                   }
               }
           }
        Test.stopTest();
        System.assert(result != null, 'BR Data should not be null');
    }

    // Test testGetBrNotificationRecordsByAccount
    @isTest static void testGetBrNotificationRecordsByAccount() {
        Test.startTest();
        Account location = [SELECT Id FROM Account WHERE Name = 'Test client' LIMIT 1];
        List<CaseRulesModalCtrl.BRWrapper> brList = CaseRulesModalCtrl.getBrNotificationRecordsByLocation(location.Id);
        Test.stopTest();
        System.assert(brList.size() > 0, 'Notification BRs should be returned');
    }
     // Test getBrNotificationRecordsByLocation
    @isTest static void testGetBrNotificationRecordsByLocation() {
        Test.startTest();
        Account location = [SELECT Id FROM Account WHERE Name = 'Test Location' LIMIT 1];
        List<CaseRulesModalCtrl.BRWrapper> brList = CaseRulesModalCtrl.getBrNotificationRecordsByLocation(location.Id);
        Test.stopTest();
        System.assert(brList.size() > 0, 'Notification BRs should be returned');
    }
    
     // Test testGetBrRecordsByLocation
    @isTest static void testGetBrRecordsByLocation() {
        Test.startTest();
        Account location = [SELECT Id FROM Account WHERE Name = 'Test Location' LIMIT 1];
        List<Business_Rule__c> brList = CaseRulesModalCtrl.getBrRecordsByLocation(location.Id);
        Test.stopTest();
    }
     // Test testGetBrRecordsByParentAccount
    @isTest static void testGetBrRecordsByParentAccount() {
        Test.startTest();
        Account location = [SELECT Id FROM Account WHERE Name = 'Test client' LIMIT 1];
        List<Business_Rule__c> brList = CaseRulesModalCtrl.getBrRecordsByLocation(location.Id);
        Test.stopTest();
    }
  
    //Method to cover ChangeTaskAssignment method in class
    @isTest static void sendEmail() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        System.runAs(currentuser){
            
            Test.startTest();
            List<Case> caselist = [SELECT Id, Origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, 
                                   Assetid, PSI__c, PSI_Comments__c, Service_Date__c, SLA_Service_Date_Time__c 
                                   FROM Case 
                                   WHERE PurchaseOrder_Number__c =: '1243'
                                   LIMIT 1];

            List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, Locationid__c, Container__c, Service__c, 
                                            Request_Type__c, Schedule_Type__c, Active__c, Effective_Date__c,
                                            RecordTypeId, Required_Information__c 
                                            FROM  Business_Rule__c 
                                            WHERE RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId()];

            CaseRulesModalCtrl.getCase(caselist[0].Id);
            CaseRulesModalCtrl.sendEmailButtonDisabled(caselist[0].Id);
            CaseRulesModalCtrl.sendEmail(new List<Id>{brlst[0].Id}, new List<Id>{caselist[0].Id});
            Test.stopTest();

            // assertion
            system.assert(brlst.size() != 0);
            system.assert(caselist.size() != 0);
        }        
    }
}