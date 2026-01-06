/**********************
@Author: Shilpa Bhatia
@Name: BatchToUpdateCaseStatus
@Description: This batch is created to close the Cases whose status is 'Open' and subStatus is 'Integration error' .
**************************************************************/
global class BatchToUpdateCaseStatus implements Database.Batchable<sObject>,Schedulable {
    
    Integer slaDays = 4;
    Id businessHourId = [SELECT Id FROM BusinessHours WHERE IsDefault = true].id;    	    
    Private static final String query = 'Select Id, Status, Tracking_Number__c,Case_Sub_Status__c, CreatedDate from Case where Status = \'Open\' and Case_Sub_Status__c = \'Integration Error\'  ';
    
    
    //Method to schedule this batch class every day.
    public void execute(SchedulableContext ctx) {
        Database.ExecuteBatch(new BatchToUpdateCaseStatus(), 50);
    } 
    
    
    //Start Method which retrieves the records of case    
    public Database.QueryLocator start(Database.BatchableContext ba) {
        return Database.getQueryLocator(query);
    }
    
    // Method to update status of Case to closed
    
    public void execute(Database.BatchableContext ba, List<Case> caseList) {
        
        
        List<Case> csToUpdate = new List<Case>();
        
        try{ 
            if(caseList.size()>0){
                for (Case c : caseList){ 
                    
                    if(c.Tracking_Number__c == null){
                    
                    Datetime targetDT = BusinessHours.add(businessHourId,c.CreatedDate, slaDays* 16 * 60 * 60 * 1000L);
                    
                    if(targetDT < System.now()){
                        Case cs = new Case(Id = c.Id,Status = 'Closed');
                        csToUpdate.add(cs);                         
                    }
                	}
                }     
                
                if(csToUpdate.size()>0){
                    Database.update(csToUpdate,false);
                }
            
          }
            
        }   catch(Exception e) { System.debug('Exception occured while closing the case: '+e.getLineNumber()+' '+e.getMessage());}
        
    }
    
    //Finish Method
    public void finish(Database.BatchableContext ba) {
        
    } 
}