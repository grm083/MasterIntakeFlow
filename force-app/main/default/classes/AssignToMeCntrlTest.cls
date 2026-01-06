/**************************************************
 * ClassName:AssignToMeCntrlTest
 * Author:Niranjan
 * Description: Test Class to cover AssignToMeCntrl
 * CreatedDate:7/24/2019
 * Modified on 09/23/2020 for SDT-13544
 * **************************************************/
@isTest(seeAllData = false)
public class AssignToMeCntrlTest {

    // set the test data
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User groupUsr = TestDataFactory.createUser(p);
        groupUsr.FirstName = 'Group';
        groupUsr.LastName = 'User';
		Database.insert(groupUsr);
        User usr = TestDataFactory.createUser(p);
        usr.FirstName = 'Genesys';
        usr.LastName = 'Integration';
        Database.insert(usr);
        
        system.runAs(usr){
        list<Account> acclist = TestDataFactory.createAccount('test', usr,'Client');
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation('Location', usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct('test');
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            list<Asset> assetlist = TestDataFactory.createAsset('first', acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = locationlist[0].Id;
            caselist[0].PurchaseOrder_Number__c =  '1243';
            caselist[0].Case_Type__c = 'Pickup';
            caselist[0].Case_Sub_Type__c = 'Extra Pickup';
            Database.insert(caselist);
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
			tasklist[0].OwnerId = groupUsr.Id;
            Database.insert(tasklist);
        }
    }
    //Method to cover TaskAssignmentChange method in class
    @isTest static void changeTaskAssignmentFunc(){
        user currentUser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser){
            Task tsk = [SELECT Id FROM Task WHERE Subject='test' LIMIT 1];
            Test.startTest();
                string toastInfoMsg = AssignToMeCntrl.TaskAssignmentChange(tsk.Id);
                system.assertEquals(Constant_Util.EMPTY_STRING, toastInfoMsg);
            Test.stopTest();
        }
    }
    //Method to cover already assigned tasks
    @isTest static void taskAssignmentTest(){
        user currentUser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser){
            Id taskId;
            Test.startTest();
            	string toastInfoMsg = AssignToMeCntrl.TaskAssignmentChange(taskId);
           		system.assertEquals(Constant_Util.ASSIGN_TO_ME_TOAST_MSG, toastInfoMsg);
            Test.stopTest();
        }
    }
    //Method to cover email related task 
    @isTest static void emailTaskTest(){
        user currentUser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser){
            Task tsk = [SELECT Id FROM Task WHERE Owner.Name !=: Constant_Util.GROUP_USERNAME LIMIT 1];
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            update tsk;
            Test.startTest();
                string toastInfoMsg = AssignToMeCntrl.TaskAssignmentChange(tsk.Id);
                system.assertEquals(Constant_Util.EMPTY_STRING, toastInfoMsg);
            Test.stopTest();
        }
    }
    //Method to cover gorup user task 
    @isTest static void exceptionCoverageTest(){
        user currentUser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        string userId = [SELECT Id, Name FROM User WHERE Name =: Constant_Util.GROUP_USERNAME LIMIT 1].Id;
        system.runAs(currentUser){
            List<Task> taskLst = [SELECT Id, OwnerId, Owner.Name, Status FROM Task];
            taskLst[0].OwnerId = userId;
            taskLst[0].RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            Database.update(taskLst);
            Test.startTest();
                string toastInfoMsg = AssignToMeCntrl.TaskAssignmentChange(taskLst[0].Id);
            Test.stopTest();
        }
    }
    //Method to cover gorup user task 
    @isTest static void groupUserTaskTest(){
        user currentUser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363 
        system.runAs(currentUser){
            Task tsk = [SELECT Id, OwnerId, Owner.Name FROM Task WHERE Owner.Name =: Constant_Util.GROUP_USERNAME LIMIT 1];
            tsk.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            update tsk;
            Test.startTest();
                string toastInfoMsg = AssignToMeCntrl.TaskAssignmentChange(tsk.Id);
                system.assertEquals(Constant_Util.ASSIGN_TO_ME_EMAIL_TASK_TOAST_MSG, toastInfoMsg);
            Test.stopTest();
        }
    }
}