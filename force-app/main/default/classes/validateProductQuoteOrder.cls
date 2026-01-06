public class validateProductQuoteOrder { 
    public static string errMsg = 'You have selected a delivery product option but have not configured a delivery order.  Please click "Create and View Order(s)" to configure your delivery order.';

    public static void vProductQuoteOrder(List<SBQQ__Quote__c> triggerNew, map<id, SBQQ__Quote__c> triggerOldMap){
        
        set<id> qIdSet = new set<id>();
        for(SBQQ__Quote__c qNew: triggerNew){
            if(qNew.SBQQ__Status__c!= triggerOldMap.get(qNew.id).SBQQ__Status__c &&  qNew.SBQQ__Status__c!='Declined' &&  qNew.SBQQ__Status__c!='Cancelled'){
                qIdSet.add(qNew.id);
            }
        }
        
        map<id, List<SBQQ__QuoteLine__c>> qIdQlineListMap = new map<id, List<SBQQ__QuoteLine__c>>();
        set<id> qLineWithOutqOrderSet = new set<id>();
        //added if condition for query optimization - av4 22/04/2025
        if(qIdSet.size() > 0) 
        {
        for(SBQQ__QuoteLine__c qLine: [SELECT id, SBQQ__ProductName__c, SBQQ__Quote__c, (SELECT Id FROM Quote_Orders1__r WHERE Service_Type__c = 'Delivery') FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: qIdSet AND SBQQ__Quote__r.Quote_Only__c = FALSE AND SBQQ__ProductName__c = 'Delivery']){
            if(!(qLine.Quote_Orders1__r.size()>0)){
                qLineWithOutqOrderSet.add(qLine.Id);
            }
            if(qIdQlineListMap.containsKey(qLine.SBQQ__Quote__c)){
                qIdQlineListMap.get(qLine.SBQQ__Quote__c).add(qLine);
            }else{
                qIdQlineListMap.put(qLine.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>{qLine});
            }
        }
        for(SBQQ__Quote__c quote: triggerNew){
            if(qIdSet.contains(quote.Id) && qIdQlineListMap.containsKey(quote.id)){
                for(SBQQ__QuoteLine__c qLine: qIdQlineListMap.get(quote.id)){
                    if(qLineWithOutqOrderSet.contains(qLine.Id)){
                        quote.addError(errMsg);
                    }
                }
            }
        }
    }
}
}