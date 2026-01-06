@isTest(seeAllData = false)

global class caseServiceTest {
    
 private static final string SYS_ADMIN = 'System Administrator';
    private static final string SPECIAL_INS ='Test Special Instructions';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string OTHER ='Other';
    private static final string TEST_NAME ='Test';
    private static final string NUMBER_145 ='145';
    private static final string REQ_INFO ='PSI ;PO NUMBER'; 
    private static final string SLA = 'Test SLA Instructions';
    private static final String LOCATION = 'Location';
    private static final String NUM_123 = '123';
    private static final String CONTACT_NOT_ONSITE = 'Contact Not Onsite';
    private static final String CONTACT = 'Contact';
    private static final String PICKUP = 'Pickup';
    private static final String EXTRA_PICKUP = 'Extra Pickup';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SCHEDULED ='Scheduled';
    private static final string REPAIRS = 'Repairs';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string InActive_CORE = 'Inactive COMPACTOR';
    private static final string INTERRUPTION = 'Interruption';
    private static final string STOP_SERVICE = 'Stop Service';
    private static final string CAM = 'CAM';
    private static final string SERVICE_REQUEST_CASE = 'Service Request Case';
    private static final string ADD = 'Add';
    private static final string EQUIPMENT = 'Equipment';
    private static final string COMPACTOR1 = 'Compactor';
    private static final string REPAIR_CASE = 'Repair Case';
    private static final string OPERABLE = 'Operable';
    private static final string COMPACTOR_ACCESSORIES = 'Compactor Accessories';    
    
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr);  
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
        system.runAs(usr){
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            productlist[0].Family = COMMERCIAL;
            
            Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT');
            Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H');
            Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV');
            Product2 trashCategory = new Product2(Name = 'Trash', Family = 'Waste Category', SBQQ__Component__c = TRUE, ProductCode = 'TRASH');
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            productlist.add(container);
            productlist.add(haulService);
            productlist.add(deliveryService);
            productlist.add(trashCategory);
            productlist.add(trashStream);
            
            Database.insert(productlist);
            Id pricebookId = Test.getStandardPricebookId();
            
            List<PricebookEntry> standardPriceList = new List<PricebookEntry>();
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = productlist[0].Id,
                UnitPrice = 10000, IsActive = true);
            standardPriceList.add(standardPrice);
            Database.insert(standardPriceList);
            
            List<Pricebook2> customPBList = new List<Pricebook2>();
            Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
            customPBList.add(customPB);
            Database.insert(customPBList);
            
            List<PricebookEntry> customPriceList = new List<PricebookEntry>();
            PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = productlist[0].Id,
                UnitPrice = 12000, IsActive = true);
            customPriceList.add(customPrice);
            Database.insert(customPriceList);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].CPQ_Product__c = container.Id; 
            assetlist[0].Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            list<Asset> assetlist1 = TestDataFactory.createAsset(InActive_CORE, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist1[0].Quantity__c = 1;
            assetlist1[0].Start_Date__c = System.today().addDays(-10);
            Database.insert(assetlist1);
            
            list<Asset>childassetlist = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);
            childassetlist[0].Product2 = haulService; 
            assetlist[0].CPQ_Product__c = productlist[1].Id;
            childassetlist[0].Supplier__c = acclist[1].Id;
            childassetlist[0].parentId = assetlist[0].Id;
            Database.insert(childassetlist);
            
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            list<Case> caselistForSameSlaDate = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                           usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today() + 1;
            caselist[0].SLA_Service_Date_Time__c = system.today() + 2;
            caselist[0].PurchaseOrder_Number__c =  Constant_Util.PO_VALUE_TEST;
            caselist[0].SLA_Override_Reason__c = REPAIRS ;
            caselist[0].Create_AM_and_PM_Pickups__c = true;
            caselist[0].Show_Multiple_Asset_Cases__c = true;
            caselist[0].Is_Multiple_Asset__c = true;
            caselistForSameSlaDate[0].Service_Date__c = system.today() + 1;
            caselistForSameSlaDate[0].SLA_Service_Date_Time__c = caselistForSameSlaDate[0].Service_Date__c;
            caselistForSameSlaDate[0].PurchaseOrder_Number__c =  Constant_Util.PO_VALUE_TEST;
            caselistForSameSlaDate[0].SLA_Override_Reason__c = REPAIRS; 
            caselistForSameSlaDate[0].Create_AM_and_PM_Pickups__c = true;
            Database.insert(caselist); 
            Database.insert(caselistForSameSlaDate); 
            
            List<Opportunity> oppList = TestDataFactory.createOpportunity(1,'TestOpportunityTest',caselist[0].Id,caselist[0].Case_Sub_Type__c, locationList[0].Id); //PK
            oppList[0].Duration__c='Temporary';
            Database.insert(oppList);
            
            List<SBQQ__Quote__c> testQuoteList = new List<SBQQ__Quote__c>();           
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote.SBQQ__Account__c = caselist[0].Location__c;
            testQuote.SBQQ__Status__c = 'Draft';
            testQuote.Duration__c = 'Temporary';
            testQuote.SBQQ__StartDate__c = system.today();
            testQuote.SBQQ__Opportunity2__c = oppList[0].Id; 
            testQuoteList.add(testQuote);
            Database.Insert(testQuoteList);
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                                SBQQ__Bundle__c = true,
                                                                SBQQ__RequiredBy__c = null);
            quoteLines.add(parentQL);
            Database.Insert(quoteLines);
                       
            List<WorkOrder> wrkOrderlst = TestDataFactory.createWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wrkOrderlst[0].Status = 'New';
            wrkOrderlst[0].Service_Date__c = system.today();
            wrkOrderlst[0].Customer_Location__c = caselist[0].Location__c;
            Database.insert(wrkOrderlst);
            
            List<WorkOrder> wrkOrderlst1 = TestDataFactory.createWorkOrder(acclist.get(0),conlist.get(0),caselist[0],assetlist.get(0));
            wrkOrderlst1[0].Status = 'New';
            wrkOrderlst1[0].Service_Date__c = system.today()-1;
            wrkOrderlst1[0].Customer_Location__c = caselist[0].Location__c;
            Database.insert(wrkOrderlst1);
            Test.stopTest();
            
        } 
    }

    @isTest static void testCreateMultipleCasesInvoke(){
        list<case> caselist = [select id, origin, contactid,Is_Clone__c, Case_Type__c, Client__c, Location__c, 
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                               Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
        
        list<String> caseIdList = new List<String>();
        caseIdList.add(caselist[0].id);
        caselist[0].Is_Clone__c = true;
        update caselist[0];
        test.startTest();
        caseService.createMultipleCasesInvoke(caselist[0].id); 
        
        test.stopTest();
    }

}