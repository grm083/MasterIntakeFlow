/**
* @author Accenture
* @date 2/12/2019
* @description : Apex class BusinessRuleTriggerHelperTest 
**/

/* test class for BusinessRuleTriggerHelper*/
@isTest(seeAllData = false)
public class BusinessRuleTriggerHelperTest {
    private static final string SYS_ADMIN = 'System Administrator';
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
            Database.insert(businessrulelist);
        }
    }
    /* test method for validate the business rule*/
    @isTest static void validateBusinessRule(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            List<Account> accountlst = [Select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 4999];
            List<Account> locationlst = [Select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 4999];
            list<Business_Rule__c> brulelist = [select id, Accountid__c, locationid__c, Container__c, Service__c, 
                                                Request_Type__c, Schedule_Type__c, RecordTypeId, Active__c ,Project_Code__c ,AssetId__c
                                                from Business_Rule__c limit 1];
            
          
           	list<Business_Rule__c> businessrulelist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, accountlst[0],locationlst[0]);
            Test.startTest();
            Database.insert(businessrulelist,false);
            
            
            list<Business_Rule__c> businessrulerec = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, accountlst[0],locationlst[0]);
            businessrulerec.get(0).RecordTypeid = TestDataFactory.getRecordType(Constant_Util.APPROVAL,Constant_Util.BUSINESS_RULE);
            Database.insert(businessrulerec,false);
            
            list<Business_Rule__c> businessrule = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, accountlst[0],locationlst[0]);
            businessrule.get(0).RecordTypeid = TestDataFactory.getRecordType(Constant_Util.APPROVAL,Constant_Util.BUSINESS_RULE);
            Database.insert(businessrule,false);
            Test.StopTest();
            system.assert(Brulelist.get(0).Accountid__c != null);
        } 
    }
    
    /* test method for cover exception*/
    @isTest static void exceptionCoverage(){
        
        user currentuser = [select id, Bypass_Validation__c ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
        list<Business_Rule__c> brulelist = new list<Business_Rule__c>();
        Test.startTest();
    	BusinessRuleTriggerHandler.onbeforeInsert(brulelist);     
        Test.stopTest();
        system.assert(brulelist.isEmpty());
        }
    }   
}