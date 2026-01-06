@isTest(seeAllData = false)
public with sharing class BatchCreateUnspecifiedContactsTest {
    @testSetup static void setup() {
		Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
        //create account
        list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,'Client');
        acclist[0].Self_Service_Eligible__c = true;
        Database.insert(acclist);

        list<Account> acclist2 = TestDataFactory.createAccount('Cleint22', usr,'Client');
        acclist2[0].Self_Service_Eligible__c = true;
        Database.insert(acclist2);
        
        //create location
        list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
        Database.insert(locationlist);

        //create location
        list<Account> locationlist2 = TestDataFactory.createLocation('Loc222', usr, acclist2.get(0).id);
        Database.insert(locationlist2);
        
        //create contact
        list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, 
                                                            Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
        Database.insert(conlist);
        
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
        assetlist[0].Quantity__c = 5;
        Database.insert(assetlist);
        
        //create case
        list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                            usr, locationlist.get(0), assetlist.get(0));
        Database.insert(caselist);           
        
        //create Workorder
        List<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), 
                                                                        assetlist.get(0));
        workOrderList[0].Vendor_Account_Id__c = supplieracclist.get(0).Id;                                                                
        Database.insert(workOrderList);
        
        list<WorkOrderLineItem> WorkOrderLineItems = TestDataFactory.createWorkOrderLineItem( workOrderList[0]);
        Database.insert(WorkOrderLineItems);

        }
    }

    /* test method */
    @isTest static void CreateContactTest(){
        user currentuser = [select id, Bypass_Validation__c ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363   
        account locAcc = [select Id,Name from Account where RecordType.name = 'Location' limit 1];  
        account clientAcc = [select Id,Name from Account where RecordType.name = 'Client' limit 1];
        Contact contact = [select Id from Contact];
        list<Contact> conlist = TestDataFactory.createContact('Unspecified', locAcc.Name, clientAcc, currentuser);
        Database.insert(conlist);
        system.runAs(currentuser){
            String cronexp = '0 0 0 24 5 ? *';
            
            Test.startTest();
                //String jobId = System.schedule('Test BatchCreateUnspecifiedContacts',  cronexp, new BatchCreateUnspecifiedContacts());
                   Database.ExecuteBatch(new BatchCreateUnspecifiedContacts(), 200);
            Test.stopTest();
        }
    }

     @isTest static void CreateContactTest2(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363      

        system.runAs(currentuser){
            String cronexp = '0 0 0 24 5 ? *';
            
            Test.startTest();
                //String jobId = System.schedule('Test BatchCreateUnspecifiedContacts',  cronexp, new BatchCreateUnspecifiedContacts());
                   Database.ExecuteBatch(new BatchCreateUnspecifiedContacts(), 200);
            Test.stopTest();
        }
    }

}