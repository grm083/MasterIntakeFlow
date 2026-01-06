/*
  * @Name          PricingChangeRequest
  * @Author        TCS - Ali
  * @Date          04/07/2023
  * @Description   This class is created to handled DML function of Pricing Change Request record.
  */
  public with sharing class PricingChangeRequest {

    /*@methodName- getAssteDetails
    *@description- Method to get the Asste Record by Baseline Id  
    *@param- Id : baselineId
    *@return- Asset Record
    */  
    @AuraEnabled(cacheable=true)
    public static Asset getAssteDetails(decimal baselineId){
        Asset assetRecord = new Asset();
        List<Asset> assetlist = new List<Asset>();
        Set<string> materialTypeList = new Set<string>{'Trash','Cardboard','Single Stream Recycling','Organic Waste'};
        Set<string> equipmentTypeList = new Set<string>{'Dumpster','Toter','Dumpster - Front Load', 'Dumpster - Rear Load'};
        //and Vendor_ID__c = '8'
        try{
            assetlist = [Select Id, AccountId, Account.ParentId, Account.Parent.IsPricingEligible__c, ParentId, Product2Id, ProductCode, ProductFamily, Name, Material_Type__c,  Service_Type__c, Duration__c, Occurrence_Type__c, Schedule__c, Weekly_Frequency__c, Schedule_Type__c, Quantity__c, Cost__c, Price__c, CurrencyIsoCode, Vendor_ID__c, Supplier__c, Supplier__r.Name, Supplier__r.Parent_Vendor_ID__c, MAS_Company_Account_Number__c, MAS_Company_Code__c, MAS_Customer_Unique_Id__c, MAS_Library__c, Account.Name, Account.Phone, Account.Primary_Segment__c, Account.tz__Local_Time__c, Account.Status__c, SBID_text_c__c, SCOD_text__c, Equipment_Type__c, Equipment_Size__c, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry, Account.Customer_Location_Code__c, Sensitivity_Code__c
            FROM Asset 
            WHERE Acorn_SBID__c = :baselineId AND ProductFamily = 'Commercial' AND Is_Active__c = true AND Location__r.Status__c = 'Active' 
            AND Supplier__r.Parent_Vendor_ID__c	 = '8' //Stand for WM Vendor
            AND Sensitivity_Code__c = null //Stand for Open Market
            AND Duration__c = 'Permanent'
            AND Occurrence_Type__c = 'Scheduled'
            AND Equipment_Type__c IN:equipmentTypeList 
            AND Material_Type__c IN:materialTypeList];
            
            if(assetlist.size() > 0)
            {
                assetRecord = assetlist[0];
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_CHANGE_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return assetRecord;
    }
    
    /*@methodName- getPricingChangeDetail
    *@description- Method to invoke Pricing API   
    *@param- Id :recordId
    *@return- String Pricing JSON
    */  
    @AuraEnabled
    public static List<String> getPricingChangeDetail(Id recordId, Boolean assetCall){
        //JSONParser objJson = JSON.createParser(inputFields);
        System.debug('In getPricingChangeDetail Method' + recordId);
        Integration_Request_URLs__mdt urlMD;
        String endpoint = '';
        string result = '';
        List<String> pricing_Result = new List<String>();
        try{
            Pricing_Request__c priceReq = [SELECT Id, Account__c, Account__r.Customer_Code__c, Location__c, Location__r.Location_Code__c, Container_Type__c, Container_Size__c, Material_Code__c
            , Quantity__c, Hauls_Month__c, Industry_Classification__c, Customer_Owned__c, Service_Type__c, Name, APIRequestOutput__c, Service_Street_Address__c, Service_City__c, Service_State__c
            , Service_Country__c, Service_Postal_Code__c, Case__c, Frequency_Type__c, Frequency_Count__c, Line_of_Business__c, Quote_Line_Bundle__c, Project_Request__c, Project_Code__c
            , Project_Code__r.Name, Account__r.IsPricingEligible__c, Account__r.Primary_Segment__c, Schedule_or_On_Call__c, Service_Baseline_ID__c, IsPriceChangeRequest__c
            FROM Pricing_Request__c 
            WHERE id = :recordId];
            // System.debug('In Change Price Record: ' + priceReq);
            // System.debug(priceReq.Service_Baseline_ID__c);
            //System.debug('priceReq.Location__r.Location_Code__c:' + priceReq.Location__r.Location_Code__c);
            
        
            // String naicCode = priceReq.Industry_Classification__c != null ? priceReq.Industry_Classification__c.substring(0,2) : '';
            String LOB_Param, Frequency_Type, Frequency_Count, Service_Type;
            Service_Type =  priceReq.Service_Type__c == 'SEAS' ? 'TEMP' : priceReq.Service_Type__c;

            String Common_Param = Constant_Util.PR_EQUIPMENT_SIZE_CODE + priceReq.Container_Size__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_QUANTITY + priceReq.Quantity__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_EQUIPMENT_AVAILABILITY + Service_Type + Constant_Util.AMPERSAND +
            Constant_Util.IS_PROJECT + priceReq.Project_Request__c + Constant_Util.AMPERSAND +
            Constant_Util.PROJECT_CATEFORY + priceReq.Project_Code__r.Name + Constant_Util.AMPERSAND +
            Constant_Util.PR_ISPRICING_ELEGIBLE + priceReq.Account__r.IsPricingEligible__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_PREMARYSEGMENT + priceReq.Account__r.Primary_Segment__c + Constant_Util.AMPERSAND;
            //Changes for SDT-16960
            if(priceReq.Line_of_Business__c.equalsIgnoreCase(Constant_Util.COMMERCIAL) ){

                if(priceReq.Schedule_or_On_Call__c.equalsIgnoreCase(Constant_Util.SCHEDULED))
                {
                    Frequency_Type = priceReq.Frequency_Type__c.equalsIgnoreCase('Monthly')?'M':'W';
                    Frequency_Count = priceReq.Frequency_Type__c.equalsIgnoreCase('Monthly')?'1': 
                                        (priceReq.Frequency_Count__c.equalsIgnoreCase('0.5')? '.5':priceReq.Frequency_Count__c);
                }
                else
                {
                    Frequency_Type = 'M';
                    Frequency_Count = '1';
                }
                // LOB_Param = Constant_Util.PR_OCCURENCE_CODE + Frequency_Type + Constant_Util.AMPERSAND +
                // Constant_Util.PR_OCCURENCE_COUNT + Frequency_Count;
            }
            //End Changes
            // System.debug('In Common Param: ' + Common_Param);
  
            urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingCommercialService' LIMIT 1];
            LOB_Param = Constant_Util.PR_OCCURENCE_CODE + Frequency_Type + Constant_Util.AMPERSAND +
            Constant_Util.PR_OCCURENCE_COUNT + Frequency_Count;

            // System.debug('In LOB Param: ' + LOB_Param);
            // System.debug('In Url Record: ' + urlMD);

            endpoint = urlMD.End_Point__c;
            endpoint = endpoint.replace(Constant_Util.PR_SERVICE_BASELINE_ID, string.valueof(priceReq.Service_Baseline_ID__c));
            endpoint = endpoint + '?' + 
            Common_Param +
            LOB_Param;
            //endpoint = endpoint + '?locationCode=HMD002718&containerCode=CMP&containerSizeCode=YRDS-20&materialTypeCode=T&equipmentAvailabilityTypeCode=PERM';
            
            System.debug(endpoint);	
            Http httpObj = new Http();
            HttpRequest req = new HttpRequest();
            
            // endpoint = EncodingUtil.urlEncode(endpoint, 'UTF-8');
            endpoint = endpoint.replace(' ', '%20');
			System.debug('@@@@@@ URL' + endpoint);
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Content-Type',urlMD.Content_Type__c);
            req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
            req.setHeader('X-PARTNER-KEY',urlMD.Client_Key__c);
            req.setHeader('X-Request-Id',priceReq.Name);
            req.setHeader('Authorization',urlMD.Client_Token__c);
            req.setTimeout(urlMD.Timeout__c.intValue());
            String RequestBody;
            
            // RedNoteController.RedNotesResponse jsonResp;
            try {
                httpresponse res = httpObj.send(req);

                result = res.getBody();   
                
            } catch (Exception e) { 
                result = e.getMessage();
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_CHANGE_REQUEST_APEX,LoggingLevel.ERROR);
            } 
            
            priceReq.APIRequestOutput__c = result;
            //System.debug('@@@@@@@@~ API Output: '+ result);

            pricing_Result.add(result);

            if(priceReq.Line_of_Business__c.equalsIgnoreCase(Constant_Util.COMMERCIAL) ){
                pricing_Result.add(Constant_Util.COMMERCIAL);
            }
            else {
                pricing_Result.add(Constant_Util.ROLLOFF);
            }
            //System.debug('@@@@@@@@~ assetCall: '+ assetCall);

            //SDT-27722
            if(assetCall){
                //RecurrsiveTriggerHandler.invokeValidationforPricing = true;
                System.debug('@@@@@@@@~ PricingChangeRequest Call Parse Function');
                //ProcessQLIPricingRequest.ParsePricingRequestJSON_Test(priceReq);
                PricingRequestHelper.assetPricingChangeResponse.put(recordId, result);
            }
            else {
                PricingRequest.saveReportingFields(priceReq, result);
                Update priceReq;
            }
        
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        return pricing_Result;
    }    
    
    public static Map<Id, decimal> validateQuoteForPriceChange(Id quoteID)
    {
        Map<Id, decimal> quoteBaselineList = new Map<Id, decimal>();
        if(quoteID != null)
        {
            List<SBQQ__QuoteLine__c> quotelineList = [SELECT Id, Name, ServiceBaselineId__c, SBQQ__ProductCode__c, SBQQ__Product__r.Name, SBQQ__RequiredBy__c, SBQQ__Product__r.Family,
            toLabel(Equipment_Size__c), Duration__c, Schedule_Frequency__c, Frequency_Interval__c, Final_Frequency__c, SBQQ__Quantity__c, Pricing_Frequency_Count__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c =: quoteID ]; //AND SBQQ__Product__r.Family = 'Commercial' AND SBQQ__Product__r.Name = 'Pickup'

            
            if(quotelineList != null && quotelineList.size() > 0)
            {
                // system.debug('----->quotelineList' + quotelineList);
                for(SBQQ__QuoteLine__c ql : quotelineList)
                {
                    if(ql.SBQQ__Product__r.Family == Constant_Util.COMMERCIAL && ql.SBQQ__Product__r.Name == Constant_Util.PR_PICKUP)
                    {
                        // system.debug('----->IN IF Commercial' + ql.ServiceBaselineId__c);
                        Asset assetRecord = getAssteDetails(ql.ServiceBaselineId__c);
                        // system.debug('----->IN IF assetRecord' + assetRecord);

                        if(assetRecord != null && assetRecord.Id != null)
                        {
                            //Changes for SDT-30984
                            If(checkPriceRequestChange(assetRecord, ql))
                            {
                                // system.debug('-----> AM Validation Process Success');
                                quoteBaselineList.put(ql.SBQQ__RequiredBy__c, ql.ServiceBaselineId__c);
                            }
                            else
                            {
                                // system.debug('-----> Price Request is Identical');
                                quoteBaselineList.put(ql.SBQQ__RequiredBy__c, -1);
                            }
                        }
                        else
                        {
                            // system.debug('----->IN IF For Commercial' + ql.Id);
                            quoteBaselineList.put(ql.SBQQ__RequiredBy__c, 0);
                        }
                    }
                    else if(ql.SBQQ__Product__r.Name != 'Dumpster' && ql.SBQQ__Product__r.Name != 'Toter' && ql.SBQQ__RequiredBy__c == null)
                    {
                        //For Rolloff Asset
                        // system.debug('----->IN IF For RollOff' + ql.Id);
                        quoteBaselineList.put(ql.Id, 0);
                    }
                }
            }
        }

        return quoteBaselineList;
    }

    /*
    Owner: TCS
    Developer: Aliasgher Kotawala
    Description: To check asset and quoteline record are identical or not
    Check: Size / Quantity / Frequency Type / Frequency Count / Service Type
    */
    @AuraEnabled
    public static boolean checkPriceRequestChange(Asset assetRecord, SBQQ__QuoteLine__c quotelineRecord)
    {
        Boolean isRequestChange = false;
        String asset_Schedule = assetRecord.Schedule__c.substring(0,1);
        String asset_Converted_Schedule = asset_Schedule == 'E' ? 'W' : asset_Schedule;
        if(assetRecord.Quantity__c != quotelineRecord.SBQQ__Quantity__c)
        {
            // System.debug('@@@@@@@@~ Quantity is not Match');
            isRequestChange = true;
        }        
        else if(!assetRecord.Duration__c.containsIgnoreCase(quotelineRecord.Duration__c))
        {
            // System.debug('@@@@@@@@~ ServiceType/Duration is not Match');
            isRequestChange = true;
        }
        else if(assetRecord.Equipment_Size__c != quotelineRecord.Equipment_Size__c)
        {
            // System.debug('@@@@@@@@~ Equipment Size is not Match');
            isRequestChange = true;
        }
        else if(asset_Converted_Schedule != quotelineRecord.Schedule_Frequency__c)
        {
            // System.debug('@@@@@@@@~ Schedule Frequency is not Match');
            isRequestChange = true;
        }        
        else if(asset_Schedule == 'W' && assetRecord.Weekly_Frequency__c != String.valueof(quotelineRecord.Final_Frequency__c))
        {
            // System.debug('@@@@@@@@~ Weekly Frequency Count is not Match');
            isRequestChange = true;
        }
        else if(asset_Schedule == 'M' && quotelineRecord.Final_Frequency__c != 1)
        {
            // System.debug('@@@@@@@@~ Monthly Frequency Count is not Match');
            isRequestChange = true;
        }
        else if(asset_Schedule == 'E' && quotelineRecord.Pricing_Frequency_Count__c != 0.5)
        {
            // System.debug('@@@@@@@@~ EOW Frequency Count is not Match');
            isRequestChange = true;
        }
        
        return isRequestChange;
    }
}