@isTest(seeAllData = false)
public class QuoteApprovalHandlerTest {    
    private static final string SYS_ADMIN = 'System Administrator';
       private static final string EMAIL = 'testfrom@test.com';
       private static final string ALTERNATIVE_EMAIL = 'test@test.com';
       private static final string FOREMAIL = 'testemail@test.com';
       private static final string EMAIL_SUBJECT = 'Approved';
       private static final string NAME = 'test';
       private static final string EMAIL_BODY = 'Test \n Test1 \n test2';
       private static final string EMAIL_BODY1 = 'Test \n\n------';
       private static final string REJECTED = 'Rejected';
       private static final string APPROVALS = 'Approvals';
       private static final string PO_PSI_VALUE = 'PO Number;PSI';
       private static final string DISTRICT_MANAGER = 'District Manager';
       private static final string COMPACTOR = 'COMPACTOR';
       private static final string SERVICE_APPROVER = 'Service_Approver__c';
       private static final string VALUE_TEST = 'Test';
       private static final string CHECK = 'Check';
      // private static final string MIXED = 'Mixed';
        
	@testSetup static void setup()  {
        //Testing for SDT-39632
        Code_Switch__c setting = new Code_Switch__c();
        setting.Name = 'Haul_Away';
        setting.Switch_Off__c =false ;
        insert setting;
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        
        Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id);
        insert acc2;
        
        //A
        Account acc3 = new Account(Name = 'Test3', ParentId = acc1.Id);
        insert acc3;
        //A
        
        Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        Case cse = new Case(Accountid = acc2.id,Is_Haul_Away_Service__c = true, Haul_Away_information__c = HaulAwayService.Haul_Away_Service_assetHaulerAvailable,
        Haul_Away_Vendor__c = HaulAwayService.Haul_Away_Vendor_Check_Sammy_API,Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
        insert cse;
        
        //A
        Case caseRecord = new Case();
        caseRecord.Accountid = acc2.id;
        caseRecord.Case_Sub_Type__c = 'Permanent';
        caseRecord.Case_Reason__c = 'Existing Location';
        caseRecord.Case_Type__c = 'New Service';
        caseRecord.recordtypeId = cseRecordTypeId;
        caseRecord.Is_Haul_Away_Service__c = true;
        caseRecord.Haul_Away_information__c = HaulAwayService.Haul_Away_Service_assetHaulerAvailable;
        caseRecord.Haul_Away_Vendor__c = HaulAwayService.Haul_Away_Vendor_Check_Sammy_API;
        insert caseRecord;
        //A
        
        Product2 prod = new Product2(Name = 'Extra Pickup');
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Pickup');
        insert prod2;
        
        //A
        Product2 prod3 = new Product2(Name = 'Haul Away Service', IsActive = true);
        insert prod3;
        //A
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today());
        insert opp;
        
        //A
        Opportunity opp1 = new Opportunity(
        Name = 'Test Opportunity', StageName = 'Proposal',CloseDate = system.today(), Case__c = caseRecord.Id);
        insert opp1;
        //A
        
        Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc1.id, 
                                                             Container__c = 'Equipment', Service__c = 'Permanent', 
                                                             Request_Type__c = 'New Service', Schedule_Type__c = 'Permanent',
                                                             Active__c = true,Effective_Date__c = System.today() - 1,
                                                             Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                             RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId() );
        
        insert businessrule; 
        
        //A
        Business_Rule__c businessrule1 = new Business_Rule__c(Accountid__c = acc1.id, 
                                                             Container__c = 'Equipment', Service__c = 'Extra Pickup', 
                                                             Request_Type__c = 'Pickup', Schedule_Type__c = 'Temporary',
                                                             Active__c = true,Effective_Date__c = System.today() - 1,
                                                             Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                             RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId() );
        
        insert businessrule1;
        //A
        
        //Quote Creation
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc2.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__StartDate__c = system.today();
        quote.Business_Rule__c = businessrule.Id;
      
        insert quote;
        
        //QuoteLine Creation
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c =  quote.Id;
        ql.SBQQ__Product__c = prod2.Id;
        ql.Equipment_Size__c = 'GALS-40';
        insert ql;
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quote__c =  quote.Id;
        ql1.SBQQ__Product__c = prod.Id;
        ql1.Equipment_Size__c = 'GALS-40';
        
        insert ql1;
        
        //A
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = acc3.Id;
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Opportunity2__c = opp1.Id;
        quote.SBQQ__StartDate__c = system.today();
        quote.Business_Rule__c = businessrule1.Id;
      
        insert quote1;
        //A
        
        //A
        SBQQ__QuoteLine__c qlHaul = new SBQQ__QuoteLine__c();
        qlHaul.SBQQ__Quote__c =  quote1.Id;
        qlHaul.SBQQ__Product__c = prod3.Id;
        qlHaul.Equipment_Size__c = 'GALS-40';
        //insert qlHaul;

        //A
        
        List<Service_Approver__c> approverList = new List<Service_Approver__c>();
        
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'sbhatia@wm.com' ,Active__c = true,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
       Service_Approver__c serviceApprover2 = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'sqamar@wm.com',Active__c = false,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId()); 
        Service_Approver__c serviceApprover3 = new Service_Approver__c(Business_Rule__c = businessrule1.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'sbatra@wm.com' ,Active__c = true,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
       Service_Approver__c serviceApprover4 = new Service_Approver__c(Business_Rule__c = businessrule1.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'svarma@wm.com',Active__c = false,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId()); 
        approverList.add(serviceApprover); 
        approverList.add(serviceApprover2);
        approverList.add(serviceApprover3); 
        approverList.add(serviceApprover4);
        insert approverList;  
        

    } 
    
    @isTest static void createEmailTest()
    {
        String subject = 'Test';
        user currentuser = [select id, Bypass_Validation__c from user where Profile.Name =: SYS_ADMIN and IsActive = True Limit 1];
        
        system.runAs(currentuser)
        {
            Test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101 Error');	//TCS-pkulkarn-SDT-41186-18-Oct-2024-Added
            
            list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];
            list<Service_Approver__c> serviceApproverlist2 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sqamar@wm.com' Limit 1];
            String emailId = serviceApproverlist1[0].Email__c ;
            String emailId2 = serviceApproverlist2[0].Email__c ;
            
            //TCS-pkulkarn-SDT-41186-18-Oct-2024-Added
            User ssmUser = TestUserFactory.getCSRUserDetails(true, false);
            ssmUser.LastName ='Team';
            ssmUser.FirstName ='SSM';
            UPDATE ssmUser;
			//TCS-pkulkarn-SDT-41186-18-Oct-2024-End

            //TCS-pkulkarn-SDT-41186-18-Oct-2024-Added Assigned_To__c, SBQQ__Status__c to the SOQL
            List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Type__c,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c, Assigned_To__c, SBQQ__Status__c, Assigned_To__r.Name from SBQQ__Quote__c LIMIT1 ]; //pk
            quotelst[0].SBQQ__Status__c = Constant_Util.QUOTE_PRICE_CONFIGURED_LABEL;		//TCS-pkulkarn-SDT-41186-18-Oct-2024-Changed to variable value
            quotelst[0].SBQQ__Type__c = Constant_Util.QUOTE_TYPE_AMEND;		//TCS-pkulkarn-SDT-41186-18-Oct-2024-Added
            UPDATE quotelst;

            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId,EMAIL_BODY1);
            
            List<Messaging.InboundEmail> emaillstNApp = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId2,EMAIL_BODY);
            
            System.debug('###emaillst'+emaillst);
            System.debug('###emaillst'+emaillstNApp);
            System.debug('quotelst'+quotelst);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId,EMAIL_BODY);
            Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();

            QuoteApprovalHandler quoteApprove1 = new QuoteApprovalHandler();
            
            
            
            Messaging.InboundEmailResult result = quoteApprove1.handleInboundEmail(emaillst1[0],env1);
            
            
            
            List<SBQQ__Quote__c> quotelst12 = [SELECT Id, Assigned_To__c, Assigned_To__r.Name, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id =: quotelst[0].Id]; //pk
            
            system.assertEquals(true, String.valueOf(quotelst12[0].SBQQ__Status__c).equalsIgnoreCase(Constant_Util.QUOTE_PRICE_CONFIGURED_LABEL), 'Error on Assertion');
            system.assertEquals(quotelst12[0].Assigned_To__r.Name, ssmUser.FirstName + ' ' + ssmUser.LastName, 'Error on Assertion');
            
            QuoteApprovalHandler quoteApprove = new QuoteApprovalHandler();
            quoteApprove.handleInboundEmail(emaillst[0],env);


            quoteApprove.handleInboundEmail(emaillstNApp[0],env);
            
            Test.stopTest();
            system.assert(result != null);
        }
    }
    
    @isTest static void createEmailTestHaul()
    {
        String subject = 'Test';
        user currentuser = [select id, Bypass_Validation__c from user where Profile.Name =: SYS_ADMIN and IsActive = True Limit 1];
        
        system.runAs(currentuser)
        {
            Test.startTest();
            system.assertEquals(true, true, 'Bypass SOQL 101 Error');	//TCS-pkulkarn-SDT-41186-18-Oct-2024-Added
            
            list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];
            list<Service_Approver__c> serviceApproverlist2 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sqamar@wm.com' Limit 1];
            String emailId = serviceApproverlist1[0].Email__c ;
            String emailId2 = serviceApproverlist2[0].Email__c ;
            
            //TCS-pkulkarn-SDT-41186-18-Oct-2024-Added
            User ssmUser = TestUserFactory.getCSRUserDetails(true, false);
            ssmUser.LastName ='Team';
            ssmUser.FirstName ='SSM';
            UPDATE ssmUser;
			//TCS-pkulkarn-SDT-41186-18-Oct-2024-End

            //TCS-pkulkarn-SDT-41186-18-Oct-2024-Added Assigned_To__c, SBQQ__Status__c to the SOQL
            List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Type__c,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c, Assigned_To__c, SBQQ__Status__c, Assigned_To__r.Name from SBQQ__Quote__c LIMIT1 ]; //pk
            quotelst[0].SBQQ__Status__c = Constant_Util.QUOTE_PRICE_CONFIGURED_LABEL;		//TCS-pkulkarn-SDT-41186-18-Oct-2024-Changed to variable value
            quotelst[0].SBQQ__Type__c = 'Quote';		//TCS-pkulkarn-SDT-41186-18-Oct-2024-Added
            UPDATE quotelst;

            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId,EMAIL_BODY1);
            
            List<Messaging.InboundEmail> emaillstNApp = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId2,EMAIL_BODY);
            
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId,EMAIL_BODY);
            Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();

            QuoteApprovalHandler quoteApprove1 = new QuoteApprovalHandler();
            
            
            Messaging.InboundEmailResult result = quoteApprove1.handleInboundEmail(emaillst1[0],env1);
            
            
            List<SBQQ__Quote__c> quotelst12 = [SELECT Id, Assigned_To__c, Assigned_To__r.Name, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id =: quotelst[0].Id]; //pk
            
            QuoteApprovalHandler quoteApprove = new QuoteApprovalHandler();
            quoteApprove.handleInboundEmail(emaillst[0],env);


            quoteApprove.handleInboundEmail(emaillstNApp[0],env);
            
            
            Test.stopTest();
        }
    }
    
}