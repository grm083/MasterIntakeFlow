public class QuoteActionsController {
    
    @AuraEnabled
    public static SBQQ__Quote__c getQuote(String recordId) {
        
        SBQQ__Quote__c q = [SELECT Id, Name, SBQQ__Status__c, Next_Action_Due_Date__c, Action_Type__c,Assigned_To__c,SBQQ__Opportunity2__r.Case__c
                            FROM SBQQ__Quote__c 
                            WHERE Id =: recordId];
        
        return q;
        
    }
    @AuraEnabled
    public static string goToCase(String quoteID){
       
        SBQQ__Quote__c quote = [Select ID, SBQQ__Opportunity2__r.Case__c FROM SBQQ__Quote__c WHERE ID=: quoteID];
       
        return quote.SBQQ__Opportunity2__r.Case__c;
    }

    /// Comment Below Code as 25361 and 25362 is reverted from SP18.
    /// This code will use in future
    /*
    @InvocableMethod(callout=true label='Invoke Escalation Email')    
    public static void invokeEscalationEmail(List<ID> ids) {
        //Do Something.
        system.debug('Invoke Escalation Email Start');

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        String toAddresses;
        List<String> toAddressesList = new List<String>();

        if(ids != null && ids.size() > 0)
        {
            quoteList = [Select Id, SBQQ__Opportunity2__r.Case__r.Account.Account_Email_Recipient__c from SBQQ__Quote__c Where Id IN: ids];
            EmailTemplate template = [SELECT Id FROM emailTemplate WHERE DeveloperName = 'Escalation_to_Sales_Team'];

            for(SBQQ__Quote__c qc : quoteList)
            {
                toAddresses = qc.SBQQ__Opportunity2__r.Case__r.Account.Account_Email_Recipient__c != null ? qc.SBQQ__Opportunity2__r.Case__r.Account.Account_Email_Recipient__c : null;
                if(String.isNotBlank(toAddresses))
                {
                    if(toAddresses.contains(';'))
                    {
                        toAddressesList = toAddresses.split(';');
                    }
                    else
                    {
                        toAddressesList.add(toAddresses);
                    }
                    system.debug('To Address : Quote Id : Template Id' + toAddressesList + ' ' + qc.Id + ' ' + template.Id);
                    createEscalationEmailMessage(toAddressesList, qc.Id, template.Id);
                }
            }
        }
    }

    public static Messaging.SingleEmailMessage createEscalationEmailMessage(List<String> toAddresses, Id QuoteId, String emailTemplateId)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Contact objContact = new Contact();
        List<Contact> lContacts = [Select Id from Contact Limit 1];
        if(!lContacts.isEmpty())
        {
            objContact = lContacts[0];
        }
        else 
        {
            objContact.LastName = 'Test Email Contact';
            objContact.Email = 'donotreply@ccemail.com';
            insert objContact;
        }
        mail.setTargetObjectId(objContact.Id);
        
        mail.setTemplateId(emailTemplateId);
        mail.setToAddresses(toAddresses);
        mail.setWhatId(QuoteId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);        
        mails.add(mail);     
        
        Messaging.SendEmailResult[] result=  Messaging.sendEmail(mails);

        if (result!= null && result.size() >0 && result[0].success) 
        {
            System.debug('Escalation email was sent successfully.' + result[0].success);
            QuoteApproval.attachEmailMessage(mail, toAddresses, QuoteId);
        }

        return mail;
    }*/
}