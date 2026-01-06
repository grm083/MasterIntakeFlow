@isTest
public class IntakeProcessAuraHandlerTest {

    @testSetup
    private static void testSetup() {
		
        Account client = new Account();
        client.Name = 'TestClient';
        client.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Client'].Id;
        insert client;
        
        Account location = new Account();
        location.Name = 'TestLocation';
        location.RecordTypeId = [SELECT Id FROM RecordType WHERE Name ='Location'].Id;
        location.ParentId = client.Id;
        insert location;

		Intake_Process__c FirstQuestion = new Intake_Process__c();
        FirstQuestion.Presentation_Order__c = 1;
        FirstQuestion.Case_Type__c = 'Status';
        FirstQuestion.Case_Sub_Type__c = 'Service Not Performed';
        FirstQuestion.Case_Reason__c = 'Hauler Reported';        
        FirstQuestion.Question__c = 'Test First Question';
        FirstQuestion.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Intake Questions' LIMIT 1].Id;
        FirstQuestion.Input_Type__c = 'Text';
        insert FirstQuestion;
        
        Intake_Process__c NextQuestion = new Intake_Process__c();
        NextQuestion.Case_Type__c = 'Status';
        NextQuestion.Case_Sub_Type__c = 'Service Not Performed';
        NextQuestion.Case_Reason__c = 'Hauler Reported';        
        NextQuestion.Question__c = 'Test Second Question';
        NextQuestion.Input_Type__c = 'Text';
        NextQuestion.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Intake Questions' LIMIT 1].Id;
        insert NextQuestion;
        
        Intake_Process__c Outcome = new Intake_Process__c();
        Outcome.Update_Case_Record_Type__c = TRUE;
        Outcome.Case_Record_Type__c = 'Status Case';
        Outcome.Update_Case_Type__c = TRUE;
        Outcome.Case_Type__c = 'Status';
        Outcome.Update_Case_Sub_Type__c = TRUE;
        Outcome.Case_Sub_Type__c = 'Service Not Performed';
        Outcome.Update_Case_Reason__c = TRUE;
        Outcome.Case_Reason__c = 'Customer Reported';
        Outcome.Intake_Question__c = FirstQuestion.Id;
        Outcome.Next_Question__c = NextQuestion.Id;
        Outcome.Update_Case_Status__c = true;
        Outcome.Case_Status__c = 'Open';
        Outcome.Create_Task__c = true;
        Outcome.Task_Type__c = 'Obtain Internal Response';
        Outcome.Task_Process__c = 'Master Intake';
        Outcome.Team_Name__c = 'Service Resolution Team';
        Outcome.Queue_Assigned__c = 'CS Resolution';
        Outcome.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Intake Outcomes' LIMIT 1].Id;
        insert Outcome;
        
        Case c = new Case();
        c.Subject = 'TestCase';
        c.RecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Status Case'].Id;
        c.Case_Type__c = 'Status';
        c.Case_Sub_Type__c = 'Service Not Performed';
        c.Case_Reason__c = 'Hauler Reported';
        c.Client__c = client.Id;
        c.Location__c = location.Id;
        insert c;
                
    }
    @isTest
    private static void AccountQuestions() {
        
        Account a = [SELECT Id FROM Account LIMIT 1];
        Case c = [SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c FROM Case LIMIT 1];
        
        Intake_Process__c AcctProcess = [SELECT Id, Customer_Account__c FROM Intake_Process__c WHERE Presentation_Order__c = 1 LIMIT 1];
        AcctProcess.Customer_Account__c = a.Id;
        update AcctProcess;
        
        Intake_Process__c masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
        Intake_Process__c subIP = IntakeProcessAuraHandler.getAccountQs(a.Id, c.Case_Type__c, c.Case_Sub_Type__c, c.Case_Reason__c);
        
        system.assertEquals(masterIP.Id, subIP.Id);
        system.assertEquals(masterIP.Id, AcctProcess.Id);
        system.assertEquals(subIP.Id, AcctProcess.Id);
        
        AcctProcess.Case_Reason__c = null;
        update AcctProcess;
        
        c.Case_Reason__c = null;
        update c;
        
		masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
        subIP = IntakeProcessAuraHandler.getAccountQs(a.Id, c.Case_Type__c, c.Case_Sub_Type__c, 'Null');
        
        system.assertEquals(masterIP.Id, subIP.Id);
        system.assertEquals(masterIP.Id, AcctProcess.Id);
        system.assertEquals(subIP.Id, AcctProcess.Id);        
        
    }
    @isTest
    private static void LocationQuestions() {
        
        Account a = [SELECT Id FROM Account WHERE RecordType.Name = 'Location' LIMIT 1];
        Case c = [SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c FROM Case LIMIT 1];
        
        Intake_Process__c LocProcess = [SELECT Id, Customer_Account__c FROM Intake_Process__c WHERE Presentation_Order__c = 1 LIMIT 1];
        LocProcess.Customer_Location__c = a.Id;
        update LocProcess;
        
        Intake_Process__c masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
        Intake_Process__c subIP = IntakeProcessAuraHandler.getLocationQs(a.Id, c.Case_Type__c, c.Case_Sub_Type__c, c.Case_Reason__c);
        
        system.assertEquals(masterIP.Id, subIP.Id);
        system.assertEquals(masterIP.Id, LocProcess.Id);
        system.assertEquals(subIP.Id, LocProcess.Id);
        
        LocProcess.Case_Reason__c = null;
        update LocProcess;
        
        c.Case_Reason__c = null;
        update c;
        
		masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
        subIP = IntakeProcessAuraHandler.getLocationQs(a.Id, c.Case_Type__c, c.Case_Sub_Type__c, 'Null');
        
        system.assertEquals(masterIP.Id, subIP.Id);
        system.assertEquals(masterIP.Id, LocProcess.Id);
        system.assertEquals(subIP.Id, LocProcess.Id); 
        
    }
    @isTest
    private static void RoleQuestions() {
        
        UserRole role = [SELECT Id, Name FROM UserRole WHERE Name = 'Customer Experience Representative'];
        system.debug(role.Name);
        
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Service'].Id;
        u.Email = 'test@test.uk';
        u.Username = 'test@test.uk.dev01';
        u.UserRoleId = role.Id;
        u.TimeZoneSidKey = 'America/New_York';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.Alias = 'tuser';
        insert u;
        
        system.runAs(u) {
            
            Case c = [SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c FROM Case LIMIT 1];
            
            Intake_Process__c RoleProcess = [SELECT Id, Customer_Account__c FROM Intake_Process__c WHERE Presentation_Order__c = 1 LIMIT 1];
            RoleProcess.User_Role__c = 'Customer Experience Representative';
            update RoleProcess;
            
            Intake_Process__c masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
            Intake_Process__c subIP = IntakeProcessAuraHandler.getRoleQs(c.Case_Type__c, c.Case_Sub_Type__c, c.Case_Reason__c);
            
            system.assertEquals(masterIP.Id, subIP.Id);
            system.assertEquals(masterIP.Id, RoleProcess.Id);
            system.assertEquals(subIP.Id, RoleProcess.Id);
            
            RoleProcess.Case_Reason__c = null;
            update RoleProcess;
            
            c.Case_Reason__c = null;
            update c;
            
            masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
            subIP = IntakeProcessAuraHandler.getRoleQs(c.Case_Type__c, c.Case_Sub_Type__c, 'Null');
            
            system.assertEquals(masterIP.Id, subIP.Id);
            system.assertEquals(masterIP.Id, RoleProcess.Id);
            system.assertEquals(subIP.Id, RoleProcess.Id); 
            
        }
    }
    @isTest
    private static void GeneralQuestions() {

         UserRole role = [SELECT Id, Name FROM UserRole WHERE Name = 'Customer Experience Representative'];
        system.debug(role.Name);
        
        User u = new User();
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Service'].Id;
        u.Email = 'test@test.uk';
        u.Username = 'test@test.uk.dev01';
        u.UserRoleId = role.Id;
        u.TimeZoneSidKey = 'America/New_York';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.Alias = 'tuser';
        insert u;

        System.runAs(u){
            Case c = [SELECT Id, Case_Type__c, Case_Sub_Type__c, Case_Reason__c FROM Case LIMIT 1];
            
            Intake_Process__c GProcess = [SELECT Id, Customer_Account__c FROM Intake_Process__c WHERE Presentation_Order__c = 1 LIMIT 1];
            
            Intake_Process__c masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
            Intake_Process__c subIP = IntakeProcessAuraHandler.getGeneralQs(c.Case_Type__c, c.Case_Sub_Type__c, c.Case_Reason__c);
            
            system.assertEquals(masterIP.Id, subIP.Id);
            system.assertEquals(masterIP.Id, GProcess.Id);
            system.assertEquals(subIP.Id, GProcess.Id);
            
            GProcess.Case_Reason__c = null;
            update GProcess;
            
            c.Case_Reason__c = null;
            update c;
            
            masterIP = IntakeProcessAuraHandler.getFirstQuestion(c.Id);
            subIP = IntakeProcessAuraHandler.getGeneralQs(c.Case_Type__c, c.Case_Sub_Type__c, 'Null');
            
            system.assertEquals(masterIP.Id, subIP.Id);
            system.assertEquals(masterIP.Id, GProcess.Id);
            system.assertEquals(subIP.Id, GProcess.Id); 
            
            Intake_Process__c GOutcomes = [SELECT Id, Next_Question__c, Intake_Question__c FROM Intake_Process__c WHERE Intake_Question__c =:GProcess.Id];
            Intake_Process__c NQuestion = [SELECT Id FROM Intake_Process__c WHERE Id =:GProcess.Id];
            
            List<Intake_Process__c> genOutcomes = IntakeProcessAuraHandler.getOutcomes(GProcess.Id);
            
            system.assertEquals(genOutcomes[0].Id, GOutcomes.Id);
            
            Intake_Process__c nexQuestion = IntakeProcessAuraHandler.getNextQuestion(GProcess.Id);
            
            system.assertEquals(nexQuestion.Id, GProcess.Id);
        }
        
    }
	@isTest
    private static void testUpdateCase() {
        
        Case c = [SELECT Id, RecordType.Name, RecordTypeId, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Status FROM Case LIMIT 1];
        Intake_Process__c o = [SELECT Id FROM Intake_Process__c WHERE RecordType.Name = 'Intake Outcomes' LIMIT 1];
        
        String success = IntakeProcessAuraHandler.doCaseUpdates(c.Id, o.Id);
        
        system.assertEquals(success, 'Open');
        
        c = IntakeProcessAuraHandler.getCaseDetails(c.Id, true);
        system.assertEquals(c.Master_Intake_Complete__c, true);
        
        c = IntakeProcessAuraHandler.getCaseDetails(c.Id, false);
        system.assertEquals(c.Master_Intake_Complete__c, true);
        
        Comment__c comm = IntakeProcessAuraHandler.createComment(c.Id, 'TEST COMMENT');
        system.assertEquals(comm.Comment__c, 'TEST COMMENT');
        
    }
    
}