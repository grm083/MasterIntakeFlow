/**
* @author WM
* @date 9/20/2022
* @description : test class for BR_RelatedListController 
**/

@isTest(seeAllData = false)
public class BR_RelatedListControllerTest {
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
        user currentuser = [select id, Bypass_Validation__c ,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            List<Account> accountlst = [Select id from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.CLIENT).getRecordTypeId() LIMIT 4999];
            List<Account> locationlst = [Select id,Brand__c,Division__c,Geography__c,Location_Type__c from Account where RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constant_Util.LOCATION).getRecordTypeId() LIMIT 1];
            List<Categorization__c> categoList = new List<Categorization__c> ();
            Categorization__c cg = new Categorization__c();
            cg.Client_Account__c = accountlst[0].Id;
            cg.Category__c = 'Brand';
            cg.Name = 'Kroger Type';
            categoList.add(cg);
            Categorization__c cgLtype = new Categorization__c();
            cgLtype.Client_Account__c = accountlst[0].Id;
            cgLtype.Category__c = 'Location Type';
            cgLtype.Name = 'LT';
            categoList.add(cgLtype);
            Categorization__c cgGeoLoc = new Categorization__c();
            cgGeoLoc.Client_Account__c = accountlst[0].Id;
            cgGeoLoc.Category__c = 'Geography';
            cgGeoLoc.Name = 'GEo';
            categoList.add(cgGeoLoc);
            Categorization__c cgDepDiv = new Categorization__c();
            cgDepDiv.Client_Account__c = accountlst[0].Id;
            cgDepDiv.Category__c = 'Division/Department';
            cgDepDiv.Name = 'division';
            categoList.add(cgDepDiv);
            Database.insert(categoList);
            locationlst[0].Brand__c = categoList[0].Id ;
            locationlst[0].Location_Type__c = categoList[1].Id ;
            locationlst[0].Geography__c = categoList[2].Id ;
            locationlst[0].Division__c = categoList[3].Id ;
            update locationlst ;
            BR_RelatedListController.getBrRecords(locationlst[0].Id);
        }
    }
}