//@isTest
//public class BatchToPurgeCaseTest {
@isTest
public class BatchToPurgeCaseTest {
    
    // method for setting up data    
    @isTest static void testBatchToPurgeCase(){
        Test.startTest();
        Database.BatchableContext dbc;
        VRBatchSetting__c vrSetting = new VRBatchSetting__c();
        VRSetting.IsBatchExecution__c = false;
        insert VRSetting;
        List<Case> caseList = new List<Case>();    
        Case case1 = new Case(Status ='New', Recordtypeid = TestDataFactory.getRecordType(Constant_Util.PICKUP,'Case'));
        Case case2 = new Case(Status ='New', Recordtypeid = TestDataFactory.getRecordType(Constant_Util.PICKUP,'Case'));
        Case case3 = new Case(Status ='New', Recordtypeid = TestDataFactory.getRecordType(Constant_Util.PICKUP,'Case'));
        
        caseList.add(case1);
        caseList.add(case2);
        caseList.add(case3);
        
        Database.insert(caselist);
        String cronexp = '0 0 9 * * ? *';
        BatchToPurgeCase b = new BatchToPurgeCase();
        b.execute(dbc,caseList);
        Database.executeBatch(b);
        
        String jobId = System.schedule('Test BatchToPurgeCase',  cronexp, new BatchToPurgeCase());
        CronTrigger cronTrgr = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger
                                        WHERE id = :jobId Limit 1];    
        Test.stopTest();
        System.assertEquals(0, cronTrgr.TimesTriggered);
    }
}