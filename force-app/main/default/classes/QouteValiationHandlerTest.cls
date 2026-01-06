@isTest public class QouteValiationHandlerTest {
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string KROGER = 'kroger';
        private static final string PO_PSI_VALUE = 'PO Number;Profile Number';
        public static String assertionErrorMessage = 'Error occured during assertion check';	//TCS-pkulkarn-13-Mar-2024-SDT-33303-Added

    
    @testSetup public static void setupData() {
        String SYS_ADMIN = 'System Administrator';
        List<Product2> prodList = insertProducts();
        List<Account> acctList = insertAccounts();
        List<MAS_Setup_Detail__c> MASList = insertMAs();
        //Changes related to SDT-39632
        List<SBQQ__QuoteLine__c> childQlList= new List<SBQQ__QuoteLine__c>();

        test.startTest();
        //inserting user for S11 test class errors
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.Bypass_Validation__c = TRUE;
        usr.FirstName = 'testuser#9999';
        Database.insert(usr);  
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        //TCS-pkulkarn-13-Mar-2024-SDT-33303-Added System.runas(), csrUser and createVendorAccounts()
        System.runAs(usr){
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        createVendorAccounts(usr);
        //inserting contact for S11 test class errors
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acctList.get(1), usr);
        Database.insert(conlist);
        
        list<Case> caselist = new list<Case>(); 
            Case cs = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = conlist[0].id, 
                               AccountId = acctList[0].Id, OwnerId = usr.id, Client__c = acctList[1].Id, Location__c = acctList[0].id, 
                               Case_Type__c = 'New Service', Case_Sub_Type__c = 'Permanent', Case_Reason__c = 'Existing Location',
                               SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
            caselist.add(cs);
            insert caselist;
            
        
        
        //inserting case for S11 test class errors
        Case pickupCase = QuoteTestDataFactory.createCase('Pickup Case','Pickup','Extra Pickup','', acctList[1],conlist[0], acctList[0]);
        Database.insert(pickupCase);
        
        Case pickupCase2 = QuoteTestDataFactory.createCase('New Service Case','New Service','Permanent','Existing Location', acctList[1],conlist[0], acctList[0]);
        Database.insert(pickupCase2);
        
        //opportunity for case - addtion for S11 test class error
        List<Opportunity> oppList = TestDataFactory.createOpportunity(1,'TestOpportunityTest',pickupCase.Id,pickupCase.Case_Sub_Type__c, acctList[0].Id); //PK
        oppList[0].Duration__c='Temporary';
        Database.insert(oppList);
        
        List<Opportunity> oppList2 = TestDataFactory.createOpportunity(1,'TestOpportunityTest',caselist[0].Id,caselist[0].Case_Sub_Type__c, acctList[0].Id); //PK
        oppList2[0].Duration__c='Temporary';
        Database.insert(oppList2);
        
         //SDT-33363- inserting asset and location

        list<Account> locationlist = TestDataFactory.createLocation('Location', usr, acctList[0].id);

        Database.insert(locationlist);

        

        List<Asset> assetList = TestDataFactory.createAsset('first', acctList[0], conlist[0], 

                                                                prodList[0], usr, locationlist[0]);

        Database.insert(assetList);
        
        Test.stopTest();
        //insert Quote
        List<SBQQ__Quote__c> qListNew   = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c draftQuote = new SBQQ__Quote__c();
        draftQuote.SBQQ__Account__c = acctList[0].id;
        draftQuote.SBQQ__Status__c = 'Draft';
        draftQuote.Duration__c = 'Temporary';
        draftQuote.SBQQ__StartDate__c = system.today();
        //addtion for S11 test class error
        draftQuote.SBQQ__Opportunity2__c = oppList[0].Id;
         qListNew.add(draftQuote);
         
        SBQQ__Quote__c draftQuote1 = new SBQQ__Quote__c();
        draftQuote1.SBQQ__Account__c = acctList[2].id;
        draftQuote1.SBQQ__Status__c = 'Cost Configured';
        draftQuote1.Duration__c = 'Temporary';
        draftQuote1.SBQQ__StartDate__c = system.today();
        //addtion for S11 test class error
        draftQuote1.SBQQ__Opportunity2__c = oppList2[0].Id;
        qListNew.add(draftQuote1);
        
        insert qListNew;
            
            //Changes related to SDT-39632 - Inserting Parent Quoteline record.
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(qListNew[0],prodList[0],'TEMP',1.00,'CLT',
                                                                                'YRDS-20','OC','D','1','PER',34.00,'DYS',
                                                                                'PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            //parentQl.Location_Position_Name__c= accPosition.id;
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__RequiredBy__c= null;
            parentQl.SBQQ__Number__c=0;
            parentQl.Account__c = locationList[0].id;
            parentQl.MASLibrary__c = 'ARDTA.129A';
            parentQl.Duration__c = 'TEMP';
            parentQl.Vendor__c = acctList[4].Id;
            parentQl.SetupComment__c = 'test';
            parentQl.MASCompany__c = '286';
            parentQl.MASCustomerUniqueId__c = 1;
            
            Insert parentQl;
            
            //Changes related to SDT-39632 - Inserting child Quoteline record.
            for(Integer i=0;i<4;i++)
            {
                childQlList.add(TestDataFactory.createQuoteLineRecords(qListNew[0],prodList[i+1],'TEMP',1.00,'CLT','YRDS-20','OC',null,
                                                                       null,'PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
                childQlList[i].SBQQ__StartDate__c= Date.today();
                childQlList[i].SBQQ__EndDate__c= Date.today().addDays(25);
                childQlList[i].SBQQ__RequiredBy__c= parentQl.Id;
                childQlList[i].SBQQ__Number__c=i+3;
                childQlList[i].Account__c = locationList[0].id;
                childQlList[i].MASLibrary__c = 'ARDTA.129A';
                childQlList[i].Vendor__c = acctList[3].Id;
                childQlList[i].MASCustomerUniqueId__c = 1;
            }
            Insert childQLList;
            
            Quote_Order__c qo = new Quote_Order__c();
            qo.Quote_Line__c= parentQl.id;
            qo.Service_Quote_Line__c= childQlList[1].id;
            qo.Service_Type__c='Delivery';
            qo.Product_Type__c='Delivery';
            qo.Service_Date__c= Date.today();
            qo.Instructions__c= 'test1234';
            qo.Onsite_Contact__c = 'test';
            qo.Onsite_Contact_Phone__c = '9999999';
            qo.Cust_Ref_Number__c='test12345';
            qo.Duration__c='PERM';
            qo.Occurrence_Type__c='OC';
            qo.Quantity__c = 20;
            qo.Service_Time_Span__c= 'ASAP';
            insert qo;
        
        //new setupData
        
        
        
        
        list<Business_Rule__c> brlist = new list<Business_Rule__c>();
            Business_Rule__c brObj = new Business_Rule__c();
            brObj.Accountid__c = caselist[0].Client__c;
            brObj.LocationId__c = caselist[0].Location__c;
            brObj.Request_Type__c = 'New Service';
            brObj.Service__c = 'Permanent';
            brObj.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
            //brObj.Required_Information__c = PO_PSI_VALUE; 
            brObj.Effective_Date__c = System.today()-1;
            brObj.Active__c=True;
            brObj.NTE_Rules__c=True;
            brlist.add(brObj);
            Database.insert(brlist);
        }
         
            
        
        
        
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
        //addition for S11 test class errors
        RecordType locationType = [SELECT Id FROM RecordType WHERE Name = 'Location'];
        RecordType vendorType = [SELECT Id FROM RecordType WHERE Name = 'Vendor'];
        //addition for S11 test class errors - changed recordtype to location
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = locationType.Id,Status__c = 'Active');
        Account parentCustomer = new Account(Name = 'Test Parent', RecordTypeId = customerType.Id,AccountNumber = '81',Status__c = 'Active');
        Account childVendor = new Account(Name = 'Test Vendor', RecordTypeId = vendorType.Id,
                                    Status__c = 'Active', AccountNumber = '111266', Vendor_Business_Unit__c = '1');
        //Changes related to SDT-39632 
        Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorType.Id,
                                           Status__c = 'Active', AccountNumber = '12');
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
        acctList[4].ParentId = acctList[3].id;
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
    
    @isTest public static void NTETestMethodNew2(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        //Changes related to SDT-39632
        Account wmVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM' LIMIT 1];
        
        
        
        Business_Rule__c brRule = [Select Id,Alias__c,NTE_Rules__c,Category_Type__c,Required_Information__c,AccountId__c,Case_Reason__c,
                                                 LocationId__c,Group__c,RecordTypeId,End_Date__c,
                                                 Container__c,Material__c,Service__c,Schedule_Type__c,
                                                 Project_Code__c,AssetId__c from Business_Rule__c where  Request_Type__c = 'New Service' Limit 1];
        
            Service_Approver__c newSA = new Service_Approver__c();
            Id rtId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get('NTE_Approval').getRecordTypeId();
            newSA.Service_Type__c = 'Pickup';
            newSA.RecordTypeId = rtId;
            newSA.Business_Rule__c = brRule.Id;
            newSA.NTE_Rule_ExtId__c = 'Pickup' + '-'+brRule.Id;
            newSA.NTE_Amount__c = 100;
            newSA.Account__c = brRule.AccountId__c;
            newSA.Location__c = brRule.LocationId__c;
            newSA.Active__c = True;
            insert newSA;   
        
            brRule.Active__c = true; 
            update brRule;
            
                    
            
            
            
        
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                             //Changes related to SDT-39632
                                                             Vendor__c =wmVendor.Id,
                                                             Occurrence_Type__c='SOC',
                                                             MASLibrary__c='ARDTA.180',
                                                             MASCompany__c='test mas company',
                                                             SetupComment__c = 'test',
                                                              Exception_Type__c ='CLTINITCHG',
                                                              Exception_Reason__c = 'NEWSRV',
                                                              Exception_Comments__c = 'testing exception');
        Test.startTest();
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                          //Changes related to SDT-39632
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W',
                                                          Frequency_Interval__c='1',
                                                          Vendor__c =wmVendor.Id,
                                                          Service_Days__c='M',
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company',
                                                          SetupComment__c = 'test',
                                                          PriceUOM__c = 'MTH',
                                                          SBQQ__ListPrice__c = 0,
                                                          Exception_Type__c ='CLTINITCHG',
                                                          Exception_Reason__c = 'NEWSRV',
                                                          Exception_Comments__c = 'testing exception');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           //Changes related to SDT-39632
                                                           Vendor__c =wmVendor.Id,
                                                           Occurrence_Type__c='SOC',
                                                           Schedule_Frequency__c='W',
                                                           Frequency_Interval__c='1',
                                                           Service_Days__c='M',
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company',
                                                          SetupComment__c = 'test',
                                                          PriceUOM__c = 'MTH',
                                                          SBQQ__ListPrice__c = 0,
                                                          Exception_Type__c ='CLTINITCHG',
                                                          Exception_Reason__c = 'NEWSRV',
                                                          Exception_Comments__c = 'testing exception');
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
        insert qLineList;
        

        testQuote.SBQQ__Status__c = 'Approved';
        update testQuote;
        
        Test.stopTest();
        
    }
    @isTest public static void qdraftTest1(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                             Occurrence_Type__c='SOC',
                                                             //Changes related to SDT-39632
                                                           	 Schedule_Frequency__c='W',
                                                             Service_Days__c='M');
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          //Changes related to SDT-39632
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           Occurrence_Type__c='SOC',
                                                           Schedule_Frequency__c='W',
                                                           //Changes related to SDT-39632
                                                           Service_Days__c='M');
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
        insert qLineList;
        testQuote.SBQQ__Status__c = 'Product Configured';
        try{
          update  testQuote;
          testQuote.SBQQ__Status__c = 'Cost Configured';
          update testQuote;
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        Test.stopTest();
        
    }
     @isTest public static void qdraftTestNew(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        
         //SDT-33363
        List<Account> acctList = insertAccounts();
        Asset testAsset = [SELECT Id,Name FROM Asset LIMIT 1]; 
        
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                            Occurrence_Type__c='OC', 
                                                            Vendor__c =acctList[2].Id,
                                                            SBQQ__UnitCost__c = 10,
                                                            IsAssetQuotelineDifferent__c = false,
                                                            AssetId__c = testAsset.Id );//SDT-33363
        Test.startTest();
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           Occurrence_Type__c='OC',
                                                          //Changes related to SDT-39632
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          Vendor__c =acctList[2].Id,
                                                           SBQQ__UnitCost__c = 10,

                                                           IsAssetQuotelineDifferent__c = false,

                                                           AssetId__c = testAsset.Id 

                                                            ); //SDT-33363
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           //Changes related to SDT-39632
                                                           Cost_Unit_of_Measure__c='DYS',
                                                           CostModelType__c='PER',
                                                           Vendor__c =acctList[2].Id,
                                                           Occurrence_Type__c='OC',
                                                           SBQQ__UnitCost__c = 10,

                                                           IsAssetQuotelineDifferent__c = false,

                                                           AssetId__c = testAsset.Id 

                                                          ); //SDT-33363
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
        insert qLineList;

        testQuote.SBQQ__Status__c = 'Cost Configured';
        update  testQuote;
        
        
        Test.stopTest();
        
        try{
          
          
          /*testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Cost Configured' LIMIT 1];
            testQuote.SBQQ__Status__c='Price Configured';
            update  testQuote;*/
        
          
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        
        
    }
    @isTest public static void NTETestMethodNew(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        //Changes related to SDT-39632
        Account wmVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM' LIMIT 1];

        
        
        
        Business_Rule__c brRule = [Select Id,Alias__c,NTE_Rules__c,Category_Type__c,Required_Information__c,AccountId__c,Case_Reason__c,
                                                 LocationId__c,Group__c,RecordTypeId,End_Date__c,
                                                 Container__c,Material__c,Service__c,Schedule_Type__c,
                                                 Project_Code__c,AssetId__c from Business_Rule__c where  Request_Type__c = 'New Service' Limit 1];
        
            Service_Approver__c newSA = new Service_Approver__c();
            Id rtId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get('NTE_Approval').getRecordTypeId();
            newSA.Service_Type__c = 'Pickup';
            newSA.RecordTypeId = rtId;
            newSA.Business_Rule__c = brRule.Id;
            newSA.NTE_Rule_ExtId__c = 'Pickup' + '-'+brRule.Id;
            newSA.NTE_Amount__c = 100;
            newSA.Account__c = brRule.AccountId__c;
            newSA.Location__c = brRule.LocationId__c;
            newSA.Active__c = True;
            insert newSA;   
        
            brRule.Active__c = true; 
            update brRule;
            
                    
            
            
            
        
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                             //Changes related to SDT-39632
                                                             Vendor__c =wmVendor.Id,
                                                             Occurrence_Type__c='SOC',
                                                             MASLibrary__c='ARDTA.180',
                                                             MASCompany__c='test mas company',
                                                             SetupComment__c = 'test',
                                                             Exception_Type__c ='CLTINITCHG',
                                                             Exception_Reason__c = 'NEWSRV',
                                                             Exception_Comments__c = 'testing exception');
        Test.startTest();
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                          //Changes related to SDT-39632
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W',
                                                          Frequency_Interval__c='1',
                                                          Vendor__c =wmVendor.Id,
                                                          Service_Days__c='M',
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company',
                                                          SetupComment__c = 'test',
                                                          PriceUOM__c = 'MTH',
                                                          SBQQ__ListPrice__c = 0,
                                                          Exception_Type__c ='CLTINITCHG',
                                                          Exception_Reason__c = 'NEWSRV',
                                                          Exception_Comments__c = 'testing exception');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           //Changes related to SDT-39632
                                                           Vendor__c =wmVendor.Id,
                                                           Occurrence_Type__c='SOC',
                                                           Schedule_Frequency__c='W',
                                                           Frequency_Interval__c='1',
                                                           Service_Days__c='M',
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company',
                                                          SetupComment__c = 'test',
                                                          PriceUOM__c = 'MTH',
                                                          SBQQ__ListPrice__c = 0,
                                                          Exception_Type__c ='CLTINITCHG',
                                                          Exception_Reason__c = 'NEWSRV',
                                                          Exception_Comments__c = 'testing exception');
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
        insert qLineList;
        

        testQuote.SBQQ__Status__c = 'Approved';
        update testQuote;
        
        Test.stopTest();
        
    }
    
     @isTest public static void qdraftTestNew2(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='draft'   LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        //Changes related to SDT-39632
        Account wmVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM' LIMIT 1];
        
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                            PriceUOM__c = 'MTH',
                                                            Occurrence_Type__c='OC',
                                                            SBQQ__UnitCost__c = 0,
                                                            Cost_Unit_of_Measure__c = 'MTH',
                                                            CostModelType__c = 'REB',
                                                             Schedule_Frequency__c = null,
                                                           Frequency_Interval__c = null,
                                                            MASCompany__c = '202',
                                                            CostPrice1__c = 20,
                                                            PricePrice1__c = 20,
                                                            PricePrice2__c = 10,
                                                            CostPrice2__c = 10,
                                                             //Changes related to SDT-39632
                                                             SBQQ__ListPrice__c = 0,
                                                            SetupComment__c = 'test',
                                                            MASLibrary__c = 'ARDTA.132A',
                                                             Vendor__c = wmVendor.Id);
        Test.startTest();
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           Occurrence_Type__c='OC',
                                                           PriceUOM__c = 'MTH',
                                                           MASCompany__c = '202',
                                                           CostPrice1__c = 20,
                                                            CostPrice2__c = 10,
                                                            PricePrice1__c = 20,
                                                            PricePrice2__c = 10,
                                                           Cost_Unit_of_Measure__c = 'MTH',
                                                           Schedule_Frequency__c = null,
                                                           SetupComment__c = 'test',
                                                           Frequency_Interval__c = null,
                                                           SBQQ__UnitCost__c = 0,
                                                          //Changes related to SDT-39632
                                                          SBQQ__ListPrice__c = 0,
                                                            CostModelType__c = 'PER',
                                                            MASLibrary__c = 'ARDTA.132A',
                                                          Vendor__c = wmVendor.Id);
                                                           
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           Occurrence_Type__c='OC',
                                                           PriceUOM__c = 'MTH',
                                                           MASCompany__c = '202',
                                                           CostPrice1__c = 20,
                                                            CostPrice2__c = 10,
                                                            PricePrice1__c = 20,
                                                            PricePrice2__c = 10,
                                                           SetupComment__c = 'test',
                                                           SBQQ__UnitCost__c = 0,
                                                           Frequency_Interval__c = null,
                                                            CostModelType__c = 'STP',
                                                            SBQQ__PricingMethod__c = 'STP',
                                                           
                                                            MASLibrary__c = 'ARDTA.132A',
                                                           Cost_Unit_of_Measure__c = 'MTH',
                                                          Schedule_Frequency__c=null,
                                                           Vendor__c = wmVendor.Id,
                                                           //Changes related to SDT-39632
                                                           SBQQ__ListPrice__c = 0);
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
        insert qLineList;
 
        testQuote.SBQQ__Status__c = 'Price Configured';
        update  testQuote;
        
        
        Test.stopTest();
        
        try{
          
          
          /*testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Cost Configured' LIMIT 1];
            testQuote.SBQQ__Status__c='Price Configured';
            update  testQuote;*/
        
          
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        
        
    }
    @isTest public static void NTETestMethod(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='draft' LIMIT 1];
        testQuote.SBQQ__StartDate__c = Date.today();
        update testQuote;
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        //Changes related to SDT-39632
        Account wmVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM' LIMIT 1];
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                             //Changes related to SDT-39632
                                                             Vendor__c =wmVendor.Id,
                                                             Occurrence_Type__c='SOC',
                                                             MASLibrary__c='ARDTA.180',
                                                             MASCompany__c='test mas company',
                                                             SetupComment__c = 'test',
                                                              Exception_Type__c ='CLTINITCHG',
                                                              Exception_Reason__c = 'NEWSRV',
                                                              Vendor_Commit_Date__c = Date.today(),
                                                              Exception_Comments__c = 'testing exception');
        Test.startTest();
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                          //Changes related to SDT-39632
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W',
                                                          Frequency_Interval__c='1',
                                                          Vendor__c =wmVendor.Id,
                                                          Service_Days__c='M',
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company',
                                                          SetupComment__c = 'test',
                                                          PriceUOM__c = 'MTH',
                                                          SBQQ__ListPrice__c = 0,
                                                          Exception_Type__c ='CLTINITCHG',
                                                          Exception_Reason__c = 'NEWSRV',
                                                          Exception_Comments__c = 'testing exception');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                           SBQQ__Product__c = haulService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           //Changes related to SDT-39632
                                                           Vendor__c =wmVendor.Id,
                                                           Occurrence_Type__c='SOC',
                                                           Schedule_Frequency__c='W',
                                                           Frequency_Interval__c='1',
                                                           Service_Days__c='M',
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company',
                                                          SetupComment__c = 'test',
                                                          PriceUOM__c = 'MTH',
                                                          SBQQ__ListPrice__c = 0,
                                                          Exception_Type__c ='CLTINITCHG',
                                                          Exception_Reason__c = 'NEWSRV',
                                                          Exception_Comments__c = 'testing exception');
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
        insert qLineList;
        

        testQuote.SBQQ__Status__c = 'Approved';
        update testQuote;
        
        Test.stopTest();
        
    }
    @isTest public static void qdraftTest2(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        
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
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine});
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
    @isTest public static void qdraftTest3(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        
        Test.startTest();
        
        testQuote.SBQQ__Status__c = 'Procure Service';
        try{
          update  testQuote;
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        Test.stopTest();
        
    }
    @isTest public static void qProductConfiguredTest1(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Test.startTest();
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        
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
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M');
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine});
        insert qLineList;
        //testQuote.SBQQ__Status__c = 'Product Configured';
        try{
            /*update  testQuote;
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Product Configured' LIMIT 1];
            testQuote.SBQQ__Status__c='Cost Configured';
            update  testQuote;*/
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        Test.stopTest();
        
    }
    @isTest public static void qProductConfiguredTest2(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        Test.startTest();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
         
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        Account parentVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='Parent Vendor' LIMIT 1];
        
       
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
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M',
                                                          vendor__c = parentVendor.id);
        SBQQ__QuoteLine__c qLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M',
                                                          vendor__c = parentVendor.id,
                                                          SBQQ__UnitCost__c=2);
        
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1,qLine2});
        insert qLineList;
        //testQuote.SBQQ__Status__c = 'Product Configured';
        try{
           /* update  testQuote;
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Product Configured' LIMIT 1];
            testQuote.SBQQ__Status__c='Cost Configured';
            update  testQuote;*/
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        Test.stopTest();
        
    }
    @isTest public static void qProductConfiguredTest3(){
       
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        Product2 managementFee = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Management Fee' LIMIT 1];
         Test.startTest();
        Account parentVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='Parent Vendor' LIMIT 1];
        Account wmVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM' LIMIT 1];
        Account wmFeeVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM Fee' LIMIT 1];
        
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
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M',
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M',
                                                          vendor__c = parentVendor.id,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER');
        SBQQ__QuoteLine__c qLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='W',
                                                          Service_Days__c='M',
                                                          vendor__c = parentVendor.id,
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER');
        SBQQ__QuoteLine__c qLine3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='SOC',
                                                          Schedule_Frequency__c='D',
                                                          vendor__c = parentVendor.id,
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='REB');
        SBQQ__QuoteLine__c qLine4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='OC',
                                                          vendor__c = wmVendor.id,
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='REB',
                                                          Schedule_Frequency__c='D',
                                                          Frequency_Interval__c='1');
        SBQQ__QuoteLine__c qLine5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='OC',
                                                          vendor__c = wmVendor.id,
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='REB',
                                                          Schedule_Frequency__c='D',
                                                          Frequency_Interval__c='1',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company');
        SBQQ__QuoteLine__c qLine6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = managementFee.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='OC',
                                                          vendor__c = wmFeeVendor.id,
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='REB',
                                                          Schedule_Frequency__c='D',
                                                          Frequency_Interval__c='1',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company');
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1,qLine2,qLine3, qLine4, qLine5, qLine6});
        insert qLineList;
        /*test.stopTest();
        testQuote.SBQQ__Status__c = 'Product Configured';*/
        try{
            update  testQuote;
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Product Configured' LIMIT 1];
            testQuote.SBQQ__Status__c='Cost Configured';
            update  testQuote;
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        
    }
    @isTest public static void qPriceConfiguredTest(){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        //Product2 managementFee = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Management Fee' LIMIT 1];
        
        Account parentVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='Parent Vendor' LIMIT 1];
        //Account wmVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM' LIMIT 1];
       // Account wmFeeVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM Fee' LIMIT 1];
        
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        //S11 update for test class error -added vendor
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                            vendor__c = parentVendor.id,
                                                            Occurrence_Type__c='SOC');
        Test.startTest();
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                          SBQQ__Product__c = haulService.Id,
                                                          SBQQ__RequiredBy__c = parentQL.Id,
                                                          Occurrence_Type__c='OC',
                                                          vendor__c = parentVendor.id,
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='PER',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company');
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine});
        insert qLineList;

        testQuote.SBQQ__Status__c = 'Product Configured';
        update  testQuote;
        Test.stopTest();
        /*testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Product Configured' LIMIT 1];
        testQuote.SBQQ__Status__c='Cost Configured';
        update  testQuote;*/
        try{
           /* testQuote.SBQQ__Status__c='Price Configured';
            update  testQuote;*/
        }
        catch(exception ex){
            system.debug('error is '+ex.getMessage());
        }
        

    }
    
    // Method: testvalidateSetupComment1
    // Usage : To test the method QouteValiationHandler.validateSetupComment()
    // Defect/Story/Author: TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
    @isTest public static void testvalidateSetupComment1()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            Test.startTest();
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
            Account wmVendorAccount = [SELECT Id from Account WHERE Name = 'WMVendorChild' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                SBQQ__Product__c = container.Id,
                                                                Equipment_Size__c = 'YRDS-30',
                                                                Occurrence_Type__c='SOC',
                                                                Vendor__c = wmVendorAccount.Id);
            insert parentQL;
            
            //Test 1-Positive scenario-Quote Line with WM Vendor, Setup Comment = NULL, DoNotCreateTaskGridTickets__c = false (default value is FALSE)
            SBQQ__QuoteLine__c qLine = createHaulLine(testQuote.Id, haulService.Id, parentQL.Id);
            INSERT qLine;
            
            qLine.vendor__c = wmVendorAccount.Id;
            UPDATE qLine;
            
            testQuote.SBQQ__Status__c = 'Product Configured';
            UPDATE  testQuote;
            
            try
            {
                testQuote.SBQQ__Status__c='Cost Configured';
                UPDATE  testQuote;
            }
            catch(exception ex){
                //system.debug('error is '+ex.getMessage());
                System.assertEquals(true, ex.getMessage().contains(haulService.Name + QouteValiationHandler.strSetupComment), assertionErrorMessage);
            }
            
            test.stopTest();
        }
    }
    
    // Method: testvalidateSetupComment2
    // Usage : To test the method QouteValiationHandler.validateSetupComment()
    // Defect/Story/Author: TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
    @isTest public static void testvalidateSetupComment2()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            Test.startTest();
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
            Account wmVendorAccount = [SELECT Id from Account WHERE Name = 'WMVendorChild' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                SBQQ__Product__c = container.Id,
                                                                Equipment_Size__c = 'YRDS-30',
                                                                Occurrence_Type__c='SOC',
                                                                Vendor__c = wmVendorAccount.Id);
            insert parentQL;
            
            //Test 1-Positive scenario-Quote Line with WM Vendor, Setup Comment = NULL, DoNotCreateTaskGridTickets__c = true (default value is FALSE)
            SBQQ__QuoteLine__c qLine = createHaulLine(testQuote.Id, haulService.Id, parentQL.Id);
            INSERT qLine;
            
            qLine.DoNotCreateTaskGridTickets__c = true;
            qLine.vendor__c = wmVendorAccount.Id;
            UPDATE qLine;
            
            testQuote.SBQQ__Status__c = 'Product Configured';
            UPDATE  testQuote;
            
            try
            {
                testQuote.SBQQ__Status__c='Cost Configured';
                UPDATE  testQuote;
            }
            catch(exception ex){
                //system.debug('error is '+ex.getMessage());
                System.assertEquals(false, ex.getMessage().contains(haulService.Name + QouteValiationHandler.strSetupComment), assertionErrorMessage);
            }
            
            test.stopTest();
        }
    }
    
    // Method: testvalidateSetupComment3
    // Usage : To test the method QouteValiationHandler.validateSetupComment()
    // Defect/Story/Author: TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
    @isTest public static void testvalidateSetupComment3()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c, STP__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            Test.startTest();
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;
            Account wmVendorAccount = [SELECT Id from Account WHERE Name = 'WMVendorChild' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                SBQQ__Product__c = container.Id,
                                                                Equipment_Size__c = 'YRDS-30',
                                                                Occurrence_Type__c='SOC',
                                                                Vendor__c = wmVendorAccount.Id);
            insert parentQL;
            
            //Test 1-Positive scenario-Quote Line with WM Vendor, Setup Comment = NULL, Quote.STP__c = true, DoNotCreateTaskGridTickets__c = false (default value is FALSE)
            SBQQ__QuoteLine__c qLine = createHaulLine(testQuote.Id, haulService.Id, parentQL.Id);
            INSERT qLine;

            qLine.vendor__c = wmVendorAccount.Id;
            UPDATE qLine;
            
            testQuote.STP__c = true;
            testQuote.SBQQ__Status__c = 'Product Configured';
            UPDATE  testQuote;
            
            try
            {
                testQuote.SBQQ__Status__c='Cost Configured';
                UPDATE  testQuote;
            }
            catch(exception ex){
                //system.debug('error is '+ex.getMessage());
                System.assertEquals(false, ex.getMessage().contains(haulService.Name + QouteValiationHandler.strSetupComment), assertionErrorMessage);
            }
            
            test.stopTest();
        }
    }
    
    // Method: testvalidateSetupComment4
    // Usage : To test the method QouteValiationHandler.validateSetupComment()
    // Defect/Story/Author: TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
    @isTest public static void testvalidateSetupComment4()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
    
            Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
            Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            
            Account thirdPartyVendorAccount = [SELECT Id from Account WHERE Name = 'ThirdPartyVendorChild' LIMIT 1];
            Test.startTest();

            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                SBQQ__Product__c = container.Id,
                                                                Equipment_Size__c = 'YRDS-30',
                                                                Occurrence_Type__c='SOC',
                                                                Vendor__c = thirdPartyVendorAccount.Id);
            insert parentQL;
            
            //Test 1-Positive scenario-Quote Line with Third Party Vendor, Setup Comment = NULL, DoNotCreateTaskGridTickets__c = false (default value is FALSE)
            SBQQ__QuoteLine__c qLine = createHaulLine(testQuote.Id, haulService.Id, parentQL.Id);
            INSERT qLine;
            
            qLine.vendor__c = thirdPartyVendorAccount.Id;
            UPDATE qLine;
            
            testQuote.SBQQ__Status__c = 'Product Configured';
            UPDATE testQuote;
            
            try
            {
                testQuote.SBQQ__Status__c='Cost Configured'; 
                UPDATE  testQuote;
            }
            catch(exception ex){
                //system.debug('error is '+ex.getMessage());
                System.assertEquals(false, ex.getMessage().contains(haulService.Name + QouteValiationHandler.strSetupComment), assertionErrorMessage);
            }
            test.stopTest();
        }
    }
    
    // Method: MaterialNotConfigured
    // Usage : To test the SDT-39632 QuoteLine Validations
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void MaterialNotConfigured()
    {
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
            User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c 
                         FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            //Deleting Waste Steam and Waste Category QuoteLines
            List<SBQQ__QuoteLine__c> wasteCategoryQLs = [SELECT Id,SBQQ__ProductFamily__c,SBQQ__Product__r.Name FROM SBQQ__QuoteLine__c
                                                         where SBQQ__Quote__c =: testQuote.Id AND SBQQ__ProductFamily__c IN:wasteCategorySet];
            Delete wasteCategoryQLs;
            test.starttest(); 
            
            try
            {
                testQuote.SBQQ__Status__c = 'Product Configured';
                UPDATE testQuote;
            }
            catch(exception ex){
                //system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strMaterialNotConfigured));
                
            }
            test.stopTest();
        }
    }
    
    // Method: wmFeeCostCheck
    // Usage : To check if vendor is WM Fee, cost should be 0
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void wmFeeCostCheck()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
            system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            Account wmFeeVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account 
                                   WHERE name='WM Fee' LIMIT 1];
            
            testQuote = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            List<SBQQ__QuoteLine__c> qlList = [SELECT Id,Name,SBQQ__ProductFamily__c FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Quote__c =: testQuote.Id 
                                               AND SBQQ__RequiredBy__c !=null AND SBQQ__ProductFamily__c NOT IN:wasteCategorySet LIMIT 1];
            
            qlList[0].Vendor__c = wmFeeVendor.Id;
            UPDATE qlList;
            test.starttest(); 
            
            try
            {
                testQuote.SBQQ__Status__c = 'Cost Configured';
                UPDATE testQuote;
            }
            catch(exception ex){
                system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strWmFeeCostChages));
                
            }
            test.stopTest();
        }
    }
    
    // Method: wmFeeCostCheck
    // Usage : To check if vendor is WM and quote type != Quote (new service) check for masUniqueId !=null
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void masUniqueIdCheckForWMVendor()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
            system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];


            List<SBQQ__QuoteLine__c> qlList = [SELECT Id,Name,SBQQ__ProductFamily__c FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Quote__c =: testQuote.Id 
                                               AND SBQQ__RequiredBy__c !=null AND SBQQ__ProductFamily__c NOT IN:wasteCategorySet LIMIT 1];
            
            //Removing MASCustomerUniqueId__c
            qlList[0].MASCustomerUniqueId__c = null;
            UPDATE qlList;
            
            test.starttest(); 
            
            try
            {
                //Updating quote type to Amendment 
                testQuote.SBQQ__Type__c = 'Amendment';
                testQuote.SBQQ__Status__c = 'Cost Configured';
                UPDATE testQuote;
            }
            catch(exception ex){
                system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strMasUniqueId));
                
            }
            test.stopTest();
        }
    }
    
    // Method: vCRCodeCheck
    // Usage : To validate  VCR code !=null for quotelines going for integration
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void vCRCodeCheck()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
            system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();

            testQuote = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            List<SBQQ__QuoteLine__c> qlList = [SELECT Id,Name,SBQQ__ProductFamily__c,VCRCode__c FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Quote__c =: testQuote.Id 
                                               AND SBQQ__RequiredBy__c !=null AND SBQQ__ProductFamily__c NOT IN:wasteCategorySet LIMIT 1];
            
            //Making VCR code null
            qlList[0].VCRCode__c = null;
            UPDATE qlList;
            
            test.starttest(); 
            
            try
            {
                testQuote.SBQQ__Status__c = 'Cost Configured';
                UPDATE testQuote;
            }
            catch(exception ex){
                system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strVCRCode));
                
            }
            test.stopTest();
        }
    }
    
    // Method: locationStatusCheck
    // Usage : check if the location is active for the give quote
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void locationStatusCheck()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
        system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = [SELECT Id,SBQQ__Status__c,SBQQ__Account__c 
                                        FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            Account locationofQuote = [SELECT id,  Status__c, AccountNumber FROM Account 
                                       WHERE Id =:testQuote.SBQQ__Account__c LIMIT 1];
            
            //Making location status inactive 
            locationofQuote.Status__c ='Inactive';
            UPDATE locationofQuote;
            
            test.starttest(); 
            try
            {
                testQuote.SBQQ__Status__c = 'Price Configured';
                UPDATE testQuote;
            }
            catch(exception ex){
                system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strLocationStatus));
                
            }
            test.stopTest();
        }
    }
    
    // Method: vendorCommitDateCheck
    // Usage : To validate  vendor commit date <SBQQ__EndDate__c
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void vendorCommitDateCheck()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
            system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            
            testQuote = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlList = [SELECT Id,Name,SBQQ__ProductFamily__c,VCRCode__c FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Quote__c =: testQuote.Id 
                                               AND SBQQ__RequiredBy__c !=null AND SBQQ__ProductFamily__c NOT IN:wasteCategorySet LIMIT 1];
            
            //providing vendor commit date >end date
            qlList[0].Vendor_Commit_Date__c =System.today()+2;
            qlList[0].SBQQ__EndDate__c = System.today()+1;
            UPDATE qlList;
            
            test.starttest(); 
            
            try
            {
                testQuote.SBQQ__Status__c = 'Price Configured';
                UPDATE testQuote;
            }
            catch(exception ex){
                system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strVendorCommitDate));
                
            }
            test.stopTest();
        }
    }
    
    // Method: priceRelatedFieldsCheck
    // Usage : To validate if the price related field values are filled for the quotelines.
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void priceRelatedFieldsCheck()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
            system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            List<SBQQ__QuoteLine__c> qlList = [SELECT Id,Name,SBQQ__ListPrice__c,SBQQ__PricingMethod__c FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Quote__c =: testQuote.Id 
                                               AND SBQQ__RequiredBy__c !=null AND SBQQ__ProductFamily__c NOT IN:wasteCategorySet LIMIT 1];
            
            qlList[0].SBQQ__ListPrice__c =null;
            qlList[0].SBQQ__PricingMethod__c = null;
            qlList[0].Price_Override_Reason__c = 'Other';
            qlList[0].Price_Override_Description__c = 'test';
            UPDATE qlList;
            
            test.starttest(); 
            try
            {
                testQuote.SBQQ__Status__c = 'Price Configured';
                UPDATE testQuote;
            }
            catch(exception ex){
                system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strPriceMissing));                
            }
            test.stopTest();
        }
    }
    
    // Method: validateExceptionDetails
    // Usage : To validate if the Exception related field values are filled for the quotelines.
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void validateExceptionDetails()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        Set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};
            system.runAs(csrUser)
        {
            SBQQ__Quote__c testQuote = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            List<SBQQ__QuoteLine__c> qlList = [SELECT Id,Name,SBQQ__ListPrice__c,SBQQ__PricingMethod__c,SBQQ__Quote__r.Name,SBQQ__Quote__r.Case_record_Type__c,IsAssetQuotelineDifferent__c,AssetId__c,SBQQ__RequiredBy__c,SBQQ__Product__r.Name FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Quote__c =: testQuote.Id 
                                               AND SBQQ__RequiredBy__c !=null AND SBQQ__ProductFamily__c NOT IN:wasteCategorySet LIMIT 1];
            
            qlList[0].Exception_Type__c =null;
            qlList[0].Exception_Reason__c = null;
            qlList[0].Exception_Comments__c = null;
            
            UPDATE qlList;
            
            test.starttest(); 
            try
            {
                //testQuote.SBQQ__Status__c = 'Approved';
                //UPDATE testQuote;
                //Calling validateExceptionDetails method directly
                String errorMessage = QouteValiationHandler.validateExceptionDetails(qlList);
                System.assert(errorMessage.contains(QouteValiationHandler.strExceptionCode));
            }
            catch(exception ex){
                system.debug('error is '+ex.getMessage());
                System.assert(ex.getMessage().contains(QouteValiationHandler.strExceptionCode));                
            }
            test.stopTest();
        }
    }
    
    // Method: testTruncateException
    // Usage : To give coverage to ExceptionModifier class.
    // Defect/Story/Author: TCS-mRishan-01-Jan-2024-SDT-39632
    @isTest public static void testTruncateException()
    {
        String testString = 'FIELD_CUSTOM_VALIDATION_EXCEPTION, test string' ;
            
        test.starttest(); 
		String truncatedString = ExceptionModifier.truncateException(testString);
        System.assertEquals(truncatedString , 'test string');              
        test.stopTest();
    }
    
    
    // Method: createVendorAccounts
    // Usage : To create different vendor accounts
    // Defect/Story/Author: TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
    public static void createVendorAccounts(User usr)
    {
        List<Account> accList = new List<Account>();
        List<Account> wmParentVendor = TestDataFactory.createAccount('WMVendorParent', usr,'Vendor');
        List<Account> wmChildVendor = TestDataFactory.createAccount('WMVendorChild', usr,'Vendor');
        wmParentVendor[0].AccountNumber = '8';
        List<Account> republicParentVendor = TestDataFactory.createAccount('RepublicVendorParent', usr,'Vendor');
        List<Account> republicChildVendor = TestDataFactory.createAccount('RepublicVendorChild', usr,'Vendor');
        republicParentVendor[0].AccountNumber = '1';
        List<Account> thirdPartyParentVendor = TestDataFactory.createAccount('ThirdPartyVendorParent', usr,'Vendor');
        List<Account> thirdPartyChildVendor = TestDataFactory.createAccount('ThirdPartyVendorChild', usr,'Vendor');
        thirdPartyParentVendor[0].AccountNumber = '2860';
        accList.addAll(wmParentVendor);
        accList.addAll(wmChildVendor);
        accList.addAll(republicParentVendor);
        accList.addAll(republicChildVendor);
        accList.addAll(thirdPartyParentVendor);
        accList.addAll(thirdPartyChildVendor);
        
        insert accList;
        accList[1].ParentId = accList[0].Id;
        accList[3].ParentId = accList[2].Id;
        accList[5].ParentId = accList[4].Id;
        UPDATE accList;
    }
    
    // Method: createVendorAccounts
    // Usage : To create a quote line
    // Defect/Story/Author: TCS-pkulkarn-13-Mar-2024-SDT-33303-Added
    public static SBQQ__QuoteLine__c createHaulLine(Id quoteId, Id haulProductId, Id parentQLId)
    {
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                          SBQQ__Product__c = haulProductId,
                                                          SBQQ__RequiredBy__c = parentQLId,
                                                          Occurrence_Type__c='OC',
                                                          SBQQ__UnitCost__c=2,
                                                          Cost_Unit_of_Measure__c='DYS',
                                                          CostModelType__c='REB',
                                                          Schedule_Frequency__c='D',
                                                          Frequency_Interval__c='1',
                                                          MASLibrary__c='ARDTA.180',
                                                          MASCompany__c='test mas company');
        return qLine;
    }
//40723
@isTest public static void newServiceQuoteValidationTest(){
SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
testQuote = [SELECT id, SBQQ__Account__c, SBQQ__Status__c, Duration__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='draft' LIMIT 1];
Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
//Changes related to SDT-39632
Account wmVendor = [SELECT id, Name, RecordTypeId, Status__c, AccountNumber FROM Account WHERE name='WM' LIMIT 1];
Id rtId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get('NTE_Approval').getRecordTypeId();
Id newServiceRecType= Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('New_Service').getRecordTypeId();




Business_Rule__c brRule = [Select Id,Alias__c,NTE_Rules__c,Category_Type__c,Required_Information__c,AccountId__c,Case_Reason__c,
			   LocationId__c,Group__c,RecordTypeId,End_Date__c,
			   Container__c,Material__c,Service__c,Schedule_Type__c,
			   Project_Code__c,AssetId__c from Business_Rule__c where  Request_Type__c = 'New Service' Limit 1];

Service_Approver__c newSA = new Service_Approver__c();

newSA.Service_Type__c = 'Pickup';
newSA.RecordTypeId = rtId;
newSA.Business_Rule__c = brRule.Id;
newSA.NTE_Rule_ExtId__c = 'Pickup' + '-'+brRule.Id;
newSA.NTE_Amount__c = 100;
newSA.Account__c = brRule.AccountId__c;
newSA.Location__c = brRule.LocationId__c;
newSA.Active__c = True;
insert newSA;   

brRule.Active__c = true; 
update brRule;

testQuote.RecordTypeId=newServiceRecType;
update testQuote;


List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
						     SBQQ__Product__c = container.Id,
						     Equipment_Size__c = 'YRDS-30',
						     //Changes related to SDT-39632
						     Vendor__c =wmVendor.Id,
						     Vendor_Commit_Date__c= date.today()-2);
Test.startTest();
insert parentQL;

List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
						  SBQQ__Product__c = haulService.Id,
						  SBQQ__RequiredBy__c = parentQL.Id,
						  //Changes related to SDT-39632
						  Occurrence_Type__c='SOC',
						  Schedule_Frequency__c='W',
						  Frequency_Interval__c='1',
						  Vendor__c =wmVendor.Id,
						  Service_Days__c='M',
						  SBQQ__UnitCost__c=2,
						  Cost_Unit_of_Measure__c='DYS',
						  CostModelType__c='PER',
						  MASLibrary__c='ARDTA.180',
						  MASCompany__c='test mas company',
						  SetupComment__c = 'test',
						  PriceUOM__c = 'MTH',
						  SBQQ__ListPrice__c = 0,
						  Exception_Type__c ='CLTINITCHG',
						  Exception_Reason__c = 'NEWSRV',
						  Exception_Comments__c = 'testing exception');
SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
						   SBQQ__Product__c = haulService.Id,
						   SBQQ__RequiredBy__c = parentQL.Id,
						   //Changes related to SDT-39632
						   Vendor__c =wmVendor.Id,
						   Occurrence_Type__c='SOC',
						   Schedule_Frequency__c='W',
						   Frequency_Interval__c='1',
						   Service_Days__c='M',
						  SBQQ__UnitCost__c=2,
						  Cost_Unit_of_Measure__c='DYS',
						  CostModelType__c='PER',
						  MASLibrary__c='ARDTA.180',
						  MASCompany__c='test mas company',
						  SetupComment__c = 'test',
						  PriceUOM__c = 'MTH',
						  SBQQ__ListPrice__c = 0,
						  Exception_Type__c ='CLTINITCHG',
						  Exception_Reason__c = 'NEWSRV',
						  Exception_Comments__c = 'testing exception');

//qLineList.add(qLine);
qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
insert qLineList;
 
    try
    {
	testQuote.SBQQ__Status__c = 'Approved';
	update testQuote;            
    }
    catch(exception ex){
	system.debug('error is '+ex.getMessage());
	//System.assert(ex.getMessage().contains(QouteValiationHandler.strExceptionCode));                
    }



Test.stopTest(); 
}
}
