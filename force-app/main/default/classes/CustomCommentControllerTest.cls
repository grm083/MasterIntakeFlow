@isTest
public class CustomCommentControllerTest {

    @testSetup static void createTestData() {
        Case c = new Case();
        c.Subject = 'TestCase';
        insert c;
        
        Opportunity o = new Opportunity();
        o.StageName = 'Product Configuration';
        o.Case__c = c.Id;
        o.Name = 'TestOpp';
        o.CloseDate = Date.today();
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Status__c = 'Draft';
        q.SBQQ__Opportunity2__c = o.Id;
        insert q;
        
        Account a = new Account();
        a.Name = 'TestAccount';
        insert a;
        
    }
    
    @isTest static void validateId() {
        
        Case c = [SELECT Id From Case LIMIT 1];
        SBQQ__Quote__c q = [SELECT Id From SBQQ__Quote__c LIMIT 1];
        Account a = [SELECT id FROM Account LIMIT 1];        
        //Changes related to SDT-18095
        String caseId = CustomCommentController.getCaseId(c.Id).Id;
        String quoteId = CustomCommentController.getCaseId(q.Id).Id;
      	//String accountId = CustomCommentController.getCaseId(a.Id).Id;
        
        system.assertEquals(caseId, c.Id);
        system.assertEquals(quoteId, c.Id);
        //Changes related to SDT-18095
        //system.assertEquals(accountId, a.Id);
        
    }
    
}