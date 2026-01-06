/**
* @date 5/12/2022
* @description : Its covers the WorkOrderReportCtrl class 
**/
@isTest
public class WorkOrderReportCtrlTest {
    
    public static testmethod void recordDetailsTest(){
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            Test.startTest();
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            locationlist[0].tz__Timezone_SFDC__c = 'America/Los_Angeles';
            locationlist[0].tz__Timezone__c = 'EST';
            Database.insert(locationlist);
            
            String acctName = WorkOrderReportCtrl.getRecordDetails(locationlist[0].Id);
            System.assertEquals(acctName, locationlist[0].Name);
            Test.stopTest();
        }
    }

}