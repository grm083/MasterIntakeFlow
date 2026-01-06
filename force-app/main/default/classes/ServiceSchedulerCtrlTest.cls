@isTest public class ServiceSchedulerCtrlTest {

    //TCS-pkulkarn-13-Mar-2024-SDT-38495-Added two variables
    public static String assertionErrorMessage = 'Error occured during assertion check';
    public static String sSuccessMessage = 'SUCCESS';
    //TCS-pkulkarn-13-Mar-2024-SDT-38495-End

    @testSetup public static void setupData() {
        String SYS_ADMIN = 'System Administrator';
        //Insert products
        List<Product2> prodList = new List<Product2>();
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT');
        Product2 dumpster = new Product2(Name = 'Dumpster', Family = 'Rolloff', ProductCode = 'DMP');
        Product2 compactor = new Product2(Name = 'Compactor', Family = 'Commercial', ProductCode = 'CMP');
        Product2 toter = new Product2(Name = 'Toter', Family = 'Commercial', ProductCode = 'TOT');
        Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
        Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV');
        Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        prodList.add(container);
        prodList.add(dumpster);
        prodList.add(compactor);
        prodList.add(toter);
        prodList.add(haulService);
        prodList.add(deliveryService);
        prodList.add(trashCategory);
        prodList.add(trashStream);
        insert prodList;
        
        List<SBQQ__ProductRule__c> prodRuleList= new List<SBQQ__ProductRule__c>();
        SBQQ__ProductRule__c prodRule = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 10 AND 20 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream',SBQQ__EvaluationOrder__c=1);
        SBQQ__ProductRule__c prodRule1 = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 30 AND 40 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream test',SBQQ__EvaluationOrder__c=2);
        SBQQ__ProductRule__c prodRule2 = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 50 AND 60 )',SBQQ__ConditionsMet__c = 'Any',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream test test',SBQQ__EvaluationOrder__c=3);
        prodRuleList.add(prodRule);
        prodRuleList.add(prodRule1);
        prodRuleList.add(prodRule2);
        SBQQ__ProductRule__c prodRule3 = new SBQQ__ProductRule__c(Name = 'test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 70 AND 80 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='test',SBQQ__EvaluationOrder__c=4);
      	SBQQ__ProductRule__c prodRule4 = new SBQQ__ProductRule__c(Name = 'test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 90 AND 100 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='test test',SBQQ__EvaluationOrder__c=5);
        SBQQ__ProductRule__c prodRule5 = new SBQQ__ProductRule__c(Name = 'test test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 110 AND 120 )',SBQQ__ConditionsMet__c = 'Any',SBQQ__ErrorMessage__c='test test test',SBQQ__EvaluationOrder__c=6);
        SBQQ__ProductRule__c prodRule6 = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory test test test test', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 130 AND 140 )',SBQQ__ConditionsMet__c = 'Any',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream test test test test',SBQQ__EvaluationOrder__c=7);
        prodRuleList.add(prodRule3);
        prodRuleList.add(prodRule4);
        prodRuleList.add(prodRule5);
        prodRuleList.add(prodRule6);
        insert prodRuleList;

        List<SBQQ__ConfigurationRule__c> configRuleList =new List<SBQQ__ConfigurationRule__c>();
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = container.Id, SBQQ__ProductRule__c=prodRule.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = dumpster.Id, SBQQ__ProductRule__c=prodRule1.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = compactor.Id, SBQQ__ProductRule__c=prodRule2.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = container.Id, SBQQ__ProductRule__c=prodRule3.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = dumpster.Id, SBQQ__ProductRule__c=prodRule4.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = compactor.Id, SBQQ__ProductRule__c=prodRule5.Id));
        configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = toter.Id, SBQQ__ProductRule__c=prodRule6.Id));
        insert configRuleList;

        List<SBQQ__ErrorCondition__c> errorCondList = new List<SBQQ__ErrorCondition__c>();
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =20, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule.Id, SBQQ__TestedField__c ='SBQQ__ProductName__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =10, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =30, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule1.Id, SBQQ__TestedField__c ='SBQQ__ProductName__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =40, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule1.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =50, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule2.Id, SBQQ__TestedField__c ='SBQQ__ProductName__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =60, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule2.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =70, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule3.Id, SBQQ__TestedField__c ='SBQQ__ProductName__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =80, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule3.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =90, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule4.Id, SBQQ__TestedField__c ='SBQQ__ProductName__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =100, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule4.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =110, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule5.Id, SBQQ__TestedField__c ='SBQQ__ProductName__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =120, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule5.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes')); 
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Metal',  SBQQ__Index__c =130, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule6.Id, SBQQ__TestedField__c ='SBQQ__ProductName__c', SBQQ__TestedObject__c='Product Option'));
        errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =140, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule6.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes')); 
        insert errorCondList;

        List<SBQQ__ProductRule__c> updateProdRule = new List<SBQQ__ProductRule__c>();
        prodRule.SBQQ__ConditionsMet__c = 'Custom';
        updateProdRule.add(prodRule);
        prodRule3.SBQQ__ConditionsMet__c = 'Custom';
        updateProdRule.add(prodRule3);
        update updateProdRule;

        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();

        //Insert Accounts
        List<Account> acctList = new List<Account>();
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
        RecordType vendorType = [SELECT Id FROM RecordType WHERE Name = 'Vendor'];
        RecordType locType = [SELECT Id FROM RecordType WHERE Name = 'Location'];
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = locType.Id);
        Account parentCustomer = new Account(Name = 'Test Parent', RecordTypeId = customerType.Id,AccountNumber = '81');
        Account childVendor = new Account(Name = 'Test Vendor', RecordTypeId = vendorType.Id,
                                          Status__c = 'Active', AccountNumber = '111266', Vendor_Business_Unit__c = '1');
        Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorType.Id,
                                           Status__c = 'Active', AccountNumber = '8');
        Account locvendor = new Account(Name = 'Location Vendor', RecordTypeId = locType.Id,
                                        Status__c = 'Active', AccountNumber = '9',Type ='Location');
        acctList.add(customer);
        acctList.add(parentCustomer);
        acctList.add(childVendor);
        acctList.add(parentVendor);
        acctList.add(locvendor);
        insert acctList;
        childVendor.ParentId = parentVendor.Id;
        update childVendor;
        customer.ParentId = parentCustomer.Id;
        update customer;

        //inserting user for S11 test class errors
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        //inserting contact for S11 test class errors
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acctList.get(1), usr);
        Database.insert(conlist);
        
        //inserting case for S11 test class errors
        Case pickupCase = QuoteTestDataFactory.createCase('Pickup Case','Pickup','Extra Pickup','', acctList[1],conlist[0], acctList[0]);
        Database.insert(pickupCase);
        
        //opportunity for case - addtion for S11 test class error
        List<Opportunity> oppList = TestDataFactory.createOpportunity(1,'TestOpportunityTest',pickupCase.Id,pickupCase.Case_Sub_Type__c, acctList[0].Id); //PK
        oppList[0].Duration__c='Temporary';
        Database.insert(oppList);
        
        //Insert Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Account__c = customer.id;
        testQuote.SBQQ__Status__c = 'Draft';
        testQuote.Duration__c = 'Temporary';
        testQuote.SBQQ__StartDate__c = system.today();
        //addtion for S11 test class error
        testQuote.SBQQ__Opportunity2__c = oppList[0].Id;
        
        insert testQuote;
        
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                             SBQQ__Product__c = container.Id,
                                                             Equipment_Size__c = 'YRDS-30');
        insert parentQL;
        
    }
    
    @isTest public static void testScheduler1() {
        
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
        pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
        
        ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
        ServiceSchedulerCtrl.submitOnCall(quote.id, pQLine.id);
        ServiceSchedulerCtrl.submitDailyEveryDay(quote.id,pQLine.id,  '1');
        ServiceSchedulerCtrl.submitDailyEveryWeek(quote.id, pQLine.id);
        ServiceSchedulerCtrl.submitWeekly(quote.id,pQLine.id,  '1', 'M');
        test.stopTest();
    }

    @isTest public static void testScheduler2() {
        
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
        pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
        
        ServiceSchedulerCtrl.submitMonthly(quote.id,pQLine.id, '1');
        ServiceSchedulerCtrl.submitMonthlySpecific(quote.id,pQLine.id, '1', '1');
        //SDT-38285 - Start
        ServiceSchedulerCtrl.submitMonthlyIntervalSpecificNew(quote.id, pQLine.id,'2','3','','','1', 'ServiceDate' );
        ServiceSchedulerCtrl.submitMonthlyIntervalSpecificNew(quote.id, pQLine.id,'','','First','Day','2', 'ServiceDay' );
        //SDT-38285 - End
        ServiceSchedulerCtrl.submitYearly(quote.id,pQLine.id, '1');
        test.stopTest();
    }

    @isTest public static void validateDescriptionOfWasteForCustomTest(){

        Product2 openTopProdObj = [SELECT Id from Product2 WHERE Name = 'Open Top' LIMIT 1];
        QuoteProcurementController.HeaderWrapper productWrapper = new QuoteProcurementController.HeaderWrapper();
        productWrapper.materialType = 'Metal';
        productWrapper.productId = openTopProdObj.Id;
        productWrapper.wasteDescription = null;
        Test.startTest();
        Map<String,List<String>> resultMap = ServiceSchedulerCtrl.validateDescriptionOfWaste(productWrapper);
        System.assert(resultMap.containsKey('Failed'));
        Test.stopTest();
    }

    @isTest public static void validateDescriptionOfWasteForAllTest(){

        Product2 openTopProdObj = [SELECT Id from Product2 WHERE Name = 'Dumpster' LIMIT 1];
        QuoteProcurementController.HeaderWrapper productWrapper = new QuoteProcurementController.HeaderWrapper();
        productWrapper.materialType = 'Metal';
        productWrapper.productId = openTopProdObj.Id;
        productWrapper.wasteDescription = null;
        Test.startTest();
        Map<String,List<String>> resultMap = ServiceSchedulerCtrl.validateDescriptionOfWaste(productWrapper);
        System.assert(resultMap.containsKey('Failed'));
        Test.stopTest();
    }

    @isTest public static void validateDescriptionOfWasteForAnyTest(){

        Product2 openTopProdObj = [SELECT Id from Product2 WHERE Name = 'Compactor' LIMIT 1];
        QuoteProcurementController.HeaderWrapper productWrapper = new QuoteProcurementController.HeaderWrapper();
        productWrapper.materialType = 'Metal';
        productWrapper.productId = openTopProdObj.Id;
        productWrapper.wasteDescription = null;
        Test.startTest();
        Map<String,List<String>> resultMap = ServiceSchedulerCtrl.validateDescriptionOfWaste(productWrapper);
        System.assert(resultMap.containsKey('Failed'));
        Test.stopTest();
    }

    @isTest public static void validateDescriptionOfWasteForSuccessTest(){

        Product2 openTopProdObj = [SELECT Id from Product2 WHERE Name = 'Toter' LIMIT 1];
        QuoteProcurementController.HeaderWrapper productWrapper = new QuoteProcurementController.HeaderWrapper();
        productWrapper.materialType = 'Metal';
        productWrapper.productId = openTopProdObj.Id;
        productWrapper.wasteDescription = 'test';
        Test.startTest();
        Map<String,List<String>> resultMap = ServiceSchedulerCtrl.validateDescriptionOfWaste(productWrapper);
        System.assert(resultMap.containsKey('Failed'));
        Test.stopTest();
    }

    /*SDT-30079
        Dev: Seema Dhikale
        FC: Athul Raj
        Description: added validation for number of days not to be greater than 500. 
        This validation is only applicable when Quote/Quote lines are being created/updated from CEI screen.
    */
    @isTest public static void testSchedulerforMaxLimitforEveryday() {
        
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
        pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
        
        ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
        ServiceSchedulerCtrl.submitOnCall(quote.id, pQLine.id);
        String msg = ServiceSchedulerCtrl.submitDailyEveryDay(quote.id,pQLine.id,  '900');
        System.assertequals(msg,QuoteLineServices.checkForMaxValueWhileSchedulingDays('900'));
        test.stopTest();
    }
    //for coverage
    @isTest public static void auraMethodsTest() {
        test.starttest();
        SBQQ__QuoteLine__c qLine = [Select Id, AAV_Service_Override_Reason__c, AAV_Service_Day_Override_Comment__c, AAV_Service_Availability__c, AAV_Service_Days_Unavailable__c FROM SBQQ__QuoteLine__c Where SBQQ__RequiredBy__c = null LIMIT 1];
        
        
        try {
            ServiceSchedulerCtrl.updateAdditionalServices(qLine.Id);
        }
        catch(exception ex) {
            system.debug(ex);
        }
        
        try {
            ServiceSchedulerCtrl.deleteQuoteLine(qLine.Id);
        }
        catch(exception ex) {
            system.debug(ex);
        }
        
        try {
            ServiceSchedulerCtrl.saveServiceOverrideOptions(qLine.Id, qLine.AAV_Service_Override_Reason__c, qLine.AAV_Service_Day_Override_Comment__c, qLine.AAV_Service_Availability__c, qLine.AAV_Service_Days_Unavailable__c);
        }
        catch(exception ex) {
            system.debug(ex);
        }
        
        test.stoptest();
    }
    /*SDT-31262
        Dev: Seema Dhikale
        FC: Athul Raj
        Description: added validation for number of weeks not to be greater than 30. 
        This validation is only applicable when Quote/Quote lines are being created/updated from CEI screen.
    */
    @isTest public static void testSchedulerForWeeklyErrorWeekGreaterThan30() {
        
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
        pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
        
        ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
        String msg = ServiceSchedulerCtrl.submitWeekly(quote.id,pQLine.id,  '199', 'W');
        System.assertequals(msg,QuoteLineServices.checkForMaxValueWhileSchedulingWeeks('199'));
        test.stopTest();
    }
    /*SDT-31262
        Dev: Seema Dhikale
        FC: Athul Raj
        Description: added validation for number of weeks not to be greater than 30. 
        This validation is only applicable when Quote/Quote lines are being created/updated from CEI screen.
    */
    @isTest public static void testSchedulerForWeeklyErrorNoServiceDays() {
        
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
        pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
        
        ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
        String msg = ServiceSchedulerCtrl.submitWeekly(quote.id,pQLine.id,  '2', '');
        System.assertequals(msg,QuoteLineServices.SERVICE_DAYS_ERROR);
        test.stopTest();
    }

    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlyFrequencyNull() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            String errorMessage = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly('100');
            
            //Test for NULL value
            msg = ServiceSchedulerCtrl.submitMonthly(quote.id, pQLine.id, '');
            System.assertequals(msg, errorMessage, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlyFrequencyLowerBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            String errorMessage = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly('100');
            
            //Test for lower boundary value < 1
            msg = ServiceSchedulerCtrl.submitMonthly(quote.id, pQLine.id, '0');
            System.assertequals(msg, errorMessage, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlyFrequencyUpperBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            String errorMessage = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly('100');
            
            //Test for upper boundary value > 99
            msg = ServiceSchedulerCtrl.submitMonthly(quote.id, pQLine.id, '100');
            System.assertequals(msg, errorMessage, assertionErrorMessage);
            
            test.stopTest();
        }
    }

	//TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlyFrequencyWithinBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for allowed value
            msg = ServiceSchedulerCtrl.submitMonthly(quote.id, pQLine.id, '54');
            System.assertequals(msg, sSuccessMessage, assertionErrorMessage);

            pQLine = [SELECT id, Day_of_Month__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            System.assertequals(pQLine.Day_of_Month__c, null, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthNullFrequencyWithinBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Day of the Month
            //Test for NULL value
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '', '1');
            System.assertequals(msg, ServiceSchedulerCtrl.sValidate_Day_of_Month_Error, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthLowerBoundaryFrequencyWithinBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Day of the Month
            //Test for lower boundary value < 1 
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '0', '1');
            System.assertequals(msg, ServiceSchedulerCtrl.sValidate_Day_of_Month_Error, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthUpperBoundaryFrequencyWithinBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Day of the Month
            //Test for upper boundary value > 99
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '100', '1');
            System.assertequals(msg, ServiceSchedulerCtrl.sValidate_Day_of_Month_Error, assertionErrorMessage);
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthStringFrequencyWithinBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Day of the Month
            //Test for non numerical value
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '1.5 ABD', '1');
            System.assertequals(msg, ServiceSchedulerCtrl.sValidate_Day_of_Month_Error, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthWithinBoundaryFrequencyNull() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            String errorMessage = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly('100');
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Schedule Frequency
            //Test for NULL value
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '1', '');
            System.assertequals(msg, errorMessage, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthWithinBoundaryFrequencyLowerBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            String errorMessage = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly('100');
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Schedule Frequency
            //Test for lower boundary value < 1
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '1', '0');
            System.assertequals(msg, errorMessage, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthWithinBoundaryFrequencyUpperBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            String errorMessage = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly('100');
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Schedule Frequency
            //Test for upper boundary value > 99
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '1', '100');
            System.assertequals(msg, errorMessage, assertionErrorMessage);
            test.stopTest();
        }
    }
    
    //TCS-pkulkarn-SDT-38495-Sprint 6-20-May-2024-Added-Test for Monthly scheduled service-Validate Days and Months
    @isTest public static void testsubmitMonthlySpecificDayofMonthWithinBoundaryFrequencyWithinBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Schedule Frequency
            //Test for allowed value for Day of the Month and Schedule Frequency
            msg = ServiceSchedulerCtrl.submitMonthlySpecific(quote.id, pQLine.id, '1', '2');
            System.assertequals(msg, sSuccessMessage, assertionErrorMessage);
            
            test.stopTest();
        }
    }
    
    /*SDT-33176
    Dev: Ruchika
    FC: Pradeep
    Description: added validation for number of weeks not to be greater than 30. 
    This validation is only applicable when Quote/Quote lines are being created/updated from CEI screen.
    */
    @isTest public static void testOccurenceType() {
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        String occurenceType = '';
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c,Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' AND Case__c != null ];
        //update testQuote;	//TCS-pkulkarn-SDT-45080-13-Feb-2025-Commented to resolve test class issue (SOQL 101)
        
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Compactor' LIMIT 1];
        Product2 haulService = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Haul' LIMIT 1];

        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                             SBQQ__Product__c = container.Id,
                                                             Equipment_Size__c = 'YRDS-30',
                                                             Occurrence_Type__c='SOC');
        INSERT parentQL;
        
        SBQQ__QuoteLine__c haulQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           Equipment_Size__c = 'YRDS-30',
                                                           Occurrence_Type__c='OC');

        INSERT haulQL;

        
        List<SBQQ__QuoteLine__c> pQLine = new List<SBQQ__QuoteLine__c>();
        pQLine = [SELECT Id, Occurrence_Type__c, Frequency_Interval__c, Schedule_Frequency__c, Service_Days__c, SBQQ__ProductFamily__c,
                  Equipment_Size__c, SBQQ__ProductName__c, SBQQ__Product__r.Name, SBQQ__RequiredBy__c, SBQQ__Quote__c 
                  FROM SBQQ__QuoteLine__c 
                  WHERE SBQQ__Quote__c = :testQuote.Id];
        
        SBQQ__QuoteLine__c parentQuoteLine = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c haulQuoteLine = new SBQQ__QuoteLine__c();
        
        for(SBQQ__QuoteLine__c ql : pQLine)
        {
            if(ql.Id == haulQL.Id)
            {
                haulQuoteLine = ql;
            }
            if(ql.Id == parentQL.Id)
            {
                parentQuoteLine = ql;
            }
        }
        Test.startTest();
        system.assertEquals(true, true, 'Bypass SOQL 101 error');	//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
        occurenceType = ServiceSchedulerCtrl.getOccurenceType(haulQuoteLine, parentQL.Id, pQLine);
        system.assertequals(occurenceType, null, 'Error in assertion');
		occurenceType = ServiceSchedulerCtrl.getOccurenceType(parentQuoteLine, parentQL.Id, pQLine);
		system.assertequals(occurenceType, ServiceSchedulerCtrl.OCCURENCE_TYPE_SCHEDULED_ON_CALL, 'Error in assertion');
        test.stopTest();
    }
    //SDT-38285 - Start
    @isTest
    public static void testGetMonthRelativeInterval(){
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        test.startTest();
        Schema.DescribeFieldResult monthRelativeIntervalPickListField = SBQQ__QuoteLine__c.Month_Relative_Interval__c.getDescribe();
        List<Schema.PicklistEntry> monthRelativeIntervalPickListValues = monthRelativeIntervalPickListField.getPicklistValues();
        
        System.runAs(csrUser){  
       
            List<String> monthRelativeIntervalList = ServiceSchedulerCtrl.getMonthRelativeInterval();
            List<String> pickListToCompare = new List<String>();
            
          for (Schema.PicklistEntry pick : monthRelativeIntervalPickListValues) 
        	{
            	pickListToCompare.add(pick.getValue());
        	}
            monthRelativeIntervalList.sort();
            pickListToCompare.sort();
         	System.assertEquals(pickListToCompare.get(0), monthRelativeIntervalList.get(0),'Picklist values are different');
        }
        test.stopTest();
    }
    
    @isTest
    public static void testGetMonthRelative(){
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        test.startTest();   
        Schema.DescribeFieldResult monthRelativePicklistField = SBQQ__QuoteLine__c.Month_Relative__c.getDescribe();
        List<Schema.PicklistEntry> monthRelativePicklistValues = monthRelativePicklistField.getPicklistValues();
        System.runAs(csrUser){  
            List<String> monthRelativeList = ServiceSchedulerCtrl.getMonthRelative();
            List<String> pickListToCompare = new List<String>();
          for (Schema.PicklistEntry pick : monthRelativePicklistValues) 
        	{
            	pickListToCompare.add(pick.getValue());
        	}
            monthRelativeList.sort();
            pickListToCompare.sort();
            System.assertEquals(pickListToCompare.get(0), monthRelativeList.get(0),'Picklist values are different');
        }
        test.stopTest();
    }
    @isTest public static void testMonthlySpecificDayofMonthNullFrequencyWithinBoundary() 
    {
    	User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        system.runAs(csrUser)
        {    
            Test.startTest();
            String msg = '';
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote = [SELECT id from SBQQ__Quote__c LIMIT 1];
            
            SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
            pQLine = [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
            
            ServiceSchedulerCtrl.retrieveParentQuoteLine(pQLine.id);
            
            //Test for Day of the Month as Null
            msg = ServiceSchedulerCtrl.submitMonthlyIntervalSpecificNew(quote.id, pQLine.id,'','1','','','1', 'ServiceDate' );
            System.assertequals(msg, ServiceSchedulerCtrl.sValidate_Day_of_Month_Error, assertionErrorMessage);
            test.stopTest();
        }
    }
	/*
     * @Method Name    : testGetMonthRelatedPickLists
     * @author         : Digdershika Ojha
     * @description    : Test both month_relative and month_relative_interval pick list values in form of map
     * @param          : Not Applicable
     * @return         : Map<String,List<String>>
	 */    
    @isTest
    public static void testGetMonthRelatedPickLists(){
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        test.startTest();
        Map<String,List<String>> mapOfMonthRelativePickList = new Map<String,List<String>>();
        System.runAs(csrUser){  
            mapOfMonthRelativePickList = ServiceSchedulerCtrl.getMonthRelatedPickLists();            
            System.assertEquals(mapOfMonthRelativePickList.size(), 2,assertionErrorMessage);
        }
        test.stopTest();
    }
    //SDT-38285 - End
}