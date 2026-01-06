/**********************
@Author: Saqib Qamar
@Name: BatchToPurgeCase
@Description: All 'New' cases that have not been updated should be purged-Closed after 60 days.
**************************************************************/
global class BatchToPurgeCase implements Database.Batchable<sObject>,Database.Stateful,schedulable {
    
    private static final String query = 'Select Id, LastModifiedDate, Status, Tracking_Number__c, Case_Reason__c, Origin, Quantity_Override__c from Case where LastModifiedDate < LAST_N_DAYS:60 AND Tracking_Number__c = Null AND Status =\'New\' LIMIT 49999';
    VRBatchSetting__c VRSetting;
    public BatchToPurgeCase(){
        VRSetting = [SELECT Id, IsBatchExecution__c FROM VRBatchSetting__c LIMIT 1];
    }
    global void execute(SchedulableContext sc){
      Database.executeBatch(new BatchToPurgeCase());   
    }
    /**@MethodName start**/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(query);
    }
  
    //@MethodName execute - Method to Update case Status as closed for 60 days old cases which are not preasent in Acorn.
    public void execute(Database.BatchableContext batchVariable, List<Case> caseList) {
        
        if(!System.isFuture()){
            
            try{
            	if(caseList.size()>0){
                	for (Case c : caseList){
                    	if(c.Origin == NULL){
                        c.Origin = 'Auto Closed';
                    	}
                    c.Status = 'Closed';
                    c.Quantity_Override__c = 1;
                }
                
                VRSetting.IsBatchExecution__c = true;
                update VRSetting;
                update caseList;
       	 	//	List<Case> includeCases = [select Id, Tracking_Number__c from Case where Id = : caseList];
            //    CloseAcornTicket.closeTicket(includeCases);
        }
        }
        catch(Exception e) { System.debug('Exception occured during case to Closed: '+e.getLineNumber()+' '+e.getMessage());}
    }
        } 
 
    /*@MethodName finish - Method to send the notification email if batch finished with errors**/ 
    public void finish(Database.BatchableContext batchVariable) {
        VRSetting.IsBatchExecution__c = false;
        update VRSetting;
    } 
}