/*
Date : 10 Jan, 2024
Author : Harunalrashidh
Story : SDT-31225
Description : this is one time execution for data correction for BR approval records.
*/
public class UpdateBrApprovalBatch implements Database.batchable<Sobject>,Database.Stateful{
  
       
    public Database.QueryLocator start(Database.BatchableContext bc){
        String QUERY = '';
        
        If(Test.isRunningTest()){   
            QUERY = 'select Id,Name,RecordType.Name,Is_Auto_Email__c, No_Approval_Required__c,Active__c  from Business_Rule__c where RecordType.Name = \'Approval\' AND  No_Approval_Required__c = true limit 1';
        }
        else{
            QUERY = 'select Id,Name,RecordType.Name,Is_Auto_Email__c, No_Approval_Required__c,Active__c  from Business_Rule__c where RecordType.Name = \'Approval\' AND Is_Auto_Email__c = true AND No_Approval_Required__c = true limit 150';
    
        }
       return Database.getQueryLocator(QUERY);
        
    }
    
    public void execute(Database.BatchableContext bc,List<Business_Rule__c> scope){
        RecurrsiveTriggerHandler.isSkipBrTrigger = true;
        List<Business_Rule__c> brToUpdate = new List<Business_Rule__c>();
       
        
            for(Business_Rule__c br : scope){

            if(br.Is_Auto_Email__c && br.No_Approval_Required__c){
              br.Is_Auto_Email__c = false;
                system.debug('the br record is '+br.Name+'br auto email is '+br.Is_Auto_Email__c);
			  brToUpdate.add(br);             
            }
        }
        if(brToUpdate.size()>0 && !brToUpdate.isEmpty()){
            update brToUpdate;            
        }
    }
    
    public void finish(Database.BatchableContext bc){
        RecurrsiveTriggerHandler.isSkipBrTrigger = false;
    }
}