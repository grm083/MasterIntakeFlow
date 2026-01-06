@isTest
public class getLocalVendorControllerTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    
    @testSetup
    public static void setupData() {
        
        //Test data required to support this class includes:
        //Quote, Asset, Location Account, and Vendor
        
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        List<Account> toCreateAccountList= new List<Account>();
        Account testVendor = new Account();
        testVendor.Name = 'Test Vendor';
        testVendor.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Vendor' LIMIT 1].Id;
        testVendor.AccountNumber = '123456';
        testVendor.Legacy_Ranking__c = 100;
        testVendor.Vendor_Business_Unit__c = '100';
        toCreateAccountList.add(testVendor);
        //insert testVendor;
        
        list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
        toCreateAccountList.addAll(acclist);
        Database.insert(toCreateAccountList);

        list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
        locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
        locationlist[0].ShippingPostalCode = '00000';
        Database.insert(locationlist);
        
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
        Database.insert(conlist);
        
        Asset testAsset = new Asset();
        testAsset.Name = 'Test Asset';
        testAsset.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Service Header' LIMIT 1].Id;
        testAsset.Location__c = locationlist.get(0).Id;
        testAsset.Supplier__c = testVendor.Id;
        testAsset.Material_Type__c = 'Trash' ;
        testAsset.MAS_Library__c = '123A';
        testAsset.MAS_Company_Code__c = '123';
        testAsset.Start_Date__c= System.today();
        testAsset.End_Date__c= System.today();
        insert testAsset;
        
        //Inserting Case
        Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist.get(0)); 
        newServiceCase.Service_Date__c = system.today() + 1;
        newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
        Database.insert(newServiceCase);
        
        // Inserting opportunity based on Case. 
        Opportunity opportunity = new Opportunity();
        opportunity.AccountId = newServiceCase.Location__c;
        opportunity.Name = '04425266';
        opportunity.AccountId = newServiceCase.Location__c;
        opportunity.StageName = Constant_Util.PRODUCT_CONFIGURATION;
        opportunity.CloseDate = date.today() + 4;
        opportunity.Case__c = newServiceCase.Id;
        Database.insert(opportunity);
        
        //Inserting Quote based on Case and opportunity 
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Opportunity2__c = opportunity.Id;
        q.SBQQ__Account__c = newServiceCase.Location__c;
        q.SBQQ__Primary__c = true;
        q.SBQQ__ExpirationDate__c = date.today() + 30;
        q.SBQQ__StartDate__c = newServiceCase.Service_Date__c;
        q.SBQQ__PrimaryContact__c = newServiceCase.ContactId;
        Database.insert(q);
        
        List<Product2> toCreateProdList= new List<Product2>();
        //Inserting product  for Open-Top
        list<product2> productlist = TestDataFactory.createCPQProduct(Constant_Util.KEYWORD_TEST);
        toCreateProdList.addAll(productlist);
        
        //Inserting second product ---
        Product2 trash = new Product2();
        trash.Name = 'Trash';
        trash.ProductCode = 'T_WC';
        trash.Family = 'Waste Category';
        trash.IsActive = true;
        trash.SBQQ__ExcludeFromOpportunity__c = true;
        toCreateProdList.add(trash);
        
        Product2 trash2 = new Product2();
        trash2.Name = 'Trash';
        trash2.ProductCode = 'T';
        trash2.Family = 'Waste Stream';
        trash2.IsActive = true;
        trash2.SBQQ__ExcludeFromOpportunity__c = true;
        toCreateProdList.add(trash2);
        Database.insert(toCreateProdList);
        
        List<SBQQ__ProductFeature__c> prodFeatureList= new List<SBQQ__ProductFeature__c>();
        //Inserting product feature ---
        SBQQ__ProductFeature__c featureOne = new SBQQ__ProductFeature__c();
        featureOne.Name = 'Waste Stream';
        featureOne.SBQQ__MinOptionCount__c = 1;
        featureOne.SBQQ__MaxOptionCount__c = 1;
        featureOne.SBQQ__Number__c = 10;
        featureOne.SBQQ__ConfiguredSKU__c = productlist[0].id;
        featureOne.SBQQ__Category__c = 'Waste Category';
        prodFeatureList.add(featureOne);
        
        //Inserting product feature ---
        SBQQ__ProductFeature__c featureTwo = new SBQQ__ProductFeature__c();
        featureTwo.Name = 'Trash';
        featureTwo.SBQQ__MinOptionCount__c = 1;
        featureTwo.SBQQ__MaxOptionCount__c = 1;
        featureTwo.SBQQ__Number__c = 10;
        featureTwo.SBQQ__ConfiguredSKU__c = trash.id;
        featureTwo.SBQQ__Category__c = 'Waste Stream';
        prodFeatureList.add(featureTwo);
        Database.insert(prodFeatureList);
        
        List<SBQQ__ProductOption__c>  prodOptionList= new List<SBQQ__ProductOption__c>();
        //inserting Product Option --
        SBQQ__ProductOption__c option = new SBQQ__ProductOption__c();
        option.SBQQ__Number__c = 1;
        option.SBQQ__ConfiguredSKU__c = productlist[0].id;
        option.SBQQ__Quantity__c = 1;
        option.SBQQ__OptionalSKU__c = trash.id;
        option.SBQQ__Feature__c = featureOne.id;
        option.SBQQ__Bundled__c = true;
        prodOptionList.add(option); 
        
       //inserting Product Option --
        SBQQ__ProductOption__c option1 = new SBQQ__ProductOption__c();
        option1.SBQQ__Number__c = 1;
        option1.SBQQ__ConfiguredSKU__c = trash.id;
        option1.SBQQ__Quantity__c = 1;
        option1.SBQQ__OptionalSKU__c = trash2.id;
        option1.SBQQ__Feature__c = featureTwo.id;
        option1.SBQQ__Bundled__c = true;
        prodOptionList.add(option1);
        Database.insert(prodOptionList); 
        
    }
    
    @isTest
    public static void testMethods() {
        
        SBQQ__Quote__c quoteData = new SBQQ__Quote__c();
        quoteData = [SELECT Id, SBQQ__Account__r.AccountNumber,SBQQ__Account__r.ParentId,  SBQQ__Account__r.Id, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c ,SBQQ__Status__c
                     FROM SBQQ__Quote__c limit 1];
        
        Map<String, List<Asset>> testAccounts = getLocalVendorController.getDetails(quoteData.Id);
        System.assertEquals(testAccounts.size(), 2);
        
    }    
}