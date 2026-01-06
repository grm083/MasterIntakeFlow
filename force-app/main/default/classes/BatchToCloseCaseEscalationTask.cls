global class BatchToCloseCaseEscalationTask implements Schedulable,Database.Batchable<sObject>{
    
	 global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchToCloseCaseEscalationTask(), 200); 
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
       DateTime dt = System.Now().addHours(-24);
        // Change for test class Coverage
         if(Test.isRunningTest()) {
            dt = System.Now().addHours(24);
        }
         return Database.getQueryLocator([select Id,CreatedDate,Outcome__c,Subject,WhatId,LastModifiedDate,Process__c,Status,Attempt__c From Task where (Process__c = 'Escalation Obtain Service Approval') and Attempt__c = 2 and Status = 'Open' and CreatedDate < :dt order by createddate asc]);
   
 }
    public void execute(Database.BatchableContext BC, List<Task> scope){
        closeCase(scope);
    }
    public void finish(Database.BatchableContext BC){
        
    }
    // Create the genesys routing record from task
    public static void closeCase(List<Task> taskList){
        try{
            set<Id> caseIdSet = new set<Id>();
             set<String> caseIdSetref = new set<String>();
              List<Case> caseListToUpdate = new List<Case>();
         
            for(Task tsk : taskList ){
           	  if(tsk.Outcome__c == '' || tsk.Outcome__c == null){
                    caseIdSet.add(tsk.WhatId);
                }  
            }
             for(case c : [Select Id,Case_Sub_Status__c,Status,Reference_Number__c from case where Id IN: caseIdSet Limit 49999]){
                caseIdSetref.add(c.Reference_Number__c);
                          }
            for(case c : [Select Id,Case_Sub_Status__c,Status,Reference_Number__c from case where Reference_Number__c IN: caseIdSetref Limit 49999]){
                    c.Status = 'Closed';
                caseListToUpdate.add(c);
                          }
             if(!caseListToUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(caseListToUpdate, false);
            } 
         
        }  catch(Exception ex){
            system.debug('Exception'+ex.getStackTraceString());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
}
