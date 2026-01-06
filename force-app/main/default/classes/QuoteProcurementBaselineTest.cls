/** @Name     
* QuoteProcurementBaselineTest
* @Author        TCS
* @Date          
* @Description   This class is created to test SDT .
*/
@isTest(seeAllData =false)
public class QuoteProcurementBaselineTest {
    
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
    
    /*
* @MethodName    setup
* @Author        TCS
* @description	  This method will be used to setup inital required data
*/
    @testSetup static void setup(){
        //create user
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.FirstName = 'testuser#9999';
        usr.Bypass_Validation__c = true;
        Database.insert(usr);
        
        //Changes for SDT-39632
        CodeSwitchTestData.CodeSwitchData();
        
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
            
            Account accParent = new Account(Name = 'Parent Account', phone = '9999999999', OwnerId = usr.id, AccountNumber='HMD',
                                            RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true); 
            insert accParent;
            
            Account acc = new Account(Name = Constant_Util.KEYWORD_TEST, phone = '9999999999', OwnerId = usr.id, AccountNumber='',
                                      RecordTypeid = TestDataFactory.getRecordType('Client','Account'), IsPricingEligible__c = true, ParentId = accParent.Id, Type ='Location');
            acclist.add(acc);
            
            Account vendorAcc = new Account(Name = 'WM Vendor Account',Vendor_Business_Unit__c= '286',phone = '9999999999', OwnerId = usr.id, AccountNumber='4321',
                                            RecordTypeid = TestDataFactory.getRecordType('Vendor','Account'));
            acclist.add(vendorAcc);
            
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Chicago';
            locationlist[0].IsPricingEligible__c = true;
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
            OpenTop_Asset.Occurrence_Type__c = 'On-Call';   
            OpenTop_Asset.Start_Date__c = Date.Today()-7;
            OpenTop_Asset.Project_Code__c=pCodeList[0].Id;
            OpenTop_Asset.Acorn_SID__c='1234';
            OpenTop_Asset.CPQ_Product__c = prod_OpenTop.Id;
            //asst.Monday__c = true;
            OpenTop_Asset.Category__c ='(WAL_SP) Special Project';
            //asst.MAS_Account_Number__c = '123456';
            OpenTop_Asset.Equipment_Owner__c='Unknown';
            OpenTop_Asset.Sensitivity_Code__c='CAM';
            OpenTop_Asset.Frequency__c = 'W';//
            OpenTop_Asset.Occurs__c = '1';	//TCS-pkulkarn-SDT-42068-Added to fix test class errors
            Database.insert(OpenTop_Asset);
            
            //inserting child asset
            childAssts = TestDataFactory.createChildAsset('Pickup_childAsset');
            childAssts[0].Occurrence_Type__c = 'On-Call';
            childAssts[0].Service_Header_Id__c   = OpenTop_Asset.Id;
            childAssts[0].ParentId = OpenTop_Asset.Id;
            childAssts[0].Location__c = locationList[0].Id;
            childAssts[0].Acorn_SID__c='1234';
            childAssts[0].Category__c ='(WAL_SP) Special Project';
            childAssts[0].Equipment_Owner__c='Unknown';
            childAssts[0].Sensitivity_Code__c='CAM';
            childAssts[0].CPQ_Product__c = prod_OpenTop.Id;
            childAssts[0].Start_Date__c = Date.Today()-7;
            childAssts[0].CPQ_Material__c = prodTrash.Id;
            childAssts[0].Frequency__c = 'W';//
            childAssts[0].Occurs__c = '1';	//TCS-pkulkarn-SDT-42068-Added to fix test class errors
            
            childAssts[1].Service_Header_Id__c  = OpenTop_Asset.Id;
            childAssts[1].ParentId = OpenTop_Asset.Id;
            childAssts[1].Location__c = locationList[0].Id;
            childAssts[1].CPQ_Product__c = prodHaul.Id;
            childAssts[1].Start_Date__c = Date.Today()-7;
            childAssts[1].CPQ_Material__c = prodTrash.Id;
            childAssts[1].Acorn_SID__c='1234';
            childAssts[1].Equipment_Owner__c='Unknown';
            childAssts[1].Sensitivity_Code__c='CAM'; 
            
            childAstHaul = TestDataFactory.createChildAsset('haulAsset');
            childAstHaul[0].Service_Header_Id__c = OpenTop_Asset.Id;
            childAstHaul[0].ParentId = OpenTop_Asset.Id;
            childAstHaul[0].Location__c = locationList[0].Id;
            childAstHaul[0].CPQ_Product__c = prodDisposal.Id;
            childAstHaul[0].Start_Date__c = Date.Today()-7;
            childAstHaul[0].CPQ_Material__c = prodTrash.Id;
            childAstHaul[0].Acorn_SID__c='1234';
            childAstHaul[0].Equipment_Owner__c='Unknown';
            childAstHaul[0].Sensitivity_Code__c='CAM';    
            //childAstHaul[0].Price_Model_Type__c = 'MRG';
            childAstHaul.remove(1);
            Database.insert(childAstHaul);
            
            //Update Asset case
            case cs = TestDataFactory.newServiceCase(Constant_Util.CONSTANT_FIRST, accList[0], conList[0], 
                                                     usr, locationList[0]);
            cs.Case_Type__c='Service Changes';
            cs.Case_Sub_Type__c='Customer Requested';
            cs.Case_Reason__c='';
            cs.Recordtypeid = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get(Constant_Util.UPDATE_ASSET_CASE).getRecordTypeId();
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
            UpdateAssetquoteList[0].SBQQ__Type__c='Amendment'; 
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
            sbqq.Occurrence_Type__c = 'OC';//SCH to OC
            sbqq.CostModelType__c = 'PER';
            sbqq.Cost_Unit_of_Measure__c = 'MTH';
            sbqq.PriceUOM__c = 'MTH';
            sbqq.Schedule_Frequency__c = 'W';
            sbqq.Service_Days__c = 'S1';
            sbqq.Frequency_Interval__c = '1';
            prodOptions.add(sbqq);
            
            SBQQ__ProductOption__c sbqq10 = new SBQQ__ProductOption__c();
            sbqq10.SBQQ__ConfiguredSKU__c = prod_OpenTop.Id;
            sbqq10.SBQQ__OptionalSKU__c = trashWC.Id;
            sbqq10.SBQQ__Number__c = 350;
            sbqq10.SBQQ__Quantity__c = 1;
            sbqq10.Occurrence_Type__c = 'OC';//SCH to OC
            sbqq10.CostModelType__c = 'PER';
            sbqq10.Cost_Unit_of_Measure__c = 'MTH';
            sbqq10.PriceUOM__c = 'MTH';
            sbqq10.Schedule_Frequency__c = 'W';
            sbqq.Service_Days__c = 'S1';
            sbqq10.Frequency_Interval__c = '1';
            prodOptions.add(sbqq10);
            
            SBQQ__ProductOption__c sbqq1 = new SBQQ__ProductOption__c();
            sbqq1.SBQQ__ConfiguredSKU__c = trashWC.Id;
            sbqq1.SBQQ__OptionalSKU__c = prodTrash.Id;
            sbqq1.SBQQ__Number__c = 350;
            sbqq1.SBQQ__Quantity__c = 1;
            sbqq1.Occurrence_Type__c = 'OC';//SCH to OC
            sbqq1.CostModelType__c = 'PER';
            sbqq1.Cost_Unit_of_Measure__c = 'MTH';
            sbqq1.PriceUOM__c = 'MTH';
            sbqq1.Schedule_Frequency__c = 'W';
            sbqq.Service_Days__c = 'S1';
            sbqq1.Frequency_Interval__c = '1';
            prodOptions.add(sbqq1);
            
            insert prodOptions;
            
            MAS_Setup_Detail__c mas = new MAS_Setup_Detail__c();
            mas.MAS_Line_of_Business__c = 'O';
            mas.MAS_Library__c = 'ARDTA.129A';
            mas.Business_Unit_Number__c = '286';
            mas.MAS_Company_Code__c = '286';
            mas.Bypass_Price_Review__c = false;
            insert mas;
        }
    }  
    
    
    /*******
@ Comment : Scenarios from UI - QuoteProcurementController.createDelivery()
*******/
    
    /*
* @MethodName    testCreateDeliveryForUpdateBaselineScenarios
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to asset start date for update baseline scenarios 
*/
    @isTest public static void testCreateDeliveryForUpdateBaselineScenarios() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            
            //inserting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__Product__c,AssetId__c,AssetId__r.Name,CompanyProjectName__c,SBQQ__StartDate__c,SBQQ__RequiredBy__c,
                                              SBQQ__Product__r.Name,Occurrence_Type__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            for(SBQQ__QuoteLine__c QL: qlList){
                System.debug(QL.SBQQ__Product__r.Name+'prodname'+QL.AssetId__r.Name+QL.AssetId__c);
                QL.Ownership__c = 'CLT';//ownership change for scenario
                QL.CompanyCategoryName__c = 'Test category';//company category change for scenario
                QL.VCRCode__c = 'IPI';//VCR code change for scenario
                QL.SBQQ__EndDate__c = null;//end date to null for scenario
                
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exception_Type__c,Exception_Reason__c,Exception_Comments__c, SBQQ__StartDate__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion updated as ScheduleAOverride__c update is added as part of End and Extend scenario. - //Changes related to Sprint 10 test class errors
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, System.today());
        }    
    }  
    
    /*
* @MethodName    testCreateDeliveryForOccurrenceType
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when occurrence type is changed - end and new
*/
    @isTest public static void testCreateDeliveryForOccurrenceType() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        Set<String> prodNames = new Set<String>{'Open Top'};
            SBQQ__QuoteLine__c parentQL;
        System.runAs(adminUSR){
            test.startTest();
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__Product__c,AssetId__c,SBQQ__RequiredBy__c,CompanyProjectName__c,SBQQ__StartDate__c,SBQQ__Product__r.Name,Occurrence_Type__c 
                                              FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.Occurrence_Type__c = 'SOC';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,Exception_Type__c,Exception_Reason__c,Exception_Comments__c, SBQQ__StartDate__c, SBQQ__Product__r.Name
                                                       from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteRec.Id AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }   
    } 
    
    /*
* @MethodName    testCreateDeliveryForsCode
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when sCode is changed - end and new
*/
    @isTest public static void testCreateDeliveryForsCode() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        Set<String> prodNames = new Set<String>{'Open Top'};
            SBQQ__QuoteLine__c parentQL;
        test.startTest();
        
        system.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__Product__c,CompanyProjectName__c,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__Product__r.Name,Occurrence_Type__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            
            for(SBQQ__QuoteLine__c QL: qlList){
                //changes by av4 on 28/12/2023
                //OGIT is changed to CTY
                QL.sCode__c = 'CTY';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }
    } 
    
    /*
* @MethodName    testCreateDeliveryForQuantity
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when Quantity is changed - end and new
*/
    @isTest public static void testCreateDeliveryForQuantity() {                     
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        Set<String> prodNames = new Set<String>{'Open Top'};
            SBQQ__QuoteLine__c parentQL;   
              Test.startTest(); 
        system.runAs(adminUSR){
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        //querying update asset case
        Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
        Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
        Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
        Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
        //querying update asset quote
        SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
        
        //getting quoteline records
        system.debug('SOQL before starttest '+ Limits.getQueries());
        
        String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
        List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__Quantity__c FROM SBQQ__QuoteLine__c 
                                          WHERE SBQQ__Quote__c =:quoteRec.Id];
        
        for(SBQQ__QuoteLine__c QL: qlList){
            QL.SBQQ__Quantity__c = 2;
            if(QL.SBQQ__RequiredBy__c == null){
                parentQL = QL;
            }
        }
        update qlList;  
      
        
        //creating wrapper object to pass values to the method
        QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
       
        system.debug('SOQL before stopttest '+ Limits.getQueries());
        RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
        
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
        //Test.stopTest();
        Test.stopTest();
        List<SBQQ__QuoteLine__c> qlListForQuote = [select Id, SBQQ__StartDate__c from
                                                   SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                   AND SBQQ__Product__r.Name IN :prodNames];
        
        //assertion 
        System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today()); 
        }    
    } 
    
    /*
* @MethodName    testCreateDeliveryForEquipmentSize
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when Equipment size is changed - end and extend
*/
    @isTest public static void testCreateDeliveryForEquipmentSize() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.Equipment_Size__c = 'YRDS-20';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id, SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }
        
        
    } 
    
    /*
* @MethodName    testCreateDeliveryForUnitCost
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when Unit cost is changed - end and extend
*/
    @isTest public static void testCreateDeliveryForUnitCost() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '4 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.SBQQ__UnitCost__c = 10;
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }
        
    } 
    
    /*
* @MethodName    testCreateDeliveryForCostUOM
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when Cost UOM is changed - end and extend
*/
    @isTest public static void testCreateDeliveryForCostUOM() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.Cost_Unit_of_Measure__c = 'HR';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }
        
    } 
    
    /*
* @MethodName    testCreateDeliveryForCostMinimumQuantity
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when Cost minimum quantity is changed - end and extend
*/
    @isTest public static void testCreateDeliveryForCostMinimumQuantity() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Disposal'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            System.debug(asset.Start_Date__c+'startdate');
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__Product__r.Name,SBQQ__StartDate__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){            
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
                else if(QL.SBQQ__Product__r.Name =='Disposal'){
                    QL.CostMinQuantity__c = 10;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id, SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }      
    } 
    
    /*
* @MethodName    testCreateDeliveryForListPrice
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when List Price is changed - end and extend
*/
    @isTest public static void testCreateDeliveryForListPrice() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Disposal'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.SBQQ__ListPrice__c = 10;
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
                
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }
    } 
    
    /*
* @MethodName    testCreateDeliveryForPriceUOM
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when Price Unit of Measurement is changed - end and extend
*/
    @isTest public static void testCreateDeliveryForPriceUOM() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.PriceUOM__c = 'GL';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today()); 
        }
        
    } 
    
    /*
* @MethodName    testCreateDeliveryForPriceMinimumQuantity
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to today when Price Minimum Quantity is changed - end and extend
*/
    @isTest public static void testCreateDeliveryForPriceMinimumQuantity() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Disposal'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c,SBQQ__StartDate__c,SBQQ__Product__r.Name FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
                else if(QL.SBQQ__Product__r.Name =='Disposal'){
                    QL.PriceMinQuantity__c = 4;
                }
                
            }
            update qlList;
            
            //creating wrapper object to pass values to the method
            QuoteProcurementController.OrderWrapper classWrapper = createOrderWrapper(parentQL.Id, quoteRec.Id);
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            QuoteProcurementController.QuoteSummaryWrapper wrapper = QuoteProcurementController.createDelivery(classWrapper, 'Delivery','test');
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, system.today());
        }
    }  
    
    
    /*******
@ Comment : Scenarios from trigger : on quote status update - QuoteTriggerHelper.CheckAndUpdateDateOnStatusChange()
*******/
    
    /*
* @MethodName    testTriggerForUpdateBaselineScenarios
* @Author        TCS
* @Description	  testing if the quoteline start date is changed to asset start date for update baseline scenarios 
*/
    @isTest public static void testTriggerForUpdateBaselineScenarios() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__Product__c,AssetId__c,CompanyProjectName__c,SBQQ__StartDate__c,SBQQ__RequiredBy__c,
                                              SBQQ__Product__r.Name,Occurrence_Type__c FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.Ownership__c = 'CLT';//ownership change for scenario
                QL.CompanyCategoryName__c = 'Test category';//company category change for scenario
                QL.VCRCode__c = 'IPI';//VCR code change for scenario
                QL.SBQQ__EndDate__c = null;//end date to null for scenario
                //QL.Schedule_Frequency__c = 'M';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from SBQQ__QuoteLine__c 
                                                       where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN:prodNames];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, asset.Start_Date__c);
        }
        
    }  
    
    /*
* @MethodName    testTriggerForOccurrenceType
* @Author        TCS
* @Description	  testing if the quote customer request date and vendor commit date is changed to today + 7 when occurrence type is changed - end and new
*/
    @isTest public static void testTriggerForOccurrenceType() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c];
            System.debug(qlList.size());
            for(SBQQ__QuoteLine__c QL: qlList){
                if(QL.SBQQ__RequiredBy__c == null){
                    QL.Occurrence_Type__c = 'SOC';
                    parentQL = QL;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        }
    }  
    
    /*
* @MethodName    testTriggerForsCode
* @Author        TCS
* @Description	  testing if the quote line customer request date and vendor commit date is changed to today + 7 when sCode is changed - end and new
*/
    @isTest public static void testTriggerForsCode() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c> qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c,
                                               sCode__c FROM SBQQ__QuoteLine__c 
                                               WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.sCode__c = 'RCPT';
                QL.Schedule_Frequency__c = 'W';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                    
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7); 
        }
        
    }
    
    /*
* @MethodName    testTriggerForQuantity
* @Author        TCS
* @Description	  testing if the testing if the quote customer request date and vendor commit date is changed to today + 7 when Quantity is changed - end and new
*/
    @isTest public static void testTriggerForQuantity() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c 
                                       Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.SBQQ__Quantity__c = 2;
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        }
        
    } 
    
    /*
* @MethodName    testTriggerForEquipmentSize
* @Author        TCS
* @Description	  testing if the quote customer request date and vendor commit date is changed to today + 7 when Equipment size is changed - end and extend
*/
    @isTest public static void testTriggerForEquipmentSize() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top','Pickup'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.Equipment_Size__c = 'YRDS-20';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        }
        
        
    } 
    
    /*
* @MethodName    testTriggerForUnitCost
* @Author        TCS
* @Description	  testing if the quote customer request date and vendor commit date is changed to today + 7 when Unit Cost is changed - end and extend
*/
    @isTest public static void testTriggerForUnitCost() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.SBQQ__UnitCost__c = 10;
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        }
    } 
    
    /*
* @MethodName    testTriggerForCostUOM
* @Author        TCS
* @Description	  testing if the quote customer request date and vendor commit date is changed to today + 7 when cost UOM is changed - end and extend
*/
    @isTest public static void testTriggerForCostUOM() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.Cost_Unit_of_Measure__c = 'HR';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7); 
        }
        
    } 
    
    /*
* @MethodName    testTriggerForCostMinimumQuantity
* @Author        TCS
* @Description	  testing if the quoteline customer request date and vendor commit date is changed to today + 7 when Cost Minimum is changed - end and extend
*/
    @isTest public static void testTriggerForCostMinimumQuantity() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Disposal'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__Product__r.Name,SBQQ__StartDate__c,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
                else if(QL.SBQQ__Product__r.Name =='Disposal'){
                    QL.CostMinQuantity__c = 10;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id, SBQQ__StartDate__c from SBQQ__QuoteLine__c 
                                                       where SBQQ__Quote__c=:quoteRec.Id AND SBQQ__Product__r.Name ='Disposal'];
            //assertion
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        }
    } 
    
    /*
* @MethodName    testTriggerListPrice
* @Author        TCS
* @Description	  testing if the quote customer request date and vendor commit date is changed to today + 7 when List Price is changed - end and extend
*/
    @isTest public static void testTriggerListPrice() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.SBQQ__ListPrice__c = 10;
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        }
        
    } 
    
    /*
* @MethodName    testTriggerForPriceUOM
* @Author        TCS
* @Description	  testing if the customer request date and vendor commit date is changed to today + 7 when Price Unit of Measurement is changed - end and extend
*/
    @isTest public static void testTriggerForPriceUOM() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Open Top'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                QL.PriceUOM__c = 'GL';
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id,SBQQ__StartDate__c from
                                                       SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteRec.Id 
                                                       AND SBQQ__Product__r.Name IN :prodNames];
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        }
        
    } 
    
    /*
* @MethodName    testTriggerForPriceMinimumQuantity
* @Author        TCS
* @Description	  testing if the quote start date is changed to today + 7 when Price Minimum Quantity is changed - end and extend
*/
    @isTest public static void testTriggerForPriceMinimumQuantity() {
        User adminUSR = [SELECT Id, Bypass_Validation__c FROM User WHERE Profile.Name = :SYS_ADMIN AND IsActive = true 
                         AND FirstName =: 'testuser#9999' LIMIT 1];
        SBQQ__QuoteLine__c parentQL;
        Set<String> prodNames = new Set<String>{'Disposal'};
            test.startTest();
        System.runAs(adminUSR){
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            //querying update asset case
            Case caseRec = [SELECT Id from Case WHERE Case_Type__c = 'Service Changes' LIMIT 1];
            Asset asset= [SELECT Id, Duration__c,Start_Date__c from Asset WHERE Name = 'OpenTop_Asset'];
            Product2 product= [SELECT Id  FROM Product2 WHERE Name = 'Open Top' LIMIT 1];
            Product2 product1= [SELECT Id FROM Product2 WHERE Family = 'Waste Stream' LIMIT 1];
            //querying update asset quote
            SBQQ__Quote__c quoteRec = [SELECT Id,Case__c,SBQQ__StartDate__c from SBQQ__Quote__c Where SBQQ__Type__c ='Amendment' LIMIT 1];
            
            //getting quoteline records
            String quotelineResponse = AssetQuoteProcurementController.createAssetQuoteLines(asset.Id, quoteRec.Id, product.Id, product1.Id, '30 Yards');
            //getting parentQL and updating
            List<SBQQ__QuoteLine__c>qlList = [Select Id,SBQQ__StartDate__c,SBQQ__RequiredBy__c,SBQQ__Product__r.Name
                                              FROM SBQQ__QuoteLine__c 
                                              WHERE SBQQ__Quote__c =:quoteRec.Id];
            
            for(SBQQ__QuoteLine__c QL: qlList){
                if(QL.SBQQ__RequiredBy__c == null){
                    parentQL = QL;
                }
                else if(QL.SBQQ__Product__r.Name =='Disposal'){
                    QL.PriceMinQuantity__c = 4;
                }
            }
            update qlList;
            
            //updating quote status
            quoteRec.SBQQ__Status__c = 'Product Configured';
            update quoteRec;
            
            RecurrsiveTriggerHandler.isRecurrsiveQuoteLine= true;
            
            if(SBQQ.TriggerControl.isEnabled()){
                SBQQ.TriggerControl.disable();
            }
            
            Test.stopTest();
            List<SBQQ__QuoteLine__c> qlListForQuote = [select Id, SBQQ__StartDate__c,Quote_SLA_Date__c from SBQQ__QuoteLine__c where
                                                       SBQQ__Quote__c=:quoteRec.Id AND SBQQ__Product__r.Name = 'Disposal'];
            
            //assertion 
            System.assertEquals(qlListForQuote[0].SBQQ__StartDate__c, Date.Today() + 7);
        } 
    } 
    
    
    
    
    
    //Method to create QuoteProcurementController.OrderWrapper object
    private static QuoteProcurementController.OrderWrapper createOrderWrapper(Id parentQLId, Id quoteRecId) {
        QuoteProcurementController.OrderWrapper classWrapper = QuoteProcurementController.generateOrderWrapper();
        classWrapper.parentQuoteLine = parentQLId;
        classWrapper.serviceDate = system.today();
        classWrapper.serviceType = 'Delivery';
        classWrapper.quantity = 1;
        classWrapper.onsiteContact = 'Test Contact';
        classWrapper.onsitePhone = '1111111111';
        classWrapper.PONumber = '1111111';
        classWrapper.duration = 'TEMP';
        classWrapper.quoteId = quoteRecId;
        
        return classWrapper;
        
    }
    
}
