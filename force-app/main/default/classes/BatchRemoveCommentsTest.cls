@isTest
public class BatchRemoveCommentsTest {
    
    //Setup Data
    @testSetup static void setup() {
        
        List<Case> caseList = new List<Case>(); 
        for (Integer x = 1; x <= 10; x++) {
            Case c = new Case();
            c.Subject = 'Test Case';
            c.Tracking_Number__c = 'T12345678';
            c.CreatedDate = Date.valueOf('2020-01-01 00:00:00');
            caseList.add(c);
        }
        
        insert caseList;
        
        RecordType commentRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Acorn_Ticket_Comment'];
        
        List<Comment__c> commentList = new List<Comment__c>();
        for (Case cIterate : caseList) {
            Comment__c comment = new Comment__c();
            comment.Case__c = cIterate.Id;
            comment.Comment__c = 'Test Comment!!';
            comment.RecordTypeId = commentRT.Id;
            comment.CreatedDate = Date.valueOf('2020-01-01 00:00:00');
            commentList.add(comment);
        }
        
        insert commentList;
    }
    
    //testBatch
    @isTest static void testBatchRemoveComments() {
        
        List<user> currentUser = [SELECT Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentUser.get(0)) {
            String cronexp ='0 0 0 24 5 ? *';
            
            Test.startTest();
            String jobId = System.schedule('Test BatchRemoveComments', cronexp, new BatchRemoveComments());
            CronTrigger cronTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                    FROM CronTrigger
                                    WHERE Id = :jobId LIMIT 1];
            Test.stopTest();
            System.assertEquals(0, cronTrig.TimesTriggered);
        }
    }
}