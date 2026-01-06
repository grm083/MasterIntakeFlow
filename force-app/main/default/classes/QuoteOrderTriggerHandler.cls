public class QuoteOrderTriggerHandler {
    
    public static void onAfterInsert(List<Quote_Order__c> newQuoteOrderList){
       QuoteOrderTriggerHelper.updateCustPOonCase(newQuoteOrderList,null);
    }

    public static void onAfterUpdate(List<Quote_Order__c> newQuoteOrderList,Map<Id,Quote_Order__c> oldQuoteOrderMap){
       QuoteOrderTriggerHelper.updateCustPOonCase(newQuoteOrderList,oldQuoteOrderMap);
        
    }

}