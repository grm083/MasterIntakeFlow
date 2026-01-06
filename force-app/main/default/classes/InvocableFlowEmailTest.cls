@isTest
public class InvocableFlowEmailTest {
	
    @testSetup
    public static void testSetup(){
    
        //Prep the case record
        Case c = new Case();
        c.Subject = 'Test Case';
        insert c;
        
    }
    
    public static testMethod void doTest() {
        
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        List<String> toAddresses = new List<String>();
        String s1 = 'test@test.test';
        String s2 = 'test@test.test';
        
        toAddresses.add(s1);
        toAddresses.add(s2);
        
        //First data wrapper
        InvocableFlowEmail.DataWrapper dw1 = new InvocableFlowEmail.DataWrapper();
        dw1.fromAddress = 'test@test.test';
        dw1.fromName = 'Test Email';
        dw1.htmlBody = 'Test Email Body';
        dw1.parentId = c.Id;
        dw1.subject = 'Test Subject 1';
        dw1.toAddress = toAddresses;
        
        InvocableFlowEmail.DataWrapper dw2 = new InvocableFlowEmail.DataWrapper();
        dw2.fromAddress = 'test@test.test';
        dw2.fromName = 'Test Email';
        dw2.htmlBody = 'Test Email Body';
        dw2.parentId = c.Id;
        dw2.subject = 'Test Subject 2';
        dw2.toAddress = toAddresses;
        
        List<InvocableFlowEmail.DataWrapper> dwList = new List<InvocableFlowEmail.DataWrapper>();
        dwList.add(dw1);
        dwList.add(dw2);
        
        InvocableFlowEmail.sendEmails(dwList);
        
        List<EmailMessage> emList = [SELECT Id FROM EmailMessage WHERE ParentId =: c.Id];
        
        System.assert(emList.size() > 0);
        
    }
    
    
}