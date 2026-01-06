/*
Author: Anup Dey
Story: SDT-22548
Description: Update quotes priority based on Quote Start date
*/
public with sharing class QuotePriorityChangeBatch implements
Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    public Set<Id> testIds = new Set<Id>();
	VRBatchSetting__c vRSetting;
	public Set<Id> casesIdsforAcorn = new Set<Id>();

    public QuotePriorityChangeBatch() {
        vRSetting = [SELECT Id, IsBatchExecution__c FROM VRBatchSetting__c LIMIT 1];
    }

     //local variables
     public Database.QueryLocator start(Database.BatchableContext bc) {
         // local variables
        String approvedStatus = 'Approved';
    	String recordType = 'New Service';
        // get all quotes which are not approved status and record type New service 
        String query ='SELECT Id, RecordType.Name, SBQQ__Status__c, SBQQ__StartDate__c, Priority__c from SBQQ__Quote__c WHERE SBQQ__Status__c !=: approvedStatus AND RecordType.Name =: recordType '; 
        // checking for test IDs if want to run with specific quote Ids 
        if(testIds.size() >0)
        {
            query ='SELECT Id, RecordType.Name, SBQQ__Status__c, SBQQ__StartDate__c, Priority__c from SBQQ__Quote__c WHERE SBQQ__Status__c !=: approvedStatus AND RecordType.Name =: recordType AND Id IN: testIds '; 
        }
        return Database.getQueryLocator(query);
     }

     public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope){
        // local priority variables
        String priorityP1= 'P1';
        String priorityP2= 'P2';
        String priorityP3= 'P3';
        String priorityP4= 'P4';
        try{
            List<SBQQ__Quote__c> finalQuotelist =new List<SBQQ__Quote__c>();
            BusinessDays bd = new BusinessDays();
            if(scope !=null && scope.size()>0)
            {
                for(SBQQ__Quote__c qt : scope)
                {
                    Integer noOfDays = bd.getNoOfDaysfromCurrentDate(qt.SBQQ__StartDate__c);
                    //Calculate Priority
                    calculatePriority(noOfDays, qt, priorityP1, priorityP2, priorityP3, priorityP4);
                }
            }
            vRSetting.IsBatchExecution__c = true;
            update VRSetting;
            // update quote with calculate priority
            update scope;
        }
        catch(Exception ex)
         {
            system.debug('error in QuotePriorityChangeBatch class: ' + ex.getMessage());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(),UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
         }
     }

     public void finish(Database.BatchableContext bc){
        vRSetting.IsBatchExecution__c = false;
        update vRSetting;
     }

     //Calculate Priorities based on Desired Priority Levels
     private void calculatePriority(Integer noOfDays, SBQQ__Quote__c qt, String priorityP1, String priorityP2, String priorityP3, String priorityP4)
     {
         system.debug('calculatePriority'+ noOfDays);
          // if start Date equal to today then assign P1
          if(noOfDays==0)
          {
              qt.Priority__c=priorityP1;
          }
          //start Date equal to next business day then assign P2
          else if(noOfDays==1)
          {
              qt.Priority__c=priorityP2;
          }
          //start Date equal to T+2 to T+10 then assign P3
          else if(noOfDays>1 && noOfDays<=10)
          {
              qt.Priority__c=priorityP3;
          }
          //start Date equal to T+11 or greater then assign P4
          else if(noOfDays>=11)
          {
              qt.Priority__c=priorityP4;
          }
     }
}