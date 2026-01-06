/*************************************************************
@Author: Ayushi Sharma
@Date: 26/03/2019
@group:EmailMessage
@Description: Handler Class to Perform operations on EmailMessage on beforeInsert, AfterInsert, beforeDelete

**************************************************************/
public class EmailMessageTriggerHandler {

/*************************************************************
@Description: Run for the before Insert of the EmailMessage
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/
    public static void onbeforeInsert(List<EmailMessage> lstmsgs) {
        List<EmailMessage> lstmsg = new List<EmailMessage>();
        for(EmailMessage em  :lstmsgs){
            if(!em.isCloned__c){
               lstmsg.add(em); 
            }

            if(em.ParentId !=null && em.ParentId.getSObjectType().getDescribe().getName() == 'Case' && em.Status == '5'){
                em.QuickEmail__c = true;
            } 
        }
        
        if(!RecurrsiveTriggerHandler.isSkipEmailMessageTrigger && lstmsg != null && lstmsg.size() > 0){
            EmailMessageTriggerHelper.updateFromAddress(lstmsg);
            EmailMessageTriggerHelper.checkEmailWithAlias(lstmsg);
            EmailMessageTriggerHelper.handleClosedCaseMessage(lstmsg);  
            EmailMessageTriggerHelper.checkEMWithOutReferenceNo(lstmsg);
            EmailMessageTriggerHelper.checkEMForServiceConfirmed(lstmsg);
            EmailMessageTriggerHelper.parseTrackingNumber(lstmsg);
            //EmailMessageTriggerHelper.checkIndicoEmailMessage(lstmsg);
	    	EmailMessageTriggerHelper.stopGenesysTaskMailerDaemon(lstmsg);
            EmailMessageTriggerHelper.updateSubject(lstmsg , null);
            EmailMessageTriggerHelper.updateMessageIdForOutboundQuoteEmails(lstmsgs);//SDT-41263
        }
        
    }

/*************************************************************
@Description: Run for the before update of the EmailMessage
@param :objectName EmailMessage List<EmailMessage> , Map<Id,EmailMessage> oldMap
@return:void

**************************************************************/
public static void onBeforeUpdate(List<EmailMessage> newList , Map<Id,EmailMessage> oldMap){
    if(!RecurrsiveTriggerHandler.isSkipEmailMessageTrigger){
        EmailMessageTriggerHelper.updateSubject(newList , oldMap);
    }
}
    
/*************************************************************
@Description: Run for the after Insert of the EmailMessage
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/
   
    public static void onAfterInsert(Map<Id,EmailMessage> newMap){
		 List<EmailMessage> listEmailMessageChatNow = new List<EmailMessage>();
        Map<Id,EmailMessage> filteredMap = new Map<Id,EmailMessage>();
        Map<String ,List<EmailMessage>> emailMsgMap = new Map<String,List<EmailMessage>>();
        Map<Id,EmailMessage> filteredForIndico = new Map<Id,EmailMessage>();
        for(EmailMessage msg:newMap.values()){
		       if(msg.Incoming){
               listEmailMessageChatNow.add(msg) ;
            }
		
            if(msg.ParentId !=null && msg.ParentId.getSObjectType().getDescribe().getName() == 'Case' ){
                filteredMap.put(msg.Id,msg);
                if(msg.Status != '5') {
                      if(!emailMsgMap.containsKey(Constant_Util.COMMENT_TEMPLATE_EMAIL_SENT_RECEIVED) ) {
                        emailMsgMap.put(Constant_Util.COMMENT_TEMPLATE_EMAIL_SENT_RECEIVED , new List<EmailMessage>{msg});
                    } else {
                        emailMsgMap.get(Constant_Util.COMMENT_TEMPLATE_EMAIL_SENT_RECEIVED).add(msg);
                    }       
                }   
            }
             if(msg.isIndicoEligible__c){
                    filteredForIndico.put(msg.Id,msg);
                }            
        }
        if(filteredMap.size() >0){
            CreateCaseHistory.createHistoryRecordOnRecordCreate(filteredMap);
        }
        if(filteredForIndico.size() >0){
            EmailMessageTriggerHelper.CreateSFDCEmailMessageForIndico(filteredForIndico);
        }
        if(emailMsgMap.size() >0){
            EmailMessageTriggerHelper.createCaseComment(emailMsgMap);
        }

        for(EmailMessage msg:newMap.values()){
            system.debug('relatedtoId>>>'+msg.relatedtoId);
        }
		
		 //call method to sent chatnow Email
        if(System.Label.Turn_On_ChatNow_Email_Auto_Reply =='true'&&!RecurrsiveTriggerHandler.isSkipsentChatNowAutoReply){
		   if(!listEmailMessageChatNow.isEmpty()){
           EmailMessageTriggerHelper.sentChatNowAutoReply(listEmailMessageChatNow); 
		   }
        }
        
       
    }
    
/*************************************************************
@Description: Run for the before delete of the EmailMessage
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/
    
    public static void onbeforeDelete(List<EmailMessage> lstmsg){
        EmailMessageTriggerHelper.preventDelete(lstmsg);
    }
    
     public static void onAfterUpdate(Map<Id,EmailMessage> newMap , Map<Id,EmailMessage> oldMap){
        Map<String ,List<EmailMessage>> emailMsgMap = new Map<String,List<EmailMessage>>();
        for(EmailMessage msg:newMap.values()){
            if(oldMap != null && oldMap.containsKey(msg.id) && msg.ParentId !=null && msg.ParentId.getSObjectType().getDescribe().getName() == 'Case' && msg.Status != '5' && oldMap.get(msg.id).Status == '5'){
                if(!emailMsgMap.containsKey(Constant_Util.COMMENT_TEMPLATE_EMAIL_SENT_RECEIVED)) {
                    emailMsgMap.put(Constant_Util.COMMENT_TEMPLATE_EMAIL_SENT_RECEIVED , new List<EmailMessage>{msg});
                } else {
                    emailMsgMap.get(Constant_Util.COMMENT_TEMPLATE_EMAIL_SENT_RECEIVED).add(msg);
                }     
            }      
        }
        if(emailMsgMap.size() >0){
            EmailMessageTriggerHelper.createCaseComment(emailMsgMap);
        }  
    }
}