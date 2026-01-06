@isTest
public class EmailServiceTest {
	private static final string CUSTOMER_SERVICE = 'Customer Service';
  //  private static final string KROGER = 'kroger';
   // private static final string RITA = 'Rita';
   // private static final string REPLY = 'Reply';
   // 
     @testSetup static void setup() {
        Test.startTest();
        List<User> testRunUserList = new List<User>();
        
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        
        User usr = TestDataFactory.createUser(p);
        usr.FirstName = 'testuser##9999';
        usr.Bypass_Validation__c = true;
        testRunUserList.add(usr);
        
        User nonByPassValidationUser = TestDataFactory.createUser(p);
        nonByPassValidationUser.Username = 'SystemAdmin'+ String.valueof(system.now().millisecond())+'@testorg.com.wm';
        testRunUserList.add(nonByPassValidationUser);
        Database.insert(testRunUserList);
        
        System.runAs(usr){
            Account acc1 = new Account(Name = 'Test');
            insert acc1;
            
            Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id,Status__c ='Active');
            insert acc2;
            
            Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
            
            Case cse = new Case(Accountid = acc2.id,Haul_Away_Service_Booked__c = 'No',Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
            insert cse;
            
            Product2 prod = new Product2(Name = 'Extra Pickup');
            insert prod;
            
            Product2 prod2 = new Product2(Name = 'Pickup');
            insert prod2;
            Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today());
            insert opp;
            
            Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc1.id, 
                                                                 Container__c = 'Equipment', Service__c = 'Permanent', 
                                                                 Request_Type__c = 'New Service', Schedule_Type__c = 'Permanent',
                                                                 Active__c = true,Effective_Date__c = System.today() - 1,
                                                                 Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                                 RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId() );
            insert businessrule;       
            
            //Quote Creation
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc2.Id;
            quote.SBQQ__Status__c = 'Submit for Approval';
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__StartDate__c = system.today();
            quote.Business_Rule__c = businessrule.Id;
            
            insert quote;
            
        }
     }
    @isTest static void test_sendEmail() {
        SBQQ__Quote__c quote = [Select Id, Name from SBQQ__Quote__c where SBQQ__Status__c = 'Submit for Approval' Limit 1];
		EmailTemplate et = [SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Haul Away Service - Quote Approval'];
        OrgWideEmailAddress owe = [SELECT Id FROM OrgWideEmailAddress where DisplayName = 'Do Not Reply' limit 1];
        List<EmailService.EmailInput> inputList = new List<EmailService.EmailInput>();
        EmailService.EmailInput input = new EmailService.EmailInput();
        input.templateId = et.Id;
        input.relatedRecordId = quote.Id;
        input.senderEmail = owe.Id;
        input.recipientEmail = 'testnew@gmail.com';
        inputList.add(input);

        Test.startTest();
        EmailService.sendEmail(inputList);
        Test.stopTest();
    }
}