/*
* @Name          PricingRequestSTPProcess
* @Author        WM - Jatan Sharma / Ali Kotawala
* @Date          03/29/2022
* @Description   This class is created to Straight-Through Processing (STP) function of Pricing Request record.
*/
public without sharing class PricingRequestSTPProcess {
    //SDT31114
    private static final String OTHER_PRICING_ERROR = 'OtherPricingError';
    private Static final string EMPTY_STRING = '';
    private Static final string SUCCESS_STRING = 'SUCCESS';
    
    public with sharing class QuotePricingWrapper {
        @AuraEnabled public String QuoteID {get;set;}
        @AuraEnabled public String BundleID {get;set;}
        @AuraEnabled public String BundleLink {get;set;}
        @AuraEnabled public String PricingReqId {get;set;}
        @AuraEnabled public String PricingRequestLink {get;set;}
        @AuraEnabled public String ProductName  {get;set;}
        @AuraEnabled public String LOB  {get;set;}
        //added for SDT 31114
        @AuraEnabled public String ProcurementErrorMessage {get;set;}
        //added for SDT 30956
        @AuraEnabled public Boolean IsVendorMismatchError {get;set;}
        @AuraEnabled public ProductDetail ProductDetails {get;set;}
        @AuraEnabled public Problem Problem {get;set;}
        @AuraEnabled Public Map<String,String> PriceOnlyReason {get; set;}
    }
    
    //added for SDT 31114
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
        @AuraEnabled public GreenPage GreenPages {get;set;}
        @AuraEnabled public List<ServiceCharges> ServiceCharges {get;set;}
        // Changes for Story 23393
        @AuraEnabled public String VendorComments  {get;set;}
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
    
    /*@methodName- getQuoteLineList
*@description- Method to query the QuoteLine Record 
*@param- Id : QuoteID
*@return- Non
*/ 
    public static list<SBQQ__QuoteLine__c> getQuoteLineList(ID quoteID)
    {
        //added as part of SDT 30956 Is_Vendor_Mismatch__c, Vendor__r.Vendor_ID__c, Vendor__r.Parent_Vendor_ID__c,
        //Type_of_Change__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName
        //adding Pricing_Error__c for 31114
        //pkulkarn-4-Aug-2023-Added SBQQ__Type__c for SDT-31211 to retrieve quote type 
        //added as part of SDT-33285 ByPassFunctionality__c
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
    
       /*@methodName- getPriceAssetErrorMessageIfAny
*@description- Method to query the QuoteLine Record SDT 31114
*@param- Id : QuoteID
*@return- Non
*/ 
    @AuraEnabled
    public static list<PricingError> getPriceAssetErrorMessageIfAny(ID quoteID)
    {
        List<PricingError> priceErrorWrapperList = new List<PricingError>();
        PricingError priceErrorWrapper = new PricingError();
        List<SBQQ__QuoteLine__c> bundles = getQuoteLineList(quoteID);
        for(SBQQ__QuoteLine__c ql : bundles){
            if( ql.Pricing_Error__c=='OtherPricingError' && ql.ProcurementErrorMessage__c!=null && ql.ProcurementErrorMessage__c!=SUCCESS_STRING && ql.BundleProcuredStatus__c=='NO')
            {
                priceErrorWrapper.ProcurementErrorMessage=ql.ProcurementErrorMessage__c;
                priceErrorWrapper.QuoteLineBundle=ql.SBQQ__ProductName__c+' '+ql.Equipment_Size__c+' '+ql.Duration__c;
                priceErrorWrapperlist.add(priceErrorWrapper);
            }
        }
        return priceErrorWrapperlist;
    }
    
    /*@methodName- getPricingList
*@description- Method to query the Pricing_Request Record 
*@param- Id : QuoteID, BundleCount
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
                                             WHERE Quote__c =: quoteID AND (Pricing_Type__c = 'AM' OR Pricing_Type__c = 'AMCO') ORDER BY CreatedDate DESC LIMIT : bundleCount];
        
        
        return priqList;
    }
    
    /*@methodName- getProductdetails
*@description- Method to query the CPQ Product Record 
*@param- Id : Non
*@return- Non
*/
    public static List<Product2> getProductdetails(){
        
        Set<string> productCodeList = new Set<string>{'CSC','DLV','RECV','DEM','REM','SWO','PSW','COF','REL','DRUN','CAS','PUSH','EQI','GTF', 'REC'};
            List<Product2> prodDetails =  [SELECT Id, ProductCode, Name, SBQQ__PricingMethod__c FROM Product2 WHERE (Family = 'Surcharges and Fees' OR ProductCode IN:productCodeList) AND IsActive = TRUE];
        
        return prodDetails;
    }
    
    /*@methodName- getProductOptions
*@description- Method to query the CPQ ProductOption Record 
*@param- Id : String
*@return- List of ProductOption
*/
    public static List<SBQQ__ProductOption__c> getProductOptions(list<string> productCode){
        
        List<SBQQ__ProductOption__c> productOption =  [SELECT id,Name, SBQQ__ProductCode__c, SBQQ__ConfiguredSKU__c,SBQQ__ConfiguredSKU__r.Name,SBQQ__ConfiguredSKU__r.ProductCode, SBQQ__OptionalSKU__c , SBQQ__OptionalSKU__r.Name ,SBQQ__OptionalSKU__r.ProductCode, Occurrence_Type__c, Schedule_Frequency__c, Frequency_Interval__c, CostModelType__c, PriceUOM__c, Cost_Unit_of_Measure__c	 
                                                       FROM SBQQ__ProductOption__c 
                                                       WHERE SBQQ__ConfiguredSKU__r.Name IN: productCode LIMIT 20000];
        
        return productOption;
    }
    
    /*@methodName- getBypassPriceReview
*@description- Method to check BypassPriceReview by Contract Type
*Change for- SDT-28904
*@param- Id : String
*@return- Boolean Value
*/
    /* public static Boolean getBypassPriceReview(string zoneType, string costSource)
{
Boolean bypassPriceReview = false;
if(zoneType == 'Open Market' && costSource.contains('WM'))
{
bypassPriceReview = true;
}
return bypassPriceReview;
}*/
    
    /*
* @Name          getBypassPriceReview
* @Vendor		  TCS
* @Author        WM - Jatan Sharma / Digdershika Ojha
* @Date          13/09/2023
* @param		  zoneType : string, parentvendor : String, library : String
* @return		  boolean
* @story		  SDT-31627
* @Description   It sets BY Pass review flag checked/unchecked based on closed market, parent vendor and MAS libraries 
*/
    
    public static Boolean getBypassPriceReview(string zoneType, string parentVendor, string library)
    {
        List<bypass_Price_Review_Setting__mdt> pricingDefaultAttributeList = [SELECT Default_Value__c,MarketAreaType__c from bypass_Price_Review_Setting__mdt];
        Map<string,string> masMarketAreaMap = new Map<string,string>();
        
        for(bypass_Price_Review_Setting__mdt defValue : pricingDefaultAttributeList){
            masMarketAreaMap.put(defValue.Default_Value__c,defValue.MarketAreaType__c);
        }
        Boolean bypassPriceReview = true;
        if(parentVendor != null && (parentVendor == Pricing_Constant_Util.VENDOR_WM || parentVendor == Pricing_Constant_Util.VENDOR_CANADA || parentVendor.contains(Pricing_Constant_Util.WM_VENDOR))){
            if((zoneType == Pricing_Constant_Util.WM_FRANCHISE && library != null && masMarketAreaMap.containsKey(library) && masMarketAreaMap.get(library).contains(Pricing_Constant_Util.CLOSED)) 
               || masMarketAreaMap.containsKey(library) && masMarketAreaMap.get(library).contains(Pricing_Constant_Util.OPEN)){
                   bypassPriceReview = false;
               }
        }
        else{
            bypassPriceReview = false;
        }
        return bypassPriceReview;
    }
    
    /*@methodName- getQuoteStatusByCase
*@description- Method to Check the Quote Status By Case Id 
*@param- Id : String
*@return- STPStatusWrapper
*/
    @AuraEnabled
    public static STPStatusWrapper getQuoteStatusByCase(ID caseId){
        STPStatusWrapper wrapperSTP = new STPStatusWrapper();
        wrapperSTP.IsInvokeSTP = false;
        
        
        try{
            List<Pricing_Request__c> prRecordList = [SELECT Id, isAPIResult__c, IsCaseError__c, Quote__c, Case__c, Case_Number__c, Quote__r.QuoteProcuredStatus__c, Quote__r.SBQQ__Status__c FROM Pricing_Request__c WHERE Case__c =: caseId AND (Pricing_Type__c = 'AM' OR Pricing_Type__c = 'AMCO')];
            //system.debug('wrapperSTP.IsInvokeSTP---->'+ wrapperSTP.IsInvokeSTP);
            //system.debug('prRecordList---->'+ prRecordList);
            if(prRecordList != null && prRecordList.size() > 0){
                for(Pricing_Request__c pr : prRecordList){
                    if(pr.Quote__r.QuoteProcuredStatus__c == null)
                    {
                       // system.debug('In True condition when QuoteProcuredStatus__c Null---->');
                        wrapperSTP.IsInvokeSTP = true;
                        wrapperSTP.QuoteId = pr.Quote__c;
                        wrapperSTP.QuoteProcuredStatus = pr.Quote__r.QuoteProcuredStatus__c;
                        wrapperSTP.QuoteStatus = pr.Quote__r.SBQQ__Status__c;
                        break;
                    }
                    else if(pr.Quote__r.QuoteProcuredStatus__c == 'Success' || pr.Quote__r.QuoteProcuredStatus__c == 'Failed')
                    {
                        //system.debug('In False condition when QuoteProcuredStatus__c have value---->');
                        wrapperSTP.IsInvokeSTP = false;
                        wrapperSTP.QuoteProcuredStatus = pr.Quote__r.QuoteProcuredStatus__c;
                        wrapperSTP.QuoteStatus = pr.Quote__r.SBQQ__Status__c;
                    }
                }
            }
        }
        catch(Exception ex){
           // system.debug('In Exception getQuoteStatusByCase---->');
            wrapperSTP.IsInvokeSTP = false;
            wrapperSTP.QuoteId = null;
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' CaseId: ' + caseId, LoggingLevel.ERROR);
        }
        
        return wrapperSTP;
    }
    
    /*@methodName- processPricingRequest
*@description- Method to call the pricing process method synchronouly 
*@param- Id : QuoteId, Boolean
*@return- List of wrapper - QuotePricingWrapper
*/    
    @AuraEnabled
    public static List<QuotePricingWrapper> processPricingRequest(ID quoteID, Boolean isFirstCall)
    {
        List<QuotePricingWrapper> wrapperList = new List<QuotePricingWrapper>();
        try
        {
            if(isFirstCall)
            {
                // Call quoteLineProcess to process the API and Insert, Update and Delete
                // the quote line according to STP business rules
                
                quoteLineProcess(quoteID);
                // Call saveProcuredStatus to update the quote and quoteline
                // for procured - complete and incomplete also check the Substituted logic
                saveProcuredStatus(quoteID);
            }
            else{
                // After successfully run the STP, Procurement and Substituted logic
                // call the getPricingDetails to create the wrapper 
                // which will pass to UI for User presentation.
                wrapperList =  getPricingDetails(quoteID);
               // System.debug('Pricing Wrapper ---> ' + wrapperList);
            }
        }
        catch(Exception ex) 
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
        }
        return wrapperList;
    }
    
    /*@methodName- getIsVendorMismatchError
    *@description- SDT 30956 Method to get  IsVendorMismatchError for 
    *@param- Id : SBQQ__QuoteLine__c ql, QuotePricingWrapper qpWrapper
    */ 
    public static void getIsVendorMismatchError(SBQQ__QuoteLine__c ql, QuotePricingWrapper qpWrapper)
    {
        //added IsVendorMismatchError to wrapper as part of SDT 30956
        qpWrapper.IsVendorMismatchError = ql.Is_Vendor_Mismatch__c;
    }
    
    /*@methodName- compareQuotelineVendorWithPRVendor
    *@description- SDT 30956 Method to compare the pricing API response and update Quote and QuoteLine 
    *@param- Id : SBQQ__QuoteLine__c ql, SBQQ__QuoteLine__c sqlHdr, Account Vendor
    *@return- Boolean true if it's Quoteline's vendor Id matches with Pricing Request's vendor Id
    */ 
    public static boolean compareQuotelineVendorWithPRVendor(SBQQ__QuoteLine__c ql, SBQQ__QuoteLine__c sqlHdr, Account vendorAccount)
    {
        Boolean isVendorSame=false;
        sqlHdr.Is_Vendor_Mismatch__c = false;
        if(vendorAccount!=null && (ql.Vendor__r.Vendor_ID__c == vendorAccount.Vendor_ID__c || ql.Vendor__r.Parent_Vendor_ID__c == vendorAccount.Parent_Vendor_ID__c) && (ql.Type_of_Change__c != null)){
            isVendorSame=true;
        }
        else if(vendorAccount==null || ql.Vendor__r.Parent_Vendor_ID__c != vendorAccount.Parent_Vendor_ID__c || ql.Type_of_Change__c == null){
            sqlHdr.BundleProcuredStatus__c = 'NO';
            //sqlHdr.ProcurementErrorMessage__c += System.label.Vendor_Mismatch;
            sqlHdr.Is_Vendor_Mismatch__c = true;
            isVendorSame=false;
        }
        return isVendorSame;
    }
    /*@methodName- quoteLineProcess
*@description- Method to process the pricing API response and update Quote and QuoteLine 
*@param- Id : QuoteId
*@return- List of wrapper - QuotePricingWrapper
*/ 
    public static void quoteLineProcess(ID quoteID)
    {
        //system.debug('Inside processPricingRequest');
        //pkulkarn-4-Aug-2023-Added below 2 variables for SDT-31211
        String quoteType = '';
        Map<Id, SBQQ__QuoteLine__c> allQuoteLinesExceptBundles = new Map<Id, SBQQ__QuoteLine__c>();
        PricingReportingFieldsMetadata prFields = new PricingReportingFieldsMetadata();
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
        List<SBQQ__QuoteLine__c> bundles = getQuoteLineList(quoteID);
        Integer bundlesCount = bundles.size();
        String currencySymbol;
        
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
        
        List<Pricing_Request__c> priqList = getPricingList(quoteID, bundlesCount);
        List<SBQQ__ProductOption__c> productOptions = getProductOptions(productCodelst);
        for(SBQQ__ProductOption__c prdopt : productOptions){
            string concatecode = prdopt.SBQQ__ConfiguredSKU__r.ProductCode + prdopt.SBQQ__OptionalSKU__r.ProductCode;
            qlProductoption.put(concatecode,prdopt);
        }
        
        Set<Id> bundleIDSet = new Set<Id>();
        for(SBQQ__QuoteLine__c qlId : bundles)
        {
            bundleIDSet.add(qlId.Id);
        }
       // system.debug('PK bundleIDSet ' + bundleIDSet);
        if(bundleIDSet != null)
        {
            //pkulkarn-4-Aug-2023-Added Type_of_Change__c, AssetId__c for SDT-31211
            //added as part of SDT-33285 ByPassFunctionality__c
            qlBuldle = [SELECT Id, SBQQ__ProductCode__c, SBQQ__ProductName__c,
                        SBQQ__Number__c,SBQQ__ProductFamily__c, SBQQ__Quote__c,
                        Occurrence_Type__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, 
                        PriceUOM__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, 
                        SBQQ__CustomerPrice__c, CostModelType__c,
                        Type_of_Change__c, AssetId__c,ByPassFunctionality__c,
                        Schedule_Frequency__c,Frequency_Interval__c,Service_Days__c //Added by Sarfaraz for 44637
                        FROM SBQQ__QuoteLine__c 
                        WHERE SBQQ__RequiredBy__c IN: bundleIDSet  ORDER BY SBQQ__Number__c DESC];
        }
        
        quoteLineNumber = qlBuldle != null && qlBuldle.size() > 0 ? qlBuldle[0].SBQQ__Number__c: 0;
        // system.debug('qlBuldle ' +qlBuldle);
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
                        quoteLineCoreSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{ qlSrvReq }
                                               );
                    }
                    
                }
                
                else
                {
                    
                    if (quoteLineSrvMap.containsKey(qlSrvReq.SBQQ__RequiredBy__c)) {
                        List<SBQQ__QuoteLine__c> quotelst = quoteLineSrvMap.get(qlSrvReq.SBQQ__RequiredBy__c);
                        quotelst.add(qlSrvReq);
                        quoteLineSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c, quotelst);
                    } else {
                        quoteLineSrvMap.put(qlSrvReq.SBQQ__RequiredBy__c,new List<SBQQ__QuoteLine__c>{ qlSrvReq }
                                           );
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
        
        List<Product2> productList = getProductdetails();
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
            if(prVendor.Vendor_Code__c != null)
            {
                vendorSet.add(prVendor.Vendor_Code__c.contains('|') ? prVendor.Vendor_Code__c.substringBefore('|') : prVendor.Vendor_Code__c);
            }
        }
        if(vendorSet != null && vendorSet.size()>0){
            //added Vendor_ID__c, Parent_Vendor_ID__c for SDT 30956
            vendorLst = [SELECT Id, Vendor_ID__c, Parent_Vendor_ID__c FROM Account WHERE Status__c = 'Active' AND Vendor_ID__c IN : vendorSet];
        }
        
        if(!vendorLst.isEmpty()){
            for(Account ven : vendorLst){
                quoteVendorMap.put(ven.Vendor_ID__c,ven);
            }
        }
        
        for(Pricing_Request__c pr : priqList)
        {
            // system.debug('inside pr loop '+ pr);
           // system.debug('pr.IsCaseError__c ' + pr.IsCaseError__c +'pr.isAPIResult__c '+ pr.isAPIResult__c);
            SBQQ__QuoteLine__c ql = quoteHdrMap.get(pr.Quote_Line_Bundle__c);
            
            SBQQ__QuoteLine__c sqlHdr = new SBQQ__QuoteLine__c();
            needRecyclingQL = false;
            if(!pr.IsCaseError__c && pr.isAPIResult__c)
            {
               // system.debug('@@@ QL BUndle Id: '+ pr.Quote_Line_Bundle__c);
                // system.debug('@@@ PR test '+pr.APIRequestOutput__c);
                prFields = PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c);
                
                currencySymbol = prFields.Data.currencyCode;
                
                //Add value in Bundle Header - Start
                sqlHdr.Id = pr.Quote_Line_Bundle__c;
                sqlHdr.Pricing_Request__c = pr.Id;
                sqlHdr.CurrencyIsoCode = currencySymbol;
                //sqlHdr.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);
                //Comment Code for SDT-31291 : Start
                // if(prFields.Data.overridableEquipmentSizeCode != null)
                // {
                //     sqlHdr.Equipment_Size__c = prFields.Data.overridableEquipmentSizeCode;
                //     sqlHdr.Original_Equipment_Size__c = prFields.Data.equipmentSizeName;
                // }
                
                //Use isPriceOnly for SDT-20125
                if(prFields.Data.costSource != null)
                {
                    String sourceCodeStr = prFields.Data.costSource;
                    sqlHdr.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? pr.Name : sourceCodeStr;
                }
                if(pr.Vendor_Code__c != null)
                {
                    if(quoteVendorMap != null && quoteVendorMap.size() > 0)
                    {
                        String vendorCode = pr.Vendor_Code__c.contains('|') ? pr.Vendor_Code__c.substringBefore('|') : pr.Vendor_Code__c;
                        vendorId = quoteVendorMap.get(vendorCode) != null ? quoteVendorMap.get(vendorCode).Id : null;
                        //added for SDT 30956
                        vendor = quoteVendorMap.get(vendorCode) != null ? quoteVendorMap.get(vendorCode) : null;
                    }
                    //added for SDT 30956
                   // system.debug('case record type is'+ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName);
                    //if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_UPDATE_ASSET_CASE){
                    if(ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API){    
                        
                        Boolean isVendorMatched = compareQuotelineVendorWithPRVendor(ql, sqlHdr, vendor);
                        if(!isVendorMatched){
                            //if vendor is null or does not matched, Quoteline will not be updated 
                            upsertQLLIst.add(sqlHdr);
                            continue;
                        }
                    }
                    //added for SDT 30956 end
                    sqlHdr.Vendor__c = vendorId;
                    
                    //SDT-31627
                    //sqlHdr.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, vendor.Parent_Vendor_ID__c, null);
                    //SDT-39060 commented BypassPriceReview__c as covered through new story SDT-29645
                    /*if(vendor!=null){
                    sqlHdr.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, vendor.Parent_Vendor_ID__c, null);
                    }*/
                    //system.debug('-------> Quoteline vendor : ' + ql.Vendor__r.Vendor_ID__c+'QLPARENT'+ql.Vendor__r.Parent_Vendor_ID__c);
                    //system.debug('-------> QuotelineHeader : ' + sqlHdr.Vendor__r.Vendor_ID__c+'HEADERQLPARENT'+sqlHdr.Vendor__r.Parent_Vendor_ID__c);
                    //system.debug('-------> Vendor : ' + vendor.Vendor_ID__c+'vendorParent'+vendor.Parent_Vendor_ID__c);
                    
                    //system.debug('-------> changes in QL : ' + ql.Type_of_Change__c);
                    //system.debug('-------> Value of vendor at Hdr QL : ' + vendorId);
                }
                upsertQLLIst.add(sqlHdr);
                
                if(pr.Zone_Type__c == null || 
                   (pr.Zone_Type__c != System.label.WM_Franchise && pr.Zone_Type__c != System.label.Competitor &&
                    pr.Zone_Type__c != System.label.Pre_Determined_Pricing && pr.Zone_Type__c != System.label.Third_Party_Agreement))
                {
                    //This loop is for Core Service Charge
                    List<SBQQ__QuoteLine__c> quotelineCoreSrvbundleLst = quoteLineCoreSrvMap != null ? quoteLineCoreSrvMap.get(pr.Quote_Line_Bundle__c) : null;
                    for(SBQQ__QuoteLine__c sql : quotelineCoreSrvbundleLst)
                    {
                        //Add value in Bundle QL - Start
                        SBQQ__QuoteLine__c sqlCoreService = new SBQQ__QuoteLine__c();
                        
                        sqlCoreService.Id = sql.Id;
                        sqlCoreService.Pricing_Request__c = pr.Id;
                        //SDT-31627
                        //sqlCoreService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);
                        //SDT-39060 commented BypassPriceReview__c as covered through new story SDT-29645
                        //sqlCoreService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, vendor.Parent_Vendor_ID__c, null);
                        //Comment Code for SDT-31291 : Start
                        // if(prFields.Data.overridableEquipmentSizeCode != null)
                        // {
                        //     sqlCoreService.Equipment_Size__c = prFields.Data.overridableEquipmentSizeCode;
                        //     sqlCoreService.Original_Equipment_Size__c = prFields.Data.equipmentSizeName;
                        // }
                        
                        if(prFields.Data.costSource != null)
                        {
                            String sourceCodeStr = prFields.Data.costSource;
                            sqlCoreService.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? pr.Name : sourceCodeStr;
                        }
                        if(pr.Vendor_Code__c != null)
                        {
                            sqlCoreService.Vendor__c = vendorId;
                        }
                        
                        if(sql.SBQQ__ProductName__c.equals(Constant_Util.HAUL) || sql.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL)
                           || sql.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP) || sql.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP)
                           || sql.SBQQ__ProductName__c.equals(Constant_Util.RECYCLING))
                        {
                            String apivalueUOMID = null;
                            apivalueUOMID = ExhibitPriceServices.setMonthlytoMonthUOM(costUOMMapName, prFields.Data.equipmentUOM);
                            sqlCoreService.CurrencyIsoCode = currencySymbol;                                    
                            
                            if(prFields.Data.rollOff != null)
                            {
                                if(sql.SBQQ__ProductName__c.equals(Constant_Util.HAUL))
                                {
                                    // if((prFields.Data.costSource.contains('WM') && prFields.Data.rollOff.haulCost < 10000) || !prFields.Data.costSource.contains('WM'))
                                    // {
                                    sqlCoreService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodHaulingDescription;
                                    sqlCoreService.SBQQ__UnitCost__c = prFields.Data.rollOff.haulCost;
                                    sqlCoreService.SBQQ__ListPrice__c = prFields.Data.rollOff.haulPrice;
                                    // }
                                }
                                else if(sql.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL))
                                {
                                    if(apivalueUOMID != null)
                                    {
                                        sqlCoreService.Cost_Unit_of_Measure__c = apivalueUOMID;
                                        sqlCoreService.PriceUOM__c = apivalueUOMID;
                                    }
                                    
                                    //Stepped Pricing changes
                                    if(prFields.Data.rollOff.stepDisposals != null && prFields.Data.rollOff.stepDisposals.size() > 0)
                                    {
                                        sqlCoreService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodDisposalDescription;
                                        Integer steppedCounter = 1;
                                        for(PricingReportingFieldsMetadata.StepDisposal step : prFields.Data.rollOff.stepDisposals)
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
                                            if(prFields.Data.rollOff.disposalCost == null)
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
                                                sqlCoreService.SBQQ__UnitCost__c = prFields.Data.rollOff.disposalCost;
                                            }
                                            
                                            if(prFields.Data.rollOff.disposalPrice == null)
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
                                                sqlCoreService.SBQQ__ListPrice__c = prFields.Data.rollOff.disposalPrice;
                                            }
                                            steppedCounter++;
                                        }
                                    }
                                    else
                                    {
                                        if((prFields.Data.costSource.contains('WM') && prFields.Data.rollOff.disposalCost >= 0) || !prFields.Data.costSource.contains('WM'))
                                        {
                                            sqlCoreService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodDisposalDescription;
                                            sqlCoreService.CostModelType__c = 'PER';
                                            sqlCoreService.SBQQ__UnitCost__c = prFields.Data.rollOff.disposalCost;
                                            sqlCoreService.SBQQ__PricingMethod__c = 'List';
                                            sqlCoreService.SBQQ__ListPrice__c = prFields.Data.rollOff.disposalPrice;
                                        }
                                        
                                        
                                    }
                                    //Change for Story SDT-23396
                                    if(prFields.Data.feeComment != null && prFields.Data.feeComment.contains('Rebate'))
                                    {
                                        deleteQuotelinelst.add(sql.Id);
                                        needRecyclingQL = true;
                                    }
                                    
                                    //Change for Story SDT-29195
                                    if(prFields.Data.serviceCharges != null)
                                    {
                                        Double costMinTon, priceMinTon;
                                        for(Integer scIndex = 0; scIndex < prFields.Data.serviceCharges.size(); scIndex++)
                                        {
                                            if(prFields.Data.materialCode == 'C' || prFields.Data.materialCode == 'SSR')
                                            {
                                                if(prFields.Data.serviceCharges[scIndex].name.toLowerCase().contains(System.label.Minimum_Tons_Recycling))
                                                {
                                                    costMinTon = prFields.Data.serviceCharges[scIndex].cost;
                                                    priceMinTon = prFields.Data.serviceCharges[scIndex].price;
                                                    break;
                                                }
                                            }
                                            else
                                            {
                                                if(prFields.Data.serviceCharges[scIndex].name.toLowerCase().contains(System.label.All_Other_Minimum_Tonnage))
                                                {
                                                    costMinTon = prFields.Data.serviceCharges[scIndex].cost;
                                                    priceMinTon = prFields.Data.serviceCharges[scIndex].price;
                                                    break;
                                                }
                                            }
                                        }
                                        //Change SDT-30495, Update CostMinQuantity and PriceMinQuantity to null when actual value is zero.
                                        if(prFields.Data.costSource.contains('WM'))
                                        { 
                                            //when the vendor is WM, then min tons price copy to both Cost and Price
                                            sqlCoreService.CostMinQuantity__c = setZeroASNullforMinTon(priceMinTon);
                                            sqlCoreService.PriceMinQuantity__c = setZeroASNullforMinTon(priceMinTon);
                                        }
                                        else
                                        {
                                            //when the vendor is 3P, then min tons price copy to price and  Cost copy to cost
                                            sqlCoreService.CostMinQuantity__c = setZeroASNullforMinTon(costMinTon);
                                            sqlCoreService.PriceMinQuantity__c = setZeroASNullforMinTon(priceMinTon);
                                        }
                                    }
                                }
                                else if(sql.SBQQ__ProductName__c.equals(Constant_Util.RECYCLING))
                                {
                                    if(prFields.Data.feeComment != null && prFields.Data.feeComment.contains('Rebate'))
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
                                        sqlancillaryService.Vendor__c = vendorId;
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
                                        sqlancillaryService.ContractNotes__c = prFields.Data.feeComment;
                                        //SDT-31627
                                        //sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);
                                        //SDT-39060 commented BypassPriceReview__c as covered through new story SDT-29645
                                        //sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, vendor.Parent_Vendor_ID__c, null);
                                        //Changes done for SDT-24353
                                        if(prFields.Data.costSource != null)
                                        {
                                            String sourceCodeStr = prFields.Data.costSource;
                                            sqlancillaryService.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? pr.Name : sourceCodeStr;
                                        }
                                        sqlancillaryService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodHaulingDescription;
                                        //End
                                        //Comment Code for SDT-31291 : Start
                                        // if(prFields.Data.overridableEquipmentSizeCode != null)
                                        // {
                                        //     sqlancillaryService.Equipment_Size__c = prFields.Data.overridableEquipmentSizeCode;
                                        //     sqlancillaryService.Original_Equipment_Size__c = prFields.Data.equipmentSizeName;
                                        // }
                                        
                                        upsertQLLIst.add(sqlancillaryService);
                                        quoteLineNumber++;
                                        
                                        needRecyclingQL = false;
                                    }
                                }
                            }
                            else if(prFields.Data.commercial != null)
                            {
                                if(sql.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP))
                                {
                                    sqlCoreService.Pricing_API_Method__c = pr.Pickup_Rate_Type__c;
                                    sqlCoreService.SBQQ__UnitCost__c = prFields.Data.commercial.unitCost;
                                    sqlCoreService.SBQQ__ListPrice__c = prFields.Data.commercial.unitPrice;
                                    if(pr.Schedule_or_On_Call__c == Constant_Util.SCHEDULED && apivalueUOMID != null)
                                    {
                                        sqlCoreService.Cost_Unit_of_Measure__c = apivalueUOMID;
                                        sqlCoreService.PriceUOM__c = apivalueUOMID;
                                    }
                                    else if(pr.Schedule_or_On_Call__c == Constant_Util.ON_CALL)
                                    {
                                        sqlCoreService.Cost_Unit_of_Measure__c = 'EV';
                                        sqlCoreService.PriceUOM__c = 'EV';
                                    }
                                }
                                else if(sql.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP))
                                {
                                    sqlCoreService.SBQQ__UnitCost__c = prFields.Data.commercial.extraPickupCost;
                                    sqlCoreService.SBQQ__ListPrice__c = prFields.Data.commercial.extraPickupPrice;
                                    sqlCoreService.Cost_Unit_of_Measure__c = 'EV';
                                    sqlCoreService.PriceUOM__c = 'EV';
                                }
                            }
                        }
                        upsertQLLIst.add(sqlCoreService);
                    }
                    
                    if(prFields.Data.serviceCharges != null)
                    {
                        //This loop is for Ancillary Charge (Non Core Service Charge)
                        //system.debug('ServiceCharge QuoteLine Id ' + pr.Quote_Line_Bundle__c);
                        List<SBQQ__QuoteLine__c> quotelineSrvbundleLst = quoteLineSrvMap.get(pr.Quote_Line_Bundle__c);
                        //system.debug('ServiceCharge QuoteLine Bundle ' + quotelineSrvbundleLst);
                        //system.debug('Checking core services>>'+quoteLineCoreSrvMap);
                        for(Integer scIndex = 0; scIndex < prFields.Data.serviceCharges.size(); scIndex++)
                        {
                            Boolean isServiceExist = false;
                            SBQQ__QuoteLine__c currentQl ; 
                            for(PricingSTP__mdt meta : pricingSTP)
                            {
                                if(prFields.Data.serviceCharges[scIndex].name.contains(meta.ServiceChargeName__c) 
                                   && (prFields.Data.serviceCharges[scIndex].actionName == meta.AcitonName__c
                                       ||  prFields.Data.serviceCharges[scIndex].actionName == null))
                                {
                                    String costUOMID = null, priceUOMID = null;
                                    costUOMID = ExhibitPriceServices.setMonthlytoMonthUOM(costUOMMapName, prFields.Data.serviceCharges[scIndex].costUOM);
                                    priceUOMID =ExhibitPriceServices.setMonthlytoMonthUOM(priceUOMMapName, prFields.Data.serviceCharges[scIndex].priceUOM);
                                    
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
                                        if(pr.Vendor_Code__c != null)
                                        {
                                            currentQl.Vendor__c = vendorId;
                                        }
                                        //Comment Code for SDT-31291 : Start
                                        // if(prFields.Data.overridableEquipmentSizeCode != null)
                                        // {
                                        //     currentQl.Equipment_Size__c = prFields.Data.overridableEquipmentSizeCode;
                                        //     currentQl.Original_Equipment_Size__c = prFields.Data.equipmentSizeName;
                                        // }
                                        currentQl.CurrencyIsoCode = currencySymbol;
                                        //SDT-31627
                                        //currentQl.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);
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
                                        pricingResponseProcessorInput.prFields = prFields;
                                        pricingResponseProcessorInput.pricingRequest = pr;
                                        pricingResponseProcessorInput.quoteLineRecord = isServiceExist ? currentQl : null;
                                        
                                        /*if(additionalMetadataRetrieved == false)
                                        {
                                        pricingResponseQuoteLineMetadata = prp.retrieveProcessQuoteLineMetadata();
                                        additionalMetadataRetrieved = true;
                                        }
                                        //prpInput.processQuoteLineMetadata = pricingResponseQuoteLineMetadata;*/
                                        pricingResponseProcessorInput.processQuoteLineMetadata = pricingResponseProcessor.retrieveProcessQuoteLineMetadata(pricingResponseQuoteLineMetadata);
                                        //system.debug('PK meta.ServiceChargeName__c' + meta.ServiceChargeName__c);
                                        pricingResponseProcessorOutput = pricingResponseProcessor.determineQuoteLineAction(pricingResponseProcessorInput);
                                        
                                        //system.debug('PK prpOutput ' + prpOutput);
                                    }
                                    //TCS-pkulkarn-SDT-40031-9-Apr-2025-End
                                    
                                    if(prFields.Data.serviceCharges[scIndex].actionName == 'Allow' || prFields.Data.serviceCharges[scIndex].actionName == 'Adjust' 
                                    || prFields.Data.serviceCharges[scIndex].actionName == null || prFields.Data.serviceCharges[scIndex].actionName == 'Manual Review')
                                    {
                                        //Added by Sarfaraz for SDT-44637
                                        if(prFields.Data.serviceCharges[scIndex].componentTypeCode==exhibitService.CSC)
                                        {
                                            if((prFields.Data.serviceCharges[scIndex].costUOM==exhibitService.DAYS||prFields.Data.serviceCharges[scIndex].costUOM==exhibitService.MONTHS
                                                ||prFields.Data.serviceCharges[scIndex].costUOM==exhibitService.WEEKS||prFields.Data.serviceCharges[scIndex].costUOM=='Event')  
                                               && exhibitService.checkIfNewServiceCase(quoteID) 
                                               && exhibitService.checkIfCanadianAccount(quoteID))
                                            {
                                            currentQl.Occurrence_Type__c=exhibitService.SCH;
                                            currentQl.Schedule_Frequency__c=(prFields.Data.serviceCharges[scIndex].costUOM).substring(0,1);
                                            currentQl.Frequency_Interval__c='1';
                                            currentQl.Service_Days__c=null;
                                                if(prFields.Data.serviceCharges[scIndex].costUOM=='Event')
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
                                            if(prFields.Data.serviceCharges[scIndex].cost != null || prFields.Data.serviceCharges[scIndex].price != null)
                                            {
                                                if(prFields.Data.serviceCharges[scIndex].costValueType != null && prFields.Data.serviceCharges[scIndex].costValueType.equals(Constant_Util.PERCENT))
                                                {
                                                    currentQl.SBQQ__SubscriptionPercent__c = prFields.Data.serviceCharges[scIndex].cost;
                                                    currentQl.SBQQ__UnitCost__c = 0.00;
                                                }
                                                else
                                                {
                                                    currentQl.SBQQ__UnitCost__c = prFields.Data.serviceCharges[scIndex].cost;
                                                }
                                                
                                                if(prFields.Data.serviceCharges[scIndex].priceValueType != null && prFields.Data.serviceCharges[scIndex].priceValueType.equals(Constant_Util.PERCENT))
                                                {
                                                    currentQl.SBQQ__MarkupRate__c = prFields.Data.serviceCharges[scIndex].price;
                                                    currentQl.SBQQ__ListPrice__c = 0.00;
                                                }
                                                else
                                                {
                                                    currentQl.SBQQ__ListPrice__c = prFields.Data.serviceCharges[scIndex].price;
                                                }
                                                currentQl.Cost_Unit_of_Measure__c = costUOMID;
                                                currentQl.PriceUOM__c = priceUOMID;
                                            }
                                            else
                                            {
                                                if(prFields.Data.isCostOnly)
                                                {
                                                    currentQl.SBQQ__ListPrice__c = null;
                                                }
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
                                            if(prFields.Data.serviceCharges[scIndex].cost != null || prFields.Data.serviceCharges[scIndex].price != null)
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
                                                    for(id quoteLineId:quoteLineCoreSrvMap.keySet())
                                                        {
                                                            for(SBQQ__QuoteLine__c singleQuoteLine:quoteLineCoreSrvMap.get(quoteLineId) )
                                                            {
                                                            exhibitService.ancillaryQuoteLineProductCode=prd.ProductCode;
                                                            exhibitService.processAncillaryQuoteLine(sqlancillaryService, singleQuoteLine, costUOMMapName, priceUOMMapName, prFields.Data.serviceCharges[scIndex].costUOM,prFields.Data.serviceCharges[scIndex].priceUOM);
                                                                                                         
                                                            }}
                                                    
                                                    //end by Sarfaraz
                                                    //Add for SDT-29716
                                                    if(prd.Name == Constant_Util.ENERGY_SURCHARGE || prd.Name == Constant_Util.ENVIRONMENTAL_CHARGE)
                                                    {
                                                        sqlancillaryService.SBQQ__PricingMethod__c = 'List';
                                                    }
                                                    else
                                                    {
                                                        sqlancillaryService.SBQQ__PricingMethod__c = prd.SBQQ__PricingMethod__c;
                                                    }
                                                    //End
                                                   // system.debug('-------> Value of vendor at DLV QL : ' + vendorId);
                                                    if(pr.Vendor_Code__c != null)
                                                    {
                                                        sqlancillaryService.Vendor__c = vendorId;
                                                    }
                                                    sqlancillaryService.SBQQ__OptionLevel__c = 1;
                                                    sqlancillaryService.SBQQ__Quantity__c = 1;
                                                    sqlancillaryService.SBQQ__Number__c = quoteLineNumber + 1; //need to check what this field is for.
                                                    sqlancillaryService.SBQQ__CostEditable__c = true;
                                                    sqlancillaryService.SBQQ__PriceEditable__c = true;
                                                    sqlancillaryService.SBQQ__StartDate__c = ql.SBQQ__StartDate__c;
                                                    sqlancillaryService.SBQQ__EndDate__c = ql.SBQQ__EndDate__c;
                                                    sqlancillaryService.CurrencyIsoCode = currencySymbol;
                                                    //SDT-31627
                                                    //sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);
                                                    //SDT-39060 commented BypassPriceReview__c as covered through new story SDT-29645
                                                    //sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, vendor.Parent_Vendor_ID__c, null);
                                                    //Comment Code for SDT-31291 : Start
                                                    // if(prFields.Data.overridableEquipmentSizeCode != null)
                                                    // {
                                                    //     sqlancillaryService.Equipment_Size__c = prFields.Data.overridableEquipmentSizeCode;
                                                    //     sqlancillaryService.Original_Equipment_Size__c = prFields.Data.equipmentSizeName;
                                                    // }
                                                    if(prFields.Data.serviceCharges[scIndex].costValueType != null && prFields.Data.serviceCharges[scIndex].costValueType.equals(Constant_Util.PERCENT))
                                                    {
                                                        sqlancillaryService.SBQQ__SubscriptionPercent__c = prFields.Data.serviceCharges[scIndex].cost;
                                                        sqlancillaryService.SBQQ__UnitCost__c = 0.00;
                                                    }
                                                    else
                                                    {
                                                        sqlancillaryService.SBQQ__UnitCost__c = prFields.Data.serviceCharges[scIndex].cost;
                                                    }
                                                    if(prFields.Data.serviceCharges[scIndex].priceValueType != null && prFields.Data.serviceCharges[scIndex].priceValueType.equals(Constant_Util.PERCENT))
                                                    {
                                                        sqlancillaryService.SBQQ__MarkupRate__c = prFields.Data.serviceCharges[scIndex].price;
                                                        sqlancillaryService.SBQQ__ListPrice__c = 0.00;
                                                    }
                                                    else
                                                    {
                                                        sqlancillaryService.SBQQ__ListPrice__c = prFields.Data.serviceCharges[scIndex].price;
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
                                    // else if(prFields.Data.serviceCharges.actionName == "Adjust")
                                    // {
                                    //     // This is for future use. If in future we have saperate business rule for Adjust.
                                    // }
                                    else if(prFields.Data.serviceCharges[scIndex].actionName == 'Exclude')
                                    {
                                        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Moved existing code to if block and added else if block
                                        //TCS-pkulkarn-SDT-40031-12-May-2025-Added OR condition in below if statement for defect SDT-47976
                                        if(meta.Additional_Processing_Needed__c == false || (meta.Additional_Processing_Needed__c == true && pricingResponseProcessorOutput.overrideAction == false))
                                        {
                                            system.debug('Exclude code will run');
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
                                                }
                                            }
                                        }
                                        //TCS-pkulkarn-SDT-40031-9-Apr-2025-End
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
                //Handling the GreenPage and Francise link through the above code where Quote header line initializes.
                //No need to create the else statement
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
            upsertQLLIst = filterUpsertQuoteLinesForQuoteType(upsertQLLIst, quoteType, allQuoteLinesExceptBundles);
            deleteQuotelinelst = filterDeleteQuoteLinesForQuoteType(deleteQuotelinelst, quoteType);
        }
        catch(exception ex){
           // system.debug('Quote Line upsert for pricing request ' + ex.getMessage());
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
        }
        finally
        {
            //Nothing here
        }
        //END - pkulkarn-4-Aug-2023-Added for SDT-31211
        
        if(upsertQLLIst !=null && upsertQLLIst.size() > 0 ){
            try{
                //system.debug('Initiate QL upsert');
                //Skip QL validation for Cost/Price, SDT-26002
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = true;
                upsert upsertQLLIst;
               // system.debug('Complete QL upsert');
                
            }
            catch(exception ex){
               // system.debug('Quote Line upsert for pricing request ' + ex.getMessage());
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
            }
            finally
            {
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = false;
            }
        }
        if(deleteQuotelinelst !=null && deleteQuotelinelst.size() > 0 ){
            try{
               // system.debug('Initiate QL Delete');
                database.delete(deleteQuotelinelst);
               // system.debug('Complete QL Delete');
            }
            catch(exception ex){
                //system.debug('Quote Line delete for pricing request ' + ex.getMessage());
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + ' QuoteID: ' + quoteID, LoggingLevel.ERROR);
            }
        }
    }
    
    /*
    * Vendor: TCS 
    * Developer: Pavankumar Kulkarni
    * Input: List of Quote Lines
    * Output: List of Quote Lines
    * Description: SDT-31211-Return a list of Quote Lines which have the Id field having a non null value for quoteTypes Amendment/Exception/Correction
    */
    public static List<SBQQ__QuoteLine__c> filterUpsertQuoteLinesForQuoteType(List<SBQQ__QuoteLine__c> quoteLines, String quoteType, Map<Id, SBQQ__QuoteLine__c> allQuoteLines)
    {
        List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
        
        if(quoteType == Pricing_Constant_Util.QUOTE_TYPE_AMEND || quoteType == Pricing_Constant_Util.QUOTE_TYPE_CORRECTION || quoteType == Pricing_Constant_Util.QUOTE_TYPE_EXCEPTION)
        {
            for(SBQQ__QuoteLine__c quoteLine : quoteLines)
            {
                
                // String costPriceCode = System.label.Cost_and_Price_Code;
                //If(costPriceCode.Equals('True'))
                //  {  
                if(quoteLine.Id != null &&
                   allQuoteLines.containsKey(quoteLine.Id) && 
                   (allQuoteLines.get(quoteLine.Id).Type_of_Change__c != null || allQuoteLines.get(quoteLine.Id).AssetId__c == null) && 
                   allQuoteLines.get(quoteLine.Id).ByPassFunctionality__c !='Update_Price')
                    quoteLinesList.add(quoteLine);               
                
                // } 
                /*
                else 
                {
                if(quoteLine.Id != null &&
                allQuoteLines.containsKey(quoteLine.Id) && 
                (allQuoteLines.get(quoteLine.Id).Type_of_Change__c != null || allQuoteLines.get(quoteLine.Id).AssetId__c == null))
                quoteLinesList.add(quoteLine);
                }  
                */
            }
            return quoteLinesList;
        }
        else 
            return quoteLines;
    }
    
    /*
    * Vendor: TCS 
    * Developer: Pavankumar Kulkarni
    * Description: SDT-31211- Return an empty list of Quote Lines for quoteTypes Amendment/Exception/Correction
    */
    public static List<Id> filterDeleteQuoteLinesForQuoteType(List<Id> quoteLinesId, String quoteType)
    {
        //List<Id> quoteLinesIdList = new List<Id>();
        if(quoteType == Constant_Util.QUOTE_TYPE_AMEND || quoteType == Constant_Util.QUOTE_TYPE_CORRECTION || quoteType == Constant_Util.QUOTE_TYPE_EXCEPTION)
            return new List<Id>();
        else
            return quoteLinesId;
    }
    
    /*
    Vendor: TCS 
    Developer: Aliasgher
    Description: Change SDT-30495, Update CostMinQuantity and PriceMinQuantity to null when actual value is zero.
    This logic is introduce to ensure user specifies minTon value after reviewing blank value in Acorn.
    */
    public static decimal setZeroASNullforMinTon(decimal minTonValue)
    {
        return minTonValue == 0 ? null : minTonValue;
    }
    
    /*
    Vendor: TCS 
    Developer: Aliasgher
    Description: Change SDT-30895, Change the Acorn - Monthly to SF - Month picklist value.
    */
    public static string setMonthlytoMonthUOM(Map<String,String> UOMMapName, string UOM)
    {
        return UOM == Pricing_Constant_Util.MONTHLY ? Pricing_Constant_Util.COST_UOM_MTH : UOMMapName.get(UOM);
    }
    
    /*@methodName- saveProcuredStatus
    *@description- Changes starts for SDT-20846- Getting SBQQ__UnitCost__c from Haul/Disposal OR Pickup/ExtraPickup and according to the combination process the Product ProcurementErrorMessage__c, BundleProcuredStatus__c to YES/NO.
    --> As per the Product bundle status process the Quote Procurement status.
    *@param- Id : QuoteId
    *@return- Non
    */    
    public static void saveProcuredStatus(ID quoteID)
    {
        Map<Id, List<SBQQ__QuoteLine__c>> quoteLinesWithHeader = new Map<Id, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> quoteLineListToUpdate = new List<SBQQ__QuoteLine__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        String alternateDescription = null;
        String altMessage = null;
        boolean STPResult = false;
        //field added for SDT-29084
        boolean bypassSTP = false;
        //End
        boolean bypassPriceReview = false;
        
        //SDT-31027
        AAV_AvailabilityUtility.getAvailabilityFlagMap();  
        Boolean isAvailable = QuoteProcurementController.hasAssetAvailabilityPermission();
        set<string> availabilityFlagSet = new set<string>();
        //END
        List<SBQQ__QuoteLine__c> qlBundle = getQuoteLineList(quoteID);
        for(SBQQ__QuoteLine__c qlChk : qlBundle)
        {
            
            if((qlChk.Account__r.Parent.IsPricingEligible__c != false && (qlChk.Pricing_Request__c == null || 
                                                                          (qlChk.Pricing_Request__r.IsCaseError__c == false && qlChk.Pricing_Request__r.APIRequestOutput__c == null)) && !(Test.isRunningTest())))
            {
               // system.debug('Return From SaveProcuredStatus');
                return;
            }
        }
        
        Pricing_Threshold_Settings__mdt pricingThreshold = [SELECT Label, DeveloperName, Line_of_Business__c, FieldType__c, Minimum_Value__c, Maximum_Value__c from Pricing_Threshold_Settings__mdt WHERE Label =: Constant_Util.PRICE_PER_HAUL];
        //SDT 31114 added Pricing_Error__c in SOQL        
        Map<Id,SBQQ__QuoteLine__c> allQuoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__ProductCode__c, Pricing_Error__c, ProcurementErrorMessage__c, BundleProcuredStatus__c,
                                                                                      Pricing_API_Method__c, SBQQ__ProductName__c, SBQQ__Quote__c, Occurrence_Type__c,SBQQ__ProductFamily__c,
                                                                                      SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, 
                                                                                      PriceUOM__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, SBQQ__CustomerPrice__c, CostPrice1__c, CostPrice2__c,
                                                                                      ContractNotes__c, SBQQ__Product__r.Is_Pricing_Eligible__c, SBQQ__Product__r.Name, Source_Code__c,
                                                                                      SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName, AAV_Service_Availability__c, //SDT-31027   
                                                                                      AAV_Delivery_Availability__c, AAV_Requested_AdditionalServicesAccessor__c,Availability_Flag__c, //SDT-31027   
                                                                                      AAV_Priority__c, SBQQ__StartDate__c //SDT - 28610
                                                                                      ,Pricing_Request__r.Customer_Price_Type__c //Seema SDT 46922
                                                                                      FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteID]);
        
        for (SBQQ__QuoteLine__c qline : allQuoteLinesMap.values()){
            if(qline.SBQQ__RequiredBy__c == null && !qline.SBQQ__Product__r.Is_Pricing_Eligible__c)
            {
                quoteLinesWithHeader.put(qline.Id, new List<SBQQ__QuoteLine__c> { qline });
            }
            else 
            {
                /* ------ Remove this logic to applied the SDT-24656 logic -------
                if(qline.SBQQ__RequiredBy__c != null && (qline.SBQQ__ProductName__c.equals(Constant_Util.HAUL) || qline.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL) 
                || qline.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP) || qline.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP)
                || qline.SBQQ__ProductName__c.equals(Constant_Util.RECYCLING)))*/
                if(qline.SBQQ__RequiredBy__c != null)
                {
                    if(quoteLinesWithHeader.containsKey(qline.SBQQ__RequiredBy__c)) {
                        List<SBQQ__QuoteLine__c> QuoteLine = quoteLinesWithHeader.get(qline.SBQQ__RequiredBy__c);
                        
                        QuoteLine.add(qline);
                        quoteLinesWithHeader.put(qline.SBQQ__RequiredBy__c, QuoteLine);
                        
                    }else {
                        quoteLinesWithHeader.put(qline.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c> { qline });
                    }
                }
            }            
        }
       // system.debug('quoteLinesWithHeader 11 >>> '+quoteLinesWithHeader);
        for(Id headerId : quoteLinesWithHeader.keySet())
        {
            Decimal unitPriceOne;
            Decimal unitPriceSecond;
            
            //SDT 46922
            Boolean isExhibitPricing = false;
            Decimal exhibitHaulCostMinValue;
            Decimal exhibitHaulCostMaxValue;
            
            Boolean IsExtraPickup = false;
            Boolean IsStepRate = false;
            Boolean IsRecycling = false;
            Boolean IsProductEligibleCase = false;
            Boolean IsCoreServiceAvailable = false;
            String CostIsModeled = '';
            
            for(SBQQ__QuoteLine__c qLine : quoteLinesWithHeader.get(headerId)){
                if(qLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c != null){
                    if(qLine.SBQQ__RequiredBy__c == headerId && qLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == Constant_Util.ROLLOFF){
                        if(qLine.SBQQ__ProductName__c == Constant_Util.HAUL){
                            IsCoreServiceAvailable = true;
                            unitPriceOne = qLine.SBQQ__UnitCost__c;
                            //SDT 46922
                            ExhibitPriceServices eps = new ExhibitPriceServices();
                            isExhibitPricing = eps.getIsExhibitPricing(qLine);
                            exhibitHaulCostMinValue = eps.getExhibitMinThreshould();
                            exhibitHaulCostMaxValue = eps.getExhibitMaxThreshould();
                            //SDT 46922end
                            if(qLine.Pricing_API_Method__c != null){
                                CostIsModeled = qLine.Pricing_API_Method__c;
                            }
                        }
                        if(qLine.SBQQ__ProductName__c == Constant_Util.DISPOSAL){
                            IsCoreServiceAvailable = true;
                            unitPriceSecond = qLine.SBQQ__UnitCost__c;
                            if(qLine.CostPrice1__c != null && qLine.CostPrice2__c != null)
                            {
                                IsStepRate = true;
                            }
                        }
                        if(qLine.SBQQ__ProductName__c == Constant_Util.RECYCLING){
                            IsRecycling = true;
                        }
                    }                
                    else if((qLine.SBQQ__RequiredBy__c == headerId && qLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) || Test.isRunningTest()){
                        if(qLine.SBQQ__ProductName__c == Constant_Util.PICKUP_SERVICE){
                            IsCoreServiceAvailable = true;
                            unitPriceOne = qLine.SBQQ__UnitCost__c;
                            if(qLine.Pricing_API_Method__c != null){
                                CostIsModeled = qLine.Pricing_API_Method__c;
                            }
                        }
                        if(qLine.SBQQ__ProductName__c == Constant_Util.EXTRA_PICKUP){
                            IsCoreServiceAvailable = true;
                            unitPriceSecond = qLine.SBQQ__UnitCost__c;
                            IsExtraPickup = true;
                        }
                    }                    
                }
                else if(qLine.Id == headerId && !qline.SBQQ__Product__r.Is_Pricing_Eligible__c)
                {
                    IsProductEligibleCase = true;
                }                
            }
            if((allQuoteLinesMap.get(headerId) != null) && (allQuoteLinesMap.get(headerId).SBQQ__RequiredBy__c == null)){                
                
                //SDT-31027
                if((isAvailable || allQuoteLinesMap.get(headerId).Availability_Flag__c != null) && 
                   allQuoteLinesMap.get(headerId).SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_NEW_SERVICE_CASE ){
                       
                       Availability_Flag__mdt availability = AAV_AvailabilityUtility.getAvailabilityFlag(allQuoteLinesMap.get(headerId));
                      // system.debug('Availability :: '+availability);
                       if(availability != null){ 
                           availabilityFlagSet.add(availability.Availability_Flag__c);
                           allQuoteLinesMap.get(headerId).Availability_Flag__c = availability.Availability_Flag__c;
                       }
                       
                       if(availability != null && availability.Manual_Procurement__c == 'Yes'){
                           allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = availability.Availability_Flag__c;
                           allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                           quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
                           continue;
                       }
                   }
                //END
                
                //Condition - if cost is modeled.
                if(CostIsModeled.contains(Constant_Util.MODELED)){
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                       // system.debug('CostIsModeled-ROLLOFF-->'+ CostIsModeled);
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_IS_MODELED;
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                        
                        quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
                        continue; }
                    
                    else if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL){
                       // system.debug('CostIsModeled-COMMERCIAL-->'+ CostIsModeled);
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_IS_MODELED;
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                        
                        quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
                        continue; } 
                }
                //SDT-24656 -- Start
                //Condition - if Core Services not available in Quote Bundle
               // system.debug('IsCoreServiceAvailable>>> '+IsCoreServiceAvailable);
                if(!IsCoreServiceAvailable)
                {
                    allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
                    continue;
                }
                //SDT-24656 -- End
                //Condition - if Disposal Cost is Stepped
                if(IsStepRate)
                {
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                       // system.debug('IsSteppedRate-ROLLOFF-->');
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_YES;
                        
                        quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
                        continue; }
                }
                //Condition - if Recycling QL in bundle
                if(IsRecycling)
                {
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                       // system.debug('IsRecycling-ROLLOFF-->');
                        if(unitPriceOne == null)
                        {
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_BLANK;
                            allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                        }
                        else if (unitPriceOne == 0)
                        {
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_ZERO;
                            allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                        }
                        else if (unitPriceOne > 0)
                        {
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;
                            allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_YES;
                        }
                        quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
                        continue; }
                }
                //Condition - if Bundle - Product is not eligible for pricing
                if(IsProductEligibleCase)
                {
                    system.debug('IsProductEligibleCase>>>'+allQuoteLinesMap.get(headerId));
                    allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
                    continue;
                }
                //Condition1
                if(unitPriceOne == null && unitPriceSecond == null ){
                    system.debug('Condition1--->'+ unitPriceOne + unitPriceSecond);
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_BLANK_DISPOSAL_COST_BLANK;
                        //added for 31114
                        setPricingError(allQuoteLinesMap,headerId); 
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(IsExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_BLANK_EXTRA_PICKUP_COST_BLANK;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId); 
                        }
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_BLANK;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                }
                //Condition 2
                if(unitPriceOne == 0 && unitPriceSecond == null ){
                    system.debug('Condition2--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_ZERO_DISPOSAL_COST_BLANK;
                        //added for 31114
                        setPricingError(allQuoteLinesMap,headerId);
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_ZERO_EXTRA_PICKUP_COST_BLANK;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_ZERO;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                }
                //Condition 3
                if(unitPriceOne > 0 && unitPriceOne != null && unitPriceSecond == null ){
                    system.debug('Condition3--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.DISPOSAL_COST_BLANK;
                        //added for 31114
                        setPricingError(allQuoteLinesMap,headerId);
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.EXTRA_PICKUP_COST_BLANK;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                            allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                        }
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;
                            allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_YES;
                        }
                    }
                }
                //Condition 4
                if(unitPriceOne == null && unitPriceSecond == 0 ){
                    system.debug('Condition4--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_BLANK;
                        //added for 31114
                        setPricingError(allQuoteLinesMap,headerId);
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_BLANK_EXTRA_PICKUP_COST_ZERO;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_BLANK;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                }
                //Condition 5
                if(unitPriceOne == 0 && unitPriceSecond == 0 ){
                    system.debug('Condition5--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_ZERO;
                        //added for 31114
                        setPricingError(allQuoteLinesMap,headerId);
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_ZERO_EXTRA_PICKUP_COST_ZERO;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_ZERO;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    } 
                }
                //Condition 6
                if(unitPriceOne > 0 && unitPriceOne != null && unitPriceSecond == 0 ){
                    system.debug('Condition6--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_YES;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.EXTRA_PICKUP_COST_ZERO;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                            allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;}
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;
                            allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_YES;
                        }
                        
                    }
                }
                //Condition 7
                if(unitPriceOne == null && unitPriceSecond > 0 && unitPriceSecond != null ){
                    system.debug('Condition7--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_BLANK;
                        //added for 31114
                        setPricingError(allQuoteLinesMap,headerId);
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_BLANK;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_BLANK;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                }
                //Condition 8
                if(unitPriceOne == 0 && unitPriceSecond > 0 && unitPriceSecond != null ){
                    system.debug('Condition8--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.HAUL_COST_ZERO;
                        //added for 31114
                        setPricingError(allQuoteLinesMap,headerId);
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_ZERO;//added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.PICKUP_COST_ZERO;
                            //added for 31114
                            setPricingError(allQuoteLinesMap,headerId);
                        }
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                    }
                }
                //Condition 9
                if(unitPriceOne > 0 && unitPriceOne != null && unitPriceSecond > 0 && unitPriceSecond !=null ){
                    system.debug('Condition9--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) {
                        
                        allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_YES;
                    }
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL) {
                        if(isExtraPickup){
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;}
                        else{
                            allQuoteLinesMap.get(headerId).ProcurementErrorMessage__c = Constant_Util.QLI_PROCURMENT_SUCCESS;
                        }
                        allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_YES;
                    }
                }
                //Condition 10 : Check Haul Threshold Value, Changes for SDT-26044
                if(unitPriceOne != null && unitPriceOne > 0)
                {
                    system.debug('Condition10--->'+ unitPriceOne + unitPriceSecond + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                    if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF) 
                    {
                        if(allQuoteLinesMap.get(headerId).Source_Code__c != null && allQuoteLinesMap.get(headerId).Source_Code__c.substringBefore(' ') == 'WM')
                        {
                            //SDT 46922 seema
                            if(isExhibitPricing && exhibitHaulCostMinValue != null && exhibitHaulCostMinValue != null && (unitPriceOne < exhibitHaulCostMinValue || unitPriceOne > exhibitHaulCostMaxValue))
                            {
                                allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                            }//SDT 46922 end aded else in next line
                            else if(!isExhibitPricing &&pricingThreshold.Minimum_Value__c != null && (unitPriceOne < pricingThreshold.Minimum_Value__c || unitPriceOne > pricingThreshold.Maximum_Value__c))
                            {
                                allQuoteLinesMap.get(headerId).BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                            }
                        }
                    }
                }
            }
            quoteLineListToUpdate.add(allQuoteLinesMap.get(headerId));
        }
        try 
        {
            update quoteLineListToUpdate;
            List<SBQQ__QuoteLine__c> productBundle = getQuoteLineList(quoteID);
            Map<String,String> equipmentSizeMap = new Map<String,String>();
            List<String> prEquipmentSizeLst = UTIL_Picklist.getPickListValuesIntoList('SBQQ__QuoteLine__c', 'Equipment_Size__c');
            for(String es : prEquipmentSizeLst){
                equipmentSizeMap.put(es.split(',').get(1), es.split(',').get(0));
            }
            
            for(SBQQ__QuoteLine__c bundle_Qline : productBundle)
            {
                STPResult = bundle_Qline.SBQQ__Quote__r.STP__c;
                //Get special handling SDT-29084
                //SDT-38472 no need of bypass flag
                //bypassSTP = bundle_Qline.SBQQ__Quote__r.Special_Handling__c;
                //End
                
                if(bundle_Qline.BundleProcuredStatus__c == Constant_Util.PROCURED_NO)
                {
                    quote.QuoteProcuredStatus__c = Constant_Util.FAILED;
                }
                if(bundle_Qline.BundleProcuredStatus__c == Constant_Util.PROCURED_YES)
                {
                    if(quote.QuoteProcuredStatus__c != Constant_Util.FAILED){
                        quote.QuoteProcuredStatus__c = Constant_Util.SUCCESS;
                    }
                }
                if(bundle_Qline.Is_Substituted_Container__c)
                {
                    quote.Alternate_Service_Provided__c = true;
                    altMessage = bundle_Qline.Name + ' ' + bundle_Qline.Original_Equipment_Size__c + ' '  + bundle_Qline.SBQQ__ProductName__c + ': The requested container size is not available and has been substituted with ' + equipmentSizeMap.get(bundle_Qline.Equipment_Size__c) + '.';
                    alternateDescription = alternateDescription != null ? alternateDescription + '\n' + altMessage : altMessage;
                }
            }
            
            
            //SDT-31027 update availability flag oon quote
            if(availabilityFlagSet != null && availabilityFlagSet.size() > 0){
                if(availabilityFlagSet.toString().containsIgnoreCase('Availability NOT Confirmed')
                   || availabilityFlagSet.toString().containsIgnoreCase('Availability could not be confirmed')) {
                       quote.AAV_Asset_Availability_Flag__c = 'Availability NOT Confirmed';
                   } else if(availabilityFlagSet.toString().containsIgnoreCase('Availability Assumed')) {
                       quote.AAV_Asset_Availability_Flag__c = 'Availability Assumed';
                       
                   } else if(availabilityFlagSet.toString().containsIgnoreCase('Availability Confirmed')){
                       quote.AAV_Asset_Availability_Flag__c = 'Availability Confirmed';
                   }
            }
            //END
            
            //Added for story SDT-26174 by jatan for STP process      
            //Added bypass stp from Special_Handling__c SDT-29084 
            system.debug('quote.QuoteProcuredStatus__c ' + quote.QuoteProcuredStatus__c);
            //SDT-38472 - removed bypassSTP false check while invoking stpruleexecution
            if(quote.QuoteProcuredStatus__c == 'Success' && STPResult == false){ // && bypassPriceReview == true
                system.debug('Inside new STP Logic');
                system.debug(System.Label.STP_Process_on_off_switch);
                if(System.Label.STP_Process_on_off_switch == 'On')
                {
                    //                    boolean result =  STPRuleExecution.executeRules(quoteID, false);
                    boolean result =  STPRuleExecution.executeRules(quoteID, Pricing_Constant_Util.FULL_STP);
                }
                quote.id = quoteID;
                quote.Alternate_Description__c = alternateDescription;
                update quote;
            }
            else
            {
                quote.id = quoteID;
                quote.Alternate_Description__c = alternateDescription;
                update quote;
            }
            
            //quote.id = quoteID;
            //quote.Alternate_Description__c = alternateDescription;
            //update quote;
        } 
        catch (exception e) 
        {
            system.debug(e.getMessage());
        }
    }
    
    /*@methodName- setPricingError
    *@description- Method to set pricing error for header QuoteLine records SDT 31114
    *@param- Id : Map<Id,SBQQ__QuoteLine__c> allQuoteLinesMap and header id
    *@return- void
    */
    private static void setPricingError(Map<Id,SBQQ__QuoteLine__c> allQuoteLinesMap, ID headerId){
        allQuoteLinesMap.get(headerId).Pricing_Error__c = OTHER_PRICING_ERROR; 
    }
    
    /*@methodName- getPricingDetails
    *@description- Method to create the wrapper for pricing output UI from Quote and QuoteLine records
    *@param- Id : QuoteId
    *@return- List of wrapper - QuotePricingWrapper
    */     
    public static List<QuotePricingWrapper> getPricingDetails(ID quoteID)
    {
        PricingReportingFieldsMetadata prFields = new PricingReportingFieldsMetadata();
        list<QuotePricingWrapper> wrapperList = new list<QuotePricingWrapper>();
        Map<String,String> equipmentSizeMap = new Map<String,String>();
        Map<String,String> durationMap = new Map<String,String>();
        Map<String,String> costUOMMap = new Map<String,String>();
        Map<String,String> priceUOMMap = new Map<String,String>();
        Map<Id,SBQQ__QuoteLine__c> quoteHdrMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,List<SBQQ__QuoteLine__c>> quoteLineSrvMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> bundles = getQuoteLineList(quoteID);
        Integer bundlesCount = bundles.size();
        String currencySymbol;
        for(SBQQ__QuoteLine__c qlHdr : bundles){
            quoteHdrMap.put(qlHdr.Id, qlHdr);
        }
        
        List<Pricing_Request__c> priqList = getPricingList(quoteID, bundlesCount);
        
        Set<Id> bundleIDSet = new Set<Id>();
        for(SBQQ__QuoteLine__c qlId : bundles)
        {
            bundleIDSet.add(qlId.Id);
        }
        Set<string> productFamilyList = new Set<string>{'Rolloff','Commercial','Services','Waste Stream','Supplies','Surcharges and Fees'};
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
        // system.debug('quoteLineSrvMap' + quoteLineSrvMap);
        
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
            costUOMMap.put(pcv.split(',').get(1), pcv.split(',').get(0));
        }
        for(String ppv : pckPriceValue){
            priceUOMMap.put(ppv.split(',').get(1), ppv.split(',').get(0));
        }
        
        for(Pricing_Request__c pr : priqList)
        {
            QuotePricingWrapper qpWrapper = new QuotePricingWrapper();
            
            SBQQ__QuoteLine__c ql = quoteHdrMap.get(pr.Quote_Line_Bundle__c);
            String equipmentSizeName = equipmentSizeMap.get(ql.Equipment_Size__c);
            String durationName = durationMap.get(ql.Duration__c);
            
            qpWrapper.QuoteID = quoteID;
            qpWrapper.BundleID = pr.Quote_Line_Bundle__r.Name;
            qpWrapper.BundleLink = pr.Quote_Line_Bundle__c;
            qpWrapper.PricingReqId = pr.Name;
            qpWrapper.PricingRequestLink = pr.Id;
            qpWrapper.LOB = pr.Line_of_Business__c;
            qpWrapper.ProductName = ql.SBQQ__ProductName__c + Constant_Util.BLANKSPACE + equipmentSizeName + Constant_Util.BLANKSPACE + durationName;
            //SDT 31114 
            qpWrapper.ProcurementErrorMessage = ql.ProcurementErrorMessage__c!=null && ql.ProcurementErrorMessage__c!=SUCCESS_STRING && ql.BundleProcuredStatus__c.equalsIgnoreCase('NO') && ql.Pricing_Error__c.equalsIgnoreCase(OTHER_PRICING_ERROR)  ? ql.ProcurementErrorMessage__c : EMPTY_STRING;
            //added qpWrapper.IsVendorMismatchError to wrapper as part of SDT 30956
            getIsVendorMismatchError(ql,qpWrapper);
            if(!pr.IsCaseError__c)
            {
                // system.debug('@@@ PR test'+pr.APIRequestOutput__c);
                prFields = pr.APIRequestOutput__c != null ? PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c) : null;
                if(prFields != null)
                {                
                    if(pr.isAPIResult__c)
                    {
                        //qpWrapper.IsPricingAvailable = true;
                        ProductDetail productDtl = new ProductDetail();
                        
                        //Comment Code for SDT-31291 : Start
                        // if(prFields.Data.overridableEquipmentSizeCode != null){
                        //     productDtl.EquipmentSize = prFields.Data.overridableEquipmentSizeCode;
                        //     productDtl.OriginalEquipmentSize = prFields.Data.equipmentSizeName;
                        //     productDtl.SubstituteMessage = 'The requested container size is not available and has been substituted with '+ prFields.Data.overridableEquipmentSizeName + '.';
                        // }
                        
                        //Changes for SDT-24009 Start done by jatan
                        //Added null check for story SDT-24338
                        if(prFields.Data.isCostOnly != null && prFields.Data.isCostOnly){
                            productDtl.CostOnlyMessage = 'Please Note: This customer is not eligible for automated pricing.  Response is COST ONLY.';
                        }
                        //End                    
                        if(pr.Zone_Type__c == null || 
                           (pr.Zone_Type__c != System.label.WM_Franchise && pr.Zone_Type__c != System.label.Competitor &&
                            pr.Zone_Type__c != System.label.Pre_Determined_Pricing && pr.Zone_Type__c != System.label.Third_Party_Agreement))
                        {
                            List<ServiceCharges> sChargelst = new List<ServiceCharges>();
                            
                            productDtl.StartDate = String.valueof(ql.SBQQ__StartDate__c);
                            productDtl.EndDate = String.valueof(ql.SBQQ__EndDate__c);
                            productDtl.SourceCode = pr.Cost_Source__c;
                            productDtl.VendorCode = ql.Vendor__c != null ? ql.Vendor__c : null;
                            productDtl.VendorType = pr.Source_Code__c;
                            productDtl.Vendor = ql.Vendor__c != null ? ql.Vendor__r.Name : Constant_Util.EMPTY_STRING;
                            //Change for SDT-27722
                            if(prFields.Data.wmMetaData != null)
                            {
                                productDtl.MASUniqueId = prFields.Data.wmMetaData.masCustomerUniqueId;
                                productDtl.TargetTrackingId = prFields.Data.wmMetaData.targetTrackingId;
                            }
                            productDtl.IsPriceChangeRequest = pr.IsPriceChangeRequest__c;
                            productDtl.BaselineId = pr.Service_Baseline_ID__c;
                            productDtl.BusinessUnit = pr.Business_Unit__c;
                            productDtl.FacilityId = pr.Facility_Id__c;
                            productDtl.IsProjectRequest =  pr.Project_Request__c;
                            if(pr.Project_Request__c){
                                productDtl.CustomerPriceType =  pr.Customer_Price_Type__c;
                            } 
                            // Changes for story 23393
                            productDtl.VendorComments = pr.Vendor_Comments__c;
                            
                            //Change for story SDT-25845
                            currencySymbol = prFields.Data.currencyCode != null ? prFields.Data.currencyCode : 'USD'; 
                            
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
                                
                                String costUOMName = costUOMMap.get(sql.Cost_Unit_of_Measure__c);
                                String priceUOMName = priceUOMMap.get(sql.PriceUOM__c);
                                
                                if(sql.SBQQ__ProductName__c.equals(Constant_Util.HAUL) || sql.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL)
                                   || sql.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP) || sql.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP)
                                   || sql.SBQQ__ProductName__c.equals(Constant_Util.RECYCLING))
                                {
                                    if(prFields.Data.rollOff != null)
                                    {
                                        if(sql.SBQQ__ProductName__c.equals(Constant_Util.HAUL)){
                                            System.debug('@@@@@@@@~ In Haul');
                                            ancillaryCharge.Cost = sql.SBQQ__UnitCost__c;
                                            ancillaryCharge.CostValueSymbol = sql.SBQQ__UnitCost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            productDtl.RateTypeHaul = sql.Pricing_API_Method__c;
                                            productDtl.HaulRecordId =  pr.Haul_Record_Id__c;
                                            ancillaryCharge.Price = sql.SBQQ__ListPrice__c;
                                            ancillaryCharge.PriceValueSymbol = sql.SBQQ__ListPrice__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                        }
                                        else if(sql.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL))
                                        { 
                                            System.debug('@@@@@@@@~ In Disposal');
                                            //ancillaryCharge.CostUOMCode = apivalueUOMID;
                                            ancillaryCharge.CostUOM = costUOMName;
                                            productDtl.RateTypeDisposal =  sql.Pricing_API_Method__c;
                                            productDtl.DisposalRecordId =  pr.Disposal_Record_Id__c;
                                            //ancillaryCharge.PriceUOMCode = apivalueUOMID;
                                            ancillaryCharge.PriceUOM = priceUOMName;
                                            
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
                                                ancillaryCharge.Cost =  sql.SBQQ__UnitCost__c;
                                                ancillaryCharge.CostValueSymbol = sql.SBQQ__UnitCost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                                ancillaryCharge.Price = sql.SBQQ__ListPrice__c;
                                                ancillaryCharge.PriceValueSymbol = sql.SBQQ__ListPrice__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            }                         
                                        }
                                        else if(sql.SBQQ__ProductName__c.equals(Constant_Util.RECYCLING))
                                        {
                                            System.debug('@@@@@@@@~ In RECYCLING');
                                            ancillaryCharge.Cost = sql.SBQQ__UnitCost__c;
                                            ancillaryCharge.CostValueSymbol = sql.SBQQ__UnitCost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            ancillaryCharge.Price = sql.SBQQ__ListPrice__c;
                                            ancillaryCharge.PriceValueSymbol = sql.SBQQ__ListPrice__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            ancillaryCharge.CostUOM = costUOMName;
                                            ancillaryCharge.PriceUOM = priceUOMName;
                                        }
                                    }
                                    else if(prFields.Data.commercial != null)
                                    {
                                        if(sql.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP))
                                        {
                                            System.debug('@@@@@@@@~ in Pickup');
                                            ancillaryCharge.Cost = sql.SBQQ__UnitCost__c;
                                            //ancillaryCharge.CostUOMCode = apivalueUOMID;
                                            ancillaryCharge.CostUOM = costUOMName;
                                            ancillaryCharge.CostValueSymbol = sql.SBQQ__UnitCost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            productDtl.RateTypePickup =  sql.Pricing_API_Method__c;
                                            productDtl.PickupRecordId =  pr.Pickup_Record_Id__c;
                                            
                                            //ancillaryCharge.PriceUOMCode = apivalueUOMID;
                                            ancillaryCharge.PriceUOM = priceUOMName;
                                            ancillaryCharge.Price = sql.SBQQ__ListPrice__c;
                                            ancillaryCharge.PriceValueSymbol = sql.SBQQ__ListPrice__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            
                                        }
                                        else if(sql.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP))
                                        {
                                            System.debug('@@@@@@@@~ ExtraPickup');
                                            ancillaryCharge.Cost = sql.SBQQ__UnitCost__c;
                                            ancillaryCharge.CostValueSymbol = sql.SBQQ__UnitCost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            productDtl.ExtraPickupRecordId =  pr.Extra_Pickup_Record_Id__c;
                                            
                                            ancillaryCharge.Price = sql.SBQQ__ListPrice__c;
                                            ancillaryCharge.PriceValueSymbol = sql.SBQQ__ListPrice__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                            
                                        }
                                    }
                                    sChargelst.add(ancillaryCharge);
                                }
                                else
                                {
                                    ancillaryCharge.CostUOM = (sql.SBQQ__SubscriptionPercent__c != null || sql.SBQQ__UnitCost__c != null) ? costUOMName : Constant_Util.EMPTY_STRING;
                                    if(sql.SBQQ__SubscriptionPercent__c != null)
                                    {
                                        ancillaryCharge.Cost = sql.SBQQ__SubscriptionPercent__c;
                                        ancillaryCharge.CostValuePercent = Constant_Util.PERCENTAGE;
                                    }
                                    else
                                    {
                                        ancillaryCharge.Cost = sql.SBQQ__UnitCost__c;
                                        ancillaryCharge.CostValueSymbol = sql.SBQQ__UnitCost__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                    }
                                    
                                    ancillaryCharge.PriceUOM = (sql.SBQQ__MarkupRate__c != null || sql.SBQQ__ListPrice__c != null) ? priceUOMName : Constant_Util.EMPTY_STRING;
                                    if(sql.SBQQ__MarkupRate__c != null)
                                    {
                                        ancillaryCharge.Price = sql.SBQQ__MarkupRate__c;
                                        ancillaryCharge.PriceValuePercent = Constant_Util.PERCENTAGE;
                                    }
                                    else
                                    {
                                        ancillaryCharge.Price = sql.SBQQ__ListPrice__c;
                                        ancillaryCharge.PriceValueSymbol = sql.SBQQ__ListPrice__c != null ? currencySymbol : Constant_Util.EMPTY_STRING;
                                    }
                                    
                                    sChargelst.add(ancillaryCharge);
                                }
                                productDtl.ServiceCharges = sChargelst;
                            }
                            productDtl.ServiceCharges = sChargelst;
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
                            gp.ZoneName = prFields.data.ZoneName;
                            gp.ZoneDescription=prFields.data.zoneDescription;
                            gp.ZoneNote=prFields.data.zoneNotes;
                            
                            productDtl.GreenPages = gp;
                        }
                        qpWrapper.ProductDetails = productDtl;
                    }
                    else
                    {
                        Problem plm = new Problem();
                        plm.ErrorMessage = prFields.Problem != null ? prFields.Problem.errors[0].message : 'reach here';
                        qpWrapper.Problem = plm;
                    }
                }
                else
                {
                    Problem plm = new Problem();
                    plm.ErrorMessage = 'Pricing response still not prepared, Please try again later or refresh the page.';
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
    
    public static Map<Id, Boolean> getQuoteProductDetail(Id quoteId)
    {
        Map<Id, Boolean> bundleStatusMap = new Map<Id, Boolean>();
        Map<Id, List<SBQQ__QuoteLine__c>> quoteLinesWithHeader = new Map<Id, List<SBQQ__QuoteLine__c>>();
        Map<Id,SBQQ__QuoteLine__c> allQuoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,SBQQ__RequiredBy__c, SBQQ__ProductFamily__c, SBQQ__RequiredBy__r.SBQQ__ProductFamily__c, SBQQ__ProductCode__c, SBQQ__ProductName__c,
                                                                                      SBQQ__UnitCost__c, SBQQ__ListPrice__c, CostPrice1__c, CostPrice2__c, Pricing_API_Method__c, SBQQ__Product__r.Is_Pricing_Eligible__c, Source_Code__c,
                                                                                      ServiceBaselineId__c, Pricing_Request__c 
                                                                                      FROM SBQQ__QuoteLine__c 
                                                                                      WHERE SBQQ__Quote__c =: quoteId]);
        
        for (SBQQ__QuoteLine__c qline : allQuoteLinesMap.values()){
            if(qline.SBQQ__RequiredBy__c == null && !qline.SBQQ__Product__r.Is_Pricing_Eligible__c)
            {
                quoteLinesWithHeader.put(qline.Id, new List<SBQQ__QuoteLine__c> { qline });
            }
            else if(qline.SBQQ__RequiredBy__c != null && (qline.SBQQ__ProductName__c != null && (qline.SBQQ__ProductName__c.equals(Constant_Util.HAUL) || qline.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL) 
                                                                                                 || qline.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP) || qline.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP)
                                                                                                 || qline.SBQQ__ProductName__c.equals(Constant_Util.RECYCLING))))
            {
                if(quoteLinesWithHeader.containsKey(qline.SBQQ__RequiredBy__c)) {
                    List<SBQQ__QuoteLine__c> QuoteLine = quoteLinesWithHeader.get(qline.SBQQ__RequiredBy__c);
                    
                    QuoteLine.add(qline);
                    quoteLinesWithHeader.put(qline.SBQQ__RequiredBy__c, QuoteLine);
                    
                }else {
                    quoteLinesWithHeader.put(qline.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c> { qline });
                }
            }            
        }
        
        for(Id headerId : quoteLinesWithHeader.keySet())
        {
            Decimal unitCostOne;
            Decimal unitCostSecond;
            String CostIsModeled = '';
            Boolean IsExtraPickup = false;
            Boolean IsRecycling = false;
            Boolean IsStepRate = false;
            Boolean IsProductEligibleCase = false;
            Boolean IsPriceChangePRError = false;
            
            for(SBQQ__QuoteLine__c qLine : quoteLinesWithHeader.get(headerId))
            {
                if(qLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c != null)
                {
                    if(qLine.SBQQ__RequiredBy__c == headerId && qLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == Constant_Util.ROLLOFF)
                    {
                        if(qLine.SBQQ__ProductName__c == Constant_Util.HAUL)
                        {
                            unitCostOne = qLine.SBQQ__UnitCost__c;
                            if(qLine.Pricing_API_Method__c != null){
                                CostIsModeled = qLine.Pricing_API_Method__c;
                            }
                        }
                        else if(qLine.SBQQ__ProductName__c == Constant_Util.DISPOSAL)
                        {
                            unitCostSecond = qLine.SBQQ__UnitCost__c;
                            if(qLine.CostPrice1__c != null && qLine.CostPrice2__c != null)
                            {
                                IsStepRate = true;
                            }
                        }
                        if(qLine.SBQQ__ProductName__c == Constant_Util.RECYCLING){
                            IsRecycling = true;
                        }
                    }
                    else if(qLine.SBQQ__RequiredBy__c == headerId && qLine.SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL)
                    {
                        if(qLine.SBQQ__ProductName__c == Constant_Util.PICKUP_SERVICE)
                        {
                            unitCostOne = qLine.SBQQ__UnitCost__c;
                            if(qLine.Pricing_API_Method__c != null){
                                CostIsModeled = qLine.Pricing_API_Method__c;
                            }
                        }
                        else if(qLine.SBQQ__ProductName__c == Constant_Util.EXTRA_PICKUP)
                        {
                            unitCostSecond = qLine.SBQQ__UnitCost__c;
                            IsExtraPickup = true;
                        }
                        
                        if(qLine.ServiceBaselineId__c != null && qLine.Pricing_Request__c == null)
                        {
                            IsPriceChangePRError = true;
                        }
                    }
                    else if(qLine.Id == headerId && !qline.SBQQ__Product__r.Is_Pricing_Eligible__c)
                    {
                        IsProductEligibleCase = true;
                    }
                }
            }
            if((allQuoteLinesMap.get(headerId) != null) && (allQuoteLinesMap.get(headerId).SBQQ__RequiredBy__c == null))
            {
                system.debug('Product family in If ' + allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c);
                
                if(CostIsModeled.contains(Constant_Util.MODELED))
                {
                    bundleStatusMap.put(headerId, false);
                    break;
                }
                if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.ROLLOFF)
                {
                    if(IsStepRate || (unitCostOne > 0 && unitCostSecond >= 0))
                    {
                        bundleStatusMap.put(headerId, true);
                    }
                    else if(IsProductEligibleCase)
                    {
                        bundleStatusMap.put(headerId, true);
                    }
                    else if(IsRecycling)
                    {
                        if(unitCostOne > 0)
                        {
                            bundleStatusMap.put(headerId, true);
                        }
                        else
                        {
                            bundleStatusMap.put(headerId, false);
                        }
                    }
                    else
                    {
                        bundleStatusMap.put(headerId, false);
                    }
                }
                else if(allQuoteLinesMap.get(headerId).SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL)
                {
                    if(IsProductEligibleCase)
                    {
                        bundleStatusMap.put(headerId, true);
                    }
                    else if(IsPriceChangePRError)
                    {
                        bundleStatusMap.put(headerId, false);
                    }
                    else if(IsExtraPickup)
                    {
                        if(unitCostOne > 0 && unitCostSecond > 0)
                        {
                            bundleStatusMap.put(headerId, true);
                        }
                        else
                        {
                            bundleStatusMap.put(headerId, false);
                        }
                    }
                    else
                    {
                        if(unitCostOne > 0)
                        {
                            bundleStatusMap.put(headerId, true);
                        }
                        else
                        {
                            bundleStatusMap.put(headerId, false);
                        }
                    }                
                }    
            }
        }
        
        return bundleStatusMap;
    }
}
