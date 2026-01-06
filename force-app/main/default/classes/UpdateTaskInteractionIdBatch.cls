/*
Date : 8 Jan, 2024
Author : Rajan Sajani
Story : SDT-32713
Description : this is one time execution for data correction for self service tasks
*/
public class UpdateTaskInteractionIdBatch implements Database.batchable<Sobject>,Database.Stateful{
    string Self_Service = 'Self-Service';
    DateTime dtStartDate = System.now().addDays(-109);
    DateTime dtEndDate =  DateTime.newInstance(2024,1,18,0,0,0) ;
    String Chat_Now = 'Chat Now'; 
    Boolean updateTask = false ;
     //Public static final String query = 'Select id,origin,Createddate,Last_Customer_Interaction_Type__c,Last_Customer_Interaction_Id__c,( Select id,subject,Description,Interaction_Id__c from tasks where subject = :Self_Service and CreatedDate < :dtEndDate) from case where   origin = :Chat_Now  and createddate > :dtStartDate and createdDate < :dtEndDate   order by createddate desc limit 30000';
       
    public Database.QueryLocator start(Database.BatchableContext bc){
        String QUERY = '';
        
        If(Test.isRunningTest()){   
            QUERY = 'Select id,origin,Createddate,Last_Customer_Interaction_Type__c,Last_Customer_Interaction_Id__c,( Select id,subject,Description,Interaction_Id__c from tasks where subject = :Self_Service) from case where   origin = :Chat_Now   order by createddate asc limit 1';
        }
        else{
          QUERY = 'Select id,origin,Createddate,Last_Customer_Interaction_Type__c,Last_Customer_Interaction_Id__c,( Select id,subject,Description,Interaction_Id__c from tasks where subject = :Self_Service and CreatedDate < :dtEndDate) from case where   origin = :Chat_Now  and createddate > :dtStartDate and createdDate < :dtEndDate  order by createddate desc limit 40000';
    
        }
       return Database.getQueryLocator(QUERY);
        
    }
    public void execute(Database.BatchableContext bc,List<Case> scope){
        RecurrsiveTriggerHandler.isSkipCaseTriggerForTask = true;
        List<Task> taskToUpdate = new List<Task>();
        String inputString;
        String finalresult;
        
            for(Case c : scope){

            if(c.tasks.size()>0){

                for(Task t: c.tasks){

                    if(t.subject == 'Self-Service' && t.Interaction_ID__c == null){
                        if(t.Description != ''){
                             inputString = t.Description;
                        }
                        String sub  = 'MediaType: ';
                        String sub2 = 'Genesys';
                        
                        if(inputString != ''){
                            String result = inputString.substringAfter(sub);
                             finalresult = result.substringBefore(sub2);
                        }
                        //System.debug('finalresult^^^^ ' +finalresult);
                        //System.debug('finalresult^^^^ ' +finalresult.length());
                       if(finalresult != '' && finalresult != 'null' && finalresult != null && finalresult.length() > 6){
                        t.Interaction_ID__c = finalresult;
                        updateTask = true;
                        }
                        else{
                            updateTask = false;
                        }
                        if(updateTask){
                            taskToUpdate.add(t);
                        }
                    //System.debug('taskToUpdate^^^^ ' +taskToUpdate);
                    }
                    
                }
            }
        }
        if(taskToUpdate.size()>0 && !taskToUpdate.isEmpty()){
            update taskToUpdate;            
        }
    }
    public void finish(Database.BatchableContext bc){
        RecurrsiveTriggerHandler.isSkipCaseTriggerForTask = false;
    }
}