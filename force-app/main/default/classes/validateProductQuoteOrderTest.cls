@isTest public class validateProductQuoteOrderTest {
    @testSetup public static void setupData() {
        test.startTest();
        String SYS_ADMIN = 'System Administrator';
        List<Product2> prodList = insertProducts();
        List<Account> acctList = insertAccounts();
        List<MAS_Setup_Detail__c> MASList = insertMAs();
        
        //inserting user for S11 test class errors
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        //inserting location account for S11 test class errors
        List<Account> locationAccList = TestDataFactory.createLocation('location account', usr, acctList[0].Id);
        insert locationAccList;
        
        //inserting contact for S11 test class errors
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acctList.get(1), usr);
        Database.insert(conlist);
        
        //inserting case for S11 test class errors
        Case pickupCase = QuoteTestDataFactory.createCase('Pickup Case','Pickup','Extra Pickup','', acctList[1],conlist[0], locationAccList[0]);
        Database.insert(pickupCase);
        
        //opportunity for case - addtion for S11 test class error
        List<Opportunity> oppList = TestDataFactory.createOpportunity(1,'TestOpportunityTest',pickupCase.Id,pickupCase.Case_Sub_Type__c, acctList[0].Id); //PK
        oppList[0].Duration__c='Temporary';
        Database.insert(oppList);

        //insert Quote
        SBQQ__Quote__c draftQuote = new SBQQ__Quote__c();
        draftQuote.SBQQ__Account__c = acctList[0].id;
        draftQuote.SBQQ__Status__c = 'Draft';
        draftQuote.Duration__c = 'Temporary';
        draftQuote.SBQQ__StartDate__c = system.today();
        //addtion for S11 test class error
        draftQuote.SBQQ__Opportunity2__c = oppList[0].Id;
        insert draftQuote;
        test.stopTest();
    }
    public static List<Product2> insertProducts(){
        List<Product2> prodList = new List<Product2>();
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
        Product2 managementFee = new Product2(Name = 'Management Fee', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
        Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV',  Bypass_Acorn_Integration__c=false);
        Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
        Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
        prodList.add(container);
        prodList.add(haulService);
        prodList.add(deliveryService);
        prodList.add(trashCategory);
        prodList.add(trashStream);
        prodList.add(managementFee);
        insert prodList;
        return prodList;
    }
    public static List<Account> insertAccounts(){
        List<Account> acctList = new List<Account>();
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
        RecordType vendorType = [SELECT Id FROM RecordType WHERE Name = 'Vendor'];
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = customerType.Id);
        Account parentCustomer = new Account(Name = 'Test Parent', RecordTypeId = customerType.Id,AccountNumber = '81');
        Account childVendor = new Account(Name = 'Test Vendor', RecordTypeId = vendorType.Id,
                                    Status__c = 'Active', AccountNumber = '111266', Vendor_Business_Unit__c = '1');
        Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorType.Id,
                                    Status__c = 'Active', AccountNumber = '8');
        Account wmVendor = new Account(Name = 'WM', RecordTypeId = vendorType.Id,
                                       Status__c = 'Active', AccountNumber = '8');
        Account wmFeeVendor = new Account(Name = 'WM Fee', RecordTypeId = vendorType.Id,
                                          Status__c = 'Active', AccountNumber = '8');
        acctList.add(customer);
        acctList.add(parentCustomer);
        acctList.add(childVendor);
        acctList.add(parentVendor);
        acctList.add(wmVendor);
        acctList.add(wmFeeVendor);
        insert acctList;
        
        acctList[2].ParentId = acctList[3].id;
        acctList[0].ParentId = acctList[1].id;
        update acctList;
        
        return acctList;
    }
    public static List<MAS_Setup_Detail__c> insertMAs(){
        List<MAS_Setup_Detail__c> MASList = new List<MAS_Setup_Detail__c>();
        MAS_Setup_Detail__c MAS1 = New MAS_Setup_Detail__c(Business_Unit_Number__c = '1', MAS_Company_Code__c='100', 
                                                           MAS_Library__c='100A', MAS_Line_of_Business__c='O');
        MAS_Setup_Detail__c MAS2 = New MAS_Setup_Detail__c(Business_Unit_Number__c = '1', MAS_Company_Code__c='100', 
                                                           MAS_Library__c='100A', MAS_Line_of_Business__c='C');
        MAS_Setup_Detail__c MAS3 = New MAS_Setup_Detail__c(Business_Unit_Number__c = '2', MAS_Company_Code__c='101', 
                                                           MAS_Library__c='100A', MAS_Line_of_Business__c='O');
        MASList.add(MAS1);
        MASList.add(MAS2);
        MASList.add(MAS3);
        insert MASList;
        return MASList;
    }
    @isTest public static void qdraftTest(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        
        Product2 deliveryService = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Delivery' LIMIT 1];
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                            Occurrence_Type__c='SOC');
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = deliveryService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W');
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine, qLine1});
        insert qLineList;
        testQuote.SBQQ__Status__c = 'Procure Service';
        try{
          update  testQuote;
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        Test.stopTest();
        
    }
}