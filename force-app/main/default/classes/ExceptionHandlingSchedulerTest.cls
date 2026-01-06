/*************************************************************
@Name: ExceptionHandlingSchedulerTest 
@Author: WM
@CreateDate: 01/03/2021
@Description: Test class for ExceptionHandlingScheduler.
@UsedBy: 
**************************************************************/
@isTest
public class ExceptionHandlingSchedulerTest {
    
    @testSetup static void setup() 
    {
        TestDataFactory.createExceptionData();
        ExceptionLog_Settings__c exc = new ExceptionLog_Settings__c();
        exc.Exception_Type_Limit__c = 10;
        exc.Exception_Log_Email_DL__c = 'test@wm.com';
        exc.Logging_Level__c = 'Error';
        exc.Exception_Log_Removal_Days__c = 30;
        insert exc;
    }
    
    private static testMethod void itShouldTestExceptionEmail()
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();

            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new ExceptionHandlingScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}