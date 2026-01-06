/*************************************************************
@Author: Ayushi Sharma
@Date: 26/03/2019
@group:EmailMessage
@Description: Trigger to Perform operations on EmailMessage on before Insert,after Insert,before delete

**************************************************************/
trigger EmailMessageTrigger on EmailMessage (before Insert,after Insert,before delete,before update ,after update) 
{      
   //Invokes Before insert
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsBefore && Trigger.IsInsert){
        EmailMessageTriggerHandler.onbeforeInsert(trigger.new);
          
    }
    
    //Invokes after insert
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsInsert && !RecurrsiveTriggerHandler.isSkipEmailMessageTrigger){
        EmailMessageTriggerHandler.onAfterInsert(Trigger.newMap);
		RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = true;
    } 
    else if(Trigger.IsAfter && Trigger.IsInsert){
        Map<String ,List<EmailMessage>> emailMsgMap = new Map<String,List<EmailMessage>>();
        for(EmailMessage msg: Trigger.newMap.values()){
            if(msg.ParentId !=null && msg.ParentId.getSObjectType().getDescribe().getName() == 'Case'){
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
    
   //Invokes Before Delete
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.isBefore && Trigger.isDelete){
        EmailMessageTriggerHandler.onBeforeDelete(trigger.old);
    }
    
    //Invokes after update
    If(!RecurrsiveTriggerHandler.bypassValidation && Trigger.isAfter && Trigger.isUpdate){
        EmailMessageTriggerHandler.onAfterUpdate(trigger.newMap , trigger.oldMap);
    }

    //Invokes before update
    if(!RecurrsiveTriggerHandler.bypassValidation && Trigger.isBefore && Trigger.isUpdate){
        EmailMessageTriggerHandler.onBeforeUpdate(trigger.new , trigger.oldMap);
    }
}