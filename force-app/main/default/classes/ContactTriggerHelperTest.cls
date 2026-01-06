/**
* @author Accenture
* @date 12/4/2019
* @description : Apex class ContactTriggerHelperTest 
**/

/* test class for ContactTriggerHelper*/
@isTest(seeAllData = false)
public class ContactTriggerHelperTest {
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
    private static final string PROF_NAME = 'System User';
    private static final string MOB_NUMBER = '2323232323';
    private static final string UPDATED_MOB_NUMBER = '2323232324';
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
           
            List<Service_Approver__c> saList = TestDataFactory.createServiceApprover(approverList[0]);
            saList[0].Account__c = accList[0].Id;
            saList[0].Location__c = locationList[0].Id;
            saList[0].Approver_Contact__c = conList[0].Id;
            Database.insert(saList);
        }
    }
    /*method to test checkContactInServiceApprover*/
    @isTest static void createContactApproverTest(){
         User currentuser = [select Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363 
        
        system.runAs(currentuser){
            List<Contact> conList = [select Id FROM Contact LIMIT 1];
            Test.startTest();
            Database.Update(conList);
            Database.Delete(conList,false);
            Test.stopTest();
            system.assert(!conList.isEmpty());
        }
    }
    /* Method to test Exceptions*/
    @isTest static void exceptionHandling(){
        User currentuser = [select Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            Test.startTest();
            ContactTriggerHelper.checkContactInServiceApprover(null,null);
            Test.stopTest();
            system.assert(currentuser != null);
        }
    }

    /* Method to test text Notification optin optout*/
    @isTest static void itShouldTestTextOptInOptOut(){
        User currentuser = [select Id FROM user where isActive = True AND Name !=:PROF_NAME AND profile.name =:SYS_ADMIN  LIMIT 1];
        List<Contact> conList = [select Id FROM Contact LIMIT 1];
        conList[0].mobilephone = MOB_NUMBER;
        conList[0].Text_Notifications_Opt_In__c = True;
        System.runAs(currentuser)
        {
            Test.startTest();
            Database.Update(conList);
            conList[0].mobilephone = UPDATED_MOB_NUMBER;
            Database.Update(conList);
            Test.stopTest();
        }
        Contact conCheck = [select Id,Text_Notifications_Opt_In__c FROM Contact where id=:conList[0].id LIMIT 1];
        System.assertEquals(false, conCheck.Text_Notifications_Opt_In__c);
    }
    
     /* Method to test text Notification optin optout for contact merge*/
    @isTest static void itShouldTestTextOptInOptOutMerge(){
        User currentuser = [select Id FROM user where isActive = True AND Name !=:PROF_NAME AND profile.name =:SYS_ADMIN  LIMIT 1];
        Contact con = [select Id,lastname FROM Contact LIMIT 1];
        Contact clonedcon = con.clone(false,true,false,false);
        clonedcon.mobilephone = MOB_NUMBER;
        clonedcon.Text_Notifications_Opt_In__c = True;
        System.runAs(currentuser)
        {
			Test.startTest();
            Database.Insert(clonedcon);
            Database.merge(con,clonedcon,false);
			Test.stopTest();
        }
        Contact conCheck = [select Id,lastname,mobilephone FROM Contact where id=:con.Id LIMIT 1];
        System.assertEquals(null, conCheck.mobilephone);
    }

	   
    @isTest static void updateDateEmailValidatedTest(){
        User currentuser = [select Id FROM user where isActive = True AND Name !=:PROF_NAME AND profile.name =:SYS_ADMIN  LIMIT 1];
        Contact con = [select Id,lastname FROM Contact LIMIT 1];
        con.Email = 'pflbyxwy@wmtest.com';
        System.runAs(currentuser)
        {
			Test.startTest();
            Database.Update(con);
			Test.stopTest();
        }
       
    }
	
}