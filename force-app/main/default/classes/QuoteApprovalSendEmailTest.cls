/*
* @Name         : QuoteApprovalSendEmailTest
* @Author       : 
* @Date         : 
* @Vendor		: TCS
* @Description  : Test class for QuoteApproval for testing email functionality. 
*/
@isTest(seeAllData = false)
public class QuoteApprovalSendEmailTest {    
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
       public static User customerServiceUser;
       public static User adminUser;
       public static SBQQ__Quote__c quoteForTesting;
      // private static final string MIXED = 'Mixed';
      
    
    /*
	 * @MethodName    setup
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  This method will be used to setup inital required data to test the methods.
	 */
	 @testSetup static void setup() {
	 /*Set<String> permissionsetNames = new Set<String>{'Customer_Service_Reporting_User','Governance_Team','Merge_Access_for_Non_Admin_Users',
                                                     'Price_Accessibility_Permission_Set','Pricing_Access', 'CPQ_Extended_License'};    
    List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
    
    
        //fetching Customer Service profile 
        Profile CustomerServieUser = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //creating a CSR user
        User CSRUser = TestDataFactory.createUser(CustomerServieUser);
        Insert CSRUser;
        //Assigning permissionset license
        insert new PermissionSetLicenseAssign(AssigneeId = CSRUser.Id, PermissionSetLicenseId= pslList[0].Id);
        //assigning permission sets
        QuoteTestDataFactory.assignPermissionSet(permissionsetNames, CSRUser);
        
        //System.debug(customerServiceUser);*/
		Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User CSRUser = TestDataFactory.createUser(adminProfile);
        Database.insert(CSRUser);
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
         
        System.runAs(CSRUser){
            
            Test.startTest();
            //create parent account
            Account parentAccount = QuoteTestDataFactory.createParentAccountRecord('Test Parent Account', '10', ConstantClass.RecordType_Client, customerServiceUser);
            QuoteTestDataFactory.insertAccount(parentAccount);
            System.debug(parentAccount);
            //create location account
            Account locationAccount = QuoteTestDataFactory.createLocationAccount('location account', parentAccount.Id, customerServiceUser);
            QuoteTestDataFactory.insertAccount(locationAccount);
            System.debug(locationAccount);
            //Create vendor account 
            Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.RecordType_Vendor).getRecordTypeId();
            Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorRecordtypeId,
                                               Status__c = ConstantClass.FieldStatus_Active, AccountNumber = '8'); 
            QuoteTestDataFactory.insertAccount(parentVendor);
            
            //create title for contact
            Account_Title__c titleForBusinessRule = QuoteTestDataFactory.createAccountTitle('Manager',parentAccount);
            Account_Title__c titleOfQuoteContact = QuoteTestDataFactory.createAccountTitle('Not Manager',parentAccount);
            
            QuoteTestDataFactory.insertAccountTitle(titleForBusinessRule);
            QuoteTestDataFactory.insertAccountTitle(titleOfQuoteContact);
            
            //create department for contact
            Department__c quoteContactDept = QuoteTestDataFactory.createDepartment('department for quotecontact',parentAccount);
            Department__c approverDepartment = QuoteTestDataFactory.createDepartment('department for businessrule',parentAccount);
            
            QuoteTestDataFactory.insertDepartment(quoteContactDept);
            QuoteTestDataFactory.insertDepartment(approverDepartment);
            
            //create contact for account
            Contact approverContact = QuoteTestDataFactory.createContactRecord('Approver contact', parentAccount.Id, customerServiceUser);
            approverContact.Email = 'mali2@wm.com';
            QuoteTestDataFactory.insertContact(approverContact);
            
            //Creating contacts
            Contact quoteContact = QuoteTestDataFactory.createContactRecord('Quote contact', parentAccount.Id, customerServiceUser);
            quoteContact.Account_Title__c = titleOfQuoteContact.Id;
            quoteContact.Account_Department__c = quoteContactDept.Id;
            QuoteTestDataFactory.insertContact(quoteContact);
            
            //creating case
            Case caseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,ConstantClass.FieldType_NewService,ConstantClass.FieldSubType_Permanent, 'Existing Location', parentAccount, quoteContact, locationAccount);
            List<Case> caseListForQuote = new List<Case>();
            caseListForQuote.add(caseForQuote);
            QuoteTestDataFactory.insertCases(caseListForQuote);

            //creating products
            List<Product2> productList = new List<Product2>();
            Product2 openTop = QuoteTestDataFactory.createProductRecord('Open Top', 'Rolloff', 'OT');
			openTop.ProductConfigurationType__c = 'Bundle';
            productList.add(openTop);
            Product2 haulService = QuoteTestDataFactory.createProductRecord('Haul', 'Services', 'H');
            productList.add(haulService);
            
            //Changes related to SDT-39632
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        	productList.add(trashCategory);
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            productList.add(trashStream);
            
            QuoteTestDataFactory.insertProducts(productList);
            
            //creating opportunity            
            Opportunity opp = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 'OpportunityForCase', caseForQuote.Id, ConstantClass.FieldSubType_Permanent, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(opp);
            
            //Creating Business rules
            Business_Rule__c businessRuleForApproval = QuoteTestDataFactory.createBusinessRule(parentAccount, locationAccount, ConstantClass.RecordType_Approval);
            businessRuleForApproval.Is_Auto_Email__c = TRUE;
            QuoteTestDataFactory.insertBusinessRule(businessRuleForApproval);
            
            //create quote
            List<SBQQ__Quote__c> quoteListForTesting = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quoteForTesting = QuoteTestDataFactory.createQuoteRecords(opp, locationAccount, quoteContact);
            quoteForTesting.Business_Rule__c = businessRuleForApproval.Id;
            quoteListForTesting.add(quoteForTesting);
            QuoteTestDataFactory.insertQuotes(quoteListForTesting);
            
            test.stopTest();
            
            //QuoteLine Creation
            //Bundle 1
            SBQQ__QuoteLine__c quotelineForContainer = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting,openTop,
                                                                                                   'TEMP',1.00,'CLT','YRDS-30',
                                                                                                   'OC','M','1','PER',34.00,'DYS',
                                                                                                   'PER',null,'DYS','Do Not Override','NBG');
            quotelineForContainer.SBQQ__Bundle__c = TRUE;
            quotelineForContainer.SBQQ__RequiredBy__c = null;
            QuoteTestDataFactory.insertQuoteLine(quotelineForContainer);
            
            SBQQ__QuoteLine__c quotelineForHaulService = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, haulService,'TEMP',1.00,'CLT',
                                                                                                     'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                     563.47,'DYS','Do Not Override','NBG');
            quotelineForHaulService.SBQQ__RequiredBy__c =  quotelineForContainer.Id;
            quotelineForHaulService.Vendor__c = parentVendor.Id;
            quotelineForHaulService.SBQQ__UnitCost__c = 2;
            quotelineForHaulService.CostModelType__c='PER';
            quotelineForHaulService.MASLibrary__c='ARDTA.180';
            quotelineForHaulService.MASCompany__c='test mas company'; 
            quotelineForHaulService.Cost_Unit_of_Measure__c= 'BNDL';
            QuoteTestDataFactory.insertQuoteLine(quotelineForHaulService);
            
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteForTesting.Id,
                                                  SBQQ__Product__c = trashCategory.Id,
                                                  SBQQ__RequiredBy__c = quotelineForContainer.Id);
                                                              
            SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteForTesting.Id,
                                                  SBQQ__Product__c = trashStream.Id,
                                                  SBQQ__RequiredBy__c = quotelineForContainer.Id);
            
            insert (new List<SBQQ__QuoteLine__c>{wCqLine,wSqLine});
            
            
            //create service approver
            List<Service_Approver__c> approverList = new List<Service_Approver__c>();
        
            Service_Approver__c serviceApproverContact = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Contact);
            serviceApproverContact.Email__c = 'mali2@wm.com';
            serviceApproverContact.Active__c = true;
            serviceApproverContact.Approver_Contact__c = approverContact.Id;
            serviceApproverContact.RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Contact').getRecordTypeId();

            Service_Approver__c serviceApproverEmail = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Email);
            serviceApproverEmail.Email__c= 'av4@wm.com';
            serviceApproverEmail.Active__c = true;
            serviceApproverEmail.RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();

            approverList.add(serviceApproverContact); 
            approverList.add(serviceApproverEmail); 
            insert approverList; 
          
            
        }
    }
    
     /*
	 * @MethodName    sendEmailTestApproved
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status moves to 'Approved' when the mail is received from the approver. 
	 * Also testing whether only a single approval log is created for the quote. 
	 */
       @isTest static void sendEmailTestApproved(){ 
        //String subject= Constant_Util.EMPTY_STRING;
        String subject = 'Test';
        user currentuser = [select id, Bypass_Validation__c from user where Profile.Name =: SYS_ADMIN and IsActive = True Limit 1];
       
           
        system.runAs(currentuser){

			list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'mali2@wm.com' Limit 1];
            list<Service_Approver__c> serviceApproverlist2 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'av4@wm.com' Limit 1];
            serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
            serviceApproverlist2[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
            String emailId = serviceApproverlist1[0].Email__c ;
            String emailId2 = serviceApproverlist2[0].Email__c ;
            
            List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c from SBQQ__Quote__c LIMIT1 ];
            quotelst[0].SBQQ__Status__c = 'Submit for Approval';
            update quotelst;
            
            List<Messaging.InboundEmail> emaillst = QuoteTestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId,EMAIL_BODY1);

            List<Messaging.InboundEmail> emaillstNApp = QuoteTestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId2,EMAIL_BODY);
            
            System.debug('###emaillst'+emaillst);
            System.debug('###emaillst'+emaillstNApp);
            System.debug('quotelst'+quotelst);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            Test.startTest();
            QuoteApprovalHandler quoteApprove = new QuoteApprovalHandler();
           	Messaging.InboundEmailResult result = quoteApprove.handleInboundEmail(emaillst[0],env); 
            
            QuoteApprovalHandler quoteApprove1 = new QuoteApprovalHandler();
           	Messaging.InboundEmailResult result1 = quoteApprove1.handleInboundEmail(emaillstNApp[0],env);
            Test.stopTest();
            
            //Approval log
            quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c from SBQQ__Quote__c LIMIT1 ];
            List<Approval_log__c> approvalLogList = [Select Id, Status__c, CaseId__c, Quote__c, Quote__r.Id from Approval_Log__c 
                                                     Where Quote__c =:quotelst[0].Id];
            
            system.assert(result != null);
            System.assertEquals(ConstantClass.FieldStatus_Approved, approvalLogList[0].Status__c);
            System.assertEquals(1, approvalLogList.size());
        }
   }
    
     /*
	 * @MethodName    sendEmailTestDeclined
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status doesnt move to 'Approved' when the mail is received from the approver.
	 * Also testing whether only a single approval log is created for the quote. 
	 */
    @isTest static void sendEmailTestDeclined(){ 
        //String subject= Constant_Util.EMPTY_STRING;
        String subject = 'Test';
        user currentuser = [select id, Bypass_Validation__c from user where Profile.Name =: SYS_ADMIN and IsActive = True Limit 1];
       
           
        system.runAs(currentuser){

			list<Service_Approver__c> serviceApproverlist1 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'mali2@wm.com' Limit 1];
            list<Service_Approver__c> serviceApproverlist2 = [select id,Approver_Email__c ,Email__c from Service_Approver__c where Email__c = 'av4@wm.com' Limit 1];
            serviceApproverlist1[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
            serviceApproverlist2[0].RecordtypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
            String emailId = serviceApproverlist1[0].Email__c ;
            String emailId2 = serviceApproverlist2[0].Email__c ;
            
            List<SBQQ__Quote__c> quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c from SBQQ__Quote__c LIMIT1 ];
            quotelst[0].SBQQ__Status__c = 'Submit for Approval';
            update quotelst;
            
            List<Messaging.InboundEmail> emaillst = QuoteTestDataFactory.createinboundemail(EMAIL_SUBJECT+Constant_Util.COLON+quotelst[0].id ,emailId,EMAIL_BODY1);

            List<Messaging.InboundEmail> emaillstNApp = QuoteTestDataFactory.createinboundemail(REJECTED+Constant_Util.COLON+quotelst[0].id ,emailId2,EMAIL_BODY);
            
            System.debug('###emaillst'+emaillst);
            System.debug('###emaillst'+emaillstNApp);
            System.debug('quotelst'+quotelst);
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
            Test.startTest();
            QuoteApprovalHandler quoteApprove1 = new QuoteApprovalHandler();
           	Messaging.InboundEmailResult result1 = quoteApprove1.handleInboundEmail(emaillstNApp[0],env);
            
            QuoteApprovalHandler quoteApprove = new QuoteApprovalHandler();
           	Messaging.InboundEmailResult result = quoteApprove.handleInboundEmail(emaillst[0],env); 
            Test.stopTest();
            
            //Approval log
            quotelst = [Select id,SBQQ__Opportunity2__c,SBQQ__Account__c,SBQQ__Primary__c,SBQQ__ExpirationDate__c,SBQQ__StartDate__c,SBQQ__PrimaryContact__c from SBQQ__Quote__c LIMIT1 ];
            List<Approval_log__c> approvalLogList = [Select Id, Status__c, CaseId__c, Quote__c, Quote__r.Id from Approval_Log__c 
                                                     Where Quote__c =:quotelst[0].Id];
            
            system.assert(result != null);
            System.assertNotEquals(ConstantClass.FieldStatus_Approved, approvalLogList[0].Status__c);
            System.assertEquals(1, approvalLogList.size());
        }
   }
}