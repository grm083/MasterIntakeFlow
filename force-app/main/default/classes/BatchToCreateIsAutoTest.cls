@isTest
public class BatchToCreateIsAutoTest {
      public static final string SYS_ADMIN = 'System Administrator';
    @testSetup static void setup() {
       
          User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(usr){
            List<Case> testCases = TestDataFactory.createNewCase();
            testCases[0].status = 'Open';
            insert testCases;
            list<Task> tasklist = TestDataFactory.createTask(testCases.get(0).id, usr);
            tasklist[0].RecordTypeId = TestDataFactory.getRecordType('Escalation',Constant_Util.OBJECT_TASK);
            tasklist[0].Process__c = 'Escalation Obtain Service Approval';
             tasklist[0].Attempt__c = 1;
            Database.insert(tasklist);

        }
    }
    
    /* test method */
    @isTest static void itShouldCloseTask(){
     
       User usr = [Select id,isActive from User WHERE isActive = TRUE AND Profile.Name =:SYS_ADMIN limit 1];
        system.runAs(usr){
            Test.startTest();
              BatchToCreateEscIsAuto batchprocess = new BatchToCreateEscIsAuto();
            Id batchId = Database.executeBatch(batchprocess);
             Test.stopTest();
        }
    }
}