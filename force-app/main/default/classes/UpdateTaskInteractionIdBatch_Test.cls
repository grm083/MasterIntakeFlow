@isTest(seeAllData = false)
public class UpdateTaskInteractionIdBatch_Test {
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            List<Case>testCases = TestDataFactory.createNewCase();
            testCases[0].Origin = 'Chat Now';
            insert testCases;
            
            Task t = new Task();
            t.Status = 'Open';
            t.WhatId = testCases[0].id;
            t.Subject = 'Self-Service';
            t.Description = 'MediaType: 00HETETTEFDFDRZ Genesys Id: null';
            insert t;
            
        }
    }
    
    /* test method */
    @isTest static void updateTaskTest(){
        user currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        system.runAs(currentuser){
            String cronexp = '0 0 0 24 5 ? *';
            Test.startTest();
            UpdateTaskInteractionIdBatch UpdateTaskbatch = new UpdateTaskInteractionIdBatch();
            Database.executeBatch(UpdateTaskbatch);
            //String jobId = System.schedule('UpdateTaskInteractionIdBatch',  cronexp, new UpdateTaskInteractionIdBatch());
            Test.stopTest();
        }
    }
}