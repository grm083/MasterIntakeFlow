/*
Author: Anup Dey
Story: SDT-20337
Description: Update quotes to declined when they expired, and update case to closed when all quotes are approved and declined
*/
public with sharing class CloseNewServiceCaseBatch implements
Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    String recordType = 'New Service Case';
    String recordTypeModify = 'Modify Existing Service Case';
    public Set<Id> testIds = new Set<Id>();
	VRBatchSetting__c VRSetting;
	public Set<Id> casesIdsforAcorn = new Set<Id>();
        
    public CloseNewServiceCaseBatch()
    {
        VRSetting = [SELECT Id, IsBatchExecution__c FROM VRBatchSetting__c LIMIT 1];
    }
    
    //local variables
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // local variables
        String closedStatus = 'Closed';
        //String recordType = 'New Service Case';
        //String recordTypeModify = 'Modify Existing Service Case';
        // get all cases which are not closed and New service type within 60 days
        //String query ='SELECT ID, Tracking_Number__c, Work_Order__r.Verify_Service_Task__c, Work_Order__r.Vendor_Service_Status__c FROM Case WHERE Status !=: closedStatus AND (Case_Record_Type__c =: recordType OR Case_Record_Type__c =: recordTypeModify) AND CreatedDate = LAST_N_DAYS:60 '; //Commented for SDT-38462
        String query = 'SELECT ID, Tracking_Number__c, Work_Order__r.Verify_Service_Task__c, Work_Order__r.Vendor_Service_Status__c FROM Case WHERE Status !=: closedStatus AND (Case_Record_Type__c =: recordType OR Case_Record_Type__c =: recordTypeModify) AND CreatedDate <= LAST_N_DAYS:60 AND IsOpportunity_Created__c = true'; //Modified for SDT-38462 
       if(testIds.size() >0)
        {
            //query ='SELECT ID, Tracking_Number__c, Work_Order__r.Verify_Service_Task__c, Work_Order__r.Vendor_Service_Status__c FROM Case WHERE Status !=: closedStatus AND ID IN: testIds  AND (Case_Record_Type__c =: recordType OR Case_Record_Type__c =: recordTypeModify) AND CreatedDate = LAST_N_DAYS:60 '; //Commented for SDT-38462
            query ='SELECT ID, Tracking_Number__c, Work_Order__r.Verify_Service_Task__c, Work_Order__r.Vendor_Service_Status__c FROM Case WHERE Status !=: closedStatus AND ID IN: testIds  AND (Case_Record_Type__c =: recordType OR Case_Record_Type__c =: recordTypeModify) AND CreatedDate <= LAST_N_DAYS:60 AND IsOpportunity_Created__c = true'; //Modified for SDT-38462
          // query ='SELECT ID, Tracking_Number__c, Work_Order__r.Verify_Service_Task__c, Work_Order__r.Vendor_Service_Status__c FROM Case WHERE Status !=: closedStatus AND ID IN: testIds  AND (Case_Record_Type__c =: recordType OR Case_Record_Type__c =: recordTypeModify) '; 
       }
        return Database.getQueryLocator(query);
    }
    
     public void execute(Database.BatchableContext bc, List<Case> scope){
         // local variables
        Set<Id> caseIds = new Set<id>();
        Map<Id, Case> mapOfCase = new Map<Id, Case>();
        Map<Id, List<SBQQ__Quote__C>> caseQuoteMap=new Map<Id, List<SBQQ__Quote__C>>();  
        List<SBQQ__Quote__C> tobeDeclinedQuoteList = new List<SBQQ__Quote__C>();
        Map<Id, List<SBQQ__Quote__C>> probablecaseQuoteMap=new Map<Id, List<SBQQ__Quote__C>>(); 
        List<Case> finalcaselist =new List<Case>();
        String strApproved= 'Approved';
        String strDeclined= 'Declined';
        String strCancelled= 'Cancelled';
         try
         {
             // initialize quote objects 
             List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
             if(scope !=null && scope.size()>0)
             {
                 for(Case cs : scope)
                 {
                   caseIds.add(cs.Id);       
                   mapOfCase.put(cs.Id, cs);
                 }
                 //system.debug('mapOfCase'+ mapOfCase);
                 if(!caseIds.isEmpty())
                 {
                    //get all quotes based on cases retrived
                    quotes = [SELECT ID, SBQQ__Opportunity2__r.Case__c,SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c, SBQQ__Status__c,SBQQ__Opportunity2__r.Id, SBQQ__ExpirationDate__c  
                              FROM SBQQ__Quote__c   WHERE SBQQ__Opportunity2__r.Case__c IN: caseIds Order by SBQQ__Opportunity2__r.Case__c, ID];
                 
                     // check if we have quotes available
                     if(quotes != null && !quotes.isEmpty())
                     {
                         // loop through the Quotes to fill the CaseQuoteMap(this map is holding relationship between case and quotes)
                         for(SBQQ__Quote__c quote : quotes)
                         { 
                             //Making map between Case and Quote
                             if(CaseQuoteMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c))
                             {
                                List<SBQQ__Quote__c> quotelist =  CaseQuoteMap.get(quote.SBQQ__Opportunity2__r.Case__c);
                                quotelist.add(quote);
                                CaseQuoteMap.put(quote.SBQQ__Opportunity2__r.Case__c,quotelist);
                             }
                             else{
                                 CaseQuoteMap.put(quote.SBQQ__Opportunity2__r.Case__c,new List<SBQQ__Quote__c> {quote});
                             }
                             
                             //#AC -1 : check for ExpirationDate and status
                             
                             if(quote.SBQQ__ExpirationDate__c < System.today() && quote.SBQQ__Status__c != strApproved && quote.SBQQ__Status__c != strDeclined && quote.SBQQ__Status__c != strCancelled)
                             {
                                 // updating quote status as 'Cancelled'
                                 //Changes done for SDT-23803
                                 quote.Cancellation_Reason__c = 'Quote canceled automatically by the system because Quote expiration date has passed';
                                 quote.SBQQ__Status__c = strCancelled;
                                 tobeDeclinedQuoteList.add(quote);
                             }
                             
                             //#AC -2 : checking all quotes status if they are Approved or Declined
                             if((quote.SBQQ__Status__c == strApproved && quote.SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c == recordType) || quote.SBQQ__Status__c == strDeclined || quote.SBQQ__Status__c == strCancelled)
                             {
                                 //adding probable case and quotes in probablecaseQuoteMap - which needs to close
                              	 if(probablecaseQuoteMap.containsKey(quote.SBQQ__Opportunity2__r.Case__c))
                                 {
                                    List<SBQQ__Quote__c> quotelist =  probablecaseQuoteMap.get(quote.SBQQ__Opportunity2__r.Case__c);
                                    quotelist.add(quote);
                                    probablecaseQuoteMap.put(quote.SBQQ__Opportunity2__r.Case__c,quotelist);
                                 }
                                 else{
                                     probablecaseQuoteMap.put(quote.SBQQ__Opportunity2__r.Case__c,new List<SBQQ__Quote__c> {quote});
                                 }
                             }
                         }
                         
                          //iterating over all the cases using keyset(case) of CaseQuoteMap
                         for(Id idValue : CaseQuoteMap.keyset())
                          {
                              // checking if key/case exists in both Maps
                              if(CaseQuoteMap.containsKey(idValue) && probablecaseQuoteMap.containsKey(idValue))
                              {
                                  // adding case if caseQuoteMap has same no. of quotes probabcasequote map
                                  // Considering when both map size is same all the quotes under the case are in Approved or Declined status
                                  if(CaseQuoteMap.get(idValue).size() == probablecaseQuoteMap.get(idValue).size())
                                  {
                                    // Creating to be closed case list
                                    Case casetobeClosed= new Case();
                                    casetobeClosed.Id=idValue;
                                    casetobeClosed.Status='Closed';
                                    finalcaselist.add(casetobeClosed);
                                    
                                    // assigning case Ids in casesIdsforAcorn object to pass in CloseAcornTicket class to call AcornAPI
                                    if(mapOfCase.containsKey(idValue))
                                    	putcasesforAcornUpdateonClosure(mapOfCase.get(idValue));
                                  }
                              }
                          }
                         //system.debug('tobeDeclinedQuoteList count'+ tobeDeclinedQuoteList + 'finalcaselist Count'+ finalcaselist);
                         //Updating Quotes to 'Declined'
                          updateQuotetoDeclined(tobeDeclinedQuoteList);
                         
                          // Updating Cases to 'Closed'
                          updateCasestoClosed(finalcaselist);
                     }
                 }
             }
         }
         catch(Exception ex)
         {
             system.debug('error in CloseNewServiceCaseBatch class: ' + ex.getMessage());
             UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(),UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
         }
     }
     
    public void finish(Database.BatchableContext bc){
        //system.debug('casesIdsforAcorn '+ casesIdsforAcorn);
        // calling Acorn API to close the cases
        if(!casesIdsforAcorn.isEmpty())
        	CloseAcornTicket.sendtoAcorn(casesIdsforAcorn);
        // Modified for SDT-33450 Start
        try {
        VRSetting.IsBatchExecution__c = false;
if(VRSetting != null){
        update VRSetting;
        }
        } catch(Exception e) {
            //System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
            STPExceptionUtil.setStepByStepExceptionObj('updateBRonCase', 'Case Screen',e.getMessage());
        }
        // Modified for SDT-33450 End
        //system.debug('batch job finished');
    }
    
    ///Method to update the cases to Closed
    private void updateCasestoClosed(List<Case> finalcaselist)
    {
        if(!finalcaselist.isEmpty())
        {
// Modified for SDT-33450 Start
            try {
            VRSetting.IsBatchExecution__c = true;
if(VRSetting != null){
            update VRSetting;
}
            } catch(Exception e) {
                //System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
                STPExceptionUtil.setStepByStepExceptionObj('updateBRonCase', 'Case Screen',e.getMessage());
            }
            // Modified for SDT-33450 End
            
            //update finalcaselist;
            List<Database.SaveResult> caseSaveResults = Database.update(finalcaselist,true);
            
        }
    }
    
    // method to check for the cases which need to close
    private void putcasesforAcornUpdateonClosure(Case objCase)
    {
        //system.debug('Tracking_Number__c'+ objCase.Tracking_Number__c + 'Verify_Service_Task__c ' + objCase.Work_Order__r.Verify_Service_Task__c + 'Vendor_Service_Status__c' + objCase.Work_Order__r.Vendor_Service_Status__c);
        //if(String.isNotEmpty(objCase.Tracking_Number__c) && (checkServiceTask(objCase) || CheckServiceStatus(objCase)))
        if(String.isNotEmpty(objCase.Tracking_Number__c))
        {
            // assigning case Ids in casesIdsforAcorn object to pass in CloseAcornTicket class to call AcornAPI
            casesIdsforAcorn.add(objCase.Id);
            //system.debug('casesIdsforAcorn '+ casesIdsforAcorn);
        }
    }
    
    // method to check wo service task
    //private Boolean checkServiceTask(Case objCase)
    //{
    //    system.debug('objCase.Work_Order__r'+ objCase.Work_Order__r + 'objCase.Work_Order__r.Verify_Service_Task__c '+ objCase.Work_Order__r.Verify_Service_Task__c);
    //    Boolean result= objCase.Work_Order__r != null && string.isNotEmpty(objCase.Work_Order__r.Verify_Service_Task__c) && (objCase.Work_Order__r.Verify_Service_Task__c == 'SRI');
    //    return result;
    //}
    
    // method to check for the WO vendor service status 
    //private Boolean checkServiceStatus(Case objCase)
    //{
    //    system.debug('objCase.Work_Order__r'+ objCase.Work_Order__r + 'objCase.Work_Order__r.Vendor_Service_Status__c' + objCase.Work_Order__r.Vendor_Service_Status__c);
    //    Boolean result= objCase.Work_Order__r != null && string.isNotEmpty(objCase.Work_Order__r.Vendor_Service_Status__c) && (objCase.Work_Order__r.Vendor_Service_Status__c == 'Confirmed Negative');
    //    return result;
    //}
   
    // Method to update the quote to Declined
    private void updateQuotetoDeclined(List<SBQQ__Quote__C> tobeDeclinedQuoteList)
    {
       if(!tobeDeclinedQuoteList.isEmpty())
       {
           //update tobeDeclinedQuoteList;   
           List<Database.SaveResult> quoteSaveResults = Database.update(tobeDeclinedQuoteList,true);
           for(Database.SaveResult sr: quoteSaveResults)
            {
                if(!sr.isSuccess())
                {
                    for(Database.Error er: sr.getErrors())
                    {
                     	system.debug('Error while updating Quotes' + er.getMessage());   
                    }
                }
            }
       } 
    }
}