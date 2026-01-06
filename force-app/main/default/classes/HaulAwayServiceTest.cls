@isTest(seeAllData = false) 
public class HaulAwayServiceTest{
    //Private constant for customer service profile name
    //private static final string CUSTOMER_SERVICE = 'Customer Service';
    public static final String BRAZIL = 'Brazil';
    public static final string JUNK_REMOVAL = 'Junk Removal';
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    
    @TestSetup
    static void setup(){
        //Creating a user with the 'Customer Service profile using test factory
        //Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        // User usr = TestDataFactory.createUser(p);
        //Database.insert(usr);
        
        //Creating a test case record with Haul Away Service fields 
        Case caseRecord = new Case();
        caseRecord.Is_Haul_Away_Service__c = true;
        caseRecord.Haul_Away_information__c = HaulAwayService.Haul_Away_Service_assetHaulerAvailable;
        caseRecord.Haul_Away_Vendor__c = HaulAwayService.Haul_Away_Vendor_Check_Sammy_API;
        insert caseRecord;
        
        //Creating and inserting a custom code switch record
        Code_Switch__c codeswitch = new Code_Switch__c(
            Name='Haul_Away',
            Switch_off__c = false );
        insert Codeswitch;
        
        //Changes for SDT-39632
        Code_Switch__c qLValidationsetting = QuoteTestDataFactory.createCodeSwitch('New_Quote_Validation',false);
        Insert qLValidationsetting;
        
        //Creating and inserting a 'Haul Away Service product record
        Product2 product = new Product2(Name = 'Haul Away Service', IsActive = true);
        insert product;
        
        //Create an Opportunity that links to the case
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addMonths(1), Case__c = caseRecord.Id);
        insert opp;
        
        //Create a Quote that links to the Opportunity
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opp.Id);
        insert quote;
        
        SBQQ__Quote__c quoteWithoutCase = new SBQQ__Quote__c();
        insert quoteWithoutCase;
        
        SBQQ__QuoteLine__c quoteLineRecord = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = product.Id);
        insert quoteLineRecord;
        
        Account GotJunk= new Account(Name= HaulAwayService.Haul_Away_Vendor_Got_Junk,
                                    AccountNumber = HaulAwayService.Haul_Away_Vendor_Got_Junk_API );
        Account CheckSammy = new Account(Name = HaulAwayService.Haul_Away_Vendor_Check_Sammy,
                                        AccountNumber = HaulAwayService.Haul_Away_Vendor_Check_Sammy_API);
        Account JunkKing = new Account(Name = HaulAwayService.Haul_Away_Vendor_Junk_King,
                                      AccountNumber = HaulAwayService.Haul_Away_Vendor_Junk_King_API);
        
        insert new List<Account>{GotJunk,CheckSammy,JunkKing};
            }
   
    // Owner : TCS-AnjaliChalase
    // Story : 44574
    @isTest static void testGetHaulAwayVendorByLocationFor_GotJunk(){
        //SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        String haulAwayVendor = HaulAwayService.Haul_Away_Vendor_Got_Junk_API;
        String locationUS = Constant_Util.UNITED_STATES;
        String locationCA = Constant_Util.Canada_Shipping_Country;
        
        test.StartTest();
        String vendorIdUS = HaulAwayService.getHaulAwayVendorByLocation(HaulAwayVendor,locationUS);
        String vendorIdCA = HaulAwayService.getHaulAwayVendorByLocation(HaulAwayVendor,locationCA);
        
        system.assertNotEquals(null,vendorIdUS, 'Vendor ID for US should not be null');
        system.assertNotEquals(null,vendorIdCA, 'Vendor ID for Canada should not be null');
        test.StopTest();     
    }
    
    // Owner : TCS-AnjaliChalase
    // Story : 44574
    @isTest static void testGetHaulAwayVendorByLocationFor_CheckSammy(){
        //SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        String haulAwayVendor = HaulAwayService.Haul_Away_Vendor_Check_Sammy_API;
        String locationUS = Constant_Util.UNITED_STATES;
        String locationCA = Constant_Util.Canada_Shipping_Country;
        
        test.StartTest();
        String vendorIdUS = HaulAwayService.getHaulAwayVendorByLocation(HaulAwayVendor,locationUS);
        String vendorIdCA = HaulAwayService.getHaulAwayVendorByLocation(HaulAwayVendor,locationCA);
        
        system.assertNotEquals(null,vendorIdUS, 'Vendor ID for US should not be null');
        system.assertNotEquals(null,vendorIdCA, 'Vendor ID for Canada should not be null');
        test.StopTest();
    }
    
   // Owner : TCS-AnjaliChalase
    // Story : 44574
    @isTest static void testGetHaulAwayVendorByLocationFor_JunkKing(){
        //SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        String haulAwayVendor = HaulAwayService.Haul_Away_Vendor_Junk_King_API;
        String locationUS = Constant_Util.UNITED_STATES;
        String locationCA = Constant_Util.Canada_Shipping_Country;
        
        test.StartTest();
        String vendorIdUS = HaulAwayService.getHaulAwayVendorByLocation(HaulAwayVendor,locationUS);
        String vendorIdCA = HaulAwayService.getHaulAwayVendorByLocation(HaulAwayVendor,locationCA);
        
        system.assertNotEquals(null,vendorIdUS, 'Vendor ID for US should not be null');
        system.assertNotEquals(null,vendorIdCA, 'Vendor ID for Canada should not be null');
        test.StopTest();
    }
    
    // Owner : TCS-AnjaliChalase
    // Story : 44574
    @isTest static void testGetHaulAwayVendorByLocationFor_NotAvailable(){
        //SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        String haulAwayVendor = HaulAwayService.Haul_Away_Vendor_Not_Available;
        String locationUS = Constant_Util.UNITED_STATES;
        
        test.StartTest();
        String vendorIdNA = HaulAwayService.getHaulAwayVendorByLocation(haulAwayVendor ,locationUS);
        
        system.assertEquals(null,VENDORIdNA,'Expected null Not Available vendor.');
        test.StopTest();
    }
    
    // Owner : TCS-AnjaliChalase
    // Story : 44574
    @isTest static void testGetHaulAwayVendorByLocationFor_otherLocation(){
        //SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
        String haulAwayVendor = JUNK_REMOVAL;
        
        test.StartTest();
        String vendorIdBrazil = HaulAwayService.getHaulAwayVendorByLocation(haulAwayVendor ,BRAZIL);
        
        system.assertEquals(JUNK_REMOVAL,vendorIdBrazil,'Expected the same vendor name for an unsupported location');
        test.StopTest(); 
    }
    
    // Owner : TCS-AnjaliChalase
    // Story : 44574
    @isTest static void testGetHaulAwayVendorFor_GotJunk(){
        Account gotJunk = [SELECT Id,Name,Vendor_ID__c FROM Account WHERE Name=:HaulAwayService.Haul_Away_Vendor_Got_Junk LIMIT 1];
         
        Id VendorId = HaulAwayService.getHaulAwayVendor(gotJunk.Vendor_ID__c);
        
        system.assertEquals(gotJunk.Id,VendorId, 'The Vendor ID should match the expected account ID');
    }
    
    // Owner : TCS-AnjaliChalase
    // Story : 44574
     @isTest static void testGetHaulAwayVendorFor_CheckSammy(){
        Account checkSammy = [SELECT Id,Name,Vendor_ID__c FROM Account WHERE Name=:HaulAwayService.Haul_Away_Vendor_Check_Sammy LIMIT 1];
         
        Id VendorId = HaulAwayService.getHaulAwayVendor(checkSammy.Vendor_ID__c);
        
        system.assertEquals(checkSammy.Id,VendorId, 'The Vendor ID should match the expected account ID');
    }
    
    // Owner : TCS-AnjaliChalase
    // Story : 44574
     @isTest static void testGetHaulAwayVendorFor_JunkKing(){
        Account junkKing = [SELECT Id,Name,Vendor_ID__c FROM Account WHERE Name=:HaulAwayService.Haul_Away_Vendor_Junk_King LIMIT 1];
         
        Id VendorId = HaulAwayService.getHaulAwayVendor(junkKing.Vendor_ID__c);
        
        system.assertEquals(junkKing.Id,VendorId, 'The Vendor ID should match the expected account ID');
    }
    
    // Owner TCS-AnjaliChalase
    //Test method to verify the functionality of the 'getIsHaulAwaySerivce' 
    @isTest
    static void testGetIsHaulAwayService(){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        //Call the method to check if it it's a Haul Away Service case
        Boolean IsHaulAwayService = HaulAwayService.getIsHaulAwayService(testCase.Id);
        Test.stopTest();
        system.assertEquals(true,IsHaulAwayService,'Expected the case to be a Haul Away Service');
        
    }
    // Owner TCS-AnjaliChalase
    //Test method to verify the functionality of the 'getIsHaulAwaySerivceCodeSwitchOn()'
    @isTest
    static void testGetIsHaulAwayServiceSwitchOn(){
        Test.startTest();
        Boolean IsSwitchOn = HaulAwayService.getIsHaulAwayServiceCodeSwitchOn();
        Test.stopTest();
        system.assertEquals(false,isSwitchOn,'Expected the Haul Away switch to be off');
        
    }
    
    // Owner TCS-AnjaliChalase
    //Test method to verify the functionality of the 'assignDefaultsToHaulAwayQL()'
    @isTest
    static void testAssignDefaultsToHaulAwayQL(){
        SBQQ__Quoteline__c quoteLineRecord = [SELECT Id,SBQQ__Quote__c,SBQQ__ProductName__c,SBQQ__UnitCost__c  FROM SBQQ__Quoteline__c WHERE SBQQ__ProductName__c = 'Haul Away Service' LIMIT 1];
        //quoteLineRecord.SBQQ__Quote__c = quoteRecord.Id;
        //insert quoteLineRecord;
        system.debug('QuoteLine Product Name before method call:'+ QuoteLineRecord.SBQQ__ProductName__c);
        Test.startTest();
        HaulAwayService.assignDefaultsToHaulAwayQL(quoteLineRecord);
        Test.stopTest();
        system.assertEquals(0, quoteLineRecord.SBQQ__UnitCost__c,'Expected Unit Cost to be 0 for Haul Away Service Product');
    }
    
    // Owner TCS-AnjaliChalase
    //Test method to verify the functionality of the 'getIsHaulAwayServiceforQuote'
    @isTest
    static void testGetIsHaulAwayServiceforQuote_ValidCase(){
        SBQQ__Quote__c testQuote =[SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c!=null LIMIT 1];
        Test.startTest();
        Boolean isHaulAwayService = HaulAwayService.getIsHaulAwayServiceforQuote(testQuote.Id);
        Test.stopTest();
        system.assertEquals(true, isHaulAwayService,'Expected the quote to be associated with a Haul Away Service');
    }
    
    // Owner TCS-AnjaliChalase
    @isTest
    static void testGetIshaulAwayServiceforQuote_NoCase(){
        SBQQ__Quote__c quoteWithoutCase =[SELECT Id,SBQQ__Quote__c.Name FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = null LIMIT 1];
        Test.startTest();
        Boolean isHaulAwayService = HaulAwayService.getIsHaulAwayServiceforQuote(quoteWithoutCase.Id);
        Test.stopTest();
        system.assertEquals(false, isHaulAwayService,'Expected the quote not to be associated with a Haul Away Service');
    }
    
    // Owner TCS-AnjaliChalase
    // Story : 44574
    @isTest static void testHaulAwayCheckForBypassValidation(){
        SBQQ__Quote__c testQuote = [SELECT Id,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_vendor__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c!= NULL LIMIT 1];
        
        Set<Id> quoteIdSet = new Set<Id>{testQuote.Id};
            system.debug('Is_Haul_Away_Service__c:'+ testQuote.SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c);
            system.debug('Haul_Away_Vendor__c:'+ testQuote.SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c);
        
        test.StartTest();
        set<Id> result = HaulAwayService.haulAwayCheckForBypassValidation(testQuote, quoteIdSet);
        system.debug('Result.Set:' +result);
        test.StopTest();
        System.assert(result.contains(testQuote.Id),'Quote should be added to haulAwayQuoteSet');
    }
   
     /*
* @vendor   :  TCS
* @story    :  //SDT 45079
* @author   :  TCS-Anjali Chalase
* @Coverage : HaulAwayService
*/
    @isTest static void testGetIfGenesysEnabledUser(){
        
        User testUser1 = new User(
        FirstName = 'TestHaul',
        LastName = 'UserHaul',
        Email = 'test@example.com',
        Alias = 'tuser',
        Username = 'testuser1234Haul@example.com.salesforce',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'LIMIT 1].Id,
        User_Categorization_Code__c = 'CSGEN',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',     
        LanguageLocaleKey = 'en_US'
        );
        insert testUser1;
        
        User testUser = [SELECT Id FROM User WHERE User_Categorization_Code__c = 'CSGEN'LIMIT 1];
        
        CSR_User_Data_Setup__mdt userDataSetup = [SELECT Is_Genesys_User__c, GR_Service_Flag__c FROM CSR_User_Data_Setup__mdt WHERE MasterLabel = 'CSGEN' LIMIT 1];
        
        HaulAwayService.genUserDetalsWrapper result = HaulAwayService.getIfGenesysEnabledUser(testUser1.Id);
        
        //system.assert(result!=null,'Result should not be null.');
        System.assert(result.isGenesysEnabledUser,'User Should be Genesys enabled');
        system.assertEquals(userDataSetup.GR_Service_Flag__c,result.genFlag,'flag should match expected value');
    }
    
      /*
* @vendor   :  TCS
* @story    :  //SDT 45079
* @author   :  TCS-Anjali Chalase
* @Coverage : HaulAwayService
*/
    
    @isTest static void testGetIfLastAgentAvailable(){
        
        Boolean result1 = HaulAwayService.getIfLastAgentAvailable('SomeAgent');
        system.assert(result1, 'Should return true when userLastAgent is non-empty');
        
        Boolean result2 = HaulAwayService.getIfLastAgentAvailable('');
        system.assert(!result2,'Should return false when userLastAgent is empty');
    }
    
     /*
* @vendor   :  TCS
* @story    :  //SDT 45079
* @author   :  TCS-Anjali Chalase
* @Coverage : HaulAwayService
*/
    
    @isTest static void testCreateGenesysRecord(){
        Task testTask = new Task(
        Subject = 'Test Task',
        ActivityDate = Date.Today(),    
        //WhatId = Quote.Id,
        OwnerId = UserInfo.getUserId(),
        Status = 'Open'
        );
        insert testTask;
        SBQQ__Quote__c testQuote = [SELECT Id,SBQQ__Status__c,Next_Action_Due_Date__c,Priority__c,SBQQ__Opportunity2__r.Id,
                                    SBQQ__Opportunity2__r.Case__r.Id,SBQQ__Opportunity2__r.Case__r.CaseNumber,
                                    SBQQ__Opportunity2__r.Case__r.Reference_Number__c,
                                    SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c,
                                    SBQQ__Opportunity2__r.Case__r.Case_Reason__c,SBQQ__Opportunity2__r.Case__r.SLa_Service_Date_Time__c,
                                    SBQQ__Account__r.Parent.Customer_Code__c,SBQQ__Account__r.Parent.Primary_Segment__c,
                                    SBQQ__Account__r.Location_Code__c,SBQQ__Account__r.tz__Timezone_F__c FROM SBQQ__Quote__c LIMIT 1];
        
        Boolean result = HaulAwayService.createGenesysRecord(testQuote,Null,UserInfo.getUserId(),'GEN_FLAG_TEST',testTask);
        system.debug('Genesys Record Creation Result:' +result);
        
        List<Genesys_Routing__c> genesysRecords = [SELECT Id,SFDCObjRecordID__c,SFDCserviceFlag__c FROM Genesys_Routing__c WHERE SFDCObjRecordID__c = :testTask.Id];
        
        system.assertEquals(1,genesysRecords.size(),'Genesys record was not created!');
        system.assertEquals('GEN_FLAG_TEST',genesysRecords[0].SFDCserviceFlag__c,'Genesys service Flag does not match.');
            }
    
     /*
* @vendor   :  TCS
* @story    :  //SDT 45079
* @author   :  TCS-Anjali Chalase
* @Coverage : HaulAwayService
*/
    
    @isTest public static void testCreateGenesysTask(){
        Test.startTest();
        List<User> testRunUserList = new List<User>();
        
        //Profile p = TestDataFactory.getProfile(SYS_ADMIN); //Commented for SDT-33448
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);  //Modified for SDT-33448
        
        User usr = TestDataFactory.createUser(p);
        usr.FirstName = 'testuser##9999';
        usr.Bypass_Validation__c = true;
        testRunUserList.add(usr);
        
         User nonByPassValidationUser = TestDataFactory.createUser(p);
        nonByPassValidationUser.Username = 'SystemAdmin'+ String.valueof(system.now().millisecond())+'@testorg.com.wm';
        testRunUserList.add(nonByPassValidationUser);
        Database.insert(testRunUserList);
        
        System.runAs(usr){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Case__c =:testCase.Id LIMIT 1];
        SBQQ__Quote__c testQuote = [SELECT Id,Name,SBQQ__Status__c,Next_Action_Due_Date__c,Priority__c,SBQQ__Opportunity2__r.Id,
                                    SBQQ__Opportunity2__r.Case__r.Id,SBQQ__Opportunity2__r.Case__r.CaseNumber,
                                    SBQQ__Opportunity2__r.Case__r.Reference_Number__c,
                                    SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c,
                                    SBQQ__Opportunity2__r.Case__r.Case_Reason__c,SBQQ__Opportunity2__r.Case__r.SLa_Service_Date_Time__c,
                                    SBQQ__Account__r.Parent.Customer_Code__c,SBQQ__Account__r.Parent.Primary_Segment__c,
                                    SBQQ__Account__r.Location_Code__c,SBQQ__Account__r.tz__Timezone_F__c FROM SBQQ__Quote__c LIMIT 1];
        
        User testUser1 = new User(
        FirstName = 'TestHaul',
        LastName = 'UserHaul',
        Email = 'test@example.com',
        Alias = 'tuser',
        Username = 'testuser1234Haul@example.com.salesforce',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'LIMIT 1].Id,
        User_Categorization_Code__c = 'CSGEN',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',     
        LanguageLocaleKey = 'en_US'
        );
        insert testUser1;   
        
       // User testUser = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        
        Task resultTask = HaulAwayService.createGenesysTask(testQuote,testUser1.Id);
        Test.StopTest();
        
        system.assertNotEquals(null,resultTask,'The returned task should not be null');
        system.assertEquals(testUser1.Id,resultTask.OwnerId,'Task owner should be assigned correctly');
        
        String expectedSubject = HaulAwayService.Haul_Away_NewTask_Subject +testQuote.Name;
        String actualSubject = resultTask.Subject;
       
        system.assert(actualSubject.startsWith(expectedSubject),'Task subject should include quote name');
        system.assertEquals(testcase.Id,resultTask.WhatId,'WhatId should be linked to the related case');
    }
    }
}