/*
  * @Name          PriceOnlyRequestSTPProcess
  * @Vendor		    TCS
  * @Author        WM - Jatan Sharma / Ali Kotawala / Digdershika Ojha
  * @Date          07/05/2023
  * @Description   This class is created to Straight-Through Processing (STP) function of Price Only Request record.
  */

public class PriceOnlyRequestSTPProcess {

    //Used in method validatePriceOnlyCall to query beased on product code.
    public static set<string> productCodes = new Set<string>{Pricing_Constant_Util.DSP,Pricing_Constant_Util.HAUL_PRODUCT,Pricing_Constant_Util.PICKUP_PRODUCT};
	public static Map<Id, priceDetailReqSTPWrapper> mapOfPrReqIdAndReqWrapper = new Map<Id, priceDetailReqSTPWrapper>();
    
    /*@methodName- getProductdetails
    *@description- Method to query the CPQ Product Record 
    *@param- Id : Non
    *@return- List of Product2
    */
    public static List<Product2> getProductdetails(){

        Set<string> productCodeList = new Set<string>{'CSC','DLV','RECV','DEM','REM','SWO','PSW','COF','REL','DRUN','CAS','PUSH','EQI','GTF', 'REC'};
        List<Product2> prodDetails =  [SELECT Id, ProductCode, Name, SBQQ__PricingMethod__c FROM Product2 WHERE (Family = :Pricing_Constant_Util.SURCHARGE_FEE OR ProductCode IN:productCodeList) AND IsActive = TRUE];

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

    /*
     * @methodName : priceDetailReqSTPWrapper , serviceChargesReqSTPWrapper
     * @description: Wrapper classes for creating API request.
    */   
    public with sharing class priceDetailReqSTPWrapper{
		public String requestNumber {get;set;}
        public String lineOfBusiness {get;set;}
        public String supplierCode {get;set;}
        public String equipmentCode {get;set;}
        public String equipmentSizeCode {get;set;}
        //equipmentUOM added for SDT-38484
        public String equipmentUOM {get;set;}
        public String materialTypeCode {get;set;}
        public String equipmentAvailabilityTypeCode {get;set;}
        public String marketTypeCode {get;set;}
        public Decimal pickupCost {get;set;}
        public Decimal extraPickupCost {get;set;}
        public Decimal haulCost {get;set;}
        public Decimal disposalCost {get;set;}
        //public String sourceSystem {get;set;}
        public Boolean isProject {get;set;}
        public String projectCategory {get;set;}
        public Boolean IsPricingEligible {get;set;}
        public List<serviceChargesReqSTPWrapper> serviceCharges {get;set;}
	}
    public with sharing class serviceChargesReqSTPWrapper{
		public String code {get;set;}
        public Decimal cost {get;set;}
        public String costValueType {get;set;}
	}

    /*
     * @methodName : callPriceOnlySTPFunctionality
     * @description: This will be called to process step by step functionality.
     * @param	   : quoteId of string type
     * @return     : void
     */ 
    public static void callPriceOnlySTPFunctionality(String quoteId){
        Set<Id> bundleIdSet = validatePriceOnlyCall(quoteId);
        if(bundleIdSet!=null && bundleIdSet.size()>0){
            try{
			createPricingRequestForMultiBundle(bundleIdSet, false);
            }catch(Exception ex){
            STPExceptionUtil.setStepByStepExceptionObj('callPriceOnlySTPFunctionality', 'createPricingRequestForMultiBundle - ' + quoteId,ex.getMessage());
        }
        }
    }

    /*@methodName- validatePriceOnlyCall
    *@description- Method to validate bundle is eligible for price only call
    *@param-: Quote Id
    *@return- Set of bundle ID
    */
    public static set<ID> validatePriceOnlyCall(string quoteId)
    {
        set<ID> bundleSetId = new set<Id>();
        List<SBQQ__QuoteLine__c> qlList = QuoteLineSelector.getQLByPrdCodesAndQuote(quoteId);  
        List<SBQQ__QuoteLine__c> quoteLinetoUpdate = new list<SBQQ__QuoteLine__c>();
        Map<ID,List<SBQQ__QuoteLine__c>> parentChildMap = New Map<ID,List<SBQQ__QuoteLine__c>>();
        Map<ID, string> bundleScodeValue = new Map <ID, string>();
        //SDT-32865
        //SDT-38472 - commenting as no longer needed
        //Boolean specialHandling ;
            List<serviceChargesCodeMapping__mdt> prodCodeListForScode = [select Product_code__c from serviceChargesCodeMapping__mdt];
        for(serviceChargesCodeMapping__mdt prdCodeForScode : prodCodeListForScode){
            productCodes.add(prdCodeForScode.Product_code__c);
        }
        
            if(qlList != null && qlList.size() > 0)
            {
                for(SBQQ__QuoteLine__c ql : qlList)
                {
                    if(ql.SBQQ__Product__r.Family != 'Waste Category' && ql.SBQQ__Product__r.Family != 'Waste Stream')
                    {
                        if(ql.SBQQ__RequiredBy__c == null )
                        {
                            bundleScodeValue.put(ql.id , ql.sCode__c);
                            //SDT-32865
                            //SDT-38472 - commenting as no longer needed
                            //specialHandling = ql.SBQQ__Quote__r.Special_Handling__c;
                        }
                        else
                        {
                            if(!parentChildMap.containsKey(ql.SBQQ__RequiredBy__c)){
                                parentChildMap.put(ql.SBQQ__RequiredBy__c, new List<SBQQ__QuoteLine__c>{ql});
                            }
                            else{
                                parentChildMap.get(ql.SBQQ__RequiredBy__c).add(ql);
                            }
                        }
                    }
                }
                for(Id key : parentChildMap.keyset())
                {
                    string sCode = bundleScodeValue.get(key);
                    
                    for(SBQQ__QuoteLine__c ql : parentChildMap.get(key))
                    {
                    
                        if(sCode == null )
                        {
                            //Commenting below code for SDT-32830
                            // if(productCodes.contains(ql.SBQQ__ProductCode__c) 
                            // && !ql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP)
                            // && (ql.SBQQ__ListPrice__c == null || ql.SBQQ__ListPrice__c == 0)
                            // && ql.SBQQ__UnitCost__c != null)
                            // {
                            //     bundleSetId.add(ql.SBQQ__RequiredBy__c);
                            //     continue;
                            // }
                            // if (productCodes.contains(ql.SBQQ__ProductCode__c) 
                            //     && ql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP) 
                            //     && ql.Cost_Unit_of_Measure__c == Pricing_Constant_Util.COST_UOM_MTH 
                            //     && (ql.SBQQ__ListPrice__c == null || ql.SBQQ__ListPrice__c == 0)
                            //     && ql.SBQQ__UnitCost__c != null)
                            // {
                            //     bundleSetId.add(ql.SBQQ__RequiredBy__c);
                            //     continue;
                            // }
                            // New changes for SDT-32830
                            if(productCodes.contains(ql.SBQQ__ProductCode__c)){
                                bundleSetId.add(ql.SBQQ__RequiredBy__c);
                                continue;
                            }

                        }
                        //If QuoteLine Scode did not match we will copy cost to price.
                        else
                        {
                            SBQQ__QuoteLine__c qline = new SBQQ__QuoteLine__c();
                            qline.id = ql.id;
                            
                            qline.SBQQ__ListPrice__c = ql.SBQQ__UnitCost__c;
                            
                            quoteLinetoUpdate.add(qline);
                        }
                    }
                    
                }
                if(quoteLinetoUpdate !=null && quoteLinetoUpdate.size()>0){
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = true;
                    update quoteLinetoUpdate;
                    RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = false;
		    //SDT-32670
                    /*if(bundleSetId ==null || bundleSetId.size()==0){
                    	STPRuleExecution.executeRules(quoteId, true);    
                    }*/
                }
                //SDT-38472 - removed check of specialHandling
                if((bundleSetId ==null || bundleSetId.size()==0) && ( System.Label.Step_By_Step_Switch == 'On')){
                    
                    	//STPRuleExecution.executeRules(quoteId, true);    
                    	STPRuleExecution.executeRules(quoteId, Pricing_Constant_Util.PARTIAL_STP);    
                    }
            }
    	
        return bundleSetId;
    }

    /*@methodName- createPricingRequestForMultiBundle
    *@description- Create pricing request based on bundle list.
    *@param-: List of bundle Id (Parent QuoteLine Id)
	*@param callingFromUI, a boolean to handle price only call from user interface get price button
    *@return- void
    */
    public static void createPricingRequestForMultiBundle(set<Id> bundleIds, boolean callingFromUI) {

        boolean isError = false; 
        String No_Mapping = System.label.No_Mapping;   
        Id pricingId;
        List<Pricing_Request__c> pricingRequestList = new List<Pricing_Request__c>();
        List<SBQQ__QuoteLine__c> quoteLines =  new List<SBQQ__QuoteLine__c>();
        Id accountId;
        String NAICSCode;
        ID QuoteID;
		String appName = '';
        Map<Id,String> materialMap  = new Map<Id,String>();

        quoteLines = QuoteLineSelector.getQLByBdlAndPricing(bundleIds);
        //Loop to fetch material and put in the material map.
        for(SBQQ__QuoteLine__c ql : quoteLines){
            appName = UTIL_ErrorConstants.STEP_STP_APPLICATION_NAME + ql.SBQQ__Quote__r.Name;
            
            if(ql.SBQQ__Product__r.Family == Pricing_Constant_Util.WASTE_STREAM){
                QuoteID = ql.SBQQ__Quote__r.id;
                materialMap.put(ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c , ql.SBQQ__Product__r.ProductCode);
            }
        } 

        List<String> prContainerTypeLst = UTIL_Picklist.getPickListValuesIntoList(Pricing_Constant_Util.PRICING_REQUEST_C, Pricing_Constant_Util.CONTAINER_TYPE_C);
        Map<String,List<String>> prDependentContainerSizeLst = UTIL_Picklist.getPicklistDependentValues(Pricing_Constant_Util.PRICING_REQUEST_C,Pricing_Constant_Util.CONTAINER_SIZE_C);
        Map<String,List<String>> prDependentMaterialLst = UTIL_Picklist.getPicklistDependentValues(Pricing_Constant_Util.PRICING_REQUEST_C, Pricing_Constant_Util.MATERIAL_CODE_C);
        String productName;
        String locationCode;
        String quoteIdOfBundle;
        String quoteNameOfBundle;
        //SDT-32865
        Boolean specialHandling;
        
        for(SBQQ__QuoteLine__c quoteLine : quoteLines)
        {
            if(quoteLine.SBQQ__RequiredBy__c ==  null)
            {
                Pricing_Request__c prParam = new Pricing_Request__c();

                accountId = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.ParentId;
                NAICSCode = PricingRequest.getNAICSCode(accountId);

                isError =false;
                String errorMessage = '';
                errorMessage ='Invalid mapping value for pricing: ';
                productName = '';
                
                prParam.Vendor_Code__c = prParam.Vendor_Code__c == null ? quoteLine.Vendor__r.Vendor_ID__c : prParam.Vendor_Code__c;
                prParam.Account__c = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.ParentId;
                prParam.Location__c = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Id;
                prParam.Service_Street_Address__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingStreet__c;
                prParam.Service_City__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingCity__c;
                prParam.Service_State__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingState__c;
                prParam.Service_Country__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingCountry__c;
                prParam.Service_Postal_Code__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingPostalCode__c;
                prParam.Case_Number__c = String.valueOf(quoteLine.SBQQ__Quote__r.Case_Number__c);
                prParam.Case__c = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c;
                prParam.Pricing_Type__c = Pricing_Constant_Util.PRICING_TYPE_AMPO;

                //Seasonal is not considered for pricing call.
                if(quoteLine.Duration__c == Pricing_Constant_Util.SERVICE_TYPE_SEAS)
                    {
                        prParam.Service_Type__c= Pricing_Constant_Util.TEMP;
                        isError = true;
                        errorMessage += ', Can not create Pricing Request for Seasonal duration type.';
                    }
                else
                    {
                        prParam.Service_Type__c = quoteLine.Duration__c;
                    }

                if (quoteLine.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.PRODUCT_CODE_OT)
                    {
                        prParam.Line_of_Business__c = Pricing_Constant_Util.ROLLOFF;
                    }
                //TCS-pkulkarn-SDT-32077-Commented following code
                /*else if(quoteLine.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.PRODUCT_CODE_CMP)
                    {
                        if(quoteLine.Equipment_Size__c != null && quoteLine.Equipment_Size__c.contains(Pricing_Constant_Util.DASH))   
                        {
                            integer eqSize = Integer.valueOf(quoteLine.Equipment_Size__c.substringAfter(Pricing_Constant_Util.DASH));
                            if(eqSize >= 10)
                            {
                                prParam.Container_Type__c = Pricing_Constant_Util.PRODUCT_CODE_CMP;
                                prParam.Line_of_Business__c = Pricing_Constant_Util.ROLLOFF;
                            }
                            else
                            {
                                prParam.Container_Type__c = Pricing_Constant_Util.PRODUCT_CODE_VTC;
                                prParam.Line_of_Business__c = Pricing_Constant_Util.COMMERCIAL;
                            }
                        }
                    }
                //Need to check.
                */
                //TCS-pkulkarn-SDT-32077-End
                //TCS-pkulkarn-SDT-32077-Added else if condition
                else if(quoteLine.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.PRODUCT_CODE_CMP || quoteLine.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.PRODUCT_CODE_VTC)
                {
                	prParam.Container_Type__c = quoteLine.SBQQ__Product__r.ProductCode;
                    prParam.Line_of_Business__c = quoteLine.SBQQ__Product__r.Family;
                }
                //TCS-pkulkarn-SDT-32077-End
                else
                    {
                        prParam.Line_of_Business__c = Pricing_Constant_Util.COMMERCIAL;
                    } 

                //Fetcing cost from quotelines and assigning to PR.
                for(SBQQ__QuoteLine__c QL : quoteLines)
                {
                    if(quoteLine.id == QL.SBQQ__RequiredBy__c)
                    {
                        system.debug('Vendor Info '+ QL.Vendor__r.Vendor_ID__c);
                        if(prParam.Line_of_Business__c == Pricing_Constant_Util.COMMERCIAL)
                        {
                            if(QL.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_EXTRA_PICKUP)){
                                prParam.Extra_Pickup_Cost__c = QL.SBQQ__UnitCost__c;
                            }
                            else if(QL.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP)){
                                prParam.Pickup_Cost__c = QL.SBQQ__UnitCost__c;
                            }
                        }
                        else if(prParam.Line_of_Business__c == Pricing_Constant_Util.ROLLOFF)
                        {
                            if(QL.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL)){
                                prParam.Disposal_Cost__c = QL.SBQQ__UnitCost__c;
                            }
                            else if(QL.SBQQ__ProductName__c.equals(Pricing_Constant_Util.HAUL)){
                                prParam.Haul_Cost__c = QL.SBQQ__UnitCost__c;
                            }
                        }
                  }
                }

                if(quoteLine.SBQQ__Product__r.ProductCode != null){
                    if(prParam.Container_Type__c == null){
                        for(Integer i=0; i< prContainerTypeLst.size(); i++){
                            if(prContainerTypeLst[i].split(Pricing_Constant_Util.COMMA).get(1) == quoteLine.SBQQ__Product__r.ProductCode){
                                prParam.Container_Type__c = quoteLine.SBQQ__Product__r.ProductCode;
                                break;
                            }
                        }
                        productName = quoteLine.SBQQ__Product__r.Name;
                    }    
                    else
                    {
                        productName = prParam.Container_Type__c == Pricing_Constant_Util.PRODUCT_CODE_CMP ? Pricing_Constant_Util.COMPACTOR : Pricing_Constant_Util.VERTICAL_COMPACTOR;
                    }
                    
                    //TCS-pkulkarn-SDT-32077-Added following line
					productName = Compactor_Utility.retrieveCompactorVerticalEquivalentProduct(quoteLine);
                    
                    if(prParam.Container_Type__c != null && prDependentContainerSizeLst.containsKey(productName))
                    {
                        List<String> prContainerSizeLst = prDependentContainerSizeLst.get(productName);
                        for(Integer j=0; j < prContainerSizeLst.size(); j++){                            
                            if(prContainerSizeLst[j].split(Pricing_Constant_Util.COMMA).get(1) == quoteLine.Equipment_Size__c){
                                prParam.Container_Size__c = quoteLine.Equipment_Size__c;
                                break;
                            }
                        }
                    }
                    //Validation PR Data.
                    If(prParam.Container_Type__c == null){
                        prParam.Container_Type__c =No_Mapping;
                        isError = true;
                        errorMessage += ', Container Type: '+ quoteLine.SBQQ__Product__r.ProductCode;
                    }
                    If(prParam.Container_Size__c == null){
                        prParam.Container_Size__c = No_Mapping;
                        isError = true;
                        errorMessage += ', Container Size: '+ quoteLine.Equipment_Size__c;
                    }
                }
                
                if(prParam.Line_of_Business__c == Pricing_Constant_Util.COMMERCIAL)
                {
                    if(quoteLine.Pricing_Frequency_Type__c != null)
                    {
                        prParam.Frequency_Type__c = quoteLine.Pricing_Frequency_Type__c;
                    }
                    
                    if(quoteLine.Pricing_Frequency_Count__c != null)
                    {
                        prParam.Frequency_Count__c = String.valueOf(quoteLine.Pricing_Frequency_Count__c);
                    }
                    //Validation PR Data.
                    If(prParam.Frequency_Type__c ==null){
                        prParam.Frequency_Type__c =No_Mapping;
                        isError = true;
                        errorMessage += 'Frequency Type is required';
                    }
                    If(prParam.Frequency_Count__c == null){
                        prParam.Frequency_Count__c = No_Mapping;
                        isError = true;
                        errorMessage += 'Frequency Count is required';
                    }
                    
                }

                if(prDependentMaterialLst.containsKey(prParam.Line_of_Business__c))
                {
                    List<String> prMaterialLst = prDependentMaterialLst.get(prParam.Line_of_Business__c);
                    for(Integer m=0; m < prMaterialLst.size(); m++){
                        if((prMaterialLst[m].split(',').get(1)).contains(materialMap.get(quoteLine.id))){
                            prParam.Material_Code__c = materialMap.get(quoteLine.id);
                            break;
                        }
                    }
                }
                //Validation PR Data.
                If(prParam.Material_Code__c == null){
                    prParam.Material_Code__c =No_Mapping;
                    isError = true;
                    errorMessage += ', Material Code ';
                }

                if(quoteLine.Occurrence_Type__c != null){
                    prParam.Schedule_or_On_Call__c = quoteLine.Occurrence_Type__c == Pricing_Constant_Util.OCCURENCE_TYPE_OC || quoteLine.Occurrence_Type__c == Pricing_Constant_Util.OCCURENCE_TYPE_SOC ? Pricing_Constant_Util.ON_CALL : Pricing_Constant_Util.SCHEDULED;
                }
                //Validation PR Data.
                If(prParam.Schedule_or_On_Call__c == null){
                    prParam.Schedule_or_On_Call__c =No_Mapping;
                    isError = true;
                    errorMessage += ', Occurrence Type: '+ quoteLine.Occurrence_Type__c +', Should be Schedule or On-Call';
                }
                //prParam.Schedule_or_On_Call__c = Pricing_Constant_Util.ON_CALL;//'On-Call';
                if(quoteLine.SBQQ__Product__r.ProductCode != null && quoteLine.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.PRODUCT_CODE_TOT 
                && quoteLine.SBQQ__Quantity__c != null && quoteLine.SBQQ__Quantity__c > 5)
                {
                    prParam.Quantity__c = quoteLine.SBQQ__Quantity__c;
                    isError = true;
                    errorMessage += ', Cannot use automated pricing for Qty > 5. Must be priced manually.';
                }
                else
                {
                    prParam.Quantity__c = quoteLine.SBQQ__Quantity__c;
                }
                prParam.Hauls_Month__c = Pricing_Constant_Util.ONE_NUMBER;
                prParam.Industry_Classification__c = NAICSCode;
                prParam.Quote_Line_Bundle__c = quoteLine.Id;
                prParam.Quote__c = quoteLine.SBQQ__Quote__c;
                prParam.Quote_Line__c = quoteLine.Name;
                prParam.Customer_Owned__c = quoteLine.Ownership__c != null ? quoteLine.Ownership__c == Pricing_Constant_Util.OWNERSHIP_CLT ? true : false : false;
                
                prParam.Project_Request__c = quoteLine.SBQQ__Quote__r.Project_Services_Request__c;
                if(quoteLine.SBQQ__Quote__r.Project_Services_Request__c == true)
                {
                    prParam.Project_Code__c = quoteLine.SBQQ__Quote__r.Project__c;
                }
                If(isError){
                    prParam.IsCaseError__c = true;
                    prParam.Case_Error_Message__c = errorMessage;
                }
                locationCode = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Location_Code__c;
                quoteIdOfBundle = quoteLine.SBQQ__Quote__r.id;
                quoteNameOfBundle = quoteLine.SBQQ__Quote__r.Name;
                specialHandling = quoteLine.SBQQ__Quote__r.Special_Handling__c;
                pricingRequestList.add(prParam);
            }
        }

        if(pricingRequestList!=null && pricingRequestList.size()>0){
            Database.SaveResult[] SR = database.insert(pricingRequestList,false);
            if(SR[0].isSuccess())
            	{
                    for(Pricing_Request__c pr : pricingRequestList){
                        buildAPIRequestWrapper(quoteLines, pr);//will make global map
                    }
                    List<priceDetailReqSTPWrapper> wrapperList = mapOfPrReqIdAndReqWrapper.values();
                    //Since future method does not support sObject thus need to pass serialized value
                    String wrapperString = JSON.serialize(wrapperList);
                    system.debug('Inside pricing creation');
                    priceOnlyAPICall(locationCode,wrapperString, quoteIdOfBundle, quoteNameOfBundle, callingFromUI, specialHandling);
                }else{
                	for(Database.Error err : SR[0].getErrors()) {
                        STPExceptionUtil.setStepByStepExceptionObj('createPricingRequestForMultiBundle', appName,err.getMessage());
                    }
        	}
        }
    }

    /*
     * @methodName buildAPIRequestWrapper
     * @description Build API request wrapper that will be saved in global map mapOfPrReqIdAndReqWrapper
     * @param-: List of quoteline and pricing Request
     * @return- void
    */
    public static void buildAPIRequestWrapper(List<SBQQ__QuoteLine__c> quoteLines, Pricing_Request__c pricingRequest){
        priceDetailReqSTPWrapper reqWrapper = null;
        List<SBQQ__QuoteLine__c> prQuoteLineList = new List<SBQQ__QuoteLine__c>();
        List<serviceChargesReqSTPWrapper> serviceCharges = new list <serviceChargesReqSTPWrapper>();
        set<string> coreLineProductCode =  new set<string>{'H','DSP','PCK','REC'}; // Need to check for more core lines.
        String appName = '';
        try{
            if(pricingRequest != null){

                reqWrapper = new priceDetailReqSTPWrapper();
                reqWrapper.requestNumber = String.valueOf(pricingRequest.Id);
                reqWrapper.lineOfBusiness = pricingRequest.Line_of_Business__c == Pricing_Constant_Util.COMMERCIAL ? pricingRequest.Line_of_Business__c : Pricing_Constant_Util.ROLL_OFF;
                reqWrapper.supplierCode = pricingRequest.Vendor_Code__c;
                reqWrapper.equipmentCode = pricingRequest.Container_Type__c;
                reqWrapper.equipmentSizeCode = pricingRequest.Container_Size__c;
                reqWrapper.materialTypeCode = pricingRequest.Material_Code__c.replace('%26',Pricing_Constant_Util.AMPERSAND);
                reqWrapper.equipmentAvailabilityTypeCode = pricingRequest.Service_Type__c == Pricing_Constant_Util.SERVICE_TYPE_SEAS ? Pricing_Constant_Util.SERVICE_TYPE_TEMP : pricingRequest.Service_Type__c;
                if(!String.isNotBlank(pricingRequest.Zone_Type__c) || pricingRequest.Zone_Type__c == Pricing_Constant_Util.OPEN_MARKET){
                    reqWrapper.marketTypeCode = Pricing_Constant_Util.OPEN;
                }else{
                    reqWrapper.marketTypeCode = Pricing_Constant_Util.CLOSE;
                }
                if(pricingRequest.Line_of_Business__c.equalsIgnoreCase(Pricing_Constant_Util.ROLLOFF) ){
                    reqWrapper.haulCost = pricingRequest.Haul_Cost__c;
                    reqWrapper.disposalCost = pricingRequest.Disposal_Cost__c;
                }else{
                    reqWrapper.pickupCost = pricingRequest.Pickup_Cost__c;
                    reqWrapper.extraPickupCost = pricingRequest.Extra_Pickup_Cost__c;
                }
                //Fetch QuoteLines specific to Pricing request, will run only once
                for(SBQQ__QuoteLine__c qlObj : quoteLines){
                    appName =  UTIL_ErrorConstants.STEP_STP_APPLICATION_NAME + qlObj.SBQQ__Quote__r.Name + Pricing_Constant_Util.QUOTE_ID + qlObj.SBQQ__Quote__r.id;
                    if(pricingRequest.Quote_Line_Bundle__c == qlObj.Id && qlObj.SBQQ__RequiredBy__c == null){
                        reqWrapper.isProject = pricingRequest.Project_Request__c;
                        
                        if(qlObj.SBQQ__Quote__r.Project_Services_Request__c == true)
                        {
                            reqWrapper.projectCategory = qlObj.SBQQ__Quote__r.Project__r.Name;
                        }
                        reqWrapper.IsPricingEligible = qlObj.Account__r.Parent.IsPricingEligible__c;
                    }
                    else if(pricingRequest.Quote_Line_Bundle__c == qlObj.SBQQ__RequiredBy__c && !coreLineProductCode.contains(qlObj.SBQQ__ProductCode__c) && qlObj.SBQQ__Product__r.Family != 'Waste Category' && qlObj.SBQQ__Product__r.Family != 'Waste Stream'){
                        serviceChargesReqSTPWrapper serviceCharge = new serviceChargesReqSTPWrapper();
                        
                        serviceCharge.code = generateCodeForServiceChanrge(qlObj.SBQQ__ProductCode__c,pricingRequest.Line_of_Business__c , pricingRequest.Service_Type__c, reqWrapper.marketTypeCode );
                        if(qlObj.SBQQ__SubscriptionPercent__c!=null){ 
                            //SDT-32793 - divide by 100
                            serviceCharge.cost = qlObj.SBQQ__SubscriptionPercent__c/100;
                            serviceCharge.costValueType = Pricing_Constant_Util.PERCENT;
                        }else{
                            serviceCharge.cost = qlObj.SBQQ__UnitCost__c;
                        	serviceCharge.costValueType = Pricing_Constant_Util.AMOUNT;
                        }
                        
                        serviceCharges.add(serviceCharge); 
                    }
                    // added equipmentUOM for SDT-38484, additional condition added Toshender for PR and bundle
                     if(pricingRequest.Line_of_Business__c.equalsIgnoreCase(Pricing_Constant_Util.ROLLOFF) && qlObj.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL) && pricingRequest.Quote_line_Bundle__c != null 
                        && qlObj.SBQQ__RequiredBy__c !=null && pricingRequest.Quote_line_Bundle__c.equals(qlObj.SBQQ__RequiredBy__c))
                        {
                            reqWrapper.equipmentUOM =qlObj.Cost_Unit_of_Measure__c;
                        }
                        else if(pricingRequest.Line_of_Business__c.equalsIgnoreCase(Pricing_Constant_Util.COMMERCIAL) && qlObj.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP) && pricingRequest.Quote_line_Bundle__c != null 
                        && qlObj.SBQQ__RequiredBy__c !=null && pricingRequest.Quote_line_Bundle__c.equals(qlObj.SBQQ__RequiredBy__c ) )
                        {
                            reqWrapper.equipmentUOM =qlObj.Cost_Unit_of_Measure__c;
                        }
                } 
                if(serviceCharges!=null && serviceCharges.size() > 0 )
                {
                    reqWrapper.serviceCharges = serviceCharges;  

                }
                mapOfPrReqIdAndReqWrapper.put(pricingRequest.Id, reqWrapper);
            }
            
        }catch(Exception ex){
            STPExceptionUtil.setStepByStepExceptionObj('buildAPIRequestWrapper', appName,ex.getMessage());
        }

    }

    /*@methodName- generateCodeForServiceChanrge
    *@description- Generate code for service charge that will used in API request. 
    *@param-: productCode,Equipment type,Duration,Market .LF_C_PERM_OPEN
    *@return- string
    */
    public static string generateCodeForServiceChanrge(string productCode , string LineofBusinessc , string ServiceType , string marketAreaCode){
        string generatedCode;
        List<serviceChargesCodeMapping__mdt> serviceChargeCode_mdt = [select Service_charge_code__c from serviceChargesCodeMapping__mdt where 
                                                    Line_of_business__c =:LineofBusinessc
                                                    and Service_type__c =:ServiceType 
                                                    and Product_code__c =: productCode
                                                    and Market_area_code__c =:marketAreaCode limit 1];
        if(serviceChargeCode_mdt != null && serviceChargeCode_mdt.size()> 0 )
        {
        generatedCode  = serviceChargeCode_mdt[0].Service_charge_code__c;
        }
        return generatedCode;

    }

    /*@methodName- priceOnlyAPICall
    *@description- Price only API call 
    *@param-: Locatio name for API end point, request wrapper in (wrapperJsonString), quoteIdOfBundle and quoteNameOfBundle for exception log entry.
    *@return- void
    */
    @future(callout=true)
	public static void priceOnlyAPICall(String locationCode,String wrapperJsonString, String quoteIdOfBundle, String quoteNameOfBundle, boolean callingFromUI, boolean specialHandling){
        System.debug('Inside Future call');
        List<ExceptionLog__c> logObjList = new List<ExceptionLog__c>();
        String endpoint = '';
        Integration_Request_URLs__mdt urlMD;
        String requestBody = '';
        String result = '';
        Http httpObj = new Http();
        set <ID> quoteid = new set <ID>();
        quoteid.add(quoteIdOfBundle);
        HttpRequest req = new HttpRequest();
        String appName = UTIL_ErrorConstants.STEP_STP_APPLICATION_NAME + quoteNameOfBundle + Pricing_Constant_Util.QUOTE_ID + quoteIdOfBundle;
        try{
			urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = :Pricing_Constant_Util.PRICE_ONLY_STP_URL LIMIT 1];
            requestBody = wrapperJsonString;
            system.debug('requestBody :: '+ requestBody);
            endpoint = urlMD.End_Point__c;
            endpoint = endpoint.replace(Pricing_Constant_Util.PR_LOCATION_CODE,locationCode);
            req.setEndpoint(endpoint);
            req.setMethod(Pricing_Constant_Util.METHOD_POST);
            req.setHeader(Pricing_Constant_Util.HEADER_CONTENT_TYPE,urlMD.Content_Type__c);
            req.setHeader(Pricing_Constant_Util.HEADER_USERID, IntegrationHandlerUtil.getLoggedInUserAcornId());
            req.setHeader(Pricing_Constant_Util.HEADER_PARTNER_KEY,urlMD.Client_Key__c);
            req.setHeader(Pricing_Constant_Util.HEADER_AUTHORIZATION,urlMD.Client_Token__c);
            req.setTimeout(urlMD.Timeout__c.intValue());            
            req.setBody(requestBody);
        
            httpresponse res = httpObj.send(req);
            
            if(res.getStatusCode() != 200){
                String errorMessage = Pricing_Constant_Util.EMPTY_STRING;
                PricingRequestJsonDeserialize priceResponse = PricingRequestJsonDeserialize.parse(res.getBody());
                PricingReportingFieldsMetadata.Problem problem = priceResponse.problem;
                List<PricingReportingFieldsMetadata.Errors> errors =  problem.Errors;
                for(PricingReportingFieldsMetadata.Errors err : errors){
                    errorMessage += err.code + Pricing_Constant_Util.EMPTY_STRING + err.message;
                }
                STPExceptionUtil.setStepByStepExceptionObj('priceOnlyAPICall', appName,errorMessage);
            }
            else{
                result = res.getBody();
                system.debug('responseBody :: '+ result);
                List<Pricing_Request__c> priceList = updatePricingRequest(result, quoteIdOfBundle, quoteNameOfBundle);
                update priceList;
                //this block handles price only call from UI and step by step
                if(!callingFromUI){
                    //PlatformEventProcessor.RaiseSTPProcessEventPE(quoteid, true);
                    SBQQ.TriggerControl.disable();
                    try {
                        savePricetoQuoteline(quoteIdOfBundle);
                        
                        //SDT-38472 - removing check of specialHandling
                        if(System.Label.Step_By_Step_Switch == 'On')
                        {
                            
                            STPRuleExecution.executeRules(quoteIdOfBundle, Pricing_Constant_Util.PARTIAL_STP);
                        }
                    } 
                    catch(Exception ex)
                    {
                        system.debug('Exception '+ex.getMessage());
                        system.debug('Exception '+ex.getStackTraceString());
                    }
                    finally 
                    {
                    system.debug('inside enable call');
                    SBQQ.TriggerControl.enable();
                    }
                }
            
            }
            
        } catch(System.CalloutException calloutex){
            STPExceptionUtil.setStepByStepExceptionObj('priceOnlyAPICall', appName,calloutex.getMessage());
        }catch (Exception ex) { 
            STPExceptionUtil.setStepByStepExceptionObj('priceOnlyAPICall', appName,ex.getMessage());  
        }
    }
    /*
     * @methodName : updatePricingRequest
     * @description : update pricing request with price only api response data and return the list of pricing request. 
     * @author  : Jatan
     * @vendor  :	TCS
     * @param	: Price only api response.
     * @return  : List<Pricing_Request__c>
     */     
    public static List<Pricing_Request__c> updatePricingRequest(String APIResponse, String quoteIdOfBundle, String quoteNameOfBundle)
    { 
        List<Pricing_Request__c> priceReqList = new List<Pricing_Request__c>();
        String appName = UTIL_ErrorConstants.STEP_STP_APPLICATION_NAME + quoteNameOfBundle + Pricing_Constant_Util.QUOTE_ID + quoteIdOfBundle;
            PricingRequestJsonDeserialize priceResponse;    
        try{
            priceResponse = PricingRequestJsonDeserialize.parse(APIResponse);
        }catch(Exception ex){
            STPExceptionUtil.setStepByStepExceptionObj('updatePricingRequest', appName,ex.getMessage());  
        }
        
            for(PricingRequestJsonDeserialize.Request responseFields : priceResponse.data)
            {
                
                Pricing_Request__c priceReq = new Pricing_Request__c();
                try{
                priceReq.Id = responseFields.requestNumber;
                responseFields.data = responseFields.price;
                if(responseFields.messages.size() > 0){
                    PricingReportingFieldsMetadata.problem prb = new PricingReportingFieldsMetadata.problem();
                    List<PricingReportingFieldsMetadata.Errors> errList = new List<PricingReportingFieldsMetadata.Errors>();
                    PricingReportingFieldsMetadata.Errors err = new PricingReportingFieldsMetadata.Errors();
                    err.message = responseFields.messages[0].description;
                    err.code = responseFields.messages[0].code;
                    errList.add(err);
                    prb.errors= errList;
                    responseFields.problem= prb; 
                    responseFields.data =null;
                }
                
                String serializedData = JSON.serializePretty(responseFields);
                priceReq.APIRequestOutput__c = serializedData;
                
                    if(responseFields.messages.size() == 0)
                    {
                        priceReq.put('isAPIResult__c',  true);
                        priceReq.put('QuoteID__c',  responseFields.price.priceQuoteIdentifier);
                        priceReq.put('Vendor_Code__c',  responseFields.price.SupplierCode);
                        priceReq.put('Vendor_Name__c',  responseFields.price.supplierName);
                        priceReq.put('Customer_Code__c',  responseFields.price.customerCode);
                        priceReq.put('Cost_Source__c',  responseFields.price.costSource);
                        priceReq.put('Zone_Type__c',  responseFields.price.contractType);
                        priceReq.put('Customer_Price_Type__c',  responseFields.price.priceSource);
                        priceReq.put('Vendor_Comments__c',  responseFields.price.feeComment);
                        priceReq.put('CurrencyIsoCode',  responseFields.price.currencyCode);
    
                        if(responseFields.price.rollOff != null){
                            priceReq.put('Disposal_Rate_Type__c',  responseFields.price.rollOff.pricingMethodDisposalDescription);
                            priceReq.put('Haul_Rate_Type__c',  responseFields.price.rollOff.pricingMethodHaulingDescription);
                            priceReq.put('Haul_Cost__c',  responseFields.price.rollOff.haulCost);
                            priceReq.put('Disposal_Cost__c',  responseFields.price.rollOff.disposalCost);
                            priceReq.put('Haul_Price__c',  responseFields.price.rollOff.haulPrice);
                            priceReq.put('Disposal_Price__c',  responseFields.price.rollOff.disposalPrice);
                            priceReq.put('Est_Tons_per_Haul__c',  responseFields.price.rollOff.estimatedVolumePerHaul);
                            priceReq.put('Haul_Record_Id__c',  responseFields.price.rollOff.haulRecordId);
                            priceReq.put('Disposal_Record_Id__c',  responseFields.price.rollOff.disposalRecordId);
                        }
                        if(responseFields.price.commercial != null){
                            priceReq.put('Pickup_Rate_Type__c',  responseFields.price.commercial.pricingMethodPickupDescription);
                            priceReq.put('Pickup_Cost__c',  responseFields.price.commercial.cost);
                            priceReq.put('Extra_Pickup_Cost__c',  responseFields.price.commercial.extraPickupCost);
                            priceReq.put('Pickup_Price__c',  responseFields.price.commercial.price);
                            priceReq.put('Extra_Pickup_Price__c',  responseFields.price.commercial.extraPickupPrice);
                            priceReq.put('Pickup_Record_Id__c',  responseFields.price.commercial.pickupRecordId);
                            priceReq.put('Extra_Pickup_Record_Id__c',  responseFields.price.commercial.extraPickupRecordId);
                        }
                        if(responseFields.price.wmMetaData != null){
                            //priceReq.put('Business_Unit__c',  responseFields.price.wmMetaData.businessUnit);
                            priceReq.put('Market_Area_Code__c',  responseFields.price.wmMetaData.marketAreaCode);
                            priceReq.put('Market_Area_Name__c',  responseFields.price.wmMetaData.marketAreaName);
                            priceReq.put('Facility_Id__c',  responseFields.price.wmMetaData.facilityId);
                            priceReq.put('Facility_Name__c',  responseFields.price.wmMetaData.facilityName);
                        }
                    }
                    else {
                        
                        priceReq.put('isAPIResult__c',  false);
                        
                        //Todo: Need to handle message section from response
                        //ToDO loop in error messages
                        appName += Pricing_Constant_Util.EMPTY_STRING + Pricing_Constant_Util.PRICING_ID + Pricing_Constant_Util.EMPTY_STRING + priceReq.Id;
                        //STPExceptionUtil.setStepByStepExceptionObj('updatePricingRequest', appName,responseFields.messages[0].code + Pricing_Constant_Util.DASH + responseFields.messages[0].description);
                        String errorMessage = Pricing_Constant_Util.EMPTY_STRING;
                        for(PricingRequestJsonDeserialize.messages err : responseFields.messages){
                            errorMessage += err.code + Pricing_Constant_Util.EMPTY_STRING + err.description;
                        }
                		STPExceptionUtil.setStepByStepExceptionObj('updatePricingRequest', appName,errorMessage);
                    }
                    
                priceReqList.add(priceReq); 
                }catch (Exception ex) {
                    priceReq.put('isAPIResult__c',  false);
                    priceReqList.add(priceReq);
                    STPExceptionUtil.setStepByStepExceptionObj('updatePricingRequest', appName,ex.getMessage());
        		}
                
            }
        
            
        return priceReqList;
    }
    
    /*@methodName- savePricetoQuoteline
    *@description- Method to process the pricing only API response and update Quote and QuoteLine 
    *@param- Id : QuoteId
    *@return- void
    */ 
    public static void savePricetoQuoteline(ID quoteID)
    {
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
        Boolean needRecyclingQL = false;
        Map<Id, Boolean> isRecycleMap = new Map<Id, Boolean>();
        
        List<SBQQ__QuoteLine__c> qlBuldle = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> bundles = QuoteLineSelector.getQuoteLineList(quoteID);
        Integer bundlesCount = bundles.size();
        String currencySymbol;
        Set<Id> bundleIDSet = new Set<Id>();

        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Variables declaration
        String quoteType = '';
        Boolean additionalMetadataRetrieved = false;
        String parentAccountPrimarySegment = '';
        String quoteShippingCountry = '';
        Boolean stdPricingRequestRetrieved = false;
        List<Pricing_Response_Process_Quote_Line__mdt> pricingResponseQuoteLineMetadata = new List<Pricing_Response_Process_Quote_Line__mdt>();
        List<Pricing_Request__c> stdPricingRequestList = new List<Pricing_Request__c>();
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-End Variables declaration
        
	//sdt-44637 sarfaraz
        ExhibitPriceServices exhibitService= new ExhibitPriceServices();
        exhibitService.quoteID= quoteId;
	    
        for(SBQQ__QuoteLine__c qlHdr : bundles){
            quoteHdrMap.put(qlHdr.Id, qlHdr);
            productCodelst.add(qlHdr.SBQQ__ProductName__c);
            bundleIDSet.add(qlHdr.Id);
            if(quoteType == null || quoteType == '')
                quoteType = qlHdr.SBQQ__Quote__r.SBQQ__Type__c;		//TCS-pkulkarn-SDT-40031-9-Apr-2025-Added
            quoteShippingCountry = qlHdr.SBQQ__Quote__r.SBQQ__ShippingCountry__c;	//TCS-pkulkarn-SDT-40031-9-Apr-2025-Added
            parentAccountPrimarySegment = qlHdr.Account__r.Parent.Primary_Segment__c;	//TCS-pkulkarn-SDT-40031-9-Apr-2025-Added
        }
		List<Pricing_Request__c> priqList = PricingRequestSelector.getPricingList(quoteID, bundlesCount);
        List<SBQQ__ProductOption__c> productOptions = getProductOptions(productCodelst);
        
        for(SBQQ__ProductOption__c prdopt : productOptions){
            string concatecode = prdopt.SBQQ__ConfiguredSKU__r.ProductCode + prdopt.SBQQ__OptionalSKU__r.ProductCode;
            qlProductoption.put(concatecode,prdopt);
            }

        if(bundleIDSet != null)
        {
            qlBuldle = QuoteLineSelector.getQuoteLineOrderedList(bundleIDSet);
        }
        
        quoteLineNumber = qlBuldle != null && qlBuldle.size() > 0 ? qlBuldle[0].SBQQ__Number__c: 0;
        for(SBQQ__QuoteLine__c qlSrvReq : qlBuldle)
        {
            if(qlSrvReq.SBQQ__ProductFamily__c != Pricing_Constant_Util.WASTE_CATEGORY)
            {
                if(qlSrvReq.SBQQ__ProductCode__c == Pricing_Constant_Util.HAUL_PRODUCT || qlSrvReq.SBQQ__ProductCode__c == Pricing_Constant_Util.DSP || qlSrvReq.SBQQ__ProductCode__c == Pricing_Constant_Util.PICKUP_PRODUCT || qlSrvReq.SBQQ__ProductCode__c == Pricing_Constant_Util.REC_PRODUCT)
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
		//TCS-pkulkarn-SDT-40031-9-Apr-2025-Added Additional_Processing_Needed__c field to the SOQL query
        List<PricingSTP__mdt> pricingSTP = [SELECT Id, ServiceChargeName__c, ServiceChargeCode__c, AcitonName__c, IsCreateQuoteLine__c, IsDeleteQuoteLine__c, APIServiceChargeCode__c, Additional_Processing_Needed__c
                                            FROM PricingSTP__mdt WHERE IsActive__c = true];
        
        List<Product2> productList = getProductdetails();
        for(Product2 prd : productList)
        {
            productMap.put(prd.ProductCode, prd);
        }

        List<String> pckCostValue = UTIL_Picklist.getPickListValuesIntoList(Pricing_Constant_Util.SBQQ_QUOTELINE_C, Pricing_Constant_Util.COST_UNIT_OF_MEASURE);
        List<String> pckPriceValue = UTIL_Picklist.getPickListValuesIntoList(Pricing_Constant_Util.SBQQ_QUOTELINE_C, Pricing_Constant_Util.PRICEUOM_C);
        
        for(String pcv : pckCostValue){
            costUOMMapName.put(pcv.split(Pricing_Constant_Util.COMMA).get(0), pcv.split(Pricing_Constant_Util.COMMA).get(1));
        }
        for(String ppv : pckPriceValue){
            priceUOMMapName.put(ppv.split(Pricing_Constant_Util.COMMA).get(0), ppv.split(Pricing_Constant_Util.COMMA).get(1));
        }
        
        for(Pricing_Request__c pr : priqList)
        {
            	
            SBQQ__QuoteLine__c ql = quoteHdrMap.get(pr.Quote_Line_Bundle__c);
            SBQQ__QuoteLine__c sqlHdr = new SBQQ__QuoteLine__c();
            needRecyclingQL = false;
            if(!pr.IsCaseError__c && pr.isAPIResult__c)
            {
                
                prFields = PricingReportingFieldsMetadata.parse(pr.APIRequestOutput__c);
                currencySymbol = prFields.Data.currencyCode;

                //Add value in Bundle Header - Start
                sqlHdr.Id = pr.Quote_Line_Bundle__c;
                sqlHdr.Pricing_Only_Request__c = pr.Id;
                sqlHdr.CurrencyIsoCode = currencySymbol;
                // sqlHdr.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);
                sqlHdr.Price_Only_Reason__c = Pricing_Constant_Util.OTH_REASON;
                sqlHdr.Reason_Description__c = Pricing_Constant_Util.STEP_BY_STEP;

                //Use isPriceOnly for SDT-20125
                if(prFields.Data.costSource != null)
                {
                    String sourceCodeStr = prFields.Data.costSource;
                    sqlHdr.Vendor_Service_Location_Code__c = sourceCodeStr.contains('WM') ? pr.Name : sourceCodeStr;
                }

                
                upsertQLLIst.add(sqlHdr);
                if(pr.Zone_Type__c == null || 
                (pr.Zone_Type__c != System.label.WM_Franchise && pr.Zone_Type__c != System.label.Competitor &&
                pr.Zone_Type__c != System.label.Pre_Determined_Pricing && pr.Zone_Type__c != System.label.Third_Party_Agreement))
                {
                    //This loop is for Core Service Charge
                    List<SBQQ__QuoteLine__c> quotelineCoreSrvbundleLst = quoteLineCoreSrvMap != null ? quoteLineCoreSrvMap.get(pr.Quote_Line_Bundle__c) : null;
                    if(quotelineCoreSrvbundleLst != null && quotelineCoreSrvbundleLst.size()>0){
                    for(SBQQ__QuoteLine__c sql : quotelineCoreSrvbundleLst)
                    {
                        //Add value in Bundle QL - Start
                        SBQQ__QuoteLine__c sqlCoreService = new SBQQ__QuoteLine__c();

                        sqlCoreService.Id = sql.Id;
                        sqlCoreService.Pricing_Only_Request__c = pr.Id;
                        // sqlCoreService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);

                        if(prFields.Data.costSource != null)
                        {
                            String sourceCodeStr = prFields.Data.costSource;
                            sqlCoreService.Vendor_Service_Location_Code__c = sourceCodeStr.contains(Pricing_Constant_Util.WM_VENDOR) ? pr.Name : sourceCodeStr;
                        }

                        //Note: In below logic comment the Cost for every Core and Ancillary Services

                        if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.HAUL) || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL)
                        || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP) || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_EXTRA_PICKUP)
                        || sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.RECYCLING))
                        {
                            String apivalueUOMID = null;

                            apivalueUOMID = setMonthlytoMonthUOM(costUOMMapName, prFields.Data.equipmentUOM);
                            sqlCoreService.CurrencyIsoCode = currencySymbol;                                    

                            if(prFields.Data.rollOff != null)
                            {
                                if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.HAUL))
                                {
                                    sqlCoreService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodHaulingDescription;
                                    sqlCoreService.SBQQ__ListPrice__c = prFields.Data.rollOff.haulPrice;
                                }
                                else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.DISPOSAL))
                                {
                                    if(apivalueUOMID != null)
                                    {
                                        //Removed for SDT-38484
                                        //sqlCoreService.Cost_Unit_of_Measure__c = apivalueUOMID;
                                        sqlCoreService.PriceUOM__c = apivalueUOMID;
                                    }
                                    
                                    //Stepped Pricing changes - Logic Start                                    
                                    if(prFields.Data.rollOff.stepDisposals != null && prFields.Data.rollOff.stepDisposals.size() > 0)
                                    {
                                        sqlCoreService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodDisposalDescription;
                                        Integer steppedCounter = 1;
                                        for(PricingReportingFieldsMetadata.StepDisposal step : prFields.Data.rollOff.stepDisposals)
                                        {
                                            if(steppedCounter == 1)
                                            {
                                                if(step.price != null)
                                                {
                                                    sqlCoreService.SBQQ__PricingMethod__c = Pricing_Constant_Util.STP;
                                                }
                                            }
                                            //Add Step Logic here...
                                            
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
                                                sqlCoreService.SBQQ__PricingMethod__c = Pricing_Constant_Util.LIST_METHOD;
                                                sqlCoreService.SBQQ__ListPrice__c = prFields.Data.rollOff.disposalPrice;
                                            }
                                            steppedCounter++;
                                        }
                                    } //Stepped Pricing changes - Logic Start
                                    else
                                    {
                                        if((prFields.Data.costSource.contains(Pricing_Constant_Util.WM_VENDOR) && prFields.Data.rollOff.disposalCost >= 0) || !prFields.Data.costSource.contains(Pricing_Constant_Util.WM_VENDOR))
                                        {
                                            sqlCoreService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodDisposalDescription;
                                            sqlCoreService.SBQQ__PricingMethod__c = Pricing_Constant_Util.LIST_METHOD;
                                            sqlCoreService.SBQQ__ListPrice__c = prFields.Data.rollOff.disposalPrice;
                                        }
                                    }
                                    //Change for Story SDT-23396
                                    if(prFields.Data.feeComment != null && prFields.Data.feeComment.contains(Pricing_Constant_Util.REBATE))
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
                                            if(prFields.Data.materialCode == Pricing_Constant_Util.CARDBOARD || prFields.Data.materialCode == Pricing_Constant_Util.SSR)
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
                                        if(prFields.Data.costSource.contains(Pricing_Constant_Util.WM_VENDOR))
                                        { 
                                            //when the vendor is WM, then min tons price copy to both Cost and Price
                                            sqlCoreService.CostMinQuantity__c = setZeroASNullforMinTon(priceMinTon);
                                            sqlCoreService.PriceMinQuantity__c = setZeroASNullforMinTon(priceMinTon);
                                        }
                                        else
                                        {
                                            //when the vendor is 3P, then min tons price copy to price and  Cost copy to cost
                                            //Comment for SDT-42461
                                            // sqlCoreService.CostMinQuantity__c = setZeroASNullforMinTon(costMinTon);
                                            sqlCoreService.PriceMinQuantity__c = setZeroASNullforMinTon(priceMinTon);
                                        }
                                    }
                                }
                                else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.RECYCLING))
                                {
                                    if(prFields.Data.feeComment != null && prFields.Data.feeComment.contains(Pricing_Constant_Util.REBATE))
                                     {
                                        deleteQuotelinelst.add(sql.Id);
                                     }
                                }

                                //This Section for create the Recycling QL
                                //SDT-23396
                                if(needRecyclingQL)
                                {
                                    //Get product ID from product Map.
                                    Product2 prdREC = productMap.get(Pricing_Constant_Util.REC_PRODUCT);
                                    string concatproductoption = ql.SBQQ__ProductCode__c + Pricing_Constant_Util.REC_PRODUCT;
                                    SBQQ__ProductOption__c productOption = qlProductoption.get(concatproductoption);
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
                                            if(productOption.Occurrence_Type__c == Pricing_Constant_Util.SCH_CALL)
                                            {
                                                sqlancillaryService.Schedule_Frequency__c = productOption.Schedule_Frequency__c;
                                                sqlancillaryService.Frequency_Interval__c = productOption.Frequency_Interval__c;
                                            }
                                        }
                                        sqlancillaryService.Vendor__c = ql.Vendor__c;
                                        sqlancillaryService.MASLibrary__c = ql.MASLibrary__c;
                                        sqlancillaryService.MASCompany__c = ql.MASCompany__c;
                                        sqlancillaryService.SetupComment__c = ql.SetupComment__c;
                                        sqlancillaryService.SBQQ__OptionLevel__c = 1;
                                        sqlancillaryService.SBQQ__Quantity__c = 1;
                                        sqlancillaryService.SBQQ__Number__c = quoteLineNumber + 1; //need to check what this field is for.
                                        sqlancillaryService.SBQQ__CostEditable__c = true;
                                        sqlancillaryService.SBQQ__PriceEditable__c = true;
                                        sqlancillaryService.SBQQ__UnitCost__c = 0.00;
                                        sqlancillaryService.SBQQ__ListPrice__c = 0.00;
                                        sqlancillaryService.CurrencyIsoCode = currencySymbol;
                                        sqlancillaryService.Cost_Unit_of_Measure__c = Pricing_Constant_Util.TN_UOM; 
                                        sqlancillaryService.PriceUOM__c = Pricing_Constant_Util.TN_UOM; 
                                        sqlancillaryService.SBQQ__StartDate__c = ql.SBQQ__StartDate__c;
                                        sqlancillaryService.SBQQ__EndDate__c = ql.SBQQ__EndDate__c;
                                        sqlancillaryService.CostModelType__c = Pricing_Constant_Util.REB_COST_MODEL;
                                        sqlancillaryService.SBQQ__PricingMethod__c = Pricing_Constant_Util.REB_COST_MODEL;
                                        sqlancillaryService.ContractNotes__c = prFields.Data.feeComment;
                                        // sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);

                                        //Changes done for SDT-24353
                                        if(prFields.Data.costSource != null)
                                        {
                                            String sourceCodeStr = prFields.Data.costSource;
                                            sqlancillaryService.Vendor_Service_Location_Code__c = sourceCodeStr.contains(Pricing_Constant_Util.WM_VENDOR) ? pr.Name : sourceCodeStr;
                                        }
                                        sqlancillaryService.Pricing_API_Method__c = prFields.Data.rollOff.pricingMethodHaulingDescription;
                                        //End
                                        
                                        upsertQLLIst.add(sqlancillaryService);
                                        quoteLineNumber++;

                                        needRecyclingQL = false;
                                    }
                                }
                            }
                            else if(prFields.Data.commercial != null)
                            {
                                if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_PICKUP))
                                {
                                    sqlCoreService.Pricing_API_Method__c = pr.Pickup_Rate_Type__c;
                                    sqlCoreService.SBQQ__ListPrice__c = prFields.Data.commercial.unitPrice;
                                    if(pr.Schedule_or_On_Call__c == Pricing_Constant_Util.SCHEDULED && apivalueUOMID != null)
                                    {
                                        sqlCoreService.PriceUOM__c = apivalueUOMID;
                                    }
                                    else if(pr.Schedule_or_On_Call__c == Pricing_Constant_Util.ON_CALL)
                                    {
                                        sqlCoreService.PriceUOM__c = Pricing_Constant_Util.EV_UOM;
                                    }
                                }
                                else if(sql.SBQQ__ProductName__c.equals(Pricing_Constant_Util.PR_EXTRA_PICKUP))
                                {
                                    sqlCoreService.SBQQ__ListPrice__c = prFields.Data.commercial.extraPickupPrice;
                                    sqlCoreService.PriceUOM__c = Pricing_Constant_Util.EV_UOM;
                                }
                            }
                        }
                        upsertQLLIst.add(sqlCoreService);
                    }
                    }

                    if(prFields.Data.serviceCharges != null)
                    {
                        //This loop is for Ancillary Charge (Non Core Service Charge)
                        List<SBQQ__QuoteLine__c> quotelineSrvbundleLst = quoteLineSrvMap.get(pr.Quote_Line_Bundle__c);
                        
                        for(Integer scIndex = 0; scIndex < prFields.Data.serviceCharges.size(); scIndex++)
                        {
                            Boolean isServiceExist = false;
                            SBQQ__QuoteLine__c currentQl ; 
                            for(PricingSTP__mdt meta : pricingSTP)
                            {
                                string api_ServiceCode = prFields.Data.serviceCharges[scIndex].code.substringBefore('_');
                                
                                if(api_ServiceCode == meta.APIServiceChargeCode__c 
                                && (prFields.Data.serviceCharges[scIndex].actionName == meta.AcitonName__c
                                ||  prFields.Data.serviceCharges[scIndex].actionName == null
                                ||  prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.MANUAL_REVIEW))
                                {
                                    String costUOMID = null, priceUOMID = null;
                                    costUOMID = setMonthlytoMonthUOM(costUOMMapName, prFields.Data.serviceCharges[scIndex].costUOM);
                                    priceUOMID = setMonthlytoMonthUOM(priceUOMMapName, prFields.Data.serviceCharges[scIndex].priceUOM);

                                    if(meta.ServiceChargeCode__c == Pricing_Constant_Util.CSC)
                                    {
                                        costUOMID = Pricing_Constant_Util.COST_UOM_MTH;    
                                        priceUOMID = Pricing_Constant_Util.COST_UOM_MTH;    
                                    }
                                    else if(meta.ServiceChargeCode__c == Pricing_Constant_Util.DLV)
                                    {
                                        costUOMID = Pricing_Constant_Util.EV_UOM;
                                        priceUOMID = Pricing_Constant_Util.EV_UOM;
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
                                        currentQl.CurrencyIsoCode = currencySymbol;
                                        // currentQl.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);
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
										pricingResponseProcessorInput.bundleId = isServiceExist ? currentQl.SBQQ__RequiredBy__c : null;
                                        pricingResponseProcessorInput.processQuoteLineMetadata = pricingResponseProcessor.retrieveProcessQuoteLineMetadata(pricingResponseQuoteLineMetadata);
										//prpInput.processQuoteLineMetadata = pricingResponseQuoteLineMetadata;
                                        if(stdPricingRequestRetrieved == false)
                                        {
                                            stdPricingRequestList = PricingRequestSelector.getStandardPricingRequestList(quoteID);
                                            stdPricingRequestRetrieved = true;

                                            if(PricingRequestSelector.isPricingMulltiVendorAMSwitchON()){
                                                Pricing_Request__c prSeleted;
                                                PricingRequestFieldsMetadata prSuppFields = new PricingRequestFieldsMetadata();
                                                for(Pricing_Request__c selectedPR : stdPricingRequestList){
                                                    if(selectedPR.Quote_Line_Bundle__c == pr.Quote_Line_Bundle__c){
                                                        prSeleted = selectedPR;
                                                        break;
                                                    }
                                                }
                                                prSuppFields = PricingRequestFieldsMetadata.parse(prSeleted.APIRequestOutput__c);
                                                //System.debug('prSeleted.APIRequestOutput__c >> ' + prSeleted.APIRequestOutput__c);
                                                //System.debug('prSuppFields >> ' + prSuppFields);
                                                //Fetching the selected supplier from the multi-vendor pricing response
                                                if(prSuppFields != null && prSuppFields.data != null && prSuppFields.data.suppliers != null){
                                                    for(PricingRequestFieldsMetadata.suppliers spp : prSuppFields.data.suppliers)
                                                    {
                                                        if(spp.supplierCode != null && spp.supplierCode.contains(pr.Vendor_Code__c)){
                                                            pricingResponseProcessorInput.prMVFields = spp;
                                                        }
                                                    }
                                                }                                                
                                            }
                                        }
                                        pricingResponseProcessorInput.stdPricingRequestList = stdPricingRequestList;
    									pricingResponseProcessorOutput = pricingResponseProcessor.determineQuoteLineAction(pricingResponseProcessorInput);
                                        //system.debug('PK Result' + meta.ServiceChargeName__c + prpOutput);
                                    }
                                    //TCS-pkulkarn-SDT-40031-9-Apr-2025-End
                                    
                                    
                                    if(prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ALLOW || prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ADJUST 
                                    || prFields.Data.serviceCharges[scIndex].actionName == null ||  prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.MANUAL_REVIEW)
                                    {
                                        if(isServiceExist) //This cater isUpdate condition 
                                        {
                                            //Update current quoteline and add into list
                                            
                                            //Changes for SDT-23997, Quoteline should not create or update if cost and price get NULL value
                                            if(prFields.Data.serviceCharges[scIndex].cost != null || prFields.Data.serviceCharges[scIndex].price != null)
                                            {
                                                if(prFields.Data.serviceCharges[scIndex].priceValueType != null && prFields.Data.serviceCharges[scIndex].priceValueType.equals(Pricing_Constant_Util.PERCENT))
                                                {
                                                    currentQl.SBQQ__MarkupRate__c = prFields.Data.serviceCharges[scIndex].price;
                                                    currentQl.SBQQ__ListPrice__c = 0.00;
                                                }
                                                else
                                                {
                                                    currentQl.SBQQ__ListPrice__c = prFields.Data.serviceCharges[scIndex].price;
                                                }
                                                currentQl.PriceUOM__c = priceUOMID;
						//Added by Sarfaraz for SDT-44637
                                                if(prFields.Data.serviceCharges[scIndex].componentTypeCode.equalsIgnoreCase('CSC') && exhibitService.checkIfCanadianAccount(quoteID) && exhibitService.checkIfNewServiceCase(quoteID))
                                                {
                                                    currentQl.PriceUOM__c=ExhibitPriceServices.setMonthlytoMonthUOM(priceUOMMapName, prFields.Data.serviceCharges[scIndex].priceUOM);
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
                                            
                                            //upsertQLLIst.add(currentQl);		//TCS-pkulkarn-SDT-40031-9-Apr-2025-Commented
                                        }

                                        else if(meta.IsCreateQuoteLine__c)
                                        {
                                            //Changes for SDT-23997, Quoteline should not create or update if cost and price get NULL value
                                            if(prFields.Data.serviceCharges[scIndex].cost != null || prFields.Data.serviceCharges[scIndex].price != null)
                                            {
                                                //Get product ID from product Map.
                                                Product2 prd = productMap.get(meta.ServiceChargeCode__c);
                                                string concatproductoption = ql.SBQQ__ProductCode__c + meta.ServiceChargeCode__c;
                                                SBQQ__ProductOption__c productOption = qlProductoption.get(concatproductoption);
                                                if(prd !=null)
                                                {
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
                                                    sqlancillaryService.Vendor__c = ql.Vendor__c;
                                                    sqlancillaryService.MASLibrary__c = ql.MASLibrary__c;
                                                    sqlancillaryService.MASCompany__c = ql.MASCompany__c;
                                                    sqlancillaryService.SetupComment__c = ql.SetupComment__c;
                                                    sqlancillaryService.SBQQ__OptionLevel__c = 1;
                                                    sqlancillaryService.SBQQ__Quantity__c = 1;
                                                    sqlancillaryService.SBQQ__Number__c = quoteLineNumber + 1; //need to check what this field is for.
                                                    sqlancillaryService.SBQQ__CostEditable__c = true;
                                                    sqlancillaryService.SBQQ__PriceEditable__c = true;                                                    
                                                    sqlancillaryService.SBQQ__StartDate__c = ql.SBQQ__StartDate__c;
                                                    sqlancillaryService.SBQQ__EndDate__c = ql.SBQQ__EndDate__c;
                                                    sqlancillaryService.CurrencyIsoCode = currencySymbol;
                                                    // sqlancillaryService.BypassPriceReview__c = getBypassPriceReview(pr.Zone_Type__c, prFields.Data.costSource);

                                                    if(prFields.Data.serviceCharges[scIndex].costValueType != null && prFields.Data.serviceCharges[scIndex].costValueType.equals(Pricing_Constant_Util.PERCENT))
                                                    {
                                                        sqlancillaryService.SBQQ__SubscriptionPercent__c = prFields.Data.serviceCharges[scIndex].cost;
                                                        sqlancillaryService.SBQQ__UnitCost__c = 0.00;
                                                    }
                                                    else
                                                    {
                                                        sqlancillaryService.SBQQ__UnitCost__c = prFields.Data.serviceCharges[scIndex].cost;
                                                    }
                                                    if(prFields.Data.serviceCharges[scIndex].priceValueType != null && prFields.Data.serviceCharges[scIndex].priceValueType.equals(Pricing_Constant_Util.PERCENT))
                                                    {
                                                        sqlancillaryService.SBQQ__MarkupRate__c = prFields.Data.serviceCharges[scIndex].price;
                                                        sqlancillaryService.SBQQ__ListPrice__c = 0.00;

                                                        //Condition - Price have %value and cost is null then set cost as zero - STP logic
                                                        if(prFields.Data.serviceCharges[scIndex].cost == null)
                                                            sqlancillaryService.SBQQ__UnitCost__c = 0.00;
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
                                            if(isServiceExist && meta.IsDeleteQuoteLine__c)
                                            {
                                                //Change for SDT-36178
                                                if(prFields.Data.costSource.contains(Pricing_Constant_Util.WM_VENDOR))
                                                {
                                                    deleteQuotelinelst.add(currentQl.id);
                                                }
                                                else
                                                {
                                                    //Change for SDT-36178
                                                    currentQl.SBQQ__ListPrice__c = 0;
                                                    currentQl.PriceUOM__c = costUOMID;
                                                    
                                                    upsertQLLIst.add(currentQl);
                                                }
                                            }
                                            else if(isServiceExist) //Update Existing Quote Line to 0 cost/price
                                            {
                                                //Update current quoteline and add into list
                                                // currentQl.SBQQ__UnitCost__c = 0;
                                                // currentQl.Cost_Unit_of_Measure__c = costUOMID;
                                                currentQl.SBQQ__ListPrice__c = 0;
                                                currentQl.PriceUOM__c = costUOMID;
                                                
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
                sqlHdr.Pricing_Only_Request__c = pr.Id;
                upsertQLLIst.add(sqlHdr);
            }
        }
        if(upsertQLLIst !=null && upsertQLLIst.size() > 0 ){
             try{
                //Skip QL validation for Cost/Price, SDT-26002
                RecurrsiveTriggerHandler.isSkipValidateQLCostPrice = true;
                 
                upsert upsertQLLIst;
            }
            catch(exception ex){
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_STP_APEX + Pricing_Constant_Util.QUOTE_ID + quoteID, LoggingLevel.ERROR);
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
            }
        }
    }
    
    /*
    Description: Change SDT-30895, Change the Acorn - Monthly to SF - Month picklist value.
    */
    private static string setMonthlytoMonthUOM(Map<String,String> UOMMapName, string UOM)
    {
        return UOM == Pricing_Constant_Util.MONTHLY ? Pricing_Constant_Util.COST_UOM_MTH : UOMMapName.get(UOM);
    }

    /*
    *@description- Method to check BypassPriceReview by Contract Type
    */
    // public static Boolean getBypassPriceReview(string zoneType, string costSource)
    // {
    //     Boolean bypassPriceReview = false;
    //     if(zoneType == Pricing_Constant_Util.OPEN_MARKET && costSource.contains(Pricing_Constant_Util.WM_VENDOR))
    //     {
    //         bypassPriceReview = true;
    //     }
    //     return bypassPriceReview;
    // }

    /*
    Description: Change SDT-30495, Update CostMinQuantity and PriceMinQuantity to null when actual value is zero.
    This logic is introduce to ensure user specifies minTon value after reviewing blank value in Acorn.
    */
    private static decimal setZeroASNullforMinTon(decimal minTonValue)
    {
        return minTonValue == 0 ? null : minTonValue;
    }

}
