public class PricingRequestHelper {
    
    public static Map<Id, String> assetPricingResponse = new Map<Id, String>();
    public static Map<Id, String> assetPricingChangeResponse = new Map<Id, String>();

    public static void getPricingRequestId(List<Pricing_Request__c > newRequestList, Map<Id,Pricing_Request__c> newRequestMap, Boolean isInsert){
        system.debug('PricingRequestHelper GetPricingRequestId--->');
        Set<Id> pricingReqIdSet = new Set<Id>();
        Set<Id> pricingChangeReqIdSet = new Set<Id>();
        Id quote ;
        // Added for SDT-29849
        Map<Id, Id> pricingQuoteMap = new Map<Id,Id>();

        for (Pricing_Request__c req : newRequestList)
        {
            if(!req.IsCaseError__c)
            {
                //system.debug('---->>>>req.IsPriceChangeRequest__c: ' + req.IsPriceChangeRequest__c);
                if(!req.IsPriceChangeRequest__c)
                {
                    pricingReqIdSet.add(req.id); // AM - New Service Price Call
                }
                else
                {
                    //SDT-27722
                    pricingChangeReqIdSet.add(req.id); // AM - Update Asset Price Call
                }
                
                // Added for SDT-29849
                pricingQuoteMap.put(req.id, req.Quote__c);
                
            }
            quote = req.Quote__c;
        }
        
        if(pricingReqIdSet != null && pricingReqIdSet.size() > 0){
            // Added for SDT-29849
            callPricingIntegration(pricingReqIdSet, pricingQuoteMap); 
            // PricingRequestSTPQueueable prSTPQueueJob = new PricingRequestSTPQueueable(pricingReqIdSet);
            // System.enqueueJob(prSTPQueueJob);
        }
        
        else if(pricingChangeReqIdSet != null && pricingChangeReqIdSet.size() > 0)
        {
            //SDT-27722 and sdt-29849
            callPricingChangeIntegration(pricingChangeReqIdSet, pricingQuoteMap);
        }
        else{
            if(PricingRequestSelector.isPricingMulltiVendorAMSwitchON())
            {
                //sdt-29849
                PricingRequestSTPProcess.processPricingRequest(quote, True);
            }
        }
    }
    
    @future(callout=true)
    public static void callPricingIntegration (Set<id> PricingReqIdSet, Map<Id, Id> pricingQuoteMap) // Added for SDT-29849
    {
        //system.debug('pricingQuoteMap--->'+ pricingQuoteMap);
        // Added for SDT-29849
        Set<Id> quoteIds = new Set<Id>();

        // Added for SDT-29849
        List<Pricing_Request__c> prList = new List<Pricing_Request__c>();
        for (Id requestId : PricingReqIdSet)
        {
            if(PricingRequestSelector.isPricingMulltiVendorAMSwitchON())
            {
                system.debug('In isPricingMulltiVendorAMSwitchON');
                //system.debug('requestId--->' +requestId);
                PricingRequestAPIIntegration.getPricingDetail(requestId, true);
                
                // Added for SDT-29849
                if(assetPricingResponse != null && assetPricingResponse.size() > 0)
                {
                    Pricing_Request__c pReqt = new Pricing_Request__c();
                    pReqt.Id = requestId;
                    pReqt.APIRequestOutput__c = assetPricingResponse.get(requestId);
                    PricingRequestAPIIntegration.savePricingData(pReqt, assetPricingResponse.get(requestId));
                    pReqt.Quote__c =  pricingQuoteMap.get(requestId);
                    prList.add(pReqt);

                    //Adding Quotes
                    if(pReqt.Quote__c != null)
                    {
                        quoteIds.add(pReqt.Quote__c);
                    }
                }
            }
            else //Old Pricing Fuctionality
            {
                //system.debug('requestId--->' +requestId);
                PricingRequest.getPricingDetail(requestId, true);
                
                // Added for SDT-29849
                if(assetPricingResponse != null && assetPricingResponse.size() > 0)
                {
                    Pricing_Request__c pReqt = new Pricing_Request__c();
                    pReqt.Id = requestId;
                    pReqt.APIRequestOutput__c = assetPricingResponse.get(requestId);
                    PricingRequest.saveReportingFields(pReqt, assetPricingResponse.get(requestId));
                    pReqt.Quote__c =  pricingQuoteMap.get(requestId);
                    prList.add(pReqt);

                    //Adding Quotes
                    if(pReqt.Quote__c != null)
                    {
                        quoteIds.add(pReqt.Quote__c);
                    }
                }
            }            
        }

        //Comment Below code, as now we do not need update trigger on price record
        if(prList != null && prList.size() > 0)
        {
            update prList;
            system.debug('@@@@@@@@~ After Pricing Update - New Service');

            //Added for SDT-29849, for all quotes priceOnlyCall is false
            PlatformEventProcessor.RaiseSTPProcessEventPE(quoteIds, false);  
            //PricingRequestMultiVendorSTPProcess.processMultiVendorPricingRequest(quoteIds, true);          
        }
    }
       
    @future(callout=true)
    public static void callPricingChangeIntegration (Set<id> PricingChangeReqIdSet, Map<Id, Id> pricingQuoteMap)
    {
        Set<Id> quoteIds = new Set<Id>();
        //system.debug('PricingChangeReqIdSet--->'+ PricingChangeReqIdSet);
        for (Id requestId : PricingChangeReqIdSet)
        {
            //system.debug('requestId--->' + requestId);
			PricingChangeRequest.getPricingChangeDetail(requestId, true);
        }

        if(assetPricingChangeResponse != null && assetPricingChangeResponse.size() > 0){
            List<Pricing_Request__c> prList = new List<Pricing_Request__c>();
            for(Id pId : assetPricingChangeResponse.keySet()){
                Pricing_Request__c pReqt = new Pricing_Request__c();

                pReqt.Id = pId;
                // system.debug('listOfStatus--->' +assetPricingResponse.get(pId));

                pReqt.APIRequestOutput__c = assetPricingChangeResponse.get(pId);
                PricingRequest.saveReportingFields(pReqt, assetPricingChangeResponse.get(pId));
                pReqt.Quote__c =  pricingQuoteMap.get(pId);
                prList.add(pReqt);
                //Adding Quotes
                if(pReqt.Quote__c != null)
                {
                    quoteIds.add(pReqt.Quote__c);
                }
            }
            if(prList != null && prList.size() > 0)
            {
                update prList;
                //system.debug('@@@@@@@@~ After Pricing Update - Update Asset');
                PlatformEventProcessor.RaiseSTPProcessEventPE(quoteIds, false);
            }
        }
    }

    
}