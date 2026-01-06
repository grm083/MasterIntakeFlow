/**
 * Date: 12/8/2022
 * Description: It's used to update the Service Type on WorkOrderLineItem
 * */
global class BatchUpdateWorkOrderLineItem implements Database.Batchable<sObject> {
    
    public database.QueryLocator start(Database.BatchableContext bc){
        String strDisposal ='Disposal';
        String strNew ='New';
        String strProgress ='In Progress';
        String strHold ='On Hold';
        return database.getQueryLocator('Select Id, Service_Type__c,Asset_Service_Type__c from WorkOrderLineItem WHERE Asset_Service_Type__c = null AND Service_Type__c =:strDisposal AND (Status =:strNew OR Status =:strProgress OR Status =: strHold)');
    }
    
    public void execute(Database.BatchableContext bc, List<WorkOrderLineItem> woList){
        List<WorkOrderLineItem> updateWOLIList = new List<WorkOrderLineItem>();
        for(WorkOrderLineItem wi : woList){
            wi.Asset_Service_Type__c  = wi.Service_Type__c;
            updateWOLIList.add(wi);
        }
        if(!updateWOLIList.isEmpty()){
            Database.update(updateWOLIList,false);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }

}