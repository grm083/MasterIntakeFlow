/**
* @description       : To process the quotelines that are under the quotes received and set the VCRCode__c value to default based on the 
*                       story SDT 31118
* @author            : TCS
* @group             : 
* @last modified on  : 23-09-2023
**/
public without sharing class VCRCodeController {
    //TCS-pkulkarn-SDT-38847-17-Apr-2024-Added new variables to store existing VCR code for haul/pickup
    public static Map<Id, String> existingVCRCodes = new Map<Id, String>();	//New variable to store the Agent provided VCR Code (per Bundle)
    //TCS-pkulkarn-SDT-38847-End
    
    
    /*
* @Method Name    : setVCRCodeForBundle
* @author         : TCS
* @story          : SDT 31118
* @description    : This method will update the quotelines with the VCRCode__c 
*/
    public static void setVCRCodeForBundle(Set<Id> filteredQuoteIdsSet) {
        
        //map to store the parentquoteline Id with the corresponding VCR code to be updated in the bundle
        Map<Id, String> parentQlIdVCRcodeMap = new Map<Id, String>();
        //List to store the quotelines that are to be updated with the VCR code 
        List<SBQQ__QuoteLine__c> toBeUpdatedQlList = new List<SBQQ__QuoteLine__c>();
        //map to store parent quotelineid and core service quotelines that are pickup or haul - calculation of V and R of QuoteLine
        Map<Id, List<SBQQ__QuoteLine__c>> parentQlIdEligibleQlsMap = new Map<Id, List<SBQQ__QuoteLine__C>>();   
        //map to store parent quotelineid and core service assets that are pickup or haul - calculation of V and R of Asset
        Map<Id, Map<Id, List<String>>> parentQlIdEligibleAssetsMap = new Map<Id, Map<Id, List<String>>>();  
        //set to store parent quoteline Ids of bundles that needs processing
        Set<Id> toBeCalculatedParentQlIdSet = new Set<Id>();
        //set to store parent quoteline Ids of bundles whose VCR is to be set to 'MSC'
        Set<Id> miscellParentQlIdSet = new Set<Id>();
        //set to store parent quoteline Ids of bundles whose VCR is to be set to NULL
        Set<Id> nullVCRParentQlIdSet = new Set<Id>();
        //Map to store parent Ql Id and count of child qls that are pickup or haul
        Map<Id, Integer> parentQLIdCountOfHaulOrPickupQls = new Map<Id, Integer>();
        //Set to store parent Ql Id and count of assets that are pickup or haul
        Map<Id, Integer> parentQLIdCountOfHaulOrPickupAssets = new Map<Id, Integer>();
        //map to keep the values of V, R and U with parent quotelineid
        Map<Id, Map<String, Decimal>> qlIdQuoteLineValuesMap = new Map<Id, Map<String, Decimal>>();
        //Set to keep the parent quoteline ids that have a regular monthly income - ie; the ones that needs processing
        Set<Id> toBeComparedAndUpdated = new Set<Id>();
        //list to store the quotelines that needs to be updated.
        List<SBQQ__QuoteLine__c> updatingQlList = new List<SBQQ__QuoteLine__c>();
        
        //this set contains the Cost_Unit_of_Measure__c values that are valid - have irregular monthly revenue
        Set<String> standardCostUOMSet = new Set<String>{'DYS', 'MTH', 'YRS', 'Days', 'Months', 'Years'};
            //this set stores the standard UOM
            Set<String> standardUOMSet = new Set<String>{'GALS', 'YRDS', 'FEET', 'Gallons', 'Yards', 'Feet'};
                
                
                
                //querying all the quotelines associated with the quote records
                //TCS-pkulkarn-SDT-38847-17-Apr-2024-Added VCR Code to field list in the SOQL
                //Changes related to SDT-42214 - adding BypassPriceReview__c and ByPassMASServiceChange__c and DoNotCreateTaskGridTickets__c in the query
                List<SBQQ__QuoteLine__c> associatedQuoteLinesList = [Select Id, SBQQ__RequiredBy__c, Core_Service__c, Equipment_Size__c, Occurrence_Type__c,
                                                                     Schedule_Frequency__c,Frequency_Interval__c, Service_Days__c, SBQQ__Quantity__c, SBQQ__Quote__c,
                                                                     AssetId__r.CPQ_Product__r.Name, AssetId__r.Is_Core_Service__c, AssetId__r.Frequency__c,
                                                                     AssetId__r.Equipment_Size__c, AssetId__r.Occurs__c, AssetId__r.Occurrence_Type__c,
                                                                     AssetId__r.Quantity__c, SBQQ__ProductName__c, AssetId__r.SBQQ__OriginalUnitCost__c,
                                                                     SBQQ__RequiredBy__r.SBQQ__Quantity__c, AssetId__r.Weekly_Frequency__c, Cost_Unit_of_Measure__c, 
                                                                     AssetId__r.Cost_Unit__c, SBQQ__UnitCost__c, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,
                                                                     Vendor__r.Parent_Vendor_ID__c, SBQQ__RequiredBy__r.Vendor__r.Parent_Vendor_ID__c,
                                                                     SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.Vendor__r.Parent_Vendor_ID__c, VCRCode__c,BypassPriceReview__c,
                                                                     ByPassMASServiceChange__c,DoNotCreateTaskGridTickets__c
                                                                     FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: filteredQuoteIdsSet];
        
        
        //iterating through the associatedQuoteLinesList and adding values to the above maps
        for(SBQQ__QuoteLine__c currentQuoteLine : associatedQuoteLinesList) {
            //getting parent vendor id
            String parentVendorId = (currentQuoteLine.SBQQ__RequiredBy__c == NULL) ? currentQuoteLine.Vendor__r.Parent_Vendor_ID__c :
            						(currentQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == NULL) ? currentQuoteLine.SBQQ__RequiredBy__r.Vendor__r.Parent_Vendor_ID__c :
            						currentQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__r.Vendor__r.Parent_Vendor_ID__c;

            //filtering and taking only WM us and canada parent vendors
            if(parentVendorId == Constant_Util.WM_CANADA_VENDOR || parentVendorId == Constant_Util.WM_US_VENDOR) {
            //for QuoteLines
            //fitering and taking the necessary quotelines - pickup or haul that are Scheduled type and core service
            if((currentQuoteLine.SBQQ__ProductName__c == PICKUP_PRODUCT || currentQuoteLine.SBQQ__ProductName__c == HAUL_PRODUCT)) {
                //if the current qls parent is already present in the map, increase its value by 1
                if(parentQLIdCountOfHaulOrPickupQls.keySet().contains(currentQuoteLine.SBQQ__RequiredBy__c)){
                    parentQLIdCountOfHaulOrPickupQls.put(currentQuoteLine.SBQQ__RequiredBy__c, 
                                                         parentQLIdCountOfHaulOrPickupQls.get(currentQuoteLine.SBQQ__RequiredBy__c) + 1);
                }
                //else add it as a new key
                else {
                    parentQLIdCountOfHaulOrPickupQls.put(currentQuoteLine.SBQQ__RequiredBy__c, 1);
                }
                
                //creating the map with parent qlid and eligible quoteline for calculation
                //TCS-pkulkarn-SDT-38847-29-Apr-2024-Added following variable and updated if condition
                String sQuoteLineOccurrenceType = currentQuoteLine.Occurrence_Type__c;
                if(sQuoteLineOccurrenceType == SCH && currentQuoteLine.Core_Service__c == TRUE) {
                    //if the current QuoteLine's parent ql Id already exists in the parentQlIdEligibleQlsMap, then the current quoteline 
                    //should be added under this key in the map
                    if(parentQlIdEligibleQlsMap.containsKey(currentQuoteLine.SBQQ__RequiredBy__c)) {
                        List<SBQQ__QuoteLine__c> childCoreQls = parentQlIdEligibleQlsMap.get(currentQuoteLine.SBQQ__RequiredBy__c);
                        childCoreQls.add(currentQuoteLine);
                        parentQlIdEligibleQlsMap.put(currentQuoteLine.SBQQ__RequiredBy__c, childCoreQls);
                    }
                    //else, adding the current Quoteline's parent ql Id as a new key and the current quoteline as it's value
                    else {
                        parentQlIdEligibleQlsMap.put(currentQuoteLine.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>{currentQuoteLine});
                    }
                    
                }
				//added as part of sdt 32850
				//haul or pickup with not scheduled or coreservice true
				else {
					miscellParentQlIdSet.add(currentQuoteLine.SBQQ__RequiredBy__c);
				}
            }
            
            //for Assets
            //fitering and taking the necessary Assets - pickup or haul core service assets that are scheduled
            if((currentQuoteLine.AssetId__r.CPQ_Product__r.Name == PICKUP_PRODUCT || currentQuoteLine.AssetId__r.CPQ_Product__r.Name == HAUL_PRODUCT)){
                //if the current qls parent is already present in the map, increase its value by 1
                if(parentQLIdCountOfHaulOrPickupAssets.keySet().contains(currentQuoteLine.SBQQ__RequiredBy__c)){
                    parentQLIdCountOfHaulOrPickupAssets.put(currentQuoteLine.SBQQ__RequiredBy__c, 
                                                            parentQLIdCountOfHaulOrPickupAssets.get(currentQuoteLine.SBQQ__RequiredBy__c) + 1);
                }
                //else add it as a new key and set value to 1
                else {
                    parentQLIdCountOfHaulOrPickupAssets.put(currentQuoteLine.SBQQ__RequiredBy__c, 1);
                }
                //TCS-pkulkarn-SDT-38847-29-Apr-2024-Added following variable and updated if condition
                String sAssetOccurrenceType = currentQuoteLine.AssetId__r.Occurrence_Type__c;
                if(currentQuoteLine.AssetId__r.Is_Core_Service__c == TRUE && sAssetOccurrenceType == SCHEDULED) {
                    //if the current Asset's quoteline's parent ql Id already exists in the parentQlIdcoreServiceAssetMap, then the current  
                    //assetID and its values should be added under this key in the map
                    if(parentQlIdEligibleAssetsMap.containsKey(currentQuoteLine.SBQQ__RequiredBy__c)) {
                        //map to store assetId with asset values as a list of string(equipment size, frequency, frequency interval,
                        //service days and quantity - in this order)
                        Map<Id, List<String>> qlIdValuesMap = parentQlIdEligibleAssetsMap.get(currentQuoteLine.SBQQ__RequiredBy__c);
                        
                        qlIdValuesMap.put(currentQuoteLine.AssetId__c, new List<String>{currentQuoteLine.AssetId__r.Equipment_Size__c,
                            currentQuoteLine.AssetId__r.Frequency__c,
                            currentQuoteLine.AssetId__r.Occurs__c,
                            currentQuoteLine.AssetId__r.Weekly_Frequency__c,
                            String.valueOf(currentQuoteLine.AssetId__r.Quantity__c),
                            currentQuoteLine.AssetId__r.Cost_Unit__c,
                            String.valueOf(currentQuoteLine.AssetId__r.SBQQ__OriginalUnitCost__c)});
                        parentQlIdEligibleAssetsMap.put(currentQuoteLine.SBQQ__RequiredBy__c, qlIdValuesMap);
                    }
                    
                    //else, adding the current Assets's quoteline's parent ql Id as a new key and the current asset as it's values as the value - 
                    //order for list<string> should be maintained as above
                    else {
                        parentQlIdEligibleAssetsMap.put(currentQuoteLine.SBQQ__RequiredBy__c, new Map<Id, List<String>>{
                            currentQuoteLine.AssetId__c => new List<String>{currentQuoteLine.AssetId__r.Equipment_Size__c, 
                                currentQuoteLine.AssetId__r.Frequency__c,
                                currentQuoteLine.AssetId__r.Occurs__c,
                                currentQuoteLine.AssetId__r.Weekly_Frequency__c,
                                String.valueOf(currentQuoteLine.AssetId__r.Quantity__c),
                                currentQuoteLine.AssetId__r.Cost_Unit__c,
                                String.valueOf(currentQuoteLine.AssetId__r.SBQQ__OriginalUnitCost__c)}});
                    }
                }
				//added as part of sdt 32850
				//haul or pickup with not scheduled or coreservice true
				else {
					miscellParentQlIdSet.add(currentQuoteLine.SBQQ__RequiredBy__c);
				}
				
            }
            }
        }
        
        
        
        //iterating through the parentQlIdEligibleQlsMap.keySet() and seperating the parent Ql Ids of the bundles that needs 
        //processing to find VCR, the ones that needs it VCR to be set to 'MSC' and the ones that needs VCR to be set to NULL.
        for(Id currentQlId : parentQlIdEligibleQlsMap.keySet()) {
            //if the parent QlId is present in both the maps. ie; there is enough data to do processing
            if(parentQlIdEligibleAssetsMap.keySet().contains(currentQlId)) {
                //checking there is multiple quotelines or assets in a bundle that are haul or pickup 
                if((parentQLIdCountOfHaulOrPickupQls.get(currentQlId) > 1) 
                   || (parentQLIdCountOfHaulOrPickupAssets.get(currentQlId) > 1)) {
                       //set vcr code to null 
                       nullVCRParentQlIdSet.add(currentQlId); 
                   }
                //if there isnt multiple quotelines or assets in a bundle that satisfy the same 
                else {
                    toBeCalculatedParentQlIdSet.add(currentQlId);              
                }
            }
            //if parent QlId is not present in both the maps. ie; there is not enough data to do processing
            else {
                //checking there is multiple quotelines or assets in a bundle that are haul or pickup
                if((parentQLIdCountOfHaulOrPickupQls.get(currentQlId) > 1) 
                   || (parentQLIdCountOfHaulOrPickupAssets.get(currentQlId) > 1)) {
                       //set vcr code to null 
                       nullVCRParentQlIdSet.add(currentQlId);
                   }
                //if there isnt multiple quotelines or assets in a bundle that satisfy the same 
                else {
                    //set vcr code to 'MSC' 
                    miscellParentQlIdSet.add(currentQlId);                 
                }
            }
        }
        
        
        
        //adding the Ids of parent Qls in another set. This set will be used for iteration for quoteline values calculation 
        toBeComparedAndUpdated.addAll(toBeCalculatedParentQlIdSet);

        //TCS-pkulkarn-SDT-38847-17-Apr-2024-Retrieve VCR Code from the Quote Lines
        checkAndRetrieveAgentUpdatedVCRCodes(associatedQuoteLinesList);
        //TCS-pkulkarn-SDT-38847-17-Apr-2024-End        
        
        /**** calculation and comparison starts here ****/
        
        //Map to store the parent quoteline ID and value relations
        Map<Id, List<String>> parentQlIdValuesListMap = new Map<Id, List<String>>();
        
        //iterating through the toBeCalculatedParentQlIdSet for calculation
        for(Id currentParentQlId : toBeCalculatedParentQlIdSet) {
            //declaring variables to store the relationship between quote and asset values
            String yardageImpact;
            String revenueImpact;
            String monthlyPerUnitRevenue;

            //TCS-pkulkarn-SDT-38847-17-Apr-2024-Check if there is an existing VCR Code for the given bundle
            //Add the VCR Code in the Map, parentQlIdVCRcodeMap, used for final update on Quote Lines
            //Remove the Bundle Id from toBeComparedAndUpdated to bypass calculation of VCR Code for the bundle
            if(existingVCRCodes.containsKey(currentParentQlId))
            {
            	parentQlIdVCRcodeMap.put(currentParentQlId, existingVCRCodes.get(currentParentQlId));
            	toBeComparedAndUpdated.remove(currentParentQlId);
        	}
            //TCS-pkulkarn-SDT-38847-17-Apr-2024-Added else for the remaining code block-to continue calculation of VCR Code
            else
            {
                //filtering and taking only the ones that have regular revenue and have a frequency interval
                if(((parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Cost_Unit_of_Measure__c != NULL) 
                    && (standardCostUOMSet.contains(parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Cost_Unit_of_Measure__c))
                    && (parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Frequency_Interval__c != NULL)
                    && (Decimal.valueOf(parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Frequency_Interval__c) != 0)
                    && (standardUOMSet.contains(((parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Equipment_Size__c).split('-'))[0]))
                    && (parentQlIdEligibleQlsMap.get(currentParentQlId)[0].SBQQ__UnitCost__c != NULL)
                    && (parentQlIdEligibleQlsMap.get(currentParentQlId)[0].SBQQ__Quantity__c != NULL))
                    && ((parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][0] != NULL)
                    && (parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][5] != NULL)
                    && (standardCostUOMSet.contains(parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][5]))
                    && (standardUOMSet.contains(((parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][0]).split(' '))[1]))
                    && (parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][6] != NULL)
                    && (parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][2] != NULL)
                    && (parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][4] != NULL)))
                {
                    
                    //QUOTELINE
                    //map to keep the values of V, R and U with its name
                    Map<String, Decimal> calculatedValuesMap = new Map<String, Decimal>();
                    
                    //calling calculateVol() method to calculate the V value for quoteLine.
                    Decimal quoteVol = calculateVol(parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Equipment_Size__c, 
                                                    parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Schedule_Frequency__c, 
                                                    parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Frequency_Interval__c, 
                                                    parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Service_Days__c, 
                                                    String.valueOf(parentQlIdEligibleQlsMap.get(currentParentQlId)[0].SBQQ__Quantity__c),
                                                    SOBJ_QUOTELINE);
                    
                    
                    //getting the U of the quoteline
                    Decimal quoteRevPerServPerMonth = parentQlIdEligibleQlsMap.get(currentParentQlId)[0].SBQQ__UnitCost__c;
                    
                    //calling caculateMonthlyRevOfAllScheduledServices() method to calculate the R value for quoteLine 
                    Decimal quoteRevOfAllServ = calculateMonthlyRevOfAllScheduledServices(quoteRevPerServPerMonth, parentQlIdEligibleQlsMap.get(currentParentQlId)[0].Cost_Unit_of_Measure__c,
                                                                                        Integer.valueOf(parentQlIdEligibleQlsMap.get(currentParentQlId)[0].SBQQ__Quantity__c));
                    
                    
                    
                    //ASSET
                    //calling calculateVol() method to calculate the V value for asset.
                    Decimal assetVol = calculateVol(parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][0], 
                                                    parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][1], 
                                                    parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][2], 
                                                    parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][3], 
                                                    parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][4],
                                                    SOBJ_ASSET);
                    
                    
                    //getting U of the asset
                    Decimal assetRevPerServPerMonth = Decimal.valueOf(parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][6]);
                        
                    //calling caculateMonthlyRevOfAllScheduledServices() method to calculate the R value for asset 
                    Decimal assetRevOfAllServ = calculateMonthlyRevOfAllScheduledServices(assetRevPerServPerMonth, parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][5],
                                                                                        Integer.valueOf(parentQlIdEligibleAssetsMap.get(currentParentQlId).values()[0][4]));
                    
                    
                    //comparing and creating quoteline and asset values
                    //YARDAGE IMPACT RELATION
                    if(quoteVol > assetVol) {
                        yardageImpact = INCREASE;
                    }
                    else if(quoteVol < assetVol) {
                        yardageImpact = DECREASE;
                    }
                    else {
                        yardageImpact = NEUTRAL;
                    }
                    
                    //REVENUE IMPACT RELATION
                    if(quoteRevOfAllServ > assetRevOfAllServ) {
                        revenueImpact = INCREASE;
                    }
                    else if(quoteRevOfAllServ < assetRevOfAllServ) {
                        revenueImpact = DECREASE;
                    }
                    else {
                        revenueImpact = NEUTRAL;
                    }
                    
                    //MONTHLY PER UNIT REVENUE RELATION
                    if(quoteRevPerServPerMonth > assetRevPerServPerMonth) {
                        monthlyPerUnitRevenue = INCREASE;
                    }
                    else if(quoteRevPerServPerMonth < assetRevPerServPerMonth) {
                        monthlyPerUnitRevenue = DECREASE;
                    }
                    else {
                        monthlyPerUnitRevenue = NEUTRAL;
                    }
                    
                    //keeping the values in a map in order
                    parentQlIdValuesListMap.put(currentParentQlId, new List<String>{yardageImpact, revenueImpact, monthlyPerUnitRevenue});
                    
                }
                
                //if the income is irregular or frequency interval is null or 0, set the VCR code to 'MSC' 
                else {
                    //add the parent QlId to miscellParentQlIdSet
                    miscellParentQlIdSet.add(currentParentQlId);
                    
                    //removing the parent ql id from the toBeComparedAndUpdated
                    toBeComparedAndUpdated.remove(currentParentQlId);
                }
            }
            
        }
        
        /**** calculation and comparison ends here ****/
        
        
        //iterating to compare and update VCR code to quotelines
        for(Id currentParentQlId : toBeComparedAndUpdated) {
            //querying metadata as per the values
            VCR_Code_Mapping__mdt mtData = new VCR_Code_Mapping__mdt();
            mtData = [SELECT Id, Yardage_Impact__c, Revenue_Impact__c, Monthly_Per_Unit_Revenue__c, VCR_Code__c FROM VCR_Code_Mapping__mdt 
                      WHERE Yardage_Impact__c =: parentQlIdValuesListMap.get(currentParentQlId)[0] AND 
                      Revenue_Impact__c =: parentQlIdValuesListMap.get(currentParentQlId)[1] AND
                      Monthly_Per_Unit_Revenue__c =: parentQlIdValuesListMap.get(currentParentQlId)[2] LIMIT 1];
            
            //keeping parent qlId along with its VCR code in the map
            parentQlIdVCRcodeMap.put(currentParentQlId, mtData.VCR_Code__c);
            
        }
        
        
        
        //iterating through the eligible quotelines list and setting the VCR Code accordingly
        for(SBQQ__QuoteLine__c  currentQuoteLine : associatedQuoteLinesList) {
            
            //if the parent is present in the map that contains the calculated VCR
            if((parentQlIdVCRcodeMap.keySet().contains(currentQuoteLine.Id)) || (parentQlIdVCRcodeMap.keySet().contains(currentQuoteLine.SBQQ__RequiredBy__c))
               || (parentQlIdVCRcodeMap.keySet().contains(currentQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c))) 
               {
                   //checking if the current quoteline is the child of child
                   if(currentQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c != NULL){
                       currentQuoteLine.VCRCode__c = parentQlIdVCRcodeMap.get(currentQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                   }
                   else {
                       //taking the id of the parent if the current quoteline is a child or taking the id if it is a parent
                       Id parentOrChildId = currentQuoteLine.SBQQ__RequiredBy__c == NULL ? currentQuoteLine.Id : currentQuoteLine.SBQQ__RequiredBy__c;
                       currentQuoteLine.VCRCode__c = parentQlIdVCRcodeMap.get(parentOrChildId);
                   }
                
                //Changes related to SDT-42214
                if(currentQuoteLine.VCRCode__c == Constant_Util.VCR_CODE_BSI ||currentQuoteLine.VCRCode__c == Constant_Util.VCR_CODE_BSD){
                    if(currentQuoteLine.BypassPriceReview__c) {
                        currentQuoteLine.BypassPriceReview__c = false;
                    }
                    currentQuoteLine.DoNotCreateTaskGridTickets__c = true;
                    currentQuoteLIne.ByPassMASServiceChange__c = true;

                }

                   //adding the quoteline to the list to be updated
                   updatingQlList.add(currentQuoteLine);
               }
            
            //else if the VCR is to be set to 'MSC'
            else if((miscellParentQlIdSet.contains(currentQuoteLine.Id)) || (miscellParentQlIdSet.contains(currentQuoteLine.SBQQ__RequiredBy__c))
                    || (miscellParentQlIdSet.contains(currentQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c))) 
                    {

                        //TCS-pkulkarn-SDT-38847-29-Apr-2024-Added to check if Agent has updated the VCR Code and update the same on the Quote Lines
                        if(isVCRCodePresentForQuoteLine(currentQuoteLine))
                        {
                            currentQuoteLine.VCRCode__c = getVCRCodeForQuoteLine(currentQuoteLine);
                        }
                        //TCS-pkulkarn-SDT-38847-End
                        else
                        {
                            currentQuoteLine.VCRCode__c = VCR_MSC;
                        }
                
                //Changes related to SDT-42214
                if(currentQuoteLine.VCRCode__c == Constant_Util.VCR_CODE_BSI ||currentQuoteLine.VCRCode__c == Constant_Util.VCR_CODE_BSD){
                    if(currentQuoteLine.BypassPriceReview__c) {
                        currentQuoteLine.BypassPriceReview__c = false;
                    }
                    currentQuoteLine.DoNotCreateTaskGridTickets__c = true;
                    currentQuoteLIne.ByPassMASServiceChange__c = true;

                }
                
                        //adding the quoteline to the list to be updated
                        updatingQlList.add(currentQuoteLine);
                    }
            
            //else if the VCR is to be set to 'NULL'
            else if((nullVCRParentQlIdSet.contains(currentQuoteLine.Id)) || (nullVCRParentQlIdSet.contains(currentQuoteLine.SBQQ__RequiredBy__c))
                    || (nullVCRParentQlIdSet.contains(currentQuoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c))) 
                    {
                        //TCS-pkulkarn-SDT-38847-29-Apr-2024-Added to check if Agent has updated the VCR Code and update the same on the Quote Lines
                        if(isVCRCodePresentForQuoteLine(currentQuoteLine))
                        {
                            currentQuoteLine.VCRCode__c = getVCRCodeForQuoteLine(currentQuoteLine);
                        }
                        //TCS-pkulkarn-SDT-38847-End
                        else
                        {
                            currentQuoteLine.VCRCode__c = NULL;
                        }
                        //adding the quoteline to the list to be updated
                        updatingQlList.add(currentQuoteLine);
                    }
        }
        
        //making the boolean true to avoid recursion
        RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = TRUE;
        
        //updating the list
        update updatingQlList;
        
    } 
    

    
    /* this method calculates Cubic volume per month of waste service provided(V)
	 * it returns the value V as an integer
	 */
    public static Decimal calculateVol(String equipmentSize, String scheduleFrequency, String frequencyInterval, String serviceDays, String quantity, String sObj) {
        
        //decalring variables to store V, S and F
        Decimal V;
        Decimal S;
        Decimal F;
        
        
        //converting frequencyInterval to integer value
        Integer frequencyIntervalValue = Integer.valueOf(frequencyInterval);
        
        String uom;
        Double size;
        Decimal countOfServiceDays;
        
        //getting the UOM and size value from equipmentSize
        if(sObj == SOBJ_QUOTELINE) {
            List<String> parts = equipmentSize.split('-');
            uom = parts[0];
            size = Double.valueOf(parts[1]);
        }
        else if(sObj == SOBJ_ASSET) {
            List<String> parts = equipmentSize.split(' ');
            uom = parts[1];
            size = Double.valueOf(parts[0]);
        }
        
        
        //converting size value to gallons using volume modifiers to find S
        if(uom == 'GALS' || uom == 'Gallons') {
            S = size * 1;
        }
        else if(uom == 'YRDS' || uom =='Yards') {
            S = size * 202;
        }
        else if(uom == 'FEET' || uom == 'Feet') {
            S = size * 7.481;
        }
        
        
        //determining service type based on sceduleFrequency and calculating F
        if(frequencyIntervalValue != 0) {
            if(scheduleFrequency == 'D' || scheduleFrequency == 'Daily') {
                F = 30.5 / frequencyIntervalValue;
            }
            
            else if(scheduleFrequency == 'W' || scheduleFrequency == 'Weekly') {
                //getting count of service days from serviceDays
                if(sObj == SOBJ_QUOTELINE) {
                    List<String> values = serviceDays.split(';');
                    //SDT 40022
                    //countOfServiceDays = values.size();
                    //countOfServiceDays = values.size() / frequencyIntervalValue;
                    //SDT 40355
                    decimal serviceDaysSize = values.size();
                    countOfServiceDays = serviceDaysSize / frequencyIntervalValue;
                    
                }
                else if(sObj == SOBJ_ASSET) {
                    countOfServiceDays = Decimal.valueOf(serviceDays);   
                }
                F = countOfServiceDays / frequencyIntervalValue;
            }
            
            else if(scheduleFrequency == 'M' || scheduleFrequency == 'Monthly') {
                F = 1 / frequencyIntervalValue;
            }
            
            else if(scheduleFrequency == 'Y' || scheduleFrequency == 'Yearly') {
                F = (1/12) / frequencyIntervalValue;
            }
        }
        
        //calculating V
        V = S * F * Decimal.valueOf(quantity);
        
        
        return V;
        
    }
    
    /* this method calculates Monthly Revenue Of All Scheduled Services(R)
	 * it returns the value R as an integer
	 */
    public static Decimal calculateMonthlyRevOfAllScheduledServices(Decimal assetRevPerServPerMonth, String costUOM, Integer quantity) {
        
        //declaring variable to store R
        Decimal R;
        
        //determinig whether monthly, yearly or daily from costUOM and calculating R using the appropriate modifier
        if(costUOM == 'DYS' || costUOM == 'Days') {
            R = (assetRevPerServPerMonth * 30.44) * quantity;
        }
        else if(costUOM == 'YRS' || costUOM =='Years') {
            R = (assetRevPerServPerMonth / 12) * quantity;
        }
        else if(costUOM == 'MTH' || costUOM == 'Months') {
            R = (assetRevPerServPerMonth * 1) * quantity;
        }
        
        
        return R;
        
    }
    
    
 	//variables to store hardcoded values
    private static String INCREASE = 'Increase';
    private static String DECREASE = 'Decrease';
    private static String NEUTRAL = 'Neutral';
    private static String HAUL_PRODUCT = 'Haul';
    private static String PICKUP_PRODUCT = 'Pickup';
    private static String SCHEDULED = 'Scheduled';
    private static String SCH = 'SCH';
    private static String VCR_MSC = 'MSC';
    private static String SOBJ_QUOTELINE = 'QuoteLine';
    private static String SOBJ_ASSET = 'Asset';
    
    //TCS-pkulkarn-SDT-33179-Check the Quote Line for each Bundle and store the Agent provided VCR Codes (if any) in a global variable existingVCRCodes
    public static void checkAndRetrieveAgentUpdatedVCRCodes(List<SBQQ__QuoteLine__c> associatedQuoteLinesList)
    {
        for(SBQQ__QuoteLine__c qlParent : associatedQuoteLinesList)
        {
            if(qlParent.SBQQ__RequiredBy__c == null && qlParent.VCRCode__c != null && qlParent.VCRCode__c != '')
            {
                existingVCRCodes.put(qlParent.Id, qlParent.VCRCode__c);
            }
        }
    }
    
    //TCS-pkulkarn-SDT-38847-Check if VCR Code is provided by the User for a Quote Line on the Bundle
    public static Boolean isVCRCodePresentForQuoteLine(SBQQ__QuoteLine__c quoteLine)
    {
        Boolean result = false;
        if(existingVCRCodes.keySet().contains(quoteLine.Id) || 
            (existingVCRCodes.keySet().contains(quoteLine.SBQQ__RequiredBy__c)) || 
            (existingVCRCodes.keySet().contains(quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c))
            )
        {
            result = true;
        }
        
        return result;
    }
    
    //TCS-pkulkarn-SDT-38847-29-Apr-2024-Check if VCR Code is present for the given Bundleprovided by the User for a Quote Line on the Bundle
    public static String getVCRCodeForQuoteLine(SBQQ__QuoteLine__c quoteLine)
    {
        String sVCRCode = '';
        //Retrieve the Bundle Id based on the Quote Line (whether it is Bundle, Child or Grand child)
        Id bundleId = quoteLine.SBQQ__RequiredBy__c == NULL ? quoteLine.Id : quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == NULL ? quoteLine.SBQQ__RequiredBy__c : quoteLine.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c;
    	if(existingVCRCodes.keySet().contains(bundleId))
        {
            sVCRCode = existingVCRCodes.get(bundleId);
        }
        return sVCRCode;
    }
}