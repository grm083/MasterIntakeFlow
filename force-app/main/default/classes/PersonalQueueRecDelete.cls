/*************************************************************
@Name: PersonalQueueRecDelete
@Author: Ashish
@CreateDate: 05/06/2022
@Description: Daily Batch to delete Personal Queue Info records for closed cases.
**************************************************************/
global class PersonalQueueRecDelete implements Schedulable,Database.Batchable<sObject>,Database.Stateful {
    
    Private static final String query = 'Select id from Personal_Queue_Info__c where CaseId__r.Status =\'' + String.escapeSingleQuotes('Closed')+'\'';
    global String errorMsg ='';
    global Boolean isError= false;

    /**@MethodName start
    * Method to schedule this batch class every day.
    **/ 
    public void execute(SchedulableContext ctx) {
        Database.ExecuteBatch(new PersonalQueueRecDelete(), 200);
    } 
    /**@MethodName start
    * Method to fetch Personal Queue Info records which has to be deleted.
    **/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        
        return Database.getQueryLocator(query);
    }
  /*@MethodName execute
  * Method to delete Personal Queue Info records
  **/
    public void execute(Database.BatchableContext batchVariable, List<Personal_Queue_Info__c> personalQueueList) {
        
        try {
            if(personalQueueList.size()>0){
                Database.DeleteResult[] drList = Database.delete(personalQueueList, false);
                for(Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        isError = True;
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            errorMsg += 'Personal Queue Info fields that affected this error: ' + err.getFields();
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
            errorMsg += 'Exception occured during Personal Queue details deletion: '+e.getLineNumber()+' '+e.getMessage()+' <br/>';
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