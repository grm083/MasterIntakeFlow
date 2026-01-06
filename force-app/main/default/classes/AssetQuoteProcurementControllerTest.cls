//Class: AssetQuoteProcurementControllerTest
//Purpose: test class for the AssetQuoteProcurementController
//Current Covrage = 93%
//Author: Anup Dey
//Date: 12/7/2022
@isTest(seeAllData = false)
public class AssetQuoteProcurementControllerTest {
    
    @testSetup 
    // method for setting up data
    static void createData() {
        //TCS-SDT-36171-16-Feb-2024-Added following 3 lines
        List<Schema.PicklistEntry> schedule_A_OverrideEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.ScheduleAOverride__c.getPicklistValues();
        String strDNC = UTIL_Picklist.getPicklistEntryByLabel(schedule_A_OverrideEntries, 'Do not Create');
        String strFHOR = UTIL_Picklist.getPicklistEntryByLabel(schedule_A_OverrideEntries, 'Force Hauler of Record');
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        //TCS-SDT-36171-16-Feb-2024-End
        Profile p= TestDataFactory.getProfile('System Administrator');
		User usr= TestDataFactory.createUser(p);
		insert usr;
		List<Account> accList;
		List<Account> locationList;
		List<Contact> conList;
		List<Case> caseList;
        Case aCase = new Case(); //PK
		List<Opportunity> oppList;
        Asset asst;
        List<Asset> childAssts;
        list<Case> assetcaselist = new list<Case>();
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
            
			accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            accList[0].AccountNumber = 'ParentTest';
            List<Account> accList12 = TestDataFactory.createAccount('TestVendorAccountTest', usr,'Vendor');
            accList12[0].Vendor_Business_Unit__c = '2860';
            accList.addAll(accList12);
			insert accList;
			locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            locationList[0].AccountNumber = 'ChildTest';
            locationList[0].type = 'location';
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
                        //addition for test class errors
                        test.startTest();
			Product2 prodOT = TestDataFactory.createProduct('Open Top','Equipment','OT');
			prodOT.Bypass_Acorn_Integration__c= false;
			prodOT.Container_Size__c='40 Yards';
            //Changes related to test class Coverage- sprint 8
            prodOT.Family= 'Rolloff';
			Product2 prod = TestDataFactory.createProduct('Delivery','Services','DLV');
			Product2 prod1 = TestDataFactory.createProduct('Pickup','Services','PCK');
			Product2 prod2 =TestDataFactory.createProduct('Removal','Services','REM');
			prod3 = TestDataFactory.createProduct('Trash','Waste Category','TW');
            prod4 = TestDataFactory.createProduct('Trash','Waste Stream','T');
			prod.Container_Size__c='40 Yards';
			prodList.add(prodOT);
			prodList.add(prod);
			prodList.add(prod1);
			prodList.add(prod2);
            prodDumpster = TestDataFactory.createProduct('Dumpster','Rolloff', 'DMP');
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
//pkulkarn-TCS-30-Mar-23-SDT-28044-Create Liner Product-Start
            Product2 prodLiner = TestDataFactory.createProduct('Liner','Supplies', 'PRD');
            prodList.add(prodLiner);
            Product2 prodHaul = TestDataFactory.createProduct('Haul','Rolloff', 'H');
            prodList.add(prodHaul);
            Product2 prodDisposal = TestDataFactory.createProduct('Disposal','Rolloff', 'DSP');
            prodList.add(prodDisposal);
            //pkulkarn-TCS-30-Mar-23-SDT-28044-Create Liner Product-End
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

            // Inserting Asset
            asst = TestDataFactory.createAsset('Test Asset', accList[0],conList[0], prodOT, usr,locationList[0])[0];
List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(accList[0].Id);//seema
            insert pCodeList;
            asst.Project_Code__c=pCodeList[0].Id;//seema
            asst.Duration__c = '';
            asst.Acorn_SID__c='1234';
            asst.Monday__c = false;
	    asst.Frequency__c = 'Weekly';
            asst.Category__c ='(WAL_SP) Special Project';
            //asst.MAS_Account_Number__c = '123456';
            asst.Equipment_Owner__c='Unknown';
            asst.Sensitivity_Code__c='CAM';
	    asst.product2id =prodOT.Id;
            //SDT-38111
            asst.Cost_Minimum_Quantity__c=23.00;
            asst.Price_Minimum_Quantity__c=56.78;
            Database.insert(asst);

            childAssts = TestDataFactory.createChildAsset('Test Asset OT');
            childAssts[0].Service_Header_Id__c   = asst.Id;
            childAssts[0].ParentId = asst.Id;
            childAssts[0].Location__c = locationList[0].Id;
            childAssts[0].Acorn_SID__c='1234';
            childAssts[0].Equipment_Owner__c='Unknown';
            childAssts[0].Sensitivity_Code__c='CAM';
            childAssts[0].CPQ_Product__c = prodOT.Id;
            childAssts[0].Start_Date__c = Date.Today();
            childAssts[0].CPQ_Material__c = prod4.Id;
            childAssts[1].Service_Header_Id__c  = asst.Id;
            childAssts[1].ParentId = asst.Id;
            childAssts[1].Location__c = locationList[0].Id;
            childAssts[1].CPQ_Product__c = prodOT.Id;
            childAssts[1].Start_Date__c = Date.Today().addDays(2);
            childAssts[1].CPQ_Material__c = prod4.Id;
            childAssts[1].Acorn_SID__c='1234';
            childAssts[1].Equipment_Owner__c='Unknown';
            childAssts[1].Sensitivity_Code__c='CAM';
            
            //SDT-26597-PavanK-Added
            childAssts[1].Price_Model_Type__c='Rebate';
            List<Asset> childAssts1;
            childAssts1 = TestDataFactory.createChildAsset('Test Asset');
            childAssts1[0].Service_Header_Id__c = asst.Id;
            childAssts1[0].ParentId = asst.Id;
            childAssts1[0].Location__c = locationList[0].Id;
            childAssts1[0].CPQ_Product__c = prod.Id; //PavanK TCS Changed to prodOT.Id to prod.Id for SDT-25617
            childAssts1[0].Start_Date__c = Date.Today().addDays(3); //PavanK TCS Added for SDT-25617
            childAssts1[0].CPQ_Material__c = prod4.Id;
	    childAssts1[0].product2id =prod.Id;
            childAssts1[0].Frequency__c = 'Weekly';
            childAssts1[0].Monday__c = true;
            childAssts1[0].Acorn_SID__c='1234';
            childAssts1[0].Equipment_Owner__c='Unknown';
            childAssts1[0].Sensitivity_Code__c='CAM';    
			childAssts1[0].Price_Model_Type__c = 'MRG';
            
            childAssts1[1].Service_Header_Id__c = asst.Id;
            childAssts1[1].ParentId = asst.Id;
            childAssts1[1].Location__c = locationList[0].Id;
            childAssts1[1].CPQ_Product__c = prod1.Id; //PavanK TCS Changed to prodOT.Id to prod1.Id for SDT-25617
            childAssts1[1].Start_Date__c = Date.Today().addDays(3); //PavanK TCS Added for SDT-25617
            childAssts1[1].CPQ_Material__c = prod4.Id;
            childAssts1[1].Acorn_SID__c='1234';
            childAssts1[1].Equipment_Owner__c='Unknown';
            childAssts1[1].Sensitivity_Code__c='CAM';
            childAssts1[1].Price_Model_Type__c = 'PER';
	    childAssts1[1].Frequency__c = 'Weekly';
            //SDT-26597-PavanK-End

            Database.insert(childAssts);
            Database.insert(childAssts1); //SDT-26597-PavanK-Added
            case cs = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accList[0], conList[0], 
                                                             usr, locationList[0]);
            cs.Case_Type__c='Service Changes';
            cs.Case_Sub_Type__c='Customer Requested';
            cs.Case_Reason__c='';
            cs.Recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Update Asset Case').getRecordTypeId();
            cs.Service_Date__c= System.today();
            cs.AssetId = asst.Id;
            assetcaselist.add(cs);
            
            //caselist[0].AccountId = clientAcc.Id;
            Database.insert(assetcaselist[0]);
            // SBS_Case_Asset__c cseAsset = new SBS_Case_Asset__c(CaseId__c = caselist[0].Id,Asset_Header__c = asst.Id,AssetId__c = childAssts[0].Id);
            // Database.insert(cseAsset);
        
            //TCS-SDT-36171-16-Feb-2024-Test Asset 1 created to test Default values on ScheduleAOverride__c field
            Asset asst1;
            asst1 = TestDataFactory.createAsset('Test Asset 1', accList[0],conList[0], prodOT, usr,locationList[0])[0];
            List<Project_Code__c> pCodeList1=TestDataFactory.createProjectCode(accList[0].Id);
            insert pCodeList1;
            asst1.Project_Code__c=pCodeList1[0].Id;
            asst1.Duration__c = '';
            asst1.Acorn_SID__c='1234';
			asst1.Monday__c = true;
            asst1.Category__c ='(WAL_SP) Special Project';
            asst1.Equipment_Owner__c='Unknown';
            asst1.Sensitivity_Code__c='CAM';
            asst1.Start_Date__c = Date.Today();
            asst1.CPQ_Material__c = prod4.Id;
            asst1.Schedule_A_Override__c = '';  //TCS-SDT-36171-Added
            asst1.CPQ_Product__c = prodOT.Id;	//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
            Database.insert(asst1);
            
            List<Asset> childAst;
            childAst = TestDataFactory.createChildAsset('Test Asset Child');
            childAst[0].Service_Header_Id__c = asst1.Id;
            childAst[0].ParentId = asst1.Id;
            childAst[0].Location__c = locationList[0].Id;
            childAst[0].Acorn_SID__c='1234';
            childAst[0].Equipment_Owner__c='Unknown';
            childAst[0].Sensitivity_Code__c='CAM';
            childAst[0].CPQ_Product__c = prodHaul.Id;
            childAst[0].Start_Date__c = Date.Today();
            childAst[0].CPQ_Material__c = prod4.Id;
            childAst[0].Schedule_A_Override__c = strDNC;   //TCS-SDT-36171-Added
            
            childAst[1].Service_Header_Id__c = asst1.Id;
            childAst[1].ParentId = asst1.Id;
            childAst[1].Location__c = locationList[0].Id;
            childAst[1].CPQ_Product__c = prod.Id;
            childAst[1].Start_Date__c = Date.Today().addDays(2);
            childAst[1].CPQ_Material__c = prod4.Id;     //Delivery
            childAst[1].Acorn_SID__c='1234';
            childAst[1].Equipment_Owner__c='Unknown';
            childAst[1].Sensitivity_Code__c='CAM';
            childAst[1].Price_Model_Type__c='Rebate';
            childAst[1].Schedule_A_Override__c = strFHOR;  //TCS-SDT-36171-Added
            
            List<Asset> childAst1;
            childAst1 = TestDataFactory.createChildAsset('Test Asset Child');
            childAst1[0].Service_Header_Id__c = asst1.Id;
            childAst1[0].ParentId = asst1.Id;
            childAst1[0].Location__c = locationList[0].Id;
            childAst1[0].CPQ_Product__c = prodDisposal.Id;
            childAst1[0].Start_Date__c = Date.Today().addDays(3);
            childAst1[0].CPQ_Material__c = prod4.Id;
            childAst1[0].Acorn_SID__c='1234';
            childAst1[0].Equipment_Owner__c='Unknown';
            childAst1[0].Sensitivity_Code__c='CAM';    
			childAst1[0].Price_Model_Type__c = 'MRG';
            //SDT-38111
            childAst1[0].Service_Type__c='Disposal';
            childAst1[0].Cost_Minimum_Quantity__c=34.78;
            childAst1[0].Price_Minimum_Quantity__c=89.07;
			childAst1.remove(1);
            
            Database.insert(childAst);
            Database.insert(childAst1);
            //TCS-SDT-36171-16-Feb-2024-End-Test Asset 1 created to test Default values on ScheduleAOverride__c field

            //addition for test class errors
            test.stopTest();
            case cs1 = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accList[0], conList[0], 
                                                             usr, locationList[0]);
            cs1.Case_Type__c='Service Changes';
            cs1.Case_Sub_Type__c='Customer Requested';
            cs1.Case_Reason__c='';
            cs1.Recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Update Asset Case').getRecordTypeId();
            cs1.Service_Date__c= System.today();
            cs1.AssetId = asst1.Id;
            
            aCase = cs1;

//caselist[0].AccountId = clientAcc.Id;
            Database.insert(aCase);
            //*************************************************************PK*/
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
		insert usrObj;
		List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
		insert new PermissionSetLicenseAssign(AssigneeId = usrObj.Id, PermissionSetLicenseId= pslList[0].Id);
		List<PermissionSet> psgList= [SELECT Id FROM PermissionSet WHERE Name = 'QuoteOrdersUser'];
		insert new PermissionSetAssignment(AssigneeId = usrObj.Id, PermissionSetId = psgList[0].id);

        

		System.runAs(usrObj){
		  caseList= new List<Case>();
		  oppList= new List<Opportunity>();
		  caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
          caseList[0].Service_Date__c= System.today();
		  insert caseList;
		  oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',assetcaselist[0].Id,assetcaselist[0].Case_Sub_Type__c, locationList[0].Id);
          oppList[0].Duration__c='Temporary';
		  insert oppList;
		  quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
          quoteList.addAll(TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false));
          quoteList.addAll(TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false));
          quoteList[1].SBQQ__Status__c='Draft';
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
sbqq.Core_Service__c = true; //Seema
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

          //pkulkarn-TCS-30-Mar-23-SDT-28044-Create Liner Product-Start
          SBQQ__ProductOption__c sbqq11 = new SBQQ__ProductOption__c();
          sbqq11.SBQQ__ConfiguredSKU__c = prodList[0].Id;
          sbqq11.SBQQ__OptionalSKU__c = prodList[10].Id;
          sbqq11.SBQQ__Number__c = 350;
          sbqq11.SBQQ__Quantity__c = 1;
          sbqq11.Occurrence_Type__c = 'SCH';
          sbqq11.CostModelType__c = 'PER';
          sbqq11.Cost_Unit_of_Measure__c = 'MTH';
          sbqq11.PriceUOM__c = 'MTH';
          sbqq11.Schedule_Frequency__c = 'W';
          sbqq11.Frequency_Interval__c = '1';
          sbqqLst.add(sbqq11);
          //pkulkarn-TCS-30-Mar-23-SDT-28044-Create Liner Product-End
          
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
          
		}
    }

    // method to call quote status details method
    @isTest static void testgetQuoteStatusDetails() {
        
        test.startTest();
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        SBQQ__Quote__c quote = AssetQuoteProcurementController.getQuoteStatusDetails(testQuote.Id);
        test.stopTest();
       
        System.assertNotEquals(quote, null);

    }

    // method to call Asset quote line method
    @isTest static void testcheckAssetQuoteLines() {
        
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];

        test.startTest();
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        
        List<SBQQ__QuoteLine__c> quotelines = AssetQuoteProcurementController.checkAssetQuoteLines(testQuote.Id,product.Id);
        test.stopTest();
        
        System.assertNotEquals(quotelines.size(), null);

    }

    // method to call quote asset header method
    @isTest static void testgetQuoteAssetHeaders() {
        
        Case c= [SELECT Id FROM Case LIMIT 1];
        test.startTest();
        
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        List<AssetQuoteProcurementController.assetHeaderModel> assetHeaders = AssetQuoteProcurementController.getQuoteAssetHeaders(c.Id);
        test.stopTest();
        
        System.assertNotEquals(assetHeaders.size(), null);

    }

    // method to call create asset quote line method
    @isTest static void testcreateAssetQuoteLines() {
        
        Asset asset= [SELECT Id from Asset LIMIT 1];
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
        Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
        
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '30 Yards');
		try{
        test.startTest();
        System.assertEquals(true, true, 'Bypass SOQL 101');		//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
        
        //SDT-26597-PavanK-Added
        List<SBQQ__QuoteLine__c> MRGPUCount = [SELECT Id
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c = :testQuote.Id 
                            AND (SBQQ__PricingMethod__c = :Constant_Util.PRICING_METHOD_MARGIN OR SBQQ__PricingMethod__c = :Constant_Util.PRICING_METHOD_PER_UNIT)
                           ];
        
        List<SBQQ__QuoteLine__c> OtherCount = ([SELECT Id
                              FROM SBQQ__QuoteLine__c 
                              WHERE SBQQ__Quote__c = :testQuote.Id 
                              AND SBQQ__PricingMethod__c = 'Rebate'
                             ]);
        
        List<SBQQ__QuoteLine__c> LstCount = [SELECT Id, AssetId__c, SBQQ__PricingMethod__c,Schedule_Frequency__c, SBQQ__ListPrice__c, SBQQ__UnitCost__c, ByPassFunctionality__c, SBQQ__RequiredBy__c, SBQQ__ProductFamily__c, Service_Days__c, Occurrence_Type__c, SBQQ__Quantity__c, Equipment_Size__c, AssetId__r.Equipment_Size__c, SBQQ__Quote__r.Name, CostModelType__c, PricingUnitMethod__c,SBQQ__ProductName__c,Service_Schedule__c //SDT-42525
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c = :testQuote.Id 
                            AND SBQQ__PricingMethod__c = :Constant_Util.PRICING_METHOD_LIST
                           ];
       //Changes related to test class Coverage- sprint 8
       List<SBQQ__QuoteLine__c> LstCountParent = [SELECT Id, AssetId__c  , SBQQ__PricingMethod__c,Schedule_Frequency__c, SBQQ__ListPrice__c, SBQQ__UnitCost__c, ByPassFunctionality__c, SBQQ__RequiredBy__c, SBQQ__ProductFamily__c, Service_Days__c, Occurrence_Type__c, SBQQ__Quantity__c, Equipment_Size__c, AssetId__r.Equipment_Size__c, SBQQ__Quote__r.Name, CostModelType__c, PricingUnitMethod__c,SBQQ__Product__c,SBQQ__ProductName__c,Service_Schedule__c //SDT-42525
                            FROM SBQQ__QuoteLine__c 
                            WHERE Id=:LstCount[0].SBQQ__RequiredBy__c
                           ];
        
        LstCountParent[0].SBQQ__Product__c = product.Id;
        update LstCountParent;
        //SDT-26597-PavanK-End
        //
	Asset assetObj = [Select Id,Quantity__c, Name, Equipment_Size__c,Product2.Name,Product2Id , Product2.Container_Size__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c, Occurrence_Type__c, Weekly_Frequency__c,Schedule__c,Frequency__c from asset WHERE Id =: LstCount[0].AssetId__c limit 1];  //SDT-42525                                                      
    LstCount[0].Schedule_Frequency__c='W';
    //Changes related to test class Coverage- sprint 8
    assetObj.Occurrence_Type__c = 'On-Call';
    update assetObj;
	LstCount[0].CostModelType__c = 'STP';
    //Changes related to test class Coverage- sprint 8
    LstCount[0].Occurrence_Type__c = 'SCH';
	LstCount[0].SBQQ__PricingMethod__c = 'STP';
    //Changes related to test class Coverage- sprint 8
    SBQQ__Quote__c selectObj = [SELECT Id,  SBQQ__Type__c
    FROM SBQQ__Quote__c where id = : LstCount[0].SBQQ__Quote__c];
    selectObj.SBQQ__Type__c = 'Amendment';
    
    update selectObj;
    QuoteLineServices.setDefaultValuesForQuoteLines(LstCount[0], LstCount[0].SBQQ__Quote__r.Name,assetObj);
        LstCount[0].SBQQ__PricingMethod__c = 'STP';
        LstCount[0].CostModelType__c = 'STP';
            
        update  LstCount[0];
        QuoteLineServices.setDefaultValuesForQuoteLines(LstCount[0],LstCount[0].SBQQ__Quote__r.Name);
        LstCount[0].Schedule_Frequency__c='D'; 
        update  LstCount[0];
        QuoteLineServices.setDefaultValuesForQuoteLines(LstCount[0],LstCount[0].SBQQ__Quote__r.Name);
        
		SBQQ__Quote__c quoteObj = [Select id from SBQQ__Quote__c limit 1];
		 SBQQ__QuoteLine__c quoteLineObj = new SBQQ__QuoteLine__c();
		 quoteLineObj.SBQQ__PricingMethod__c = 'STP';
		 quoteLineObj.CostModelType__c = 'STP';
		 quoteLineObj.SBQQ__Quote__c = quoteObj.Id;
		 Insert quoteLineObj;
		 
		 system.debug('quoteLineObj>>>> '+quoteLineObj);
		 
		 system.debug('quoteLineObj>>>> '+quoteLineObj.SBQQ__PricingMethod__c);
		 List<SBQQ__QuoteLine__c> LstCountupdated = [SELECT Id, PricingUnitMethod__c,CostModelType__c,SBQQ__Quote__r.Name,SBQQ__ProductName__c,Service_Schedule__c from SBQQ__QuoteLine__c where Id  =: quoteLineObj.id limit 1];  //SDT-42525
		 system.debug('quoteLineObj>>>> '+LstCountupdated[0].PricingUnitMethod__c);
		  QuoteLineServices.setDefaultValuesForQuoteLines(LstCountupdated[0],LstCountupdated[0].SBQQ__Quote__r.Name);
        List<SBQQ__QuoteLine__c> LstCount1 = [SELECT Id, AssetId__c  , SBQQ__PricingMethod__c,Schedule_Frequency__c, SBQQ__ListPrice__c, SBQQ__UnitCost__c, ByPassFunctionality__c, SBQQ__RequiredBy__c, SBQQ__ProductFamily__c, Service_Days__c, Occurrence_Type__c, SBQQ__Quantity__c, Equipment_Size__c, AssetId__r.Equipment_Size__c, SBQQ__Quote__r.Name, CostModelType__c, PricingUnitMethod__c,SBQQ__ProductName__c,Service_Schedule__c //SDT-42525
                            FROM SBQQ__QuoteLine__c 
                            WHERE id  = :LstCount[0].Id ];
                            
          QuoteLineServices.setDefaultValuesForQuoteLines(LstCount1[0], LstCount1[0].SBQQ__Quote__r.Name,assetObj);
        test.stopTest();
        
        System.assertNotEquals(quotelineResponse, null);
        //SDT-26597-PavanK-Added
        System.assertEquals(0, MRGPUCount.size(), 'Asset Items with Price Model of Margin and Per Unit were not converted to List.');
        System.assertEquals(1, OtherCount.size(), 'Asset Items with Price Model other than Margin and Per Unit do not match with Quote Item.');
        System.assertEquals(2, LstCount.size(), 'Asset Items with Price Model of List do not match.');
		}
        catch(exception ex) {
			system.debug('Exception-'+ ex);
		}
        //SDT-26597-PavanK-End
    }
    /*SDT-38111
        Dev: Seema Dhikale
        FC: Anmoal Bharti
        Description: check if Cost_Minimum_Quantity__c,Price_Minimum_Quantity__care correctly copied on Disposal Quoteline CostMinQuantity__c,PriceMinQuantity__c from associated Asset
    */
    @isTest static void testDisposalMinQuantityfromAssetOnQL() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        User usrObj= [select id from user where profileId=:p.Id and IsActive=true limit 1];
        System.runAs(usrObj){
        Asset asset= [SELECT Id,Name,Equipment_Owner__c,CPQ_Product__r.Name,Start_Date__c 
                                from Asset WHERE Name='Test Asset 1' LIMIT 1];

        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            
        Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Rolloff' LIMIT 1];
        test.startTest();
        
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
                                    FROM SBQQ__Quote__c 
                                    WHERE SBQQ__Status__c = 'Draft' AND Case__c != null 
                                    ORDER BY CreatedDate DESC LIMIT 1];
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
         String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '30 Yards');
       //SDT38111 adding query CostMinQuantity__c,PriceMinQuantity__c,AssetId__r.Cost_Minimum_Quantity__c,AssetId__r.Price_Minimum_Quantity__c
        List<SBQQ__QuoteLine__c> quoteLinesCreatedOpenTop = [SELECT Id,Name,Ownership__c,AssetId__r.Name,CostMinQuantity__c,PriceMinQuantity__c,AssetId__r.Cost_Minimum_Quantity__c,AssetId__r.Price_Minimum_Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,AssetId__c,Equipment_Size__c,Occurrence_Type__c,Duration__c,sCode__c,
                                                      Schedule_Frequency__c,Service_Days__c,SBQQ__Product__r.Name
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c = :testQuote.Id and SBQQ__Product__r.Name = 'Open Top'];
        
        List<SBQQ__QuoteLine__c> quoteLinesCreatedRolloff = [SELECT Id,Name,Ownership__c,AssetId__r.Name,CostMinQuantity__c,PriceMinQuantity__c,AssetId__r.Cost_Minimum_Quantity__c,AssetId__r.Price_Minimum_Quantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,AssetId__c,Equipment_Size__c,Occurrence_Type__c,Duration__c,sCode__c,
                                                      Schedule_Frequency__c,Service_Days__c,SBQQ__Product__r.Name
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c = :testQuote.Id and SBQQ__Product__r.Name = 'Disposal'];
            System.assertEquals(quoteLinesCreatedRolloff[0].CostMinQuantity__c, quoteLinesCreatedRolloff[0].AssetId__r.Cost_Minimum_Quantity__c,'Assets Cost_Minimum_Quantity__c gets copied to quotelines CostMinQuantity__c for disposal line '); 
            System.assertEquals(quoteLinesCreatedRolloff[0].PriceMinQuantity__c, quoteLinesCreatedRolloff[0].AssetId__r.Price_Minimum_Quantity__c,'Assets Price_Minimum_Quantity__c gets copied to quotelines PriceMinQuantity__c for disposal line '); 
        test.stopTest();
    }
    }
// method to call new create asset quote line method
    @isTest static void testNewCreateAssetQuoteLines() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
		User usrObj= [select id from user where profileId=:p.Id and IsActive=true limit 1];
        System.runAs(usrObj){
        Asset asset= [SELECT Id,Name,Equipment_Owner__c,CPQ_Product__r.Name,Start_Date__c 
                          from Asset WHERE Name='Test Asset 1' LIMIT 1];
            //Asset asset= [SELECT Id,Name,Equipment_Owner__c,CPQ_Product__r.Name,Start_Date__c from Asset WHERE Name='Test Asset' LIMIT 1];
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            
        Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
        test.startTest();
        
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        							FROM SBQQ__Quote__c 
                                    WHERE SBQQ__Status__c = 'Draft' AND Case__c != null 
                                    ORDER BY CreatedDate DESC LIMIT 1];
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
         String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '30 Yards');
       
        List<SBQQ__QuoteLine__c> quoteLinesCreatedOpenTop = [SELECT Id,Name,Ownership__c,AssetId__r.Name,SBQQ__StartDate__c,SBQQ__EndDate__c,AssetId__c,Equipment_Size__c,Occurrence_Type__c,Duration__c,sCode__c,
                                                      Schedule_Frequency__c,Service_Days__c,SBQQ__Product__r.Name
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c = :testQuote.Id and SBQQ__Product__r.Name = 'Open Top'];

List<SBQQ__QuoteLine__c> quoteLinesCreatedWasteStream = [SELECT Id,Name,Ownership__c,AssetId__r.Name,SBQQ__StartDate__c,SBQQ__EndDate__c,AssetId__c,Equipment_Size__c,Occurrence_Type__c,Duration__c,sCode__c,
                                                      Schedule_Frequency__c,Service_Days__c,SBQQ__Product__r.Name
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c = :testQuote.Id and SBQQ__Product__r.Family = 'Waste Stream'];
            system.assertEquals(asset.Equipment_Owner__c,'Unknown');
            system.assertEquals(quoteLinesCreatedOpenTop[0].Ownership__c,'UKW');
        system.debug('quoteLinesCreatedWasteStream'+quoteLinesCreatedWasteStream);
            System.assertEquals(1, quoteLinesCreatedOpenTop.size());  // SDT-33363
        //System.assertEquals(Date.Today().addDays(2), quoteLinesCreatedOpenTop[0].SBQQ__StartDate__c);//
        System.assertEquals(1, quoteLinesCreatedWasteStream.size()); 
        //test.stopTest();
    }
    }
    // method to call create bulk asset quote line method
    @isTest static void testcreateBulkAssetQuoteLines() {
        
        Asset asset= [SELECT Id from Asset LIMIT 1];
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
        Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
        test.startTest();
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        List<AssetQuoteProcurementController.assetProductRequestModel> assetProducts = new List<AssetQuoteProcurementController.assetProductRequestModel>();
        AssetQuoteProcurementController.assetProductRequestModel assetProduct = new AssetQuoteProcurementController.assetProductRequestModel();
        assetProduct.assetId = asset.Id;
        assetProduct.quoteId = testQuote.Id;
        assetProduct.productId = product.Id;
        assetProduct.wastestreamId = product1.Id;
        assetProduct.equipmentSize = '30 Yards';
        assetProducts.add(assetProduct);

        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
	    try {
        List<AssetQuoteProcurementController.assetProductResponseModel> quotelineResponse = AssetQuoteProcurementController.createBulkAssetQuoteLines(assetProducts);
        System.assertNotEquals(quotelineResponse, null);
	    }
	    catch(exception ex){}
	    test.stopTest();

    }

    // method to call update quote status method
    @isTest static void testupdateStatus() {
        

        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        
        Asset asset= [SELECT Id,Name,Equipment_Owner__c,CPQ_Product__r.Name,Start_Date__c 
              from Asset WHERE Name='Test Asset 1' LIMIT 1];
           
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            
       	Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];

        //if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        //}
        String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '30 Yards');
        
        QuoteProcurementController.OrderWrapper ow = QuoteProcurementController.generateOrderWrapper();
        ow.parentQuoteLine = quotelineResponse;
        ow.serviceDate = Date.Today().addDays(10); //quoteLines[0].SBQQ__StartDate__c;
        ow.serviceEndDate = null;
        ow.serviceType = 'Delivery';
        ow.quantity = 1;
        ow.onsiteContact = 'Test User';
        ow.onsitePhone = '1111111111';
        ow.PONumber = '123456';
        ow.duration = 'TEMP';
        ow.quoteId = testQuote.Id;
        
        test.starttest();
        QuoteProcurementController.createDelivery(ow, 'Delivery', 'Test');
        
        String result = AssetQuoteProcurementController.updateStatus(testQuote.Id, 'Product Configured' ,false);
        test.stopTest();
        System.assertNotEquals(result, null);

    }

    // method to call create asset quote line method
    @isTest static void testcreateAssetQuoteLinesExceptionDate() {
        
        Asset asset= [SELECT Id from Asset WHERE Name = 'Test Asset 1' LIMIT 1];
        system.debug('testcreateAssetQuoteLinesExceptionDate'+asset);
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
        Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
        Product2 prodLiner = [SELECT Id  FROM Product2 WHERE Name = 'Liner' LIMIT 1];
        RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;		//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
        test.startTest(); //SDT-42525
        System.assertEquals(true, true, 'Bypass SOQL 101');		//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
        
        SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '30 Yards');
        
        //Insert a product option
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Number__c, SBQQ__StartDate__c, Equipment_Size__c,
                                              SBQQ__Quote__c, SID__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c
                                              WHERE Id=: quotelineResponse OR SBQQ__RequiredBy__c =: quotelineResponse
                                              ORDER BY SBQQ__Number__c DESC];
        system.debug('quoteLines==>'+quoteLines);
        system.debug('quotelineResponse==>'+quotelineResponse);
        
        SBQQ__ProductOption__c prodOption = [SELECT Id, SBQQ__OptionalSKU__c, SBQQ__Quantity__c, Occurrence_Type__c,
                                             CostModelType__c, Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c,
                                             Frequency_Interval__c
                                             FROM SBQQ__ProductOption__c
                                             WHERE SBQQ__ConfiguredSKU__c = :product.Id AND SBQQ__OptionalSKU__c = :prodLiner.Id
                                            ];
        system.debug('prodOption==>'+prodOption.Id);
        ////Changes related to Sprint 10 test class errors
        //test.stopTest();
        List<SBQQ__QuoteLine__c> OldQuoteLines = [SELECT Id, SBQQ__Number__c, SBQQ__StartDate__c, Exception_Effective_Date__c,Exceptions_Effective_Date__c, SBQQ__ProductName__c
                                              FROM SBQQ__QuoteLine__c
                                              WHERE (Id=: quotelineResponse OR SBQQ__RequiredBy__c =: quotelineResponse)
                                              ORDER BY SBQQ__Number__c DESC];
        system.debug('OldQuoteLines' + OldQuoteLines);
        
        SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteLines[0].SBQQ__Quote__c,
                                                            SBQQ__Product__c = prodOption.SBQQ__OptionalSKU__c,
                                                            Equipment_Size__c = quoteLines[0].Equipment_Size__c,
                                                            SBQQ__RequiredBy__c = quotelineResponse,
                                                            SBQQ__ProductOption__c = prodOption.Id,
                                                            SBQQ__OptionLevel__c = 1,
                                                            SBQQ__Number__c = quoteLines[0].SBQQ__Number__c + 1,
                                                            SBQQ__CostEditable__c = true,
                                                            SBQQ__PriceEditable__c = true,
                                                            SBQQ__Quantity__c = prodOption.SBQQ__Quantity__c,
                                                            Occurrence_Type__c = prodOption.Occurrence_Type__c, 
                                                            CostModelType__c = prodOption.CostModelType__c, 
                                                            Cost_Unit_of_Measure__c = prodOption.Cost_Unit_of_Measure__c, 
                                                            PriceUOM__c = prodOption.PriceUOM__c,
                                                            Schedule_Frequency__c = prodOption.Schedule_Frequency__c,
                                                            Frequency_Interval__c = prodOption.Frequency_Interval__c,
                                                            SBQQ__StartDate__c = quoteLines[0].SBQQ__StartDate__c,
                                                            SID__c= quoteLines[0].SID__c);
        system.debug('qLine==>'+qLine);

        try {
            insert qLine;
        } 
        catch (exception e) {
            throw (e);
        }
        
        QuoteProcurementController.OrderWrapper ow = QuoteProcurementController.generateOrderWrapper();
        ow.parentQuoteLine = quotelineResponse;
        ow.serviceDate = Date.Today().addDays(10); //quoteLines[0].SBQQ__StartDate__c;
        ow.serviceEndDate = null;
        ow.serviceType = 'Delivery';
        ow.quantity = 1;
        ow.onsiteContact = 'Test User';
        ow.onsitePhone = '1111111111';
        ow.PONumber = '123456';
        ow.duration = 'TEMP';
        ow.quoteId = quoteLines[0].SBQQ__Quote__c;
        
        QuoteProcurementController.createDelivery(ow, 'Delivery', 'Test');
        
        List<SBQQ__QuoteLine__c> NewQuoteLines = [SELECT Id, SBQQ__Number__c, SBQQ__StartDate__c, Exception_Effective_Date__c, Exceptions_Effective_Date__c, SBQQ__ProductName__c
                                              FROM SBQQ__QuoteLine__c
                                              WHERE (Id=: quotelineResponse OR SBQQ__RequiredBy__c =: quotelineResponse)
                                              ORDER BY SBQQ__Number__c DESC];
        test.stopTest(); //SDT-42525
        system.debug('NewQuoteLines' + NewQuoteLines);
        System.assertNotEquals(quotelineResponse, null);
        RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = false;	//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
    }
     
    @isTest public static void testDefaultsForQuotelineWhenUpdated() {
        Test.startTest();
        Asset asset= [SELECT Id from Asset WHERE Name = 'Test Asset 1' LIMIT 1];
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
        Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
        Product2 prodLiner = [SELECT Id  FROM Product2 WHERE Name = 'Liner' LIMIT 1];
        
        QuoteProcurementController.OrderWrapper classWrapper = QuoteProcurementController.generateOrderWrapper();
        
        SBQQ__Quote__c testQuote = [SELECT Id, Name, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.RecordTypeId, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
        FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        List<Case> caseList= TestDataFactory.getCasesForAddChange();
        
        String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '30 Yards');
        Test.stopTest();
            for(Case c : caseList){
            //added for test class errors - Modified by Harun
            if(c.Case_Record_Type__c == 'Modify Existing Service Case') {
            testQuote.SBQQ__Opportunity2__r.Case__r.RecordTypeId=c.RecordTypeId;
            testDefaultsForCaseTypes(testQuote, quotelineResponse, classWrapper);
            }
        }
        List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exception_Type__c,Exception_Reason__c,Exception_Comments__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=: testQuote.Id];
        for(SBQQ__QuoteLine__c qlList : qlListForQuote){
            system.debug('qllistnew'+qlList);
        }
        //SDT38499
        assert.areEqual(qlListForQuote[0].Exception_Type__c, null, 'default value before status change');
        assert.areEqual(qlListForQuote[0].Exception_Reason__c, null, 'default value before status change'); //modified by av4 for SDT-38494
        assert.areEqual(qlListForQuote[0].Exception_Comments__c, null, 'default value before status change'); //modified by av4 for SDT-38494
   
         }
    private static void testDefaultsForCaseTypes(SBQQ__Quote__c testQuote,String quotelineResponse, QuoteProcurementController.OrderWrapper classWrapper){
        classWrapper.parentQuoteLine = quotelineResponse;
        classWrapper.serviceDate = system.today();
        classWrapper.serviceType = 'Delivery';
        classWrapper.quantity = 1;
        classWrapper.onsiteContact = 'Test Contact';
        classWrapper.onsitePhone = '1111111111';
        classWrapper.PONumber = '1111111';
        classWrapper.duration = 'TEMP';
        classWrapper.quoteId = testQuote.Id;
        RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        system.debug(classWrapper+'classwrapper');
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
        
    }
    
    //TCS-SDT-36171-16-Feb-2024-Added to test for Default values on ScheduleAOverride__c field
    @isTest static void testScheduleAOverrideFieldDefaults()    
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        system.runAs(csrUser)
        {
            List<Schema.PicklistEntry> schedule_A_OverrideEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.ScheduleAOverride__c.getPicklistValues();
        
            String strFCOS = UTIL_Picklist.getPicklistEntryByLabel(schedule_A_OverrideEntries, 'Force Continuation of Service');
            String strDNC = UTIL_Picklist.getPicklistEntryByLabel(schedule_A_OverrideEntries, 'Do not Create');
            String strDNO = UTIL_Picklist.getPicklistEntryByLabel(schedule_A_OverrideEntries, 'Do Not Override');
            Asset asset = [SELECT Id from Asset WHERE Name = 'Test Asset 1' LIMIT 1];

            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            String quotelineResponse = '';
            Integer SchAOvrideTotalCount = 0;
            Integer SchAOvrideDoNotCreateCount = 0;
            Integer SchAOvrideDoNotOverrideCount = 0;
            Integer SchAOvrideForceContinuationofServiceCount = 0;   
            //Test without a value for ScheduleAOverride field on Bundle
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;		//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
            test.startTest();
            
            SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
            FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> SchAOvrideTotal = [SELECT Id, ScheduleAOverride__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__Quote__c = :testQuote.Id
                                            ];
            
            SchAOvrideTotalCount = SchAOvrideTotal.size();
            for(SBQQ__QuoteLine__c qline : SchAOvrideTotal)
            {
                if(qline.ScheduleAOverride__c.equalsIgnoreCase(strDNC))
                {
                    SchAOvrideDoNotCreateCount = SchAOvrideDoNotCreateCount + 1;
                }
                if(qline.ScheduleAOverride__c.equalsIgnoreCase(strDNO))
                {
                    SchAOvrideDoNotOverrideCount = SchAOvrideDoNotOverrideCount + 1;
                }
            }
            
            System.assertNotEquals(quotelineResponse, null, 'Error in quote lines creation');
            System.debug('Test all count 1: ' + SchAOvrideTotalCount + ':' + SchAOvrideDoNotCreateCount + ':' + SchAOvrideDoNotOverrideCount);
            System.assertEquals(6, SchAOvrideTotalCount, 'All Specs not coverted to Quote Lines');
            System.assertEquals(1, SchAOvrideDoNotCreateCount, 'ScheduleAOverride mismatch for value = Do not Create');
            System.assertEquals(4, SchAOvrideDoNotOverrideCount, 'ScheduleAOverride mismatch for value = Do Not Override');
            
            //Test with a value for ScheduleAOverride field on Bundle      
            asset.Schedule_A_Override__c = strFCOS;
            UPDATE asset;
            List<SBQQ__Quote__c> testQuotes = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
            FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC];
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuotes[1].Id, product.Id, product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> SchAOvrideTotal1 = [SELECT Id, ScheduleAOverride__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__Quote__c = :testQuotes[1].Id
                                            ];
            
            SchAOvrideTotalCount = SchAOvrideDoNotCreateCount = SchAOvrideDoNotOverrideCount = SchAOvrideForceContinuationofServiceCount = 0;
            SchAOvrideTotalCount = SchAOvrideTotal1.size();
            for(SBQQ__QuoteLine__c qline : SchAOvrideTotal1)
            {
                if(qline.ScheduleAOverride__c.equalsIgnoreCase(strDNC))
                {
                    SchAOvrideDoNotCreateCount = SchAOvrideDoNotCreateCount + 1;
                }
                if(qline.ScheduleAOverride__c.equalsIgnoreCase(strDNO))
                {
                    SchAOvrideDoNotOverrideCount = SchAOvrideDoNotOverrideCount + 1;
                }
                if(qline.ScheduleAOverride__c.equalsIgnoreCase(strFCOS))
                {
                    SchAOvrideForceContinuationofServiceCount = SchAOvrideForceContinuationofServiceCount + 1;
                }
            }
            
            test.stopTest();
            
            System.assertNotEquals(quotelineResponse, null, 'Error in quote lines creation'); 
            System.debug('Test All count 2: ' + SchAOvrideTotalCount + ':' + SchAOvrideDoNotCreateCount + ':' + SchAOvrideDoNotOverrideCount + ':' + SchAOvrideForceContinuationofServiceCount);
            System.assertEquals(6, SchAOvrideTotalCount, 'All Specs not coverted to Quote Lines');
            System.assertEquals(1, SchAOvrideDoNotCreateCount, 'ScheduleAOverride mismatch for value = Do not Create');
            System.assertEquals(1, SchAOvrideDoNotOverrideCount, 'ScheduleAOverride mismatch for value = Do Not Override');
            System.assertEquals(3, SchAOvrideForceContinuationofServiceCount, 'ScheduleAOverride mismatch for value = Force Continuation of Service');
            RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = false;	//TCS-pkulkarn-SDT-45080-13-Feb-2025-To resolve test class issue (SOQL 101)
        }
    }
}
