@isTest //(SeeAllData=true)  
public class QuoteProcurementControllerTest {

    private static final string US_LOCATION = 'United States';
    private static final string CANADA_LOCATION = 'Canada';
    private static final string US_CANADA_ENDDATEOFFSET = 'United States_7;Canada_7';
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    //Modified by Yugandhar Adem for SDT-47978
    //private static final String BACKDATED_REASON = 'Back-dated service requested';
    private static final String BACKDATED_REASON = 'Delivery not needed/container on site';
 
    public static final String AAV_API_REQUEST_OUTPUT = '{"data": {"requestedDate": "2023-09-04","lineOfBusiness": "Roll Off","customerCode": "HMD","customerName": "The Home Depot","locationCode": "HMD006959","materialCode": "T","materialName": "Trash","countryCode": "USA","suppliers": [{"availabilitySource": "WM","supplierCode": null,"supplierName": null,"contractType": "Competitor","wasteStreamCode": "MSW","wasteStreamName": "Municipal Solid Waste","zoneCode": "GIS624853","zoneName": "Non WM Franchise - Bainbridge - CM MSW","wmMetaData": {"marketAreaCode": "K00126","marketAreaName": "WM of South Atlantic","facilityId": "GA0075","facilityName": "Albany Hauling","siteId": "S10284","siteName": "Albany Hauling"},"tpMetaData": null,"deliveryDays": null,"serviceDays": null,"deliveries": null,"outages": null,"messages": [{"code": "ER400","description": "WM Schedule information not available due to Competitor / Franchise Contract Type"}]}],"messages": []},"problem": null}';
    @testSetup
    static void createData() {
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
            CodeSwitchTestData.CodeSwitchData();
           //Changes for SDT-39632
            Code_Switch__c qLValidationsetting = QuoteTestDataFactory.createCodeSwitch('New_Quote_Validation',false);
            Insert qLValidationsetting;
            
            Code_Switch__c codeSwitchSLA = QuoteTestDataFactory.createCodeSwitch('SLA Logic Switch',false);
            Insert codeSwitchSLA;
            //Changes for SDT-20689
            Code_Switch__c multiVendorSwitchAM = QuoteTestDataFactory.createCodeSwitch('Pricing MulltiVendor AM Switch',false);
            Insert multiVendorSwitchAM;
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
    
    @isTest public static void testHeaderAndDetail() {
        
        test.startTest();
        
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        List<SBQQ__QuoteLine__c> classHeaders = QuoteProcurementController.getQuoteProducts(testQuote.Id);
        List<SBQQ__QuoteLine__c> classDetails = QuoteProcurementController.getQuoteDetails(classHeaders[0].Id);
        List<SBQQ__QuoteLine__c> lineHeaderRecords = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__ProductFamily__c 
                                                      FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: testQuote.Id AND
                                                      SBQQ__RequiredBy__c = null];
        List<SBQQ__QuoteLine__c> lineDetailRecords = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__ProductFamily__c 
                                                      FROM SBQQ__QuoteLine__c WHERE
                                                      (SBQQ__RequiredBy__c =: classHeaders[0].Id OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: classHeaders[0].Id)
                                                      AND SBQQ__ProductFamily__c != 'Waste Category'];
        
        test.stopTest();
        
        system.assertEquals(classHeaders.size(), lineHeaderRecords.size());
        system.assertEquals(classDetails.size(), lineDetailRecords.size());
    }
    
    @isTest public static void testWrapperClass() {
        
        test.startTest();
        SBQQ__Quote__c testQuote = returnTestQuote('Product Configured');
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        QuoteProcurementController.ProductsWrapper testWrapper = QuoteProcurementController.buildWrapper(testQuote.Id);
        test.stopTest();
        
        System.assertNotEquals(testWrapper, null);
        
    }
    
    @istest public static void testVendorAndMAS() {
        
        test.startTest();
        
        //TCS-pkulkarn-SDT-42525-8-Nov-2024-Added SBQQ__PricingMethod__c, CostPrice1__c, CostPrice2__c, PricePrice1__c, PricePrice2__c to the SOQL. To fix the test class issues.
        SBQQ__QuoteLine__c testQL = [SELECT Id, SBQQ__ProductName__c,Occurrence_Type__c, Schedule_Frequency__c, Frequency_Interval__c, PriceUOM__c, 
                                     Vendor__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, MASLibrary__c, MASCompany__c, Vendor_Commit_Date__c,SBQQ__EndDate__c,VCRCode__c, SBQQ__ListPrice__c,
                                     SetupComment__c, Vendor__r.Id, Vendor__r.Name, SBQQ__Product__r.Name,Vendor__r.Parent_Vendor_ID__c, CostModelType__c, Equipment_Size__c, Vendor__r.FacilityCode__c,Vendor__r.Status__c, SBQQ__ProductFamily__c,
                                     SBQQ__PricingMethod__c, CostPrice1__c, CostPrice2__c, PricePrice1__c, PricePrice2__c, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.STP__c, Service_Days__c, SBQQ__Quote__r.Case_record_Type__c
                                     //IsAssetQuotelineDifferent__c, AssetId__c, SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, BypassPriceReview__c, ByPassMASServiceChange__c
                                     // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                                     //Vendor__r.Name, Vendor__r.Parent_Vendor_ID__c, CostModelType__c, Equipment_Size__c
                                     FROM SBQQ__QuoteLine__c
                                     where SBQQ__RequiredBy__c = null and SBQQ__Product__r.Name = 'Dumpster'
                                     LIMIT 1];
        
        Account vendorAcc = [Select id,Name,Vendor_Business_Unit__c from Account where 
                                   Id =: testQL.Vendor__r.Id  AND Status__c = 'Active' AND RecordType.Name = 'Vendor' LIMIT 1];
        
        //sdt-29645
        vendorAcc.FacilityCode__c = '123';
        update vendorAcc;
        
        //String searchString = 'WMI of';
        String searchString = 'WM';
        List<Account> vendorList = QuoteProcurementController.searchVendors(searchString);
        Account a = new Account();
        for (Account iter : vendorList) {
            if (iter.Vendor_Business_Unit__c != null) {
                a = iter;
                break;
            }
        }
        system.assertNotEquals(vendorList, null);
        //shajiya
        // Case 1 - Scheduled service missing frequency
        testQL.Occurrence_Type__c = 'SOC';
        testQL.Schedule_Frequency__c = null;
        String socMsg = QuoteProcurementController.vFStage(testQL);
        System.assertEquals(
            'Scheduled service missing a service frequency (weekly, monthly, etc.)',
            socMsg,
            'SOC missing frequency check.'
        );
    
        // Case 2 - Weekly scheduled service missing day(s)
        testQL.Occurrence_Type__c = 'SCH';
        testQL.Schedule_Frequency__c = 'W';
        String weeklyMsg = QuoteProcurementController.vFStage(testQL);
        System.assertEquals(
            'Weekly scheduled service missing day(s) of the week',
            weeklyMsg,
            'SCH weekly missing days check.'
        );
       // **Vendor Status Check  if vendor is inactive**
        testQL.Vendor__r.Status__c = 'Inactive'; 
        String vendorStatusError = QuoteProcurementController.vFStage(testQL);
        system.assertEquals(vendorStatusError, 'Selected vendor is not active ');
     
 
        // **Skip WM Fee Validation if Vendor is Inactive**
       
        if (testQL.Vendor__r.Status__c == 'Active') {
    	// **WM Fee Unit Cost Validation** - Only perform this if the vendor is active
        testQL.MASLibrary__c = '192A';   
        testQL.MASCompany__c = '060';    
        testQL.SetupComment__c = 'Valid Setup Comment'; 
        testQL.SBQQ__UnitCost__c = 100; 
 
        String wmFeeError = QuoteProcurementController.vSStage(testQL);
        system.assertEquals(wmFeeError, 'WM Fee charges requires a price greater than 0');
        }

        //vss stage
        // Case 1️: Inactive Vendor
            
        testQL.SBQQ__Quote__r.SBQQ__Type__c = 'Amendment';
        testQL.Vendor__r.Status__c = 'Inactive';
        testQL.MASCustomerUniqueId__c = 12345; 
        testQL.MASLibrary__c = '192A';   
        testQL.MASCompany__c = '060';    
        testQL.SetupComment__c = 'Valid Setup Comment'; 
        String inactiveVendorErr = QuoteProcurementController.vSStage(testQL);
        System.assertEquals('Selected vendor is not active ', inactiveVendorErr);
    
        // Case 2️: WM Fee Vendor with non-zero cost
        testQL.Vendor__r.Status__c = 'Active';
        testQL.Vendor__r.Name = 'WM Fee Vendor';
        testQL.SBQQ__UnitCost__c = 50;
        String wmFeeErr = QuoteProcurementController.vSStage(testQL);
        System.assertEquals(wmFeeErr, QuoteProcurementController.strCostModelTypeSTP);
    
    
        // Case 3: End Date before Vendor Commit Date
        testQL.Vendor_Commit_Date__c = System.today().addDays(10);
        testQL.SBQQ__EndDate__c = System.today().addDays(5);
        String dateErr = QuoteProcurementController.vSStage(testQL);
        System.assertEquals(dateErr, 'End Dates must be greater than the vendor commit date');
            
        // Case 4: Missing MAS Unique ID (Amendment Quote)
        testQL.MASCustomerUniqueId__c = null;
        testQL.SBQQ__Quote__r.SBQQ__Type__c = 'Amendment';
        String masIdErr = QuoteProcurementController.vSStage(testQL);

        // System.assertEquals(QuoteProcurementController.strMassIdMissing, masIdErr);
        //SDT-29645 STP method returnMASDetails no longer used instead returnUniqueMASDetails
        //List<AggregateResult> masResultClass = QuoteProcurementController.returnMASDetails(a.Vendor_Business_Unit__c);
        
        List<AggregateResult> masResultClass = QuoteProcurementController.returnUniqueMASDetails(testQL.Id);
        //SDT-29645 end
        List<AggregateResult> masResultManual = [SELECT MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c
                                                 FROM MAS_Setup_Detail__c
                                                 WHERE Business_Unit_Number__c =: a.Vendor_Business_Unit__c
                                                 GROUP BY MAS_Library__c, MAS_Company_Code__c, MAS_Line_of_Business__c, Bypass_Price_Review__c];
        
        test.stopTest();
        
        system.assertEquals(masResultClass, masResultManual);
        
        testQL.Occurrence_Type__c = 'SCH';
        testQL.Schedule_Frequency__c = 'D';
        testQL.Frequency_Interval__c = null;
        String occurrenceTest = QuoteProcurementController.validateOccurence(testQL);
        //system.assertEquals(occurrenceTest, 'Non-weekly Scheduled/SOC service missing frequency interval');
        
        testQL.Occurrence_Type__c = 'OC';
        String onCallTest = QuoteProcurementController.validateOccurence(testQL);
        system.assertEquals(onCallTest, 'On-call Service should not contain a Service Frequency or Frequency interval');

        testQL.SBQQ__PricingMethod__c = 'PER';	//TCS-pkulkarn-SDT-42525-8-Nov-2024-Added to fix the test class issues.
        testQL.PriceUOM__c = '';
        String priceUOMTest = QuoteProcurementController.vTStage(testQL);
        //System.debug('@@priceUOMTest'+priceUOMTest);
        system.assertEquals(priceUOMTest, 'Missing price unit of measure');
        
        if (testQL.Vendor__r.Parent_Vendor_ID__c == '8') {
            testQL.MASLibrary__c = '';
            testQL.MASCompany__c = '';
            // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
            testQL.SetupComment__c = '';
           // String wmVendorTest = QuoteProcurementController.vSStage(testQL);
           // system.assertEquals(wmVendorTest, 'Missing MAS Library, Company Code or Setup Comment');
            
            testQL.MASLibrary__c = '192A';
            testQL.MASCompany__c = '060';
            // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
            testQL.SetupComment__c = 'test';
        }
        testQL.Cost_Unit_of_Measure__c = '';
        //String costUOMTest = QuoteProcurementController.vSStage(testQL);
        //system.assertEquals(costUOMTest, 'Vendor missing');
        
        testQL.Cost_Unit_of_Measure__c = 'EV';
        testQL.CostModelType__c = 'PER';
        testQL.SBQQ__UnitCost__c = null;
        //String costTest = QuoteProcurementController.vSStage(testQL);
        //system.assertEquals(costTest, 'Vendor missing');
        
        SBQQ__QuoteLine__c newQL = QuoteProcurementController.getQuoteLineForOrders(testQL.Id);
        system.assertEquals(newQL.Id, testQL.Id);
        
        Boolean testUpdate = QuoteProcurementController.updateQuoteLineForOrders(newQL);
        //system.assertEquals(testUpdate, true);
        
    }
    
    @isTest public static void testMASReturnData() {
        
        test.startTest();
        List<SBQQ__QuoteLine__c> MASQuoteLineManual = [SELECT Id, MASLibrary__c FROM SBQQ__QuoteLine__c WHERE MASLibrary__c != null LIMIT 1];
        List<SBQQ__QuoteLine__c> MASQuoteLineClass = QuoteProcurementController.getQuoteLineMASDetails(MASQuoteLineManual[0].Id);
        test.stopTest();
        
        system.assertEquals(MASQuoteLineManual[0].Id, MASQuoteLineClass[0].Id);
    }
    
    @isTest public static void testHeaderFunctions() {
        
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //adding mock callout
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        QuoteProcurementController.ProductsWrapper testWrapper = QuoteProcurementController.buildWrapper(testQuote.Id);
        
        Boolean testCompanyCategoryResult;
        Boolean testOverviewUpdate;
        String testUpdateFinancial;
        RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        if(SBQQ.TriggerControl.isEnabled()){
            	SBQQ.TriggerControl.disable();
        }

        test.startTest();
        for (QuoteProcurementController.HeaderWrapper header : testWrapper.configuredProducts) {
            
            testCompanyCategoryResult = QuoteProcurementController.updateCompanyCategories(header);
            header.equipmentSize = '30 Yards';
        //    testOverviewUpdate = QuoteProcurementController.updateQuoteOverview(header);
            testUpdateFinancial = QuoteProcurementController.updateFinancialDetail(header.parentId, true, 'Test', 'Test','Test', 'Test');
            break;
        }
        test.stopTest();
        
        
        system.assertEquals(testCompanyCategoryResult, true);
    //    system.assertEquals(testOverviewUpdate, true);
        system.assertEquals(testUpdateFinancial, 'Success');
    }
    
    @isTest public static void testWrapperUpdates() {
        test.startTest();
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //making mock callout
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        QuoteProcurementController.ProductsWrapper testWrapper = generateWrapper(testQuote.Id);
        
        QuoteProcurementController.FinancialDetailWrapper fWrap = new QuoteProcurementController.FinancialDetailWrapper();
        QuoteProcurementController.MASWrapper masWrap = new QuoteProcurementController.MASWrapper();
        
        masWrap = QuoteProcurementController.getMasDetails(testWrapper.configuredProducts[0].parentId);
        fWrap = QuoteProcurementController.getQLFinancialDetail(testWrapper.configuredProducts[0].parentId);
        
        system.assertNotEquals(masWrap, null);
        system.assertNotEquals(fWrap, null);
        test.stoptest();
        
    }
    
    @isTest public static void testVendorUpdates() {
        test.startTest();
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //making mock callout
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        QuoteProcurementController.ProductsWrapper testWrapper = generateWrapper(testQuote.Id);
        Boolean testVendorResult;
        //Boolean testMASResults;
        QuoteProcurementController.MASResponseWrapper response = new QuoteProcurementController.MASResponseWrapper();
        testWrapper.configuredProducts[0].vendorId = [SELECT Id FROM Account WHERE RecordType.Name = 'Vendor' LIMIT 1].Id;
        testWrapper.configuredProducts[0].companyCategory = 'TestCategory';
        testWrapper.configuredProducts[0].MAS.MASCompany = '123A';
        RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        if(SBQQ.TriggerControl.isEnabled()){
            	SBQQ.TriggerControl.disable();
        }
        testVendorResult = QuoteProcurementController.updateVendorDetails(testWrapper.configuredProducts[0]);
        response = QuoteProcurementController.writeMASDetails(testWrapper.configuredProducts[0]);
        
       // system.assertEquals(response.IsSuccess, true);
        //system.assertEquals(testVendorResult, true);
        test.stopTest();
    }
    
    @isTest public static void testCaseFunctions() {
        
        test.startTest();
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //List<QuoteProcurementController.ProductsWrapper> dupQuotes = QuoteProcurementController.getDuplicates(testQuote.SBQQ__Opportunity2__r.Case__c);
        //List<QuoteProcurementController.ProductsWrapper> caseQuotes = QuoteProcurementController.getCaseQuotes(testQuote.SBQQ__Opportunity2__r.Case__c);
        String caseId = QuoteProcurementController.goToCase(testQuote.Id);
        test.stopTest();
        
        //system.assertNotEquals(caseQuotes, null);
        system.assertNotEquals(caseId, null);
        
    }
    @isTest public static void testPositions() {
        
        test.startTest();
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //adding mock callout
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        QuoteProcurementController.ProductsWrapper testWrapper = QuoteProcurementController.buildWrapper(testQuote.Id);
        List<Account_Position__c> ALP = new List<Account_Position__c>();
        List<Account_Position__c> ALPSearch = new List<Account_Position__c>();
        String onsiteResult;
        String offsiteResult;
        
        for (QuoteProcurementController.HeaderWrapper header : testWrapper.configuredProducts) {
            ALP = QuoteProcurementController.allPositions(header);
            ALPSearch = QuoteProcurementController.searchPositions(header, 'Default');
            onsiteResult = QuoteProcurementController.storeOnsite(header, 'TestingPosition');
            offsiteResult = QuoteProcurementController.storeOffsite(header, 'BackTest', '123 main street', 'windsor', 'ct', '06095');
            break;
        }
        test.stopTest();
        system.assertNotEquals(ALP, null);
        system.assertNotEquals(ALPSearch, null);
        system.assertEquals(onsiteResult, 'Success');
        system.assertEquals(offsiteResult, 'Success');
    }
    
    @isTest public static void addFavorites() {
        test.startTest();
        QuoteProcurementController.FavoriteContainerWrapper fcw = QuoteProcurementController.getFavorites();
        system.assertNotEquals(fcw, null);
        test.stopTest();
        
    }
    
    @isTest public static void testPicklists() {
        test.startTest();
        List<String> picklist = QuoteProcurementController.getPicklistSchema();
        system.assertNotEquals(picklist, null);
        test.stoptest();
        
    }
    
    @isTest public static void getQuoteFunctions() {
        
        test.startTest();
        SBQQ__Quote__c testQuote = returnTestQuote('Product Configured');
        SBQQ__Quote__c q1 = QuoteProcurementController.getQuoteForOrders(testQuote.Id);
        SBQQ__Quote__c q2 = QuoteProcurementController.getQuoteStatusDetails(testQuote.Id);
        Business_Rule__c testBR = QuoteProcurementController.quoteBusinessRules(testQuote.Id, 'Pickup', 'Empty and Return');
        List<Project_Code__c> activeProjects = QuoteProcurementController.getActiveProjects(testQuote.Id, 'Floor');
        
        Id productId = [SELECT Id FROM Product2 WHERE Name = 'Open Top' AND ProductCode = 'OT' AND IsActive = true].Id;
        String updateStatus = QuoteProcurementCOntroller.updateStatus(testQuote.Id, 'Declined', true);
        test.stopTest();
        
        system.assertEquals(testQuote.Id, q1.Id);
        system.assertEquals(testQuote.Id, q2.Id);
        system.assertNotEquals(testBR, null);
        system.assertNotEquals(activeProjects, null);
        //system.assertEquals(updateStatus, 'SUCCESS');
        
        Boolean success = QuoteProcurementController.updateQuoteForOrders(testQuote);
        system.assertEquals(success, true);
    }
    
    @isTest public static void createQuoteLines() {
        try{
            if(SBQQ.TriggerControl.isEnabled()){
            	SBQQ.TriggerControl.disable();
        	}
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = true;
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        System.runAs(usr){
        List<Account> accList;
        accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
        insert accList;
        
        List<Contact> conList;
        conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
        conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
        conList[0].Phone= '1890870468';
        insert conList;
        
        List<Account> locationList;
        locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
        insert locationList;
        
        List<Case> caseList= new List<Case>();
        caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
        insert caseList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
        insert oppList;
        
        Product2 trash = new Product2();
        trash.Name = 'Open Top';
        trash.ProductCode = 'OT';
        trash.Family = 'Waste Category';
        trash.IsActive = true;
        trash.SBQQ__ExcludeFromOpportunity__c = true;
        insert trash;
        
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
        insert quoteList;
        
        SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],trash,'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
        parentQl.LocationPositionName__c='Test Location';
        parentQl.SBQQ__StartDate__c= Date.today();
        parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
        parentQl.SBQQ__Number__c=1;
        insert parentQl;
        
        SBQQ__Quote__c testQuote = returnTestQuote('Product Configured');
        
        Product2 testProduct = [SELECT Id,Name,ProductCode FROM Product2 LIMIT 1];
        
        
        String testSize = 'YRDS-30';
        SBQQ__ProductOption__c testCategory = [SELECT Id FROM SBQQ__ProductOption__c LIMIT 1];
        List<SBQQ__ProductOption__c> testWasteList = QuoteFavoritesController.getWasteStreams(testProduct.Id);
        
        System.debug('quoteList-->'+quoteList);
        System.debug('testProduct-->'+testProduct);
        System.debug('testWasteList-->'+testWasteList);
        System.debug('testSize-->'+testSize); 
         
        test.startTest();
        String str = QuoteProcurementController.createQuoteLines(quoteList[0].Id, testProduct.Id, testWasteList[0].Id, testSize);
        System.debug('str-->'+str); 
        test.stopTest();
        }
        //  system.assertNotEquals(testResult, '');
        }Catch(Exception e){
            System.debug('Exception-->' + e.getMessage() + 'At Line no. -->' + e.getLineNumber());
        } 
        
    }
    
    
    @isTest public static void checkPicklists() {
        test.starttest();
        List<String> slaPicklists = QuoteProcurementCOntroller.getSLAOverrideReasons();
        
        List<String> slaReasons = new List<String>();
        Schema.DescribeFieldResult slaPicklistField = SBQQ__QuoteLine__c.SLA_Override_Reason__c.getDescribe();
        List<Schema.PicklistEntry> slaPicklistValues = slaPicklistField.getPicklistValues();
        for (Schema.PicklistEntry pck : slaPicklistValues) {
            slaReasons.add(pck.getValue());
        }
        system.assertEquals(slaPicklists, slaReasons);
        test.stoptest();
        
    }
    
    @isTest public static void testOrders() {
        //Query some account and pass it to the company categories method
        List<Account> acctNumber = [Select Customer_Code__c from Account limit 1];
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Dumpster' AND ProductCode = 'DMP' LIMIT 1];
        List<String> acctIds = new List<String>();       
        For (Account a: acctNumber) {
            acctIds.add(a.Customer_Code__c);
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        
        Map<String, String> methodMaps = AcornCompanyDetails.getAcornCCMap(acctIds[0]);

        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        QuoteProcurementController.ProductsWrapper testWrapper = QuoteProcurementController.buildWrapper(testQuote.Id);
        QuoteProcurementController.OrderWrapper classWrapper = QuoteProcurementController.generateOrderWrapper();
        //system.assertEquals(classWrapper.parentQuoteLine, '');
        
        classWrapper.parentQuoteLine = testWrapper.configuredProducts[0].parentId;
        classWrapper.serviceDate = system.today();
        classWrapper.serviceType = 'Delivery';
        classWrapper.quantity = 1;
        classWrapper.onsiteContact = 'Test Contact';
        classWrapper.onsitePhone = '1111111111';
        classWrapper.PONumber = '1111111';
        classWrapper.duration = 'TEMP';
        classWrapper.quoteId = testQuote.Id;
        RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
        Test.stopTest();
        List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];
        system.assertEquals(wrapper.result, 'SUCCESS');
        List<Quote_Order__c> qoList = [SELECT Id FROM Quote_Order__c];
        String result = QuoteProcurementController.deleteQuoteOrders(qoList);
        SBQQ__ConfigurationAttribute__c confAtr = new SBQQ__ConfigurationAttribute__c();
        confAtr.SBQQ__TargetField__c = 'Equipment_Style__c';
        confAtr.SBQQ__ApplyToProductOptions__c = false;
        confAtr.SBQQ__Product__c = testProduct.Id;
        confAtr.SBQQ__ColumnOrder__c = '1';
        confAtr.SBQQ__DisplayOrder__c =1;
        Insert confAtr;
        QuoteProcurementController.getConfigAttributes(testProduct.Id,qlListForQuote[0].Id);
        system.assertEquals(result, 'SUCCESS');
        QuoteProcurementController.getMaterialTypes('Cardboard');
        
    }
    @isTest public static void testAddAcc() {
        test.starttest();
       
        List<Account> vendorAcc = [Select id,Name,Vendor_Business_Unit__c from Account where RecordType.Name = 'Vendor' LIMIT 1];
        System.debug('@@@vendorAcc'+vendorAcc);
        
        List<MAS_Setup_Detail__c> masLst = [Select id,MAS_Line_of_Business__c,MAS_Company_Code__c,MAS_Library__c,Business_Unit_Number__c from MAS_Setup_Detail__c where MAS_Company_Code__c = '286'];
        RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> testQL = [SELECT Id, Occurrence_Type__c, Schedule_Frequency__c, Frequency_Interval__c, PriceUOM__c, 
                                     Vendor__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, MASLibrary__c, MASCompany__c,
                                     SetupComment__c,Description_of_Waste__c, Vendor__r.Name, Vendor__r.Parent_Vendor_ID__c, CostModelType__c, Equipment_Size__c, SBQQ__ProductName__c
                                     // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
                                     //Description_of_Waste__c, Vendor__r.Name, Vendor__r.Parent_Vendor_ID__c, CostModelType__c, Equipment_Size__c, SBQQ__ProductName__c
                                     FROM SBQQ__QuoteLine__c
                                     LIMIT 2];
        //testQL.Vendor__c = vendorAcc[0].Id;
        testQL[0].SBQQ__RequiredBy__c = null;
        testQL[1].Duration__c = 'PERM';
        testQL[1].SBQQ__RequiredBy__c = null;
        //qlList.add(testQL);
        //update testQL;
        
        /*SBQQ__QuoteLine__c permTest = [SELECT Id, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__ProductFamily__c, Duration__c,
                                       SBQQ__Quote__r.SBQQ__Account__r.ParentId, SBQQ__Quote__r.Project__c, SBQQ__ProductName__c
                                       FROM SBQQ__QuoteLine__c
                                       LIMIT 1];
        permTest.Duration__c = 'PERM';
        permTest.SBQQ__RequiredBy__c = null;
        qlList.add(permTest);*/
        //update permTest;
        update qlList;
        
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Dumpster' AND ProductCode = 'DMP' LIMIT 1];
        List<SBQQ__ProductOption__c> productOptionList = QuoteProcurementController.getAccessories(testProduct.Id);
        system.assertNotEquals(productOptionList.size(), 0);
        
        List<SBQQ__ErrorCondition__c> testError = SBQQConfigurationRuleService.getProductRules(testProduct.Id);
        system.assertNotEquals(testError, null);
        
        QuoteProcurementController.showLocationPosition(testQL[1].Id);
        
        Set<Id> testActions = SBQQConfigurationRuleService.getActions(testError, testQL[0]);
        system.assertNotEquals(testActions, null);
        Set<Id> addTest = SBQQConfigurationRuleService.getAddRuleProducts(testActions);
        Set<Id> remTest = QuoteProcurementController.getRemRuleProducts(testActions);
        
        system.assertNotEquals(addTest, null);
        system.assertNotEquals(remTest, null);
        test.stoptest();
    }
    
    @isTest public static void testFavoritesController() {
        test.startTest();
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        User currentUser = [Select Id, FirstName FROM User WHERE FirstName =: 'testUser#99997' AND Bypass_Validation__c =: True AND Genesys_Enabled__c =: FALSE LIMIT 1];
        System.runAs(currentUser) {
        List<Account> accList;
        accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
        insert accList;
        
        List<Contact> conList;
        conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
        conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
        conList[0].Phone= '1890870468';
        insert conList;
        
        List<Account> locationList;
        locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
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
           test.stopTest();
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
        sbqq.SBQQ__Number__c = 350;
        sbqq.SBQQ__Quantity__c = 1;
        sbqqLst.add(sbqq);
        insert sbqqLst;
        
        List<SBQQ__ProductOption__c> testWaste = QuoteFavoritesController.getWasteStreams(testProduct.Id);
        system.assertEquals(testWaste.size(), 1);
        Map<String, String> testSizes = QuoteFavoritesController.getSizes(testProduct.Id, false);
        Map<String, String> testAllSizes = QuoteFavoritesController.getSizes(testProduct.Id, true);
        system.assertNotEquals(testSizes, testAllSizes);
        
        List<QuoteFavoritesController.FavoriteWrapper> fw = QuoteFavoritesController.getFavorites(testProduct.Id);
        system.assertNotEquals(fw, null);
        
        SBQQ__QuoteLine__c permTest = [SELECT Id, SBQQ__Quote__r.SBQQ__Account__c, SBQQ__ProductFamily__c, Duration__c,
                                       SBQQ__Quote__r.SBQQ__Account__r.ParentId, SBQQ__Quote__r.Project__c, SBQQ__ProductName__c
                                       FROM SBQQ__QuoteLine__c LIMIT 1];
        permTest.Duration__c = 'PERM';
        permTest.SBQQ__RequiredBy__c = null;
        update permTest;
        
        //     DateTime permSlaDate = QuoteFavoritesController.determineSLA(permTest.Id);
        //     system.assertNotEquals(permSlaDate, null);
        }
        
        
    }
    
    @isTest public static void testInsertQLParts() {
        test.startTest();
        SBQQ__ProductOption__c wasteCategoryOption  = returnProductOption();
        SBQQ__ProductOption__c materialOption = QuoteProcurementController.getMaterialOption(wasteCategoryOption.id);
        if(materialOption!=null && materialOption.Id != null){
            SBQQ__ProductOption__c getCategoryOption = QuoteProcurementController.getCategoryOption(materialOption.SBQQ__OptionalSKU__c, materialOption.SBQQ__ConfiguredSKU__c);
        }
        SBQQ__QuoteLine__c pQLine = insertParentQuoteLine();
        if(pQLine != null && pQLine.id!=null){
            Decimal quoteLineNumber = QuoteProcurementController.getMaxQuoteLineNumber(pQLine.SBQQ__Quote__c);    
        }
        test.stopTest();
        
        /*SBQQ__Quote__c testQuote = returnTestQuote('Product Configured');
List<SBQQ__QuoteLine__c> testLines = [SELECT Id, SBQQ__ProductFamily__c, SBQQ__ProductOption__c, SBQQ__RequiredBy__c, SBQQ__Product__c
FROM SBQQ__QuoteLine__c
WHERE SBQQ__Quote__c =: testQuote.Id];

String materialOption;
String categoryOption;
String productOption;
if (testLines.size() > 0) {
for (SBQQ__QuoteLine__c testQL : testLines) {
productOption =  (testQL.SBQQ__RequiredBy__c == null) ? testQL.SBQQ__Product__c : productOption;
materialOption =  (testQL.SBQQ__ProductFamily__c == 'Waste Stream') ? testQL.SBQQ__ProductOption__c : materialOption;
categoryOption =  (testQL.SBQQ__ProductFamily__c == 'Waste Category') ? testQL.SBQQ__Product__c : productOption;
}

SBQQ__ProductOption__c getMaterialOption = QuoteProcurementController.getMaterialOption(materialOption);
SBQQ__ProductOption__c getCategoryOption = QuoteProcurementController.getCategoryOption(getMaterialOption.SBQQ__ConfiguredSKU__c, productOption);
Decimal quoteLineNumber = QuoteProcurementController.getMaxQuoteLineNumber(testQuote.Id);

system.assertNotEquals(getMaterialOption, null);
system.assertNotEquals(getCategoryOption, null);
system.assertNotEquals(quoteLineNumber, 0);
}*/
        
    }
    public static SBQQ__ProductOption__c returnProductOption(){
        Product2 trash = new Product2();
        trash.Name = 'Trash';
        trash.ProductCode = 'T_WC';
        trash.Family = 'Waste Category';
        trash.IsActive = true;
        trash.SBQQ__ExcludeFromOpportunity__c = true;
        insert trash;
        
        Product2 prodOT = TestDataFactory.createProduct('Open Top','Equipment','OT');
        prodOT.Bypass_Acorn_Integration__c= false;
        insert prodOT;
        
        SBQQ__ProductFeature__c featureOne = new SBQQ__ProductFeature__c();
        featureOne.Name = 'Waste Stream';
        featureOne.SBQQ__MinOptionCount__c = 1;
        featureOne.SBQQ__MaxOptionCount__c = 1;
        featureOne.SBQQ__Number__c = 10;
        featureOne.SBQQ__ConfiguredSKU__c = prodOT.id;
        featureOne.SBQQ__Category__c = 'Waste Category';
        insert featureOne;
        
        SBQQ__ProductOption__c option = new SBQQ__ProductOption__c();
        option.SBQQ__Number__c = 1;
        option.SBQQ__ConfiguredSKU__c = prodOT.id;
        option.SBQQ__Quantity__c = 1;
        option.SBQQ__OptionalSKU__c = trash.id;
        option.SBQQ__Feature__c = featureOne.id;
        option.SBQQ__Bundled__c = true;
        insert option;
        return option;
    }
    public static SBQQ__QuoteLine__c insertParentQuoteLine(){
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        
        List<Account> accList;
        accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
        insert accList;
        
        List<Contact> conList;
        conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
        conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
        conList[0].Phone= '1890870468';
        insert conList;
        
        List<Account> locationList;
        locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
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
        
        SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],trash,'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
        parentQl.LocationPositionName__c='Test Location';
        parentQl.SBQQ__StartDate__c= Date.today();
        parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
        parentQl.SBQQ__Number__c=1;
        insert parentQl;
        return parentQl;
    }
    /*
    @isTest public static void addProductOption() {
        //SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //SBQQ__Quote__c testQuote = getQuoteInsertedQuote();
        Test.startTest();
        SBQQ__Quote__c testQuote = [Select Id From SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' limit 1];
        System.debug('quote>>'+testQuote.Id);
        List<SBQQ__QuoteLine__c> classHeaders = QuoteProcurementController.getQuoteProducts(testQuote.Id);
        System.debug('%%classHeaders'+classHeaders);
        System.debug('%%testQuote'+testQuote);
        
        List<Product2> prdList = new List<Product2>();
        Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Equipment', 'OT');
        prodOpenTop.Is_Pricing_Eligible__c = true;
        prdList.add(prodOpenTop);
        insert prdList;
        System.debug('%%prdList'+prdList);
        
        List<SBQQ__ProductOption__c> sbqqLst = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
        sbqq.SBQQ__OptionalSKU__c = prdList[0].Id;
        sbqq.SBQQ__Number__c = 350;
        sbqq.SBQQ__Quantity__c = 1;
        sbqqLst.add(sbqq);
        insert sbqqLst;
        
        System.debug('###sbqqLst'+sbqqLst);
        System.debug('&&&sbqqLst[0].Id'+sbqqLst[0].Id);
        System.debug('##testQuote.Id'+testQuote.Id);
        
        List<SBQQ__QuoteLine__c> sbQuoteLine = new List<SBQQ__QuoteLine__c>();
        QuoteProcurementController.addProductOption(classHeaders[0].Id,sbqqLst[0].Id);
        SBQQ__QuoteLine__c quoteLine = [SELECT Id
                                        FROM SBQQ__QuoteLine__c
                                        WHERE SBQQ__RequiredBy__c =: classHeaders[0].Id AND SBQQ__ProductOption__c =: sbqqLst[0].Id
                                        LIMIT 1];
        QuoteProcurementController.removeProductOption(classHeaders[0].Id,sbqqLst[0].Id);
        Test.stopTest();
    }

    */
    @isTest public static void addProductOption2() {
        test.startTest();
        //SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        if(SBQQ.TriggerControl.isEnabled()){
            	SBQQ.TriggerControl.disable();
        	}
        //SBQQ__Quote__c testQuote = getQuoteInsertedQuote();
        SBQQ__Quote__c testQuote = [Select Id,SBQQ__Account__c,SBQQ__StartDate__c From SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' ORDER BY CreatedDate DESC limit 1];
        System.debug('%%testQuote'+testQuote);
        
        List<Product2> prdList = new List<Product2>();
        Product2 prodDumpster = TestDataFactory.createProduct('Dumpster','Equipment', 'DMP');
        prodDumpster.Is_Pricing_Eligible__c = true;
        prdList.add(prodDumpster);
        Product2 prodPadlock = TestDataFactory.createProduct('Gravity with Padlock Bar','Equipment', 'LCKFEE');
        prodPadlock.Is_Pricing_Eligible__c = true;
        prdList.add(prodPadlock);
        Product2 prodKeys = TestDataFactory.createProduct('Keys','Equipment', 'LCKFEE');
        prodKeys.Is_Pricing_Eligible__c = false;
        prdList.add(prodKeys);
        insert prdList;
        System.debug('%%prdList'+prdList);
        
        List<SBQQ__ProductOption__c> sbqqLst = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
        sbqq.SBQQ__ConfiguredSKU__c = prdList[0].Id;
        sbqq.SBQQ__OptionalSKU__c = prdList[1].Id;
        sbqq.SBQQ__Number__c = 350;
        sbqq.SBQQ__Quantity__c = 1;
        sbqqLst.add(sbqq);
        SBQQ__ProductOption__c sbqq1 = new SBQQ__ProductOption__c();
        sbqq1.SBQQ__ConfiguredSKU__c = prdList[1].Id;
        sbqq1.SBQQ__OptionalSKU__c = prdList[2].Id;
        sbqq1.SBQQ__Number__c = 350;
        sbqq1.SBQQ__Quantity__c = 1;
        sbqqLst.add(sbqq1);
        insert sbqqLst;
        
        System.debug('###sbqqLst'+sbqqLst);
        System.debug('&&&sbqqLst[0].Id'+sbqqLst[0].Id);
        System.debug('##testQuote.Id'+testQuote.Id);
        
        List<SBQQ__QuoteLine__c> sbQuoteLine = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(testQuote,prodDumpster,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlDMP.SBQQ__Bundle__c = TRUE;
        qlDMP.SBQQ__RequiredBy__c = null;
        qlDMP.SBQQ__Number__c = 1;
        sbQuoteLine.add(qlDMP);
        insert sbQuoteLine;
        QuoteProcurementController.addProductOption(sbQuoteLine[0].Id,sbqqLst[0].Id);
        SBQQ__QuoteLine__c quoteLine = [SELECT Id
                                        FROM SBQQ__QuoteLine__c
                                        WHERE SBQQ__RequiredBy__c =: sbQuoteLine[0].Id AND SBQQ__ProductOption__c =: sbqqLst[0].Id
                                        LIMIT 1];
        QuoteProcurementController.addProductOption(quoteLine.Id,sbqqLst[1].Id);
        List<Id> idList = new List<Id>();
        idList.add(prdList[1].Id);
        QuoteProcurementController.getPadlockKeys(idList);
        List<QuoteProcurementController.KeyMapWrapper> keyList= new List<QuoteProcurementController.KeyMapWrapper>();
        QuoteProcurementController.KeyMapWrapper keyObj= new QuoteProcurementController.KeyMapWrapper();
		keyObj.id=sbqqLst[1].Id;
		keyObj.value='1';    
        keyList.add(keyObj);
        QuoteProcurementController.updateKeysQuantity(sbQuoteLine[0].Id,keyList);
        QuoteProcurementController.removeProductOption(sbQuoteLine[0].Id,sbqqLst[0].Id,sbqqLst[1].Id);
        test.stopTest();
    }
    public static SBQQ__Quote__c getQuoteInsertedQuote(){
        Profile adminProfile = TestDataFactory.getProfile('System Administrator');
        
        User usr = TestDataFactory.createUser(adminProfile);
        Database.insert(usr); 
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        list<Account> acclist = new List<Account>();
        
        Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='5678',
                                        RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
        insert accParent;
        
        Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='1234',
                                  RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
        acclist.add(acc);
        
        Account vendorAcc = new Account(Name = 'WM Vendor Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
                                        RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
        acclist.add(vendorAcc);
        
        Database.insert(acclist);
        
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
        Database.insert(conlist);
        
        list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
        locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
        locationlist[0].IsPricingEligible__c = true;
        Database.insert(locationlist);
        
        
        Case newServiceCase = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0),usr,locationlist.get(0)); 
        newServiceCase.Service_Date__c = system.today() + 1;
        newServiceCase.SLA_Service_Date_Time__c = system.today() + 2;
        newServiceCase.Case_Type__c = 'New Service';
        newServiceCase.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'New Service Case'].Id;  
        newServiceCase.Case_Sub_Type__c = 'Permanent';
        newServiceCase.Case_Reason__c = 'Existing Location';
        newServiceCase.LOB__c = 'Rolloff';
        newServiceCase.Status = 'Open';
        newServiceCase.Service_Occurrence_Type_Code__c = 'On-Call';
        newServiceCase.Material_Type__c = 'Trash';
        
        
        oppList.addAll(TestDataFactory.createOpportunity(1,'TestOpportunityTest',newServiceCase.Id,newServiceCase.Case_Sub_Type__c, newServiceCase.Location__c));
        insert oppList;
        
        quoteList.addAll(TestDataFactory.createQuoteRecords(oppList,acclist[0],conlist[0],Date.today(),false,true));
        quoteList[0].SBQQ__ShippingStreet__c = 'ABC';
        quoteList[0].SBQQ__ShippingCity__c = 'Test1';
        quoteList[0].SBQQ__ShippingCountry__c = 'USA';
        quoteList[0].SBQQ__ShippingState__c = 'NY';
        quoteList[0].SBQQ__ShippingPostalCode__c = '1234';
        quoteList[0].Duration__c = 'Permanent';
        quoteList[0].SBQQ__Status__c = 'Draft';
        insert quoteList;
        
        Account_Position__c accLocPosition = new Account_Position__c(AccountId__c = acclist[0].Id,
                                                                     Container_Position__c = 'Test 2',
                                                                     AlternatePostalCode__c = '1234',
                                                                     AlternateCity__c = 'Test City',
                                                                     AlternateCountry__c = 'USA',
                                                                     AlternateState__c = 'NY',
                                                                     AlternateStreet__c = 'Day Hill Road');
        insert accLocPosition;
        
        List<Product2> prdList = new List<Product2>();
        
        Product2 prodOpenTop = TestDataFactory.createProduct('Open Top','Rolloff', 'OT');
        prodOpenTop.Is_Pricing_Eligible__c = true;
        prdList.add(prodOpenTop);
        
        Product2 prodCompactor = TestDataFactory.createProduct('Compactor','Equipment', 'CMP');
        prodCompactor.Is_Pricing_Eligible__c = true;
        prdList.add(prodCompactor);
        
        Product2 prodDumpster = TestDataFactory.createProduct('Dumpster','Commercial', 'DMP');
        prodDumpster.Is_Pricing_Eligible__c = true;
        prdList.add(prodDumpster);
        
        Product2 prodNull= TestDataFactory.createProduct('Error','Equipment','ERR');
        prodNull.Is_Pricing_Eligible__c = true;
        prdList.add(prodNull);
        
        Product2 prodPickup= TestDataFactory.createProduct('Pickup','Services','PCK');
        prdList.add(prodPickup);
        
        Product2 prodExPickup= TestDataFactory.createProduct('Extra Pickup','Services','PCK');
        prdList.add(prodExPickup);
        
        Product2 prodHaul= TestDataFactory.createProduct('Haul','Services','H');
        prdList.add(prodHaul);
        
        Product2 prodDisposal= TestDataFactory.createProduct('Disposal','Services','DSP');
        prdList.add(prodDisposal);
        
        Product2 prodDelivery= TestDataFactory.createProduct('Delivery','Surcharges and Fees','DLV');
        prdList.add(prodDelivery);
        
        Product2 prodLandfill= TestDataFactory.createProduct('Landfill Fee','Surcharges and Fees','LF');
        prdList.add(prodLandfill);
        
        Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
        prodTrash.Is_Pricing_Eligible__c = true;
        prdList.add(prodTrash);
        
        Product2 prodCardboard = TestDataFactory.createProduct('Cardboard','Waste Stream','C');
        prodCardboard.Is_Pricing_Eligible__c = true;
        prdList.add(prodCardboard);
        
        Database.insert(prdList);
        
        List<SBQQ__QuoteLine__c> qlHdr = new List<SBQQ__QuoteLine__c>();
        //Bundle 1 - Open Top
        SBQQ__QuoteLine__c qlOT = TestDataFactory.createQuoteLineRecords(quoteList[0],prodOpenTop,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlOT.SBQQ__Bundle__c = TRUE;
        qlOT.SBQQ__RequiredBy__c = null;
        qlOT.Vendor__c = vendorAcc.Id;
        qlOT.SBQQ__Number__c = 1;
        qlOT.Location_Position_Name__c = accLocPosition.Id;
        qlHdr.add(qlOT);
        
        insert qlHdr;
        
        return quoteList[0];
    }
    @isTest public static void addQuoteAndQuoteineTest(){
        SBQQ__Favorite__c fav = [Select Id FROM SBQQ__Favorite__c LIMIT 1];
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        Test.startTest();
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        String Id = QuoteProcurementController.addQuoteAndQuoteine(String.valueOf(fav.Id), String.valueOf(testQuote.SBQQ__Opportunity2__r.Case__c),String.valueOf(testQuote.Id),true);
        Test.stopTest();
    }

    @isTest public static void addQuoteAsProductNotListedTest(){
        Case c= [SELECT Id, Status, Location__c, ContactId, CaseNumber, Service_Date__c,Case_Sub_Type__c, Reference_Number__c, Tracking_Number__c, Integrate_with_Acorn__c
        FROM Case LIMIT 1];
        Test.startTest();
        String quoteID = QuoteProcurementController.addQuoteAsProductNotListed(String.valueOf(c.Id));
        Test.stopTest();
    }
    
    @isTest public static void getQuoteLineForOrdersWrapperTest(){
        SBQQ__Quoteline__c qline= [SELECT Id FROM SBQQ__Quoteline__c WHERE SBQQ__requiredby__c= null LIMIT 1];
        Test.startTest();
        QuoteProcurementController.qLineWrapper qw = QuoteProcurementController.getQuoteLineForOrdersWrapper(qline.id);
        Test.stopTest();
    }

        @isTest public static void getCaseQuotesTest(){
        Profile p= TestDataFactory.getProfile('System Administrator');
		User usr= TestDataFactory.createUser(p);
        usr.Bypass_Validation__c = TRUE;
        usr.Genesys_Enabled__c = FALSE;
		insert usr;
        System.runAs(usr){
          //Querying data for creating quote and case
          List<Account> accList = [SELECT Id FROM Account WHERE AccountNumber = 'ParentTest'LIMIT 1];
          List<Contact> conList = [SELECT Id FROM Contact WHERE FirstName = 'TestContactTest' LIMIT 1];
          List<Account> locationList = [SELECT Id,ParentId FROM Account WHERE Name = 'TestLocationAccountTest' LIMIT 1];
          
           //inserting case record
          Case caseRec = TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]);
          caseRec.Service_Date__c= System.today();
		  insert caseRec;
          
            //Inserting opportunity record
          List<Opportunity>oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseRec.Id,caseRec.Case_Sub_Type__c, locationList[0].Id);
		  insert oppList;
          
          //Inserting quote record
          List <SBQQ__Quote__c> quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
          insert quoteList;
		
            // trying mock callout
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        List<QuoteProcurementController.ProductsWrapper> pwList = QuoteProcurementController.getCaseQuotes(String.valueOf(caseRec.Id));
         Test.stopTest(); 
        }
          
    }

    @isTest public static void getDuplicatesTest(){
        Test.startTest();
        Case c= [SELECT Id, Status, Location__c, ContactId, CaseNumber, Service_Date__c,Case_Sub_Type__c, Reference_Number__c, Tracking_Number__c, Integrate_with_Acorn__c,recordtype.name
        FROM Case LIMIT 1];
        c.Service_Date__c= System.today();
        update c;
        
        List<QuoteProcurementController.ProductsWrapper> pwList = QuoteProcurementController.getDuplicates(String.valueOf(c.Id));
        Test.stopTest();
    }

    @isTest public static void updateConfigAttributeTest(){
        Test.startTest();
        SBQQ__Quoteline__c qline= [SELECT Id,SBQQ__Quote__c FROM SBQQ__Quoteline__c WHERE SBQQ__requiredby__c= null LIMIT 1];
        
        String str = QuoteProcurementController.updateConfigAttribute(qline.Id,'MASLibrary__c','ARDTA.129A',qline.SBQQ__Quote__c);
        Test.stopTest();
    }

    // @isTest public static void fetchUserTest(){
    //     Test.startTest();
    //     QuoteProcurementController.fetchUser();
    //     Test.stopTest();
    // }

    @isTest public static void validateHaulRemovalqLineTest(){
        SBQQ__QuoteLine__c qline = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null AND SBQQ__ProductFamily__c='Rolloff' LIMIT 1];
        Test.startTest();
        String result = QuoteProcurementController.validateHaulRemovalqLine(qline.id,String.valueOf(System.today()));
        Test.stopTest();
    }
    @isTest public static void validateHaulRemovalqLineTest1(){
        SBQQ__QuoteLine__c qline = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = null AND SBQQ__ProductFamily__c='Commercial' LIMIT 1];
        Test.startTest();
        String result = QuoteProcurementController.validateHaulRemovalqLine(qline.id,String.valueOf(System.today()));
        Test.stopTest();
    }

    @isTest public static void removeProductOptionTest(){
        Test.startTest();
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        //SBQQ__Quote__c testQuote = getQuoteInsertedQuote();
        SBQQ__Quote__c testQuote = [Select Id,SBQQ__Account__c,SBQQ__StartDate__c From SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' ORDER BY CreatedDate DESC limit 1];
        System.debug('%%testQuote'+testQuote);
        
        List<Product2> prdList = new List<Product2>();
        Product2 prodDumpster = TestDataFactory.createProduct('Dumpster','Equipment', 'DMP');
        prodDumpster.Is_Pricing_Eligible__c = true;
        prdList.add(prodDumpster);
        Product2 prodPadlock = TestDataFactory.createProduct('Gravity with Padlock Bar','Equipment', 'LCKFEE');
        prodPadlock.Is_Pricing_Eligible__c = true;
        prdList.add(prodPadlock);
        Product2 prodKeys = TestDataFactory.createProduct('Keys','Equipment', 'LCKFEE');
        prodKeys.Is_Pricing_Eligible__c = false;
        prdList.add(prodKeys);
        insert prdList;
        System.debug('%%prdList'+prdList);
        
        List<SBQQ__ProductOption__c> sbqqLst = new List<SBQQ__ProductOption__c>();
        SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
        sbqq.SBQQ__ConfiguredSKU__c = prdList[0].Id;
        sbqq.SBQQ__OptionalSKU__c = prdList[1].Id;
        sbqq.SBQQ__Number__c = 350;
        sbqq.SBQQ__Quantity__c = 1;
        sbqqLst.add(sbqq);
        SBQQ__ProductOption__c sbqq1 = new SBQQ__ProductOption__c();
        sbqq1.SBQQ__ConfiguredSKU__c = prdList[1].Id;
        sbqq1.SBQQ__OptionalSKU__c = prdList[2].Id;
        sbqq1.SBQQ__Number__c = 350;
        sbqq1.SBQQ__Quantity__c = 1;
        sbqqLst.add(sbqq1);
        insert sbqqLst;
        
        System.debug('###sbqqLst'+sbqqLst);
        System.debug('&&&sbqqLst[0].Id'+sbqqLst[0].Id);
        System.debug('##testQuote.Id'+testQuote.Id);
        
        List<SBQQ__QuoteLine__c> sbQuoteLine = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlDMP = TestDataFactory.createQuoteLineRecords(testQuote,prodDumpster,'TEMP',1.00,'CLT','YRDS-30','OC','M','1','PER',34.00,'DYS','PER',null,'DYS','Do Not Override','NBG');
        qlDMP.SBQQ__Bundle__c = TRUE;
        qlDMP.SBQQ__RequiredBy__c = null;
        qlDMP.SBQQ__Number__c = 1;
        sbQuoteLine.add(qlDMP);
        insert sbQuoteLine;
        QuoteProcurementController.addProductOption(sbQuoteLine[0].Id,sbqqLst[0].Id);

        //Addition for test class errors
        SBQQ__QuoteLine__c quoteLine = [SELECT Id
        FROM SBQQ__QuoteLine__c
        WHERE SBQQ__RequiredBy__c =: sbQuoteLine[0].Id AND SBQQ__ProductOption__c =: sbqqLst[0].Id
        LIMIT 1];
        QuoteProcurementController.addProductOption(quoteLine.Id,sbqqLst[1].Id);

        
        QuoteProcurementController.removeProductOption(sbQuoteLine[0].Id,prdList[1].Id);
        Test.stopTest();
    }

    @isTest public static void validateDescriptionOfWasteForCustomTest(){

        Product2 openTopProdObj = [SELECT Id from Product2 WHERE Name = 'Open Top' LIMIT 1];
        QuoteProcurementController.HeaderWrapper productWrapper = new QuoteProcurementController.HeaderWrapper();
        productWrapper.materialType = 'Metal';
        productWrapper.productId = openTopProdObj.Id;
        productWrapper.wasteDescription = null;
        Test.startTest();
        Map<String,List<String>> resultMap = QuoteProcurementController.validateDescriptionOfWaste(productWrapper);
        System.assert(resultMap.containsKey('Failed'));
        Test.stopTest();
    }
    
    //SDT-42448
    @isTest public static void updateQuoteOverviewtest(){

          SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        
        QuoteProcurementController.ProductsWrapper testWrapper = QuoteProcurementController.buildWrapper(testQuote.Id);
        
        Boolean testOverviewUpdate;
       
        RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        if(SBQQ.TriggerControl.isEnabled()){
            	SBQQ.TriggerControl.disable();
        }

        test.startTest();
        for (QuoteProcurementController.HeaderWrapper header : testWrapper.configuredProducts) {
            
            header.equipmentSize = '30 Yards';
             testOverviewUpdate = QuoteProcurementController.updateQuoteOverview(header);
            break;
        }
        test.stopTest();
        
        
        system.assertEquals(testOverviewUpdate, true);
    }

    @isTest public static void getWasteStreamsTest(){

        Product2 openTopProdObj = [SELECT Id from Product2 WHERE Name = 'Open Top' LIMIT 1];
        Test.startTest();
        List<SBQQ__ProductOption__c> results = QuoteProcurementController.getWasteStreams(openTopProdObj.Id);
        System.assert(results != null);
        Test.stopTest();
    }

    @isTest public static void getPreselectedProductTest(){

        Product2 openTopProdObj = [SELECT Id, Name from Product2 WHERE Name = 'Open Top' LIMIT 1];
        Test.startTest();
        Product2 result = QuoteProcurementController.getPreselectedProduct(openTopProdObj.Name);
        System.assert(result != null);
        Test.stopTest();
    }

    @isTest public static void getProductsTest(){

        Test.startTest();
        List<Product2> products = QuoteProcurementController.getProducts();
        System.assert(products != null);
        Test.stopTest();
    }

    @isTest public static void getQuoteLinesByQuoteTest(){

        SBQQ__Quote__c testQuote = [Select Id,SBQQ__Account__c,SBQQ__StartDate__c From SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' ORDER BY CreatedDate DESC limit 1];
        Test.startTest();
        List<QuoteProcurementController.HeaderWrapper> results = QuoteProcurementController.getQuoteLinesByQuote(testQuote.Id);
	QuoteProcurementController.getReqBusinessRulesCC(testQuote.Id);
        System.assert(results != null);
        Test.stopTest();
    }

    @isTest public static void getDurationsTest(){

        Test.startTest();
        Map<String, String> results = QuoteProcurementController.getDurations();
        System.assert(results != null);
        Test.stopTest();
    }
    //SDT-30963 - Asset Availability
    @isTest public static void testUpdateAlternateProduct() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        SBQQ__QuoteLine__c qli = [SELECT Id FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null AND SBQQ__Quote__c =:testQuote.Id  LIMIT 1];
        QuoteProcurementController.HeaderWrapper productWrapper = new QuoteProcurementController.HeaderWrapper();
        productWrapper.parentId = qli.Id;
        productWrapper.equipmentSize = 'YRDS-40';
        Boolean Result=false;
        test.startTest();
        Result = QuoteProcurementController.updateAlternateProduct(productWrapper);
        test.stopTest();
        system.assert(Result);
        SBQQ__QuoteLine__c qliResult = [SELECT Id,Equipment_Size__c FROM SBQQ__QuoteLine__c where Id =:qli.Id LIMIT 1];
        system.assertEquals(qliResult.Equipment_Size__c,'YRDS-40');
    }
    //SDT-30864 - Asset Availability
    @isTest public static void testDeliveryOverrideReasons() {
        test.starttest();
        List<String> picklist = QuoteProcurementController.getDeliveryOverrideReasons();
        system.assert(picklist.size()!=0);
        test.stopTest();
    }
    //SDT-29961 - Asset Availability
    @isTest public static void testDetermineSLAForAlternateProducts(){
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        SBQQ__QuoteLine__c qli = [SELECT Id FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c=null AND SBQQ__Product__r.Name='Compactor'  LIMIT 1];
        //SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //List<SBQQ__QuoteLine__c> classHeaders = QuoteProcurementController.getQuoteProducts(testQuote.Id);
        List<String> equipmentSizes = new List<String>{'YRDS-20','YRDS-30'};
        Test.startTest();
        Map<String,Date> slaDates = QuoteFavoritesController.determineSLAForAlternateProducts(qli.Id,equipmentSizes);
        system.assert(slaDates.size()!=0);
        Test.stopTest();
    }

    //Addition for test class issues ***start
    //create test method for getCompanyCategory
        @isTest public static void testgetCompanyCategory() {
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        List<Map<String, String>> companyCategoryReturn = QuoteProcurementController.getCompanyCategory(testQuote.Id);
        
        System.assert(companyCategoryReturn.size()!=0);
        test.stopTest();
    }
    //create method for getAccessoriesWithSelection
        @isTest public static void testgetAccessoriesWithSelection() {
        test.startTest();
        SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        Set<id> quoteLineIDSet = new  Set<id>();
        Product2 testProduct = [SELECT Id FROM Product2 WHERE Name = 'Dumpster' AND ProductCode = 'DMP' LIMIT 1];
        Map<String,List<Object>> prodOptionMap = QuoteProcurementController.getAccessoriesWithSelection(testProduct.Id,testQuote.Id);
    //SDT 31262
    
        List<SBQQ__QuoteLine__c> qtLine = [Select Id,AssetId__c,SBQQ__Quote__r.Case_record_Type__c,Name,AssetId__r.Equipment_Size__c,SBQQ__RequiredBy__c,Equipment_Size__c,SBQQ__ProductFamily__c,SBQQ__Quantity__c,Occurrence_Type__c,Schedule_Frequency__c,Service_Days__c,CostModelType__c,PricingUnitMethod__c, SBQQ__Product__r.EndDateOffset__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Id, SBQQ__Product__r.Name, Account__r.ShippingCountry, SBQQ__StartDate__c, SBQQ__EndDate__c
                                               FROM SBQQ__QuoteLine__c Where Schedule_Frequency__c = 'W' 
                                                Limit 1];
        quoteLineIDSet.add(qtLine[0].id);

   
        Asset assetObj = [Select Id,ContactId,Quantity__c ,AccountId,Equipment_Size__c,Weekly_Frequency__c,Occurrence_Type__c,ParentId,RootAssetId,Product2Id,ProductCode,ProductFamily,ProductDescription from asset limit 1];                                                       
        
        QuoteLineServices.getQuoteLinesByIds(quoteLineIDSet);
        
        QuoteLineServices.getQuoteLinesByQuoteIdList(quoteLineIDSet);
       
        QuoteLineServices.setDefaultValuesForQuoteLines(qtLine[0],qtLine[0].Name);
        QuoteLineServices.isQuoteLineChangedforNonNs(qtLine[0]);
        QuoteLineServices.updateQuantityForLockProducts(qtLine[0], 1.2);
        QuoteLineServices.getQuoteLinesByQuoteId(testQuote.id);
        try {
        QuoteLineServices.setDefaultValuesForQuoteLines(qtLine[0], qtLine[0].SBQQ__Quote__r.Name,assetObj);
        }
        catch(Exception Ex){}
        test.stoptest();
        system.assert(prodOptionMap.keyset().size()!=0);

    }
    //adding for coverage of QuoteLineSelector
    @isTest public static void testQuoteLineServices() {
        test.starttest();
        User usr = [Select Id, FirstName From User Where FirstName =: 'testuser#9999' Limit 1];
        system.runAs(usr) {
            Id busHrsId = QuoteLineSelector.getBusinessHourId();
            try{
            //for US location
            //SDT 31262 adding CostModelType__c,PricingUnitMethod__c, to query
            List<SBQQ__QuoteLine__c> qtLine = [Select Id,CostModelType__c,PricingUnitMethod__c, SBQQ__Product__r.EndDateOffset__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Id, SBQQ__Product__r.Name, Account__r.ShippingCountry, SBQQ__StartDate__c, SBQQ__EndDate__c
                                               FROM SBQQ__QuoteLine__c Where LocationPositionName__c=:'Test Location' AND SBQQ__Product__r.Name =: 'Dumpster' Limit 1];
            
            QuoteLineServices.populateEndDateForQuoteline(qtLine[0], busHrsId);
            
            //querying quote
            List<SBQQ__Quote__c> quoteList = [Select Id, SBQQ__Account__c, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Id =: qtLine[0].SBQQ__Quote__r.Id LIMIT 1];
            QuoteLineServices.getQuoteLinesByQuoteId(quoteList[0].Id);
            
            Set<Id> quoteIds = new Set<Id>();
            quoteIds.add(quoteList[0].Id);
            QuoteLineServices.getQuoteLinesByQuoteIdList(quoteIds);

            Asset assetObj = [Select Id,ContactId,AccountId,ParentId,RootAssetId,Product2Id,ProductCode,ProductFamily,ProductDescription from asset limit 1];
            QuoteLineServices.setDefaultValuesForQuoteLines(qtLine[0], qtLine[0].SBQQ__Quote__r.Name,assetObj);
            
           }
            catch(exception ex) {
                system.debug(ex);
            }
            
        }
        test.stopTest();
    }
    
    @isTest public static void testQuoteLineServices2() {
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        test.starttest();
        User usr = [Select Id, FirstName From User Where FirstName =: 'testuser#9999' Limit 1];
        system.runAs(usr) {
            Id busHrsId = QuoteLineSelector.getBusinessHourId();
            
            //for CAN loc
            List<SBQQ__QuoteLine__c> qtLine = [Select Id,CostModelType__c,PricingUnitMethod__c, SBQQ__Product__r.EndDateOffset__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.Id, SBQQ__Product__r.Name, Account__r.ShippingCountry, SBQQ__StartDate__c, SBQQ__EndDate__c
                                               FROM SBQQ__QuoteLine__c Where LocationPositionName__c=:'Test Location' AND SBQQ__Product__r.Name =: 'Dumpster' Limit 1];
            qtLine[0].Account__r.ShippingCountry = CANADA_LOCATION; 
            update qtLine;
            QuoteLineServices.populateEndDateForQuoteline(qtLine[0], busHrsId);
            
        }
        test.stopTest();
    }      

     @isTest public static void NTETest() {
        
        test.startTest();
       
        //adding mock callout
        SBQQ__Quote__c testQuote2 = [SELECT Id, Name, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
                                    FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Cost Configured' AND Case__c != null];
                                    
        Product2 container = [SELECT id, Name, Family, ProductCode FROM Product2 WHERE name='Open Top' LIMIT 1];
        Product2 haulService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Haul' LIMIT 1];
        Product2 deliveryService = [SELECT Name, Family, SBQQ__Component__c, ProductCode FROM Product2 WHERE Name = 'Delivery' LIMIT 1];
        
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote2.Id,
                                                            SBQQ__Product__c = deliveryService.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                            SBQQ__ListPrice__c = 110,
                                                            NTE_amount_on_SR__c = 10,
                                                            Occurrence_Type__c='SOC');
        insert parentQL;
        
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote2.Id,
                                                           SBQQ__Product__c = deliveryService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           SBQQ__ListPrice__c = 110,
                                                           NTE_amount_on_SR__c = 10,
                                                           Occurrence_Type__c='SOC');
        SBQQ__QuoteLine__c qLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote2.Id,
                                                           SBQQ__Product__c = deliveryService.Id,
                                                           SBQQ__RequiredBy__c = parentQL.Id,
                                                           Occurrence_Type__c='SOC',
                                                           SBQQ__ListPrice__c = 110,
                                                           NTE_amount_on_SR__c = 10,
                                                          Schedule_Frequency__c='W');
        
        //qLineList.add(qLine);
        qLineList.addAll(new List<SBQQ__QuoteLine__c>{qLine,qLine1});
        insert qLineList;
        
        Business_Rule__c brRule = [Select Id,Alias__c,NTE_Rules__c,Category_Type__c,Required_Information__c,AccountId__c,Case_Reason__c,
                                                 LocationId__c,Group__c,RecordTypeId,End_Date__c,
                                                 Container__c,Material__c,Service__c,Schedule_Type__c,
                                                 Project_Code__c,AssetId__c from Business_Rule__c where  Request_Type__c = 'New Service' Limit 1];
    
        Service_Approver__c newSA = new Service_Approver__c();
            Id rtId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get('NTE_Approval').getRecordTypeId();
            newSA.Service_Type__c = 'Delivery';
            newSA.RecordTypeId = rtId;
            newSA.Business_Rule__c = brRule.Id;
            newSA.NTE_Rule_ExtId__c = 'Delivery' + '-'+brRule.Id;
            newSA.NTE_Amount__c = 100;
            newSA.Account__c = brRule.AccountId__c;
            newSA.Location__c = brRule.LocationId__c;
            newSA.Active__c = True;
            insert newSA;   
            
        brRule.Active__c = true; 
        update brRule;
	List<Id> qLIds = new List<Id>();
	     qLIds.add(qLineList[0].Id);
        List<QuoteProcurementController.nteWrapper> showNTEWrapper = QuoteProcurementController.showErrorWrapper(testQuote2.Id,qLIds);

                                                 
                                                 
         SBQQ__Quote__c testQuote = returnTestQuote('Draft');
        //Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsTest.AcornCompanyDetailsMock());
        //QuoteProcurementController.ProductsWrapper testWrapper = QuoteProcurementController.buildWrapper(testQuote.Id);
        
        test.stopTest();
       
    }

     //test method for SDT 25005 functionality
     @isTest public static void addCommentForSLAOverrideTest() {
        List<Case> caseList = [Select Id from Case where Site_Contact__c like '%TestSiteTest%'];
        List<Comment__c> commentList = [Select Id from Comment__c WHERE Case__c =: caseList[0].Id];
        System.assertEquals(commentList.size(), 0);
        
        List<SBQQ__QuoteLine__c> parentQl = [Select Id from SBQQ__QuoteLine__c where SBQQ__RequiredBy__c =: null 
                                             and sbqq__Quote__r.SBQQ__Opportunity2__r.Case__c =: caseList[0].Id limit 1];
        
        parentQl[0].SLA_Override_Reason__c = 'Repairs';
        parentQl[0].SLA_Override_Comment__c = 'test 1';
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        update parentQl[0];
        
        //for testing from Intake screen
        QuoteProcurementController.addCommentForSLAOverrideFromIntake(caseList[0].Id);
        
        //for testing from MIF flow
        QuoteProcurementController.InputWrapperForMIFFlow wrapperObj = new QuoteProcurementController.InputWrapperForMIFFlow();
        List<QuoteProcurementController.InputWrapperForMIFFlow> inputWrapperList = new List<QuoteProcurementController.InputWrapperForMIFFlow>();
        wrapperObj.caseId = caseList[0].Id;
        wrapperObj.slaComment = 'Repairs';
        wrapperObj.slaReason = 'test 1';
        inputWrapperList.add(wrapperObj);
        QuoteProcurementController.addCommentForSLAOverrideFromMIF(inputWrapperList);
        
        commentList = [Select Id from Comment__c WHERE Case__c =: caseList[0].Id];
        
        System.assertEquals(commentList.size(), 2);
        
            
    }
    /*
     * This Section marks the Start of STP related methods
	 */
    /*
     * @MethodName    : updateSpecialHandlingUncheckAutoTest
     * @description   : Test if updateSpecialHandling method is able to update special handling if Automated criteria is unchecked in quote for given quoteId and quoteline
     * @return        : void
     */
    @isTest
    public static void updateSpecialHandlingUncheckAutoTest(){
        Test.startTest();
        Id quoteId;
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        User adminUsr = [Select Id, FirstName From User Where FirstName =: 'testuser#9999' Limit 1];
        system.runAs(adminUsr){
            SBQQ__Quote__c testQuote = returnTestQuote('Draft');
            testQuote.Special_Handling_Reason__c = BACKDATED_REASON;
            SBQQ.TriggerControl.disable();
            RecurrsiveTriggerHandler.bypassValidation = true;
            update testQuote;
            SBQQ.TriggerControl.enable();
        }
        system.runAs(csrUser){
            SBQQ__Quote__c testQuote = returnTestQuote('Draft');
            quoteId = testQuote.Id;
            SBQQ__QuoteLine__c quoteLine = [select Id, Certificate_of_Destruction__c,Certificate_of_Disposal__c,Profile_Number__c,Landfill_Tickets__c,Special_Disposal_Description__c,Location_Position_Name__c,LocationPositionName__c,Gate_Code__c,Service_End_Time__c, Service_Start_Time__c, Restriction_Details__c, Quote_SLA_Date__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId and SBQQ__RequiredBy__c = null limit 1];
            //system.debug('Quote_SLA_Date__c '+ quoteLine.Quote_SLA_Date__c);
            QuoteProcurementController.updateSpecialHandling(quoteId);
            //SBQQ__Quote__c updatedQuote = [select Id, Special_Handling__c from SBQQ__Quote__c where Id =: quoteId];
            //System.assertEquals(false,updatedQuote.Special_Handling__c);
        }
        
        Test.stopTest();
    }
    /*
     * @MethodName    : updateSpecialHandlingGateCodeTest
     * @description   : Test if updateSpecialHandling method is able to update special handling if gate code available in quote for given quoteId and quoteline
     * @return        : void
     */
    @isTest
    public static void updateSpecialHandlingGateCodeTest(){
        Test.startTest();
        Id quoteId;
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        User adminUsr = [Select Id, FirstName From User Where FirstName =: 'testuser#9999' Limit 1];
        system.runAs(adminUsr){
            SBQQ__Quote__c testQuote = returnTestQuote('Draft');
            quoteId = testQuote.Id;
            SBQQ__QuoteLine__c quoteLine = [select Id, Gate_Code__c, Quote_SLA_Date__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId and SBQQ__RequiredBy__c = null limit 1];
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
            QuoteLineTriggerHelper.extrapickUpRecursion = false;
            SBQQ.TriggerControl.disable();
            quoteLine.Quote_SLA_Date__c = System.today() + 5;
            quoteLine.Gate_Code__c = '123';
            update quoteLine;
            SBQQ.TriggerControl.enable();
            
            //system.debug('Quote_SLA_Date__c '+ quoteLine.Quote_SLA_Date__c);
            
        }
        system.runAs(csrUser){
            
            QuoteProcurementController.updateSpecialHandling(quoteId);
            //SBQQ__Quote__c updatedQuote = [select Id, Special_Handling__c from SBQQ__Quote__c where Id =: quoteId];
            //System.assertEquals(false,updatedQuote.Special_Handling__c);
        }
        
        Test.stopTest();
    }
    /*
     * @MethodName    : updateSpecialHandlingBackDateTest
     * @description   : Test if updateSpecialHandling method is able to update special handling if SLA date is back dated in quote for given quoteId and quoteline
     * @return        : void
     */
    @isTest
    public static void updateSpecialHandlingBackDateTest(){
        Test.startTest();
        Id quoteId;
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        User adminUsr = [Select Id, FirstName From User Where FirstName =: 'testuser#9999' Limit 1];
        system.runAs(adminUsr){
            SBQQ__Quote__c testQuote = returnTestQuote('Draft');
            quoteId = testQuote.Id;
            SBQQ__QuoteLine__c quoteLine = [select Id, Quote_SLA_Date__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId and SBQQ__RequiredBy__c = null limit 1];
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
            QuoteLineTriggerHelper.extrapickUpRecursion = false;
            SBQQ.TriggerControl.disable();
            quoteLine.Quote_SLA_Date__c = System.today() - 1;
            update quoteLine;
            SBQQ.TriggerControl.enable();
            
            //system.debug('Quote_SLA_Date__c '+ quoteLine.Quote_SLA_Date__c);
            
        }
        system.runAs(csrUser){
            
            QuoteProcurementController.updateSpecialHandling(quoteId);
            //SBQQ__Quote__c updatedQuote = [select Id, Special_Handling__c from SBQQ__Quote__c where Id =: quoteId];
            //System.assertEquals(false,updatedQuote.Special_Handling__c);
        }
        
        Test.stopTest();
    }
    /*
     * @MethodName    : getByPassSTPReasonListTest
     * @description   : Test if getByPassSTPReasonList method is able to fetch special handling STP reasons from picklist
     * @return        : void
     */
	@isTest 
    public static void getByPassSTPReasonListTest(){
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        Test.startTest();
         System.runAs(csrUser){
            Map<String,String> stpReasonList = QuoteProcurementController.getByPassSTPReasonList();
            //assert.isNotNull(stpReasonList,'Special Handling STP Reasons list should not be null');
         }
        Test.stopTest();
    }
	/*
     * @MethodName    : saveByPassSTPRequestTest
     * @description   : Test if saveByPassSTPRequest method is able to save special handling fields and quoteOnly in quote
     * @return        : void
     */
	@isTest 
    public static void saveByPassSTPRequestTest(){
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        Test.startTest();
        SBQQ__Quote__c quote = returnTestQuote('Draft');
         System.runAs(csrUser){
            QuoteProcurementController.saveByPassSTPRequest(quote.Id,true, 'Other', 'test', true);
            //SBQQ__Quote__c quoteToVerify = [Select Id, Quote_Only__c from SBQQ__Quote__c where Id =: quote.Id];

         }
        Test.stopTest();
    }
    /*
     * @MethodName    : bypassPriceReviewTest
     * @description   : Test if bypassPriceReview method is able to save byPass Review Flag on MAS Setup Detail screen
     * @return        : void
     */
    @isTest 
    public static void bypassPriceReviewTest(){
        User adminUsr = [Select Id, FirstName From User Where FirstName =: 'testuser#9999' Limit 1];
        Test.startTest();
        System.runAs(adminUsr){
            Account locationAccount = [Select Id, Name from Account where Name = 'TestLocationAccountTest' limit 1];
             SBQQ__Quote__c testQuote = returnTestQuote('Draft');
            Id quoteId = testQuote.Id;
            SBQQ__QuoteLine__c quoteLine = [select Id, MASLibrary__c, sCode__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId and SBQQ__RequiredBy__c = null limit 1];
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            RecurrsiveTriggerHandler.isSkipValidateQLCostPrice =true;
            QuoteLineTriggerHelper.extrapickUpRecursion = false;
            SBQQ.TriggerControl.disable();
            //Adding Availablity 
                AAV_Asset_Availability__c aavObj = new AAV_Asset_Availability__c();
                aavObj.AAV_Location__c = locationAccount.Id;
                aavObj.AAV_APIRequestOutput__c = AAV_API_REQUEST_OUTPUT;
                aavObj.AAV_Quote_Line__c = quoteLine.Id;

                insert aavObj;
                quoteLine.sCode__c = 'FRCH';
            update quoteLine;
            SBQQ.TriggerControl.enable();
            QuoteProcurementController.bypassPriceReview(quoteLine.Id,quoteLine.MASLibrary__c);
            
            //System.assertEquals(quoteToVerify.Quote_Only__c,true);
         }
        Test.stopTest();
    }   
    
    /*
     * End of STP related methods
     */
	
	/*
     * @MethodName    : getMultiVendorDetailTest
     * @description   : Test get the Multi-Vendor Pricing response and get Multi-Vendor Switch.
     * @return        : void
     */
    @isTest 
    public static void getMultiVendorDetailTest(){
        User csrUser = [SELECT Id FROM User WHERE Profile.Name = :CUSTOMER_SERVICE AND IsActive = true  LIMIT 1];
        Test.startTest();
        SBQQ__Quote__c testQuote = [Select Id,SBQQ__Account__c,SBQQ__StartDate__c From SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' ORDER BY CreatedDate DESC limit 1];
         System.runAs(csrUser){
            QuoteProcurementController.getMultivendorPricingRecord(testQuote.Id);
            QuoteProcurementController.getAMMultiVendorSwitch();
         }
        Test.stopTest();
    }
}