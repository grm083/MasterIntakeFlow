/*
    * @Name          ExtraPickupHandler
    * @Author        Seema Dhikale
    * @Vendor        TCS
    * @Date          15/05/2024
    * @description   This class will be used as Handler class for Extra pickup asset/ Quotelines, story SDT-36176
    */
public with sharing class ExtraPickupHandler {
    public static final string QUOTETYPE_QUOTE = 'Quote';
    public static final string QUOTE_TYPE_AMENDMENT = 'Amendment';	//pkulkan-TCS-SDT-39624-Added
    public static final string EVENT = 'Event';	//akotawal-TCS-SDT-45591-Added
    public static final string EV = 'EV';	//akotawal-TCS-SDT-45591-Added
    public static Map<Id,boolean> extrapickUpDeleteRecursionMap = new Map<Id,boolean>();
    
    public static void operateExtraPickupLine(List<SBQQ__QuoteLine__c> newQuoteLineList, map<id, SBQQ__QuoteLine__c> newQuoteLineMap){
        set<id> parentQLineSet = new set<id>();
        system.debug('inside QuoteLineTriggerHelper validatePickUp line#208');
        for(SBQQ__QuoteLine__c qLine : newQuoteLineList){
            //changes related to SDT-31628 --start
            if(qLine.SBQQ__RequiredBy__c!=null && qLine.SBQQ__ProductName__c !='Pickup') continue;
            
            system.debug('continue line#212');
            if(qLine.SBQQ__RequiredBy__c!=null){
                parentQLineSet.add(qLine.SBQQ__RequiredBy__c);
            }
            else{
                parentQLineSet.add(qLine.id);
            }
            //changes related to SDT-31628 --end
        }
        system.debug('parentQLineSet==>'+parentQLineSet);
        if(parentQLineSet.size()==0) return;
        
        system.debug('Continue line#218');
        
        set<id> qlinesToDelete = new set<id>();
        set<id> qlinesToInsert = new set<id>();
        
        for(SBQQ__QuoteLine__c qLine : getChildQuoteLines(parentQLineSet)){
            system.debug('inside line#224');
            system.debug('qLine==>'+qLine);
			String pickupOccurenceType = qLine.Occurrence_Type__c;
            String pickupParentOccurenceType = qLine.SBQQ__RequiredBy__r.Occurrence_Type__c;
            //changes related to SDT-31628 --start
			if(newQuoteLineMap.containsKey(qLine.Id))
            {
                pickupOccurenceType = newQuoteLineMap.get(qLine.Id).Occurrence_Type__c;
            }
            
			if(newQuoteLineMap.containsKey(qLine.SBQQ__RequiredBy__c))
            {
                pickupParentOccurenceType = newQuoteLineMap.get(qLine.SBQQ__RequiredBy__c).Occurrence_Type__c;
            }
			
            system.debug('qLine.Occurrence_Type__c==>'+qLine.Occurrence_Type__c);
            if(pickupParentOccurenceType == 'SCH' && pickupOccurenceType =='SCH'){
			    //changes related to SDT-31628 --end
                //SDT 36176 Extra pick up line will only be added automatically if quote is of type Quote(New Service case)
                if(qLine.SBQQ__Quote__r.SBQQ__Type__c == QUOTETYPE_QUOTE){
                    qlinesToInsert.add(qLine.SBQQ__RequiredBy__c);
                }
            }else{
                qlinesToDelete.add(qLine.SBQQ__RequiredBy__c);
            }
        }
        system.debug('qlinesToDelete==>'+qlinesToDelete);
        if(qlinesToDelete.size()>0){
            deleteExtraPickUp(qlinesToDelete);
        }
        
        system.debug('qlinesToInsert==>'+qlinesToInsert);
        if(qlinesToInsert.size()>0){
            /*id extraPickUpProductId = getExtraPickUpProductId();
            system.debug('extraPickUpProductId==>'+extraPickUpProductId);
            if(extraPickUpProductId == null) return;*/
            
            set<id> extraPickUpExistingParentQLineIdSet = extraPickUpExists(qlinesToInsert);
            system.debug('extraPickUpExistingParentQLineIdSet==>'+extraPickUpExistingParentQLineIdSet);
            
            List<SBQQ__QuoteLine__c> extraPickUpQlinesToInsert = new List<SBQQ__QuoteLine__c>();
            
            List<SBQQ__QuoteLine__c> parentQuoteLines = new List<SBQQ__QuoteLine__c>();
			//changes for SDT-31628
            Map<Id,SBQQ__QuoteLine__c> parentQlInsertMap = new Map<Id,SBQQ__QuoteLine__c>();
			//Added more fields of quoteline as part of SDT -31628 in the query
            parentQuoteLines = [SELECT id,SBQQ__Quote__c,Account__c,CurrencyIsoCode,SBQQ__StartDate__c,Exception_Effective_Date__c,
                                Exceptions_Effective_Date__c,Exception_Type__c,Exception_Reason__c,Exception_Comments__c,Duration__c,
                                sCode__c,Equipment_Size__c, (SELECT id, SBQQ__Number__c FROM SBQQ__Quote_Lines__r ORDER BY SBQQ__Number__c 
                                                             DESC LIMIT 1) FROM SBQQ__QuoteLine__c WHERE id IN:qlinesToInsert];  
															 
            map<id, Decimal> parentQLineIdNextExtrapickupNumberMap = new map<id, Decimal>();
            for(SBQQ__QuoteLine__c parentQLine : parentQuoteLines){
			    //changes for SDT-31628
                parentQlInsertMap.put(parentQLine.Id,parentQLine);
                if(parentQLine.SBQQ__Quote_Lines__r.size()>0){
                    decimal nextNum =  parentQLine.SBQQ__Quote_Lines__r[0].SBQQ__Number__c;
                    if(nextNum ==null || nextNum ==0){
                        nextNum=1;
                    }else{
                        nextNum++;
                    }
                    parentQLineIdNextExtrapickupNumberMap.put(parentQLine.id, nextNum);
                }
            }
            map<id,SBQQ__ProductOption__c> pqlineIdExtraPickUpIdMap = getparentQlineIdExtraPickUpIdMap(qlinesToInsert);
            for(id pQLineId : qlinesToInsert){
                
                if(
                    extraPickUpExistingParentQLineIdSet == null || 
                   	extraPickUpExistingParentQLineIdSet.size() == 0 || 
                   	!extraPickUpExistingParentQLineIdSet.contains(pQLineId)
                )
                {
                    system.debug('line#251 after continue');
                    //if(newQuoteLineMap.containskey(pQLineId) && newQuoteLineMap.get(pQLineId) != null)
                    //{
                        //check if the parent quoteline`s product has any extra pick up then only insert a new extra pick up
                        if(pqlineIdExtraPickUpIdMap.containsKey(pQLineId) && pqlineIdExtraPickUpIdMap.get(pQLineId) != null){
						    //changes for SDT-31628
                            SBQQ__QuoteLine__c pQLine = parentQlInsertMap.get(pQLineId);
                            id extraPickUpProductId = pqlineIdExtraPickUpIdMap.get(pQLineId).SBQQ__OptionalSKU__c;
                            id pOptionId = pqlineIdExtraPickUpIdMap.get(pQLineId).Id;
                            //pkulkarn-TCS-31-5-2023-Added below line for SDT-30115
                            SBQQ__ProductOption__c productOptionEP = pqlineIdExtraPickUpIdMap.get(pQLineId);
                            //pkulkarn-TCS-31-5-2023-Added productOptionEP parameter in below call for SDT-30115
                            extraPickUpQlinesToInsert.add(assignExtraPickUp(pQLine, extraPickUpProductId, pOptionId,  parentQLineIdNextExtrapickupNumberMap.get(pQLineId), productOptionEP));
                        }
                    //}   
                }
            }  
            
            system.debug('extraPickUpQlinesToInsert==>'+extraPickUpQlinesToInsert);
            if(extraPickUpQlinesToInsert.size() == 0) return;
            
            insert extraPickUpQlinesToInsert;
        }    
    }
    
    //SDT36176 added SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName,SBQQ__Quote__r.SBQQ__Type__c
    public static List<SBQQ__QuoteLine__c> getChildQuoteLines(set<id> parentQLineSet){
        return [SELECT id, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName,SBQQ__Quote__r.SBQQ__Type__c, SBQQ__ProductName__c, Occurrence_Type__c, SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.Occurrence_Type__c  FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c IN : parentQLineSet AND  SBQQ__ProductName__c='Pickup'];
    }
    public static void deleteExtraPickUp(set<id> parentQLineSet){
        delete [SELECT id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c IN : parentQLineSet AND SBQQ__ProductName__c='Extra Pickup' AND id NOT IN:extrapickUpDeleteRecursionMap.keySet()];
    } 
    
    public static set<id> extraPickUpExists(set<id> parentQLineSet){
        set<id> qLineIdSet = new set<id>();
        for(SBQQ__QuoteLine__c qLine : [SELECT SBQQ__RequiredBy__c  FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c IN : parentQLineSet AND  SBQQ__ProductName__c='Extra Pickup']){
            qLineIdSet.add(qLine.SBQQ__RequiredBy__c);
        }
        return qLineIdSet;
    }
    public static map<id,SBQQ__ProductOption__c> getparentQlineIdExtraPickUpIdMap(set<id> pqLineIdSet){
        map<id,set<id>> productIdPArentQLineIdSetMap= new map<id,set<id>>();
        for(SBQQ__QuoteLine__c qLine: [SELECT id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE id IN:pqLineIdSet]){
            if(productIdPArentQLineIdSetMap.containsKey(qLine.SBQQ__Product__c)){
                set<id>productIdset =productIdPArentQLineIdSetMap.get(qLine.SBQQ__Product__c);
                productIdset.add(qLine.Id);
                productIdPArentQLineIdSetMap.put(qLine.SBQQ__Product__c, productIdset); 
            }else{
                set<id> productIdset = new set<id>();
                productIdset.add(qLine.Id);
                productIdPArentQLineIdSetMap.put(qLine.SBQQ__Product__c, productIdset);
            }
        }
        
        map<id,SBQQ__ProductOption__c> pQlineIdExtraPickUpIdMap = new map<id,SBQQ__ProductOption__c>();
        for(SBQQ__ProductOption__c pOtions: getProductOptions(productIdPArentQLineIdSetMap.keySet())){
            for(id qLineId : productIdPArentQLineIdSetMap.get(pOtions.SBQQ__ConfiguredSKU__c)){
               pQlineIdExtraPickUpIdMap.put(qLineId, pOtions);
            }
        }
        return pQlineIdExtraPickUpIdMap;
    }
    
    //Removed the IsExtraPickup__c for Bug SDT-25050, For extra pick up line this flag always be false. 
    //pkulkarn-TCS-31-5-2023-Added productOptionEP parameter in signature for SDT-30115 
    public static SBQQ__QuoteLine__c assignExtraPickUp(SBQQ__QuoteLine__c pQline, id ePickUpId, id pOptionId, decimal nextNumber, SBQQ__ProductOption__c productOptionEP){
        SBQQ__QuoteLine__c extraPickUpQLine = new SBQQ__QuoteLine__c(Occurrence_Type__c = 'OC',
                                                                     SBQQ__RequiredBy__c = pQline.Id,
                                                                     SBQQ__Product__c = ePickUpId,
                                                                     SBQQ__ProductOption__c = pOptionId,
                                                                     SBQQ__Quote__c = pQline.SBQQ__Quote__c,
                                                                     Account__c = pQline.Account__c,
                                                                     CurrencyIsoCode = pQline.CurrencyIsoCode,
                                                                     SBQQ__StartDate__c = pQline.SBQQ__StartDate__c,
                                                                     Exception_Effective_Date__c = pQline.Exception_Effective_Date__c,
																	 Exceptions_Effective_Date__c = pQline.Exceptions_Effective_Date__c,
                                                                     Exception_Type__c = pQline.Exception_Type__c,
                                                                     Exception_Reason__c = pQline.Exception_Reason__c,
                                                                     Exception_Comments__c = pQline.Exception_Comments__c,
                                                                     Duration__c = pQline.Duration__c,
                                                                     sCode__c = pQline.sCode__c,
                                                                     Equipment_Size__c = pQline.Equipment_Size__c,
                                                                     SBQQ__Number__c = nextNumber,
                                                                     SBQQ__Quantity__c = 1,
                                                                     //IsExtraPickup__c= true,
                                                                     SBQQ__Bundle__c = true,
                                                                     SBQQ__OptionLevel__c = 1,
                                                                     CostModelType__c = 'PER',
                                                                     SBQQ__CostEditable__c = True,
                                                                     SBQQ__PriceEditable__c = True
                                                                     );
        extraPickUpQLine.Exception_Effective_Date__c =  Date_Utility.getDateTimeInGMTForGivenDateTime(pQline.Exception_Effective_Date__c);//Updated according to the SDT29615                                                           
		extraPickUpQLine.Exceptions_Effective_Date__c =  pQline.Exceptions_Effective_Date__c;//SDT-31323
	    //pkulkarn-TCS-31-5-2023-Added for SDT-30115
        UTIL_Picklist.picklistWrapper PLWrapperCostUOM = UTIL_Picklist.validateDependentPicklist('SBQQ__QuoteLine__c', 'Cost_Unit_of_Measure__c', Constant_Util.ON_CALL, productOptionEP.Cost_Unit_of_Measure__c);
        UTIL_Picklist.picklistWrapper PLWrapperPriceUOM = UTIL_Picklist.validateDependentPicklist('SBQQ__QuoteLine__c', 'PriceUOM__c', Constant_Util.ON_CALL, productOptionEP.PriceUOM__c);
        if(PLWrapperCostUOM.isvalid && productOptionEP.Cost_Unit_of_Measure__c == EVENT )
            extraPickUpQLine.Cost_Unit_of_Measure__c = EV;
        if(PLWrapperPriceUOM.isvalid && productOptionEP.PriceUOM__c == EVENT)
            extraPickUpQLine.PriceUOM__c = EV;
        //pkulkarn-TCS-31-5-2023-End
        return extraPickUpQLine;
    }
    public static List<SBQQ__ProductOption__c> getProductOptions(set<id> parentProductIdSet){
        //pkulkarn-TCS-31-5-2023-Added toLabel(Cost_Unit_of_Measure__c), toLabel(PriceUOM__c) for SDT-30115
        return [SELECT id, SBQQ__ConfiguredSKU__c, SBQQ__ConfiguredSKU__r.Name, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, toLabel(Cost_Unit_of_Measure__c), toLabel(PriceUOM__c)
                FROM SBQQ__ProductOption__c 
                WHERE SBQQ__ConfiguredSKU__c IN: parentProductIdSet AND SBQQ__OptionalSKU__r.Name='Extra Pickup'];
    }
    /**************************************************
		* Created By:Mohammed Rishan Ali
		* CreatedDate:03/16/2022
		* Defect: SDT-31628
		* Description: To prevent the recurrsive deletion of extra pickup quoteline
		* **************************************************/
			public static void filterExtrapickupQL(List<SBQQ__QuoteLine__c> newQouteLineList){
				for(SBQQ__QuoteLine__c qL : newQouteLineList)
				{
					extrapickUpDeleteRecursionMap.put(qL.Id,TRUE);
				} 
			}

            //pkulkan-TCS-SDT-39624-Added method to set fields on Extra Pickup quote line before insert
    //Caller: QuoteLineTriggerHandler.onBeforeInsert()
    //This validation is not applicable for New Service quote
    public static void handleExtraPickupInsertion(List<SBQQ__QuoteLine__c> newQuoteLineList)
    {
        Map<Id, SBQQ__QuoteLine__c> pickupQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> extraPickupQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> validatedExtraPickupLines = new List<SBQQ__QuoteLine__c>();
        Set<Id> bundleIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLines;
        SBQQ__QuoteLine__c pickupQuoteLine;
        String sQuoteType;
        
        for(SBQQ__QuoteLine__c quoteLine : newQuoteLineList)
        {
            //Check if Extra Pickup is added
            if(quoteLine.SBQQ__ProductName__c == Constant_Util.PR_EXTRA_PICKUP && quoteLine.AssetId__c == null)
            {
                if(quoteLine.SBQQ__RequiredBy__c != null)	//pkulkarn-TCS-SDT-40364-Added NULL check for Parent. For New Service quote created from Intake (non favourites, the Parent is not set for QLs)
                {
                    bundleIds.add(quoteLine.SBQQ__RequiredBy__c);
                }   
                extraPickupQuoteLines.put(quoteLine.Id, quoteLine);
            }
        }
        
        //Retrieve Bundle and Pickup quote lines
        if(extraPickupQuoteLines.size() > 0)
        {
            quoteLines = QuoteLineSelector.getPickupQuoteLines(bundleIds);
            
            for(SBQQ__QuoteLine__c quoteLine : quoteLines)
            {
                pickupQuoteLines.put(quoteLine.SBQQ__RequiredBy__c, quoteLine);
            }
        }
        //Validate for Occurrence Type on Pickup and Bundle
        for(Id extraPickupId : extraPickupQuoteLines.keySet())
        {
            SBQQ__QuoteLine__c quoteLine = extraPickupQuoteLines.get(extraPickupId);
            if(pickupQuoteLines.containsKey(quoteLine.SBQQ__RequiredBy__c))
            {
                pickupQuoteLine = pickupQuoteLines.get(quoteLine.SBQQ__RequiredBy__c);
                sQuoteType = pickupQuoteLine.SBQQ__Quote__r.SBQQ__Type__c;
                
                if(sQuoteType != QUOTETYPE_QUOTE &&
                   (pickupQuoteLine.Occurrence_Type__c != Constant_util.SCHEDULED_TYPE || pickupQuoteLine.SBQQ__RequiredBy__r.Occurrence_Type__c != Constant_util.SCHEDULED_TYPE))
                {
                    quoteLine.addError(System.Label.ExtraPickupAdditionValidationError);
                }
                else
                {
                    validatedExtraPickupLines.add(quoteLine);
                }
            }
        }
        
        if(validatedExtraPickupLines.size() > 0)
        {
            setExtraPickupFields(validatedExtraPickupLines, pickupQuoteLines);
        }
    }
    
    //pkulkan-TCS-SDT-39624-Added method to set fields on Extra Pickup quote line before insert
    //Caller: ExtraPickupHandler.handleExtraPickupInsertion()
    public static void setExtraPickupFields(List<SBQQ__QuoteLine__c> validatedExtraPickupLines, Map<Id, SBQQ__QuoteLine__c> pickupQuoteLinesMap)
    {
        List<SBQQ__QuoteLine__c> updatedExtraPickupLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c pickUpQuoteLine;

        for(SBQQ__QuoteLine__c extraPickupQuoteLine : validatedExtraPickupLines)
        {
            if(pickupQuoteLinesMap.containsKey(extraPickupQuoteLine.SBQQ__RequiredBy__c))
            {
                pickUpQuoteLine = pickupQuoteLinesMap.get(extraPickupQuoteLine.SBQQ__RequiredBy__c);

                extraPickupQuoteLine.Material_Type__c = pickUpQuoteLine.SBQQ__RequiredBy__r.Material_Type__c;
                extraPickupQuoteLine.Vendor__c = pickUpQuoteLine.SBQQ__RequiredBy__r.Vendor__c;
                extraPickupQuoteLine.VendorAccountNumber__c = pickUpQuoteLine.SBQQ__RequiredBy__r.VendorAccountNumber__c;
                extraPickupQuoteLine.sCode__c = pickUpQuoteLine.SBQQ__RequiredBy__r.sCode__c;
                extraPickupQuoteLine.Location_Position_Name__c = pickUpQuoteLine.Location_Position_Name__c;		//pkulkan-TCS-SDT-40338-Added
                extraPickupQuoteLine.LocationPositionName__c = pickUpQuoteLine.LocationPositionName__c;		//pkulkan-TCS-SDT-40338-Added


                extraPickupQuoteLine.SBQQ__StartDate__c = pickUpQuoteLine.SBQQ__StartDate__c;
                if(pickupQuoteLine.SBQQ__Quote__r.SBQQ__Type__c == QUOTE_TYPE_AMENDMENT)
                {
                    extraPickupQuoteLine.SetupComment__c = pickupQuoteLine.SetupComment__c;
                }
                updatedExtraPickupLines.add(extraPickupQuoteLine);
            }
        }
        
        if(updatedExtraPickupLines.size() > 0)
        {
            setCostAndPriceOnExtraPickup(updatedExtraPickupLines);
        }
    }
    
    //pkulkan-TCS-SDT-39624-Added method to set Cost and Price on ExtraPickup quote line if Pricing data is available
    //Caller: ExtraPickupHandler.setExtraPickupFields()
    public static void setCostAndPriceOnExtraPickup(List<SBQQ__QuoteLine__c> extraPickupQuoteLines)
    {
       	Set<Id> bundleIds = new Set<Id>();
        Map<Id, Pricing_Request__c> pricingRequestMap = new Map<Id, Pricing_Request__c>();
        //Get the Bundle Ids from inserted Extra Pickup Lines
        if(extraPickupQuoteLines.size() > 0)
        {
            for(SBQQ__QuoteLine__c quoteLine : extraPickupQuoteLines)
            {
                bundleIds.add(quoteLine.SBQQ__RequiredBy__c);
            }
            
            PricingRequestJsonDeserialize.Request prFields = new PricingRequestJsonDeserialize.Request();
            Pricing_Request__c pr;
            
            //Query Pricing Request records
            List<Pricing_Request__c> priqList = QuoteLineSelector.getPricingRequests(bundleIds);
            
            for(Pricing_Request__c pricingRequest : priqList)
            {
                pricingRequestMap.put(pricingRequest.Quote_Line_Bundle__c, pricingRequest);
            }
            //Update Cost and Price on Extra Pickup lines
            for(SBQQ__QuoteLine__c quoteLine : extraPickupQuoteLines)
            {
                if(pricingRequestMap.containsKey(quoteLine.SBQQ__RequiredBy__c))
                {
                    pr = pricingRequestMap.get(quoteLine.SBQQ__RequiredBy__c);
                    if(pr != null && !pr.IsCaseError__c)
                    {
                        prFields = PricingRequestJsonDeserialize.parseOnlyRequest(pr.APIRequestOutput__c);
                        if(pr.isAPIResult__c)
                        {
                            if(pr.Zone_Type__c == null || 
                               (pr.Zone_Type__c != System.label.WM_Franchise && pr.Zone_Type__c != System.label.Competitor &&
                                pr.Zone_Type__c != System.label.Pre_Determined_Pricing && pr.Zone_Type__c != System.label.Third_Party_Agreement))
                            {
                                if(prFields.Data.commercial != null)
                                {
                                    //Set Extra Pickup cost and price
                                    quoteLine.SBQQ__UnitCost__c = pr.Extra_Pickup_Cost__c;
                                    quoteLine.SBQQ__ListPrice__c = pr.Extra_Pickup_Price__c;
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //pkulkan-TCS-SDT-39624-Added method to set IsExtraPickup__c on Pickup quote line before update
    //Caller: QuoteLineTriggerHandler.onBeforeUpdate()
    public static void validateExtraPickupStartDate(List<SBQQ__QuoteLine__c> newQuoteLineList, Map<Id,SBQQ__QuoteLine__c> oldQuoteLineMap, Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap)
    {
        Map<Id, SBQQ__QuoteLine__c> extraPickupQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> bundleQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c extraPickupQuoteLine;
        SBQQ__QuoteLine__c bundleQuoteLine;
        Set<Id> extraPickupIds = new Set<Id>();
        Set<Id> bundleIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLines;
        
        for(SBQQ__QuoteLine__c quoteLine : newQuoteLineList)
        {
            //Check if Extra Pickup is updated
            if(quoteLine.SBQQ__ProductName__c == Constant_Util.PR_EXTRA_PICKUP)
            {
                extraPickupIds.add(quoteLine.Id);
                bundleIds.add(quoteLine.SBQQ__RequiredBy__c);
                extraPickupQuoteLines.put(quoteLine.Id, quoteLine);
            }
        }
        
        //Retrieve Bundle records with Asset Start Date
        if(extraPickupQuoteLines.size() > 0)
        {
            quoteLines = QuoteLineSelector.getBundleQuoteLines(bundleIds);

            for(SBQQ__QuoteLine__c bundleQLine : quoteLines)
            {
                bundleQuoteLines.put(bundleQLine.Id, bundleQLine);
            }
        }
        
        //Check if Extra Pickup is updated
        for(Id extraPickupId : extraPickupQuoteLines.keyset())
        {
            extraPickupQuoteLine = extraPickupQuoteLines.get(extraPickupId);
            bundleQuoteLine = bundleQuoteLines.get(extraPickupQuoteLine.SBQQ__RequiredBy__c);
            
            //Check if Start Date is changed and less than the Asset start date (on an Add/Change quote)
            //pkulkarn-TCS-SDT-40326-Added null check for bundleQuoteLine to fix test class failures
            if(extraPickupQuoteLine.AssetId__c == null && bundleQuoteLine != null &&
               bundleQuoteLine.SBQQ__Quote__r.SBQQ__Type__c != QUOTETYPE_QUOTE &&
               oldQuoteLineMap.get(extraPickupId).SBQQ__StartDate__c != null && extraPickupQuoteLine.SBQQ__StartDate__c != oldQuoteLineMap.get(extraPickupId).SBQQ__StartDate__c &&
               extraPickupQuoteLine.SBQQ__StartDate__c < bundleQuoteLine.AssetId__r.Start_Date__c
              )
            {
                newQuoteLineMap.get(extraPickupId).addError(System.Label.ExtraPickupStartDateValidationError);
            }
        }
    }
    
    //pkulkan-TCS-SDT-39624-Added method to set IsExtraPickup__c on Pickup quote line before update
    //Caller: QuoteLineTriggerHandler.onBeforeUpdate()
    public static void validateAndSetIsExtraPickupFlagOnPickup(List<SBQQ__QuoteLine__c> newQuoteLineList)
    {
        Map<Id, SBQQ__QuoteLine__c> pickupQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> bundleQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> extraPickupQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        Set<Id> bundleIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();

        //Check if Pickup is changed
        for(SBQQ__QuoteLine__c quoteLine : newQuoteLineList)
        {
            if(quoteLine.SBQQ__ProductName__c == Constant_Util.PR_PICKUP)
            {
                pickupQuoteLines.put(quoteLine.Id, quoteLine);
                bundleIds.add(quoteLine.SBQQ__RequiredBy__c);
            }
        }
		//Retrieve Bundle and Extra Pickup Lines
        if(pickupQuoteLines.size() > 0)
        {
            quoteLines = QuoteLineSelector.getBundleAndExtraPickupQuoteLines(bundleIds);

            for(SBQQ__QuoteLine__c quoteLine : quoteLines)
            {
                if(bundleIds.contains(quoteLine.Id))
                {
                    bundleQuoteLines.put(quoteLine.Id, quoteLine);
                }
                else if(quoteLine.SBQQ__ProductName__c == Constant_Util.PR_EXTRA_PICKUP)
                {
                    extraPickupQuoteLines.put(quoteLine.SBQQ__RequiredBy__c, quoteLine);
                }
            }
        }
        
        for(Id pickupId : pickupQuoteLines.keySet())
        {
            //Check if Bundle and Pickup are scheduled and update IsExtraPickup on Pickup line accordingly
            SBQQ__QuoteLine__c quoteLine = pickupQuoteLines.get(pickupId);
            if(extraPickupQuoteLines.containsKey(quoteLine.SBQQ__RequiredBy__c))
            {
                if(quoteLine.Occurrence_Type__c == Constant_util.SCHEDULED_TYPE)
                {
                    if(bundleQuoteLines.containsKey(quoteLine.SBQQ__RequiredBy__c) && bundleQuoteLines.get(quoteLine.SBQQ__RequiredBy__c).Occurrence_Type__c == Constant_util.SCHEDULED_TYPE)
                    {
                        quoteLine.IsExtraPickup__c = true;
                    }
                }
                else
                {
                    quoteLine.IsExtraPickup__c = false;
                }
            }
            else
            {
                quoteLine.IsExtraPickup__c = false;
            }
        }
    }

    
}