/**
 * @description       : 
 * @author            : Adil Aleem
 * @group             : 
 * @last modified on  : 08-25-2023
 * @last modified by  : Adil Aleem
**/
global class SObjectUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    List<SObject> sObjectList = new List<SObject>();

    global SObjectUpdateBatch(List<SObject> sList){
        sObjectList = sList;
    }
    global Iterable<sObject> start( Database.BatchableContext BC ) {
        return sObjectList;
    }
   
    global void execute( Database.BatchableContext BC, List<SObject> scope ) {
        Database.saveResult[] srList = database.update(scope, false);        
    }   
    
    global void finish( Database.BatchableContext BC ) {
        
    }
 
}