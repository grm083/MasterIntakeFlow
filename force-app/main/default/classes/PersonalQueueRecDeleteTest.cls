@isTest(seeAllData = false)
public class PersonalQueueRecDeleteTest {
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            List<Case>testCases = TestDataFactory.createNewCase();
            testCases[0].status = 'Closed';
            insert testCases;
            
            Personal_Queue_Info__c testQueue = new Personal_Queue_Info__c();
            testQueue.Acorn_Update_DT__c = System.now();
            testQueue.CaseId__c = testCases[0].id;
            insert testQueue;
            
        }
    }
    
    /* test method */
    @isTest static void deletePersonalQueueTest(){
        //test class errors - SDT - 33363
        User currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name ='System Administrator' limit 1];
        system.runAs(currentuser){
            String cronexp = '0 0 0 24 5 ? *';
            Test.startTest();
            String jobId = System.schedule('BatchtoDeletePersonalQueue',  cronexp, new PersonalQueueRecDelete());
            Test.stopTest();
        }
    }
}