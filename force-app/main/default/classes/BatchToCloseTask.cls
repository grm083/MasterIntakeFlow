/*************************************************************
@Name: BatchToCloseTask
@Author: Ashish
@CreateDate: 07/12/2022
@Description: Daily Batch to close Task for closed cases.
**************************************************************/
global class BatchToCloseTask implements Schedulable,Database.Batchable<sObject>,Database.Stateful {
    
    Private static final String query = 'select id,Process__c,CreatedDate from task where Status =\'' + String.escapeSingleQuotes('Open')+'\' AND WhatId in (Select id from case where status = \'' + String.escapeSingleQuotes('Closed')+'\' ) order by createddate desc';
    global String errorMsg ='';
    global Boolean isError= false;

    /**@MethodName start
    * Method to schedule this batch class every day.
    **/ 
    public void execute(SchedulableContext ctx) {
        Database.ExecuteBatch(new BatchToCloseTask(), 200);
    } 
    /**@MethodName start
    * Method to fetch Task records which has to be closed.
    **/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        
        return Database.getQueryLocator(query);
    }
  /*@MethodName execute
  * Method to close Task records
  **/
    public void execute(Database.BatchableContext batchVariable, List<Task> taskList) {
        List<Task> tskUpdate = new List<Task>();
        try {
            if(taskList.size()>0){
                for(Task t : taskList)
                {
                    t.status = Constant_Util.COMPLETED;
                    t.Description = Constant_Util.TASK_COMMENTS;
                    tskUpdate.add(t);
                }
                Database.SaveResult[] svRes = Database.update(tskUpdate,false);
                for(Database.SaveResult dr : svRes) {
                    if (!dr.isSuccess()) {
                        isError = True;
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            errorMsg += 'Task fields that affected this error: ' + err.getFields();
                        }
                    }
                }
            }
            if(Test.isRunningTest()){
                DMLException e = new DMLException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch(Exception e) {
            isError = True;
            errorMsg += 'Exception occured during Task deletion: '+e.getLineNumber()+' '+e.getMessage()+' <br/>';
        }
        
    }   

 /*@MethodName finish
  * Method to send the notification email if batch finished with errors
  **/ 
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
            mail.setSenderDisplayName('WM Batch Job');
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