/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-02-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AutoSendEmailToServiceApprovers{
    public static final String TEMPLATE_NAME_CASE = 'Customer or Internal: Pickup Approval';
    public static final String TEMPLATE_NAME_MULTICASE = 'Pickup Obtain Service Approval - Multi Case';
    //SDT-39594 
    public static final String TEMPLATE_NAME_ESC = 'Customer or Internal: Pickup Approval - Multi Case Escalation';
    public static final String TEMPLATE_NAME_SINGLE_ESC = 'Customer or Internal: Pickup Approval Escalation';

    public static void autosendEmail(Set<Id> brlst, Set<Id> cselst, Set<Id> tsklst){
        
        System.debug('*************IN AutoSendEmailToServiceApprovers Class************');        
        List<Messaging.SingleEmailMessage> msgList=new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        //Fetch Service Approvers Mail Id's
        List<String> approversEmail = new List<String>();
        Id caseId;
        Id contactId;
        
        System.debug('&&&&& Business Rule List' +brlst); 
        
        List<Service_Approver__c> myServiceApproverList = new List<Service_Approver__c>();
        //soql 101 Issue fix -SDT-40083
        if(!brlst.isEmpty()){
        myServiceApproverList = [SELECT Id, Active__c, Requester_Only__c, Email__c, Approver_Contact__c,
                                 Approver_Contact__r.Preferred_Method__c, Approver_Contact__r.Email,
                                 User__r.Email,User__r.IsActive, Business_Rule__c 
                                 FROM Service_Approver__c
                                 WHERE Business_Rule__c IN: brlst
                                 AND Active__c = true 
                                 LIMIT 49999];
        }
        //soql 101 issue fix sdt-40083
        if(!myServiceApproverList.isEmpty()){
        for(Service_Approver__c sa: myServiceApproverList){
            
            if(sa.Email__c != null && !(sa.Requester_Only__c))
            {
                approversEmail.add(sa.Email__c);    
            }
            
            if((sa.User__r.IsActive) 
               && sa.User__r.Email != null 
               && !(sa.Requester_Only__c)) 
            {
                approversEmail.add(sa.User__r.Email);    
            }
            
            if(sa.Approver_Contact__c != null 
               && sa.Approver_Contact__r.Preferred_Method__c == Constant_Util.ORIGIN_EMAIL 
               && !(sa.Requester_Only__c) && sa.Approver_Contact__r.Email != null)
            {
                contactId = sa.Approver_Contact__c;
                approversEmail.add(sa.Approver_Contact__r.Email);
            } 
        }
        }
        // Out of Office Features
        Map<String , Set<String>> approversMap = BusinessRuleCtrl.getBusinessRuleApprovers(brlst);
        List<String> approversEmailList;
        System.debug('approversMap : ' + approversMap);
        if(approversMap!=null && !approversMap.isEmpty()){
            Set<String> approverEmailSet = new Set<String>(approversEmail);
            for(String strEmail : approverEmailSet){
                if(approversMap.containsKey(strEmail)){
                    approverEmailSet.remove(strEmail);
                    approverEmailSet.addAll(approversMap.get(strEmail));
                } 
            }
            approversEmailList = new List<String>(approverEmailSet);
            
        }
        if(approversEmailList==null){
            approversEmailList = new List<String>(approversEmail);
        }
        // Out of Office Features
        
        Case caseRecord = [Select Id, Status, ContactEmail, (SELECT Id, Outcome__c, WhatId, Attempt__c, Status, ContactEmail__c FROM Tasks) From Case Where Id IN: cselst Limit 1];
        if(caseRecord != null){
            if(caseRecord.Status == 'Closed'){
                approversEmailList = null;
            }else{
                for(Task tsk: caseRecord.Tasks){
                    if((tsk.Outcome__c == 'Approved')
                        && String.isNotBlank(tsk.ContactEmail__c)
                        && approversEmailList.contains(tsk.ContactEmail__c)){
                            approversEmailList.remove(approversEmailList.indexOf(tsk.ContactEmail__c));
                        }
                }
                if(approversEmailList.contains(caseRecord.ContactEmail)){
                    contactId = null;
                    approversEmailList.remove(approversEmailList.indexOf(caseRecord.ContactEmail));
                }
            }
        }
        
        
        EmailTemplate templateId; 
        //soql 101 issue fix
        String SingleCaseTemplateName = TEMPLATE_NAME_CASE;
        String MultiCaseTemplateName = TEMPLATE_NAME_MULTICASE;
        String EscCaseTemplateName = TEMPLATE_NAME_ESC;
        String EscCaseSingleTemplateName = TEMPLATE_NAME_SINGLE_ESC;
        //soql 101 issue sprint 8
        if(cselst.size()>0){
        List<Case> cList = [SELECT Id,Is_MultiCase_TaskBundling__c,ParentId FROM Case WHERE Id IN:cselst];
        
      
        
       
       
        
      
        
                //SDT-39594 


      
        //SDT- 15689 - Added check for Is_MultiCase_TaskBundling__c to confirm whether case is created from UI (Case/Task) or not
        for(Case cse : cList){
            if(cse.parentId!= null && cse.Is_MultiCase_TaskBundling__c){
                EmailTemplate multiCaseTemplate= SystemObjectSelector.getEmailTemplateByName(MultiCaseTemplateName);
                caseId = cse.parentId;
                templateId = multiCaseTemplate;
            }
            else if(!cse.Is_MultiCase_TaskBundling__c){
                /* EmailTemplate singleCaseTemplate = [SELECT Id, Name 
                                        FROM EmailTemplate 
                                        WHERE Name =:TEMPLATE_NAME_CASE LIMIT 1];*/
            EmailTemplate singleCaseTemplate= SystemObjectSelector.getEmailTemplateByName(SingleCaseTemplateName);
            caseId = cse.Id;
            templateId = singleCaseTemplate;
        }
           
          
            
        
    
        //soql 101 issue fix 
        if(!tsklst.isEmpty()){
          List<Task> tList = [SELECT Id, Outcome__c,Process__c,Attempt__c, Status FROM Task WHERE ID IN:tsklst];
          //SDT-41162
          if(cse.Is_MultiCase_TaskBundling__c && cse.parentId!= null){
            for(Task tsk: tList){            
                if(tsk.Process__c == 'Escalation Obtain Service Approval' && tsk.Attempt__c == 1){
                    EmailTemplate templateIdEsc=   SystemObjectSelector.getEmailTemplateByName(EscCaseTemplateName);
                     templateId = templateIdEsc;
    
                }
				//Changes related to SDT-41178
				else if(tsk.Process__c == 'Escalation Obtain Service Approval' && tsk.Attempt__c == 2){ templateId = null;}
                	
                }
          }
          else if (!cse.Is_MultiCase_TaskBundling__c){
            for(Task tsk: tList){            
                if(tsk.Process__c == 'Escalation Obtain Service Approval' && tsk.Attempt__c == 1){
                    EmailTemplate templateIdSingleEsc=   SystemObjectSelector.getEmailTemplateByName(EscCaseSingleTemplateName);
                     templateId = templateIdSingleEsc;
    
                }
				//Changes related to SDT-41178
				else if(tsk.Process__c == 'Escalation Obtain Service Approval' && tsk.Attempt__c == 2){ templateId = null;}
                
                }

          }

			
         }
        }
    }
    //soql 101 issue fix 
        try {
            if(templateId != null &&  templateId.Id != null && approversEmailList!=null && !approversEmailList.isEmpty()){
                msg = Messaging.renderStoredEmailTemplate(String.valueof(templateId.Id), String.valueof(contactId), String.valueof(caseId));
                //if(approversEmailList!=null && !approversEmailList.isEmpty()){
                	//msg.setToAddresses(approversEmailList); // Out of Office Features   
                //}else{
                   	//msg.setToAddresses(approversEmail); 
                //}
                msg.setToAddresses(approversEmailList);
                msg.setTargetObjectId(contactId);
                msg.setWhatId(caseId);
                msg.setTemplateId(templateId.id);
                msg.saveAsActivity = true; //SDT-11746 fix
                msgList.add(msg);
            	system.debug('msgList : ' + msgList);                
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgList);
                System.debug('results[0].success :: '+results[0].success);
                
                /* Started - 21227 & 17976, and 21921, 21946 - Commented the code
List<Task> tList = [SELECT Id, Outcome__c,Process__c, Status FROM Task WHERE ID IN:tsklst];
List<Task> tskUpdate = new List<Task>();
* Ended */
                if(results.get(0).isSuccess()) 
                { 
                    /* Started - 21227 & 17976, and 21921, 21946 - Commented the code
for(Task tsk: tList){
// tsk.Status = Constant_Util.COMPLETED;
// tsk.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
tsk.Status = Constant_Util.Open;

tsk.Outcome__c = Constant_Util.OUTCOME_ON_TASK;

tskUpdate.add(tsk);    
}
Database.update(tskUpdate);
* Ended */
                    
                    //SDT-16246 - Auto Send Approval Emails
                    System_Log_Event__e emailEvent = new System_Log_Event__e();
                    emailEvent.Message__c = System.Label.ApprovalEmailSuccessMsg;
                    emailEvent.Level__c = 'INFO';          
                    emailEvent.Parent_ID__c = caseId;
                    emailEvent.User_ID__c  = UserInfo.getUserId();
                    Database.SaveResult result = EventBus.publish(emailEvent);
                    // Inspect publishing results          
                    if (!result.isSuccess()) {
                        UTIL_LoggingService.logDmlResults(new List<Database.SaveResult>{result} , null, new List<System_Log_Event__e >{emailEvent}, UTIL_ErrorConstants.ERROR_APPLICATION, 'AutoSendEmailToServiceApprovers', 'autosendEmail', null, LoggingLevel.ERROR);
                        
                    }
                    //SDT-16246 END
                }  
            }
            
        }
        catch(Exception e){
            System.debug('Exception'+e.getMessage());
        }  
    }    
}