//TCS-pkulkarn
//Date : 12-Jul-2024
//Purpose: To collate the functionality related to End Date validation or related processes
//Test classes covering the code: <List here>

public class EndDateHandler 
{
    public static String strForQuote = ' For Quote ';
    public static Set<String> endDateUpdateExcludedProducts = new Set<String>{Constant_Util.REMOVAL, Constant_Util.ServiceType_Delivery, Constant_Util.SWAPOUT_PRODUCT};
        
    public static String validateEndDateOnCommercialTemporaryContainers(List<SBQQ__QuoteLine__c> quoteLines)
    {
        //Caller: QouteValiationHandler.vSStage
        //Caller: QouteValiationHandler.approvedStage
        //Test class/method for coverage: 
        //SDT-40056- For a Commercial/Rolloff container with WM Vendor, Temporary/Permanent duration and a Core Service, when End Date is being added
        //check that DoNotCreateMASTicket__c or MASRemoval__c is set to TRUE before integration to avoid integration error. Show error message otherwise.
        
        String errorMessage = 'SUCCESS';
        //Check the Product Family, Duration and Vendor for the Core Service
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            String vendorId = quoteLine.Vendor__r.Parent_Vendor_ID__c;

            if(quoteLine.SBQQ__Quote__r.SBQQ__Type__c != Constant_Util.QUOTE &&
               (quoteLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL || quoteLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) &&
               (quoteLine.SBQQ__RequiredBy__r.Duration__c == Constant_Util.TEMP || quoteLine.SBQQ__RequiredBy__r.Duration__c == Constant_Util.PERM) &&
               (vendorId == Constant_Util.WM_US_VENDOR || vendorId == Constant_Util.WM_CANADA_VENDOR) &&
               quoteLine.SBQQ__EndDate__c != null &&
               quoteLine.AssetId__c != null &&
               quoteLine.AssetId__r.End_Date__c == null
              )
            {
                //Check for DoNotCreateMASTickets flag
                if(quoteLine.DoNotCreateMASTicket__c == false && quoteLine.MASRemoval__c == false)
                {
                    if(errorMessage == 'SUCCESS')
                    {
                        errorMessage = quoteLine.SBQQ__Product__r.Name + ' ' + System.Label.ValidationErrorEndDateOnCommercialTemporaryContainers + strForQuote + quoteLine.SBQQ__Quote__r.Name;
                    }
                    else
                    {
                        errorMessage = errorMessage + quoteLine.SBQQ__Product__r.Name + ' ' + System.Label.ValidationErrorEndDateOnCommercialTemporaryContainers + strForQuote + quoteLine.SBQQ__Quote__r.Name;
                    }
                }
            }
        }
        return errorMessage;
    }

    public static void updateEndDatesOnQuoteLines(List<SBQQ__QuoteLine__c> quoteLines, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap, Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap)
    {
        //TCS-pkulkarn-SDT-41184-Added to update child/related quote lines with End Date when Bundle or Pickup is updated with End Date
        //Caller: QuoteLineTriggerHandler.onBeforeUpdate()
        if(System.Label.EndDateUpdateOnChildQuoteLinesFlag == 'N')
        {
            return;
        }
        Set<String> quoteTypes = new Set<String>{Constant_Util.QUOTE_TYPE_AMEND, Constant_Util.QUOTE_TYPE_CORRECTION, Constant_Util.QUOTE_TYPE_EXCEPTION};
        Set<Id> pickupAndBundleIds = new Set<Id>();
        Set<Id> pickupIds = new Set<Id>();
        Set<Id> bundleIds = new Set<Id>();
        Map<Id, Date> pickupUpdatedDateMap = new Map<Id, Date>();
        Map<Id, Date> bundleUpdatedDateMap = new Map<Id, Date>();
        List<SBQQ__QuoteLine__c> quoteLinesForUpdate = new List<SBQQ__QuoteLine__c>();
        
        List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
        
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.SBQQ__ProductName__c == Constant_Util.PR_PICKUP && oldQuoteLineMap.get(quoteLine.Id).SBQQ__EndDate__c != newQuoteLineMap.get(quoteLine.Id).SBQQ__EndDate__c)
            {
                pickupIds.add(quoteLine.SBQQ__RequiredBy__c);
                pickupUpdatedDateMap.put(quoteLine.SBQQ__RequiredBy__c, quoteLine.SBQQ__EndDate__c);
            }
            if(quoteLine.SBQQ__RequiredBy__c == null && oldQuoteLineMap.get(quoteLine.Id).SBQQ__EndDate__c != newQuoteLineMap.get(quoteLine.Id).SBQQ__EndDate__c)
            {
                bundleIds.add(quoteLine.Id);
                bundleUpdatedDateMap.put(quoteLine.Id, quoteLine.SBQQ__EndDate__c);
            }
            
        }
        
        if(bundleIds.size() > 0)
        {
            //When Bundle is updated
            quoteLinesList = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__ProductName__c, SBQQ__EndDate__c 
                              FROM SBQQ__QuoteLine__c 
                              WHERE SBQQ__Quote__r.SBQQ__Type__c IN :quoteTypes AND (SBQQ__RequiredBy__c IN :bundleIds OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c IN :bundleIds)
                             ];
            for(SBQQ__QuoteLine__c quoteLine : quoteLinesList)
            {
                //Check for Child Quote Lines
                if(bundleUpdatedDateMap.containsKey(quoteLine.SBQQ__RequiredBy__c) &&
                   quoteLine.SBQQ__EndDate__c != bundleUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__c) &&	//newQuoteLineMap.get(quoteLine.SBQQ__RequiredBy__c).SBQQ__EndDate__c &&
                   endDateUpdateExcludedProducts.contains(quoteLine.SBQQ__ProductName__c) == false
                  )
                {
                    quoteLine.SBQQ__EndDate__c = bundleUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__c);	//newQuoteLineMap.get(quoteLine.SBQQ__RequiredBy__c).SBQQ__EndDate__c;
                    quoteLinesForUpdate.add(quoteLine);
                }
                
                //Check for Grand Child Quote Lines
                if(bundleUpdatedDateMap.containsKey(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c) &&
                   quoteLine.SBQQ__EndDate__c != bundleUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c) &&
                   endDateUpdateExcludedProducts.contains(quoteLine.SBQQ__ProductName__c) == false
                  )
                {
                    quoteLine.SBQQ__EndDate__c = bundleUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                    quoteLinesForUpdate.add(quoteLine);
                }
                
            }
        }
        
        if(pickupIds.size() > 0)
        {
            //When Pickup is updated
            quoteLinesList = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__ProductName__c, SBQQ__EndDate__c 
                              FROM SBQQ__QuoteLine__c 
                              WHERE SBQQ__Quote__r.SBQQ__Type__c IN :quoteTypes AND
                              SBQQ__ProductName__c = :Constant_Util.PR_EXTRA_PICKUP AND
                              SBQQ__RequiredBy__c IN :pickupIds 
                             ];
            
            for(SBQQ__QuoteLine__c quoteLine : quoteLinesList)
            {
                //Check if Bundle is also updated
                if(pickupUpdatedDateMap.containsKey(quoteLine.SBQQ__RequiredBy__c) && 
                   bundleUpdatedDateMap.containsKey(quoteLine.SBQQ__RequiredBy__c) &&
                   pickupUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__c) != bundleUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__c)
                  )
                {
                    quoteLine.SBQQ__EndDate__c = pickupUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__c);
                    quoteLinesForUpdate.add(quoteLine);
                }
                else if(pickupUpdatedDateMap.containsKey(quoteLine.SBQQ__RequiredBy__c) &&
                        quoteLine.SBQQ__EndDate__c != pickupUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__c)
                       )
                {
                    quoteLine.SBQQ__EndDate__c = pickupUpdatedDateMap.get(quoteLine.SBQQ__RequiredBy__c);
                    quoteLinesForUpdate.add(quoteLine);
                }
            }
        }
        
        if(quoteLinesForUpdate.size() > 0 && RecurrsiveTriggerHandler.isSkipEndDateUpdate == false && Test.isRunningTest() == false)
        {
            RecurrsiveTriggerHandler.isSkipEndDateUpdate = true;
            UPDATE quoteLinesForUpdate;
        }
    }
    //TCS-Harun
    //Date : 18-10-2024
    //Purpose: on update the startdate in quoteline the enddate gets added by seven days which is required for Haul Away process
    public static void updateEndDatesOnQuoteLinesforHaulAway(List<SBQQ__QuoteLine__c> quoteLines, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap, Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap){
        Set<Id> quoteIds = new Set<Id>();
        
        //Method is not conditionally fired from the QuoteTriggerHandler resulting in numerous queries and occassional 100+ SOQL error
        //Injecting check logic before firing the additional queries to prevent test class compilation errors
        List<SBQQ__QuoteLine__c> haulAwayQuoteLines = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> haulAwayOldMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> haulAwayNewMap = new Map<Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            if (oldQuoteLineMap.get(ql.Id).SBQQ__StartDate__c != newQuoteLineMap.get(ql.Id).SBQQ__StartDate__c) {
                haulAwayQuoteLines.add(ql);
                haulAwayOldMap.put(ql.Id, oldQuoteLineMap.get(ql.Id));
                haulAwayNewMap.put(ql.Id, newQuoteLineMap.get(ql.Id));
            }
        }
        
        if (haulAwayQuoteLines.isEmpty() || haulAwayOldMap.isEmpty() || haulAwayNewMap.isEmpty()) return;
        
        for(SBQQ__QuoteLine__c ql :quoteLines){
            if(ql.SBQQ__Quote__c != null){
                quoteIds.add(ql.SBQQ__Quote__c);
            }
        }
        List<SBQQ__Quote__c> queriedQuotes = [SELECT Id,SBQQ__Opportunity2__r.Case__r.Id,SBQQ__Opportunity2__r.Case__r.Haul_Away_information__c,SBQQ__Opportunity2__r.Case__r.Is_Haul_Away_Service__c,SBQQ__Opportunity2__r.Case__r.Haul_Away_Vendor__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds];

        Map<Id,Boolean> haulAwayServiceMap = HaulAwayService.getIsHaulAwayServiceforQuote(queriedQuotes);
        
        for(SBQQ__QuoteLine__c ql :quoteLines){
            if(haulAwayServiceMap.containsKey(ql.SBQQ__Quote__c)){
                Boolean hasHaulAwayService = haulAwayServiceMap.get(ql.SBQQ__Quote__c);

                if(hasHaulAwayService){
                    SBQQ__QuoteLine__c oldQuoteLineRecord = oldQuoteLineMap.get(ql.Id);
                    SBQQ__QuoteLine__c newQuoteLineRecord = newQuoteLineMap.get(ql.Id);
                if(oldQuoteLineRecord.SBQQ__StartDate__c != newQuoteLineRecord.SBQQ__StartDate__c)
                {
                    newQuoteLineRecord.SBQQ__EndDate__c = newQuoteLineRecord.SBQQ__StartDate__c.addDays(7);
                }
                }
            }
        }

    }
}
