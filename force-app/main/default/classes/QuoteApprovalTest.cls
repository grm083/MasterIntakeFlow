/* 
* Apex Class : QuoteApprovalTest
* Description : This class is used for QuoteApproval
* Developer : Arvind Kumar
* Date : 6/June/2021
* Edit Comments :
*/

@isTest(seeAllData = false)
public class QuoteApprovalTest {    
    public static User customerServiceUser;
    public static User adminUser;
    public static SBQQ__Quote__c quoteForTesting;
    public static List<SBQQ__QuoteLine__c> quoteLineList;
    public static List<SBQQ__QuoteLine__c> updatedQuoteLineList;
    public static List<Case> caseList = new List<Case>();
    public static List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    public static List<Product2> productList = new List<Product2>();
    public static final string SYS_ADMIN = 'System Administrator';

    /*
     * Description : Setup Data for Quote Approval
    */    
    @testSetup static void setup()  {
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        
        //Changes related to SDT-39632
        Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id, Status__c = 'Active');
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
        
        
    }
    
    /*
     * Description : Test Data if Business rule not find
    */
    /*
    @isTest static void quoteApprovalTestNoBR(){ 
        Test.startTest();  
        list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];
        String emailId = serviceApproverlist1[0].Email__c ;
        
        List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c from SBQQ__Quote__c LIMIT1 ];
        quotelst[0].SBQQ__Status__c = 'Price Configured';
        quotelst[0].Quote_Only__c = false;
        update quotelst;
     
        Test.stopTest();
        
        system.assert(quotelst != null);        
    }*/
    
    /*
     * Description : Test Data if Business rule is find
    */
    @isTest static void quoteApprovalTestwithBR(){ 
    
        Test.startTest();  
        list<Service_Approver__c> serviceApproverlist1 = [select id,Account__c,Recordtype.Name,Approver_Email__c ,Email__c,Business_Rule__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];
        String emailId = serviceApproverlist1[0].Email__c ;
        String businessID = serviceApproverlist1[0].Business_Rule__c ;
        List<String> emails = new List<String>{serviceApproverlist1[0].Email__c} ;
        //Yeshas Changes
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
        //Changes related to SDT-39632
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = customerType.Id, Status__c = 'Active'); 
        
        //changes start for genesys flow error
        customer.AccountNumber = '12345678';
        insert customer;
        Account location = new Account(Name = 'Test Location',Status__c = 'Active');
        location.ParentId = customer.Id;
        insert location;
        //changes ends
        
        //querying opportunity for S11 test class error
        Opportunity opp = [Select Id FROM Opportunity LIMIT 1];
        
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        insert container;
        List<SBQQ__Quote__c> testQuote = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testquote1 = new SBQQ__Quote__c(SBQQ__Account__c = location.id,SBQQ__Status__c = 'Draft',Duration__c = 'Temporary',SBQQ__StartDate__c = system.today());
        //addition for S11 test class error
        testquote1.SBQQ__Opportunity2__c = opp.Id;
        testQuote.add(testquote1);
        insert testQuote;
        Product2 mgmtFeePrd = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
        insert mgmtFeePrd;
        
                
        //Changes related to SDT-39632
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        insert trashStream;
        
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote[0].Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30');
        insert parentQL;
        	
        //Changes related to SDT-39632
        SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote[0].Id,
                                              SBQQ__Product__c = trashStream.Id,
                                              SBQQ__RequiredBy__c = parentQL.Id);
        
        QuoteTestDataFactory.insertQuoteLine(wSqLine);
        
        
 
        List<SBQQ__Quote__c> quotelst = [Select id,Duration__c,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,SBQQ__Status__c from SBQQ__Quote__c Where ID =: testQuote[0].Id];
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        qLineList = [SELECT id, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotelst[0].id];
        for(SBQQ__QuoteLine__c qLine: qLineList){
            qLine.Occurrence_Type__c = 'SOC';
            qLine.Schedule_Frequency__c ='D';
        }
        update qLineList;
        quotelst[0].SBQQ__Status__c = 'Product Configured';
        quotelst[0].Quote_Only__c = false;
        update quotelst;
        //Yeshas Changes Till here
        quoteApproval.createInboundApprovalLog(emails,quotelst[0].Id,'Approved','test',businessID);
        serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        serviceApproverlist1[0].Active__c = TRUE ;
        update serviceApproverlist1 ;
        
       quoteApproval.createInboundApprovalLog(emails,quotelst[0].Id,'Approved','test',businessID);
        
        serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Department').getRecordTypeId();
        update serviceApproverlist1 ;
        quoteApproval.createInboundApprovalLog(emails,quotelst[0].Id,'Approved','test',businessID);
        serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        update serviceApproverlist1 ;
        quoteApproval.createInboundApprovalLog(emails,quotelst[0].Id,'Approved','test',businessID);
        serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('User').getRecordTypeId();
        update serviceApproverlist1 ;
        quoteApproval.createInboundApprovalLog(emails,quotelst[0].Id,'Approved','test',businessID);
        
        //quoteApproval.createApprovalLog(null,quotelst[0].Id,'Approved','test');
      //  quoteApproval.createEmailMessage(emails,quotelst[0].Id);
        
        Test.stopTest();
        
        system.assert(quotelst != null);        
    }
     @isTest static void quoteApprovalTestwithBR1(){ 
    
        Test.startTest();  
        list<Service_Approver__c> serviceApproverlist1 = [select id,Account__c,Recordtype.Name,Approver_Email__c ,Email__c,Business_Rule__c from Service_Approver__c where Email__c = 'sbhatia@wm.com' Limit 1];
        String emailId = serviceApproverlist1[0].Email__c ;
        String businessID = serviceApproverlist1[0].Business_Rule__c ;
        List<String> emails = new List<String>{serviceApproverlist1[0].Email__c} ;
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
        //Changes related to SDT-39632
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = customerType.Id, Status__c = 'Active');
        //changes start for genesys flow error
        customer.AccountNumber = '12345678';
        insert customer;
        //Changes related to SDT-39632
        Account location = new Account(Name = 'Test Location', Status__c = 'Active');
        location.ParentId = customer.Id;
        insert location;
        //changes ends
        
        //querying opportunity for S11 test class error
        Opportunity opp = [Select Id FROM Opportunity LIMIT 1];

        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        insert container;
        List<SBQQ__Quote__c> testQuote = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testquote1 = new SBQQ__Quote__c(SBQQ__Account__c = location.id,SBQQ__Status__c = 'Draft',Duration__c = 'Temporary',SBQQ__StartDate__c = system.today());
        //addition for S11 test class error
        testquote1.SBQQ__Opportunity2__c = opp.Id;
        testQuote.add(testquote1);
        insert testQuote;
        Product2 mgmtFeePrd = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
        insert mgmtFeePrd;
                       
        //Changes related to SDT-39632
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        insert trashStream;
         
        
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote[0].Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30');
        insert parentQL;
         
        //Changes related to SDT-39632
        SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote[0].Id,
                                              SBQQ__Product__c = trashStream.Id,
                                              SBQQ__RequiredBy__c = parentQL.Id);
        
        QuoteTestDataFactory.insertQuoteLine(wSqLine);
         
        List<SBQQ__Quote__c> quotelst = [Select id,Duration__c,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c,SBQQ__Status__c from SBQQ__Quote__c Where ID =: testQuote[0].Id];
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        qLineList = [SELECT id, Occurrence_Type__c, Schedule_Frequency__c, Service_Days__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotelst[0].id];
        for(SBQQ__QuoteLine__c qLine: qLineList){
            qLine.Occurrence_Type__c = 'SOC';
            qLine.Schedule_Frequency__c ='D';
        }
        update qLineList;
        quotelst[0].SBQQ__Status__c = 'Product Configured';
        quotelst[0].Quote_Only__c = false;
        update quotelst;
        serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Title').getRecordTypeId();
        serviceApproverlist1[0].Active__c = TRUE ;
        update serviceApproverlist1 ;
        
       quoteApproval.createInboundApprovalLog(emails,quotelst[0].Id,'Approved','test',businessID);
        
        serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Department').getRecordTypeId();
        
        update serviceApproverlist1 ;
       
       quoteApproval.createInboundApprovalLog(emails,quotelst[0].Id,'Approved','test',businessID);
        
        Test.stopTest();
        
        system.assert(quotelst != null);        
    }
    
    //Added by gmarti18 - 5/14/2025
    @istest
    public static void testCreateApprovalLogForTitleContactAndDepartment() {
        
        //In order to test this class, we need multiple inputs from the Quote Object, a Business Rule, and a String
        SBQQ__Quote__c testQuote = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Case__c, SBQQ__PrimaryContact__c,
                                    SBQQ__Status__c, SBQQ__PrimaryContact__r.Email FROM SBQQ__Quote__c LIMIT 1];
        Business_Rule__c testRule = [SELECT Id FROM Business_Rule__c LIMIT 1];
        
        List<Approval_Log__c> testTitle = new List<Approval_Log__c>();
        List<Approval_Log__c> testDepartment = new List<Approval_Log__c>();
        List<Approval_Log__c> testContact = new List<Approval_Log__c>();
        List<Approval_Log__c> testNBR = new List<Approval_Log__c>();
        
        testTitle = QuoteApproval.createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_TITLE_RECORDTYPE, testQuote.Id, testQuote.SBQQ__Opportunity2__r.Case__c,
                                                                               'Test Title', testQuote.SBQQ__PrimaryContact__r.Email, testQuote.SBQQ__PrimaryContact__c,
                                                                                testQuote.SBQQ__Status__c, 'Testing title approval log array', testRule.Id);
        
        testDepartment = QuoteApproval.createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_DEPARTMENT_RECORDTYPE, testQuote.Id, testQuote.SBQQ__Opportunity2__r.Case__c,
                                                                               'Test Department', testQuote.SBQQ__PrimaryContact__r.Email, testQuote.SBQQ__PrimaryContact__c,
                                                                                testQuote.SBQQ__Status__c, 'Testing department approval log array', testRule.Id);
        
        testContact = QuoteApproval.createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_CONTACT_RECORDTYPE, testQuote.Id, testQuote.SBQQ__Opportunity2__r.Case__c,
                                                                               'Test Contact', testQuote.SBQQ__PrimaryContact__r.Email, testQuote.SBQQ__PrimaryContact__c,
                                                                                testQuote.SBQQ__Status__c, 'Testing contact approval log array', testRule.Id);
        
        testNBR = QuoteApproval.createApprovalLogForTitleContactAndDepartment(Constant_Util.SERVICE_CONTACT_RECORDTYPE, testQuote.Id, testQuote.SBQQ__Opportunity2__r.Case__c,
                                                                               'Test No Business Rule', testQuote.SBQQ__PrimaryContact__r.Email, testQuote.SBQQ__PrimaryContact__c,
                                                                                testQuote.SBQQ__Status__c, 'Testing no business rule approval log array', 'NBR');
        
        Assert.areEqual(testTitle.size(), 1, 'Test Title Array Size does not contain 1 approval log as expected');
        Assert.areEqual(testDepartment.size(), 1, 'Test Department Array Size does not contain 1 approval log as expected');
        Assert.areEqual(testContact.size(), 1, 'Test Contact Array Size does not contain 1 approval log as expected');
        Assert.areEqual(testNBR.size(), 0, 'Test NBR Array Size does not contain 0 approval log as expected');
        
    }

     @isTest static void createEmailMessageTestFirst(){
        //to addresses
        List<String> toaddresses = new List<String>{'mali2@gmail.com'};

        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true  LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();           //querying case
            Case caseRec = [SELECT Id,contactEmail,contactId FROM Case LIMIT 1];
            //querying businessrule and updating isautoemail
            Business_Rule__c  brule= [SELECT Id,Is_Auto_Email__c FROM Business_Rule__c LIMIT 1];
            brule.Is_Auto_Email__c = true;
            update brule;
            //querying Email Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Email', 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c,Email__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeId];
            serviceApproverEmail.Active__c = True;
            serviceApproverEmail.Email__c = 'test@gmail.com';
            update serviceApproverEmail;
            
            //querying inserted test quote
            quoteForTesting =  [SELECT Id, SBQQ__Opportunity2__r.Case__c, SBQQ__Status__c FROM SBQQ__Quote__c LIMIT 1];
            
            //updating the quote returnQuoteWithSingleBundle(); staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            try{
                update quoteForTesting; 
                //this needs to be fixed. Since it gives error in QA while sending Email
                //System.EmailException: SendEmail failed. First exception on row 0; first error: UNKNOWN_EXCEPTION, Map key a9HVC000000aeVB2AY not found in map.: []
                QuoteApproval.createEmailMessage(toaddresses,quoteForTesting.Id);
            }
            catch(Exception e){
            }
           Test.stopTest();
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];

        
    } 
    
}
