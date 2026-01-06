/*************************************************************
@Name: ToActivateServiceApproversTest
@Author: Priyadharshini R
@CreateDate: 01/02/2019
@Description: Test Class to cover ToActivateServiceApprovers
*************************************************************/
@isTest(seeAllData = false)
public class ToActivateServiceApproversTest {
    
private static final string SYS_ADMIN = 'System Administrator';
private static final string EMAIL = 'standarduser@testorg.com';
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Business_Rule__c> businessrulelist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                                         locationlist.get(0));
            businessrulelist[0].RecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Database.insert(businessrulelist);
            list<Service_Approver__c> serviceApproverlist = TestDataFactory.createServiceApprover(businessrulelist[0]);
            serviceApproverlist[0].Recordtypeid = TestDataFactory.getRecordType('Email','Service_Approver__c');
            serviceApproverlist[0].Email__c = EMAIL;
            serviceApproverlist[0].Active__c = false;
            Database.insert(serviceApproverlist,false);
        }
    }
    /*Test Method to cover ToActivateServiceApprovers Batch*/
    @isTest static void standardSlaDateTime(){
        //test class errors - SDT - 33363
        User currentuser = [Select id,isActive from User WHERE isActive = TRUE limit 1];
            system.runAs(currentuser){		
				ToActivateServiceApprovers batch = new ToActivateServiceApprovers();
				Database.executeBatch(batch);
            }
		}	
}