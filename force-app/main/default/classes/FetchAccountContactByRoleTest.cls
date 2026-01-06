/**************************************************
* ClassName:FetchAccountContactByRoleTest
* Author:Adil 
* Description: Test Class to cover FetchAccountContactByRole
* CreatedDate:01/11/2022
* **************************************************/
@isTest
public class FetchAccountContactByRoleTest {
    
    // set the test data
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount('test', usr,'Client');
            Database.insert(acclist);
            list<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
            conlist[0].Email = 'abc@test.com';
            Database.insert(conlist);
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            String roles = Constant_Util.ROLL_OFF_ESCALATION_DISPATCH_ROLE + ';' + Constant_Util.COMMERCIAL_ESCALATION_DISPATCH_ROLE;
            AccountContactRelation accContactList = TestDataFactory.returnAccConRel(supplieracclist.get(0).id, conlist.get(0), roles);
            Database.insert(accContactList);
        }
    }

    @isTest static void testFetchAccountContact() {
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        
        system.runAs(currentuser){
            list<Account> accList = [select id from Account WHERE Name = 'testsupplier' limit 1];
            List<FetchAccountContactByRole.FlowInputvalues> wrapperList = new List<FetchAccountContactByRole.FlowInputvalues>();
            FetchAccountContactByRole.FlowInputvalues wrapper = new FetchAccountContactByRole.FlowInputvalues();
            wrapper.vendorId = accList[0].id;
            wrapper.role = Constant_Util.ROLL_OFF_ESCALATION_DISPATCH_ROLE;
            wrapperList.add(wrapper);
            Test.startTest();
            List<Integer> accContactList = FetchAccountContactByRole.fetchAccountContactData(wrapperList);
            system.assertEquals(accContactList[0] , 1);  

            wrapperList.clear();
            wrapper.vendorId = accList[0].id;
            wrapper.role = '';
            wrapperList.add(wrapper);

            accContactList = FetchAccountContactByRole.fetchAccountContactData(wrapperList);
            system.assertEquals(accContactList[0] , 0);  
            
            wrapperList.clear();
            accContactList = FetchAccountContactByRole.fetchAccountContactData(wrapperList);
            system.assertEquals(accContactList[0] , 0);  
            Test.stopTest();    
        } 
    }
}