public class InvocableFlowEmail {
    
    //Invocable apex to send emails created in flows (outside of the flow action)
    //to whomever is needing them.  Built as part of SDT-18555, SDT-18554, and 
    //SDT-18553.  Overrides "default from" address defined on the user record.
    
    public class DataWrapper {
        @InvocableVariable(label='From Address' required=true)
        public string fromAddress;
        @InvocableVariable(label='From Name' required=true)
        public string fromName;
        @InvocableVariable(label='HTML Body' required=true)
        public string htmlBody;
        @InvocableVariable(label='What Id' required=true)
    	public string parentId;
        @InvocableVariable(label='Subject' required=true)
    	public string subject;
        @InvocableVariable(label='To Address' required=true)
    	public List<string> toAddress;
    }
    
    @InvocableMethod(label='Send Flow-Defined Email' 
                     description='Pass in an EmailMessageId and it will send it to the defined recipient.')
    public static void sendEmails(List<DataWrapper> emailDetails) {
        
        OrgWideEmailAddress owe = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Premium Deliveries'];
        
        for (DataWrapper e: emailDetails) {
        
            Messaging.SingleEmailMessage mailToSend = new Messaging.SingleEmailMessage();
            mailToSend.setWhatId(e.parentId);
            mailToSend.setSubject(e.subject);
            mailToSend.setHtmlBody(e.htmlBody);
            mailToSend.setToAddresses(e.toAddress);
            mailToSend.setOrgWideEmailAddressId(owe.Id);
            
            List<messaging.SendEmailResult> sendResults = Messaging.sendEmail(new List<Messaging.Email> {mailToSend});
            system.debug(sendResults[0]);
            
        }
        
    }

}