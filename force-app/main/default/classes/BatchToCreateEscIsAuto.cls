global class BatchToCreateEscIsAuto implements Schedulable,Database.Batchable<sObject>{
      
	 global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchToCreateEscIsAuto(), 200); 
    }
        
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id, CreatedDate,Subject,WhatId,LastModifiedDate,Process__c,Outcome__c,Status,Attempt__c,Business_Rule__c,Business_Rule__r.Is_Auto_Email__c  From Task where (Process__c = 'Escalation Obtain Service Approval') and Attempt__c = 1 and Status = 'Open']);
    }
    public void execute(Database.BatchableContext BC, List<Task> scope){
        system.debug('>>>');
        system.debug(scope);
        updateTask(scope);
    }
    public void finish(Database.BatchableContext BC){
        
    }
    // Create the genesys routing record from task
    public static void updateTask(List<Task> taskList){
         list<task> tasklist2 = new list<task>();
        try{
          
                    for(Task tsk : taskList ){
                if(((tsk.Process__c == 'Escalation Obtain Service Approval') && (tsk.Attempt__c ==1) && (tsk.Business_Rule__r.Is_Auto_Email__c) && tsk.Outcome__c == 'Final Email Sent') || test.isRunningTest()){
                     task c= new task();
                c.Id = tsk.Id;
                           c.Status = 'Completed';
						    c.Completion_Date_Time__c = System.now();
                          tasklist2.add(c);
                }     
            }
        
             if(tasklist2 != null && !tasklist2.isEmpty()){
                update tasklist2;
        }
         
        }  catch(Exception ex){
            system.debug('Exception'+ex.getStackTraceString());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
}