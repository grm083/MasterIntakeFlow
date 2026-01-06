/**************************************************
 * ClassName:SendEmailForNotifyCustomerDelayTask
 * Author:Rajan Sajani 
 * Description: Class to send email and log email in email tab for notify customer of delay tasks
 * CreatedDate:19/12/2023
 * **************************************************/
public Without Sharing class SendEmailForNotifyCustomerDelayTask {
    @InvocableMethod
    /*
    * This method is invoked from process builder/flow to send an email.
    * @owner : Rajan Sajani
    * @param : string
    */
    public static Void sendEmail(List<String> CaseList) { 
        list<Messaging.SingleEmailMessage> msgList=new list<Messaging.singleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        //system.debug('CaseList^^^ ' +CaseList);
        
        list<string> emailList = new List<string>();
        String inputlst = CaseList[0].replaceAll('<p>','').replaceAll('</p>','');
        //System.debug('inputlst^^^ ' +inputlst);
        Id caseId = Id.valueof(inputlst);
        //System.debug('caseId^^^ ' +caseId);
        Id contactId;
        for(Case ca: [SELECT id,ContactEmail,Contact.Email
                                     FROM Case
                                     WHERE ID =  :caseId  
                                     LIMIT 49999]){
                                     
            if(ca.Contact.Email != null)
            {
                emailList.add(ca.Contact.Email); 
            }
            else if(ca.ContactEmail != null) 
            {
                emailList.add(ca.ContactEmail); 
            }
            contactId = ca.ContactId;                          
                
        } 
         //system.debug('++++mail ids' +emailList);
         //system.debug('++++mail ids' +processVal); 
        
      
        EmailTemplate templateId = [Select id FROM EmailTemplate WHERE Name ='Notify Customer of SD Delay Template' LIMIT 49999];
        //system.debug('++++mail ids' +templateId);
       
        try {
            if(templateId.Id!=null && !emailList.isEmpty()){
                OrgWideEmailAddress owe = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'WM Service Update'];
                
                msg = Messaging.renderStoredEmailTemplate(string.valueof(templateId.Id), String.valueof(contactId), String.valueof(caseId));
                //System.debug( 'msg' +msg);
                String  subject = msg.getSubject();
                String body = msg.getHtmlBody();
                
                msg.setToAddresses(EmailList);
                
                msg.setWhatId(caseId);
                msg.setTargetObjectId(contactId);
                msg.setSubject(subject);
                msg.setHtmlBody(body);
                msg.saveAsActivity = false;
                msg.setOrgWideEmailAddressId(owe.Id);
                msgList.add(msg);
                
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgList);
                //System.debug('here^^^ ' +results[0].success); 

                EmailMessage newEmailMessage = new EmailMessage (fromAddress= 'wmserviceupdate@wm.com',FromName= 'WM Service Update', toAddress = emailList[0],subject = subject,htmlBody =body,ParentId =caseId,MessageDate = System.now());
                if(newEmailMessage != null){
                    insert newEmailMessage;
                //System.debug('email record created :' +newEmailMessage.Id);
                }
                            
                
            }
            
        }
        catch(Exception e){
            System.debug('Exception^^^^ '+e.getMessage() +e.getLineNumber() +e.getStackTraceString());
        }
    }
}