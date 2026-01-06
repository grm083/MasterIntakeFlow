/*
Author: Shilpa Bhatia
Story: SDT-23088
Description: Create Genesys Records for Quote
*/

public with sharing class CreateGenesysForQuoteBatch implements
Database.Batchable<sObject>, Database.Stateful{
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query ='SELECT Id,Is_Genesys_Required__c, RecordType.Name, SBQQ__Status__c, SBQQ__StartDate__c, Priority__c from SBQQ__Quote__c WHERE Is_Genesys_Required__c = true';
        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope){
        
        List<Id> quoteListId = new List<Id>(); 
        List<SBQQ__Quote__c>quoteList = new List<SBQQ__Quote__c>(); 
        
        for(SBQQ__Quote__c quote: scope){
            Boolean isStartDateWithinthirtyDays = QuoteTriggerHelper.checkQuoteStartDateWithinthirtyDays(quote.SBQQ__StartDate__c);
            if(isStartDateWithinthirtyDays){
                quoteList.add(quote);    
                quoteListId.add(quote.Id);
            }     
            
        }
        
        QuoteTriggerHelper.RunAsyncGenesysCreation = false;////SDT-23088 - Field is being used to update Genesys fields Synchronously.
        QuoteTriggerHelper.createGenesysForQuote(quoteList,quoteListId,'New',null);
        
        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}