/*
Developer: Jatan Sharma
Date: 10/10/2025
Description: This class is used to send email with template and related record from flow.
Current used in : Haul Away Automate Follow Up Approval Attempts Email Flow
*/
public with sharing class EmailService {
    public class EmailInput {
        @InvocableVariable(required=true)
        public Id templateId; //Store Email Template ID
        @InvocableVariable(required=true)
        public Id relatedRecordId; //Store Related Record ID
        @InvocableVariable(required=true)
        public Id senderEmail;//Store Sender Email ID or Org wide email ID
        @InvocableVariable(required=true)
        public String recipientEmail;//Store Recipient Emails
    }


    @InvocableMethod(label='Send Email with Template' description='Sends an email using a specified template' category='Email')
    public static void sendEmail(List<EmailInput> inputs) {
        List<Contact> lContacts = [Select Id from Contact Limit 1];
        Contact objContact = new Contact();
        if (!lContacts.isEmpty()) {
            objContact = lContacts[0];
        } else {
            objContact.LastName = 'Test Email Contact';
            objContact.Email = 'donotreply@ccemail.com';
            insert objContact;
        }
        Set<String> toAddressesSet = new Set<String>();
        for (EmailInput input : inputs) {
            toAddressesSet.addAll(convertRecipientEmailToList(input.recipientEmail));
        }
        List<String> toAddresses = new List<String>(toAddressesSet);
        
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(inputs[0].templateId);
            email.setTargetObjectId(objContact.Id);
            email.setOrgWideEmailAddressId(inputs[0].senderEmail);
            email.setWhatId(inputs[0].relatedRecordId);
            email.setTreatTargetObjectAsRecipient(false);
            email.setBccSender(false);
            email.setUseSignature(false);
            email.setSaveAsActivity(false);  
            email.setToAddresses(toAddresses);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
             if(email != null){
               attachEmailMessage(email, toAddresses, inputs[0].relatedRecordId, inputs[0].senderEmail);
            }
       
    }

    public static list<string> convertRecipientEmailToList(string recipientEmail){
        list<string> recipientEmailList = new list<string>();
        if(recipientEmail!=null && recipientEmail!=''){
            recipientEmailList = recipientEmail.split(';');
        }
        return recipientEmailList;
    }
    
    public static void attachEmailMessage(Messaging.SingleEmailMessage email, List<String> toAddresses, Id QuoteId, Id oweAddressId){
        List<EmailMessage> lstemail = new List<EmailMessage>(); 
        String fromAddress;
        if(oweAddressId != null){
            fromAddress = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Id=:oweAddressId].Address;
        }
        if(email != null){
            for(String address : toAddresses){
                EmailMessage newMessage = new EmailMessage();
                newMessage.HtmlBody = email.htmlBody;
                newMessage.Status = '0';
                newMessage.FromAddress = fromAddress;
                newMessage.ToAddress = address;
                newMessage.Subject = email.subject; 
                newMessage.MessageDate = System.now();
                newMessage.RelatedToId = QuoteId;
                lstemail.add(newMessage);
            } 
            insert lstemail;
        }
    }
    
}