//Test class for scenarios 12, 13, 14, 15, 16, 17 and 18
/*
* @Name         : TestForQuoteApprovalBundleAuto
* @Author       : 
* @Date         : 
* @Vendor		: TCS
* @Description  : Test class for QuoteApproval for quote having single Business rule. 
* Testing for auto approval condition.
*/
@isTest(seeAllData = false)
public class QuoteApprovalBundleAutoTest {
    
    public static User customerServiceUser;
    public static User adminUser;
    public static SBQQ__Quote__c quoteForTesting;
	public static final string SYS_ADMIN = 'System Administrator';
    
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
        CSRUser.FirstName = 'testuser#9999';
        CSRUser.Bypass_Validation__c = false;
        CSRUser.Genesys_Enabled__c = false;
        Database.insert(CSRUser);
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        System.runAs(CSRUser){
            //Test.startTest();  //SDT-33363
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
            caseForQuote.Origin = 'Email';
            caseForQuote.SuppliedEmail = 'testclass123@abc.com';
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
            
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteForTesting.Id,
                                                  SBQQ__Product__c = trashCategory.Id,
                                                  SBQQ__RequiredBy__c = quotelineForContainer.Id);
            insert wCqLine;
            
             Test.startTest(); // SDT-33363
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
	 * @MethodName    returnQuoteWithSingleBundle
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  This method will return the quote with a single bundle in 'Cost Configured' status.
	 */
    public static SBQQ__Quote__c returnQuoteWithSingleBundle() {
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999' LIMIT 1];
        
        System.runAs(customerServiceUser){
            
            //querying inserted test quote
            quoteForTesting =[SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c 
                              WHERE SBQQ__Status__c =:ConstantClass.FieldStatus_Draft];
            
            
            //updating the quote staus to Product Configured.
            quoteForTesting.SBQQ__Status__c = ConstantClass.FieldStatus_ProductConfigured;
            update quoteForTesting;
            
            //updating the quote staus to Cost Configured.
            quoteForTesting = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c 
                               FROM SBQQ__Quote__c WHERE SBQQ__Status__c=: ConstantClass.FieldStatus_ProductConfigured LIMIT 1];
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_CostConfigured;
            update quoteForTesting; 
            system.debug('quote inserted ' + quoteForTesting);
            
        } 
        return quoteForTesting;
        
    }
    
    /*
	 * @MethodName    autoApprovalForBRContact
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status moves to 'Approved' when the approver(Contact) 
	 * is same. 
	 */
   /* @isTest static void autoApprovalForBRContact(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE  AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying contact Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            Service_Approver__c serviceApproverContact = [Select Id, Active__c from Service_Approver__c 
                                                          Where RecordTypeId =: recordTypeId];
            serviceApproverContact.Active__c = True;
            update serviceApproverContact;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 
            system.debug('quote inserted ' + quoteForTesting);
            
            Test.stopTest();
            
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        system.debug('quote inserted ' + quoteForTesting);
        System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    } */
    
   /*
	 * @MethodName    autoApprovalForBREmail
	 * @Author        
	 * @Vendor		  TCS
	 * @descriptionChecking whether the quote status moves to 'Approved' when the approver(Email) 
	 * is same. 
	 */
     @isTest static void autoApprovalForBREmail(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            //TCS-pkulkarn-SDT-45080-19-Feb-2025-Added following line to resolve test class issue (SOQL 101)
            RecurrsiveTriggerHandler.bypassValidation = true;
            Test.startTest();
            //querying Email Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeId];
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            //Test.stopTest(); //SDT-33363

            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 

        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
	Test.stopTest();//SDT-33363     
        
    }  

	/*
	 * @MethodName - submitforApprovalForLocationBREmail
	 * @Author     - Anup Dey   
	 * @Vendor	   -  TCS
	 * @description-This method will check for the location specific BR, if Location Spcific BR is found with mismatch approval then this will
     *  update the Quote status to 'Submit for Approval' and quote will pick location BR before Account BR as Account BR as least priorty then location.
	 */
    @isTest static void submitforApprovalForLocationBREmail(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            

            //querying Email Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeId];
            serviceApproverEmail.Email__c ='abc@wm.com';
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;
            
            //querying inserted test quote
            Test.startTest();
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 

            Test.stopTest();
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c, SBQQ__Account__c, Business_Rule__r.LocationId__c, Business_Rule__r.AccountId__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        //System.assertEquals(quoteForTesting.SBQQ__Account__c, quoteForTesting.Business_Rule__r.LocationId__c);
    }  

	/*
	 * @MethodName - submitforApprovalForAccountBREmail
	 * @Author     - Anup Dey   
	 * @Vendor	   -  TCS
	 * @description-This method will check for the Account BR only, if no other matching BR found then system will update the Quote status
     *  to 'Submit for Approval' due to mimatch of approval and quote will pick account BR as no other BR were found.
	 */
    @isTest static void submitforApprovalForAccountBREmail(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            //TCS-pkulkarn-SDT-45080-19-Feb-2025-Added following line to resolve test class issue (SOQL 101)
            RecurrsiveTriggerHandler.bypassValidation = true;
            Test.startTest();

            // Updating Location Id to NULL sot this will become Account BR
            Business_Rule__c businessRuleForApproval = [Select Id, locationid__c from Business_Rule__c Limit 1];
            businessRuleForApproval.locationid__c = null;
            update businessRuleForApproval;

            //querying Email Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeId];
            serviceApproverEmail.Email__c ='abc@wm.com';
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 

            Test.stopTest();
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c, SBQQ__Account__c, SBQQ__Account__r.Parent.Id, Business_Rule__r.LocationId__c, Business_Rule__r.AccountId__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        //System.assertEquals(quoteForTesting.SBQQ__Account__r.Parent.Id, quoteForTesting.Business_Rule__r.AccountId__c);
        //System.assertEquals(quoteForTesting.Business_Rule__r.LocationId__c, null);
    }
    
    /*
	 * @MethodName    autoApprovalForBRTitle
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status moves to 'Approved' when the approver(Title) 
	 * is same. 
	 */
  /*  @isTest static void autoApprovalForBRTitle(){ 
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying Title Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Title, 'Service_Approver__c');
            Service_Approver__c serviceApproverTitle = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeId];
            serviceApproverTitle.Active__c = True;
            update serviceApproverTitle;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update  quoteForTesting; 

            Test.stopTest();
        }
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);
        
    } */
    
    /*
	 * @MethodName    autoApprovalForBRDepartment
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status moves to 'Approved' when the approver(Department) 
	 * is same. 
	 */
 /*   @isTest static void autoApprovalForBRDepartment(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying Department Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Department, 'Service_Approver__c');
            Service_Approver__c serviceApproverDepartment = [Select Id, Active__c from Service_Approver__c 
                                                             Where RecordTypeId =: recordTypeId];
            serviceApproverDepartment.Active__c = True;
            update serviceApproverDepartment;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle(); 
            
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update  quoteForTesting; 

            Test.stopTest();
        }
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);
        
    } */
    
     /*
	 * @MethodName    autoApprovalForBRUser
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status moves to 'Approved' when the approver(User) 
	 * is same. 
	 */
  /*  @isTest static void autoApprovalForBRUser(){
        
       
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying User Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_User, 'Service_Approver__c');
            Service_Approver__c serviceApproverUser = [Select Id, Active__c from Service_Approver__c 
                                                       Where RecordTypeId =: recordTypeId];
            serviceApproverUser.Active__c = True;
            update serviceApproverUser;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle(); 
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update  quoteForTesting; 

            Test.stopTest();
        }
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);
        
    } */
    
     /*
	 * @MethodName    autoApprovalForDifferentApproversInactiveSA
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status moves to 'Approved' when the approvers are different and inactive. 
	 */
  /*  @isTest static void autoApprovalForDifferentApproversInactiveSA(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 
            
            Test.stopTest();
 
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    } */
    
     /*
	 * @MethodName    autoApprovalForDifferentApproverInactiveBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status moves to 'Approved' when the approvers are different 
	 * and business rule is inactive. 
	 */
   /* @isTest static void autoApprovalForDifferentApproverInactiveBR(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying contact Service Approver
            Id recordTypeIdSA = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            Service_Approver__c serviceApproverContact = [Select Id, Active__c from Service_Approver__c 
                                                          Where RecordTypeId =: recordTypeIdSA];
            serviceApproverContact.Active__c = True;
            update serviceApproverContact;
            
            //querying business rule
            Id recordTypeIdBR = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Approval, 'Business_Rule__c');
            Business_Rule__c businessRuleForApproval=[Select Id, Active__c from Business_Rule__c 
                                                      Where RecordTypeId =: recordTypeIdBR];
            businessRuleForApproval.Active__c = False;
            update businessRuleForApproval;
            
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 
            
            Test.stopTest();
            
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    } */
    
     /*
	 * @MethodName    autoApprovalApprovalLogsUpdation
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the approval logs are created with the correct quote status.
	 */
   /* @isTest static void autoApprovalApprovalLogsUpdation(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying Department Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Department', 'Service_Approver__c');
            Service_Approver__c serviceApproverDepartment = [Select Id, Active__c from Service_Approver__c 
                                                             Where RecordTypeId =: recordTypeId];
            serviceApproverDepartment.Active__c = True;
            update serviceApproverDepartment;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle(); 
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update  quoteForTesting; 
            
            Test.stopTest();
        }
        
        //Approval log
        List<Approval_log__c> approvalLogList = [Select Id, Status__c, CaseId__c, Quote__c, Quote__r.Id from Approval_Log__c 
                                                 Where Quote__c =:quoteForTesting.Id ];
        System.assertEquals(ConstantClass.FieldStatus_Approved, approvalLogList[0].Status__c);
        
    } */
 
}