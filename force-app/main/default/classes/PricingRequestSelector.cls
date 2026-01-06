/*
    * @name          : PricingRequestSelector
    * @author        : Digdershika Ojha
    * @vendor		 : TCS
    * @last modified on : 05/07/2023
    * @last modified by : Digdershika Ojha
    * @description	 : This class will be used as Selector class for PricingRequest Object, designed for SDT-28509
    * @Reference	: PriceOnlyRequestSTPProcess
    */
public with sharing class PricingRequestSelector {

    /*@methodName- getPricingList
    *@description- Method to query the Pricing_Request Record 
    *@param- Id : QuoteID, BundleCount
	*@Reference	PriceOnlyRequestSTPProcess
    *@return- List of Pricing_Request
    */ 
    public static list<Pricing_Request__c> getPricingList(ID quoteID, Integer bundleCount)
    {
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added Pricing_Type__c field to the SOQL query
        List<Pricing_Request__c> priqList = [SELECT Id, Name, Line_of_Business__c, Container_Type__c, Container_Size__c, Material_Code__c, Service_Type__c, Quote__c, Quote__r.Name, Quote_Line_Bundle__c, Quote_Line_Bundle__r.Name, Zone_Type__c,  
        Haul_Rate_Type__c,  Haul_Cost__c, Haul_Price__c, Disposal_Rate_Type__c, Disposal_Cost__c, Disposal_Price__c, Pickup_Rate_Type__c, Pickup_Cost__c, Pickup_Price__c, Extra_Pickup_Cost__c, Extra_Pickup_Price__c,  
        isAPIResult__c, APIRequestOutput__c, Case_Error_Message__c, IsCaseError__c, Cost_Source__c, Source_Code__c, Vendor_Code__c, Vendor_Name__c, Business_Unit__c, Project_Request__c, Customer_Price_Type__c,
        Disposal_Record_Id__c, Haul_Record_Id__c, Pickup_Record_Id__c, Extra_Pickup_Record_Id__c , Vendor_Comments__c, Facility_Id__c, Facility_Name__c, Schedule_or_On_Call__c, Service_Baseline_ID__c, IsPriceChangeRequest__c,
        Pricing_Type__c
        FROM Pricing_Request__c 
        WHERE Quote__c =: quoteID AND (Pricing_Type__c = 'AMPO') ORDER BY CreatedDate DESC LIMIT : bundleCount];
        

        return priqList;
    }
    /*@methodName- getPricingRequestListById
    *@description- Method to query the Pricing_Request Record 
    *@param- Set of Id : pricingRequestIdSet
	*@Reference	PriceOnlyRequestSTPProcess
    *@return- List of Pricing_Request priceReqList
    */ 
    //Added additional fileds in below query for SDT-20689  
    public static list<Pricing_Request__c> getPricingRequestListById(Set<Id> pricingRequestIdSet){
        List<Pricing_Request__c> priceReqList = [SELECT Id, Name, Account__c, Location__c, Location__r.Location_Code__c, Container_Type__c, Container_Size__c, Material_Code__c, 
            Service_Type__c, APIRequestOutput__c, Case__c, Case__r.CaseNumber, Line_of_Business__c, Quote_Line_Bundle__c, Disposal_Cost__c, Extra_Pickup_Cost__c, Haul_Cost__c, 
            Pickup_Cost__c, Vendor_Code__c, Project_Request__c, Project_Code__c, Project_Code__r.Name, Quote__c, Account__r.IsPricingEligible__c, Quote__r.Name,
            Account__r.Customer_Code__c, Quantity__c, Hauls_Month__c, Industry_Classification__c, Customer_Owned__c, Service_Street_Address__c, Service_City__c, Service_State__c,
            Service_Country__c, Service_Postal_Code__c, Frequency_Type__c, Frequency_Count__c, Account__r.Primary_Segment__c, Schedule_or_On_Call__c, 
            Quote__r.SBQQ__Opportunity2__r.Case__r.Price_Quote_Identifier__c,Quote__r.Quote_Only__c, Service_Baseline_ID__c, IsPriceChangeRequest__c, Is_Multi_Vendor__c
            FROM Pricing_Request__c 
            WHERE id IN :pricingRequestIdSet];
            return priceReqList;
    }
    
    //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added following method
    //Caller: PriceOnlyRequestSTPProcess.savePricetoQuoteline()
    //Purpose : To retrieve list of Standard prcing request for given quote id
    public static List<Pricing_Request__c> getStandardPricingRequestList(Id quoteId)
    {
        List<Pricing_Request__c> priqList = [SELECT Id, Name, Line_of_Business__c, Container_Type__c, Container_Size__c, Material_Code__c, Service_Type__c, Quote__c, Quote__r.Name, Quote_Line_Bundle__c, Quote_Line_Bundle__r.Name, Zone_Type__c,  
        Haul_Rate_Type__c,  Haul_Cost__c, Haul_Price__c, Disposal_Rate_Type__c, Disposal_Cost__c, Disposal_Price__c, Pickup_Rate_Type__c, Pickup_Cost__c, Pickup_Price__c, Extra_Pickup_Cost__c, Extra_Pickup_Price__c,  
        isAPIResult__c, APIRequestOutput__c, Case_Error_Message__c, IsCaseError__c, Cost_Source__c, Source_Code__c, Vendor_Code__c, Vendor_Name__c, Business_Unit__c, Project_Request__c, Customer_Price_Type__c,
        Disposal_Record_Id__c, Haul_Record_Id__c, Pickup_Record_Id__c, Extra_Pickup_Record_Id__c , Vendor_Comments__c, Facility_Id__c, Facility_Name__c, Schedule_or_On_Call__c, Service_Baseline_ID__c, IsPriceChangeRequest__c,
        Pricing_Type__c, Quote_Line_Bundle__r.Availability_Flag__c, Quote_Line_Bundle__r.Vendor__r.Customer_Code__c, Quote_Line_Bundle__r.SBQQ__StartDate__c, Quote_Line_Bundle__r.SBQQ__EndDate__c,
        Quote_Line_Bundle__r.ProcurementErrorMessage__c, Quote_Line_Bundle__r.BundleProcuredStatus__c, Quote_Line_Bundle__r.Pricing_Error__c,Is_Multi_Vendor__c
        FROM Pricing_Request__c 
        WHERE Quote__c =: quoteId AND (Pricing_Type__c = 'AM') ORDER BY CreatedDate DESC];
        

        return priqList;
    }

    public static list<Pricing_Request__c> getStandardPricingRequestList(ID quoteID, Integer bundleCount)//check
    {
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added Pricing_Type__c field to the SOQL query
        List<Pricing_Request__c> priqList = [SELECT Id, Name, Line_of_Business__c, Container_Type__c, Container_Size__c, Material_Code__c, Service_Type__c, Quote__c, Quote__r.Name, Quote_Line_Bundle__c, Quote_Line_Bundle__r.Name, Zone_Type__c,  
        Haul_Rate_Type__c,  Haul_Cost__c, Haul_Price__c, Disposal_Rate_Type__c, Disposal_Cost__c, Disposal_Price__c, Pickup_Rate_Type__c, Pickup_Cost__c, Pickup_Price__c, Extra_Pickup_Cost__c, Extra_Pickup_Price__c,  
        isAPIResult__c, APIRequestOutput__c, Case_Error_Message__c, IsCaseError__c, Cost_Source__c, Source_Code__c, Vendor_Code__c, Vendor_Name__c, Business_Unit__c, Project_Request__c, Customer_Price_Type__c,
        Disposal_Record_Id__c, Haul_Record_Id__c, Pickup_Record_Id__c, Extra_Pickup_Record_Id__c , Vendor_Comments__c, Facility_Id__c, Facility_Name__c, Schedule_or_On_Call__c, Service_Baseline_ID__c, IsPriceChangeRequest__c,
        Pricing_Type__c, Quote_Line_Bundle__r.Availability_Flag__c, Quote_Line_Bundle__r.Vendor__r.Customer_Code__c, Quote_Line_Bundle__r.SBQQ__StartDate__c, Quote_Line_Bundle__r.SBQQ__EndDate__c,
        Quote_Line_Bundle__r.ProcurementErrorMessage__c, Quote_Line_Bundle__r.BundleProcuredStatus__c, Quote_Line_Bundle__r.Pricing_Error__c
        FROM Pricing_Request__c 
        WHERE Quote__c =: quoteID AND (Pricing_Type__c = 'AM' OR Pricing_Type__c = 'AMCO') ORDER BY CreatedDate DESC LIMIT : bundleCount];
        
        
        return priqList;
    }

    public static list<SBQQ__QuoteLine__c> getQuoteLineList(ID quoteID) //Used in new apex getpricedetails method
    {
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added fields SBQQ__Quote__r.SBQQ__ShippingCountry__c, Account__r.Parent.Primary_Segment__c to the SOQL query
        List<SBQQ__QuoteLine__c> bundles = [SELECT Id, Pricing_Error__c, Is_Vendor_Mismatch__c,SBQQ__ProductCode__c, SBQQ__ProductName__c, Equipment_Size__c, SBQQ__Quote__c, SBQQ__Quote__r.Name, Name, SBQQ__StartDate__c, SBQQ__EndDate__c, Duration__c, CurrencyIsoCode,
        ProcurementErrorMessage__c, ByPassFunctionality__c,BundleProcuredStatus__c, Is_Substituted_Container__c,Type_of_Change__c, Vendor__c, Vendor__r.Name, Vendor__r.Vendor_ID__c, Vendor__r.Parent_Vendor_ID__c, Original_Equipment_Size__c, Material_Type__c, Pricing_Request__c, Pricing_Request__r.IsCaseError__c, Pricing_Request__r.APIRequestOutput__c
        , Account__r.Parent.IsPricingEligible__c, SBQQ__Product__r.Is_Pricing_Eligible__c, SBQQ__Quote__r.STP__c, BypassPriceReview__c, PriceMinQuantity__c, CostMinQuantity__c,SBQQ__Quote__r.Special_Handling__c,
        SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName, AAV_Service_Availability__c, AAV_Delivery_Availability__c, AAV_Requested_AdditionalServicesAccessor__c,Availability_Flag__c, //SDT-31027 
        SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.SBQQ__ShippingCountry__c, Account__r.Parent.Primary_Segment__c
        FROM SBQQ__QuoteLine__c 
        WHERE SBQQ__Quote__c =: quoteID  AND SBQQ__RequiredBy__c = null ]; //AND SBQQ__Product__r.Is_Pricing_Eligible__c = TRUE
        
        return bundles;
    }
    
    //20689
    public static list<SBQQ__QuoteLine__c> getQuoteLineListAll(ID quoteID) //Used in new apex getpricedetails method
    {
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added fields SBQQ__Quote__r.SBQQ__ShippingCountry__c, Account__r.Parent.Primary_Segment__c to the SOQL query
        List<SBQQ__QuoteLine__c> bundles = [SELECT Id, Pricing_Error__c, Is_Vendor_Mismatch__c,SBQQ__ProductCode__c, SBQQ__ProductName__c, Equipment_Size__c, SBQQ__Quote__c, SBQQ__Quote__r.Name, Name, SBQQ__StartDate__c, SBQQ__EndDate__c, Duration__c, CurrencyIsoCode,
        ProcurementErrorMessage__c, ByPassFunctionality__c,BundleProcuredStatus__c, Is_Substituted_Container__c,Type_of_Change__c, Vendor__c, Vendor__r.Name, Vendor__r.Vendor_ID__c, Vendor__r.Parent_Vendor_ID__c, Original_Equipment_Size__c, Material_Type__c, Pricing_Request__c, Pricing_Request__r.IsCaseError__c, Pricing_Request__r.APIRequestOutput__c
        , Account__r.Parent.IsPricingEligible__c, SBQQ__Product__r.Is_Pricing_Eligible__c, SBQQ__Quote__r.STP__c, BypassPriceReview__c, PriceMinQuantity__c, CostMinQuantity__c,SBQQ__Quote__r.Special_Handling__c,
        SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName, AAV_Service_Availability__c, AAV_Delivery_Availability__c, AAV_Requested_AdditionalServicesAccessor__c,Availability_Flag__c, //SDT-31027 
        SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.SBQQ__ShippingCountry__c, Account__r.Parent.Primary_Segment__c, SBQQ__RequiredBy__c, SBQQ__ProductFamily__c, SBQQ__Number__c,
        Occurrence_Type__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c,
        PriceUOM__c, SBQQ__ListPrice__c,SBQQ__CustomerPrice__c, CostModelType__c,
        AssetId__c, Schedule_Frequency__c, Frequency_Interval__c, Service_Days__c,
        Cost_Override_Reason__c, Price_Override_Reason__c, 
        Cost_Override_Description__c, Price_Override_Description__c
        FROM SBQQ__QuoteLine__c 
        WHERE SBQQ__Quote__c =: quoteID]; 
        
        return bundles;
    }

    @AuraEnabled(cacheable=true)
    public static boolean isPricingMulltiVendorPTSwitchON()
    {
        Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('Pricing MulltiVendor PT Switch'); 
        
        return !codeSwitchSetting.Switch_Off__c;
    }

    @AuraEnabled(cacheable=true)
    public static boolean isPricingMulltiVendorAMSwitchON()
    {
        Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('Pricing MulltiVendor AM Switch'); 
        
        return !codeSwitchSetting.Switch_Off__c;
    }
}
