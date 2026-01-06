/**
* @author Anupreethy
* @date 12/4/2019
* @description : Apex class AccountTitleTriggerHelperTest 
**/

/*test class for AccountTitleTriggerHelper*/
@isTest(seeAllData = false)
public class AccountTitleTriggerHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string EMPTY_AND_DO_NOT_RETURN = 'Empty and Do NOT Return';
    private static final string PO_NUMBER = 'PO Number';
    private static final string NAME = 'test';
    private static final string NAME1 = 'test1';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    /*test data setup*/
    @testSetup static void setup(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,Constant_Util.CLIENT);
            Database.insert(accList);
            List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
            Database.insert(locationList);
            List<Contact> conList = TestDataFactory.createContact(RITA,REPLY, accList.get(0), currentUser);
            Database.insert(conList);
            List<product2> productList = TestDataFactory.createProduct(PRODUCT);
            Database.insert(productList);
            List<Asset> assetList = TestDataFactory.createAsset(ASSET_NAME , accList.get(0), conList.get(0), 
                                                                productList.get(0), currentUser, locationList.get(0));
            Database.insert(assetList);
            List<Business_Rule__c> brList = TestDataFactory.createBusinessRule(NAME,accList.get(0),locationList.get(0));
            brList[0].Service__c = EMPTY_AND_DO_NOT_RETURN;
            brList[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            brList[0].Container__c = Constant_Util.EMPTY_STRING;
            brList[0].AssetId__c = assetList[0].id;
            brList[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            brList[0].Required_Information__c = PO_NUMBER; 
            Database.insert(brList);
            
            List<Business_Rule__c> approverList = TestDataFactory.createBusinessRule(NAME1 ,accList.get(0),locationList.get(0));
            approverList[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            approverList[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            approverList[0].Container__c = Constant_Util.EMPTY_STRING;
            approverList[0].AssetId__c = assetlist[0].Id;
            approverList[0].Multiple_Mandatory_Approvers__c = true;
            approverList[0].Service__c = EMPTY_AND_DO_NOT_RETURN;
            Database.insert(approverList);
            Account_Title__c accTitle = new Account_Title__c();
            accTitle.Account__c = accList[0].Id;
            accTitle.Name = NAME1;
            accTitle.Status__c = Constant_Util.ACTIVE;
            accTitle.Business_Rule_Title__c = true;
            Database.insert(accTitle);
            List<Service_Approver__c> saList = TestDataFactory.createServiceApprover(approverList[0]);
            saList[0].Account__c = accList[0].Id;
            saList[0].Location__c = locationList[0].Id;
            saList[0].Title__c = accTitle.Id;
            Database.insert(saList);
        }
    }
    
    /*method to test checkTitleInServiceApprover*/
     @isTest static void inactiveStatusAccTitleApproverTest(){
         User currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
         Map<Id,Account_Title__c> oldAccTitleMap = new Map<Id,Account_Title__c>();
         Map<Id,Account_Title__c> newAccTitleMap = new Map<Id,Account_Title__c>();
        system.runAs(currentuser){
            Account_Title__c accTile = [select id,Status__c from Account_Title__c limit 1];
            accTile.Status__c=Constant_Util.INACTIVE;
            Test.startTest();
            Database.update(accTile,false);
            Database.delete(accTile,false);
            Test.stopTest();
            accTile = [select id,Status__c from Account_Title__c limit 1];
            System.assert(accTile!=null);
        }
    }
    /* Method to test Exceptions*/
    @isTest static void exceptionHandling(){
        User currentuser = [select id, Bypass_Validation__c,IsActive from user Where IsActive = true limit 1]; //SDT-33363
        system.runAs(currentuser){
            Test.startTest();
            AccountTitleTriggerHelper.checkTitleInServiceApprover(null,null,null);
            Test.stopTest();
            System.assert(currentuser!=null);
        }
    }
}