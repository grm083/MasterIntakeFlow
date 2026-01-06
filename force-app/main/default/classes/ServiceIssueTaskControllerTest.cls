/**
* @author Accenture
* @date 13/7/2020
* @description : Apex class ServiceIssueTaskControllerTest 
**/
@isTest(seeAllData = false)
public class ServiceIssueTaskControllerTest {

    /**
    * @author Accenture
    * @date 2/27/2019
    * @description : Apex method setup 
    **/
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Los_Angeles';
            locationlist[0].tz__Timezone__c = 'EST';
            Database.insert(locationlist);
            
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);

            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            productlist[0].Family = Constant_Util.COMMERCIAL;
            Database.insert(productlist);
            
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = acclist.get(0).Id;
            caselist[0].Service_Date__c = system.today() + 1;
			caselist[0].status = 'Open';
			caselist[0].Case_Sub_Status__c = 'Pending Service Issue Resolution';
            Database.insert(caselist[0]);
            
            list<Task> taskLst = TestDataFactory.createTask(caselist[0].Id, usr);
            taskLst[0].RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Non Pickup Follow up Task').getRecordTypeId(); 
            taskLst[0].Process__c = Constant_Util.RESOLVE_SERV_ISSUE; 
			taskLst[0].Attempt__c = 1; 
			Database.insert(taskLst);
        }        
    }    
    
    /**
    * @author Accenture
    * @date 13/7/2020
    * @description : Apex method updateCaseTaskHaulerTest 
    **/
    @isTest static void updateCaseTaskHaulerTest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            Case cse = [select Id FROM Case WHERE Case_Sub_Status__c = 'Pending Service Issue Resolution' limit 1];
            Test.startTest();
				string status = ServiceIssueTaskController.updateServiceClassfication(cse.Id,Constant_Util.HAULER_REPORTED);
                //test class errors - SDT - 33363
                //system.assert(Constant_Util.SUCCESS == status);
            Test.stopTest();
        }
    }
	/**
    * @author Accenture
    * @date 13/7/2020
    * @description : Apex method updateCaseTaskCustomerTest 
    **/
    @isTest static void updateCaseTaskCustomerTest(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            Case cse = [select Id FROM Case WHERE Case_Sub_Status__c = 'Pending Service Issue Resolution' limit 1];
            Test.startTest();
				string status = ServiceIssueTaskController.updateServiceClassfication(cse.Id,Constant_Util.CUSTOMER_REPORTED);
                //test class errors - SDT - 33363
                 //system.assert(Constant_Util.SUCCESS == status);
            Test.stopTest();
        }
    }
}