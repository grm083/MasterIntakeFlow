/*
  * @Name          PricingRequest
  * @Author        WM - Ali
  * @Date          07/28/2020
  * @Description   This class is created to handled DML function of Pricing Request record.
  */
  public with sharing class PricingRequest {

    /*@methodName- getCaseDetails
    *@description- Method to query the Case Record 
    *@param- Id :CaseId
    *@return- Case Record
    */  
    @AuraEnabled(cacheable=true)
    public static Case getCaseDetails(Id caseId){
        Case caseRecord = new Case();
        List<Case> caselist = new List<Case>();
        try{
            caselist = [SELECT Id, CaseNumber, Case_Record_Type__c, Case_Type__c, Case_Sub_Type__c,  Status__c, Location__r.ParentId, Location__c, Location_Code__c, Location__r.ShippingStreet, Location__r.ShippingCity, Location__r.ShippingState, Location__r.ShippingCountry, Location__r.ShippingPostalCode, Service_Occurrence_Type_Code__c,  Equipment_Type_Code__c, Equipment_Size_Code__c, Material_Type__c, SalesMeet_Quantity__c, Account.NAICS_Code__c, Tech_Asset_ProductFamily__c, LOB__c, Location__r.Parent.IsPricingEligible__c, Event_Recurrence_Interval__c, Event_Recurrence_Type_Code__c, Frequency__c, Acorn_Issue_Id__c, Tracking_Number__c FROM Case WHERE Id = :caseId and Case_Record_Type__c = 'New Service Case' and Status__c = 'Open'];
            if(caselist.size() > 0)
            {
                caseRecord =caselist[0];
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return caseRecord;
    }

    /*@methodName- getCaseDetails by case Id
    *@description- Method to query the Case Record 
    *@param- Id :CaseId
    *@return- Case Record
    */  
    @AuraEnabled(cacheable=true)
    public static Case getCaseDetailsById(Id caseId){
        Case caseRecord = new Case();
        List<Case> caselist = new List<Case>();
        try{
            caselist = [SELECT Id, CaseNumber, Case_Record_Type__c, Case_Type__c, Case_Sub_Type__c,  Status__c, Location__r.ParentId, Location__c, Location_Code__c, Location__r.ShippingStreet, Location__r.ShippingCity, Location__r.ShippingState, Location__r.ShippingCountry, Location__r.ShippingPostalCode, Service_Occurrence_Type_Code__c,  Equipment_Type_Code__c, Equipment_Size_Code__c, Material_Type__c, SalesMeet_Quantity__c, Account.NAICS_Code__c, Tech_Asset_ProductFamily__c, LOB__c, Location__r.Parent.IsPricingEligible__c, Event_Recurrence_Interval__c, Event_Recurrence_Type_Code__c, Frequency__c, Acorn_Issue_Id__c, Tracking_Number__c FROM Case WHERE Id = :caseId and Case_Record_Type__c = 'New Service Case'];
            if(caselist.size() > 0)
            {
                caseRecord =caselist[0];
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return caseRecord;
    }

    /*@methodName- getCaseDetails
    *@description- Method to query the Account address record 
    *@param- Id :accountId
    *@return- Account Record
    */  
    @AuraEnabled(cacheable=true)
    public static Account getAccountAddress(Id accountId){
        Account accRecord;
        try{
            accRecord = [SELECT Id, Name,ShippingStreet,ShippingCity,ShippingState,ShippingCountry,ShippingPostalCode, ParentId FROM Account WHERE id = :accountId];
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return accRecord;
    }

    /*@methodName- getNAICSCode
    *@description- Method to query the NAIC code FROM account 
    *@param- Id :accountId
    *@return- String: naicsValue
    */  
    @AuraEnabled(cacheable=true)
    public static String getNAICSCode(Id accountId){
        String naicsValue;
        try{
            Account accRecord = [SELECT id,NAICS_Code__c, IsPricingEligible__c FROM Account WHERE id = :accountId];
            if(accRecord != null && accRecord.NAICS_Code__c != null){ 
                String accNAICS = accRecord.NAICS_Code__c.substring(0,2);

                if(accNAICS.equalsIgnoreCase('31') || accNAICS.equalsIgnoreCase('32') || accNAICS.equalsIgnoreCase('33')){
                    naicsValue = '313233';
                }else if(accNAICS.equalsIgnoreCase('44') || accNAICS.equalsIgnoreCase('45')){
                    naicsValue = '4445';
                }else if(accNAICS.equalsIgnoreCase('48') || accNAICS.equalsIgnoreCase('49')){
                    naicsValue = '4849';
                }else{
                    naicsValue = accNAICS;
                }
            }
            else
                naicsValue = '99';
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return naicsValue;
    }

    /*@methodName- checkPricingEligibility
    *@description- Method to query the Account to check pricing eligibility 
    *@param- Id :accountId
    *@return- Boolean
    */  
    @AuraEnabled(cacheable=true)
    public static Boolean checkPricingEligibility(Id accountId){
        Boolean isPricingEligible = false;
        try{
            Account accRecord;
            accRecord = [SELECT id, IsPricingEligible__c FROM Account WHERE id = :accountId];
            isPricingEligible = accRecord.IsPricingEligible__c;
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return isPricingEligible;
    }
    
    /*@methodName- getRequestNumber
    *@description- Method to query the Pricing Record 
    *@param- Id :recordId
    *@return- WrapperClass which hold pricing record and create date
    */  
    @AuraEnabled(cacheable=true)
    public static Wrapper getRequestNumber(Id recordId){
        Boolean buttonAccess;
        Wrapper wrapperClass = new Wrapper();
        try{
            Pricing_Request__c priceReq = [SELECT Id, Name, CreatedBy.Name, createdDate, APIRequestOutput__c, Case__c, Case__r.CaseNumber, PriceCaseComment__c, Line_of_Business__c, Frequency_Type__c, Frequency_Count__c, Quantity__c, Schedule_or_On_Call__c, Service_Baseline_ID__c, IsPriceChangeRequest__c,Pricing_Type__c FROM Pricing_Request__c WHERE id = :recordId];
            wrapperClass.priReq = priceReq;
            wrapperClass.createdDate = priceReq.createdDate.format();
            //Changes for SDT-26044
            wrapperClass.pricingThresholds = [SELECT Label, DeveloperName, Line_of_Business__c, FieldType__c, Minimum_Value__c, Maximum_Value__c from Pricing_Threshold_Settings__mdt];
           
           //Changes related to SDT -33633-start
           //Checking if logged in user is having CAT profile
            buttonAccess = ButtonAccessController.returnButtonAccess();
            If(!buttonAccess){
                wrapperClass.priReq.PriceCaseComment__c = true;
            }
            //Changes related to SDT -33633-end
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return wrapperClass;
    }

    /*@methodName- getPricingRecord
    *@description- Method to query the Pricing Record 
    *@param- Id :recordId
    *@return- Pricing_Request__c which hold pricing record
    */  
    @AuraEnabled(cacheable=true)
    public static Pricing_Request__c getPricingRecord(Id recordId){
        Pricing_Request__c priceReq;
        try{
          Set<Id> prId = new Set<Id>();
          prId.add(recordId);
          priceReq = PricingRequestSelector.getPricingRequestListById(prId)[0];
            // priceReq = [SELECT Id, Name, Account__c, Case__c, Case__r.CaseNumber, Container_Size__c, Container_Type__c, Customer_Owned__c,
            //         Frequency_Count__c, Frequency_Type__c, Hauls_Month__c, Industry_Classification__c, Line_of_Business__c, Location__c,
            //         Material_Code__c, Quantity__c, Schedule_or_On_Call__c, Service_City__c, Service_Country__c, Service_Postal_Code__c,
            //         Service_State__c, Service_Street_Address__c, Service_Type__c, Project_Request__c, Project_Code__c,
            //         Service_Baseline_ID__c, IsPriceChangeRequest__c,Is_Multi_Vendor__c
            //         FROM Pricing_Request__c WHERE id = :recordId];


        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return priceReq;
    }

    /*@methodName- getFieldDetails
    *@description- Method to query the PricingRequestOutputField__mdt Record 
    *@param- String :objectAPiName
    *@return- Case Record
    */  
    @AuraEnabled(cacheable=true)
    public static List<PricingRequestOutputField__mdt> getFieldDetails(String objectAPiName){
        List<PricingRequestOutputField__mdt> formFields;
        try{
            //AAC-3 / SDT-28754 Asset Availabilty - QualifiedApiName field added to query
            formFields = [SELECT QualifiedApiName,ParentContainer__c, FieldName__c, APIFieldName__c, APIParentNode__c, Sequence__c, Condition__c FROM PricingRequestOutputField__mdt WHERE Active__c = true ORDER BY Sequence__c ];
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
        }
        return formFields;
    }

    /*@methodName- insertCaseComment
    *@description- Method to insert pricing in comment object 
    *@param- String :caseComment hold pricing info
    *@param- Id :CaseId
    *@param- String :caseNumber hold case number
    *@return- NA
    */  
    // @AuraEnabled
    // public static void insertCaseComment(String caseComment, Id caseId, String caseNumber){
    //     try{
    //         Map<Id,String> mapCaseComment = new Map<Id,String>();
    //         mapCaseComment.put(caseId,caseComment);
    //         AcornController.createAcornCommentforCase(mapCaseComment);
    //     }catch(Exception ex){
    //         UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.PRICING_REQUEST_APEX,LoggingLevel.ERROR);
    //     }
    // }

    /*@methodName- getCaseDetails
    *@description- Method to update case and pricing commect flag in pricing object 
    *@param- Id :priceId
    *@param- Id :caseId
    *@param- Boolean :PriceCaseComment
    *@return- NA
    */  
    // @AuraEnabled
    // public static void updatePriceRequest(Id priceId, Id caseId, Boolean PriceCaseComment, Decimal AcornIssueId, String CaseNumber, String TrackingNumber){
    //     try{
    //         Pricing_Request__c preq = new Pricing_Request__c();
    //         preq.Id = priceId;
    //         preq.Case__c = caseId;
    //         preq.PriceCaseComment__c = PriceCaseComment;
    //         if(AcornIssueId != null){
    //             preq.Acorn_Issue_Id__c = AcornIssueId;
    //             preq.Tracking_Number__c = TrackingNumber;
    //             preq.Case_Number__c = CaseNumber;
    //         }
    //         Update preq;
    //     }catch(Exception ex){
    //         UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
    //     }
    // }

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
        List<String> pricing_Result = new List<String>();
        try{
            Pricing_Request__c priceReq = [SELECT Id, Account__c, Account__r.Customer_Code__c, Location__c, Location__r.Location_Code__c, Container_Type__c, Container_Size__c, Material_Code__c
            , Quantity__c, Hauls_Month__c, Industry_Classification__c, Customer_Owned__c, Service_Type__c, Name, APIRequestOutput__c, Service_Street_Address__c, Service_City__c, Service_State__c
            , Service_Country__c, Service_Postal_Code__c, Case__c, Frequency_Type__c, Frequency_Count__c, Line_of_Business__c, Quote_Line_Bundle__c, Project_Request__c, Project_Code__c
            , Project_Code__r.Name, Account__r.IsPricingEligible__c, Account__r.Primary_Segment__c, Schedule_or_On_Call__c
            ,Quote__r.SBQQ__Opportunity2__r.Case__r.Price_Quote_Identifier__c,Quote__r.Quote_Only__c
            FROM Pricing_Request__c 
            WHERE id = :recordId];
            //System.debug('priceReq.Location__r.Location_Code__c:' + priceReq.Location__r.Location_Code__c);
            PriceQuoteIdentifier = priceReq.Quote__r.SBQQ__Opportunity2__r.Case__r.Price_Quote_Identifier__c;
            //Changes by jatan 
            if(PriceQuoteIdentifier != null && priceReq.Quote__r.Quote_Only__c)
            {
            //system.debug('PriceQuoteIdentifier '+PriceQuoteIdentifier);
            urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'GetPriceFrompriceQuoteIdentifier' LIMIT 1];
            endpoint = urlMD.End_Point__c;
            endpoint = endpoint.replace('{PriceQuoteIdentifier}', PriceQuoteIdentifier); 
            }
        else{
        
            String naicCode = priceReq.Industry_Classification__c != null ? priceReq.Industry_Classification__c.substring(0,2) : '';
            String LOB_Param, Frequency_Type, Frequency_Count, Service_Type;
            Service_Type =  priceReq.Service_Type__c == 'SEAS' ? 'TEMP' : priceReq.Service_Type__c;

            String Common_Param = Constant_Util.PR_EQUIPMENT_CODE + priceReq.Container_Type__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_EQUIPMENT_SIZE_CODE + priceReq.Container_Size__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_MATERIAL_TYPE_CODE + priceReq.Material_Code__c.replace(Constant_Util.AMPERSAND,'%26') + Constant_Util.AMPERSAND +
            Constant_Util.PR_QUANTITY + priceReq.Quantity__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_NAIC_CODE + naicCode + Constant_Util.AMPERSAND +
            Constant_Util.PR_IS_CLIENT_OWNED + priceReq.Customer_Owned__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_EQUIPMENT_AVAILABILITY + Service_Type + Constant_Util.AMPERSAND +
            // Changes for Exhibit Pricing Story- SDT-20401
            Constant_Util.IS_PROJECT + priceReq.Project_Request__c + Constant_Util.AMPERSAND +
            Constant_Util.PROJECT_CATEFORY + priceReq.Project_Code__r.Name + Constant_Util.AMPERSAND +
            // Changes for Exhibit Pricing Story- SDT-24009
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
            
            if(priceReq.Account__c != null && priceReq.Location__c == null){
                if(priceReq.Line_of_Business__c.equalsIgnoreCase(Constant_Util.ROLLOFF) ){
                    urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingCustomerRollOff' LIMIT 1];
                    LOB_Param = Constant_Util.PR_HAULS_PER_MONTH + priceReq.Hauls_Month__c;
                }
                else{
                    urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingCustomerCommercial' LIMIT 1];
                    LOB_Param = Constant_Util.PR_OCCURENCE_CODE + Frequency_Type + Constant_Util.AMPERSAND +
                    Constant_Util.PR_OCCURENCE_COUNT + Frequency_Count;
                }

                endpoint = urlMD.End_Point__c;
                endpoint = endpoint.replace(Constant_Util.PR_CUSTOMER_CODE, priceReq.Account__r.Customer_Code__c);
                endpoint = endpoint + '?' + 
                Constant_Util.PR_ADDRESS1 + priceReq.Service_Street_Address__c + Constant_Util.AMPERSAND +
                Constant_Util.PR_CITY + priceReq.Service_City__c + Constant_Util.AMPERSAND +
                Constant_Util.PR_STATE + priceReq.Service_State__c + Constant_Util.AMPERSAND +
                Constant_Util.PR_ZIPCODE + priceReq.Service_Postal_Code__c + Constant_Util.AMPERSAND +
                Constant_Util.PR_COUNTRY + priceReq.Service_Country__c + Constant_Util.AMPERSAND +
                Common_Param +
                LOB_Param;
            }
            else {
                if(priceReq.Line_of_Business__c.equalsIgnoreCase(Constant_Util.ROLLOFF) ){
                    urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingLocationRollOff' LIMIT 1];
                    LOB_Param = Constant_Util.PR_HAULS_PER_MONTH + priceReq.Hauls_Month__c;
                }
                else{
                    urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingLocationCommercial' LIMIT 1];
                    LOB_Param = Constant_Util.PR_OCCURENCE_CODE + Frequency_Type + Constant_Util.AMPERSAND +
                    Constant_Util.PR_OCCURENCE_COUNT + Frequency_Count;
                }
                endpoint = urlMD.End_Point__c;
                endpoint = endpoint.replace(Constant_Util.PR_LOCATION_CODE, priceReq.Location__r.Location_Code__c);
                endpoint = endpoint + '?' + 
                Common_Param +
                LOB_Param;
            }
        }
            //endpoint = endpoint + '?locationCode=HMD002718&containerCode=CMP&containerSizeCode=YRDS-20&materialTypeCode=T&equipmentAvailabilityTypeCode=PERM';
            
            //System.debug(endpoint);	
            Http httpObj = new Http();
            HttpRequest req = new HttpRequest();
            
            // endpoint = EncodingUtil.urlEncode(endpoint, 'UTF-8');
            endpoint = endpoint.replace(' ', '%20');
			//System.debug('@@@@@@ URL' + endpoint);
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
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
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
			
            if(assetCall){
                //RecurrsiveTriggerHandler.invokeValidationforPricing = true;
                //System.debug('@@@@@@@@~ PricingRequest Call Parse Function');
                //ProcessQLIPricingRequest.ParsePricingRequestJSON_Test(priceReq);
                PricingRequestHelper.assetPricingResponse.put(recordId, result);
            }
            else {
                saveReportingFields(priceReq, result);
                Update priceReq;
            }
        
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        return pricing_Result;
    }

    /*@methodName- getPriceOnlyDetail
    *@description- Method to invoke Pricing Only API   
    *@param- Id :recordId
    *@return- String Pricing JSON
    */  
    @AuraEnabled
    public static String getPriceOnlyDetail(Id recordId, Boolean assetCall){
        //JSONParser objJson = JSON.createParser(inputFields);
        //system.debug('In getPriceOnlyDetail');

        Integration_Request_URLs__mdt urlMD;
        String endpoint = '';
        string result = '';
        try{
            Pricing_Request__c priceReq = [SELECT Id, Account__c, Location__c, Location__r.Location_Code__c, Container_Type__c, Container_Size__c, Material_Code__c, Service_Type__c, Name, APIRequestOutput__c, Case__c, Line_of_Business__c, Quote_Line_Bundle__c, Disposal_Cost__c, Extra_Pickup_Cost__c, Haul_Cost__c, Pickup_Cost__c, Vendor_Code__c, Project_Request__c, Project_Code__c, Project_Code__r.Name FROM Pricing_Request__c WHERE id = :recordId];
        
            String LOB_Param, Service_Type;
            Service_Type =  priceReq.Service_Type__c == 'SEAS' ? 'TEMP' : priceReq.Service_Type__c;

            String Common_Param = Constant_Util.PR_LOCATIONCODE + priceReq.Location__r.Location_Code__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_SUPPLIER_CODE + priceReq.Vendor_Code__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_EQUIPMENT_CODE + priceReq.Container_Type__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_EQUIPMENT_SIZE_CODE + priceReq.Container_Size__c + Constant_Util.AMPERSAND +
            Constant_Util.PR_MATERIAL_TYPE_CODE + priceReq.Material_Code__c.replace(Constant_Util.AMPERSAND,'%26') + Constant_Util.AMPERSAND +
            Constant_Util.PR_EQUIPMENT_AVAILABILITY + Service_Type + Constant_Util.AMPERSAND +
            Constant_Util.PR_MARKET_TYPE_CODE + Constant_Util.OPEN + Constant_Util.AMPERSAND +
            // Changes for Exhibit Pricing Story- SDT-20401
            Constant_Util.IS_PROJECT + priceReq.Project_Request__c + Constant_Util.AMPERSAND +
            Constant_Util.PROJECT_CATEFORY + priceReq.Project_Code__r.Name + Constant_Util.AMPERSAND;
             
            if(priceReq.Line_of_Business__c.equalsIgnoreCase(Constant_Util.ROLLOFF) ){
                urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingOnlyLocationRollOff' LIMIT 1];
                LOB_Param = Constant_Util.PR_HAUL_COST + priceReq.Haul_Cost__c + Constant_Util.AMPERSAND +
                Constant_Util.PR_DISPOSAL_COST + priceReq.Disposal_Cost__c;
            }
            else{
                urlMD = [SELECT DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c FROM Integration_Request_URLs__mdt WHERE DeveloperName = 'PricingOnlyLocationCommercial' LIMIT 1];
                LOB_Param = Constant_Util.PR_PICKUP_COST + priceReq.Pickup_Cost__c + Constant_Util.AMPERSAND +
                Constant_Util.PR_EXTRAPICKUP_COST + priceReq.Extra_Pickup_Cost__c;                
            }

            endpoint = urlMD.End_Point__c;
            endpoint = endpoint.replace(Constant_Util.PR_LOCATION_CODE, priceReq.Location__r.Location_Code__c);
            endpoint = endpoint + '?' + 
            Common_Param +
            LOB_Param;
            

            //endpoint = endpoint + '?locationCode=HMD002718&containerCode=CMP&containerSizeCode=YRDS-20&materialTypeCode=T&equipmentAvailabilityTypeCode=PERM';
            
            //System.debug(endpoint);	
            Http httpObj = new Http();
            HttpRequest req = new HttpRequest();
            
            // endpoint = EncodingUtil.urlEncode(endpoint, 'UTF-8');
            endpoint = endpoint.replace(' ', '%20');
            //System.debug('@@@@@@ URL' + endpoint);
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
                UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
            } 
            
            priceReq.APIRequestOutput__c = result;
            //System.debug('@@@@@@@@~ API Output: '+ result);

            if(assetCall){
                CreatePricingRequest.assetPriceOnlyResponse.put(recordId, result);
            }
            else {
                saveReportingFields(priceReq, result);
                Update priceReq;
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.Pricing_Request_APEX,LoggingLevel.ERROR);
        }
        return result;
    }

    public static void saveReportingFields(Pricing_Request__c priceReq, String APIResponse)
    {        
       PricingReportingFieldsMetadata reportingFields = new PricingReportingFieldsMetadata();
        try{
            reportingFields = PricingReportingFieldsMetadata.parse(APIResponse);           

            if(reportingFields.data != null)
            {
                priceReq.put('isAPIResult__c',  true);
                priceReq.put('QuoteID__c',  reportingFields.Data.priceQuoteIdentifier);
                priceReq.put('Vendor_Code__c',  reportingFields.Data.SupplierCode);
                priceReq.put('Vendor_Name__c',  reportingFields.Data.supplierName);
                priceReq.put('Customer_Code__c',  reportingFields.Data.customerCode);
                priceReq.put('Cost_Source__c',  reportingFields.Data.costSource);
                priceReq.put('Zone_Type__c',  reportingFields.Data.contractType);
                priceReq.put('Customer_Price_Type__c',  reportingFields.Data.priceSource);
                priceReq.put('Vendor_Comments__c',  reportingFields.Data.feeComment);
                priceReq.put('CurrencyIsoCode',  reportingFields.Data.currencyCode);

                if(reportingFields.Data.rollOff != null){
                    priceReq.put('Disposal_Rate_Type__c',  reportingFields.Data.rollOff.pricingMethodDisposalDescription);
                    priceReq.put('Haul_Rate_Type__c',  reportingFields.Data.rollOff.pricingMethodHaulingDescription);
                    priceReq.put('Haul_Cost__c',  reportingFields.Data.rollOff.haulCost);
                    priceReq.put('Disposal_Cost__c',  reportingFields.Data.rollOff.disposalCost);
                    priceReq.put('Haul_Price__c',  reportingFields.Data.rollOff.haulPrice);
                    priceReq.put('Disposal_Price__c',  reportingFields.Data.rollOff.disposalPrice);
                    priceReq.put('Est_Tons_per_Haul__c',  reportingFields.Data.rollOff.estimatedVolumePerHaul);
                    priceReq.put('Haul_Record_Id__c',  reportingFields.Data.rollOff.haulRecordId);
                    priceReq.put('Disposal_Record_Id__c',  reportingFields.Data.rollOff.disposalRecordId);
                }
                if(reportingFields.Data.commercial != null){
                    priceReq.put('Pickup_Rate_Type__c',  reportingFields.Data.commercial.pricingMethodPickupDescription);
                    priceReq.put('Pickup_Cost__c',  reportingFields.Data.commercial.cost);
                    priceReq.put('Extra_Pickup_Cost__c',  reportingFields.Data.commercial.extraPickupCost);
                    priceReq.put('Pickup_Price__c',  reportingFields.Data.commercial.price);
                    priceReq.put('Extra_Pickup_Price__c',  reportingFields.Data.commercial.extraPickupPrice);
                    priceReq.put('Pickup_Record_Id__c',  reportingFields.Data.commercial.pickupRecordId);
                    priceReq.put('Extra_Pickup_Record_Id__c',  reportingFields.Data.commercial.extraPickupRecordId);
                }
                if(reportingFields.Data.wmMetaData != null){
                    //priceReq.put('Business_Unit__c',  reportingFields.Data.wmMetaData.businessUnit);
                    priceReq.put('Market_Area_Code__c',  reportingFields.Data.wmMetaData.marketAreaCode);
                    priceReq.put('Market_Area_Name__c',  reportingFields.Data.wmMetaData.marketAreaName);
                    priceReq.put('Facility_Id__c',  reportingFields.Data.wmMetaData.facilityId);
                    priceReq.put('Facility_Name__c',  reportingFields.Data.wmMetaData.facilityName);
                    priceReq.put('Site_Id__c',  reportingFields.Data.wmMetaData.siteId);
                    priceReq.put('Site_Name__c',  reportingFields.Data.wmMetaData.siteName);
                }
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

    public with sharing class Wrapper {
        @AuraEnabled public Pricing_Request__c priReq {get;set;}
        @AuraEnabled public String createdDate {get;set;}    
        //Changes for SDT-26044
        @AuraEnabled public List<Pricing_Threshold_Settings__mdt> pricingThresholds {get;set;}      
    }
}