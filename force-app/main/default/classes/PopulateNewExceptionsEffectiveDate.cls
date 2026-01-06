global class PopulateNewExceptionsEffectiveDate implements Database.Batchable<SObject>, Database.Stateful{
    Public Integer successRecordCount = 0;
    Public Integer failedRecordCount = 0;
    Public String errorString = '';
    Public String successString = '';
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'select Id,Exception_Effective_Date__C,Exceptions_Effective_Date__C from SBQQ__QuoteLine__c where (SBQQ__Quote__r.SBQQ__Status__c =\'Product Configured\' or SBQQ__Quote__r.SBQQ__Status__c=\'Draft\' or SBQQ__Quote__r.SBQQ__Status__c=\'Cost Configured\' or SBQQ__Quote__r.SBQQ__Status__c=\'Price Configured\' or(SBQQ__Quote__r.Acorn_Integration_Status__c !=\'Success\' and SBQQ__Quote__r.SBQQ__Status__c =\'Approved\')) and SBQQ__ProductFamily__c !=\'Waste Stream\' and SBQQ__ProductFamily__c !=\'Waste Category\' and Exception_Effective_Date__c !=null and Exceptions_Effective_Date__c=null order by Exception_Effective_Date__c';
            return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> qlListToUpdate){
        if(SBQQ.TriggerControl.isEnabled()){
            SBQQ.TriggerControl.disable();
        }
        for(SObject item : qlListToUpdate){
            SBQQ__QuoteLine__c ql=(SBQQ__QuoteLine__c)item;
            ql.Exceptions_Effective_Date__c = Date.valueOf(ql.Exception_Effective_Date__c);
        }
        Database.SaveResult[] srList = Database.update(qlListToUpdate, false); 
        Integer recordid = 0;
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                successRecordCount=successRecordCount+1;
                this.successString += ' ' + qlListToUpdate[recordid].id + ', <br/>';
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    failedRecordCount=failedRecordCount+1;
                    this.errorString += ' ' + qlListToUpdate[recordid].id + ', ' + SR.getErrors()[0].getMessage() + '<br/>';
                }
            }
            recordid++;
        }
    }
    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems,CreatedBy.Email 
                          from AsyncApexJob 
                          where Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'sdhikale@wm.com','tkumar3@wm.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('ExceptionEffectiveDateBatch Result ' + a.Status);
        mail.setHTMLBody('Batch processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.'+'<br/>'+' Successful record count is'+successRecordCount+'<br/> Failed record count is'+failedRecordCount+'<br/> here are all the record IDs which got Success<br/>'+successString+'<br/> here are all the record IDs which got failed'+errorString);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}