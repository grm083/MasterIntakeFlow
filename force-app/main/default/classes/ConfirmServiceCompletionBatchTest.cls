/*************************************************************
@Name: ConfirmServiceCompletionBatchTest
@Author: Saurav
@CreateDate: 10/17/2019
@Description: Test class of ConfirmServiceCompletionBatch
**************************************************************/
@isTest (SeeAllData=false)
public class ConfirmServiceCompletionBatchTest {
    
	// method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        System.runAs(usr){
            //create 2 accounts
            List<Account> accList = new List<Account>();
            Account testAccount1 = TestDataFactory.returnAccount('TestAccount1', '12345', 'Client', usr);
            accList.add(testAccount1);

            Account testAccount2 = TestDataFactory.returnAccount('TestAccount2', '12346', 'Client', usr);
            accList.add(testAccount2);
            Database.insert(accList);
            

            //create 1 location for each Account
            List<Account> locList = new List<Account>();
            Account testLocation1 = TestDataFactory.returnLocation('TestLocation1', testAccount1.Id, usr);
            locList.add(testLocation1);

            Account testLocation2 = TestDataFactory.returnLocation('TestLocation2', testAccount2.Id, usr);
            locList.add(testLocation2);
            Database.insert(locList);
            

            //create 1 contact for each Account
            List<Contact> conList = new List<Contact>();
            Contact testContact1 = TestDataFactory.returnContact('TestFirstName1', 'TestLastName1', 
                                                                 testAccount1, usr);
            conList.add(testContact1);

            Contact testContact2 = TestDataFactory.returnContact('TestFirstName2', 'TestLastName2', 
                                                                 testAccount2, usr);
            conList.add(testContact2);
            Database.insert(conList);
            

            //create 2 products
            List<Product2> productList = new List<Product2>();
            Product2 commercialProduct = TestDataFactory.returnProduct('commercialTestProduct', 'Commercial', 'Equipment');
            productList.add(commercialProduct);

            Product2 rolloffProduct = TestDataFactory.returnProduct('rolloffTestProduct', 'Rolloff', 'Baler');
            productList.add(rolloffProduct);
            Database.insert(productList);
            

            //create 2 vendor Accounts
            List<Account> supplierAccList = new List<Account>();
            Account supplierAccount1 = TestDataFactory.returnAccount('TestSupplier1', '12347', 'Vendor', usr);
            supplierAccList.add(supplierAccount1);

            Account supplierAccount2 = TestDataFactory.returnAccount('TestSupplier2', '12348', 'Vendor', usr);
            supplierAccList.add(supplierAccount2);
            Database.insert(supplierAccList);
            

            // Setup relationship between Contacts and Suppliers
            List<AccountContactRelation> myACRList = new List<AccountContactRelation>();
            AccountContactRelation testACR1 = 
            TestDataFactory.returnAccConRel(supplierAccount1.Id, testContact1, 'Commercial Service/Dispatch');
            myACRList.add(testACR1);

            AccountContactRelation testACR2 = 
            TestDataFactory.returnAccConRel(supplierAccount2.Id, testContact2, 'Rolloff Service/Dispatch');
            myACRList.add(testACR2);
            Database.insert(myACRList);


            // SDT-11703 - Create a Rolloff Asset and a Commercial Asset
            List<Asset> assetList = new List<Asset>();
            Asset testCommercialAsset1 = 
            TestDataFactory.returnServiceHeaderAsset('TestCommercialServiceHeaderAsset', testAccount1, testContact1, 
                                                        commercialProduct, usr, testLocation1);
            testCommercialAsset1.Supplier__c = supplierAccount1.Id;
            testCommercialAsset1.Quantity__c = 5;
            assetList.add(testCommercialAsset1);
    
            Asset testRolloffAsset1 = 
            TestDataFactory.returnServiceHeaderAsset('TestRolloffServiceHeaderAsset', testAccount2, testContact2, 
                                                        rolloffProduct, usr, testLocation2);
            testRolloffAsset1.Supplier__c = supplierAccount2.Id;
            testRolloffAsset1.Quantity__c = 5;
            assetList.add(testRolloffAsset1);
            Database.insert(assetList);
            

            // SDT-11703 - Create Pickup Cases from the Rolloff Asset and the Commercial Asset
            // Set the Case up to be picked up by the Batch Job with Sub_Status__c
            List<Case> caseList = new List<Case>();
            
            Case testCommercialCase1 = 
            TestDataFactory.returnCase('TestCase1', testAccount1, testContact1, 
                                        usr, testLocation1, testCommercialAsset1);
            testCommercialCase1.Status = 'Open';
			testCommercialCase1.Case_Sub_Status__c = 'Pending Service Confirmation';
            testCommercialCase1.Supplier__c = supplierAccount1.Id;
            caseList.add(testCommercialCase1);

            Case testRolloffCase1 = 
            TestDataFactory.returnCase('TestCase2', testAccount2, testContact2, 
                                        usr, testLocation2, testRolloffAsset1);
            testRolloffCase1.Status = 'Open';
			testRolloffCase1.Case_Sub_Status__c = 'Pending Service Confirmation';
            testRolloffCase1.Supplier__c = supplierAccount2.Id;
            caseList.add(testRolloffCase1);
            Database.insert(caseList);
            

            //create 2 Workorders
            List<WorkOrder> workOrderList = new List<WorkOrder>();
            WorkOrder testCommercialWorkOrder1 = 
            TestDataFactory.returnWorkOrder(testAccount1, testContact1, testCommercialCase1, testCommercialAsset1);
            testCommercialWorkOrder1.Vendor_Account_Id__c = supplierAccount1.Id; 
            testCommercialWorkOrder1.Service_Date__c =  System.today().addDays(-1);
            workOrderList.add(testCommercialWorkOrder1);

            WorkOrder testRolloffWorkOrder1 = 
            TestDataFactory.returnWorkOrder(testAccount2, testContact2, testRolloffCase1, testRolloffAsset1);
            testRolloffWorkOrder1.Vendor_Account_Id__c = supplierAccount2.Id; 
            testRolloffWorkOrder1.Service_Date__c =  System.today().addDays(-1);
            workOrderList.add(testRolloffWorkOrder1);
            Database.insert(workOrderList);


            // Set Work Orders to be parents of the Cases...
            List<Case> updateCaseList = new List<Case>();
            testCommercialCase1.Work_Order__c = testCommercialWorkOrder1.Id;
            updateCaseList.add(testCommercialCase1);
            testRolloffCase1.Work_Order__c = testRolloffWorkOrder1.Id;
            updateCaseList.add(testRolloffCase1);
            Database.update(updateCaseList);
        }
    }

	@isTest static void testConfirmSvcCompletionBatch() {
		User usr = [SELECT Id, Bypass_Validation__c 
                    FROM User 
                    WHERE ProfileId =:(TestDataFactory.getProfile('System Administrator')).Id 
                    AND IsActive = true 
                    LIMIT 1];

        // For faux scheduling coverage
        String cronexp = '0 0 0 15 3 ? *';

        System.runAs(usr) {
			Test.startTest();
            System.schedule('test02', cronexp, new ConfirmServiceCompletionBatch());
            DataBase.executeBatch(new ConfirmServiceCompletionBatch());            
            Test.stopTest();
		}

        /* SDT-11073 
        *  1) For Cases with Commercial Assets: Vendor Contact on Case's vendor 
        *     with Commercial Dispatch needs to be added to tasks.
        *     If 2 Contacts with this role are found,
        *     the one created most recently is attached
        *  2) For Cases with Rolloff Assets: Vendor Contact on Case's Vendor with Rolloff
        *     Dispatch needs to be added. If 2 Contacts with this role are found,
        *     the one created most recently is attached
        *  3) If no Contact with a specified role is found on Case's Vendor, attach
        *     a Vendor Contact with Dispatch role from Vendor Account. If 2 Contacts 
        *     with this role are found, the one created most recently is attached.
        */ 

        Set<Id> caseIds = new Set<Id>();
        List<Case> myCaseList = [SELECT Id FROM Case];

        for(Case myCase : myCaseList){
            caseIds.add(myCase.Id);
        }

        List<Task> taskList = [SELECT Id, WhatId, WhoId 
                              FROM Task 
                              WHERE WhatId IN: caseIds];

        Case testCommercialCase1 = [SELECT Id FROM Case WHERE Site_Contact__c =: 'TestCase1' LIMIT 1];
        Case testRolloffCase1 = [SELECT Id FROM Case WHERE Site_Contact__c =: 'TestCase2' LIMIT 1];
        Contact testContact1 = [SELECT Id FROM Contact WHERE FirstName =: 'TestFirstName1' LIMIT 1];
        Contact testContact2 = [SELECT Id FROM Contact WHERE FirstName =: 'TestFirstName2' LIMIT 1];

		for(Task myTask : taskList){
            if(myTask.WhatId == testCommercialCase1.Id){
                System.assert(myTask.WhoId == testContact1.Id);
                System.debug('********whatisthis 1: ' + myTask.WhoId);
            }
            if(myTask.WhatId == testRolloffCase1.Id){
                System.debug('********whatisthis 2: ' + myTask.WhoId);
                System.assert(myTask.WhoId != null);
            }
        }
	}
}