global class BatchCloseAcornTicket implements Schedulable, Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    //querying cases with Close_Acorn_Ticket_API_Failed__c = TRUE which are closed within 3 days timeframe
    Private static final String Query = 'SELECT Id,Close_Acorn_Ticket_API_Failed__c FROM Case WHERE Close_Acorn_Ticket_API_Failed__c = TRUE AND Status =\'Closed\' AND ClosedDate  <= LAST_N_DAYS:'+Integer.valueOf(System.Label.CloseDate_TimeFrame) +'AND Tracking_Number__c != Null LIMIT 49999';
    
    //Method to schedule the class
    global void execute(SchedulableContext cases) {
        Database.executeBatch(new BatchCloseAcornTicket(), 1); 
    }
    //Method to fetch the case records
    global Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(Query);
    }
    //Method to call the API request for closing Acorn Ticket. 
    global void execute(Database.BatchableContext batchVariable, List<Case> caseList) {
        try
        {
            if(caseList.size()>0)
            {
                Set<Id> setCaseIds = new Set<Id>();
                for(Case c : caseList)
                {
                    setCaseIds.add(c.id);
                }            
                CloseAcornTicket.sendtoAcorn(setCaseIds);
            }
            
        }
        catch(Exception e)
        {
            System.debug('Exception occurred during Batch closing of Acorn Ticket: ' + e.getLineNumber() + ' ' + e.getMessage());
        }
        
    }
    //Method to send notification email
    global void finish(Database.BatchableContext batchVariable) {
        
    }   
}