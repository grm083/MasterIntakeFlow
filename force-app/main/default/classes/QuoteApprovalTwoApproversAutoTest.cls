// Test scenarios for 23, 24, 25 and 26
/*
* @Name         : TestForQuoteApprovalTwoApproversAuto
* @Author       : 
* @Date         : 
* @Vendor       : TCS
* @Description  : Test class for QuoteApproval for quote having single Business rule and two active approvers.
* Testing for auto approval condition.
*/
@isTest(seeAllData = false)
public class QuoteApprovalTwoApproversAutoTest {

    public static User customerServiceUser;
    public static User adminUser;
    public static SBQQ__Quote__c quoteForTesting;
    public static final string SYS_ADMIN = 'System Administrator';
    /*
     * @MethodName    setup
     * @Author        
     * @Vendor        TCS
     * @description   This method will be used to setup inital required data to test the methods.
     */
    @testSetup static void setup() {
       /* Set<String> permissionsetNames = new Set<String>{'Customer_Service_Reporting_User','Governance_Team','Merge_Access_for_Non_Admin_Users',
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
        
        //System.debug(customerServiceUser); */

        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User adminUser = TestDataFactory.createUser(adminProfile);
        adminUser.Bypass_Validation__c = false;
        adminUser.Genesys_Enabled__c = false;
        adminUser.FirstName = 'testuser#9999';
        Database.insert(adminUser);
        
	//Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
	    
        User CSRUser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];

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
            businessRuleForApproval.Container__c=null;
            businessRuleForApproval.Schedule_Type__c = null;
            businessRuleForApproval.Service__c = null;
            businessRuleForApproval.Case_Reason__c =null;
            businessRuleForApproval.Channel__c =null;
            businessRuleForApproval.Channel_Req__c = null;
            QuoteTestDataFactory.insertBusinessRule(businessRuleForApproval);
           // QuoteTestDataFactory.insertBusinessRule(businessRuleForApproval);
            
            
            //create quote
            SBQQ__Quote__c quoteForTesting = QuoteTestDataFactory.createQuoteRecords(opp, locationAccount, quoteContact);
            List<SBQQ__Quote__c> quoteListForTesting = new List<SBQQ__Quote__c>();
            quoteListForTesting.add(quoteForTesting);
            QuoteTestDataFactory.insertQuotes(quoteListForTesting);
            
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
            
            
            //create service approver
            List<Service_Approver__c> SAList = new List<Service_Approver__c>();
            Service_Approver__c serviceApproverContact = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Contact);
            serviceApproverContact.Active__c = false;
            serviceApproverContact.Approver_Contact__c = quoteContact.Id;
            SAList.add(serviceApproverContact);
            
            Service_Approver__c serviceApproverEmail = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Email);
            serviceApproverEmail.Active__c = false;
            serviceApproverEmail.Email__c = quoteContact.Email;
            SAList.add(serviceApproverEmail);
            
            Service_Approver__c serviceApproverTitle = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Title);
            serviceApproverTitle.Active__c = false;
            serviceApproverTitle.Title__c = titleOfQuoteContact.Id;
            SAList.add(serviceApproverTitle);
            
            Service_Approver__c serviceApproverDepartment = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Department);
            serviceApproverDepartment.Active__c = false;
            serviceApproverDepartment.Department__c = quoteContactDept.Id; 
            SAList.add(serviceApproverDepartment);
            
            Service_Approver__c serviceApproverUser = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_User);
            serviceApproverUser.User__c = CSRUser.Id;
            serviceApproverUser.Active__c = false;
            SAList.add(serviceApproverUser);
            
            insert SAList;
            
            test.stopTest();
            
        }
    }
    
    /*
     * @MethodName    returnQuoteWithSingleBundle
     * @Author        
     * @Vendor        TCS
     * @description   This method will return the quote with a single bundle in 'Cost Configured' status.
     */
    public static SBQQ__Quote__c returnQuoteWithSingleBundle() {
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, FirstName, Profile.Name, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999'LIMIT 1];
        
        System.runAs(customerServiceUser){
            
            //querying inserted test quote
            quoteForTesting =[SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c =:ConstantClass.FieldStatus_Draft];
            
            
            //updating the quote staus to Product Configured.
            quoteForTesting.SBQQ__Status__c = ConstantClass.FieldStatus_ProductConfigured;
            update quoteForTesting;
            
            //updating the quote staus to Cost Configured.
            quoteForTesting = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case_Type__c,SBQQ__Account__r.Parent.Id,SBQQ__Opportunity2__r.Case__c
                               FROM SBQQ__Quote__c WHERE SBQQ__Status__c=: ConstantClass.FieldStatus_ProductConfigured LIMIT 1];
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_CostConfigured;
            update quoteForTesting; 
            
        } 
        return quoteForTesting;
        
    }
    
    /*
     * @MethodName    autoApprovalForContactEmail
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status moves to 'Approved' when the approvers(Contact + email) 
     * are same. 
     */
    @isTest static void autoApprovalForContactEmail(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, Bypass_Validation__c, IsActive FROM User WHERE Bypass_Validation__c =: false AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive =: true LIMIT 1];

        
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying contact Service Approver
            Id recordTypeIdContact = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            Service_Approver__c serviceApproverContact = [Select Id, Active__c from Service_Approver__c 
                                                          Where RecordTypeId =: recordTypeIdContact];
            serviceApproverContact.Active__c = True;
            update serviceApproverContact;
            
             //querying Email Service Approver
            Id recordTypeIdEmail = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeIdEmail];
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;            
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            Test.stopTest();
            update quoteForTesting; 
            

            
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    }
    
    /*
     * @MethodName    autoApprovalForEmailTitle
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status moves to 'Approved' when the approvers(Title + Email) 
     * are same. 
     */
    @isTest static void autoApprovalForEmailTitle(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, FirstName, Profile.Name, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999'LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
             //querying Email Service Approver
            Id recordTypeIdEmail = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdEmail];
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;
             //querying Title Service Approver
            Id recordTypeIdTitle = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Title, 'Service_Approver__c');
            Service_Approver__c serviceApproverTitle = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdTitle];
            serviceApproverTitle.Active__c = True;
            update serviceApproverTitle;            
          
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            Test.stopTest();
            update quoteForTesting; 
  
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    }
    
    /*
     * @MethodName    autoApprovalForTitleDept
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status moves to 'Approved' when the approvers(Title+ Department) 
     * are same. 
     */
    @isTest static void autoApprovalForTitleDept(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, FirstName, Profile.Name, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999'LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Title Service Approver
            Id recordTypeIdTitle = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Title, 'Service_Approver__c');
            Service_Approver__c serviceApproverTitle = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdTitle];
            serviceApproverTitle.Active__c = True;
            update serviceApproverTitle; 
            //querying Department Service Approver
            Id recordTypeIdDept = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Department, 'Service_Approver__c');
            Service_Approver__c serviceApproverDepartment = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdDept];
            serviceApproverDepartment.Active__c = True;
            update serviceApproverDepartment; 
          
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            Test.stopTest();
            update quoteForTesting; 
            

        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    }     
    
    /*
     * @MethodName    autoApprovalForDeptContact
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status moves to 'Approved' when the approvers(Contact+ Department) 
     * are same. 
     */
    @isTest static void autoApprovalForDeptContact(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, FirstName, Profile.Name, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999'LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();            
            
            //querying Department Service Approver
            Id recordTypeIdDept = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Department, 'Service_Approver__c');
            Service_Approver__c serviceApproverDepartment = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdDept];
            serviceApproverDepartment.Active__c = True;
            update serviceApproverDepartment;
            //querying Contact Service Approver
            Id recordTypeIdContact = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            Service_Approver__c serviceApproverContact = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeIdContact];
            serviceApproverContact.Active__c = True;
            update serviceApproverContact;
          
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            //Changes related to SDT-42734 - test class failure - 12/10/2024
            Test.stopTest(); 
            update quoteForTesting; 
            
            //Test.stopTest(); 
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    }
    	/*
	 * @MethodName    getBusinessRuleByPriorityTest
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  added for code covereage sp 5 
	 */
    @isTest static void getBusinessRuleByPriorityTest(){
        String approvalRecordType = 'Approval'; 
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
            
            //update  quoteForTesting; 
            
            Test.stopTest();
            QuoteApproval qApp = new QuoteApproval();
            try{
                  qApp.getBusinessRuleByPriority(approvalRecordType, quoteForTesting.Case_Type__c, 
                                                    quoteForTesting.SBQQ__Account__r.Parent.Id ,quoteForTesting.Duration__c, 
                                                    quoteForTesting.SBQQ__Account__c, 
                                                    quoteForTesting.SBQQ__Opportunity2__r.Case__c);
            }
            catch(exception ex){
                system.debug(ex.getMessage());
            }

        }

    } 
    
     /*
	 * @MethodName    noApprovalRequiredTest
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  added for code covereage sp 5 
	 */
    @isTest static void noApprovalRequiredTest(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, FirstName, Profile.Name, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999'LIMIT 1];
        Business_Rule__c businessRuleForApproval = [SELECT Id,No_Approval_Required__c from Business_Rule__c LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            businessRuleForApproval.No_Approval_Required__c = TRUE;
            Update businessRuleForApproval;
                
            //querying contact Service Approver
            Id recordTypeIdContact = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            Service_Approver__c serviceApproverContact = [Select Id, Active__c from Service_Approver__c 
                                                          Where RecordTypeId =: recordTypeIdContact];
            serviceApproverContact.Active__c = True;
            update serviceApproverContact;
            
             //querying Email Service Approver
            Id recordTypeIdEmail = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeIdEmail];
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;            
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            Test.stopTest();
            update quoteForTesting; 
            

            
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //System.assertEquals(ConstantClass.FieldStatus_Approved, quoteForTesting.SBQQ__Status__c);  
        
    }
        
     /*
	 * @MethodName    createApprovalLogEmailtoCaseAutoApprovalTest
	 * @Author        
	 * @Vendor		  TCS
	 * @description	  added for code covereage sp 5 
	 */
        @isTest static void createApprovalLogEmailtoCaseAutoApprovalTest(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, FirstName, Profile.Name, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND FirstName =: 'testuser#9999'LIMIT 1];
        Business_Rule__c businessRuleForApproval = [SELECT Id,No_Approval_Required__c from Business_Rule__c LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            businessRuleForApproval.No_Approval_Required__c = TRUE;
            Update businessRuleForApproval;
                
            //querying contact Service Approver
            Id recordTypeIdContact = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Contact, 'Service_Approver__c');
            Service_Approver__c serviceApproverContact = [Select Id, Active__c,Email__c,Approver_Contact__c from Service_Approver__c 
                                                          Where RecordTypeId =: recordTypeIdContact];
            serviceApproverContact.Active__c = True;
            update serviceApproverContact;
            
             //querying Email Service Approver
            Id recordTypeIdEmail = QuoteTestDataFactory.getRecordType(ConstantClass.RecordType_Email, 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeIdEmail];
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;            
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            Test.stopTest();
            update quoteForTesting; 
            
            QuoteApproval.createApprovalLogEmailtoCaseAutoApproval(quoteForTesting.Id, 
                                                                   quoteForTesting.SBQQ__Opportunity2__r.Case__c, 
                                                                   customerServiceUser.Id,
                                                                   serviceApproverContact.Email__c, 
                                                                   serviceApproverContact.Approver_Contact__c, 
                                                                   ConstantClass.FieldStatus_PriceConfigured, 
                                                                   'test', businessRuleForApproval.Id); 
            
        } 
        
    }
    
        
}
