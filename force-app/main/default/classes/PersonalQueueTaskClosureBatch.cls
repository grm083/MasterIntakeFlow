/*************************************************************
@Name: PersonalQueueTaskClosureBatch
@Author: Saurav Dwivedi
@CreateDate: 23/12/2020
@Description: SDT - 18002 - close personal queue task
**************************************************************/
global class PersonalQueueTaskClosureBatch implements Schedulable,Database.Batchable<sObject>,Database.Stateful {
    String COMPLETED = 'Completed';
    String PQsubject = 'Personal Queue Ticket Assignment';
        
    Private static final String query = 'SELECT id,whatId,OwnerId FROM Task WHERE Status !=: COMPLETED and Subject =: PQsubject LIMIT 49999';

    /**@MethodName execute
    * Method to schedule this batch .
    **/
    
    public void execute(SchedulableContext ctx) {
        PersonalQueueTaskClosureBatch perBatch = new PersonalQueueTaskClosureBatch();
        Database.executeBatch(perBatch);
    } 
    /**@MethodName start
    * Method to fetch  records which has to be completed.
    **/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(query);
    }
  /*@MethodName execute
  * Method to update records to completed
  **/
    public void execute(Database.BatchableContext batchVariable, List<Task> taskList) {
        Set<Task> taskToUpdate = new Set<Task>();
         Set<Id> caseId = new Set<Id>();
        List<Task> taskToUpdate1 = new List<Task>();
        try {
            if(taskList.size()>0){
    				for(Task t : taskList){
        			caseId.add(t.whatId);
    				}
                List <Case > caseList = [Select id,Status,OwnerId from Case where Id IN :caseId and Status = 'Closed' LIMIT 49999];
                for(Case c: caseList){
                        for(Task tsk: taskList){
                    		 if(c.Status == 'Closed' && c.Id == tsk.WhatId){
                     Task t = new Task(Id = tsk.Id,Status = 'Completed');
                        taskToUpdate.add(t);
                }
                    }
                }
                for(Task tt : taskToUpdate){
                   taskToUpdate1.add(tt); 
                }
                 if(taskToUpdate1.size()>0){
                    Database.update(taskToUpdate1,false);
                }
                
            }
           
        } catch(Exception e) {
            System.debug('Exception occured during case deletion: '+e.getLineNumber()+' '+e.getMessage());
        }
        
    }   

 /*@MethodName finish
  *
  **/ 
    public void finish(Database.BatchableContext batchVariable) {
    
    } 
}