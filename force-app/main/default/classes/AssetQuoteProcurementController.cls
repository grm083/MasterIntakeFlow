//Class: AssetQuoteProcurementController
//Purpose: To return and manipulate data for Add Change/ Asset related objects
//in accordance with the business process
//Author: Anup Dey
//Date: 4/7/2022

public class AssetQuoteProcurementController {
    
    // Private variable
    public static set<string> wasteCategorySet = new set<string>{'Waste Stream', 'Waste Category'};

    // method to get the Case Asset and Quote information from Quote
    // sdt-37527 field added Material_Grade
    @AuraEnabled
    public static SBQQ__Quote__c getQuoteStatusDetails(Id quoteId) {
        SBQQ__Quote__c q = [SELECT Id, SBQQ__Status__c, Assigned_To__r.Name, Quote_Only__c,SBQQ__Opportunity2__r.Case__r.Asset.Material_Grade__c, 
                            SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Phone, SBQQ__Opportunity2__r.Case__c, 
                            Project__c,Project__r.Name, Project_Services_Request__c, QuoteProcuredStatus__c
                            ,SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Product__c , SBQQ__Opportunity2__r.Case__r.AssetId
                            ,SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Material__c, SBQQ__Opportunity2__r.Case__r.Asset.Acorn_SID__c,SBQQ__Opportunity2__r.Case__r.Asset.Equipment_Size__c,
                            SBQQ__Opportunity2__r.Case__r.RecordType.Name
                            FROM SBQQ__Quote__c
                            WHERE Id =: quoteId
                            LIMIT 1];
        
        return q;
    }

    //Method to check if quote lines exists for respective product
    @AuraEnabled 
    public static List<SBQQ__QuoteLine__c> checkAssetQuoteLines(Id quoteId, Id cpqProductId){
        system.debug('quoteId>>'+ quoteId);
        system.debug('cpqProductId>>'+ cpqProductId);
        //SDT33101 adding ,SBQQ__Quote__r.SBQQ__Type__c
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Product__r.Name, SBQQ__Product__r.ProductCode, SBQQ__RequiredBy__c,SBQQ__Product__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Asset.Acorn_SID__c, toLabel(Equipment_Size__c), SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Material__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Material__r.ProductCode, SID__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quoteId  AND SBQQ__RequiredBy__c =''];
        system.debug('quoteLines>>'+ quoteLines);
        return quoteLines;
    }

    // get Asset Headers for Tab
    @AuraEnabled
    public static List<assetHeaderModel> getQuoteAssetHeaders(String caseId) {
        List<Asset> assetHeaders = null;
        Set<Id> headerIds = new Set<Id>();
        Set<Id> highlightIds = new Set<Id>();
        List<assetHeaderModel> wrapperList = new List<assetHeaderModel>();
        String recordType = Constant_Util.SERVICE_HEADER;
        String detailRecordType = Constant_Util.SERVICE_DETAILS;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        Case currentCase = Database.query('select AssetId,ParentId,Location__c,CaseNumber,Reference_Number__c,Is_Multiple_Asset__c from case where id = :caseId limit 1');
        String locationId = currentCase.Location__c;
        
        if(locationId != null){
            assetHeaders = Database.query('select id,Name,Active__c,Acorn_SID__c,Material_Type__c,Material_Grade__c, Equipment_Type__c,Equipment_Size__c, CPQ_Material__c, CPQ_Product__c,CPQ_Material__r.ProductCode, CPQ_Product__r.ProductCode from asset where AccountId = :locationId and RecordType.DeveloperName = :recordType');
            //SDT-37527 field added-Material_Grade
            List<Case> caseList = new List<Case>();
            caseList = [SELECT id,AssetId,ParentId,Is_Multiple_Asset__c 
                        FROM Case
                        WHERE Reference_Number__c =: currentCase.Reference_Number__c 
                        AND Location__c = : currentCase.Location__c 
                        AND id !=: currentCase.Id];

            for(Case cse : caseList){ //and Is_Multiple_Asset__c = true 
                if(cse.AssetId != null && cse.Is_Multiple_Asset__c 
                    && currentCase.Is_Multiple_Asset__c 
                    && cse.ParentId==currentCase.ParentId){
                    highlightIds.add(cse.AssetId);
                }
            }

            if(currentCase.AssetId != null){
                highlightIds.add(currentCase.AssetId);
            }

            if(sessionPart.contains(caseId)){
                String[] assets= (String[])sessionPart.get(caseId);
                for(String s : assets){
                    highlightIds.add(s);
                }
            }
        }   

        // for(Asset asset : assetHeaders){
        //     headerIds.add(asset.Id);
        // }
        
        if(!assetHeaders.isEmpty()){
            for(Asset asset : assetHeaders){
                assetHeaderModel recordWrap = new assetHeaderModel();
                recordWrap.assetId = asset.Id;
                recordWrap.assetName = asset.Name;
                recordWrap.Acorn_SID = asset.Acorn_SID__c;
                recordWrap.Material_Type = asset.Material_Type__c;
                recordWrap.Equipment_Type = asset.Equipment_Type__c;
                recordWrap.Equipment_Size = asset.Equipment_Size__c;
		        recordWrap.Material_Grade = asset.Material_Grade__c; //sdt-37527
                recordWrap.CPQ_Material = asset.CPQ_Material__c;
                recordWrap.CPQ_Product = asset.CPQ_Product__c;
                recordWrap.ProductCode = asset.CPQ_Product__r.ProductCode;
                recordWrap.MaterialCode = asset.CPQ_Material__r.ProductCode;
                if(highlightIds.contains(asset.Id)){
                    wrapperList.add(recordWrap);
                }
            }
        }
        system.debug('wrapperList '+wrapperList.size());

        return wrapperList;
    }

    
    //Get Waste Category product from select product 
    public static Map<Id,SBQQ__ProductOption__c> getAssetCategoryOptions(String productId) {

        List<SBQQ__ProductOption__c> wasteCategoryOptionsList=[SELECT Id, Name, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.ProductCode,
        SBQQ__Quantity__c, Occurrence_Type__c, CostModelType__c,
        Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c, Frequency_Interval__c 
        FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c =:productId AND SBQQ__ProductFamily__c = 'Waste Category' 
        And SBQQ__OptionalSKU__r.IsActive = true AND SBQQ__ConfiguredSKU__r.IsActive = true];
        SBQQ__ProductOption__c categoryOption;
        Map<Id,SBQQ__ProductOption__c> wasteCategoryCodeCatergoryOptionsMap = new Map<Id,SBQQ__ProductOption__c>(); 
        for(SBQQ__ProductOption__c catobj: wasteCategoryOptionsList)
        { 
             wasteCategoryCodeCatergoryOptionsMap.put(catobj.SBQQ__OptionalSKU__c, catobj);
        } 

        return wasteCategoryCodeCatergoryOptionsMap;

    }

    // Method to get the PickList entry by Label
    public static String getPicklistEntryByLabel(List<Schema.PicklistEntry> picklistEntries, String searchString)
    {
        String result;
        if(searchString!='')
        {
            for(Schema.PicklistEntry pe :picklistEntries){
                if(pe.getLabel() == searchString){
                    result= pe.getValue();
                    break;
                }
            }
        }
        return result;
    }

    // Method to get the PickList entry by API Name
    public static String getPicklistEntryByAPIName(List<Schema.PicklistEntry> picklistEntries, String searchString)
    {
        String result;
        if(searchString!='')
        {
            for(Schema.PicklistEntry pe :picklistEntries){
                if(pe.getValue() == searchString){
                    result= pe.getValue();
                    break;
                }
            }
        }
        return result;
    }


    // Creating quote line from Asset Product
    @AuraEnabled 
    public static List<assetProductResponseModel> createBulkAssetQuoteLines(List<assetProductRequestModel> assetProducts){

        //system.debug('assetProducts >>'+ assetProducts);
        List<assetProductResponseModel> responseModels = new List<assetProductResponseModel>();
        for(assetProductRequestModel assetProduct : assetProducts)
        {
            assetProductResponseModel responseModel = new assetProductResponseModel();
            responseModel.productId = assetProduct.productId;
            responseModel.assetId = assetProduct.assetId;
            responseModel.quoteLineId = createAssetQuoteLines(assetProduct.assetId, assetProduct.quoteId, assetProduct.productId, assetProduct.wastestreamId, assetProduct.equipmentSize);
            responseModels.add(responseModel);
        }
        //system.debug('responseModels>>'+ responseModels);
        return responseModels;
    }

    //Update the quote status
    @AuraEnabled
    public static String updateStatus(Id quoteId, String newStatus, Boolean quoteOnly) {
        String result = QuoteProcurementController.updateStatus(quoteId,newStatus,quoteOnly);
        return result;
    }

    // Creating quote line from Asset Product
    //@AuraEnabled 
    public static String createAssetQuoteLines(Id assetId,Id quoteId, Id productId, Id wastestreamId, String equipmentSize){
        system.debug('wastestreamId>>'+ wastestreamId);
        system.debug('assetId >>'+ assetId);
        
        // Disabling QL Copy from Bundle On Insertion
        QuoteLineServices.DISABLE_QL_COPY_FROM_BUNDLE_ONINSERT = true;

        String successMessage;
        Id projectCode; 
        
        // Local Variables
        //List<SBQQ__ErrorCondition__c> errorConditions = new List<SBQQ__ErrorCondition__c>();
        //Set<Id> actionIds = new Set<Id>();
        //Set<Id> addProducts = new Set<Id>();
        Set<Id> remProducts = new Set<Id>();
        List<SBQQ__QuoteLine__c> newLines = new List<SBQQ__QuoteLine__c>();
        
        //Get Product 
        Map<Id,SBQQ__ProductOption__c> categoryOptions = getAssetCategoryOptions(productId);

        // TransformationHelper for mapping 
        TransformationHelper transformationHelper = new TransformationHelper();
        //Get Product Option for WasteStream
        //SBQQ__ProductOption__c materialOption = QuoteProcurementController.getMaterialOption(productOptions.Id);

        SBQQ__ProductOption__c categoryOption; 
        SBQQ__ProductOption__c materialOption; 
        List<SBQQ__ProductOption__c> materialOptionList = [SELECT Id, Name, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ConfiguredSKU__c,
        SBQQ__ConfiguredSKU__r.ProductCode, SBQQ__Quantity__c, Occurrence_Type__c, CostModelType__c,
        Cost_Unit_of_Measure__c, PriceUOM__c, Schedule_Frequency__c, Frequency_Interval__c FROM SBQQ__ProductOption__c Where SBQQ__OptionalSKU__c=: wastestreamId 
        AND SBQQ__ProductFamily__c = 'Waste Stream' And SBQQ__OptionalSKU__r.IsActive = true AND SBQQ__ConfiguredSKU__r.IsActive = true]; 

        for(SBQQ__ProductOption__c matObj: materialOptionList)
        { 
            if(categoryOptions.containsKey(matObj.SBQQ__ConfiguredSKU__c))
            { 
                materialOption = matObj; 
                categoryOption = categoryOptions.get(matObj.SBQQ__ConfiguredSKU__c); 
                break; 
            }
         }
        system.debug('materialOption>>'+ materialOption);
        system.debug('categoryOption>>'+ categoryOption);

        Decimal quoteLineNumber = QuoteProcurementController.getMaxQuoteLineNumber(quoteId);
        
        Decimal parentLineNumber;
        String wasteCategoryId;
        // Get the Asset Details to create the quotelines
        // SDT-38285 - Added Month_Relative_Interval__c and Month_Relative__c
        // SDT33378 adding filter and End_Date__c=null
        //Added Supplier__r.Parent_Vendor_ID__c for story SDT-39662
        List<Asset> assetDetails = [Select Id,AccountId,ParentId,RootAssetId,ProductCode,ProductFamily,ProductDescription,Description,Name,Status,Price,Quantity,LocationId,Duration__c,Location__c,Acorn_SBID__c,Acorn_SID__c,BusinessUnit_Name__c,Bypass_MAS__c,Category__c,Container_Position__c,Contract_Notes__c,Cost_Center__c,Cost_Increment_1__c,Cost_Increment_2__c,Cost_Increment_3__c,Cost_Increment_4__c,Cost_Minimum_Quantity__c,Cost_Model_Type__c,Cost_Price_1__c,Cost_Price_2__c,Cost_Price_3__c,Cost_Price_4__c,Cost_Unit__c,Cost_UpTo_1__c,Cost_UpTo_2__c,Cost_UpTo_3__c,Cost_UpTo_4__c,Cost__c,End_Date__c,Equipment_Owner__c,Equipment_Size__c,Equipment_Type__c,Exception_Comments__c,SBQQ__RequiredByProduct__c, Exception_Effective_Date__c,Exception_Reason_Detail__c,Exception_Reason__c,Frequency__c,Friday__c,GL_Code__c,Has_Extra_Pickup__c,Is_Active__c,Is_Core_Service__c,Is_Hold_Until_Posted__c,Is_Locally_Billed__c,Location_Code__c,MAS_Account_Number__c,MAS_Company_Code__c,MAS_Customer_Unique_Id__c,MAS_Library__c,MAS_Line_Number__c,MAS_Setup_Comment__c,MAS_VCR_Code__c,Material_Grade__c, Material_Grade_Code__c,Material_Type__c,Monday__c,Monitored__c,Occurrence_Type__c,Occurs__c,Of_Month__c,Price_Increment_1__c,Price_Increment_2__c,Price_Increment_3__c,Price_Increment_4__c,Price_Minimum_Quantity__c,Price_Model_Type__c,Price_Price_1__c,Price_Price_2__c,Price_Price_3__c,Price_Price_4__c,Price_Tax_Inclusive__c,Price_Unit__c,Price_UpTo_1__c,Price_UpTo_2__c,Price_UpTo_3__c,Price_UpTo_4__c,Price__c,Project__c,Quantity__c,Saturday__c,Schedule_A_Override__c,Schedule__c,Sensitivity_Code__c,Service_Type__c,Start_Date__c,Sunday__c,Supplier__c,Supplier__r.Parent_Vendor_ID__c,Thursday__c,Tuesday__c,Vendor_Account_Number__c,Vendor_BU__c,Vendor_ID__c,Vendor_Service_Number__c,Waste_Profile__c,Wednesday__c,Weekly_Frequency__c,Active__c,Project_Code__c,Schedule_Type__c,SBQQ__AdditionalDiscountAmount__c,SBQQ__BillingFrequency__c,SBQQ__BillingType__c,SBQQ__Bundle__c,SBQQ__BundledQuantity__c,SBQQ__Bundled__c,SBQQ__ChargeType__c,SBQQ__ComponentDiscountedByPackage__c,SBQQ__DiscountScheduleType__c,SBQQ__Discount__c,SBQQ__DistributorDiscount__c,SBQQ__DynamicOptionId__c,SBQQ__ListPrice__c,SBQQ__MarkupAmount__c,SBQQ__MarkupRate__c,SBQQ__Number__c,SBQQ__OptionDiscountAmount__c,SBQQ__OptionDiscount__c,SBQQ__OptionLevel__c,SBQQ__OptionType__c,SBQQ__OriginalUnitCost__c,SBQQ__PackageProductCode__c,SBQQ__PackageProductDescription__c,SBQQ__PartnerDiscount__c,SBQQ__PricingMethod__c,SBQQ__ProductOption__c,SBQQ__QuoteLine__c,SBQQ__RegularPrice__c,SBQQ__SegmentIndex__c,SBQQ__SegmentKey__c,SBQQ__SegmentLabel__c,SBQQ__TermDiscountSchedule__c,SBQQ__UnitCost__c,CPQ_Product__c,CPQ_Material__c, RecordType.DeveloperName , Account_Position__c, MASBox__c, CPQ_Product__r.Name, Month_Relative_Interval__c, Month_Relative__c from asset where RootAssetId=:assetId and End_Date__c=null Order BY CPQ_Product__r.Name, Start_Date__c DESC]; //and RecordType.DeveloperName =: Constant_Util.SERVICE_DETAILS //and Is_Active__c=true
        //system.debug('assetDetails >>'+ assetDetails);
        
        Set<Id> assetProducts = new Set<id>();
        Map<Id, List<Asset>> productAssetMap = new Map<Id, List<Asset>>();
        Asset assetHeader= new Asset();
        for(Asset asset: assetDetails)
        {
            // To get the Asset Header
            if(asset.RecordType.DeveloperName == Constant_Util.SERVICE_HEADER)
                assetHeader = asset;

            // To get the Product from CPQ product
            if(asset.RecordType.DeveloperName == Constant_Util.SERVICE_DETAILS && asset.CPQ_Product__c != null)
            {
                assetProducts.add(asset.CPQ_Product__c);

                // Changes for 25617
                if(productAssetMap.containsKey(asset.CPQ_Product__c))
                {
                    List<Asset> assetlist =  productAssetMap.get(asset.CPQ_Product__c);
                    assetlist.add(asset);
                    productAssetMap.put(asset.CPQ_Product__c,assetlist);
                }
                else{
                    productAssetMap.put(asset.CPQ_Product__c,new List<Asset> {asset});
                }
            }
        }

        Map<Id, Id> assetProductOptionMap = new Map<Id, Id>();
        List<Asset> filteredAssetList = new List<Asset>();
        // get the Product options for Service Details
        List<SBQQ__ProductOption__c> serviceproductOptions= [Select Id, SBQQ__OptionalSKU__c, SBQQ__ConfiguredSKU__c, Name, SBQQ__OptionalSKU__r.Name, Core_Service__c, SBQQ__Feature__r.Name, SBQQ__ProductCode__c    from SBQQ__ProductOption__c Where SBQQ__ConfiguredSKU__c =: productId AND SBQQ__OptionalSKU__c  IN: assetProducts];
        //system.debug('serviceproductOptions > '+ serviceproductOptions.size());
        for(SBQQ__ProductOption__c productOption: serviceproductOptions)
        {
            assetProductOptionMap.put(productOption.SBQQ__OptionalSKU__c,productOption.Id);
        }
        //system.debug('assetProductOptionMap >'+ assetProductOptionMap);

        // Changes for 25617
        //iterating over all the Products using keyset(product) of productAssetMap
        for(Id idValue : productAssetMap.keyset())
        {
            // Get the product Option from Product
            Id assetoptionId = assetProductOptionMap.get(idValue);
            SBQQ__ProductOption__c filteredProductOption = new SBQQ__ProductOption__c();
            for(SBQQ__ProductOption__c productOption: serviceproductOptions)
            {
                if(productOption.Id == assetoptionId)
                {
                    filteredProductOption = productOption;
                    break;
                }
            }
            // checking if key-product exists in both Maps
            if(productAssetMap.containsKey(idValue) && productAssetMap.get(idValue).size() > 0)
            {
                List<Asset> assetList = productAssetMap.get(idValue);
                if(assetList != null && !assetList.isEmpty())
                {
                    Asset filteredAsset =assetList[0];
                    // In case of Core Service pick the latest one including Past, Current and Future
                    if(filteredProductOption !=null && filteredProductOption.Core_Service__c)
                    {
                        //TCS-pkulkarn-25-Aug-2023-Added for SDT-31259
                        if(assetList.size() > 1)
                        {
                        	Asset asset = retrieveLatestAssetFromList(assetList);
                        	if(asset != null)
                                filteredAssetList.add(asset);
                            else
                                filteredAssetList.add(filteredAsset);
                        }
                        else
                        {
                            if(assetList != null && filteredAsset != null)		//TCS-pkulkarn-25-Aug-2023-Moved the two lines into else {} Added for SDT-31259
                                filteredAssetList.add(filteredAsset);
                        }
                        //TCS-pkulkarn-25-Aug-2023-End
                    }
                    else
                    {
                        // SDT-31973
                        //Logic for Key product because we may need multiple Key line
                        //TCS-pkulkarn-SDT-33180-Removed the IF condition check for Keys and the else part, as All active non-core services need to be quote lined
                        //If multiple active services exist (non core services like fees, keys etc), the select all the active ones for creation of quote line
                        
                            for(Asset keyAsset: assetList)
                            {
                                if(keyAsset != null && keyAsset.End_Date__c == null)
                                    filteredAssetList.add(keyAsset);

                                else if(keyAsset != null && (keyAsset.End_Date__c != null && keyAsset.End_Date__c >= Date.Today()))
                                    filteredAssetList.add(keyAsset);
                            }

                        //TCS-pkulkarn-SDT-33180-End
                        
                    }
                }
            }
        }
        assetDetails= filteredAssetList;

        // get the Asset QuoteLine Mapping from MetaData
        List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings = [SELECT AssetDataType__c,AssetField__c,AssetFieldValue__c,IsActive__c,QuoteLineField__c,QuoteLineFieldValue__c FROM Asset_Quoteline_Mapping__mdt Where IsActive__c = true]; 
        
        // Creating Parent Quoteline from Asset Header Product
        SBQQ__QuoteLine__c parentQLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                                SBQQ__Bundle__c = true,
                                                                SBQQ__Number__c = quoteLineNumber
                                                                );

        //Transform Asset header to QuoteLine
        parentQLine= transformationHelper.ConvertAssetToQuoteLineUpdated(assetHeader,parentQLine,null,false,false, assetQuoteLineMappings,false);
        parentLineNumber = quoteLineNumber;
        quoteLineNumber = quoteLineNumber + 3;
        // Assigning Project code
        projectCode = assetHeader.Project_Code__c;
        DateTime SLADate;

        try {
            insert parentQLine;
            system.debug('parent Quoteline Id'+ parentQLine.Id);
            // SLADate = QuoteFavoritesController.determineSLA(parentQLine.Id);
            // parentQLine.SBQQ__StartDate__c = SLADate.date();
            //update parentQLine;
        } catch (exception e) {
           system.debug('Error in Quoteline'+ e.getMessage());
        }

        // Product Rule Logic
        // errorConditions = SBQQConfigurationRuleService.getProductRules(productId);
        // if (errorConditions.size() > 0) {
        //     actionIds = SBQQConfigurationRuleService.getActions(errorConditions, parentQLine);
        //     addProducts = SBQQConfigurationRuleService.getAddRuleProducts(actionIds);
        // }

        // SDT-31973
        // Looping though asset detail record to insert the Parent Product first so we can use these Ids on Child
        ///*****We are using INSERT insead of UPDATE because update has more logics in triggers than insert */
        List<Asset> parentAssetProductDetails = new List<Asset>();
        List<Asset> childAssetProductDetails = new List<Asset>();
        // variables for Parent and Child Product QLs    
        Set<Id> parentProductAssetSet = new Set<Id>();
        Set<Id> childProductAssetSet = new Set<Id>();
        for(Asset asset: assetDetails)
        {
            // if Parent Product Matchs with ParentQuoteline Product (SBQQ__RequiredByProduct__c) then COnsidering those all as parent QL else Child lines
            if(asset.SBQQ__RequiredByProduct__c ==null || parentQLine.SBQQ__Product__c == asset.SBQQ__RequiredByProduct__c)
            {
                // Assigning and incrementing Line number
                asset.SBQQ__Number__c= quoteLineNumber;
                quoteLineNumber = quoteLineNumber + 1;
                // Adding Asset in Parent line
                parentAssetProductDetails.add(asset);
                // Adding Parent Product Asset Id in a set
                parentProductAssetSet.add(asset.Id);
                // Looping Over Asset Records Again To Identify Childs 
                for(Asset subasset: assetDetails)
                {
                    if(!parentProductAssetSet.contains(subasset.Id) && subasset.SBQQ__RequiredByProduct__c != null && subasset.SBQQ__RequiredByProduct__c == asset.CPQ_Product__c)
                    {
                        if(!childProductAssetSet.contains(subasset.Id))
                        {
                            // Assigning and incrementing Line number
                            subasset.SBQQ__Number__c= quoteLineNumber;
                            quoteLineNumber = quoteLineNumber + 1;
                            // Adding Asset in Child line
                            childAssetProductDetails.add(subasset);
                            // Adding Parent Product Asset Id in a set
                            childProductAssetSet.add(subasset.Id);
                        }
                    }
                }
            }
        }
        
        // SDT-31973
        List<SBQQ__QuoteLine__c> parentProductsLines = new List<SBQQ__QuoteLine__c>();
        Map<Id,Id> parentProductandQLMap = new Map<Id,Id>();
        // Looping throught Asset Detail to create the child quote line
        for(Asset asset: parentAssetProductDetails)
        {
            //system.debug('asset.CPQ_Product__c >>'+ asset.CPQ_Product__c);
            if(asset.CPQ_Product__c != null && parentQLine.Id != null && asset.RecordType.DeveloperName == Constant_Util.SERVICE_DETAILS) 
            {
                Id assetoptionId = assetProductOptionMap.get(asset.CPQ_Product__c);
                //system.debug('assetoptionId >'+ assetProductOptionMap.get(asset.CPQ_Product__c));
                SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                                    SBQQ__RequiredBy__c = parentQLine.Id,
                                                                    SBQQ__ProductOption__c = assetoptionId,
                                                                    SBQQ__OptionLevel__c =  1,
                                                                    //SBQQ__Number__c =  quoteLineNumber,
                                                                    SBQQ__Number__c =  asset.SBQQ__Number__c,
                                                                    SBQQ__CostEditable__c = true,
                                                                    SBQQ__PriceEditable__c = true
                                                                   ); 

                //Transform Asset detail to QuoteLine
                qLine= transformationHelper.ConvertAssetToQuoteLineUpdated(asset,qLine,parentQLine,true,true,assetQuoteLineMappings,false);
                
                parentProductsLines.add(qLine);
                

                // Assigning Project code
                if(projectCode==null)
                    projectCode = asset.Project_Code__c;
            }
        }
        try {
            if(parentProductsLines.size() > 0)
            {
                
                insert parentProductsLines;
                //successMessage = parentQLine.Id;
                // Looping over inserted Parent record to create a Map<product,QLId>
                for(SBQQ__QuoteLine__c ql: parentProductsLines)
                {
                    parentProductandQLMap.put(ql.SBQQ__Product__c, ql.Id);
                }
            }
        } catch (exception e) {
            System.debug('Exception-->' + e.getMessage() + 'At Line no. -->' + e.getLineNumber());
            system.debug(e.getMessage());
        }
        // Looping throught Asset Detail to create the child quote line
        for(Asset asset: childAssetProductDetails)
        {
            if(asset.CPQ_Product__c != null && parentQLine.Id != null && asset.RecordType.DeveloperName == Constant_Util.SERVICE_DETAILS) 
            {
                // Setting Required By as a Default Parent QLId
                Id requiredById = parentQLine.Id;
                // Checking if Parent Product Present
                if(parentProductsLines.size() > 0 && parentProductandQLMap != null && !parentProductandQLMap.isEmpty())
                {
                    // Assigning Parent Products QLId if Present
                    if(parentProductandQLMap.get(asset.SBQQ__RequiredByProduct__c) != null)
                        requiredById = parentProductandQLMap.get(asset.SBQQ__RequiredByProduct__c);
                    
                }
                
                Id assetoptionId = assetProductOptionMap.get(asset.CPQ_Product__c);
                SBQQ__QuoteLine__c qLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                                    SBQQ__RequiredBy__c = requiredById,
                                                                    SBQQ__ProductOption__c = assetoptionId,
                                                                    SBQQ__OptionLevel__c =  1,
                                                                    //SBQQ__Number__c =  quoteLineNumber,
                                                                    SBQQ__Number__c =  asset.SBQQ__Number__c,
                                                                    SBQQ__CostEditable__c = true,
                                                                    SBQQ__PriceEditable__c = true
                                                                   ); 

                //Transform Asset detail to QuoteLine
                qLine= transformationHelper.ConvertAssetToQuoteLineUpdated(asset,qLine,parentQLine,true,true,assetQuoteLineMappings,false);
                
                newLines.add(qLine);
                quoteLineNumber = quoteLineNumber + 1;

                // Assigning Project code
                if(projectCode==null)
                    projectCode = asset.Project_Code__c;
            }
        }
        try {
            if(newLines.size() > 0)
            {
                //SDT 48524 7/7/25 too many soql
                Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('QuotelineTriggerSwitchModifyExisting'); 
                if(codeSwitchSetting.Switch_Off__c){
                    RecurrsiveTriggerHandler.isSkipQuoteLineTrigger = true;}
                insert newLines;
            }
        } catch (exception e) {
            System.debug('Exception-->' + e.getMessage() + 'At Line no. -->' + e.getLineNumber());
            system.debug(e.getMessage());
        }

        //Creating QuoteLine for Waste Category 
        SBQQ__QuoteLine__c wasteCategoryQLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                SBQQ__Product__c = categoryOption!= null ? categoryOption.SBQQ__OptionalSKU__c : null,
                                                SBQQ__ProductOption__c = categoryOption!= null ? categoryOption.Id : null, 
                                                SBQQ__RequiredBy__c = parentQLine.Id,
                                                SBQQ__Number__c = parentLineNumber + 1,
                                                SBQQ__OptionLevel__c = 1,
                                                SBQQ__CostEditable__c = false,
                                                SBQQ__PriceEditable__c = true
                                                );
        
        //Transform waste category to QuoteLine
        wasteCategoryQLine= transformationHelper.ConvertAssetToQuoteLineUpdated(null,wasteCategoryQLine,parentQLine,true,false,assetQuoteLineMappings,false);
        if(categoryOption!= null)
        {
            wasteCategoryQLine.SBQQ__Quantity__c = categoryOption.SBQQ__Quantity__c;
            wasteCategoryQLine.CostModelType__c = categoryOption.CostModelType__c;
            wasteCategoryQLine.PriceUOM__c = categoryOption.PriceUOM__c;
        }
        
        
        try {
            insert wasteCategoryQLine;
            wasteCategoryId = wasteCategoryQLine.Id;
        } catch (exception e) {
            System.debug('Exception-->' + e.getMessage() + 'At Line no. -->' + e.getLineNumber());
            system.debug(e.getMessage());
        }

        //Creating QuoteLine for Material Type
        SBQQ__QuoteLine__c materialQLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quoteId,
                                                                SBQQ__Product__c = materialOption != null ? materialOption.SBQQ__OptionalSKU__c : null,
                                                                SBQQ__RequiredBy__c =  wasteCategoryId,
                                                                SBQQ__ProductOption__c = materialOption != null ? materialOption.Id : null,
                                                                SBQQ__OptionLevel__c = 2,
                                                                SBQQ__Number__c =  parentLineNumber + 2 ,
                                                                SBQQ__CostEditable__c =  false,
                                                                SBQQ__PriceEditable__c = false 
                                                                //AssetId__c = parentQLine.Id,
                                                                );
        
        //Transform waste material to QuoteLine
        materialQLine= transformationHelper.ConvertAssetToQuoteLineUpdated(null,materialQLine,parentQLine,true,false,assetQuoteLineMappings,false);
        if(materialOption != null)
        {
            materialQLine.SBQQ__Quantity__c = materialOption.SBQQ__Quantity__c;
            materialQLine.CostModelType__c = materialOption.CostModelType__c;
            materialQLine.PriceUOM__c = materialOption.PriceUOM__c;
        }
        
        
        try {
            insert materialQLine;
            //Logic for SDT-28899
            SBQQ__QuoteLine__c parentQL = [SELECT ID,Initial_Classification_Changes__c FROM SBQQ__QuoteLine__c where Id =:parentQLine.Id LIMIT 1];
            QuoteLineClassificationChanges.initialcChange pqLineInitialcChange = new QuoteLineClassificationChanges.initialcChange();
            if(String.isNotBlank(parentQL.Initial_Classification_Changes__c)){
                pqLineInitialcChange = pqLineInitialcChange.parse(parentQL.Initial_Classification_Changes__c);
                pqLineInitialcChange.wasteStreamMaterialType = materialOption.SBQQ__OptionalSKU__r.Name;
                parentQL.Initial_Classification_Changes__c = JSON.serialize(pqLineInitialcChange);
                update parentQL;
            }
            //End
            successMessage = parentQLine.Id;
            System.debug('materialQLine inserted' + materialQLine.Duration__c);
        } catch (exception e) {
            successMessage = e.getMessage();
            System.debug('Exception-->' + e.getMessage() + 'At Line no. -->' + e.getLineNumber());
        }

        // Updating Project Code if available
        if(projectCode!=null)
        {
            try
            {
                //Retrieve quotes by Id
                List<SBQQ__Quote__c> quotes = [SELECT id, Project__c FROM SBQQ__Quote__c WHERE Id =:quoteId ];
                
                //Loop through quote and assing project code
                for(SBQQ__Quote__c quote: quotes){
                    quote.Project__c = projectCode;
                    quote.Project_Services_Request__c = true;
                }

                // DML to update quotes
                update quotes;
            }
            catch (exception e) {
                System.debug('Exception-->' + e.getMessage() + 'At Line no. -->' + e.getLineNumber());
            }
        }
        return successMessage;
    }
    
    private static Asset retrieveLatestAssetFromList(List<Asset> assetList)
    {
        /**************************************************
        * Created By: TCS, Pavankumar Kulkarni
        * CreatedDate: 24-Aug-23
        * Story: SDT-31259
        * Comment: To retrieve the latest active Asset from the list
        * Input/Output: List of Asset/Asset
        * *************************************************/
        Asset assetToReturn = assetList[0];
        for(Asset asset : assetList)
        {
            if(asset.Id == assetToReturn.Id)
            {
                continue;
            }
            else
            {
                if(assetToReturn.End_Date__c != null && asset.End_Date__c == null)
                    assetToReturn = asset;
                else if(assetToReturn.End_Date__c == null && asset.End_Date__c == null && asset.Start_Date__c > assetToReturn.Start_Date__c)
                    assetToReturn = asset;
            }
        }
        return assetToReturn;
    }
    
    public class assetHeaderModel{
        @AuraEnabled public Id assetId;
        @AuraEnabled public String assetName;
        @AuraEnabled public String Acorn_SID;
        @AuraEnabled public String Material_Type;
        @AuraEnabled public String Material_Grade; //sdt-37527
        @AuraEnabled public String Equipment_Type;
        @AuraEnabled public String Equipment_Size;
        @AuraEnabled public String CPQ_Material;
        @AuraEnabled public String CPQ_Product;
        @AuraEnabled public String ProductCode;
        @AuraEnabled public String MaterialCode;
	}

    public class assetProductRequestModel
    {
        @AuraEnabled public Id assetId {get; set;}
        @AuraEnabled public Id quoteId {get; set;}
        @AuraEnabled public Id productId {get; set;}
        @AuraEnabled public Id wastestreamId {get; set;}
        @AuraEnabled public String equipmentSize {get; set;}
    }

    public class assetProductResponseModel
    {
        @AuraEnabled public Id productId {get; set;}
        @AuraEnabled public Id assetId {get; set;}
        @AuraEnabled public Id quoteLineId {get; set;}
    }

    // Changes for SDT-30514 & SDT-30515
    // Class to hold the baseline behavior:- UPDATE ONLY, END AND EXTEND OR END AND NEW 
    public class comparisonResponseModel
    {
        @AuraEnabled public Boolean isQLMached {get; set;}
        @AuraEnabled public Boolean isUpdateBaseline {get; set;}
        @AuraEnabled public Boolean isEndAndExtendBaseline {get; set;}
    }
    // class for transformation
    public class TransformationHelper 
    {
        //get the Service days from Asset List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings
        public String getServiceDaysFromAsset(Asset asset, List<Asset_Quoteline_Mapping__mdt> MappingmetaDataList)
        {
            String serviceDays ='';
            Map<String,String> serviceDayMap = new Map<String,String>();
            for(Asset_Quoteline_Mapping__mdt MappingmetaData: MappingmetaDataList)
            {
                if(!serviceDayMap.containsKey(MappingmetaData.AssetField__c) && MappingmetaData.QuoteLineField__c == 'Service_Days__c')
                {
                    serviceDayMap.put(MappingmetaData.AssetField__c,MappingmetaData.QuoteLineFieldValue__c);
                }
            }

            if(asset.Monday__c ){
                serviceDays += serviceDayMap.get('Monday__c') + ';';
            }
            if(asset.Tuesday__c){
                serviceDays += serviceDayMap.get('Tuesday__c') + ';';
            }
            if(asset.Wednesday__c){
                serviceDays += serviceDayMap.get('Wednesday__c') + ';';
            }
            if(asset.Thursday__c){
                serviceDays += serviceDayMap.get('Thursday__c') + ';';
            }
            if(asset.Friday__c){
                serviceDays += serviceDayMap.get('Friday__c') + ';';
            }
            if(asset.Saturday__c){
                serviceDays += serviceDayMap.get('Saturday__c') + ';';
            }
            if(asset.Sunday__c){
                serviceDays += serviceDayMap.get('Sunday__c') + ';';
            } 
            return serviceDays;
        }

        //commented as part of SDT 31118
        //method to get the default VCR code by duration if VCR is null
       /* public String getDefaultVCRCode(String duration)
        {
            String vCR_Code;
            SWITCH ON duration {
                WHEN 'TEMP' {
                    vCR_Code = QuoteLineServices.VCR_CODE_NBT;
                }
                WHEN 'PERM' {
                    vCR_Code = QuoteLineServices.VCR_CODE_NBG;
                }
            }
            return vCR_Code;
        }*/

        //get Company Category Code
        public String getCompanyCategoryCode(String category)
        {
            Integer openingIndex = category.indexOf('(');
            Integer closingIndex = category.indexOf(')');
            return category.subString(openingIndex + 1, closingIndex);
        }

        //Transfer Asset to QuoteLine
        public SBQQ__QuoteLine__c ConvertAssetToQuoteLineUpdated(Asset asset,SBQQ__QuoteLine__c quoteline, SBQQ__QuoteLine__c parentquoteline, Boolean isChildQL, Boolean isAssetDetail, List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings, Boolean isIntegrationCall)
        {
            // get the Equipment Size
            List<Schema.PicklistEntry> equipment_SizeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Equipment_Size__c.getPicklistValues();
            quoteline.Equipment_Size__c = (isChildQL && !isAssetDetail) ? parentquoteline.Equipment_Size__c : getPicklistEntryByLabel(equipment_SizeEntries, asset.Equipment_Size__c);
            
            // get the Occurrence Type
            List<Schema.PicklistEntry> occurrenceTypeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Occurrence_Type__c.getPicklistValues();
            quoteline.Occurrence_Type__c= (isChildQL && !isAssetDetail) ? parentquoteline.Occurrence_Type__c : getPicklistEntryByLabel(occurrenceTypeEntries, asset.Occurrence_Type__c);

            // get the Duration
            List<Schema.PicklistEntry> durationEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Duration__c.getPicklistValues();
            quoteline.Duration__c = (isChildQL && !isAssetDetail) ? parentquoteline.Duration__c : getPicklistEntryByLabel(durationEntries, asset.Duration__c);

             // get the Sensitivity_Code
            List<Schema.PicklistEntry> sCodeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.sCode__c.getPicklistValues();
            quoteline.sCode__c = (isChildQL && !isAssetDetail) ? parentquoteline.sCode__c : getPicklistEntryByLabel(sCodeEntries, asset.Sensitivity_Code__c); // Changes for SDT-30042

             // to get the Frequency__c
            List<Schema.PicklistEntry> schedule_FrequencyEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Schedule_Frequency__c.getPicklistValues();
            quoteline.Schedule_Frequency__c = (isChildQL && !isAssetDetail) ? parentquoteline.Schedule_Frequency__c :getPicklistEntryByLabel(schedule_FrequencyEntries, asset.Frequency__c);

            // to get the Frequency_Interval__c
            List<Schema.PicklistEntry> frequencyIntervalEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Frequency_Interval__c.getPicklistValues();
            quoteline.Frequency_Interval__c= (isChildQL && !isAssetDetail) ? parentquoteline.Frequency_Interval__c :getPicklistEntryByAPIName(frequencyIntervalEntries, asset.Occurs__c);

            //SDT-38285 - Added Month_Relative_Interval__c and Month_Relative__c from asset to quoteline
			List<Schema.PicklistEntry> monthRelativeIntervalEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Month_Relative_Interval__c.getPicklistValues();
            quoteline.Month_Relative_Interval__c= (isChildQL && !isAssetDetail) ? parentquoteline.Month_Relative_Interval__c :getPicklistEntryByAPIName(monthRelativeIntervalEntries, asset.Month_Relative_Interval__c);

            List<Schema.PicklistEntry> monthRelativeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Month_Relative__c.getPicklistValues();
            quoteline.Month_Relative__c= (isChildQL && !isAssetDetail) ? parentquoteline.Month_Relative__c :getPicklistEntryByAPIName(monthRelativeEntries, asset.Month_Relative__c);
            
            // to get the PriceUOM
            List<Schema.PicklistEntry> priceUOMEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.PriceUOM__c.getPicklistValues();
            quoteline.PriceUOM__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceUOM__c :getPicklistEntryByLabel(priceUOMEntries, asset.Price_Unit__c);

            // to get the costUOM
            List<Schema.PicklistEntry> costUOMEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.Cost_Unit_of_Measure__c.getPicklistValues();
            quoteline.Cost_Unit_of_Measure__c = (isChildQL && !isAssetDetail) ? parentquoteline.Cost_Unit_of_Measure__c :getPicklistEntryByLabel(costUOMEntries, asset.Cost_Unit__c);

            // to get the costModel
            List<Schema.PicklistEntry> costModelEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.CostModelType__c.getPicklistValues();
            quoteline.CostModelType__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostModelType__c :getPicklistEntryByLabel(costModelEntries, asset.Cost_Model_Type__c);

            // to get the schedule_A_Override
            List<Schema.PicklistEntry> schedule_A_OverrideEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.ScheduleAOverride__c.getPicklistValues();
	    //TCS-SDT-36171-16-Feb-2024-Commented following line
            //quoteline.ScheduleAOverride__c = (isChildQL && !isAssetDetail) ? parentquoteline.ScheduleAOverride__c :getPicklistEntryByLabel(schedule_A_OverrideEntries, asset.Schedule_A_Override__c);
	    //TCS-SDT-36171-16-Feb-2024-Added following lines
	    QuoteLineScheduleAOverride.setValueOnScheduleAOverrideFieldOnQuoteLine(isChildQL, isAssetDetail, quoteline, parentquoteline, asset, schedule_A_OverrideEntries);
	    //TCS-SDT-36171-16-Feb-2024-End

            //commented out as part of SDT 31118
            /*
            // to get the VCRCode__c 
            List<Schema.PicklistEntry> vCR_CodeEntries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.VCRCode__c.getPicklistValues();
            quoteline.VCRCode__c = (isChildQL && !isAssetDetail) ? parentquoteline.VCRCode__c :getPicklistEntryByLabel(vCR_CodeEntries, asset.MAS_VCR_Code__c);
            
            
           if(String.isBlank(quoteline.VCRCode__c) || String.isEmpty(quoteline.VCRCode__c))
            {
                quoteline.VCRCode__c = getDefaultVCRCode(quoteline.Duration__c);
            }*/

            quoteline.Ownership__c =null;
            //get the Equipment Owner
            if((isChildQL && !isAssetDetail))
            {
                quoteline.Ownership__c =parentquoteline.Ownership__c;
            }
            else
            {
                for(Asset_Quoteline_Mapping__mdt MappingmetaData : assetQuoteLineMappings)
                {
                    // to get the header Equipment_Owner__c
                    if(MappingmetaData.AssetField__c == QuoteLineServices.ASSET_EQUIP_FIELD && MappingmetaData.AssetFieldValue__c == asset.Equipment_Owner__c)
                    {
                        quoteline.Ownership__c = MappingmetaData.QuoteLineFieldValue__c;
                        break;
                    }
                }
            }
            //system.debug('equipmentOwner >'+ quoteline.Ownership__c);
            
            quoteline.Service_Days__c =null;
            // to get the header Service Days if frequency is Daily or Weekly
            if(quoteline.Schedule_Frequency__c == 'D' || quoteline.Schedule_Frequency__c == 'W')
            {
                if((isChildQL && !isAssetDetail))
                    quoteline.Service_Days__c =parentquoteline.Service_Days__c; 
                else
                {
                    if(quoteline.Frequency_Interval__c == null && quoteline.Schedule_Frequency__c == 'D')
                    {
                        // Assuming Service line coming as Every weekday when Frequency_Interval__c is null so Setting up this value with weekdays  
                        quoteline.Service_Days__c='M;T;W;T1;F';
                    }
                    else{
                        String serviceDays =getServiceDaysFromAsset(asset, assetQuoteLineMappings);
                        if(!String.isEmpty(serviceDays))
                        quoteline.Service_Days__c = serviceDays.removeEnd(';');
                    }
                }
            }
            
            if((isChildQL && isAssetDetail) || (!isChildQL && !isAssetDetail))
            {
                if(asset.CPQ_Product__c != null)
                    quoteline.SBQQ__Product__c = asset.CPQ_Product__c;
            }
            quoteline.SBQQ__Quantity__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__Quantity__c : asset.Quantity__c;
            quoteline.SID__c = (isChildQL && !isAssetDetail) ? parentquoteline.SID__c : (asset.Acorn_SID__c != '' && asset.Acorn_SID__c != null) ? Decimal.valueOf(asset.Acorn_SID__c): null;
            quoteline.ServiceBaselineId__c= (isChildQL && !isAssetDetail) ? parentquoteline.ServiceBaselineId__c : asset.Acorn_SBID__c;
            quoteline.SBQQ__StartDate__c =(isChildQL && !isAssetDetail)  ? parentquoteline.SBQQ__StartDate__c : asset.Start_Date__c; 
            quoteline.SBQQ__EndDate__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__EndDate__c : asset.End_Date__c;

            quoteline.AssetId__c = (isChildQL && !isAssetDetail) ? parentquoteline.AssetId__c : asset.Id; // May be not needed for waste category and Waste Material
            quoteline.Vendor__c = (isChildQL && !isAssetDetail)  ? parentquoteline.Vendor__c : asset.Supplier__c;
            quoteline.AccountingBusinessUnitNumber__c = (isChildQL && !isAssetDetail) ? parentquoteline.AccountingBusinessUnitNumber__c : asset.BusinessUnit_Name__c;
            //quoteline.SBQQ__PricingMethod__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__PricingMethod__c :  (isIntegrationCall ? asset.Price_Model_Type__c : getPriceModelType(asset.Price_Model_Type__c)); 
            quoteline.SBQQ__PricingMethod__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__PricingMethod__c :   getPriceModelType(asset.Price_Model_Type__c, isIntegrationCall);  
            quoteline.SBQQ__Description__c=(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__Description__c : asset.Description;
            quoteline.ByPassMASServiceChange__c=(isChildQL && !isAssetDetail) ? parentquoteline.ByPassMASServiceChange__c : asset.Bypass_MAS__c;
            quoteline.ClientCostCenter__c =(isChildQL && !isAssetDetail) ? parentquoteline.ClientCostCenter__c : asset.Cost_Center__c;
            quoteline.ClientGLAccount__c=(isChildQL && !isAssetDetail) ? parentquoteline.ClientGLAccount__c : asset.GL_Code__c;
            quoteline.CompanyCategoryCode__c=null;
            quoteline.CompanyCategoryName__c=null;
            if(isChildQL && !isAssetDetail)
            {
                quoteline.CompanyCategoryCode__c = parentquoteline.CompanyCategoryCode__c;
                quoteline.CompanyCategoryName__c = parentquoteline.CompanyCategoryName__c;
            }else{
                // removing Name from category because Category contains = (Code) + Name so spiting Code
                if(!String.isEmpty(asset.Category__c) && asset.Category__c.indexOf('(') >= 0 && asset.Category__c.indexOf(')') > 0)
                {
                    quoteline.CompanyCategoryCode__c = getCompanyCategoryCode(asset.Category__c);
                    quoteline.CompanyCategoryName__c = asset.Category__c.substringAfter(')').trim();
                }
            }
            quoteline.CostMinQuantity__c = (asset != null && asset.Service_Type__c == Constant_UTIL.DISPOSAL) ? asset.Cost_Minimum_Quantity__c : null; 
            quoteline.PriceMinQuantity__c= (asset != null && asset.Service_Type__c == Constant_UTIL.DISPOSAL) ? asset.Price_Minimum_Quantity__c : null;
            quoteline.CostPrice1__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostPrice1__c : asset.Cost_Price_1__c;  
            quoteline.CostIncrement1__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostIncrement1__c : asset.Cost_Increment_1__c;  
            quoteline.CostUpTo1__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostUpTo1__c : asset.Cost_UpTo_1__c; 
            quoteline.CostPrice2__c= (isChildQL && !isAssetDetail) ? parentquoteline.CostPrice2__c : asset.Cost_Price_2__c; 
            quoteline.CostIncrement2__c= (isChildQL && !isAssetDetail) ? parentquoteline.CostIncrement2__c : asset.Cost_Increment_2__c; 
            quoteline.CostUpTo2__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostUpTo2__c : asset.Cost_UpTo_2__c;
            quoteline.CostPrice3__c =(isChildQL && !isAssetDetail) ? parentquoteline.CostPrice3__c :  asset.Cost_Price_3__c;
            quoteline.CostIncrement3__c =(isChildQL && !isAssetDetail) ? parentquoteline.CostIncrement3__c :  asset.Cost_Increment_3__c;
            quoteline.CostUpTo3__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostUpTo3__c : asset.Cost_UpTo_3__c;
            quoteline.CostPrice4__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostPrice4__c : asset.Cost_Price_4__c;
            quoteline.CostIncrement4__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostIncrement4__c : asset.Cost_Increment_4__c;
            quoteline.CostUpTo4__c = (isChildQL && !isAssetDetail) ? parentquoteline.CostUpTo4__c : asset.Cost_UpTo_4__c;
            quoteline.IsExtraPickup__c= (isChildQL && !isAssetDetail) ? parentquoteline.IsExtraPickup__c : asset.Has_Extra_Pickup__c;
            quoteline.HoldUntilPosted__c= (isChildQL && !isAssetDetail) ? parentquoteline.HoldUntilPosted__c : asset.Is_Hold_Until_Posted__c;
            quoteline.IsLocalBilling__c= (isChildQL && !isAssetDetail) ? parentquoteline.IsLocalBilling__c : asset.Is_Locally_Billed__c;
            quoteline.MASAccount__c=null;
            if(isChildQL && !isAssetDetail)
            {
                quoteline.MASAccount__c =parentquoteline.MASAccount__c;
            }
            else {
                if(!String.isEmpty(asset.MAS_Account_Number__c))
                {
                    quoteline.MASAccount__c =integer.valueOf(asset.MAS_Account_Number__c);
                }
            }
            quoteline.MASCompany__c= (isChildQL && !isAssetDetail) ? parentquoteline.MASCompany__c : asset.MAS_Company_Code__c;
            quoteline.MASCustomerUniqueId__c = (isChildQL && !isAssetDetail) ? parentquoteline.MASCustomerUniqueId__c : asset.MAS_Customer_Unique_Id__c;
            quoteline.MASLibrary__c = (isChildQL && !isAssetDetail) ? parentquoteline.MASLibrary__c : asset.MAS_Library__c;
            quoteline.MASServiceLine__c = (isChildQL && !isAssetDetail) ? parentquoteline.MASServiceLine__c : asset.MAS_Line_Number__c;
            quoteline.MAS_SwapoutComment__c= (isChildQL && !isAssetDetail) ? parentquoteline.MAS_SwapoutComment__c : asset.MAS_Setup_Comment__c;
            quoteline.VendorAccountNumber__c = (isChildQL && !isAssetDetail) ? parentquoteline.VendorAccountNumber__c : asset.Vendor_Account_Number__c;
            //quoteline.SBQQ__ListPrice__c= (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__ListPrice__c : asset.Price__c;
            //Changes to display Unit price
            quoteline.SBQQ__ListPrice__c= (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__ListPrice__c : asset.SBQQ__RegularPrice__c;
            quoteline.PricePrice1__c = (isChildQL && !isAssetDetail) ? parentquoteline.PricePrice1__c : asset.Price_Price_1__c;
            quoteline.PriceIncrement1__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceIncrement1__c : asset.Price_Increment_1__c;
            quoteline.PriceUpTo1__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceUpTo1__c : asset.Price_UpTo_1__c;
            quoteline.PricePrice2__c = (isChildQL && !isAssetDetail) ? parentquoteline.PricePrice2__c : asset.Price_Price_2__c;
            quoteline.PriceIncrement2__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceIncrement2__c : asset.Price_Increment_2__c;
            quoteline.PriceUpTo2__c =(isChildQL && !isAssetDetail) ? parentquoteline.PriceUpTo2__c :  asset.Price_UpTo_2__c;
            quoteline.PricePrice3__c = (isChildQL && !isAssetDetail) ? parentquoteline.PricePrice3__c : asset.Price_Price_3__c;
            quoteline.PriceUpTo3__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceUpTo3__c : asset.Price_UpTo_3__c;
            quoteline.PriceIncrement3__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceIncrement3__c : asset.Price_Increment_3__c;
            quoteline.PricePrice4__c = (isChildQL && !isAssetDetail) ? parentquoteline.PricePrice4__c : asset.Price_Price_4__c;
            quoteline.PriceIncrement4__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceIncrement4__c : asset.Price_Increment_4__c;
            quoteline.PriceUpTo4__c = (isChildQL && !isAssetDetail) ? parentquoteline.PriceUpTo4__c : asset.Price_UpTo_4__c;
            quoteline.Profile_Number__c= (isChildQL && !isAssetDetail) ? parentquoteline.Profile_Number__c : asset.Waste_Profile__c;
            quoteline.ContractNotes__c = (isChildQL && !isAssetDetail) ? parentquoteline.ContractNotes__c : asset.Contract_Notes__c; 
            // Commented 'SetupComment__c' field reference for story SDT-25787 to change the DataType from 'Text(255)' to 'Long Text(1500)' Will uncomment after DataType is changed
            quoteline.SetupComment__c = (isChildQL && !isAssetDetail) ? parentquoteline.SetupComment__c : asset.MAS_Setup_Comment__c;
            quoteline.BusinessUnitNumber__c = (isChildQL && !isAssetDetail) ? parentquoteline.BusinessUnitNumber__c : asset.Vendor_BU__c;
            quoteline.Vendor_Service_Location_Code__c= (isChildQL && !isAssetDetail) ? parentquoteline.Vendor_Service_Location_Code__c : asset.Vendor_Service_Number__c;
            // Sprint 16 Changes
			// Changes for SDT-32105
            quoteline.MaterialGrade__c = (isChildQL && !isAssetDetail) ? parentquoteline.MaterialGrade__c : asset.Material_Grade__c; //sdt-37527
            quoteline.Core_Service__c =(isChildQL && !isAssetDetail) ? parentquoteline.Core_Service__c : asset.Is_Core_Service__c;
            quoteline.IncludeTaxInCostAmount__c =(isChildQL && !isAssetDetail) ? parentquoteline.IncludeTaxInCostAmount__c : asset.Price_Tax_Inclusive__c;
            //quoteline.SBQQ__Bundled__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__Bundled__c : asset.SBQQ__Bundled__c;
            quoteline.SBQQ__ComponentDiscountedByPackage__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__ComponentDiscountedByPackage__c : asset.SBQQ__ComponentDiscountedByPackage__c;
            quoteline.SBQQ__OptionDiscountAmount__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__OptionDiscountAmount__c : asset.SBQQ__OptionDiscountAmount__c;
            quoteline.SBQQ__AdditionalDiscountAmount__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__AdditionalDiscountAmount__c : asset.SBQQ__AdditionalDiscountAmount__c;
            quoteline.SBQQ__RegularPrice__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__RegularPrice__c : asset.SBQQ__RegularPrice__c;
            quoteline.SBQQ__MarkupAmount__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__MarkupAmount__c : asset.SBQQ__MarkupAmount__c;
            quoteline.SBQQ__OriginalUnitCost__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__OriginalUnitCost__c : asset.SBQQ__OriginalUnitCost__c;
            //sdt-37527
			List<Schema.PicklistEntry> materialGrade_Entries = Schema.SObjectType.SBQQ__QuoteLine__c.fields.materialGrade__c.getPicklistValues();
		//	System.debug('here6^^^ '+materialGrade_Entries);
            quoteline.materialGrade__c = (isChildQL && !isAssetDetail) ? parentquoteline.materialGrade__c : getPicklistEntryByLabel(materialGrade_Entries, asset.material_grade__c);
            // get the Occurrence Type
             //sdt-37527
            quoteline.SBQQ__Discount__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__Discount__c : asset.SBQQ__Discount__c;
            quoteline.SBQQ__TermDiscountSchedule__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__TermDiscountSchedule__c : asset.SBQQ__TermDiscountSchedule__c;
            //quoteline.Weekly_Frequency__c =asset.Weekly_Frequency__c; this field is not present in QL
            quoteline.SBQQ__BundledQuantity__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__BundledQuantity__c : asset.SBQQ__BundledQuantity__c;
            quoteline.SBQQ__SegmentIndex__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__SegmentIndex__c : asset.SBQQ__SegmentIndex__c;
            quoteline.SBQQ__DistributorDiscount__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__DistributorDiscount__c : asset.SBQQ__DistributorDiscount__c;
            quoteline.SBQQ__OptionDiscount__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__OptionDiscount__c : asset.SBQQ__OptionDiscount__c;
            quoteline.SBQQ__PartnerDiscount__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__PartnerDiscount__c : asset.SBQQ__PartnerDiscount__c;
            quoteline.SBQQ__MarkupRate__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__MarkupRate__c : asset.SBQQ__MarkupRate__c;
            //quoteline.CostModelType__c =(isChildQL && !isAssetDetail) ? parentquoteline.CostModelType__c : asset.Cost_Model_Type__c;
            quoteline.Equipment_Schedule_Type__c =(isChildQL && !isAssetDetail) ? parentquoteline.Equipment_Schedule_Type__c : asset.Schedule_Type__c;
            quoteline.Material_Type__c =(isChildQL && !isAssetDetail) ? parentquoteline.Material_Type__c : asset.Material_Type__c;
            quoteline.SBQQ__BillingFrequency__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__BillingFrequency__c : asset.SBQQ__BillingFrequency__c;
            quoteline.SBQQ__BillingType__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__BillingType__c : asset.SBQQ__BillingType__c;
            quoteline.SBQQ__ChargeType__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__ChargeType__c : asset.SBQQ__ChargeType__c;
            quoteline.SBQQ__DiscountScheduleType__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__DiscountScheduleType__c :  asset.SBQQ__DiscountScheduleType__c;
            quoteline.SBQQ__OptionType__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__OptionType__c :  asset.SBQQ__OptionType__c;
            quoteline.SBQQ__PackageProductDescription__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__PackageProductDescription__c : asset.SBQQ__PackageProductDescription__c;
            quoteline.SBQQ__SegmentLabel__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__SegmentLabel__c :  asset.SBQQ__SegmentLabel__c;
            quoteline.LocationPositionName__c =(isChildQL && !isAssetDetail) ? parentquoteline.LocationPositionName__c :  asset.Container_Position__c;
            quoteline.Location_Position_Name__c =(isChildQL && !isAssetDetail) ? parentquoteline.Location_Position_Name__c :  asset.Account_Position__c;
            quoteline.SBQQ__PackageProductCode__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__PackageProductCode__c :  asset.SBQQ__PackageProductCode__c;
            quoteline.SBQQ__SegmentKey__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__SegmentKey__c : asset.SBQQ__SegmentKey__c;
            quoteline.SBQQ__DynamicOptionId__c = (isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__DynamicOptionId__c : asset.SBQQ__DynamicOptionId__c;
            //quoteline.SBQQ__UnitCost__c=(isChildQL && asset !=null) ? asset.Cost__c : null;
            //quoteline.SBQQ__RequiredBy__c= (isChildQL) ? parentquoteline.Id : null;
            //Changes to display Unit Cost
            quoteline.SBQQ__UnitCost__c =(isChildQL && !isAssetDetail) ? parentquoteline.SBQQ__UnitCost__c : asset.SBQQ__OriginalUnitCost__c;
            //changes for Strory 25064
            //quoteline.MASBox__c = QuoteLineServices.DEFAULT_MAS_BOX; // passing default as CENTRAL
            quoteline.MASBox__c=(isChildQL && !isAssetDetail) ? parentquoteline.MASBox__c : asset.MASBox__c;
            // assigning default value to API fields as we are using this method for field comparison
            //commenting as part of SDT-34351 quoteline.Exception_Type__c ='CLTINITCHG';
            //quoteline.Day_of_Month__c=null;		/pkulkarn-TCS-6-Mar-23-Commented for SDT-28592
	    quoteline.Day_of_Month__c = (isChildQL && !isAssetDetail) ? parentquoteline.Day_of_Month__c : (asset.Of_Month__c != null ? integer.valueof(asset.Of_Month__c) : null);		//pkulkarn-TCS-6-Mar-23-Added for SDT-28592
            //Changes done for story SDT-39662 Start
            if(asset !=null && asset.Supplier__c!= null && asset.Supplier__r!=null && asset.Supplier__r.Parent_Vendor_ID__c !=null)
            {
            quoteline.BypassPriceReview__c=quoteline.sCode__c =='FRCH'  ? PricingRequestSTPProcess.getBypassPriceReview('WM Franchise',asset.Supplier__r.Parent_Vendor_ID__c,quoteline.MASLibrary__c):PricingRequestSTPProcess.getBypassPriceReview('Open Market',asset.Supplier__r.Parent_Vendor_ID__c,quoteline.MASLibrary__c);
            }
            else{
                quoteline.BypassPriceReview__c = false;
            }
            //End
            quoteline.MASDelivery__c=false;
            quoteline.MASRemoval__c=false;
            quoteline.MAS_Swapout__c=false;
            quoteline.MASNewTicket__c=false;
            quoteline.MASOpsRouting__c=false;
            quoteline.DoNotCreateMASTicket__c=false;
            quoteline.MASDeliveryComment__c=null;
            quoteline.MASRemovalComment__c=null;
            quoteline.MASNewTicketComment__c=null;
            quoteline.MASOpsRoutingComment__c=null;
            quoteline.SBQQ__Taxable__c=false;
            //TCS-pkulkarn-SDT-41365-Added following line to set the field value to Fixed Price to make the Start and End Date fields editable in Quote Line Drawer
            quoteline.SBQQ__SubscriptionPricing__c = UTIL_Picklist.getPickListLabelByAPIValue('SBQQ__QuoteLine__c', 'SBQQ__SubscriptionPricing__c', 'Fixed Price');		
            return quoteline;
        }
        //Method for SDT-40012 Start
        //Need to create a method for putting value in the map.. to highlight that what we are trying to achieve.
        public Map<String, Object> ConvertAssetToQuoteLineUpdatedMap(Asset asset,SBQQ__QuoteLine__c quoteline, SBQQ__QuoteLine__c parentquoteline, Boolean isChildQL, Boolean isAssetDetail, List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings, Boolean isIntegrationCall)
        {  
            SBQQ__QuoteLine__c convertedQL = ConvertAssetToQuoteLineUpdated(asset,quoteline, parentquoteline, True, True , assetQuoteLineMappings, True);
            //Asset Map
            String serializeAssetQL = JSON.serialize(convertedQL);
            Map<String, Object> assetMap = (Map<String, Object>)JSON.deserializeUntyped(serializeAssetQL);
            //"In order to put the values for calculated field, which is readonly, and does not populate. we have update the field value in the Map with that in the Asset."  Asset to QL conversion does not populate formula fields as calculated fields get populated only when query.
            assetMap.put('CompanyProjectName__c', asset.RootAsset.Project_Code__r.ProjectCode_Id__c);
            return assetMap;
        }
        //Method for SDT-40012 End
        //Method for SDT-26597
        public String getPriceModelType(String priceModelType, Boolean isIntegrationCall)
        {
            //assigning default asset's price model type
            String modelType = priceModelType;
            
            //checking for null
            if(!String.isEmpty(priceModelType))
            {
                //if this method is called from Intergration layer then Convert this to same as PricingUnitMethod field
                if(isIntegrationCall)
                {
                    modelType = priceModelType == Constant_Util.PRICING_METHOD_PER_UNIT ? Constant_Util.PRICING_METHOD_LIST : priceModelType;
                }
                // if price model is 'Margin' or 'Per unit' then updating with 'List'
                else if(priceModelType == Constant_Util.PRICING_METHOD_MARGIN || priceModelType == Constant_Util.PRICING_METHOD_PER_UNIT)
                {
                    modelType = Constant_Util.PRICING_METHOD_LIST;
                }
            }
            return modelType; 
        }

        // Changes for SDT-30514 & SDT-30515
        public comparisonResponseModel compareAssetQuoteLines(Asset asset ,SBQQ__QuoteLine__c toCompareQL, SBQQ__QuoteLine__c parentQL, boolean debugRequired, set<string> updateBaselineFields, set<string> endAndExtendBaselineFields, Set<string> excludedFields, List<Asset_Quoteline_Mapping__mdt> assetQuoteLineMappings)
        {

            comparisonResponseModel responseModel = new comparisonResponseModel();
            // Assigning Default Values
            responseModel.isUpdateBaseline = responseModel.isEndAndExtendBaseline = false;
            responseModel.isQLMached= true;
            set<string> additionFieldsforMetadata = new Set<string>{'Vendor__c', 'LocationPositionName__c', 'Location_Position_Name__c','SBQQ__PricingMethod__c','SBQQ__StartDate__c'};
            Set<String> metaDataQLFields = new Set<String>();
            //Create new Quoteline
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c ();
            //Convert Asset to Quoteline
			System.debug('here2^^^ ');
            /* Commented for SDT-40012 Start
            //SBQQ__QuoteLine__c convertedQL = ConvertAssetToQuoteLineUpdated(asset,ql, parentQL, True, True , assetQuoteLineMappings, True);
    
            //Asset Map
            //String serializeAssetQL = JSON.serialize(convertedQL);
            //Map<String, Object> assetMap = (Map<String, Object>)JSON.deserializeUntyped(serializeAssetQL);
            Commented for SDT-40012 End */
            Map<String, Object> assetMap = ConvertAssetToQuoteLineUpdatedMap(asset,ql, parentQL, True, True , assetQuoteLineMappings, True); // Added for SDT-40012
            //Quoteline Map 
            String serializeQL = JSON.serialize(toCompareQL);
            Map<String, Object> qlMap = (Map<String, Object>)JSON.deserializeUntyped(serializeQL);
    
            // adding update baseline fields
            if(updateBaselineFields !=null && !updateBaselineFields.isEmpty())
                metaDataQLFields.addAll(updateBaselineFields);

            // Adding End and Extend fields
            if(endAndExtendBaselineFields !=null && !endAndExtendBaselineFields.isEmpty())
                metaDataQLFields.addAll(endAndExtendBaselineFields);

            // Removing Except Fields
            if(excludedFields !=null && !excludedFields.isEmpty())
                metaDataQLFields.removeAll(excludedFields);
            
            // local basline variables
            Boolean isUpdateBaseline =false, isEndAndExtendBaseline = false;

            //Looping through Map to identify change in data.
            for(string Key : metaDataQLFields)
            {
                key =key.trim();
                // if(key == 'LocationPositionName__c'){
                    // system.debug('assetMap'+ assetMap.containsKey(key));
                    // system.debug('Matched '+'Key >>> '+Key+ ' -- QL Value >>> '+qlMap.get(Key) + ' -- Asset Value >>>'+assetMap.get(Key));
                    // system.debug('assetMap mathed' +assetMap.get(Key) != qlMap.get(Key));
                // }

                //if(assetMap.get(Key) != qlMap.get(Key))
                if(!PricingJSONRequest.checkAssetAndQuoteLineFields(assetMap, qlMap, key, debugRequired))
                {
                    if(debugRequired)
                    {
                        system.debug(' Quote Line '+toCompareQL.name + ' Not Matched '+'Key >>> '+Key+ ' -- QL Value >>> '+qlMap.get(Key) + ' -- Asset Value >>>'+assetMap.get(Key));
                    }
                    // Condition to check if Key matched with Only Update BaseLine case
                    // For Update base line Case: Asset has EndDate and updated NULL in QL
                    // Special Logic For End Date :: If End date is changed (Not null in Asset and QuoteLine) then updating EndandExtend flag 
                    // For End and Extend base line Case: Asset has EndDate and updated in QL
                    if((key == 'SBQQ__EndDate__c' && assetMap.get(Key) != null && qlMap.get(Key) != null))
                    {
                        isEndAndExtendBaseline = true;
                    }
                    // For End and Extend base line Case: Asset has EndDate and date removed in QL
                    else if(key == 'SBQQ__EndDate__c' && assetMap.get(Key) != null && qlMap.get(Key) == null){
                        isUpdateBaseline = true;
                    }
                    else if(endAndExtendBaselineFields.contains(key))
                    {
                         // Condition to check if Key matched with End and Extend BaseLine case
                        isEndAndExtendBaseline = true;
                    }
                    else if(updateBaselineFields.contains(key))
                    {
                         // Condition to check if Key matched with Only Update BaseLine case
                        // For Update base line Case: Asset has EndDate and updated NULL in QL
                        isUpdateBaseline = true;
                    } 
                    // End and Extend found then breaking the loop
                    if(isEndAndExtendBaseline)
                    {
                        break;
                    }
                }
            }
            if(isUpdateBaseline)
            {
                responseModel.isUpdateBaseline = true;
                responseModel.isQLMached = false;
            }
            if(isEndAndExtendBaseline)
            {
                responseModel.isEndAndExtendBaseline = true;	
                responseModel.isQLMached = false;
            }
            //system.debug('responseModel 2>'+ responseModel);
            return responseModel;
        }

        // Method to read Field Set
        public Set<String> readFieldSet(String fieldSetName, String objectName)
        {
              // SDT-31110
              return FieldSetReader.readFieldSet(fieldSetName,objectName);           
        }
    }
}
