/**
 * @description       : Class to return Availability API record.
 * @author            : Hanmi Reddy
 * @last modified on  : 5-24-2023
 * @last modified by  : Hanmi Reddy
 * Modifications Log
 * Ver      Date         Author            Modification
 * 1.0      5-24-2023    Hanmi Reddy       Initial Version
 *       
 **/

public class AAV_APIIntegration {

    static AAV_Asset_Availability__c availability;
    /*@methodName- getAvailabilityRecord
    *@description- Method to get the Availability Record by Quote Line Id  
    *@param- Id : quoteLineId
    *@return- Asset Availability record
    */  
    @AuraEnabled(cacheable=false)
    public static AAV_Asset_Availability__c getAvailabilityRecord(String quoteLineId){
        if(quoteLineId != null){
            list<AAV_Asset_Availability__c> availabilityList = [SELECT Id,AAV_APIRequestOutput__c,AAV_isAPIResult__c, CreatedDate, format(CreatedDate) createdDt 
                                            FROM AAV_Asset_Availability__c 
                                            WHERE AAV_Quote_Line__c =: quoteLineId Order BY CreatedDate DESC];    //modified query as part of SDT 31585    
            //Check availability record is exist or not, if exist then return the availability Record.     
            if(availabilityList != null && availabilityList.size() > 0){
                availability = availabilityList[0];
                return availability;
            }
            return null;
        } else {
            throw new AuraHandledException('Quote Bundle is Empty');
        }
    }
    /*@methodName- getAvailabilityResponse
    *@description- Method to get the Availability Record by Quote Line Id  
    *@param- Id : quoteLineId
    *@return- Asset Availability record
    */  
    @AuraEnabled
    public static AAV_Asset_Availability__c getAvailabilityResponse(String quoteLineId){
        if(quoteLineId != null){
            
            list<AAV_Asset_Availability__c> availabilityList = [SELECT Id,AAV_APIRequestOutput__c,AAV_isAPIResult__c 
                                            FROM AAV_Asset_Availability__c 
                                            WHERE AAV_Quote_Line__c =: quoteLineId];    
            //Check availability record is exist or not, if exist then return the availability Record.     
            if(availabilityList != null && availabilityList.size() > 0){
                availability = availabilityList[0];
                return availability;
            } else { 
                //If availability record not found then make a call to the Availability API
               try {
                    availability = getAvailabilityDetail(quoteLineId, null);
                    return availability;
               } catch (Exception e) {
                    system.debug('excep @@:'+ e.getMessage());
                    throw new AuraHandledException(e.getMessage());
                   // return availability;
                }
            }
            
        } else {
            throw new AuraHandledException('Quote Bundle is Empty');
        }
    }
    /*@methodName- retryAvailabilityResponse
    *@description- Method to get the Availability Record by Quote Line Id  
    *@param- Id : quoteLineId
    *@return- Asset Availability record
    */  
    @AuraEnabled
    public static AAV_Asset_Availability__c retryAvailabilityResponse(String quoteLineId){
        if(quoteLineId != null){
            
            list<AAV_Asset_Availability__c> availabilityList = [SELECT Id,AAV_APIRequestOutput__c,AAV_isAPIResult__c 
                                            FROM AAV_Asset_Availability__c 
                                            WHERE AAV_Quote_Line__c =: quoteLineId];    
            //Check availability record is exist or not, if exist then return the availability Record. 
            string availabilityId;
            if(availabilityList != null && availabilityList.size() > 0){
                availabilityId = availabilityList[0].Id;
            }
            try {
                availability = getAvailabilityDetail(quoteLineId, availabilityId);
                return availability;
            } catch (Exception e) {
                system.debug('excep @@:'+ e.getMessage());
                throw new AuraHandledException(e.getMessage());               
            }
        } else {
            throw new AuraHandledException('Quote Bundle is Empty');
        }
    }
    /*@methodName- getAvailabilityDetail
    *@description- Method to make call to the Availability API and create Record by Quote Line Id  
    *@param- Id : quoteLineId
    *@return- Asset Availability record
    */ 
    @AuraEnabled
    public static AAV_Asset_Availability__c getAvailabilityDetail(String quoteLineId, String availabilityId){
        //call method to get Assert Availability record
        availability = getAssetAvailability(quoteLineId);
        availability = makeApiCallout(availability,availabilityId);
        //Insert / update the availability record
        upsert availability;
        return availability;
    }

    /**************************************************
    * Created By:TCS av4
    * CreatedDate:
    * Story: SDT-31585
    * Description : To make call to the Availability API and create Record by Quote Line Id  
    * Return : Asset Availability Record
    * **************************************************/
    @AuraEnabled
    public static AAV_Asset_Availability__c getUpdatedAvailability(String quoteLineId, Date vendorCommitDate){
        if(quoteLineId != null){
            
            List<AAV_Asset_Availability__c> aavRecords;
            
            try {
                //call method to get Asset Availability record
                availability = getAssetAvailability(quoteLineId);
                
                if(vendorCommitDate != null)
                	availability.AAV_Delivery_Date__c = vendorCommitDate;
                
                availability = makeApiCallout(availability,null);
                //Insert the availability record
                insert availability;
                
                //querying and returning the availability record
                aavRecords = [Select Id, CreatedDate, format(CreatedDate) createdDt, AAV_APIRequestOutput__c, AAV_isAPIResult__c, 
                              AAV_Quote_Line__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, AAV_Quote_Line__r.SBQQ__Product__r.name, 
                              AAV_Quote_Line__r.equipment_size__c 
                              FROM AAV_Asset_Availability__c WHERE AAV_Quote_Line__c =: quoteLineId Order By CreatedDate DESC];
                
                
                //calling method to create a comment record
                if(aavRecords[0].AAV_isAPIResult__c)
                	createCommentForAAVChangeHistory(aavRecords[0].AAV_Quote_Line__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, aavRecords[0].CreatedDate.format(),
                                                UserInfo.getTimeZone(), aavRecords[0].AAV_Quote_Line__r.equipment_size__c,
                                                aavRecords[0].AAV_Quote_Line__r.SBQQ__Product__r.name);
                
            }
            catch (Exception e) {
                throw new AuraHandledException(e.getMessage());               
            }
            
            if(aavRecords.size() > 0) 
                return aavRecords[0];
            else 
                return null;
        }
        else {
            throw new AuraHandledException('Quote Bundle is Empty');
        }
    }
    

    /**************************************************
    * Created By:TCS av4
    * CreatedDate:
    * Story: SDT-31585
    * Description : To create and insert a comment record to capture and retain availability change history  
    * Return : 
    * **************************************************/
    public static void createCommentForAAVChangeHistory(String caseId, String latestApiCallDate,TimeZone userTimeZone, String equipSize, String productName) {
        
        try {
            if(caseId != null && !String.IsEmpty(caseId)) {
                //creating a map of metadata records of Comment_Log_Detail__mdt type and getting the SLA_Override record
                Map<String , Comment_Log_Detail__mdt> commentLogTemplateData = new Map<String , Comment_Log_Detail__mdt>();
                for(Comment_Log_Detail__mdt c : Comment_Log_Detail__mdt.getAll().values()){
                    commentLogTemplateData.put(c.DeveloperName , c);
                }
                Comment_Log_Detail__mdt aavChangeHitoryCommentTemplate = commentLogTemplateData.get('AAV_Change_History');
                
                
                //creating the comment body
                String commentBody = aavChangeHitoryCommentTemplate.Comment__c.replaceAll('<NewAavDate__x>', String.valueOf(latestApiCallDate));
                commentBody = commentBody.replaceAll('<EquipmentSize__x>', equipSize);
                commentBody = commentBody.replaceAll('<ProductName__x>', productName);
                commentBody = commentBody.replaceAll('<TimeZone__x>', userTimeZone.getDisplayName());

                //calling method to create and insert Comment__c record into the database
                AcornController.createAcornComment(commentBody, caseId);
                
            }
            
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        
    }
    
    
    /*@methodName- makeApiCallout
    *@description- Method to make call to the Availability API 
    *@param- Id : AAV_Asset_Availability__c
    *@return- void
    */ 
    @AuraEnabled
    public static AAV_Asset_Availability__c makeApiCallout(AAV_Asset_Availability__c availability,String availabilityId){
        String responseBody;
        Integration_Request_URLs__mdt urlMD;
        String integrationName;
        String endpoint;
        String No_Mapping = System.label.No_Mapping; 
        if(availability != null){
            if(String.isNotBlank(availabilityId)){
                availability.Id = availabilityId;
            }
            integrationName =  availability.AAV_Line_of_Business__c == 'Rolloff' ? 
                                'AvailabilityLocationRollOff' : 'AvailabilityLocationCommercial'; 
            //get available API detailes from metadata
            urlMD =  AAV_AvailabilityUtility.getIntegrationRecord(integrationName);        
            endpoint = urlMD.End_Point__c;
            endpoint = endpoint.replace(Constant_Util.PR_LOCATION_CODE, availability.AAV_Location_Name__c);
            endpoint += '?' + 'MaterialCode=';
            endpoint += availability.AAV_MaterialCode__c;
            endpoint += availability.AAV_Service_Type__c != null ?
                        '&EquipmentAvailabilityCode='+availability.AAV_Service_Type__c :'' ;
            endpoint += availability.AAV_Container_Type__c != null ?
                        '&EquipmentCode='+availability.AAV_Container_Type__c :'' ;
            //SDT-32012
            endpoint += availability.AAV_Delivery_Date__c != null ?
                        '&DeliveryDate='+availability.AAV_Delivery_Date__c :'' ;                
            endpoint = endpoint.replace(' ', '%20');
            //Make API call
            AAV_AvailabilityUtility.RequestHeaders reqHeaders = new AAV_AvailabilityUtility.RequestHeaders();
            reqHeaders.endpoint         = endpoint;
            reqHeaders.method           = 'GET';
            reqHeaders.classMethodName  = 'getAvailabilityDetail';
            reqHeaders.requestId        = availability.AAV_Location_Name__c;
            reqHeaders.intMetaData      = urlMD;
            AAV_AvailabilityUtility.RequestResponse reqResponse = AAV_AvailabilityUtility.getResponse(reqHeaders);
            if(reqResponse.errorMessage != null){
                availability.AAV_isAPIResult__c = false;  
                availability.AAV_APIRequestOutput__c = reqResponse.errorMessage;      
            } else {
                HttpResponse response = reqResponse.response;
                if(response.getStatusCode() != 200) {
                    availability.AAV_isAPIResult__c = false;
                } else {                
                    availability.AAV_isAPIResult__c = true;
                }
                availability.AAV_APIRequestOutput__c = response.getBody();
            }
        } 
        return availability;
    }
   /*@methodName- getAssetAvailability
    *@description- Method to create the Availability Record by Quote Line Id  
    *@param- Id : quoteLineId
    *@return- Uncomitted Asset Availability record
    */  
    public static AAV_Asset_Availability__c getAssetAvailability(String quoteLineId){
        List<SBQQ__Quote__c> quoteDataList = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        String productName;
        String quoteID;
        AAV_Asset_Availability__c availability;
        String No_Mapping = System.label.No_Mapping; 

        quoteLineItems = [SELECT Id, SBQQ__Product__r.ProductCode, SBQQ__Quote__c, Duration__c, Equipment_Size__c, SBQQ__Product__r.Name                                                      
                         FROM SBQQ__QuoteLine__c 
                         WHERE Id =: quoteLineId AND SBQQ__RequiredBy__c = null ];

        if(quoteLineItems != null && quoteLineItems.size() > 0){
            quoteID = quoteLineItems[0].SBQQ__Quote__c;
            quoteDataList = [SELECT Id, SBQQ__Account__r.Id, SBQQ__Opportunity2__r.Case__c, 
                SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName, SBQQ__Account__r.Name
                FROM SBQQ__Quote__c WHERE Id =: quoteID 
                AND (SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName =: Constant_Util.R_NEW_SERVICE_CASE
                OR SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName =: Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API)];
                //OR SBQQ__Opportunity2__r.Case__r.RecordType.DeveloperName =: Constant_Util.R_UPDATE_ASSET_CASE)];
        }
        //proceed only if quote data exists
        if(quoteDataList != null && quoteDataList.size() > 0){   
            SBQQ__QuoteLine__c   quoteLine =  quoteLineItems[0];
            SBQQ__Quote__c quoteData = quoteDataList[0];

            List<String> prContainerTypeLst = UTIL_Picklist.getPickListValuesIntoList(
                                                                    'Pricing_Request__c', 'Container_Type__c');
          /*  Map<String,List<String>> prDependentContainerSizeLst = UTIL_Picklist.getPicklistDependentValues(
                                                                    'Pricing_Request__c', 'Container_Size__c');*/
            Map<String,List<String>> prDependentMaterialLst = UTIL_Picklist.getPicklistDependentValues(
                                                                    'Pricing_Request__c', 'Material_Code__c');
            
            availability = new AAV_Asset_Availability__c();
            availability.AAV_Quote_Line__c      = quoteLineId;
            availability.AAV_Location__c        = quoteData.SBQQ__Account__r.Id;
            availability.AAV_Location_Name__c   = quoteData.SBQQ__Account__r.Name;
            string  productCode = quoteLine.SBQQ__Product__r.ProductCode;

            //Logic for add Equipment Availability Code
            if(quoteLine.Duration__c == 'SEAS') {
                availability.AAV_Service_Type__c = 'Temp';
                //pricingRequest.Service_Type__c= 'Temp';
                //  isError = true;
                //  errorMessage += ', Can not create Pricing Request for Seasonal duration type.';
                
            }
            else {
                availability.AAV_Service_Type__c = quoteLine.Duration__c;
                
            }

            //Logic for add Line of Business & Equipment Code
            if (productCode == 'OT') {
                availability.AAV_Line_of_Business__c = Constant_Util.ROLLOFF;
            }
            else if(productCode == 'CMP' 
                    && quoteLine.Equipment_Size__c != null 
                    && quoteLine.Equipment_Size__c.contains('-')) {

                    integer eqSize = Integer.valueOf(quoteLine.Equipment_Size__c.substringAfter('-'));
                    if(eqSize >= 10) {
                        availability.AAV_Container_Type__c = 'CMP';
                        availability.AAV_Line_of_Business__c = Constant_Util.ROLLOFF;
                    }
                    else {
                        availability.AAV_Container_Type__c = 'VTC';
                        availability.AAV_Line_of_Business__c = Constant_Util.COMMERCIAL;
                    }                  
            }
            else {
                availability.AAV_Line_of_Business__c = Constant_Util.COMMERCIAL;
            }                
            
            //logic for adding Equipment Code
            if(productCode != null && availability.AAV_Container_Type__c == null ){
                
                map<string,string> proContainerMap = AAV_AvailabilityUtility.getProductMeterialMap(prContainerTypeLst);
                if(proContainerMap.containsKey(productCode)){
                    availability.AAV_Container_Type__c = productCode;
                }
                //Validation PR Data.
                If(availability.AAV_Container_Type__c == null){
                    availability.AAV_Container_Type__c =No_Mapping;                      
                }
                
            }

            // Logic for add Meterial code to the availability record
            if(prDependentMaterialLst.containsKey(availability.AAV_Line_of_Business__c)){
                List<SBQQ__QuoteLine__c> materialCode = [SELECT Id, SBQQ__Product__r.ProductCode
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Product__r.Family = 'Waste Stream' 
                            AND SBQQ__RequiredBy__r.SBQQ__RequiredBy__c =: quoteLineId ];
                List<String> prMaterialLst = prDependentMaterialLst.get(availability.AAV_Line_of_Business__c);
                //call utility class and get map b/w Material Cobination
                map<string,string> productMeterialMap = AAV_AvailabilityUtility.getProductMeterialMap(prMaterialLst);
                for (SBQQ__QuoteLine__c wsLineItem : materialCode) {
                    if(productMeterialMap.containsKey(wsLineItem.SBQQ__Product__r.ProductCode)){
                        availability.AAV_MaterialCode__c = wsLineItem.SBQQ__Product__r.ProductCode;                            
                        break;
                    }
                }                   
            }
            //Add no mapping if Material Code is null
            If(availability.AAV_MaterialCode__c == null){
                availability.AAV_MaterialCode__c =No_Mapping;
                //isError = true;
                //errorMessage += ', Material Code ';
            }
            system.debug('availability @@ '+availability);
        }
        return availability;
    }  
}