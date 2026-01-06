/**
 * @description       : Class to maintain code reusability.
 * @author            : Hanmi Reddy
 * @last modified on  : 5-24-2023
 * @last modified by  : Hanmi Reddy
 * Modifications Log
 * Ver      Date         Author            Modification
 * 1.0      5-24-2023    Hanmi Reddy       Initial Version
 * 1.1      10-8-2023    Satnam Singh      SDT-31583     
 **/
public inherited sharing class AAV_AvailabilityUtility {
    public static map<string, map<string, map<string, list<Availability_Flag__mdt>>>> availabilityFlagMap;
    
    /*@methodName- getProductMeterialMap
    *@description- Create a map b/w string pair values  
    *@param- Id : prMaterialLst
    *@return- map b/w string
    */  
    public static map<string,string> getProductMeterialMap(List<String> prMaterialLst){
        map<string,string> productMeterialMap = new map<string,string>();
        for(String prMaterial: prMaterialLst){
            list<string> materialCombo = prMaterial.split(',');
            if(materialCombo != null && materialCombo.size() > 0){
                productMeterialMap.put(materialCombo[1],materialCombo[0]);
            }
        }
        return productMeterialMap;
    }
     /*@methodName- getResponse
    *@description- Make a API call and return response/error  
    *@param- Id : reqHeaders
    *@return- reqResponse
    */  
    public static RequestResponse getResponse(RequestHeaders reqHeaders){
        RequestResponse reqResponse = new RequestResponse();   
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(reqHeaders.endPoint);
            request.setMethod(reqHeaders.method);
            request.setHeader('Content-Type',reqHeaders.intMetaData.Content_Type__c);
            request.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
            request.setHeader('X-PARTNER-KEY',reqHeaders.intMetaData.Client_Key__c);
            request.setHeader('X-Request-Id',reqHeaders.requestId);
            request.setHeader('Authorization',reqHeaders.intMetaData.Client_Token__c);
            request.setTimeout(reqHeaders.intMetaData.Timeout__c.intValue());
            //Request
            reqResponse.response = http.send(request);
            system.debug('httpresponse @@ '+reqResponse.response);

        } catch (Exception e){
            reqResponse.errorMessage = e.getMessage();           
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), reqHeaders.classMethodName,LoggingLevel.ERROR);
        }
        return reqResponse;
    }
    

    public static Integration_Request_URLs__mdt getIntegrationRecord(string developerName){
        Integration_Request_URLs__mdt intMetaData = new Integration_Request_URLs__mdt();
        if(developerName != null){
            intMetaData = [SELECT DeveloperName,MasterLabel,Client_Key__c,
                                    Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c
                                    FROM Integration_Request_URLs__mdt 
                                    WHERE DeveloperName =:developerName  LIMIT 1];
        }
        return intMetaData;
    }
     /*@methodName- getSelectedServices
    *@description-  returns selected services list. 
    *@param- Id : bundleId - parent quote line Id
    *@return- reqResponse
    */  
    public static list<SBQQ__QuoteLine__c> getSelectedServices(string bundleId, string bundleProductId){
        list<SBQQ__QuoteLine__c> supplierList;
        set<Id> productIdSet = new set<Id>();
        /*SBQQ__QuoteLine__c quoteLine = [SELECT Id, SBQQ__Product__c,AAV_Requested_AdditionalServicesAccessor__c 
                            FROM SBQQ__QuoteLine__c WHERE Id =:bundleId];*/
                            
        
        for(SBQQ__ProductOption__c prodOption : [SELECT Id, SBQQ__OptionalSKU__c
                            FROM SBQQ__ProductOption__c
                            WHERE SBQQ__ConfiguredSKU__c =:bundleProductId 
                            AND SBQQ__Feature__r.Name IN ('Additional Services','General Accessories') 
                            ORDER BY SBQQ__Number__c DESC]){
            if(prodOption.SBQQ__OptionalSKU__c != null){
                productIdSet.add(prodOption.SBQQ__OptionalSKU__c);
            }
        }        
        if(productIdSet != null && productIdSet.size() > 0){
            supplierList = [SELECT Id FROM SBQQ__QuoteLine__c
                    WHERE SBQQ__RequiredBy__c =:bundleId  AND SBQQ__Product__c IN :productIdSet];
        }
        return supplierList;
    }
    
    /*@methodName- addDeliveryServicesUnAvailableComment
    *@description-  add case comment based on Delivery and Services selected. 
    *@param- list<SBQQ__QuoteLine__c> : Quote list - Quote bundles  
    */ 
    public static string addDeliveryServicesUnAvailableComment(list<SBQQ__QuoteLine__c> quoteLineList) {
        String commentRichtext;

        for(SBQQ__QuoteLine__c qline: quoteLineList){
            String richText;
            
            Boolean isServiceNotAvailable   = false;
            Boolean isDeliveryNotAvailable  = false;   
            Boolean isAccessoryRequested    = false;
            Boolean isWMNotAvailable        = false;
            Map<String,String> weekDays = new Map<String,String>{'M'=>'Monday',
                            'T'=>'Tuesday','W'=>'Wednesday','T1'=>'Thursday',
                            'F'=>'Friday','S'=>'Saturday','S1'=>'Sunday'};          
            richText = '<strong>'+qline.Equipment_Size__c+' '+qline.SBQQ__Product__r.Name + '</Strong> ';
            system.debug('Delivery :: '+qline.AAV_Delivery_Availability__c);
            system.debug('Service :: '+qline.AAV_Service_Availability__c);
            set<string> unavailableDays;
            set<string> availableDays;
            
            if(String.isNotBlank(qline.AAV_Service_Days_Unavailable__c)){
                unavailableDays = new Set<String>(qline.AAV_Service_Days_Unavailable__c.split(';'));
            }
            if(String.isNotBlank(qline.Service_Days__c)){
                availableDays = new Set<String>(qline.Service_Days__c.split(';'));
                if(unavailableDays != null){
                    availableDays.removeAll(unavailableDays);
                }
                
            }

            //SDT-31583 :START
            Map<String,List<String>> errorMap = deserializeErrorString(qline.AAV_Asset_Availability_API_Errors__c);
            String commonValue = getErrorMapValue(errorMap,'common');
            String deliveryValue = getErrorMapValue(errorMap,'delivery');
            String serviceValue = getErrorMapValue(errorMap,'service');
                      
            if(commonValue!=null){
                richText += '<br />'+commonValue;
                isWMNotAvailable = true;
            } 
            //SDT-31583 :END
            else if((serviceValue == null && deliveryValue == null) && (qline.AAV_Delivery_Availability__c != null && qline.AAV_Delivery_Availability__c.containsIgnoreCase('WM NOT available to Deliver in the area'))
            || (qline.AAV_Service_Availability__c != null && qline.AAV_Service_Availability__c.containsIgnoreCase('WM NOT available to Service in the area'))){
                richText += '<br />WM NOT Available in the area, kindly confirm availability with Vendor';
                system.debug(richText);
                isWMNotAvailable = true;
            } else {
                //SDT-31583 
                if(deliveryValue != null){
                    richText += '<br/><strong>Delivery </strong> <br/>'+ deliveryValue;
                    isDeliveryNotAvailable = true;
                }
                else if(qline.AAV_Delivery_Availability__c != null
                && !qline.AAV_Delivery_Availability__c.containsIgnoreCase('Availability could not be confirmed as there is no response from the API') //SDT-31583
            //    && !qline.AAV_Delivery_Availability__c.containsIgnoreCase('Selected Delivery is as per WM Availability')
                && !qline.AAV_Delivery_Availability__c.containsIgnoreCase(System.label.AAV_Availability_for_Delivery_Beyond_N_Days)
                && !qline.AAV_Delivery_Availability__c.containsIgnoreCase('back dated') && qline.SBQQ__StartDate__c != null) { 
                    
                    Datetime dateValue = DateTime.newInstance(qline.SBQQ__StartDate__c, Time.newInstance(0, 0, 0, 0));
                    richText += '<br /><strong>Delivery </strong> <br/>';
                    //SDT-32774
                    if(!qline.AAV_Delivery_Availability__c.containsIgnoreCase('Selected Delivery is as per WM Availability')){
                        richText += qline.Equipment_Size__c+' not available for '+ dateValue.format('EEEE MM/dd/yyyy');  
                    } else {
                        richText += qline.Equipment_Size__c+' available for '+ dateValue.format('EEEE MM/dd/yyyy');  
                    }
                    //Ends
                    
                    richText += qline.AAV_Delivery_Override_Reason__c != null ?
                                '<br />Reason: '+qline.AAV_Delivery_Override_Reason__c : '';

                    richText += qline.AAV_Delivery_Override_Comment__c != null ?
                                '<br />Comment: '+qline.AAV_Delivery_Override_Comment__c : '';             
                    isDeliveryNotAvailable = true;
                }
                //SDT-31583 
                if(serviceValue != null){
                    richText += '<br/><strong>Service </strong> <br/>'+ serviceValue;
                    isServiceNotAvailable = true;
                }
                else if(qline.AAV_Service_Availability__c != null
                //&& !qline.AAV_Service_Availability__c.containsIgnoreCase('Selected Service is as per WM Availability')
                && !qline.AAV_Service_Availability__c.containsIgnoreCase('Availability could not be confirmed as there is no response from the API')) { //SDT-31583
                    
                    richText += '<br /><br /><strong>Service </strong>'; 
                    //get Unavailable days
                    
                    if(!qline.AAV_Service_Availability__c.containsIgnoreCase('Selected Service is as per WM Availability') 
                    && unavailableDays != null && unavailableDays.size() > 0){
                        string days;//='<br />Not available on ';
                        for(String ss:unavailableDays){
                            days = String.isNotBlank(days) ? days + ', '+ weekDays.get(ss) : weekDays.get(ss);
                        }
                        richText += '<br />Not available on ' + days;
                    }
                    if(availableDays != null && availableDays.size() > 0){
                        string days;//='<br />available on ';
                        for(String ss:availableDays){
                            days = String.isNotBlank(days) ? days + ', '+ weekDays.get(ss) : weekDays.get(ss);
                        }
                        richText += '<br />Available on ' + days;
                    }
                    richText += qline.AAV_Service_Override_Reason__c != null ?
                                '<br />Reason: '+qline.AAV_Service_Override_Reason__c : '';

                    richText += qline.AAV_Service_Day_Override_Comment__c != null ?
                                '<br />Comment: '+qline.AAV_Service_Day_Override_Comment__c : '';
                    isServiceNotAvailable = true;
                }
                if( qline.AAV_Requested_AdditionalServicesAccessor__c == 'Requested Additional Services & Accessories' 
                && !qline.AAV_Service_Availability__c.containsIgnoreCase('Availability could not be confirmed as there is no response from the API')//SDT-31583
                && !qline.AAV_Delivery_Availability__c.containsIgnoreCase('Availability could not be confirmed as there is no response from the API')) {//SDT-31583
                    richText += '<br /><br />'+System.label.AAV_Availability_For_Accessories_Comment;
                    isAccessoryRequested = true;
                }
            }
           
            
            if(isServiceNotAvailable || isDeliveryNotAvailable || isAccessoryRequested || isWMNotAvailable){
                commentRichtext = commentRichtext != null ? 
                                    commentRichtext +'<br /><br /><br />'+ richText : richText;
            }
        }
       
        return commentRichtext;        
        
    }

    public static void availabilityComments(string quoteId){
        String caseId;
        String commentRichtext;
        Boolean isAdditionalServiceRequeted = false;
        list<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, SBQQ__Product__c,SBQQ__Product__r.Name, Equipment_Size__c,
                            AAV_Service_Day_Override_Comment__c, AAV_Service_Availability__c, AAV_Service_Override_Reason__c,
                            AAV_Delivery_Availability__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c,SBQQ__StartDate__c,
                            AAV_Requested_AdditionalServicesAccessor__c,AAV_Delivery_Override_Reason__c,AAV_Delivery_Override_Comment__c,
                            AAV_Service_Days_Unavailable__c,AAV_Asset_Availability_API_Errors__c,//SDT-31583
                            Service_Days__c
                            FROM SBQQ__QuoteLine__c 
                            WHERE SBQQ__Quote__c =:quoteId AND SBQQ__RequiredBy__c = null]; 
        
        if(quoteLineList != null && quoteLineList.size() > 0){
            caseId = quoteLineList[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c;          
            commentRichtext = addDeliveryServicesUnAvailableComment(quoteLineList);
        }
        
        //Add delivery ans services date not available comment for all bundles to the case comments.
        if(String.isNotBlank(commentRichtext)){
            AcornController.createAcornComment(commentRichtext, caseId);
        }
    }

    /*@methodName- getAvailabilityFlagMap
    * @description-  This method creates a mapping between Service, Delivery, and Additional Services. 
    * @param- no params
    */
    public static void getAvailabilityFlagMap() {
        system.debug('Limit 1: '+Limits.getHeapSize());
        //get availability flag records        
        Map<String, Availability_Flag__mdt> mapCountryCodes = Availability_Flag__mdt.getAll();
        availabilityFlagMap = new map<string, map<string, map<string, list<Availability_Flag__mdt>>>>();

        for(Availability_Flag__mdt aflag:mapCountryCodes.values()) {
            string service = aflag.Service_Availability__c;
            string delivery = aflag.Delivery_Availability__c;
            string additionalService = aflag.Accessories_Requested__c;
            map<string, Availability_Flag__mdt> accessoryMap = new map<string, Availability_Flag__mdt>();
            
            if(availabilityFlagMap.containsKey(service)) {
                if(availabilityFlagMap.get(service).containsKey(delivery)){
                    if(availabilityFlagMap.get(service).get(delivery).containsKey(additionalService)){
                    availabilityFlagMap.get(service).get(delivery).get(additionalService).add(aflag);
                    } else {
                    availabilityFlagMap.get(service).get(delivery).put(additionalService, new list<Availability_Flag__mdt>{aflag});
                    } 
                } else {
                availabilityFlagMap.get(service).put(delivery, new map<string, list<Availability_Flag__mdt>>());
                availabilityFlagMap.get(service).get(delivery).put(additionalService, new list<Availability_Flag__mdt>{aflag});
                }
            } else {
                availabilityFlagMap.put(service, new map<string, map<string, list<Availability_Flag__mdt>>>());
                availabilityFlagMap.get(service).put(delivery, new map<string, list<Availability_Flag__mdt>>());
                availabilityFlagMap.get(service).get(delivery).put(additionalService, new list<Availability_Flag__mdt>{aflag});
            }
        }
        system.debug('Limit 1: '+Limits.getHeapSize());       
    }

    /*@methodName- getAvailabilityFlag
    * @description-  This method returns the availability Flag based on values populated on bundle. 
    * @param- Quote Bundle
    */
    public static Availability_Flag__mdt getAvailabilityFlag(SBQQ__QuoteLine__c quoteLine){
        String service = quoteLine.AAV_Service_Availability__c;
        String delivery = quoteLine.AAV_Delivery_Availability__c;
        string accessory = 'No';
        Availability_Flag__mdt availabilityFlag;
        if(quoteLine.AAV_Requested_AdditionalServicesAccessor__c == 'Requested Additional Services & Accessories'){
            accessory = 'Yes';
        }
        //SDT - 28610
        if(quoteLine.SBQQ__StartDate__c != null){
            BusinessDays bd = new BusinessDays();
            Integer noOfDays = bd.getNoOfDaysfromCurrentDate(quoteLine.SBQQ__StartDate__c);
            calculatePripority(noOfDays, quoteLine);
        }
        //End
        if(availabilityFlagMap.containsKey(service) 
                && availabilityFlagMap.get(service).containsKey(delivery) 
                && availabilityFlagMap.get(service).get(delivery).containsKey(accessory)) {
            list<Availability_Flag__mdt> availabilityList = availabilityFlagMap.get(service).get(delivery).get(accessory);
            
            if(availabilityList != null && availabilityList.size() > 0 && quoteLine.AAV_Priority__c != null){
                for(Availability_Flag__mdt availability: availabilityList){
                    if(availability.Priority__c == quoteLine.AAV_Priority__c){
                        availabilityFlag = availability;
                    }
                }                
            }
        }
        return availabilityFlag;
    }

     /*@methodName- calculatePripority
    * @description-  This method calculates priority based on Delivery date selected on Budle creation. 
    * @param- noOfDays, Quote Bundle
    * 
    * User Story :SDT-28610
    */
    private static void calculatePripority(Integer noOfDays, SBQQ__QuoteLine__c quoteLine){
        String priorityP1 = 'P1';
        String priorityP2 = 'P2';
        String priorityP3= 'P3';
        String priorityP4= 'P4';
        // if start Date equal to today then assign P1
        if(noOfDays==0)
          {
              quoteLine.AAV_Priority__c=priorityP1;
          }
          //start Date equal to next business day then assign P2
          else if(noOfDays==1)
          {
              quoteLine.AAV_Priority__c=priorityP2;
          }
          //start Date equal to T+2 to T+10 then assign P3
          else if(noOfDays>1 && noOfDays<=10)
          {
              quoteLine.AAV_Priority__c=priorityP3;
          }
          //start Date equal to T+11 or greater then assign P4
          else if(noOfDays>=11)
          {
              quoteLine.AAV_Priority__c=priorityP4;
          }
    }

    /*@methodName- deserializeErrorString
    * @description-  This method returns map of Error as <Key, value[list]>. 
    * @param- String
    * return- Map<String,List<String>>
    * User Story :SDT-31583
    */
    public static Map<String,List<String>> deserializeErrorString(String errorJsonStr){
        Map<String, List<String>> dataMap = new Map<String, List<String>>();
        if(errorJsonStr!=null){
            Map<String, Object> dataMapRaw = (Map<String, Object>)JSON.deserializeUntyped(errorJsonStr);
            for (String key : dataMapRaw.keySet()) {
                List<String> values = new List<String>();
                for (Object value : (List<Object>)dataMapRaw.get(key)) {
                    values.add((String)value);
                }
                dataMap.put(key, values);
            }
        }
        System.debug(dataMap);
        return dataMap;
    }
     /*@methodName- getErrorMapValue
    * @description-  This method returns String of combine List values. 
    * @param- Map<String,List<String>>,String
    * return- String
    * User Story :SDT-31583
    */
    public static String getErrorMapValue(Map<String,List<String>> errorMap,String str){
        String returnStr = null;
        if(errorMap.containsKey(str) && errorMap.get(str).size()>0){
            returnStr = String.join(errorMap.get(str),'\n');
        }
        return returnStr;
    }

     /*@methodName- getAvailabilityBellIconMessage
    * @description-  This method returns availability bell icon messages. 
    * @param- SBQQ__QuoteLine__c,String
    * return- String
    * User Story :SDT-31583
    */
    public static String getAvailabilityBellIconMessage(SBQQ__QuoteLine__c header, String procurementErrorMessage){
        Map<String,List<String>> errorMap = AAV_AvailabilityUtility.deserializeErrorString(header.AAV_Asset_Availability_API_Errors__c);
        String commonValue = AAV_AvailabilityUtility.getErrorMapValue(errorMap,'common');
        String deliveryValue = AAV_AvailabilityUtility.getErrorMapValue(errorMap,'delivery');
        String serviceValue = AAV_AvailabilityUtility.getErrorMapValue(errorMap,'service');
        string iconString = String.isNotBlank(commonValue) ? commonValue : '';

        iconString += String.isNotBlank(deliveryValue) ? 
            String.isNotBlank(iconString) ?  
                '\n' + deliveryValue : deliveryValue 
            : '';

        iconString += String.isNotBlank(serviceValue) ? 
            String.isNotBlank(iconString) ?  
                '\n' + serviceValue : serviceValue 
            : '';
        
        //Condition for WM not available for service and API errored out
        if(header.Availability_Flag__c != null && 
        (header.Availability_Flag__c.containsIgnoreCase('NON WM Availability') ||
        header.Availability_Flag__c.containsIgnoreCase('Availability could not be confirmed as there is no response from the API'))) {

            if(String.isNotBlank(procurementErrorMessage) && 
            procurementErrorMessage.containsIgnoreCase(header.Availability_Flag__c)) {
                procurementErrorMessage = procurementErrorMessage.removeStartIgnoreCase(header.Availability_Flag__c);
            }

            procurementErrorMessage = String.isNotBlank(procurementErrorMessage) ? 
                            String.isNotBlank(iconString) ?
                                procurementErrorMessage + '\n '+ iconString
                                : ''
                            : iconString;                
        } else if(header.Availability_Flag__c != null && 
            !header.Availability_Flag__c.containsIgnoreCase('WM Availability Confirmed')){
            if(String.isNotBlank(procurementErrorMessage)){
                procurementErrorMessage += !procurementErrorMessage.containsIgnoreCase(header.Availability_Flag__c) ?
                    '\n '+ header.Availability_Flag__c : '';
                
            } else {
                procurementErrorMessage =  header.Availability_Flag__c;
            }
            //Append icon message to the exisitng error message.
            procurementErrorMessage += String.isNotBlank(iconString) ? '\n '+ iconString : '';
        }
        return procurementErrorMessage;
    }

    /*@methodName- getCustomLabels
    * @param- List<String>
    * return- Map<String,String>
    * User Story :SDT-31583
    */
    public static Map<String,String> getCustomLabels (List<String> labelNames) {
        Map<String, String> labelMap = new Map<String, String>();
        for (String labelName : labelNames) {
            String labelValue = System.Label.get('',labelName,'en');
            labelMap.put(labelName, labelValue);
        }
        return labelMap;
    }
    
    
     
    
    
    public class RequestHeaders {
        public string endPoint;
        public string method;
        public string classMethodName;
        public Integration_Request_URLs__mdt intMetaData;
        public string requestId;
    }
    public class RequestResponse {
        public HttpResponse response;
        public string errorMessage;
    }
   
}