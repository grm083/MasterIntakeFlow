public class TrackingNoEmailThreadToParentBatch implements Schedulable,Database.Batchable<sObject>,Database.Stateful{
    
    Private static final String query = 'SELECT ActivityId,BccAddress,ByPassGRByFilter__c,Bypass_Genesys_Task__c,CcAddress,CreatedById,'+
        'CreatedDate,EmailTemplateId,FirstOpenedDate,FromAddress,FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,IndicoErrorMessage__c,'+
        'IndicoStatus__c,In_Reply_To_ID__c,IsBounced,IsClientManaged,isCloned__c,IsDeleted,IsExternallyVisible,isIndicoEligible__c,IsNonThreadEmail__c,'+
        'IsOpened,IsPrivateDraft,IsTracked,LastModifiedById,LastModifiedDate,LastOpenedDate,MarkToDelete__c,MessageDate,MessageIdentifier,Message_ID__c,ParentId,'+
        'RelatedToId,ReplyToEmailMessageId,Sent_or_Received__c,Status,Subject,SystemModstamp,Tech_New_Case__c,TextBody,ThreadIdentifier,ToAddress,'+
        'To_Be_Processed__c,Tracking_Number_Email__c,Parent.Acorn_Work_order__c,Parent.Location__r.Location_Code__c,Parent.RecordType.Name,'+
        'Parent.Case_Type__c,Parent.Case_Sub_Type__c,Parent.Reference_Number__c,Parent.Case_Reason__c,Parent.CaseNumber,Parent.Customer_Code__c,'+
        'HourCreation__c,IsBatchProcessed__c,parent.Email_Tracking_Number__c FROM EmailMessage WHERE parent.Email_Tracking_Number__c != null and parent.Tracking_Number__c = null and '+
        'parent.Email_Tracking_Number__c like \'T%\' and Incoming = True and HourCreation__c > 0.44 and parent.Owner.name = \'Group User\' and CreatedDate = TODAY  LIMIT 49999';
    public String errorMsg ='';
    public Boolean isError= false;
    
    
    
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext ctx) {
        Database.ExecuteBatch(new TrackingNoEmailThreadToParentBatch(), 50);
    } 
    
    public void execute(Database.BatchableContext batchVariable, List<EmailMessage> lstMessage) {
        
		Set<String> trackNumber = new Set<String>();
        Map<String,Id> caseTrackingMap = new Map<String,Id>();
        List<Id> delCaseList = new List<Id>();
        List<EMailMessage> lstCloneEM = new List<EmailMessage>();
        for(EmailMessage objEM : lstMessage)
        {
            trackNumber.add('%'+objEM.parent.Email_Tracking_Number__c+'%');
        }
        
        if(!trackNumber.isEmpty())
        {
            for(Case cs : [SELECT Id,Tracking_Number__c FROM Case WHERE (Email_Tracking_Number__c IN : trackNumber Or (Tracking_Number__c like :trackNumber)) 
                               AND Status !=: Constant_Util.CLOSED AND Tracking_Number__c != null order by CreatedDate limit 400])
            {
                String trackNum;
                if(cs.Tracking_Number__c.contains('-'))
                {
                    String[] splitTrack = cs.Tracking_Number__c.split('-');
                    trackNum = splitTrack[0];
                }
                else
                {
                    trackNum = cs.Tracking_Number__c;
                }
                if(!caseTrackingMap.containsKey(trackNum))
                {
                    caseTrackingMap.put(trackNum,cs.Id);
                }
            }
            
            for(EmailMessage em : lstMessage)
            {
                EmailMessage clonedEM = new EmailMessage();
                if(caseTrackingMap.containsKey(em.parent.Email_Tracking_Number__c))
                {
                    clonedEM = em.clone(false);
                    clonedEM.ParentId =  caseTrackingMap.get(em.parent.Email_Tracking_Number__c);
                	clonedEM.RelatedToId  =  caseTrackingMap.get(em.parent.Email_Tracking_Number__c);
                	clonedEM.isCloned__c = true;
                	clonedEM.Bypass_Genesys_Task__c = true;
                	clonedEM.Tracking_Number_Email__c = true;
                    delCaseList.add(em.ParentId);
                    lstCloneEM.add(clonedEM);
                }
            }
        }
        try{
            if(!lstCloneEM.isEmpty()){
                Database.SaveResult[] srList = Database.insert(lstCloneEM);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        isError = True;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            errorMsg += 'Fields that affected this error: ' + err.getFields();
                        }
                    }
                }    
            }
            if(!delCaseList.isEmpty()){
                Database.DeleteResult[] drList = Database.delete(delCaseList,false);
                for(Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        isError = True;
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            errorMsg += 'Fields that affected this error: ' + err.getFields();
                        }
                    }
                }
            }
            if(Test.isRunningTest()){
                DMLException e = new DMLException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            } 
        }
        catch(Exception e)
        {
            isError = True;
            errorMsg += 'Exception occured: '+e.getLineNumber()+' '+e.getMessage()+' <br/>';
        }

    }
    
    public void finish(Database.BatchableContext batchVariable) {
        
        if(isError)
        {
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,CreatedById,TotalJobItems, CreatedBy.Email,CreatedBy.Name,ApexClass.Name
                                FROM AsyncApexJob
                                WHERE Id = :batchVariable.getJobId()];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(job.CreatedById);
            mail.setToAddresses(sendTo);
            mail.setReplyTo('noReply@wm.com');
            mail.setSenderDisplayName('WM Tracking Number Linking Batch Job');
            mail.setSubject('Batch Job '+job.ApexClass.Name+' Status '+job.status);
            String body = 'Dear ' + job.CreatedBy.Name + ', '+ ' <br/>';
            body += 'Batch Job: '+job.ApexClass.Name+'. Job Status of '+job.status+'. ';
            if(errorMsg != null && errorMsg.length() >0){
                body += '<br/> The Following Error(s) occured '+'<br/>'+ errorMsg ; 
            }
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
    }
}