/* 
* Apex Class : SBQQQuoteServiceTest
* Description : This class is used for SBQQQuoteService
* Developer : Ruchika
* Date : 19/02/2025
* Edit Comments :
*/

@isTest(seeAllData = false)
public class SBQQQuoteServiceTest{    
    private static final string SYS_ADMIN = 'System Administrator';
   
    @testSetup static void setup()  {
        
        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        
        Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id);
        insert acc2;
        
        contact c = new contact(LastName='testCon',accountId = acc1.id,Email='sbhatia@wm.com');
        insert c;
        
        Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        Case cse = new Case(Accountid = acc2.id,Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
        insert cse;
        
        Product2 prod = new Product2(Name = 'Extra Pickup');
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Pickup');
        insert prod2;
        
        //Changes related to SDT-39632
        Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        insert trashCategory;
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        insert trashStream;  
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today(),Duration__c = cse.Case_Sub_Type__c);
        insert opp;
        
        system.debug('acc1.id :: ' + acc1.id);
        Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc1.id,
                                                             Category_Type__c='Brand',
                                                             Service__c = 'Permanent',
                                                             Container__c = 'Equipment', 
                                                             Request_Type__c = 'New Service', 
                                                             Schedule_Type__c = 'Permanent',
                                                             Active__c = true,
                                                             Effective_Date__c = System.today() - 1,
                                                             Channel_Req__c= 'Test Channel Requirements',
                                                             Channel__c = 'WM Portal',
                                                             RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId());
        
        insert businessrule; 
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
        test.starttest();
        //Quote Creation
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc2.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__StartDate__c = system.today();
        quote.Business_Rule__c = businessrule.Id;
        quote.Duration__c = opp.Duration__c;
        insert quote;
        
        //QuoteLine Creation
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c =  quote.Id;
        ql.SBQQ__Product__c = prod2.Id;
        ql.Equipment_Size__c = 'GALS-40';
        //ql.Duration__c = 'PERM'; //quote.Duration__c;
        insert ql;
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quote__c =  quote.Id;
        ql1.SBQQ__Product__c = prod.Id;
        ql1.Equipment_Size__c = 'GALS-40';
        //ql1.Duration__c = 'PERM'; //quote.Duration__c;
        insert ql1;
        
        
        //Changes related to SDT-39632
        SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id,
                                                            SBQQ__Product__c = trashStream.Id,
                                                            SBQQ__RequiredBy__c = ql.Id);
        
        QuoteTestDataFactory.insertQuoteLine(wSqLine);
        
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'sbhatia@wm.com' ,Active__c = true,Approver_Contact__c=c.id,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
        
        insert serviceApprover;   
        test.stoptest();
        }
        
    }
    
    @isTest
    public static void testCheckCustomerTypePS() {
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote1 = [SELECT Id, SBQQ__Opportunity2__r.Case__c,CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Project__c, Project_Services_Request__c, QuoteProcuredStatus__c, Priority__c, SBQQ__Status__c, SBQQ__ShippingCountry__c from SBQQ__Quote__c ];
         Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
        Test.startTest();
        Boolean result2 = SBQQQuoteService.CheckCustomerTypePS(quote1);
        Test.stopTest();
        }
        
    }
    
    @isTest
    public static void testGetOrganizationWideFromEmailAddress() {
        List<SBQQ__Quote__c> quote1 = new List<SBQQ__Quote__c>();
        quote1 = [SELECT Id, SBQQ__Opportunity2__r.Case__c,CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Project__c, Project_Services_Request__c, QuoteProcuredStatus__c, Priority__c, SBQQ__Status__c, SBQQ__ShippingCountry__c from SBQQ__Quote__c ];
         Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
        Test.startTest();
        String result2 = SBQQQuoteService.getOrganizationWideFromEmailAddress(quote1[0].Id);
        Test.stopTest();
        }
        
    }
    
    @isTest
    public static void testGetFromEmailAddress() {
        List<SBQQ__Quote__c> quote1 = new List<SBQQ__Quote__c>();
        List<OrgWideEmailAddress> oweaList = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: 'WM Service Update' OR DisplayName =: Constant_Util.EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.PS_EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.CANADA_VRM_EMAIL_TO_QUOTE Order by DisplayName];
        
        quote1 = [SELECT Id, SBQQ__Opportunity2__r.Case__c,CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Project__c, Project_Services_Request__c, QuoteProcuredStatus__c, Priority__c, SBQQ__Status__c, SBQQ__ShippingCountry__c from SBQQ__Quote__c ];
         Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
        Test.startTest();
        String result2 =SBQQQuoteService.getFromEmailAddress(true, true, oweaList, true);
        Test.stopTest();
        }
        
    }
    
    @isTest
    public static void testGetFromEmailAddress1() {
        List<SBQQ__Quote__c> quote1 = new List<SBQQ__Quote__c>();
        List<OrgWideEmailAddress> oweaList = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: 'WM Service Update' OR DisplayName =: Constant_Util.EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.PS_EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.CANADA_VRM_EMAIL_TO_QUOTE Order by DisplayName];
        
        quote1 = [SELECT Id, SBQQ__Opportunity2__r.Case__c,CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Project__c, Project_Services_Request__c, QuoteProcuredStatus__c, Priority__c, SBQQ__Status__c, SBQQ__ShippingCountry__c from SBQQ__Quote__c ];
         Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
        Test.startTest();
        String result2 =SBQQQuoteService.getFromEmailAddress(false, true, oweaList, true);
        Test.stopTest();
        }
        
    }
    
    @isTest
    public static void testGetFromEmailAddress2() {
        List<SBQQ__Quote__c> quote1 = new List<SBQQ__Quote__c>();
        List<OrgWideEmailAddress> oweaList = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: 'WM Service Update' OR DisplayName =: Constant_Util.EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.PS_EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.CANADA_VRM_EMAIL_TO_QUOTE Order by DisplayName];
        
        quote1 = [SELECT Id, SBQQ__Opportunity2__r.Case__c,CreatedBy.UserRole.Name, SBQQ__Account__r.Parent.Primary_Segment__c, Project__c, Project_Services_Request__c, QuoteProcuredStatus__c, Priority__c, SBQQ__Status__c, SBQQ__ShippingCountry__c from SBQQ__Quote__c ];
         Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        Profile csrProfile = TestDataFactory.getProfile(Pricing_Constant_Util.CUSTOMER_SERVICE);
        User csrUsr = TestDataFactory.createUser(csrProfile);
        Database.insert(csrUsr); 
        
        System.runAs(usr){
        Test.startTest();
        String result2 =SBQQQuoteService.getFromEmailAddress(false, false, oweaList, true);
        Test.stopTest();
        }
        
    }
 
}