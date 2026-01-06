/*
Author: Rishiraj Singh
Requirement Id/Story: SDT-21793
FC: Rahul Rana
Module: Asset Management/Quote Summary on Case Page
--------------------------------------------------------------------
Description: test class for GetQuoteSummary.
*/

@isTest
public class GetQuoteSummaryTest {
    @testSetup
    public static void setupData() {
        Profile p= TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.CPQ_Active_User__c =true;
        insert usr;
        List<Account> accList;
        List<Account> locationList;
        List<Contact> conList;
        List<Case> caseList;
        List<Opportunity> oppList;
        List<Product2> prodList= new List<Product2>();
        List<Pricebookentry> pbeList= new List<Pricebookentry>();
        SBQQ__ProductOption__c option;
        SBQQ__ProductOption__c option1;
        SBQQ__ProductOption__c option2;
        Asset asst;
        Product2 trash;
        Product2 trash2;
        System.runAs(usr){
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();
            
            accList= TestDataFactory.createAccount('TestParentAccountTest', usr,'Client');
            insert accList;
            locationList= TestDataFactory.createLocation('TestLocationAccountTest', usr,accList[0].Id);
            insert locationList;
            conList= TestDataFactory.createContact('TestContactTest', 'TestContactTest', accList[0], usr);
            conList[0].Email= 'testemail'+ String.valueof(system.now().millisecond())+'@testorg1.com.wm';
            conList[0].Phone= '1890870468';
            insert conList;
            Product2 prodOT = TestDataFactory.createProduct('Open Top','Equipment','OT');
            prodOT.Bypass_Acorn_Integration__c= false;

            trash = new Product2();
            trash.Name = 'Trash';
            trash.ProductCode = 'T_WC';
            trash.Family = 'Waste Category';
            trash.IsActive = true;
            trash.SBQQ__ExcludeFromOpportunity__c = true;
            prodList.add(trash);
            
            trash2 = new Product2();
            trash2.Name = 'Trash';
            trash2.ProductCode = 'T';
            trash2.Family = 'Waste Stream';
            trash2.IsActive = true;
            trash2.SBQQ__ExcludeFromOpportunity__c = true;
            prodList.add(trash2);
            Product2 prod = TestDataFactory.createProduct('Delivery','Services','DLV');
            Product2 prod1 = TestDataFactory.createProduct('Pickup','Services','PCK');
            Product2 prod2 =TestDataFactory.createProduct('Removal','Services','REM');
            //Product2 prod3 = TestDataFactory.createProduct('Extra Pickup','Services','PCK');
            prodList.add(prodOT);
            prodList.add(prod);
            prodList.add(prod1);
            prodList.add(prod2);
            //prodList.add(prod3);
            insert prodList;
            
            // Inserting Asset
            asst = TestDataFactory.createAsset('Test Asset', accList[0],conList[0], prodOT, usr,locationList[0])[0];
            List<Project_Code__c> pCodeList=TestDataFactory.createProjectCode(accList[0].Id);//seema
            insert pCodeList;
            asst.Quantity__c=5;
            asst.Project_Code__c=pCodeList[0].Id;//seema
            asst.Duration__c = '';
            asst.Acorn_SID__c='1234';
            asst.Category__c ='(WAL_SP) Special Project';asst.Equipment_Owner__c='Unknown';
            asst.Sensitivity_Code__c='CAM';
            Database.insert(asst);
            
            Pricebookentry pbeObjOT= new Pricebookentry(Product2Id = prodOT.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj1= new Pricebookentry(Product2Id = prod.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj2= new Pricebookentry(Product2Id = prod1.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj3= new Pricebookentry(Product2Id = prod2.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj4= new Pricebookentry(Product2Id = trash.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            Pricebookentry pbeObj5= new Pricebookentry(Product2Id = trash2.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
            pbeList.add(pbeObjOT);
            pbeList.add(pbeObj1);
            pbeList.add(pbeObj2);
            pbeList.add(pbeObj3);
            pbeList.add(pbeObj4);
            pbeList.add(pbeObj5);
            insert pbeList;
            
            List<SBQQ__ProductFeature__c> prodFeatureList= new List<SBQQ__ProductFeature__c>();
        	//Inserting product feature ---
            SBQQ__ProductFeature__c feature = new SBQQ__ProductFeature__c();
            feature.Name = 'Standard Services';
            feature.SBQQ__MinOptionCount__c = 1;
            feature.SBQQ__MaxOptionCount__c = 1;
            feature.SBQQ__Number__c = 10;
            feature.SBQQ__ConfiguredSKU__c = prodOT.Id;
            feature.SBQQ__Category__c = 'Services';
            prodFeatureList.add(feature);
            
            SBQQ__ProductFeature__c featureOne = new SBQQ__ProductFeature__c();
            featureOne.Name = 'Waste Stream';
            featureOne.SBQQ__MinOptionCount__c = 1;
            featureOne.SBQQ__MaxOptionCount__c = 1;
            featureOne.SBQQ__Number__c = 10;
            featureOne.SBQQ__ConfiguredSKU__c = prodOT.id;
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
                
            insert prodFeatureList;
            
            List<SBQQ__ProductOption__c>  prodOptionList= new List<SBQQ__ProductOption__c>();
            //inserting Product Option --
            option = new SBQQ__ProductOption__c();
            option.SBQQ__Number__c = 1;
            option.SBQQ__ConfiguredSKU__c = prodOT.id;
            option.SBQQ__Quantity__c = 1;
            option.SBQQ__OptionalSKU__c = trash.id;
            option.SBQQ__Feature__c = featureOne.id;
            option.SBQQ__Bundled__c = true;
            prodOptionList.add(option); 
            
           //inserting Product Option --
            option1 = new SBQQ__ProductOption__c();
            option1.SBQQ__Number__c = 1;
            option1.SBQQ__ConfiguredSKU__c = trash.id;
            option1.SBQQ__Quantity__c = 1;
            option1.SBQQ__OptionalSKU__c = trash2.id;
            option1.SBQQ__Feature__c = featureTwo.id;
            option1.SBQQ__Bundled__c = true;
            prodOptionList.add(option1);
            
            option2 = new SBQQ__ProductOption__c();
            option2.SBQQ__Number__c = 1;
            option2.SBQQ__ConfiguredSKU__c = prodOT.id;
            option2.SBQQ__Quantity__c = 1;
            option2.SBQQ__OptionalSKU__c = prod.id;
            option2.SBQQ__Feature__c = feature.id;
            option2.SBQQ__Bundled__c = true;
            prodOptionList.add(option2);
            
            Database.insert(prodOptionList);
        }
        List<SBQQ__Quote__c> quoteList= new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQl= new SBQQ__QuoteLine__c();
        Profile prfl = [SELECT Id FROM Profile WHERE Name = 'Customer Service'];
        User usrObj= TestDataFactory.createUser(prfl); 
        usrObj.CPQ_Active_User__c =true;
        insert usrObj;
        List<PermissionSetLicense> pslList= [SELECT Id FROM PermissionSetLicense WHERE DeveloperName = 'SalesforceCPQ_CPQStandardPerm' AND Status='Active'];
        insert new PermissionSetLicenseAssign(AssigneeId = usrObj.Id, PermissionSetLicenseId= pslList[0].Id);
        List<PermissionSet> psgList= [SELECT Id FROM PermissionSet WHERE Name = 'QuoteOrdersUser'];
        insert new PermissionSetAssignment(AssigneeId = usrObj.Id, PermissionSetId = psgList[0].id);
        System.runAs(usrObj){
            caseList= new List<Case>();
            oppList= new List<Opportunity>();
            caseList.add(TestDataFactory.newServiceCase('TestSiteTest'+1, accList[0], conList[0], usr, locationList[0]));
            insert caseList;
            oppList= TestDataFactory.createOpportunity(1,'TestOpportunityTest',caseList[0].Id,caseList[0].Case_Sub_Type__c, locationList[0].Id);
            insert oppList;
            quoteList= TestDataFactory.createQuoteRecords(1,oppList,accList[0],conList[0],Date.today(),false,false);
            insert quoteList;
            parentQl= TestDataFactory.createQuoteLineRecords(quoteList[0],prodList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            parentQl.LocationPositionName__c='Test Location';
            parentQl.SBQQ__StartDate__c= Date.today();
            parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
            parentQl.AssetId__c=asst.id;
            insert parentQl;
            //parentQlwithoutAsset= TestDataFactory.createQuoteLineRecords(quoteList[0],prodList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            //insert parentQlwithoutAsset;
            
            for(Integer i=0;i<3;i++){
                qlList.add(TestDataFactory.createQuoteLineRecords(quoteList[0],prodList[i+3],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
                qlList[i].SBQQ__StartDate__c= Date.today();
                qlList[i].SBQQ__EndDate__c= Date.today().addDays(25);
                qlList[i].SBQQ__RequiredBy__c= parentQl.Id;
                qlList[i].SBQQ__ProductOption__c= option2.Id;
            }
            
            SBQQ__QuoteLine__c ql = TestDataFactory.createQuoteLineRecords(quoteList[0],trash,'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
            ql.SBQQ__StartDate__c= Date.today();
            ql.SBQQ__EndDate__c= Date.today().addDays(25);
            ql.SBQQ__RequiredBy__c= parentQl.Id;
            ql.SBQQ__ProductOption__c= option1.Id;
            qlList.add(ql);
            insert qlList;
            
            Quote_Order__c qo = new Quote_Order__c();
            qo.Quote_Line__c= parentQl.id;
            qo.Service_Quote_Line__c= qlList[2].id;
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
            qo.Placement_Instructions__c = 'test';
            insert qo;
        }
    }
    @isTest
    public static void testMethods(){
        User usr= [SELECT Id FROM User LIMIT 1];
        Case c= [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        String str= GetQuoteSummary.getQuoteDetails(c.Id,usr.Id);
        system.assertNotEquals(str, null);
        system.debug('strIng is'+str);
                
        List<GetQuoteSummary.QuoteSummary> QuoteSummaryList =null;
        QuoteSummaryList = (List<GetQuoteSummary.QuoteSummary>) JSON.deserialize(str, List<GetQuoteSummary.QuoteSummary>.class);
        system.debug('QuoteSummary'+QuoteSummaryList);
        for(GetQuoteSummary.QuoteSummary quote : QuoteSummaryList){
            //GetQuoteSummary.QuoteSummary quoteS=new GetQuoteSummary.QuoteSummary();
            For(GetQuoteSummary.Bundle b : quote.bundleList){
                system.assertequals(false,b.requestServiceConfigObj.isUpdateAssetCase);
                //system.assertEquals(null,b.requestServiceConfigObj.originalQuantity);
                system.assertEquals(double.valueOf(5),b.requestServiceConfigObj.originalQuantity);

            }
        }
        SBQQ__Quote__c quoteRec= [SELECT Id,Name,SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c,SBQQ__Opportunity2__r.Case__r.AssetDetail__r.Quantity__c, Assigned_To__r.Name, toLabel(SBQQ__Status__c), Quote_Only__c,Project__r.Name,Project_Services_Request__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Case__c=:c.Id];
        /*List<SBQQ__QuoteLine__c> qlList= [SELECT Id,AssetId__r.Quantity__c,SBQQ__Quote__c,Service_Start_Time__c,Service_End_Time__c,Gate_Code__c,Restriction_Details__c,SBQQ__ProductName__c,SBQQ__ProductFamily__c,	SBQQ__ProductOption__r.SBQQ__Feature__r.Name,toLabel(Equipment_Size__c),SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,Description_of_Waste__c,Service_Schedule__c,LocationPositionName__c,Certificate_of_Disposal__c,Certificate_of_Destruction__c,Profile_Number__c,Landfill_Tickets__c,Special_Disposal_Description__c,Compactor_Type__c,Compactor_Size__c,Equipment_Style__c,toLabel(Service_Style__c),Equipment_Side_Doors__c,Type_of_Lid__c,Understructure__c,toLabel(Ownership__c),SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c
                                          WHERE SBQQ__Quote__c = :quoteRec.id and AssetId__c!=null];
        qlList[0].AssetId__c=null;
        update qlList;
        
        QuoteSummaryList =null;
        QuoteSummaryList = (List<GetQuoteSummary.QuoteSummary>) JSON.deserialize(str, List<GetQuoteSummary.QuoteSummary>.class);
        system.debug('QuoteSummary'+QuoteSummaryList);
        for(GetQuoteSummary.QuoteSummary quote : QuoteSummaryList){
            //GetQuoteSummary.QuoteSummary quoteS=new GetQuoteSummary.QuoteSummary();
            For(GetQuoteSummary.Bundle b : quote.bundleList){
                system.assertequals(false,b.requestServiceConfigObj.isUpdateAssetCase);
                system.assertEquals(null,b.requestServiceConfigObj.originalQuantity);
            }
        }*/
        //system.assertEquals(qlList[0].AssetId__r.Quantity__c,Decimal.valueof(5));
        Test.stopTest();
        
    }
    @isTest 
    public static void testPicklists() {
        
        List<String> picklist = GetQuoteSummary.getPicklistSchema();
        system.assertNotEquals(picklist, null);
        
    }
}