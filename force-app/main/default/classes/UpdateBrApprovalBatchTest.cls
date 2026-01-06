@isTest(seeAllData = false)
public class UpdateBrApprovalBatchTest {
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
        List<Account> acctList = insertAccounts();
      
            
            list<Business_Rule__c> brlist = new list<Business_Rule__c>();
            Business_Rule__c brObj = new Business_Rule__c();
            brObj.Accountid__c = acctList[0].Id;
            //brObj.LocationId__c = pickupCase.Location__c;
            brObj.Request_Type__c = 'New Service';
            brObj.Service__c = 'Permanent';
            brObj.RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
            brObj.Effective_Date__c = System.today()-1;
            brObj.Active__c=True;
            brObj.No_Approval_Required__c = true;
            brObj.Is_Auto_Email__c = false;
            brlist.add(brObj);
            Database.insert(brlist);
        }
    }
    
    public static List<Account> insertAccounts(){
        List<Account> acctList = new List<Account>();
        RecordType customerType = [SELECT Id FROM RecordType WHERE Name = 'Client'];
        //addition for S11 test class errors
        RecordType locationType = [SELECT Id FROM RecordType WHERE Name = 'Location'];
        RecordType vendorType = [SELECT Id FROM RecordType WHERE Name = 'Vendor'];
        //addition for S11 test class errors - changed recordtype to location
        Account customer = new Account(Name = 'Test Customer', RecordTypeId = locationType.Id);
        Account parentCustomer = new Account(Name = 'Test Parent', RecordTypeId = customerType.Id,AccountNumber = '81');
        Account childVendor = new Account(Name = 'Test Vendor', RecordTypeId = vendorType.Id,
                                    Status__c = 'Active', AccountNumber = '111266', Vendor_Business_Unit__c = '1');
        Account parentVendor = new Account(Name = 'Parent Vendor', RecordTypeId = vendorType.Id,
                                    Status__c = 'Active', AccountNumber = '8');
        Account wmVendor = new Account(Name = 'WM', RecordTypeId = vendorType.Id,
                                       Status__c = 'Active', AccountNumber = '8');
        Account wmFeeVendor = new Account(Name = 'WM Fee', RecordTypeId = vendorType.Id,
                                          Status__c = 'Active', AccountNumber = '8');
        
                                  
        
        acctList.add(customer);
        acctList.add(parentCustomer);
        acctList.add(childVendor);
        acctList.add(parentVendor);
        acctList.add(wmVendor);
        acctList.add(wmFeeVendor);
        
        insert acctList;
        
        acctList[2].ParentId = acctList[3].id;
        acctList[0].ParentId = acctList[1].id;
        update acctList;
        
        return acctList;
    }
    /* test method */
    @isTest static void updateBrApproval(){
        user currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            
            Test.startTest();
            UpdateBrApprovalBatch Updatebrbatch = new UpdateBrApprovalBatch();
            Database.executeBatch(Updatebrbatch);
         
            Test.stopTest();
        }
    }
    
    
}