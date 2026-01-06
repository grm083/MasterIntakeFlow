@isTest
public class SCH_PurgeOldExcptionSchedulerTest {
    
    private static final String SYSTEM_ADMIN = 'System Administrator';
    private static final String CUSTOM_SETTING_RECORD = 'Test record';
    private static final String SCHEDULED_TIME = '0 0 23 * * ?';
    private static final String JOB_NAME = 'Test Check';
    private static final String JOB_STATUS = 'WAITING';
    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYSTEM_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
        ExceptionLog_Settings__c exceptionBatchDays = new ExceptionLog_Settings__c(Name=CUSTOM_SETTING_RECORD, Exception_Log_Removal_Days__c=30);
        insert exceptionBatchDays;
	}

    private static testMethod void scheduleDelete(){
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        SCH_PurgeOldExcptionScheduler schVar = new SCH_PurgeOldExcptionScheduler();
        String sch = SCHEDULED_TIME ;
        String jobId = UTIL_ErrorConstants.BLANK_SPACE;
        Test.StartTest();
        System.runAs(currentuser){
            jobId = System.Schedule(JOB_NAME, sch, schVar);
        }
        Test.stopTest();
        CronTrigger schData = [SELECT Id, State FROM CronTrigger WHERE Id =: jobId];
        System.assertEquals(schData.State, JOB_STATUS);                  
    }
}