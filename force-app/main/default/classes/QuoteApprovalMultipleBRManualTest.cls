//Test class for scenarios 28 - 36
/*
* @Name         : TestForQuoteApprovalMultipleBRManual
* @Author       : 
* @Date         : 
* @Vendor		: TCS
* @Description  : Test class for QuoteApproval for quote having two Business rules. 
* Testing for manual approval condition.
*/
@isTest(seealldata = false)
public class QuoteApprovalMultipleBRManualTest {
    
    public static User customerServiceUser;
    public static User adminUser;
    public static SBQQ__Quote__c quoteForTesting;
	public static final string SYS_ADMIN = 'System Administrator';
    
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
        CSRUser.Genesys_Enabled__c = false;
        CSRUser.Bypass_Validation__c = true;
        CSRUser.FirstName = 'testuser#9999';
        Database.insert(CSRUser);
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        System.runAs(CSRUser){
            Test.startTest();
            //create parent account
            Account parentAccount = QuoteTestDataFactory.createParentAccountRecord('Test Parent Account', '10', ConstantClass.RecordType_Client, CSRUser);
            QuoteTestDataFactory.insertAccount(parentAccount);
            System.debug(parentAccount);
            //create location account
            Account locationAccount = QuoteTestDataFactory.createLocationAccount('location account', parentAccount.Id, CSRUser);
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
            
            //create contacts for account
            Contact approverContact = QuoteTestDataFactory.createContactRecord('Approver contact', parentAccount.Id, CSRUser);
            QuoteTestDataFactory.insertContact(approverContact);
            
            Contact quoteContact = QuoteTestDataFactory.createContactRecord('Quote contact', parentAccount.Id, CSRUser);
            quoteContact.Account_Title__c = titleOfQuoteContact.Id;
            quoteContact.Account_Department__c = quoteContactDept.Id;
            QuoteTestDataFactory.insertContact(quoteContact);
            
            //creating case
            Case caseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,ConstantClass.FieldType_NewService,ConstantClass.FieldSubType_Permanent,'Existing Location', parentAccount, quoteContact, locationAccount);
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
            
            insert productList;
            
            //creating Opportunity
            Opportunity opp = QuoteTestDataFactory.createOpportunity(1, ConstantClass.FieldStageName_Proposal, 'OpportunityForCase', caseForQuote.Id, ConstantClass.FieldSubType_Permanent, locationAccount.Id);  
            QuoteTestDataFactory.insertOpportunity(opp);
            
            //Creating business rules
            Business_Rule__c businessRuleForApproval1 = QuoteTestDataFactory.createBusinessRule(parentAccount, locationAccount, ConstantClass.RecordType_Approval);
            QuoteTestDataFactory.insertBusinessRule(businessRuleForApproval1);
            
            Business_Rule__c businessRuleForApproval2 = new Business_Rule__c(Accountid__c = parentAccount.id, 
                                                                             Container__c = 'Equipment', Service__c = 'Temporary', 
                                                                             Request_Type__c = 'New Service', Schedule_Type__c = 'Permanent',
                                                                             Active__c = true, Effective_Date__c = System.today() - 1,
                                                                             Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                                             RecordTypeid = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Approval, 'Business_Rule__c'));
            QuoteTestDataFactory.insertBusinessRule(businessRuleForApproval2);
            
            //creating quote
            SBQQ__Quote__c quoteForTesting = QuoteTestDataFactory.createQuoteRecords(opp, locationAccount, quoteContact);
            List<SBQQ__Quote__c> quoteListForTesting = new List<SBQQ__Quote__c>();
            quoteListForTesting.add(quoteForTesting);
            QuoteTestDataFactory.insertQuotes(quoteListForTesting); 
            
            //QuoteLine Creation
            List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
            //Bundle 1
            SBQQ__QuoteLine__c quotelineForContainer = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting,openTop,
                                                                                                   'TEMP',1.00,'CLT','YRDS-30',
                                                                                                   'OC','M','1','PER',34.00,'DYS',
                                                                                                   'PER',null,'DYS','Do Not Override','NBG');
            quotelineForContainer.SBQQ__Bundle__c = TRUE;
            quotelineForContainer.SBQQ__RequiredBy__c = null;
            quotelineList.add(quotelineForContainer);
            
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
            
            //Changes related to SDT-39632
            SBQQ__QuoteLine__c quotelineForWasteCategory = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting, trashCategory,'TEMP',1.00,'CLT',
                                                                                                     'YRDS-30','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                     563.47,'DYS','Do Not Override','NBG');
            quotelineForWasteCategory.SBQQ__RequiredBy__c =  quotelineForContainer.Id;
            quotelineForWasteCategory.Vendor__c = parentVendor.Id;
            quotelineForWasteCategory.SBQQ__UnitCost__c = 2;
            quotelineForWasteCategory.CostModelType__c='PER';
            quotelineForWasteCategory.MASLibrary__c='ARDTA.180';
            quotelineForWasteCategory.MASCompany__c='test mas company'; 
            quotelineForWasteCategory.Cost_Unit_of_Measure__c= 'BNDL';
            quotelineList.add(quotelineForWasteCategory);
            
            
            insert quotelineList;
            
            //creating service approvers
            List<Service_Approver__c> sericeApproversList = new List<Service_Approver__c>();
            
            Service_Approver__c serviceApproverContact1 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval1, ConstantClass.RecordType_Contact);
            serviceApproverContact1.Active__c = false;
            serviceApproverContact1.Approver_Contact__c = approverContact.Id;
            sericeApproversList.add(serviceApproverContact1);
            Service_Approver__c serviceApproverContact2 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval2, ConstantClass.RecordType_Contact);
            serviceApproverContact2.Active__c = false;
            serviceApproverContact2.Approver_Contact__c = approverContact.Id;
            sericeApproversList.add(serviceApproverContact2);
            
            Service_Approver__c serviceApproverEmail1 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval1, ConstantClass.RecordType_Email);
            serviceApproverEmail1.Active__c = false;
            serviceApproverEmail1.Email__c = approverContact.Email;
            sericeApproversList.add(serviceApproverEmail1);
            Service_Approver__c serviceApproverEmail2 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval2, ConstantClass.RecordType_Email);
            serviceApproverEmail2.Active__c = false;
            serviceApproverEmail2.Email__c = approverContact.Email;
            sericeApproversList.add(serviceApproverEmail2);
            
            Service_Approver__c serviceApproverTitle1 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval1, ConstantClass.RecordType_Title);
            serviceApproverTitle1.Active__c = false;
            serviceApproverTitle1.Title__c = titleForBusinessRule.Id;
            sericeApproversList.add(serviceApproverTitle1);
            Service_Approver__c serviceApproverTitle2 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval2, ConstantClass.RecordType_Title);
            serviceApproverTitle2.Active__c = false;
            serviceApproverTitle2.Title__c = titleForBusinessRule.Id;
            sericeApproversList.add(serviceApproverTitle2);
            
            Service_Approver__c serviceApproverDepartment1 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval1, ConstantClass.RecordType_Department);
            serviceApproverDepartment1.Active__c = false;
            serviceApproverDepartment1.Department__c = approverDepartment.Id;
            sericeApproversList.add(serviceApproverDepartment1);
            Service_Approver__c serviceApproverDepartment2 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval2, ConstantClass.RecordType_Department);
            serviceApproverDepartment2.Active__c = false;
            serviceApproverDepartment2.Department__c = approverDepartment.Id;
            sericeApproversList.add(serviceApproverDepartment2);
            
            Service_Approver__c serviceApproverUser1 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval1, ConstantClass.RecordType_User);
            //serviceApproverUser1.User__c = adminUser.Id;
            serviceApproverUser1.Active__c = false;
            sericeApproversList.add(serviceApproverUser1);
            Service_Approver__c serviceApproverUser2 = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval2, ConstantClass.RecordType_User);
            //serviceApproverUser2.User__c = adminUser.Id;
            serviceApproverUser2.Active__c = false;
            sericeApproversList.add(serviceApproverUser2);
            
            insert sericeApproversList;
            
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
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        
        System.runAs(customerServiceUser){
            
            //querying inserted test quote
            quoteForTesting =[SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c =:ConstantClass.FieldStatus_Draft];
            
            
            //updating the quote staus to Product Configured.
            quoteForTesting.SBQQ__Status__c = ConstantClass.FieldStatus_ProductConfigured;
            update quoteForTesting;
            
            //updating the quote staus to Cost Configured.
            quoteForTesting = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c 
                               FROM SBQQ__Quote__c WHERE SBQQ__Status__c=: ConstantClass.FieldStatus_ProductConfigured LIMIT 1];
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_CostConfigured;
            update quoteForTesting; 
            
        } 
        return quoteForTesting;
        
    }
    
     /*
	 * @MethodName    manualApprovalForContactEmailMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(Contact + Email)
	 *  are different and multiple Business rules are present. 
	 */
    @isTest static void manualApprovalForContactEmailMultipleBR(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying contact and email Service Approvers
            Id contactRecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            Id emailRecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: contactRecordTypeId OR RecordTypeId =: emailRecordTypeId];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            }

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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    }
    
    /*
	 * @MethodName    manualApprovalForEmailTitleMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(Email + Title)
	 *  are different and multiple Business rules are present.
	 */
    @isTest static void manualApprovalForEmailTitleMultipleBR(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Email and Title Service Approvers
            Id recordTypeIdEmail = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Id recordTypeIdTitle = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Title, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdEmail OR RecordTypeId =: recordTypeIdTitle];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            }

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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    }
    
    /*
	 * @MethodName    manualApprovalForTitleDepartmentMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(Title+ dept)
	 * are different and multiple Business rules are present.
	 */
    @isTest static void manualApprovalForTitleDepartmentMultipleBR(){
        
        //Querying CSR User.
       customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //Querying Title and Department service approvers
            Id recordTypeIdTitle = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Title, 'Service_Approver__c');
            Id recordTypeIdDepartment = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Department, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdTitle OR RecordTypeId =: recordTypeIdDepartment];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            }
            
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    }     
    
    /*
	 * @MethodName    manualApprovalForContactsMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(contact+contact)
	 * are different and multiple Business rules are present.
	 */
    @isTest static void manualApprovalForContactsMultipleBR(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying contact Service Approvers
            Id contactRecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: contactRecordTypeId];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            }
            
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    }
    
    /*
	 * @MethodName    manualApprovalForEmailsMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(email+email)
	 * are different and multiple Business rules are present.
	 */
    @isTest static void manualApprovalForEmailsMultipleBR(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Email Service Approvers
            Id emailRecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: emailRecordTypeId];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            } 
            
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    } 
    
    /*
	 * @MethodName    manualApprovalForTitlesMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(title+title)
	 * are different and multiple Business rules are present.
	 */
    @isTest static void manualApprovalForTitlesMultipleBR(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Email Service Approvers
            Id titleRecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Title, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: titleRecordTypeId];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            } 
            
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    } 
    
     /*
	 * @MethodName    manualApprovalForDepartmentsMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(department+department)
	 * are different and multiple Business rules are present.
	 */
    @isTest static void manualApprovalForDepartmentsMultipleBR(){
        
        //Querying CSR User.
       customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Email Service Approvers
            Id departmentRecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_department, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: departmentRecordTypeId];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            } 
            
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    } 
    
    /*
	 * @MethodName    manualApprovalForUsersMultipleBR
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  Checking whether the quote status stays at 'Price Configured' itself when the approvers(user+user)
	 * are different and multiple Business rules are present.
	 */
    @isTest static void manualApprovalForUsersMultipleBR(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND FirstName =: 'testuser#9999' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Email Service Approvers
            Id userRecordTypeId = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_user, 'Service_Approver__c');
            List<Service_Approver__c> serviceApproversList = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: userRecordTypeId];
            for(Service_Approver__c approver : serviceApproversList) {
                approver.Active__c = True;
                update approver;
            } 
            
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    } 
    
}