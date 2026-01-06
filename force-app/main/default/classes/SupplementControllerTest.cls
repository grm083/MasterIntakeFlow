@isTest public class SupplementControllerTest {
    
    @testSetup public static void setupData()
    {
        String SYS_ADMIN = 'System Administrator';
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        //Insert products
        List<Product2> prodList = new List<Product2>();
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT');
        Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
        Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV');
        Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        prodList.add(container);
        prodList.add(haulService);
        prodList.add(deliveryService);
        prodList.add(trashCategory);
        prodList.add(trashStream);
        insert prodList;
        
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
        testQuote.Project_Services_Request__c = false;
        //addition for S11 test class error
        testQuote.SBQQ__Opportunity2__c = oppList[0].Id; 
        insert testQuote;
        
        String stime = '02:00:00.000Z';
        String etime = '19:00:00.000Z';
        String [] strStartTime = stime.split(':');
        String [] strEndTime = etime.split(':');
        Time tmStartTime = Time.newInstance(Integer.valueOf(strStartTime[0]), Integer.valueOf(strStartTime[1]), 0, 0); 
        Time tmEndTime = Time.newInstance(Integer.valueOf(strEndTime[0]), Integer.valueOf(strEndTime[1]), 0, 0);
        
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                             SBQQ__Product__c = container.Id,
                                                             Equipment_Size__c = 'YRDS-30',
                                                             Profile_Number__c = '123456',
                                                             Landfill_Tickets__c = true,
                                                             Other_Paperwork_Needs__c = 'otherPaperWorkNeeded',
                                                             Certificate_of_Destruction__c=true,
                                                             Certificate_of_Disposal__c = true,
                                                             restricted_hours_of_operation__c = true,
                                                             Requires_Push_In_Push_Out_Service__c = true,
                                                             Container_in_a_Restricted_Area__c= true,
                                                             Restriction_Details__c = 'Trespassing',
                                                             Service_Start_Time__c = tmStartTime,
                                                             Service_End_Time__c = tmEndTime,
                                                             Gate_Code__c = 'Gate Code 123',
                                                             Special_Disposal_Description__c = 'Test Special Disposal Description');
        insert parentQL;
    }
    
    @isTest public static void testSupplement1() {
        
        Test.startTest();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT id,Project_Services_Request__c,Project__c from SBQQ__Quote__c LIMIT 1];
        
        SBQQ__QuoteLine__c pQLine = new SBQQ__QuoteLine__c();
        pQLine = [SELECT id, Profile_Number__c, Landfill_Tickets__c, Other_Paperwork_Needs__c, Certificate_of_Destruction__c,
                          Certificate_of_Disposal__c, Container_in_a_Restricted_Area__c,restricted_hours_of_operation__c,Requires_Push_In_Push_Out_Service__c,
                          SBQQ__Quote__c, SBQQ__Quote__r.Project_Services_Request__c, SBQQ__Quote__r.Project__c,Restriction_Details__c,
                          Service_Start_Time__c, Service_End_Time__c, Gate_Code__c, Special_Disposal_Description__c
                          FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quote.Id AND SBQQ__RequiredBy__c=null LIMIT 1];
        SupplementController.getParentQuote(pQLine.id);
        SupplementController.assignSuppWrapper(pQLine);
        SupplementController.assignDestructionType(pQLine);
        SupplementController.supplementWrapper  supplementWrapperTest = SupplementController.getParentQuote(pQLine.id);
        String supplementWrapperJSON = JSON.serialize(supplementWrapperTest);
        //system.debug('wrapper ' + supplementWrapperJSON);
        SupplementController.updateQuoteLines(supplementWrapperJSON);

        system.assert(supplementWrapperTest != null);
        test.stopTest();
    }
     
}