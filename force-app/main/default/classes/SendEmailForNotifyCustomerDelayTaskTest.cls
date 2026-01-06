/**************************************************
* ClassName:SendEmailForNotifyCustomerDelayTaskTest
* Author:Rajan Sajani
* Description: Test Class to cover SendEmailForNotifyCustomerDelayTask
* CreatedDate:15/1/2024
* **************************************************/
@isTest
public class SendEmailForNotifyCustomerDelayTaskTest {
    
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
            caselist[0].Case_Type__c = 'Pickup';
            caselist[0].Status = Constant_Util.OPEN;
            caselist[0].RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.PICK_CASE).getRecordTypeId();
            //caselist[0].RecordTypeId = '0121I000000JoJuQAK';
            caselist[0].Case_Sub_Type__c = 'Empty and Return';
            
            Database.insert(caselist);
            
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            taskList[0].RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Follow_Up').getRecordTypeId();
            taskList[0].Process__c = 'Notify Customer of Delay';
            Database.insert(tasklist);
            
            /*EmailTemplate em = new EmailTemplate();
            em.Name = 'Notify Customer of SD Delay Template';
            em.DeveloperName = 'Notify_Customer_of_SD_Delay_Template';
            em.FolderId = '00D8A000000MkaHUAS';
            em.TemplateType = 'visualforce';
            insert em;*/

        }
    }

    @isTest static void testSendEmailToUser() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user WHERE isActive = TRUE and Profile.Name = 'System Administrator'  limit 1];
        
        system.runAs(currentuser){
            list<case> caselist = [select id from case limit 1];
            String caseID = caselist[0].Id;
            list<contact> conlist = [Select id from contact limit 1];
            list<String> caseStringList = new list<String>();
            //EmailTemplate emTemp = [Select id,Name,DeveloperName,FolderId,TemplateType from EmailTemplate where Name = 'Notify Customer of SD Delay Template'];
            caseStringList.add(caseID);
           // list<Account> accList = [select id from Account WHERE Name = 'testsupplier' limit 1];
           // list<task> taskList = [select id from task limit 1];
            Test.startTest();
           // System.debug( 'OrgWideEmailAddress^^' );
               // System.debug( 'string.valueof(templateId.Id)^^' +tempId);
               // System.debug( 'string.valueof(contactId.Id)^^^^' +conlist);
               // System.debug( 'string.valueof(caseId.Id)^^^^' +caselist);
            SendEmailForNotifyCustomerDelayTask.sendEmail(caseStringList);
            Test.stopTest();    
        } 
    }
}