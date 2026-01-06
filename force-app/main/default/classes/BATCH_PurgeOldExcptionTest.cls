@isTest
public class BATCH_PurgeOldExcptionTest {
    
    private static final String SYSTEM_ADMIN = 'System Administrator';
    private static final String TEST_NAME = 'Test';
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYSTEM_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        ExceptionLog__c excpRec = new ExceptionLog__c(Exception_Details__c=TEST_NAME,Exception_Type__c=TEST_NAME);
        insert excpRec;
        ExceptionLog_Settings__c logLevel = ExceptionLog_Settings__c.getInstance(UserInfo.getOrganizationId());
        logLevel.Logging_Level__c=UTIL_ErrorConstants.SEVERITY_LEVEL_ERROR;
        insert logLevel;
    }
    
     private static testmethod void dataDelete(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        ExceptionLog__c[] excpRec = Database.query('Select Id From ExceptionLog__c Where CreatedDate < N_DAYS_AGO:30');
        Database.BatchableContext currentScope;
        BATCH_PurgeOldExcption batchVar = new BATCH_PurgeOldExcption();
        Test.startTest();
        System.runAs(currentuser){
            batchVar.execute(currentScope, excpRec);
        }
        Test.stopTest();
        excpRec = Database.query('Select Id From ExceptionLog__c Where CreatedDate < N_DAYS_AGO:30');
        System.assert(excpRec.isEmpty());
    }

}