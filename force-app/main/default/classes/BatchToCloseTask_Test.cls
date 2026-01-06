@isTest(seeAllData = false)
public class BatchToCloseTask_Test {
    @testSetup static void setup() {
        /*Profile p = TestDataFactory.getProfile('System Administrator');        
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);*/ //Commented for SDT-33457
        
        Boolean BypassValidation = true; //Modified for SDT-33457 
        Boolean GenesysEnabled = false; //Modified for SDT-33457 
        User usr = TestDataFactory.getCSRUser(BypassValidation, GenesysEnabled); //Modified for SDT-33457
        
        system.runAs(usr){
            List<Case>testCases = TestDataFactory.createNewCase();
            testCases[0].status = 'Closed';
            insert testCases;
            
List<Task> taskList = new List<Task>(); //Modified for SDT-33457
            Task t = new Task();
            t.Status = 'Open';
            t.WhatId = testCases[0].id;
            taskList.add(t); //Modified for SDT-33457
            insert taskList; //Modified for SDT-33457
        }
    }
    
    /* test method */
    @isTest static void itShouldCloseTask(){
        //user currentuser = [select id,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
//Querying CSR User.
        User currentuser = [SELECT Id, Profile.Name, LastName, IsActive FROM User WHERE Profile.Name = :Constant_Util.CUSTOMER_SERVICE AND IsActive = true LIMIT 1]; //Modified for SDT-33457
        system.runAs(currentuser){
            String cronexp = '0 0 0 24 5 ? *';
            Test.startTest();
            String jobId = System.schedule('BatchtoCloseTask',  cronexp, new BatchToCloseTask());
            Test.stopTest();
        }
    }
}