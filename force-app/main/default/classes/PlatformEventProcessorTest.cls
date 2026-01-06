/*
@vendor			- TCS
@owner			- Toshender Kumar
@Description	- Test class to check the execution of Platform event 
*/
@isTest(seealldata=false)
public class PlatformEventProcessorTest {
    public static User customerServiceUser;
	public static final string SYS_ADMIN = 'System Administrator';
    
    @testSetup static void setup() {
	/*
        Set<String> permissionsetNames = new Set<String>{'Customer_Service_Reporting_User','Governance_Team','Merge_Access_for_Non_Admin_Users',
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
        //System.debug(customerServiceUser);
		*/
		Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User CSRUser = TestDataFactory.createUser(adminProfile);
        Database.insert(CSRUser);
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        System.runAs(CSRUser){
             //Test.startTest(); //SDT-33363
            //create parent account
            Account parentAccount = QuoteTestDataFactory.createParentAccountRecord('Test Parent Account', '10', ConstantClass.RecordType_Client, CSRUser);
            QuoteTestDataFactory.insertAccount(parentAccount);
            
            //create location account
            Account locationAccount = QuoteTestDataFactory.createLocationAccount('location account', parentAccount.Id, CSRUser);
            QuoteTestDataFactory.insertAccount(locationAccount);
            
            //Create vendor account 
            Id vendorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantClass.RecordType_Vendor).getRecordTypeId();
            Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorRecordtypeId,
                                               Status__c = ConstantClass.FieldStatus_Active, AccountNumber = '8'); 
            QuoteTestDataFactory.insertAccount(parentVendor);
            
            //create title for contact
            Account_Title__c titleOfQuoteContact = QuoteTestDataFactory.createAccountTitle('Not Manager',parentAccount);
            QuoteTestDataFactory.insertAccountTitle(titleOfQuoteContact);
            
            //create department for contact
            Department__c quoteContactDept = QuoteTestDataFactory.createDepartment('department for quotecontact',parentAccount);
            QuoteTestDataFactory.insertDepartment(quoteContactDept);
            
            //creating contact
            Contact quoteContact = QuoteTestDataFactory.createContactRecord('Quote contact', parentAccount.Id, CSRUser);
            quoteContact.Email = 'testclass123@abc.com';
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
            QuoteTestDataFactory.insertProducts(productList);
            
            //creating Opportunity
            Opportunity opp = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 'OpportunityForCase', caseForQuote.Id, ConstantClass.FieldSubType_Permanent, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(opp);
            
            //creating Business rule
            Business_Rule__c businessRuleForApproval = QuoteTestDataFactory.createBusinessRule(parentAccount, locationAccount, ConstantClass.RecordType_Approval);
            QuoteTestDataFactory.insertBusinessRule(businessRuleForApproval);
            
            //create quote
            SBQQ__Quote__c quoteForTesting = QuoteTestDataFactory.createQuoteRecords(opp, locationAccount, quoteContact);
            quoteForTesting.SBQQ__StartDate__c= system.today();
            List<SBQQ__Quote__c> quoteListForTesting = new List<SBQQ__Quote__c>();
            quoteListForTesting.add(quoteForTesting);
            QuoteTestDataFactory.insertQuotes(quoteListForTesting);
            system.debug('quote inserted ' + quoteListForTesting[0]);
            
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
            
            Test.startTest(); //SDT-33363
            //create service approver
            Service_Approver__c serviceApproverContact = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Contact);
            serviceApproverContact.Active__c = false;
            serviceApproverContact.Approver_Contact__c = quoteContact.Id;
            
            Service_Approver__c serviceApproverEmail = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Email);
            serviceApproverEmail.Active__c = false;
            serviceApproverEmail.Email__c = quoteContact.Email;
            
            Service_Approver__c serviceApproverTitle = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Title);
            serviceApproverTitle.Active__c = false;
            serviceApproverTitle.Title__c = titleOfQuoteContact.Id;
            
            Service_Approver__c serviceApproverDepartment = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Department);
            serviceApproverDepartment.Active__c = false;
            serviceApproverDepartment.Department__c = quoteContactDept.Id; 
            
            Service_Approver__c serviceApproverUser = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_User);
            serviceApproverUser.User__c = CSRUser.Id;
            serviceApproverUser.Active__c = false;
            
            QuoteTestDataFactory.insertserviceApprover(serviceApproverContact); 
            QuoteTestDataFactory.insertserviceApprover(serviceApproverEmail);
            QuoteTestDataFactory.insertserviceApprover(serviceApproverTitle);
            QuoteTestDataFactory.insertserviceApprover(serviceApproverDepartment);
            QuoteTestDataFactory.insertserviceApprover(serviceApproverUser);
            
            test.stopTest();
            
        }
    }    
    
/*
    @vendor			- TCS
    @owner			- Toshender Kumar
    @Description	- Test method Raises the STPProcess Platform event with Price only check as false 
*/
    @istest  static void testForRaisePlatformEventForSTPProcess(){
        
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN  AND IsActive = true LIMIT 1];
        
        System.runAs(customerServiceUser){
            Test.startTest();
            
            Map<ID, SBQQ__Quote__c> mapQuotes = new Map<ID, SBQQ__Quote__c>([SELECT Id from SBQQ__Quote__c]);
            
            PlatformEventProcessor.RaiseSTPProcessEventPE(mapQuotes.keySet(),false);
            
            Test.stopTest();  
        }
    }
    
/*
    @vendor			- TCS
    @owner			- Toshender Kumar
    @Description	- Test method Raises the STPProcess Platform event with Price only check as true
*/
    @istest  static void testForRaisePlatformEventForSTPProcess_PriceOnly(){
        
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
        
        System.runAs(customerServiceUser){
            Test.startTest();
            
            Map<ID, SBQQ__Quote__c> mapQuotes = new Map<ID, SBQQ__Quote__c>([SELECT Id from SBQQ__Quote__c]);
            
            PlatformEventProcessor.RaiseSTPProcessEventPE(mapQuotes.keySet(),true);
            
            Test.stopTest();
        }
        
    }
    
    
    
/*
    @vendor			- TCS
    @owner			- Jatan Sharma
    @Description	- Test method Raises the CaseToquoteEvent Platform event
*/
    @istest  static void testForRaiseCaseToquoteEventPE(){
        
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
        
        System.runAs(customerServiceUser){
            Test.startTest();
            
            Map<String,sobject> PayLoadData =  new Map<String,sobject>();
            List<map<String,sobject>> PayLoadList = new List<map<String,sobject>>();
            case caseObj = [SELECT Id from Case];
          	PayLoadData.put(caseObj.Id,caseObj);
            PayLoadList.add(PayLoadData);
            PlatformEventProcessor.RaiseCaseToquoteEventPE('CaseUpdate',PayLoadList);
            
            Test.stopTest();
        }
        
    }
    
    
}