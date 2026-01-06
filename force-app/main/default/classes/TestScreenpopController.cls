@isTest(seeAllData = false)
public class TestScreenpopController {
    
    /**
* @description set the test data
*/ 
    @testSetup static void setup() {
        Test.startTest(); //SDT-33637
        Profile prf = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(prf);
//test class errors - SDT - 33363
        usr.LastName = 'AdminUserForTest';
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation('FAM002508', usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Account> locationlist2 = TestDataFactory.createLocation('FAM002509', usr, acclist.get(0).id);
            Database.insert(locationlist2);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                  Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            AccountContactRelation acr = new AccountContactRelation (ContactId = conlist.get(0).Id, 
                                                                     AccountId = locationlist.get(0).Id);
            Database.insert(acr);
            //create product
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            
            //create vendor
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            
            //create asset
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist.get(0).Id;
            Database.insert(assetlist);
            
            //create case
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist.get(0).AccountId = acclist.get(0).id ;
            Database.insert(caselist.get(0)); 
            
            list<Case> caselist2 = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist2.get(0).AccountId = acclist.get(0).id ;
            Database.insert(caselist2.get(3)); 
            
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, caselist.get(1));
            Database.insert(lstEM);
            
            //create task
            list<Task> tasklist = TestDataFactory.createTask(caselist[0].id,usr);
            Database.insert(tasklist); 

            list<WorkOrder> workOrder = TestDataFactory.createWorkOrder(acclist.get(0),conlist.get(0),caselist.get(0),assetlist.get(0));
            workOrder.get(0).Acorn_WorkOrder_Number__c = 'W23423';
            Database.insert(workOrder); 
            Test.stopTest(); //SDT-33637
            
        }
        
    }


// Test 1:1 case match on reference number
    @isTest
    static void testEM() {
        Integer random = Integer.valueof(crypto.getRandomLong());
        if(random < 0){
            random = random  * -1;
        }
        final String IXN_ID = String.valueof(random);
        final String MEDIA_TYPE = ScreenpopController.MEDIA_TYPE_WORKITEM;
        
        List<Case> lstCase = new List<Case>();
        lstCase = [select Id from Case limit 1];
        List<EmailMessage> lstEM = new List<EmailMessage>();   
        
        String Subject = Constant_Util.KEYWORD_TEST;
        String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
        lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase[0]);
		Test.startTest();
        Database.insert(lstEM);
        
        lstEM = [Select Id,ParentId, Subject from EmailMessage limit 1];
        
        Task tsk = new Task();
        tsk.Message_ID__c = lstEM[0].Id;
        tsk.WhatId = lstEM[0].ParentId;
        insert tsk;
        
        String SFDCRecId = lstEM[0].Id;
        
        // create test data
       // Id caseId = createCase('Pickup', REF_NO);
        
        // set up test
        PageReference pageRef = Page.Screenpop;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_MEDIA_TYPE, MEDIA_TYPE);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_INTERACTION_ID, IXN_ID);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_SFDCRecId, SFDCRecId);
         // execute controller
        ScreenpopController controller = new ScreenpopController();
        PageReference nextPage = controller.init();
        
        // check result
        String url = nextPage == null ? null : nextPage.getUrl(); 

		  Test.stopTest();
       
    }
    
    // Test 1:1 case match on reference number
    @isTest
    static void testRefNoSingleMatch() {
        
        Integer random = Integer.valueof(crypto.getRandomLong());
        if(random < 0){
            random = random  * -1;
        }
        final String IXN_ID = String.valueof(random);
        final String MEDIA_TYPE = ScreenpopController.MEDIA_TYPE_WORKITEM;
        final String REF_NO = crypto.getRandomLong() + '';
        
        // create test data
        Id caseId = createCase('Pickup', REF_NO);
        
        // set up test
        PageReference pageRef = Page.Screenpop;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_MEDIA_TYPE, MEDIA_TYPE);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_INTERACTION_ID, IXN_ID);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_REF_NO, REF_NO);
        
        // execute controller
        ScreenpopController controller = new ScreenpopController();
        PageReference nextPage = controller.init();
        
        // check result
        String url = nextPage == null ? null : nextPage.getUrl();        
        if(url == null){
            throw new AssertException('Case for reference [' + REF_NO + '] not found!');
        }else{}
        String expectedUrl = '/lightning/r/Case/' + caseId + '/view';
        System.assert(url.equalsIgnoreCase(expectedUrl), 'Output URL does not match expected URL');        
        
        String caseQuery = 'select id, Reference_Number__c, Status, Last_Customer_Interaction_ID__c, '
            + 'Last_Customer_Interaction_Type__c, Last_Agent_ID__c from Case where id = \'' + caseId + '\'';
        Test.startTest();
        assertCaseProperties(caseQuery, IXN_ID, MEDIA_TYPE, REF_NO);
		Test.stopTest();
    }
    
    // Test 1:* case matches on reference number
    @isTest
    static void testRefNoMultipleMatches() {
        
        Integer random = Integer.valueof(crypto.getRandomLong());
        if(random < 0){
            random = random  * -1;
        }
        final String IXN_ID = String.valueof(random);
        final String MEDIA_TYPE = ScreenpopController.MEDIA_TYPE_WORKITEM;
        final String REF_NO = crypto.getRandomLong() + '';
        
        // create test data
        Id caseId1 = createCase('ETA', REF_NO);
        Id caseId2 = createCase('Delivery', REF_NO);
        Id caseId3 = createCase('Other', REF_NO);
        
        // set up test
        PageReference pageRef = Page.Screenpop;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_MEDIA_TYPE, MEDIA_TYPE);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_INTERACTION_ID, IXN_ID);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_REF_NO, REF_NO);
        
        // execute controller
        ScreenpopController controller = new ScreenpopController();
        PageReference nextPage = controller.init();
        
        // check result
        String url = nextPage == null ? null : nextPage.getUrl();        
        System.debug('**url: ' + url);
        if(url == null){
            throw new AssertException('Cases for reference [' + REF_NO + '] not found!');
        }else{}
        String searchExpr = EncodingUtil.base64Encode(Blob.valueOf(ScreenpopController.SEARCH1 + REF_NO + ScreenpopController.SEARCH2));
        //System.assert(url.equalsIgnoreCase('/one/one.app#' + searchExpr), 'Output URL does not match expected URL');
        System.debug('url.equalsignoreCase ' + url.equalsIgnoreCase('/one/one.app#' + searchExpr));
        System.debug('compare url '  + '/one/one.app#' + searchExpr);
        System.debug('searchExpr ' + searchExpr);
        String caseQuery = 'select id, Reference_Number__c, Status, Last_Customer_Interaction_ID__c, '
            + 'Last_Customer_Interaction_Type__c, Last_Agent_ID__c from Case where Reference_Number__c = \'' + REF_NO + '\'';
        
        assertCaseProperties(caseQuery, IXN_ID, MEDIA_TYPE, REF_NO);
    }
    
    // Test 1:0 matches on reference number
    @isTest
    static void testRefNoNoMatch() {
        
        Integer random = Integer.valueof(crypto.getRandomLong());
        if(random < 0){
            random = random  * -1;
        }
        final String IXN_ID = String.valueof(random);
        final String MEDIA_TYPE = 'task';
        final String REF_NO = crypto.getRandomLong() + '';
        
        // set up test
        PageReference pageRef = Page.Screenpop;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_MEDIA_TYPE, MEDIA_TYPE);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_INTERACTION_ID, IXN_ID);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_REF_NO, REF_NO);
        
        // execute controller
        ScreenpopController controller = new ScreenpopController();
        PageReference nextPage = controller.init();
        
        // check result
        String url = nextPage == null ? null : nextPage.getUrl();        
        if(url == null){
            throw new AssertException('Cases for reference [' + REF_NO + '] not found!');
        }else{}
        if(url.length() != 41){
            throw new AssertException('Unexpected URL format [' + url + ']');
        }else{}
        Id caseId = Id.valueOf(url.substring(18, 36));  
        System.assert(url.equalsIgnoreCase('/lightning/r/Case/' + caseId + '/view'), 'Output URL does not match expected URL');
        
        String caseQuery = 'select id, Reference_Number__c, Status, Last_Customer_Interaction_ID__c, '
            + 'Last_Customer_Interaction_Type__c, Last_Agent_ID__c from Case where id = \'' + caseId + '\'';
        
        List<Case> cases = assertCaseProperties(caseQuery, IXN_ID, MEDIA_TYPE, null);        
        System.assert(cases.get(0).Status == 'New', 'Unexpected case status [' + cases.get(0).Status + ']!');
    }
    
    static List<Case> assertCaseProperties(String caseQuery, String genesysId, String mediaType, String refNo) {  
        
        List<Case> cases = Database.query(caseQuery);
        System.debug('cases -- ' + cases);
        System.debug('genesys ID -- ' + genesysId);
        if(cases == null || cases.size() < 1){
            throw new AssertException('Case(s) not found!');
        }else{}
        for(Case c : cases) {  
            
            System.debug('genesysId = ' + genesysId + ' --- connid = ' + c.Last_Customer_Interaction_Id__c);
            System.debug('c -- '  + c);
            System.assert(genesysId.equals(c.Last_Customer_Interaction_ID__c), 'Unexpected connid [' + c.Last_Customer_Interaction_ID__c + ']!');
            System.assert(mediaType.equals(c.Last_Customer_Interaction_Type__c), 'Unexpected media type [' + c.Last_Customer_Interaction_Type__c + ']!');
                        
            if(refNo != null){
                System.assert(refNo.equals(c.Reference_Number__c), 'Unexpected reference number [' + refNo + ']!');
            }else{}
        }
        
        if(cases.size() == 1) {
            
            Case c = cases.get(0);
            System.assert(c.Last_Agent_ID__c != null && !''.equals(c.Last_Agent_ID__c), 'Last_Agent_ID__c is blank!');
            String currentUserName = UserInfo.getUserName();
            System.debug('>>>>> TestScreenpopController.assertCaseProperties: lastAgentId = ' + c.Last_Agent_ID__c + ', currentUserName = ' + currentUserName);
            
            if(currentUserName != null && currentUserName.length() > 0)
                System.assert(currentUserName.startsWith(c.Last_Agent_ID__c), 'Last_Agent_ID__c does not match current user!');
        }
        
        return cases;
    }
    
    // Test pickup case with full ANI match
    @isTest
    static void testNewPickupCaseOnAniMatch() {
        Integer random = Integer.valueof(crypto.getRandomLong());
        if(random < 0){
            random = random  * -1;
        }
        String connId = String.valueof(random);
		Test.startTest();
        Case c = testIvrFlow('Pickup', connId, true, true, true, true,false);
        
        List<Task> tasks = [select id from Task 
            where WhatId =: c.Id and Subject = 'Inbound Customer Interaction' and Description__c =: connId];
           Test.stopTest();
        // make sure task was created
        System.assert(tasks != null || tasks.size() == 1, 'No default task created!');
    }
    
    // Test status case with location ANI match
    @isTest
    static void testNewEtaCaseOnAniMatch() {
        Integer random = Integer.valueof(crypto.getRandomLong());
        if(random < 0){
            random = random  * -1;
        }
        String connId = String.valueof(random);
		Test.startTest();
        testIvrFlow('ETA', connId, true, true, false, false,false);
		Test.stopTest();
    }
    
    // Test status case with contact ANI match
    @isTest
    static void testNewNewServiceCaseOnAniMatch() {
        Integer random = Integer.valueof(crypto.getRandomLong());
        if(random < 0){
            random = random  * -1;
        }
        String connId = String.valueof(random);
		Test.startTest();
        testIvrFlow('Delivery', connId, true, false, true, false,false);
		Test.stopTest();
    }
    
    // Test standard case with contact no ANI match
    @isTest
    static void testNewStandardCaseWithNoAniMatch() {
        testIvrFlow(null, null, false, false, false, false,false);
    }
    // Test redirect to Work Order
    @isTest
    static void testInvalidWorkOrder() {
        //test class errors - SDT - 33363
        user u = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];

        system.runAs(u){
            Integer random = Integer.valueof(crypto.getRandomLong());
            if(random < 0){
                random = random  * -1;
            }
            String connId = String.valueof(random);
            Test.StartTest();
            testIvrFlow('Delivery', connId, true, false, true, false,true);
            Test.StopTest();
        }
    }
    // Test redirect to Work Order
    @isTest
    static void testWorkOrder() {
        //test class errors - SDT - 33363
        User u = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE AND LastName = 'AdminUserForTest' LIMIT 1];
        system.runAs(u){
            Integer random = Integer.valueof(crypto.getRandomLong());
            if(random < 0){
                random = random  * -1;
            }
            String connId = String.valueof(random);
            final String MEDIA_TYPE = ScreenpopController.MEDIA_TYPE_VOICE;
            WorkOrder wo = [Select Id,CaseId,Acorn_WorkOrder_Number__c,WorkOrderNumber from WorkOrder Limit 1];
            Case c = [Select Id,AccountId,Client__c,assetid,Location__c from Case where Id =: wo.CaseId Limit 1];
            string woNum = (wo.Acorn_WorkOrder_Number__c).substring(1, (wo.Acorn_WorkOrder_Number__c).length());
            System.debug('WorkOrderNumber'+woNum);
            // set up test
            PageReference pageRef = Page.Screenpop;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_MEDIA_TYPE, ScreenpopController.MEDIA_TYPE_VOICE);
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_CONNECTION_ID, connId);
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_INTENT, 'Pickup');
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_ACCT_ID, c.Client__c);
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_LOCATION_ID, c.Location__c);
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_IVRWO, woNum); 
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_IVRVENDOR, 'true');
            
            Test.startTest();
                //execute controller
                ScreenpopController controller = new ScreenpopController();
                PageReference nextPage = controller.init();
                // check result
                String url = nextPage == null ? null : nextPage.getUrl();
            	system.debug('url'+url);
                Id workOrderId = Id.valueOf(url.substring(23, 41));
                System.AssertEquals(workOrderId,wo.Id);
            Test.StopTest();
        }
    }
    static Case testIvrFlow(String intent, String connId, Boolean withAccount, Boolean withLocation, Boolean withContact, Boolean withAsset,Boolean IsworkOrder) {
        DateTime startDT = System.now();
        final String MEDIA_TYPE = ScreenpopController.MEDIA_TYPE_VOICE;
        
        // set up test
        PageReference pageRef = Page.Screenpop;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_MEDIA_TYPE, ScreenpopController.MEDIA_TYPE_VOICE);
        
        if(connId != null && connId.length() > 0){
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_CONNECTION_ID, connId);
        }else{}       
        // set up test data and input query parameters (normally passed by Genesys)
        intent = intent == null ? null : intent.trim();
        if(intent != null && !''.equals(intent)){
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_INTENT, intent);
        }else{}
        Account client = null;
        Id locId = null;
        Id contactId = null;
        Id assetId = null;
        
        if(withAccount || withLocation || withContact) {
            client = createDummyAccount();
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_ACCT_ID, client.Id);
        }else{}
        
        if(withLocation) {      
            
            locId = createDummyLocation(client);
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_LOCATION_ID, locId);
            
            if(withAsset){
                assetId = createDummyAsset(locId);  
            }else{}
        }else{}
        
        if(withContact) {
            contactId = createDummyContact(client.Id);
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_CONTACT_ID, contactId);
        }else{}
        
        if(IsworkOrder){
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_IVRWO, '3465'); 
            ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_IVRVENDOR, 'Y');
        }       
        
        // execute controller
        ScreenpopController controller = new ScreenpopController();
        PageReference nextPage = controller.init();
        
        // check result
        String url = nextPage == null ? null : nextPage.getUrl();        
        if(url == null){
            throw new AssertException('Case not created!');
        }else{}
        System.debug('>>>>>>>> URL = [' + url + ']');
        
        if(url.length() != 41){
            throw new AssertException('Unexpected URL format [' + url + ']');
        }else{}
        Id newCaseId = Id.valueOf(url.substring(18, 36));        
        System.debug('>>>>>>>> Case ID = [' + newCaseId + ']');
        
        List<Case> cases = [select id, Reference_Number__c, CaseNumber, Status, RecordType.Name, 
                            Last_Customer_Interaction_ID__c, Last_Customer_Interaction_Type__c, CreatedDate
                            from Case where id = : newCaseId];
        
        if(cases == null || cases.size() < 1 || cases.get(0) == null){
            throw new AssertException('Case [' + newCaseId + '] not found!');
        }else{}
        Case c = cases.get(0);
        System.debug('>>>>>>>> Case Reference Number = [' + c.Reference_Number__c + ']');        
        System.assert(c.Status == 'New', 'Unexpected case status [' + c.Status + ']!');
        System.assert(c.CaseNumber == c.Reference_Number__c, 'Case and Reference number don\'t match!');
        System.assert(connId == c.Last_Customer_Interaction_ID__c, 'Unexpected connid [' + c.Last_Customer_Interaction_ID__c + ']!');
        if(startDT < c.CreatedDate) {
            System.assert(MEDIA_TYPE == c.Last_Customer_Interaction_Type__c, 'Unexpected media type [' + c.Last_Customer_Interaction_Type__c + ']!');
            if(intent == null || ''.equals(intent)) {       
                System.assert(c.RecordTypeId == ScreenpopController.CaseTypesByIntent.get(ScreenpopController.INTENT_OTHER.toLowerCase()), 'Unexpected case record type ['  + c.RecordType.Name + ']');
            }
            else{
                System.assert(c.RecordTypeId == ScreenpopController.CaseTypesByIntent.get(intent.toLowerCase()), 'Unexpected case record type ['  + c.RecordType.Name + ']');
            }
        }
        
        return c; // in case additional assertions needed
    }
    
    // creates dummy cases
    static Id createCase(String intent, String refNo) {
        
        intent = intent == null ? ScreenpopController.INTENT_OTHER : intent.toLowerCase();
        Id recTypeId = ScreenpopController.CaseTypesByIntent.containsKey(intent) 
            ? ScreenpopController.CaseTypesByIntent.get(intent) : null;
        
        Case c = recTypeId == null ? new Case() : new Case(RecordTypeId = recTypeId);
        c.Origin = 'Phone';
         if(refNo != null) {
            c.Reference_Number__c = refNo;
           // update c;
        }else{}
        insert c;        
        
       
        
        return c.Id;        
    }
    
    @isTest
    static void testPopTask(){
         
        final string SFDCRecId;

        //Set up test data
        Account acc = createDummyAccount();
        
        Case c = new Case();
        c.ownerID = UserInfo.getUserId();
        c.AccountId = acc.Id;
        insert c;
        
        task t = new Task();
        t.ownerId = UserInfo.getUserId();
        t.WhatId = c.Id;
        insert t;
        
        SFDCRecId = id.valueof(t.id);
        
        PageReference pageRef = Page.Screenpop;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put(ScreenpopController.PARAM_SFDCRecId, SFDCRecId);
        
        ScreenpopController controller = new ScreenpopController();
        controller.init();

    }
    
    static Account createDummyAccount() {
        
        Account client = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId());
        client.Name = 'DUMMY ACCOUNT';
        client.Common_Name__c = 'DUM';
        
        insert client;
        System.debug('>>>>>>>> Account created = ' + client);
        return client;
    }
    
    // create dummy test location
    static Id createDummyLocation(Account client) {        
        
        Account location = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId());
        location.Name = 'DUMMY LOCATION';
        location.ParentId = client.Id;
        location.AccountNumber = 'DUM' + ((Math.random() * 10));
        
        insert location;
        System.debug('>>>>>>>> Location created = ' + location);
        return location.Id;       
    }
    
    // create dummy test asset
    static Id createDummyAsset(Id locId) {        
        Asset a = new Asset();
        a.Name = 'DUMMY ASSET';
        a.AccountId = locId;
        a.Location__c = locId;        
        insert a;
        return a.Id;        
    }
    
    static Id createDummyContact(Id parentId) {
        Contact c = new Contact();
        c.AccountId = parentId;
        c.LastName = 'CONTACT';
        c.FirstName = 'DUMMY';
        insert c;
        return c.Id;        
    }

}