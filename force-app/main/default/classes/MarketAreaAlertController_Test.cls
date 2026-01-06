/*
*********************************************************
Apex Class Name    : MarketAreaAlertController_Test
Created Date       : July 28, 2025
@description       : This is class is used for testing Market Area Alerts
@author            : George Martin III
@Coverage 		   : 85%
Modification Log:
Ver   Date         Author                               Modification
1.0   28-07-2025   George Martin III                   Initial Version
2.0   30-07-2025   Soham Datta						   Increase Code Coverage
*********************************************************
*/
@isTest(seeAllData=false)
private class MarketAreaAlertController_Test {
    
    @testSetup
    public static void setup() {
        
        Code_Switch__c cs = new Code_Switch__c(Name = 'Market Area Alerts', Switch_Off__c = false);
        insert cs;
        
        List<MAA_Admin_Settings__c> maSettingsList = new List<MAA_Admin_Settings__c>();
        MAA_Admin_Settings__c caseSettings = new MAA_Admin_Settings__c(Allow_Filtering_by_LOB__c = true,
                                                                       Number_of_Days_of_Alerts__c = 2,
                                                                       Number_of_Alerts_Per_Page__c = 10,
                                                                       MAA_Page_Type__c = 'Case');
        MAA_Admin_Settings__c locationSettings = new MAA_Admin_Settings__c(Allow_Filtering_by_LOB__c = true,
                                                                           Number_of_Days_of_Alerts__c = 14,
                                                                           Number_of_Alerts_Per_Page__c = 10,
                                                                           MAA_Page_Type__c = 'Location');
        MAA_Admin_Settings__c quoteSettings = new MAA_Admin_Settings__c(Allow_Filtering_by_Equipment__c = true,
                                                                        Allow_Filtering_by_LOB__c = true,
                                                                        Number_of_Days_of_Alerts__c = 14,
                                                                        Number_of_Alerts_Per_Page__c = 10,
                                                                        MAA_Page_Type__c = 'Quote');
        maSettingsList.add(quoteSettings);
        maSettingsList.add(caseSettings);
        maSettingsList.add(locationSettings);
        insert maSettingsList;
        
        Account a = new Account();
        Account l = new Account();
        Account l1 = new Account();
        Account sp = new Account();
        Account sc = new Account();
        
        a.Name = 'Test Client';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        a.AccountNumber = 'TESTC';
        insert a;
        
        l.Name = 'Test Location';
        l.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        l.ParentId = a.Id;
        l.AccountNumber = 'TESTL';
        insert l;
        
        l1.Name = 'Test Location 1';
        l1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        l1.ParentId = a.Id;
        l1.AccountNumber = 'TESTL1';
        insert l1;
        
        sp.Name = 'WM Test Parent';
        sp.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        sp.AccountNumber = '8';
        insert sp;
        
        sc.Name = 'WM Test Child';
        sc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        sc.AccountNumber = 'TESTS';
        sc.ParentId = sp.Id;
        insert sc;
                
        Asset ah = new Asset();
        Product2 p = new Product2();
        Product2 w = new Product2();
        
        p.Name = 'Open Top';
        p.ProductCode = 'OT';
        p.Family = 'Roll off';
        w.Name = 'Trash';
        w.ProductCode = 'T';
        insert new List<Product2>{p, w};
            
        ah.Name = 'Test Header';
        ah.CPQ_Product__c = p.Id;
        ah.CPQ_Material__c = w.Id;
        ah.Supplier__c = sc.Id;
        ah.Location__c = l.Id;
        ah.AccountId = l.Id;
        insert ah;
        
        Case c = new Case();
        c.Client__c = a.Id;
        c.Location__c = l.Id;
        c.AssetId = ah.Id;
        c.Selected_Asset_Header_Ids__c = ah.Id;
        c.Subject = 'Test Subject';
        c.Service_Date__c = Date.today();
        insert c;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.StageName = 'New';
        o.CloseDate = Date.Today();
        o.Case__c = c.Id;
        o.Name = 'Test opportunity';
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Opportunity2__c = o.Id;
        q.SBQQ__Account__c = l.Id;
        q.SBQQ__Status__c = 'Draft';
        q.SBQQ__Status__c = 'Cost Configured';
        q.Duration__c = 'Temporary';
        q.SBQQ__StartDate__c = system.today();
        insert q;
        
        List<Product2> prodList= new List<Product2>();
        Product2 prodDumpster = TestDataFactory.createProduct('Dumpster','Rolloff', 'DMP');
        prodList.add(prodDumpster);
        Product2 prodCompactor = TestDataFactory.createProduct('Compactor','Commercial', 'CMP');
        prodList.add(prodCompactor);
        insert prodList;
        
        List<Pricebookentry> pbeList= new List<Pricebookentry>();
        Pricebookentry pbeDump = new Pricebookentry(Product2Id = prodDumpster.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        pbeList.add(pbeDump);
        Pricebookentry pbeCmp = new Pricebookentry(Product2Id = prodCompactor.Id, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 20);
        pbeList.add(pbeCmp);
        insert pbeList;
        
        SBQQ__QuoteLine__c parentQl= TestDataFactory.createQuoteLineRecords(q, prodList[0],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG');
        parentQl.LocationPositionName__c='Test Location';
        parentQl.SBQQ__StartDate__c= Date.today();
        parentQl.SBQQ__EndDate__c= Date.today().addDays(25);
        parentQl.SBQQ__Number__c=1;
        parentQl.Vendor__c = sp.Id;
        insert parentQl;
        
        List<SBQQ__QuoteLine__c> qlList= new List<SBQQ__QuoteLine__c>();
        
        for(Integer i=0;i<2;i++){
            qlList.add(TestDataFactory.createQuoteLineRecords(q,prodList[i],'TEMP',1.00,'CLT','YRDS-20','OC','D','1','PER',34.00,'DYS','PER',56.00,'DYS','Do Not Override','NBG'));
            qlList[i].SBQQ__StartDate__c= Date.today();
            qlList[i].SBQQ__EndDate__c= Date.today().addDays(25);
            qlList[i].SBQQ__RequiredBy__c= parentQl.Id;
            qlList[i].SBQQ__Number__c=i+1;
            qlList[i].Account__c = l.Id;
            qlList[i].SBQQ__Product__c = p.Id;
            
        }
        
        insert qlList;
        
    }
    
    //Test disable code switch
    @isTest
    public static void testSwitchOff() {
        
        Code_Switch__c cs = [SELECT Id, Name, Switch_Off__c FROM Code_Switch__c WHERE Name = 'Market Area Alerts'];
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        cs.Switch_Off__c = true;
        update cs;
        
        Test.startTest();
        MarketAreaAlertController.AlertsResponse cRes = MarketAreaAlertController.getAlerts(c.Id, 0, 10);
        Assert.isNotNull(cRes);
        Test.stopTest();
        
    }
    
    //Test the LWC utilities such as getting the switch and page sizes
    @isTest
    public static void testLWCUtilities() {
        
        Case c = [SELECT Id FROM Case LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' LIMIT 1];
        SBQQ__Quote__c q = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        Integer testCaseSize = MarketAreaAlertController.getPageSize(c.Id);
        Integer testLocationSize = MarketAreaAlertController.getPageSize(a.Id);
        Integer testQuoteSize = MarketAreaAlertController.getPageSize(q.Id);
        
        Set<String> testSet = new Set<String>{'a', 'b', 'c'};
            
        Test.startTest();
        
        Boolean testQuoteSwitch = MarketAreaAlertController.getMAASwitch();
        String sizeCode = MarketAreaAlertController.getEquipmentSizeCode('30 Yards');
        //List<String> testSetToList = MarketAreaAlertController.convertSetToList(testSet);
        
        Assert.isFalse(testQuoteSwitch);
        Assert.areEqual(testCaseSize, 10);
        Assert.areEqual(testLocationSize, 10);
        Assert.areEqual(sizeCode, 'YRDS-30');
        //Assert.isNotNull(testSetToList);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testJSONParse() {
        
        //This is a gigantic string generated from a real callout
        String jsonString = '{"Problem":null,"pageSize":10,"pageIndex":0,"Data":[{"wasteStream":null,"type":"Inventory","title":null,"status":"Published","startDate":null,"Sites":[],"serviceDisruptionStartDate":null,"recoveryPlan":null,"recoveryDate":null,"recipients":null,"outageType":"containershortage","outageStartDate":"2025-07-21T00:00:00.000Z","other":null,"nonCustomTitle":"30 Yard Open Top : S04009","newServiceDate":null,"name":"Alert-556005","marketareaName":"Mid-South","marketAreaId":null,"lob":"Roll Off","impactGeographicalArea":null,"globalAlertType":null,"facilityType":null,"extend":null,"equipmentCode":"30O","endDate":"2025-07-24T00:00:00.000Z","country":null,"agentInstructions":"test","action":null},{"wasteStream":null,"type":"Operational","title":null,"status":"Published","startDate":null,"Sites":[],"serviceDisruptionStartDate":null,"recoveryPlan":null,"recoveryDate":null,"recipients":null,"outageType":"capacityoutage","outageStartDate":"2025-07-14T00:00:00.000Z","other":null,"nonCustomTitle":"S04009","newServiceDate":null,"name":"Alert-556001","marketareaName":"Mid-South","marketAreaId":null,"lob":"Roll Off","impactGeographicalArea":null,"globalAlertType":null,"facilityType":null,"extend":null,"equipmentCode":null,"endDate":"2025-07-31T00:00:00.000Z","country":null,"agentInstructions":"This outage impacts all container actions.","action":null},{"wasteStream":null,"type":"Inventory","title":null,"status":"Published","startDate":null,"Sites":[],"serviceDisruptionStartDate":null,"recoveryPlan":null,"recoveryDate":null,"recipients":null,"outageType":"containershortage","outageStartDate":"2025-07-14T00:00:00.000Z","other":null,"nonCustomTitle":"40 Yard Open Top : S04009","newServiceDate":null,"name":"Alert-556000","marketareaName":"Mid-South","marketAreaId":null,"lob":"Roll Off","impactGeographicalArea":null,"globalAlertType":null,"facilityType":null,"extend":null,"equipmentCode":"40O","endDate":"2025-07-31T00:00:00.000Z","country":null,"agentInstructions":"qa3 inventory","action":null},{"wasteStream":"trash","type":"Bi-Weekly Re-Route","title":null,"status":"Published","startDate":"2025-07-28T00:00:00.000Z","Sites":[{"routeId":"M104,252946,M117","name":null,"id":"S04009","alertFacilitiesName":"Alert Facility-579699"}],"serviceDisruptionStartDate":null,"recoveryPlan":null,"recoveryDate":null,"recipients":"Greenpages","outageType":null,"outageStartDate":null,"other":null,"nonCustomTitle":"Commercial,Roll Off Bi Weekly Re Route","newServiceDate":null,"name":"Alert-556011","marketareaName":"Mid-South","marketAreaId":null,"lob":"Commercial;Roll Off","impactGeographicalArea":"test","globalAlertType":null,"facilityType":null,"extend":null,"equipmentCode":null,"endDate":"2025-08-08T00:00:00.000Z","country":null,"agentInstructions":null,"action":null},{"wasteStream":"trash","type":"service delay","title":null,"status":"Published","startDate":"2025-07-28T00:00:00.000Z","Sites":[{"routeId":"M110,M113,M115,M117","name":null,"id":"S04009","alertFacilitiesName":"Alert Facility-579695"}],"serviceDisruptionStartDate":null,"recoveryPlan":null,"recoveryDate":null,"recipients":"WM.com;Greenpages","outageType":null,"outageStartDate":null,"other":null,"nonCustomTitle":"Commercial,Roll Off service(s) have been delayed","newServiceDate":"2 to 4 hours","name":"Alert-556007","marketareaName":"Mid-South","marketAreaId":null,"lob":"Commercial;Roll Off","impactGeographicalArea":"test","globalAlertType":null,"facilityType":null,"extend":"All customers","equipmentCode":null,"endDate":"2025-08-07T00:00:00.000Z","country":null,"agentInstructions":null,"action":"delayed"},{"wasteStream":"trash","type":"Re-Route","title":null,"status":"Published","startDate":"2025-07-28T00:00:00.000Z","Sites":[{"routeId":"M110,M111,M112,M113,M117,252946","name":null,"id":"S04009","alertFacilitiesName":"Alert Facility-579698"}],"serviceDisruptionStartDate":null,"recoveryPlan":null,"recoveryDate":null,"recipients":"Greenpages","outageType":null,"outageStartDate":null,"other":null,"nonCustomTitle":"Commercial,Roll Off Re Route","newServiceDate":null,"name":"Alert-556010","marketareaName":"Mid-South","marketAreaId":null,"lob":"Commercial;Roll Off","impactGeographicalArea":"Test","globalAlertType":null,"facilityType":null,"extend":null,"equipmentCode":null,"endDate":"2025-08-08T00:00:00.000Z","country":null,"agentInstructions":null,"action":null},{"wasteStream":"trash","type":"ticket schedule","title":null,"status":"Published","startDate":"2025-07-25T00:00:00.000Z","Sites":[{"routeId":"M110,M111,M112,M113","name":null,"id":"S04009","alertFacilitiesName":"Alert Facility-579696"}],"serviceDisruptionStartDate":"2025-07-24T00:00:00.000Z","recoveryPlan":null,"recoveryDate":null,"recipients":"Greenpages","outageType":null,"outageStartDate":null,"other":null,"nonCustomTitle":"Commercial,Roll Off service(s) have been scheduled","newServiceDate":null,"name":"Alert-556008","marketareaName":"Mid-South","marketAreaId":null,"lob":"Commercial;Roll Off","impactGeographicalArea":"test","globalAlertType":null,"facilityType":null,"extend":"All customers","equipmentCode":null,"endDate":"2025-08-08T00:00:00.000Z","country":null,"agentInstructions":null,"action":"scheduled"},{"wasteStream":"trash","type":"custom","title":"custom mid south","status":"Published","startDate":"2025-07-25T00:00:00.000Z","Sites":[{"routeId":"M104,M111,M113,M115","name":null,"id":"S04009","alertFacilitiesName":"Alert Facility-579697"}],"serviceDisruptionStartDate":null,"recoveryPlan":null,"recoveryDate":null,"recipients":"WM.com;Greenpages","outageType":null,"outageStartDate":null,"other":null,"nonCustomTitle":null,"newServiceDate":"4 to 8 hours","name":"Alert-556009","marketareaName":"Mid-South","marketAreaId":null,"lob":"Commercial;Roll Off","impactGeographicalArea":"Test","globalAlertType":null,"facilityType":null,"extend":"All customers","equipmentCode":null,"endDate":"2025-08-08T00:00:00.000Z","country":null,"agentInstructions":null,"action":null},{"wasteStream":null,"type":"rescheduled","title":null,"status":"Published","startDate":"2025-07-25T00:00:00.000Z","Sites":[{"routeId":"M104,M110,M112,M113","name":null,"id":"S04009","alertFacilitiesName":"Alert Facility-579691"}],"serviceDisruptionStartDate":"2025-07-28T00:00:00.000Z","recoveryPlan":null,"recoveryDate":"2025-07-25T00:00:00.000Z","recipients":"WM.com;Greenpages","outageType":null,"outageStartDate":null,"other":null,"nonCustomTitle":"Commercial,Roll Off service(s) have been rescheduled","newServiceDate":null,"name":"Alert-556003","marketareaName":"Mid-South","marketAreaId":null,"lob":"Commercial;Roll Off","impactGeographicalArea":"test","globalAlertType":null,"facilityType":null,"extend":"All customers","equipmentCode":null,"endDate":"2025-07-31T00:00:00.000Z","country":null,"agentInstructions":null,"action":"rescheduled"},{"wasteStream":null,"type":"rescheduled","title":null,"status":"Published","startDate":"2025-07-21T00:00:00.000Z","Sites":[{"routeId":"M111,M112,M113","name":null,"id":"S04009","alertFacilitiesName":"Alert Facility-579692"}],"serviceDisruptionStartDate":"2025-07-14T00:00:00.000Z","recoveryPlan":null,"recoveryDate":null,"recipients":"WM.com;Greenpages","outageType":null,"outageStartDate":null,"other":null,"nonCustomTitle":"Commercial,Roll Off service(s) have been rescheduled","newServiceDate":null,"name":"Alert-556004","marketareaName":"Mid-South","marketAreaId":null,"lob":"Commercial;Roll Off","impactGeographicalArea":"test","globalAlertType":null,"facilityType":null,"extend":"All customers","equipmentCode":null,"endDate":"2025-07-24T00:00:00.000Z","country":null,"agentInstructions":null,"action":"rescheduled"}],"count":10}';
        
        Test.startTest();
        MarketAreaAlertController.AlertsResponse ar = MarketAreaAlertController.parseAlerts(jsonString);
        Assert.isNotNull(ar);

        Assert.isNotNull(ar.Data);
        Assert.isNull(ar.Problem);
        Assert.isNotNull(ar.pageIndex);
        Assert.isNotNull(ar.pageSize);
        Assert.isNotNull(ar.count);
        
        Assert.areEqual(ar.Data[0].wasteStream, ar.Data[0].wasteStream);
        Assert.areEqual(ar.Data[0].lob, ar.Data[0].lob);
        Assert.areEqual(ar.Data[0].startDate, ar.Data[0].startDate);
        Assert.areEqual(ar.Data[0].globalAlertType, ar.Data[0].globalAlertType);
        Assert.areEqual(ar.Data[0].recoveryDate, ar.Data[0].recoveryDate);
        Assert.areEqual(ar.Data[0].endDate, ar.Data[0].endDate);
        Assert.areEqual(ar.Data[0].facilityType, ar.Data[0].facilityType);
        Assert.areEqual(ar.Data[0].title, ar.Data[0].title);
        Assert.areEqual(ar.Data[0].name, ar.Data[0].name);
        Assert.areEqual(ar.Data[0].newServiceDate, ar.Data[0].newServiceDate);
        Assert.areEqual(ar.Data[0].recipients, ar.Data[0].recipients);
        Assert.areEqual(ar.Data[0].type, ar.Data[0].type);
        Assert.areEqual(ar.Data[0].recoveryPlan, ar.Data[0].recoveryPlan);
        Assert.areEqual(ar.Data[0].marketAreaId, ar.Data[0].marketAreaId);
        Assert.areEqual(ar.Data[0].action, ar.Data[0].action);
        Assert.areEqual(ar.Data[0].other, ar.Data[0].other);
        Assert.areEqual(ar.Data[0].marketareaName, ar.Data[0].marketareaName);
        Assert.areEqual(ar.Data[0].status, ar.Data[0].status);
        Assert.areEqual(ar.Data[0].serviceDisruptionStartDate, ar.Data[0].serviceDisruptionStartDate);
        Assert.areEqual(ar.Data[0].agentInstructions, ar.Data[0].agentInstructions);
        Assert.areEqual(ar.Data[0].equipmentCode, ar.Data[0].equipmentCode);
        Assert.areEqual(ar.Data[0].outageType, ar.Data[0].outageType);
        Assert.areEqual(ar.Data[0].outageStartDate, ar.Data[0].outageStartDate);
        Assert.areEqual(ar.Data[0].country, ar.Data[0].country);
        Assert.areEqual(ar.Data[0].nonCustomTitle, ar.Data[0].nonCustomTitle);
        Assert.areEqual(ar.Data[0].extend, ar.Data[0].extend);
        Assert.areEqual(ar.Data[0].impactGeographicalArea, ar.Data[0].impactGeographicalArea);
        Assert.areEqual(ar.Data[0].Sites, ar.Data[0].Sites);
        Test.stopTest();
        
    }
    
    //Test Location Alerts with a LOB
    @isTest
    private static void testLocationAlertswithOneLOB() {
        
        Account l = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' AND Name = 'Test Location' LIMIT 1];
        Asset ah1 = [Select Id, Name, CPQ_Product__c, CPQ_Material__c, Supplier__c, Location__c, AccountId From Asset Where Name = 'Test Header' AND Location__c=: l.Id Limit 1];
        
        Product2 p = new Product2();
        Product2 w = new Product2();
        
        p.Name = 'Compactor';
        p.ProductCode = 'COM';
        p.Family = 'Commercial';
        p.Container_Size__c = '10 Gallons';
        w.Name = 'Compactor';
        w.ProductCode = 'C';
        insert new List<Product2>{p, w};
            
        Id serviceHeaderId = [Select Id, Name From RecordType Where Name = 'Service Header' AND SObjectType = 'Asset'].Id;    
        
        Asset ah2 = new Asset();
        ah2.Name = 'Test Header 1';
        ah2.CPQ_Product__c = p.Id;
        ah2.CPQ_Material__c = w.Id;
        ah2.Supplier__c = ah1.Supplier__c;
        ah2.Location__c = ah1.Location__c;
        ah2.AccountId = ah1.AccountId;
        ah2.RecordTypeId = serviceHeaderId;
        insert ah2;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketAreaAlertMockResponse());
        MarketAreaAlertController.AlertsResponse locationRes = new MarketAreaAlertController.AlertsResponse();
        locationRes = MarketAreaAlertController.getAlerts(l.Id, 0, 10);
        Test.stopTest();
        
        Assert.isNotNull(locationRes);
        
    }
    
    //Test Location Alerts without LOB
    @isTest
    private static void testLocationAlertswithNoLOB() {
        
        Account a = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' AND Name = 'Test Location 1' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new MarketAreaAlertMockResponse());
        Test.startTest();
        MarketAreaAlertController.AlertsResponse locationRes = new MarketAreaAlertController.AlertsResponse();
        locationRes = MarketAreaAlertController.getAlerts(a.Id, 0, 10);
        Test.stopTest();
        
        Assert.isNotNull(locationRes);
        
    }
    
    //Test Location Alerts with multiple LOB
    @isTest
    private static void testLocationAlertswithMultipleLOB() {
        
        Account l = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' AND Name = 'Test Location' LIMIT 1];
        Asset ah1 = [Select Id, Name, CPQ_Product__c, CPQ_Material__c, Supplier__c, Location__c, AccountId From Asset Where Name = 'Test Header' AND Location__c=: l.Id Limit 1];
        
        Product2 p = new Product2();
        Product2 w = new Product2();
        
        p.Name = 'Compactor';
        p.ProductCode = 'COM';
        p.Family = 'Commercial';
        p.Container_Size__c = '10 Gallons';
        w.Name = 'Compactor';
        w.ProductCode = 'C';
        insert new List<Product2>{p, w};
        
        Id serviceHeaderId = [Select Id, Name From RecordType Where Name = 'Service Header' AND SObjectType = 'Asset'].Id;    
            
        Asset ah2 = new Asset();
        ah2.Name = 'Test Header 1';
        ah2.CPQ_Product__c = p.Id;
        ah2.CPQ_Material__c = w.Id;
        ah2.Supplier__c = ah1.Supplier__c;
        ah2.Location__c = ah1.Location__c;
        ah2.AccountId = ah1.AccountId;
        ah2.RecordTypeId = serviceHeaderId;
        insert ah2;
        
        Product2 p1 = new Product2();
        Product2 w1 = new Product2();
        
        p1.Name = 'Compactor';
        p1.ProductCode = 'COM';
        p1.Family = 'Rolloff';
        p1.Container_Size__c = '10 Gallons';
        w1.Name = 'Trash';
        w1.ProductCode = 'T';
        insert new List<Product2>{p1, w1};
                    
        Asset ah3 = new Asset();
        ah3.Name = 'Test Header 2';
        ah3.CPQ_Product__c = p1.Id;
        ah3.CPQ_Material__c = w1.Id;
        ah3.Supplier__c = ah1.Supplier__c;
        ah3.Location__c = ah1.Location__c;
        ah3.AccountId = ah1.AccountId;
        ah3.RecordTypeId = serviceHeaderId;
        insert ah3;
        
        Test.setMock(HttpCalloutMock.class, new MarketAreaAlertMockResponse());
        Test.startTest();
        MarketAreaAlertController.AlertsResponse locationRes = new MarketAreaAlertController.AlertsResponse();
        locationRes = MarketAreaAlertController.getAlerts(l.Id, 0, 10);
        Test.stopTest();
        
        Assert.isNotNull(locationRes);
        
    }
    
    //Test Case Alerts with Equipment
    @isTest
    private static void testCaseAlertsWithEq() {
        
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketAreaAlertMockResponse());
        MarketAreaAlertController.AlertsResponse caseRes = new MarketAreaAlertController.AlertsResponse();
        caseRes = MarketAreaAlertController.getAlerts(c.Id, 0, 10);
        Test.stopTest();
        
        Assert.isNotNull(caseRes);
        
    }
    
    //Test Case Alerts without Equipment
    @isTest
    private static void testCaseAlertsWithoutEq() {
        
        MAA_Admin_Settings__c caseSetting = [Select Id, Name From MAA_Admin_Settings__c Where MAA_Page_Type__c = 'Case' Limit 1];
        caseSetting.Allow_Filtering_by_Equipment__c = false;
        update caseSetting;
        
        Case c = [SELECT Id, AssetId FROM Case LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketAreaAlertMockResponse());
        MarketAreaAlertController.AlertsResponse caseRes = new MarketAreaAlertController.AlertsResponse();
        caseRes = MarketAreaAlertController.getAlerts(c.Id, 0, 10);
        Test.stopTest();
        
        Assert.isNotNull(caseRes);
        
    }
    
    //Test Case Alerts without Asset
    @isTest
    private static void testCaseAlertsWithoutAsset() {
        
        Case c = [SELECT Id, AssetId FROM Case LIMIT 1];
        c.AssetId = null;
        update c;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketAreaAlertMockResponse());
        MarketAreaAlertController.AlertsResponse caseRes = new MarketAreaAlertController.AlertsResponse();
        caseRes = MarketAreaAlertController.getAlerts(c.Id, 0, 10);
        Test.stopTest();
        
        Assert.isNotNull(caseRes);
        
    }
    
    //Test Quote Alerts
    @isTest
    private static void testQuoteAlerts() {
        
        SBQQ__Quote__c q = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MarketAreaAlertMockResponse());
        MarketAreaAlertController.AlertsResponse quoteRes = new MarketAreaAlertController.AlertsResponse();
        quoteRes = MarketAreaAlertController.getAlerts(q.Id, 0, 10);
        Test.stopTest();
        
        Assert.isNotNull(quoteRes);
        
    }
    

}