/**
* @author WM
* @date 7/16/2019
* @description : Apex class EmailMessageContactMapping
**/
@isTest(SeeAllData=false)
public class EmailMessageContactMappingTest {
    private static final string NAME = 'test';
    private static final string EMAIL = 'test@wm.com';
    
    /**
* @description set the test data
*/ 
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation('FAM002508', usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Account> locationlist2 = TestDataFactory.createLocation('FAM002509', usr, acclist.get(0).id);
            Database.insert(locationlist2);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                                  Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            AccountContactRelation acr = new AccountContactRelation (ContactId = conlist.get(0).Id, 
                                                                     AccountId = locationlist.get(0).Id);
            Database.insert(acr);
            //create product
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            
            //create vendor
            list<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            
            //create asset
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist.get(0).Id;
            Database.insert(assetlist);
            
            //create case
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Location__c = null;
            caselist[0].AssetId = null;
            Database.insert(caselist);
            
            //create Business Rule
            List<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(NAME, acclist.get(0),locationlist.get(0));
            brlst[0].Service__c = Constant_Util.EXTRA_PICKUP;
            brlst[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brlst[0].Container__c = Constant_Util.EMPTY_STRING;
            brlst[0].AssetId__c = assetlist[0].Id;
            brlst[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            Database.insert(brlst);
            
            //create Service Approver
            list<Service_Approver__c> serviceConApproverlist = TestDataFactory.createEmailServiceApprover(brlst[0]);
            serviceConApproverlist[0].Active__c=true;
            Database.insert(serviceConApproverlist, false);
        }   
    }
    
    @isTest static void emailMessageContactTest(){
        User usr =  [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        List<Case> lstCase = new List<Case>();
        lstCase = [Select Id from Case];
        
        List<Account> lstLocation = new List<Account>();
        lstLocation = [select Id,Name,Location_Code__c,ParentId from Account where 
                       RecordType.DeveloperName =: Constant_Util.LOCATION];
        
        Contact con = [SELECT id,Contact_Status__c,Email FROM Contact WHERE Accountid =: lstLocation[0].ParentId  LIMIT 1];
        con.Contact_Status__c = Constant_Util.ACTIVE;
        con.Email = EMAIL;
        Database.update(con, false);
        
        List<Business_Rule__c> brlst = [SELECT Id, Accountid__c, locationid__c, Container__c,
                                        Service__c, Request_Type__c, Schedule_Type__c, Active__c, 
                                        Effective_Date__c, RecordTypeid, Required_Information__c 
                                        FROM Business_Rule__c LIMIT 1];
        
        brlst[0].Active__c = true;
        Database.Update(brlst, false);
        
        List<Service_Approver__c> salst = [SELECT Id,Active__c, Business_Rule__c,Approver_Contact__c,Service_Approver__c.Title__c 
                                           FROM Service_Approver__c where Business_Rule__c =:brlst[0].id LIMIT 1];
        salst[0].Active__c = true;
        Database.Update(salst, false);
        
        
        system.runAs(usr){
            String Subject = Constant_Util.KEYWORD_TEST;
            String Body = Constant_Util.KEYWORD_TEST + ' lOCatioN # FAM002508';
            List<EmailMessage> lstEM = new List<EmailMessage>();
            lstEM = TestDataFactory.createEmailMessage(Subject, Body, lstCase.get(0));
			Test.startTest();
            Database.insert(lstEM);
            
            List<Case> cases = [SELECT Id,Contact.Name FROM Case];
            cases[0].ContactId = con.id;
            Database.update(cases);
            
            List<EmailMessage> testEm = [SELECT Id,FromAddress,ParentId,Bypass_Genesys_Task__c FROM EmailMessage limit 1];
            testEm[0].FromAddress = EMAIL;
            Database.update(testEm);                
            
            
            EmailMessageContactMapping.emailMessageContact(testEm);
            Test.stopTest();
            
            Case c = [select id,ContactId from case where Id =:cases.get(1).Id LIMIT 1];
            System.assert(c.ContactId != null);
            System.assertEquals(4, cases.size());
            
        }
    }
}