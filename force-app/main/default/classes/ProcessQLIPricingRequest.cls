public class ProcessQLIPricingRequest {

    public with sharing class QuotePricingWrapper {
    	@AuraEnabled public String QuoteID {get;set;}
    	@AuraEnabled public String BundleID {get;set;}
   	    @AuraEnabled public String BundleLink {get;set;}
   		@AuraEnabled public String PricingReqId {get;set;}
    	@AuraEnabled public String PricingRequestLink {get;set;}
        @AuraEnabled public String ProductName  {get;set;}
        @AuraEnabled public String LOB  {get;set;}
        @AuraEnabled public String CurrencyCode  {get;set;}        
        @AuraEnabled public Boolean BypassPriceReview  {get;set;}        
    	@AuraEnabled public ProductDetail ProductDetails {get;set;}
    	@AuraEnabled public Problem Problem {get;set;}
        //@AuraEnabled Public boolean IsPricingAvailable {get;Set;}
        @AuraEnabled Public Map<String,String> PriceOnlyReason {get; set;}
    }

    public with sharing class ProductDetail{
        @AuraEnabled public String StartDate  {get;set;}
    	@AuraEnabled public String EndDate  {get;set;}
    	@AuraEnabled public String SourceCode  {get;set;}
    	@AuraEnabled public String VendorCode  {get;set;}
    	@AuraEnabled public String Vendor  {get;set;}
    	@AuraEnabled public String BusinessUnit  {get;set;}
        @AuraEnabled public String RateTypeHaul  {get;set;}
        @AuraEnabled public String RateTypeDisposal  {get;set;}
        @AuraEnabled public String RateTypePickup  {get;set;}
        @AuraEnabled public String CustomerPriceType  {get;set;}
        @AuraEnabled public String FacilityId  {get;set;}
        @AuraEnabled public Boolean IsProjectRequest  {get;set;}
        @AuraEnabled public Double DisposalRecordId  {get;set;}
        @AuraEnabled public Double HaulRecordId  {get;set;}
        @AuraEnabled public Double PickupRecordId  {get;set;}
        @AuraEnabled public Double ExtraPickupRecordId  {get;set;}
        @AuraEnabled public String EquipmentSize  {get;set;}
        @AuraEnabled public String OriginalEquipmentSize  {get;set;}
		@AuraEnabled public String SubstituteMessage {get;set;}
   	    @AuraEnabled public GreenPage GreenPages {get;set;}
   	    @AuraEnabled public List<ServiceCharges> ServiceCharges {get;set;}
    }

    public with sharing class ServiceCharges{
        @AuraEnabled public String ServiceId {get;set;}
        @AuraEnabled public String ServiceName {get;set;}
        @AuraEnabled public String CostValueType {get;set;}
        @AuraEnabled public String CostValueSymbol {get;set;}
        @AuraEnabled public String CostValuePercent {get;set;}
        @AuraEnabled public String CostUOMCode {get;set;}
        @AuraEnabled public String CostUOM {get;set;}
        @AuraEnabled public Double Cost {get;set;}
        @AuraEnabled public Boolean IsContractPrice {get;set;}
        @AuraEnabled public String PriceValueType {get;set;}
        @AuraEnabled public String PriceValueSymbol {get;set;}
        @AuraEnabled public String PriceValuePercent {get;set;}
        @AuraEnabled public String PriceUOMCode {get;set;}
        @AuraEnabled public String PriceUOM {get;set;}
        @AuraEnabled public Double Price {get;set;}
        // Changes for Exhibit Pricing Story- SDT-20401
        @AuraEnabled public Boolean IsSteppedRate {get; set;}
        @AuraEnabled public Boolean IsSteppedRateCost {get; set;}
        @AuraEnabled public Boolean IsSteppedRatePrice {get; set;}
        @AuraEnabled public List<StepRate> StepRates {get; set;} 
    }

    public with sharing class StepRate{
        @AuraEnabled public Double StepPriceUpTo {get;set;}
        @AuraEnabled public string StepPriceRange {get;set;}
        @AuraEnabled public Double StepCostUpTo {get;set;}
        @AuraEnabled public string StepCostRange {get;set;}
        @AuraEnabled public Double StepCost {get;set;}
        @AuraEnabled public String CostValueSymbol {get;set;}
        @AuraEnabled public Double StepPrice {get;set;}
        @AuraEnabled public String PriceValueSymbol {get;set;}
    }
    public with sharing class Problem{
        @AuraEnabled public String ErrorMessage {get;set;}
    }

    public with sharing class GreenPage{
        @AuraEnabled public String Message {get;set;}
        @AuraEnabled public String Market {get;set;}
        @AuraEnabled public String GPLabelName {get;set;}
        @AuraEnabled public String GPLabelLink {get;set;}
    }

    @AuraEnabled
    public static list<PricingRequestSTPProcess.QuotePricingWrapper> getQuotePricingDetail(ID quoteID)
    {
        list<PricingRequestSTPProcess.QuotePricingWrapper> wrapperList = new list<PricingRequestSTPProcess.QuotePricingWrapper>();
        wrapperList = PricingRequestSTPProcess.getPricingDetails(quoteID);
        return wrapperList;
    }

    @AuraEnabled
    public static list<QuotePricingWrapper> getQuotePriceOnlyDetail(ID quoteLineID)
    {
        system.debug('getQuotePriceOnlyDetail@@@@@@@@@@@@@');
        //PricingReportingFieldsMetadata prFields = new PricingReportingFieldsMetadata();
        PricingRequestJsonDeserialize.Request prFields = new PricingRequestJsonDeserialize.Request();
        list<QuotePricingWrapper> wrapperList = new list<QuotePricingWrapper>();
        Map<String,String> materialMap = new Map<String,String>();
        Map<String,String> containerMap = new Map<String,String>();
        Map<String,String> equipmentSizeMap = new Map<String,String>();
        Map<String,String> durationMap = new Map<String,String>();
        Map<String,String> costUOMMapId = new Map<String,String>();
        Map<String,String> costUOMMapName = new Map<String,String>();
        Map<String,String> priceUOMMapId = new Map<String,String>();
        Map<String,String> priceUOMMapName = new Map<String,String>();
        Map<Id,SBQQ__QuoteLine__c> quoteHdrMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,List<SBQQ__QuoteLine__c>> quoteLineMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
        String currencySymbol;

        List<SBQQ__QuoteLine__c> bundles = [SELECT Id, SBQQ__ProductCode__c, SBQQ__ProductName__c, Equipment_Size__c, SBQQ__Quote__c, SBQQ__Quote__r.Name, Name, SBQQ__StartDate__c, SBQQ__EndDate__c, Duration__c, BypassPriceReview__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE Id =: quoteLineID  AND SBQQ__Bundle__c = TRUE AND SBQQ__Product__r.Is_Pricing_Eligible__c = TRUE];
        
        for(SBQQ__QuoteLine__c qlHdr : bundles){
            quoteHdrMap.put(qlHdr.Id, qlHdr);
        }

        List<Pricing_Request__c> priqList = [SELECT Id, Name, Line_of_Business__c, Container_Type__c, Container_Size__c, Material_Code__c, Service_Type__c, Quote__c, Quote__r.Name, Quote_Line_Bundle__c,
                                             Quote_Line_Bundle__r.Name, Zone_Type__c, Haul_Rate_Type__c,  Haul_Cost__c, Haul_Price__c, Disposal_Rate_Type__c, Disposal_Cost__c, Disposal_Price__c, Pickup_Rate_Type__c,
                                             Pickup_Cost__c, Pickup_Price__c, Extra_Pickup_Cost__c, Extra_Pickup_Price__c, isAPIResult__c, APIRequestOutput__c, Case_Error_Message__c, IsCaseError__c,
                                              Cost_Source__c, Source_Code__c, Vendor_Code__c, Vendor_Name__c, Business_Unit__c, QuoteID__c,  Project_Request__c, Customer_Price_Type__c,
                                             Disposal_Record_Id__c, Haul_Record_Id__c, Pickup_Record_Id__c, Extra_Pickup_Record_Id__c , Vendor_Comments__c, Facility_Id__c, Facility_Name__c 
                                              FROM Pricing_Request__c 
                                              WHERE Quote_Line_Bundle__c =: quoteLineID AND Pricing_Type__c = 'AMPO'  Order By CreatedDate DESC LIMIT 1];
                                               //AND Pricing_Type__c = AMPO

        for(SBQQ__QuoteLine__c qlReq : bundles){
            List<SBQQ__QuoteLine__c> qlLst = [SELECT Id, SBQQ__ProductCode__c, SBQQ__ProductName__c, SBQQ__Quote__c, Occurrence_Type__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, PriceUOM__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, SBQQ__CustomerPrice__c 
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__RequiredBy__c =: qlReq.Id and SBQQ__ProductFamily__c != 'Waste Category'];

            quoteLineMap.put(qlReq.Id, qlLst);                                    
        }

        List<String> prDurationLst = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'Duration__c');
        List<String> prEquipmentSizeLst = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'Equipment_Size__c');
        List<String> pckCostValue = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'Cost_Unit_of_Measure__c');
        List<String> pckPriceValue = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'PriceUOM__c');
        
        for(String dur : prDurationLst){
            durationMap.put(dur.split(',').get(1), dur.split(',').get(0));
        }
        for(String es : prEquipmentSizeLst){
            equipmentSizeMap.put(es.split(',').get(1), es.split(',').get(0));
        }
        for(String pcv : pckCostValue){
            costUOMMapId.put(pcv.split(',').get(1), pcv.split(',').get(0));
            costUOMMapName.put(pcv.split(',').get(0), pcv.split(',').get(1));
        }
        for(String ppv : pckPriceValue){
            priceUOMMapId.put(ppv.split(',').get(1), ppv.split(',').get(0));
            priceUOMMapName.put(ppv.split(',').get(0), ppv.split(',').get(1));
        }

        for(Pricing_Request__c pr : priqList)
        {
            QuotePricingWrapper qpWrapper = new QuotePricingWrapper();

            SBQQ__QuoteLine__c ql = quoteHdrMap.get(pr.Quote_Line_Bundle__c);
            String equipmentSizeName = equipmentSizeMap.get(ql.Equipment_Size__c);
            String durationName = durationMap.get(ql.Duration__c);

            qpWrapper.QuoteID = pr.QuoteID__c;
            qpWrapper.BundleID = pr.Quote_Line_Bundle__r.Name;
            qpWrapper.BundleLink = pr.Quote_Line_Bundle__c;
            qpWrapper.PricingReqId = pr.Name;
            qpWrapper.PricingRequestLink = pr.Id;
            qpWrapper.LOB = pr.Line_of_Business__c;
            qpWrapper.ProductName = ql.SBQQ__ProductName__c + Constant_Util.BLANKSPACE + equipmentSizeName + Constant_Util.BLANKSPACE + durationName;
            
            if(!pr.IsCaseError__c)
            {
                system.debug('@@@ PR test'+pr.APIRequestOutput__c);
                //prFields = PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c);
                prFields = PricingRequestJsonDeserialize.parseOnlyRequest(pr.APIRequestOutput__c);
                //system.debug('deseralize prFields '+ prFields);
                if(pr.isAPIResult__c)
                {
                    //SDT-31627
                    qpWrapper.BypassPriceReview = PricingRequestSTPProcess.getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource, null);
                    

                    //qpWrapper.IsPricingAvailable = true;
                    ProductDetail productDtl = new ProductDetail();

                    //Comment Code for SDT-31291 : Start
                    // if(prFields.Data.overridableEquipmentSizeCode != null){
                    //     productDtl.EquipmentSize = prFields.Data.overridableEquipmentSizeCode;
                    //     productDtl.OriginalEquipmentSize = prFields.Data.equipmentSizeName;
					// 	productDtl.SubstituteMessage = 'The requested container size is not available and has been substituted with '+ prFields.Data.overridableEquipmentSizeName + '.';
                    // }

                    if(pr.Zone_Type__c == null || 
                    (pr.Zone_Type__c != System.label.WM_Franchise && pr.Zone_Type__c != System.label.Competitor &&
                    pr.Zone_Type__c != System.label.Pre_Determined_Pricing && pr.Zone_Type__c != System.label.Third_Party_Agreement))
                    {
                        List<ServiceCharges> sChargelst = new List<ServiceCharges>();

                        productDtl.StartDate = String.valueof(ql.SBQQ__StartDate__c);
                        productDtl.EndDate = String.valueof(ql.SBQQ__EndDate__c);
                        productDtl.SourceCode = pr.Cost_Source__c;
                        productDtl.VendorCode = pr.Vendor_Code__c.contains('|') ? pr.Vendor_Code__c.substringBefore('|') : pr.Vendor_Code__c;
                        productDtl.Vendor = pr.Vendor_Name__c;
                        productDtl.BusinessUnit = pr.Business_Unit__c;
                        productDtl.FacilityId = pr.Facility_Id__c;
                        productDtl.IsProjectRequest =  pr.Project_Request__c;
                        if(pr.Project_Request__c){
                            productDtl.CustomerPriceType =  pr.Customer_Price_Type__c;
                        }                    
                        //Change for story SDT-25845
                        currencySymbol = prFields.Data.currencyCode != null ? prFields.Data.currencyCode : 'USD';
                        qpWrapper.CurrencyCode = currencySymbol;

                        List<SBQQ__QuoteLine__c> quotelinebundleLst = quoteLineMap.get(pr.Quote_Line_Bundle__c);
                        List<StepRate> steppeddisposallst = new List<StepRate>();
                        Integer stepCount = 0;

                        for(SBQQ__QuoteLine__c sql : quotelinebundleLst)
                        {
                            ServiceCharges ancillaryCharge = new ServiceCharges();
                            ancillaryCharge.ServiceName = sql.SBQQ__ProductName__c;
                            ancillaryCharge.ServiceId = sql.Id;
                            ancillaryCharge.IsSteppedRate = false;
                            ancillaryCharge.IsSteppedRateCost = false;
                            ancillaryCharge.IsSteppedRatePrice = false;
                            //ancillaryCharge.IsContractPrice = sql.Contracted_Price__c;

                            if(sql.SBQQ__ProductName__c.equals(Constant_Util.HAUL) || sql.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL)
                            || sql.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP) || sql.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP))
                            {
                                String apivalueUOMID = null, apivalueUOMName = null;
                                apivalueUOMID = costUOMMapName.get(prFields.Data.equipmentUOM);
                                apivalueUOMName = costUOMMapId.get(apivalueUOMID);
                                system.debug('@@@ PR LOB '+pr.Line_of_Business__c);

                                if(prFields.Data.rollOff != null)
                                {
                                    if(sql.SBQQ__ProductName__c.equals(Constant_Util.HAUL)){
                                        System.debug('@@@@@@@@~ In Haul');
                                        ancillaryCharge.Cost = pr.Haul_Cost__c;
                                        ancillaryCharge.CostValueSymbol = pr.Haul_Cost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        productDtl.RateTypeHaul =  pr.Haul_Rate_Type__c;
                                        productDtl.HaulRecordId =  pr.Haul_Record_Id__c;
                                        ancillaryCharge.Price = pr.Haul_Price__c;
                                        ancillaryCharge.PriceValueSymbol = pr.Haul_Price__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        
                                    }else if(sql.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL)){ 
                                        System.debug('@@@@@@@@~ In Disposal');
                                        ancillaryCharge.CostUOMCode = apivalueUOMID;
                                        ancillaryCharge.CostUOM = apivalueUOMName;
                                        productDtl.RateTypeDisposal =  pr.Disposal_Rate_Type__c;
                                        productDtl.DisposalRecordId =  pr.Disposal_Record_Id__c;
                                        ancillaryCharge.PriceUOMCode = apivalueUOMID;
                                        ancillaryCharge.PriceUOM = apivalueUOMName;

                                        //Stepped Pricing changes
                                        if(prFields.Data.rollOff.stepDisposals != null && prFields.Data.rollOff.stepDisposals.size() > 0)
                                        {
                                            for(PricingReportingFieldsMetadata.StepDisposal step : prFields.Data.rollOff.stepDisposals)
                                            {
                                                StepRate steppedCharge = new StepRate();
                                                if(pr.Disposal_Cost__c == null)
                                                {
                                                    steppedCharge.StepCostUpTo =  step.costUpTo;
                                                    steppedCharge.StepCostRange =  step.costRange;
                                                    steppedCharge.StepCost = step.cost;
                                                    ancillaryCharge.IsSteppedRateCost = true;
                                                }
                                                else 
                                                {
                                                    steppedCharge.StepCost = stepCount == 0 ? pr.Disposal_Cost__c : null;
                                                    ancillaryCharge.Cost = pr.Disposal_Cost__c;
                                                }

                                                if(pr.Disposal_Price__c == null)
                                                {
                                                    steppedCharge.StepPriceUpTo =  step.priceUpTo;
                                                    steppedCharge.StepPriceRange =  step.priceRange;                                                
                                                    steppedCharge.StepPrice = step.price;
                                                    ancillaryCharge.IsSteppedRatePrice = true;
                                                }
                                                else
                                                {
                                                    steppedCharge.StepPrice = stepCount == 0 ? pr.Disposal_Price__c : null;
                                                    ancillaryCharge.Price = pr.Disposal_Price__c;
                                                }
                                                steppedCharge.CostValueSymbol = (pr.Disposal_Cost__c != null || step.cost != null) ? currencySymbol : Constant_Util.EMPTY_STRING;
                                                steppedCharge.PriceValueSymbol = (pr.Disposal_Price__c != null || step.price != null) ? currencySymbol : Constant_Util.EMPTY_STRING;
                                                steppeddisposallst.add(steppedCharge);
                                                stepCount++;
                                            }
                                            // Changes for Stepped Pricing
                                            if(steppeddisposallst != null && steppeddisposallst.size() > 0)
                                            {
                                                ancillaryCharge.StepRates = steppeddisposallst;
                                            }
                                            ancillaryCharge.IsSteppedRate = true;
                                        }
                                        else 
                                        {
                                            ancillaryCharge.Cost =  pr.Disposal_Cost__c;
                                            ancillaryCharge.CostValueSymbol = pr.Disposal_Cost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            ancillaryCharge.Price = pr.Disposal_Price__c;
                                            ancillaryCharge.PriceValueSymbol = pr.Disposal_Price__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        } 
                                    }
                                }
                                else if(prFields.Data.commercial != null)
                                {
                                    if(sql.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP))
                                    {
                                        System.debug('@@@@@@@@~ in Pickup');
                                        ancillaryCharge.Cost = pr.Pickup_Cost__c;
                                        ancillaryCharge.CostUOMCode = apivalueUOMID;
                                        ancillaryCharge.CostUOM = apivalueUOMName;
                                        ancillaryCharge.CostValueSymbol = pr.Pickup_Cost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        productDtl.RateTypePickup =  pr.Pickup_Rate_Type__c;
                                        productDtl.PickupRecordId =  pr.Pickup_Record_Id__c;
                                        
                                        ancillaryCharge.PriceUOMCode = apivalueUOMID;
                                        ancillaryCharge.PriceUOM = apivalueUOMName;
                                        ancillaryCharge.Price = pr.Pickup_Price__c;
                                        ancillaryCharge.PriceValueSymbol = pr.Pickup_Price__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        
                                    }
                                    else if(sql.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP))
                                    {
                                        System.debug('@@@@@@@@~ ExtraPickup');
                                        ancillaryCharge.Cost = pr.Extra_Pickup_Cost__c;
                                        ancillaryCharge.CostValueSymbol = pr.Extra_Pickup_Cost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        productDtl.ExtraPickupRecordId =  pr.Extra_Pickup_Record_Id__c;
                                        
                                        ancillaryCharge.Price = pr.Extra_Pickup_Price__c;
                                        ancillaryCharge.PriceValueSymbol = pr.Extra_Pickup_Price__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        
                                    }
                                }
                                
                                // Changes for Stepped Pricing
                                sChargelst.add(ancillaryCharge);
                            }
                            else if(prFields.Data.serviceCharges != null)
                            {
                                for(Integer scIndex = 0; scIndex < prFields.Data.serviceCharges.size(); scIndex++)
                                {
                                    if(prFields.Data.serviceCharges[scIndex].name.contains(ancillaryCharge.ServiceName))
                                    {
                                        String costUOMId = costUOMMapName.get(prFields.Data.serviceCharges[scIndex].costUOM);
                                        String costUOMName = costUOMMapId.get(costUOMId);
                                        String priceUOMId = priceUOMMapName.get(prFields.Data.serviceCharges[scIndex].priceUOM);
                                        String priceUOMName = priceUOMMapId.get(priceUOMId);

                                        ancillaryCharge.CostValueType = prFields.Data.serviceCharges[scIndex].costValueType;
                                        ancillaryCharge.CostUOMCode = costUOMId;
                                        ancillaryCharge.CostUOM = costUOMName;
                                        ancillaryCharge.Cost = prFields.Data.serviceCharges[scIndex].cost;
                                        if(ancillaryCharge.Cost != null)
                                        {
                                            if (ancillaryCharge.CostValueType != null && ancillaryCharge.CostValueType.toLowercase() == System.label.Percent)
                                            {
                                                ancillaryCharge.CostValuePercent = Constant_Util.PERCENTAGE;
                                            }
                                            else
                                            {
                                                ancillaryCharge.CostValueSymbol =  currencySymbol;
                                            }
                                        }

                                        ancillaryCharge.PriceValueType = prFields.Data.serviceCharges[scIndex].priceValueType;
                                        ancillaryCharge.PriceUOMCode = priceUOMId;
                                        ancillaryCharge.PriceUOM = priceUOMName;
                                        ancillaryCharge.Price = prFields.Data.serviceCharges[scIndex].price;
                                        if(ancillaryCharge.Price != null)
                                        {
                                            if (ancillaryCharge.PriceValueType != null && ancillaryCharge.PriceValueType.toLowercase() == System.label.Percent)
                                            {
                                                ancillaryCharge.PriceValuePercent =  Constant_Util.PERCENTAGE;
                                            }
                                            else
                                            {
                                                ancillaryCharge.PriceValueSymbol =  currencySymbol;
                                            }
                                        }

                                        break;
                                    }
                                }
                                sChargelst.add(ancillaryCharge);
                            }
                            productDtl.ServiceCharges = sChargelst;
                        }
                    }
                    else
                    {
                        GreenPage gp = new GreenPage();
                        String francisePricingLink = '',  greenPagesLink = '';
                        francisePricingLink = prFields.data.wmMetaData != null ? prFields.data.wmMetaData.francisePricingLink : null;
                        greenPagesLink = prFields.data.wmMetaData != null ? prFields.data.wmMetaData.greenPagesLink : null;
                        if(pr.Zone_Type__c == System.label.WM_Franchise)
                        {
                            gp.Message = System.label.zoneFranchiseMsg;
                            gp.Market = System.label.Market_WM_Franchise;
                        }
                        else if(pr.Zone_Type__c == System.label.Competitor)
                        {
                            gp.Message = System.label.zoneCompetitorMsg;
                            gp.Market = System.label.Market_Non_WM_Franchise;
                        }
                        else if(pr.Zone_Type__c == System.label.Pre_Determined_Pricing)
                        {
                            gp.Message = System.label.zoneDeterminedMsg;
                            gp.Market = System.label.Market_WM_Pre_Determined_Pricing;
                        }
                        else if(pr.Zone_Type__c == System.label.Third_Party_Agreement)
                        {
                            gp.Message = System.label.zone3PAMsg;
                            gp.Market = System.label.Market_WM_Third_Party_Agreement;
                        }
                        gp.GPLabelName = francisePricingLink != null ? 'Franchise Pricing Link' : greenPagesLink != null ? 'Green Pages Link' : null;
                        gp.GPLabelLink = francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;

                        productDtl.GreenPages = gp;
                    }
                    qpWrapper.ProductDetails = productDtl;
                }
                else
                {	
                    //system.debug('prFields.Problem '+ prFields.Problem);
                    //system.debug('prFields.messages '+ prFields.messages);
                    Problem plm = new Problem();
                    //plm.ErrorMessage = prFields.Problem != null ? prFields.Problem.errors[0].message : 'reach here';
                    plm.ErrorMessage = prFields.messages != null && prFields.messages.size() > 0 ? prFields.messages[0].description : 'reach here';
                    qpWrapper.Problem = plm;
                }
            }
            else
            {
                Problem plm = new Problem();
                plm.ErrorMessage = pr.Case_Error_Message__c != null ? pr.Case_Error_Message__c : 'reach here';
                qpWrapper.Problem = plm;
            }
            wrapperList.Add(qpWrapper);
        }
        return wrapperList;
    }

    @AuraEnabled
    public static void acceptQLIPricingRequest(List<QuotePricingWrapper> qpWrapper, Boolean isPriceOnly){
        system.debug('@@@@~ isPriceOnly ' + isPriceOnly);
        Map<Id, QuotePricingWrapper> qbundleMap = new Map<Id, QuotePricingWrapper>();
        Map<Id, List<ServiceCharges>> sChargeMap = new Map<Id, List<ServiceCharges>>();
        List<SBQQ__QuoteLine__c> upsertQLLIst = new List<SBQQ__QuoteLine__c>();
        Set<String> vendorSet = new Set<String>();
        Map<String,Account> quoteVendorMap = new Map<String,Account>(); 
        List<Account> vendorLst = new List<Account>();
        Id vendorId= null;
        // boolean IsPricingAvailable =false;
        if(!qpWrapper.isEmpty())
        {
            for(QuotePricingWrapper qblst : qpWrapper)
            {
                if(qblst.Problem == null)
                {
                    sChargeMap.put(qblst.BundleLink, qblst.ProductDetails.ServiceCharges);

                    if(qblst.ProductDetails != null && qblst.ProductDetails.VendorCode != null)
                    {
                        vendorSet.add(qblst.ProductDetails.VendorCode);
                    }
                }
            }
            if(vendorSet != null && vendorSet.size()>0){
                vendorLst = [SELECT Id, Vendor_ID__c FROM Account WHERE Status__c = 'Active' AND Vendor_ID__c IN : vendorSet];
            }
    
            if(!vendorLst.isEmpty()){
                for(Account ven : vendorLst){
                    quoteVendorMap.put(ven.Vendor_ID__c,ven);
                }
            }
            for(QuotePricingWrapper qblst : qpWrapper)
            { 
                
                if(qblst.Problem == null && qblst.ProductDetails.GreenPages == null)
                {   
                    //Add value in Bundle Header - Start
                    SBQQ__QuoteLine__c sqlHdr = new SBQQ__QuoteLine__c();
                    sqlHdr.Id = qblst.BundleLink;
                    sqlHdr.CurrencyIsoCode = qblst.CurrencyCode;
                    sqlHdr.BypassPriceReview__c = qblst.BypassPriceReview;
                   // sqlHdr.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);

                    if(isPriceOnly)
                        sqlHdr.Pricing_Only_Request__c = qblst.PricingRequestLink;
                    else
                        sqlHdr.Pricing_Request__c = qblst.PricingRequestLink;

                    if(qblst.ProductDetails != null)
                    {
                        //Comment Code for SDT-31291 : Start
                        // if(qblst.ProductDetails.EquipmentSize != null)
                        // {
                        //     sqlHdr.Equipment_Size__c = qblst.ProductDetails.EquipmentSize;
                        //     sqlHdr.Original_Equipment_Size__c = qblst.ProductDetails.OriginalEquipmentSize;
                        // }

                        //Use isPriceOnly for SDT-20125
                        if(!isPriceOnly && qblst.ProductDetails.SourceCode != null)
                        {
                            String sourceCodeStr = qblst.ProductDetails.SourceCode;
                            sqlHdr.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? qblst.PricingReqId : sourceCodeStr;
                            //sqlHdr.Vendor_Service_Location_Code__c = qblst.ProductDetails.SourceCode;
                        }
                        if(qblst.ProductDetails.VendorCode != null)
                        {
                            if(quoteVendorMap != null && quoteVendorMap.size() > 0)
                            {
                                vendorId = quoteVendorMap.get(qblst.ProductDetails.VendorCode) != null ? quoteVendorMap.get(qblst.ProductDetails.VendorCode).Id : null;
                            }
                            sqlHdr.Vendor__c = vendorId;
                        }
                    }
                    upsertQLLIst.add(sqlHdr);
                    //Add value in Bundle Header - End

                    List<ServiceCharges> sChargelst = new List<ServiceCharges>();
                    sChargelst = sChargeMap.get(qblst.BundleLink);

                    for(ServiceCharges sCharge : sChargelst)
                    {
                        SBQQ__QuoteLine__c sql = new SBQQ__QuoteLine__c();
                        sql.Id = sCharge.ServiceId;
                        sql.CurrencyIsoCode = qblst.CurrencyCode;
                        sql.BypassPriceReview__c = qblst.BypassPriceReview;

                        if(isPriceOnly)
                            sql.Pricing_Only_Request__c = qblst.PricingRequestLink;
                        else
                            sql.Pricing_Request__c = qblst.PricingRequestLink;

                        if(qblst.ProductDetails != null)
                        {
                            if(qblst.ProductDetails.VendorCode != null){
                                sql.Vendor__c = vendorId;
                            }

                            //Comment Code for SDT-31291 : Start
                            // if(qblst.ProductDetails.EquipmentSize != null){
                            //     sql.Equipment_Size__c = qblst.ProductDetails.EquipmentSize;
                            //     sql.Original_Equipment_Size__c = qblst.ProductDetails.OriginalEquipmentSize;
                            // }

                            if(!isPriceOnly && qblst.ProductDetails.SourceCode != null)
                            {
                                String sourceCodeStr = qblst.ProductDetails.SourceCode;
                                sql.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? qblst.PricingReqId : sourceCodeStr;
                                //sql.Vendor_Service_Location_Code__c = qblst.ProductDetails.SourceCode;
                            }
                        }

                        if(sCharge.ServiceName.equals(Constant_Util.HAUL) || sCharge.ServiceName.equals(Constant_Util.DISPOSAL)
                        || sCharge.ServiceName.equals(Constant_Util.PR_PICKUP) || sCharge.ServiceName.equals(Constant_Util.PR_EXTRA_PICKUP))
                        {
                            if(!sCharge.IsSteppedRate)
                            {
                                sql.SBQQ__UnitCost__c = sCharge.Cost != null ? sCharge.Cost : sql.SBQQ__UnitCost__c;
                                sql.SBQQ__ListPrice__c = sCharge.Price != null ? sCharge.Price : sql.SBQQ__ListPrice__c;
                            }
                            else
                            {
                                sql.SBQQ__UnitCost__c = sCharge.IsSteppedRateCost ? 0 : sCharge.Cost != null ? sCharge.Cost : sql.SBQQ__UnitCost__c;
                                sql.SBQQ__ListPrice__c = sCharge.IsSteppedRatePrice ? 0 : sCharge.Price != null ? sCharge.Price : sql.SBQQ__ListPrice__c;
                                sql.CostModelType__c = sCharge.IsSteppedRateCost ? 'STP' : 'PER';
                                sql.SBQQ__PricingMethod__c = sCharge.IsSteppedRatePrice ? 'STP' : 'List';
                            }

                            if(sCharge.ServiceName.equals(Constant_Util.HAUL))
                            {
                                sql.Pricing_API_Method__c = qblst.ProductDetails.RateTypeHaul;
                            }
                            else if(sCharge.ServiceName.equals(Constant_Util.DISPOSAL))
                            {
                                sql.Pricing_API_Method__c = qblst.ProductDetails.RateTypeDisposal;
                                if(sCharge.CostUOMCode != null){
                                    sql.Cost_Unit_of_Measure__c = sCharge.CostUOMCode;
                                }
                                if(sCharge.PriceUOMCode!=null){
                                    sql.PriceUOM__c = sCharge.PriceUOMCode;
                                }
                                
                                if(sCharge.IsSteppedRate)
                                {
                                    Integer steppedCounter = 1;
                                    for(StepRate sRate : sCharge.StepRates)
                                    {
                                        system.debug('In switch case - Counter ' + steppedCounter);
                                        switch on steppedCounter 
                                        {
                                            when 1 
                                            {
                                                if(sCharge.IsSteppedRateCost)
                                                {
                                                    sql.CostUpTo1__c = sRate.StepCostUpTo != null ? sRate.StepCostUpTo : sql.CostUpTo1__c;
                                                    sql.CostPrice1__c = sRate.StepCost != null ? sRate.StepCost : sql.CostPrice1__c;
                                                }
                                                if(sCharge.IsSteppedRatePrice)
                                                {
                                                    sql.PriceUpTo1__c = sRate.StepPriceUpTo != null ? sRate.StepPriceUpTo : sql.PriceUpTo1__c;
                                                    sql.PricePrice1__c = sRate.StepPrice != null ? sRate.StepPrice : sql.PricePrice1__c;
                                                }
                                            }
                                            when 2
                                            {
                                                if(sCharge.IsSteppedRateCost)
                                                {
                                                    sql.CostUpTo2__c = sRate.StepCostUpTo != null ? sRate.StepCostUpTo : sql.CostUpTo2__c;
                                                    sql.CostPrice2__c = sRate.StepCost != null ? sRate.StepCost : sql.CostPrice2__c;
                                                }
                                                if(sCharge.IsSteppedRatePrice)
                                                {
                                                    sql.PriceUpTo2__c = sRate.StepPriceUpTo != null ? sRate.StepPriceUpTo : sql.PriceUpTo2__c;
                                                    sql.PricePrice2__c = sRate.StepPrice != null ? sRate.StepPrice : sql.PricePrice2__c;
                                                }
                                            }
                                            when 3
                                            {
                                                if(sCharge.IsSteppedRateCost)
                                                {
                                                    sql.CostUpTo3__c = sRate.StepCostUpTo != null ? sRate.StepCostUpTo : sql.CostUpTo3__c;
                                                    sql.CostPrice3__c = sRate.StepCost != null ? sRate.StepCost : sql.CostPrice3__c;
                                                }
                                                if(sCharge.IsSteppedRatePrice)
                                                {
                                                    sql.PriceUpTo3__c = sRate.StepPriceUpTo != null ? sRate.StepPriceUpTo : sql.PriceUpTo3__c;
                                                    sql.PricePrice3__c = sRate.StepPrice != null ? sRate.StepPrice : sql.PricePrice3__c;
                                                }
                                            }
                                            when 4
                                            {
                                                if(sCharge.IsSteppedRateCost)
                                                {
                                                    sql.CostUpTo4__c = sRate.StepCostUpTo != null ? sRate.StepCostUpTo : sql.CostUpTo4__c;
                                                    sql.CostPrice4__c = sRate.StepCost != null ? sRate.StepCost : sql.CostPrice4__c;
                                                }
                                                if(sCharge.IsSteppedRatePrice)
                                                {
                                                    sql.PriceUpTo4__c = sRate.StepPriceUpTo != null ? sRate.StepPriceUpTo : sql.PriceUpTo4__c;
                                                    sql.PricePrice4__c = sRate.StepPrice != null ? sRate.StepPrice : sql.PricePrice4__c;
                                                }
                                            }
                                        }
                                        steppedCounter++;
                                    }
                                }
                            }
                            else if(sCharge.ServiceName.equals(Constant_Util.PR_PICKUP))
                            {
                                sql.Pricing_API_Method__c = qblst.ProductDetails.RateTypePickup;
                                if(sCharge.CostUOMCode != null){
                                    sql.Cost_Unit_of_Measure__c = sCharge.CostUOMCode;

                                }
                        
                                if(sCharge.PriceUOMCode != null){
                                    sql.PriceUOM__c = sCharge.PriceUOMCode;
                                }
                               
                            }
                        }
                        else
                        {
                            if(sCharge.Cost != null)
                            {
                                if(sCharge.CostUOM != null){
                                    sql.Cost_Unit_of_Measure__c = sCharge.CostUOM;
                                }
                                
                                if(sCharge.CostValueType != null && sCharge.CostValueType.equals(Constant_Util.PERCENT))
                                {
                                    sql.SBQQ__SubscriptionPercent__c = sCharge.Cost;
                                    sql.SBQQ__UnitCost__c = 0.00;
                                }
                                else
                                {
                                    sql.SBQQ__UnitCost__c = sCharge.Cost;
                                }
                            }
                            if(sCharge.Price != null)
                            {
                                if(sCharge.priceUOMCode != null){
                                    sql.PriceUOM__c = sCharge.priceUOMCode;
                                }
                                
                                if(sCharge.PriceValueType != null && sCharge.PriceValueType.equals(Constant_Util.PERCENT))
                                {
                                    sql.SBQQ__MarkupRate__c = sCharge.Price;
                                    sql.SBQQ__ListPrice__c = 0.00;
                                }
                                else
                                {
                                    sql.SBQQ__ListPrice__c = sCharge.Price;
                                }
                            }
                        }
                        System.debug('Bundle Set Value : '+ sql);
                        upsertQLLIst.add(sql);
                    }
                }
            }
            if(upsertQLLIst.size() > 0 && !upsertQLLIst.isEmpty()){
                System.debug('upsert list -- ' + upsertQLLIst);
                try{
                    //Skip QL validation for Cost/Price, SDT-26002
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = true;
                    upsert upsertQLLIst;
                }catch(Exception e){
                    System.debug('Exception caught -- ' + e.getMessage());
                }
                finally
                {
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = false;
                }
            }
        }
    }

    @AuraEnabled
    public static List<QLIPricingWrapper> getPricingResponseStatus(String quoteID){
        list<QLIPricingWrapper> wrapperList = new list<QLIPricingWrapper>();
        Boolean IsMultiVendor = false;
        //Hot Fix Changes
        List<SBQQ__QuoteLine__c> bundles = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, SBQQ__Quote__c, SBQQ__Quote__r.Name, Name, 
                                            SBQQ__ProductName__c, Material_Type__c, Equipment_Size__c, Pricing_Request__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__Quote__c =: quoteID AND SBQQ__RequiredBy__c = null ]; //AND SBQQ__Product__r.Is_Pricing_Eligible__c = TRUE
        List<Pricing_Request__c> priqList = [SELECT Id, Name, tolabel(Pricing_Type__c), Container_Type__c, toLabel(Container_Size__c), toLabel(Material_Code__c), Service_Type__c, Quote__c, APIRequestOutput__c, 
                                            Quote_Line_Bundle__c, Zone_Type__c, isAPIResult__c, Vendor_Code__c, Is_Multi_Vendor__c
                                            FROM Pricing_Request__c
                                            WHERE Quote__c =: quoteID Order By CreatedDate DESC];
        if(priqList.size() == 0){
            return wrapperList;
        }
        for(Pricing_Request__c pr : priqList){
            if(pr.Is_Multi_Vendor__c){
                IsMultiVendor = true;
                break;
            }
        }
        //
        if(PricingRequestSelector.isPricingMulltiVendorAMSwitchON() 
        && bundles[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c == Constant_Util.NEW_SERVICE 
        && IsMultiVendor)
            wrapperList = getPricingResponseStatusMultiVendor(quoteID, bundles, priqList);
        else
            wrapperList = getPricingResponseStatusSingleVendor(quoteID, bundles, priqList);
        return wrapperList;
    }

    public static List<QLIPricingWrapper> getPricingResponseStatusSingleVendor(String quoteID, List<SBQQ__QuoteLine__c> bundles, List<Pricing_Request__c> priqList)
    {
        System.debug('@@@@@@@~ IN  getPricingResponseStatus');
        list<QLIPricingWrapper> wrapperList = new list<QLIPricingWrapper>();
        PricingReportingFieldsMetadata reportingFields = new PricingReportingFieldsMetadata();   
        //List<String> prMaterialCodeLst = UTIL_Picklist.getPickListValuesIntoList('Pricing_Request__c', 'Material_Code__c');
        //List<String> prContainerSizeLst = UTIL_Picklist.getPickListValuesIntoList('Pricing_Request__c', 'Container_Size__c');
        //Map<String,String> materialMap = new Map<String,String>();
        //Map<String,String> containerMap = new Map<String,String>();
        /*for(String mc : prMaterialCodeLst){
            materialMap.put(mc.split(',').get(1), mc.split(',').get(0));
        }
        for(String cs : prContainerSizeLst){
            containerMap.put(cs.split(',').get(1), cs.split(',').get(0));
        }*/
        if(priqList.size() > 0)
        {
            String containerSize = '', materialCode = ''; 
            for(SBQQ__QuoteLine__c ql : bundles)
            {//BundleLink {get;set;}BundleID
                for(Pricing_Request__c pr : priqList)
                {
                    if(pr.Quote_Line_Bundle__c == ql.Id)
                    {
                        QLIPricingWrapper wrapperClass = new QLIPricingWrapper();
                        wrapperClass.BundleID = ql.Id;
                        wrapperClass.BundleLink = ql.Name;
                        wrapperClass.PricingType = pr.Pricing_Type__c;
                        system.debug('ql.Name--->'+ql.Name);
                    
                            wrapperClass.PricingReqId = pr.Id;
                            wrapperClass.PricingRequestLink = pr.Name;
                            //containerSize = containerMap.get(pr.Container_Size__c);
                            //materialCode = materialMap.get(pr.Material_Code__c);
                            wrapperClass.Container = pr.Container_Size__c + ' ' + ql.SBQQ__ProductName__c + ' ' + pr.Material_Code__c;
                            //wrapperClass.Resultant = 'PR Created';
                            
                            if(pr.isAPIResult__c)
                            {
                                reportingFields = PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c);

                                String francisePricingLink = '',  greenPagesLink = '';
                                francisePricingLink = reportingFields.data.wmMetaData != null ? 'Franchise Pricing Link: ' + reportingFields.data.wmMetaData.francisePricingLink : null;
                                greenPagesLink = reportingFields.data.wmMetaData != null ? 'Green Pages Link: ' + reportingFields.data.wmMetaData.greenPagesLink : null;
                                if(pr.Zone_Type__c == System.label.WM_Franchise)
                                {
                                    wrapperClass.PricingResponse = System.label.Market_WM_Franchise;
                                    wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                                    system.debug('wrapperClass--->'+wrapperClass);
                                }
                                else if(pr.Zone_Type__c == System.label.Competitor)
                                {
                                    wrapperClass.PricingResponse = System.label.Market_Non_WM_Franchise;
                                    wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                                }
                                else if(pr.Zone_Type__c == System.label.Pre_Determined_Pricing)
                                {
                                    wrapperClass.PricingResponse = System.label.Market_WM_Pre_Determined_Pricing;
                                    wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                                }
                                else if(pr.Zone_Type__c == System.label.Third_Party_Agreement)
                                {
                                    wrapperClass.PricingResponse = System.label.Market_WM_Third_Party_Agreement;
                                    wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                                }
                                else
                                {
                                    wrapperClass.PricingResponse = 'Pricing created successfully';
                                    system.debug('wrapperClass--->'+wrapperClass);
                                }
                            }
                            else
                            {
                                if(pr.APIRequestOutput__c != null)
                                {
                                    reportingFields = PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c);
                                    wrapperClass.PricingResponse = reportingFields.Problem != null ? reportingFields.Problem.errors[0].message : 'API Error';
                                }
                                else
                                {
                                    wrapperClass.PricingResponse = 'In Progress/Not get API response.';
                                }
                            }
                        wrapperList.add(wrapperClass);
                    }
                    // else
                    // {
                    //     wrapperClass.PricingResponse = 'API Error';
                    // }
                    
                }
                
                system.debug('wrapperList--->'+wrapperList);
            }
        }
        else
        {

        }
        return wrapperList;
    }

    public static List<QLIPricingWrapper> getPricingResponseStatusMultiVendor(String quoteID, List<SBQQ__QuoteLine__c> bundles, List<Pricing_Request__c> priqList)
    {
        System.debug('@@@@@@@~ IN  getPricingResponseStatusMultiVendor');
        list<QLIPricingWrapper> wrapperList = new list<QLIPricingWrapper>();
        PricingReportingFieldsMetadata prSingleVendor = new PricingReportingFieldsMetadata();
        PricingRequestFieldsMetadata prMultiVendor = new PricingRequestFieldsMetadata();
        Map<Id, List<Pricing_Request__History>> prHistoryMap = new Map<Id, List<Pricing_Request__History>>();

        Set<Id> prIdSet = new Set<Id>();
        for(Pricing_Request__c pr : priqList){
            prIdSet.add(pr.Id);
        }
        List<Pricing_Request__History> priqListHistory = [SELECT Id, ParentId, Parent.Name, tolabel(Parent.Pricing_Type__c), OldValue, NewValue, Field FROM Pricing_Request__History  WHERE ParentId  =: prIdSet and Field = 'Vendor_Code__c' ORDER BY CreatedDate DESC];
        System.debug('priqListHistory : ' +priqListHistory);

        for(Pricing_Request__History prHistory : priqListHistory){
            if(prHistoryMap.containsKey(prHistory.ParentId)){
                List<Pricing_Request__History> prhlst = prHistoryMap.get(prHistory.ParentId);
                prhlst.add(prHistory);
                prHistoryMap.put(prHistory.ParentId, prhlst);
            }
            else{
                prHistoryMap.put(prHistory.ParentId, new  List<Pricing_Request__History>{ prHistory });
            }
        }

        if(priqList.size() > 0)
        {
            String containerSize = '', materialCode = ''; 
            for(SBQQ__QuoteLine__c ql : bundles)
            {
                for(Pricing_Request__c pr : priqList)
                {
                    if(pr.Quote_Line_Bundle__c == ql.Id)
                    {
                        QLIPricingWrapper wrapperClass = new QLIPricingWrapper();
                        wrapperClass.BundleID = ql.Id;
                        wrapperClass.BundleLink = ql.Name;
                        wrapperClass.PricingType = pr.Pricing_Type__c;
                        wrapperClass.IsMultiVendorPriceOn = true;
                        wrapperClass.VendorId = (pr.Vendor_Code__c != null && pr.Vendor_Code__c.contains('|')) ? pr.Vendor_Code__c.substringBefore('|') : pr.Vendor_Code__c;
                        system.debug('ql.Name--->'+ql.Name);
                    
                        wrapperClass.PricingReqId = pr.Id;
                        wrapperClass.PricingRequestLink = pr.Name;

                        // containerSize = containerMap.get(pr.Container_Size__c);
                        // materialCode = materialMap.get(pr.Material_Code__c);
                        wrapperClass.Container = pr.Container_Size__c + ' ' + ql.SBQQ__ProductName__c + ' ' + pr.Material_Code__c;
                        
                        if(pr.isAPIResult__c)
                        {
                            String francisePricingLink = '',  greenPagesLink = '';
                            if(pr.Pricing_Type__c == 'Price Only'){
                                prSingleVendor = PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c);
                                francisePricingLink = prSingleVendor.data.wmMetaData != null ? 'Franchise Pricing Link: ' + prSingleVendor.data.wmMetaData.francisePricingLink : null;
                                greenPagesLink = prSingleVendor.data.wmMetaData != null ? 'Green Pages Link: ' + prSingleVendor.data.wmMetaData.greenPagesLink : null;
                            }
                            else{
                                prMultiVendor = PricingRequestFieldsMetadata.parse(pr.APIRequestOutput__c);
                                PricingRequestFieldsMetadata.suppliers prMVFields = new PricingRequestFieldsMetadata.suppliers();
                                if(prMultiVendor != null && prMultiVendor.data != null){
                                    for(PricingRequestFieldsMetadata.suppliers spp : prMultiVendor.data.suppliers)
                                    {
                                        system.debug('PR value: ' + pr);
                                        system.debug('spp value: ' + spp);
                                        if(spp.supplierCode != null && (pr.Vendor_Code__c != null && spp.supplierCode.contains(pr.Vendor_Code__c))){
                                            prMVFields = spp;
                                        }
                                    }
                                }                

                                if(prMVFields != null){
                                    francisePricingLink = prMVFields.wmMetaData != null ? 'Franchise Pricing Link: ' + prMVFields.wmMetaData.francisePricingLink : null;
                                    greenPagesLink = prMVFields.wmMetaData != null ? 'Green Pages Link: ' + prMVFields.wmMetaData.greenPagesLink : null;
                                }
                            }                            
                            if(pr.Zone_Type__c == System.label.WM_Franchise)
                            {
                                wrapperClass.PricingResponse = System.label.Market_WM_Franchise;
                                wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                                system.debug('wrapperClass--->'+wrapperClass);
                            }
                            else if(pr.Zone_Type__c == System.label.Competitor)
                            {
                                wrapperClass.PricingResponse = System.label.Market_Non_WM_Franchise;
                                wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                            }
                            else if(pr.Zone_Type__c == System.label.Pre_Determined_Pricing)
                            {
                                wrapperClass.PricingResponse = System.label.Market_WM_Pre_Determined_Pricing;
                                wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                            }
                            else if(pr.Zone_Type__c == System.label.Third_Party_Agreement)
                            {
                                wrapperClass.PricingResponse = System.label.Market_WM_Third_Party_Agreement;
                                wrapperClass.PricingResponse += '\n' + francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                            }
                            else
                            {
                                wrapperClass.PricingResponse = 'Pricing created successfully';
                                system.debug('wrapperClass--->'+wrapperClass);
                            }
                        }
                        else
                        {
                            if(pr.APIRequestOutput__c != null)
                            {
                                if(pr.Pricing_Type__c == 'Price Only'){
                                    prSingleVendor = PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c);
                                    wrapperClass.PricingResponse = prSingleVendor.Problem != null ? prSingleVendor.Problem.errors[0].message : 'API Error';
                                }
                                else{
                                    prMultiVendor = PricingRequestFieldsMetadata.parse(pr.APIRequestOutput__c);
                                    wrapperClass.PricingResponse = prMultiVendor.Problem != null ? prMultiVendor.Problem.errors[0].message : 'API Error';
                                }
                            }
                            else
                            {
                                wrapperClass.PricingResponse = 'In Progress/Not get API response.';
                            }
                        }

                        //Add Pricing History Logic
                        List<VendorTracking> vtList = new List<VendorTracking>();
                        if(prHistoryMap != null && prHistoryMap.size() > 0){
                            List<Pricing_Request__History> prhList = prHistoryMap.get(pr.Id);
                            if(prhList != null){
                                for(Pricing_Request__History prh: prhList){
                                   if(prh.ParentId == ql.Pricing_Request__c){                           
                                        VendorTracking vt = new VendorTracking();
                                        vt.PricingReqId = prh.Parent.Name;
                                        vt.PricingType = prh.Parent.Pricing_Type__c;
                                        vt.OldVendor = String.valueOf(prh.OldValue);
                                        vt.NewVendor = String.valueOf(prh.NewValue);

                                        vtList.add(vt);
                                    }
                                }
                                wrapperClass.VendorTracking = vtList;
                            }
                        }
                        wrapperList.add(wrapperClass);
                    }
                }
                system.debug('wrapperList--->'+wrapperList);
            }
        }
        else
        {

        }
        return wrapperList;
    }

    @AuraEnabled
    public static void CreatePricingOnlyRequest(string quoteLineID, string reasonValue, string reasonDescription){
        system.debug('QuoteLineId From Get Price@@'+quoteLineID);
        if(validatePriceOnlyCall(quoteLineID))
        {
            List<SBQQ__QuoteLine__c> qlList = [SELECT Id, Price_Only_Reason__c, Reason_Description__c
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE Id =: quoteLineID]; //SBQQ__RequiredBy__c =: quoteLineID OR

            if(qlList != null && qlList.size() > 0)
            {
                List<SBQQ__QuoteLine__c> updateQL = new List<SBQQ__QuoteLine__c>();
                for(SBQQ__QuoteLine__c sql : qlList)
                {
                    sql.Price_Only_Reason__c = reasonValue;
                    sql.Reason_Description__c = reasonDescription;
                    
                    updateQL.add(sql);
                }

                update updateQL;
            }
            //START - SDT-31298
            //CreatePricingRequest.createPriceOnlyPR(quoteLineID);
            Set<ID> bundleIdSet = new Set<Id>();
            bundleIdSet.add(quoteLineID);
            PriceOnlyRequestSTPProcess.createPricingRequestForMultiBundle(bundleIdSet, true);
            //END - SDT-31298
        }
    }

    public static Boolean validatePriceOnlyCall(string quoteLineID)
    {
        Boolean isValidCall;
        String sourceCode;

        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, SBQQ__UnitCost__c, Cost_Unit_of_Measure__c, sCode__c, SBQQ__ListPrice__c, SBQQ__ProductCode__c,SBQQ__ProductName__c, Vendor__c, Vendor__r.Vendor_ID__c, Vendor_Service_Location_Code__c
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__RequiredBy__c =: quoteLineID
                                                and SBQQ__ProductCode__c IN ('DSP','H','PCK')];        
        
        if(qlList != null && qlList.size() > 0)
        {
            for(SBQQ__QuoteLine__c ql : qlList)
            {
                sourceCode = ql.Vendor_Service_Location_Code__c;

                //Changes done for SDT-21363
                if(ql.sCode__c != 'CAM' && ql.sCode__c != 'CTY' && ql.sCode__c != 'FRCH' && ql.sCode__c != 'UTL' && ql.sCode__c != 'LL')
                {
                    if((ql.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL) || ql.SBQQ__ProductName__c.equals(Constant_Util.HAUL)
                    || ql.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP))
                    && (ql.SBQQ__ListPrice__c == null || ql.SBQQ__ListPrice__c == 0)
                    && ql.SBQQ__UnitCost__c != null)
                    {
                        isValidCall = true;
                        break;
                    }
                    if(ql.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP) 
                    && ql.Cost_Unit_of_Measure__c == 'MTH' && (ql.SBQQ__ListPrice__c == null || ql.SBQQ__ListPrice__c == 0)
                    && ql.SBQQ__UnitCost__c != null)
                    {
                        isValidCall = true;
                        break;
                    }
                }
            }
        }

        return isValidCall;
    }

    @AuraEnabled
    public static QuotePricingWrapper getPriceOnlyReasonList()
    {
        QuotePricingWrapper wrapper = new QuotePricingWrapper();
        Map<String,String> prValue = new Map<String,String>();
        List<String> pckValuelist =  UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c','Price_Only_Reason__c');
        for(String pckValue : pckValuelist){
            prValue.put(pckValue.split(',').get(1), pckValue.split(',').get(0));
        }

        wrapper.PriceOnlyReason = prValue;

        return wrapper;
    } 

    public with sharing class QLIPricingWrapper
    {
    	//New value added for popup- 
    	@AuraEnabled public String BundleID {get;set;}
   	@AuraEnabled public String BundleLink {get;set;}
    	@AuraEnabled public String Container  {get;set;}
    	@AuraEnabled public String PricingType  {get;set;}
    	@AuraEnabled public String VendorId  {get;set;}
        @AuraEnabled public String Resultant  {get;set;}
    	@AuraEnabled public String PricingResponse {get;set;}
    	@AuraEnabled public String PricingRequestLink {get;set;}
   	@AuraEnabled public String PricingReqId {get;set;}
   	@AuraEnabled public String GreenPageLink {get;set;}    
   	@AuraEnabled public List<VendorTracking> VendorTracking {get;set;}    
   	@AuraEnabled public Boolean IsMultiVendorPriceOn {get;set;}    
    } 

    public with sharing class VendorTracking
    {
    	@AuraEnabled public String PricingReqId {get;set;}
    	@AuraEnabled public String PricingType {get;set;}
    	@AuraEnabled public String OldVendor {get;set;}
    	@AuraEnabled public String NewVendor {get;set;}
    }
}