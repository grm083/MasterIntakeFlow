/*************************************************************
@Name: CloseAcornTicket
@Author: Paul Payne
@CreateDate: 29/04/2019
@Description: Helper Class to Perform operations on CloseAcornTicket
@UsedBy: 
**************************************************************/
public without sharing class CloseAcornTicket {
    
    @InvocableMethod(label='Invocable Close Acorn Ticket Method' description='It is invocable method for the Close Acorn Ticket Method')
    /*
    * This method is Invokable from Process Builder
    * @owner : Paul Payne
    * @param : List<Case>
    */
    public static void closeTicket(List<Case> caselst){
        Set<Id> setCaseIds = new Set<Id>();
        for(Case c : caselst){
            setCaseIds.add(c.id);
        }
        if(!System.isBatch() && !System.isFuture()){
            sendtoAcornAsync(setCaseIds);
        } else {
            sendtoAcorn(setCaseIds);
        }
    }
	
	/*
    * This is a future method and sending details to Acorn.
    * @owner : Anup Dey
    * @param : Set<Id>
    */
    @future(callout=true)
    public static void sendtoAcornAsync(Set<Id> caselst){
        sendtoAcorn(caselst);
    }
    
    /*
    * This is a future method and sending details to Acorn.
    * @owner : Paul Payne
    * @param : Set<Id>
    * edit comment: Updated by Anup Dey, this method is getting called from CloseNewServiceCaseBatch
    * this method call for new service case type to close the tickets for which WO is not present and  VRBatchSetting__c.IsBatchExecution__c is set to true to aviod calling futur method from batch class
    * the same method is called from the process builder : Case Update Process where VRBatchSetting__c.IsBatchExecution__c is set to false when case record type is other than new service case
    */ 
    public static void sendtoAcorn(Set<Id> caselst){
        //Map<Id, Case> updatecaselist = new Map<Id, Case>();
        List<Case> updateCaseList = new List<Case>();
        //changes related to SDT - 31977 -added Close_Acorn_Ticket_API_Failed__c field to the query
        List<Case> includeCases = [SELECT ID, TRACKING_NUMBER__C,CASE_CLOSE_REASON__C,Close_Acorn_Ticket_API_Failed__c,CaseNumber FROM CASE WHERE ID = : caselst];
        List<System_Log__c> sysLogList = new List<System_Log__c>();
		//creating exception log for testing -SDT-36168
        List<ExceptionLog__c> exLogList = new List<ExceptionLog__c>();
        for (Case c: includeCases) {
            //String result;
            //RESTHelper.AcornResponse jsonResp;
            //try {
                String result = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.CLOSE_ACORN_TICKET, c.Id);
                //result = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.CLOSE_ACORN_TICKET, c.Id);             
                RESTHelper.AcornResponse jsonResp;
            try{    
                jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
            }
            catch (Exception e){
                //changes related to SDT - 31977
                if(!c.Close_Acorn_Ticket_API_Failed__c)
                {
                    c.Close_Acorn_Ticket_API_Failed__c = TRUE;
                    updateCaseList.add(c);
                }
                // Remove after debug the issue in Prod - SDT-8018
                System_Log__c  sysLog = new System_Log__c();
                String logMessage = e.getMessage() +' '+ e.getStackTraceString();
                //truncating length of Message__c field to avoid DML exception -changes related to SDT - 31977 .substring(0,80)
                sysLog.Message__c = (logMessage.length() > 200) ? (logMessage.subString(0,190)) : logMessage;
                sysLog.Class_Name__c = 'CloseAcornTicket'; 
                sysLog.Payload__c = result;
				sysLog.Case__c = c.Id;
                sysLogList.add(sysLog);
            }
			//creating exception log for testing -SDT-36168
            ExceptionLog__c exLog = TwoWayService.logExceptions('Case number - '+c.CaseNumber+' Flag value - '+c.Close_Acorn_Ticket_API_Failed__c, 'sendtoAcorn', 'Generic Exception');
 			exLogList.add(exLog);
			
            //changes related to SDT - 31977 -  additional condition to check if the response is null
            if (jsonResp == null || (jsonResp != null && jsonResp.hasProblems())){ 
                //changes related to SDT - 31977
                //revertedCases.put(c.Id, c.clone(true, true, false, true));
                if(!c.Close_Acorn_Ticket_API_Failed__c)
                {
                    c.Close_Acorn_Ticket_API_Failed__c = TRUE;
                    updateCaseList.add(c);
                }
        }else{
                if(c.Close_Acorn_Ticket_API_Failed__c)
                {
                    c.Close_Acorn_Ticket_API_Failed__c = FALSE;
                    updateCaseList.add(c);
                }
                
            }
        }
        if(!sysLogList.isEmpty())
        {
            insert sysLogList;
        }
        
        //changes related to SDT - 31977 -updating list of cases
        if(!updateCaseList.isEmpty())
        {
            update updateCaseList;

        }
		
		//creating exception log for testing -SDT-36168
        if(!exLogList.isEmpty())
        {
            insert exLogList;
            
        }
        
        /*   if (revertedCases.size() > 0 && revertedCases != null)
        { 
            CloseAcornTicket.revertCases(revertedCases);
        } */
    }
    
    // Finds latest change from CaseHistory table for Status or Sub Status, or Both
    /* public static void revertCases(Map<Id, Case> revertedCases) {
        try {
            Boolean STATUS_REVERT_COMPLETE = false;
            Boolean SUB_STATUS_REVERT_COMPLETE = false;
            Boolean Close_Irrelevant_Case_REVERT_COMPLETE = false;
            Boolean Close_Pickup_Case_REVERT_COMPLETE = false;
            Map<Id, Case> updatedCases = new Map<Id, Case>();        
            
            List<Case> revertedCaseHistory = [select Id, Status, Case_Sub_Status__c,Close_Irrelevant_Case__c, Close_Pickup_Case__c,Case_Close_Reason__c,LastModifiedDate, (select Field, OldValue, NewValue, CreatedDate from Histories where Field in ('Status', 'Case_Sub_Status__c','Close_Irrelevant_Case__c', 'Close_Pickup_Case__c','Case_Close_Reason__c') order by CreatedDate DESC limit 2) from Case where Id in:revertedCases.keySet()];
            
            for (Case c: revertedCaseHistory) {
                Case revertedCase = (Case) revertedCases.get(c.Id);
                List<CaseHistory> itr = new List<CaseHistory>();
                if(c.Histories!=null || !c.Histories.isEmpty() ){
                    itr = c.Histories ;
                } 
                
                if(Test.isRunningTest()){  //if TEST, create dummy CaseHistory
                    list<CaseHistory> chList = TestDataFactory.CaseHistory(c.id);
                    itr = chList ;        
                }

                for (CaseHistory ch: itr) {
                    if ( Test.isRunningTest() ||c.LastModifiedDate.date() == ch.CreatedDate.date()) {
                        System.debug('ch '+ch);
                        if (ch.Field == 'Status') { 
                            revertedCase.Status = String.valueOf(ch.OldValue); STATUS_REVERT_COMPLETE  = true;
                        } 
                        if (ch.Field == 'Case_Sub_Status__c') {
                            revertedCase.Case_Sub_Status__c = String.valueOf(ch.OldValue); SUB_STATUS_REVERT_COMPLETE = true;
                        }
                        if (ch.Field == 'Close_Irrelevant_Case__c' && !Test.isRunningTest()) {
                            revertedCase.Close_Irrelevant_Case__c = Boolean.valueOf(ch.OldValue); Close_Irrelevant_Case_REVERT_COMPLETE = true;revertedCase.Case_Close_Reason__c = null;
                        }
                    }
                    if (STATUS_REVERT_COMPLETE || SUB_STATUS_REVERT_COMPLETE || Close_Pickup_Case_REVERT_COMPLETE || Close_Irrelevant_Case_REVERT_COMPLETE ){ updatedCases.put(revertedCase.Id, revertedCase); }
                    if (STATUS_REVERT_COMPLETE && SUB_STATUS_REVERT_COMPLETE && Close_Pickup_Case_REVERT_COMPLETE && Close_Irrelevant_Case_REVERT_COMPLETE ){ break;}
                }
            }
            if (STATUS_REVERT_COMPLETE || SUB_STATUS_REVERT_COMPLETE || Close_Pickup_Case_REVERT_COMPLETE || Close_Irrelevant_Case_REVERT_COMPLETE ){ update updatedCases.values(); }    
        } catch(Exception e) {
            System.debug('An Error Occurred While Trying to Revert The Case: ' + e.getMessage());
        }
    } */
}