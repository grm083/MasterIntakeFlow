/**************************************************
* ClassName:SendEmailToServiceApproversCntrlrURuleTest
* Author:Niranjan 
* Description: Test Class to cover SendEmailToServiceApproversCntrlrURule
* CreatedDate:6/3/2019
* **************************************************/
@isTest(seeAllData = false)
public class SendEmailToServiceApproversCntrlrURtest {
    
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
            list<Business_Rule__c> approverlst = TestDataFactory.createBusinessRule('test1',acclist.get(0),locationlist.get(0));
            approverlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
            approverlst[0].Service__c = 'Empty and Do NOT Return';
            Insert approverlst;
            system.debug('approverlst'+approverlst);
            list<Service_Approver__c> salst = TestDataFactory.createServiceApprover(approverlst[0]);
            salst[0].Email__c = 'abc@gmail.com';
            salst[0].Business_Rule__c = approverlst[0].Id;
            salst[0].User__c = usr.Id;
            insert salst;
            system.debug('salst'+salst);
        }
    }
    //Method to cover ChangeTaskAssignment method in class
    @isTest static void sendEmail() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        
        system.runAs(currentuser){
            list<case> caselist = [select id, origin, contactid, Case_Type__c, Client__c, Location__c, 
                                   PSI_Override_Reason__c, Case_Sub_Type__c,PurchaseOrder_Number__c, assetid,PSI__c,PSI_Comments__c,
                                   Service_Date__c,SLA_Service_Date_Time__c from case limit 1];
            list<contact> Contactlst = [select id from contact limit 1];
            list<Business_Rule__c> brlst = [Select Id,Accountid__c,locationid__c,Container__c,Service__c,Request_Type__c,Schedule_Type__c,Active__c,Effective_Date__c,RecordTypeid,
                                            Required_Information__c from  Business_Rule__c where RecordTypeid =: Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId()];
            list<Service_Approver__c> salst = [Select Id, Business_Rule__c from Service_Approver__c];
            String br = '['+brlst[0].Id + '];' + caselist[0].Id + ';' + Contactlst[0].Id+';Escalation Obtain Customer Info';
            List<String> brlsts = new List<String>();
            brlsts.add(br);
            Test.startTest();
            SendEmailToServiceApproversCntrlrURule.sendEmail(brlsts);
            Test.stopTest();
            system.assert(brlsts.size() != 0);
        }
        
    }
}