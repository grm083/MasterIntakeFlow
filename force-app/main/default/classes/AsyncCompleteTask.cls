public class AsyncCompleteTask implements Queueable{
    private Set<Id> closedCaseIds = new set<Id>();
    
    public AsyncCompleteTask(set<Id> asyncCaseIds){
        this.closedCaseIds = asyncCaseIds;
    }
    
    public void execute(QueueableContext context) {
    	List<Task> taskToCloseList = new List<Task>();
        for(Task thisTask: [SELECT Id, Status, Process__c, WhatId, Description, RecordType.DeveloperName FROM Task WHERE Status =: Constant_Util.OPEN AND WhatId IN : closedCaseIds]){
            if(!Constant_Util.NOTIFY_CUSTOMER_OF_DECLINE.equals(thisTask.Process__c)){
                thisTask.status = Constant_Util.COMPLETED;
                thisTask.Description = Constant_Util.TASK_COMMENTS;
            }
            taskToCloseList.add(thisTask);
        }
        if(taskToCloseList!= null && !taskToCloseList.isEmpty()) {
            Database.SaveResult[] svRes = Database.update(taskToCloseList,false);
            UTIL_LoggingService.logDmlResults(svRes, null, taskToCloseList, '', UTIL_ErrorConstants.ASYN_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
        }
    }
}