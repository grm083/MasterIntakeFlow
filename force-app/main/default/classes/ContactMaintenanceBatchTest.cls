@isTest
public class ContactMaintenanceBatchTest {
    
    
    @testSetup static void setup(){
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        System.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Business_Rule__c> businessrulelist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                                         locationlist.get(0));
            Database.insert(businessrulelist);

            List<Contact> contacts = new List<Contact>();

            Contact con1 = new Contact();
            con1.FirstName = 'Test';
            con1.LastName = 'Con';
            con1.Last_Activity_Date__c = Date.today().addDays(-91);
            con1.contact_status__c = 'Active';
            contacts.add(con1);
            
            Contact con2 = new Contact();
            con2.FirstName = 'Test';
            con2.LastName = 'Con';
            con2.Last_Activity_Date__c = Date.today().addDays(-80);
            con2.contact_status__c = 'Inactive';
            contacts.add(con2);

            Contact con3 = new Contact();
            con3.FirstName = 'Unspecified';
            con3.LastName = 'Con';
            con3.Last_Activity_Date__c = Date.today().addDays(-91);
            con3.contact_status__c = 'Active';
            contacts.add(con3);
            
            Contact con4 = new Contact();
            con4.FirstName = 'Biz';
            con4.LastName = 'Con';
            con4.Last_Activity_Date__c = Date.today().addDays(-91);
            con4.contact_status__c = 'Active';
            con4.Location__c = locationlist[0].id;
            con4.AccountId = acclist[0].id;
            contacts.add(con4);
            
            insert contacts;

            Service_Approver__c sa = new Service_Approver__c();
            sa.Approver_Contact__c = con4.Id;
            sa.Business_Rule__c = businessrulelist[0].id;
            sa.Account__c = acclist[0].id;
            sa.Location__c = locationlist[0].id;
            insert sa;

            
        }
    }

    @isTest
    static void testInactivation(){
        User u = [Select Id,ProfileId,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(u){
            Contact c = [SELECT Id, contact_status__c FROM Contact WHERE contact_status__c = 'Active' AND FirstName != 'Unspecified' LIMIT 1];
            Test.startTest();
            ContactMaintenanceBatch batch = new ContactMaintenanceBatch();
            Database.executeBatch(batch);
            Test.stopTest();
            Contact c2 = [SELECT Id, contact_status__c FROM Contact WHERE Id = :c.id];
            System.assert(c2.contact_status__c == 'Inactive');
            System.debug('c2 -- ' + c2);
        }
    }

    @isTest
    static void testActivation(){
        User u = [Select Id,ProfileId,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(u){
            Contact c = [SELECT Id, contact_status__c FROM Contact WHERE contact_status__c = 'Inactive' LIMIT 1];
            Test.startTest();
            ContactMaintenanceBatch batch = new ContactMaintenanceBatch();
            Database.executeBatch(batch);
            Test.stopTest();
            Contact c2 = [SELECT Id, contact_status__c FROM Contact WHERE Id = :c.id];
            System.assert(c2.contact_status__c =='Active');
            System.debug('c2 -- ' + c2);
        }
    }

    @isTest
    static void testSchedule(){
        User u = [Select Id,ProfileId,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(u){
            Test.startTest();
            string jobId = System.schedule('ContactMaintenanceBatch_'+system.now(),'0 0 23 * * ?', new ContactMaintenanceBatch());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals('0 0 23 * * ?', ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            Test.stopTest();

        }
    }

    @isTest
    static void testUnspecified(){
        User u = [Select Id,ProfileId,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(u){
            Contact c = [SELECT Id, contact_status__c FROM Contact WHERE contact_status__c = 'Active' AND FirstName = 'Unspecified' LIMIT 1];
            Test.startTest();
            ContactMaintenanceBatch batch = new ContactMaintenanceBatch();
            Database.executeBatch(batch);
            Test.stopTest();
            Contact c2 = [SELECT Id, contact_status__c FROM Contact WHERE Id = :c.id];
            System.assert(c2.contact_status__c =='Active');
            System.debug('c2 -- ' + c2);
        }
    }

    @isTest
    static void testServiceApprover(){
        User u = [Select Id,ProfileId,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(u){
            Contact c = [SELECT Id, contact_status__c FROM Contact WHERE contact_status__c = 'Active' AND FirstName = 'Biz' LIMIT 1];
            Test.startTest();
            ContactMaintenanceBatch batch = new ContactMaintenanceBatch();
            Database.executeBatch(batch);
            Test.stopTest();
            Contact c2 = [SELECT Id, contact_status__c FROM Contact WHERE Id = :c.id];
            System.assert(c2.contact_status__c =='Active');
            System.debug('c2 -- ' + c2);
        }
    }

}