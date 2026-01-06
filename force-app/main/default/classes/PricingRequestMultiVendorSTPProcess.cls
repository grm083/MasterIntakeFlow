//SDT-20689 -Multi Vendor Pricing Response
//Author: TCS - akotawal
//This class is used for the new pricing flow for New Service cases
public with sharing class PricingRequestMultiVendorSTPProcess {

    public with sharing class QuotePricingMVWrapper
    {
        @AuraEnabled public List<QuotePricingWrapper> selectedVendor {get;set;}
        @AuraEnabled public List<QuotePricingWrapper> multiVendor {get;set;}
    }
    public with sharing class QuotePricingWrapper {
        @AuraEnabled public String QuoteID {get;set;}
        @AuraEnabled public String BundleID {get;set;}
        @AuraEnabled public String BundleLink {get;set;}
        @AuraEnabled public String PricingReqId {get;set;}
        @AuraEnabled public String PricingRequestLink {get;set;}
        @AuraEnabled public String ProductName  {get;set;}
        @AuraEnabled public String LOB  {get;set;}
        @AuraEnabled public String ProcurementErrorMessage {get;set;}
        @AuraEnabled public Boolean IsVendorMismatchError {get;set;}
        @AuraEnabled public List<ProductDetail> ProductDetailsList {get;set;}
        @AuraEnabled public Problem Problem {get;set;}
        @AuraEnabled public Map<String,String> PriceOnlyReason {get; set;}
        @AuraEnabled public Integer VendorCount {get; set;}
    }
    
    public with sharing class PricingError{
        @AuraEnabled public String ProcurementErrorMessage {get;set;}
        @AuraEnabled public String QuoteLineBundle {get;set;}
    }
    
    public with sharing class ProductDetail{
        @AuraEnabled public String StartDate  {get;set;}
        @AuraEnabled public String EndDate  {get;set;}
        @AuraEnabled public String SourceCode  {get;set;}
        @AuraEnabled public String TargetTrackingId  {get;set;}
        @AuraEnabled public String VendorCode  {get;set;}
        @AuraEnabled public String VendorType  {get;set;}
        @AuraEnabled public String Vendor  {get;set;}
        @AuraEnabled public Decimal BaselineId  {get;set;}
        @AuraEnabled public Boolean IsPriceChangeRequest  {get;set;}
        @AuraEnabled public String BusinessUnit  {get;set;}
        @AuraEnabled public String MASUniqueId  {get;set;}
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
        @AuraEnabled public String CostOnlyMessage {get;set;}
        @AuraEnabled public List<GreenPage> GreenPages {get;set;}
        @AuraEnabled public List<ServiceCharges> ServiceCharges {get;set;}
        @AuraEnabled public String VendorComments  {get;set;}
        @AuraEnabled public Integer VendorRank  {get;set;}
        @AuraEnabled public List<Message> vendorMessage  {get;set;}         
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
    public with sharing class Message{
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String description {get;set;}
    }
    public with sharing class GreenPage{
        @AuraEnabled public String Message {get;set;}
        @AuraEnabled public String Market {get;set;}
        @AuraEnabled public String GPLabelName {get;set;}
        @AuraEnabled public String GPLabelLink {get;set;}
        @AuraEnabled public String ZoneName {get;set;}
        @AuraEnabled public String ZoneDescription {get;set;}
        @AuraEnabled public String ZoneNote {get;set;}
    }
    
    public class STPStatusWrapper{
        @AuraEnabled public Boolean IsInvokeSTP {get;set;}
        @AuraEnabled public String QuoteId {get;set;}
        @AuraEnabled public String QuoteProcuredStatus {get;set;}
        @AuraEnabled public String QuoteStatus {get;set;}
    }    

    /*@methodName- getPricingMultiVendorDetails
    *@description- Method to create the wrapper for pricing output UI from Quote and QuoteLine records
    *@param- Id : QuoteId
    *@return- List of wrapper - QuotePricingWrapper
    */    
    @AuraEnabled(cacheable=false)
    public static QuotePricingMVWrapper getPricingMultiVendorDetails(ID quoteID)
    {
        QuotePricingMVWrapper wrapperLst = new QuotePricingMVWrapper();
        wrapperLst.selectedVendor  = getPricingDetails(quoteID, true);
        wrapperLst.multiVendor = getPricingDetails(quoteID, false);
        return wrapperLst;
    }

    /*@methodName- getPricingDetails
    *@description- Method to create the wrapper for pricing output UI from Quote and QuoteLine records
    *@param- Id : QuoteId, Boolean isSelectedVendor
    *@return- List of wrapper - QuotePricingWrapper
    */
    @AuraEnabled(cacheable=true)
    public static List<QuotePricingWrapper> getPricingDetails(ID quoteID, Boolean isSelectedVendor) {
        
        
        PricingRequestFieldsMetadata prFields = new PricingRequestFieldsMetadata();
        list<QuotePricingWrapper> wrapperList = new list<QuotePricingWrapper>();
        Map<String,String> equipmentSizeMap = new Map<String,String>();
        Map<String,String> durationMap = new Map<String,String>();
        Map<String,String> costUOMMap = new Map<String,String>();
        Map<String,String> priceUOMMap = new Map<String,String>();
        Set<Id> bundleIDSet = new Set<Id>();
        String currencySymbol;
        //Map<Id,SBQQ__QuoteLine__c> quoteHdrMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,List<SBQQ__QuoteLine__c>> quoteLineSrvMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
        Map<String, String> pricingSTPMap = new Map<String, String>();
        
        List<SBQQ__QuoteLine__c> bundles = PricingRequestSelector.getQuoteLineList(quoteID);
       
        Integer bundlesCount = bundles.size();
        List<Pricing_Request__c> prList = PricingRequestSelector.getStandardPricingRequestList(quoteID, bundlesCount);
        

        for(SBQQ__QuoteLine__c qlId : bundles)
        {
            bundleIDSet.add(qlId.Id);
        }
        Set<string> productFamilyList = new Set<string>{'Rolloff','Commercial','Services','Waste Stream','Supplies','Surcharges and Fees'};
        List<PricingSTP__mdt> pricingSTP = [SELECT Id, ServiceChargeName__c, ServiceChargeCode__c, APIServiceChargeCode__c FROM PricingSTP__mdt WHERE IsActive__c = true];
        for(PricingSTP__mdt prSTP : pricingSTP){
            pricingSTPMap.put(prSTP.APIServiceChargeCode__c, prSTP.ServiceChargeCode__c);
        }
        //added Is_Vendor_Mismatch__c in query as part of SDT 30956
        //added Pricing_Error__c as part of 31114
        List<SBQQ__QuoteLine__c> qlBuldle = [SELECT Id, Is_Vendor_Mismatch__c, BundleProcuredStatus__c, Pricing_Error__c,ProcurementErrorMessage__c, SBQQ__ProductCode__c, SBQQ__ProductName__c, SBQQ__Quote__c, Occurrence_Type__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, PriceUOM__c, SBQQ__ListPrice__c, 
                                            SBQQ__RequiredBy__c, SBQQ__CustomerPrice__c, Pricing_API_Method__c, CostModelType__c, SBQQ__PricingMethod__c, SBQQ__SubscriptionPercent__c, SBQQ__MarkupRate__c  
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__RequiredBy__c IN: bundleIDSet AND SBQQ__ProductFamily__c IN: productFamilyList];
        
        
        for(SBQQ__QuoteLine__c qlSrvReq : qlBuldle)
        {
            if (quoteLineSrvMap.containsKey(qlSrvReq.SBQQ__RequiredBy__c)) 
            {
                List<SBQQ__QuoteLine__c> quotelst = quoteLineSrvMap.get(qlSrvReq.SBQQ__RequiredBy__c);
                quotelst.add(qlSrvReq);
                quoteLineSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c, quotelst);
            } 
            else 
            {
                quoteLineSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{ qlSrvReq });
            }                                  
        }

        List<Schema.PicklistEntry> containerTypePicklist = Schema.SObjectType.Pricing_Request__c.fields.Container_Type__c.getPicklistValues();
        List<Schema.PicklistEntry> containerSizePicklist = Schema.SObjectType.Pricing_Request__c.fields.Container_Size__c.getPicklistValues();
            
        //creating a wrapper for each pricing request and adding them in a list for AM UI.
        for(Pricing_Request__c pr : prList)
        {
            QuotePricingWrapper qpWrapper = new QuotePricingWrapper();
            
            qpWrapper.QuoteID = quoteID; 
            qpWrapper.BundleID = pr.Quote_Line_Bundle__r.Name; 
            qpWrapper.BundleLink = pr.Quote_Line_Bundle__c; 
            qpWrapper.PricingReqId = pr.Name;
            qpWrapper.PricingRequestLink = pr.Id;
            qpWrapper.LOB = pr.Line_of_Business__c;
            
            if(!pr.IsCaseError__c)
            {
                //Get the Selected Supplier from UI
                String seletedSupplier = pr.Quote_Line_Bundle__r.Vendor__r.Customer_Code__c;
                
                prFields = pr.APIRequestOutput__c != null ? PricingRequestFieldsMetadata.parse(pr.APIRequestOutput__c) : null;
                if(prFields != null && prFields.data != null)
                {                   
                    Integer vendorCount = prFields.data.suppliers != null ? prFields.data.suppliers.size() : 0;
                    qpWrapper.ProductName = prFields.data.equipmentName + Pricing_Constant_Util.EMPTY_SPACE + prFields.data.equipmentSizeName + Pricing_Constant_Util.EMPTY_SPACE + prFields.data.equipmentAvailabilityCode;
                    qpWrapper.ProcurementErrorMessage = pr.Quote_Line_Bundle__r.ProcurementErrorMessage__c != null && pr.Quote_Line_Bundle__r.ProcurementErrorMessage__c != Pricing_Constant_Util.SUCCESS_STRING && pr.Quote_Line_Bundle__r.BundleProcuredStatus__c.equalsIgnoreCase('NO') && pr.Quote_Line_Bundle__r.Pricing_Error__c.equalsIgnoreCase(Pricing_Constant_Util.OTHER_PRICING_ERROR)  ? pr.Quote_Line_Bundle__r.ProcurementErrorMessage__c : Pricing_Constant_Util.EMPTY_STRING;
                    qpWrapper.VendorCount = vendorCount;
                    List<ProductDetail> productDetaillst = new List<ProductDetail>();

                    //added loop to iterate each supplier
                    system.debug('prFields.data.suppliers===>'+ prFields.data.suppliers);                    
                    for(PricingRequestFieldsMetadata.suppliers supplier : prFields.data.suppliers) {
                        ProductDetail productDtl = new ProductDetail();                        
                        productDtl.SourceCode = supplier.costSource;
                        string qlSupplier = (supplier.supplierCode != null && supplier.supplierCode.contains('|')) ? supplier.supplierCode.substringBefore('|') : supplier.supplierCode;
                        system.debug('qlSupplier:::'+qlSupplier);
                        system.debug('seletedSupplier:::'+seletedSupplier);
                        system.debug('isSelectedVendor:::'+isSelectedVendor);
                        //&& String.isNotBlank(qlSupplier) 
                        if(isSelectedVendor && (qlSupplier != seletedSupplier)){
                            //In Case if selected supplier is not match then by pass the logic.
                            //This will again execute the iteration without running below code.
                            continue;
                        }

                        if(supplier.messages == null){                          
                            
                            //map to store the service charges for a bundle under a supplier
                            Map<String, PricingRequestFieldsMetadata.ServiceCharges> serviceChargeNameDetailsMap = new Map<String, PricingRequestFieldsMetadata.ServiceCharges>();
                            if(supplier.serviceCharges != null){
                                for(PricingRequestFieldsMetadata.ServiceCharges sql : supplier.serviceCharges) {
                                    string apiCompCode = sql.code.substringBefore('_');
                                    string sCompCode = pricingSTPMap.get(apiCompCode);
                                    serviceChargeNameDetailsMap.put(sCompCode, sql);
                                } 
                            }
                            //End    
                            system.debug('supplier.contractType::::'+supplier.contractType);                
                            if(supplier.contractType == null || 
                                (supplier.contractType != System.label.WM_Franchise && supplier.contractType != System.label.Competitor &&
                                supplier.contractType != System.label.Pre_Determined_Pricing && supplier.contractType != System.label.Third_Party_Agreement))
                            {
                                List<ServiceCharges> sChargelst = new List<ServiceCharges>();
                                
                                productDtl.StartDate = String.valueof(pr.Quote_Line_Bundle__r.SBQQ__StartDate__c);
                                productDtl.EndDate = String.valueof(pr.Quote_Line_Bundle__r.SBQQ__EndDate__c);
                                //productDtl.SourceCode = supplier.costSource;
                                productDtl.VendorType = productDtl.SourceCode != null ? productDtl.SourceCode.contains('WM') ? 'WM' : '3PS' : null;
                                productDtl.VendorCode = supplier.supplierCode != null ? supplier.supplierCode : Pricing_Constant_Util.EMPTY_STRING;
                                productDtl.Vendor = supplier.supplierName != null ? supplier.supplierName : Pricing_Constant_Util.EMPTY_STRING;
                                system.debug('productDtl.SourceCode::::'+productDtl.SourceCode);
                                productDtl.IsPriceChangeRequest = pr.IsPriceChangeRequest__c;
                                // productDtl.BaselineId = pr.Service_Baseline_ID__c; // no need on new service
                                // productDtl.BusinessUnit = pr.Business_Unit__c; // no need
                                productDtl.FacilityId = pr.Facility_Id__c;
                                productDtl.IsProjectRequest =  pr.Project_Request__c;
                                if(pr.Project_Request__c){
                                    productDtl.CustomerPriceType =  supplier.priceSource;
                                }  
                                if(supplier.tpMetaData!= null ){
                                    if(supplier.tpMetaData.feeComment != null)
                                        productDtl.VendorComments = supplier.tpMetaData.feeComment;
                                    if(supplier.tpMetaData.zoneRank != null)
                                        productDtl.VendorRank = supplier.tpMetaData.zoneRank;
                                }
                                currencySymbol = prFields.Data.currencyCode != null ? prFields.Data.currencyCode : 'USD'; //moved top

                                if(supplier.wmMetaData != null)
                                {
                                    productDtl.MASUniqueId = supplier.wmMetaData.masCustomerUniqueId;
                                    productDtl.TargetTrackingId = supplier.wmMetaData.targetTrackingId;
                                    productDtl.FacilityId = supplier.wmMetaData.facilityId;
                                }

                                //This loop is for Core Service Charge
                                List<SBQQ__QuoteLine__c> quotelineSrvbundleLst = quoteLineSrvMap.get(pr.Quote_Line_Bundle__c);
                                List<StepRate> steppeddisposallst = new List<StepRate>();
                                Integer stepCount = 0;
                                
                                for(SBQQ__QuoteLine__c sql : quotelineSrvbundleLst)
                                {
                                    ServiceCharges ancillaryCharge = new ServiceCharges();
                                    
                                    ancillaryCharge.ServiceName = sql.SBQQ__ProductName__c;
                                    ancillaryCharge.ServiceId = sql.Id;
                                    ancillaryCharge.IsSteppedRate = false;
                                    ancillaryCharge.IsSteppedRateCost = false;
                                    ancillaryCharge.IsSteppedRatePrice = false;
                                    
                                    String costUOMName = supplier.equipmentUOM;
                                    String priceUOMName = supplier.equipmentUOM;
                                    
                                    if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.HAUL) || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL)
                                    || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP) || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_EXTRA_PICKUP)
                                    || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.RECYCLING))
                                    {
                                        if(supplier.rollOff != null)
                                        {
                                            productDtl.RateTypeHaul = supplier.rollOff.pricingMethodHaulingDescription;
                                            productDtl.RateTypeDisposal = supplier.rollOff.pricingMethodDisposalDescription;
                                            productDtl.HaulRecordId = supplier.rollOff.haulRecordId;
                                            productDtl.DisposalRecordId = supplier.rollOff.disposalRecordId;

                                            if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.HAUL)){
                                            
                                                ancillaryCharge.Cost = supplier.rollOff.haulCost;
                                                ancillaryCharge.CostValueSymbol = supplier.rollOff.haulCost != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                                ancillaryCharge.Price = supplier.rollOff.haulPrice;
                                                ancillaryCharge.PriceValueSymbol = supplier.rollOff.haulPrice != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                            }
                                            else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL))
                                            { 
                                                
                                                ancillaryCharge.CostUOM = costUOMName;
                                                ancillaryCharge.PriceUOM = priceUOMName;
                                                
                                                //Stepped Pricing changes
                                                if(supplier.rollOff.stepDisposals != null && supplier.rollOff.stepDisposals.size() > 0)
                                                {
                                                    for(PricingRequestFieldsMetadata.StepDisposal step : supplier.rollOff.stepDisposals)
                                                    {
                                                        StepRate steppedCharge = new StepRate();
                                                        if(supplier.rollOff.disposalCost == null)
                                                        {
                                                            steppedCharge.StepCostUpTo =  step.costUpTo;
                                                            steppedCharge.StepCostRange =  step.costRange;
                                                            steppedCharge.StepCost = step.cost;
                                                            ancillaryCharge.IsSteppedRateCost = true;
                                                        }
                                                        else 
                                                        {
                                                            steppedCharge.StepCost = stepCount == 0 ? supplier.rollOff.disposalCost : null;
                                                            ancillaryCharge.Cost = supplier.rollOff.disposalCost;
                                                        }
                                                        
                                                        if(supplier.rollOff.disposalPrice == null)
                                                        {
                                                            steppedCharge.StepPriceUpTo =  step.priceUpTo;
                                                            steppedCharge.StepPriceRange =  step.priceRange;                                                
                                                            steppedCharge.StepPrice = step.price;
                                                            ancillaryCharge.IsSteppedRatePrice = true;
                                                        }
                                                        else
                                                        {
                                                            steppedCharge.StepPrice = stepCount == 0 ? supplier.rollOff.disposalPrice : null;
                                                            ancillaryCharge.Price = supplier.rollOff.disposalPrice;
                                                        }
                                                        steppedCharge.CostValueSymbol = (supplier.rollOff.disposalCost != null || step.cost != null) ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                                        steppedCharge.PriceValueSymbol = (supplier.rollOff.disposalPrice != null || step.price != null) ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
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
                                                    ancillaryCharge.Cost =  supplier.rollOff.disposalCost;
                                                    ancillaryCharge.CostValueSymbol = supplier.rollOff.disposalCost != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                                    ancillaryCharge.Price = supplier.rollOff.disposalPrice;
                                                    ancillaryCharge.PriceValueSymbol = supplier.rollOff.disposalPrice != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                                }                         
                                            }
                                            // TBD for RECYCLING
                                            // else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.RECYCLING))
                                            // {
                                            //     System.debug('@@@@@@@@~ In RECYCLING');
                                            //     ancillaryCharge.Cost = sql.SBQQ__UnitCost__c;
                                            //     ancillaryCharge.CostValueSymbol = sql.SBQQ__UnitCost__c != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                            //     ancillaryCharge.Price = sql.SBQQ__ListPrice__c;
                                            //     ancillaryCharge.PriceValueSymbol = sql.SBQQ__ListPrice__c != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                            //     ancillaryCharge.CostUOM = costUOMName;
                                            //     ancillaryCharge.PriceUOM = priceUOMName;
                                            // }
                                        }
                                        else if(supplier.commercial != null)
                                        {
                                            productDtl.RateTypePickup = supplier.commercial.pricingMethodPickupDescription;
                                            productDtl.PickupRecordId = supplier.commercial.pickupRecordId;
                                            if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP))
                                            {
                                            
                                                //ancillaryCharge.CostUOMCode = apivalueUOMID;
                                                ancillaryCharge.CostUOM = costUOMName;
                                                ancillaryCharge.Cost = supplier.commercial.unitCost;
                                                ancillaryCharge.CostValueSymbol = supplier.commercial.unitCost != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                                
                                                //ancillaryCharge.PriceUOMCode = apivalueUOMID;
                                                ancillaryCharge.PriceUOM = priceUOMName;
                                                ancillaryCharge.Price = supplier.commercial.unitPrice;
                                                ancillaryCharge.PriceValueSymbol = supplier.commercial.unitPrice != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                                
                                            }
                                            else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_EXTRA_PICKUP))
                                            {
                                                
                                                productDtl.ExtraPickupRecordId =  supplier.commercial.extraPickupRecordId;

                                                ancillaryCharge.Cost = supplier.commercial.extraPickupCost;
                                                ancillaryCharge.CostValueSymbol = supplier.commercial.extraPickupCost != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                                
                                                ancillaryCharge.Price = supplier.commercial.extraPickupPrice;
                                                ancillaryCharge.PriceValueSymbol = supplier.commercial.extraPickupPrice != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;                                            
                                                ancillaryCharge.CostUOM = 'EV';
                                                ancillaryCharge.PriceUOM = 'EV';
                                            }
                                        }
                                        // sChargelst.add(ancillaryCharge);
                                    }
                                    else
                                    {
                                        //Service Charges - Ancillary Charges
                                        //sql.SBQQ__ProductName__c - CSC find in Service Charges List
                                        
                                        //starts here - av4
                                        //picking the respective service charge from the serviceChargeNameDetailsMap map
                                        
                                        PricingRequestFieldsMetadata.ServiceCharges servCharge = serviceChargeNameDetailsMap.get(sql.SBQQ__ProductCode__c);
                                        
                                        if(servCharge != null)
                                        {
                                            ancillaryCharge.CostUOM = (servCharge.costUOM != null || servCharge.cost != null) ? servCharge.costUOM : Pricing_Constant_Util.EMPTY_STRING;
                                            if(servCharge.costValueType == Pricing_Constant_Util.PERCENT)
                                            {
                                                ancillaryCharge.Cost = servCharge.cost;
                                                ancillaryCharge.CostValuePercent = servCharge.cost != null ? Pricing_Constant_Util.PERCENTAGE : Pricing_Constant_Util.EMPTY_STRING;
                                            }
                                            else {
                                            
                                                ancillaryCharge.Cost = servCharge.cost;
                                                ancillaryCharge.CostValueSymbol = servCharge.cost != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                            }
                                            
                                            ancillaryCharge.PriceUOM = (servCharge.priceUOM != null || servCharge.price != null) ? servCharge.priceUOM : Pricing_Constant_Util.EMPTY_STRING;
                                            if(servCharge.priceValueType == Pricing_Constant_Util.PERCENT)
                                            {
                                                ancillaryCharge.Price = servCharge.price;
                                                ancillaryCharge.PriceValuePercent = servCharge.price != null ? Pricing_Constant_Util.PERCENTAGE : Pricing_Constant_Util.EMPTY_STRING;
                                            }
                                            else
                                            {
                                                ancillaryCharge.Price = servCharge.price;
                                                ancillaryCharge.PriceValueSymbol = servCharge.price != null ? currencySymbol : Pricing_Constant_Util.EMPTY_STRING;
                                            }
                                        }
                                        // sChargelst.add(ancillaryCharge);
                                        //ends here - av4
                                    }
                                    sChargelst.add(ancillaryCharge);
                                    // productDtl.ServiceCharges = sChargelst;
                                }
                                productDtl.ServiceCharges = sChargelst;
                            }
                            else
                            {
                                List<GreenPage> gpList = new List<GreenPage>();
                                GreenPage gp = new GreenPage();
                                String francisePricingLink = '',  greenPagesLink = '';
                                francisePricingLink = supplier.wmMetaData != null ? supplier.wmMetaData.francisePricingLink : null;
                                greenPagesLink = supplier.wmMetaData != null ? supplier.wmMetaData.greenPagesLink : null;
                                if(supplier.contractType == System.label.WM_Franchise)
                                {
                                    gp.Message = System.label.zoneFranchiseMsg;
                                    gp.Market = System.label.Market_WM_Franchise;
                                }
                                else if(supplier.contractType == System.label.Competitor)
                                {
                                    gp.Message = System.label.zoneCompetitorMsg;
                                    gp.Market = System.label.Market_Non_WM_Franchise;
                                }
                                else if(supplier.contractType == System.label.Pre_Determined_Pricing)
                                {
                                    gp.Message = System.label.zoneDeterminedMsg;
                                    gp.Market = System.label.Market_WM_Pre_Determined_Pricing;
                                }
                                else if(supplier.contractType == System.label.Third_Party_Agreement)
                                {
                                    gp.Message = System.label.zone3PAMsg;
                                    gp.Market = System.label.Market_WM_Third_Party_Agreement;
                                }
                                gp.GPLabelName = francisePricingLink != null ? 'Franchise Pricing Link' : greenPagesLink != null ? 'Green Pages Link' : null;
                                gp.GPLabelLink = francisePricingLink != null ? francisePricingLink : greenPagesLink != null ? greenPagesLink : null;
                                gp.ZoneName = supplier.ZoneName;
                                gp.ZoneDescription= supplier.zoneDescription;
                                gp.ZoneNote= supplier.zoneNotes;
                                gpList.add(gp);
                                productDtl.GreenPages = gpList;
                            }                            
                        }
                        else
                        {
                            List<Message> msgLst = new List<Message>();

                            for(PricingRequestFieldsMetadata.messages sMsg : supplier.messages)
                            {
                                Message msg = new Message();
                                msg.code = sMsg.code;
                                msg.description = sMsg.description;
                                msgLst.add(msg);
                            }
                            productDtl.vendorMessage = msgLst;
                        }                        
                        productDetaillst.add(productDtl);
                    }
                    qpWrapper.ProductDetailsList = productDetaillst; 
                    system.debug('qpWrapper.ProductDetailsList::::'+qpWrapper.ProductDetailsList);                    
                }
				else 
				{	
                    Problem plm = new Problem();
                    if(prFields.problem != null && prFields.problem.errors != null){
                        for(Schema.PicklistEntry ple :containerTypePicklist){
                            if(ple.getValue() == pr.Container_Type__c)
                                qpWrapper.ProductName = ple.getLabel();
                        }
                        for(Schema.PicklistEntry ple :containerSizePicklist){
                            if(ple.getValue() == pr.Container_Size__c)
                                qpWrapper.ProductName = qpWrapper.ProductName + Pricing_Constant_Util.EMPTY_SPACE + ple.getLabel() + Pricing_Constant_Util.EMPTY_SPACE + pr.Service_Type__c;
                        } 
                        plm.ErrorMessage = prFields.problem.errors[0].message;
                    }
                    else{
                        plm.ErrorMessage = 'Pricing response still not prepared, Please try again later or refresh the page.';
                    }
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
            system.debug('wrapperList::::'+wrapperList);
        }
        return wrapperList;        
    }

    //This method iterates through the pricing records under a quote and determines whether it should go for multi response or single response behavior
    //Method will return null map if the quote is ineligible for automatic updation
    public static Map<Id, String> validateMultiVendorPricingRequest(Id quoteId) {
        
        
		Boolean isSingleVendorResponse = false;
		
        //Map to store header quoteline id and applicable vendor code.
        Map<Id, string> bundleIdVendorCodeMapForQuote = new Map<Id, String>();
        
        //map to store the pr id with the boolea value
        Map<Id, Boolean> prIdIsSingleVendorResponseMap = new Map<Id, Boolean>();
        
        //fetching quotelines and pricing request records
        List<SBQQ__QuoteLine__c> bundles = PricingRequestSelector.getQuoteLineList(quoteID);
        
        Integer bundlesCount = bundles.size();
        List<Pricing_Request__c> prList = PricingRequestSelector.getStandardPricingRequestList(quoteID, bundlesCount);
        
        //looping through each pr records
        for(Pricing_Request__c pr : prList){
            Map<Id, string> bundleIdVendorCodeMap = validateSingleVendorResponseBehavior(pr);

			if(bundleIdVendorCodeMap.keySet().isEmpty())
				return null;
            
            bundleIdVendorCodeMapForQuote.putAll(bundleIdVendorCodeMap);
        }        
        system.debug('bundleIdVendorCodeMapForQuote: ' + bundleIdVendorCodeMapForQuote);
        return bundleIdVendorCodeMapForQuote;
    }
    
    @TestVisible
    //This method returns true if conditions for automatically updating quote lines are met. ie; the conditions for no manual interventions
    private static Map<Id, string> validateSingleVendorResponseBehavior(Pricing_Request__c pr) {
        Boolean isSingleVendorEligible = False;
        //Map to store header quoteline id and applicable vendor code.
        Map<Id, string> bundleIdVendorCodeMap = new Map<Id, String>();
        
        if(!pr.IsCaseError__c) {
            //parsing here
            PricingRequestFieldsMetadata prResponse = new PricingRequestFieldsMetadata();
            prResponse = pr.APIRequestOutput__c != null ? PricingRequestFieldsMetadata.parse(pr.APIRequestOutput__c) : null;
            
            if(prResponse != null && prResponse.data != null) {
                //the below logic is only for third party
                //checking if response is having only one vendor and that vendor is having pricing details
                Integer numberOfVendors = prResponse.data.suppliers.size();
                if (numberOfVendors == 1)
                {
                    bundleIdVendorCodeMap.put(pr.Quote_Line_Bundle__c, prResponse.data.suppliers[0].supplierCode);
                    return bundleIdVendorCodeMap;
                }                
                //multiple vendor scenarios
                else {   
                    //WM availability scenario
                    for(PricingRequestFieldsMetadata.suppliers supplier : prResponse.data.suppliers) {
                        //&& pr.Quote_Line_Bundle__r.Availability_Flag__c.containsIgnoreCase(Pricing_Constant_Util.WM_AVAILABILITY_CONFIRMED)
                        if(supplier.costSource.contains(Pricing_Constant_Util.WM_VENDOR)){
                            if(supplier.messages == null){
                                    bundleIdVendorCodeMap.put(pr.Quote_Line_Bundle__c, supplier.supplierCode);
                                    return bundleIdVendorCodeMap;
                            }
                            else if(supplier.messages != null 
                                && !supplier.messages[0].description.contains(Pricing_Constant_Util.NO_WM_ZONE_AVAILABLE)
                                && !supplier.messages[0].description.contains(Pricing_Constant_Util.NO_COST_PRICE_AVAILABLE)){
                                    bundleIdVendorCodeMap.put(pr.Quote_Line_Bundle__c, supplier.supplierCode);
                                    return bundleIdVendorCodeMap;
                                }
                        }
                    }

                    //Third Party scenario - 3P
                    Map<String, Map<String, Integer>> suppRank = new Map<String, Map<String, Integer>>();
                    for(PricingRequestFieldsMetadata.suppliers supplier3P : prResponse.data.suppliers) {
                        if(!supplier3P.costSource.contains('WM')){
                            Map<String, Integer> suppInfo = new Map<String, Integer>();
                            if(supplier3P.messages == null && supplier3P.tpMetaData != null && supplier3P.tpMetaData.zoneRank != null){
                                suppInfo.put(supplier3P.supplierName, supplier3P.tpMetaData.zoneRank);
                            }
                            else 
                            {
                                suppInfo.put(supplier3P.supplierName, 999);
                            }
                            suppRank.put(supplier3P.supplierCode, suppInfo);
                        }                        
                    }

                    //added b av4 on 17/06/2025 for testing sorting of nested maps
                    Map<String, Map<String, Integer>> suppMapRankSorted = new Map<String, Map<String, Integer>>();
                    suppMapRankSorted = MapSortService.nestedMapSorter(suppRank);

                    //Get the top supplier to store in QL
                    if(suppMapRankSorted != null && suppMapRankSorted.size() > 0){
                        List<String> sortedSupplierCode = new List<String>(suppMapRankSorted.keySet()); 
                        bundleIdVendorCodeMap.put(pr.Quote_Line_Bundle__c, sortedSupplierCode[0]);
                    }                    
                }
                
            }
            else{
                //This condition when WM and 3P Cost/Price not come and data node is null.
                //Supplier code 999998 is a dummy code use for this logic.
                bundleIdVendorCodeMap.put(pr.Quote_Line_Bundle__c, '999998');
            }
        }
        
        return bundleIdVendorCodeMap;
    }

    public static List<QuotePricingWrapper> processMultiVendorPricingRequest(ID quoteID, Boolean isFirstCall)
    {
        List<QuotePricingWrapper> wrapperList = new List<QuotePricingWrapper>();
        try
        {
            if(isFirstCall)
            {
                //Call validateMultiVendorPricingRequest to check to go for STP or show multi vendor response to user
                Map<Id, String> validateResponse = validateMultiVendorPricingRequest(quoteID);

                if(validateResponse != null && validateResponse.size() > 0){
                    // Call quoteLineMultiVendorProcess to process the API and Insert, Update and Delete
                    // the quote line according to STP business rules                
                    quoteLineMultiVendorProcess(quoteID, validateResponse);

                    // Call saveProcuredStatus to update the quote and quoteline
                    // for procured - complete and incomplete also check the Substituted logic
                    PricingRequestSTPProcess.saveProcuredStatus(quoteID);
                }
            }
            
        }
        catch(Exception ex) 
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
        }
        return wrapperList;
    }

    @AuraEnabled
    public static String saveMultiVendorPricingRequest(ID quoteID, string suppliersMap)
    {
        

        Map<Id, String> deserializedMap = (Map<Id, String>) JSON.deserializeStrict(suppliersMap, Map<Id, String>.class);
        
        String result;
        try
        {
            // Call quoteLineMultiVendorProcess to process the API and Insert, Update and Delete
            // the quote line according to STP business rules                
            result = quoteLineMultiVendorProcess(quoteID, deserializedMap);
        }
        catch(Exception ex) 
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
        }
        return result;
    }

    /*@methodName- quoteLineMultiVendorProcess
    *author: TCS - akotawal
    *@description- Method to process the pricing API response and update Quote and QuoteLine 
    *@param- Id : QuoteId, Map<Id, String> where (Id: QuotelineId and String: VendorCode)
    *@return- List of wrapper - QuotePricingWrapper
    */
    @AuraEnabled
    public static string quoteLineMultiVendorProcess(ID quoteID, Map<Id, String> suppliersMap)
    {
        
        //pkulkarn-4-Aug-2023-Added below 2 variables for SDT-31211
        String quoteType = '';
        Map<Id, SBQQ__QuoteLine__c> allQuoteLinesExceptBundles = new Map<Id, SBQQ__QuoteLine__c>();
        // PricingReportingFieldsMetadata prFields = new PricingReportingFieldsMetadata();
        PricingRequestFieldsMetadata prSuppFields = new PricingRequestFieldsMetadata();
        Map<String,String> costUOMMapName = new Map<String,String>();
        Map<String,String> priceUOMMapName = new Map<String,String>();
        Map<String,Product2> productMap = new Map<String,Product2>();
        Map<Id,SBQQ__QuoteLine__c> quoteHdrMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,List<SBQQ__QuoteLine__c>> quoteLineCoreSrvMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
        Map<Id,List<SBQQ__QuoteLine__c>> quoteLineSrvMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> upsertQLLIst = new List<SBQQ__QuoteLine__c>();
        List<Id> deleteQuotelinelst =  new List<Id>();
        List<string> productCodelst = new list<string>();
        Map<string,SBQQ__ProductOption__c> qlProductoption = new map<string,SBQQ__ProductOption__c>();
        List<Pricing_Request__c> pricingReqLst = new List<Pricing_Request__c>();
        Double quoteLineNumber = 0;
        Id vendorId= null;
        //added for SDT 30956
        Account vendor= new Account();
        Boolean needRecyclingQL = false;
        Map<Id, Boolean> isRecycleMap = new Map<Id, Boolean>();
        Set<String> vendorSet = new Set<String>();
        Map<String,Account> quoteVendorMap = new Map<String,Account>(); 
        List<Account> vendorLst = new List<Account>();
        List<SBQQ__QuoteLine__c> qlBuldle = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lds = new List<SBQQ__QuoteLine__c>();
        
        //modified by av4 on 27/06/2025
        List<SBQQ__QuoteLine__c> bundles = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> dsbundles = new List<SBQQ__QuoteLine__c>();
         DataStoreProcessor dataProcessor = new DataStoreProcessor();
         List<Data_Store__c> bundleData = new List<Data_Store__c>();

         bundleData = [SELECT Field1__c, Field2__c, Field3__c, Field4__c, Field5__c, Field6__c, Field7__c, Field8__c, Field9__c, Field10__c, 
                       Related_Record_Id__c FROM Data_Store__c WHERE Related_Record_Id__c = :quoteID ORDER BY Sequence_Number__c ASC LIMIT 200];

        //if data store records exist, we reconstruct quotelines from those.
        Boolean flag = false;
         if(bundleData.size() > 0) {
            dsbundles = (List<SBQQ__QuoteLine__c>) dataProcessor.reconstruct(list<SBQQ__QuoteLine__c>.class, quoteID);
            //  bundles = (List<SBQQ__QuoteLine__c>) dataProcessor.reconstruct(list<SBQQ__QuoteLine__c>.class, quoteID);
             for(SBQQ__QuoteLine__c ql: dsbundles) {
                if(ql.SBQQ__RequiredBy__c == null) {
                    flag = true;
                    bundles.add(ql);
                } else {
                    lds.add(ql);
                }
             }
         }
         //if not, we fetch the quotelines and also create data store records for future
         else {
            bundles = PricingRequestSelector.getQuoteLineList(quoteID);
            dsbundles = PricingRequestSelector.getQuoteLineListAll(quoteID); 
            //creating data store records for future
             dataProcessor.convertAndInsertToDataStore(dsbundles, quoteId);
         }
        //modification ends
        
        Integer bundlesCount = bundles.size();
        String currencySymbol;
        String updateStatus;
        
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Variables declaration
        Boolean additionalMetadataRetrieved = false;
        String parentAccountPrimarySegment = '';
        String quoteShippingCountry = '';
        List<Pricing_Response_Process_Quote_Line__mdt> pricingResponseQuoteLineMetadata = new List<Pricing_Response_Process_Quote_Line__mdt>();
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-End Variables declaration
        
        //sdt-44637 sarfaraz
        ExhibitPriceServices exhibitService= new ExhibitPriceServices();
        exhibitService.quoteID= quoteId;
        
        
        for(SBQQ__QuoteLine__c qlHdr : bundles){
            quoteHdrMap.put(qlHdr.Id, qlHdr);
            productCodelst.add(qlHdr.SBQQ__ProductName__c);
            if(quoteType == null || quoteType == '')
                quoteType = qlHdr.SBQQ__Quote__r.SBQQ__Type__c;		//pkulkarn-4-Aug-2023-Added for SDT-31211 to retrieve quote type 
            quoteShippingCountry = qlHdr.SBQQ__Quote__r.SBQQ__ShippingCountry__c;	//TCS-pkulkarn-SDT-40031-9-Apr-2025-Added
            parentAccountPrimarySegment = qlHdr.Account__r.Parent.Primary_Segment__c;	//TCS-pkulkarn-SDT-40031-9-Apr-2025-Added
            
        }
        
        List<Pricing_Request__c> priqList = PricingRequestSelector.getStandardPricingRequestList(quoteID, bundlesCount);
        List<SBQQ__ProductOption__c> productOptions = PricingRequestSTPProcess.getProductOptions(productCodelst);
        for(SBQQ__ProductOption__c prdopt : productOptions){
            string concatecode = prdopt.SBQQ__ConfiguredSKU__r.ProductCode + prdopt.SBQQ__OptionalSKU__r.ProductCode;
            qlProductoption.put(concatecode,prdopt);
        }
        
        Set<Id> bundleIDSet = new Set<Id>();
        for(SBQQ__QuoteLine__c qlId : bundles)
        {
            bundleIDSet.add(qlId.Id);
        }
      
        if(bundleIDSet != null && flag == false)
        {
            //pkulkarn-4-Aug-2023-Added Type_of_Change__c, AssetId__c for SDT-31211
            //added as part of SDT-33285 ByPassFunctionality__c
            qlBuldle = [SELECT Id, SBQQ__ProductCode__c, SBQQ__ProductName__c,
                        SBQQ__Number__c,SBQQ__ProductFamily__c, SBQQ__Quote__c,
                        Occurrence_Type__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, 
                        PriceUOM__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, 
                        SBQQ__CustomerPrice__c, CostModelType__c,
                        Type_of_Change__c, AssetId__c,ByPassFunctionality__c,
                        Schedule_Frequency__c, Frequency_Interval__c, Service_Days__c //Added by Sarfaraz for 44637
                        FROM SBQQ__QuoteLine__c 
                        WHERE SBQQ__RequiredBy__c IN: bundleIDSet  ORDER BY SBQQ__Number__c DESC];
        } else {
            qlBuldle = lds;
        }
        
        quoteLineNumber = qlBuldle != null && qlBuldle.size() > 0 ? qlBuldle[0].SBQQ__Number__c: 0;
        
        for(SBQQ__QuoteLine__c qlSrvReq : qlBuldle)
        {
            if(qlSrvReq.SBQQ__ProductFamily__c != 'Waste Category')
            {
                if(qlSrvReq.SBQQ__ProductCode__c == 'H' || qlSrvReq.SBQQ__ProductCode__c == 'DSP' || qlSrvReq.SBQQ__ProductCode__c == 'PCK' || qlSrvReq.SBQQ__ProductCode__c == 'REC')
                {
                    if (quoteLineCoreSrvMap.containsKey(qlSrvReq.SBQQ__RequiredBy__c)) {
                        List<SBQQ__QuoteLine__c> quotelst = quoteLineCoreSrvMap.get(qlSrvReq.SBQQ__RequiredBy__c);
                        quotelst.add(qlSrvReq);
                        quoteLineCoreSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c, quotelst);
                    } else {
                        quoteLineCoreSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{ qlSrvReq });
                    }                    
                }                
                else
                {
                    if (quoteLineSrvMap.containsKey(qlSrvReq.SBQQ__RequiredBy__c)) {
                        List<SBQQ__QuoteLine__c> quotelst = quoteLineSrvMap.get(qlSrvReq.SBQQ__RequiredBy__c);
                        quotelst.add(qlSrvReq);
                        quoteLineSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c, quotelst);
                    } else {
                        quoteLineSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{ qlSrvReq });
                    }                                  
                }                                    
            }
        }
        
        //pkulkarn-4-Aug-2023-Added the for loop for SDT-31211 to get a map of all quote lines of the Quote
        for(SBQQ__QuoteLine__c quoteLine : qlBuldle)
        {
            allQuoteLinesExceptBundles.put(quoteLine.Id, quoteLine);
        }
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added Additional_Processing_Needed__c field to the SOQL query
        List<PricingSTP__mdt> pricingSTP = [SELECT Id, ServiceChargeName__c, ServiceChargeCode__c, AcitonName__c, IsCreateQuoteLine__c, IsDeleteQuoteLine__c, Additional_Processing_Needed__c
                                            FROM PricingSTP__mdt WHERE IsActive__c = true];
        
        List<Product2> productList = PricingRequestSTPProcess.getProductdetails();
        for(Product2 prd : productList)
        {
            productMap.put(prd.ProductCode, prd);
        }
        
        List<String> pckCostValue = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'Cost_Unit_of_Measure__c');
        List<String> pckPriceValue = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'PriceUOM__c');
        
        for(String pcv : pckCostValue){
            costUOMMapName.put(pcv.split(',').get(0), pcv.split(',').get(1));
        }
        for(String ppv : pckPriceValue){
            priceUOMMapName.put(ppv.split(',').get(0), ppv.split(',').get(1));
        }
        
        for(Pricing_Request__c prVendor : priqList)
        {
            String seletedSupplier = suppliersMap.get(prVendor.Quote_Line_Bundle__c);
            if(seletedSupplier != null)
            {
                vendorSet.add(seletedSupplier.contains('|') ? seletedSupplier.substringBefore('|') : seletedSupplier);
            }
        }
        if(vendorSet != null && vendorSet.size()>0){
            vendorLst = [SELECT Id, Vendor_ID__c, Parent_Vendor_ID__c FROM Account WHERE Status__c = 'Active' AND Vendor_ID__c IN : vendorSet];
           
        }
        
        if(!vendorLst.isEmpty()){
            for(Account ven : vendorLst){
                quoteVendorMap.put(ven.Vendor_ID__c,ven);
            }
        }
        
        for(Pricing_Request__c pr : priqList)
        {
            PricingRequestFieldsMetadata.suppliers prFields;
            Boolean isNullValueSupplier = false;
           
            SBQQ__QuoteLine__c ql = quoteHdrMap.get(pr.Quote_Line_Bundle__c);

            //Get the Selected Supplier from UI
            String seletedSupplier = suppliersMap.get(pr.Quote_Line_Bundle__c);
            if(seletedSupplier == '999998'){
                seletedSupplier = null;
                isNullValueSupplier = true;
            }
            
            SBQQ__QuoteLine__c sqlHdr = new SBQQ__QuoteLine__c();
            needRecyclingQL = false;
            if(!pr.IsCaseError__c && pr.isAPIResult__c)
            {
                // system.debug('@@@ QL BUndle Id: '+ pr.Quote_Line_Bundle__c);
                // system.debug('@@@ PR test '+pr.APIRequestOutput__c);
                // prFields = PricingRequestFieldsMetadata.parse(pr.APIRequestOutput__c);
                prSuppFields = PricingRequestFieldsMetadata.parse(pr.APIRequestOutput__c);
                //Fetching the selected supplier from the multi-vendor pricing response
                for(PricingRequestFieldsMetadata.suppliers spp : prSuppFields.data.suppliers)
                {
                    if(spp.supplierCode == seletedSupplier){
                        prFields = spp;
                    }
                }
                //Add value in Bundle Header - Start
                sqlHdr.Id = pr.Quote_Line_Bundle__c;
                sqlHdr.Pricing_Request__c = pr.Id;
                sqlHdr.CurrencyIsoCode = currencySymbol;
                currencySymbol = prSuppFields.data.currencyCode;

                //Check that Supplier data as prFields
                if(prFields != null)
                {
                    //Save Pricing Data for select vendor
                    Pricing_Request__c prData = new Pricing_Request__c();
                    prData.Id = pr.Id;
                    savePricingFields(prData, prFields);
                    pricingReqLst.add(prData);

                    // Gunjan Shah - for SDT-49568 error scenarios
                    if(prFields.messages != null) {
                        try{
                            List<SBQQ__QuoteLine__c> upsertQuoteLines = new List<SBQQ__QuoteLine__c>();
                            for(SBQQ__QuoteLine__c ds: dsbundles) {
				ds.SBQQ__UnitCost__c = null;
                                ds.SBQQ__ListPrice__c = null;
                                ds.Cost_Override_Reason__c = 'Other';
                                ds.Cost_Override_Description__c = 'Change to vendor with error';
                                ds.Price_Override_Description__c = 'Change to vendor with error';
                                ds.Price_Override_Reason__c = 'Other';
                                ds.Vendor__c = null;
                                upsertQuoteLines.add(ds);
                            }
                            upsert upsertQuoteLines;
                            updateStatus = 'Records Save Successfully.';
                        }
                        catch(exception ex){
                            
                            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
                            updateStatus = 'Error: ' + ex;
                        }
                        // return updateStatus;
                    }

                    //Use isPriceOnly for SDT-20125
                    if(prFields.costSource != null && (prFields.contractType == null || prFields.contractType ==  Pricing_Constant_Util.OPEN_MARKET))//sdt-50613
                    {
                        String sourceCodeStr = prFields.costSource;
                        sqlHdr.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? pr.Name : sourceCodeStr;
                    }
                    if(prFields.supplierCode != null && (prFields.contractType == null || prFields.contractType == Pricing_Constant_Util.OPEN_MARKET)) //sdt-50613
                    {
                        if(quoteVendorMap != null && quoteVendorMap.size() > 0)
                        {
                            String vendorCode = (prFields.supplierCode != null && prFields.supplierCode.contains('|')) ? prFields.supplierCode.substringBefore('|') : prFields.supplierCode;
                            vendorId = quoteVendorMap.get(vendorCode) != null ? quoteVendorMap.get(vendorCode).Id : null;
                            //added for SDT 30956
                            vendor = quoteVendorMap.get(vendorCode) != null ? quoteVendorMap.get(vendorCode) : null;
                        }

                        sqlHdr.Vendor__c = vendorId;
                    }

                    //SDT-49568 - When user select supplier with Null value
                    if(isNullValueSupplier){
                        sqlHdr.Vendor__c = null;
                    }
                    
                    upsertQLLIst.add(sqlHdr);

                    if(prFields.contractType == null || 
                    (prFields.contractType != System.label.WM_Franchise && prFields.contractType != System.label.Competitor &&
                        prFields.contractType != System.label.Pre_Determined_Pricing && prFields.contractType != System.label.Third_Party_Agreement))
                    {
                        //This loop is for Core Service Charge
                        List<SBQQ__QuoteLine__c> quotelineCoreSrvbundleLst = quoteLineCoreSrvMap != null ? quoteLineCoreSrvMap.get(pr.Quote_Line_Bundle__c) : null;
                        for(SBQQ__QuoteLine__c sql : quotelineCoreSrvbundleLst)
                        {
                            //Add value in Bundle QL - Start
                            SBQQ__QuoteLine__c sqlCoreService = new SBQQ__QuoteLine__c();
                            
                            sqlCoreService.Id = sql.Id;
                            sqlCoreService.Pricing_Request__c = pr.Id;
                            
                            if(prFields.costSource != null)
                            {
                                String sourceCodeStr = prFields.costSource;
                                sqlCoreService.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? pr.Name : sourceCodeStr;
                            }
                            if(prFields.supplierCode != null)
                            {
                                sqlCoreService.Vendor__c = vendorId;
                            }
                            //SDT-49568 - When user select supplier with Null value
                            if(isNullValueSupplier){
                                sqlCoreService.Vendor__c = null;
                            }
                            if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.HAUL) || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL)
                            || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP) || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_EXTRA_PICKUP)
                            || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.RECYCLING))
                            {
                                String apivalueUOMID = null;
                                apivalueUOMID = ExhibitPriceServices.setMonthlytoMonthUOM(costUOMMapName, prFields.equipmentUOM);
                                sqlCoreService.CurrencyIsoCode = currencySymbol;                                    
                                
                                if(prFields.rollOff != null)
                                {
                                    if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.HAUL))
                                    {
                                        // if((prFields.costSource.contains('WM') && prFields.rollOff.haulCost < 10000) || !prFields.costSource.contains('WM'))
                                        // {
                                        sqlCoreService.Pricing_API_Method__c = prFields.rollOff.pricingMethodHaulingDescription;
                                        sqlCoreService.SBQQ__UnitCost__c = prFields.rollOff.haulCost;
                                        sqlCoreService.SBQQ__ListPrice__c = prFields.rollOff.haulPrice;
                                        // }
                                    }
                                    else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL))
                                    {
                                        if(apivalueUOMID != null)
                                        {
                                            sqlCoreService.Cost_Unit_of_Measure__c = apivalueUOMID;
                                            sqlCoreService.PriceUOM__c = apivalueUOMID;
                                        }
                                        
                                        //Stepped Pricing changes
                                        if(prFields.rollOff.stepDisposals != null && prFields.rollOff.stepDisposals.size() > 0)
                                        {
                                            sqlCoreService.Pricing_API_Method__c = prFields.rollOff.pricingMethodDisposalDescription;
                                            Integer steppedCounter = 1;
                                            for(PricingRequestFieldsMetadata.StepDisposal step : prFields.rollOff.stepDisposals)
                                            {
                                                if(steppedCounter == 1)
                                                {
                                                    if(step.cost != null)
                                                    {
                                                        sqlCoreService.CostModelType__c = 'STP';
                                                    }
                                                    if(step.price != null)
                                                    {
                                                        sqlCoreService.SBQQ__PricingMethod__c = 'STP';
                                                    }
                                                }
                                                //Add Step Logic here...
                                                // system.debug('In switch case - Counter ' + steppedCounter);
                                                if(prFields.rollOff.disposalCost == null)
                                                {
                                                    switch on steppedCounter 
                                                    {
                                                        when 1 
                                                        {
                                                            sqlCoreService.CostUpTo1__c = step.costUpTo;
                                                            sqlCoreService.CostPrice1__c = step.cost;
                                                        }
                                                        when 2
                                                        {
                                                            sqlCoreService.CostUpTo2__c = step.costUpTo;
                                                            sqlCoreService.CostPrice2__c = step.cost;
                                                        }
                                                        when 3
                                                        {
                                                            sqlCoreService.CostUpTo3__c = step.costUpTo;
                                                            sqlCoreService.CostPrice3__c = step.cost;
                                                        }
                                                        when 4
                                                        {
                                                            sqlCoreService.CostUpTo4__c = step.costUpTo;
                                                            sqlCoreService.CostPrice4__c = step.cost;
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    sqlCoreService.CostModelType__c = 'PER';
                                                    sqlCoreService.SBQQ__UnitCost__c = prFields.rollOff.disposalCost;
                                                }
                                                
                                                if(prFields.rollOff.disposalPrice == null)
                                                {
                                                    switch on steppedCounter 
                                                    {
                                                        when 1 
                                                        {
                                                            sqlCoreService.PriceUpTo1__c = step.priceUpTo;
                                                            sqlCoreService.PricePrice1__c = step.price;
                                                        }
                                                        when 2
                                                        {                                                        
                                                            sqlCoreService.PriceUpTo2__c = step.priceUpTo;
                                                            sqlCoreService.PricePrice2__c = step.price;
                                                        }
                                                        when 3
                                                        {
                                                            sqlCoreService.PriceUpTo3__c = step.priceUpTo;
                                                            sqlCoreService.PricePrice3__c = step.price;
                                                        }
                                                        when 4
                                                        {
                                                            sqlCoreService.PriceUpTo4__c = step.priceUpTo;
                                                            sqlCoreService.PricePrice4__c = step.price;
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    sqlCoreService.SBQQ__PricingMethod__c = 'List';
                                                    sqlCoreService.SBQQ__ListPrice__c = prFields.rollOff.disposalPrice;
                                                }
                                                steppedCounter++;
                                            }
                                        }
                                        else
                                        {
                                            if((prFields.costSource.contains('WM') && prFields.rollOff.disposalCost >= 0) || !prFields.costSource.contains('WM'))
                                            {
                                                sqlCoreService.Pricing_API_Method__c = prFields.rollOff.pricingMethodDisposalDescription;
                                                sqlCoreService.CostModelType__c = 'PER';
                                                sqlCoreService.SBQQ__UnitCost__c = prFields.rollOff.disposalCost;
                                                sqlCoreService.SBQQ__PricingMethod__c = 'List';
                                                sqlCoreService.SBQQ__ListPrice__c = prFields.rollOff.disposalPrice;
                                            }
                                            
                                            
                                        }
                                        //Change for Story SDT-23396
                                        if(prFields.tpMetaData != null && prFields.tpMetaData.feeComment != null && prFields.tpMetaData.feeComment.contains('Rebate'))
                                        {
                                            deleteQuotelinelst.add(sql.Id);
                                            needRecyclingQL = true;
                                        }
                                        
                                        //Change for Story SDT-29195
                                        if(prFields.serviceCharges != null)
                                        {
                                            Double costMinTon, priceMinTon;
                                            for(Integer scIndex = 0; scIndex < prFields.serviceCharges.size(); scIndex++)
                                            {
                                                if(prSuppFields.data.materialCode == 'C' || prSuppFields.data.materialCode == 'SSR')
                                                {
                                                    if(prFields.serviceCharges[scIndex].name.toLowerCase().contains(System.label.Minimum_Tons_Recycling))
                                                    {
                                                        costMinTon = prFields.serviceCharges[scIndex].cost;
                                                        priceMinTon = prFields.serviceCharges[scIndex].price;
                                                        break;
                                                    }
                                                }
                                                else
                                                {
                                                    if(prFields.serviceCharges[scIndex].name.toLowerCase().contains(System.label.All_Other_Minimum_Tonnage))
                                                    {
                                                        costMinTon = prFields.serviceCharges[scIndex].cost;
                                                        priceMinTon = prFields.serviceCharges[scIndex].price;
                                                        break;
                                                    }
                                                }
                                            }
                                            //Change SDT-30495, Update CostMinQuantity and PriceMinQuantity to null when actual value is zero.
                                            if(prFields.costSource.contains('WM'))
                                            { 
                                                //when the vendor is WM, then min tons price copy to both Cost and Price
                                                sqlCoreService.CostMinQuantity__c = PricingRequestSTPProcess.setZeroASNullforMinTon(priceMinTon);
                                                sqlCoreService.PriceMinQuantity__c = PricingRequestSTPProcess.setZeroASNullforMinTon(priceMinTon);
                                            }
                                            else
                                            {
                                                //when the vendor is 3P, then min tons price copy to price and  Cost copy to cost
                                                sqlCoreService.CostMinQuantity__c = PricingRequestSTPProcess.setZeroASNullforMinTon(costMinTon);
                                                sqlCoreService.PriceMinQuantity__c = PricingRequestSTPProcess.setZeroASNullforMinTon(priceMinTon);
                                            }
                                        }
                                    }
                                    else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.RECYCLING))
                                    {
                                        if(prFields.tpMetaData != null && prFields.tpMetaData.feeComment != null && prFields.tpMetaData.feeComment.contains('Rebate'))
                                        {
                                            deleteQuotelinelst.add(sql.Id);
                                        }
                                    }
                                    
                                    //This Section for create the Recycling QL
                                    //SDT-23396
                                    if(needRecyclingQL)
                                    {
                                        //Get product ID from product Map.
                                        Product2 prdREC = productMap.get('REC');
                                        string concatproductoption = ql.SBQQ__ProductCode__c + 'REC';
                                        SBQQ__ProductOption__c productOption = qlProductoption.get(concatproductoption);
                                        // system.debug('productOptionRec' + productOption);
                                        // system.debug('prdREC ' + prdREC);
                                        if(prdREC != null)
                                        {
                                            SBQQ__QuoteLine__c sqlancillaryService = new SBQQ__QuoteLine__c();
                                            sqlancillaryService.SBQQ__Quote__c = quoteID;
                                            sqlancillaryService.SBQQ__Product__c = prdREC.id;
                                            sqlancillaryService.Equipment_Size__c = ql.Equipment_Size__c;
                                            sqlancillaryService.SBQQ__RequiredBy__c = ql.id;
                                            sqlancillaryService.Duration__c = ql.Duration__c;
                                            if(productOption != null)
                                            {
                                                sqlancillaryService.SBQQ__ProductOption__c = productOption.id;
                                                sqlancillaryService.Occurrence_Type__c = productOption.Occurrence_Type__c;
                                                if(productOption.Occurrence_Type__c == 'SCH')
                                                {
                                                    sqlancillaryService.Schedule_Frequency__c = productOption.Schedule_Frequency__c;
                                                    sqlancillaryService.Frequency_Interval__c = productOption.Frequency_Interval__c;
                                                }
                                            }
                                            sqlancillaryService.Vendor__c = !isNullValueSupplier ? vendorId : null;
                                            sqlancillaryService.SBQQ__OptionLevel__c = 1;
                                            sqlancillaryService.SBQQ__Quantity__c = 1;
                                            sqlancillaryService.SBQQ__Number__c = quoteLineNumber + 1; //need to check what this field is for.
                                            sqlancillaryService.SBQQ__CostEditable__c = true;
                                            sqlancillaryService.SBQQ__PriceEditable__c = true;
                                            sqlancillaryService.SBQQ__UnitCost__c = 0.00;
                                            sqlancillaryService.SBQQ__ListPrice__c = 0.00;
                                            sqlancillaryService.CurrencyIsoCode = currencySymbol;
                                            sqlancillaryService.Cost_Unit_of_Measure__c = 'TN'; 
                                            sqlancillaryService.PriceUOM__c = 'TN'; 
                                            sqlancillaryService.SBQQ__StartDate__c = ql.SBQQ__StartDate__c;
                                            sqlancillaryService.SBQQ__EndDate__c = ql.SBQQ__EndDate__c;
                                            sqlancillaryService.CostModelType__c = 'REB';
                                            sqlancillaryService.SBQQ__PricingMethod__c = 'REB';
	                                        if(prFields.tpMetaData!=null && prFields.tpMetaData.feeComment != null)
                                            {
                                                sqlancillaryService.ContractNotes__c = prFields.tpMetaData.feeComment;
                                            }
                                            //SDT-31627
                                            //sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.costSource);
                                            //SDT-39060 commented BypassPriceReview__c as covered through new story SDT-29645
                                            //sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, vendor.Parent_Vendor_ID__c, null);
                                            //Changes done for SDT-24353
                                            if(prFields.costSource != null)
                                            {
                                                String sourceCodeStr = prFields.costSource;
                                                sqlancillaryService.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? pr.Name : sourceCodeStr;
                                            }
                                            sqlancillaryService.Pricing_API_Method__c = prFields.rollOff.pricingMethodHaulingDescription;
                                            //End
                                            //Comment Code for SDT-31291 : Start
                                            // if(prFields.overridableEquipmentSizeCode != null)
                                            // {
                                            //     sqlancillaryService.Equipment_Size__c = prFields.overridableEquipmentSizeCode;
                                            //     sqlancillaryService.Original_Equipment_Size__c = prFields.equipmentSizeName;
                                            // }
                                            
                                            upsertQLLIst.add(sqlancillaryService);
                                            quoteLineNumber++;
                                            
                                            needRecyclingQL = false;
                                        }
                                    }
                                }
                                else if(prFields.commercial != null)
                                {
                                    if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP))
                                    {
                                        sqlCoreService.Pricing_API_Method__c = pr.Pickup_Rate_Type__c;
                                        sqlCoreService.SBQQ__UnitCost__c = prFields.commercial.unitCost;
                                        sqlCoreService.SBQQ__ListPrice__c = prFields.commercial.unitPrice;
                                        if(pr.Schedule_or_On_Call__c == Pricing_Constant_Util.SCHEDULED && apivalueUOMID != null)
                                        {
                                            sqlCoreService.Cost_Unit_of_Measure__c = apivalueUOMID;
                                            sqlCoreService.PriceUOM__c = apivalueUOMID;
                                        }
                                        else if(pr.Schedule_or_On_Call__c == Pricing_Constant_Util.ON_CALL)
                                        {
                                            sqlCoreService.Cost_Unit_of_Measure__c = 'EV';
                                            sqlCoreService.PriceUOM__c = 'EV';
                                        }
                                    }
                                    else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_EXTRA_PICKUP))
                                    {
                                        sqlCoreService.SBQQ__UnitCost__c = prFields.commercial.extraPickupCost;
                                        sqlCoreService.SBQQ__ListPrice__c = prFields.commercial.extraPickupPrice;
                                        sqlCoreService.Cost_Unit_of_Measure__c = 'EV';
                                        sqlCoreService.PriceUOM__c = 'EV';
                                    }
                                }
                            }
                            upsertQLLIst.add(sqlCoreService);
                        }
                        
                        if(prFields.serviceCharges != null)
                        {
                            //system.debug('In Service Charge Section');

                            //This loop is for Ancillary Charge (Non Core Service Charge)
                            //system.debug('ServiceCharge QuoteLine Id ' + pr.Quote_Line_Bundle__c);
                            List<SBQQ__QuoteLine__c> quotelineSrvbundleLst = quoteLineSrvMap.get(pr.Quote_Line_Bundle__c);
                            //system.debug('Checking core services>>'+quoteLineCoreSrvMap);

                            for(Integer scIndex = 0; scIndex < prFields.serviceCharges.size(); scIndex++)
                            {
                                Boolean isServiceExist = false;
                                SBQQ__QuoteLine__c currentQl ; 
                                for(PricingSTP__mdt meta : pricingSTP)
                                {
                                    if(prFields.serviceCharges[scIndex].name.contains(meta.ServiceChargeName__c) 
                                    && (prFields.serviceCharges[scIndex].actionName == meta.AcitonName__c
                                        ||  prFields.serviceCharges[scIndex].actionName == null
                                        ||  prFields.serviceCharges[scIndex].actionName == 'Manual Review'))
                                    {
                                        String costUOMID = null, priceUOMID = null;
                                        costUOMID = ExhibitPriceServices.setMonthlytoMonthUOM(costUOMMapName, prFields.serviceCharges[scIndex].costUOM);
                                        priceUOMID =ExhibitPriceServices.setMonthlytoMonthUOM(priceUOMMapName, prFields.serviceCharges[scIndex].priceUOM);
                                        
                                        if(meta.ServiceChargeCode__c == exhibitService.CSC && !exhibitService.checkIfCanadianAccount(quoteID) )// added by Sarfaraz for 44637
                                        {
                                            costUOMID = 'MTH';
                                            priceUOMID = 'MTH';    
                                        }
                                    
                                    
                                        else if(meta.ServiceChargeCode__c == 'DLV')
                                        {
                                            costUOMID = 'EV';
                                            priceUOMID = 'EV';
                                        }
                                        if(quotelineSrvbundleLst != null)
                                        {
                                            for(SBQQ__QuoteLine__c servQL : quotelineSrvbundleLst)
                                            {
                                                if(servQL.SBQQ__ProductCode__c ==  meta.ServiceChargeCode__c)
                                                {
                                                    isServiceExist = true;
                                                    currentQl = servQL;
                                                    if(costUOMID == null)
                                                        costUOMID =  currentQl.Cost_Unit_of_Measure__c;
                                                    if(priceUOMID == null)
                                                        priceUOMID =  currentQl.PriceUOM__c;
                                                    
                                                    break;
                                                }
                                            }
                                        }                                    
                                        if(isServiceExist)
                                        {
                                            if(prFields.supplierCode != null)
                                            {
                                                currentQl.Vendor__c = vendorId;
                                            }
                                            //SDT-49568 - When user select supplier with Null value
                                            if(isNullValueSupplier){
                                                currentQl.Vendor__c = null;
                                            }
                                            
                                            currentQl.CurrencyIsoCode = currencySymbol;
                                            //SDT-31627
                                            //currentQl.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.costSource);
                                            //SDT-39060 commented BypassPriceReview__c as covered through new story SDT-29645
                                            //currentQl.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, vendor.Parent_Vendor_ID__c, null);
                                            
                                        }
                                        
                                        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added following code block
                                        PricingResponseProcessor pricingResponseProcessor = new PricingResponseProcessor();
                                        PricingResponseProcessor.serviceChargeActionInput pricingResponseProcessorInput = new PricingResponseProcessor.serviceChargeActionInput();
                                        PricingResponseProcessor.serviceChargeActionOutput pricingResponseProcessorOutput = new PricingResponseProcessor.serviceChargeActionOutput();
                                        
                                        if(meta.Additional_Processing_Needed__c == true)
                                        {
                                            pricingResponseProcessorInput.parentAccountPrimarySegment = parentAccountPrimarySegment;
                                            pricingResponseProcessorInput.serviceChargeName = meta.ServiceChargeName__c;
                                            pricingResponseProcessorInput.serviceChargeCode = meta.ServiceChargeCode__c;
                                            pricingResponseProcessorInput.quoteType = quoteType;
                                            pricingResponseProcessorInput.shippingCountry = quoteShippingCountry;
                                            pricingResponseProcessorInput.prMVFields = prFields; //--TBD
                                            pricingResponseProcessorInput.pricingRequest = pr;
                                            pricingResponseProcessorInput.quoteLineRecord = isServiceExist ? currentQl : null;
                                            pricingResponseProcessorInput.equipmentName = prSuppFields.data.equipmentName;
                                            
                                            /*if(additionalMetadataRetrieved == false)
                                            {
                                            pricingResponseQuoteLineMetadata = prp.retrieveProcessQuoteLineMetadata();
                                            additionalMetadataRetrieved = true;
                                            }
                                            //prpInput.processQuoteLineMetadata = pricingResponseQuoteLineMetadata;*/
                                            pricingResponseProcessorInput.processQuoteLineMetadata = pricingResponseProcessor.retrieveProcessQuoteLineMetadata(pricingResponseQuoteLineMetadata);
                                            //system.debug('PK meta.CSC' + meta.ServiceChargeName__c);
                                            pricingResponseProcessorOutput = pricingResponseProcessor.determineMultiVendorQLAction(pricingResponseProcessorInput);
                                            
                                            //system.debug('PK prpOutput ' + prpOutput);
                                        }
                                        //TCS-pkulkarn-SDT-40031-9-Apr-2025-End
                                        
                                        if(prFields.serviceCharges[scIndex].actionName == 'Allow' || prFields.serviceCharges[scIndex].actionName == 'Adjust' 
                                        || prFields.serviceCharges[scIndex].actionName == 'Manual Review' || prFields.serviceCharges[scIndex].actionName == null)
                                        {
                                            //Added by Sarfaraz for SDT-44637
                                            if(prFields.serviceCharges[scIndex].componentCode == exhibitService.CSC)
                                            {
                                                if((prFields.serviceCharges[scIndex].costUOM==exhibitService.DAYS||prFields.serviceCharges[scIndex].costUOM==exhibitService.MONTHS
                                                    ||prFields.serviceCharges[scIndex].costUOM==exhibitService.WEEKS||prFields.serviceCharges[scIndex].costUOM=='Event')  
                                                && exhibitService.checkIfNewServiceCase(quoteID) 
                                                && exhibitService.checkIfCanadianAccount(quoteID))
                                                {
                                                currentQl.Occurrence_Type__c=exhibitService.SCH;
                                                currentQl.Schedule_Frequency__c=(prFields.serviceCharges[scIndex].costUOM).substring(0,1);
                                                currentQl.Frequency_Interval__c='1';
                                                currentQl.Service_Days__c=null;
                                                    if(prFields.serviceCharges[scIndex].costUOM=='Event')
                                                    {
                                                        currentQl.Occurrence_Type__c='OC';
                                                        currentQl.Schedule_Frequency__c=null; 
                                                        currentQl.Frequency_Interval__c=null;
                                                    }
                                                }}
                                            //End by Sarfaraz for SDT-44637
                                            if(isServiceExist) //This cater isUpdate condition 
                                            {
                                                //system.debug('Service exist update code will run');
                                                //Update current quoteline and add into list
                                                
                                                //Changes for SDT-23997, Quoteline should not create or update if cost and price get NULL value
                                                if(prFields.serviceCharges[scIndex].cost != null || prFields.serviceCharges[scIndex].price != null)
                                                {
                                                    if(prFields.serviceCharges[scIndex].costValueType != null && prFields.serviceCharges[scIndex].costValueType.equals(Pricing_Constant_Util.PERCENT))
                                                    {
                                                        currentQl.SBQQ__SubscriptionPercent__c = prFields.serviceCharges[scIndex].cost;
                                                        currentQl.SBQQ__UnitCost__c = 0.00;
                                                    }
                                                    else
                                                    {
                                                        currentQl.SBQQ__UnitCost__c = prFields.serviceCharges[scIndex].cost;
                                                    }
                                                    
                                                    if(prFields.serviceCharges[scIndex].priceValueType != null && prFields.serviceCharges[scIndex].priceValueType.equals(Pricing_Constant_Util.PERCENT))
                                                    {
                                                        currentQl.SBQQ__MarkupRate__c = prFields.serviceCharges[scIndex].price;
                                                        currentQl.SBQQ__ListPrice__c = 0.00;
                                                    }
                                                    else
                                                    {
                                                        currentQl.SBQQ__ListPrice__c = prFields.serviceCharges[scIndex].price;
                                                    }
                                                    currentQl.Cost_Unit_of_Measure__c = costUOMID;
                                                    currentQl.PriceUOM__c = priceUOMID;
                                                }
                                                else
                                                {
                                                    currentQl.SBQQ__UnitCost__c = null;
                                                    currentQl.SBQQ__ListPrice__c = null;
                                                }
                                                
                                                //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added following code block
                                                if(meta.Additional_Processing_Needed__c == false)
                                                {
                                                    upsertQLLIst.add(currentQl);
                                                }
                                                else if(pricingResponseProcessorOutput.overrideAction)
                                                {
                                                    if(pricingResponseProcessorOutput.updateQuoteLine)
                                                    {
                                                        upsertQLLIst.add(currentQl);
                                                    }
                                                }
                                                else
                                                {
                                                    upsertQLLIst.add(currentQl);
                                                }
                                                
                                                //upsertQLLIst.add(currentQl);	//TCS-pkulkarn-SDT-40031-9-Apr-2025-Commented
                                            }
                                            else if(meta.IsCreateQuoteLine__c)
                                            {
                                                //Changes for SDT-23997, Quoteline should not create or update if cost and price get NULL value
                                                //system.debug('cost===>' +prFields.serviceCharges[scIndex].cost);
                                                //system.debug('price==>' +prFields.serviceCharges[scIndex].price);
                                                if(prFields.serviceCharges[scIndex].cost != null || prFields.serviceCharges[scIndex].price != null)
                                                {
                                                    //Get product ID from product Map.
                                                    Product2 prd = productMap.get(meta.ServiceChargeCode__c);
                                                    string concatproductoption = ql.SBQQ__ProductCode__c + meta.ServiceChargeCode__c;
                                                    // system.debug('concatproductoption ' +concatproductoption);
                                                    SBQQ__ProductOption__c productOption = qlProductoption.get(concatproductoption);
                                                    // system.debug('productOption' +productOption);
                                                    // system.debug('prd' +prd);
                                                    if(prd !=null)
                                                    {
                                                        // system.debug('New quoteline will create for ' +meta.ServiceChargeCode__c);
                                                        //Create new quoteline for ancillary Service 
                                                        SBQQ__QuoteLine__c sqlancillaryService = new SBQQ__QuoteLine__c();
                                                        sqlancillaryService.SBQQ__Quote__c = quoteID;
                                                        sqlancillaryService.SBQQ__Product__c = prd.id;
                                                        sqlancillaryService.Equipment_Size__c = ql.Equipment_Size__c;
                                                        sqlancillaryService.SBQQ__RequiredBy__c = ql.id;
                                                        sqlancillaryService.Duration__c = ql.Duration__c;
                                                        if(productOption != null){
                                                            sqlancillaryService.SBQQ__ProductOption__c = productOption.id;
                                                            sqlancillaryService.Occurrence_Type__c = productOption.Occurrence_Type__c;
                                                            //Add For SDT-29716
                                                           sqlancillaryService.CostModelType__c = productOption.CostModelType__c;                                                        
                                                             //End
                                                            if(productOption.Occurrence_Type__c == 'SCH')
                                                            {
                                                                sqlancillaryService.Schedule_Frequency__c = productOption.Schedule_Frequency__c;
                                                                sqlancillaryService.Frequency_Interval__c = productOption.Frequency_Interval__c;
                                                            }
                                                            sqlancillaryService.Cost_Unit_of_Measure__c = costUOMID != null ? costUOMID : productOption.Cost_Unit_of_Measure__c; 
                                                            sqlancillaryService.PriceUOM__c = priceUOMID != null ? priceUOMID : productOption.PriceUOM__c;
                                                        }
                                                        //Added by Sarfaraz for SDT-44637
                                                        //system.debug('Line Line 1130 Sarf>> ' );
                                                            for(id quoteLineId:quoteLineCoreSrvMap.keySet())
                                                            {
                                                                for(SBQQ__QuoteLine__c singleQuoteLine:quoteLineCoreSrvMap.get(quoteLineId) )
                                                                {
                                                                exhibitService.ancillaryQuoteLineProductCode=prd.ProductCode;
                                                                exhibitService.processAncillaryQuoteLine(sqlancillaryService, singleQuoteLine, costUOMMapName, priceUOMMapName, prFields.serviceCharges[scIndex].costUOM,prFields.serviceCharges[scIndex].priceUOM);
                                                                                                            
                                                                }}
                                                        
                                                        //end by Sarfaraz
                                                        //Add for SDT-29716
                                                        if(prd.Name == Pricing_Constant_Util.ENERGY_SURCHARGE || prd.Name == Pricing_Constant_Util.ENVIRONMENTAL_CHARGE)
                                                        {
                                                            sqlancillaryService.SBQQ__PricingMethod__c = 'List';
                                                        }
                                                        else
                                                        {
                                                            sqlancillaryService.SBQQ__PricingMethod__c = prd.SBQQ__PricingMethod__c;
                                                        }
                                                        //End
                                                        // system.debug('-------> Value of vendor at DLV QL : ' + vendorId);
                                                        if(prFields.supplierCode != null)
                                                        {
                                                            sqlancillaryService.Vendor__c = vendorId;
                                                        }
                                                        //SDT-49568 - When user select supplier with Null value
                                                        if(isNullValueSupplier){
                                                            sqlancillaryService.Vendor__c = null;
                                                        }
                                                        sqlancillaryService.SBQQ__OptionLevel__c = 1;
                                                        sqlancillaryService.SBQQ__Quantity__c = 1;
                                                        sqlancillaryService.SBQQ__Number__c = quoteLineNumber + 1; //need to check what this field is for.
                                                        sqlancillaryService.SBQQ__CostEditable__c = true;
                                                        sqlancillaryService.SBQQ__PriceEditable__c = true;
                                                        sqlancillaryService.SBQQ__StartDate__c = ql.SBQQ__StartDate__c;
                                                        sqlancillaryService.SBQQ__EndDate__c = ql.SBQQ__EndDate__c;
                                                        sqlancillaryService.CurrencyIsoCode = currencySymbol;

                                                        if(prFields.serviceCharges[scIndex].costValueType != null && prFields.serviceCharges[scIndex].costValueType.equals(Pricing_Constant_Util.PERCENT))
                                                        {
                                                            sqlancillaryService.SBQQ__SubscriptionPercent__c = prFields.serviceCharges[scIndex].cost;
                                                            sqlancillaryService.SBQQ__UnitCost__c = 0.00;
                                                        }
                                                        else
                                                        {
                                                            sqlancillaryService.SBQQ__UnitCost__c = prFields.serviceCharges[scIndex].cost;
                                                        }
                                                        if(prFields.serviceCharges[scIndex].priceValueType != null && prFields.serviceCharges[scIndex].priceValueType.equals(Pricing_Constant_Util.PERCENT))
                                                        {
                                                            sqlancillaryService.SBQQ__MarkupRate__c = prFields.serviceCharges[scIndex].price;
                                                            sqlancillaryService.SBQQ__ListPrice__c = 0.00;
                                                        }
                                                        else
                                                        {
                                                            sqlancillaryService.SBQQ__ListPrice__c = prFields.serviceCharges[scIndex].price;
                                                        }
                                                        
                                                        
                                                        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added following code block
                                                        if(meta.Additional_Processing_Needed__c == false)
                                                        {
                                                            upsertQLLIst.add(sqlancillaryService);
                                                        }
                                                        else if(pricingResponseProcessorOutput.overrideAction)
                                                        {
                                                            if(pricingResponseProcessorOutput.createQuoteLine)
                                                            {
                                                                upsertQLLIst.add(sqlancillaryService);
                                                            }
                                                        }
                                                        else
                                                        {
                                                            upsertQLLIst.add(sqlancillaryService);
                                                        }
                                                        
                                                        //upsertQLLIst.add(sqlancillaryService);	//TCS-pkulkarn-SDT-40031-9-Apr-2025-Commented
                                                        quoteLineNumber++;
                                                    }
                                                }
                                            }
                                        }
                                        // else if(prFields.serviceCharges.actionName == "Adjust")
                                        // {
                                        //     // This is for future use. If in future we have saperate business rule for Adjust.
                                        // }
                                        else if(prFields.serviceCharges[scIndex].actionName == 'Exclude')
                                        {
                                            //system.debug('PK meta.ServiceChargeName__c' + meta.ServiceChargeName__c);
                                            //system.debug('PK meta.ServiceChargeName__c' + meta.Additional_Processing_Needed__c);
                                            //system.debug('PK meta.ServiceChargeName__c' + pricingResponseProcessorOutput);
                                            //TCS-pkulkarn-SDT-40031-9-Apr-2025-Moved existing code to if block and added else if block
                                            //TCS-pkulkarn-SDT-40031-12-May-2025-Added OR condition in below if statement for defect SDT-47976
                                            if(meta.Additional_Processing_Needed__c == false || (meta.Additional_Processing_Needed__c == true && pricingResponseProcessorOutput.overrideAction == false))
                                            {
                                                //system.debug('Exclude code will run');
                                                if(isServiceExist && meta.IsDeleteQuoteLine__c)
                                                {
                                                    deleteQuotelinelst.add(currentQl.id);
                                                }
                                                else if(isServiceExist) //Update Existing Quote Line to 0 cost/price
                                                {
                                                    //Update current quoteline and add into list
                                                    currentQl.SBQQ__UnitCost__c = 0;
                                                    currentQl.SBQQ__ListPrice__c = 0;
                                                    currentQl.Cost_Unit_of_Measure__c = costUOMID;
                                                    currentQl.PriceUOM__c = priceUOMID;
                                                    
                                                    upsertQLLIst.add(currentQl);
                                                }
                                            }
                                            else if(meta.Additional_Processing_Needed__c == true)
                                            {
                                                if(pricingResponseProcessorOutput.overrideAction)
                                                {
                                                    if(pricingResponseProcessorOutput.deleteQuoteLine && isServiceExist)
                                                    {
                                                        deleteQuotelinelst.add(currentQl.id);
                                                    } else if(isServiceExist && prFields.serviceCharges[scIndex].name.contains('Container Service Charge')){
                                                        currentQl.SBQQ__UnitCost__c = null;
                                                        currentQl.SBQQ__ListPrice__c = null;
                                                        currentQl.Cost_Unit_of_Measure__c = costUOMID;
                                                        currentQl.PriceUOM__c = priceUOMID;
                                                        
                                                        upsertQLLIst.add(currentQl);
                                                    }
                                                }
                                            }
                                            //TCS-pkulkarn-SDT-40031-9-Apr-2025-End
                                        }
                                        break;
                                    } 
                                    //Commented code for SDT-51135, as this condition is already covered in above if block with actionName == manual Review
                                    // else if(prFields.serviceCharges[scIndex].actionName == 'Manual Review')
                                    // {
                                    //     String costUOMID = null, priceUOMID = null;
                                    //     if(quotelineSrvbundleLst != null)
                                    //     {
                                    //         for(SBQQ__QuoteLine__c servQL : quotelineSrvbundleLst)
                                    //         {
                                    //             if(prFields.serviceCharges[scIndex].name.contains(servQL.SBQQ__ProductName__c))
                                    //             {
                                    //                 currentQl = servQL;
                                    //                 if(costUOMID == null)
                                    //                     costUOMID =  currentQl.Cost_Unit_of_Measure__c;
                                    //                 if(priceUOMID == null)
                                    //                     priceUOMID =  currentQl.PriceUOM__c;
                                                    
                                    //                 break;
                                    //             }
                                    //         }
                                    //     }
                                    //     Boolean isCostPriceNull = false;
                                    //     if(currentQl != null) {
                                    //         if(prFields.serviceCharges[scIndex].cost == null){
                                    //             isCostPriceNull = true;
                                    //             currentQl.SBQQ__UnitCost__c = null;
                                    //             currentQl.Vendor__c = null;
                                    //             currentQl.Cost_Unit_of_Measure__c = costUOMID;
                                    //         } 
                                    //         if(prFields.serviceCharges[scIndex].price == null){
                                    //             isCostPriceNull = true;
                                    //             currentQl.SBQQ__ListPrice__c = 0;
                                    //             currentQl.Vendor__c = null;
                                    //             currentQl.PriceUOM__c = priceUOMID;
                                    //         } 

                                    //         if(isCostPriceNull == true)
                                    //             upsertQLLIst.add(currentQl);
                                    //     }
                                    //     break;
                                    // }
                                }
                            }
                        }
                    }
                    //Handling the GreenPage and Francise link through the above code where Quote header line initializes.
                    //No need to create the else statement
                }
            }
            else 
            {
                //Handle Error Message if Case Error or API Return the error message
                sqlHdr.Id = pr.Quote_Line_Bundle__c;
                sqlHdr.Pricing_Request__c = pr.Id;
                upsertQLLIst.add(sqlHdr);
            }
        }
        
        //pkulkarn-4-Aug-2023-Added for SDT-31211
        try
        {
            
            upsertQLLIst = PricingRequestSTPProcess.filterUpsertQuoteLinesForQuoteType(upsertQLLIst, quoteType, allQuoteLinesExceptBundles);
            deleteQuotelinelst = PricingRequestSTPProcess.filterDeleteQuoteLinesForQuoteType(deleteQuotelinelst, quoteType);
        }
        catch(exception ex){
          
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
        }
       
        //END - pkulkarn-4-Aug-2023-Added for SDT-31211
        
        if(upsertQLLIst !=null && upsertQLLIst.size() > 0 ){
            try{               
                //Skip QL validation for Cost/Price, SDT-26002
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = true;
                upsert upsertQLLIst;
                updateStatus = 'Records Save Successfully.';
            }
            catch(exception ex){
                
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
                updateStatus = 'Error: ' + ex;
            }
            finally
            {
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = false;
            }
        }
        if(deleteQuotelinelst !=null && deleteQuotelinelst.size() > 0 ){
            try{               
                database.delete(deleteQuotelinelst);               
            }
            catch(exception ex){
                
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
                updateStatus = 'Error: ' + ex;
            }
        }
        if(pricingReqLst != null && pricingReqLst.size() > 0){
            try{               
                update pricingReqLst;     
            }
            catch(exception ex){
                
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
                updateStatus = 'Error: ' + ex;
            }
        }
        return updateStatus;
    }

    public static void savePricingFields(Pricing_Request__c priceReq, PricingRequestFieldsMetadata.suppliers supplierData)
    {        
        if(supplierData != null)
        {            
            priceReq.put('Vendor_Code__c',  supplierData.SupplierCode);
            priceReq.put('Vendor_Name__c',  supplierData.supplierName);
            priceReq.put('Cost_Source__c',  supplierData.costSource);
            priceReq.put('Zone_Type__c',  supplierData.contractType);
            priceReq.put('Customer_Price_Type__c',  supplierData.priceSource);

            if(supplierData.rollOff != null){
                priceReq.put('Disposal_Rate_Type__c',  supplierData.rollOff.pricingMethodDisposalDescription);
                priceReq.put('Haul_Rate_Type__c',  supplierData.rollOff.pricingMethodHaulingDescription);
                priceReq.put('Haul_Cost__c',  supplierData.rollOff.haulCost);
                priceReq.put('Disposal_Cost__c',  supplierData.rollOff.disposalCost);
                priceReq.put('Haul_Price__c',  supplierData.rollOff.haulPrice);
                priceReq.put('Disposal_Price__c',  supplierData.rollOff.disposalPrice);
                priceReq.put('Est_Tons_per_Haul__c',  supplierData.rollOff.estimatedVolumePerHaul);
                priceReq.put('Haul_Record_Id__c',  supplierData.rollOff.haulRecordId);
                priceReq.put('Disposal_Record_Id__c',  supplierData.rollOff.disposalRecordId);
            }
            else if(supplierData.commercial != null){
                priceReq.put('Pickup_Rate_Type__c',  supplierData.commercial.pricingMethodPickupDescription);
                priceReq.put('Pickup_Cost__c',  supplierData.commercial.cost);
                priceReq.put('Extra_Pickup_Cost__c',  supplierData.commercial.extraPickupCost);
                priceReq.put('Pickup_Price__c',  supplierData.commercial.price);
                priceReq.put('Extra_Pickup_Price__c',  supplierData.commercial.extraPickupPrice);
                priceReq.put('Pickup_Record_Id__c',  supplierData.commercial.pickupRecordId);
                priceReq.put('Extra_Pickup_Record_Id__c',  supplierData.commercial.extraPickupRecordId);
            }
            if(supplierData.wmMetaData != null){
                priceReq.put('Market_Area_Code__c',  supplierData.wmMetaData.marketAreaCode);
                priceReq.put('Market_Area_Name__c',  supplierData.wmMetaData.marketAreaName);
                priceReq.put('Facility_Id__c',  supplierData.wmMetaData.facilityId);
                priceReq.put('Facility_Name__c',  supplierData.wmMetaData.facilityName);
                priceReq.put('Site_Id__c',  supplierData.wmMetaData.siteId);
                priceReq.put('Site_Name__c',  supplierData.wmMetaData.siteName);
            }
            if(supplierData.tpMetaData != null){
                priceReq.put('Vendor_Comments__c',  supplierData.tpMetaData.feeComment);
            }
        }
    }
}
