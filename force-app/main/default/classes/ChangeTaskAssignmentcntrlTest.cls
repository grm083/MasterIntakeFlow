/**************************************************
 * ClassName:ChangeTaskAssignmentcntrlTest
 * Author:Priyadharshini 
 * Description: Test Class to cover ChangeTaskAssignmentCntrl
 * CreatedDate:1/3/2019
 * Modified on 09/23/2020 for SDT-13544
 * **************************************************/
@isTest(seeAllData = false)
public class ChangeTaskAssignmentcntrlTest {

    // set the test data
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
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
            Database.insert(tasklist);
        }
    }
    //Method to cover ChangeTaskAssignment for group user
    @isTest static void changeTaskAssignmentToGroupUser(){
        user currentuser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        string userId = [SELECT Id, Name FROM User WHERE Name =: Constant_Util.GROUP_USERNAME LIMIT 1].Id;
        system.runAs(currentuser){
            List<Task> taskLst = [SELECT Id, OwnerId, Status FROM Task];
            taskLst[0].OwnerId = userId;
            Database.update(taskLst);
            Test.startTest();
            	ChangeTaskAssignmentCntrl.ChangeTaskAssignment(taskLst);
            	List<Task> updatedTaskLst = [SELECT Id, OwnerId, Status FROM Task];
            	system.assertEquals(updatedTaskLst[0].OwnerId, userInfo.getUserId());
            Test.stopTest();
        }
    }
    @isTest static void exceptionCoverageTest(){
        user currentuser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
		system.runAs(currentuser){      
            Test.startTest();
                List<Task> taskLst2 = [SELECT Status FROM Task];
                ChangeTaskAssignmentCntrl.ChangeTaskAssignment(taskLst2);
            Test.stopTest();
        }
    }
}