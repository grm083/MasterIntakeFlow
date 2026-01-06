/*************************************************************
@Name: IVRExitControllerTest
@Author: DineshKumar S
@CreateDate: 11/1/2019
@Description: Test class for IVRExitController
@UsedBy: IVRExitController
*************************************************************/
@isTest(seeAllData = false)
public class EmailAliasProcessBatchTest {

    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string TESTSUPPLIER = 'testsupplier';
    private static final string SUPPLIER = 'Vendor';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string COMPACTOR = 'COMPACTOR';
    private static final string CASE_NAME = 'First';
    private static final string PO_NUMBER = '1243';
    private static final string SENT = 'Sent';
    private static final string COMMERCIAL = 'Commercial';
    private static final string SCHEDULED = 'Scheduled';
    private static final string PICKUP = 'Pickup';
    public static final String MEDIA_TYPE_VOICE = 'voice';
    /**set the test data**/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
  	List<Email_Alias__mdt> eadata = [Select Id,Label from Email_Alias__mdt];
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(RITA,REPLY, acclist.get(0), usr);
            Database.insert(conlist);
            
            list<product2> productlist = TestDataFactory.createProduct(PRODUCT);
            productlist[0].Family = COMMERCIAL;
            productlist[0].ProductTypeSelected__c = COMPACTOR;
            Database.insert(productlist);
            
            list<Account> supplieracclist = TestDataFactory.createAccount(TESTSUPPLIER , usr, SUPPLIER);
            supplieracclist[0].AccountNumber = '600';
            Database.insert(supplieracclist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(ASSET_NAME , acclist.get(0), conlist.get(0),productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist[0].Status = Constant_Util.PENDING;
            caselist[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            list<Case> caselist1 = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist1[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist1[0].Status = Constant_Util.PENDING;
            caselist1[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist1[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            caselist.add(caselist1[0]);
            list<Case> caselist2 = TestDataFactory.createCase( CASE_NAME, acclist.get(0), conlist.get(0), usr, locationlist.get(0), assetlist.get(0));
            caselist2[0].PurchaseOrder_Number__c =  PO_NUMBER;
            caselist2[0].Status = Constant_Util.PENDING;
            caselist2[0].Case_Type__c = Constant_Util.PICKUP_CSTYPE;
            caselist2[0].Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
            caselist.add(caselist2[0]);
            Database.insert(caselist,false);
            String Header = 'Message-ID: <1234574MB0022227D61A03821A797F3F8F6550@COM> In-Reply-To: <4321574MB0022227D61A03821A797F3F8F6550@COM>';
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessageWithHeader(Subject, Body, caselist[0], Header);
            lstEM[0].FromAddress  = 'abc@wm.com';
            lstEM[0].ToAddress += eadata != null && eadata.size() > 0 ? eadata[0].Label : null;
            lstEM[0].CcAddress += eadata != null && eadata.size() > 1 ? eadata[1].Label : null;
            lstEM[0].Message_ID__c = '1234574MB0022227D61A03821A797F3F8F6550@COM';
            lstEM[0].To_Be_Processed__c = true;
            List<EmailMessage> lstEM1 = new List<EmailMessage>();
            lstEM1 = TestDataFactory.createEmailMessageWithHeader(Subject, Body, caselist[0], Header);
            lstEM1[0].Message_ID__c = '1234574MB0022227D61A03821A797F3F8F6550@COM';
            lstEM.add(lstEM1[0]);
            List<EmailMessage> lstEM2 = new List<EmailMessage>();
            lstEM2 = TestDataFactory.createEmailMessageWithHeader(Subject, Body, caselist[1], Header);
            lstEM2[0].FromAddress  = 'abc@wm.com';
            lstEM2[0].ToAddress += eadata != null && eadata.size() > 0 ? eadata[0].Label : null;
            lstEM2[0].CcAddress += eadata != null && eadata.size() > 1 ? eadata[1].Label : null;
            lstEM2[0].To_Be_Processed__c = true;
            lstEM2[0].Message_ID__c = '1234574MB0022227D61A03821A797F3F8F6550@COM';
            lstEM.add(lstEM2[0]);
            String Header1 = 'Message-ID: <1234574MF0022227D61A03821A797F3F8F6550@COM> In-Reply-To: <4321574MB0022227D61A03821A797F3F3F6550@COM>';
            List<EmailMessage> lstEM3 = new List<EmailMessage>();
            lstEM3 = TestDataFactory.createEmailMessageWithHeader(Subject, Body, caselist[2], Header1);
            lstEM3[0].FromAddress  = 'abc@wm.com';
            lstEM3[0].ToAddress += eadata != null && eadata.size() > 0 ? eadata[0].Label : null;
            lstEM3[0].CcAddress += eadata != null && eadata.size() > 1 ? eadata[1].Label : null;
            lstEM3[0].To_Be_Processed__c = true;
            lstEM3[0].Message_ID__c = '1234574MF0022227D61A03821A797F3F8F6550@COM';
            lstEM.add(lstEM3[0]);
            
            List<EmailMessage> lstEM4 = new List<EmailMessage>();
            lstEM4 = TestDataFactory.createEmailMessageWithHeader(Subject, Body, caselist[0], Header);
            lstEM4[0].FromAddress  = 'abc@wm.com';
            lstEM4[0].ToAddress += eadata != null && eadata.size() > 0 ? eadata[0].Label : null;
            lstEM4[0].CcAddress += eadata != null && eadata.size() > 1 ? eadata[1].Label : null;
            lstEM4[0].Message_ID__c = '';
            lstEM4[0].To_Be_Processed__c = true;
            lstEM.add(lstEM4[0]);
            Database.insert(lstEM);
            
            
        }
    }
    /**Test method to execute Batch with already existing EmailMessage.**/
    @isTest
    static void testEmailMessage() {
        User u = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(u){
            List<EmailMessage> emlst = [SELECT ID, RelatedToId, ParentId, Incoming, Message_ID__c, To_Be_Processed__c FROM EmailMessage Limit 49999];
            Test.StartTest();
            RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = true;
            EmailAliasProcessBatch batch = new EmailAliasProcessBatch();
            Database.executeBatch(batch);
            List<EmailMessage> emmsglst = [Select Id,ParentId from EmailMessage where Message_ID__c =: '1234574MB0022227D61A03821A797F3F8F6550@COM' and isDeleted = true];
            Test.StopTest();
            List<EmailMessage> nullmessageId = [SELECT Id, ParentId FROM EmailMessage WHERE Message_ID__c = '' and isDeleted = true];
            System.debug('size nullmessageId -- ' + nullmessageId.size());
            system.assert(emmsglst != null);
            system.assert(nullmessageId.isEmpty());
     
      }
    }

        /**Test method to execute Batch with already existing EmailMessage.**/
        @isTest
        static void testSchedule() {
            User u = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
            system.runAs(u){
                List<EmailMessage> emlst = [SELECT ID, RelatedToId, ParentId, Incoming, Message_ID__c, To_Be_Processed__c FROM EmailMessage Limit 49999];
                Test.StartTest();
                RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = true;
                String jobId = System.schedule('ScheduleApexClassTest',  '0 0 23 * * ?', new scheduledEmailAliasProcessBatch());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                System.assertEquals('0 0 23 * * ?', ct.CronExpression);
                System.assertEquals(0, ct.TimesTriggered);
                List<EmailMessage> emmsglst = [Select Id,ParentId from EmailMessage where Message_ID__c =: '1234574MB0022227D61A03821A797F3F8F6550@COM' and isDeleted = true];
                Test.StopTest();
                system.assert(emmsglst != null);
        }
    }
    /***Test method to execute Batch.***/
    @isTest
    static void testEmailAliasBatch() {
        User u = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(u){
            List<Email_Alias__mdt> eadata = [Select Id,Label from Email_Alias__mdt];
            List<EmailMessage> emlst = [SELECT ID, RelatedToId, ParentId, Incoming, Message_ID__c, To_Be_Processed__c FROM EmailMessage Limit 49999];
            Id clientRecId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Client').getRecordTypeId();
            Id locRecId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Location').getRecordTypeId();
            Account acc = [Select Id from Account where RecordTypeId =:ClientRecId Limit 1];
            Account loc = [Select Id,ParentId from Account where RecordTypeId =:locRecId  Limit 1];
            Contact con = [Select Id from Contact Limit 1];
            Asset asst = [Select Id from Asset Limit 1];
	    list<Case> caselist = TestDataFactory.createCase( CASE_NAME, acc, con, u, loc, asst);
            Database.Insert(caselist,false);
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM3 = new List<EmailMessage>();
            lstEM3 = TestDataFactory.createEmailMessage(Subject, Body, caselist[0]);
            lstEM3[0].FromAddress  = 'abc@accenture.com';
            lstEM3[0].ToAddress += eadata != null && eadata.size() > 0 ? eadata[0].Label : null;
            lstEM3[0].CcAddress += eadata != null && eadata.size() > 1 ? eadata[1].Label : null;
            lstEM3[0].To_Be_Processed__c = true;
            lstEM3[0].Message_ID__c = '1234574MF0022227D61A03821A797F3F8F6550@COM';
            Database.insert(lstEM3);
            Test.StartTest();
            RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = true;
            EmailAliasProcessBatch batch = new EmailAliasProcessBatch();
            Database.executeBatch(batch);
            List<EmailMessage> emmsglst = [Select Id,ParentId from EmailMessage where Message_ID__c =: '1234574MF0022227D61A03821A797F3F8F6550@COM' and isDeleted = true];
            List<EmailMessage> nullmessageId = [SELECT Id, ParentId FROM EmailMessage WHERE Message_ID__c = '' and isDeleted = true];
            Test.StopTest();
            system.assert(emmsglst != null);
            system.assert(nullmessageId.isEmpty());
            
        }
    }
    /**Test method to check on the Email Task with Open Status.**/
    @isTest
    static void testEmailAliaswithOpenTask() {
        User u = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(u){
            
            EmailMessage em = [Select Id,ParentId from EmailMessage where Message_ID__c =: '1234574MF0022227D61A03821A797F3F8F6550@COM'];
            Id tskRecId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            List<Task> tsklst = TestDataFactory.createTask(em.ParentId,u);
            tsklst[0].Process__c = null;
            tsklst[0].Status = Constant_Util.COMPLETED;
            tsklst[0].RecordTypeId = tskRecId;
            tsklst[1].Process__c = null;
            tsklst[1].RecordTypeId = tskRecId;
            Database.insert(tsklst,false);
            Test.StartTest();
            EmailAliasProcessBatch batch = new EmailAliasProcessBatch();
            Database.executeBatch(batch);
            Test.StopTest();
            EmailMessage emsg = [Select Id,ParentId,Bypass_Genesys_Task__c from EmailMessage where Message_ID__c =: '1234574MF0022227D61A03821A797F3F8F6550@COM'];
            List<EmailMessage> nullmessageId = [SELECT Id, ParentId FROM EmailMessage WHERE Message_ID__c = '' AND Bypass_Genesys_Task__c = true];
            system.assert(nullmessageId.isEmpty());
            System.AssertEquals(emsg.Bypass_Genesys_Task__c,false);
        }
    }
    /**Test method to to check on the Email Task with Close Status.**/
    @isTest
    static void testEmailAliaswithCloseTask() {
        User u = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(u){
            EmailMessage em = [Select Id,ParentId from EmailMessage where Message_ID__c =: '1234574MF0022227D61A03821A797F3F8F6550@COM'];
            Id tskRecId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            List<Task> tsklst = TestDataFactory.createTask(em.ParentId,u);
            tsklst[0].Process__c = null;
            tsklst[0].Status = Constant_Util.COMPLETED;
            tsklst[0].RecordTypeId = tskRecId;
            tsklst.remove(1);
            Database.insert(tsklst,false);
            Test.StartTest();
            Task t =  [Select Id,Status from task where Id =:tsklst[0].Id];
            RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = true;
            EmailAliasProcessBatch batch = new EmailAliasProcessBatch();
	    Database.executeBatch(batch);
            Test.StopTest();
            EmailMessage emsg = [Select Id,ParentId,Bypass_Genesys_Task__c from EmailMessage where Id =:em.Id];
            system.assert(emsg != null);
        }
    }
}