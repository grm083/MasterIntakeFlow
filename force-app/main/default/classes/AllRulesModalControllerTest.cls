/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-06-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

/**
 * @description   : Get Business Rules
 * @Created Date  : 04-02-2023
**/
@isTest
public class AllRulesModalControllerTest {
    
    // set the test data
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        System.runAs(usr){
            List<Account> acclist = TestDataFactory.createAccount('Test client', usr,'Client');
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation('Test Location', usr, acclist.get(0).id);
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact('first', 'last', acclist.get(0), usr);
            conlist[0].Preferred_Method__c = 'Email' ;
            conlist[0].Email = 'abc@gmail.com';
            Database.insert(conlist);
            
            List<Product2> productlist = TestDataFactory.createProduct('test');
            Database.insert(productlist);
            
            List<Account> supplieracclist = TestDataFactory.createAccount('testsupplier', usr,'Vendor');
            Database.insert(supplieracclist);
            
            List<Asset> assetlist = TestDataFactory.createAsset('first', acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0].Supplier__c = supplieracclist[0].Id;
            Database.insert(assetlist);
            
            // returns 4 cases as of 3/20/2020
            List<Case> caselist = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].AccountId = locationlist[0].Id;
            caselist[0].PurchaseOrder_Number__c =  '1243';
            caselist[0].Case_Type__c = 'Pickup';
            caselist[0].Case_Sub_Type__c = 'Extra Pickup';
            Database.insert(caselist);
            
            // returns 4 cases as of 3/20/2020
            List<Case> caselist2 = TestDataFactory.createCase('first', acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist2[0].AccountId = locationlist[0].Id;
            caselist2[0].PurchaseOrder_Number__c =  '1243';
            caselist2[0].Case_Type__c = 'Pickup';
            caselist2[0].Case_Sub_Type__c = 'Extra Pickup';
            caselist2[0].parentId =  caselist[0].Id;
            Database.insert(caselist2);
            
            // returns a single Extra Pickup Business Rule
            List<Business_Rule__c> approverlst = TestDataFactory.createBusinessRule('test1',acclist.get(0),locationlist.get(0));
            approverlst[0].RecordTypeid = 
            Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();           
            approverlst[0].Request_Type__c = 'Pickup';
            approverlst[0].Service__c = 'Extra Pickup';
            approverlst[0].Active__c = True;
            insert approverlst;

            // returns a single service approver in a list
            List<Service_Approver__c> salst = TestDataFactory.createServiceApprover(approverlst[0]);
            salst[0].Email__c = 'abc@gmail.com';
            salst[0].Business_Rule__c = approverlst[0].Id;
            salst[0].User__c = usr.Id;
            salst[0].Requester_Only__c= false;
            salst[0].Approver_Contact__c = conlist[0].Id;
            salst[0].Active__c = True;
            insert salst;
            System.debug('salst'+salst);
        }
    }
    
    //Method to cover fetch all BR on location
    @isTest static void testFetchAllBusinessRules() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        System.runAs(currentuser){
            
            Test.startTest();
            List<Account> account = [SELECT Id
                                        FROM Account 
                                        WHERE Name = 'Test Location'
                                        LIMIT 1];
            List<AllRulesModalController.CaseRecordTypeWrapper> wrapperList = AllRulesModalController.fetchAllBusinessRules(account[0].id);
            Test.stopTest();
            system.assert(wrapperList.size() != 0);
        }        
    }

    //Method to cover fetch all BR on client
    @isTest static void testFetchAllBusinessRulesClient() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User currentuser = [SELECT Id, Bypass_Validation__c 
                            FROM User
                            WHERE ProfileId =: p.Id 
                            AND isActive =: true
                            LIMIT 1];
        
        System.runAs(currentuser){
            
            Test.startTest();
            List<Account> account = [SELECT Id
                                        FROM Account 
                                        WHERE Name = 'Test client'
                                        LIMIT 1];
            List<AllRulesModalController.CaseRecordTypeWrapper> wrapperList = AllRulesModalController.fetchAllBusinessRules(account[0].id);
            Test.stopTest();
            system.assert(wrapperList.size() != 0);
        }        
    }

}