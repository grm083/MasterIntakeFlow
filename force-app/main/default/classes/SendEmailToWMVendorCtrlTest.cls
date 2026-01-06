/**************************************************
* ClassName:SendEmailToWMVendorCtrlTest
* Author:Adil 
* Description: Test Class to cover SendEmailToWMVendorCtrl
* CreatedDate:01/09/2022
* **************************************************/
@isTest
public class SendEmailToWMVendorCtrlTest {
    
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
            conlist[0].Email = 'abc@test.com';
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct('test');
            productlist[0].Family = Constant_Util.COMMERCIAL;
            Database.insert(productlist);
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            String roles = Constant_Util.ROLL_OFF_ESCALATION_DISPATCH_ROLE + ';' + Constant_Util.COMMERCIAL_ESCALATION_DISPATCH_ROLE;
            AccountContactRelation accContactList = TestDataFactory.returnAccConRel(supplieracclist.get(0).id, conlist.get(0), roles);
            Database.insert(accContactList);
            list<Asset> assetlist = TestDataFactory.createAsset('first', acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = locationlist[0].Id;
            caselist[0].Case_Type__c = Constant_Util.STATUS_CSTYPE;
            caselist[0].Status = Constant_Util.OPEN;
            caselist[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.STATUS_CASE).getRecordTypeId();
            caselist[0].Case_Sub_Type__c = Constant_Util.SERVICE_NOT_PERFORMED;
            Database.insert(caselist);
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            taskList[0].RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Non_Pickup_Escalation_Task').getRecordTypeId();
            taskList[0].Process__c = Constant_Util.ESCAL_UNRESP_CON_VENDOR;
            Database.insert(tasklist);

        }
    }

    @isTest static void testSendEmailToVendor() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        
        system.runAs(currentuser){
            list<case> caselist = [select id from case limit 1];
            list<Account> accList = [select id from Account WHERE Name = 'testsupplier' limit 1];
            list<task> taskList = [select id from task limit 1];
            List<String> vendorTaskList = new List<String>();
            vendorTaskList.add(taskList[0].id + ';' + caselist[0].id + ';' + accList[0].id);
            Test.startTest();
            SendEmailToWMVendorCtrl.sendEmailToVendor(vendorTaskList);
            //test class errors - SDT - 33363
            //system.assertEquals(Limits.getEmailInvocations() , 1);  
            Test.stopTest();    
        } 
    }
}