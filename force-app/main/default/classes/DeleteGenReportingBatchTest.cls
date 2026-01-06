@isTest(seeAllData =false)
public with sharing class DeleteGenReportingBatchTest {
    
    @testSetup static void setup(){
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(p);
        insert usr;

        Genesys_Reporting__c gr = new Genesys_Reporting__c();
        insert gr;
    }

    @isTest
    static void testDelete(){
        User u = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        System.runAs(u){
            List<Genesys_Reporting__c> oldgenList = [SELECT Id FROM Genesys_Reporting__c];
            Test.setCreatedDate(oldgenList[0].id, datetime.newInstance(2019,1,1,1,1,1));
            
            Test.startTest();
            DeleteGenesysReportingBatch dg = new DeleteGenesysReportingBatch();
            Database.executeBatch(dg);
            Test.stopTest();
            
            List<Genesys_Reporting__c> newgenList = [SELECT Id FROM Genesys_Reporting__c];
            System.assert(newgenList.isEmpty());
        }
    }

    @isTest
        static void testSchedule() {
            User u = [SELECT id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
            system.runAs(u){
                List<Genesys_Reporting__c> grlst = [SELECT ID FROM Genesys_Reporting__c Limit 49999];
                Test.StartTest();
                String jobId = System.schedule('ScheduleApexClassTest',  '0 0 22 * * ? *', new scheduledDeleteGenReportingBatch());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                System.assertEquals('0 0 22 * * ? *', ct.CronExpression);
                System.assertEquals(0, ct.TimesTriggered);
                Test.StopTest();
        }
    }
}