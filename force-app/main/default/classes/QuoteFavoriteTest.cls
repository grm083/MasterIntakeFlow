@isTest //(SeeAllData=true)  
public class QuoteFavoriteTest {
    
    private static final string US_LOCATION = 'United States';
    private static final string CANADA_LOCATION = 'Canada';
    private static final string US_CANADA_ENDDATEOFFSET = 'United States_7;Canada_7';
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    private static final String BACKDATED_REASON = 'Back-dated service requested';
    public static final String AAV_API_REQUEST_OUTPUT = '{"data": {"requestedDate": "2023-09-04","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD006959","materialCode": "T","materialName": "Trash","countryCode": "USA","suppliers": [{"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste","zoneCode": "GIS624853","zoneName": "Non WM Franchise - Bainbridge - CM MSW","wmMetaData": {"marketAreaCode": "K00126","marketAreaName": "WM of South Atlantic","facilityId": "GA0075","facilityName": "Albany Hauling","siteId": "S10284","siteName": "Albany Hauling"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,"messages": [{"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"}]}],"messages": []},"problem": null}';
    @testSetup
    static void createData() {
        CodeSwitchTestData  CodeSwithData = new CodeSwitchTestData();
       
        //added by av4 for 39637
        
        //ends
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = TRUE;
        usr.FirstName = 'testuser#9999';
        usr.Genesys_Enabled__c = FALSE;
        insert usr;
        //Added csr profile for stp test methods - start
        Profile csrProfile= TestDataFactory.getProfile(CUSTOMER_SERVICE);
        User csrUsr= TestDataFactory.createUser(csrProfile);
        csrUsr.Bypass_Validation__c = TRUE;
        csrUsr.FirstName = 'csrtestuser#9999';
        insert csrUsr;
        //Added csr profile for stp test methods - End
        List<Account> accList;
        List<Account> locationList;
        List<Contact> conList;
        List<Case> caseList;
        List<Opportunity> oppList;
        List<Product2> prodList= new List<Product2>();
        List<Pricebookentry> pbeList= new List<Pricebookentry>();
        List<MAS_Setup_Detail__c> masLst = new List<MAS_Setup_Detail__c>();
        Product2 prodDumpster;
        Product2 prodCompactor;
        Product2 prod3;
        Product2 prod4;
        Account_Position__c accPosition;
        System.runAs(usr){
            
            //Changes for SDT-39632
            Code_Switch__c qLValidationsetting = QuoteTestDataFactory.createCodeSwitch('New_Quote_Validation',false);
            Insert qLValidationsetting;
            
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].AccountNumber = 'ParentTest';
            List<Account> accList12 = TestDataFactory.createAccount('TestVendorAccountTest', usr,'Vendor');
            accList12[0].Vendor_Business_Unit__c = '2860';
            accList.addAll(accList12);
            insert accList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            locationList[0].AccountNumber = 'ChildTest';
            locationList[0].type = 'location';
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Detroit';
            insert locationList;
            accPosition = new Account_Position__c();
            accPosition.AccountId__c = locationList[0].Id;
            accPosition.Container_Position__c = 'TestingPosition1';
            insert accPosition;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            MAS_Setup_Detail__c masObj= new MAS_Setup_Detail__c();
            masObj.MAS_Line_of_Business__c = 'C';
            masObj.MAS_Company_Code__c= '286';
            masObj.MAS_Library__c= 'ARDTA.129A';
            masObj.Business_Unit_Number__c= '2860';
            masLst.add(masObj);
            masObj= new MAS_Setup_Detail__c();
            masObj.MAS_Line_of_Business__c = 'O';
            masObj.MAS_Company_Code__c= '286';
            masObj.MAS_Library__c= 'ARDTA.129A';
            masObj.Business_Unit_Number__c= '2860';
            masLst.add(masObj);
            insert masLst;
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            Product2 prodOT = TestDataFactory.createProduct('Open Top','Equipment','OT');
            prodOT.Bypass_Acorn_Integration__c= false;
            prodOT.Family= 'None';
            Product2 prod = TestDataFactory.createProduct('Delivery','Services','DLV');
            Product2 prod1 = TestDataFactory.createProduct('Pickup','Services','PCK');
            Product2 prod2 =TestDataFactory.createProduct('Removal','Services','REM');
            prod3 = TestDataFactory.createProduct('Trash','Waste Category','TW');
            prod4 = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodList.add(prodOT);
            prodList.add(prod);
            prodList.add(prod1);
            prodList.add(prod2);
            prodDumpster = TestDataFactory.createProduct('Dumpster','Rolloff', 'DMP');
            //SDT39054
            prodDumpster.EndDateOffset__c = US_CANADA_ENDDATEOFFSET;
            prodDumpster.Is_Pricing_Eligible__c = true;
            prodList.add(prodDumpster);
            Product2 prodPadlock = TestDataFactory.createProduct('Gravity with Padlock Bar','Equipment', 'LCKFEE');
            prodPadlock.Is_Pricing_Eligible__c = true;
            prodList.add(prodPadlock);
            Product2 prodKeys = TestDataFactory.createProduct('Keys','Equipment', 'LCKFEE');
            prodKeys.Is_Pricing_Eligible__c = false;
            prodList.add(prodKeys);
            prodList.add(prod3);
            prodList.add(prod4);
            prodCompactor = TestDataFactory.createProduct('Compactor','Commercial', 'CMP');
            prodList.add(prodCompactor);
            insert prodList;
            Pricebook2 pbObj = new Pricebook2(Name = 'Standard Price Book');
            insert pbObj;
            Pricebookentry pbeObjOT= new Pricebookentry(Product2Id = prodOT.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj1= new Pricebookentry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj2= new Pricebookentry(Product2Id = prod1.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj3= new Pricebookentry(Product2Id = prod2.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj4= new Pricebookentry(Product2Id = prod3.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            pbeList.add(pbeObjOT);
            pbeList.add(pbeObj1);
            pbeList.add(pbeObj2);
            pbeList.add(pbeObj3);
            pbeList.add(pbeObj4);
            insert pbeList;
            Asset assetObj = TestDataFactory.createAsset('Test Asset 1', accList[0],conList[0], prodOT, usr,locationList[0])[0];
            Database.insert(assetObj);
        }
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQl= new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c parentQl1= new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c parentQl2= new SBQQ__QuoteLine__c();
        SBQQ__FavoriteProduct__c favProduct = new SBQQ__FavoriteProduct__c();
        SBQQ__FavoriteProduct__c favProduct1 = new SBQQ__FavoriteProduct__c();
        SBQQ__FavoriteProduct__c favProduct2 = new SBQQ__FavoriteProduct__c();
        SBQQ__FavoriteProduct__c favProduct3 = new SBQQ__FavoriteProduct__c();
        SBQQ__FavoriteProduct__c favProduct4 = new SBQQ__FavoriteProduct__c();
        SBQQ__Favorite__c fav = new SBQQ__Favorite__c();
        List<SBQQ__Favorite__c> favList= new List<SBQQ__Favorite__c>();
        List<SBQQ__FavoriteProduct__c> favProductList = new List<SBQQ__FavoriteProduct__c>();
        List<SBQQ__QuoteLine__c> parentQls = new List<SBQQ__QuoteLine__c>();
        Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        User usrObj= TestDataFactory.createUser(prfl); 
        usrObj.FirstName = 'testUser#99997';
        usrObj.Bypass_Validation__c = TRUE;
        usrObj.Genesys_Enabled__c = FALSE;
        insert usrObj;
        List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
        insert new PermissionSetLicenseAssign(AssigneeId = usrObj.Id, PermissionSetLicenseId= pslList[0].Id);
        List<PermissionSet> psgList= [SELECT Id FROM PermissionSet WHERE Name = 'QuoteOrdersUser'];
        insert new PermissionSetAssignment(AssigneeId = usrObj.Id, PermissionSetId = psgList[0].id);
        System.runAs(usrObj){
            List<Account> acctListNew = insertAccounts();
            List<Product2> prodListNew = insertProducts();
            caseList= new List<Case>();
            oppList= new List<Opportunity>();
            list<Contact> conlistNew = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acctListNew.get(1), usr);
            Database.insert(conlistNew);
            
            Case pickupCase2 = QuoteTestDataFactory.createCase('New Service Case','New Service','Permanent','Existing Location', acctListNew[1],conlistNew[0], acctListNew[0]);
            Database.insert(pickupCase2);
            
            caseList= new List<Case>();
            oppList= new List<Opportunity>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            caseList[0].Service_Date__c= System.today();
            insert caseList;
            
            list<Case> caselistnew = new list<Case>(); 
            Case cs = new Case(Status ='New', Priority = 'Medium', Origin = 'Phone', ContactId = conlistNew[0].id, 
                               AccountId = acctListNew[0].Id, OwnerId = usr.id, Client__c = acctListNew[1].Id, Location__c = acctListNew[0].id, 
                               Case_Type__c = 'New Service', Case_Sub_Type__c = 'Permanent', Case_Reason__c = 'Existing Location',
                               SlaStartDate = system.today(),Recordtypeid = TestDataFactory.getRecordType('New Service Case','Case'));
            caselistnew.add(cs);
            insert caselistnew;
            
            List<Opportunity> oppList2 = TestDataFactory.createOpportunity(1,'TestOpportunityTest',caselistnew[0].Id,caselistnew[0].Case_Sub_Type__c, acctListNew[0].Id); //PK
            oppList2[0].Duration__c='Temporary';
            Database.insert(oppList2);
            
            
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            
            insert oppList;
            
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
            quoteList.addAll(TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false));
            quoteList.addAll(TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false));
            quoteList[1].SBQQ__Status__c='Product Configured';
            
            quoteList[0].SBQQ__Type__c = 'Amendment';
            
            insert quoteList;
            System.debug('quoteList>>>'+quoteList[0]+'>>>'+quoteList[1]+'>>>'+quoteList[2]);
            List<SBQQ__ProductFeature__c> sbqqFeatList= new List<SBQQ__ProductFeature__c>();
            SBQQ__ProductFeature__c feat= new SBQQ__ProductFeature__c();
            feat.Name= 'Additional Services';
            feat.SBQQ__Number__c = 20;
            feat.SBQQ__MinOptionCount__c = 0;
            feat.SBQQ__ConfiguredSKU__c = prodDumpster.id;
            sbqqFeatList.add(feat);
            insert sbqqFeatList;
            List<SBQQ__ProductOption__c> sbqqLst = new List<SBQQ__ProductOption__c>();
            SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
            sbqq.SBQQ__ConfiguredSKU__c = prodList[0].Id;
            sbqq.SBQQ__OptionalSKU__c = prodList[1].Id;
            sbqq.SBQQ__Number__c = 350;
            sbqq.SBQQ__Quantity__c = 1;
            sbqq.Occurrence_Type__c = 'SCH';
            sbqq.CostModelType__c = 'PER';
            sbqq.Cost_Unit_of_Measure__c = 'MTH';
            sbqq.PriceUOM__c = 'MTH';
            sbqq.Schedule_Frequency__c = 'W';
            sbqq.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq);
            SBQQ__ProductOption__c sbqq1 = new SBQQ__ProductOption__c();
            sbqq1.SBQQ__ConfiguredSKU__c = prodList[0].Id;
            sbqq1.SBQQ__OptionalSKU__c = prodList[2].Id;
            sbqq1.SBQQ__Number__c = 350;
            sbqq1.SBQQ__Quantity__c = 1;
            sbqq1.Occurrence_Type__c = 'SCH';
            sbqq1.CostModelType__c = 'PER';
            sbqq1.Cost_Unit_of_Measure__c = 'MTH';
            sbqq1.PriceUOM__c = 'MTH';
            sbqq1.Schedule_Frequency__c = 'W';
            sbqq1.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq1);
            SBQQ__ProductOption__c sbqq2 = new SBQQ__ProductOption__c();
            sbqq2.SBQQ__ConfiguredSKU__c = prodList[0].Id;
            sbqq2.SBQQ__OptionalSKU__c = prodList[3].Id;
            sbqq2.SBQQ__Number__c = 350;
            sbqq2.SBQQ__Quantity__c = 1;
            sbqq2.Occurrence_Type__c = 'SCH';
            sbqq2.CostModelType__c = 'PER';
            sbqq2.Cost_Unit_of_Measure__c = 'MTH';
            sbqq2.PriceUOM__c = 'MTH';
            sbqq2.Schedule_Frequency__c = 'W';
            sbqq2.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq2);
            SBQQ__ProductOption__c sbqq3 = new SBQQ__ProductOption__c();
            sbqq3.SBQQ__ConfiguredSKU__c = prodDumpster.Id;
            sbqq3.SBQQ__OptionalSKU__c = prodList[5].Id;
            sbqq3.SBQQ__Number__c = 350;
            sbqq3.SBQQ__Quantity__c = 1;
            sbqq3.Occurrence_Type__c = 'SCH';
            sbqq3.CostModelType__c = 'PER';
            sbqq3.Cost_Unit_of_Measure__c = 'MTH';
            sbqq3.PriceUOM__c = 'MTH';
            sbqq3.Schedule_Frequency__c = 'W';
            sbqq3.Frequency_Interval__c = '1';
            sbqq3.SBQQ__Feature__c= sbqqFeatList[0].id;
            sbqqLst.add(sbqq3);
            SBQQ__ProductOption__c sbqq4 = new SBQQ__ProductOption__c();
            sbqq4.SBQQ__ConfiguredSKU__c = prodList[5].Id;
            sbqq4.SBQQ__OptionalSKU__c = prodList[6].Id;
            sbqq4.SBQQ__Number__c = 350;
            sbqq4.SBQQ__Quantity__c = 1;
            sbqq4.Occurrence_Type__c = 'SCH';
            sbqq4.CostModelType__c = 'PER';
            sbqq4.Cost_Unit_of_Measure__c = 'MTH';
            sbqq4.PriceUOM__c = 'MTH';
            sbqq4.Schedule_Frequency__c = 'W';
            sbqq4.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq4);
            SBQQ__ProductOption__c sbqq5 = new SBQQ__ProductOption__c();
            sbqq5.SBQQ__ConfiguredSKU__c = prodList[0].Id;
            sbqq5.SBQQ__OptionalSKU__c = prodList[7].Id;
            sbqq5.SBQQ__Number__c = 350;
            sbqq5.SBQQ__Quantity__c = 1;
            sbqq5.Occurrence_Type__c = 'SCH';
            sbqq5.CostModelType__c = 'PER';
            sbqq5.Cost_Unit_of_Measure__c = 'MTH';
            sbqq5.PriceUOM__c = 'MTH';
            sbqq5.Schedule_Frequency__c = 'W';
            sbqq5.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq5);
            SBQQ__ProductOption__c sbqq6 = new SBQQ__ProductOption__c();
            sbqq6.SBQQ__ConfiguredSKU__c = prodCompactor.Id;
            sbqq6.SBQQ__OptionalSKU__c = prodList[1].Id;
            sbqq6.SBQQ__Number__c = 350;
            sbqq6.SBQQ__Quantity__c = 1;
            sbqq6.Occurrence_Type__c = 'SCH';
            sbqq6.CostModelType__c = 'PER';
            sbqq6.Cost_Unit_of_Measure__c = 'MTH';
            sbqq6.PriceUOM__c = 'MTH';
            sbqq6.Schedule_Frequency__c = 'W';
            sbqq6.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq6);
            SBQQ__ProductOption__c sbqq7 = new SBQQ__ProductOption__c();
            sbqq7.SBQQ__ConfiguredSKU__c = prodCompactor.Id;
            sbqq7.SBQQ__OptionalSKU__c = prodList[2].Id;
            sbqq7.SBQQ__Number__c = 350;
            sbqq7.SBQQ__Quantity__c = 1;
            sbqq7.Occurrence_Type__c = 'SCH';
            sbqq7.CostModelType__c = 'PER';
            sbqq7.Cost_Unit_of_Measure__c = 'MTH';
            sbqq7.PriceUOM__c = 'MTH';
            sbqq7.Schedule_Frequency__c = 'W';
            sbqq7.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq7);
            SBQQ__ProductOption__c sbqq8 = new SBQQ__ProductOption__c();
            sbqq8.SBQQ__ConfiguredSKU__c = prodCompactor.Id;
            sbqq8.SBQQ__OptionalSKU__c = prodList[3].Id;
            sbqq8.SBQQ__Number__c = 350;
            sbqq8.SBQQ__Quantity__c = 1;
            sbqq8.Occurrence_Type__c = 'SCH';
            sbqq8.CostModelType__c = 'PER';
            sbqq8.Cost_Unit_of_Measure__c = 'MTH';
            sbqq8.PriceUOM__c = 'MTH';
            sbqq8.Schedule_Frequency__c = 'W';
            sbqq8.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq8);
            SBQQ__ProductOption__c sbqq9 = new SBQQ__ProductOption__c();
            sbqq9.SBQQ__ConfiguredSKU__c = prodCompactor.Id;
            sbqq9.SBQQ__OptionalSKU__c = prod3.Id;
            sbqq9.SBQQ__Number__c = 350;
            sbqq9.SBQQ__Quantity__c = 1;
            sbqq9.Occurrence_Type__c = 'SCH';
            sbqq9.CostModelType__c = 'PER';
            sbqq9.Cost_Unit_of_Measure__c = 'MTH';
            sbqq9.PriceUOM__c = 'MTH';
            sbqq9.Schedule_Frequency__c = 'W';
            sbqq9.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq9);
            SBQQ__ProductOption__c sbqq10 = new SBQQ__ProductOption__c();
            sbqq10.SBQQ__ConfiguredSKU__c = prod3.Id;
            sbqq10.SBQQ__OptionalSKU__c = prod4.Id;
            sbqq10.SBQQ__Number__c = 350;
            sbqq10.SBQQ__Quantity__c = 1;
            sbqq10.Occurrence_Type__c = 'SCH';
            sbqq10.CostModelType__c = 'PER';
            sbqq10.Cost_Unit_of_Measure__c = 'MTH';
            sbqq10.PriceUOM__c = 'MTH';
            sbqq10.Schedule_Frequency__c = 'W';
            sbqq10.Frequency_Interval__c = '1';
            sbqqLst.add(sbqq10);
            insert sbqqLst;
            fav.Name = 'Test Fav';
            fav.SBQQ__Description__c = 'Test Desc';
            favList.add(fav);
            insert favList;
            favProduct.Name= 'Open Top';
            favProduct.SBQQ__ConfigurationAttributes__c='{"Profile_Number__c":null,"Certificate_of_Disposal__c":"false","Certificate_of_Destruction__c":"false","Description_of_Waste__c":null,"Occurrence_Type__c":"OC","Ownership__c":null,"Equipment_Size__c":"YRDS-40"}';
            favProduct.SBQQ__Favorite__c= favList[0].id;
            favProduct.SBQQ__Product__c= prodList[0].id;
            favProduct.SBQQ__Quantity__c= 1;
            favProductList.add(favProduct);
            favProduct1.Name= 'Delivery';
            favProduct1.SBQQ__ConfigurationAttributes__c='{"Profile_Number__c":null,"Certificate_of_Disposal__c":"false","Certificate_of_Destruction__c":"false","Description_of_Waste__c":null,"Occurrence_Type__c":"OC","Ownership__c":null,"Equipment_Size__c":"YRDS-40"}}';
            favProduct1.SBQQ__Favorite__c= favList[0].id;
            favProduct1.SBQQ__Product__c= prodList[2].id;
            favProduct1.SBQQ__ProductOption__c= sbqq.id;
            favProduct1.SBQQ__RequiredBy__c= favProduct.id;
            favProduct1.SBQQ__Quantity__c= 1;
            favProductList.add(favProduct1);
            favProduct2.Name= 'Pickup';
            favProduct2.SBQQ__ConfigurationAttributes__c='{"Profile_Number__c":null,"Certificate_of_Disposal__c":"false","Certificate_of_Destruction__c":"false","Description_of_Waste__c":null,"Occurrence_Type__c":"OC","Ownership__c":null,"Equipment_Size__c":"YRDS-40"}}';
            favProduct2.SBQQ__Favorite__c= favList[0].id;
            favProduct2.SBQQ__Product__c= prodList[1].id;
            favProduct2.SBQQ__ProductOption__c= sbqq1.id;
            favProduct2.SBQQ__RequiredBy__c= favProduct.id;
            favProduct2.SBQQ__Quantity__c= 1;
            favProductList.add(favProduct2);
            favProduct3.Name= 'Removal';
            favProduct3.SBQQ__ConfigurationAttributes__c='{"Profile_Number__c":null,"Certificate_of_Disposal__c":"false","Certificate_of_Destruction__c":"false","Description_of_Waste__c":null,"Occurrence_Type__c":"OC","Ownership__c":null,"Equipment_Size__c":"YRDS-40"}}';
            favProduct3.SBQQ__Favorite__c= favList[0].id;
            favProduct3.SBQQ__Product__c= prodList[2].id;
            favProduct3.SBQQ__ProductOption__c= sbqq2.id;
            favProduct3.SBQQ__RequiredBy__c= favProduct.id;
            favProduct3.SBQQ__Quantity__c= 1;
            favProductList.add(favProduct3);
            favProduct4.Name= 'Trash';
            favProduct4.SBQQ__ConfigurationAttributes__c='{"Profile_Number__c":null,"Certificate_of_Disposal__c":"false","Certificate_of_Destruction__c":"false","Description_of_Waste__c":null,"Occurrence_Type__c":"OC","Ownership__c":null,"Equipment_Size__c":"YRDS-40"}}';
            favProduct4.SBQQ__Favorite__c= favList[0].id;
            favProduct4.SBQQ__Product__c= prodList[7].id;
            favProduct4.SBQQ__ProductOption__c= sbqq5.id;
            favProduct4.SBQQ__RequiredBy__c= favProduct.id;
            favProduct4.SBQQ__Quantity__c= 1;
            favProductList.add(favProduct4);
            insert favProductList;
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prodList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.Location_Position_Name__c= accPosition.id;
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__RequiredBy__c= null;
            parentQl.SBQQ__Number__c=0;
            parentQl.Account__c = locationList[0].id;
            parentQl.MASLibrary__c = 'ARDTA.129A';
            parentQl.Duration__c = 'TEMP';
            parentQls.add(parentQl);
            parentQl1= TestDataFactory.createQuoteLineRecords(quoteList[2],prodDumpster,'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl1.LocationPositionName__c='Test Location';
            parentQl1.Location_Position_Name__c= accPosition.id;
            parentQl1.SBQQ__StartDate__c= Date.today();
            parentQl1.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl1.SBQQ__RequiredBy__c= null;
            parentQl1.SBQQ__Number__c=0;
            parentQl1.Account__c = locationList[0].id;
            parentQl1.MASLibrary__c = 'ARDTA.129A';
            parentQl1.Duration__c = 'TEMP';
            parentQl1.Vendor__c = acctListNew[2].Id;
            parentQl1.SBQQ__PricingMethod__c='STP';
            parentQl1.CostModelType__c='STP';
            parentQls.add(parentQl1);
            parentQl2= TestDataFactory.createQuoteLineRecords(quoteList[0],prodCompactor,'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl2.LocationPositionName__c='Test Location';
            parentQl2.Location_Position_Name__c= accPosition.id;
            parentQl2.SBQQ__StartDate__c= Date.today();
            parentQl2.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl2.SBQQ__RequiredBy__c= null;
            parentQl2.SBQQ__Number__c=0;
            parentQl2.Account__c = locationList[0].id;
            parentQl2.MASLibrary__c = 'ARDTA.129A';
            parentQl2.Duration__c = 'TEMP';
            parentQls.add(parentQl2);
            insert parentQls;
            for(Integer i=0;i<3;i++){
                
                qlList.add(TestDataFactory.createQuoteLineRecords(quoteList[0],prodList[i+1],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
                qlList[i].SBQQ__StartDate__c= Date.today();
                qlList[i].SBQQ__EndDate__c= Date.today().addDays(25);
                qlList[i].SBQQ__RequiredBy__c= parentQl.Id;
                qlList[i].SBQQ__ProductOption__c= sbqqLst[i].id;
                qlList[i].SBQQ__Number__c=i+3;
                qlList[i].Account__c = locationList[0].id;
                qlList[i].MASLibrary__c = 'ARDTA.129A';
                qlList.add(TestDataFactory.createQuoteLineRecords(quoteList[2],prodList[i+3],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
                qlList[i+1].SBQQ__StartDate__c= Date.today();
                qlList[i+1].SBQQ__EndDate__c= Date.today().addDays(25);
                qlList[i+1].SBQQ__RequiredBy__c= parentQl1.Id;
                qlList[i+1].SBQQ__ProductOption__c= sbqqLst[i+2].id;
                qlList[i+1].SBQQ__Number__c=i+3;
                qlList[i+1].Account__c = locationList[0].id;
                qlList[i+1].MASLibrary__c = 'ARDTA.129A';
                qlList.add(TestDataFactory.createQuoteLineRecords(quoteList[2],prodList[i+1],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
                qlList[i+1].SBQQ__StartDate__c= Date.today();
                qlList[i+1].SBQQ__EndDate__c= Date.today().addDays(25);
                qlList[i+1].SBQQ__RequiredBy__c= parentQl2.Id;
                qlList[i+1].SBQQ__ProductOption__c= sbqqLst[i+6].id;
                qlList[i+1].SBQQ__Number__c=i+3;
                qlList[i+1].Account__c = locationList[0].id;
                qlList[i+1].MASLibrary__c = 'ARDTA.129A';
            }
            
            for(Integer i=0;i<qlList.size();i++){
                qlList[i].SBQQ__Number__c= i;
                qlList[i].Schedule_Frequency__c = 'W';
                qlList[i].Duration__c = 'TEMP';
                qlList[i].LocationPositionName__c='Test Location';
                qlList[i].Location_Position_Name__c= accPosition.id;
                if(qlList[i].SBQQ__ProductName__c == 'Removal'){
                    qlList[i].SBQQ__EndDate__c = system.today();
                }
            }
            insert qlList;
            System.debug('xyz>>'+qlList);
            Quote_Order__c qo = new Quote_Order__c();
            qo.Quote_Line__c= parentQl.id;
            qo.Service_Quote_Line__c= qlList[2].id;
            qo.Service_Type__c='Pickup';
            qo.Product_Type__c='Haul';
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
            
            SBQQ__ProductRule__c prodRule = new SBQQ__ProductRule__c(Name = 'Make Product description mandatory', SBQQ__Scope__c= 'Product', SBQQ__Active__c =true, SBQQ__Type__c ='Validation',SBQQ__EvaluationEvent__c ='Save',SBQQ__AdvancedCondition__c= '( 10 AND 20 )',SBQQ__ConditionsMet__c = 'All',SBQQ__ErrorMessage__c='Description of Waste is mandatory for the selected Waste Stream',SBQQ__EvaluationOrder__c=1);
            insert prodRule;
            List<SBQQ__ConfigurationRule__c> configRuleList =new List<SBQQ__ConfigurationRule__c>();
            configRuleList.add(new SBQQ__ConfigurationRule__c(SBQQ__Active__c = true, SBQQ__Product__c = prodList[0].Id, SBQQ__ProductRule__c=prodRule.Id));
            insert configRuleList;
            List<SBQQ__ErrorCondition__c> errorCondList = new List<SBQQ__ErrorCondition__c>();
            errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__FilterValue__c = 'Trash',  SBQQ__Index__c =20, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule.Id, SBQQ__TestedField__c ='Optional_Product__c', SBQQ__TestedObject__c='Product Option'));
            errorCondList.add(new SBQQ__ErrorCondition__c(SBQQ__FilterType__c = 'Value', SBQQ__Index__c =10, SBQQ__Operator__c = 'equals', SBQQ__Rule__c = prodRule.Id, SBQQ__TestedField__c ='Description_of_Waste__c', SBQQ__TestedObject__c='Configuration Attributes'));
            insert errorCondList;
            
            SBQQ__Quote__c draftQuote1 = new SBQQ__Quote__c();
            draftQuote1.SBQQ__Account__c = acctListNew[2].id;
            draftQuote1.SBQQ__Status__c = 'Cost Configured';
            draftQuote1.Duration__c = 'Temporary';
            draftQuote1.SBQQ__StartDate__c = system.today();
            //addtion for S11 test class error
            draftQuote1.SBQQ__Opportunity2__c = oppList2[0].Id;
            //qListNew.add(draftQuote1);
            
            insert draftQuote1;
            
            list<Business_Rule__c> brlist = new list<Business_Rule__c>();
            Business_Rule__c brObj = new Business_Rule__c();
            brObj.Accountid__c = caselistnew[0].Client__c;
            brObj.LocationId__c = caselistnew[0].Location__c;
            brObj.Request_Type__c = 'New Service';
            brObj.Service__c = 'Permanent';
            brObj.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
            //brObj.Required_Information__c = PO_PSI_VALUE; 
            brObj.Effective_Date__c = System.today()-1;
            brObj.NTE_Rules__c = true;
            brObj.Active__c=True;
            brlist.add(brObj);
            Database.insert(brlist);
        }
        test.stopTest();
    }
    public static List<Account> insertAccounts(){
        List<Account> acctList = new List<Account>();
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
        //addition for S11 test class errors
        RecordType locationType = [SELECT Id FROM RecordType WHERE Name = 'Location'];
        RecordType vendorType = [SELECT Id FROM RecordType WHERE Name = 'Vendor'];
        //addition for S11 test class errors - changed recordtype to location
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = locationType.Id);
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
    public static List<Product2> insertProducts(){
        List<Product2> prodListNew = new List<Product2>();
        Product2 container = new Product2(Name = 'Open Top', Family = 'Equipment', ProductCode = 'OT', Bypass_Acorn_Integration__c=false);
        Product2 haulService = new Product2(Name = 'Haul', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'H',  Bypass_Acorn_Integration__c=false);
        Product2 deliveryService = new Product2(Name = 'Delivery', Family = 'Services', SBQQ__Component__c = TRUE, ProductCode = 'DLV',  Bypass_Acorn_Integration__c=false);
        
        prodListNew.add(container);
        prodListNew.add(haulService);
        prodListNew.add(deliveryService);
        
        insert prodListNew;
        return prodListNew;
    }
    
    public static SBQQ__Quote__c returnTestQuote(String status) {
        /*SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c
FROM SBQQ__Quote__c WHERE SBQQ__Status__c =: status AND Case__c != null
AND SBQQ__Account__r.Parent.AccountNumber = 'HMD'
ORDER BY CreatedDate DESC LIMIT 1];*/
        SBQQ__Quote__c testQuote = [SELECT Id, Name, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
                                    FROM SBQQ__Quote__c WHERE SBQQ__Status__c =: status AND Case__c != null
                                    ORDER BY CreatedDate DESC LIMIT 1];
        return testQuote;
    }
    
    public static QuoteProcurementController.ProductsWrapper generateWrapper(String QuoteId) {
        
        QuoteProcurementController.ProductsWrapper testWrapper = QuoteProcurementController.buildWrapper(QuoteId);
        return testWrapper;
        
    }
    
    
    
    @isTest public static void testFavoritesController() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Detroit';
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Detroit';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            Product2 trash = new Product2();
            trash.Name = 'Trash';
            trash.ProductCode = 'T_WC';
            trash.Family = 'Waste Category';
            trash.IsActive = true;
            trash.SBQQ__ExcludeFromOpportunity__c = true;
            insert trash;
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            System.debug('$$$$limitbeforestoptest$$$$' + Limits.getLimitQueries());
            
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],trash,'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            
            List<Product2> testProducts = QuoteFavoritesController.getProducts();
            system.assertNotEquals(testProducts.size(), 0);
            testProducts = QuoteFavoritesController.searchProducts('open t');
            system.assertNotEquals(testProducts, null);
            Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
            testProduct.Name = 'Open Top';
            testProduct.IsActive = true;
            update testProduct;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__ProductOption__c> sbqqLst = new List<SBQQ__ProductOption__c>();
            SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
            sbqq.SBQQ__OptionalSKU__c = prdList[0].Id;
            sbqq.SBQQ__ConfiguredSKU__c = prdList[0].Id;
            sbqq.SBQQ__Number__c = 350;
            sbqq.SBQQ__Quantity__c = 1;
            sbqqLst.add(sbqq);
            insert sbqqLst;
            
            SBQQ__ConfigurationAttribute__c confAtr = new SBQQ__ConfigurationAttribute__c();
            confAtr.SBQQ__TargetField__c = 'Equipment_Size__c';
            confAtr.SBQQ__ApplyToProductOptions__c = false;
            confAtr.SBQQ__Product__c = testProduct.Id;
            confAtr.SBQQ__ColumnOrder__c = '1';
            confAtr.SBQQ__DisplayOrder__c =1;
            Insert confAtr;
            
            list<Account> acclistNew = TestDataFactory.createAccount('test', usr);
            Database.insert(acclistNew);
            
            // list<Account> locationlistNew = TestDataFactory.createLocation('Location', usr, acclistNew.get(0).id);
            // //Added for SDT-39637
            // locationlistNew[0].tz__Timezone_SFDC__c = 'America/Detroit';
            // Database.insert(locationlistNew);
            
            // list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationlistNew.get(0));
            // entitlementlist[0].container__c = '';
            // entitlementlist[1].container__c = '';
            // entitlementlist[2].container__c = '';
            // Database.insert(entitlementlist);
            
            List<SBQQ__ProductOption__c> testWaste = QuoteFavoritesController.getWasteStreams(testProduct.Id);
            system.assertEquals(testWaste.size(), 1);
            
            
            Map<String, String> testSizes = QuoteFavoritesController.getSizes(testProduct.Id, false);
            Map<String, String> testAllSizes = QuoteFavoritesController.getSizes(testProduct.Id, true);
            // system.assertNotEquals(testSizes, testAllSizes);
            
            List<QuoteFavoritesController.FavoriteWrapper> fw = QuoteFavoritesController.getFavorites(testProduct.Id);
            system.assertNotEquals(fw, null);
            
            SBQQ__QuoteLine__c permTest = [SELECT Id, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__ProductFamily__c, Duration__c,
                                           SBQQ__Quote__r.SBQQ__Account__r.ParentId, SBQQ__Quote__r.Project__c, SBQQ__ProductName__c,
                                           SBQQ__Quote__r.SBQQ__Account__r.tz__Timezone_SFDC__c
                                           FROM SBQQ__QuoteLine__c where SBQQ__Product__r.Name!='Compactor' LIMIT 1];
            permTest.Duration__c = 'TEMP';
            permTest.SBQQ__RequiredBy__c = null;
            update permTest;
            SBQQ__Favorite__c fav=[select id,name from SBQQ__Favorite__c where name=: 'Test Fav'];	
            
            List<SBQQ__ProductOption__c> testWasteList = QuoteFavoritesController.getWasteStreams(testProduct.Id);
            
            //  BusinessHours businessHoursOBJ  = [SELECT Id FROM BusinessHours WHERE Name =: Constant_Util.BUSINESSNAME and IsActive = true LIMIT 1];
            QuoteFavoritesController.getFavorites(testProduct.Id);
            QuoteFavoritesController.getPreselectedProduct(testProduct.name); 
            
            //List<Project_Code__c> activeProjects = QuoteProcurementController.getActiveProjects(quoteList[0].Id, 'Floor');
            
            // Entitlement EntitlementObj =  QuoteFavoritesController.getEntitlement(entitlementlist,parentQl,'Permanent');
            // EntitlementObj.Request_Type__c = Constant_Util.NEW_SERVICE;
            // EntitlementObj.Status__c =  Constant_Util.APPROVED;
            // EntitlementObj.Container__c = '';
            // EntitlementObj.AccountId = quoteList[0].SBQQ__Account__c;
            // EntitlementObj.Location__c = null;//quoteList[0].SBQQ__Account__c;
            // EntitlementObj.StartDate = system.today();
            // EntitlementObj.EndDate = system.today()+2;
            // EntitlementObj.Schedule_Type__c = 'Permanent';
            // EntitlementObj.Service__c = 'Permanent';
            // //EntitlementObj.Project_Code__c = activeProjects[0].id;
            // update EntitlementObj;
            //quoteList[0].Project__c = activeProjects[0].id;
            //update quoteList[0];
            //  QuoteFavoritesController.getRelatedEntitleMentforprojectrecalculation(quoteList[0].id, parentQl.id);
            try{
                QuoteFavoritesController.createNonFavoriteLine(parentQl.id, testProduct.Id, testWasteList[0].Id,'30 Yards');
            }
            catch(Exception e){}
            QuoteFavoritesController.addQuoteFavorite(fav.Id,quoteList[0].id);
            
            // SBQQ__ProductRule__c rule =[select id from SBQQ__ProductRule__c where Name =: 'Make Product description mandatory']; 
            // SBQQ__ProductAction__c prodAction = new SBQQ__ProductAction__c();
            // prodAction.SBQQ__Type__c = 'Add';
            // prodAction.SBQQ__Product__c = prdList[0].Id;
            // prodAction.SBQQ__Rule__c = rule.id;
            // insert prodAction;
            //QuoteFavoritesController.getSizesByProductAndWasteStream(prdList[0].Id, sbqq.Id);
            //DateTime permSlaDate = QuoteFavoritesController.determineSLA(permTest.Id);
            //     system.assertNotEquals(permSlaDate, null);
            // adding from here
            //QuoteFavoritesController.getSizesByProductAndWasteStream();
            // end
            test.StopTest();
        }
    }   
    
    
    //SDT-29961 - Asset Availability
    @isTest public static void testDetermineSLACompactor(){
        //39637
        Code_Switch__c csData = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch', false);
        insert csData;
        //ends
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        SBQQ__QuoteLine__c qli = [SELECT Id FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null AND SBQQ__Product__r.Name!='Compactor'  LIMIT 1];
        //Change as SEAS duration Industry SLA not available, SDT-39637
        qli.Duration__c = 'PERM';
        qli.SBQQ__RequiredBy__c = null;
        update qli;
        //SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //List<SBQQ__QuoteLine__c> classHeaders = QuoteProcurementController.getQuoteProducts(testQuote.Id);
        List<String> equipmentSizes = new List<String>{'YRDS-20','YRDS-30'};
            Test.startTest();
        QuoteFavoritesController.determineSLA(qli.Id);
        Test.stopTest();
    }
    @isTest public static void testDetermineSLAForAlternateProducts(){
        //39637
        Code_Switch__c csData = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch', false);
        insert csData;
        //ends
        
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        SBQQ__QuoteLine__c qli = [SELECT Id FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null AND SBQQ__Product__r.Name='Compactor'  LIMIT 1];
        //SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //List<SBQQ__QuoteLine__c> classHeaders = QuoteProcurementController.getQuoteProducts(testQuote.Id);
        List<String> equipmentSizes = new List<String>{'YRDS-20','YRDS-30'};
            Test.startTest();
        Map<String,Date> slaDates = QuoteFavoritesController.determineSLAForAlternateProducts(qli.Id,equipmentSizes);
        system.debug('Check date list: '+ slaDates);
        system.assert(slaDates.size()!=0);
        Test.stopTest();
    }
    @isTest public static void testDetermineSLAForAlternateNonCompactorProducts(){
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        SBQQ__QuoteLine__c qli = [SELECT Id FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null AND SBQQ__Product__r.Name!='Compactor'  LIMIT 1];
        //SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //List<SBQQ__QuoteLine__c> classHeaders = QuoteProcurementController.getQuoteProducts(testQuote.Id);
        List<String> equipmentSizes = new List<String>{'YRDS-20','YRDS-30'};
            Test.startTest();
        Map<String,Date> slaDates = QuoteFavoritesController.determineSLAForAlternateProducts(qli.Id,equipmentSizes);
        //system.assert(slaDates.size()!=0);
        Test.stopTest();
    }
    
    
    @isTest public static void testcalculateISSLA() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = '';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__c;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Schedule_Type__c = 'Temporary';
            entitlementlist[0].Service__c = 'Temporary';
            entitlementlist[0].Service_Guarantee_Category__c = 'Days';
            Database.insert(entitlementlist);
            
            BusinessHours businessHoursCST  = [SELECT Id FROM BusinessHours WHERE Name =: 'WM SBS - America/Chicago' and IsActive = true LIMIT 1];
            Industry_Standard_SLA__mdt indSLA  = [SELECT Id, DeveloperName, After__c, Before__c FROM Industry_Standard_SLA__mdt WHERE DeveloperName = 'New_Service_Temporary_Services' LIMIT 1];
            DateTime dt = QuoteFavoritesController.calculateISSLA(indSLA, businessHoursCST);  
            System.debug('QuoteFavoritesController.determineSLA==> ' + dt);
            DateTime dt1 = QuoteFavoritesController.calculateEntitlementSLA(entitlementlist[0],businessHoursCST);  
            DateTime dt2 = QuoteFavoritesController.calculateEntitlementSLA_LocTimezone(entitlementlist[0],businessHoursCST,'America/Chicago');
            System.debug('QuoteFavoritesController.calculateEntitlementSLA==> ' + dt1);
            
            system.assert(dt != null);
            system.assert(dt1 != null);
            Test.StopTest();
        }
    }
    
    @isTest public static void testgetRelatedEntitleMentAfter() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        Code_Switch__c csData = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch', false);
        insert csData;
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            List<Account> accListParent;
            accListParent = TestDataFactory.createAccount('TestParentAccount', usr,'Client');
            accListParent[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accListParent;
            
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            accList[0].ParentId = accListParent[0].Id;
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Dumpster','Equipment', 'DMP');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Commercial';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'PERM',1.00,'CLT','YRDS-4','SCH','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location 123';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = 'Dumpster';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            // entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__r.ParentId;
            entitlementlist[0].Location__c = null;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Before_After__c = 'After';
            entitlementlist[0].Call_Time__c = '14:00';
            entitlementlist[0].Schedule_Type__c = 'Permanent';
            entitlementlist[0].Service__c = 'Permanent';
            Database.insert(entitlementlist);
            
            SBQQ__QuoteLine__c ql = [Select Id, SBQQ__Quote__c From SBQQ__QuoteLine__c Where LocationPositionName__c = 'Test Location 123' Limit 1];
            Entitlement ent = QuoteFavoritesController.getRelatedEntitleMent(ql.SBQQ__Quote__c, ql.Id);  
            System.debug('Entitlement==> ' + ent);
            
            //system.assert(ent != null);
            Test.StopTest();
        }
    }
    
     @isTest public static void testgetRelatedEntitleMentBefore() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        Code_Switch__c csData = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch', false);
        insert csData;
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            List<Account> accListParent;
            accListParent = TestDataFactory.createAccount('TestParentAccount', usr,'Client');
            accListParent[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accListParent;
            
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            accList[0].ParentId = accListParent[0].Id;
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location 123';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = 'Open Top';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            // entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__r.ParentId;
            entitlementlist[0].Location__c = null;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Before_After__c = 'Before';
            entitlementlist[0].Call_Time__c = '13:00';
            entitlementlist[0].Schedule_Type__c = 'Temporary';
            entitlementlist[0].Service__c = 'Temporary';
            Database.insert(entitlementlist);
            
            SBQQ__QuoteLine__c ql = [Select Id, SBQQ__Quote__c From SBQQ__QuoteLine__c Where LocationPositionName__c = 'Test Location 123' Limit 1];
            Entitlement ent = QuoteFavoritesController.getRelatedEntitleMent(ql.SBQQ__Quote__c, ql.Id);  
            System.debug('Entitlement==> ' + ent);
            
            system.assert(ent != null);
            Test.StopTest();
        }
    }
    
    //Comment the test case for SDT-39637 and SDT-45007
    
  /*  @isTest public static void testDetermineSLA() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            System.debug('$$$$limitbeforestoptest$$$$' + Limits.getLimitQueries());
            
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = 'Open Top';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            Database.insert(entitlementlist);
            
            BusinessHours businessHoursOBJ  = [SELECT Id FROM BusinessHours WHERE Name =: Constant_Util.BUSINESSNAME and IsActive = true LIMIT 1];
            DateTime dt = QuoteFavoritesController.determineSLA(parentQl.Id);  
            
            //system.assert(dt != null);
            test.StopTest();
        }
    }   
    
    @isTest public static void testDetermineSLACompactor1() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            // Product2 trash = new Product2();
            // trash.Name = 'Trash';
            // trash.ProductCode = 'T_WC';
            // trash.Family = 'Waste Category';
            // trash.IsActive = true;
            // trash.SBQQ__ExcludeFromOpportunity__c = true;
            // insert trash;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Compactor','Equipment', 'CMP');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            System.debug('$$$$limitbeforestoptest$$$$' + Limits.getLimitQueries());
            
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            DateTime dt = QuoteFavoritesController.determineSLA(parentQl.Id);  
            
            system.assert(dt != null);
            test.StopTest();
        }
    }  
    
    @isTest public static void testDetermineSLAEntitlement() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            System.debug('$$$$limitbeforestoptest$$$$' + Limits.getLimitQueries());
            
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = '';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__c;
            //entitlementlist[0].Location__c = null;//quoteList[0].SBQQ__Account__c;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Schedule_Type__c = 'Temporary';
            entitlementlist[0].Service__c = 'Temporary';
            // update EntitlementObj;
            Database.insert(entitlementlist);
            
            BusinessHours businessHoursOBJ  = [SELECT Id FROM BusinessHours WHERE Name =: Constant_Util.BUSINESSNAME and IsActive = true LIMIT 1];
            DateTime dt = QuoteFavoritesController.determineSLA(parentQl.Id);  
            System.debug('QuoteFavoritesController.determineSLA==> ' + dt);
            
            List<String> equipmentSizes = new List<String>{'YRDS-20','YRDS-30'};
                Map<String,Date> slaDates = QuoteFavoritesController.determineSLAForAlternateProducts(parentQl.Id,equipmentSizes);
            system.debug('Check date list: '+ slaDates);
            
            system.assert(dt != null);
            system.assert(slaDates.size()!=0);
            Test.StopTest();
        }
    } 
    
    @isTest public static void testcalculateISSLA() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = '';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__c;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Schedule_Type__c = 'Temporary';
            entitlementlist[0].Service__c = 'Temporary';
            Database.insert(entitlementlist);
            
            BusinessHours businessHoursCST  = [SELECT Id FROM BusinessHours WHERE Name =: 'WM SBS - America/Chicago' and IsActive = true LIMIT 1];
            Industry_Standard_SLA__mdt indSLA  = [SELECT Id, DeveloperName, After__c, Before__c FROM Industry_Standard_SLA__mdt WHERE DeveloperName = 'New_Service_Temporary_Services' LIMIT 1];
            DateTime dt = QuoteFavoritesController.calculateISSLA(indSLA, businessHoursCST);  
            System.debug('QuoteFavoritesController.determineSLA==> ' + dt);
            DateTime dt1 = QuoteFavoritesController.calculateEntitlementSLA(entitlementlist[0],businessHoursCST);  
            System.debug('QuoteFavoritesController.calculateEntitlementSLA==> ' + dt1);
            
            system.assert(dt != null);
            system.assert(dt1 != null);
            Test.StopTest();
        }
    } 
    
    @isTest public static void testgetRelatedEntitleMentBefore() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            List<Account> accListParent;
            accListParent = TestDataFactory.createAccount('TestParentAccount', usr,'Client');
            accListParent[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accListParent;
            
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            accList[0].ParentId = accListParent[0].Id;
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location 123';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = 'Open Top';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            // entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__r.ParentId;
            entitlementlist[0].Location__c = null;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Before_After__c = 'Before';
            entitlementlist[0].Call_Time__c = '13:00';
            entitlementlist[0].Schedule_Type__c = 'Temporary';
            entitlementlist[0].Service__c = 'Temporary';
            Database.insert(entitlementlist);
            
            SBQQ__QuoteLine__c ql = [Select Id, SBQQ__Quote__c From SBQQ__QuoteLine__c Where LocationPositionName__c = 'Test Location 123' Limit 1];
            Entitlement ent = QuoteFavoritesController.getRelatedEntitleMent(ql.SBQQ__Quote__c, ql.Id);  
            System.debug('Entitlement==> ' + ent);
            
            system.assert(ent != null);
            Test.StopTest();
        }
    }
    
    @isTest public static void testgetRelatedEntitleMentAfter() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            List<Account> accListParent;
            accListParent = TestDataFactory.createAccount('TestParentAccount', usr,'Client');
            accListParent[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accListParent;
            
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            accList[0].ParentId = accListParent[0].Id;
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Dumpster','Equipment', 'DMP');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Commercial';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'PERM',1.00,'CLT','YRDS-4','SCH','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location 123';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = 'Dumpster';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            // entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__r.ParentId;
            entitlementlist[0].Location__c = null;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Before_After__c = 'After';
            entitlementlist[0].Call_Time__c = '14:00';
            entitlementlist[0].Schedule_Type__c = 'Permanent';
            entitlementlist[0].Service__c = 'Permanent';
            Database.insert(entitlementlist);
            
            SBQQ__QuoteLine__c ql = [Select Id, SBQQ__Quote__c From SBQQ__QuoteLine__c Where LocationPositionName__c = 'Test Location 123' Limit 1];
            Entitlement ent = QuoteFavoritesController.getRelatedEntitleMent(ql.SBQQ__Quote__c, ql.Id);  
            System.debug('Entitlement==> ' + ent);
            
            //system.assert(ent != null);
            Test.StopTest();
        }
    }
    
    @isTest public static void testDetermineSLA_calculateEntitlementSLA() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
            Test.startTest();
            List<Account> accListParent;
            accListParent = TestDataFactory.createAccount('TestParentAccount', usr,'Client');
            accListParent[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert accListParent;
            
            List<Account> accList;
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            accList[0].ParentId = accListParent[0].Id;
            insert accList;
            
            List<Contact> conList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            
            List<Account> locationList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            //Added for SDT-39637
            locationList[0].tz__Timezone_SFDC__c = 'America/Chicago';
            insert locationList;
            
            List<Case> caseList= new List<Case>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            
            List<Opportunity> oppList = new List<Opportunity>();
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            
            List<Product2> prdList = new List<Product2>();
            Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
            prodOpenTop.Is_Pricing_Eligible__c = true;
            prodOpenTop.Family = 'Rolloff';
            prdList.add(prodOpenTop);
            insert prdList;
            System.debug('%%prdList'+prdList);
            
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
            insert quoteList; 
            
            SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prdList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location 123';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.SBQQ__Number__c=1;
            insert parentQl;
            
            list<Entitlement> entitlementlist = TestDataFactory.createEntitlement('test', locationList.get(0));
            entitlementlist[0].container__c = 'Open Top';
            entitlementlist[1].container__c = '';
            entitlementlist[2].container__c = '';
            
            entitlementlist[0].Request_Type__c = Constant_Util.NEW_SERVICE;
            entitlementlist[0].Status__c =  Constant_Util.APPROVED;
            // entitlementlist[0].AccountId = quoteList[0].SBQQ__Account__r.ParentId;
            entitlementlist[0].Location__c = null;
            entitlementlist[0].StartDate = system.today();
            entitlementlist[0].EndDate = system.today()+2;
            entitlementlist[0].Before_After__c = 'Before';
            entitlementlist[0].Call_Time__c = '13:00';
            entitlementlist[0].Schedule_Type__c = 'Temporary';
            entitlementlist[0].Service__c = 'Temporary';
            Database.insert(entitlementlist);
            
            SBQQ__QuoteLine__c ql = [Select Id, SBQQ__Quote__c From SBQQ__QuoteLine__c Where LocationPositionName__c = 'Test Location 123' Limit 1];
            DateTime dt = QuoteFavoritesController.determineSLA(ql.Id);  
            System.debug('QuoteFavoritesController.determineSLA==> ' + dt);
            
            List<String> equipmentSizes = new List<String>{'YRDS-20','YRDS-30'};
                Map<String,Date> slaDates = QuoteFavoritesController.determineSLAForAlternateProducts(ql.Id,equipmentSizes);
            system.debug('Check date list: '+ slaDates);
            system.assert(slaDates.size()!=0);
            
            system.assert(dt != null);
            Test.StopTest();
        }
    }
*/
    //End the test
}