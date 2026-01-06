@isTest
public class ReassignAcornTicketTest {
    
    @testSetup static void setup() {
        Id standardRecType = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Standard Case').getRecordTypeId();
        list<Case> cases = TestDataFactory.createNewCase();
       	cases[0].RecordTypeId = standardRecType;
        cases[0].Status = 'Open';
        cases[0].Tracking_Number__c =  'T22510938';
        System.debug('Case[0]------ ' + cases[0]);
        insert cases;
        
        Profile p = TestDataFactory.getProfile('System Administrator');
        
        User u = TestDataFactory.createUser(p);
        u.Acorn_SUser_ID__c = 1;
        insert u;
        
        User u1 = TestDataFactory.createUser(p);
        u.Acorn_SUser_Id__c = null;
        insert u1;
    }
    
     @isTest static void testAcornNotes() {
        Test.startTest();
        Case c = [select Id, Team_Queue__c, User_Name__r.Acorn_SUser_ID__c from Case limit 1];
        User u = [select Id FROM User WHERE Acorn_SUser_Id__c = 1 limit 1];
        User u1 = [SELECT Id FROM User WHERE Acorn_SUser_Id__c = null limit 1];
        String startTeamQueue = c.Team_Queue__c;
        Decimal startUserId = c.User_Name__r.Acorn_SUser_ID__c;
        List<Case> reassignAcornTickets = new List<Case>{c};
         
        /*
        * ** NOTE: CaseHistory does not get created in Test Classes:
        * https://success.salesforce.com/ideaView?id=08730000000h6RwAAI
        */
        //ReassignAcornTicket.reassignTicket(reassignAcornTickets); 
        /*c.Team_Name__c = 'Account Management';
        c.Team_Queue__c = 'AM Collins';
		*/
          
        Task t = new Task();
        t.WhatId = c.id;
        t.Subject = 'Testing reassign case';
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Quick Task').getRecordTypeId(); 
        t.Process__c = Constant_Util.CASE_ASSIGNMENT;
        insert t;


        c.User_Name__c = u.id;
        update c;
         
        c.User_Name__c = null;
        c.Team_Name__c = 'Account Management';
        c.Team_Queue__c = 'Home Depot Team';
        
        update c;
         
        c.Team_Name__c = null;
        c.Team_Queue__c = null;
       	c.User_Name__C = u1.id;
        update c;
        //c.Status = 'Closed';
        //update c;

        Case updatedC = [SELECT Id, User_Name__c, Tracking_Number__c FROM Case WHERE Tracking_Number__c = 'T22510938'];

        System.assert(updatedC.User_Name__c == u1.id);
        
        //TestDataFactoryclass has createcase method
        
        //List<CaseHistory> histories = [select Id from CaseHistory where CaseId =: c.Id];
        Map<Id, Case> revertedCases = new Map<Id, Case>(); 
        revertedCases.put(c.Id, c);
         
        ReassignAcornTicket.revertCases(revertedCases);
        ReassignAcornTicket.handleTaskError(revertedCases);
        Case revertedCase = [select Id, Team_Queue__c, User_Name__r.Acorn_SUser_ID__c from Case where Id =: c.Id limit 1];
                
        Test.stopTest();
     }

}