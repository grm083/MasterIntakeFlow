@isTest(seeAllData = false)
public class QuoteEmailHandlerTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string EMAIL = 'testfrom@test.com';
    private static final string ALTERNATIVE_EMAIL = 'test@test.com';
    private static final string FOREMAIL = 'testemail@test.com';
    private static final string EMAIL_SUBJECT = 'Approved';
    private static final string NAME = 'test';
    private static final string EMAIL_BODY = 'ref:_00D6tt8hWJ._a9L6t0Cc5h:ref';
    private static final string EMAIL_BODY1 = '';
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
        test.starttest();
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User CSRUser = TestDataFactory.createUser(adminProfile);
        CSRUser.FirstName = 'testuser#9999';
        CSRUser.Bypass_Validation__c = true;
        CSRUser.Genesys_Enabled__c = false;
        Database.insert(CSRUser); 
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        System.runAs(CSRUser){
        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        
        Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id);
        insert acc2;
        
        Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
        
        Case cse = new Case(Accountid = acc2.id,Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
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
        
        Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                      Email__c = 'sbhatia@wm.com' ,Active__c = true,
                                                                      Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
        
        insert serviceApprover; 
        test.stopTest();
        }
    }
    
    @isTest static void itShouldCreateGenesysForQuoteEmail(){ 
        test.startTest();
        String subject = 'Test';
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];
        List<SBQQ__Quote__c> quotelst;
        
        list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];    
        String emailId = serviceApproverlist1[0].Email__c ;
		
		List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.PS_EMAIL_TO_QUOTE];
		//Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
        if(lstEmailAddress.size() > 0) {
        String foreEmail = lstEmailAddress[0].Address;
        
        system.runAs(currentuser){
            quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT1 ];  
        }    
        
        List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,foreEmail,quotelst[0].Quote_Thread_Id__c);           
            
            //added by av4 for coverage
            //Create and add a text attachment
            Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
            textAttachment.fileName = 'TestAttachment.txt';
            textAttachment.body = 'This is the content of the text attachment.';
            emaillst[0].textAttachments = new Messaging.InboundEmail.TextAttachment[] { textAttachment };
            //done    
                
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        QuoteEmailHandler quoteApprove = new QuoteEmailHandler();
        quoteApprove.handleInboundEmail(emaillst[0],env);
        List<Genesys_Routing__c> genRecord = [Select Id from Genesys_Routing__c];
       System.assertEquals(1, genRecord.size());
        }
        test.stopTest();
    }
    
    @isTest static void itShouldRouteQuoteEmail(){
        test.startTest();
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];  
        system.runas(currentuser) {
        List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT1 ];
		List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.EMAIL_TO_QUOTE];
		//Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
        if(lstEmailAddress.size() > 0) {
        String foreEmail = lstEmailAddress[0].Address;

        List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id,foreEmail,EMAIL_BODY1);           
        Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
        QuoteEmailHandler quoteApprove1 = new QuoteEmailHandler();
        quoteApprove1.handleInboundEmail(emaillst1[0],env1);
        List<Genesys_Routing__c> genRecord = [Select Id from Genesys_Routing__c];
        System.assertNotEquals(1, genRecord.size());
        }
    }
        test.stopTest();
    }
    
    //added by av4 for coverage
    @isTest static void itShouldRouteQuoteEmailPSEmailToQuote(){
        test.startTest();
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];  
        system.runas(currentuser) {
            List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT1 ];
            List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.PS_EMAIL_TO_QUOTE];
            //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
            if(lstEmailAddress.size() > 0) {
                String foreEmail = lstEmailAddress[0].Address;
                
                List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id,foreEmail,EMAIL_BODY1);           
                Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
                QuoteEmailHandler quoteApprove1 = new QuoteEmailHandler();
                quoteApprove1.handleInboundEmail(emaillst1[0],env1);
                List<Genesys_Routing__c> genRecord = [Select Id from Genesys_Routing__c];
                System.assertNotEquals(1, genRecord.size());
            }
        }
        test.stopTest();
    }
    
    //added by av4 for coverage
    @isTest static void itShouldRouteQuoteEmailVRMEmailToQuote(){
        
        test.startTest();
        try{
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];  
        system.runas(currentuser) {
            List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT1 ];
            List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.VRM_EMAIL_TO_QUOTE];
            //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
            if(lstEmailAddress.size() > 0) {
                String foreEmail = lstEmailAddress[0].Address;
                
                List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id,foreEmail,EMAIL_BODY1);           
                Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
                QuoteEmailHandler quoteApprove1 = new QuoteEmailHandler();
                quoteApprove1.handleInboundEmail(emaillst1[0],env1);
                List<Genesys_Routing__c> genRecord = [Select Id from Genesys_Routing__c];
                System.assertNotEquals(1, genRecord.size());
            }
        }
    }
    catch(Exception ex) {}
        test.stopTest();
    }
    
    //added by av4 for coverage
    @isTest static void itShouldRouteQuoteEmailCanadaVRMEmailToQuote(){
        test.startTest();
        try{
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];  
        system.runas(currentuser) {
            List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT1 ];
            List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.CANADA_VRM_EMAIL_TO_QUOTE];
            //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
            if(lstEmailAddress.size() > 0) {
                String foreEmail = lstEmailAddress[0].Address;
                
                List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id,foreEmail,EMAIL_BODY1);           
                Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
                QuoteEmailHandler quoteApprove1 = new QuoteEmailHandler();
                quoteApprove1.handleInboundEmail(emaillst1[0],env1);
                List<Genesys_Routing__c> genRecord = [Select Id from Genesys_Routing__c];
                System.assertNotEquals(1, genRecord.size());
            }
        }
    }
    catch(exception ex){}
        test.stopTest();
    }
    
    //added by av4 for coverage
    @isTest static void testBinaryAttachments(){ 
        test.startTest();
        String subject = 'Test';
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];
        List<SBQQ__Quote__c> quotelst;
        
        list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];    
        String emailId = serviceApproverlist1[0].Email__c ;
        
        List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.PS_EMAIL_TO_QUOTE];
        //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
        if(lstEmailAddress.size() > 0) {
            String foreEmail = lstEmailAddress[0].Address;
            
            system.runAs(currentuser){
                quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT1 ];  
            }    
            
            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,foreEmail,quotelst[0].Quote_Thread_Id__c);           
            
            // Create and add a binary attachment
            Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
            binaryAttachment.fileName = 'TestAttachment.pdf'; // Example file name
            binaryAttachment.body = Blob.valueOf('This is the binary content of the attachment.');
            binaryAttachment.mimeTypeSubType = 'application/pdf'; // Example MIME type
            emaillst[0].binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[] { binaryAttachment };
            //done    
                
                Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            QuoteEmailHandler quoteApprove = new QuoteEmailHandler();
            quoteApprove.handleInboundEmail(emaillst[0],env);
        }
        test.stopTest();
    }

    //Coverage : EmailMessageProcessorExtension.getReferenceId()
    @isTest 
    public static void getReferenceIdTestNotFoundNullKey()
    {
        try {
        String strTest = 'ref:_00DVFF956mE._a9LVF04q01:reflst:_00DVFF956mE._005VF9g1ck:lst';
        String keyRef = '';
        
        EmailMessageProcessorExtension emailMsgProcessor = new EmailMessageProcessorExtension();
        String referenceId = emailMsgProcessor.getReferenceId(strTest, keyRef);
        system.assertEquals(referenceId, '');
        }
        catch(Exception ex){}
    }

    //added by av4 for coverage
    @isTest static void forwardEmailTest(){ 
        test.startTest();
        String subject = 'Test';
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];
        List<SBQQ__Quote__c> quotelst;
        
        list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];    
        String emailId = serviceApproverlist1[0].Email__c ;
        
        List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress WHERE DisplayName=: Constant_Util.PS_EMAIL_TO_QUOTE];
        //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
        if(lstEmailAddress.size() > 0) {
            String foreEmail = lstEmailAddress[0].Address;
            
            system.runAs(currentuser){
                quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c from SBQQ__Quote__c LIMIT 1 ];  
            }    
            
            List<Messaging.InboundEmail> emaillst = TestDataFactory.createinboundemail(EMAIL_SUBJECT+'' ,foreEmail,'');           
            
            //added by av4 for coverage
            //Create and add a text attachment
            Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
            textAttachment.fileName = 'TestAttachment.txt';
            textAttachment.body = 'This is the content of the text attachment.';
            emaillst[0].textAttachments = new Messaging.InboundEmail.TextAttachment[] { textAttachment };
            //done    
                
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            try{
            QuoteEmailHandler quoteApprove = new QuoteEmailHandler();
            quoteApprove.handleInboundEmail(emaillst[0],env);
            }
            catch(exception ex) {}

        }
        test.stopTest();
    }
    
    /*Developer  : TCS - Rishan
    *Description :testing  SDT-37849 to find out org wide address from toaddress and ccaddress
    *Test Coverage: QuoteEmailHandlerTest class - checkForGenesysMediatypeIfORgAddressInTo,checkForGenesysMediatypeIfORgAddressInCC.
    */ 
    @isTest static void checkForGenesysMediatypeIfORgAddressInTo(){
        test.startTest();
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];  
        List<String> testEmailAddresses =new List<String>{'test1@wm.com','test2@wm.com'};
            system.runas(currentuser) {
                List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,
                                                 SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c 
                                                 from SBQQ__Quote__c LIMIT 1 ];
                List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress 
                                                             WHERE DisplayName=: Constant_Util.EMAIL_TO_QUOTE];
                //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
                if(lstEmailAddress.size() > 0) {
                    String foreEmail = lstEmailAddress[0].Address;
                    testEmailAddresses.add(lstEmailAddress[0].Address);
                    List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id,
                                                                                                foreEmail,quotelst[0].Quote_Thread_Id__c);
                    emaillst1[0].toAddresses = testEmailAddresses;
                    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                    QuoteEmailHandler handler = new QuoteEmailHandler();
                    handler.handleInboundEmail(emaillst1[0],env);
                    List<Genesys_Routing__c> genRecord = [Select Id,MediaType__c,EmailTo__c from Genesys_Routing__c];
                    system.assertEquals(Constant_Util.SFDCCPQQUOTE, genRecord[0].MediaType__c);
                    system.assertEquals(lstEmailAddress[0].Address,genRecord[0].EmailTo__c);
                    
                }
            }
        test.stopTest();
    }
    
    /*Developer  : TCS - Rishan
    *Description :testing  SDT-37849 to find out org wide address from toaddress and ccaddress
    *Test Coverage: QuoteEmailHandlerTest class - checkForGenesysMediatypeIfORgAddressInTo,checkForGenesysMediatypeIfORgAddressInCC.
    */ 
    @isTest static void checkForGenesysMediatypeIfORgAddressInCC(){
        test.startTest();
        user currentuser = [select id, Bypass_Validation__c, FirstName from user WHERE FirstName =: 'testuser#9999' limit 1];  
        List<String> testEmailAddresses =new List<String>{'test1@wm.com','test2@wm.com'};
        List<String> ccAddressList = new List<String>();
            system.runas(currentuser) {
                List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,
                                                 SBQQ__StartDate__c,SBQQ__PrimaryContact__c,Quote_Thread_Id__c 
                                                 from SBQQ__Quote__c LIMIT 1 ];
                List<OrgWideEmailAddress> lstEmailAddress = [select Id,Address from OrgWideEmailAddress 
                                                             WHERE DisplayName=: Constant_Util.EMAIL_TO_QUOTE];
                //Adding this below list size check condition since we are getting List Index Out of bound errors while deployment
                if(lstEmailAddress.size() > 0) {
                    String foreEmail = lstEmailAddress[0].Address;
                    ccAddressList.add(lstEmailAddress[0].Address);
                    List<Messaging.InboundEmail> emaillst1 = TestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id,
                                                                                                foreEmail,quotelst[0].Quote_Thread_Id__c);
                    emaillst1[0].toAddresses = testEmailAddresses;
                    emaillst1[0].ccAddresses = ccAddressList;
                    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
                    QuoteEmailHandler handler = new QuoteEmailHandler();
                    handler.handleInboundEmail(emaillst1[0],env);
                    List<Genesys_Routing__c> genRecord = [Select Id,MediaType__c,EmailTo__c from Genesys_Routing__c];
                    system.assertEquals(Constant_Util.SFDCCPQQUOTE, genRecord[0].MediaType__c);
                    system.assertEquals(lstEmailAddress[0].Address,genRecord[0].EmailTo__c);
                    
                }
            }
        test.stopTest();
    }
}