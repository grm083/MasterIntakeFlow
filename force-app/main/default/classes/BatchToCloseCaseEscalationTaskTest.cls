@isTest
public class BatchToCloseCaseEscalationTaskTest {
      public static final string SYS_ADMIN = 'System Administrator';
    @testSetup static void setup() {
       
          User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(usr){
            List<Case> testCases = TestDataFactory.createNewCase();
            testCases[0].status = 'Open';
            insert testCases;
             
         /**   List<Task> taskList = new List<Task>(); //Modified for SDT-33457
            Task t = new Task();
            t.Status = 'Open';
            t.Process__c = 'Escalation Obtain Service Approval';
            t.Outcome__c = 'Approved';
            t.Attempt__c = 2;
            t.WhatId = testCases[0].id;
            taskList.add(t); //Modified for SDT-33457
            insert taskList; //Modified for SDT-33457**/
            
            list<Task> tasklist = TestDataFactory.createTask(testCases.get(0).id, usr);
            tasklist[0].RecordTypeId = TestDataFactory.getRecordType('Escalation',Constant_Util.OBJECT_TASK);
            tasklist[0].Process__c = 'Escalation Obtain Service Approval';
             tasklist[0].Attempt__c = 2;
            Database.insert(tasklist);

        }
    }
    
    /* test method */
    @isTest static void itShouldCloseTask(){
        //user currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        //Querying CSR User.
       User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(usr){
            Test.startTest();
              BatchToCloseCaseEscalationTask batchprocess = new BatchToCloseCaseEscalationTask();
            Id batchId = Database.executeBatch(batchprocess);
             Test.stopTest();
        }
    }
}