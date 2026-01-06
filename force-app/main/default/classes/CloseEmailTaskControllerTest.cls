@isTest
public class CloseEmailTaskControllerTest {

    @testSetup static void setup(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        usr.FirstName = 'Test';
        usr.LastName = 'User';
        Database.insert(usr);
        
        User usr2 = usr.clone(false);
        usr2.FirstName = 'Mr Clone';
        usr2.UserName = 'MrClone@CloneMan.com';
        Database.insert(usr2);
        
        Id Email2CaseRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Email to Case').getRecordTypeId();

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
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr2);
            tasklist[0].recordtypeId = Email2CaseRecId;
            tasklist[0].Process__c = null;
            tasklist[0].Status = 'New';
            Database.insert(tasklist);
        
        List<EmailMessage> emailList = new List<EmailMessage>(); //Modified for SDT-33459
            EmailMessage email = new EmailMessage();
            email.subject = 'Test';
            email.ParentId = caselist[0].id;
            emailList.add(email); //Modified for SDT-33459
        Database.insert(emailList); //Modified for SDT-33459
        //System.debug('email insert--' + email);
        }
    
    @isTest static void testOwnerCheck(){
        //user currentuser = [select id, Bypass_Validation__c from user WHERE Id = :UserInfo.getUserId() limit 1];
//Querying CSR User.
        User currentuser = [SELECT Id, Bypass_Validation__c, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33459
        System.runAs(currentuser){
            List<EmailMessage> email = new List<EmailMessage>();
            for(EmailMessage e : [SELECT Id FROM EmailMessage LIMIT 4999]){
                email.add(e);   
            }
            //System.debug('emailmessage----' + email);
Test.startTest(); //Modified for SDT-33459
            closeEmailTaskController.taskOwnerCheck(email[0].id);
Test.stopTest(); //Modified for SDT-33459
        }
    }
    
    
    @isTest static void testTaskComplete(){
        EmailMessage email = [SELECT Id FROM EmailMessage LIMIT 1];
        //user currentuser = [select id, Bypass_Validation__c from user WHERE Id = :UserInfo.getUserId() limit 1];
//Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33459
        System.runAs(currentUser){
Test.startTest(); //Modified for SDT-33459
            closeEmailTaskController.EmailTaskComplete(email.id);
Test.stopTest(); //Modified for SDT-33459
        }
        
    }
    
   }