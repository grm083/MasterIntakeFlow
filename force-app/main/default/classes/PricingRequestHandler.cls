public class PricingRequestHandler {
	
    public static void onAfterUpdate(List<Pricing_Request__c > PricingReqList, Map<Id,Pricing_Request__c> oldMap, Map<Id,Pricing_Request__c> newMap){
        
        //ProcessQLIPricingRequest.ParsePricingRequestJSON(PricingReqList,oldMap,newMap);
    }

    public static void onAfterInsert(List<Pricing_Request__c > newPricingReqList, Map<Id,Pricing_Request__c> newPricingReqMap){
        System.debug('In pricingrequest onAfterInsert ---');
       PricingRequestHelper.getPricingRequestId(newPricingReqList,newPricingReqMap,true);
    }

}