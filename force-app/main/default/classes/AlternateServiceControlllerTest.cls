//Class: AlternateServiceControlllerTest
//Purpose: Test class for the AlternateServiceController
//Author: Seema Dhikale
//Date: 25-June-2025
//Covering AlternateServiceController Class along with other test classes with 100% code coverage
@isTest(seeAllData =false)
public class AlternateServiceControlllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string CUSTOMER_SERVICE = 'Customer Service';
    private static final string SSM = 'SSM';
    private static final string EMAIL = 'testfrom@test.com';
    private static final string ALTERNATIVE_EMAIL = 'test@test.com';
    private static final string FOREMAIL = 'testemail@test.com';
    private static final string EMAIL_SUBJECT = 'Approved';
    private static final string NAME = 'test';
    private static final string EMAIL_BODY = 'Test \n Test1 \n test2';
    private static final string EMAIL_BODY1 = 'Test \n\n------';
    private static final string REJECTED = 'Rejected';
    private static final string APPROVALS = 'Approvals';
    private static final string PO_PSI_VALUE = 'PO Number;PSI';
    private static final string DISTRICT_MANAGER = 'District Manager';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string SERVICE_APPROVER = 'Service_Approver__c';
    private static final string VALUE_TEST = 'Test';
    private static final string CHECK = 'Check';
    // private static final string MIXED = 'Mixed';
    
    @testSetup static void setup()  {
        test.startTest();
        CodeSwitchTestData.CodeSwitchData();
        Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(adminProfile);
        usr.Bypass_Validation__c = TRUE;
        usr.Genesys_Enabled__c = false;
        usr.FirstName = 'testuser#9999';
        Database.insert(usr);
        
        Profile customerServiceProfile = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        User usrCSR = TestDataFactory.createUser(customerServiceProfile);
        usrCSR.Bypass_Validation__c = TRUE;
        usrCSR.Genesys_Enabled__c = false;
        usrCSR.FirstName = 'testCSRuser#9999';
        Database.insert(usrCSR); 
        
        Profile SSMProfile = TestDataFactory.getProfile(SSM);
        User usrSSM = TestDataFactory.createUser(SSMProfile);
        usrSSM.Bypass_Validation__c = TRUE;
        usrSSM.Genesys_Enabled__c = false;
        usrSSM.FirstName = 'testSSMuser#9999';
        Database.insert(usrSSM);
            
        //Changes for SDT-39632
        //Code_Switch__c qLValidationsetting = QuoteTestDataFactory.createCodeSwitch('New_Quote_Validation',false);
        //Insert qLValidationsetting;
        
        User salesUser = TestDataFactory.createUser(adminProfile);
        salesUser.Bypass_Validation__c = TRUE;
        salesUser.Genesys_Enabled__c = false;
        salesUser.FirstName = 'TestSalesUser#41186';
        salesUser.User_categorization_code__c = 'SALESGEN';
        INSERT salesUser;
        
        system.runas(usr) {
            
            Account acc1 = new Account(Name = 'Test');
            insert acc1;
            
            Account acc2 = new Account(Name = 'Test2', ParentId = acc1.Id,Status__c ='Active');
            insert acc2;
            
            Id cseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Service Case').getRecordTypeId();
            
            Case cse = new Case(Accountid = acc2.id,Haul_Away_Service_Booked__c = 'No',Case_Sub_Type__c = 'Permanent',Case_Reason__c = 'Existing Location',Case_Type__c = 'New Service',recordtypeId = cseRecordTypeId);
            insert cse;
            
            Product2 prod = new Product2(Name = 'Extra Pickup');
            insert prod;
            
            Product2 prod2 = new Product2(Name = 'Pickup',Family = 'Waste Stream');
            insert prod2;
            Opportunity opp = new Opportunity(Name = 'Test Opp',Case__c = cse.Id,StageName = 'Proposal',CloseDate = system.today());
            insert opp;
            
            Business_Rule__c businessrule = new Business_Rule__c(Accountid__c = acc1.id, 
                                                                 Container__c = 'Equipment', Service__c = 'Permanent', 
                                                                 Request_Type__c = 'New Service', Schedule_Type__c = 'Permanent',
                                                                 Active__c = true,Effective_Date__c = System.today() - 1,
                                                                 Channel_Req__c= 'Test Channel Requirements',Channel__c = 'WM Portal',
                                                                 RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId() );
            insert businessrule;       
            
            //Quote Creation
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc2.Id;
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Opportunity2__c = opp.Id;
            quote.SBQQ__StartDate__c = system.today();
            quote.Business_Rule__c = businessrule.Id;
            
            insert quote;
            
            SBQQ__Quote__c quoteWithNoBR = new SBQQ__Quote__c();
            quoteWithNoBR.SBQQ__Account__c = acc2.Id;
            quoteWithNoBR.SBQQ__Status__c = 'Approved';
            quoteWithNoBR.SBQQ__Opportunity2__c = opp.Id;
            quoteWithNoBR.SBQQ__StartDate__c = system.today();
            
            insert quoteWithNoBR;
            
            //QuoteLine Creation
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Quote__c =  quote.Id;
            ql.SBQQ__Product__c = prod2.Id;
            ql.Equipment_Size__c = 'GALS-40';
            insert ql;
            
            SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c();
            ql1.SBQQ__Quote__c =  quote.Id;
            ql1.SBQQ__Product__c = prod.Id;
            ql1.Equipment_Size__c = 'GALS-40';
            
            insert ql1;
            
             Service_Approver__c serviceApprover = new Service_Approver__c(Business_Rule__c = businessrule.id, Account__c = businessrule.Accountid__c,
                                                                          Email__c = 'cdd@ymail.com',Active__c = true,
                                                                          Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Email').getRecordTypeId());
            
            insert serviceApprover;   
        }
        test.stoptest();
        
    } 
      /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName : testPopulateSysdefaultFieldForQLsNormalflow
* @Coverage :QuoteTriggerHelper.populateSysdefaultFieldForQLs()
			 AlternateServiceController.removeAttributesNode()
			 AlternateServiceController.frameSysFieldqLine()
*/
    //asset values for 7 fields are populated on Quote and Quotelines, now user click on confirm configuration button
    @isTest static void testPopulateSysdefaultFieldForQLsNormalflow()
    {
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr){
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            insert trashStream;

            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = trashStream.Id,
                                                                 SBQQ__Quantity__c = 2,
                                                                 Equipment_Size__c = 'YRDS-3',
                                                                 Material_Type__c = 'Single Stream Recycling',
                                                                 Occurrence_Type__c ='SCH',
                                                                 duration__c ='PERM');
            insert parentQL;
            SBQQ__QuoteLine__c quoteLinesInDraftStatus = [select Id,SBQQ__Quantity__c,toLabel(Equipment_Size__c),SBQQ__Product__r.Name,SBQQ__ProductName__c,toLabel(Occurrence_Type__c),
                         toLabel(Duration__c),toLabel(Schedule_Frequency__c),Service_Schedule__c,Final_Frequency__c,Frequency_Interval__c,Service_Days__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
        	Integer draftQuantity = Integer.valueOf(quoteLinesInDraftStatus.SBQQ__Quantity__c);
            String draftEquipmentSize = quoteLinesInDraftStatus.Equipment_Size__c;
            String draftProductName = quoteLinesInDraftStatus.SBQQ__ProductName__c;
            String draftOccurenceType = quoteLinesInDraftStatus.Occurrence_Type__c;
            String draftDuration = quoteLinesInDraftStatus.Duration__c;
            
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        	testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
            update testQuote;
            
            SBQQ__QuoteLine__c quoteLine = [select Id,SysHistoryTracking__c,SBQQ__Quantity__c,toLabel(Equipment_Size__c),SBQQ__Product__r.Name,SBQQ__ProductName__c,toLabel(Occurrence_Type__c),
                         toLabel(Duration__c),toLabel(Schedule_Frequency__c),Service_Schedule__c,Final_Frequency__c,Frequency_Interval__c,Service_Days__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
            system.assertNotEquals(quoteLine.SysHistoryTracking__c,'' ,'when quote moves from draft to any othere status field value is generated with JSON');
            System.assertEquals(draftQuantity, Integer.valueOf(quoteLinesInDraftStatus.SBQQ__Quantity__c),'test if values getting saved appropriatly');
            System.assertEquals(draftEquipmentSize, quoteLine.Equipment_Size__c,'test if values getting saved appropriatly');
            System.assertEquals(draftProductName, quoteLine.SBQQ__ProductName__c,'test if values getting saved appropriatly');
            System.assertEquals(draftOccurenceType, quoteLine.Occurrence_Type__c,'test if values getting saved appropriatly');
            System.assertEquals(draftDuration, quoteLine.Duration__c,'test if values getting saved appropriatly');
            test.stopTest();
        }
    }
     /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName : testPopulateSysdefaultFieldForQLsUpdateQuantity
* @Coverage :QuoteTriggerHelper.populateSysdefaultFieldForQLs()
			 AlternateServiceController.getDraftAlternateServiceDetails()
*/
	//asset values for 7 fields are populated on Quote and Quotelines, now user update quantity and click on confirm configuration button
	@isTest static void testPopulateSysdefaultFieldForQLsUpdateQuantity()
    {
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr){
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
			SBQQ__QuoteLine__c parentQL = [select Id,SysHistoryTracking__c,SBQQ__Quantity__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
           			
            parentQL.SBQQ__Quantity__c = 6;
            update parentQL;
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        	testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
            update testQuote;
            
            SBQQ__QuoteLine__c quoteLineSysField = [select Id,SysHistoryTracking__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
            
            SBQQ__QuoteLine__c quoteLine = AlternateServiceController.getDraftAlternateServiceDetails(quoteLineSysField.SysHistoryTracking__c);
            system.assertNotEquals(quoteLine.SysHistoryTracking__c,'' ,'when quote moves from draft to any othere status field value is generated with JSON');
            System.assertEquals(6, Integer.valueOf(quoteLine.SBQQ__Quantity__c),'test if values getting saved appropriatly');
            test.stopTest();
        }
    }
     /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName : testPopulateSysdefaultFieldForQLsUpdateEquipmentSize
* @Coverage :QuoteTriggerHelper.populateSysdefaultFieldForQLs()
			 AlternateServiceController.removeAttributesNode()
			 AlternateServiceController.frameSysFieldqLine()
*/
    //asset values for 7 fields are populated on Quote and Quotelines, now user update Equipment size 30 yards and click on confirm configuration button
    @isTest static void testPopulateSysdefaultFieldForQLsUpdateEquipmentSize()
    {
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testuser#9999' LIMIT 1];
        system.runAs(usr){
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = [select Id,SysHistoryTracking__c,Equipment_Size__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
           			
            parentQL.Equipment_Size__c = 'YRDS-30';
            update parentQL;
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        	testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
            update testQuote;
            
            SBQQ__QuoteLine__c quoteLineSysField = [select Id,SysHistoryTracking__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
            
            SBQQ__QuoteLine__c quoteLine = AlternateServiceController.getDraftAlternateServiceDetails(quoteLineSysField.SysHistoryTracking__c);
            system.assertNotEquals(quoteLine.SysHistoryTracking__c,'' ,'when quote moves from draft to any othere status field value is generated with JSON');
            System.assertEquals('30 Yards', quoteLine.Equipment_Size__c,'latest updated equipment size');
            test.stopTest();
        }
    }
    
         /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName : testPopulateSysdefaultFieldForQLsUpdateEquipmentSizeBySSMUser
* @Coverage :QuoteTriggerHelper.populateSysdefaultFieldForQLs()
			 AlternateServiceController.removeAttributesNode()
			 AlternateServiceController.frameSysFieldqLine()
*/
    //asset values for 7 fields are populated on Quote and Quotelines, now user update Equipment size 30 yards and click on confirm configuration button
    @isTest static void testPopulateSysdefaultFieldForQLsUpdateEquipmentSizeBySSMUser()
    {
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testSSMuser#9999' LIMIT 1];
        system.runAs(usr){
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = [select Id,SysHistoryTracking__c,Equipment_Size__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
           			
            parentQL.Equipment_Size__c = 'YRDS-30';
            update parentQL;
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        	testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
            update testQuote;
            
            SBQQ__QuoteLine__c quoteLineSysField = [select Id,SysHistoryTracking__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
            
            SBQQ__QuoteLine__c quoteLine = AlternateServiceController.getDraftAlternateServiceDetails(quoteLineSysField.SysHistoryTracking__c);
            system.assertNotEquals(quoteLine.SysHistoryTracking__c,'' ,'when quote moves from draft to any othere status field value is generated with JSON');
            System.assertEquals('30 Yards', quoteLine.Equipment_Size__c,'latest updated equipment size');
            test.stopTest();
        }
    }
    
     /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName : testPopulateSysdefaultFieldForQLsNormalflowForCSRUser
* @Coverage :QuoteTriggerHelper.populateSysdefaultFieldForQLs()
			 AlternateServiceController.removeAttributesNode()
			 AlternateServiceController.frameSysFieldqLine()
*/
    //asset values for 7 fields are populated on Quote and Quotelines, now user click on confirm configuration button
    @isTest static void testPopulateSysdefaultFieldForQLsNormalflowForCSRUser()
    {
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testCSRuser#9999' LIMIT 1];
        system.runAs(usr){
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            Product2 trashStream = new Product2(Name = 'Trash', Family = 'Waste Stream', SBQQ__Component__c = TRUE, ProductCode = 'T');
            insert trashStream;

            SBQQ__QuoteLine__c parentQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id,
                                                                 SBQQ__Product__c = trashStream.Id,
                                                                 SBQQ__Quantity__c = 2,
                                                                 Equipment_Size__c = 'YRDS-3',
                                                                 Material_Type__c = 'Single Stream Recycling',
                                                                 Occurrence_Type__c ='SCH',
                                                                 duration__c ='PERM');
            insert parentQL;
            SBQQ__QuoteLine__c quoteLinesInDraftStatus = [select Id,SBQQ__Quantity__c,toLabel(Equipment_Size__c),SBQQ__Product__r.Name,SBQQ__ProductName__c,toLabel(Occurrence_Type__c),
                         toLabel(Duration__c),toLabel(Schedule_Frequency__c),Service_Schedule__c,Final_Frequency__c,Frequency_Interval__c,Service_Days__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
        	Integer draftQuantity = Integer.valueOf(quoteLinesInDraftStatus.SBQQ__Quantity__c);
            String draftEquipmentSize = quoteLinesInDraftStatus.Equipment_Size__c;
            String draftProductName = quoteLinesInDraftStatus.SBQQ__ProductName__c;
            String draftOccurenceType = quoteLinesInDraftStatus.Occurrence_Type__c;
            String draftDuration = quoteLinesInDraftStatus.Duration__c;

            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        	testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
            update testQuote;
            
            SBQQ__QuoteLine__c quoteLine = [select Id,SysHistoryTracking__c,SBQQ__Quantity__c,toLabel(Equipment_Size__c),SBQQ__Product__r.Name,SBQQ__ProductName__c,toLabel(Occurrence_Type__c),
                         toLabel(Duration__c),toLabel(Schedule_Frequency__c),Service_Schedule__c,Final_Frequency__c,Frequency_Interval__c,Service_Days__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
            system.assertNotEquals(quoteLine.SysHistoryTracking__c,'' ,'when quote moves from draft to any othere status field value is generated with JSON');
            System.assertEquals(draftQuantity, Integer.valueOf(quoteLinesInDraftStatus.SBQQ__Quantity__c),'test if values getting saved appropriatly');
            System.assertEquals(draftEquipmentSize, quoteLine.Equipment_Size__c,'test if values getting saved appropriatly');
            System.assertEquals(draftProductName, quoteLine.SBQQ__ProductName__c,'test if values getting saved appropriatly');
            System.assertEquals(draftOccurenceType, quoteLine.Occurrence_Type__c,'test if values getting saved appropriatly');
            System.assertEquals(draftDuration, quoteLine.Duration__c,'test if values getting saved appropriatly');
            test.stopTest();
        }
    }
     /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName : testPopulateSysdefaultFieldForQLsUpdateQuantityForCSRUser
* @Coverage :QuoteTriggerHelper.populateSysdefaultFieldForQLs()
			 AlternateServiceController.removeAttributesNode()
			 AlternateServiceController.frameSysFieldqLine()
*/
	//asset values for 7 fields are populated on Quote and Quotelines, now user update quantity and click on confirm configuration button
	@isTest static void testPopulateSysdefaultFieldForQLsUpdateQuantityForCSRUser()
    {
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testCSRuser#9999' LIMIT 1];
        system.runAs(usr){
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
			SBQQ__QuoteLine__c parentQL = [select Id,SysHistoryTracking__c,SBQQ__Quantity__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
           			
            parentQL.SBQQ__Quantity__c = 6;
            update parentQL;
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        	testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
            update testQuote;
            
            SBQQ__QuoteLine__c quoteLineSysField = [select Id,SysHistoryTracking__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
            
            SBQQ__QuoteLine__c quoteLine = AlternateServiceController.getDraftAlternateServiceDetails(quoteLineSysField.SysHistoryTracking__c);
            system.assertNotEquals(quoteLine.SysHistoryTracking__c,'' ,'when quote moves from draft to any othere status field value is generated with JSON');
            System.assertEquals(6, Integer.valueOf(quoteLine.SBQQ__Quantity__c),'test if values getting saved appropriatly');
            test.stopTest();
        }
    }
     /*
* @Owner : TCS-Seema Dhikale
* @Story : 44716
* @MethodName : testPopulateSysdefaultFieldForQLsUpdateEquipmentSizeForCSRUser
* @Coverage :QuoteTriggerHelper.populateSysdefaultFieldForQLs()
			 AlternateServiceController.removeAttributesNode()
			 AlternateServiceController.frameSysFieldqLine()
*/
    //asset values for 7 fields are populated on Quote and Quotelines, now user update Equipment size 30 yards and click on confirm configuration button
    @isTest static void testPopulateSysdefaultFieldForQLsUpdateEquipmentSizeForCSRUser()
    {
        User usr = [Select Id, FirstName FROM User WHERE FirstName =: 'testCSRuser#9999' LIMIT 1];
        system.runAs(usr){
            test.startTest();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
            testQuote = [SELECT Id,SBQQ__Type__c,Quote_Only__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c='Draft' LIMIT 1];
            
            SBQQ__QuoteLine__c parentQL = [select Id,SysHistoryTracking__c,Equipment_Size__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
           			
            parentQL.Equipment_Size__c = 'YRDS-30';
            update parentQL;
            testQuote.SBQQ__Status__c = Constant_Util.QUOTE_PRODUCT_CONFIGURED;
        	testQuote.SBQQ__Type__c=Constant_Util.KEYWORD_EXCEPTION;
            update testQuote;
            
            SBQQ__QuoteLine__c quoteLineSysField = [select Id,SysHistoryTracking__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: testQuote.id and SBQQ__RequiredBy__c = null][0];
            
            SBQQ__QuoteLine__c quoteLine = AlternateServiceController.getDraftAlternateServiceDetails(quoteLineSysField.SysHistoryTracking__c);
            system.assertNotEquals(quoteLine.SysHistoryTracking__c,'' ,'when quote moves from draft to any othere status field value is generated with JSON');
            System.assertEquals('30 Yards', quoteLine.Equipment_Size__c,'latest updated equipment size');
            test.stopTest();
        }
    }
}