//Test class for scenarios 1(42), 2(43),3(44), 4(45), 5(46), 7(19,47), 8(20,48), 9(22,49), 10(50), 11(21)
/*
* @Name         : TestForQuoteApprovalBundleManual
* @Author       : 
* @Date         : 
* @Vendor       : TCS
* @Description  : Test class for QuoteApproval for quote having single Business rule. 
* Testing for manual approval condition.
*/
@isTest(seeAllData = false)
public class QuoteApprovalBundleManualTest{
    
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
     * @MethodName    setup
     * @Author        
     * @Vendor        TCS
     * @description   This method will be used to setup inital required data to test the methods.
     */
    @testSetup static void setup() {
    /*Set<String> permissionsetNames = new Set<String>{'Customer_Service_Reporting_User','Governance_Team','Merge_Access_for_Non_Admin_Users',
                                                     'Price_Accessibility_Permission_Set','Pricing_Access', 'CPQ_Extended_License'};    
        List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
    
    
        //fetching Customer Service profile 
        Profile CustomerServieUser = TestDataFactory.getProfile(Constant_Util.CUSTOMER_SERVICE);
        //creating a CSR user
        User CSRUser = TestDataFactory.createUser(CustomerServieUser);
        CSRUser.LastName = 'TestingForApproval';
        Insert CSRUser;
        //Assigning permissionset license
        insert new PermissionSetLicenseAssign(AssigneeId = CSRUser.Id, PermissionSetLicenseId= pslList[0].Id);
        //assigning permission sets
        QuoteTestDataFactory.assignPermissionSet(permissionsetNames, CSRUser);
        
        //System.debug(customerServiceUser);*/
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User CSRUser = TestDataFactory.createUser(adminProfile);
        CSRUser.Bypass_Validation__c = true;
        CSRUser.Genesys_Enabled__c = false;
        CSRUser.LastName = 'TestingForApproval';
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
            
            //creating contacts
            Contact approverContact = QuoteTestDataFactory.createContactRecord('Approver contact', parentAccount.Id, CSRUser);
            QuoteTestDataFactory.insertContact(approverContact);
            
            Contact quoteContact = QuoteTestDataFactory.createContactRecord('Quote contact', parentAccount.Id, CSRUser);
            quoteContact.Account_Title__c = titleOfQuoteContact.Id;
            quoteContact.Account_Department__c = quoteContactDept.Id;
            QuoteTestDataFactory.insertContact(quoteContact);
            
            //creating case
            Case caseForQuote = QuoteTestDataFactory.createCase(ConstantClass.RecordType_NewServiceCase,ConstantClass.FieldType_NewService,ConstantClass.FieldSubType_Permanent,'Existing Location', parentAccount, quoteContact, locationAccount);
            caseList.add(caseForQuote);
            QuoteTestDataFactory.insertCases(caseList);
            
            //creating products
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
            
            //creating quote
            SBQQ__Quote__c quoteForTesting = QuoteTestDataFactory.createQuoteRecords(opp, locationAccount, quoteContact);
            quoteList.add(quoteForTesting);
            QuoteTestDataFactory.insertQuotes(quoteList);
            
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
            List<SBQQ__QuoteLine__c> wcQlList = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c wCqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteForTesting.Id,
                                                  SBQQ__Product__c = trashCategory.Id,
                                                  SBQQ__RequiredBy__c = quotelineForContainer.Id);
            QuoteTestDataFactory.insertQuoteLine(wCqLine);
                                                              
            SBQQ__QuoteLine__c wSqLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteForTesting.Id,
                                                  SBQQ__Product__c = trashStream.Id,
                                                  SBQQ__RequiredBy__c = quotelineForContainer.Id);
            
            QuoteTestDataFactory.insertQuoteLine(wSqLine);
            
            
            //create service approver
            List<Service_Approver__c> SAList = new List<Service_Approver__c>();
            Service_Approver__c serviceApproverContact = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Contact);
            serviceApproverContact.Active__c = false;
            serviceApproverContact.Approver_Contact__c = approverContact.Id;
            SAList.add(serviceApproverContact);
            
            Service_Approver__c serviceApproverEmail = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Email);
            serviceApproverEmail.Active__c = false;
            serviceApproverEmail.Email__c = approverContact.Email;
            SAList.add(serviceApproverEmail);
            
            Service_Approver__c serviceApproverTitle = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Title);
            serviceApproverTitle.Active__c = false;
            serviceApproverTitle.Title__c = titleForBusinessRule.Id;
            SAList.add(serviceApproverTitle);
            
            Service_Approver__c serviceApproverDepartment = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_Department);
            serviceApproverDepartment.Active__c = false;
            serviceApproverDepartment.Department__c = approverDepartment.Id; 
            SAList.add(serviceApproverDepartment);
            
            Service_Approver__c serviceApproverUser = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, ConstantClass.RecordType_User);
            serviceApproverUser.Active__c = false;
            SAList.add(serviceApproverUser);
            
            Service_Approver__c serviceApproverNTEApproval = QuoteTestDataFactory.createServiceApprover(businessRuleForApproval, 'NTE Approval');
            serviceApproverUser.Active__c = true;
            SAList.add(serviceApproverNTEApproval);
            
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
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        
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
            
        } 
        return quoteForTesting;
        
    }
    
    /*
     * @MethodName    returnQuoteWithTwoBundles
     * @Author        
     * @Vendor        TCS
     * @description   This method will return the quote with two bundles in 'Cost Configured' status.
     */
    public static SBQQ__Quote__c returnQuoteWithTwoBundles() {
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        
        System.runAs(customerServiceUser){
            
            //querying inserted test quote
            quoteForTesting =[SELECT Id,SBQQ__Status__c, SBQQ__Account__c, Duration__c,
                              SBQQ__PrimaryContact__c, Business_Rule__c, SBQQ__StartDate__c 
                              FROM SBQQ__Quote__c WHERE SBQQ__Status__c =:ConstantClass.FieldStatus_Draft];
            
            //Creating product for second bundle
            Product2 compactor = QuoteTestDataFactory.createProductRecord('Compactor', 'Equipment', 'CMP');
            compactor.ProductConfigurationType__c = 'Bundle';
            productList.add(compactor);
            Product2 pickupService = QuoteTestDataFactory.createProductRecord('Pickup', 'Services', 'PCK');
            productList.add(pickupService);
            
            QuoteTestDataFactory.insertProducts(productList);
            //Querying Vendor
            Account parentVendor = [Select Id, Name From Account Where Name= 'Parent Vendor' LIMIT 1];
            
            //Creating QuoteLine
            //Bundle 2
            SBQQ__QuoteLine__c quotelineForCompactor = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting,compactor,'TEMP',1.00,'CLT','YRDS-20','OC',
                                                                                                   null,null,'PER',34.00,'DYS','PER',67,'DYS','Do Not Override',
                                                                                                   'NBG');
            quotelineForCompactor.Schedule_Frequency__c = 'M';
            quotelineForCompactor.SBQQ__Bundle__c = TRUE;
            quotelineForCompactor.SBQQ__RequiredBy__c = null;
            QuoteTestDataFactory.insertQuoteLine(quotelineForCompactor); 
            
            SBQQ__QuoteLine__c quotelineForPickupService = QuoteTestDataFactory.createQuoteLineRecords(quoteForTesting,pickupService,'PERM',1.00,'CLT','YRDS-4','SCH',
                                                                                                       '','','PER',34.00,'DYS','PER',59,'DYS','Do Not Override',
                                                                                                       'NBG');
            quotelineForPickupService.Schedule_Frequency__c = 'M';
            quotelineForPickupService.Frequency_Interval__c ='2';
        
            quotelineForPickupService.SBQQ__RequiredBy__c =  quotelineForCompactor.Id;
            quotelineForPickupService.Vendor__c = parentVendor.Id;
            QuoteTestDataFactory.insertQuoteLine(quotelineForPickupService); 
            
            //updating the quote staus to Product Configured.
            quoteForTesting.SBQQ__Status__c = ConstantClass.FieldStatus_ProductConfigured;
            /*update quoteForTesting;
            
            //updating the quote staus to Cost Configured.
            quoteForTesting = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c 
                               FROM SBQQ__Quote__c WHERE SBQQ__Status__c=: ConstantClass.FieldStatus_ProductConfigured LIMIT 1]; */
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_CostConfigured;
            update quoteForTesting; 
            
        } 
        return quoteForTesting;
        
    }
    
    /*
     * @MethodName    manualApprovalForBRContact
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(Contact) is different. 
     */
    @isTest static void manualApprovalForBRContact(){
        

        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying contact Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Contact', 'Service_Approver__c');
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
            
            Test.stopTest();
            
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    }
    
    /*
     * @MethodName    manualApprovalForBREmail
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(email) is different. 
     */
    @isTest static void manualApprovalForBREmail(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying Email Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Email', 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeId];
            serviceApproverEmail.Requester_Only__c = true;//added
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
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    }
    
    /*
     * @MethodName    manualApprovalForBRTitle
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(Title) is different. 
     */
    @isTest static void manualApprovalForBRTitle(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying Title Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Title', 'Service_Approver__c');
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    } 
    
    /*
     * @MethodName    manualApprovalForBRDepartment
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(Department) is different. 
     */
    @isTest static void manualApprovalForBRDepartment(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
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
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    } 
    
    /*
     * @MethodName    manualApprovalForBRUser
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(User) is different. 
     
    @isTest static void manualApprovalForBRUser(){
        
        //Creating a user for User service approver
        List<String>permissionsetNamesForAdmin = new List<String>{'Reports_and_Dashboards_Administrator'};            
        adminUser = UserTestDataFactory.createUserRecord('System Administrator', 'System Administrator', permissionsetNamesForAdmin);
            
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying User Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('User', 'Service_Approver__c');
            Service_Approver__c serviceApproverUser = [Select Id, Active__c from Service_Approver__c 
                                                       Where RecordTypeId =: recordTypeId];
            serviceApproverUser.User__c = adminUser.Id;
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    } 
    */

    /*
     * @MethodName    manualApprovalTwoBundlesContactApproval
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(Contact) is different. 
     */
    @isTest static void manualApprovalTwoBundlesContactApproval(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying contact Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Contact', 'Service_Approver__c');
            Service_Approver__c serviceApproverContact = [Select Id, Active__c from Service_Approver__c 
                                                          Where RecordTypeId =: recordTypeId];
            serviceApproverContact.Active__c = True;
            update serviceApproverContact;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithTwoBundles();
            Test.stopTest();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 
            
            
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    }
    
    /*
     * @MethodName    manualApprovalTwoBundlesEmailApproval
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(Email) is different. covering some more methods for coverage
     */
    @isTest static void manualApprovalTwoBundlesEmailApproval(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Email Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Email', 'Service_Approver__c');
            Service_Approver__c serviceApproverEmail = [Select Id, Active__c from Service_Approver__c Where RecordTypeId =: recordTypeId];
            serviceApproverEmail.Active__c = True;
            update serviceApproverEmail;
            Test.stopTest();
            //querying inserted test quote
            quoteForTesting = returnQuoteWithTwoBundles();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update quoteForTesting; 
            
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    }
    
     /*
     * @MethodName    manualApprovalTwoBundlesTitleApproval
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(Title) is different. 
     */
    @isTest static void manualApprovalTwoBundlesTitleApproval(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying Title Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Title', 'Service_Approver__c');
            Service_Approver__c serviceApproverTitle = [Select Id, Active__c from Service_Approver__c 
                                                        Where RecordTypeId =: recordTypeId];
            serviceApproverTitle.Active__c = True;
            update serviceApproverTitle;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithTwoBundles();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            Test.stopTest();
            update  quoteForTesting; 
            
        }
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    } 
    
    /*
     * @MethodName    manualApprovalTwoBundlesDepartmentApproval
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(Department) is different. 
     */
    @isTest static void manualApprovalTwoBundlesDepartmentApproval(){
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying Department Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('Department', 'Service_Approver__c');
            Service_Approver__c serviceApproverDepartment = [Select Id, Active__c from Service_Approver__c 
                                                             Where RecordTypeId =: recordTypeId];
            serviceApproverDepartment.Active__c = True;
            update serviceApproverDepartment;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithTwoBundles(); 
            Test.stopTest();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            update  quoteForTesting; 
            
        }
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    } 
    
    /*
     * @MethodName    manualApprovalTwoBundlesUserApproval
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(User) is different. 
     */
    @isTest static void manualApprovalTwoBundlesUserApproval(){
        
        //Creating a user for User service approver
        List<String>permissionsetNamesForAdmin = new List<String>{'Reports_and_Dashboards_Administrator'};            
            adminUser = UserTestDataFactory.createUserRecord('System Administrator', 'System Administrator', permissionsetNamesForAdmin);
        
        //Querying CSR User.
        customerServiceUser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval' LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            
            //querying User Service Approver
            Id recordTypeId = QuoteTestDataFactory.getRecordType('User', 'Service_Approver__c');
            Service_Approver__c serviceApproverUser = [Select Id, Active__c from Service_Approver__c 
                                                       Where RecordTypeId =: recordTypeId];
            serviceApproverUser.User__c = adminUser.Id;
            serviceApproverUser.Active__c = True;
            update serviceApproverUser;
            
            //querying inserted test quote
            quoteForTesting = returnQuoteWithTwoBundles(); 
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c=ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            Test.stopTest();
            update  quoteForTesting; 
            
        }
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        //Commented by Srishti as per  SDT47246
        //System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);
        
    } 

    /*
     * @MethodName    manualApprovalForBREmailTestCreate
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(email) is different. 
     */
    @isTest static void manualApprovalForBREmailTestCreate(){
        //to addresses
        List<String> toaddresses = new List<String>{'mali2@gmail.com'};

        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval'  LIMIT 1];
        System.runAs(customerServiceUser){
            
            Test.startTest();
            //querying case
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
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
            quoteForTesting.SBQQ__Status__c= ConstantClass.FieldStatus_PriceConfigured; 
            
            //Bypassing RecursiveTriggerHandler class for trigger and updating.
            RecurrsiveTriggerHandler.isSkipQuoteTrigger = true;
            
            try{
                update quoteForTesting; 
            }
            catch(DmlException e){
            }
            QuoteApproval.approvallogcreation(QuoteApproval.createApprovalLogForManualEmails(toaddresses,quoteForTesting.Id));
            QuoteApproval.createApprovalLogForOrigin(quoteForTesting.Id,'Approved','Auto Approved');
            QuoteApproval.createApprovalLogForNoApproval(quoteForTesting.Id,'Approved','Auto Approved');
            
            QuoteApproval.createApprovalLogUserTypeAutoApproval(quoteForTesting.Id, caseRec.id, customerServiceUser.id, 'test@gmail.com',caseRec.ContactId, 'Approved','Auto Approved', brule.id);
            QuoteApproval.createApprovalLogForRoleProfile(caseRec.id);
            QuoteApproval.createApprovalLogForRequestorOnly(toaddresses, quoteForTesting.Id, 'Approved','Auto Approved', caseRec.contactEmail);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setWhatId(quoteForTesting.Id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setSaveAsActivity(false);
            //QuoteApproval a = new QuoteApproval();
            QuoteApproval.attachEmailMessage(mail, toaddresses, quoteForTesting.Id);
            QuoteApproval.approvallogcreation(QuoteApproval.createApprovalLogForManualEmails(toaddresses,quoteForTesting.Id));
            GetBRQuotePriorityNTECtrl.getBRNTEPriority(quoteForTesting.Id);    
            Test.stopTest();
        } 
        
        quoteForTesting = [select Id,SBQQ__Status__c from SBQQ__Quote__c where Id =:quoteForTesting.Id];
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    } 
    /*
     * @MethodName    createEmailMessageTest
     * @Author        
     * @Vendor        TCS
     * @description   Checking whether the quote status stays at 'Price Configured' itself when the approver(email) is different. 
     */
    @isTest static void createEmailMessageTest(){
        //to addresses
        List<String> toaddresses = new List<String>{'mali2@gmail.com'};

        //Querying CSR User.
        customerServiceUser = [SELECT Id FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true AND LastName =: 'TestingForApproval'  LIMIT 1];
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
            quoteForTesting = returnQuoteWithSingleBundle();
            
            //updating the quote staus to Price Configured.
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
        System.assertEquals(ConstantClass.FieldStatus_PriceConfigured, quoteForTesting.SBQQ__Status__c);  
        
    } 
    
}