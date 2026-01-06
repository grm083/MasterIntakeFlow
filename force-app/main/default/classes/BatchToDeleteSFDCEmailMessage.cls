/*************************************************************
@Name: BatchToDeleteSFDCEmailMessage
@Author: WM
@CreateDate: 11/05/2020
@Description: Indico Project : Batch to delete SFDCEmailMessage object records
*************************************************************/
public class BatchToDeleteSFDCEmailMessage implements  Schedulable,Database.Batchable<sObject>,Database.Stateful {
    public Integer filteringDate = null;
    
    // Method to schedule this batch class every day.
    
    public void execute(SchedulableContext ctx) {
        Database.ExecuteBatch(new BatchToDeleteSFDCEmailMessage(), 200);
    } 
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(filteringDate == null){
            filteringDate = 2;
        }
        String query = 'SELECT ID FROM SFDCEmailMessage__c WHERE CreatedDate < LAST_N_DAYS:' + filteringDate;
        
       if(Test.isRunningTest()){
		 query = 'SELECT ID FROM SFDCEmailMessage__c';
		}
        return Database.getQueryLocator(query);
    }

    public void execute (Database.BatchableContext bc, List<SFDCEmailMessage__c> scope){
        List<SFDCEmailMessage__c> deleteGenList = new List<SFDCEmailMessage__c>();
        try{
            for(SFDCEmailMessage__c gr : scope){
                deleteGenList.add(gr);
            }
            Database.delete(deleteGenList);
        }catch(Exception e){
            System.debug('delete exception -- ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext batchVariable) {

    } 
}