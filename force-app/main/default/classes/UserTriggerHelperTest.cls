/**
* @author Anupreethy
* @date 12/4/2019
* @description : Apex class UserTriggerHelperTest 
**/

/* test class for UserTriggerHelper*/
@isTest(seeAllData = false)
public class UserTriggerHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string CUS_ACC_TEAM = 'Customer Account Team';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string EMPTY_AND_DO_NOT_RETURN = 'Empty and Do NOT Return';
    private static final string PO_NUMBER = 'PO Number';
    private static final string NAME = 'test';
    private static final string NAME1 = 'test1';
    private static final string ASSET_NAME = '8 yrd Dumpster';
    private static final string USER_RECTYPE = 'User';
    private static final string ATM_RECTYPE = 'Account Team Member';
    private static final string EMAIL = '@testorg.com';
    private static final string SYS_ADMIN_NAME = 'Sys_Admin2';
    /*test data setup*/
    @testSetup static void setup(){
        Profile profAdmin = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(profAdmin);
     
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
            AccountTeamMember accTeamMem = TestDataFactory.createAccountTeamMember(accList.get(0),currentUser.id);
            Database.insert(accTeamMem);
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
            List<Service_Approver__c> saList = TestDataFactory.createServiceApprover(approverList[0]);
            saList[0].Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get(USER_RECTYPE).getRecordTypeId();
            saList[0].Account__c = accList[0].Id;
            saList[0].Location__c = locationList[0].Id;
            saList[0].User__c = currentUser.Id;
            Database.insert(saList);
            
            Profile profCusAcc = TestDataFactory.getProfile(CUS_ACC_TEAM);
        	User currentUserAccTeam = TestDataFactory.createUser(profCusAcc);
        	currentUserAccTeam.ProfileId = profCusAcc.Id; //pkulkarn-TCS-SDT-38449-7-Mar-2024-Added to fix the test class failures
            Database.insert(currentUserAccTeam);
            
            List<Service_Approver__c> saList1 = TestDataFactory.createServiceApprover(approverList[0]);
            saList[0].Recordtypeid = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get(ATM_RECTYPE).getRecordTypeId();
            saList1[0].Account__c = accList[0].Id;
            saList1[0].Location__c = locationList[0].Id;
            saList1[0].Account_Team_Member__c = currentUserAccTeam.Id;
            Database.insert(saList1);
        }
    }
    /*method to test User in checkRelatedServiceApprover*/
    @isTest static void checkRelatedServiceApproverTest(){
        
        Profile profAdmin = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(profAdmin);
        currentUser.UserName = SYS_ADMIN_NAME + String.valueof(system.now().millisecond())+ EMAIL;
        Database.insert(currentUser);
        system.runAs(currentuser){
            Service_Approver__c sap = [SELECT Id,User__c,Account_Team_Member__c FROM Service_Approver__c where User__c !=null LIMIT 1];
          
            User us = [select Id, Bypass_Validation__c,IsActive FROM user WHERE Id =:sap.User__c LIMIT 1];
			us.IsActive = false;
            
            Test.startTest();
            Database.update(us,false);
            
            us = [select Id, Bypass_Validation__c,IsActive FROM user WHERE Id =:sap.User__c LIMIT 1];
            Test.stopTest();
            system.assert(us.IsActive, 'User is Inactive');	//pkulkarn-TCS-SDT-38449-7-Mar-2024-Added 2nd parameter
        } 
    }
    /* Method to test Account team memeber in checkRelatedServiceApprover*/
    @isTest static void checkRelatedAccTeamServiceApproverTest(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        //Map<Id,User> newMap = new Map<Id,User>();	//pkulkarn-TCS-SDT-38449-7-Mar-2024-Commented unused variable
        //Map<Id,User> oldMap = new Map<Id,User>();	//pkulkarn-TCS-SDT-38449-7-Mar-2024-Commented unused variable
        system.runAs(currentuser){
            Service_Approver__c sa = [SELECT Id,Account_Team_Member__c,User__c FROM Service_Approver__c where Account_Team_Member__c != null LIMIT 1];
            
            User currentuserAccTeamRecord = [select id, Bypass_Validation__c,IsActive from user where ID =: sa.Account_Team_Member__c LIMIT 1];
            currentuserAccTeamRecord.IsActive=false;
            
            Test.startTest();
            Database.update(currentuserAccTeamRecord,false);
            currentuserAccTeamRecord = [select id, Bypass_Validation__c,IsActive from user where ID =: sa.Account_Team_Member__c LIMIT 1];
            Test.stopTest();
            system.assertEquals(currentuserAccTeamRecord.IsActive, true, 'User is Inactive');	//pkulkarn-TCS-SDT-38449-7-Mar-2024-Added 3rd parameter
        } 
    }
    
    /* Method to test Exceptions*/
    @isTest static void exceptionHandling(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE limit 1];
        
        system.runAs(currentuser){
            Test.startTest();
            UserTriggerHelper.checkRelatedServiceApprover(null,null);
            Test.stopTest();
            System.assert(currentuser.Id!=null, 'User is Inactive');	//pkulkarn-TCS-SDT-38449-7-Mar-2024-Added 2nd parameter
        }
    }
}