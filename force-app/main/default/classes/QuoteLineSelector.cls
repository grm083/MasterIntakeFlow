/*
    * @Name          QuoteLineSelector
    * @Author        Digdershika Ojha
    * @Vendor		 TCS
    * @Date          27/02/2023
    * @description	 This class will be used as Selector class for SBQQ__QuoteLine__c Object, story SDT-26174
    */
public with sharing class QuoteLineSelector {
    // SDT-31110
    // Object API name
    public static string ObjectName	= 'SBQQ__QuoteLine__c';
    
    // SDT-31110
    public static string Fields_To_Copy_From_Bundle = 'Fields_To_Copy_From_Bundle';
    //SDT-31788
    public static string SERVICE_ACTION_DO_NOT_EXTEND_SERVICE= 'Do Not Extend Service';
    
    /*
    * @vendor			 TCS
    * @story		   	 SDT-26174
    * @author			 Digdershika Ojha
    * @description       This method is used to return quote Bundles. Get Quote Lines by Parent Id 
    * @param             set of quoteIds the Id of Quote
    * @return            List of type SBQQ__QuoteLine__c
    */    
    public static List<SBQQ__QuoteLine__c> getQuoteLinesByQuoteIdList(Set<Id> quoteIds)
    {
        return [SELECT Id, SBQQ__ProductCode__c, SBQQ__ProductName__c, Equipment_Size__c, SBQQ__Quote__c, SBQQ__Quote__r.Name, Name, Duration__c, 
                Vendor__c, Vendor__r.Name,  Material_Type__c,SBQQ__Product__r.Name,SBQQ__RequiredBy__c,SBQQ__ProductFamily__c,Occurrence_Type__c,
                SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name,Account__r.ParentId,Vendor__r.Parent_Vendor_ID__c, Vendor__r.Vendor_ID__c,
                SBQQ__ListPrice__c,SBQQ__UnitCost__c,SBQQ__Product__r.ProductCode,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,sCode__c, SBQQ__Quote__r.Special_Handling__c, 
                SBQQ__Quote__r.Special_Handling_Reason__c, SBQQ__Quote__r.Special_Handling_Reason_Details__c,
                SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Case_Sub_Type__c,Pricing_Request__r.Market_Area_Code__c, Pricing_Request__r.zone_Type__c,Pricing_Request__r.Customer_Price_Type__c,
                SBQQ__Quote__r.Priority__c,Account__r.Parent.Customer_Code__c,Account__r.Parent.Accounting_System__c, SBQQ__RequiredBy__r.SBQQ__Product__r.Name,
                (SELECT id, AAV_APIRequestOutput__c from Asset_Availabilities__r)
                FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__c IN :quoteIds];
    }
    /*
    * @vendor			 TCS
    * @story		   	 SDT-29385
    * @author			 Seema Dhikale
    * @description       This method is used to return quote Bundles. Get Quote Lines by Parent Id 
    * @param             Set of String  as setFields( Getting all intergration metadata where isActive true),
    * 					 Id of parent Quoteline as parentQLId,
    * 					 Id of quote as quoteId,
    * 					 set of string as additionFieldsforMetadata(fields that need to check to update the start date)
    * @return            List of type SBQQ__QuoteLine__c
    */    
    public static List<SBQQ__QuoteLine__c> getQuoteLinesByQuoteId(Set<String> setFields,Id parentQLId,Id quoteId,set<string> additionFieldsforMetadata)
    {
        //sdt-38052 added SBQQ__Quote__r.SBQQ__Type__c
       //SDT32803 adding CreatedBy.User_categorization_code__c,LastModifiedBy.User_categorization_code__c
       //SDT-33285-TCS-Ruchika-Added AssetId__r.Equipment_Size__c to the SOQL
       return Database.Query('Select '+ String.join(new List<String>(setFields), ', ') +','+ String.join(new List<String>(additionFieldsforMetadata), ', ') +',CreatedBy.User_categorization_code__c,LastModifiedBy.User_categorization_code__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name,Service_Schedule__c,AssetId__c,SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__r.Family,SBQQ__ProductOption__r.SBQQ__Feature__r.Name,SBQQ__Product__c,EventRecurrence__c,SBQQ__ProductOption__r.SBQQ__ProductCode__c,SBQQ__ProductFamily__c,SBQQ__ProductName__c,SBQQ__RequiredBy__c,SBQQ__Quote__r.Name,SBQQ__Product__r.Family,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c, SBQQ__Quote__r.Project__c,  SBQQ__Quote__r.Project_Services_Request__c, AssetId__r.Equipment_Size__c,SBQQ__Quote__r.SBQQ__Type__c, (Select Id, Service_Type__c from Quote_Orders__r) from SBQQ__QuoteLine__c WHERE Id = :parentQLId OR SBQQ__RequiredBy__c =:parentQLId OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =:parentQLId ');
    }
    
    /*
    * @vendor			 TCS
    * @story		   	 SDT-29623
    * @author			 Pavankumar Kulkarni
    * @description       This method is used to return quote lines based on the Bundle Id and it excludes Waste Stream product.
    * @param             Bundle Quote Line Id
    * @return            List of type SBQQ__QuoteLine__c
    */    
    public static List<SBQQ__QuoteLine__c> getQLsByParentQLIdExcludeWasteCategory(String bundleQLId)
    {
     	
        //TCS-SDT-33321-24-Nov-2023-Changed the query to get all quote lines at all levels
        //TCS-SDT-31265-Added new fields to the query - toLabel(Cost_Unit_of_Measure__c),toLabel(PriceUOM__c),CostMinQuantity__c,PriceMinQuantity__c,CostPrice1__c,CostPrice2__c,CostPrice3__c,CostPrice4__c, CostUpTo1__c, CostUpTo2__c, CostUpTo3__c, CostUpTo4__c, PriceUpTo1__c, PriceUpTo2__c, PriceUpTo3__c, PriceUpTo4__c, PricePrice1__c, PricePrice2__c, PricePrice3__c, PricePrice4__c, toLabel(SBQQ__PricingMethod__c), toLabel(CostModelType__c)
	//TCS-SDT-38416-28-Feb-2024-Added sorting for SBQQ__Number__c and Name ASC to resolve issue related to display of Lines on Comparison screen
        //TCS-pkulkarn-SDT-32107-10-Sep-2024-Added field SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Quote__r.Integration_Status__c to the SOQL
	    return [SELECT id, AssetId__c,SBQQ__ProductFamily__c,Service_Schedule__c,SBQQ__UnitCost__c, SBQQ__Quantity__c, Equipment_Size__c, SBQQ__Product__r.Name, SBQQ__Product__r.Family,SBQQ__ProductName__c, 
        //SDT41407
        Frequency_Interval__c,Schedule_Frequency__c,Day_of_Month__c,Month_Relative_Interval__c,Month_Relative__c,            
        CompanyCategoryName__c,SBQQ__ListPrice__c, Account__r.Name,LocationPositionName__c, Location_Position_Name__r.Name, sCode__c,Initial_Classification_Changes__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__RequiredBy__c,toLabel(Cost_Unit_of_Measure__c),toLabel(PriceUOM__c),CostMinQuantity__c,PriceMinQuantity__c,CostPrice1__c,CostPrice2__c,CostPrice3__c,CostPrice4__c,
                    Vendor__r.Name, CostUpTo1__c, CostUpTo2__c, CostUpTo3__c, CostUpTo4__c, PriceUpTo1__c, PriceUpTo2__c, PriceUpTo3__c, PriceUpTo4__c,
                    PricePrice1__c, PricePrice2__c, PricePrice3__c, PricePrice4__c, toLabel(SBQQ__PricingMethod__c), toLabel(CostModelType__c), SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Quote__r.Integration_Status__c
                     FROM SBQQ__QuoteLine__c WHERE (Id = :bundleQLId OR SBQQ__RequiredBy__c = :bundleQLId OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =:bundleQLId)  AND SBQQ__ProductFamily__c != 'Waste Category' AND SBQQ__ProductFamily__c != 'Waste Stream' ORDER BY SBQQ__Number__c ASC, Name ASC];
        //Added LocationPositionName__c for solution related to SDT-28900 & SBQQ__ProductName__c for solution SDT-28899
        //pkulkar-TCS-08-May-23-Added SBQQ__Quantity__c and SBQQ__ProductFamily__c WHERE clause for Child Quote Lines query as per SDT-29623
    }
    
    /*
    * @vendor			 TCS
    * @story		   	 SDT-30717
    * @author			 Anup Dey
    * @description       This method is used to return quote lines based on the Quote Ids those having Opportunity.
    * @param             Quote Id
    * @return            List of type SBQQ__QuoteLine__c
    */  
    public List<SBQQ__QuoteLine__c> getQuoteLinesByQuoteIdHavingOpportunity(Set<Id> sQuoteIds)
    {
        // List<String> quoteLineFields = new List<String>(Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap().keySet());
        // String qlQuery  = 'SELECT '+String.join(quoteLineFields, ',')+' FROM '+'SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: sQuoteIds AND SBQQ__Quote__r.SBQQ__Opportunity2__c!=null ';
        String qlQuery  = 'SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__c, Duration__c, SBQQ__Quote__c,SBQQ__ListPrice__c,SBQQ__ProductName__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: sQuoteIds AND SBQQ__Quote__r.SBQQ__Opportunity2__c!=null ';
        return database.query(qlQuery);
    }
    
    /*
    * @vendor			 TCS
    * @story		   	 SDT-29792
    * @author			 Seema Dhikale
    * @description       This method is used to return quotes for case
    * @param             Id of Case
    * @return            List of type SBQQ__Quote__c
    */  
    public static List<SBQQ__Quote__c> getQuoteByCaseId(case caseObj)
    {
        List<SBQQ__Quote__c> qList = [SELECT Id,Name,SBQQ__Opportunity2__r.Case__r.Case_Record_Type__c, Assigned_To__r.Name, toLabel(SBQQ__Status__c), Quote_Only__c,Project__r.Name,Project_Services_Request__c 
                                      FROM SBQQ__Quote__c 
                                      WHERE SBQQ__Opportunity2__r.Case__c=:caseObj.Id];
        return qList;
    }
    
    /*
    * @vendor			 TCS
    * @story		   	 SDT-29792
    * @author			 Seema Dhikale
    * @description       This method is used to return quote lines based on the Quote
    * @param             List of Quote 
    * @return            List of type SBQQ__QuoteLine__c
    */  
    public static List<SBQQ__QuoteLine__c> getQuoteLinesByQuoteIdList(List<SBQQ__Quote__c> quoteList)
    {
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id,AssetId__r.Quantity__c,SBQQ__Quote__c,Service_Start_Time__c,
                                           Service_End_Time__c,Gate_Code__c,Restriction_Details__c,SBQQ__ProductName__c,
                                           SBQQ__ProductFamily__c,	SBQQ__ProductOption__r.SBQQ__Feature__r.Name,
                                           toLabel(Equipment_Size__c),SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Quantity__c,
                                           Description_of_Waste__c,Service_Schedule__c,LocationPositionName__c,
                                           Certificate_of_Disposal__c,Certificate_of_Destruction__c,Profile_Number__c,
                                           Landfill_Tickets__c,Special_Disposal_Description__c,Compactor_Type__c,
                                           Compactor_Size__c,Equipment_Style__c,toLabel(Service_Style__c),
                                           Equipment_Side_Doors__c,Type_of_Lid__c,Understructure__c,
                                           Day_of_Month__c,Month_Relative_Interval__c,Month_Relative__c, Schedule_Frequency__c, Frequency_Interval__c, //SDT41407
                                           toLabel(Ownership__c),SBQQ__RequiredBy__c,AssetId__r.ParentId //SDT-33378  
                                           FROM SBQQ__QuoteLine__c 
                                           WHERE SBQQ__Quote__c IN :quoteList];
        return qlList;
    }
/*@methodName- getQuoteLineList
*@description- Method to query the QuoteLine Record 
*@param- Id : QuoteID
*@return- List of SBQQ__QuoteLine__c
*@Reference	PriceOnlyRequestSTPProcess
*/ 
    public static list<SBQQ__QuoteLine__c> getQuoteLineList(ID quoteID)
    {
        //SDT 38499 adding SBQQ__ProductFamily__c 
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added fields SBQQ__Quote__r.SBQQ__ShippingCountry__c, Account__r.Parent.Primary_Segment__c, SBQQ__Quote__r.SBQQ__Type__c to the SOQL query
        List<SBQQ__QuoteLine__c> bundles = [SELECT Id,SBQQ__ProductFamily__c, SBQQ__ProductCode__c, SBQQ__ProductName__c, Equipment_Size__c, SBQQ__Quote__c, SBQQ__Quote__r.Name, Name, SBQQ__StartDate__c, SBQQ__EndDate__c, Duration__c, CurrencyIsoCode,
                                            ProcurementErrorMessage__c, BundleProcuredStatus__c, Is_Substituted_Container__c, Vendor__c, Vendor__r.Name, Original_Equipment_Size__c, Material_Type__c, Pricing_Request__c, Pricing_Request__r.IsCaseError__c, Pricing_Request__r.APIRequestOutput__c
                                            , Account__r.Parent.IsPricingEligible__c, SBQQ__Product__r.Is_Pricing_Eligible__c, SBQQ__Quote__r.STP__c, BypassPriceReview__c, PriceMinQuantity__c, CostMinQuantity__c,SBQQ__Quote__r.Special_Handling__c, MASLibrary__c, MASCompany__c, SetupComment__c
                                            , SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName, AAV_Service_Availability__c, AAV_Delivery_Availability__c, AAV_Requested_AdditionalServicesAccessor__c,Availability_Flag__c, //SDT-31027 
                                            SBQQ__Quote__r.SBQQ__ShippingCountry__c, Account__r.Parent.Primary_Segment__c, SBQQ__Quote__r.SBQQ__Type__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__Quote__c =: quoteID  AND SBQQ__RequiredBy__c = null ]; 
        
        return bundles;
    }
    
    /*@methodName- getQuoteLineOrderedList
*@description- Method to query the QuoteLine Record and ordered by descending order of SBQQ__Number__c
*@param- Set of Id : bundleIDSet
*@return- List of SBQQ__QuoteLine__c
*@Reference	PriceOnlyRequestSTPProcess
*/ 
    public static list<SBQQ__QuoteLine__c> getQuoteLineOrderedList(Set<Id> bundleIDSet)
    {
        //TCS-pkulkarn-SDT-40031-9-Apr-2025-Added Vendor__c field to the SOQL query
        //TCS-pkulkarn-SDT-47955-28-Apr-2025-Added Vendor__r.Vendor_ID__c field to the SOQL query
        List<SBQQ__QuoteLine__c> bundles = [SELECT Id, SBQQ__ProductCode__c, SBQQ__ProductName__c,SBQQ__Number__c,SBQQ__ProductFamily__c, SBQQ__Quote__c, Occurrence_Type__c, Cost_Unit_of_Measure__c, SBQQ__UnitCost__c, PriceUOM__c, SBQQ__ListPrice__c, SBQQ__RequiredBy__c, SBQQ__CustomerPrice__c, CostModelType__c,
                                            Vendor__c, Vendor__r.Vendor_ID__c
                                            FROM SBQQ__QuoteLine__c 
                                            WHERE SBQQ__RequiredBy__c IN: bundleIDSet  ORDER BY SBQQ__Number__c DESC ]; 
        
        return bundles;
    }
    /*
* @vendor            TCS
* @story             SDT-31298 SDT-32865
* @author            Digdershika Ojha
* @name              getQLByPrdCodesAndQuote
* @description       This method is used to return quote Bundles. Get Quote Lines by quote and specifc product code list 
* @param             quoteId, the String value of Id of Quote
* @param             productCodes, set of strings
* @Reference         PriceOnlyRequestSTPProcess.apxc
* @return            List of type SBQQ__QuoteLine__c
*/
    
    public static list<SBQQ__QuoteLine__c> getQLByPrdCodesAndQuote(string quoteId){
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, SBQQ__UnitCost__c, Cost_Unit_of_Measure__c, sCode__c, SBQQ__ListPrice__c, SBQQ__ProductCode__c,SBQQ__ProductName__c, Vendor__c, Vendor__r.Vendor_ID__c, Vendor_Service_Location_Code__c,SBQQ__RequiredBy__c, SBQQ__Quote__r.Name, SBQQ__Product__r.Family, SBQQ__Quote__r.Special_Handling__c
                                           FROM SBQQ__QuoteLine__c 
                                           WHERE SBQQ__Quote__r.id =: quoteId]; 
        return qlList;
    }
    /*
* @vendor            TCS
* @story             SDT-31298 SDT-32865
* @name              getQLByBdlAndPricing
* @description       This method is used to return quote Bundles. Get Quote Lines by Bundle Ids and is pricing eligible for account and product
* @param             bundleIds, the set of bundle Ids
* @Reference         PriceOnlyRequestSTPProcess.apxc
* @return            List of type SBQQ__QuoteLine__c
*/
    public static list<SBQQ__QuoteLine__c> getQLByBdlAndPricing(set<Id> bundleIds){
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, SBQQ__Product__r.Name,SBQQ__Product__r.ProductCode, Material_Type__c, Duration__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,Vendor__r.Vendor_ID__c, 
                                               SBQQ__Quantity__c, Equipment_Size__c, Name, Pricing_Frequency_Type__c, Pricing_Frequency_Count__c, Occurrence_Type__c, SBQQ__UnitCost__c, SBQQ__ProductCode__c,SBQQ__ProductName__c,
                                               Ownership__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__r.AccountNumber, SBQQ__Quote__r.Case_Number__c, 
                                               SBQQ__Quote__r.SBQQ__Account__r.ParentId,SBQQ__Quote__r.SBQQ__Account__r.RecordType.Name, SBQQ__Quote__r.SBQQ__Account__r.Id, SBQQ__Quote__r.SBQQ__ShippingStreet__c, 
                                               SBQQ__Quote__r.SBQQ__ShippingCity__c, SBQQ__Quote__r.SBQQ__ShippingCountry__c, SBQQ__Quote__r.SBQQ__ShippingState__c, 
                                               SBQQ__Quote__r.SBQQ__ShippingPostalCode__c, SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Quote__r.Project__c, SBQQ__Quote__r.Project_Services_Request__c
                                               , Vendor__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, Account__r.Parent.IsPricingEligible__c, Account__r.Primary_Segment__c,
                                               SBQQ__Product__r.Is_Pricing_Eligible__c, SBQQ__Product__r.Family, SBQQ__Quote__r.Name, SBQQ__Quote__r.Project__r.Name, SBQQ__Quote__r.SBQQ__Account__r.Location_Code__c, SBQQ__Quote__r.id, SBQQ__SubscriptionPercent__c, SBQQ__Quote__r.Special_Handling__c, toLabel(Cost_Unit_of_Measure__c)
                                               FROM SBQQ__QuoteLine__c 
                                               WHERE (ID IN :bundleIds AND Account__r.Parent.IsPricingEligible__c = TRUE AND SBQQ__Product__r.Is_Pricing_Eligible__c = TRUE)                                   
                                               Or SBQQ__RequiredBy__c IN:bundleIds or SBQQ__RequiredBy__r.SBQQ__RequiredBy__c IN : bundleIds];
        
        return quoteLines;
    }
	
	   /*
* @vendor			 TCS
* @story		   	 SDT-31752
* @name				 getProductOptionForQuote
* @description       The method retrieves Quotelines with associated Product Options and set the ID of the option in a list, map of product option id and option SKU Id  
* @param             Quote Id whole Quotelines are to be retrieved, List in which the same is to be added, parent quote line Id, when removing the selected option 
* @Reference		 QuoteProcurementController.apxc getAccessoriesWithSelection, removeProductOption(Id,Id,Id) ,, removeProductOption(Id,Id) 
* @return            List of Id of product options selected for a QL. Map of OptionId and option sku id
*/
    public static void getProductOptionForQuote(Id quoteId, List<Id> selectedAccessoryList, map<Id,Id> mapOptionIdAndOptionSKUId, List<Id> disabledAccessoryList){
		
		// QuoteId = QuoteId when called from getAccessoriesWithSelection
        // QuoteId = Parent QL Id when called from removeProductOption
        for(SBQQ__QuoteLine__c quoteline :[select Id,SBQQ__ProductOption__c, SBQQ__ProductOption__r.SBQQ__OptionalSKU__c, AssetId__c, SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name 
                                           from SBQQ__QuoteLine__c where SBQQ__Quote__c =:quoteId 
                                           or SBQQ__RequiredBy__c =:quoteId
                                           or SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =:quoteId  ] ){
                                               
                                               if(quoteline.SBQQ__ProductOption__c!=null){
                                                   selectedAccessoryList.add(quoteline.SBQQ__ProductOption__c);
                                                   mapOptionIdAndOptionSKUId.put(quoteline.SBQQ__ProductOption__c,quoteline.SBQQ__ProductOption__r.SBQQ__OptionalSKU__c);
												    // Changes for SDT-31752
												   if(quoteline.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.RecordType.Name != Constant_Util.R_NEW_SERVICE_CASE && quoteline.AssetId__c != null)
												   {
													 disabledAccessoryList.add(quoteline.SBQQ__ProductOption__r.SBQQ__OptionalSKU__c);
												   }
                                               }
                                           }
        
    }
    
    //SDT 31120 get list of QLs whos statrtdate is changed
    //Changes related to SDT-38985 - adding SBQQ__Quote__r.Case_record_Type__c to query
    //TCS-pkulkarn-SDT-41377-Added SBQQ__RequiredBy__r.SBQQ__EndDate__c to SOQL
    public static List<SBQQ__QuoteLine__c> getquoteLinesToUpdateEndDate(List<Id> newQuoteLineIdList){
        List<SBQQ__QuoteLine__c> lstStartDateUpdatedQuoteLines = [SELECT Id,Account__r.ShippingCountry, SBQQ__StartDate__c, SBQQ__EndDate__c,
                             SBQQ__Product__r.EndDateOffset__c, SBQQ__Product__c, SBQQ__Product__r.Name,SBQQ__Quote__r.Case_record_Type__c, SBQQ__RequiredBy__r.SBQQ__EndDate__c
                             From SBQQ__QuoteLine__c 
                             WHERE Id IN :newQuoteLineIdList];
        return lstStartDateUpdatedQuoteLines;
    }
    
    //SDT31120 get businessHourId
    public static final string BUSINESSNAME = 'WM SBS';
    public static Id getBusinessHourId(){
        Id businessHoursId = [SELECT Id 
                              FROM BusinessHours 
                              WHERE Name =: BUSINESSNAME 
                              AND IsActive = true 
                              LIMIT 1].Id;
        return businessHoursId;
        }   
        
    //TCS-pkulkarn-SDT-38495-20-May-2024-Added new method to move SOQL from ServiceSchedulerCtrl.submitMonthly() and ServiceSchedulerCtrl.submitMonthlySpecific()
    public static List<SBQQ__QuoteLine__c> getQuoteLinesForMonthlyFrequency(Id quoteId, Id parentQuoteLineId)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        //SDT-38285 Add in select query Month_Relative_Interval__c and Month_Relative__c
        quoteLineList = [SELECT Id, Occurrence_Type__c, Frequency_Interval__c, Schedule_Frequency__c, Service_Days__c, 
                         SBQQ__ProductFamily__c, Day_of_Month__c, Equipment_Size__c, SBQQ__ProductName__c, Month_Relative_Interval__c, Month_Relative__c 
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c=:quoteId AND (id=:parentQuoteLineId OR (SBQQ__ProductOption__r.Core_Service__c = true AND SBQQ__RequiredBy__c = :parentQuoteLineId))];
        return quoteLineList;
    }

    //TCS-pkulkarn-SDT-39624-3-Jul-2024-Added new method to query Pickup Quote Lines
    //Caller: ExtraPickupHandler.handleExtraPickupInsertion
    public static List<SBQQ__QuoteLine__c> getPickupQuoteLines(Set<Id> bundleIds)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        quoteLineList = [SELECT Id, Occurrence_Type__c, SBQQ__RequiredBy__c, SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__StartDate__c, SetupComment__c, Location_Position_Name__c, LocationPositionName__c,
                         SBQQ__RequiredBy__r.Occurrence_Type__c, SBQQ__RequiredBy__r.Material_Type__c, SBQQ__RequiredBy__r.Vendor__c, SBQQ__RequiredBy__r.VendorAccountNumber__c, SBQQ__RequiredBy__r.sCode__c,
                         SBQQ__RequiredBy__r.Location_Position_Name__c, SBQQ__RequiredBy__r.LocationPositionName__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__RequiredBy__c IN :bundleIds AND SBQQ__ProductName__c =: Constant_Util.PR_PICKUP
                        ];
        
        return quoteLineList;
    }
    
    //TCS-pkulkarn-SDT-39624-3-Jul-2024-Added new method to query Pickup Quote Lines
    //Caller: ExtraPickupHandler.setCostAndPriceOnExtraPickup
    public static List<Pricing_Request__c> getPricingRequests(Set<Id> bundleIds)
    {
        List<Pricing_Request__c> priqList = [SELECT Id, Name, Line_of_Business__c, Container_Type__c, Container_Size__c, Material_Code__c, Service_Type__c, Quote__c, Quote__r.Name, Quote_Line_Bundle__c,
                                                 Quote_Line_Bundle__r.Name, Zone_Type__c, Haul_Rate_Type__c,  Haul_Cost__c, Haul_Price__c, Disposal_Rate_Type__c, Disposal_Cost__c, Disposal_Price__c, Pickup_Rate_Type__c,
                                                 Pickup_Cost__c, Pickup_Price__c, Extra_Pickup_Cost__c, Extra_Pickup_Price__c, isAPIResult__c, APIRequestOutput__c, Case_Error_Message__c, IsCaseError__c,
                                                 Cost_Source__c, Source_Code__c, Vendor_Code__c, Vendor_Name__c, Business_Unit__c, QuoteID__c,  Project_Request__c, Customer_Price_Type__c,
                                                 Disposal_Record_Id__c, Haul_Record_Id__c, Pickup_Record_Id__c, Extra_Pickup_Record_Id__c , Vendor_Comments__c, Facility_Id__c, Facility_Name__c 
                                                 FROM Pricing_Request__c 
                                                 WHERE Quote_Line_Bundle__c IN :bundleIds AND IsPriceChangeRequest__c = true  Order By CreatedDate DESC LIMIT 1];
                
        return priqList;
    }
    
    
    //TCS-pkulkarn-SDT-39624-3-Jul-2024-Added new method to query Pickup Quote Lines
    //Caller: ExtraPickupHandler.validateAndSetIsExtraPickupFlagOnPickup
    public static List<SBQQ__QuoteLine__c> getBundleAndExtraPickupQuoteLines(Set<Id> bundleIds)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        //Retrieve Bundle and Extra Pickup Lines
        quoteLineList = [SELECT Id, Occurrence_Type__c, IsExtraPickup__c, SBQQ__RequiredBy__c, SBQQ__ProductName__c, SBQQ__Quote__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE Id IN :bundleIds OR
                         (SBQQ__ProductName__c =: Constant_Util.PR_EXTRA_PICKUP AND SBQQ__RequiredBy__c IN :bundleIds)
                        ];
        
        return quoteLineList;
    }
    
    //TCS-pkulkarn-SDT-39624-3-Jul-2024-Added new method to query Pickup Quote Lines
    //Caller: ExtraPickupHandler.validateExtraPickupStartDate
    public static List<SBQQ__QuoteLine__c> getBundleQuoteLines(Set<Id> bundleIds)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        //Retrieve Bundle Lines
        quoteLineList = [SELECT Id, SBQQ__Quote__r.SBQQ__Type__c, AssetId__c, AssetId__r.Start_Date__c, SBQQ__StartDate__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE Id IN :bundleIds
                        ];
        
        return quoteLineList;
    }
    /*
    * @vendor            TCS
    * @story             SDT-38052
    * @author            Digdershika Ojha
    * @description       This method is used to return quote Line with quoteType and service Action used in QuoteLineTriggerHelper for sdt-38052
    * @param             Set of quoteLineIds
    * @return            List of type SBQQ__QuoteLine__c
    */
    public static List<SBQQ__QuoteLine__c> getQuoteLinesToUpdateServiceAction(Set<Id> quoteIds){
        List<SBQQ__QuoteLine__c> lstOfQuoteLines = [SELECT Id,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__Type__c,Service_Action__c 
                                                    From SBQQ__QuoteLine__c
                                                    where SBQQ__Quote__c IN :quoteIds AND 
                                                    (SBQQ__Quote__r.SBQQ__Type__c =: Constant_Util.QUOTE_TYPE_AMEND
                                                    OR SBQQ__Quote__r.SBQQ__Type__c =: Constant_Util.QUOTE_TYPE_CORRECTION
                                                    OR SBQQ__Quote__r.SBQQ__Type__c =: Constant_Util.QUOTE_TYPE_EXCEPTION)];
        return lstOfQuoteLines;
    }

    //TCS-pkulkarn-SDT-32740-25-09-2024-Added new query for Type Of Change field updates
    //Caller: QuoteTriggerHelper.compareAndUpdateTypeOfChangeFieldOnQuoteLine
    public static List<SBQQ__QuoteLine__c> getQuoteLinesToUpdateTypeOfChangeField(Set<Id> quotesUpdated)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        //SDT 48524 7/7/25 too many soql
        if(!quotesUpdated.isEmpty()){
        //Retrieve Bundle Lines
        quoteLineList = [SELECT Id, 
                         LocationPositionName__c, AssetId__r.Container_Position__c,
                         //Billing Administration Change fields start
                         ClientGLAccount__c, AssetId__r.GL_Code__c,
                         ClientCostCenter__c, AssetId__r.Cost_Center__c,
                         CompanyCategoryCode__c, AssetId__r.Category__c,
                         //Billing Administration Change fields end
                         SBQQ__StartDate__c, AssetId__r.Start_Date__c,
                         SBQQ__EndDate__c, AssetId__r.End_Date__c,
                         sCode__c, AssetId__r.Sensitivity_Code__c,
                         Equipment_Style__c, Service_Style__c,
                         Ownership__c, AssetId__r.Equipment_Owner__c,
                         //MAS Change Fields start
                         MASLibrary__c, AssetId__r.MAS_Library__c,
                         MASCompany__c, AssetId__r.MAS_Company_Code__c,
                         MASAccount__c, AssetId__r.MAS_Account_Number__c,
                         MASCustomerUniqueId__c, AssetId__r.MAS_Customer_Unique_Id__c,
                         MASServiceLine__c, AssetId__r.MAS_Line_Number__c,
                         //MAS Change Fields end
                         SBQQ__Quantity__c, AssetId__r.Quantity__c,
                         Equipment_Size__c, AssetId__r.Equipment_Size__c,
                         Occurrence_Type__c, AssetId__r.Occurrence_Type__c,
                         Schedule_Frequency__c, AssetId__r.Frequency__c,
                         Frequency_Interval__c, AssetId__r.Occurs__c,
                         Service_Days__c, AssetId__r.Monday__c, AssetId__r.Tuesday__c, AssetId__r.Wednesday__c, AssetId__r.Thursday__c, AssetId__r.Friday__c, AssetId__r.Saturday__c, AssetId__r.Sunday__c,
                         Vendor__c, AssetId__r.Supplier__c,
                         SBQQ__ListPrice__c, AssetId__r.SBQQ__RegularPrice__c,
                         SBQQ__UnitCost__c, AssetId__r.SBQQ__OriginalUnitCost__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: quotesUpdated 
                         AND AssetId__c != null
                         AND SBQQ__ProductFamily__c != 'Waste Category' 
                         AND SBQQ__ProductFamily__c != 'Waste Stream'
                        ];
        }
        return quoteLineList;
    }   
    //TCS-pkulkarn-SDT-33101-11-Nov-2024-Added new method to query Bundle Quote Lines based on QuoteId
    //Caller: QuoteTriggerHelper.validateAmendmentQuoteApproval
    public static List<SBQQ__QuoteLine__c> getBundleQuoteLinesByQuoteIds(Set<Id> quoteIds)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        //Retrieve Bundle Lines
        quoteLineList = [SELECT Id, SBQQ__Quote__c, CustomerApproval__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c IN :quoteIds AND SBQQ__RequiredBy__c = null
                        ];
        
        return quoteLineList;
    }
    //SDT-33101 -11-Nov-2024-Added new method to query all Quote Lines based on QuoteId
    //Caller: QuoteOnlyController.approveQuoteLine
    public static List<SBQQ__QuoteLine__c> getAllQuoteLinesByQuoteIds(Set<Id> quoteIds)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        //Retrieve Bundle Lines
        quoteLineList = [SELECT Id, SBQQ__Quote__c, CustomerApproval__c,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__RequiredBy__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c IN :quoteIds 
                        ];
        
        return quoteLineList;
    }
    //@ TCS-SDT 44716
    //@ Caller: QuoteTriggerHelper.compareAndUpdateTypeOfChangeFieldOnQuoteLine
    //@ This method will return parent QLs with Specific format used in email template
    public static List<SBQQ__QuoteLine__c> getQuoteLinesToUpdateSysField(Set<Id> quotesUpdated)
    {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        //Retrieve Bundle Lines
        quoteLineList = [SELECT Id,SBQQ__Quantity__c,toLabel(Equipment_Size__c),SBQQ__Product__r.Name,SBQQ__ProductName__c,toLabel(Occurrence_Type__c),
                         toLabel(Duration__c),toLabel(Schedule_Frequency__c),Service_Schedule__c,Final_Frequency__c,Frequency_Interval__c,Service_Days__c
                         FROM SBQQ__QuoteLine__c
                         WHERE SBQQ__Quote__c =: quotesUpdated AND SBQQ__RequiredBy__c = null
                        ];
        
        return quoteLineList;
    }
}