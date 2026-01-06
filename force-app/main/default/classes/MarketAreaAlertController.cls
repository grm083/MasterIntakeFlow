/*
*********************************************************
Apex Class Name    : MarketAreaAlertController
Created Date       : July 20, 2025
@description       : This is class is used for fetching Market Area Alerts from SBS
@author            : George Martin III
Modification Log:
Ver   Date         Author                               Modification
1.0   20-07-2025   George Martin                   	   Initial Version
1.1   24-07-2025   Soham Datta						   Added modification
1.2   28-07-2025   Kari Chandu						   Added modification
1.3   08-08-2025   George Martin					   Abstracted Date Identification
1.4   08-08-2025   Soham Datta					       Fixed endedFromDate issue
1.5   19-08-2025   Kari Chandu					       Fixed LOB on Loaction and equiments on Quote issues
1.6   30-09-2025   George Martin					   Modified class to look to custom metadata, built deployment module
1.7   01-10-2025   Kari Chandu						   Update instead of custom setting with custom object MAA_Admin_Settings__c
1.8   14-10-2025   Soham Datta						   Quote Page only display WM Alerts
*********************************************************
*/
public class MarketAreaAlertController {
    
    //Constants defined to capture some elements we may want to change quickly at the top of the class based on business feedback
    public static final string FETCHALERTS = 'FETCH_ALERTS';
    
    //Determines if the holistic feature should be enabled or not based on custom settings
    public static final Boolean ALERTSDISABLED = Code_Switch__c.getValues('Market Area Alerts').Switch_Off__c;
    
    //Case filter fields
    public static Integer CASEDATEDELTA ;
    public static Integer CASERECORDS ;
    public static Boolean CASEFILTERLOB ;
    
    //Location filter fields
    public static Integer LOCATIONDATEDELTA ;
    public static Integer LOCATIONRECORDS ;
    public static Boolean LOCATIONFILTERLOB ;
    
    //Quote filter fields
    public static Integer QUOTEDATEDELTA;
    public static Integer QUOTERECORDS;
    public static Boolean QUOTEFILTERLOB;
    public static Boolean QUOTEFILTEREQUIPMENT;
    
    //Recursion helper from LWC
    public static Boolean bodyConstructed = false;
    
    //fetching case service date
    public static  DateTime caseServiceDate = null;
    
    public static void getAdminPanelSettings(){
        list<MAA_Admin_Settings__c> adminSettings= [select id, MAA_Page_Type__c, Allow_Filtering_by_Equipment__c, Allow_Filtering_by_LOB__c, Number_of_Alerts_Per_Page__c, Number_of_Days_of_Alerts__c from MAA_Admin_Settings__c];
        
        for(MAA_Admin_Settings__c mas: adminSettings){
            if(mas.MAA_Page_Type__c == 'Case'){
                CASEDATEDELTA = (Integer)mas.Number_of_Days_of_Alerts__c * -1;
                CASERECORDS = (Integer)mas.Number_of_Alerts_Per_Page__c;
                CASEFILTERLOB = mas.Allow_Filtering_by_LOB__c;
            }
            if(mas.MAA_Page_Type__c == 'Quote'){
                QUOTEDATEDELTA = (Integer)mas.Number_of_Days_of_Alerts__c * -1;
                QUOTERECORDS = (Integer)mas.Number_of_Alerts_Per_Page__c;
                QUOTEFILTERLOB = mas.Allow_Filtering_by_LOB__c;
                QUOTEFILTEREQUIPMENT = mas.Allow_Filtering_by_Equipment__c;
            }
            if(mas.MAA_Page_Type__c == 'Location'){
                LOCATIONDATEDELTA = (Integer)mas.Number_of_Days_of_Alerts__c * -1;
                LOCATIONRECORDS = (Integer)	mas.Number_of_Alerts_Per_Page__c;
                LOCATIONFILTERLOB = mas.Allow_Filtering_by_LOB__c;
            }
        }
    }
    //Main method that accepts a locationCode (retrievable from LWC - see AllRulesModal for examples of dynamic sObjectType retrieval) and a recordId to determine the
    //overloaded method to call to construct the API body
    @AuraEnabled
    public static AlertsResponse getAlerts(Id recordId, Integer pageIndex,Integer pageSize) {
        
        //Fetch admin panel settings
        getAdminPanelSettings();       
        AlertsResponse ar = new AlertsResponse();
        
        //Display nothing if code switch is off 
        if (ALERTSDISABLED) {
            return ar;
        }
        
        String locationCode;
        String sObjectType = String.valueOf(recordId.getSobjectType());
        MAAlertBody alertBodyList = new MAAlertBody();
        
        switch on sObjectType {
            when 'Account' {
                Account a = [SELECT Id, AccountNumber FROM Account WHERE Id =: recordId LIMIT 1];
                locationCode = a.AccountNumber;
                //caseServiceDate = null;
                alertBodyList = generateBody(a, pageIndex, pageSize);
            }
            when 'Case' {
                List<Case> c = [SELECT Id, Location__r.AccountNumber, Service_Date__c, AssetId, Asset.CPQ_Product__r.ProductCode, Asset.CPQ_Material__r.ProductCode, Asset.Equipment_Size__c 
                                FROM Case 
                                WHERE Id =: recordId LIMIT 1];
                locationCode = c[0].Location__r.AccountNumber;
                caseServiceDate = c[0].Service_Date__c;
                
                //If no asset is attached to case, fetch alerts based on location
                if (!c.IsEmpty() && c[0].AssetId == null){
                    Account a = [SELECT Id, AccountNumber FROM Account WHERE Id =: c[0].Location__c LIMIT 1];
                    alertBodyList = generateBody(a, pageIndex, CASERECORDS);
                } else {
                    alertBodyList = generateBody(c[0], pageIndex, CASERECORDS);
                }
            }
            when 'SBQQ__Quote__c' {
                SBQQ__Quote__c q = [SELECT Id, SBQQ__Account__r.AccountNumber, SBQQ__StartDate__c FROM SBQQ__Quote__c WHERE Id =: recordId LIMIT 1];
                locationCode = q.SBQQ__Account__r.AccountNumber;
                //caseServiceDate = null;
                alertBodyList = generateBody(q, pageIndex, QUOTERECORDS);
            }
            when else {
                return ar;
            }
        }
        
        bodyConstructed = true;
        
        //Fetch integration metadata details
        Integration_Request_URLs__mdt alertsAPI = getAlertAPIDetails();
        //Callout to SBS Alerts
        ar = callAlertsAPI(alertsAPI, locationCode, JSON.serialize(alertBodyList));
        
        System.debug('ar::: '+ar);
        return ar;
        
    }
    
    //METHOD OVERLOADING BELOW.  Three methods constructed given various UIs needed to generate API body
    //First method is dedicated to Location Ids.  We must obtain a list of valid materials from the location's active assets
    //to make the return as selective as possible
    //Material is nulled after a conversation with the business dated 7/22/2025
    public static MAAlertBody generateBody(Account locationRecord, Integer pageIndex, Integer pageSize) {
        
        MAAlertBody alertBody = new MAAlertBody();
        
        //Call to supporting method to generate a map of <Line of Business, Set of Materials>
        Map<String, Set<String>> materialLOBMap = getLocationMap(locationRecord.Id);
        //System.debug('materialLOBMap:: '+materialLOBMap);
        if(materialLOBMap.isEmpty()){
            return alertBody;
        }
        
        alertBody = calculateEndedFrom(System.now().date(), String.valueOf(locationRecord.Id.getSobjectType()));
        alertBody.lob = '';
        
        if(LOCATIONFILTERLOB){
            if (materialLOBMap.size() == 1){
                for(String key : materialLOBMap.keyset()) {
                    alertBody.lob = key;
                }
            }
        }
        
        alertBody.pageIndex = pageIndex;
        alertBody.pageSize = pageSize;
        //System.debug('alertBody::: '+alertBody);
        return alertBody;
        
    }
    
    //Second method is dedicated to Case Ids.  Similar to the above, we need to construct a selective call to the API so 
    //we will limit by LOB and Material type.  Service Dates are used to generate date details
    //Similar to location callouts, the material codes have been rendered nullable in this instance.
    public static MAAlertBody generateBody(Case caseRecord, Integer pageIndex, Integer pageSize) {
        
        MAAlertBody alertBody = new MAAlertBody();
        List<String> relatedCaseIds = new List<String>();
        Set<String> caseLOBFilters = new Set<String>();
        List<String> selectedAssetIds = new List<String>();

        alertBody = calculateEndedFrom(caseRecord.Service_Date__c, String.valueOf(caseRecord.Id.getSobjectType()));
        List<Case> caseList = getCaseMap(new List<String>{caseRecord.Id});
        //System.debug('caseList:: '+caseList);
        //System.debug('Asset:: '+caseList[0].AssetId);
        
        if(!caseList.isEmpty() && caseList[0].AssetId != null) {
            Case c = caseList[0];
            //System.debug('Asset Ids: '+c.Selected_Asset_Header_Ids__c);
            if(CASEFILTERLOB){
                if (String.isNotBlank(c.Selected_Asset_Header_Ids__c)) {
                    selectedAssetIds = c.Selected_Asset_Header_Ids__c.split(';');
                }
                //System.debug('selectedAssetIds::: '+selectedAssetIds);
                if(!selectedAssetIds.isEmpty()){
                    List<Asset> relatedWMAssets = getAssetMap(selectedAssetIds);
                    //System.debug('relatedWMAssets:: '+relatedWMAssets);
                    if(!relatedWMAssets.isEmpty()){
                        //Adding Parents LOB
                        caseLOBFilters.add(c.Asset.CPQ_Product__r.Family);
                        for(Asset ast: relatedWMAssets){
                            //Adding children LOB
                            caseLOBFilters.add(ast.CPQ_Product__r.Family);
                        }
                    }
                }
                
                //Assign LOB Filter for Case
                alertBody.lob = caseLOBFilters.size() > 1 ? '' : c.Asset.CPQ_Product__r.Family;
            }
            //alertBody.lob = CASEFILTERLOB ? c.Asset.CPQ_Product__r.Family : '';
            alertBody.pageIndex = pageIndex;
            alertBody.pageSize = pageSize;
        } else if (caseList.isEmpty()) {
            getAlerts(caseRecord.Location__c, pageIndex, CASERECORDS);
            Account a = [SELECT Id, AccountNumber FROM Account WHERE Id =: caseRecord.Location__c LIMIT 1];
            alertBody = generateBody(a, pageIndex, CASERECORDS);
            alertBody = calculateEndedFrom(caseRecord.Service_Date__c, String.valueOf(caseRecord.Id.getSobjectType()));
        }
        
        //System.debug('alertBody: '+alertBody);
        return alertBody;
        
    }
    
    public static MAAlertBody generateBody(SBQQ__Quote__c quoteRecord, Integer pageIndex, Integer pageSize) {
        
        MAAlertBody alertBody = new MAAlertBody();
        String lineOfBusiness = '';
        Set<String> materialSet = new Set<String>();
        Set<equipments> equipmentSet = new Set<equipments>();
        Set<String> setNonWMVendor = new Set<String>();
        List<QuoteProcurementController.HeaderWrapper> wmHWList = new List<QuoteProcurementController.HeaderWrapper>();
        
        QuoteProcurementController.ProductsWrapper productsWrapper = QuoteProcurementController.buildQuoteWrapper(quoteRecord.Id);
        List<QuoteProcurementController.HeaderWrapper> hwList = productsWrapper.configuredProducts;
        //System.debug('hwList:: '+hwList);
        if (hwList.isEmpty()) {
            getAlerts(quoteRecord.SBQQ__Account__c, pageIndex, QUOTERECORDS);
        }
        
        for(QuoteProcurementController.HeaderWrapper hw: hwList){
            if(String.isNotBlank(hw.vendorName)){
                if(hw.vendorName.startsWithIgnoreCase('wm') || hw.vendorName.startsWithIgnoreCase('waste management') || hw.parentVendorId == '8' || hw.parentVendorId == '5889'){
                    wmHWList.add(hw);
                }else{
                    setNonWMVendor.add(hw.vendorName);
                }
            }
        }
        //System.debug('wmHWList:: '+wmHWList);
        //System.debug('setNonWMVendor:: '+setNonWMVendor);
        if(wmHWList.isEmpty() && setNonWMVendor.isEmpty()){
            MAAlertBody dateRangeAlertBody = calculateEndedFrom(quoteRecord.SBQQ__StartDate__c, String.valueOf(quoteRecord.Id.getSobjectType()));
            Account a = [SELECT Id, AccountNumber FROM Account WHERE Id =: quoteRecord.SBQQ__Account__c LIMIT 1];
            alertBody = generateBody(a, pageIndex, QUOTERECORDS);
            alertBody.Types = new List<String>{'Operational', 'Inventory', 'Early Service'};
            alertBody.endedFrom = dateRangeAlertBody.endedFrom;
            alertBody.endedTo = dateRangeAlertBody.endedTo;
            return alertBody;
        }else if(!setNonWMVendor.isEmpty() && wmHWList.isEmpty()){
            return null;
        }
        
        Map<String, List<QuoteProcurementController.HeaderWrapper>> callOutMap = getQuoteMap(wmHWList);
        if(callOutMap.size() > 1 || !QUOTEFILTERLOB) {
            lineOfBusiness = '';
        } else {
            for (String key : callOutMap.keyset()) {
                if (key != 'Commercial' && key != 'Rolloff') {
                    lineOfBusiness = '';
                }
                lineOfBusiness = key;
            }
        }
        for(String key : callOutMap.keyset()) {
            for (QuoteProcurementController.HeaderWrapper hw : callOutMap.get(key)) {
                equipments e = new equipments();
                if(QUOTEFILTEREQUIPMENT) {
                    e.code = hw.equipmentTypeCode;
                    e.sizeCode = getEquipmentSizeCode(hw.equipmentSize);
                    equipmentSet.add(e);
                } else {
                    e.code = '';
                    e.sizeCode = '';
                    equipmentSet.add(e);
                }
            }
        }
        
        alertBody = calculateEndedFrom(quoteRecord.SBQQ__StartDate__c, String.valueOf(quoteRecord.Id.getSobjectType()));
        alertBody.lob = lineOfBusiness;
        alertBody.equipments = new List<equipments>(equipmentSet);
        alertBody.pageSize = pageSize;
        alertBody.pageIndex = pageIndex;
        alertBody.Types = new List<String>{'Operational', 'Inventory', 'Early Service'};
        return alertBody;
    }
    
    //Identify the selected asset for a case, specifically those that are servied by WM specifically
    public static List<Case> getCaseMap(List<String> caseIds) {
        
        List<Case> caseAsset = new List<Case>();
        
        caseAsset = [SELECT AssetId, Asset.CPQ_Product__r.Family, Asset.CPQ_Product__r.ProductCode, Asset.CPQ_Material__r.ProductCode, Location__c, Reference_Number__c, Selected_Asset_Header_Ids__c
                     FROM Case
                     WHERE Id In: caseIds 
                     AND (Asset.Supplier__r.Parent_Vendor_ID__c = '8' OR Asset.Supplier__r.Parent_Vendor_ID__c = '5889' OR Asset.Supplier__r.Name LIKE 'WM%' OR Asset.Supplier__r.Name LIKE 'Waste Management%')];
        
        return caseAsset;
        
    }
    
    //Identify the selected multiple assets for a case, specifically those that are servied by WM specifically
    public static List<Asset> getAssetMap(List<String> assetIds) {
        
        return [SELECT Id, CPQ_Product__r.Family, CPQ_Product__r.ProductCode, Equipment_Size__c, Is_Active__c, Supplier__r.Parent_Vendor_Id__c, Supplier__r.Name 
                FROM Asset 
                WHERE (Supplier__r.Parent_Vendor_Id__c = '8' OR Supplier__r.Parent_Vendor_Id__c = '5889' OR Supplier__r.Name LIKE 'WM%' OR Supplier__r.Name LIKE 'Waste Management%')
                AND Is_Active__c = true
                AND Id IN :assetIds];
        
        
    }
    
    //Identify active assets at a location, identify those that are serviced by WM specifically.  Return a set of Material Types, as this is the only dynamic
    //field needed for locations
    public static Map<String, Set<String>> getLocationMap(String locationId) {
        
        Map<String, Set<String>> materialLOBMap = new Map<String, Set<String>>();
        List<Asset> assetHeaderList = [SELECT Id, CPQ_Material__r.ProductCode, CPQ_Product__r.Family, 
                                       CPQ_Product__r.ProductCode, Equipment_Size__c
                                       FROM Asset
                                       WHERE RecordType.Name = 'Service Header' 
                                       AND (Supplier__r.Parent_Vendor_Id__c = '8' OR Supplier__r.Parent_Vendor_Id__c = '5889' OR Supplier__r.Name LIKE 'WM%' OR Supplier__r.Name LIKE 'Waste Management%') 
                                       AND AccountId =: locationId
                                      AND Is_Active__c = true];
               
        if(!assetHeaderList.isEmpty() && assetHeaderList.size() > 0) {
            for(Asset a : assetHeaderList) {
                Set<String> materialList = new Set<String>();
                if(materialLOBMap.get(a.CPQ_Product__r.Family) != null) materialList = materialLOBMap.get(a.CPQ_Product__r.Family);
                materialList.add(a.CPQ_Material__r.ProductCode);
                if (a.CPQ_Product__r.Family == 'Commercial' || a.CPQ_Product__r.Family == 'Rolloff'){
                   materialLOBMap.put(a.CPQ_Product__r.Family, materialList); 
                }

            }
        }
		assetHeaderList = null;
        return materialLOBMap;
    }
    
    //Break apart a quote into a map, where each key represents the number of API calls that we would need to invoke
    public static Map<String, List<QuoteProcurementController.HeaderWrapper>> getQuoteMap(List<QuoteProcurementController.HeaderWrapper> quoteHeaderWrapper) {
        Map<String, List<QuoteProcurementController.HeaderWrapper>> productsLOBMap = new Map<String, List<QuoteProcurementController.HeaderWrapper>>();
        Set<String> productList = new Set<String>();
        Map<Id, List<QuoteProcurementController.HeaderWrapper>> productMap = new Map<Id, List<QuoteProcurementController.HeaderWrapper>>();
        
        //LOB is a required field and is not explicitly defined in the header wrapper class, this block will put together a map of the header wrappers by product id
        for (QuoteProcurementController.HeaderWrapper hw : quoteHeaderWrapper) {
            productList.add(hw.productId);
            List<QuoteProcurementController.HeaderWrapper> hwList = new List<QuoteProcurementController.HeaderWrapper>();
            if(productMap.get(hw.productId) != null) {
                hwList = productMap.get(hw.productId);
            }
            hwList.add(hw);
            productMap.put(hw.productId, hwList);
        }
        
        //Store the productIds in the header for simple retrieval of the LOB (family)
        Map<Id, Product2> productListMap = new Map<Id, Product2>([SELECT Id, Family, ProductCode FROM Product2 WHERE Id IN :productList]);
        String lineOfBusiness = '';
        
        //If there are multiple types of products being setup, this will construct a map of the products so that we can match the productId on the header record
        //to the key value in the productListMap below
        if (!productList.isEmpty() && productList.size() > 1) {
            Set<String> lineOfBusinessList = new Set<String>();
            for (Id key : productListMap.keyset()) {
                lineOfBusiness = productListMap.get(key).Family;
                List<QuoteProcurementController.HeaderWrapper> existingHeaderList = new List<QuoteProcurementController.HeaderWrapper>();
                if (productsLOBMap.get(lineOfBusiness) != null) existingHeaderList = productsLOBMap.get(lineOfBusiness);
                existingHeaderList.addAll(productMap.get(key));
                productsLOBMap.put(lineOfBusiness, existingHeaderList);
            }
        } else if (productList.size() != 0) {
            lineOfBusiness = productListMap.get(new List<String> (productList).get(0)).Family;
            List<QuoteProcurementController.HeaderWrapper> newHeaderList = productMap.get(new List<String> (productList).get(0));
            productsLOBMap.put(lineOfBusiness, newHeaderList);
        }        
        
        //The result is a map that should have no greater than 3 keys of type string (line of business) with a list of product details
        return productsLOBMap;
        
    }
    
    //Utility to get the appropriate Custom Metadata Record for the API Call
    public static Integration_Request_URLs__mdt getAlertAPIDetails() {
        Integration_Request_URLs__mdt alert = [SELECT Id, DeveloperName, End_Point__c, Client_Key__c, Client_Token__c, Content_Type__c,
                                               Timeout__c, Method__c
                                               FROM Integration_Request_URLs__mdt
                                               WHERE DeveloperName =: FETCHALERTS
                                               LIMIT 1];
        return alert;
    }
    
    //Utility to invoke the returned API endpoint and parameters in the above referenced method
    public static AlertsResponse callAlertsAPI(Integration_Request_URLs__mdt mdURL, String locationCode, String requestBody) {
        
        String response = '';
        AlertsResponse jsonResp = new AlertsResponse();
        
        String endpoint = mdURL.End_Point__c;
        endPoint = endPoint.replace('{LocationCode}', locationCode);
        requestBody = requestBody.replace('Rolloff', 'Roll off');
        
        Http h = new Http();
        HttpRequest hReq = new HttpRequest();
        
        system.debug('Request body is ' + requestBody);
        
        //Preventing double calls
        MAAlertBody body = (MAAlertBody) System.JSON.deserialize(requestBody, MAAlertBody.class);
        
        if (body == null || body.endedFrom == null) {
            return jsonResp;
        }
                
        hReq.setEndpoint(endPoint);
        hReq.setMethod(mdURL.Method__c);
        hReq.setHeader('Content-Type', mdURL.Content_Type__c);
        hReq.setHeader('X-USERID', '1');
        hReq.setHeader('X-PARTNER-KEY', mdURL.Client_Key__c);
        hReq.setHeader('Authorization', mdURL.Client_Token__c);
        hReq.setBody(requestBody);
        hReq.setTimeout(mdURL.Timeout__c.intValue());
        
        try {
            HttpResponse hResp = h.send(hReq);
            response = hResp.getBody();
            jsonResp = (AlertsResponse) System.JSON.deserialize(response, AlertsResponse.class);
            //System.debug('Code::: '+hResp.getStatusCode());
            //System.debug('jsonResp::: '+jsonResp.count);
        } catch (Exception e) {
            throw e;
        }
        
        return jsonResp;
        
    }
    
    //Utility method to get the equipment size code based on the equipment size label
    //Specifically referencing the equipment size field on quote lines as they are already stored as label/acorn code to adhere to Acorn integration patterns
    public static String getEquipmentSizeCode(String equipmentSize) {
        String equipmentSizeCode;
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap().get('Equipment_Size__c').getDescribe();
        
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            if(picklistEntry.getLabel() == equipmentSize) {
                equipmentSizeCode = picklistEntry.getValue();
                break;
            }
        }
        
        return equipmentSizeCode;
    }
    
    //For connected call back for page size given an sObjectTYpe
    @AuraEnabled
    public static Integer getPageSize(Id recordId) {
        getAdminPanelSettings();
        String sObjectType = String.valueOf(recordId.getSobjectType());
        
        Switch on sObjectType {
            when 'Case' {
                return CASERECORDS;
            }
            when 'SBQQ__Quote__c' {
                return QUOTERECORDS;
            }
            when 'Account' {
                return LOCATIONRECORDS;
            }
            WHEN else {
                return 10;
            }
            
        }
        
    }
    
    //Generalized utility class to parse JSON responses into the nested class defined below
    public static AlertsResponse parseAlerts(String json) {
        AlertsResponse ar = (AlertsResponse) System.JSON.deserialize(json, AlertsResponse.class);
        return ar;
    }
    
    // Get switch code Market Area Alerts.
    @AuraEnabled(cacheable=true)
    public static boolean getMAASwitch(){
        return ALERTSDISABLED;
    }
    
    //The purpose of this method is to abstract the date calculations associated with the MAA callout body
    //This centralizes the logic for handling our "endedFrom" variable in the request body of the API
    public static MAAlertBody calculateEndedFrom(DateTime targetDate, String sObjectType) {
        
        MAAlertBody alertBody = new MAAlertBody();
        DateTime endedFromDate = targetDate != null ? targetDate : System.now();
        DateTime endedToDate;      
        //System.debug('endedFromDate: '+endedFromDate);
        
        Switch on sObjectType {
            when 'Case' {
                endedToDate = endedFromDate.addDays(CASEDATEDELTA*-1+1);
                endedFromDate = endedFromDate.addDays(CASEDATEDELTA+1);
            }
            when 'Account' {
                endedToDate = caseServiceDate == null ? endedFromDate.addDays((365)) : caseServiceDate.addDays(LOCATIONDATEDELTA*-1+1);
                endedFromDate = caseServiceDate == null ? endedFromDate.addDays(LOCATIONDATEDELTA+1) : caseServiceDate.addDays(LOCATIONDATEDELTA+1);
            	//endedToDate = DateTime.newInstance(2025, 10, 4);
                //endedFromDate = DateTime.newInstance(2024, 10, 4);
            }
            when 'SBQQ__Quote__c' {
                endedToDate = endedFromDate.addDays(QUOTEDATEDELTA*-1+1);
                endedFromDate = endedFromDate.addDays(QUOTEDATEDELTA+1);
            }
            when else {
                alertBody.endedFrom = endedFromDate.format('YYYY-MM-dd');
                return alertBody;
            }
        }
        
        alertBody.endedFrom = endedFromDate.format('YYYY-MM-dd');
        alertBody.endedTo = endedToDate != null ? endedToDate.format('YYYY-MM-dd') : '';
        //System.debug('endedFrom::: '+alertBody.endedFrom);
        //System.debug('endedFrom::: '+alertBody.endedTo);
        
        return alertBody;
    }
    
    //Nested class to handle the request and response structure of the alerts API
    //Reutilizing standard ErrorMessageWrapper designed under the WorkOrderWebServices class
    public class MAAlertBody {
        public string lob {get; set;}
        public List<String> materialCodes {get; set;}
        public string endedFrom {get; set;}
        public string endedTo {get; set;}
        public List<equipments> equipments {get; set;}
        public List<String> Types {get; set;}
        public Integer pageIndex {get; set;}
        public Integer pageSize {get; set;}
    }
    
    public class equipments {
        public string code {get; set;}
        public string sizeCode {get; set;}
    }
    
    public class AlertsResponse {
        @AuraEnabled public List<Data> Data {get; set;}
        @AuraEnabled public WorkOrderWebservices.ErrorMessageWrapper Problem {get; set;}
        @AuraEnabled public Integer pageIndex {get; set;}
        @AuraEnabled public Integer pageSize {get; set;}
        @AuraEnabled public Integer count {get; set;}
    }	
    
    public class Data {
        @AuraEnabled public String reason {get; set;}
        @AuraEnabled public String outageReason {get; set;}
        @AuraEnabled public String wasteStream {get; set;}
        @AuraEnabled public string lob {get; set;}
        @AuraEnabled public String startDate {get; set;}
        @AuraEnabled public string globalAlertType {get; set;}
        @AuraEnabled public String recoveryDate {get; set;}
        @AuraEnabled public String endDate {get; set;}
        @AuraEnabled public String facilityType {get; set;}
        @AuraEnabled public String title {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String newServiceDate {get; set;}
        @AuraEnabled public String recipients {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public String recoveryPlan {get; set;}
        @AuraEnabled public String recoveryOption {get; set;}
        @AuraEnabled public String marketAreaId {get; set;}
        @AuraEnabled public String action {get; set;}
        @AuraEnabled public String other {get; set;}
        @AuraEnabled public String marketareaName {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String serviceDisruptionStartDate {get; set;}
        @AuraEnabled public String agentInstructions {get; set;}
        @AuraEnabled public String equipmentCode {get; set;}
        @AuraEnabled public String outageType {get; set;}
        @AuraEnabled public String outageStartDate {get; set;}
        @AuraEnabled public String country {get; set;}
        @AuraEnabled public String nonCustomTitle {get; set;}
        @AuraEnabled public String extend {get; set;}
        @AuraEnabled public String impactGeographicalArea {get; set;}
        @AuraEnabled public String equipmentName {get; set;}
        @AuraEnabled public String internalStandardPreview {get; set;}
        @AuraEnabled public String externalStandardPreview {get; set;}
        @AuraEnabled public String communicationStandardPreview {get; set;}
        @AuraEnabled public List<Sites> Sites {get; set;}
    }
    
    public class Sites {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String routeId {get; set;}
        @AuraEnabled public String alertFacilitiesName {get; set;}
    }
    
}