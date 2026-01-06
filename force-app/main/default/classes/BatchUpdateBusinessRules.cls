global class BatchUpdateBusinessRules implements Database.Batchable<Sobject>{    
    /*@MethodName start
    *Method to fetch Business rules which has to be updated.
    **/        
    public Database.QueryLocator start(Database.BatchableContext btchContext){
        String approvl = Constant_Util.APPROVAL;
        String queryString ='SELECT ID,Is_Auto_Email__c FROM Business_Rule__c WHERE Active__c=TRUE AND Is_Auto_Email__c=FALSE AND RecordType.DeveloperName =:approvl LIMIT 49999';    
        return Database.getQueryLocator(queryString );
    }
    
    /*@MethodName execute
    * Method to update business rules
    **/
    public void execute(Database.BatchableContext btchContext,List<Business_Rule__c> listOfBusinessRules){
        try{
            for(Business_Rule__c bsRule : listOfBusinessRules){
                bsRule.Is_Auto_Email__c = TRUE;                
            }
             Database.update(listOfBusinessRules);
           }
       catch(Exception e){
       //Not inserting to ExceptionLog__c object as this is a one time batch
            System.debug('Exception occured during Business Rule Updation: '+e.getLineNumber()+' '+e.getMessage());      
       }     
    }
    
    /*@MethodName finish
    * Method to send out emails on batch success/failures
    **/
    public void finish(Database.BatchableContext btchContext){
    
    
    }
 
}