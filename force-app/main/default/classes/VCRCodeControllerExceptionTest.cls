/*
* @Name         : VCRCodeControllerExceptionTest
* @Author       : 
* @Date         : 
* @Vendor       : TCS 
* @Description  : Test class for VCRCodeController.setVCRCodeForBundle()
* Updates		: TCS-sDhikale-SDT-39669-12-June-2024
  Whenever Vendor is updated on a Quote Line, MAS Details (Library and Company) are updated if record is found in MAS Setup Details, otherwise set to NULL
  To fix the issues related to SDT-39054, the Vendor details and MAS Details are updated on Asset so that the Quote Lines contain the Vendor Id and MAS Details.
  In each of the test method, commented the code which was setting Vendor, hence avoiding resetting of MAS Details.
*/
@isTest
public class VCRCodeControllerExceptionTest {
    
    
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string TRASH = 'Trash';
    private static final string ON_CALL = 'On-Call';
    private static final string ROLLOFF = 'Rolloff';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SERVICES = 'Services';
    private static final string EQUIPMENT = 'Equipment'; 
    private static final string ObjectApiName = 'Pricing_Request__c';
    private static final string FieldApiName = 'Material_Code__c';
    private static final string fieldValue = 'Cardboard';
    
    //TCS-pkulkarn-12-Apr-2024-SDT-38847-Added new variables
    private static String HAUL_PRODUCT = 'Haul';
    private static String DISPOSAL_PRODUCT = 'Disposal';
    //TCS-pkulkarn-SDT-38847-12-Apr-2024-End

    /*
* @MethodName    setup
* @Author        TCS
* @description    This method will be used to setup inital required data
*/
    @testSetup static void setup(){
        //create user
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.FirstName = 'testuser#9999';
        usr.Bypass_Validation__c = true;
        Database.insert(usr);
        //TCS-pkulkarn-12-Apr-2024-SDT-38847-Added below line
        User csrUser = TestUserFactory.getCSRUserDetails(true, false);
        List<Asset> childAstHaul;
        Asset OpenTop_Asset;
        list<Case> assetcaselist = new list<Case>();
        List<Asset> childAssts;
        
        System.runAs(usr){
            List<Opportunity> oppList = new List<Opportunity>();
            List<Opportunity> oppListForUpdateAsset = new List<Opportunity>();
            List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
            List<SBQQ__Quote__c> UpdateAssetquoteList= new List<SBQQ__Quote__c>();
            List<Product2> prdList = new List<Product2>();    
            list<Account> acclist = new List<Account>();
            
            // Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
            
            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id,
                                            RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            //latest addition
            accParent.AccountNumber = Constant_Util.WM_CANADA_VENDOR;
            insert accParent;
            
            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='',
                                      RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);
            
            Account vendorAcc = new Account(Name = 'WM Vendor Account',Vendor_Business_Unit__c= '286',phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
                                            RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            //latest addition
            vendorAcc.ParentId = accParent.Id;
            acclist.add(vendorAcc);
            
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
            locationlist[0].AccountNumber = '12345678';
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            
            //Inserting Account Position (Location_Position)
            Account_Position__c accLocPosition = new Account_Position__c(AccountId__c = acclist[0].Id,
                                                                         Container_Position__c = 'Test 2',
                                                                         AlternatePostalCode__c = '1234',
                                                                         AlternateCity__c = 'Test City',
                                                                         AlternateCountry__c = 'USA',
                                                                         AlternateState__c = 'NY',
                                                                         AlternateStreet__c = 'Day Hill Road');
            insert accLocPosition;
            
            test.startTest();
            
            //adding dumpster product with family = commercial
            Product2 prod_OpenTop = TestDataFactory.createProduct('Open Top','Equipment','OT');
            prod_OpenTop.Bypass_Acorn_Integration__c= false;
            prod_OpenTop.Family= 'None';
            prdList.add(prod_OpenTop);
            
            
            
            Product2 trashWC = TestDataFactory.createProduct('Trash','Waste Category','TW');
            prdList.add(trashWC);
            
            Product2 prodPickup= TestDataFactory.createProduct('Pickup',SERVICES,'PCK');
            prdList.add(prodPickup);
            
            Product2 prodExPickup= TestDataFactory.createProduct('Extra Pickup',SERVICES,'PCK');
            prdList.add(prodExPickup);
            
            Product2 prodHaul= TestDataFactory.createProduct('Haul',SERVICES,'H');
            prodHaul.Container_Size__c = '6 Yards';
            prdList.add(prodHaul);
            
            Product2 prodDisposal= TestDataFactory.createProduct('Disposal',SERVICES,'DSP');
            prdList.add(prodDisposal);
            
            Product2 prodDelivery= TestDataFactory.createProduct('Delivery',SERVICES,'DLV');
            prdList.add(prodDelivery);
            
            Product2 prodTrash = TestDataFactory.createProduct('Trash','Waste Stream','T');
            prodTrash.Is_Pricing_Eligible__c = true;
            prdList.add(prodTrash);
            
            
            Database.insert(prdList);
            
            RecurrsiveTriggerHandler.bypassValidationQuoteLine = true;
            
            //inserting assets
            OpenTop_Asset = TestDataFactory.createAsset('OpenTop_Asset', accList[0],conList[0], prod_OpenTop, usr,locationList[0])[0];
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(accList[0].Id);
            //pCodeList[0].
            //insert pCodeList;
            OpenTop_Asset.Occurrence_Type__c = 'Scheduled';   
            OpenTop_Asset.Start_Date__c = Date.Today()-7;
            OpenTop_Asset.Project_Code__c=pCodeList[0].Id;
            OpenTop_Asset.Acorn_SID__c='1234';
            OpenTop_Asset.CPQ_Product__c = prod_OpenTop.Id;
            //asst.Monday__c = true;
            OpenTop_Asset.Category__c ='(WAL_SP) Special Project';
            //asst.MAS_Account_Number__c = '123456';
            OpenTop_Asset.Equipment_Owner__c='Unknown';
            OpenTop_Asset.Sensitivity_Code__c='CAM';
            OpenTop_Asset.Frequency__c = 'W';
            OpenTop_Asset.Supplier__c = vendorAcc.Id;
			OpenTop_Asset.MAS_Library__c = 'ARDTA.199A';	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            OpenTop_Asset.MAS_Company_Code__c = '703';		//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            OpenTop_Asset.Occurs__c = '1';	//TCS-pkulkarn-SDT-42068-Added to fix test class errors
            Database.insert(OpenTop_Asset);
            
            //inserting child asset
            childAssts = TestDataFactory.createChildAsset('Disposal');
            childAssts[1].Service_Header_Id__c  = OpenTop_Asset.Id;
            childAssts[1].ParentId = OpenTop_Asset.Id;
            //childAssts[1].RootAssetId = OpenTop_Asset.Id;
            childAssts[1].Location__c = locationList[0].Id;
            childAssts[1].CPQ_Product__c = prodDisposal.Id;
            childAssts[1].Start_Date__c = Date.Today()-7;
            childAssts[1].CPQ_Material__c = prodTrash.Id;
            childAssts[1].Acorn_SID__c='1234';
            childAssts[1].Equipment_Owner__c='Unknown';
            childAssts[1].Sensitivity_Code__c='CAM';
            childAssts[1].Supplier__c = vendorAcc.Id;
            childAssts[1].SBQQ__OriginalUnitCost__c = 10;
            childAssts[1].MAS_Library__c = 'ARDTA.199A';	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            childAssts[1].MAS_Company_Code__c = '703';		//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            Insert childAssts[1];
            
            childAstHaul = TestDataFactory.createChildAsset('haulAsset');
            childAstHaul[0].Service_Header_Id__c = OpenTop_Asset.Id;
            childAstHaul[0].ParentId = OpenTop_Asset.Id;
            //childAstHaul[0].RootAssetId = OpenTop_Asset.Id;
            childAstHaul[0].Location__c = locationList[0].Id;
            childAstHaul[0].CPQ_Product__c = prodHaul.Id;
            childAstHaul[0].Start_Date__c = Date.Today()-7;
            childAstHaul[0].CPQ_Material__c = prodTrash.Id;
            childAstHaul[0].Acorn_SID__c='1234';
            childAstHaul[0].Equipment_Owner__c='Unknown';
            childAstHaul[0].Sensitivity_Code__c='CAM';    
            childAstHaul[0].Supplier__c = vendorAcc.Id;
            childAstHaul[0].SBQQ__OriginalUnitCost__c = 10;
            childAstHaul[0].Is_Core_Service__c = TRUE;
            childAstHaul[0].Occurrence_Type__c = 'Scheduled';
            childAstHaul[0].Frequency__c = 'Weekly';
            childAstHaul[0].Cost_Unit__c = 'Years';
            childAstHaul[0].Occurs__c = '1';
            childAstHaul[0].Weekly_Frequency__c = '1';
            childAstHaul[0].Product2Id = prodHaul.Id;
            childAstHaul[0].MAS_Library__c = 'ARDTA.199A';	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            childAstHaul[0].MAS_Company_Code__c = '703';	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            childAstHaul.remove(1);
            Database.insert(childAstHaul);
            
            //Update Asset case
            case cs = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accList[0], conList[0], 
                                                     usr, locationList[0]);
            cs.Case_Type__c='Add';
            cs.Case_Sub_Type__c='Services';
            cs.Case_Reason__c='Missing Service';
            cs.Recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(Constant_Util.SERVICE_REQUEST_CASE).getRecordTypeId();
            cs.Service_Date__c= System.today();
            cs.AssetId = OpenTop_Asset.Id;
            assetcaselist.add(cs);
            Database.insert(assetcaselist);
            
            //opportunity for update asset
            oppListForUpdateAsset= TestDataFactory.createOpportunity(1,'TestOpportunityTest',assetcaselist[0].Id,assetcaselist[0].Case_Sub_Type__c, locationList[0].Id); //PK
            oppListForUpdateAsset[0].Duration__c='Temporary';
            Database.insert(oppListForUpdateAsset);
            
            //create a quote for update asset case
            UpdateAssetquoteList = TestDataFactory.createQuoteRecords(1,oppListForUpdateAsset,locationList[0],conList[0],Date.today(),false,false);
            UpdateAssetquoteList[0].SBQQ__Status__c='Draft';
            UpdateAssetquoteList[0].SBQQ__Type__c='Exception'; 
            //UpdateAssetquoteList[0].Project__c = pCodeList[0].Id;
            Database.insert(UpdateAssetquoteList);
            
            //inserting product options
            List<SBQQ__ProductOption__c> prodOptions = new List<SBQQ__ProductOption__c>();
            SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
            sbqq.Core_Service__c = true;
            sbqq.SBQQ__ConfiguredSKU__c = prod_OpenTop.Id;
            sbqq.SBQQ__OptionalSKU__c = prodHaul.Id;
            sbqq.SBQQ__Number__c = 350;
            sbqq.SBQQ__Quantity__c = 1;
            sbqq.Occurrence_Type__c = 'SCH';
            sbqq.CostModelType__c = 'PER';
            sbqq.Cost_Unit_of_Measure__c = 'YRS';
            sbqq.PriceUOM__c = 'MTH';
            sbqq.Schedule_Frequency__c = 'W';
            sbqq.Service_Days__c = 'S1';
            sbqq.Frequency_Interval__c = '1';
            sbqq.Vendor__c = vendorAcc.Id;
            prodOptions.add(sbqq);
            
            SBQQ__ProductOption__c sbqq10 = new SBQQ__ProductOption__c();
            sbqq10.SBQQ__ConfiguredSKU__c = prod_OpenTop.Id;
            sbqq10.SBQQ__OptionalSKU__c = trashWC.Id;
            sbqq10.SBQQ__Number__c = 350;
            sbqq10.SBQQ__Quantity__c = 1;
            sbqq10.Occurrence_Type__c = 'SCH';
            sbqq10.CostModelType__c = 'PER';
            sbqq10.Cost_Unit_of_Measure__c = 'MTH';
            sbqq10.PriceUOM__c = 'MTH';
            sbqq10.Schedule_Frequency__c = 'W';
            sbqq.Service_Days__c = 'S1';
            sbqq10.Frequency_Interval__c = '1';
            sbqq10.Vendor__c = vendorAcc.Id;
            prodOptions.add(sbqq10);
            
            SBQQ__ProductOption__c sbqq1 = new SBQQ__ProductOption__c();
            sbqq1.SBQQ__ConfiguredSKU__c = trashWC.Id;
            sbqq1.SBQQ__OptionalSKU__c = prodTrash.Id;
            sbqq1.SBQQ__Number__c = 350;
            sbqq1.SBQQ__Quantity__c = 1;
            sbqq1.Occurrence_Type__c = 'SCH';
            sbqq1.CostModelType__c = 'PER';
            sbqq1.Cost_Unit_of_Measure__c = 'MTH';
            sbqq1.PriceUOM__c = 'MTH';
            sbqq1.Schedule_Frequency__c = 'W';
            sbqq.Service_Days__c = 'S1';
            sbqq1.Frequency_Interval__c = '1';
            sbqq1.Vendor__c = vendorAcc.Id;
            prodOptions.add(sbqq1);
            
            insert prodOptions;
            
            MAS_Setup_Detail__c mas = new MAS_Setup_Detail__c();
            mas.MAS_Line_of_Business__c = 'O';
            mas.MAS_Library__c = 'ARDTA.129A';
            mas.Business_Unit_Number__c = '286';
            mas.MAS_Company_Code__c = '286';
            mas.Bypass_Price_Review__c = false;
            insert mas;
           	//changes related to test class errors-SDT-33637
           	test.stoptest();
        }
    }  
    
    //testing calculation - size increase
    @isTest
    public static void testVCRUpdateSizeIncrease() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    //changed
                    ql.Equipment_Size__c = 'YRDS-8';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;

            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'INP');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - quantity increase
    @isTest
    public static void testVCRUpdateQuantityIncrease() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
    //    test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                //changed
                ql.SBQQ__Quantity__c = 2;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'INP');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - unit cost increased
    @isTest
    public static void testVCRUpdateCostIncreased() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    //changed
                    ql.SBQQ__UnitCost__c = 20;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                    ql.Cost_Override_Reason__c = 'Vendor changed - vendor cost exceeded client NTE';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'IPI');
            
        }
        test.stopTest();
        
    }
    
     //testing calculation - unit cost decreased
    @isTest
    public static void testVCRUpdateCostDecreased() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    //changed
                    ql.SBQQ__UnitCost__c = 5;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                    ql.Cost_Override_Reason__c = 'Vendor changed - vendor cost exceeded client NTE';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'RBP');
            
        }
        test.stopTest();
        
    }
    
    
    //testing calculation - changing equipment size uom
    @isTest
    public static void testVCRUpdateSizeUOMChangeToGals () {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
       // test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    //changed
                    ql.Equipment_Size__c = 'GALS-150';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'DIS');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - changing equipment size uom
    @isTest
    public static void testVCRUpdateSizeUOMChangeToFeet () {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    //changed
                    ql.Equipment_Size__c = 'FEET-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'DIS');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - costUOM changed
    @isTest
    public static void testVCRUpdateCostUOMChangedToDays() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'DYS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'IPI');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - costUOM changed
    @isTest
    public static void testVCRUpdateCostUOMChangedToMonths() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'MTH';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'IPI');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - schedule frequency changed
    @isTest
    public static void testVCRUpdateSchedFreqChangedToDays() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    //changed
                    ql.Schedule_Frequency__c = 'D';
                    ql.Frequency_Interval__c = '1';
                    //ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'INP');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - schedule frequency changed
    @isTest
    public static void testVCRUpdateSchedFreqChangedToMonths() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    //changed
                    ql.Schedule_Frequency__c = 'M';
                    //changed
                    ql.Frequency_Interval__c = '2';
                    //ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'DIS');
            
        }
        test.stopTest();
        
    }
    
    //testing calculation - schedule frequency changed
    @isTest
    public static void testVCRUpdateSchedFreqChangedToYears() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    //changed
                    ql.Schedule_Frequency__c = 'Y';
                    ql.Frequency_Interval__c = '1';
                    //ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'DIS');
            
        }
        test.stopTest();
        
    }
    

    //testing MSC
    @isTest
    public static void testVCRUpdateForMSC() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c =: 'Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    //changed
                    ql.Cost_Unit_of_Measure__c = 'TN';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, 'MSC');
            
        }
        test.stopTest();
        
    }
    
    
    //testing NULL - multiple haul quotelines
    @isTest
    public static void testVCRUpdateMultiHaulQuotelines() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Product2 prodHaul= [SELECT Id  FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            Product2 prodTrash= [SELECT Id  FROM Product2 WHERE Name = 'Trash' LIMIT 1];
            List<Opportunity> oppListForUpdateAsset = [SELECT Id from Opportunity LIMIT 1];
            List<Account> locationList = [SELECT Id, ParentId FROM Account WHERE ParentId != NULL AND AccountNumber =: '12345678' LIMIT 1];
            List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c, SBQQ__Account__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c =: 'Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            //querying parentql
            SBQQ__QuoteLine__c OTQuoteline = [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c =: NULL LIMIT 1];
            //inserting another haul ql
            SBQQ__QuoteLine__c quotelineForHaulService = QuoteTestDataFactory.createQuoteLineRecords(quoteRec, prodHaul,'TEMP',1.00,'CLT',
                                                                                                     'YRDS-6','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                     10,'DYS','Do Not Override','NBG');
            quotelineForHaulService.SBQQ__RequiredBy__c = OTQuoteline.Id;
            quotelineForHaulService.Vendor__c = vendorAcc.Id;
            quotelineForHaulService.CostModelType__c ='PER';
            quotelineForHaulService.MASLibrary__c = 'ARDTA.180';
            quotelineForHaulService.MASCompany__c = 'test mas company'; 
            quotelineForHaulService.Cost_Unit_of_Measure__c = 'YRS';
            QuoteTestDataFactory.insertQuoteLine(quotelineForHaulService);
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;

            
            //updating quote status  //SDT-33363
            //quoteRec.SBQQ__Status__c = 'Product Configured';
           // update quoteRec; 
            
            //updating quote status
            test.startTest();
            System.assertEquals(true, true);
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Draft';   //SDT-33363 - changed to draft from cost configured
            update quoteRec; 
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__Quote__r.Case_record_Type__c,
                                                      SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c 
                                                      FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, NULL);
            
        }
        test.stopTest();
        
    }
    
    //testing null - multiple haul assets
    @isTest
    public static void testVCRUpdateMultiHaulAssets() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            //Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Product2 prodTrash= [SELECT Id  FROM Product2 WHERE Name = 'Trash' LIMIT 1];
            Product2 prodHaul= [SELECT Id  FROM Product2 WHERE Name = 'Haul' LIMIT 1];
            List<Contact> conList = [SELECT Id FROM Contact LIMIT 1];
            List<Account> locationList = [SELECT Id, ParentId FROM Account WHERE ParentId != NULL AND AccountNumber =: '12345678' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            List<Account> accList = [SELECT Id, AccountNumber FROM Account WHERE AccountNumber =: '' LIMIT 1];
            User usr = [SELECT Id FROM User LIMIT 1];
            
            test.startTest(); //SDT-33637
            //creating haul asset
            List<Asset> childAstHaul = TestDataFactory.createChildAsset('haulAsset');
            childAstHaul[0].Service_Header_Id__c = asset.Id;
            childAstHaul[0].ParentId = asset.Id;
            //childAstHaul[0].RootAssetId = OpenTop_Asset.Id;
            childAstHaul[0].Location__c = locationList[0].Id;
            childAstHaul[0].CPQ_Product__c = prodHaul.Id;
            childAstHaul[0].Start_Date__c = Date.Today()-7;
            childAstHaul[0].CPQ_Material__c = prodTrash.Id;
            childAstHaul[0].Acorn_SID__c='1234';
            childAstHaul[0].Equipment_Owner__c='Unknown';
            childAstHaul[0].Sensitivity_Code__c='CAM';    
            childAstHaul[0].Supplier__c = vendorAcc.Id;
            childAstHaul[0].SBQQ__OriginalUnitCost__c = 10;
            childAstHaul[0].Is_Core_Service__c = TRUE;
            childAstHaul[0].Occurrence_Type__c = 'Scheduled';
            childAstHaul[0].Frequency__c = 'Weekly';
            childAstHaul[0].Cost_Unit__c = 'Years';
            childAstHaul[0].Occurs__c = '1';
            childAstHaul[0].Weekly_Frequency__c = '1';
            childAstHaul[0].Product2Id = prodHaul.Id;
            childAstHaul.remove(1);
            Database.insert(childAstHaul);
            
            //creating case, opportunity and quote
            //Update Asset case
            case cs = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accList[0], conList[0], 
                                                     usr, locationList[0]);
            cs.Case_Type__c='Add';
            cs.Case_Sub_Type__c='Services';
            cs.Case_Reason__c='Missing Service';
            cs.Recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(Constant_Util.SERVICE_REQUEST_CASE).getRecordTypeId();
            cs.Service_Date__c= System.today();
            cs.AssetId = asset.Id;
            Database.insert(cs);
            
            //opportunity for update asset
            List<Opportunity> oppListForUpdateAsset= TestDataFactory.createOpportunity(1,'TestOpportunityTest', cs.Id, cs.Case_Sub_Type__c, locationList[0].Id);
            oppListForUpdateAsset[0].Duration__c='Temporary';
            Database.insert(oppListForUpdateAsset[0]);
            
            //create a quote for update asset case
            List<SBQQ__Quote__c> UpdateAssetquoteList = TestDataFactory.createQuoteRecords(1,oppListForUpdateAsset,locationList[0],conList[0],Date.today(),false,false);
            UpdateAssetquoteList[0].SBQQ__Status__c='Draft';
            UpdateAssetquoteList[0].SBQQ__Type__c='Exception'; 
            //UpdateAssetquoteList[0].Project__c = pCodeList[0].Id;
            Database.insert(UpdateAssetquoteList[0]);
            
            
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c, 
                                       SBQQ__Account__c from SBQQ__Quote__c Where Id =: UpdateAssetquoteList[0].Id LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            //querying parentql
            SBQQ__QuoteLine__c OTQuoteline = [SELECT Id, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c =: NULL LIMIT 1];
            
            //inserting another haul ql
            SBQQ__QuoteLine__c quotelineForHaulService = QuoteTestDataFactory.createQuoteLineRecords(quoteRec, prodHaul,'TEMP',1.00,'CLT',
                                                                                                     'YRDS-6','OC','M','1','PER',34.00,'DYS','PER',
                                                                                                     10,'DYS','Do Not Override','NBG');
            quotelineForHaulService.SBQQ__RequiredBy__c = OTQuoteline.Id;
            quotelineForHaulService.Vendor__c = vendorAcc.Id;
            quotelineForHaulService.CostModelType__c ='PER';
            quotelineForHaulService.MASLibrary__c = 'ARDTA.180';
            quotelineForHaulService.MASCompany__c = 'test mas company'; 
            quotelineForHaulService.Cost_Unit_of_Measure__c = 'YRS';
            quotelineForHaulService.AssetId__c = childAstHaul[0].Id;
            QuoteTestDataFactory.insertQuoteLine(quotelineForHaulService);
            
            //querying all quotelines
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteRec.Id];
            
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();

            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                //ql.Vendor__c = vendorAcc.Id;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Commented
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    //changed
                    ql.Equipment_Size__c = 'YRDS-8';
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            //updating the quotelines
            update toUpdateList;

            
            //updating quote status
            /*quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;*/
            system.debug('the updated quotelist is '+UpdateAssetquoteList[0]);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where Id =: UpdateAssetquoteList[0].Id LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Draft';
            quoteRec.SBQQ__Type__c = 'Quote';
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, 
                                                      AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c
                                                     WHERE SBQQ__Quote__c =: quoteRec.Id];
            List<Asset> assetList = [Select Id, CPQ_Product__c, CPQ_Product__r.Name FROM Asset WHERE ParentId =: asset.Id];
            
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            //for checking
            for(Asset ast : assetList) {
                system.debug('id ' + ast.Id + ' >> CPQ_Product__c >> ' + ast.CPQ_Product__r.Name);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, NULL);
             test.stopTest(); //SDT-33637
        }
       
        
    }
    
     //testing with no canada or us vendor
    @isTest
    public static void testVCRUpdateForNonWMVendor() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        //test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            asset.Supplier__c = null;	//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            UPDATE asset;				//TCS-pkulkarn-SDT-39054-1-Apr-2024-Added
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       from SBQQ__Quote__c 
                                       Where SBQQ__Type__c =: 'Exception' AND sbqq__status__c=:'Draft' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, 
                                                                                             product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c,
                                               SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) {
                ql.SBQQ__Quantity__c = 1;
                //latest addition
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                if(ql.SBQQ__ProductName__c == 'Haul' || ql.SBQQ__ProductName__c == 'Disposal') {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                }
                toUpdateList.add(ql);
            }
            
            update toUpdateList;
            
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c 
                        from SBQQ__Quote__c Where SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Modified to Approved from Cost Configured to trigger VCR Code calculation when status changes to Approved
            update quoteRec;
            
            
            List<SBQQ__QuoteLine__c> updatedQlList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, AssetId__r.Quantity__c FROM SBQQ__QuoteLine__c];
            //for checking
            for(SBQQ__QuoteLine__c ql : updatedQlList) {
                system.debug('Id ' + ql.Id + ' >> requiredby ' + ql.SBQQ__RequiredBy__c + ' >> requiredby.requiredby ' + ql.SBQQ__RequiredBy__r.sbqq__requiredby__c + ' >> VCR ' + ql.VCRCode__c + ' >> quantity ' + ql.SBQQ__Quantity__c);
				system.debug('QL-Asset values >> ' + ql.AssetId__r.CPQ_Product__r.Name + ' ' + ql.AssetId__r.Quantity__c);
            }
            
            System.assertEquals(updatedQlList[0].VCRCode__c, NULL);
            
        }
        test.stopTest();
        
    }
        
    //TCS-pkulkarn/sdhikale-SDT-38847-Added new method to test with Asset having Sheduled On-Call asset
    //And Value is provided in the VCR Code field manually, to test whether User provided value is updated on other quote lines
    @isTest public static void testVCRUpdateQuantityIncreaseVCRUserInput()
    {
        User csrUser = [SELECT Id FROM User WHERE LastName = 'TestingForApproval'];
        //test.startTest();
        system.runAs(csrUser)
        {
            if(SBQQ.TriggerControl.isEnabled())
            {
                SBQQ.TriggerControl.disable();
            }
            
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Add' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            Account vendorAcc = [SELECT Id, Name FROM Account WHERE Name =: 'WM Vendor Account' LIMIT 1];
            
            //querying asset and change Occurrence Type to Scheduled On-Call
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, SBQQ__Status__c, SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                       FROM SBQQ__Quote__c 
                                       WHERE SBQQ__Type__c ='Exception' AND SBQQ__Status__c=:'Draft' LIMIT 1];
            Database.update(asset,false);
            
            Asset assetHaul= [SELECT Id, Duration__c, Start_Date__c, Cost_Unit__c, CPQ_Product__c from Asset WHERE CPQ_Product__r.Name = 'Haul' AND ParentId = :asset.Id];
            Database.update(assetHaul,false);
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c> qlList = [Select Id, SBQQ__ProductName__c, Vendor__c, SBQQ__RequiredBy__c, SBQQ__UnitCost__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];
           
            //to store the quotelines to be updated
            List<SBQQ__QuoteLine__c> toUpdateList = new List<SBQQ__QuoteLine__c>();
            
            for(SBQQ__QuoteLine__c ql : qlList) 
            {
                ql.SBQQ__Quantity__c = 2;
                ql.MASLibrary__c = 'ARDTA.199A';
                ql.MASCompany__c = '703';
                ql.SetupComment__c = 'test';
                if(ql.SBQQ__ProductName__c == HAUL_PRODUCT || ql.SBQQ__ProductName__c == DISPOSAL_PRODUCT)
                {
                    ql.SBQQ__UnitCost__c = 10;
                    ql.Cost_Unit_of_Measure__c = 'YRS';
                    ql.CostModelType__c = 'PER';
                    ql.Occurrence_Type__c = 'SCH';
                    ql.Core_Service__c = TRUE;
                    ql.Schedule_Frequency__c = 'W';
                    ql.Frequency_Interval__c = '1';
                    ql.Service_Days__c = 'M';
                    ql.Equipment_Size__c = 'YRDS-6';
                    
                }
                if(ql.SBQQ__RequiredBy__c == null)
                {
                    ql.VCRCode__c = getVCRCodeFromListByLabel('INP');	//Update VCR code with valid choice, to test whether system overrides it or not
                }
                //latest addition
                toUpdateList.add(ql);
            }
            
            update toUpdateList;

            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            test.startTest();
            System.assertEquals(true, true);
            //updating quote status
            quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c, sbqq__status__c, Case_Record_Type__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c ='Exception' LIMIT 1];
            quoteRec.SBQQ__Status__c = 'Approved';	
            update quoteRec;
            
            List<SBQQ__QuoteLine__c> quoteLinesList = [Select Id, SBQQ__RequiredBy__c, SBQQ__Quantity__c, VCRCode__c, SBQQ__RequiredBy__r.sbqq__requiredby__c, AssetId__r.CPQ_Product__r.Name, 
                                                       AssetId__r.Quantity__c 
                                                       FROM SBQQ__QuoteLine__c 
                                                       WHERE SBQQ__ProductName__c =: HAUL_PRODUCT OR SBQQ__ProductName__c =: DISPOSAL_PRODUCT];
            System.assertEquals(quoteLinesList[0].VCRCode__c, getVCRCodeFromListByLabel('INP'), 'Error in assertion');
        }
        test.stopTest();
    }

	//TCS-pkulkarn-SDT-38847-15-Apr-2024-Added new method to test get the VCR Code from picklist
    public static String getVCRCodeFromListByLabel(String sVCRCodeLabel)
    {
        List<String> sVCRCodes = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'VCRCode__c');

        for(String strVCRCodeLabelAndValue : sVCRCodes)
        {
            if(strVCRCodeLabelAndValue.contains(sVCRCodeLabel))
            {
                return strVCRCodeLabelAndValue.split(',')[1];
            }
        }
        return '';
    }
}