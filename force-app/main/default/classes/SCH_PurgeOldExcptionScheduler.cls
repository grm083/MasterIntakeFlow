/**
  * @Name          SCH_PurgeOldExcptionScheduler
  * @Author        Accenture
  * @Date          25/09/2019
  * @Description   Schedulable class for the purpose of removing ExceptionLog__c log crossing throsold timeline by calling BATCH_PurgeOldExcption class 
  */
public class SCH_PurgeOldExcptionScheduler implements Schedulable{    
    
    /**
      * @description       This method defines the query which determines which records are to be deleted and invokes the BATCH_PurgeOldExcption Batch Class to delete these records.
      * @param             context A reference to the SchedulableContext object
      * @return            void
	*/
    public void execute(SchedulableContext context){
    BATCH_PurgeOldExcption batchVar = new BATCH_PurgeOldExcption();
         batchVar.queryString = UTIL_ErrorConstants.BATCH_QUERY +
                                 Integer.valueOf(ExceptionLog_Settings__c.getOrgDefaults().Exception_Log_Removal_Days__c); 
         Database.executeBatch(batchVar);
    }
}