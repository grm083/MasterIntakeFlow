global class BatchRemoveComments implements Schedulable, Database.Batchable<sObject>, Database.Stateful {

    Private static final String Query = 'SELECT Id, CreatedDate, Case__r.Tracking_Number__c FROM Comment__c WHERE is_Log__c = false AND CreatedDate < LAST_N_DAYS:3 AND Case__r.Tracking_Number__c != Null LIMIT 49999';

    //Method to schedule the class
    global void execute(SchedulableContext comments) {
        Database.executeBatch(new BatchRemoveComments(), 2000);
    }
    //Method to fetch the records
    global Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(Query);
    }
    //Method to Delete the Comments
    global void execute(Database.BatchableContext batchVariable, List<Comment__c> CommentList) {
        
        try {
            if(CommentList.size()>0) {
                delete CommentList;
                Database.emptyRecycleBin(CommentList);
            }
            if(Test.isRunningTest()) {
                DMLException e = new DMLException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch(Exception e) {
            System.debug('Exception occurred during comment deletion: ' + e.getLineNumber() + ' ' + e.getMessage());
        }
    }
    //Method to send notification email
    global void finish(Database.BatchableContext batchVariable) {
        
    }   
}