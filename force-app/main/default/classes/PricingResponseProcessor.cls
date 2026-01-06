//Author 		: TCS, pkulkarn
//Purpose 		: To define a class to collate email message related processing
//Date		 	: 25-Mar-2025
//Test class 	: PricingResponseProcessorTest

public class PricingResponseProcessor 
{
    private final String priceTypePriceOnly = 'Price Only';
    private final String priceTypePriceOnlyAPIName = 'AMPO';
    private final String priceTypeStandard = 'Standard';
    private final String sVendorTypeThirdParty = 'Third Party';
    
    //Class to contain multiple return variables from determineQuoteLineAction method
    public with sharing class serviceChargeActionOutput 
    {
		public Boolean overrideAction {get;set;}
        public Boolean createQuoteLine {get;set;}
        public Boolean updateQuoteLine {get;set;}
        public Boolean deleteQuoteLine {get;set;}
        
        //Default constructor to initialize members
        public serviceChargeActionOutput()
        {
            overrideAction = createQuoteLine = updateQuoteLine = deleteQuoteLine = false;
        }
	}
    
    //Class to contain multiple parameters for determineQuoteLineAction method
    public with sharing class serviceChargeActionInput
    {
		public String parentAccountPrimarySegment {get;set;}
        public String serviceChargeName {get;set;}
        public String serviceChargeCode {get;set;}
        public String quoteType {get;set;}
        public String shippingCountry {get;set;}
        public PricingReportingFieldsMetadata prFields {get;set;}
        public PricingRequestFieldsMetadata.suppliers prMVFields {get;set;}
        public Pricing_Request__c pricingRequest {get;set;}
        public SBQQ__QuoteLine__c quoteLineRecord {get;set;}
        public List<Pricing_Response_Process_Quote_Line__mdt> processQuoteLineMetadata {get;set;}
        public Id bundleId {get;set;}
        public List<Pricing_Request__c> stdPricingRequestList;
        public string equipmentName;
        
        //Default constructor to initialize members
        public serviceChargeActionInput()
        {
            parentAccountPrimarySegment = '';
            serviceChargeName = '';
            serviceChargeCode = '';
            quoteType = '';
            shippingCountry = '';
            PricingReportingFieldsMetadata prFields = null;
            PricingRequestFieldsMetadata.suppliers prMVFields = null;
            Pricing_Request__c pricingRequest = null;
            SBQQ__QuoteLine__c quoteLineRecord = null;
            processQuoteLineMetadata = null;
            stdPricingRequestList = null;
            equipmentName = null;
        }
	}
    
    ////Multi-vendor Pricing Response Processing
     //Caller:
    //Purpose : To determine what action is needed for the Service Charge based additional processing
    public serviceChargeActionOutput determineMultiVendorQLAction(serviceChargeActionInput inputs)
    {
        //Output variable
        serviceChargeActionOutput outputs = new serviceChargeActionOutput();
        
        //Check for code switch
        Boolean isSpecMappingDisabled = CodeSwitchUtility.getCodeSwitchOn('Spec_Mapping');
        if(isSpecMappingDisabled == true)
        {
        	outputs.overrideAction = outputs.createQuoteLine = outputs.updateQuoteLine = outputs.deleteQuoteLine = false;
        	return outputs;
        }
        
        //Retrieve inputs into local variables
        PricingRequestFieldsMetadata.suppliers prMVFields = inputs.prMVFields;
        String serviceChargeName = inputs.serviceChargeName;
        String serviceChargeCode = inputs.serviceChargeCode;
        String parentAccountPrimarySegment = inputs.parentAccountPrimarySegment;
        Pricing_Request__c pricingRequest = inputs.pricingRequest;
        String quoteType = inputs.quoteType;
        String shippingCountry = inputs.shippingCountry;
        SBQQ__QuoteLine__c quoteLineRecord = inputs.quoteLineRecord;
        Id bundleId = inputs.bundleId;
        
        //Get metadata
        List<Pricing_Response_Process_Quote_Line__mdt> processQuoteLineMetadata = inputs.processQuoteLineMetadata;
        
        String priceType = pricingRequest.Pricing_Type__c;	//Get Pricing Type. Standard Pricing = AM, Price Only = AMPO
        String vendorType = prMVFields.costSource;		//Get Vendor Type. Contains 'WM' for WM vendors. Otherwise it is a Third Party vendor
        String marketType = prMVFields.contractType;		//Get Market Type. Open or Closed market
        //String equipmentType = prMVFields.equipmentCode;	//Get Equipment Type CMP, OT etc 14-May-2025-Commented for defect SDT-47976
        String equipmentType = inputs.equipmentName;		//TCS-pkulkarn-14-May-2025-Change to equipmentName for defect SDT-47976
        
        Boolean matchingMetadataFound = false;
        Boolean manyallyProcuredService = false;
        
        if(vendorType.contains(Pricing_Constant_Util.WM_VENDOR) == false)
        {
            vendorType = sVendorTypeThirdParty;
        }
        
        /***************************************************PROCESSING LOGIC HERE***************************************************/
        if(prMVFields != null && prMVFields.serviceCharges != null){
            for(Integer scIndex = 0; scIndex < prMVFields.serviceCharges.size(); scIndex++)	//Loop through Service Charges on the Pricing Request
            {
                if(prMVFields.serviceCharges[scIndex].name.containsIgnoreCase(serviceChargeName))
                {
                    //Get Metadata record for given Service Charge name
                    for(Pricing_Response_Process_Quote_Line__mdt metadataRecord : processQuoteLineMetadata)		//Loop through the Metadata records 
                    {
                        if(prMVFields.serviceCharges[scIndex].name.containsIgnoreCase(metadataRecord.Service_Charge_Name__c))	//Metadata record found
                        {
                            
                            // if(priceType == priceTypePriceOnlyAPIName)		//AMPO = Price Only
                            // {
                            //     //Determine if manually procured
                            //     manyallyProcuredService = determineMultiVendorManuallyProcuredService(metadataRecord.Service_Charge_Name__c, serviceChargeCode, inputs);
                            // }
                            
                            //Check conditions for matching metadata record	//Add conditions for Procurement Type
                            if(vendorType.containsIgnoreCase(metadataRecord.Vendor_Type__c)
                            && marketType.equalsIgnoreCase(metadataRecord.Market_Type__c)
                            && matchingExpression(shippingCountry, metadataRecord.Shipping_Country__c)
                            && quoteType.equalsIgnoreCase(metadataRecord.Quote_Type__c)
                            && matchingExpression(metadataRecord.Equipment__c, equipmentType)
                            && matchingExpression(metadataRecord.Parent_Account_Primary_Segment__c, parentAccountPrimarySegment)
                            && metadataRecord.Price_Type__c.equalsIgnoreCase(UTIL_Picklist.getPickListLabelByAPIValue('Pricing_Request__c', 'Pricing_Type__c', priceType))
                            )
                            {
                                if(metadataRecord.Price_Type__c == priceTypeStandard)
                                {
                                    if(prMVFields.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ALLOW || prMVFields.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ADJUST
                                    || prMVFields.serviceCharges[scIndex].actionName == Pricing_Constant_Util.MANUAL_REVIEW)
                                    {
                                        outputs.overrideAction = true;
                                        outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                        outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;
                                        outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;
                                        matchingMetadataFound = true;
                                    }
                                    else if(prMVFields.serviceCharges[scIndex].actionName == Pricing_Constant_Util.EXCLUDE)
                                    {
                                        outputs.overrideAction = true;
                                        outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                        outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;
                                        outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;
                                        matchingMetadataFound = true;
                                    }
                                }
                                // else if(metadataRecord.Price_Type__c == priceTypePriceOnly)
                                // {
                                // 	String manullyProcuredString = manyallyProcuredService ? 'Yes' : 'No';
                                //     if(metadataRecord.Manually_Procured__c.equalsIgnoreCase(manullyProcuredString) || metadataRecord.Manually_Procured__c == 'Any')
                                //     {
                                //         if(prMVFields.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ALLOW || prMVFields.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ADJUST)
                                //         {
                                //             outputs.overrideAction = true;
                                //             outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                //             outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;
                                //             outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;                                        
                                //             matchingMetadataFound = true;
                                //         }
                                //         else if(prMVFields.serviceCharges[scIndex].actionName == Pricing_Constant_Util.EXCLUDE)
                                //         {
                                //             outputs.overrideAction = true;
                                //             outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                //             outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;                                        
                                //             outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;
                                //             matchingMetadataFound = true;
                                //             system.debug('PK Std PR Dev' + metadataRecord.DeveloperName);
                                //         }
                                //     }
                                // }
                            }
                        }
                        if(matchingMetadataFound == true)
                        {
                            return outputs;
                        }
                    }
                }
            }
        }        

		if(matchingMetadataFound == false)
        {
            outputs.overrideAction = outputs.createQuoteLine = outputs.updateQuoteLine = outputs.deleteQuoteLine = false;
        }
        return outputs;
    }
    //Multi-vendor Pricing Response Processing
    //Caller: PricingResponseProcessor.determineQuoteLineAction()
    //Purpose : To determine what action is needed for the Service Charge based additional processing
    //public Boolean determineMultiVendorManuallyProcuredService(String serviceChargeName, String serviceChargeCode, Id quoteId, SBQQ__QuoteLine__c quoteLineRecord, Id bundleId)
    private Boolean determineMultiVendorManuallyProcuredService(String serviceChargeName, String serviceChargeCode, PricingResponseProcessor.serviceChargeActionInput inputs)
    {
        system.debug('PK Std Manual ' + serviceChargeName);
        Id quoteId = inputs.pricingRequest.Quote__c;
        SBQQ__QuoteLine__c quoteLineRecord = inputs.quoteLineRecord;
        Id bundleId = inputs.bundleId;
        List<Pricing_Request__c> stdPricingRequestList = inputs.stdPricingRequestList;
        Boolean manuallyProcured = false;
        
        if(quoteLineRecord == null)
        {
            return manuallyProcured;
        }

        List<Pricing_Request__c> pricingRequest = new List<Pricing_Request__c>();
        for(Pricing_Request__c stdPR : stdPricingRequestList)
        {
            if(stdPR.Quote_Line_Bundle__c == bundleId)
            {
                pricingRequest.add(stdPR);
                system.debug('PK Std Pr ID ' + stdPR.Id);
            }
        }
        
        PricingRequestFieldsMetadata.suppliers prMVFields = inputs.prMVFields;
        if(pricingRequest.size() == 1 && (prMVFields != null && prMVFields.serviceCharges != null && prMVFields.serviceCharges.size() > 0))
        {
            //Standard Pricing response successful
            if(pricingRequest[0].IsCaseError__c == false && pricingRequest[0].isAPIResult__c == true)
            {
                for(Integer scIndex = 0; scIndex < prMVFields.serviceCharges.size(); scIndex++)
                {
                    if(prMVFields.serviceCharges[scIndex].name.contains(serviceChargeName))
                    {
                        system.debug('PK Std C' + quoteLineRecord.SBQQ__ProductCode__c + '=' + serviceChargeCode);
                        system.debug('PK Std C' + quoteLineRecord.SBQQ__UnitCost__c + '=' + prMVFields.serviceCharges[scIndex].cost);
                        system.debug('PK Std C' + pricingRequest[0].Vendor_Code__c + '=' + quoteLineRecord.Vendor__r.Vendor_ID__c);
                        //Cost and Vendor matching means Successful procurement                        
                        if(quoteLineRecord.SBQQ__ProductCode__c ==  serviceChargeCode &&
                           quoteLineRecord.SBQQ__UnitCost__c == prMVFields.serviceCharges[scIndex].cost &&
                           pricingRequest[0].Vendor_Code__c.contains(quoteLineRecord.Vendor__r.Vendor_ID__c)
                          )
                        {
                            manuallyProcured = false;
                        }
                        else
                        {
                            manuallyProcured = true;
                        }
                    }
                }
            }
            //Standard Pricing response unsuccessful
            else
            {
                manuallyProcured = true;
            }
        }
        else
        {
            manuallyProcured = true;
        }
        //system.debug('PK' + quoteLineRecord.SBQQ__ProductCode__c + manuallyProcured);
        return manuallyProcured;
    }

    //Caller:
    //Purpose : To determine what action is needed for the Service Charge based additional processing
    public serviceChargeActionOutput determineQuoteLineAction(serviceChargeActionInput inputs)
    {
        //Output variable
        serviceChargeActionOutput outputs = new serviceChargeActionOutput();
        
        //Check for code switch
        Boolean isSpecMappingDisabled = CodeSwitchUtility.getCodeSwitchOn('Spec_Mapping');
        if(isSpecMappingDisabled == true)
        {
        	outputs.overrideAction = outputs.createQuoteLine = outputs.updateQuoteLine = outputs.deleteQuoteLine = false;
        	return outputs;
        }
        
        //Retrieve inputs into local variables
        PricingReportingFieldsMetadata prFields = inputs.prFields;
        String serviceChargeName = inputs.serviceChargeName;
        String serviceChargeCode = inputs.serviceChargeCode;
        String parentAccountPrimarySegment = inputs.parentAccountPrimarySegment;
        Pricing_Request__c pricingRequest = inputs.pricingRequest;
        String quoteType = inputs.quoteType;
        String shippingCountry = inputs.shippingCountry;
        SBQQ__QuoteLine__c quoteLineRecord = inputs.quoteLineRecord;
        Id bundleId = inputs.bundleId;
        Boolean isPricingMulltiVendorAMSwitchON = PricingRequestSelector.isPricingMulltiVendorAMSwitchON();
        
        //Get metadata
        List<Pricing_Response_Process_Quote_Line__mdt> processQuoteLineMetadata = inputs.processQuoteLineMetadata;
        
        String priceType = pricingRequest.Pricing_Type__c;	//Get Pricing Type. Standard Pricing = AM, Price Only = AMPO
        String vendorType = prFields.Data.costSource;		//Get Vendor Type. Contains 'WM' for WM vendors. Otherwise it is a Third Party vendor
        String marketType = prFields.Data.contractType;		//Get Market Type. Open or Closed market
        //String equipmentType = prFields.Data.equipmentCode;	//Get Equipment Type CMP, OT etc 14-May-2025-Commented for defect SDT-47976
        String equipmentType = prFields.Data.equipmentName;		//TCS-pkulkarn-14-May-2025-Change to equipmentName for defect SDT-47976
        
        Boolean matchingMetadataFound = false;
        Boolean manyallyProcuredService = false;
        
        if(vendorType.contains(Pricing_Constant_Util.WM_VENDOR) == false)
        {
            vendorType = sVendorTypeThirdParty;
        }
        
        /***************************************************PROCESSING LOGIC HERE***************************************************/
        
        for(Integer scIndex = 0; scIndex < prFields.Data.serviceCharges.size(); scIndex++)	//Loop through Service Charges on the Pricing Request
        {
            if(prFields.Data.serviceCharges[scIndex].name.containsIgnoreCase(serviceChargeName))
            {
                //Get Metadata record for given Service Charge name
                for(Pricing_Response_Process_Quote_Line__mdt metadataRecord : processQuoteLineMetadata)		//Loop through the Metadata records 
                {
                    if(prFields.Data.serviceCharges[scIndex].name.containsIgnoreCase(metadataRecord.Service_Charge_Name__c))	//Metadata record found
                    {
                        
                        if(priceType == priceTypePriceOnlyAPIName)		//AMPO = Price Only
                        {
                            //Determine if manually procured
                            if(isPricingMulltiVendorAMSwitchON){
                                manyallyProcuredService = determineMultiVendorManuallyProcuredService(metadataRecord.Service_Charge_Name__c, serviceChargeCode, inputs);
                            }
                            else{
                                manyallyProcuredService = determineWhetherManuallyProcuredService(metadataRecord.Service_Charge_Name__c, serviceChargeCode, inputs);
                            }
                        }
                        
                        //Check conditions for matching metadata record	//Add conditions for Procurement Type
                        if(vendorType.containsIgnoreCase(metadataRecord.Vendor_Type__c)
                           && marketType.equalsIgnoreCase(metadataRecord.Market_Type__c)
                           && matchingExpression(shippingCountry, metadataRecord.Shipping_Country__c)
                           && quoteType.equalsIgnoreCase(metadataRecord.Quote_Type__c)
                           && matchingExpression(metadataRecord.Equipment__c, equipmentType)
                           && matchingExpression(metadataRecord.Parent_Account_Primary_Segment__c, parentAccountPrimarySegment)
                           && metadataRecord.Price_Type__c.equalsIgnoreCase(UTIL_Picklist.getPickListLabelByAPIValue('Pricing_Request__c', 'Pricing_Type__c', priceType))
                          )
                        {
                            if(metadataRecord.Price_Type__c == priceTypeStandard)
                            {
                                if(prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ALLOW || prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ADJUST
                                || prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.MANUAL_REVIEW)
                                {
                                    outputs.overrideAction = true;
                                    outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                    outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;
                                    outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;
                                    matchingMetadataFound = true;
                                }
                                else if(prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.EXCLUDE)
                                {
                                    outputs.overrideAction = true;
                                    outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                    outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;
                                    outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;
                                    matchingMetadataFound = true;
                                }
                            }
                            else if(metadataRecord.Price_Type__c == priceTypePriceOnly)
                            {
								String manullyProcuredString = manyallyProcuredService ? 'Yes' : 'No';
                                if(metadataRecord.Manually_Procured__c.equalsIgnoreCase(manullyProcuredString) || metadataRecord.Manually_Procured__c == 'Any')
                                {
                                    if(prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ALLOW || prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.ADJUST)
                                    {
                                        outputs.overrideAction = true;
                                        outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                        outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;
                                        outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;                                        
                                        matchingMetadataFound = true;
                                    }
                                    else if(prFields.Data.serviceCharges[scIndex].actionName == Pricing_Constant_Util.EXCLUDE)
                                    {
                                        outputs.overrideAction = true;
                                        outputs.createQuoteLine = metadataRecord.Create_Quote_Line__c;
                                        outputs.updateQuoteLine = metadataRecord.Update_Quote_Line__c;                                        
                                        outputs.deleteQuoteLine = metadataRecord.Delete_Quote_Line__c;
                                        matchingMetadataFound = true;
                                        system.debug('PK Std PR Dev' + metadataRecord.DeveloperName);
                                    }
                                }
                            }
                        }
                    }
                    if(matchingMetadataFound == true)
                    {
	                    return outputs;
                    }
                }
            }
        }

		if(matchingMetadataFound == false)
        {
            outputs.overrideAction = outputs.createQuoteLine = outputs.updateQuoteLine = outputs.deleteQuoteLine = false;
        }
        return outputs;
    }

    //Caller: PricingResponseProcessor.determineQuoteLineAction()
    //Purpose : To determine what action is needed for the Service Charge based additional processing
    //public Boolean determineWhetherManuallyProcuredService(String serviceChargeName, String serviceChargeCode, Id quoteId, SBQQ__QuoteLine__c quoteLineRecord, Id bundleId)
    private Boolean determineWhetherManuallyProcuredService(String serviceChargeName, String serviceChargeCode, PricingResponseProcessor.serviceChargeActionInput inputs)
    {
        system.debug('PK Std Manual ' + serviceChargeName);
        Id quoteId = inputs.pricingRequest.Quote__c;
        SBQQ__QuoteLine__c quoteLineRecord = inputs.quoteLineRecord;
        Id bundleId = inputs.bundleId;
        List<Pricing_Request__c> stdPricingRequestList = inputs.stdPricingRequestList;
        Boolean manuallyProcured = false;
        
        if(quoteLineRecord == null)
        {
            return manuallyProcured;
        }

        List<Pricing_Request__c> pricingRequest = new List<Pricing_Request__c>();
        for(Pricing_Request__c stdPR : stdPricingRequestList)
        {
            if(stdPR.Quote_Line_Bundle__c == bundleId)
            {
                pricingRequest.add(stdPR);
                system.debug('PK Std Pr ID ' + stdPR.Id);
            }
        }
        
        PricingReportingFieldsMetadata prFields;
        if(pricingRequest.size() == 1)
        {
            //Standard Pricing response successful
            if(pricingRequest[0].IsCaseError__c == false && pricingRequest[0].isAPIResult__c == true)
            {
                prFields = PricingReportingFieldsMetadata.parse(pricingRequest[0].APIRequestOutput__c);
                
                for(Integer scIndex = 0; scIndex < prFields.Data.serviceCharges.size(); scIndex++)
                {
                    if(prFields.Data.serviceCharges[scIndex].name.contains(serviceChargeName))
                    {
                        system.debug('PK Std C' + quoteLineRecord.SBQQ__ProductCode__c + '=' + serviceChargeCode);
                        system.debug('PK Std C' + quoteLineRecord.SBQQ__UnitCost__c + '=' + prFields.Data.serviceCharges[scIndex].cost);
                        system.debug('PK Std C' + pricingRequest[0].Vendor_Code__c + '=' + quoteLineRecord.Vendor__r.Vendor_ID__c);
                        //Cost and Vendor matching means Successful procurement                        
                        if(quoteLineRecord.SBQQ__ProductCode__c ==  serviceChargeCode &&
                           quoteLineRecord.SBQQ__UnitCost__c == prFields.Data.serviceCharges[scIndex].cost &&
                           pricingRequest[0].Vendor_Code__c.contains(quoteLineRecord.Vendor__r.Vendor_ID__c)
                          )
                        {
                            manuallyProcured = false;
                        }
                        else
                        {
                            manuallyProcured = true;
                        }
                    }
                }
            }
            //Standard Pricing response unsuccessful
            else
            {
                manuallyProcured = true;
            }
        }
        else
        {
            manuallyProcured = true;
        }
        //system.debug('PK' + quoteLineRecord.SBQQ__ProductCode__c + manuallyProcured);
        return manuallyProcured;
    }
    
    //Caller: PricingResponseProcessor.determineQuoteLineAction()
    //Purpose : To check if given value is present in the expression
    private Boolean matchingExpression(String sExpression, String sFieldvalue)
    {
        Boolean result = false;
        system.debug('PK Compare' + sExpression + sFieldvalue);
        if(sExpression.containsIgnoreCase('NOT_IN'))
        {
            result = sExpression.containsIgnoreCase(sFieldvalue) ? false : true;
        }
        else if(sExpression.containsIgnoreCase('IN'))
        {
            result = sExpression.containsIgnoreCase(sFieldvalue)? true : false;
        }
        else if(sExpression.equalsIgnoreCase('Any'))
        {
            result = true;
        }
        else if(sExpression.equalsIgnoreCase(sFieldvalue))
        {
            result = true;
        }
        return result;
    }
    
    //Caller: PriceOnlyRequestSTPProcess.savePricetoQuoteline()
    //Caller: PricingRequestSTPProcess.quoteLineProcess()
    //Purpose : To retrieve metadata records
    public List<Pricing_Response_Process_Quote_Line__mdt> retrieveProcessQuoteLineMetadata(List<Pricing_Response_Process_Quote_Line__mdt> metadata)
    {
        //Query metadata
        if(metadata.size() == 0 || metadata == null)
        {
            List<Pricing_Response_Process_Quote_Line__mdt> processQuoteLineMetadata = [SELECT Id, DeveloperName, Service_Charge_Name__c, Create_Quote_Line__c, Update_Quote_Line__c, Delete_Quote_Line__c, Vendor_Type__c,
                                                                                       Market_Type__c, Equipment__c, Price_Type__c, Quote_Type__c, Parent_Account_Primary_Segment__c, Shipping_Country__c, Manually_Procured__c
                                                                                       FROM Pricing_Response_Process_Quote_Line__mdt 
                                                                                      ];
            return processQuoteLineMetadata;
        }
        else
        {
            return metadata;
        }
    }
    
    //Caller: PriceOnlyRequestSTPProcess.savePricetoQuoteline()
    //Caller: PricingRequestSTPProcess.quoteLineProcess()
    //Purpose : To retrieve metadata records
    /*public void processQuoteLineInsertOrUpdate(SBQQ__QuoteLine__c quoteLine, List<SBQQ__QuoteLine__c> quoteLineList, PricingResponseProcessor.serviceChargeActionOutput pricingResponseProcessorOutput, PricingSTP__mdt pricingMetadataRecord)
    {
        if(pricingMetadataRecord.Additional_Processing_Needed__c == false)
        {
            quoteLineList.add(quoteLine);
        }
        else if(pricingResponseProcessorOutput.overrideAction)
        {
            if(pricingResponseProcessorOutput.createQuoteLine || pricingResponseProcessorOutput.updateQuoteLine)
            {
                quoteLineList.add(quoteLine);
            }
        }
        else
        {
            quoteLineList.add(quoteLine);
        }
    }
    
    //Caller: PriceOnlyRequestSTPProcess.savePricetoQuoteline()
    //Caller: PricingRequestSTPProcess.quoteLineProcess()
    //Purpose : To retrieve metadata records
    public void processQuoteLineDelete(SBQQ__QuoteLine__c quoteLine, List<SBQQ__QuoteLine__c> quoteLineList, PricingResponseProcessor.serviceChargeActionOutput pricingResponseProcessorOutput, PricingSTP__mdt pricingMetadataRecord)
    {
        if(pricingMetadataRecord.Additional_Processing_Needed__c == false)
        {
            quoteLineList.add(quoteLine);
        }
        else if(pricingResponseProcessorOutput.overrideAction)
        {
            if(pricingResponseProcessorOutput.createQuoteLine || pricingResponseProcessorOutput.updateQuoteLine)
            {
                quoteLineList.add(quoteLine);
            }
        }
        else
        {
            quoteLineList.add(quoteLine);
        }
    }*/
}
