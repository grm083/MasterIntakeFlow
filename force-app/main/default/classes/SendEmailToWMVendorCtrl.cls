/*
 * Class Name: SendEmailToWMVendorCtrl
 * Author: Adil Aleem
 * Date: 01/05/2022
 * Description: This class is used to send the escalation email to 2nd Dispatch Escalation Contact for WM Vendor
 *  
 * */
public class SendEmailToWMVendorCtrl {
    @InvocableMethod
    public static void sendEmailToVendor(List<String> vendorTaskList){
        system.debug('vendorTaskList : ' + vendorTaskList);
        if(vendorTaskList!=null && !vendorTaskList.isEmpty()){
            List<string> inputlst = vendorTaskList[0].split(Constant_Util.SEMI_COLON);
            system.debug('inputlst '+inputlst);
            String taskId = inputlst[0];
            String caseId = inputlst[1];
            String vendorId = inputlst[2];
            
            system.debug('taskId : ' + taskId + 'caseId : ' + caseId + 'vendorId : ' + vendorId);
            List<Task> taskList = [Select Id, Process__c, Subject,Attempt__c from Task where Id =: taskId];
            List<Case> caseList = [Select Id, ContactId, Tech_Asset_ProductFamily__c,Supplier__c from Case where Id =: caseId];
            Map<String , String> inputMap = new Map<String , String>();
            List<String> recipientList = new List<String>();
            
            List<AccountContactRelation> conListForAccount = new List<AccountContactRelation>();
                    conListForAccount = [SELECT Id, ContactId,Contact.Email,Roles
                                        FROM AccountContactRelation 
                                        WHERE AccountId =: vendorId 
                                        AND Roles INCLUDES (:Constant_Util.ROLL_OFF_ESCALATION_DISPATCH_ROLE , :Constant_Util.COMMERCIAL_ESCALATION_DISPATCH_ROLE)
                                        LIMIT 5000];
            for(AccountContactRelation accCon : conListForAccount){
                String role = accCon.roles;
                if((taskList[0].Process__c == Constant_Util.ESCAL_UNRESP_CON_VENDOR || taskList[0].Process__c == Constant_Util.ESCAL_UNRESP_CON_CUSTOMER)
                    && ((caseList[0].Tech_Asset_ProductFamily__c == Constant_Util.ROLLOFF && role.contains(Constant_Util.ROLL_OFF_ESCALATION_DISPATCH_ROLE) )
                            || (caseList[0].Tech_Asset_ProductFamily__c == Constant_Util.COMMERCIAL && role.contains(Constant_Util.COMMERCIAL_ESCALATION_DISPATCH_ROLE) ))){
                                recipientList.add(accCon.Contact.Email);
                }
            }           
            if(!recipientList.isEmpty()){
                inputMap.put('process' , taskList[0].Process__c);
                inputMap.put('caseId' , caseId);    
                sendEmail(recipientList , inputMap);
            }
        }
    }

    public static Void sendEmail(List<string> recipientList , Map<String, String> inputMap) { 
        list<Messaging.SingleEmailMessage> msgList=new list<Messaging.singleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        list<string> approversEmail = new List<string>();
        String processVal = inputMap.containsKey('process') ? inputMap.get('process') : null ;
        String caseId = inputMap.containsKey('caseId') ? inputMap.get('caseId') : null ;
        String whoId = null;
        
		if(recipientList != null && !recipientList.isEmpty()){
            approversEmail.addAll(recipientList);
        } 
        
        List<EmailTemplate> template = [Select id FROM EmailTemplate WHERE Name =:processVal LIMIT 1];
        List<User> adminUsr = [Select Id, Email FROM User WHERE Name = :Constant_Util.GROUP_USERNAME LIMIT 1];
        
        if(adminUsr != null && !adminUsr.isEmpty()){
            whoId = adminUsr[0].id;
        }
        try {
            if(template !=null && !template.isEmpty() && !approversEmail.isEmpty() && caseId != null && whoId != null){
                msg = Messaging.renderStoredEmailTemplate(string.valueof(template[0].Id), whoId, caseId);
                String  subject = msg.getSubject();
				String body = msg.getHtmlBody();
                msg.setToAddresses(approversEmail);
                msg.setWhatId(caseId);
                msg.setTargetObjectId(whoId);
                msg.setSubject(subject);
                msg.setHtmlBody(body);
                msg.saveAsActivity = false;
                msgList.add(msg);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgList);
                System.debug(results[0].success);            
            }
        } catch(Exception e){
            System.debug('Exception'+e.getMessage());
       }
    }

}