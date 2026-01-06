/*************************************************************
@Name: BatchToUpdateUsersGroupIdScheduler
@Author: Ganesh ram S
@CreateDate: 07/02/2019
@Description: Scheduler class for BatchToUpdateUsersGroupId batch class.
**************************************************************/
global class BatchToUpdateUsersGroupIdScheduler implements Schedulable {
    
    /* @Method execute
* Method to invoke the BatchToUpdateUsersGroupId Apex batch
**/    
    public void execute(SchedulableContext ctx) {
        
        BatchToUpdateUsersGroupId jobApex = new BatchToUpdateUsersGroupId();
        
        Database.ExecuteBatch(jobApex);
        
    }  
}