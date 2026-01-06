/*************************************************************
@Name: ScheduleConfirmationBatchTest
@Author: Kalaiselvi R
@CreateDate: 10/17/2019
@Description: Test class of ScheduleConfirmationBatch
**************************************************************/
@isTest
public class ScheduleConfirmationBatchTest {
	// method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            //create account
            list<Account> accLst = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
            Database.insert(accLst);
            
            //create location
            list<Account> locationLst = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, accLst.get(0).id);
            Database.insert(locationLst);
            
            //create contact
            list<Contact> conLst = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, 
                                                                accLst.get(0), usr);
            Database.insert(conLst);
            
            //create product
            list<product2> productLst = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productLst);
            
            //create vendor
            list<Account> supplierAccLst = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplierAccLst);
            
            //create Vendor contact
            list<Contact> venConLst = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, 
                                                                supplierAccLst.get(0), usr);
            Database.insert(venConLst);
            
            //create asset
            list<Asset> assetLst = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, accLst.get(0), conLst.get(0), 
                                                                productLst.get(0), usr, locationLst.get(0));
            assetLst[0].Supplier__c = supplierAccLst.get(0).Id;
            assetLst[0].Quantity__c = 5;
            Database.insert(assetLst);
            
            //create case
            list<Case> caseLst = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, supplierAccLst.get(0), venConLst.get(0), 
                                                             usr, locationLst.get(0), assetLst.get(0));
            caseLst[0].Status = Constant_Util.OPEN;
			caseLst[0].Case_Sub_Status__c = 'Pending Schedule Confirmation';
            caseLst[0].Service_Date__c = system.today();
            caseLst[0].Supplier__c = supplierAccLst.get(0).Id;
            Database.insert(caseLst);   
            
            //create task
            List<Task> tasklist = TestDataFactory.createTask(caseLst.get(0).id, usr);
            Database.insert(tasklist);
            
            //create Workorder
            List<WorkOrder> workOrderLst = TestDataFactory.createWorkOrder(accLst.get(0), conLst.get(0), caseLst.get(0), 
                                                                           assetLst.get(0));
            workOrderLst[0].Vendor_Account_Id__c = supplierAccLst.get(0).Id; 
            workOrderLst[0].Service_Date__c =  system.today();
            Database.insert(workOrderLst);  
        }
    }
    @isTest static void testBatchScheduleConfirmation() {
        User usr = [SELECT Id, Bypass_Validation__c 
                    FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id 
                    AND IsActive = true 
                    LIMIT 1];
        
        List<Account> accList = [SELECT Id,Name,RecordTypeId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.SUPPLIER).getRecordTypeId() LIMIT 1];
        
        List<Contact> conList = [SELECT Id,Contact_Status__c from Contact where AccountId =: accList[0].id LIMIT 1];
        conList[0].Contact_Status__c  = Constant_Util.ACTIVE; 
        Database.update(conList);
        
        AccountContactRelation accCont =[SELECT Id, AccountId, ContactId, contact.Email, contact.phone, contact.Tech_Contact_Account_Title__c,  
                                                    Tech_Contact_Status__c, Tech_Contact_Created_Date__c, Roles ,CreatedDate FROM AccountContactRelation WHERE AccountId =: accList[0].id];
        accCont.Roles = Constant_Util.COMM_SERVICE_DISPATCH;
        Database.Update(accCont);

        product2 prd = [SELECT Id, Name, Family FROM Product2 LIMIT 1];
        prd.Family = Constant_Util.COMMERCIAL;
        Database.update(prd);
            
        Asset asst = [SELECT Id, Occurrence_Type__c, Duration__c, Location__c, Account.ParentId FROM Asset LIMIT 1];
            
        Account loc = [SELECT Id, Parentid FROM Account WHERE Recordtype.name='Vendor' LIMIT 1];
        asst.Occurrence_Type__c = Constant_Util.ON_CALL;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
        
        List<Case> caseList = [SELECT Id, Status, Case_Sub_Status__c,Supplier__c, Is_Case_OSC_Created__c, OwnerId, PurchaseOrder_Number__c,
                              Profile_Number__c,Tech_Asset_ProductFamily__c from Case];
        caseList[0].Is_Case_OSC_Created__c = false ;
        Database.update(caseList);
        
        List<WorkOrder> workorders = [SELECT Id,Service_Date__c FROM WorkOrder LIMIT 5];
        Database.update(workorders);
        
        System.runAs(usr){
            Test.startTest();
            	System.schedule('test03', '0 0 0 15 3 ? *', new ScheduleConfirmationBatch());
            	Database.ExecuteBatch(new ScheduleConfirmationBatch()); 
            Test.stopTest();
        }
        System.assertEquals(Constant_Util.COMM_SERVICE_DISPATCH, accCont.Roles);
        System.assertEquals(4, caseList.size());
    }
    
     @isTest static void testBatchScheduleConfirmationSecondTest() {
        User usr = [SELECT Id, Bypass_Validation__c 
                    FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id 
                    AND IsActive = true 
                    LIMIT 1];
        
        List<Account> accList = [SELECT Id,Name,RecordTypeId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.SUPPLIER).getRecordTypeId() LIMIT 1];
        
        List<Contact> conList = [SELECT Id,Contact_Status__c from Contact where AccountId =: accList[0].id LIMIT 1];
        conList[0].Contact_Status__c  = Constant_Util.ACTIVE; 
        Database.update(conList);
        
        AccountContactRelation accCont =[SELECT Id, AccountId, ContactId, contact.Email, contact.phone, contact.Tech_Contact_Account_Title__c,  
                                                    Tech_Contact_Status__c, Tech_Contact_Created_Date__c, Roles ,CreatedDate FROM AccountContactRelation WHERE AccountId =: accList[0].id];
        accCont.Roles = Constant_Util.DISPATCH;
        Database.Update(accCont);

        product2 prd = [SELECT Id, Name, Family FROM Product2 LIMIT 1];
        prd.Family = Constant_Util.SERVICES;
        Database.update(prd);
            
        Asset asst = [SELECT Id, Occurrence_Type__c, Duration__c, Location__c, Account.ParentId FROM Asset LIMIT 1];
            
        Account loc = [SELECT Id, Parentid FROM Account WHERE Recordtype.name='Vendor' LIMIT 1];
        asst.Occurrence_Type__c = Constant_Util.ON_CALL;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
        
        List<Case> caseList = [SELECT Id, Status, Case_Sub_Status__c,Supplier__c, Is_Case_OSC_Created__c, OwnerId, PurchaseOrder_Number__c,
                              Profile_Number__c,Tech_Asset_ProductFamily__c from Case LIMIT 1];
        caseList[0].Is_Case_OSC_Created__c = false ;
        Database.update(caseList);
        
        List<WorkOrder> workorders = [SELECT Id,Service_Date__c FROM WorkOrder LIMIT 5];
        Database.update(workorders);
        
        System.runAs(usr){
            Test.startTest();
            	System.schedule('test03', '0 0 0 15 3 ? *', new ScheduleConfirmationBatch());
            	Database.ExecuteBatch(new ScheduleConfirmationBatch()); 
            Test.stopTest();
        }         
        System.assertEquals(Constant_Util.DISPATCH,accCont.Roles);
        System.assertEquals(Constant_Util.SERVICES,prd.Family);
    }
    
    @isTest static void testBatchScheduleConfirmationThirdTest() {
        User usr = [SELECT Id, Bypass_Validation__c 
                    FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id 
                    AND IsActive = true 
                    LIMIT 1];
        
        List<Account> accList = [SELECT Id,Name,RecordTypeId from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.SUPPLIER).getRecordTypeId() LIMIT 1];
        
        List<Contact> conList = [SELECT Id,Contact_Status__c from Contact where AccountId =: accList[0].id LIMIT 1];
        conList[0].Contact_Status__c  = Constant_Util.ACTIVE; 
        Database.update(conList);
        
        AccountContactRelation accCont =[SELECT Id, AccountId, ContactId, contact.Email, contact.phone, contact.Tech_Contact_Account_Title__c,  
                                                    Tech_Contact_Status__c, Tech_Contact_Created_Date__c, Roles ,CreatedDate FROM AccountContactRelation WHERE AccountId =: accList[0].id];
        accCont.Roles = Constant_Util.DISPATCH;
        Database.Update(accCont);
        
        product2 prd = [SELECT Id, Name, Family FROM Product2 LIMIT 1];
        prd.Family = Constant_Util.COMMERCIAL;
        Database.update(prd);
            
        Asset asst = [SELECT Id, Occurrence_Type__c, Duration__c, Location__c, Account.ParentId FROM Asset LIMIT 1];
            
        Account loc = [SELECT Id, Parentid FROM Account WHERE Recordtype.name='Vendor' LIMIT 1];
        asst.Occurrence_Type__c = Constant_Util.ON_CALL;
        asst.Project_Code__c = null;
        asst.Duration__c = Constant_Util.PERMANENT;
        Database.update(asst);
        
        List<Case> caseList = [SELECT Id, Status, Case_Sub_Status__c,Supplier__c, Is_Case_OSC_Created__c, OwnerId, PurchaseOrder_Number__c,
                              Profile_Number__c,Tech_Asset_ProductFamily__c from Case LIMIT 1];
        caseList[0].Is_Case_OSC_Created__c = false ;
        Database.update(caseList);
         
        List<Task> taskList = [SELECT Id,Subject,WhoId, CreatedDate, Due_Date_Time__c FROM task WHERE WhatId =: caseList[0].Id LIMIT 1];
        taskList[0].WhoId = null;
        taskList[0].Subject = Constant_Util.Obtain_Schedule_Confirmation;
        Database.update(taskList);
        
        System.runAs(usr){
            Test.startTest();
            	System.schedule('test03', '0 0 0 15 3 ? *', new ScheduleConfirmationBatch());
            	Database.ExecuteBatch(new ScheduleConfirmationBatch()); 
            Test.stopTest();
        }
        
        System.assertEquals(Constant_Util.COMMERCIAL,prd.Family);
        System.assertEquals(Constant_Util.Obtain_Schedule_Confirmation,taskList.get(0).Subject);
       
    }

}