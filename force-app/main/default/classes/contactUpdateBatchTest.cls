/*************************************************************
@Name: contactUpdateBatch
@Author: Accenture
@CreateDate: 03/08/2020
@Description: SDT- 13765
@UsedBy: contactUpdateBatch
**************************************************************/
@isTest(seeAllData = false)
public class contactUpdateBatchTest {
	private static final string SYS_ADMIN = 'System Administrator';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    private static final string KROGER = 'kroger';
    private static final string NAME1 = 'test1';
    private static final string EMPTY_AND_DO_NOT_RETURN = 'Empty and Do NOT Return';
    private static final string EMPTY = '';
    /*test data setup*/
    @testSetup static void setup(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser) {
            
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,Constant_Util.CLIENT);
            Database.insert(accList);
            
            List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
            Database.insert(locationList);
            
            List<Contact> conList = TestDataFactory.createContact(RITA,REPLY, accList.get(0), currentUser);
            Database.insert(conList);
            
            List<Business_Rule__c> approverList = TestDataFactory.createBusinessRule(NAME1 ,accList.get(0),locationList.get(0));
            approverList[0].RecordTypeid = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            approverList[0].Schedule_Type__c = Constant_Util.EMPTY_STRING;
            approverList[0].Container__c = Constant_Util.EMPTY_STRING;
            approverList[0].Multiple_Mandatory_Approvers__c = true;
            approverList[0].Service__c = EMPTY_AND_DO_NOT_RETURN;
            Database.insert(approverList);
           
            List<Service_Approver__c> saList = TestDataFactory.createServiceApprover(approverList[0]);
            saList[0].Account__c = accList[0].Id;
            saList[0].Location__c = locationList[0].Id;
            saList[0].Approver_Contact__c = conList[0].Id;
            Database.insert(saList);
            
            AccountContactRelation testACR1 = 
            TestDataFactory.returnAccConRel(locationList[0].Id, conList[0], 'Commercial Service/Dispatch');
            Database.insert(testACR1);
        }
    }
    
    public static testmethod void contactUpdateBatchTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
			AccountContactRelation acr =  [SELECT id, AccountId,ContactId FROM AccountContactRelation Limit 1];
            
            contact con = [Select Id,No_Of_Locations_Assoc_With_Contact__c,Business_Rule_Association__c from Contact where Id =: acr.ContactId Limit 1];
            con.No_Of_Locations_Assoc_With_Contact__c = 0;
            con.Business_Rule_Association__c = EMPTY;
            update con;
            Test.startTest();
            	Database.executeBatch(new contactUpdateBatch(),200);
            Test.stopTest();
            contact updatecon = [Select Id,No_Of_Locations_Assoc_With_Contact__c,Business_Rule_Association__c from Contact where Id =: acr.ContactId Limit 1];
            system.assertEquals(1,updatecon.No_Of_Locations_Assoc_With_Contact__c);
            system.assertEquals('Yes', updatecon.Business_Rule_Association__c);
        }
    }
}