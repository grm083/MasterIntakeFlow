/**************************************************
 * ClassName:SendEmailToServiceApproversCntrlr
 * Author:Niranjan 
 * Description: This class was created as part of Release1-Sprint3 to trigger Email to Users
 * CreatedDate:4/3/2019
 * **************************************************/
public Without Sharing class SendEmailToServiceApproversCntrlrURule {
    @InvocableMethod
    /*
    * This method is invoked from process builder/flow to send an email.
    * @owner : Niranjan
    * @param : List<string>
    */
    public static Void sendEmail(List<string> brlst) { 
        list<Messaging.SingleEmailMessage> msgList=new list<Messaging.singleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        //Fetch Service Approvers Mail Id's
        list<string> approversEmail = new List<string>();
        List<string> inputlst = brlst[0].split(Constant_Util.SEMI_COLON);
        String brstr = String.valueof(inputlst[0]);
        String br = brstr.substring(1,brstr.length()-1);
        List<string> brlist = new List<string>();
        brlist = br.split(Constant_Util.COMMA);
        Id caseId = Id.valueof(inputlst[1]);
        Id contactId = Id.valueof(inputlst[2]);
        String processVal = String.valueof(inputlst[3]);
         Contact con = new Contact();
        
        if(!test.isRunningTest()){
           
        con.firstname = '';
        con.lastname = 'test';
        con.phone = '';
        List<User> emailId = new List<User>();
        emailId = [Select email from user where id =: contactId limit 1];
        con.Email = emailId[0].email;
       
        Database.insert(con);
        }
       
        
        for(Service_Approver__c sa: [SELECT id,Email__c,User__r.Email,Business_Rule__c
                                     FROM Service_Approver__c
                                     WHERE Business_Rule__c IN: brlist 
                                     AND Active__c = true 
                                     LIMIT 49999]){
            if(sa.Email__c != null)
            {
             approversEmail.add(sa.Email__c);    
            }
           if(sa.User__r.Email != null) 
           {
               approversEmail.add(sa.User__r.Email); 
               
            }
             
                                         
        } 
         system.debug('++++mail ids' +approversEmail);
         system.debug('++++mail ids' +processVal);       
        EmailTemplate templateId = [Select id FROM EmailTemplate WHERE Name =:processVal LIMIT 49999];
         system.debug('++++mail ids' +templateId);
        
        List<String> approversList = BusinessRuleCtrl.getApproversForEscalations(approversEmail);
       
        try {
            if(templateId.Id!=null && !approversEmail.isEmpty()){
               /* msg.setToAddresses(approversEmail);
                //msg.setToAddresses(new List<String> {'niranjankumarmathad@gmail.com'});
                msg.settargetObjectId(contactId);
                msg.setWhatId(caseId);
                msg.setTemplateId(templateId.Id);
                msg.setSaveAsActivity(false); */
                msg = Messaging.renderStoredEmailTemplate(string.valueof(templateId.Id), String.valueof(con.Id), String.valueof(caseId));
                String  subject = msg.getSubject();
				String body = msg.getHtmlBody();
                system.debug('body'+body);
                system.debug('++++inside if' +templateId);
                if(approversList!=null && !approversList.isEmpty()){
                	msg.setToAddresses(approversList);
                }
                else{
                    msg.setToAddresses(approversEmail);
                }
                msg.setWhatId(caseId);
                msg.setTargetObjectId(con.Id);
                msg.setSubject(subject);
                msg.setHtmlBody(body);
                msg.saveAsActivity = true;
                msgList.add(msg);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgList);
                System.debug(results[0].success);       
                
            }
        } catch(Exception e){
            System.debug('Exception'+e.getMessage());
       }
    }
}