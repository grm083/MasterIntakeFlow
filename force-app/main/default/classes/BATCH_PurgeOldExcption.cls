/**
  * @Name          BATCH_PurgeOldExcption
  * @Author        Accenture
  * @Date          25/09/2019
  * @Description   BATCH class for the purpose of removing ExceptionLog__c log crossing throsold timeline 
  */
public class BATCH_PurgeOldExcption implements Database.Batchable<sObject> {

    public String queryString; 
    
    /**
      * @description       This method queries the soql query defined in the scheduler class and passes the List of records obtained to the execute method.
      * @param             currentScope A reference to the Database.BatchableContext object
      * @return            Database.QueryLocator
	*/
    public Database.QueryLocator start(Database.BatchableContext currentScope){
         return Database.getQueryLocator(queryString);
    }
    
    /**
      * @description       This method deletes the List of records passed to it and in case of a failure logs an ExceptionLog__c record.
      * @param             currentScope A reference to the Database.BatchableContext object
      * @param             queryResult List of the records obtained in the start() method
      * @return            void
	*/
    public void execute(Database.BatchableContext currentScope, List<sObject> queryResult){
		Database.DeleteResult[] dmlExResult = Database.Delete(queryResult, false);
        UTIL_LoggingService.logDmlResults(null, dmlExResult, queryResult, null, UTIL_ErrorConstants.BATCH_CLASS_NAME, UTIL_ErrorConstants.BATCH_METHOD_NAME, null, LoggingLevel.ERROR);
	}

    /**
      * @description       This method implements finish logic for the Batch Class
      * @param             currentScope A reference to the Database.BatchableContext object
      * @return            void
	 */
    public void finish(Database.BatchableContext currentScope){
    }
}