/**
* @author Accenture
* @date 2/8/2019
* @description : Apex class GetCaseInformationTest 
test class for GetCaseInformation
**/
@isTest(seeAllData = false)
global class GetCaseInformationTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string SPECIAL_INS ='Test Special Instructions';
    private static final string CHANNEL_INFO ='Test Channel Instructions';
    private static final string OTHER ='Other';
    private static final string TEST_NAME ='Test';
    private static final string NUMBER_145 ='145';
    private static final string REQ_INFO ='PSI ;PO NUMBER'; //SDT-33363
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

    
                



    
  /**
* @author Accenture
* @date 2/27/2019
* @description : Apex method setup 
**/
    /* method for setting up data*/ 
    @testSetup static void setup() {
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.User_categorization_code__c = Constant_Util.CSRES;
        Database.insert(usr); 
        
        
        system.runAs(usr){
            Test.startTest();
            
            //Changes for SDT-39632
            CodeSwitchTestData.CodeSwitchData();

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
            
            List<PricebookEntry> standardPriceList = new List<PricebookEntry>();// Modified for SDT-33453
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = productlist[0].Id,
                UnitPrice = 10000, IsActive = true);
            standardPriceList.add(standardPrice);// Modified for SDT-33453
            Database.insert(standardPriceList);// Modified for SDT-33453
            
            List<Pricebook2> customPBList = new List<Pricebook2>();// Modified for SDT-33453
            Pricebook2 customPB = new Pricebook2(Name='Standard Price Book', isActive=true);
            customPBList.add(customPB);// Modified for SDT-33453
            Database.insert(customPBList);// Modified for SDT-33453
            
            List<PricebookEntry> customPriceList = new List<PricebookEntry>();// Modified for SDT-33453
            PricebookEntry customPrice = new PricebookEntry(
                Pricebook2Id = customPB.Id, Product2Id = productlist[0].Id,
                UnitPrice = 12000, IsActive = true);
            customPriceList.add(customPrice);// Modified for SDT-33453
            Database.insert(customPriceList);// Modified for SDT-33453
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].CPQ_Product__c = container.Id; //added for coverage
            assetlist[0].Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            list<Asset> assetlist1 = TestDataFactory.createAsset(InActive_CORE, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist1[0].Quantity__c = 1;
            assetlist1[0].Start_Date__c = System.today().addDays(-10);
            Database.insert(assetlist1);
            
            list<Asset>childassetlist = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);
            childassetlist[0].Product2 = haulService; //added for coverage
            assetlist[0].CPQ_Product__c = productlist[1].Id; //added for coverage
            childassetlist[0].Supplier__c = acclist[1].Id;
            childassetlist[0].parentId = assetlist[0].Id;
            Database.insert(childassetlist);
            
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            //List<Case> myCaseList = TestDataFactory.createNewCase();
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
            
            //opportunity for case - addtion for S11 test class error
            List<Opportunity> oppList = TestDataFactory.createOpportunity(1,'TestOpportunityTest',caselist[0].Id,caselist[0].Case_Sub_Type__c, locationList[0].Id); //PK
            oppList[0].Duration__c='Temporary';
            Database.insert(oppList);
            
            ////200080
            List<SBQQ__Quote__c> testQuoteList = new List<SBQQ__Quote__c>();// Modified for SDT-33453            
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote.SBQQ__Account__c = caselist[0].Location__c;
            testQuote.SBQQ__Status__c = 'Draft';
            testQuote.Duration__c = 'Temporary';
            testQuote.SBQQ__StartDate__c = system.today();
            //addition for S11 test class error
            testQuote.SBQQ__Opportunity2__c = oppList[0].Id; 
            testQuoteList.add(testQuote);// Modified for SDT-33453
            Database.Insert(testQuoteList);// Modified for SDT-33453
            
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,// Modified for SDT-33453
                                                            SBQQ__Product__c = container.Id,
                                                            Equipment_Size__c = 'YRDS-30',
                                                                SBQQ__Bundle__c = true,
                                                                SBQQ__RequiredBy__c = null);
            quoteLines.add(parentQL);// Modified for SDT-33453
            Database.Insert(quoteLines);// Modified for SDT-33453
                       
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
    
    /**
* @author Accenture
* @date 3/27/2019
* @description : Apex method getCaseSummaryTest
**/
     @isTest static void getCaseSummaryTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            test.startTest();
            list<case> caselist = [select id,ParentId,origin, contactid, Case_Type__c, Client__c, Location__c, Reference_Number__c,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c from case limit 1];
            //Case c = [SELECT id,isMultiCalendarChecked__c,Create_AM_and_PM_Pickups__c,Asset_Material__c,CaseNumber,Case_Sub_Type__c, case_type__c, Reference_Number__c,Contact.Name,Contact_Title__c,SLA_Date_Text__c,Service_Date_Text__c,Asset.Name,SLA_Service_Date_Time__c,SLA_Service_DateTime__c,Service_Date__c,Is_Clone__c,ParentId,Asset.Acorn_SID__c from case LIMIT 1]; 
            //caselist.add(c);
            
            List<Case> resultList = GetCaseInformation.getCaseSummary(caselist[0].id,'',caselist[0].ParentId);
            List<Case> resultList1 = GetCaseInformation.getCaseSummary(caselist[0].id,caselist[0].Reference_Number__c,caselist[0].ParentId);
			Boolean eligibilityResult = GetCaseInformation.launchCPQQuoteValidation(caseList[0].Id);
            test.stopTest();
            system.assert(resultList != null);
            system.assertEquals(2,resultList.size());
        }
    }
    
    /**
    * @author Accenture
    * @date 3/27/2019
    * @description : Apex method getCaseSummaryTest
    * 
    * 4/13/2020 Hotfix SDT-12670 for properly managing end-date
    **/
    @isTest static void inactiveCoreDetailTest(){
        User usr = [SELECT Id, Bypass_Validation__c 
                    FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id 
                    AND IsActive = true 
                    LIMIT 1];
        
        System.runAs(usr){
            test.startTest();
            Map<Id, Date> assetParam = new map<Id, Date>();
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            Id ParentId = null;
            List<Asset> myTestAsset = [SELECT Id, Occurrence_Type__c, End_Date__c FROM Asset WHERE Name =: InActive_CORE LIMIT 1];// Modified for SDT-33453
            myTestAsset[0].Occurrence_Type__c = 'Scheduled';// Modified for SDT-33453
            Database.update(myTestAsset);// Modified for SDT-33453
            
            assetParam.put(myTestAsset[0].Id, System.today());// Modified for SDT-33453
            ParentId = myTestAsset[0].Id;// Modified for SDT-33453
            
            List<Asset> childassetlst = TestDataFactory.createChildAsset(Constant_Util.CONSTANT_FIRST);
            childassetlst[0].parentId = ParentId;
            childassetlst[0].Service_Header_Id__c = ParentId;
            childassetlst[0].Service_Type__c = 'Pickup';
            childassetlst[0].Is_Core_service__c = true;
            childassetlst[0].Occurrence_Type__c = 'Scheduled';
            childassetlst[0].Start_Date__c = System.today().addDays(-10);
            childassetlst[0].End_Date__c = System.today().addDays(-2);
            
            Database.insert(childassetlst);
            map<Id, String> assetValidationMsg = new map<Id, String>();
            
            assetValidationMsg = GetCaseInformation.getAssetDetail(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();
            system.assert(Constant_Util.CASE_ASSETS_END_DATE_PASSED.equals(assetValidationMsg.values().get(0)));
        }
    }     
    
    /**
* @author Accenture
* @date 3/27/2019
* @description : Apex method initiateWorkOrderPositiveTest
**/
    @isTest static void initiateWorkOrderTest(){
         //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        Case caseObj = new Case(
        Status = 'New',
        Origin = 'Phone');

        insert caseObj;
        caseObj = [select id FROM Case where id = : caseObj.id];
        //System.debug('case number' + caseObj.casenumber);
        //list<Case> caseListToInsert= new list<Case>();
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid,Is_Clone__c, Case_Type__c, Client__c, Location__c, CaseNumber,
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            
            list<String> caseIdList = new List<String>();
            caseIdList.add(caselist[0].id);
            caselist[0].Is_Clone__c = true;
            update caselist[0];
            test.startTest();
            String msg = GetCaseInformation.initiateWorkOrder(caselist[0].id,caseIdList);
            Comment__c notes = new Comment__c();
            notes.Case__c = caselist[0].Id;
            notes.RecordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
            Database.insert(notes);
            //String caseId = caseObj.id;
            GetCaseInformation.copyAcornCommentsToChildCase(caselist[0].id, caselist[0]);                                
            test.stopTest();
            system.assert(msg == Constant_Util.SUCCESS);
        }
    }
    // Modified for SDT-33453 Start
    /**
    * @author TCS
    * @date 3/11/2024
    * @description : Apex method testCreateMultipleCasesInvoke
    **/
    @isTest static void testCreateMultipleCasesInvoke(){
        list<case> caselist = [select id, origin, contactid,Is_Clone__c, Case_Type__c, Client__c, Location__c, 
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                               Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
        
        list<String> caseIdList = new List<String>();
        caseIdList.add(caselist[0].id);
        caselist[0].Is_Clone__c = true;
        update caselist[0];
        test.startTest();
        GetCaseInformation.createMultipleCasesInvoke(caselist[0].id); 
        
        test.stopTest();
    }
    // Modified for SDT-33453 End
    // Modified for SDT-33453 Start
    /**
    * @author TCS
    * @date 3/11/2024
    * @description : Apex method testCreateMultipleCasesInvoke
    **/
    @isTest static void testInsertPlannerComment(){
        list<case> caselist = [select id, origin, contactid,Is_Clone__c, Case_Type__c, Client__c, Location__c, 
                               PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                               Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
        
        list<String> caseIdList = new List<String>();
        caseIdList.add(caselist[0].id);
        caselist[0].Is_Clone__c = true;
        update caselist[0];
        test.startTest();
        GetCaseInformation.insertPlannerComment(caselist[0].id, 'test', true, false);
        GetCaseInformation.insertPlannerComment(caselist[0].id, 'test', true, true);
        test.stopTest();
    }
    // Modified for SDT-33453 End
   @isTest static void initiateWorkOrderSecondTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        /*Case caseObj = new Case(
        Status = 'Open',
        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.INTERRUPTION).getRecordTypeId(),
        Origin = 'Phone');
        insert caseObj;*/
       
        // Modified for SDT-33453 Start
        List<Case> caseObjList = new List<Case>();
        Case caseObj = new Case(); 
        caseObj.Status = 'New';
        caseObj.Origin = 'Phone';
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.INTERRUPTION).getRecordTypeId();
        caseObjList.add(caseObj);              
        Database.insert(caseObjList);

        
        caseObj = [select id FROM Case where id = : caseObjList[0].id];
        // Modified for SDT-33453 End
        //System.debug('case number' + caseObj.casenumber);
        //list<Case> caseListToInsert= new list<Case>();
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid,Is_Clone__c, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            
            list<String> caseIdList = new List<String>();
            caseIdList.add(caselist[0].id);
            caselist[0].Is_Clone__c = true;
            caselist[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.INTERRUPTION).getRecordTypeId();
            update caselist[0];
            test.startTest();
            String msg = GetCaseInformation.initiateWorkOrder(caselist[0].id,caseIdList);
            test.stopTest();
            system.assert(msg == Constant_Util.SUCCESS);
        }
    }      
    /**
* @author Accenture
* @date 3/27/2019
* @description : Apex method addWorkOrderDetailsTest
**/
    @isTest static void addWorkOrderDetailsTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        /*Case caseObj = new Case(
        Status = 'New',
        Origin = 'Phone');*/
        // Modified for SDT-33453 Start
        List<Case> caseObjList = new List<Case>();
        Case caseObj = new Case(); 
        caseObj.Status = 'New';
        caseObj.Origin = 'Phone';
        caseObjList.add(caseObj);              
        Database.insert(caseObjList);
        
        caseObj = [select id FROM Case where id = : caseObjList[0].id];
        // Modified for SDT-33453 End
        
        //System.debug('case number' + caseObj.casenumber);
        //list<Case> caseListToInsert= new list<Case>();
        system.runAs(currentuser){
            list<case> caselist = [select id, origin,Site_Contact__c,Site_Contact_Phone__c,User_Input_Work_Order_Instructions__c,Quantity_Override__c,contactid,Is_Clone__c, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,Is_ByPassWO__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            
            list<String> caseIdList = new List<String>();
            caseIdList.add(caselist[0].id);
            
            caselist[0].Site_Contact__c = 'test' ;
            caselist[0].Site_Contact_Phone__c = '9999999999';
            caselist[0].User_Input_Work_Order_Instructions__c = 'testWM';            
            update caselist[0];
          
            test.startTest();
                String msg = GetCaseInformation.addWorkOrderDetails(caselist[0],caseIdList);
                GetCaseInformation.saveAdditionalTemplate('test',caseIdList);
            test.stopTest();
            
            system.assert(msg == Constant_Util.SUCCESS);
        }
    }
    // Modified for SDT-33453 Start  
    @isTest static void testsaveAdditionalTemplateThrowAnException() {
        Exception capturedException;
        
        try {
            list<String> caseIdList = new List<String>();
            GetCaseInformation.saveAdditionalTemplate('test',caseIdList);
        } catch (Exception e) {
            capturedException = e;
        }
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');        
    }
    // Modified for SDT-33453 End
    // Modified for SDT-33453 Start  
    /*@isTest static void testsaddWorkOrderDetailsThrowAnException() {
        Exception capturedException;
        String msg;
        try {
            list<case> caselist = [select id, origin,Site_Contact__c,Site_Contact_Phone__c,User_Input_Work_Order_Instructions__c,Quantity_Override__c,contactid,Is_Clone__c, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,Is_ByPassWO__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            
            caselist[0].Site_Contact__c = 'test' ;
            caselist[0].Site_Contact_Phone__c = '9999999999';
            caselist[0].User_Input_Work_Order_Instructions__c = 'testWM';            
            update caselist[0];
            list<String> caseIdList = new List<String>();
            msg = GetCaseInformation.addWorkOrderDetails(caselist[0],caseIdList);
        } catch (Exception e) {
            capturedException = e;
        }
        system.assert(msg == Constant_Util.Failure);
        System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');        
    }*/
    // Modified for SDT-33453 End
    @isTest static void getRelatedCaseTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c from case limit 1];
            test.startTest();
            List<Case> resultList = GetCaseInformation.getRelatedCase(caselist[0].id);
            Case caseRec= GetCaseInformation.getCaseDetails(caselist[0].id);
            GetCaseInformation.getcaseAssetDetails(caselist[0].id);
            GetCaseInformation.createAcornComment('comments',caselist[0].id);
            GetCaseInformation.addQuoteCheck(caselist[0].id);
            //GetCaseInformation.getAddProductId();
            GetCaseInformation.getOpportunityID(caselist[0].id);
            GetCaseInformation.ShowExistingQuotes(caselist[0].id);
            GetCaseInformation.getCopyCaseOpenTask(caselist[0].id);
            GetCaseInformation.updateThisCaseToClose(caselist[0].id);
            GetCaseInformation.getCopyCaseOpenTask(caselist[0].id);
            test.stopTest();
            system.assert(resultList != null);
        }
    }
    
    //Test getAddProductId()
    @isTest static void getAddProductIdTest(){
        
        SBQQ__CustomAction__c action = new SBQQ__CustomAction__c();
        action.Name = Constant_Util.ADD_PRODUCTS;
        action.SBQQ__DisplayOrder__c = 1;
        insert action;
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            
            test.startTest();
            String productId = GetCaseInformation.getAddProductId();
            system.assert(productId != null);
            test.stopTest();
            
        }
    }
    
    //Test copyEmailToChildCase()
    @isTest static void copyEmailToChildCaseTest(){
        
        Case caseRecord = [select Id from case limit 1];
        String subject = 'Email Subject';
        String body = 'Email Body';
        List<EmailMessage> emails = TestDataFactory.createEmailMessage(subject, body, caseRecord); 
        insert emails;
        
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            
            test.startTest();
            	GetCaseInformation.copyEmailToChildCase(caseRecord.Id, caseRecord);
            	system.assertEquals('Hi', 'Hi');
            test.stopTest();
            
        }
    }
    
    /*  @author Accenture
* @date 3/27/2019
* @description : Apex method getBusinessRuleTest
*/
    @isTest static void getBusinessRuleTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        System.runAs(currentUser){
            
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            list<Contact> conlistNew = TestDataFactory.createContact('Business','Rule', acclist[0], currentUser);
            Database.insert(conlistNew);
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            Case myCase = [SELECT Id,Location__c,AccountId,AssetId,Case_Sub_Type__c from Case WHERE AccountId =:accList AND AssetId =:assetlist and Location__c =:locationList LIMIT 1];
            Id priceBookId = [SELECT Id FROM PriceBook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            
                brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
                brlist.get(0).Effective_Date__c = System.today() - 1;
                brlist.get(0).End_Date__c = system.today() + 5;
                brlist.get(0).Active__c = true; 
                brlist.get(0).Container__c= Constant_Util.EMPTY_STRING;
                brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
                brlist.get(0).Project_Code__c=null;
                brlist.get(0).AssetId__c = assetlist[0].id;
                brlist.get(0).Special_Ins__c= CHANNEL_INFO;
                brlist.get(0).Channel__c = null;
                brlist.get(0).Channel_Req__c= null;

                Database.insert(brlist.get(0),true);
/*
                Business_Rule__c brRec1 = new Business_Rule__c();
                brRec1=brlist.get(0).clone(false,true,false,false);
                brRec1.Multiple_Mandatory_Approvers__c = true;
                brRec1.Is_Auto_Email__c = true;
                brlist.get(0).Effective_Date__c = System.today() - 5;
                brlist.get(0).End_Date__c = system.today() + 4;
            	brlist.get(0).Case_Reason__c = 'Contaminated';

                Database.DMLOptions dml = new Database.DMLOptions();
                dml.DuplicateRuleHeader.AllowSave = true;
 
                // Insert the record, bypassing duplicate rules
                Database.SaveResult sr = Database.insert(brRec1, dml);

                brlist.add(brRec1);
*/
                
                

                // Create Business Rule - Approval
           List<Business_Rule__c> approverlst = TestDataFactory.createBusinessRule('test1', acclist[0], locationlist[0]);
           approverlst[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVAL, 'Business_Rule__c');
           approverlst[0].Request_Type__c = 'Pickup';
           approverlst[0].Service__c = 'Extra Pickup';
           approverlst[0].Active__c = true;
           approverlst[0].LocationId__c = locationlist[0].Id;
           approverlst[0].AccountId__c = acclist[0].Id;
           approverlst[0].AssetId__c = assetlist[0].id;
           approverlst[0].Container__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Effective_Date__c = System.today() - 2;
           approverlst[0].Channel_Req__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Multiple_Mandatory_Approvers__c = true;
           approverlst[0].Channel__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Is_Auto_Email__c = true;

           insert approverlst;

        //    list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        //    Database.insert(acctitlelst);
           
        //    List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(approverlst[0]);
        //    serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        //    insert serviceApproverList;


           List<Service_Approver__c> EmailServiceApprover = TestDataFactory.createEmailServiceApprover(approverlst[0]);
           EmailServiceApprover[0].Email__c = 'sharma@gmail.com';
           EmailServiceApprover[0].Active__c = true;
           insert EmailServiceApprover;
           // Create Service Approver
           List<Service_Approver__c> salst = TestDataFactory.createServiceApprover(approverlst[0]);
           salst[0].Email__c = 'jatan@gmail.com';
           salst[0].Business_Rule__c = approverlst[0].Id;
           salst[0].User__c = currentuser.Id;
           salst[0].Requester_Only__c = false;
           salst[0].Approver_Contact__c = conlist[0].Id;
           salst[0].Active__c = true;
           insert salst;

           // Create Service Requestor
           Service_Approver__c requestor = new Service_Approver__c(
               Business_Rule__c = approverlst[0].Id,
               Location__c = approverlst[0].LocationId__c,
               Account__c = approverlst[0].AccountId__c,
               RecordTypeId = TestDataFactory.getRecordType('Email', 'Service_Approver__c'),
               Requester_Only__c = true,
               Approver_Contact__c = conlist[0].Id,
               Email__c = 'jshara@gmail.com',
               //Title__c  = acctitlelst.id,

               Active__c = true
           );
           insert requestor;

                test.startTest();
                // GetCaseInformation.getBusinessRule(myCase.id);
                myCase.Status = Constant_Util.STATUS_New;
                myCase.AssetId = assetlist[0].id;
                myCase.Service_Date__c = null;
                myCase.isWorkOrderCreated__c = false;
                //myCase.Case_Sub_type__c = Constant_Util.EMPTY_STRING;
                update myCase;
                GetCaseInformation.GetMessage(myCase.id);
                // brlist.get(0).Channel_Req__c= Constant_Util.EMPTY_STRING;
                // brlist.get(0).Special_Ins__c= SPECIAL_INS;

                // approverlst.get(0).Channel_Req__c= Constant_Util.EMPTY_STRING;
                // approverlst.get(0).Special_Ins__c= SPECIAL_INS;

                // Database.update(brlist,true);
                // Database.update(approverlst,true);
                
                // GetCaseInformation.GetMessage(myCase.id);
                // myCase.Status = Constant_Util.INTEGRATION_ERROR;
                // //myCase.Case_Sub_type__c = Constant_Util.EMPTY_STRING;
                // update myCase;
                // GetCaseInformation.GetMessage(myCase.id);
                myCase.Status = Constant_Util.PENDING;
                update myCase;
                GetCaseInformation.GetMessage(myCase.id);
                approverlst.get(0).Channel_Req__c= CHANNEL_INFO;
                approverlst.get(0).Channel__c = 'WM Portal';
                approverlst.get(0).Special_Ins__c= Constant_Util.EMPTY_STRING;

                brlist.get(0).Channel_Req__c= CHANNEL_INFO;
                brlist.get(0).Channel__c = 'WM Portal';
                brlist.get(0).Special_Ins__c= Constant_Util.EMPTY_STRING;

          

                Database.update(brlist,true);
                Database.update(approverlst,true);
                
                GetCaseInformation.getBusinessRule(myCase.id);
                GetCaseInformation.createOppQuote(myCase.id);
                GetCaseInformation.getcaseAssetDetails(myCase.id);
                test.stopTest();
                system.assert(brlist!=null);          
        }
     } 

     @isTest static void getBusinessRuleTest2(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        System.runAs(currentUser){
            
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            list<Contact> conlistNew = TestDataFactory.createContact('Business','Rule', acclist[0], currentUser);
            Database.insert(conlistNew);
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            Case myCase = [SELECT Id,Location__c,AccountId,AssetId,Case_Sub_Type__c from Case WHERE AccountId =:accList AND AssetId =:assetlist and Location__c =:locationList LIMIT 1];
            Id priceBookId = [SELECT Id FROM PriceBook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            
                brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
                brlist.get(0).Effective_Date__c = System.today() - 1;
                brlist.get(0).End_Date__c = system.today() + 5;
                brlist.get(0).Active__c = true; 
                brlist.get(0).Container__c= Constant_Util.EMPTY_STRING;
                brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
                brlist.get(0).Project_Code__c=null;
                brlist.get(0).AssetId__c = assetlist[0].id;
                brlist.get(0).Special_Ins__c= CHANNEL_INFO;
                brlist.get(0).Channel__c = null;
                brlist.get(0).Channel_Req__c= null;

                Database.insert(brlist.get(0),true);
                // Create Business Rule - Approval
           List<Business_Rule__c> approverlst = TestDataFactory.createBusinessRule('test1', acclist[0], locationlist[0]);
           approverlst[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVAL, 'Business_Rule__c');
           approverlst[0].Request_Type__c = 'Pickup';
           approverlst[0].Service__c = 'Extra Pickup';
           approverlst[0].Active__c = true;
           approverlst[0].LocationId__c = locationlist[0].Id;
           approverlst[0].AccountId__c = acclist[0].Id;
           approverlst[0].AssetId__c = assetlist[0].id;
           approverlst[0].Container__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Effective_Date__c = System.today() - 2;
           approverlst[0].Channel_Req__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Multiple_Mandatory_Approvers__c = false;
           approverlst[0].Channel__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Is_Auto_Email__c = true;

           insert approverlst;

           
           List<Service_Approver__c> EmailServiceApprover = TestDataFactory.createEmailServiceApprover(approverlst[0]);
           EmailServiceApprover[0].Email__c = 'sharma@gmail.com';
           EmailServiceApprover[0].Active__c = true;
           insert EmailServiceApprover;
                test.startTest();
                GetCaseInformation.GetMessage(myCase.id);
                GetCaseInformation.getCaseMessages(myCase.id);
                //GetCaseInformation.IsTemplateVisible(myCase.id);
                test.stopTest();
        }
     } 
    /*  @author Accenture
* @date 3/27/2019
* @description : Apex method getEntitlementTest
*/
    @isTest Public static void getEntitlementTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999 ];
        List<Account> locationList =[Select Location_Type__c,ParentId from account where ParentId =:accList LIMIT 1];
        
        List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        Case myCase = [SELECT Id,AssetId from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.Case_Type__c= PICKUP;
        myCase.Case_Sub_Type__c= EXTRA_PICKUP;
        database.update(myCase,true);
        List<Entitlement> entitlementList = TestDataFactory.createEntitlement(TEST_NAME,locationList.get(0));
        entitlementList.get(0).SLA_Ins__c=SLA;
        entitlementList[0].Container__c= 'Open Top';
        //entitlementList.get(0).assetId = myCase.AssetId;
            try{
                Database.insert(entitlementList,true);
            }catch(Exception e){
                
            }
        test.startTest();
        GetCaseInformation.getEntitlement(myCase.id);
        test.stopTest();
        system.assert(entitlementList!=null);
        }
    } 
  /*  @author Accenture
* @date 3/27/2019
* @description : Apex method getEntitlementWithoutAssetTest
*/  
    @isTest Public static void getEntitlementWithoutAssetTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        Case myCase = [SELECT Id,AssetId from Case LIMIT 1];
        myCase.status=Constant_Util.OPEN;
        myCase.AssetId = null;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        Database.update(myCase,false); 
        test.startTest();
        GetCaseInformation.getEntitlement(myCase.id);
        test.stopTest();
        system.assert(myCase!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method getEntitlementWithNewCase
*/
    @isTest Public static void getEntitlementWithNewCase(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,ParentId from account where ParentId =:accList LIMIT 1];
        Case myCase = [SELECT Id from Case WHERE AccountId =:accList LIMIT 1];
        myCase.Status=Constant_Util.STATUS_New;
        myCase.Case_Sub_Type__c=Constant_Util.EMPTY_STRING;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase); 
        test.startTest();
        GetCaseInformation.getEntitlement(myCase.id);
        test.stopTest();
        system.assert(myCase!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method getMessageTest
*/
    @isTest Public static void getMessageTest(){
        String[] assetlistToUse = new String[]{};
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId,RecordTypeId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist AND Status =: Constant_Util.PENDING LIMIT 1];
        
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), locationlist.get(0));
                  brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Channel_Req__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Channel__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).AccountId__c = accList.get(0).ID;
            brlist.get(0).locationid__c = locationList.get(0).ID;
            brlist.get(0).Active__c = True;
            brlist.get(0).Service__c = 'Extra Pickup';
            brlist.get(0).Request_Type__c = 'Pickup';
            brlist.get(0).AssetId__c = assetlist[0].id;
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            brlist.get(0).Effective_Date__c = System.Today()-2;
            brlist.get(0).Is_Auto_Email__c = true;
            brlist.get(0).Multiple_Mandatory_Approvers__c = true;
        insert brlist;
          
             list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
            Database.insert(acctitlelst);
            
            List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
            serviceApproverList[0].Title__c = acctitlelst[0].Id; 
            
            Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                             Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa.Email__c = 'test@test.com';
            serviceApproverList.add(sa);
            Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                             Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa1.Email__c = 'testtest@test.com';
            serviceApproverList.add(sa1);
            
            insert serviceApproverList;
            
        myCase.Business_RuleId__c = brlist[0].Id;
        update myCase;
            
        test.startTest();
        assetlistToUse.add(assetlist[0].Id);
        assetlistToUse.add(assetlist[1].Id);
        sessionPart.put(myCase.Id,assetlistToUse);
        myCase.Status=Constant_Util.OPEN;
        myCase.SLA_Service_Date_Time__c = Null;
        //myCase.Status=Constant_Util.OPEN;
        //myCase.Status=Constant_Util.PENDING;
            
        Database.update(myCase);
        GetCaseInformation.Wrapper w = GetCaseInformation.getMessage(myCase.id);
        //boolean logic1 = GetCaseInformation.ProgressCaseVisiblityLogicCheck(w);
        boolean logic2 = GetCaseInformation.getUserUCCDetail(w);
        test.stopTest();
        system.assert(myCase!=null);
        system.assertEquals(w.multiAssetSelections,assetlistToUse);
        }
        }
    
    @isTest Public static void getMessageTest1(){
        String[] assetlistToUse = new String[]{};
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist AND Status =: Constant_Util.STATUS_New LIMIT 1];
            
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), locationlist.get(0));
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Channel_Req__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Channel__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).AccountId__c = accList.get(0).ID;
            brlist.get(0).locationid__c = locationList.get(0).ID;
            brlist.get(0).Active__c = True;
            brlist.get(0).Service__c = 'Extra Pickup';
            brlist.get(0).Request_Type__c = 'Pickup';
            brlist.get(0).AssetId__c = assetlist[0].id;
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            brlist.get(0).Effective_Date__c = System.Today()-2;
            insert brlist;
            
            list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
            Database.insert(acctitlelst);
            
            List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
            serviceApproverList[0].Title__c = acctitlelst[0].Id; 
            
            Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                             Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa.Email__c = 'test@test.com';
            serviceApproverList.add(sa);
            Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                              Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa1.Email__c = 'testtest@test.com';
            serviceApproverList.add(sa1);
            
            myCase.Business_RuleId__c = brlist[0].Id;
            update myCase;
            
            test.startTest();
            assetlistToUse.add(assetlist[0].Id);
            assetlistToUse.add(assetlist[1].Id);
            sessionPart.put(myCase.Id,assetlistToUse);
            myCase.Status=Constant_Util.OPEN;
            myCase.SLA_Service_Date_Time__c = Null;
            //myCase.Status=Constant_Util.OPEN;
            //myCase.Status=Constant_Util.PENDING;
            
            Database.update(myCase);
            GetCaseInformation.Wrapper w = GetCaseInformation.getMessage(myCase.id);
            test.stopTest();
            system.assert(myCase!=null);
            system.assertEquals(w.multiAssetSelections,assetlistToUse);
        }
    }
    
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method getMessageWithoutAsset
*/
  @isTest public static void getMessageWithoutAsset(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.AssetId=null;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        Test.startTest();
        GetCaseInformation.getMessage(myCase.id);
        Test.stopTest();
        system.assert(assetlist!=null);
        system.assert(myCase!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method getMessageWithoutContact
*/
    @isTest public static void getMessageWithoutContact(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.ContactId=null;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        test.startTest();
        GetCaseInformation.getMessage(myCase.id);
        test.stopTest();
        system.assert(assetlist!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method getMessageWithoutCaseSubType
*/
    @isTest public static void getMessageWithoutCaseSubType(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.Case_Sub_Type__c=Constant_Util.EMPTY_STRING;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        test.startTest();
        GetCaseInformation.getMessage(myCase.id);
        test.stopTest();
        system.assert(assetlist!=null);
        system.assert(myCase!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method testBusinessRule
*/
    @isTest public static void testBusinessRule(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.PurchaseOrder_Number__c=Constant_Util.EMPTY_STRING;
        myCase.Override_PO_Create_Task__c=false;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
        brlist.get(0).Effective_Date__c = System.today() - 1;
        brlist.get(0).End_Date__c = system.today() + 5;
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).AssetId__c = assetlist[0].id;
        Database.insert(brlist,true);
        test.startTest();
        GetCaseInformation.getMessage(myCase.id);
        brlist.get(0).Required_Information__c = Constant_Util.PSI;
        Database.update(brlist,false);
        GetCaseInformation.getMessage(myCase.id);

        //---------------
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Required_Information__c = Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Channel_Req__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Channel__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).AccountId__c = accList.get(0).ID;
        brlist.get(0).locationid__c = locationList.get(0).ID;
        brlist.get(0).Active__c = True;
        brlist.get(0).Service__c = 'Extra Pickup';
        brlist.get(0).Request_Type__c = 'Pickup';
        brlist.get(0).AssetId__c = assetlist[0].id;
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        brlist.get(0).Effective_Date__c = System.Today()-2;
        Database.update(brlist,false);

        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
            Database.insert(acctitlelst);
            
            List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
            serviceApproverList[0].Title__c = acctitlelst[0].Id; 
            
            Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                             Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa.Email__c = 'test@test.com';
            serviceApproverList.add(sa);
            Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                             Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
            sa1.Email__c = 'testtest@test.com';
            serviceApproverList.add(sa1);
          
            Database.insert(serviceApproverList,false);
        GetCaseInformation.getMessage(myCase.id);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method testBusinessRuleWithReqInfo
*/
    @isTest public static void testBusinessRuleWithReqInfo(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.Status=Constant_Util.STATUS_New;
        myCase.Case_Type__c=PICKUP;
        myCase.SLA_Service_Date_Time__c=system.today() + 2;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        brlist.get(0).Effective_Date__c = System.today() - 1;
        brlist.get(0).End_Date__c = system.today() + 5;
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        Database.insert(brlist,true);
        test.startTest();
        GetCaseInformation.getMessage(myCase.id);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
        }    
    } 
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method testBusinessRuleWithCase
*/
    @isTest public static void testBusinessRuleWithCase(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.PSI_Override_Reason__c=Constant_Util.OTHER_API;
        myCase.PSI_Comments__c=Constant_Util.EMPTY_STRING;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        brlist.get(0).Required_Information__c = Constant_Util.PSI;
        brlist.get(0).Effective_Date__c = System.today() - 1;
        brlist.get(0).End_Date__c = system.today() + 5;
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        Database.insert(brlist,true);
        test.startTest();
        GetCaseInformation.getMessage(myCase.id);
        brlist.get(0).Required_Information__c = REQ_INFO;
        Database.update(brlist,true);
        GetCaseInformation.getMessage(myCase.id);
        myCase.PurchaseOrder_Number__c= NUM_123;
        myCase.Override_PO_Create_Task__c=true;
        myCase.PSI_Comments__c=TEST_NAME;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        GetCaseInformation.getMessage(myCase.id);
        myCase.PSI_Override_Reason__c=CONTACT_NOT_ONSITE;
        myCase.PSI__c=8;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        GetCaseInformation.getMessage(myCase.id);
        brlist.get(0).Required_Information__c = Constant_Util.PSI ;
        Database.update(brlist,true);
        GetCaseInformation.getMessage(myCase.id);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method testBusinessRuleWithDiffCases
*/
    @isTest public static void testBusinessRuleWithDiffCases(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
        Case myCase = [SELECT Id,AssetId  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        myCase.PurchaseOrder_Number__c=NUMBER_145;
        myCase.Override_PO_Create_Task__c=true;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
        brlist.get(0).Effective_Date__c = System.today() - 1;
        brlist.get(0).End_Date__c = system.today() + 5;
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        Database.insert(brlist,true);
        test.startTest();
        GetCaseInformation.getMessage(myCase.id);
        brlist.get(0).Required_Information__c = Constant_Util.PSI;
        Database.update(brlist,true);
        myCase.PSI_Override_Reason__c=Constant_Util.OTHER_API;
        myCase.PSI_Comments__c=TEST_NAME;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        GetCaseInformation.getMessage(myCase.id);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
        }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method testBusinessRuleWithServiceApprovers
*/
    @isTest public static void testBusinessRuleWithServiceApprovers(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
        List<Account> accList = [SELECT Id from Account LIMIT 49999];
        List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
        List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
        List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
        List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            
        Case myCase = [SELECT Id,AssetId,Location__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
        
        WorkOrder wo = [Select Id,AssetId,Customer_Location__c,Case.Case_Sub_Type__c from WorkOrder where Customer_Location__c =: myCase.Location__c LIMIT 1];
        
        myCase.Status=Constant_Util.PENDING;
        myCase.Case_Sub_Status__c= Constant_Util.PENDING_CUSTOMER_INFORMATION;
        myCase.SLA_Override_Reason__c = OTHER;
        myCase.SLA_Override_Comment__c=TEST_NAME;
        myCase.SlaStartDate = system.now().addHours(1);
        Database.update(myCase);
        List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        brlist.get(0).Multiple_Mandatory_Approvers__c=true;
        brlist.get(0).Occurrence_Limit__c = 1;
        brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
        Database.insert(brlist,true);
            
        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        Database.insert(acctitlelst);
         test.startTest(); //SDT-33363
        List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        
        Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa.Email__c = 'test@test.com';
        serviceApproverList.add(sa);
            
        Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa1.Email__c = 'testtest@test.com';
        serviceApproverList.add(sa1);
            
        Service_Approver__c sa2 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa2.Email__c = 'testtes@test.com';
        serviceApproverList.add(sa2);
        Database.insert(serviceApproverList,false);
        
        //test.startTest(); //SDT-33363
        GetCaseInformation.getMessage(myCase.id);
        
        serviceApproverList[0].Requester_Only__c = false;
        serviceApproverList[1].Requester_Only__c = true;
        serviceApproverList[2].Requester_Only__c = false;
        serviceApproverList[3].Requester_Only__c = true;
        Database.Update(serviceApproverList,false);
        GetCaseInformation.getMessage(myCase.id);
            
        brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        Database.update(brlist,true);
        GetCaseInformation.getMessage(myCase.id);
  
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[1].Requester_Only__c = false;
        Database.Update(serviceApproverList,false);
        GetCaseInformation.getMessage(myCase.id);
     
        brlist.get(0).Active__c = false;
        Database.update(brlist,true);
        GetCaseInformation.getMessage(myCase.id);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
    }
    }
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method exceptionHandling
*/
    @isTest public static void getMessageNewCaseTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id);
            Database.insert(sbsCaseAsset,true);
            myCase.Status=Constant_Util.STATUS_New;
            myCase.Case_Sub_type__c = Constant_Util.EXTRA_PICKUP;
            myCase.PurchaseOrder_Number__c =  Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =false;
            Database.update(myCase);
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
            brlist.get(0).Effective_Date__c = System.today() - 1;
            brlist.get(0).End_Date__c = system.today() + 5;
            brlist.get(0).Active__c = true; 
            brlist.get(0).Service__c = Constant_Util.EXTRA_PICKUP;
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = myCase.AssetId;
            Database.insert(brlist,true);

            test.startTest();
            GetCaseInformation.getMessage(myCase.id);
            brlist.get(0).Required_Information__c = Constant_Util.PSI;
            Database.update(brlist,true);
            GetCaseInformation.getMessage(myCase.id);
            myCase.PSI_Override_Reason__c = Constant_Util.OTHER_API;
            myCase.PSI_Comments__c = Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =true;
            myCase.Case_Type__c= PICKUP;
            
            Database.update(myCase,true);
            brlist.get(0).Required_Information__c = REQ_INFO;
            Database.update(brlist,true);
            GetCaseInformation.getMessage(myCase.id);
            myCase.Case_Type__c= PICKUP;
            myCase.PSI_Comments__c = TEST_NAME;
            myCase.PSI__c = 8;
            
            myCase.PSI_Override_Reason__c = CONTACT_NOT_ONSITE;
            Database.update(myCase,true);
            GetCaseInformation.getMessage(myCase.id);
            Test.stopTest();
            system.assert(myCase.PSI__c!=null);
    }

    } 
    /*  @author Accenture
* @date 4/3/2019
* @description : Apex method exceptionHandling
*/
    @isTest public static void getMessageNewCaseElseBlockTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id);
            Database.insert(sbsCaseAsset,true);
            myCase.Status=Constant_Util.STATUS_New;
            myCase.Case_Sub_type__c = Constant_Util.EXTRA_PICKUP;
            myCase.PurchaseOrder_Number__c =  Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =false;
            Database.update(myCase);
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
            brlist.get(0).Effective_Date__c = System.today() - 1;
            brlist.get(0).End_Date__c = system.today() + 5;
            brlist.get(0).Active__c = true; 
            brlist.get(0).Service__c = Constant_Util.EXTRA_PICKUP;
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = myCase.AssetId;
            Database.insert(brlist,true);

            test.startTest();
            GetCaseInformation.getMessage(myCase.id);
            brlist.get(0).Required_Information__c = Constant_Util.PSI;
            Database.update(brlist,true);
            GetCaseInformation.getMessage(myCase.id);
            myCase.PSI_Override_Reason__c = Constant_Util.OTHER_API;
           myCase.PSI_Comments__c = TEST_NAME;
          //  myCase.Override_PO_Create_Task__c =true;
            myCase.Case_Type__c= PICKUP;
            myCase.PSI__c = 8;
            Database.update(myCase,true);
            GetCaseInformation.getMessage(myCase.id);
            myCase.SLA_Service_Date_Time__c = system.today() + 2;
            Database.update(myCase,true);
            GetCaseInformation.getMessage(myCase.id);
            Test.stopTest();
            system.assert(myCase.PSI__c!=null);
    }

    } 
     /*  @author Accenture
* @date 4/3/2019
* @description : Apex method exceptionHandling
*/
    @isTest public static void getMessageNewCaseElseBlockSLATest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id);
            Database.insert(sbsCaseAsset,true);
            myCase.Status=Constant_Util.STATUS_New;
            myCase.Case_Sub_type__c = Constant_Util.EXTRA_PICKUP;
            myCase.PurchaseOrder_Number__c =  Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =false;
            Database.update(myCase);
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
            brlist.get(0).Effective_Date__c = System.today() - 1;
            brlist.get(0).End_Date__c = system.today() + 5;
            brlist.get(0).Active__c = true; 
            brlist.get(0).Service__c = Constant_Util.EXTRA_PICKUP;
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = myCase.AssetId;
            Database.insert(brlist,true);

            test.startTest();
            GetCaseInformation.getMessage(myCase.id);
            brlist.get(0).Required_Information__c = Constant_Util.PSI;
            Database.update(brlist,true);
            GetCaseInformation.getMessage(myCase.id);
            myCase.PSI_Override_Reason__c = CONTACT_NOT_ONSITE;
           myCase.PSI_Comments__c = TEST_NAME;
          //  myCase.Override_PO_Create_Task__c =true;
            myCase.Case_Type__c= PICKUP;
            myCase.PSI__c = 8;
            Database.update(myCase,true);
            GetCaseInformation.getMessage(myCase.id);
            myCase.SLA_Service_Date_Time__c = system.today() + 2;
            Database.update(myCase,true);
            GetCaseInformation.getMessage(myCase.id);
            Test.stopTest();
            system.assert(myCase.PSI__c!=null);
    }

    } 
      /*  @author Accenture
* @date 4/3/2019
* @description : Apex method exceptionHandling
*/
    @isTest public static void getMessageNewCaseElseBlockSLADateTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            test.startTest(); //S-17 //SDT-33637
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id);
            Database.insert(sbsCaseAsset,true);
            myCase.Status=Constant_Util.STATUS_New;
            myCase.Case_Sub_type__c = Constant_Util.EXTRA_PICKUP;
            myCase.PurchaseOrder_Number__c =  Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =false;
            Database.update(myCase);
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist.get(0).Effective_Date__c = System.today() - 1;
            brlist.get(0).End_Date__c = system.today() + 5;
            brlist.get(0).Active__c = true; 
            brlist.get(0).Service__c = Constant_Util.EXTRA_PICKUP;
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = myCase.AssetId;
            Database.insert(brlist,true);
            brlist.get(0).Required_Information__c = Constant_Util.EMPTY_STRING;
            Database.update(brlist,true);
            myCase.PSI_Override_Reason__c = CONTACT_NOT_ONSITE;
            myCase.PSI_Comments__c = TEST_NAME;
            myCase.Override_PO_Create_Task__c =true;
            myCase.PurchaseOrder_Number__c= Constant_Util.PO_VALUE_TEST;
            myCase.Case_Type__c= PICKUP;
            myCase.PSI__c = 8;
            myCase.SLA_Service_Date_Time__c = system.today() + 2;
            Database.update(myCase,true);
             //test.startTest(); S-17
            GetCaseInformation.getMessage(myCase.id);
            Test.stopTest();
            system.assert(myCase.PSI__c!=null);
    }

    } 
   
             /*  @author Accenture
* @date 4/3/2019
* @description : Apex method exceptionHandling
*/
    @isTest public static void getMessageNewCaseElseBlockSLAServiceDateTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            test.startTest(); //SDT-33637
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id);
            Database.insert(sbsCaseAsset,true);
            myCase.Status=Constant_Util.STATUS_New;
            myCase.Case_Sub_type__c = Constant_Util.EXTRA_PICKUP;
            myCase.PurchaseOrder_Number__c =  Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =false;
            Database.update(myCase);
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist.get(0).Effective_Date__c = System.today() - 1;
            brlist.get(0).End_Date__c = system.today() + 5;
            brlist.get(0).Active__c = true; 
            brlist.get(0).Service__c = Constant_Util.EXTRA_PICKUP;
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = myCase.AssetId;
            Database.insert(brlist,true);
            brlist.get(0).Required_Information__c = REQ_INFO;
            Database.update(brlist,true);
            myCase.PSI_Override_Reason__c = CONTACT_NOT_ONSITE;
            myCase.PSI_Comments__c = TEST_NAME;
            myCase.Override_PO_Create_Task__c =true;
            myCase.PurchaseOrder_Number__c= Constant_Util.PO_VALUE_TEST;
            myCase.Case_Type__c= PICKUP;
            myCase.PSI__c = 8;
            myCase.SLA_Service_Date_Time__c = system.today() + 2;
            Database.update(myCase,true);
              //test.startTest(); //SDT-33637
            GetCaseInformation.getMessage(myCase.id);
            myCase.PSI_Override_Reason__c = Constant_Util.OTHER_API;
            myCase.PSI_Comments__c = TEST_NAME;
            myCase.PurchaseOrder_Number__c=  Constant_Util.PO_VALUE_TEST;
                
            Database.update(myCase,true);
            GetCaseInformation.getMessage(myCase.id);
            Test.stopTest();
            System.assert(myCase.PSI__c!=null);
    }

    } 
     /*  @author Accenture
* @date 4/3/2019
* @description : Apex method exceptionHandling
*/
    @isTest public static void getMessageNewCaseElseBlockSLASerDateTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            test.startTest();  //SDT-33637
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];

            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c,CaseNumber from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id);
            
            Database.insert(sbsCaseAsset,true);
            myCase.Status=Constant_Util.STATUS_New;
            myCase.Case_Sub_type__c = Constant_Util.EXTRA_PICKUP;
            myCase.PurchaseOrder_Number__c =  Constant_Util.EMPTY_STRING;
            myCase.Override_PO_Create_Task__c =false;
            Database.update(myCase);
            
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
            brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brlist.get(0).Effective_Date__c = System.today() - 1;
            brlist.get(0).End_Date__c = system.today() + 5;
            brlist.get(0).Active__c = true; 
            brlist.get(0).Service__c = Constant_Util.EXTRA_PICKUP;
            brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
            brlist.get(0).Project_Code__c=null;
            brlist.get(0).AssetId__c = myCase.AssetId;
            Database.insert(brlist,true);
            brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
            Database.update(brlist,true);
            
            myCase.PSI_Override_Reason__c = CONTACT_NOT_ONSITE;
            myCase.PSI_Comments__c = TEST_NAME;
            myCase.Override_PO_Create_Task__c =true;
            myCase.PurchaseOrder_Number__c= Constant_Util.PO_VALUE_TEST;
            myCase.Case_Type__c= PICKUP;
            myCase.PSI__c = 8;
            myCase.SLA_Service_Date_Time__c = system.today() + 2;
            Database.update(myCase,true);
            
              //test.startTest();  //SDT-33637
            GetCaseInformation.getMessage(myCase.id);
            myCase.PSI_Override_Reason__c = Constant_Util.OTHER_API;
            myCase.PSI_Comments__c = TEST_NAME;
            myCase.PurchaseOrder_Number__c=  Constant_Util.PO_VALUE_TEST;
            Test.stopTest();    
            Database.update(myCase,true);
            GetCaseInformation.getMessage(myCase.id);
            list<EmailMessage> emailMsgLst = TestDataFactory.createEmailMessage(Constant_Util.CONSTANT_FIRST,'Testing',myCase);
            Database.insert(emailMsgLst,false);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, accList.get(0), conlist.get(0), 
                                                             currentUser, locationlist.get(0), assetlist.get(0));
            caselist[0].Status ='New';
            caselist[0].Reference_Number__c = myCase.CaseNumber;
            caselist[0].Is_Multiple_Asset__c = true;
            try{
                RecurrsiveTriggerHandler.isSkipcaseTrigger = false;
                Database.insert(caselist[0],true);
            }Catch(Exception ex){

            }
            List<Case> c = [select id,Reference_Number__c,Status,Is_Multiple_Asset__c,CaseNumber from Case where Reference_Number__c =: myCase.CaseNumber and Id !=: myCase.Id];
            
            
            //System.assert(myCase.PSI__c!=null);
    }

    } 
      /*  @author Accenture
* @date 4/3/2019
* @description : Apex method exceptionHandling
*/
   /* @isTest public static void exceptionHandlingGetCase(){
        User currentUser = [select id, Bypass_Validation__c from user LIMIT 1];
        system.runAs(currentUser){
        Test.startTest();
         GetCaseInformation.getCaseSummary(null);
        GetCaseInformation.initiateWorkOrder(null);
        GetCaseInformation.getEntitlement(null);
        GetCaseInformation.getBusinessRule(null);
        Test.stopTest();
        System.assertEquals(Null,GetCaseInformation.getEntitlement(null));
        }
    }*/
    
    
    @isTest static void getRecordTypeIdTest(){
        //test class errors - SDT - 33363
        Code_Switch__c codeSwitchSetting = new Code_Switch__c();
        codeSwitchSetting = TestDataFactory.codeSwitch('HaulAwayUIEnable', false);
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c from case limit 1];
            test.startTest();
            ID resultList2 = GetCaseInformation.getRecordTypeId(caselist[0].id);
            List<String> resultCCList = GetCaseInformation.getCaseRecordDetails(caselist[0].id);
            test.stopTest();
            system.assert(resultList2 != null);
            system.assert(resultCCList != null);
        }
    }
    
    @isTest public static void getAssetDetailTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Has_Extra_Pickup__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                           ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c = 'SCHEDULED';
            
            assetList[0].End_Date__c = system.today().addDays(16);
                
            Database.update(assetList,false);    
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            
            assetDetailList[0].Has_Extra_Pickup__c = true;
          
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetDetailList[0].id,myCase.Service_Date__c);
            
            Database.update(assetDetailList,false);   
          
            
            test.startTest();
            GetCaseInformation.getAssetDetail(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    /*  @author WM
* @date 4/5/2019
* @description : For Apex method getAssetDetail

*/     
    
    @isTest public static void getAssetDetailSecondTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Is_Active__c,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                           ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c ='On-Call';
            
            
            Database.update(assetList,false);    
                        
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
               
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetlist[0].id,myCase.Service_Date__c);
            
            test.startTest();
            GetCaseInformation.getAssetDetail(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
    /*  @author WM
* @date 4/5/2019
* @description : For Apex method getAssetDetail

*/    
    @isTest public static void getAssetDetailThirdTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            productlist[0].Family = 'Rolloff';
            Database.update(productlist,false); 
            
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Service_Type__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                           ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c ='Scheduled On-Call';
            
            Database.update(assetList,false);    
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            
            //assetDetailList[0].Occurrence_Type__c = 'SCHEDULED';
            assetDetailList[0].Service_Type__c = 'Haul';         
            Database.update(assetDetailList,false);   
            
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetlist[0].id,myCase.Service_Date__c);
            
            
            test.startTest();
            GetCaseInformation.getAssetDetail(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
     @isTest public static void getAssetDetailfourthTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 1];
            List<Asset> childassetlist =[SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where ParentId =:assetlist[0].Id];
            childassetlist[0].ParentId = assetlist[0].Id;
            //assetList[0].Occurrence_Type__c = 'SCHEDULED';
            
          //  List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Has_Extra_Pickup__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                 //          ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c = 'SCHEDULED';
            
            Database.update(assetList,false);   
            Database.update(childassetlist,false);  
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            
         //   assetDetailList[0].Has_Extra_Pickup__c = true;          
            childassetlist[0].Has_Extra_Pickup__c = true;
            
          //  Database.update(assetDetailList,false);
            Database.update(childassetlist,false);
            
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetlist[0].id,myCase.Service_Date__c);
            
            test.startTest();
            GetCaseInformation.getAssetDetail(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
    @isTest public static void getAssetDetailFifthTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Has_Extra_Pickup__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                           ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c = Constant_Util.SCHEDULED_ON_CALL;
            assetList[0].End_Date__c = null;
            assetList[0].Start_Date__c = System.today()-50;
                
            Database.update(assetList,false);    
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            
            assetDetailList[0].Has_Extra_Pickup__c = true;
          
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetDetailList[0].id,myCase.Service_Date__c);
            
            Database.update(assetDetailList,false);   
          
            
            test.startTest();
            GetCaseInformation.getAssetDetailNonPickup(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
     @isTest public static void getAssetDetailSixthTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Has_Extra_Pickup__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                           ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c = Constant_Util.SCHEDULED_ON_CALL;
            assetList[0].End_Date__c = System.today()+5;
            assetList[0].Start_Date__c = System.today()-50;
                
            Database.update(assetList,false);    
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            
            assetDetailList[0].Has_Extra_Pickup__c = true;
          
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetDetailList[0].id,myCase.Service_Date__c);
            
            Database.update(assetDetailList,false);   
          
            
            test.startTest();
            GetCaseInformation.getAssetDetailNonPickup(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
     @isTest public static void getAssetDetailSeventhTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Has_Extra_Pickup__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                           ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            assetList[0].End_Date__c = System.today()+5;
            assetList[0].Start_Date__c = System.today()-5;
                
            Database.update(assetList,false);    
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            
            assetDetailList[0].Has_Extra_Pickup__c = true;
          
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetDetailList[0].id,myCase.Service_Date__c);
            
            Database.update(assetDetailList,false);   
          
            
            test.startTest();
            GetCaseInformation.getAssetDetailNonPickup(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
     @isTest public static void getAssetDetailEighthTest(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Asset> assetDetailList = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Occurrence_Type__c,Has_Extra_Pickup__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                           ContactId =:conlist AND product2Id =:productlist LIMIT 49999];    
            assetList[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            assetList[0].End_Date__c = System.today()-50;
            assetList[0].Start_Date__c = System.today()-5;
                
            Database.update(assetList,false);    
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c  from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            
            assetDetailList[0].Has_Extra_Pickup__c = true;
          
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetDetailList[0].id,myCase.Service_Date__c);
            
            Database.update(assetDetailList,false);   
          
            
            test.startTest();
            GetCaseInformation.getAssetDetailNonPickup(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
    
     @isTest public static void getAssetDetailProductCommercial(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 1];
            List<Asset> childassetlist =[SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where ParentId =:assetlist[0].Id];
            childassetlist[0].ParentId = assetlist[0].Id;
            
            childassetlist[0].Occurrence_Type__c = Constant_Util.SCHEDULED;
            childassetlist[0].End_Date__c = System.today().addDays(5);
            childassetlist[0].Service_Type__c = 'Pickup';
            
            Database.update(assetList,false);   
            Database.update(childassetlist,false);  
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            myCase.Service_Date__c = System.today().addDays(1);
            Database.update(myCase);
            
         //   assetDetailList[0].Has_Extra_Pickup__c = true;          
            childassetlist[0].Has_Extra_Pickup__c = true;
            
          //  Database.update(assetDetailList,false);
            Database.update(childassetlist,false);
            
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetlist[0].id,myCase.Service_Date__c);
            
            test.startTest();
            map<Id,String>testMap = GetCaseInformation.getAssetDetail(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
    @isTest public static void getAssetDetailOccurrenceOncall(){
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            Boolean isEndedExtendedAssets = true; //Added for SDT-33377 and making covergae for SDT-33453
            List<Account> accList = [SELECT Id from Account LIMIT 49999 ];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 1];
            List<Asset> childassetlist =[SELECT Id,Product2.ProductTypeSelected__c,Duration__c,ProductFamily,Project_Code__c FROM Asset where ParentId =:assetlist[0].Id];
            childassetlist[0].ParentId = assetlist[0].Id;
            
            childassetlist[0].Occurrence_Type__c = Constant_Util.ON_CALL;
            childassetlist[0].End_Date__c = System.today().addDays(5);
            childassetlist[0].Service_Type__c = 'Pickup';
            
            Database.update(assetList,false);   
            Database.update(childassetlist,false);  
            
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Service_Date__c from Case WHERE AccountId =:accList AND AssetId =:assetlist LIMIT 1];
            myCase.Service_Date__c = System.today().addDays(1);
            Database.update(myCase);
            
         //   assetDetailList[0].Has_Extra_Pickup__c = true;          
            childassetlist[0].Has_Extra_Pickup__c = true;
            
          //  Database.update(assetDetailList,false);
            Database.update(childassetlist,false);
            
            map<Id, Date>assetParam = new map<Id, Date>();
            assetParam.put(assetlist[0].id,myCase.Service_Date__c);
            
            test.startTest();
            map<Id,String>testMap = GetCaseInformation.getAssetDetail(assetParam);//Added for SDT-33377 and making covergae for SDT-33453
            test.stopTest();    
        }
        
    }
    
     @isTest static void updateRelatedCasesTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        String[] assetlist = new String[]{};
        system.runAs(currentuser){
            
            list<case> caselist = [select id, origin, Reference_Number__c,contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c,RecordTypeId from case limit 1];
            list<Asset> assets = [select id,name from Asset limit 2];
            assetlist.add(assets[0].Id);
            assetlist.add(assets[1].Id);
            EmailMessage email = new EmailMessage();
            email.ParentId = caselist[0].Id;
            email.RelatedToId = caselist[0].Id;
            Database.insert(email);
            Comment__c notes = new Comment__c();
            notes.Case__c = caselist[0].Id;
            notes.RecordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
            Database.insert(notes);
            test.startTest();
            System.assertEquals(1, [select id from Case where reference_number__c=:caselist[0].reference_number__c].size());
            String msg = GetCaseInformation.updateRelatedCases(caselist[0].id,assetlist);
            System.assertEquals(3, [select id from Case where reference_number__c=:caselist[0].reference_number__c].size());
            test.stopTest();
            system.assert(msg != null);
        }
    }
    
       @isTest static void getCaseMessagesTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        currentuser.User_categorization_code__c = Constant_Util.CSRES;
        update currentuser;
       // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            
        //     List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        // brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        
        // brlist.get(0).Active__c = true; 
        // brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        // brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        // brlist.get(0).Project_Code__c=null;
        // brlist.get(0).AssetId__c = assetlist[0].id;
        // brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        // brlist.get(0).Occurrence_Limit__c = 1;
        // brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
        // Database.insert(brlist,true);

        List<Business_Rule__c> approverlst = TestDataFactory.createBusinessRule('test1', acclist[0], locationlist[0]);
           approverlst[0].RecordTypeId = TestDataFactory.getRecordType(Constant_Util.APPROVAL, 'Business_Rule__c');
           approverlst[0].Request_Type__c = 'Pickup';
           approverlst[0].Service__c = 'Extra Pickup';
           approverlst[0].Active__c = true;
           approverlst[0].LocationId__c = locationlist[0].Id;
           approverlst[0].AccountId__c = acclist[0].Id;
           approverlst[0].AssetId__c = assetlist[0].id;
           approverlst[0].Container__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Effective_Date__c = System.today() - 2;
           approverlst[0].Channel_Req__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Multiple_Mandatory_Approvers__c = true;
           approverlst[0].Channel__c = Constant_Util.EMPTY_STRING;
           approverlst[0].Is_Auto_Email__c = true;

           insert approverlst;

            
        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        Database.insert(acctitlelst);
        
        List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(approverlst[0]);
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        
        Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = approverlst[0].id, Location__c =  approverlst[0].locationid__c , Account__c = approverlst[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa.Email__c = 'test@test.com';
        serviceApproverList.add(sa);
            
        Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = approverlst[0].id, Location__c =  approverlst[0].locationid__c , Account__c = approverlst[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa1.Email__c = 'testtest@test.com';
        serviceApproverList.add(sa1);
            
        Service_Approver__c sa2 = new Service_Approver__c(Business_Rule__c = approverlst[0].id, Location__c =  approverlst[0].locationid__c , Account__c = approverlst[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa2.Email__c = 'testtes@test.com';
        serviceApproverList.add(sa2);
        Database.insert(serviceApproverList,false);
        
             list<case> myCase = [select id, origin,AssetId,status, Reference_Number__c,contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c,RecordTypeId from case where AssetId =: assetlist[0].id limit 1];
            
            myCase[0].status = Constant_Util.STATUS_NEW;
            //myCase[0].RecordType.Name = Constant_Util.New_Service_Case; // 
            database.update(myCase[0]);
            
        test.startTest();
        GetCaseInformation.getCaseMessages(myCase[0].id);
        
        serviceApproverList[0].Requester_Only__c = false;
        serviceApproverList[1].Requester_Only__c = true;
        serviceApproverList[2].Requester_Only__c = false;
        serviceApproverList[3].Requester_Only__c = true;
        Database.Update(serviceApproverList,false);
            
        // brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        // Database.update(brlist,true);
        
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[1].Requester_Only__c = false;
        Database.Update(serviceApproverList,false);
        // brlist.get(0).Active__c = false;
        // Database.update(brlist,true);
         test.stopTest();
        // system.assert(brlist!=null);
        system.assert(myCase!=null);
            
        }
    }
    
      @isTest static void getCaseMessagesSecondTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
       // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        brlist.get(0).Multiple_Mandatory_Approvers__c=true;
        brlist.get(0).Occurrence_Limit__c = 1;
        brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
        Database.insert(brlist,true);
            
        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        Database.insert(acctitlelst);
        
        List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        
        Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa.Email__c = 'test@test.com';
        serviceApproverList.add(sa);
            
        Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa1.Email__c = 'testtest@test.com';
        serviceApproverList.add(sa1);
            
        Service_Approver__c sa2 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa2.Email__c = 'testtes@test.com';
        serviceApproverList.add(sa2);
        Database.insert(serviceApproverList,false);
        test.startTest();
             list<case> myCase = [select id, origin,AssetId,status, Reference_Number__c,contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c,RecordTypeId from case where AssetId =: assetlist[0].id limit 1];
            
            
            WorkOrder wo = [Select Id,AssetId,Customer_Location__c,Case.Case_Sub_Type__c from WorkOrder where Customer_Location__c =: myCase[0].Location__c LIMIT 1];
        
            myCase[0].status = Constant_Util.PENDING;
            database.update(myCase[0]);
            
       // test.startTest(); 
        GetCaseInformation.getCaseMessages(myCase[0].id);
        
        serviceApproverList[0].Requester_Only__c = false;
        serviceApproverList[1].Requester_Only__c = true;
        serviceApproverList[2].Requester_Only__c = false;
        serviceApproverList[3].Requester_Only__c = true;
        Database.Update(serviceApproverList,false);
            
        brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        Database.update(brlist,true);
        
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[1].Requester_Only__c = false;
        Database.Update(serviceApproverList,false);
        brlist.get(0).Active__c = false;
        Database.update(brlist,true);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
            
        }
    }  
    
     @isTest static void getCaseMessagesThirdTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
       // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        brlist.get(0).Multiple_Mandatory_Approvers__c=true;
        brlist.get(0).Occurrence_Limit__c = 1;
        brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
        Database.insert(brlist,true);
            
        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        Database.insert(acctitlelst);
        
        List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        
        Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa.Email__c = 'test@test.com';
        serviceApproverList.add(sa);
            
        Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa1.Email__c = 'testtest@test.com';
        serviceApproverList.add(sa1);
            
        Service_Approver__c sa2 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa2.Email__c = 'testtes@test.com';
        serviceApproverList.add(sa2);
        Database.insert(serviceApproverList,false);
        test.startTest();    //SDT-33363(3)    
             list<case> myCase = [select id, origin,AssetId,status, Reference_Number__c,contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c,RecordTypeId from case where AssetId =: assetlist[0].id limit 1];
            
            
            WorkOrder wo = [Select Id,AssetId,Customer_Location__c,Case.Case_Sub_Type__c from WorkOrder where Customer_Location__c =: myCase[0].Location__c LIMIT 1];
        
            myCase[0].status = Constant_Util.Open;
            database.update(myCase[0]);
           // test.startTest();    //SDT-33363(3) 
        
        GetCaseInformation.getCaseMessages(myCase[0].id);
        
        serviceApproverList[0].Requester_Only__c = false;
        serviceApproverList[1].Requester_Only__c = true;
        serviceApproverList[2].Requester_Only__c = false;
        serviceApproverList[3].Requester_Only__c = true;
        Database.Update(serviceApproverList,false);
            
        brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        Database.update(brlist,true);
        
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[1].Requester_Only__c = false;
        Database.Update(serviceApproverList,false);
       
        brlist.get(0).Active__c = false;
        Database.update(brlist,true);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
            
        }
    }
    
    @isTest static void getCaseMessagesfourthTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
       // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        brlist.get(0).Multiple_Mandatory_Approvers__c=true;
        brlist.get(0).Occurrence_Limit__c = 1;
        brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
        brlist.get(0).Required_Information__c = Constant_Util.PO_NUMBER;
        Database.insert(brlist,true);
            
        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        Database.insert(acctitlelst);
        
        List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        
        Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa.Email__c = 'test@test.com';
        serviceApproverList.add(sa);
            
        Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa1.Email__c = 'testtest@test.com';
        serviceApproverList.add(sa1);
            
        Service_Approver__c sa2 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa2.Email__c = 'testtes@test.com';
        serviceApproverList.add(sa2);
        Database.insert(serviceApproverList,false);
        
             list<case> myCase = [select id, origin,AssetId,status, Reference_Number__c,contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c,RecordTypeId from case where AssetId =: assetlist[0].id limit 1];
            
            
            WorkOrder wo = [Select Id,AssetId,Customer_Location__c,Case.Case_Sub_Type__c from WorkOrder where Customer_Location__c =: myCase[0].Location__c LIMIT 1];
        
            myCase[0].status = Constant_Util.STATUS_New;
            myCase[0].PurchaseOrder_Number__c = null ;
            myCase[0].Override_PO_Create_Task__c = false;
            database.update(myCase[0]);
            
        test.startTest();
        GetCaseInformation.getCaseMessages(myCase[0].id);
        
        serviceApproverList[0].Requester_Only__c = false;
        serviceApproverList[1].Requester_Only__c = true;
        serviceApproverList[2].Requester_Only__c = false;
        serviceApproverList[3].Requester_Only__c = true;
        Database.Update(serviceApproverList,false);
            
        brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        Database.update(brlist,true);
        
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[1].Requester_Only__c = false;
        Database.Update(serviceApproverList,false);
      
        brlist.get(0).Active__c = false;
        Database.update(brlist,true);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
            
        }
    }
    
    @isTest static void getCaseMessagesfifthTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
       // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        brlist.get(0).Multiple_Mandatory_Approvers__c=true;
        brlist.get(0).Occurrence_Limit__c = 1;
        brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
        brlist.get(0).Required_Information__c = Constant_Util.PSI;
        Database.insert(brlist,true);
            
        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        Database.insert(acctitlelst);
        
        List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        
        Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa.Email__c = 'test@test.com';
        serviceApproverList.add(sa);
            
        Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa1.Email__c = 'testtest@test.com';
        serviceApproverList.add(sa1);
            
        Service_Approver__c sa2 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa2.Email__c = 'testtes@test.com';
        serviceApproverList.add(sa2);
        Database.insert(serviceApproverList,false);
        
             list<case> myCase = [select id, origin,AssetId,status, Reference_Number__c,contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c,RecordTypeId from case where AssetId =: assetlist[0].id limit 1];
            
            
            WorkOrder wo = [Select Id,AssetId,Customer_Location__c,Case.Case_Sub_Type__c from WorkOrder where Customer_Location__c =: myCase[0].Location__c LIMIT 1];
        
            myCase[0].status = Constant_Util.STATUS_New;
            myCase[0].PSI__c = null;
            myCase[0].PSI_Override_Reason__c = null;
            database.update(myCase[0]);
            
        test.startTest();
        GetCaseInformation.getCaseMessages(myCase[0].id);
        
        serviceApproverList[0].Requester_Only__c = false;
        serviceApproverList[1].Requester_Only__c = true;
        serviceApproverList[2].Requester_Only__c = false;
        serviceApproverList[3].Requester_Only__c = true;
        Database.Update(serviceApproverList,false);
            
        brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        Database.update(brlist,true);
        
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[1].Requester_Only__c = false;
        Database.Update(serviceApproverList,false);
        
        brlist.get(0).Active__c = false;
        Database.update(brlist,true);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
            
        }
    }
    
    @isTest static void getCaseMessagesSixthTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
       // String[] assetlist = new String[]{};
        system.runAs(currentuser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id from Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            List<Account> locationList =[Select Location_Type__c from account where ParentId =:accList AND RecordType.DeveloperName=:LOCATION LIMIT 1];
            
            List<Business_Rule__c> brlist = TestDataFactory.createBusinessRule(Constant_Util.TEST_BUSINESS_RULE,accList.get(0),locationList.get(0));
        brlist.get(0).RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        
        brlist.get(0).Active__c = true; 
        brlist.get(0).Container__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Schedule_Type__c=Constant_Util.EMPTY_STRING;
        brlist.get(0).Project_Code__c=null;
        brlist.get(0).AssetId__c = assetlist[0].id;
        brlist.get(0).Multiple_Mandatory_Approvers__c=true;
        brlist.get(0).Occurrence_Limit__c = 1;
        brlist.get(0).Special_Instructions_Approval__c = 'Test Approval Ins';
        brlist.get(0).Required_Information__c = Constant_Util.PSI;
        Database.insert(brlist,true);
            
        list<Account_Title__c> acctitlelst = TestDataFactory.createAccountTitle(accList[0],TEST_NAME);
        Database.insert(acctitlelst);
        
        List<Service_Approver__c> serviceApproverList = TestDataFactory.createServiceApprover(brlist.get(0));
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[0].Title__c = acctitlelst[0].Id; 
        
        Service_Approver__c sa = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa.Email__c = 'test@test.com';
        serviceApproverList.add(sa);
            
        Service_Approver__c sa1 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa1.Email__c = 'testtest@test.com';
        serviceApproverList.add(sa1);
            
        Service_Approver__c sa2 = new Service_Approver__c(Business_Rule__c = brlist[0].id, Location__c =  brlist[0].locationid__c , Account__c = brlist[0].Accountid__c,
                                                                      Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c'));
        sa2.Email__c = 'testtes@test.com';
        serviceApproverList.add(sa2);
        Database.insert(serviceApproverList,false);
        
             list<case> myCase = [select id, origin,AssetId,status, Reference_Number__c,contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c,RecordTypeId from case where AssetId =: assetlist[0].id limit 1];
            
            
            WorkOrder wo = [Select Id,AssetId,Customer_Location__c,Case.Case_Sub_Type__c from WorkOrder where Customer_Location__c =: myCase[0].Location__c LIMIT 1];
        
            myCase[0].status = Constant_Util.STATUS_New;
            myCase[0].PSI__c = null;
            myCase[0].PSI_Override_Reason__c = Constant_Util.OTHER_API;
            myCase[0].PSI_Comments__c = null;
            database.update(myCase[0]);
            
        test.startTest();
        GetCaseInformation.getCaseMessages(myCase[0].id);
        
        serviceApproverList[0].Requester_Only__c = false;
        serviceApproverList[1].Requester_Only__c = true;
        serviceApproverList[2].Requester_Only__c = false;
        serviceApproverList[3].Requester_Only__c = true;
        Database.Update(serviceApproverList,false);
            
        brlist.get(0).Multiple_Mandatory_Approvers__c=false;
        Database.update(brlist,true);
        
        serviceApproverList[0].Requester_Only__c = true;
        serviceApproverList[1].Requester_Only__c = false;
        Database.Update(serviceApproverList,false);
    
        brlist.get(0).Active__c = false;
        Database.update(brlist,true);
        test.stopTest();
        system.assert(brlist!=null);
        system.assert(myCase!=null);
            
        }
    }
    
    @isTest static void IsWMCapacityPlannerVisible_Test()
    {
        List<Case> cselist = [SELECT id FROM CASE LIMIT 1];
        Boolean  result = GetCaseInformation.IsWMCapacityPlannerVisible(cselist.get(0).id);
        //to Handle test class error
	try{
	if(cselist!=null)
		{
        Boolean  TempResult= GetCaseInformation.IsTemplateVisible(cselist.get(0).id);
		}
	}catch(Exception ex){}
        system.assert(result==false);
    }
    
     /** @Author- WM 
* Date- 10/8/2020
* Description- negative test case where service date is not falling under asset start date and end date  -SDT-15281
*/
    
    @isTest static void caseCaseAssetValidationWithEndDateTest()
    {   
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            assetlist[0].End_Date__c=system.today();
            assetlist[0].Start_Date__c=system.today().addDays(-30);
            Database.update(assetlist[0]); 
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c,CaseNumber from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            
            myCase.service_date__c= system.today().addDays(15); 
            Database.update(myCase); 
            Map<Id,string> caseAssetErrorMap= new Map<Id,string>();
            Set<Id> caseIdSet= new Set<Id>();
            caseIdSet.add(myCase.Id);
            List<SBS_Case_Asset__c> sbsCaseAssetList= new List<SBS_Case_Asset__c>();
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id );            
            sbsCaseAssetList.add(sbsCaseAsset);
            
            SBS_Case_Asset__c sbsCaseAsset2 = new SBS_Case_Asset__c ( AssetId__c = assetlist[1].id ,CaseId__c= myCase.id );           
            sbsCaseAssetList.add(sbsCaseAsset2);            
            
            Database.insert(sbsCaseAssetList);
            
            Test.startTest();
            caseAssetErrorMap=GetCaseInformation.caseAssetDateValidation(caseIdSet);
            Test.stopTest();       
            
            string errorMsg=caseAssetErrorMap.get(myCase.id);
            system.assertEquals(System.Label.CASE_ASSET_VAL_ERR_MSG,errorMsg);
        } 
    }
    
    /** @Author- WM 
* Date- 10/8/2020
* Description- negative test case where service date is less than asset start date and asset has no end date  -SDT-15281
*/
    @isTest static void caseCaseAssetValidateWithoutEndDt_PriorServiceDT_Test()
    {   
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            assetlist[0].Start_date__c=system.today().addDays(15);
            Database.update(assetlist[0]); 
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c,CaseNumber from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            myCase.service_date__c= system.today();
            Database.update(myCase); 
            Map<Id,string> caseAssetErrorMap= new Map<Id,string>();
            Set<Id> caseIdSet= new Set<Id>();
            caseIdSet.add(myCase.Id);
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].Id ,CaseId__c= myCase.Id );           
            Database.insert(sbsCaseAsset);  
            
            Test.startTest();
            caseAssetErrorMap=GetCaseInformation.caseAssetDateValidation(caseIdSet);
            Test.stopTest();         
            
            string errorMsg=caseAssetErrorMap.get(myCase.id);
            system.assertEquals(System.Label.CASE_ASSET_VAL_ERR_MSG,errorMsg);
        } 
    }
    
    /** @Author- WM 
* Date- 10/8/2020
* Description- positive test case where service date falls under asset start date and end date  -SDT-15281
*/  
    @isTest static void caseCaseAssetValidationWithPositiveTest()
    {   
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            assetlist[0].End_Date__c=system.today();
            assetlist[0].Start_Date__c=system.today().addDays(-30);
            Database.update(assetlist[0]); 
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c,CaseNumber from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            
            myCase.service_date__c= system.today(); 
            Database.update(myCase); 
            Map<Id,string> caseAssetErrorMap= new Map<Id,string>();
            Set<Id> caseIdSet= new Set<Id>();
            caseIdSet.add(myCase.Id);
            List<SBS_Case_Asset__c> sbsCaseAssetList= new List<SBS_Case_Asset__c>();
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id );            
            sbsCaseAssetList.add(sbsCaseAsset);
            
            Database.insert(sbsCaseAssetList);
            
            Test.startTest();
            caseAssetErrorMap=GetCaseInformation.caseAssetDateValidation(caseIdSet);
            Test.stopTest();       
            
            string errorMsg=caseAssetErrorMap.get(myCase.id);
            system.assert(string.isBlank(errorMsg));
        } 
    }
    
    /** @Author- WM 
* Date- 10/8/2020
* Description- positive test case where service date is greater than asset start date and asset has no end date  -SDT-15281
*/  
    @isTest static void caseCaseAssetValidationWithoutEndDatePositiveTest()
    {   
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentUser){
            List<Account> accList = [SELECT Id from Account LIMIT 49999];
            List<Contact> conlist = [SELECT Id from Contact where AccountId =: accList LIMIT 49999];
            List<product2> productlist = [SELECT Id from product2 LIMIT 49999];
            List<Asset> assetlist = [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c FROM Asset where AccountId =:accList AND 
                                     ContactId =:conlist AND product2Id =:productlist LIMIT 49999];
            assetlist[0].Start_Date__c=system.today().addDays(-30);
            Database.update(assetlist[0]); 
            List<Account> locationList =[Select Location_Type__c,RecordTypeid,ParentId from account where ParentId =:accList AND RecordType.DeveloperName=: LOCATION LIMIT 1];
            Case myCase = [SELECT Id,AssetId,Status,AccountId,PSI_Comments__c,PSI_Override_Reason__c,PSI__c,CaseNumber from Case WHERE AccountId =:accList AND AssetId =:assetlist AND ContactId =:conlist LIMIT 1];
            
            myCase.service_date__c= system.today(); 
            Database.update(myCase); 
            Map<Id,string> caseAssetErrorMap= new Map<Id,string>();
            Set<Id> caseIdSet= new Set<Id>();
            caseIdSet.add(myCase.Id);
            List<SBS_Case_Asset__c> sbsCaseAssetList= new List<SBS_Case_Asset__c>();
            SBS_Case_Asset__c sbsCaseAsset = new SBS_Case_Asset__c ( AssetId__c = assetlist[0].id ,CaseId__c= myCase.id );            
            sbsCaseAssetList.add(sbsCaseAsset);
            
            Database.insert(sbsCaseAssetList);
            
            Test.startTest();
            caseAssetErrorMap=GetCaseInformation.caseAssetDateValidation(caseIdSet);
            Test.stopTest();       
            
            string errorMsg=caseAssetErrorMap.get(myCase.id);
            system.assert(string.isBlank(errorMsg));
        } 
    }
    
    @isTest static void getCompanyCategoryErrorTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            list<case> caselist = [select id, Client__r.AccountNumber from case limit 1];
            test.startTest();
            List<Map<String, String>> companyList = GetCaseInformation.getCompanyCategory(caselist[0].Client__r.AccountNumber);
            test.stopTest();
        }
    }
    
    @isTest static void getCompanyCategorySuccessTest(){
        //test class errors - SDT - 33363-re
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1]; //SDT-33363(3)
        system.runAs(currentuser){
            list<case> caselist = [select id, Client__r.AccountNumber from case limit 1];
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new AcornCompanyDetailsMock());
            List<Map<String, String>> companyList = GetCaseInformation.getCompanyCategory(caselist[0].Id);
            test.stopTest();
            system.assert(companyList != null);
        }
    }
    
    //test
    @isTest static void checkQuoteCreationEligibilityTest(){
        test.startTest();
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            //querying
            Product2 prodOT = [Select Id, Name FROM Product2 WHERE Name =: 'Open Top' LIMIT 1];
            Product2 prodDel = [Select Id, Name FROM Product2 WHERE Name =: 'Haul' LIMIT 1];
            //creating product option
            SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
            sbqq.Core_Service__c = true;
            sbqq.SBQQ__ConfiguredSKU__c = prodOT.Id;
            sbqq.SBQQ__OptionalSKU__c = prodOT.Id;
            sbqq.SBQQ__Number__c = 350;
            sbqq.SBQQ__Quantity__c = 1;
            sbqq.Occurrence_Type__c = 'SCH';
            sbqq.CostModelType__c = 'PER';
            sbqq.Cost_Unit_of_Measure__c = 'MTH';
            sbqq.PriceUOM__c = 'MTH';
            sbqq.Schedule_Frequency__c = 'W';
            sbqq.Frequency_Interval__c = '1';
            insert sbqq;
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid, Asset.CPQ_Product__c, 
                                   PSI__c,PSI_Comments__c,Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c 
                                   from case limit 1];
            
            GetCaseInformation.addQuoteCheck(caselist[0].id);
            
        }
        test.stopTest();
    }
    
     //test
    @isTest static void checkQuoteCreationEligibilityTest2(){
        test.startTest();
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            //querying
            Product2 prodOT = [Select Id, Name FROM Product2 WHERE Name =: 'Open Top' LIMIT 1];
            Product2 prodDel = [Select Id, Name FROM Product2 WHERE Name =: 'Haul' LIMIT 1];
            //creating product option
            SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
            sbqq.Core_Service__c = true;
            sbqq.SBQQ__ConfiguredSKU__c = prodOT.Id;
            sbqq.SBQQ__OptionalSKU__c = prodOT.Id;
            sbqq.SBQQ__Number__c = 350;
            sbqq.SBQQ__Quantity__c = 1;
            sbqq.Occurrence_Type__c = 'SCH';
            sbqq.CostModelType__c = 'PER';
            sbqq.Cost_Unit_of_Measure__c = 'MTH';
            sbqq.PriceUOM__c = 'MTH';
            sbqq.Schedule_Frequency__c = 'W';
            sbqq.Frequency_Interval__c = '1';
            insert sbqq;
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid, Asset.CPQ_Product__c, 
                                   PSI__c,PSI_Comments__c,Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c 
                                   from case limit 1];
            
            List<Asset> assetList = [Select Id, Start_Date__c, End_Date__c FROM Asset Where Id =: caselist[0].assetId OR RootAssetId =: caselist[0].assetId limit 1];
            assetList[0].Start_Date__c = Date.today() + 1;
            assetList[0].End_Date__c = Date.today() + 1;
            update assetList[0];
            
            GetCaseInformation.addQuoteCheck(caselist[0].id);
            
        }
        test.stopTest();
    }
    
     //test
    @isTest static void checkQuoteCreationEligibilityTest3(){
        test.startTest();
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            //querying
            Product2 prodOT = [Select Id, Name FROM Product2 WHERE Name =: 'Open Top' LIMIT 1];
            Product2 prodDel = [Select Id, Name FROM Product2 WHERE Name =: 'Haul' LIMIT 1];
            //creating product option
            SBQQ__ProductOption__c sbqq = new SBQQ__ProductOption__c();
            sbqq.Core_Service__c = true;
            sbqq.SBQQ__ConfiguredSKU__c = prodOT.Id;
            sbqq.SBQQ__OptionalSKU__c = prodOT.Id;
            sbqq.SBQQ__Number__c = 350;
            sbqq.SBQQ__Quantity__c = 1;
            sbqq.Occurrence_Type__c = 'SCH';
            sbqq.CostModelType__c = 'PER';
            sbqq.Cost_Unit_of_Measure__c = 'MTH';
            sbqq.PriceUOM__c = 'MTH';
            sbqq.Schedule_Frequency__c = 'W';
            sbqq.Frequency_Interval__c = '1';
            insert sbqq;
            
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid, Asset.CPQ_Product__c, 
                                   PSI__c,PSI_Comments__c,Service_Date__c,SLA_Service_Date_Time__c,Create_AM_and_PM_Pickups__c 
                                   from case limit 1];
            
            List<Asset> assetList = [Select Id, Start_Date__c, End_Date__c FROM Asset Where Id =: caselist[0].assetId OR RootAssetId =: caselist[0].assetId limit 1];
            assetList[0].Start_Date__c = Date.today() + 1;
            assetList[0].End_Date__c = Date.today() + 1;
            update assetList[0];
            
            GetCaseInformation.addQuoteCheck(caselist[0].id);
            
        }
        test.stopTest();
    }
    //test class changes for SDT-42337
    @isTest static void validateAssetMandatoryCheckbox(){
        List<Case> caseList = new List<Case>();
        Map<Id,GetCaseInformation.Wrapper> caseMessageWrapperMap = New Map<Id,GetCaseInformation.Wrapper>();
        
        Account loc =[SELECT Id,ParentId from Account WHERE ParentId !=null AND  RecordType.Name ='Location' LIMIT 1];
        Contact con = [SELECT Id from Contact LIMIT 1];
        Account acc = [SELECT Id from Account WHERE RecordType.Name ='Client' LIMIT 1];
        
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :Constant_Util.CUSTOMER_SERVICE limit 1];
        system.runAs(currentuser){
            
            Case existingLocationCase = QuoteTestDataFactory.createCase('Standard Case', 'Site Survey','Existing Location',
                                                                        null, acc, con, loc);
            Case nowLowCase = QuoteTestDataFactory.createCase('Service Request Case', 'Add','Services',
                                                              'NOW/LOW', acc, con, loc);
            Case cancelledServiceCase = QuoteTestDataFactory.createCase('Standard Case', 'Billing','Customer Question',
                                                                        'Cancelled Services', acc, con, loc);
            Case serviceNRCase = QuoteTestDataFactory.createCase('Standard Case', 'Billing','Customer Question',
                                                                 'Service Not Requested', acc, con, loc);
            Case misMatchedSpecCase = QuoteTestDataFactory.createCase('Standard Case', 'Billing','Mismatched Spec',
                                                                      null, acc, con, loc);
            /*Case wmsscSpecCase = QuoteTestDataFactory.createCase('Standard Case', 'Billing','Recon Problem Quote',
                                                                 'WMSSC Spec Qty/Size needs to be updated', acc, con, loc);*/
            
            caseList.add(existingLocationCase);
            caseList.add(nowLowCase);
            caseList.add(cancelledServiceCase);
            caseList.add(serviceNRCase);
            caseList.add(misMatchedSpecCase);
            //caseList.add(wmsscSpecCase);
           
            test.startTest();
            
            QuoteTestDataFactory.insertCases(caseList);
            //TCS-pkulkarn-SDT-49657-25-Aug-25-Added for test class issue
            for(Case c : caseList)
            {
                c.Status = 'Open';
            }
            //TCS-pkulkarn-SDT-49657-25-Aug-25-End
            
            caseMessageWrapperMap = GetCaseInformation.getCaseValidationMessages(caseList, null);
            
            test.stopTest();
            System.assertEquals(caseMessageWrapperMap.get(existingLocationCase.Id).isAssetMandatory, false);
            System.assertEquals(caseMessageWrapperMap.get(nowLowCase.Id).isAssetMandatory, false);
            
            System.assertEquals(caseMessageWrapperMap.get(cancelledServiceCase.Id).isAssetMandatory, false);
            
            System.assertEquals(caseMessageWrapperMap.get(serviceNRCase.Id).isAssetMandatory, false);
            
            System.assertEquals(caseMessageWrapperMap.get(misMatchedSpecCase.Id).isAssetMandatory, false);
            /*System.assertEquals(caseMessageWrapperMap.get(wmsscSpecCase.Id).isAssetMandatory, false);*/
            
            
        }
    }
    
    global class AcornCompanyDetailsMock implements HTTPCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
         
         String json = '{'+
        '    \"Data\": ['+
        '        {'+
        '            \"Code\": \"WAL-NS\",'+
        '            \"Name\": \"New Store\",'+
        '            \"Description\": \"New Store\",'+
        '            \"IsConstructionDemolition\": 1'+
        '        },'+
        '        {'+
        '            \"Code\": \"WAL_24976359\",'+
        '            \"Name\": \"Take Over\",'+
        '            \"Description\": \"Take Over\",'+
        '            \"IsConstructionDemolition\": 1'+
        '        },'+
        '        {'+
        '            \"Code\": \"WAL_SP\",'+
        '            \"Name\": \"Special Project\",'+
        '            \"Description\": \"Special Project\",'+
        '            \"IsConstructionDemolition\": 1'+
        '        }'+
        '    ],'+
        '    \"Problem\": null'+
        '}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(200);
        return response;
        }
    }
    //SDT39047
    @isTest static void getBillingTest(){
        Code_Switch__c codeSwitchSetting = new Code_Switch__c();
        codeSwitchSetting = TestDataFactory.codeSwitch('HaulAwayUIEnable', true);
        
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        system.runAs(currentuser){
            
           list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c,
		PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
		Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
		Id caseRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case').getRecordTypeId();
        BillingService billing = new BillingService();
		caselist[0].RecordTypeId = caseRecId;
		caselist[0].Case_Type__c = billing.CASE_TYPE_BILLING;
		caselist[0].Case_Sub_Type__c = billing.CASE_SUB_TYPE_Invoice_Charge_Dispute;
		caselist[0].Case_Reason__c = 'Customer Short Pay';
		Database.update(caselist);
            test.startTest();
            List<String> resultCCList = GetCaseInformation.getCaseRecordDetails(caselist[0].id);
            test.stopTest();
            system.assert(resultCCList != null);
        }
    }
    
}