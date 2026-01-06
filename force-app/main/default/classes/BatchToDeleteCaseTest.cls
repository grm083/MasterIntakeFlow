/*************************************************************
@Name: BatchToDeleteCaseTest
@Author: Kalaiselvi
@CreateDate: 24/05/2019
@Description: Test class of BatchToDeleteCase
**************************************************************/
@isTest
public class BatchToDeleteCaseTest {
    
    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Case> caselist = TestDataFactory.createNewCase();
            caselist[0].Mark_to_delete__c = true;
            Database.insert(caselist);
        }
    }
    
    //Test Batch to Delete Case
    @isTest static void testBatchToDeleteCase() {
        
        List<user> currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
       
        system.runAs(currentuser.get(0)){
            String cronexp = '0 0 0 24 5 ? *';
            
            Test.startTest();
                String jobId = System.schedule('Test BatchToDeleteCase',  cronexp, new BatchToDeleteCase());
                CronTrigger cronTrgr = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger
                                        WHERE id = :jobId Limit 1];             
            Test.stopTest();
            System.assertEquals(0, cronTrgr.TimesTriggered);
        }
    }
}