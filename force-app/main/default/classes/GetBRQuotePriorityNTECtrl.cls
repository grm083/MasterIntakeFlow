public class GetBRQuotePriorityNTECtrl {

    public static Business_Rule__c getBRNTEPriority(String quoteId)
    {
        Business_Rule__c brRules = null;
        Map<Id, SBQQ__Quote__c>  mnewQuote = new Map<Id, SBQQ__Quote__c>([SELECT id,SBQQ__Type__c,SBQQ__Status__c,Owner.Profile.Name,SBQQ__PrimaryContact__c,Next_Action_Start_Date__c,SBQQ__EndDate__c,
                                                                             SBQQ__Account__r.parentid,SBQQ__Account__c,SBQQ__PrimaryContact__r.Account_Title__c,Next_Action_Due_Date__c,
                                                                             SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Reason__c,Assigned_To__c,SBQQ__StartDate__c,
                                                                             Project__c,SBQQ__PrimaryContact__r.Email,SBQQ__PrimaryContact__r.Account_Department__c,Action_Type__c,CreatedBy.Email,
                                                                             SBQQ__Account__r.Division__c,SBQQ__Account__r.Brand__c,SBQQ__Account__r.Location_Type__c,SBQQ__Account__r.Geography__c,
                                                                             SBQQ__Quote__c.Business_Rule__c,Last_Action_Performed__c,Case_Number__c,Case_Type__c, SBQQ__Opportunity2__r.Case__r.Origin,
                                                                             //Changes for SDT-30717
                                                                             ////SDT41544 adding SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c to query
                                                                             SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c, SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c, CreatedById, SBQQ__Opportunity2__r.Case__c, SBQQ__Opportunity2__r.Case__r.CreatedBy.Email,  SBQQ__Opportunity2__r.Case__r.CreatedById, 
                                                                             SBQQ__Opportunity2__r.Case__r.SuppliedEmail, SBQQ__Opportunity2__r.Case__r.SuppliedName, SBQQ__Opportunity2__r.Case__r.ContactId, 
                                                                             SBQQ__Account__r.Parent.Id,SBQQ__Account__r.Parent.AccountNumber , Duration__c
                                                                             FROM SBQQ__Quote__c 
                                                                             WHERE Id =: quoteId AND Quote_Only__c=false]);

        
        //System.debug('mnewQuote--'+mnewQuote);
        if(!mnewQuote.isEmpty()){
            // local Variables
            Set<Id> sQuoteIds = new Set<Id>();
            Map<Id, Map<String,List<SBQQ__QuoteLine__c>>> getQuoteLinesDurationAndQuote = new Map<Id, Map<String,List<SBQQ__QuoteLine__c>>>();
            Map<String,List<SBQQ__QuoteLine__c>> mQuouteLines =  new Map<String,List<SBQQ__QuoteLine__c>>();
            Map<String, Map<String, Map<Decimal, String>>> mQuoteDurationPriorityCondition = new Map<String, Map<string, Map<Decimal,String>>>();
            Map<decimal, String> getFilterbasedOnPriority = new Map<decimal, String>();
            Map<Id,Map<String, List<String>>> quoteApprovers = new Map<Id,Map<String, List<String>>>();
            //Map <String,Map<String, List<String>>> mDurationApprovers = new Map <String,Map<String, List<String>>>();
            Map <String,List<String>> mServiceApprovers = new Map<String,List<String>>();
            QuoteApproval qcls = new QuoteApproval();
            //Fetching all the Quote Line records using quote id
            sQuoteIds = mnewQuote.keyset();
            //System.debug('sQuoteIds--+'+sQuoteIds);
            //Changes for SDT-30717
            QuoteLineSelector qlSelector = new QuoteLineSelector();
            List<SBQQ__QuoteLine__c> lQuotelines = qlSelector.getQuoteLinesByQuoteIdHavingOpportunity(sQuoteIds);
            
            if(lQuotelines != Null && !lQuotelines.isEmpty())
            {
                /*This will store the Map of Quote Id with Map of QuoteLines based on Duration__c for prioritization*/
                for(SBQQ__QuoteLine__c objQuoteLine : lQuotelines){
                    mQuouteLines.put(objQuoteLine.Duration__c,lQuotelines); 
                    getQuoteLinesDurationAndQuote.put(objQuoteLine.SBQQ__Quote__c, mQuouteLines);
                }
                
                //Prioritization logic
                mQuoteDurationPriorityCondition = qcls.constructPriorityConditions(getQuoteLinesDurationAndQuote,mnewQuote);    
                System.debug('mQuoteDurationPriorityCondition===='+mQuoteDurationPriorityCondition);
                
                //Get Business Rule Approvers
                for(Id qId : mQuoteDurationPriorityCondition.keyset()){
                    if(mQuoteDurationPriorityCondition.get(qId) != null){
                        for(String duration : mQuoteDurationPriorityCondition.get(qId).keyset()){
                            getFilterbasedOnPriority.putAll(mQuoteDurationPriorityCondition.get(qId).get(duration));
                        }
                    }
                }
    
                // Get Business Approvers
                brRules = qcls.getBusinessRuleApproversDetails(getFilterbasedOnPriority,mnewQuote.get(lQuotelines.get(0).SBQQ__Quote__c), lQuotelines);
                system.debug('Priority brRules :: ' +brRules);
                
            }    
        }
        return brRules;
    }

}