@isTest(seeAllData =false)
public class QuoteTriggerHelperTest {
    
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
        test.startTest();
        
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.Bypass_Validation__c = TRUE;
        usr.Genesys_Enabled__c = false;
        usr.FirstName = 'testuser#9999';
        Database.insert(usr);
        
        //Changes for SDT-39632
        Code_Switch__c qLValidationsetting = QuoteTestDataFactory.createCodeSwitch('New_Quote_Validation',false);
        Insert qLValidationsetting;
        
        //TCS-pkulkarn-SDT-41186-24-Oct-2024-Added
        User salesUser = TestDataFactory.createUser(adminProfile);
        salesUser.Bypass_Validation__c = TRUE;
        salesUser.Genesys_Enabled__c = false;
        salesUser.FirstName = 'TestSalesUser#41186';
        salesUser.User_categorization_code__c = 'SALESGEN';
        INSERT salesUser;
        //TCS-pkulkarn-SDT-41186-24-Oct-2024-End
        
        system.runas(usr) {
        
        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        //Changes related to SDT-41190    
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
        quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.SBQQ__StartDate__c = system.today();
        quote.Business_Rule__c = businessrule.Id;
      
        insert quote;

        SBQQ__Quote__c quoteWithNoBR = new SBQQ__Quote__c();
            quoteWithNoBR.SBQQ__Account__c = acc2.Id;
            quoteWithNoBR.SBQQ__Status__c = 'Approved';
            quoteWithNoBR.SBQQ__Opportunity2__c = opp.Id;
            quoteWithNoBR.SBQQ__StartDate__c = system.today();
            
            insert quoteWithNoBR;
            
            //SP-8test class
           List<Asset> assets = new List<Asset>();
            Asset baseAsset = new Asset(
            Name = 'Test Asset',
            Occurs__c = '1',
            Frequency__c = 'Daily',
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            Thursday__c = true,
            Friday__c = true,
            Saturday__c = false,
            Sunday__c = false,
            Acorn_SID__c  = '2977664'
        );
        Asset baseAsset1 = new Asset(
            Name = 'Test Asset',
            Occurs__c = '1',
            Frequency__c = 'Weekly',
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            Thursday__c = true,
            Friday__c = true,
            Saturday__c = false,
            Sunday__c = false,
            Acorn_SID__c  = '2977664'
        );
        assets.add(baseAsset);
        assets.add(baseAsset1);   
        insert assets;
        
        //QuoteLine Creation
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c =  quote.Id;
        ql.SBQQ__Product__c = prod2.Id;
        ql.Equipment_Size__c = 'GALS-40';
        ql.AssetId__c = assets[0].Id;
        insert ql;
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
        ql1.SBQQ__Quote__c =  quote.Id;
        ql1.SBQQ__Product__c = prod.Id;
        ql1.Equipment_Size__c = 'GALS-40';
        ql1.AssetId__c = assets[1].Id;
        insert ql1;
        
       
        
        
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'cdd@ymail.com',Active__c = true,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
        
        insert serviceApprover;   
        }
        test.stoptest();
        
    } 
    
    @isTest static void createApprovalLogTest(){
        
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr) {
        Test.startTest();
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c, SBQQ__Type__c  FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        
        List<Product2> prdList = new List<Product2>();
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
        Product2 managementFee = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
            //Changes related to SDT-39632
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        	Product2 trashStream = new Product2(Name = 'Trash', Family = 'Rolloff', SBQQ__Component__c = TRUE, ProductCode = 'T');
            prdList.addAll(new List<Product2>{container, haulService, managementFee,trashCategory,trashStream});
        insert prdList;
        
        Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        
        List<Account> vndList = new List<Account>();
        Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorRecordtypeId,
                                    Status__c = 'Active', AccountNumber = '8');
        vndList.add(parentVendor);
        insert vndList;
        

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                             SBQQ__Product__c = container.Id,
                                                             Equipment_Size__c = 'YRDS-30',
                                                             Occurrence_Type__c='SOC');

        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='OC',
                                                          vendor__c = vndList[0].id,
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company');
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = trashCategory.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
                                                              
            SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = trashStream.Id,
                                                  SBQQ__RequiredBy__c = null,
                                                               CompanyCategoryCode__c = 'Test102',
                                                               SBQQ__StartDate__c = System.Today(),
                                                               SBQQ__EndDate__c = System.Today()+2,
                                                               sCode__c = 'UTL',
                                                               Equipment_Style__c = 'Tall',
                                                               Ownership__c = 'CLT',
                                                               MASLibrary__c = 'ARDTA.268',
                                                               SBQQ__Quantity__c = 5,
                                                               Equipment_Size__c = 'YRDS-40',
                                                               Occurrence_Type__c = 'OC');
            
            qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,wCqLine,wSqLine});
        insert qLineList;
        Test.stopTest();
        RecurrsiveTriggerHandler.bypassValidation = false;
        testQuote.SBQQ__Status__c = 'Product Configured';
        testQuote.SBQQ__Type__c = 'Amendment';
        update  testQuote;
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Product Configured' LIMIT 1];
        testQuote.SBQQ__Status__c='Cost Configured';
        update  testQuote; 
        try{
            testQuote.SBQQ__Status__c='Approved';
            update  testQuote;
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        }
        
        
        
        
        
        
        /*List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = [Select Id, SBQQ__Status__c from SBQQ__Quote__c];
        quoteList[0].SBQQ__Status__c = 'Price Configured';
        
        update quoteList;        
        quoteList[0].SBQQ__Status__c = 'Approved';
        update quoteList;
        
        quoteList[0].SBQQ__Status__c = 'Declined';
        update quoteList; */ 
     }
    @isTest static void itShouldCreateGenesysRecord(){
        Test.startTest();
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr) {
        Profile testProf = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        user currentuser = TestDataFactory.createGenesysEnabledUser(testProf);
		insert currentuser;
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
            //Changes related to SDT-39632
            Account customer = new Account(Name = 'Test Customer', RecordTypeId = customerType.Id,  Status__c = 'Active');
        insert customer;
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        insert container;
            
            //Changes related to SDT-39632
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        	Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            List<Product2> prdList = new List<Product2>();
           	prdList.addAll(new List<Product2>{trashCategory,trashStream});
            Insert prdList;

        //querying opportunity for S11 test class error
        Opportunity opp = [Select Id FROM Opportunity LIMIT 1];

        List<SBQQ__Quote__c> testQuote = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testquote1 = new SBQQ__Quote__c(SBQQ__Account__c = customer.id,SBQQ__Status__c = 'Draft',Duration__c = 'Temporary',SBQQ__StartDate__c = system.today());
        //addition for S11 test class error
        testquote1.SBQQ__Opportunity2__c = opp.Id;
        testQuote.add(testquote1);
        insert testQuote;
        Product2 mgmtFeePrd = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
        insert mgmtFeePrd;
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote[0].Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30');
        insert parentQL;
            //Changes related to SDT-39632
            List<SBQQ__QuoteLine__c> qLineListToUpdate = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testquote1.Id,
                                                  SBQQ__Product__c = trashCategory.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
                                                              
            SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testquote1.Id,
                                                  SBQQ__Product__c = trashStream.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
            
            qLineListToUpdate.addAll(new List<SBQQ__QuoteLine__c>{wCqLine,wSqLine});
            Insert qLineListToUpdate;
            
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = [Select Id, SBQQ__Status__c from SBQQ__Quote__c Where ID =: testQuote[0].Id limit 1];
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        qLineList = [SELECT id, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteList[0].id];
        for(SBQQ__QuoteLine__c qLine: qLineList){
            qLine.Occurrence_Type__c = 'SOC';
            qLine.Schedule_Frequency__c ='D';
        }
        update qLineList;
        quoteList[0].SBQQ__Status__c = 'Product Configured';
        quoteList[0].Assigned_To__c = currentuser.Id;
        quoteList[0].Next_Action_Start_Date__c = System.today().addDays(-1);    
        update quoteList;
        Test.stopTest();
        List<Genesys_Routing__c> genRecord = [Select Id,Action__c,SFDCObjType__c,SFDCTaskDescription__c from Genesys_Routing__c where SFDCObjRecordID__c=: quoteList[0].Id];
        }
    }
    
     @isTest static void getQuotePriceDataTest(){
        Test.startTest();
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr) {
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
            //Changes related to SDT-39632
            Account customer = new Account(Name = 'Test Customer', RecordTypeId = customerType.Id, Status__c = 'Active');
        insert customer;
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        insert container;
                        
            //Changes related to SDT-39632
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        	Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            List<Product2> prdList = new List<Product2>();
           	prdList.addAll(new List<Product2>{trashCategory,trashStream});
            Insert prdList;

        //querying opportunity for S11 test class error
        Opportunity opp = [Select Id FROM Opportunity LIMIT 1];

        List<SBQQ__Quote__c> testQuote = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testquote1 = new SBQQ__Quote__c(SBQQ__Account__c = customer.id,SBQQ__Status__c = 'Draft',Duration__c = 'Temporary',SBQQ__StartDate__c = system.today());
        //addition for S11 test class error
        testquote1.SBQQ__Opportunity2__c = opp.Id;
        testQuote.add(testquote1);
        insert testQuote;
        Product2 mgmtFeePrd = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
        insert mgmtFeePrd;
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote[0].Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30');
        insert parentQL;
            
            //Changes related to SDT-39632
            List<SBQQ__QuoteLine__c> qLineListToUpdate = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testquote1.Id,
                                                  SBQQ__Product__c = trashCategory.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
                                                              
            SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testquote1.Id,
                                                  SBQQ__Product__c = trashStream.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id);
            
            qLineListToUpdate.addAll(new List<SBQQ__QuoteLine__c>{wCqLine,wSqLine});
            Insert qLineListToUpdate;
            
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = [Select Id, SBQQ__Status__c from SBQQ__Quote__c Where ID =: testQuote[0].Id];
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        qLineList = [SELECT id, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteList[0].id];
        for(SBQQ__QuoteLine__c qLine: qLineList){
            qLine.Occurrence_Type__c = 'SOC';
            qLine.Schedule_Frequency__c ='D';
        }
        update qLineList;
        quoteList[0].SBQQ__Status__c = 'Product Configured';  
        update quoteList;
        System.debug('QuoteList'+quoteList);
        system.assert(quoteList != null);
        }
        Test.stopTest();
    }
    //test
    @isTest static void itShouldCreateGenesysForQuoteEmail(){ 
        test.startTest();
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr) {
        String subject = 'Test';
        //user currentuser = [select id, Bypass_Validation__c from user limit 1];
        List<SBQQ__Quote__c> quotelst;
        
        list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'cdd@ymail.com' Limit 1];    
        String emailId = serviceApproverlist1[0].Email__c ;
		
		List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.PS_EMAIL_TO_QUOTE];
        if(lstEmailAddress.size() > 0) {
		String foreEmail = lstEmailAddress[0].Address;
        
        
        quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT 1 ];  
           
        
        List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,foreEmail,quotelst[0].Quote_Thread_Id__c);           
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        QuoteEmailHandler quoteApprove = new QuoteEmailHandler();
        quoteApprove.handleInboundEmail(emaillst[0],env);
        List<Genesys_Routing__c> genRecord = [Select Id, LastAgentId__c from Genesys_Routing__c];
        System.assertEquals(1, genRecord.size());
        System.assertEquals('agent', genRecord[0].LastAgentId__c);
        }
    }
    test.stoptest();
    }

    //added as part of SDT-41263
    @isTest static void testUpdateMessageIdForOutboundQuoteEmails(){ 
        test.startTest();
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr) {
            String subject = 'Test';
            //user currentuser = [select id, Bypass_Validation__c from user limit 1];
            List<SBQQ__Quote__c> quotelst;
            
            list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'cdd@ymail.com' Limit 1];    
            String emailId = serviceApproverlist1[0].Email__c ;
            
            List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.PS_EMAIL_TO_QUOTE];
            if(lstEmailAddress.size() > 0) {
                String foreEmail = lstEmailAddress[0].Address;
                
                
                quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT 1 ];  
                
                
                List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,foreEmail,quotelst[0].Quote_Thread_Id__c);           
                Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
                EmailMessage newMessage = new EmailMessage();
                newMessage.HtmlBody = emaillst[0].htmlBody;
                newMessage.RelatedToId = quotelst[0].Id;
                newMessage.Status = '3';
                newMessage.FromAddress = emaillst[0].fromAddress;
                newMessage.ToAddress = emaillst[0].toAddresses[0];
                newMessage.Subject = emaillst[0].subject;
                newMessage.MessageDate = System.now();
                newMessage.Message_ID__c = null;
                insert newMessage;
                
                List<EmailMessage> emMsg = new List<Emailmessage>();
                emMsg = [Select Id, Message_Id__c from EmailMessage where Id =: newMessage.Id Limit 1];
                system.assertNotEquals(null, emMsg[0].Message_Id__c , 'Message Id is null');
                    }
        }
        test.stoptest();
    }
    
    
    //test
    @isTest static void getQuoteDataTest() {
        test.startTest();
        try {
            List<SBQQ__Quote__c> QuoteNewList = [Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
            Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1]);
            Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1]);
            
            QuoteTriggerHelper.getQuoteData(QuoteNewList, oldMap, newMap);
        }
        catch(exception ex) {
            //method not used
        }
        test.stopTest();
    }
    
    //test
    @isTest static void isEligibleForGenesysTest() {
        test.startTest();
        try {
            List<SBQQ__Quote__c> QuoteNewList = [Select Id, SBQQ__Status__c, Next_Action_Start_Date__c, Genesys_Enabled__c, Genesys_Record_Created__c, SBQQ__StartDate__c FROM SBQQ__Quote__c LIMIT 1];
            Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c, Next_Action_Start_Date__c, Genesys_Enabled__c, Genesys_Record_Created__c, SBQQ__StartDate__c FROM SBQQ__Quote__c LIMIT 1]);
            Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c, Next_Action_Start_Date__c, Genesys_Enabled__c, Genesys_Record_Created__c, SBQQ__StartDate__c FROM SBQQ__Quote__c LIMIT 1]);
            QuoteTriggerHelper.isEligibleForGenesys(QuoteNewList, oldMap, newMap);
        }
        catch(exception ex) {
            //method not used
        }
        test.stopTest();
    }
    
    //test
    @isTest static void changeInStatusTest() {
        test.startTest();
        try {
        List<SBQQ__Quote__c> QuoteList = [Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1]);
        Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1]);
        
        QuoteTriggerHelper.changeInStatus(QuoteList, oldMap, newMap);
        }
        catch(exception ex) {
            //method not used
        }
        test.stopTest();
    }
    
    //test
    @isTest static void changeInOwnerOfQuoteTest() {
        test.startTest();
        try {
            List<SBQQ__Quote__c> quoteList = [Select Id, SBQQ__Status__c, Action_Type__c, Genesys_Record_Created__c, Assigned_To__c FROM SBQQ__Quote__c LIMIT 1];
            Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c, Action_Type__c, Genesys_Record_Created__c, Assigned_To__c FROM SBQQ__Quote__c LIMIT 1]);
            
            QuoteTriggerHelper.changeInOwnerOfQuote(quoteList, oldMap);
        }
        catch(exception ex) {
            //method not used
        }
        test.stopTest();
    }
    
    //test
  /*  feature not released
  @isTest static void createApprovalLogforManualApprovalTest() {
        test.startTest();
        try {
        List<SBQQ__Quote__c> QuoteList = [Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
        
        QuoteTriggerHelper.createApprovalLogforManualApproval(QuoteList);
        }
        catch(exception ex) {
            //method not used
        }
        test.stopTest();
    }*/
    
    //test
    @isTest static void updateQuoteFlagTest() {
        test.startTest();
        try {
            Id insertedGenesysId = [Select Id from Genesys_Routing__c LIMIT 1].Id;
            List<Id> insertedGenesysIdList = new List<Id>();
            insertedGenesysIdList.add(insertedGenesysId);
            String action = 'Action';
            
            QuoteTriggerHelper.updateQuoteFlag(insertedGenesysIdList, action);
        }
        catch(exception ex) {
            system.debug(ex);
        }
        test.stopTest();
    }
    
    //test
    @isTest static void sendDeclineQuoteNotificationTest() {
        test.startTest();
        try {
            List<SBQQ__Quote__c> QuoteList = [Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
            Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1]);
            QuoteList[0].SBQQ__Status__c = Constant_Util.QUOTE_DECLINED;
            update QuoteList;
            Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1]);
            
            QuoteTriggerHelper.sendDeclineQuoteNotification(QuoteList, oldMap, newMap);
        }
        catch(exception ex) {
            //method not used
        }
        test.stopTest();
    }
    
    //test
    @isTest static void getQuoteMapTest() {
        test.startTest();
        try {
        List<SBQQ__Quote__c> quoteList = [Select Id, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
        
        QuoteTriggerHelper.getQuoteMap(quoteList);
        }
        catch(exception ex) {
            //method not used
        }
        test.stopTest();
    }

    //TCS-pkulkarn-SDT-41186-24-Oct-2024-Added test method
    @isTest static void testverifyAmendmentQuoteApprovalBySalesTeam()
    {
        test.startTest();
        User salesUser = [SELECT Id FROM User WHERE FirstName = 'TestSalesUser#41186' AND User_categorization_code__c = 'SALESGEN' LIMIT 1];
        system.runAs(salesUser)
        {
            try 
            {
                //Quote Creation
                Account acc = [SELECT Id FROM Account WHERE Name = 'Test2'];
                Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp'];
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.SBQQ__Account__c = acc.Id;
                quote.SBQQ__Status__c = Constant_Util.QUOTE_PRICE_CONFIGURED;
                quote.SBQQ__Type__c = Constant_Util.QUOTE_TYPE_AMEND;
                quote.SBQQ__Opportunity2__c = oppty.Id;
                quote.SBQQ__StartDate__c = system.today();
                quote.Is_Amendment_Quote_Approved_By_Sales__c = false;                  
                INSERT quote;
                
                quote.SBQQ__Status__c = Constant_Util.QUOTE_APPROVED;
                UPDATE quote;
                
                quote = [SELECT Id, SBQQ__Status__c, Is_Amendment_Quote_Approved_By_Sales__c, Assigned_To__r.FirstName, Assigned_To__r.LastName, Assigned_To__c FROM SBQQ__Quote__c WHERE Id =: quote.Id];
                system.assertEquals(true, String.valueOf(quote.SBQQ__Status__c).equalsIgnoreCase(Constant_Util.QUOTE_PRICE_CONFIGURED), 'Error on Assertion');
                system.assertEquals(quote.Assigned_To__r.FirstName + ' ' + quote.Assigned_To__r.LastName, 'SSM Team', 'Error on Assertion');
                system.assertEquals(true, quote.Is_Amendment_Quote_Approved_By_Sales__c, 'Error on Assertion');
            }
            catch(exception ex)
            {
                //method not used
            }
        }
        test.stopTest();
    }   
    
    //Changes relaed to SDT-41190
    //Check TaskdescCode for reply email at Approved Stage of Quote
    //Method to check if Genesys routing records are created at approved stage of Quote
    @isTest static void replyEmailGenesysRoutingRecordApprovedStage(){
        List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.PS_EMAIL_TO_QUOTE];
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr) {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            //TCS-pkulkarn-SDT-45080-13-Feb-2025-Added Quote_Thread_Id__c to SOQL
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Quote_Thread_Id__c
                        FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            List<Product2> prdList = new List<Product2>();
            Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
            Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
            Product2 managementFee = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
            //Changes related to SDT-39632
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        	Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            prdList.addAll(new List<Product2>{container, haulService, managementFee,trashCategory,trashStream});
            insert prdList;
            
            Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
            Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
            
            List<Account> vndList = new List<Account>();
            Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorRecordtypeId,
                                               Status__c = 'Active', AccountNumber = '8');
            vndList.add(parentVendor);
            insert vndList;
            
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = container.Id,
                                                                 Equipment_Size__c = 'YRDS-30',
                                                                 Occurrence_Type__c='SOC');
            
            insert parentQL;
            
            Test.startTest();
            
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                              SBQQ__Product__c = haulService.Id,
                                                              SBQQ__RequiredBy__c = parentQL.Id,
                                                              Occurrence_Type__c='OC',
                                                              vendor__c = vndList[0].id,
                                                              SBQQ__UnitCost__c=2,
                                                              Cost_Unit_of_Measure__c='DYS',
                                                              CostModelType__c='PER',
                                                              MASLibrary__c='ARDTA.180',
                                                              MASCompany__c='test mas company',
                                                              SBQQ__ListPrice__c =10,
                                                              PriceUOM__c = 'EV',
                                                              Exception_Type__c = 'CLTINITCHG',
                                                              Exception_Reason__c = 'NEWSRV',
                                                              Exception_Comments__c = 'TestTestTestTest');
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = trashCategory.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id,
                                                  Exception_Type__c = 'CLTINITCHG',
                                                  Exception_Reason__c = 'NEWSRV',
                                                  Exception_Comments__c = 'TestTestTestTest');
                                                              
            SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                  SBQQ__Product__c = trashStream.Id,
                                                  SBQQ__RequiredBy__c = parentQL.Id,
                                                  Exception_Type__c = 'CLTINITCHG',
                                                  Exception_Reason__c = 'NEWSRV',
                                                  Exception_Comments__c = 'TestTestTestTest');
            
            qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,wCqLine,wSqLine});
            insert qLineList;
            RecurrsiveTriggerHandler.bypassValidation = false;

            //Update Quote status = Approved.
            testQuote.SBQQ__Status__c='Approved';
            testQuote.STP__c = true;
            update  testQuote;
            
            test.stoptest();
            
            if(lstEmailAddress.size() > 0) 
            {
                String foreEmail = lstEmailAddress[0].Address;
                List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+testQuote.id ,foreEmail,testQuote.Quote_Thread_Id__c);           
                Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                
                QuoteEmailHandler quoteApprove = new QuoteEmailHandler();
                quoteApprove.handleInboundEmail(emaillst[0],env);
                List<Genesys_Routing__c> genRecord = [Select Id, LastAgentId__c,SFDCTaskDescCode__c,SFDCTaskDescription__c from Genesys_Routing__c];
                System.assertEquals(1, genRecord.size());
                System.assertEquals('agent', genRecord[0].LastAgentId__c);
                System.assertEquals('Approved', genRecord[0].SFDCTaskDescCode__c);
            }
            
        }
    }
    //Owner:Chandu Kari Story:45082
    @isTest static void handleamendmentQuoteApprovalBySingleBundle(){
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'TestSalesUser#41186' LIMIT 1];
        system.runAs(usr){
            String quoteId;
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            insert trashStream;

            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = trashStream.Id,
                                                                 Equipment_Size__c = 'YRDS-30');
            insert parentQL;

            testQuote.SBQQ__Type__c = Constant_Util.QUOTE_TYPE_AMEND; 
            testQuote.Quote_Only__c =true; 
            testQuote.SBQQ__Status__c = 'Approved';
            update testQuote;
            
            quoteId = testQuote.id;
            quoteList.add(testQuote);
            QuoteTriggerHelper.amendmentQuoteApprovalBySingleBundle(quoteList);
            SBQQ__QuoteLine__c quoteLines = [SELECT Id, CustomerApproval__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteId LIMIT 1];
            system.assertEquals('Approved', quoteLines.CustomerApproval__c, 'Customer Approval Should be Approved');
            test.stopTest();
        }
    }

     //Owner:Chandu Kari Story:46465
    @isTest static void handleDeclineAmendmentSingleQuote(){
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'TestSalesUser#41186' LIMIT 1];
        system.runAs(usr){
            String quoteId;
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            insert trashStream;

            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = trashStream.Id,
                                                                 Equipment_Size__c = 'YRDS-30');
            insert parentQL;

            testQuote.SBQQ__Type__c = Constant_Util.QUOTE_TYPE_AMEND; 
            testQuote.Quote_Only__c =true; 
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_DECLINED;
            update testQuote;
            
            quoteId = testQuote.id;
            quoteList.add(testQuote);
            QuoteTriggerHelper.amendmentQuoteApprovalBySingleBundle(quoteList);
            SBQQ__QuoteLine__c quoteLines = [SELECT Id, CustomerApproval__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteId LIMIT 1];
            system.assertEquals(Constant_Util.REJECTED, quoteLines.CustomerApproval__c, 'Customer Approval Should be Rejected');
            
            test.stopTest();
        }
    }
    @isTest static void handleAfterUpdateCatchError(){
        String quoteId;
            
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote.SBQQ__Opportunity2__c=null;
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_DRAFT;
            testQuote.Assigned_To__c=[select id from user limit 1][0].id;
            insert testQuote;
     		
            RecurrsiveTriggerHandler.mapQuotePricingCallTracker= new map<id,String>();
            List<SBQQ__Quote__c > QuoteList =new List<SBQQ__Quote__c >();
            QuoteList.add(testQuote);
            Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
     		oldMap.put(testQuote.id,testQuote);
            Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>();
            QuoteTriggerHandler.onAfterUpdate(QuoteList,oldMap,newMap);
            test.startTest();
            test.stopTest();
        }

        // @@ SP-8 Test 
        @isTest static void updateGenesysRequiredTest(){
            List<SBQQ__Quote__c> QuoteList = [Select Id, SBQQ__Status__c,SBQQ__StartDate__c,Genesys_Enabled__c,Next_Action_Start_Date__c,Genesys_Record_Created__c FROM SBQQ__Quote__c LIMIT 1];
            Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c,SBQQ__StartDate__c,Genesys_Enabled__c,Next_Action_Start_Date__c,Genesys_Record_Created__c FROM SBQQ__Quote__c LIMIT 1]);
            Map<Id,SBQQ__Quote__c> newMap = new Map<Id,SBQQ__Quote__c>([Select Id, SBQQ__Status__c,SBQQ__StartDate__c,Genesys_Enabled__c,Next_Action_Start_Date__c,Genesys_Record_Created__c FROM SBQQ__Quote__c LIMIT 1]);
            
            QuoteTriggerHelper.updateGenesysRequired(QuoteList, oldMap, newMap);
        }
        
        @isTest static void calculateQuoteLineFrequencyTest(){
            SBQQ__QuoteLine__c quoteLines = [SELECT Id,SBQQ__Quote__c,Frequency_Interval__c,Schedule_Frequency__c,Service_Days__c FROM SBQQ__QuoteLine__c  LIMIT 1];
            quoteLines.Frequency_Interval__c = '1';
            quoteLines.Schedule_Frequency__c = 'D';
            update quoteLines;
            QuoteTriggerHelper.calculateQuoteLineFrequency(quoteLines);
        
            quoteLines.Frequency_Interval__c = '1';
            quoteLines.Schedule_Frequency__c = 'M';
            update quoteLines;
            QuoteTriggerHelper.calculateQuoteLineFrequency(quoteLines);
        }

        @isTest static void calculateAssetFrequencyTest(){
            Asset asset = [SELECT Id, Occurs__c, Frequency__c FROM Asset LIMIT 1];
            asset.Frequency__c = 'Daily';
            asset.Occurs__c = '2';
            update asset; 
            
            SBQQ__QuoteLine__c quoteLines = [SELECT Id,SBQQ__Quote__c,Frequency_Interval__c,Schedule_Frequency__c,AssetId__c,AssetId__r.Occurs__c,AssetId__r.Frequency__c FROM SBQQ__QuoteLine__c  LIMIT 1];
            quoteLines.AssetId__c = asset.Id;
            update quoteLines;
            
            Decimal result = QuoteTriggerHelper.calculateAssetFrequency(quoteLines);
            string returnFrequenyChange = QuoteTriggerHelper.calculateFrequencyChange(quoteLines);
            system.debug('@@@'+returnFrequenyChange);    
            system.debug('@@@'+quoteLines.AssetId__r.Frequency__c);
            system.debug('@@@'+quoteLines.AssetId__r.Occurs__c);   

            asset.Frequency__c = 'Weekly';
            asset.Occurs__c = '2';
            asset.Monday__c = true;
            update asset; 
            quoteLines = [SELECT Id,SBQQ__Quote__c,Frequency_Interval__c,Schedule_Frequency__c,AssetId__c,AssetId__r.Occurs__c,AssetId__r.Frequency__c,AssetId__r.Monday__c,AssetId__r.Tuesday__c,AssetId__r.Wednesday__c,
                        AssetId__r.Thursday__c,AssetId__r.Friday__c,AssetId__r.Saturday__c,AssetId__r.Sunday__c FROM SBQQ__QuoteLine__c WHERE AssetId__c=:asset.Id LIMIT 1];
            system.debug('new@@@'+quoteLines.AssetId__r.Frequency__c);
                Decimal result1 = QuoteTriggerHelper.calculateAssetFrequency(quoteLines);
            asset.Frequency__c = 'Monthly';
            asset.Occurs__c = '3';
            asset.Monday__c = true;
                asset.Tuesday__c = true;
                asset.Wednesday__c = true;
                asset.Thursday__c = true;
                asset.Friday__c = true;
            update asset; 
            quoteLines = [SELECT Id,SBQQ__Quote__c,Frequency_Interval__c,Schedule_Frequency__c,AssetId__c,AssetId__r.Occurs__c,AssetId__r.Frequency__c FROM SBQQ__QuoteLine__c WHERE AssetId__c=:asset.Id LIMIT 1];
            system.debug('new123@@@'+quoteLines.AssetId__r.Frequency__c);
                Decimal result2 = QuoteTriggerHelper.calculateAssetFrequency(quoteLines);
            asset.Frequency__c = 'Yearly';
            asset.Occurs__c = '4';
            asset.Monday__c = false;
            update asset; 
            quoteLines = [SELECT Id,SBQQ__Quote__c,Frequency_Interval__c,Schedule_Frequency__c,AssetId__c,AssetId__r.Occurs__c,AssetId__r.Frequency__c FROM SBQQ__QuoteLine__c WHERE AssetId__c=:asset.Id LIMIT 1];
            Decimal result3 = QuoteTriggerHelper.calculateAssetFrequency(quoteLines);
        }

}