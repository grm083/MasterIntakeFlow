public class PricingRequestAPIIntegration {

    /*@methodName- getPricingDetail
    *@description- Method to invoke Pricing API   
    *@param- Id :recordId
    *@return- String Pricing JSON
    */  
    @AuraEnabled
    public static List<String> getPricingDetail(Id recordId, Boolean assetCall){
        //JSONParser objJson = JSON.createParser(inputFields);
        Integration_Request_URLs__mdt urlMD;
        String endpoint = '';
        string result = '';
        string PriceQuoteIdentifier;
        APICallUtility apiObj = new APICallUtility();
        List<String> pricing_Result = new List<String>();
        Set<Id> pricingRequestId = new Set<Id>();
        Pricing_Request__c priceReq;
        try{
            pricingRequestId.add(recordId);

            List<Pricing_Request__c> priceReqLst = PricingRequestSelector.getPricingRequestListById(pricingRequestId);

            if(priceReqLst != null && priceReqLst.size() > 0)
            {
                priceReq = priceReqLst[0];
            }
            //System.debug('priceReq.Location__r.Location_Code__c:' + priceReq.Location__r.Location_Code__c);
            PriceQuoteIdentifier = priceReq.Quote__r.SBQQ__Opportunity2__r.Case__r.Price_Quote_Identifier__c;
            //Changes by jatan 
            if(PriceQuoteIdentifier != null && priceReq.Quote__r.Quote_Only__c)
            {
                //system.debug('PriceQuoteIdentifier ' + PriceQuoteIdentifier);
                urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PriceMV_QuoteIdentifier' LIMIT 1];
                endpoint = urlMD.End_Point__c;
                endpoint = endpoint.replace('{PriceQuoteIdentifier}', PriceQuoteIdentifier); 
            }
            else{
        
                String naicCode = priceReq.Industry_Classification__c != null ? priceReq.Industry_Classification__c.substring(0,2) : '';
                String LOB_Param, Frequency_Type, Frequency_Count, Service_Type;
                Service_Type =  priceReq.Service_Type__c == 'SEAS' ? 'TEMP' : priceReq.Service_Type__c;

                String Common_Param = Pricing_Constant_Util.PR_EQUIPMENT_CODE + priceReq.Container_Type__c + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PR_EQUIPMENT_SIZE_CODE + priceReq.Container_Size__c + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PR_MATERIAL_CODE + priceReq.Material_Code__c.replace(Pricing_Constant_Util.AMPERSAND,'%26') + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PR_QUANTITY + priceReq.Quantity__c + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PR_NAIC_CODE + naicCode + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PR_IS_CLIENT_OWNED + priceReq.Customer_Owned__c + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PR_EQUIPMENT_AVAILABILITY + Service_Type + Pricing_Constant_Util.AMPERSAND +
                // Changes for Exhibit Pricing Story- SDT-20401
                Pricing_Constant_Util.IS_PROJECT + priceReq.Project_Request__c + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PROJECT_CATEFORY + priceReq.Project_Code__r.Name + Pricing_Constant_Util.AMPERSAND +
                // Changes for Exhibit Pricing Story- SDT-24009
                Pricing_Constant_Util.PR_ISPRICING_ELEGIBLE + priceReq.Account__r.IsPricingEligible__c + Pricing_Constant_Util.AMPERSAND +
                Pricing_Constant_Util.PR_PREMARYSEGMENT + priceReq.Account__r.Primary_Segment__c + Pricing_Constant_Util.AMPERSAND;
                //Changes for SDT-16960
                if(priceReq.Line_of_Business__c.equalsIgnoreCase(Pricing_Constant_Util.COMMERCIAL) ){

                    if(priceReq.Schedule_or_On_Call__c.equalsIgnoreCase(Pricing_Constant_Util.SCHEDULED))
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
                    // LOB_Param = Pricing_Constant_Util.PR_OCCURENCE_CODE + Frequency_Type + Pricing_Constant_Util.AMPERSAND +
                    // Pricing_Constant_Util.PR_OCCURENCE_COUNT + Frequency_Count;
                }
                //End Changes
                
                if(priceReq.Account__c != null && priceReq.Location__c == null){
                    if(priceReq.Line_of_Business__c.equalsIgnoreCase(Pricing_Constant_Util.ROLLOFF) ){
                        urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingCustomerRollOff' LIMIT 1];
                        LOB_Param = Pricing_Constant_Util.PR_HAULS_PER_MONTH + priceReq.Hauls_Month__c;
                    }
                    else{
                        urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingCustomerCommercial' LIMIT 1];
                        LOB_Param = Pricing_Constant_Util.PR_OCCURENCE_CODE + Frequency_Type + Pricing_Constant_Util.AMPERSAND +
                        Pricing_Constant_Util.PR_OCCURENCE_COUNT + Frequency_Count;
                    }

                    endpoint = urlMD.End_Point__c;
                    endpoint = endpoint.replace(Pricing_Constant_Util.PR_CUSTOMER_CODE, priceReq.Account__r.Customer_Code__c);
                    endpoint = endpoint + '?' + 
                    Pricing_Constant_Util.PR_ADDRESS1 + priceReq.Service_Street_Address__c + Pricing_Constant_Util.AMPERSAND +
                    Pricing_Constant_Util.PR_CITY + priceReq.Service_City__c + Pricing_Constant_Util.AMPERSAND +
                    Pricing_Constant_Util.PR_STATE + priceReq.Service_State__c + Pricing_Constant_Util.AMPERSAND +
                    Pricing_Constant_Util.PR_ZIPCODE + priceReq.Service_Postal_Code__c + Pricing_Constant_Util.AMPERSAND +
                    Pricing_Constant_Util.PR_COUNTRY + priceReq.Service_Country__c + Pricing_Constant_Util.AMPERSAND +
                    Common_Param +
                    LOB_Param;
                }
                else {
                    if(priceReq.Line_of_Business__c.equalsIgnoreCase(Pricing_Constant_Util.ROLLOFF) ){
                        urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingLocation_RollOff' LIMIT 1];
                        LOB_Param = Pricing_Constant_Util.PR_HAULS_PER_MONTH + priceReq.Hauls_Month__c;
                    }
                    else{
                        urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingLocation_Commercial' LIMIT 1];
                        LOB_Param = Pricing_Constant_Util.PR_OCCURENCE_CODE + Frequency_Type + Pricing_Constant_Util.AMPERSAND +
                        Pricing_Constant_Util.PR_OCCURENCE_COUNT + Frequency_Count;
                    }
                    endpoint = urlMD.End_Point__c;
                    endpoint = endpoint.replace(Pricing_Constant_Util.PR_LOCATION_CODE, priceReq.Location__r.Location_Code__c);
                    endpoint = endpoint + '?' + 
                    Common_Param +
                    LOB_Param;
                }
            }
            //endpoint = endpoint + '?locationCode=HMD002718&containerCode=CMP&containerSizeCode=YRDS-20&materialTypeCode=T&equipmentAvailabilityTypeCode=PERM';
            
            //Calling API 
            endpoint = endpoint.replace(' ', '%20');
            //System.debug(endpoint);	

            try {
                HttpResponse responseOBJ = apiObj.authenticateAndResponseGET(endpoint, urlMD, IntegrationHandlerUtil.getLoggedInUserAcornId(), priceReq.Name);
                //System.debug('*** Result' + responseOBJ.getBody());
                
                result = responseOBJ.getBody();
            } catch (Exception e) { 
                result = e.getMessage();
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
            }            
            //End Calling API
            
            //System.debug('@@@@@@@@~ API Output: '+ result);
            priceReq.APIRequestOutput__c = result;
            //added by av4 as part of SDT-20689
            // priceReq.Is_Multi_Vendor__c = true;

            pricing_Result.add(result);

           if(priceReq.Line_of_Business__c.equalsIgnoreCase(Pricing_Constant_Util.COMMERCIAL) ){
                pricing_Result.add(Pricing_Constant_Util.COMMERCIAL);
            }
            else {
                pricing_Result.add(Pricing_Constant_Util.ROLLOFF);
            }
            //System.debug('@@@@@@@@~ assetCall: '+ assetCall);

            //System.debug('@@@@@@@@~ assetCall' + assetCall);
            if(assetCall){
                //RecurrsiveTriggerHandler.invokeValidationforPricing = true;
                //System.debug('@@@@@@@@~ PricingRequest Call Parse Function');
                //ProcessQLIPricingRequest.ParsePricingRequestJSON_Test(priceReq);
                PricingRequestHelper.assetPricingResponse.put(recordId, result);
            }
            else {
                savePricingData(priceReq, result);
                Update priceReq;
            }
        
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        //System.debug('@@@@@@@@ Final Output: '+ pricing_Result);
        return pricing_Result;
    }

    public static void savePricingData(Pricing_Request__c priceReq, String APIResponse)
    {        
        PricingRequestFieldsMetadata priceJSON = new PricingRequestFieldsMetadata();
        priceReq.put('Is_Multi_Vendor__c',  true);
        
        try{
            priceJSON = PricingRequestFieldsMetadata.parse(APIResponse);           

            if(priceJSON.data != null)
            {
                priceReq.put('isAPIResult__c',  true);
                priceReq.put('QuoteID__c',  priceJSON.data.priceQuoteIdentifier);
                priceReq.put('CurrencyIsoCode',  priceJSON.data.currencyCode);
                priceReq.put('Customer_Code__c',  priceJSON.data.customerCode);
            }
            else {
                priceReq.put('isAPIResult__c',  false);
            }
        }
        catch(Exception ex)
        {
            priceReq.put('isAPIResult__c',  false);
        }
    }
}