public class CreatePricingRequest {
    //SDT 31114
    private static final String OTHER_PRICING_ERROR = 'OtherPricingError';
    public static Map<Id, String> assetPriceOnlyResponse = new Map<Id, String>();    

    /*@methodName- createPricingRequest
    *@description- Method to create the pricing request 'PR' 
    *@param- Id : QuoteID
    *@return- Non
    */ 
    @AuraEnabled
    public static void createPricingRequest(Id quoteID) {
        
        boolean isError = false; 
        String Status = null;
        String objectAPI = 'Pricing_Request__c';
        String fieldAPI = null;
        String No_Mapping = System.label.No_Mapping;   
        Integer successCount = 0;
        Integer failedCount = 0;
        List<Pricing_Request__c> pricingRequestList = new List <Pricing_Request__c>(); 
        List<SBQQ__Quote__c> quoteData = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> bundles = new List<SBQQ__QuoteLine__c>();
        Map<Id, decimal> quoteBaselineList = new Map<Id, decimal>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        List<SBQQ__QuoteLine__c> nonPRQLList = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> availabilityQLList = new List<SBQQ__QuoteLine__c>();
        Id accountId;
        String NAICSCode;

        quoteData = [SELECT Id, SBQQ__Account__r.AccountNumber,Case_Number__c,SBQQ__Account__r.ParentId,SBQQ__Account__r.Id, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c 
                    ,SBQQ__Status__c, Project__c, Project_Services_Request__c, SBQQ__Opportunity2__r.Case__c, QuoteProcuredStatus__c, SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName
                     FROM SBQQ__Quote__c 
                     WHERE Id =: quoteID 
                     AND (SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName =: Constant_Util.R_NEW_SERVICE_CASE
                     OR SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName =: Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API)];
                     //OR SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName =: Constant_Util.R_UPDATE_ASSET_CASE)];

        //SDT-27722 : Check Valid Asset for Price Change Request
       // if(quoteData.size() > 0 && quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_UPDATE_ASSET_CASE) //pkulkarn-TCS-31-5-2023-Added size check for SDT-30091
       if(quoteData.size() > 0 && quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API) //pkulkarn-TCS-31-5-2023-Added size check for SDT-30091
        {
            //Todo Call Validation Function
            quoteBaselineList = PricingChangeRequest.validateQuoteForPriceChange(quoteID);
            system.debug('----->quoteBaselineList' + quoteBaselineList);
            // if(quoteBaselineList != null && quoteBaselineList.size() == 0)
            // {
            //     system.debug('----->Before Return');
            //     return;
            // }
            // system.debug('----->After Return');
        }         
                     
        system.debug(' before in quoteData' + quoteData.size());
        if(quoteData != null && quoteData.size() > 0)
        {
            accountId = quoteData[0].SBQQ__Account__r.ParentId;
            NAICSCode = PricingRequest.getNAICSCode(accountId);
            // system.debug('NAICSCode--->' + NAICSCode);
            
            bundles = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, Material_Type__c,
                Duration__c, SBQQ__Quantity__c, Equipment_Size__c, Name, Pricing_Frequency_Type__c, 
                Pricing_Frequency_Count__c, Occurrence_Type__c, Ownership__c,Location_Position_Name__c,
                Location_Position_Name__r.AlternateStreet__c,Location_Position_Name__r.AlternateCity__c,
                Location_Position_Name__r.AlternateState__c,Location_Position_Name__r.AlternateCountry__c,
                Location_Position_Name__r.AlternatePostalCode__c, Account__r.Parent.IsPricingEligible__c,
                Account__r.Primary_Segment__c, SBQQ__Product__r.Is_Pricing_Eligible__c, SBQQ__Product__r.Family,
                AAV_Service_Availability__c, AAV_Delivery_Availability__c, AAV_Requested_AdditionalServicesAccessor__c, //SDT-31027      
                AAV_Priority__c, SBQQ__StartDate__c //SDT - 28610                        
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c =: quoteID 
                AND SBQQ__RequiredBy__c = null ]; //AND SBQQ__Product__r.Is_Pricing_Eligible__c = TRUE //AND Account__r.Parent.IsPricingEligible__c = TRUE
        }
      
        if(bundles.size()>0) {

              // system.debug('Bundles detail' + bundles.size() + bundles);
            List<SBQQ__QuoteLine__c> materialCode = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c  
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Product__r.Family = 'Waste Stream' 
            AND SBQQ__Quote__c =: quoteID];

            List<String> prContainerTypeLst = UTIL_Picklist.getPickListValuesIntoList('Pricing_Request__c', 'Container_Type__c');
            Map<String,List<String>> prDependentContainerSizeLst = UTIL_Picklist.getPicklistDependentValues('Pricing_Request__c', 'Container_Size__c');
            Map<String,List<String>> prDependentMaterialLst = UTIL_Picklist.getPicklistDependentValues('Pricing_Request__c', 'Material_Code__c');
            String productName;
            //SDT-31027           
            AAV_AvailabilityUtility.getAvailabilityFlagMap();  
            Boolean isAvailable = QuoteProcurementController.hasAssetAvailabilityPermission();
            //END
            system.debug('&&&&&&size of list'+bundles);

            for(SBQQ__QuoteLine__c quoteBundle : bundles){
                // system.debug('in for loo'+quoteBundle);
                //Reset falg and errorMsg
                isError =false;
                String errorMessage = '';
                errorMessage ='Invalid mapping value for pricing: ';
                productName = '';
                Pricing_Request__c pricingRequest = new Pricing_Request__c();
                pricingRequest.Account__c = quoteData[0].SBQQ__Account__r.ParentId;
                //Changes done for SDT-20205
                //pricingRequest.Location__c = quoteData.SBQQ__Account__r.Id;
				
                //Changes for SDT-27723 - Start
                //if(quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_UPDATE_ASSET_CASE)
                if(quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API)
                {
                    system.debug('----> quoteBaselineList.get(quoteBundle.Id)' + quoteBaselineList.get(quoteBundle.Id));
                    if(quoteBaselineList != null && quoteBaselineList.size() > 0 
                    && quoteBaselineList.get(quoteBundle.Id) != null && quoteBaselineList.get(quoteBundle.Id) > 0){
                        pricingRequest.Service_Baseline_ID__c = quoteBaselineList.get(quoteBundle.Id);
                        pricingRequest.IsPriceChangeRequest__c = true;
                    }
                    else{
                        System.debug('PR not create for Quoteline Id: ' + quoteBundle.Id);
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                        quoteLine.Id = quoteBundle.Id;
                        quoteLine.BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                        if(quoteBaselineList != null && quoteBaselineList.size() > 0 
                            && quoteBaselineList.get(quoteBundle.Id) != null && quoteBaselineList.get(quoteBundle.Id) == 0)
                        {
                            quoteLine.ProcurementErrorMessage__c = System.label.Error_InvalidServiceBaseline;
                            //SDT 31114
                            quoteLine.Pricing_Error__c= OTHER_PRICING_ERROR;
                        }
                        else{
                            quoteLine.ProcurementErrorMessage__c = System.label.Error_PC_FieldChange;
                            //SDT 31114
                            quoteLine.Pricing_Error__c= OTHER_PRICING_ERROR;
                        }
                        nonPRQLList.add(quoteLine);
                        continue;
                    }
                }
                else
                {
                    pricingRequest.IsPriceChangeRequest__c = false;
                }
                //SDT-27723 - End

                //pricingRequest.Service_Baseline_ID__c = quoteBaselineList != null ? quoteBaselineList.get(quoteBundle.Id) : null;
                //pricingRequest.IsPriceChangeRequest__c = pricingRequest.Service_Baseline_ID__c != null ? true : false;

                //SDT-31027                
                if(isAvailable &&
                quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_NEW_SERVICE_CASE ){
                    Availability_Flag__mdt availability = AAV_AvailabilityUtility.getAvailabilityFlag(quoteBundle);
                    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                    quoteLine.Id = quoteBundle.Id;
                    quoteLine.AAV_Priority__c = quoteBundle.AAV_Priority__c;
                    if(availability != null && availability.Pricing__c != 'Get Price'){
                        isError = true;
                        errorMessage += availability.Availability_Flag__c + ' ';                        
                    }
                    if(availability != null && availability.Manual_Procurement__c == 'Yes'){
                        quoteLine.ProcurementErrorMessage__c = availability.Availability_Flag__c;
                        quoteLine.BundleProcuredStatus__c = Constant_Util.PROCURED_NO;
                        quoteLine.Availability_Flag__c = availability.Availability_Flag__c;
                        availabilityQLList.add(quoteLine);
                    } else if(availability != null && availability.Manual_Procurement__c == 'No'){
                        quoteLine.Availability_Flag__c = availability.Availability_Flag__c;
                        availabilityQLList.add(quoteLine);
                    }
                }
                //END

                if(quoteBundle.Location_Position_Name__c != null && quoteBundle.Location_Position_Name__r.AlternateStreet__c != null && 
                   quoteBundle.Location_Position_Name__r.AlternateCity__c !=null && quoteBundle.Location_Position_Name__r.AlternateState__c!=null )
                    {
                        pricingRequest.Service_Street_Address__c = quoteBundle.Location_Position_Name__r.AlternateStreet__c;
                        pricingRequest.Service_City__c = quoteBundle.Location_Position_Name__r.AlternateCity__c;
                        pricingRequest.Service_State__c = quoteBundle.Location_Position_Name__r.AlternateState__c;
                        pricingRequest.Service_Country__c = quoteBundle.Location_Position_Name__r.AlternateCountry__c;
                        pricingRequest.Service_Postal_Code__c = quoteBundle.Location_Position_Name__r.AlternatePostalCode__c;
                    }
                else
                    {
                    pricingRequest.Location__c = quoteData[0].SBQQ__Account__r.Id;
                    pricingRequest.Service_Street_Address__c = quoteData[0].SBQQ__ShippingStreet__c;//'8334 Tamarack Vlg';
                    pricingRequest.Service_City__c = quoteData[0].SBQQ__ShippingCity__c;//'Woodbury';
                    pricingRequest.Service_State__c = quoteData[0].SBQQ__ShippingState__c;//'Indiana';
                    pricingRequest.Service_Country__c = quoteData[0].SBQQ__ShippingCountry__c;//'United States';
                    pricingRequest.Service_Postal_Code__c = quoteData[0].SBQQ__ShippingPostalCode__c;//'55125';
                    }
                // system.debug('caseDtl before>>'+ caseDtl);
                pricingRequest.Case_Number__c = String.valueOf(quoteData[0].Case_Number__c);
                pricingRequest.Case__c = quoteData[0].SBQQ__Opportunity2__r.Case__c;
                // system.debug('caseDtl after>>'+ caseDtl);
                //Changes Done for SDT-24009 -- START
                if(quoteBundle.Account__r.Parent.IsPricingEligible__c)
                {
                    PricingRequest.Pricing_Type__c = 'AM';
                }
                else
                {
                    PricingRequest.Pricing_Type__c = 'AMCO';
                }
                //END
                //Validation PR Data.
                if(quoteBundle.Duration__c == 'SEAS')
                {
                    pricingRequest.Service_Type__c= 'Temp';
                    isError = true;
                    errorMessage += ', Can not create Pricing Request for Seasonal duration type.';
                    
                }
                else
                {
                    pricingRequest.Service_Type__c = quoteBundle.Duration__c;
                    
                }
                
                //Changes for SDT-32077 - Comment below code as product created for Vertical Compactor.
                /*
                if(quoteBundle.SBQQ__Product__r.ProductCode == 'CMP')
                {
                    if(quoteBundle.Equipment_Size__c != null && quoteBundle.Equipment_Size__c.contains('-'))   
                    {
                        integer eqSize = Integer.valueOf(quoteBundle.Equipment_Size__c.substringAfter('-'));
                        if(eqSize >= 10)
                        {
                            pricingRequest.Container_Type__c = 'CMP';
                            pricingRequest.Line_of_Business__c = Constant_Util.ROLLOFF;
                        }
                        else
                        {
                            pricingRequest.Container_Type__c = 'VTC';
                            pricingRequest.Line_of_Business__c = Constant_Util.COMMERCIAL;
                        }
                    }
                }
                else
                {
                    pricingRequest.Line_of_Business__c = quoteBundle.SBQQ__Product__r.Family;
                }
                */
		pricingRequest.Line_of_Business__c = quoteBundle.SBQQ__Product__r.Family;
                if(quoteBundle.SBQQ__Product__r.ProductCode != null){
                    // if(pricingRequest.Container_Type__c == null){	Changes for SDT-32077 - Comment below code as product created for Vertical Compactor.
                        for(Integer i=0; i< prContainerTypeLst.size(); i++){
                            if(prContainerTypeLst[i].split(',').get(1) == quoteBundle.SBQQ__Product__r.ProductCode){
                                pricingRequest.Container_Type__c = quoteBundle.SBQQ__Product__r.ProductCode;
                                break;
                            }
                        }
                        //Change for SDT-32077
                        productName = Compactor_Utility.retrieveCompactorVerticalEquivalentProduct(quoteBundle);
                    	
                    // }    //Changes for SDT-32077 - Comment below code as product created for Vertical Compactor including this line.
                    // else
                    // {
                    //     productName = pricingRequest.Container_Type__c == 'CMP' ? 'Compactor' : 'Vertical Compactor';
                    // } 

                    if(pricingRequest.Container_Type__c != null && prDependentContainerSizeLst.containsKey(productName))
                    {
                        List<String> prContainerSizeLst = prDependentContainerSizeLst.get(productName);
                        for(Integer j=0; j < prContainerSizeLst.size(); j++){                            
                            if(prContainerSizeLst[j].split(',').get(1) == quoteBundle.Equipment_Size__c){
                                pricingRequest.Container_Size__c = quoteBundle.Equipment_Size__c;
                                break;
                            }
                        }
                    }
                    //Validation PR Data.
                    If(pricingRequest.Container_Type__c == null){
                        pricingRequest.Container_Type__c =No_Mapping;
                        isError = true;
                        errorMessage += ', Container Type: '+quoteBundle.SBQQ__Product__r.ProductCode;
                    }
                    If(pricingRequest.Container_Size__c == null){
                        pricingRequest.Container_Size__c = No_Mapping;
                        isError = true;
                        errorMessage += ', Container Size: '+quoteBundle.Equipment_Size__c;
                    }
                }
                
                if(pricingRequest.Line_of_Business__c == Constant_Util.COMMERCIAL)
                {
                    if(quoteBundle.Pricing_Frequency_Type__c != null)
                    {
                        pricingRequest.Frequency_Type__c = quoteBundle.Pricing_Frequency_Type__c;
                    }
                    
                    if(quoteBundle.Pricing_Frequency_Count__c != null)
                    {
                        pricingRequest.Frequency_Count__c = String.valueOf(quoteBundle.Pricing_Frequency_Count__c);
                    }
                    //Validation PR Data.
                    If(pricingRequest.Frequency_Type__c ==null){
                        pricingRequest.Frequency_Type__c =No_Mapping;
                        isError = true;
                        errorMessage += 'Frequency Type is required';
                    }
                    If(pricingRequest.Frequency_Count__c == null){
                        pricingRequest.Frequency_Count__c = No_Mapping;
                        isError = true;
                        errorMessage += 'Frequency Count is required';
                    }
                    
                }
                
                // Getting Material code 
                for (SBQQ__QuoteLine__c WSLineItem : materialCode)
                {   if(WSLineItem.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == quoteBundle.Id && prDependentMaterialLst.containsKey(pricingRequest.Line_of_Business__c))
                {
                    List<String> prMaterialLst = prDependentMaterialLst.get(pricingRequest.Line_of_Business__c);
                    for(Integer m=0; m < prMaterialLst.size(); m++){
                        if(prMaterialLst[m].split(',').get(1) == WSLineItem.SBQQ__Product__r.ProductCode){
                            pricingRequest.Material_Code__c = WSLineItem.SBQQ__Product__r.ProductCode;
                            break;
                        }
                    }
                }
                }
                //Validation PR Data.
                If(pricingRequest.Material_Code__c == null){
                    pricingRequest.Material_Code__c =No_Mapping;
                    isError = true;
                    errorMessage += ', Material Code ';
                }
                // system.debug('@@@ Jatan Occurrence '+quoteBundle.Occurrence_Type__c);
                if(quoteBundle.Occurrence_Type__c != null){
                    pricingRequest.Schedule_or_On_Call__c = quoteBundle.Occurrence_Type__c == 'OC' || quoteBundle.Occurrence_Type__c == 'SOC' ? 'On-Call' : 'Scheduled';
                }
                //Validation PR Data.
                If(pricingRequest.Schedule_or_On_Call__c == null){
                    pricingRequest.Schedule_or_On_Call__c =No_Mapping;
                    isError = true;
                    errorMessage += ', Occurrence Type: '+quoteBundle.Occurrence_Type__c +', Should be Schedule or On-Call';
                }
                //pricingRequest.Schedule_or_On_Call__c = Constant_Util.ON_CALL;//'On-Call';
                if(quoteBundle.SBQQ__Product__r.ProductCode != null && quoteBundle.SBQQ__Product__r.ProductCode == 'TOT' 
                && quoteBundle.SBQQ__Quantity__c != null && quoteBundle.SBQQ__Quantity__c > 5)
                {
                    pricingRequest.Quantity__c = quoteBundle.SBQQ__Quantity__c;
                    isError = true;
                    errorMessage += ', Cannot use automated pricing for Qty > 5. Must be priced manually.';
                }
                else
                {
                    pricingRequest.Quantity__c = quoteBundle.SBQQ__Quantity__c;
                }
                pricingRequest.Hauls_Month__c = Constant_Util.ONE_NUMBER;
                pricingRequest.Industry_Classification__c = NAICSCode;
                pricingRequest.Quote_Line_Bundle__c = quoteBundle.Id;
                pricingRequest.Quote__c = quoteData[0].Id;
                pricingRequest.Quote_Line__c = quoteBundle.Name;
                pricingRequest.Customer_Owned__c = quoteBundle.Ownership__c != null ? quoteBundle.Ownership__c == 'CLT' ? true : false : false;               
                pricingRequest.Project_Request__c = quoteData[0].Project_Services_Request__c;
                if(quoteData[0].Project_Services_Request__c == true)
                {
                    pricingRequest.Project_Code__c = quoteData[0].Project__c;
                }
                pricingRequestList.add(pricingRequest); 
                
                //Changes for SDT-24477
                //When Product is not pricing eligible
                if(!quoteBundle.SBQQ__Product__r.Is_Pricing_Eligible__c) 
                {
                    pricingRequest.Container_Type__c = No_Mapping;
                    pricingRequest.Container_Size__c = No_Mapping;
                    pricingRequest.Material_Code__c = No_Mapping;
                    isError = true;
                    errorMessage = ' Container Type: ' + quoteBundle.SBQQ__Product__r.ProductCode + ' is not pricing eligible';
                }
                //End SDT-24477

                If(isError){
                    pricingRequest.IsCaseError__c = true;
                    pricingRequest.Case_Error_Message__c = errorMessage;
                }
            }
            
            try 
            {
                //Changes For SDT-27723 - Start                
                //if(quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_UPDATE_ASSET_CASE)
                if(quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API)  
                {
                    if(nonPRQLList != null && nonPRQLList.size() > 0)
                    {
                        update nonPRQLList;

                        if(nonPRQLList.size() == bundles.size())
                        {
                            quote.Id = quoteID;
                            quote.QuoteProcuredStatus__c = Constant_Util.FAILED;
                            update quote;
                        }
                    }
                }

                if(isAvailable && availabilityQLList != null && availabilityQLList.size() > 0 &&
                quoteData[0].SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName == Constant_Util.R_NEW_SERVICE_CASE){
                    update availabilityQLList;
                }
                //SDT-27723 - End

                system.debug('RecurrsiveTriggerHandler before Insert');
                RecurrsiveTriggerHandler.invokeValidationforPricing = true;
                Database.SaveResult[] SR = database.insert(pricingRequestList,false);
            }
            Catch(Exception ex){
                Status = ex.getMessage();            
                //System.debug('New Error:'+ Status);
                throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    /*@methodName- createPriceOnlyPR
    *@description- Method to create the pricing request 'PR' for price only
    *@param- Id : QuoteID
    *@return- Non
    */     
    @AuraEnabled
    public static String createPriceOnlyPR(Id quoteLineID) {
        // system.debug('createPriceOnlyPR Starte');
        boolean isError = false; 
        String No_Mapping = System.label.No_Mapping;   
        Id pricingId;
        List<Pricing_Request__c> pricingRequestList = new List<Pricing_Request__c>();
        Pricing_Request__c prParam = new Pricing_Request__c();
        List<SBQQ__QuoteLine__c> quoteLines =  new List<SBQQ__QuoteLine__c>();
        Id accountId;
        String NAICSCode;

        quoteLines = [SELECT Id, SBQQ__Product__r.Name,SBQQ__Product__r.ProductCode, Material_Type__c, Duration__c, 
                SBQQ__Quantity__c, Equipment_Size__c, Name, Pricing_Frequency_Type__c, Pricing_Frequency_Count__c, Occurrence_Type__c, 
                Ownership__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__r.AccountNumber, SBQQ__Quote__r.Case_Number__c, 
                SBQQ__Quote__r.SBQQ__Account__r.ParentId, SBQQ__Quote__r.SBQQ__Account__r.Id, SBQQ__Quote__r.SBQQ__ShippingStreet__c, 
                SBQQ__Quote__r.SBQQ__ShippingCity__c, SBQQ__Quote__r.SBQQ__ShippingCountry__c, SBQQ__Quote__r.SBQQ__ShippingState__c, 
                SBQQ__Quote__r.SBQQ__ShippingPostalCode__c, SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Quote__r.Project__c, SBQQ__Quote__r.Project_Services_Request__c
                , Vendor__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, Account__r.Parent.IsPricingEligible__c, Account__r.Primary_Segment__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE Id =: quoteLineID 
                                            AND SBQQ__Bundle__c = TRUE 
                                            AND SBQQ__Product__r.Is_Pricing_Eligible__c = TRUE
                                            AND Account__r.Parent.IsPricingEligible__c = TRUE];

        List<SBQQ__QuoteLine__c> materialCode = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__r.SBQQ__RequiredBy__c  
                                                 FROM SBQQ__QuoteLine__c 
                                                 WHERE SBQQ__Product__r.Family = 'Waste Stream' 
                                                 AND SBQQ__Quote__c =: quoteLines[0].SBQQ__Quote__c];

        List<SBQQ__QuoteLine__c> costQuote = [SELECT Id, SBQQ__UnitCost__c, SBQQ__ProductCode__c,SBQQ__ProductName__c, Vendor__c, Vendor__r.Vendor_ID__c
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__RequiredBy__c =: quoteLines[0].Id
                                                and SBQQ__ProductCode__c IN ('DSP','H','PCK')];                                         
        
        List<String> prContainerTypeLst = UTIL_Picklist.getPickListValuesIntoList('Pricing_Request__c', 'Container_Type__c');
        Map<String,List<String>> prDependentContainerSizeLst = UTIL_Picklist.getPicklistDependentValues('Pricing_Request__c', 'Container_Size__c');
        Map<String,List<String>> prDependentMaterialLst = UTIL_Picklist.getPicklistDependentValues('Pricing_Request__c', 'Material_Code__c');
        String productName;
        // system.debug('&&&&&&size of list'+quoteLine);

        for(SBQQ__QuoteLine__c quoteLine : quoteLines) 
        {
            accountId = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.ParentId;
            NAICSCode = PricingRequest.getNAICSCode(accountId);

            isError =false;
            String errorMessage = '';
            errorMessage ='Invalid mapping value for pricing: ';
            productName = '';
            prParam.Account__c = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.ParentId;
            prParam.Location__c = quoteLine.SBQQ__Quote__r.SBQQ__Account__r.Id;
            prParam.Service_Street_Address__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingStreet__c;
            prParam.Service_City__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingCity__c;
            prParam.Service_State__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingState__c;
            prParam.Service_Country__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingCountry__c;
            prParam.Service_Postal_Code__c = quoteLine.SBQQ__Quote__r.SBQQ__ShippingPostalCode__c;
            prParam.Case_Number__c = String.valueOf(quoteLine.SBQQ__Quote__r.Case_Number__c);
            prParam.Case__c = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c;

            //prParam.Vendor_Code__c = quoteLine.Vendor__c;
            prParam.Pricing_Type__c = 'AMPO';
            //Validation PR Data.
            if(quoteLine.Duration__c == 'SEAS')
            {
                prParam.Service_Type__c= 'Temp';
                isError = true;
                errorMessage += ', Can not create Pricing Request for Seasonal duration type.';
            }
            else
            {
                prParam.Service_Type__c = quoteLine.Duration__c;
            }
            
            
            if (quoteLine.SBQQ__Product__r.ProductCode == 'OT')
            {
                prParam.Line_of_Business__c = Constant_Util.ROLLOFF;
            }
            else if(quoteLine.SBQQ__Product__r.ProductCode == 'CMP')
            {
                if(quoteLine.Equipment_Size__c != null && quoteLine.Equipment_Size__c.contains('-'))   
                {
                    integer eqSize = Integer.valueOf(quoteLine.Equipment_Size__c.substringAfter('-'));
                    if(eqSize >= 10)
                    {
                        prParam.Container_Type__c = 'CMP';
                        prParam.Line_of_Business__c = Constant_Util.ROLLOFF;
                    }
                    else
                    {
                        prParam.Container_Type__c = 'VTC';
                        prParam.Line_of_Business__c = Constant_Util.COMMERCIAL;
                    }
                }
            }
            else
            {
                prParam.Line_of_Business__c = Constant_Util.COMMERCIAL;
            } 
            //Changes by jatan sharma for 20125

            for(SBQQ__QuoteLine__c QL : costQuote)
            {
                prParam.Vendor_Code__c = QL.Vendor__r.Vendor_ID__c;
                if(prParam.Line_of_Business__c == Constant_Util.COMMERCIAL)
                {
                    if(QL.SBQQ__ProductName__c.equals(Constant_Util.PR_EXTRA_PICKUP)){
                        prParam.Extra_Pickup_Cost__c = QL.SBQQ__UnitCost__c;
                        // system.debug('In Extra Pickup@@@@');
                        // system.debug(prParam.Extra_Pickup_Cost__c);
                    }
                    else if(QL.SBQQ__ProductName__c.equals(Constant_Util.PR_PICKUP)){
                        prParam.Pickup_Cost__c = QL.SBQQ__UnitCost__c;
                        // system.debug('In  Pickup@@@@');
                        // system.debug(prParam.Pickup_Cost__c);
                    }
                }
                else if(prParam.Line_of_Business__c == Constant_Util.ROLLOFF)
                {
                    if(QL.SBQQ__ProductName__c.equals(Constant_Util.DISPOSAL)){
                        prParam.Disposal_Cost__c = QL.SBQQ__UnitCost__c;
                        // system.debug('In Disposal@@@@');
                        // system.debug(prParam.Disposal_Cost__c);
                    }
                    else if(QL.SBQQ__ProductName__c.equals(Constant_Util.HAUL)){
                        prParam.Haul_Cost__c = QL.SBQQ__UnitCost__c;
                        // system.debug('In  Haul@@@@');
                        // system.debug(prParam.Haul_Cost__c);
                    }
                }
            }
            // system.debug('costQuote@@'+ costQuote);
            //changes END
        
            
            if(quoteLine.SBQQ__Product__r.ProductCode != null){
                if(prParam.Container_Type__c == null){
                    for(Integer i=0; i< prContainerTypeLst.size(); i++){
                        if(prContainerTypeLst[i].split(',').get(1) == quoteLine.SBQQ__Product__r.ProductCode){
                            prParam.Container_Type__c = quoteLine.SBQQ__Product__r.ProductCode;
                            break;
                        }
                    }
                    productName = quoteLine.SBQQ__Product__r.Name;
                }    
                else
                {
                    productName = prParam.Container_Type__c == 'CMP' ? 'Compactor' : 'Vertical Compactor';
                }
                if(prParam.Container_Type__c != null && prDependentContainerSizeLst.containsKey(productName))
                {
                    List<String> prContainerSizeLst = prDependentContainerSizeLst.get(productName);
                    for(Integer j=0; j < prContainerSizeLst.size(); j++){                            
                        if(prContainerSizeLst[j].split(',').get(1) == quoteLine.Equipment_Size__c){
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
            
            if(prParam.Line_of_Business__c == Constant_Util.COMMERCIAL)
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
            
            // Getting Material code 
            for (SBQQ__QuoteLine__c WSLineItem : materialCode)
            {   if(WSLineItem.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c == quoteLine.Id && prDependentMaterialLst.containsKey(prParam.Line_of_Business__c))
            {
                List<String> prMaterialLst = prDependentMaterialLst.get(prParam.Line_of_Business__c);
                for(Integer m=0; m < prMaterialLst.size(); m++){
                    if(prMaterialLst[m].split(',').get(1) == WSLineItem.SBQQ__Product__r.ProductCode){
                        prParam.Material_Code__c = WSLineItem.SBQQ__Product__r.ProductCode;
                        break;
                    }
                }
            }
            }
            //Validation PR Data.
            If(prParam.Material_Code__c == null){
                prParam.Material_Code__c =No_Mapping;
                isError = true;
                errorMessage += ', Material Code ';
            }
            // system.debug('@@@ Jatan Occurrence '+ quoteLine.Occurrence_Type__c);
            if(quoteLine.Occurrence_Type__c != null){
                prParam.Schedule_or_On_Call__c = quoteLine.Occurrence_Type__c == 'OC' || quoteLine.Occurrence_Type__c == 'SOC' ? 'On-Call' : 'Scheduled';
            }
            //Validation PR Data.
            If(prParam.Schedule_or_On_Call__c == null){
                prParam.Schedule_or_On_Call__c =No_Mapping;
                isError = true;
                errorMessage += ', Occurrence Type: '+ quoteLine.Occurrence_Type__c +', Should be Schedule or On-Call';
            }
            //prParam.Schedule_or_On_Call__c = Constant_Util.ON_CALL;//'On-Call';
            if(quoteLine.SBQQ__Product__r.ProductCode != null && quoteLine.SBQQ__Product__r.ProductCode == 'TOT' 
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
            prParam.Hauls_Month__c = Constant_Util.ONE_NUMBER;
            prParam.Industry_Classification__c = NAICSCode;
            prParam.Quote_Line_Bundle__c = quoteLine.Id;
            prParam.Quote__c = quoteLine.SBQQ__Quote__c;
            prParam.Quote_Line__c = quoteLine.Name;
            prParam.Customer_Owned__c = quoteLine.Ownership__c != null ? quoteLine.Ownership__c == 'CLT' ? true : false : false;
            
            prParam.Project_Request__c = quoteLine.SBQQ__Quote__r.Project_Services_Request__c;
            if(quoteLine.SBQQ__Quote__r.Project_Services_Request__c == true)
            {
                prParam.Project_Code__c = quoteLine.SBQQ__Quote__r.Project__c;
            }
            
            If(isError){
                prParam.IsCaseError__c = true;
                prParam.Case_Error_Message__c = errorMessage;
            }
            
            pricingRequestList.add(prParam); 
            
            try 
            {
                // system.debug('@@@@ Param Request ' + prParam);

                //insert prParam;
                Database.SaveResult[] SR = database.insert(pricingRequestList,false);

                if(SR[0].isSuccess())
                {
                    pricingId = pricingRequestList[0].Id;
                    // system.debug('@@@@ PR ID ' + pricingRequestList[0].Id);

                    Set<Id> pricingReqIdSet = new Set<Id>();
                    pricingReqIdSet.add(pricingRequestList[0].Id);
                    callPriceOnlyIntegration(pricingReqIdSet);
                }
            }
            Catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }
        // system.debug('createPriceOnlyPR End' + pricingId);
        return pricingId;
    }

    /*@methodName- callPriceOnlyIntegration
    *@description- Method to invoke the API through future call method
    *@param- Id : Set of Pricing Request Id
    *@return- Non
    */ 
    @future(callout=true)
    public static void callPriceOnlyIntegration(Set<id> PricingReqIdSet)
    {
        // system.debug('PricingReqIdSet--->'+ PricingReqIdSet);
        for (Id requestId : PricingReqIdSet)
        {
            // system.debug('requestId--->' +requestId);
			PricingRequest.getPriceOnlyDetail(requestId, true);
        }

        if(assetPriceOnlyResponse != null && assetPriceOnlyResponse.size() > 0){
            List<Pricing_Request__c> prList = new List<Pricing_Request__c>();
            for(Id pId : assetPriceOnlyResponse.keySet()){
                Pricing_Request__c pReqt = new Pricing_Request__c();

                pReqt.Id = pId;
                // system.debug('listOfStatus--->' +assetPriceOnlyResponse.get(pId));

                pReqt.APIRequestOutput__c = assetPriceOnlyResponse.get(pId);
                PricingRequest.saveReportingFields(pReqt, assetPriceOnlyResponse.get(pId));

                prList.add(pReqt);
            }
            if(prList != null && prList.size() > 0)
            {
                //RecurrsiveTriggerHandler.invokeValidationforPricing = true;
                update prList;
                system.debug('@@@@@@@@~ After Pricing Update');
            }
        }
    }
}