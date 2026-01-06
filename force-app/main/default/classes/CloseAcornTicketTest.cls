@isTest(seeAllData=false)
public class CloseAcornTicketTest {

    @testSetup static void setup() {
        list<Case> cases = TestDataFactory.createNewCase();
        insert cases;
    }
    
     @isTest static void testAcornNotes() {
        Test.startTest();
         
        Case c = [select Id, Status , Close_Irrelevant_Case__c , Case_Close_Reason__c, Close_Pickup_Case__c from Case limit 1];
        String startStatus = c.Status;        
        List<Case> closeAcornTickets = new List<Case>{c};
         
        /*
        * ** NOTE: CaseHistory does not get created in Test Classes:
        * https://success.salesforce.com/ideaView?id=08730000000h6RwAAI
        */
        CloseAcornTicket.closeTicket(closeAcornTickets); 
        c.Status = 'Pending';
        update c;
        c.Status = 'Closed';
        c.Close_Irrelevant_Case__c = true;
        c.Close_Case_Reason__c = 'Locally Serviced';
		
        update c;
         
        
        //TestDataFactoryclass has createcase method
        
        //List<CaseHistory> histories = [select Id from CaseHistory where CaseId =: c.Id];
        //Map<Id, Case> revertedCases = new Map<Id, Case>(); 
        //revertedCases.put(c.Id, c);
         
        //CloseAcornTicket.revertCases(revertedCases);
        //Case revertedCase = [select Id, Status from Case where Id =: c.Id limit 1];
         
        Test.stopTest();
     }
}