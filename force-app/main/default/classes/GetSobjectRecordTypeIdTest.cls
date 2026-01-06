/**
* @author Dinesh Kumar S
* @date 2/6/2019
* @description : Apex class GetSobjectRecordTypeIdTest 
**/

// test class for GetSobjectRecordTypeId
@isTest(seeAllData = false)
public class GetSobjectRecordTypeIdTest {
 	public static final string SYS_ADMIN = 'System Administrator';
    public static final string INPUT = 'Task;Approvals';
    // set the test data
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
    }
    // test method for fetching Sobject RecordType Id
    @isTest static void getRecordTypeIdTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        
        system.runAs(currentuser){
            GetSobjectRecordTypeId.getRecordTypeId(new List<string>{INPUT});
        }
    }
    // test method for fetching Sobject RecordType Id
    @isTest static void exceptionCoverage(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        
        system.runAs(currentuser){
            GetSobjectRecordTypeId.getRecordTypeId(null);
        }
    }
}