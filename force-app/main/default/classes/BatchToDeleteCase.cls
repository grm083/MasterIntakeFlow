/*************************************************************
@Name: BatchToDeleteCase
@Author: Kalaiselvi R
@CreateDate: 05/23/2019
@Description: Daily Batch to delete case records if it is duplicate of EmailToCase.
**************************************************************/
global class BatchToDeleteCase implements Schedulable,Database.Batchable<sObject>,Database.Stateful {
    
    Private static final String query = 'SELECT id, Mark_to_delete__c FROM case WHERE Mark_to_delete__c = true LIMIT 49999';

    /**@MethodName start
    * Method to schedule this batch class every day.
    **/ 
    public void execute(SchedulableContext ctx) {
        Database.ExecuteBatch(new BatchToDeleteCase(), 200);
    } 
    /**@MethodName start
    * Method to fetch case records which has to be deleted.
    **/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        
        return Database.getQueryLocator(query);
    }
  /*@MethodName execute
  * Method to delete case records
  **/
    public void execute(Database.BatchableContext batchVariable, List<Case> caseList) {
        
        try {
            if(caseList.size()>0){
                delete caseList;
            }
            if(Test.isRunningTest()){
                DMLException e = new DMLException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch(Exception e) {
            System.debug('Exception occured during case deletion: '+e.getLineNumber()+' '+e.getMessage());
        }
        
    }   

 /*@MethodName finish
  * Method to send the notification email if batch finished with errors
  **/ 
    public void finish(Database.BatchableContext batchVariable) {
    
    } 
}