/*
* @Name          STPRuleExecution
* @Author        WM - Jatan Sharma, WM - Digdershika Ojha
* @Date          23/01/2023
* @Vendor		 TCS
* @Description   This class is created to Straight-Through Processing (STP) functionality.
This will execute the rules to confirm if STP or Not.
*/
public with sharing class STPRuleExecution {
    //Variable initialization
    public static List<SBQQ__QuoteLine__c> qlines = new List<SBQQ__QuoteLine__c>();
    public static List<SBQQ__QuoteLine__c> parentLines = new List<SBQQ__QuoteLine__c>();
    public static Set<Id> quoteIdList = new Set<Id>();
    public static Map<Id,string> quoteLineProductMap = new Map<Id,string>();
    public static Map<Id,string> quotLineMaterialMap = new Map<Id,string>();
    public static Map<Id,string> quotLineOccuranceTypeMap = new Map<Id,string>();
    public static Map<Id,string> quotLineMarketAreaMap = new Map<Id,string>();
    public static Map<Id,string> contractTypeMap = new Map<Id,string>();
    public static boolean isSTPSuccess = true;
    public static string recordType= null;
    public static Map<Id,string> duration = new Map<Id,string>();
    public static string errorMessage = '';
    public static string quoteIDStr = ' QuoteID:';
    public static string quoteNameStr = ' QuoteName : ';
    public static ExceptionLog__c exceptionLog = new ExceptionLog__c();
    public static ExceptionLog__c logObj = null;
    public static List<ExceptionLog__c> logObjList = new List<ExceptionLog__c>();
    
    public static Map<string,List<string>> quoteErrorMessageMap = new Map<string,List<string>>();
    //Start-SDT-29086
    public static string parentAccountCustomerCode='';
    public static string EXEMPTION_RECORD_TYPE = 'Client Pricing Exemption';
    public static string STP_ELIGIBILITY_REC_TYPE = 'STP Eligibility';
    //End-SDT-29086
    //Start- SDT - 28597
    //WMI National Accounts
    public static string WMNAT = 'WMNAT';
    //Wasteless Environmental Services
    public static string OAKWL = 'OAKWL';
    //End - SDT-28597
    //Start-30855
    public static Map<Id,String> bundleProductMap =  new Map<Id,String>();
    //End-30855

    //SDT-29084
    public static map<id,List<SBQQ__QuoteLine__c>> parentChildQLMap = new map<id,List<SBQQ__QuoteLine__c>>();
    public static map<id,boolean> parentIDMap = new map<id,boolean>();
    public static Boolean specialHandling = false;
    public static String specialHandlingReason = '';
    public static String specialHandlingDetailReason = '';
    
    /*
     * @Method Name    : executeRules
     * @author         : Jatan Sharma
     * @description    : For given quoteId, code will try to match all quoteLines against each configured STPCriteria__c
     * rules and if any first match is found will break from making isSTPSuccess as false.
     * @param          : QuoteId is unique Id of quote
     * @return         : a boolean true or false to signify whether quote matched with any configured STPCriteria__c
	 */
    public static boolean executeRules(Id quoteId, String STPType){
        
        //SDT-47978 - Added variable by Yugandhar Adem : START
        List<String> allowedReasonsForPartialSTP = new List<String>{'Vendor costs attached','Vendor preference','Emergency vendor','Other','Delivery not needed/container on site','Automatically flagged by system'};
        //SDT-47978 - Added variable by Yugandhar Adem : END
        
        quoteIdList.add(quoteId);
        String quoteName = null;
        exceptionLog.Method_Name__c = 'executeRules';
        exceptionLog.Exception_Type__c = STPType;
        exceptionLog.Exception_Details__c = '';
        Integer counter = 0;
        //SDT - 30975 - start
        Pricing_Threshold_Settings__mdt pricingThreshold = Pricing_Threshold_Settings__mdt.getInstance(Pricing_Constant_Util.STP_HAUL_COST);
        Decimal haulCostMinimumValue = pricingThreshold.Minimum_Value__c;
        Decimal haulCostMaximumValue = pricingThreshold.Maximum_Value__c;

        //SDT 46922
            Boolean isExhibitPricing = false;
            Decimal exhibitHaulCostMinValue;
            Decimal exhibitHaulCostMaxValue;
        //SDT-46922 - end

        //SDT - 30975 - End
        //Get the Parent quoteline
        qlines =  QuoteLineSelector.getQuoteLinesByQuoteIdList(quoteIdList);
        for(SBQQ__QuoteLine__c ql : qlines)
        {
            quoteName = ql.SBQQ__Quote__r.Name;
            
            if(ql.SBQQ__RequiredBy__c == null)
            {
                //Counter increment only for WM Vendor
                if(ql.Vendor__r.Parent_Vendor_ID__c != null && (ql.Vendor__r.Parent_Vendor_ID__c == Pricing_Constant_Util.VENDOR_WM || ql.Vendor__r.Parent_Vendor_ID__c == Pricing_Constant_Util.VENDOR_CANADA)){
                	counter++; // 2 for 2 bundle
                }
                //SDT-36034
                specialHandling = ql.SBQQ__Quote__r.Special_Handling__c;
                specialHandlingReason = ql.SBQQ__Quote__r.Special_Handling_Reason__c;
                if(ql.SBQQ__Quote__r.Special_Handling_Reason_Details__c != null){
                	specialHandlingDetailReason = ql.SBQQ__Quote__r.Special_Handling_Reason_Details__c;
                    system.debug('specialHandlingDetailReason :: '+ specialHandlingDetailReason);
                }
                //SDT-47978 - Added variable by Yugandhar Adem : START
                if(allowedReasonsForPartialSTP.contains(specialHandlingReason) && STPType == Pricing_Constant_Util.PARTIAL_STP){
                    //specialHandlingReasonsAllowedForPartialSTP = true;
                    specialHandling = false;
                    //system.debug('specialHandlingReasonsAllowedForPartialSTP :: '+ specialHandlingReasonsAllowedForPartialSTP);
                }
                //SDT-47978 - Added variable by Yugandhar Adem : END
                if(specialHandling){
                   
                   errorMessage = 'By Passing Straight Through Processing as specialHandling is selected reason being ' + specialHandlingReason + ' ' + specialHandlingDetailReason + ' for Quote '+ ql.SBQQ__Quote__r.Name;
                   exceptionLog.Application_Name__c = quoteIDStr + ql.SBQQ__Quote__r.Id + quoteNameStr + ql.SBQQ__Quote__r.Name;
                   isSTPSuccess = false;
                   exceptionLog.Exception_Details__c = errorMessage;
                   logObj = createExceptionLogObj(exceptionLog);
            		logObjList.add(logObj);
            		UTIL_LoggingService.logExceptionObject(logObjList);
                   return false;
                    
                }
                
                quoteLineProductMap.put(ql.Id,ql.SBQQ__Product__r.Name);
                quotLineOccuranceTypeMap.put(ql.Id,ql.Occurrence_Type__c);
                //SDT-32003 - Fetch Market area from availability api
                for(AAV_Asset_Availability__c availabilityOutput : ql.Asset_Availabilities__r){
                    if(availabilityOutput!=null){
                    AvailabilityAPIJsonDeserialize availabilityData ;
                        try{
                            availabilityData = AvailabilityAPIJsonDeserialize.parse(availabilityOutput.AAV_APIRequestOutput__c);
                            if(availabilityData.data != null && availabilityData.data.suppliers != null && availabilityData.data.suppliers.size()>0 && availabilityData.data.suppliers[0]!=null){
                                
                                if(availabilityData.data.suppliers[0].wmMetaData!=null){
                                //system.debug('availabilityData.data.suppliers[0].wmMetaData.marketAreaCode ::'+ availabilityData.data.suppliers[0].wmMetaData.marketAreaCode);
                                if(!String.isBlank(availabilityData.data.suppliers[0].wmMetaData.marketAreaCode)){
                                    quotLineMarketAreaMap.put(ql.Id, availabilityData.data.suppliers[0].wmMetaData.marketAreaCode);
                                }
                                
                            }
                        	}
                        }catch(Exception ex){
                            
                            String appName = 'STPRuleExecution By Pass Review Availiability parser failed for Quote '+ quoteName + ' QuoteLine '+ ql.Name;
                            STPExceptionUtil.setStepByStepExceptionObj('executeRules', appName,ex.getMessage());
                        }
                        
                        
                    }
            	}
                contractTypeMap.put(ql.Id, ql.Pricing_Request__r.zone_Type__c);
                
                
                recordType = ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name;
                duration.put(ql.Id, ql.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c);
                parentAccountCustomerCode = ql.Account__r.Parent.Customer_Code__c;
                parentIDMap.put(ql.id,false);                  
                
            }
            //SDT-29084 - start
            else{
                if(ql.SBQQ__ProductFamily__c != Pricing_Constant_Util.WASTE_CATEGORY && ql.SBQQ__ProductFamily__c != Pricing_Constant_Util.WASTE_STREAM)
                {
                    if(parentChildQLMap.containsKey(ql.SBQQ__RequiredBy__c)){
                        list<SBQQ__QuoteLine__c> newList= parentChildQLMap.get(ql.SBQQ__RequiredBy__c);
                        newList.add(ql);
                        parentChildQLMap.put(ql.SBQQ__RequiredBy__c , newList);
                    }
                    else{
                        parentChildQLMap.put(ql.SBQQ__RequiredBy__c , new list<SBQQ__QuoteLine__c>{ql});
                    }
                    //SDT-36170 Updating QL ID with Grand parent ID only for execution
                    if(ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c!=null){
                        ql.SBQQ__RequiredBy__c = ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c;

                    }
                }
            }
            //SDT-29084 - End
            
            if(ql.SBQQ__ProductFamily__c == Pricing_Constant_Util.WASTE_STREAM){
                quotLineMaterialMap.put(ql.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,ql.SBQQ__Product__r.Name );
            }
        }
        
        
        //SDT-29086 - added recordType of StpCriteria as last argument
        List<STP_Criteria__c> stpRules = STPCriteriaSelector.getRecordByMatchingQuote(recordType, quoteLineProductMap, quotLineMaterialMap, duration, quotLineOccuranceTypeMap,STP_ELIGIBILITY_REC_TYPE, STPType);
		
        //SDT-29086 - Fetch the STPExemption based on Customer Code. 
        //List<STP_Criteria__c> STPExemption = STPCriteriaSelector.getSTPExemptionRecord(EXEMPTION_RECORD_TYPE,parentAccountCustomerCode);
        //SDT-30855 - Start
        List<STP_Criteria__c> stpExemptionRules = STPCriteriaSelector.getSTPExemptionRecord(EXEMPTION_RECORD_TYPE,parentAccountCustomerCode, duration, quoteLineProductMap);
       
        
        bundleProductMap = getExemptionProduct( stpExemptionRules,  qlines,  quoteLineProductMap, STPType);
        
        //SDT-30855 - End
        
        /*
		 * Check quoteLines against eligible stp rules only if recordtype is 'New Service case as part of current scope'
		 * exclude the execution for quote line who belong to 'Waste Category/Waste Stream' product family
		 */ 
        
        if(recordType == Pricing_Constant_Util.New_Service_Case) {
            
            for(id qlID : parentChildQLMap.keyset())
            {
                for(SBQQ__QuoteLine__c ql : parentChildQLMap.get(qlID)){

                    if(isSTPSuccess ){
                        if(stpRules!=null && !stpRules.isEmpty()){
                            for(STP_Criteria__c rule : stpRules){
                                
                                /*
								 * For each rule and eligible quoteLine check if their
								 * Equipment type match
								 * material value match
								 * duration value match
								 * frequency value match
								 * vendor match - currently only value '8' is in scope
								 * Market Area value match
								 * Quote Line Priority is either P1 or P2
								 */ 
                                if(quoteLineProductMap.get(ql.SBQQ__RequiredBy__c) == rule.Equipment__c 
                                   && rule.Material__c.contains(quotLineMaterialMap.get(ql.SBQQ__RequiredBy__c))
                                   && rule.Duration__c.contains(ql.Duration__c)
                                   && rule.frequency__c.contains(quotLineOccuranceTypeMap.get(ql.SBQQ__RequiredBy__c))
                                // Commented below code for SDT-28507
                                //    && ql.Vendor__r.Parent_Vendor_ID__c != null
                                //    && ql.Vendor__r.Parent_Vendor_ID__c == rule.Parent_VID__c
                                  )
                                {
                                    isSTPSuccess = true;
                                    List<String> parentVidList ;
                                    if(rule.Parent_VID__c !=null){
                                       parentVidList = rule.Parent_VID__c.split(',');
                                    }
                                    //WM Vendor - included Exclude and market area check for WM
                                    if(ql.Vendor__c == null){
                                        isSTPSuccess = false;
                                        errorMessage = ql.SBQQ__Product__r.Name + ' is missing vendor in Pricing Response for QuoteLine ' +
                                            ql.Name + ' for Quote '+ ql.SBQQ__Quote__r.Name;
                                        exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                        setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                        parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                        continue;
                                    }
                                    if(ql.Vendor__r.Parent_Vendor_ID__c != null 
                                        && (ql.Vendor__r.Parent_Vendor_ID__c == Pricing_Constant_Util.VENDOR_WM || ql.Vendor__r.Parent_Vendor_ID__c == Pricing_Constant_Util.VENDOR_CANADA)){
                                        if(!rule.WM_Vendor__c){// Exclude logic
                                            if(rule.All_WM_Vendors__c){ 
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', All WM vendors excluded for Quote '+ ql.SBQQ__Quote__r.Name;
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue;
                                            }
                                            else{
                                                //if(rule.Parent_VID__c != null && rule.Parent_VID__c.contains(ql.Vendor__r.Parent_Vendor_ID__c)){
                                                if(parentVidList != null && parentVidList.size()>0 && parentVidList.contains(ql.Vendor__r.Parent_Vendor_ID__c)){
                                                    isSTPSuccess = false;
                                                    errorMessage = 'Rule Name: ' + rule.Name + ', Excluded vendor found which contains Vendor '+ ql.Vendor__r.Parent_Vendor_ID__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                    exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                    setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                    parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                    continue; 
                                                }
                                            }
                                        }
                                        else{ // include logic
                                            //if(!rule.All_WM_Vendors__c && (rule.Parent_VID__c !=null && !rule.Parent_VID__c.contains(ql.Vendor__r.Parent_Vendor_ID__c)) ){
                                            if(!rule.All_WM_Vendors__c && (parentVidList != null && parentVidList.size()>0 && !parentVidList.contains(ql.Vendor__r.Parent_Vendor_ID__c)) ){
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', does not contain following Vendor - '+ ql.Vendor__r.Parent_Vendor_ID__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue; 
                                            }
                                        }
                                        //Logic to check Market Area recieved from pricing, if not included in rule it fails.
                                    if(rule.MAS__c != null && quotLineMarketAreaMap != null && quotLineMarketAreaMap.size() > 0 
                                          && quotLineMarketAreaMap.containsKey(ql.SBQQ__RequiredBy__c)
                                          && !rule.MAS__c.contains(quotLineMarketAreaMap.get(ql.SBQQ__RequiredBy__c) )){
                                           //system.debug('Inside IF quotLineMarketAreaMap check');
                                           isSTPSuccess = false;
                                           errorMessage = 'Rule Name: ' + rule.Name + ', Market Area Library code '+quotLineMarketAreaMap.get(ql.SBQQ__RequiredBy__c)+' not included for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                           exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                           setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                           parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                          continue;
                                          }else if(quotLineMarketAreaMap == null || quotLineMarketAreaMap.size() == 0 || quotLineMarketAreaMap.size() != counter){
                                                if(!STPType.equalsIgnoreCase(Pricing_Constant_Util.PARTIAL_STP)){ //SDT43354 // @Covered by :  STPRuleExecutionTest.getDataMarketAreanullTest()     
                                                isSTPSuccess = false;
                                                  errorMessage = 'Rule Name: ' + rule.Name + ',Market Area is not available from Availibility for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                  exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                  setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                  parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                  continue;
                                                }
                                            }
                                    }
                                    //3rd Part vendor - include exclude
                                    else {
                                        List<String> childVidList;
                                        if(rule.Parent_Non_Parent_VID_s__c!=null){
                                             childVidList = rule.Parent_Non_Parent_VID_s__c.split(',');
                                        }
                                        if(!rule.Child_VID_Check_Include_Uncheck_Exclude__c){// Exclude logic
                                            if(rule.All_3rd_Party_Vendor__c){ 
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', All 3rd Party vendors excluded.';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue;
                                            }
                                            else{
                                                if(childVidList != null && childVidList.size()>0 && (childVidList.contains(ql.Vendor__r.Vendor_ID__c) || (ql.Vendor__r.Parent_Vendor_ID__c != null && childVidList.contains(ql.Vendor__r.Parent_Vendor_ID__c)))){
                                                    isSTPSuccess = false;

                                                    if(childVidList.contains(ql.Vendor__r.Vendor_ID__c))
                                                        errorMessage = 'Rule Name: ' + rule.Name + ', Excluded 3rd Party vendor found which contains Vendor '+ ql.Vendor__r.Vendor_ID__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                    else
                                                        errorMessage = 'Rule Name: ' + rule.Name + ', Excluded 3rd Party parent vendor found which contains Vendor '+ ql.Vendor__r.Parent_Vendor_ID__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';

                                                    exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                    setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                    parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                    continue; 
                                                }
                                            }
                                        }
                                        else{ // include logic
                                           if(!rule.All_3rd_Party_Vendor__c && childVidList != null && childVidList.size() > 0
                                                && ((!childVidList.contains(ql.Vendor__r.Vendor_ID__c) &&
                                                     ( !childVidList.contains(ql.Vendor__r.Parent_Vendor_ID__c))))){
                                                isSTPSuccess = false;

                                                if(!childVidList.contains(ql.Vendor__r.Vendor_ID__c))
                                                    errorMessage = 'Rule Name: ' + rule.Name + ', does not contain following 3rd Party Vendor - '+ ql.Vendor__r.Vendor_ID__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                else
                                                    errorMessage = 'Rule Name: ' + rule.Name + ', does not contain following 3rd Party parent vendor - '+ ql.Vendor__r.Parent_Vendor_ID__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue; 
                                            }
                                        }
                                    }

                                    //Market Type - Full Or Partial Type But not ANY and for WM Or canada account
                                    
                                    if(rule.Market_Type__c != Pricing_Constant_Util.OPTION_ANY){ 
                                        Boolean isOpenMarket = false;                                        
                                        
                                        // WM Vendor
                                        if(STPType == Pricing_Constant_Util.FULL_STP)
                                        {
										// ContractTypeMap !=null && ( !=WM Fracnchise || != Competitor)  = Open Market
                                            if(contractTypeMap.containsKey(ql.SBQQ__RequiredBy__c) 
                                                && contractTypeMap.get(ql.SBQQ__RequiredBy__c) != null 
                                            	&& (!contractTypeMap.get(ql.SBQQ__RequiredBy__c).contains(Pricing_Constant_Util.WM_FRANCHISE)
                                            	|| !contractTypeMap.get(ql.SBQQ__RequiredBy__c).contains(Pricing_Constant_Util.COMPETITOR))
                                             )
                                            {
                                                isOpenMarket = true;
                                            }

                                            // Check for Availabilty field Contract and compare with market type
                                            if(rule.Market_Type__c.contains(Pricing_Constant_Util.OPEN) && !isOpenMarket){
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', Rule Market Type - '+ Pricing_Constant_Util.OPEN + ' || Quote Market Type - ' + contractTypeMap.get(ql.SBQQ__RequiredBy__c) + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';										
                                    			exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue;
                                    		}
                                            else if(rule.Market_Type__c.contains(Pricing_Constant_Util.CLOSED) && isOpenMarket){
                                                
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', Rule Market Type - '+ Pricing_Constant_Util.CLOSED + ' || Quote Market Type - ' + contractTypeMap.get(ql.SBQQ__RequiredBy__c) + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';										
                                    			exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue;
                                            }
                                            
                                        }
                                        //Partial STP
                                        else 
                                        {
                                            if(ql.sCode__c == null)
                                            {
                                                isOpenMarket = true;
                                            }

                                            if(rule.Market_Type__c.contains(Pricing_Constant_Util.OPEN) && !isOpenMarket){
                                                
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', Rule Market Type - '+ Pricing_Constant_Util.OPEN + ' || Quote Market Type - ' + ql.sCode__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                    			exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue;
                                    		}
                                            else if(rule.Market_Type__c.contains(Pricing_Constant_Util.CLOSED) && isOpenMarket){
                                                
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', Rule Market Type - '+ Pricing_Constant_Util.CLOSED + ' || Quote Market Type - ' + ql.sCode__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c, isSTPSuccess);
                                                continue;
                                            }
                                        }
                                    }

                                    //Priority Check - SDT-34216
                                    if(rule.Applicable_Priority__c != null && !rule.Applicable_Priority__c.contains(ql.SBQQ__Quote__r.Priority__c)){
                                        isSTPSuccess = false;
                                        errorMessage = 'Rule Name: ' + rule.Name + ', priority '+  rule.Applicable_Priority__c + ' does not match Quote priority of ' + ql.SBQQ__Quote__r.Priority__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                        exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                        setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                        parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                        continue;
                                    }
                                    
                                    // Customer Check - Start
                                     /*
                                     * Start - SDT-28597
                                     * If Account_Sytem__c is WMNAT then it is USA client
                                     * Logic to check against list of customers which are exceptions i.e, Include/Exclude Check
                                     */
                                    if(ql.Account__r.Parent.Accounting_System__c!=null && ql.Account__r.Parent.Accounting_System__c.contains(WMNAT)){
                                        if(!rule.Customer_Included__c){// Exclude logic
                                            if(rule.Customer_All__c){ 
                                                isSTPSuccess = false;
                                                //errorMessage = 'Rule Name: ' + rule.Name + ', Customers excluded but All US Customer is checked for QuoteLine '+ ql.Name + ' '+ ql.SBQQ__Product__r.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                errorMessage = 'Rule Name: ' + rule.Name + ', All US Customers excluded for QuoteLine '+ ql.Name + ' '+ ql.SBQQ__Product__r.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                continue;
                                            }
                                            else{
                                                //Start - SDT-28598
                                                if(rule.Customer__c!=null && rule.Customer__c.contains(ql.Account__r.Parent.Customer_Code__c)){
                                                //End - SDT-28598
                                                    isSTPSuccess = false;
                                                    errorMessage = 'Rule Name: ' + rule.Name + ', Excluded Customer found which contains account '+ ql.Account__r.Parent.Customer_Code__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                    exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                    setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                    parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                    continue; 
                                                }
                                            }
                                        }
                                        else{ // include logic
                                            
                                            //Start - SDT-28598
                                            if(!rule.Customer_All__c && (rule.Customer__c!=null && !rule.Customer__c.contains(ql.Account__r.Parent.Customer_Code__c)) ){
                                            //End - SDT-28598
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', does not contain following Account - '+ ql.Account__r.Parent.Customer_Code__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                continue; 
                                            }
                                            
                                        }
                                    }
                                    //If Account_Sytem__c is OAKWL then it is Canada client
                                    
                                    if(ql.Account__r.Parent.Accounting_System__c!=null && ql.Account__r.Parent.Accounting_System__c.contains(OAKWL)){
                                        if(!rule.Customer_Included_Canada__c){// Exclude logic
                                            if(rule.Customer_All_Canada__c){ 
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', All Canadian Customers excluded for QuoteLine '+ ql.Name + ' '+ ql.SBQQ__Product__r.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                continue;
                                            }
                                            else{
                                                //Start - SDT-28598
                                                if(rule.Customer_Canada__c!=null && rule.Customer_Canada__c.contains(ql.Account__r.Parent.Customer_Code__c)){
                                                //End - SDT-28598
                                                    isSTPSuccess = false;
                                                    errorMessage = 'Rule Name: ' + rule.Name + ', CANADA :: Excluded Customer found which contains account '+ ql.Account__r.Parent.Customer_Code__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                	exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                    setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                    parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                    continue; 
                                                }
                                            }
                                        }
                                        else{ // include logic
                                            
                                            //Start - SDT-28598
                                            if(!rule.Customer_All_Canada__c && (rule.Customer_Canada__c!=null && !rule.Customer_Canada__c.contains(ql.Account__r.Parent.Customer_Code__c)) ){
                                            //End - SDT-28598
                                                isSTPSuccess = false;
                                                errorMessage = 'Rule Name: ' + rule.Name + ', CANADA :: does not contain following Account - '+ ql.Account__r.Parent.Customer_Code__c + ' for Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                continue; 
                                            }
                                            
                                        }
                                    }
                                    //End - SDT-28597
                                    // Customer Check - End                                    
                                    
                                    /* 
                                     * set isSTPSuccess to false If
                                     * Cost of Haul is greater than 1000 or less than 150
                                     * Price of Haul is not a positive value
                                     * Cost of Devliery/ CSC is not a positive value
                                     * Price of Delivery/ CSC is not a positive value
                                     */ 
                                    //Check for Haul Cost and price
                                    if(ql.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.HAUL_PRODUCT)
                                    {
                                        //Exhibit Cost Check for Canada - Start
                                        /* Story SDT-46922 - point # 2 implementation
                                        * For exhibit canada location Haul Cost/Price threshold will be less than 150$
                                        */
                                        ExhibitPriceServices eps = new ExhibitPriceServices();
                                        isExhibitPricing = eps.getIsExhibitPricing(ql);
                                        exhibitHaulCostMinValue = eps.getExhibitMinThreshould();
                                        exhibitHaulCostMaxValue = eps.getExhibitMaxThreshould();
                                        if(isExhibitPricing)
                                        {
                                            haulCostMaximumValue = exhibitHaulCostMaxValue;
                                                haulCostMinimumValue = exhibitHaulCostMinValue;
                                        }//SDT 46922 end
                                        //SDT-30975 - start - change upper limit of cost
                                        if (ql.SBQQ__UnitCost__c == null || ql.SBQQ__UnitCost__c > haulCostMaximumValue || ql.SBQQ__UnitCost__c < haulCostMinimumValue || ql.SBQQ__ListPrice__c == null || ql.SBQQ__ListPrice__c <= 0){
                                        //SDT-30975 - End
                                            isSTPSuccess = false;
                                            //errorMessage = 'Rule Name: ' + rule.Name + ', '+ ql.SBQQ__Product__r.Name + ' has cost:: ' + ql.SBQQ__UnitCost__c + ' and Price:: ' + ql.SBQQ__ListPrice__c + ' for QuoteLine '+ ql.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                            errorMessage = 'Rule Name: ' + rule.Name + ', '+ ql.SBQQ__Product__r.Name + ' has cost:: ' + ql.SBQQ__UnitCost__c + ' and Price:: ' + ql.SBQQ__ListPrice__c + ' Threshold minimum cost :: '+ haulCostMinimumValue + ', Threshold maximum cost :: '+ haulCostMaximumValue +' for QuoteLine '+ ql.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                            exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                            setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                            parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                            continue;
                                        }
                                    }
                                    //Check for CSC Cost and price along with excemption to bypass the check
                                    else if(ql.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.CSC)
                                    {
                                        
                                        if(!bundleProductMap.containsKey(ql.SBQQ__RequiredBy__c) || (bundleProductMap.get(ql.SBQQ__RequiredBy__c)!=null && !bundleProductMap.get(ql.SBQQ__RequiredBy__c).contains(ql.SBQQ__Product__r.Name)))
                                        //if(STPExemption.size() ==0 || (STPExemption[0].Zero_Cost_Price_Allowed__c != null && !STPExemption[0].Zero_Cost_Price_Allowed__c.contains(ql.SBQQ__Product__r.Name)))
                                        {
                                            if(ql.SBQQ__UnitCost__c == null || ql.SBQQ__UnitCost__c <= 0 || ql.SBQQ__ListPrice__c == null || ql.SBQQ__ListPrice__c <= 0)
                                            {
                                                isSTPSuccess = false;
                                                //errorMessage = 'Rule Name: ' + rule.Name + ', '+ ql.SBQQ__Product__r.Name + ' has cost:: ' + ql.SBQQ__UnitCost__c + ' and Price:: ' + ql.SBQQ__ListPrice__c + ' for QuoteLine '+ ql.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                errorMessage = ql.SBQQ__Product__r.Name + ' has cost:: ' + ql.SBQQ__UnitCost__c + ' and Price:: ' + ql.SBQQ__ListPrice__c + ' for QuoteLine '+ ql.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                                exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                                setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                                parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                                continue;
                                            }
                                        }
                                        
                                    }
                                    //Check for DLV Cost and price along with excemption to bypass the check
                                    else if(ql.SBQQ__Product__r.ProductCode == Pricing_Constant_Util.DLV)
                                    {
                                        if(!bundleProductMap.containsKey(ql.SBQQ__RequiredBy__c) || (bundleProductMap.get(ql.SBQQ__RequiredBy__c)!=null && !bundleProductMap.get(ql.SBQQ__RequiredBy__c).contains(ql.SBQQ__Product__r.Name)))
                                        //if (STPExemption.size() ==0 || ( STPExemption[0].Zero_Cost_Price_Allowed__c!= null && !STPExemption[0].Zero_Cost_Price_Allowed__c.contains(ql.SBQQ__Product__r.Name)))
                                        {
                                        
                                        if(ql.SBQQ__UnitCost__c == null || ql.SBQQ__UnitCost__c <= 0 || ql.SBQQ__ListPrice__c == null || ql.SBQQ__ListPrice__c <= 0)
                                        {
                                            isSTPSuccess = false;
                                            //errorMessage = 'Rule Name:' + rule.Name + ', '+ ql.SBQQ__Product__r.Name + ' has cost:: ' + ql.SBQQ__UnitCost__c + ' and Price:: ' + ql.SBQQ__ListPrice__c + ' for QuoteLine '+ ql.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                            errorMessage = ql.SBQQ__Product__r.Name + ' has cost:: ' + ql.SBQQ__UnitCost__c + ' and Price:: ' + ql.SBQQ__ListPrice__c + ' for QuoteLine '+ ql.Name + ' of Quote ' + ql.SBQQ__Quote__r.Name + '; ';
                                            exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                            setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                            parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                            continue;
                                        }
                                        }
                                    }
                                    
                                    
                                    if(isSTPSuccess){
                                        //If stpSuccess is true means rule and quoteLine criteria matched but rest internal conditions not matching
                                        parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                        break;
                                    }
                                }
                                else{
                                    
                                    errorMessage = 'Rule Name: ' + rule.Name + ', Rule criteria did not match for Quote ' + ql.SBQQ__Quote__r.Name + 
                                        '\r\n Quote Equipment - ' + ql.SBQQ__RequiredBy__r.SBQQ__Product__r.Name + ' || Rule Equipment - ' + rule.Equipment__c +
                                        '\r\n Quote Material - ' + quotLineMaterialMap.get(ql.SBQQ__RequiredBy__c) + ' || Rule Material - ' + rule.Material__c +
                                        '\r\n Quote Duration - ' + ql.Duration__c + ' || Rule Duration - ' + rule.Duration__c +
                                        '\r\n Quote Frequency - ' + quotLineOccuranceTypeMap.get(ql.SBQQ__RequiredBy__c) + ' || Rule Frequency - ' + rule.frequency__c +
                                        '; ';
                                    
                                    exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                                    isSTPSuccess = false;
                                    parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                                    setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                                }
                            }
                        }
                        else{
                            //errorMessage = 'No STP rule Found for Quote ' + ql.SBQQ__Quote__r.Name;
                            errorMessage = 'No STP rule found for Quote '+ ql.SBQQ__Quote__r.Name + ': STP Type ' + STPType + 
							'\r\n Quote Equipment - ' + quoteLineProductMap.values() +
							'\r\n Quote Material - ' + quotLineMaterialMap.values() +
                            '\r\n Quote Duration - ' + duration.values() +
                            '\r\n Quote Duration - ' + quotLineOccuranceTypeMap.values();
                            exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + ql.SBQQ__Quote__r.Name;
                            setErrorMessageForQuote(ql.SBQQ__Quote__r.Name, errorMessage);
                            isSTPSuccess = false;
                            parentIDMap.put(ql.SBQQ__RequiredBy__c,isSTPSuccess);
                        }
                    }
                    else{
                        break;
                    }
                    
                }
                
            }
        }else{
            errorMessage = 'Record Type is Not a New Service Case';
            setErrorMessageForQuote(quoteName, errorMessage);
            isSTPSuccess = false;
        }

        for(boolean stp : parentIDMap.Values() ){
            if(stp == false){
                isSTPSuccess = false;
                if(quoteErrorMessageMap.size()>0){
                    for(String errVal : quoteErrorMessageMap.get(quoteName)){
                        exceptionLog.Exception_Details__c += errVal;
                    }
                }
                break;
            }
            else{
                isSTPSuccess = true;
            }
            
        }
        
        /* If isSTPSuccess is true then call updateQuoteStatus method to Update Quote status
         * If isSTPSuccess is false then log the reason by calling UTIL_LoggingService.logExceptionObject
         */ 
        if(isSTPSuccess){
            boolean result = updateQuoteStatus(quoteId,Pricing_Constant_Util.QUOTE_PRICE_CONFIGURED,quoteName, STPType);
            if(!result){
                isSTPSuccess = false;
            }
            system.debug('Result Of Final STP :: '+ isSTPSuccess);
        }else{
            logObj = createExceptionLogObj(exceptionLog);
            logObjList.add(logObj);
            UTIL_LoggingService.logExceptionObject(logObjList);
            
        }
        return isSTPSuccess;
    }    
    
    /*
     * @Method Name    : updateQuoteStatus
     * @author         : Jatan Sharma
     * @description    : Update Quote status if STP process is success. 
     * Also if any error occurs while updating status then log the error for audit purpose.
     * @param          : QuoteId is unique Id of quote
     * @param		   : status is 'Price Configured' picked from QUOTE_PRICE_CONFIGURED of Pricing_Constant_Util
     * @return         : a boolean true or false to signify whether status of quote has been updated or not
	 */
    public static boolean updateQuoteStatus(id quoteId, string status, String quoteName, String STPType){
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        SBQQ__Quote__c quotetoUpdate =  new SBQQ__Quote__c();
        quotetoUpdate.id = quoteId;
        quotetoUpdate.SBQQ__Status__c = status;
        quotetoUpdate.STP__c = true;
        if(Pricing_Constant_Util.PARTIAL_STP.equalsIgnoreCase(STPType)){
        	quotetoUpdate.STP_Success_Report__c = Pricing_Constant_Util.PARTIAL_STP;
        }else{
            quotetoUpdate.STP_Success_Report__c = Pricing_Constant_Util.FULL_STP;
        }
        quoteList.add(quotetoUpdate);
        try{
            SBQQ.TriggerControl.disable();
            Database.SaveResult [] updateResult = Database.update(quoteList, false);
            for (Database.SaveResult result : updateResult)
            {
                if (result.isSuccess())
                {
                    return true;
                }
                else{
                    for(Database.Error err : result.getErrors()) {
                        
                        errorMessage = err.getMessage() + ' for Quote ' + quoteName;
                        exceptionLog.Method_Name__c = 'updateQuoteStatus';
                        exceptionLog.Exception_Details__c = errorMessage;
                        exceptionLog.Application_Name__c = quoteIDStr + quoteId + quoteNameStr + quoteName;
                            
                    }
                    
                }
            }
            // Log Error message for Audit purpose in ExceptionLog__c if any issue occurs while saving the status
            logObj = createExceptionLogObj(exceptionLog);
            logObjList.add(logObj);
            UTIL_LoggingService.logExceptionObject(logObjList);
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), Pricing_Constant_Util.APPLICATION_NAME + 'QuoteID: ' + quoteId + ' QuoteName '+ quoteName, LoggingLevel.ERROR);
	        }
            finally{
                SBQQ.TriggerControl.enable();
            }
        return false;
        
    }
    /*
     * @Method Name    : createExceptionLogObj
     * @author         : Digdershika Ojha
     * @story		   : SDT-26174
     * @description    : creates an object of ExceptionLog__c with details specific to functionality and STPRuleExecutionClass with no severity
     * @param		   : exceptionLog of type ExceptionLog__c
	 * @return         : ExceptionLog__c
     */
    
    public static ExceptionLog__c createExceptionLogObj(ExceptionLog__c exceptionLog){
        ExceptionLog__c exceptionLogObj = new ExceptionLog__c();
		exceptionLogObj.Org_Id__c = UserInfo.getOrganizationId();
		exceptionLogObj.Exception_Code__c = '';
		exceptionLogObj.Exception_Description__c =  Pricing_Constant_Util.STP_EXCEPTION_DESCRIPTION;
		exceptionLogObj.Exception_Details__c = exceptionLog.Exception_Details__c; // holds errorMessage
		exceptionLogObj.Log_Time__c = System.now();
		exceptionLogObj.Username__c = UserInfo.getUserId();
		exceptionLogObj.Class_Name__C = Pricing_Constant_Util.STP_RULE_CLASS_NAME;
		exceptionLogObj.Method_Name__c = exceptionLog.Method_Name__c;
		//exceptionLogObj.Exception_Type__c = UTIL_ErrorConstants.EXCEPTION_TYPE;
        exceptionLogObj.Exception_Type__c = exceptionLog.Exception_Type__c + Pricing_Constant_Util.FAILED_EXCEPTION;
        if(null != exceptionLog.Application_Name__c && !String.isBlank(exceptionLog.Application_Name__c)){
            exceptionLogObj.Application_Name__c = Pricing_Constant_Util.APPLICATION_NAME + ' ' + exceptionLog.Application_Name__c; //UTIL_ErrorConstants.APPLICATION_NAME + quoteId + ' QuoteName '+ quoteName;
        }else {
            exceptionLogObj.Application_Name__c = Pricing_Constant_Util.APPLICATION_NAME;
        }
        return exceptionLogObj;
    }
    /*
     * @Method Name    : setErrorMessageForQuote
     * @description    : set Error Messages for Quote in a map.
     * @param          : QuoteName is String name of quote
     * @param		   : errorMessage is string to set as message
     * @return         : void
	 */
    public static void setErrorMessageForQuote(String quoteName, String errorMessage){
        if(quoteErrorMessageMap.containsKey(quoteName)){
            List<String> errorMsgList = quoteErrorMessageMap.get(quoteName);
            errorMsgList.add(errorMessage);
            quoteErrorMessageMap.put(quoteName, errorMsgList);
        }else{
            quoteErrorMessageMap.put(quoteName, new List<String>{errorMessage});
        }
    }
    
    public static Map<Id,String> getExemptionProduct(List<STP_Criteria__c> STPExemption, List<SBQQ__QuoteLine__c> qlines, Map<Id, string> quoteLineProductMap, String STPType){
        Set<String> matchedConfigValues = new Set<String>();
        for(SBQQ__QuoteLine__c ql : qlines )
        {
            //Loop to get parent from bundle
            if(ql.SBQQ__RequiredBy__c == null )
            {
                Boolean isWmVendor = false;
                //Boolean isOpenMarket = false;
                String marketType = Pricing_Constant_Util.CLOSED;
                if(STPType == Pricing_Constant_Util.FULL_STP){
                    //Full STP
                    if(ql.Pricing_Request__r!=null && ql.Pricing_Request__r.zone_Type__c!=null 
                      && ql.Pricing_Request__r.zone_Type__c != Pricing_Constant_Util.WM_FRANCHISE
                       && ql.Pricing_Request__r.zone_Type__c != Pricing_Constant_Util.COMPETITOR){
                           //isOpenMarket = true;
                          //System.debug('Full STP Open Market'); 
                           marketType = Pricing_Constant_Util.OPEN;
                       }
                }else{
                    //Partial STP
                    if(ql.sCode__c == null)
                    {
                        //isOpenMarket = true;
                        //System.debug('Partial STP Open Market');
                        marketType = Pricing_Constant_Util.OPEN;
                    }
                }
                //System.debug('quoteLineProductMap.get(ql.Id) '+ quoteLineProductMap.get(ql.Id) + ' ql.Vendor__r.Parent_Vendor_ID__c '+ ql.Vendor__r.Parent_Vendor_ID__c);
                
                if(ql.Vendor__c!=null && ql.Vendor__r.Parent_Vendor_ID__c != null && 
                           (ql.Vendor__r.Parent_Vendor_ID__c == Pricing_Constant_Util.VENDOR_WM 
                            || ql.Vendor__r.Parent_Vendor_ID__c == Pricing_Constant_Util.VENDOR_CANADA)){
                        isWmVendor = true;
                      //  System.debug('parent vendor');
                   }else if(ql.Vendor__c!=null){
                        isWmVendor = false;
                      // System.debug('child vendor');
                  }
                //Execute all STP excemptionRules
                for( STP_Criteria__c excemptionRule : STPExemption)
                {
                    
                    if(quoteLineProductMap!=null && (quoteLineProductMap.get(ql.Id) == excemptionRule.Equipment__c)
                      && ((isWmVendor && (excemptionRule.Eligible_Vendor__c == Pricing_Constant_Util.WM_VENDOR)) 
                          || (!isWmVendor && (excemptionRule.Eligible_Vendor__c == Pricing_Constant_Util.THRID_PARTY))
                         )
                       && (marketType == excemptionRule.Market_Type__c)
                      ){
                        bundleProductMap.put(ql.Id,excemptionRule.Zero_Cost_Price_Allowed__c);
                            
                    }
                }
                
            }
        }
        return bundleProductMap;
    }
   

}
