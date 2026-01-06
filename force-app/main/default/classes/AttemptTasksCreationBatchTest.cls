/*************************************************************
@Name: AttemptTasksCreationBatchTest
@Author: Kalaiselvi R
@CreateDate: 10/17/2019
@Description: Test class of AttemptTasksCreationBatch
**************************************************************/
@isTest(SeeAllData=false)
public class AttemptTasksCreationBatchTest {
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
            
            //create asset
            list<Asset> assetLst = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, accLst.get(0), conLst.get(0), 
                                                                productLst.get(0), usr, locationLst.get(0));
            assetLst[0].Supplier__c = supplierAccLst.get(0).Id;
            assetLst[0].Quantity__c = 5;
            Database.insert(assetLst);
            
            //return 4 cases - update 2 of them to fit testing criteria - insert all 4
            List<Case> caseLst = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, accLst.get(0), conLst.get(0), 
                                                             usr, locationLst.get(0), assetLst.get(0));
            caseLst[0].Status = Constant_Util.OPEN;
			caseLst[0].Case_Sub_Status__c = 'Pending Schedule Confirmation';
            caseLst[0].Service_Date__c = System.today();
            caseLst[0].Instructions_for_the_driver__c = 'attemptTasksCreationBatchTest1';
            caseLst[1].Case_Sub_Status__c = Constant_Util.Pending_Service_Confirmation;
            caseLst[1].Status = Constant_Util.OPEN;
            caseLst[1].Service_Date__c = System.today();
            caseLst[1].Instructions_for_the_driver__c = 'attemptTasksCreationBatchTest2';
            Database.insert(caseLst);           
            
            //create Workorder
            List<WorkOrder> workOrderLst = TestDataFactory.createWorkOrder(accLst.get(0), conLst.get(0), caseLst.get(0), 
                                                                           assetLst.get(0));
            workOrderLst[0].Vendor_Account_Id__c = supplierAccLst.get(0).Id; 
            workOrderLst[0].Service_Date__c =  system.today();
            Database.insert(workOrderLst);  
            
            list<Task> tasklist = TestDataFactory.createTask(caseLst.get(0).id, usr);
            tasklist[0].Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tasklist[0].Process__c = Constant_Util.CONFIRM_SERVICE_COMPLETION;
            tasklist[0].Next_Attempt_Date_Time__c = system.today();
			tasklist[0].Is_Attempt_Created__c = false;
            tasklist[0].Attempt__c = 1;
            
            tasklist[1].Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
            tasklist[1].Process__c = Constant_Util.CONFIRM_SERVICE_COMPLETION;
			tasklist[1].Next_Attempt_Date_Time__c = system.today();
			tasklist[1].Is_Attempt_Created__c = false;
            tasklist[1].Attempt__c = 3;
            
            Database.insert(tasklist);
        }
    }
    @isTest static void testBatchScheduleConfirmation() {
        User usr = [SELECT Id, Bypass_Validation__c 
                    FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id 
                    AND IsActive = true 
                    LIMIT 1];

        System.runAs(usr){
            Test.startTest();
            String jobId = Database.ExecuteBatch(new AttemptTasksCreationBatch());
            Test.stopTest();
        }

        Case testCase1 = [SELECT Id FROM Case 
                          WHERE Instructions_for_the_driver__c = 'attemptTasksCreationBatchTest1'
                          LIMIT 1];

        Case testCase2 = [SELECT Id FROM Case 
                          WHERE Instructions_for_the_driver__c = 'attemptTasksCreationBatchTest2'
                          LIMIT 1];

        List<Task> testTasks = [SELECT Id, CreatedDate, Due_Date_Time__c 
                                FROM Task 
                                WHERE WhatId =: testCase1.Id 
                                OR WhatId =: testCase2.Id
                                LIMIT 1];
		
        for(Task myTestTask : testTasks){
            if(myTestTask.Due_Date_Time__c != null)
            System.assert(myTestTask.Due_Date_Time__c >= myTestTask.CreatedDate);
        }
    }
}