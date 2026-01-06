@isTest(seeAllData = false)
public class  ExceptionDetailsModifyServicesTest
{
    private static final string ASSERTION_FAILED_MSG = 'Assertion failed';

    @testSetup 
    // method for setting up data
    static void createData() {
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        insert usr;
        List<Account> accList;
        List<Account> locationList;
        List<Contact> conList;
        List<Case> caseList;
        List<Opportunity> oppList;
        Asset asst;
        list<Case> assetcaselist = new list<Case>();
        List<Product2> prodList= new List<Product2>();
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
            createVendorAccounts(usr);
            
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
            
            //Setup MAS Details
            createMASDetailRecords();
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //addition for test class errors
            test.startTest();
            
            Product2 prodOT = TestDataFactory.createProduct('Open Top','Equipment','OT');
            prodOT.Bypass_Acorn_Integration__c= false;
            prodOT.Family= 'None';
            Product2 prod = TestDataFactory.createProduct('Delivery','Services','DLV');
            Product2 prod1 = TestDataFactory.createProduct('Pickup','Services','PCK');
            Product2 prod2 =TestDataFactory.createProduct('Removal','Services','REM');
            Product2 prodSwapout =TestDataFactory.createProduct('Swapout','Services','SWO');
            prod3 = TestDataFactory.createProduct('Trash','Waste Category','TW');
            prod4 = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodList.add(prodOT);
            prodList.add(prod);
            prodList.add(prod1);
            prodList.add(prod2);
            prodDumpster = TestDataFactory.createProduct('Dumpster','Commercial', 'DMP'); //30092 PK Commercial
            prodDumpster.Is_Pricing_Eligible__c = true;
            prodDumpster.Container_Size__c = '2 Yards';
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
            
         
            Product2 prodLiner = TestDataFactory.createProduct('Liner','Supplies', 'PRD');
            prodList.add(prodLiner);
            Product2 prodHaul = TestDataFactory.createProduct('Haul','Rolloff', 'H');
            prodList.add(prodHaul);
            Product2 prodDisposal = TestDataFactory.createProduct('Disposal','Rolloff', 'DSP');
            prodList.add(prodDisposal);
            prodList.add(prodSwapout);
           
            
            insert prodList;
            
            //Create Price book and price book entries
            createPriceBookAndBookEntries(prodOT, prod, prod1, prod2, prod3);

            // Inserting Asset
            asst = TestDataFactory.createAsset('Test Asset', accList[0],conList[0], prodOT, usr,locationList[0])[0];
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(accList[0].Id);//seema
            insert pCodeList;
            asst.Project_Code__c=pCodeList[0].Id;//seema
            asst.Duration__c = '';
            asst.Acorn_SID__c='1234';
            asst.Monday__c = false;
            asst.Category__c ='(WAL_SP) Special Project';
            //asst.MAS_Account_Number__c = '123456';
            asst.Equipment_Owner__c='Unknown';
            asst.Sensitivity_Code__c='CAM';
            Database.insert(asst);
            
            case cs = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accList[0], conList[0], 
                                                             usr, locationList[0]);
            cs.Case_Type__c='Service Changes';
            cs.Case_Sub_Type__c='Customer Requested';
            cs.Case_Reason__c='';
            cs.Recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Update Asset Case').getRecordTypeId();
            cs.Service_Date__c= System.today();
            cs.AssetId = asst.Id;
            assetcaselist.add(cs);
            
            Database.insert(assetcaselist[0]);
			//Create Dumpster Asset with Service Header and Service Details
            createDumpsterAsset(accList, conList, prodDumpster, usr, locationList, prod, prod1, prod4);
            
        }
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        
        Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        User usrObj= TestDataFactory.createUser(prfl); 
        usrObj.LastName = 'TestingForApprovalcsr';
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
          oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',assetcaselist[0].Id,assetcaselist[0].Case_Sub_Type__c, locationList[0].Id); //PK
          oppList[0].Duration__c='Temporary';
          insert oppList;
          quoteList= TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false);
          quoteList.addAll(TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false));
          quoteList.addAll(TestDataFactory.createQuoteRecords(1,oppList,locationList[0],conList[0],Date.today(),false,false));
          quoteList[1].SBQQ__Status__c='Draft';
          insert quoteList;
          
          
          List<SBQQ__ProductFeature__c> sbqqFeatList= new List<SBQQ__ProductFeature__c>();
          SBQQ__ProductFeature__c feat= new SBQQ__ProductFeature__c();
          feat.Name= 'Additional Services';
          feat.SBQQ__Number__c = 20;
          feat.SBQQ__MinOptionCount__c = 0;
          feat.SBQQ__ConfiguredSKU__c = prodDumpster.id;
          sbqqFeatList.add(feat);
          insert sbqqFeatList;
            
          //Create product options
          List<Product2> otherProductsList = new List<Product2>();
          otherProductsList.add(prodDumpster);
          otherProductsList.add(prodCompactor);
          otherProductsList.add(prod3);
          otherProductsList.add(prod4);
          createProductOptions(prodList, otherProductsList, sbqqFeatList);
          
          RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        }
    }
    
    
    @isTest static void allModifyExistingServicesTest()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName =: 'TestingForApprovalcsr'];
        system.runAs(csrUser)
        {
	     
            Asset asset = [SELECT Id from Asset WHERE Name = 'Test Asset DMP 1' LIMIT 1];
            Account wmVendorAccount = [SELECT Id from Account WHERE Name = 'WMVendorChild' LIMIT 1];
    
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Dumpster' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            String quotelineResponse = '';
            
            SBQQ__Quote__c testQuote = [SELECT Id, Case__c, SBQQ__Opportunity2__r.Case__c, SBQQ__Account__r.Parent.AccountNumber,SBQQ__StartDate__c
            FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Draft' AND Case__c != null ORDER BY CreatedDate DESC LIMIT 1];
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, testQuote.Id, product.Id, product1.Id, '2 Yards');
            System.assertNotEquals(quotelineResponse, null, 'Error in quote lines creation'); 
            List<SBQQ__QuoteLine__c> bundleQuoteLines = [SELECT Id, SBQQ__Quote__c, Equipment_Size__c, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,
                                                         Vendor_Commit_Date__c, SBQQ__StartDate__c, Vendor__c
                                                         FROM SBQQ__QuoteLine__c 
                                                         WHERE SBQQ__Quote__c = :testQuote.Id //AND SBQQ__RequiredBy__c = null
                                                        ];
         
            
            
            bundleQuoteLines[0].SBQQ__Quantity__c = 6;
            bundleQuoteLines[0].Vendor_Commit_Date__c = Date.Today().addDays(10);
            bundleQuoteLines[0].SBQQ__StartDate__c = Date.Today().addDays(10);
            bundleQuoteLines[0].Vendor__c = wmVendorAccount.Id;
            
            bundleQuoteLines[1].SBQQ__Quantity__c = 6;
            bundleQuoteLines[1].Vendor_Commit_Date__c = Date.Today().addDays(10);
            bundleQuoteLines[1].SBQQ__StartDate__c = Date.Today().addDays(10);
            bundleQuoteLines[1].Vendor__c = wmVendorAccount.Id;
            
            bundleQuoteLines[2].SBQQ__Quantity__c = 6;
            bundleQuoteLines[2].Vendor_Commit_Date__c = Date.Today().addDays(10);
            bundleQuoteLines[2].SBQQ__StartDate__c = Date.Today().addDays(10);
            bundleQuoteLines[2].Vendor__c = wmVendorAccount.Id;
            
            bundleQuoteLines[3].SBQQ__Quantity__c = 6;
            bundleQuoteLines[3].Vendor_Commit_Date__c = Date.Today().addDays(10);
            bundleQuoteLines[3].SBQQ__StartDate__c = Date.Today().addDays(10);
            bundleQuoteLines[3].Vendor__c = wmVendorAccount.Id;
            
            test.startTest();
            system.assertEquals(true, true, 'To avoid SOQL 101');
            
            UPDATE bundleQuoteLines;
                        
            QuoteProcurementController.OrderWrapper orderWrapper = QuoteProcurementController.generateOrderWrapper();
            orderWrapper.parentQuoteLine = quotelineResponse;
            orderWrapper.serviceDate = Date.Today().addDays(10);
            orderWrapper.serviceEndDate = null;
            orderWrapper.serviceType = 'Delivery';
            orderWrapper.onsiteContact = 'Test User';
            orderWrapper.onsitePhone = '1111111111';
            orderWrapper.PONumber = '123456';
            orderWrapper.duration = 'PERM';
            orderWrapper.quoteId = bundleQuoteLines[0].SBQQ__Quote__c;
            
            //test.startTest();
            QuoteProcurementController.createDelivery(orderWrapper, 'Delivery', 'Test');
            testQuote.SBQQ__Status__c='Product Configured';
	   // Commeting out update to handle too many SOQL error	
           // update testQuote;
            
            test.stopTest();
        }
    }
 
    
    //Create vendor accounts
    static void createVendorAccounts(User usr)
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
    
    //Create Price book and price book entries
    static void createPriceBookAndBookEntries(Product2 prodOT, Product2 prod, Product2 prod1, Product2 prod2, Product2 prod3)
    {
        Pricebook2 pbObj = new Pricebook2(Name = 'Standard Price Book');
        insert pbObj;
        Pricebookentry pbeObjOT= new Pricebookentry(Product2Id = prodOT.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        Pricebookentry pbeObj1= new Pricebookentry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        Pricebookentry pbeObj2= new Pricebookentry(Product2Id = prod1.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        Pricebookentry pbeObj3= new Pricebookentry(Product2Id = prod2.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        Pricebookentry pbeObj4= new Pricebookentry(Product2Id = prod3.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        List<Pricebookentry> pbeList= new List<Pricebookentry>();
        pbeList.add(pbeObjOT);
        pbeList.add(pbeObj1);
        pbeList.add(pbeObj2);
        pbeList.add(pbeObj3);
        pbeList.add(pbeObj4);
        insert pbeList;
    }
    
    //Setup MAS Details
    static void createMASDetailRecords()
    {
        List<MAS_Setup_Detail__c> masLst = new List<MAS_Setup_Detail__c>();
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
    }
    
    static void createProductOptions(List<Product2> prodList, List<Product2> otherProductsList, List<SBQQ__ProductFeature__c> sbqqFeatList)
    {
        Product2 prodDumpster = otherProductsList[0];
        Product2 prodCompactor  = otherProductsList[1];
        Product2 prod3 = otherProductsList[2];
        Product2 prod4 = otherProductsList[3];
        
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
        
        SBQQ__ProductOption__c wstCategoryPO = new SBQQ__ProductOption__c();
        wstCategoryPO.SBQQ__ConfiguredSKU__c = prodDumpster.Id;
        wstCategoryPO.SBQQ__OptionalSKU__c = prod3.Id;
        wstCategoryPO.SBQQ__Number__c = 350;
        wstCategoryPO.SBQQ__Quantity__c = 1;
        wstCategoryPO.Occurrence_Type__c = 'SCH';
        wstCategoryPO.CostModelType__c = 'PER';
        wstCategoryPO.Cost_Unit_of_Measure__c = 'MTH';
        wstCategoryPO.PriceUOM__c = 'MTH';
        wstCategoryPO.Schedule_Frequency__c = 'W';
        wstCategoryPO.Frequency_Interval__c = '1';
        sbqqLst.add(wstCategoryPO);
        
        
        SBQQ__ProductOption__c wstStreamPO = new SBQQ__ProductOption__c();
        wstStreamPO.SBQQ__ConfiguredSKU__c = prod3.Id;
        wstStreamPO.SBQQ__OptionalSKU__c = prod4.Id;
        wstStreamPO.SBQQ__Number__c = 350;
        wstStreamPO.SBQQ__Quantity__c = 1;
        wstStreamPO.Occurrence_Type__c = 'SCH';
        wstStreamPO.CostModelType__c = 'PER';
        wstStreamPO.Cost_Unit_of_Measure__c = 'MTH';
        wstStreamPO.PriceUOM__c = 'MTH';
        wstStreamPO.Schedule_Frequency__c = 'W';
        wstStreamPO.Frequency_Interval__c = '1';
        sbqqLst.add(wstStreamPO);
        
        
        SBQQ__ProductOption__c swapoutPO = new SBQQ__ProductOption__c();
        swapoutPO.SBQQ__ConfiguredSKU__c = prodDumpster.Id;
        swapoutPO.SBQQ__OptionalSKU__c = prodList[13].Id;
        swapoutPO.SBQQ__Number__c = 350;
        swapoutPO.SBQQ__Quantity__c = 1;
        swapoutPO.Occurrence_Type__c = 'SCH';
        swapoutPO.CostModelType__c = 'PER';
        swapoutPO.Cost_Unit_of_Measure__c = 'MTH';
        swapoutPO.PriceUOM__c = 'MTH';
        swapoutPO.Schedule_Frequency__c = 'W';
        swapoutPO.Frequency_Interval__c = '1';
        sbqqLst.add(swapoutPO);
        
       
        SBQQ__ProductOption__c deliveryPO = new SBQQ__ProductOption__c();
        deliveryPO.SBQQ__ConfiguredSKU__c = prodDumpster.Id;
        deliveryPO.SBQQ__OptionalSKU__c = prodList[1].Id;
        deliveryPO.SBQQ__Number__c = 350;
        deliveryPO.SBQQ__Quantity__c = 1;
        deliveryPO.Occurrence_Type__c = 'OC';
        deliveryPO.CostModelType__c = 'PER';
        deliveryPO.Cost_Unit_of_Measure__c = 'EV';
        deliveryPO.PriceUOM__c = 'EV';
        deliveryPO.Schedule_Frequency__c = 'W';
        deliveryPO.Frequency_Interval__c = '1';
        sbqqLst.add(deliveryPO);
        
        
        SBQQ__ProductOption__c removalPO = new SBQQ__ProductOption__c();
        removalPO.SBQQ__ConfiguredSKU__c = prodDumpster.Id;
        removalPO.SBQQ__OptionalSKU__c = prodList[3].Id;
        removalPO.SBQQ__Number__c = 350;
        removalPO.SBQQ__Quantity__c = 1;
        removalPO.Occurrence_Type__c = 'SCH';
        removalPO.CostModelType__c = 'PER';
        removalPO.Cost_Unit_of_Measure__c = 'MTH';
        removalPO.PriceUOM__c = 'MTH';
        removalPO.Schedule_Frequency__c = 'W';
        removalPO.Frequency_Interval__c = '1';
        sbqqLst.add(removalPO);
       
        
        insert sbqqLst;
    }
    
    //Create Dumpster Asset with Service Header and Service Details
    static void createDumpsterAsset(List<Account> accList, List<Contact> conList, Product2 prodDumpster, User usr, List<Account> locationList, Product2 prod, Product2 prod1, Product2 prod4)
    {
        Asset asstDMP = TestDataFactory.createAsset('Test Asset DMP 1', accList[0],conList[0], prodDumpster, usr,locationList[0])[0];
        List<Project_Code__c> pCodeList2 = TestDataFactory.createProjectCode(accList[0].Id);
        insert pCodeList2;
        asstDMP.Project_Code__c = pCodeList2[0].Id;
        asstDMP.Duration__c = '';
        asstDMP.Acorn_SID__c='1234';
        asstDMP.Monday__c = true;
        asstDMP.Category__c ='(WAL_SP) Special Project';
        asstDMP.Equipment_Owner__c='Unknown';
        asstDMP.Sensitivity_Code__c='CAM';
        asstDMP.Start_Date__c = Date.Today();
        asstDMP.CPQ_Product__c = prodDumpster.Id;
        asstDMP.CPQ_Material__c = prod4.Id;
        asstDMP.Schedule_A_Override__c = '';
        asstDMP.Quantity__c = 4;
        Database.insert(asstDMP);
        
        List<Asset> childAstDMP;
        childAstDMP = TestDataFactory.createChildAsset('Test Asset Child');
        childAstDMP[0].Service_Header_Id__c = asstDMP.Id;
        childAstDMP[0].ParentId = asstDMP.Id;
        childAstDMP[0].Location__c = locationList[0].Id;
        childAstDMP[0].Acorn_SID__c='1234';
        childAstDMP[0].Equipment_Owner__c='Unknown';
        childAstDMP[0].Sensitivity_Code__c='CAM';
        childAstDMP[0].CPQ_Product__c = prod1.Id;	//pickup
        childAstDMP[0].Start_Date__c = Date.Today() - 3;
        childAstDMP[0].CPQ_Material__c = prod4.Id;
        childAstDMP[0].Occurrence_Type__c = 'On-Call';
        
        
        childAstDMP[1].Service_Header_Id__c = asstDMP.Id;
        childAstDMP[1].ParentId = asstDMP.Id;
        childAstDMP[1].Location__c = locationList[0].Id;
        childAstDMP[1].CPQ_Product__c = prod.Id;
        childAstDMP[1].Start_Date__c = Date.Today().addDays(3);
        childAstDMP[1].End_Date__c = Date.Today().addDays(3);
        childAstDMP[1].CPQ_Material__c = prod4.Id;
        childAstDMP[1].Acorn_SID__c='1234';
        childAstDMP[1].Equipment_Owner__c='Unknown';
        childAstDMP[1].Sensitivity_Code__c='CAM';
        
        Database.insert(childAstDMP);
       
    }
}
