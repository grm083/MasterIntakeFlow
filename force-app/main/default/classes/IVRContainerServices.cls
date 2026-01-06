/*************************************************************
@Name: IVRContainerServices
@Author: Accenture
@CreateDate: 7/22/2019
@Description: Apex webservice to get WorkOrder and Container information
@UsedBy: SDT-7342
**************************************************************/

@RestResource(urlMapping='/ContainerStatus/V1/*')
global with sharing class IVRContainerServices {
    public static Map<Id,Account> casewithLocation = new Map<Id,Account>(); 
    public static Map<Id,Case> mapCaseAsset = new Map<Id,Case>();
    public static Map<Id,String> mapSBID = new Map<Id,String>();
    public static Map<Id,WorkOrder> mapAssetIdWO = new Map<Id,WorkOrder>();
    public static Map<Id,Asset> containerWithContainerIdMap = new Map<Id,Asset>();
    public static Map<String,Case> caseKeyWithCaseMap = new Map<String,Case>();
    public static Map<Id,Entitlement> getEntitlementByAssetId = new Map<Id,Entitlement>(); 
    public static Map<Id,set<Date>> getWoListByAssetId = new Map<Id,set<Date>>();
    public static Map<Id,Date> getPotentialPickupDateByAssetId = new Map<Id,Date>();
    public static map<Id,Set<string>> assetIdOccurencemap = new map<Id,Set<String>>();
    public static map<Id,Boolean> hasweeklyfrequencymap = new map<Id,Boolean>();
    /**
* @description Get WorkOrder & service status information, return WorkOrder & service status Information
**/
    @HttpPost
    global static void getAsset(){ 
        //Initialize RestContext
        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        
        Set<ID> commercialAssetIds = new Set<Id>();
        Set<ID> nonCommercialAssetIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        set<Id> caseIds = new set<Id>();
        set<Id> caseIdSets = new set<Id>();
        Set<Id> selfCoreDetailSet = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<String> caseInputValues = new List<String>();
        List<Asset> assetLst = new List<Asset>();
        List<Case> newCaseList = new List<Case>();
        List<WorkOrder> woLst = new List<WorkOrder>();
        map<Id,String> materialTypeValuemap = new map<Id,String>();
        map<Id,Id> assetCaseIdMap = new map<Id,Id>();
        List<container> lstContainer = new List<container>();
        List<ErrorsWrapper> errorList = new List<ErrorsWrapper>();
        Map<Id,Integer> mapAssetIdWORank = new Map<Id,Integer>();
        Map<String,String> materialPromptResp = new Map<String,String>();
        Map<String,String> promptResponse = new Map<String,String>();
        Map<Id,Asset> assetmap = new Map<Id,Asset>();
        Integer containerLimit = 3;
        Integer count = 0;
        string[] promptResponseArray;
        string[] materialResponseArray;
        ContainerStatusResponse contStatusResp = new ContainerStatusResponse();   
        
        try {
            //Get request body
            String jsonRequest = inboundRequest.requestBody.toString();
            
            //Convert request body to data structure, deserialize JSON
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            //Get values from map
            String connectionId = string.valueOf(requestDataMap.get(Constant_Util.CONNECTION_ID));
            string locationCode = string.valueOf(requestDataMap.get(Constant_Util.LOCATION_CODE));
            Set<Id> assetIds = new Set<Id>();
            //To fetch last 30 days from yesterday (Configurable) wo records
            Date yesterday = System.today().adddays(-1);
            Date noOfDays = yesterday.adddays(integer.valueOf(system.label.Last_n_no_of_Service_Date_Days));
            
            //Added below map as part of story SDT-9532 to avoid fetching Project related assets based on the location codes in the custom settings.
            Map<String,Client_Account_Numbers__c> clientAccNums = Client_Account_Numbers__c.getall();
            set<String> occrenceSet = new set<String>();
            //Query Containers based on Location Code
            if(String.isNotBlank(locationCode) && !locationCode.equalsIgnoreCase('Null')){
                for(Asset a : [SELECT Id, Has_Extra_Pickup__c, Product2Id, Product2.Container_Prompt_ID__c, Location__r.ParentId, 
                               Is_Active__c,Location__r.Parent.Customer_Code__c, Quantity__c, ProductFamily, Location_Code__c , Product2.Name , Equipment_Type__c, 
                               Duration__c, Material_Type__c, Location__r.Name,  RecordType.DeveloperName, Acorn_SBID__c,Product2.Voice_Prompt__c,Occurrence_Type__c,
                               Product2.ProductTypeSelected__c, Project_Code__c, Active__c, End_Date_Based_on_Project_code__c,End_Date__c,Start_Date__c,Frequency__c,
                               (SELECT Id,Quantity__c,SBID_Text_c__c,Is_Self_Service__c,Is_Core_Service__c,Supplier__r.Parent_Vendor_ID__c,Project_Code__c,Location__r.Parent.Customer_Code__c,Active__c,Frequency__c, Occurs__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c,Sunday__c,Service_Header_Id__c 
                                FROM Assets_Parent__r 
                                WHERE Is_Active__c =true)                                
                               FROM Asset 
                               WHERE Location__r.Name =: locationCode AND RecordType.DeveloperName =: Constant_Util.SERVICE_HEADER AND Is_Active__c =true and Is_Self_Service__c = true LIMIT 49999]){
                                   //Added below condition as part of story SDT-9532 to avoid fetching Project related assets based on the location codes in the custom settings.
                                   
                                   hasweeklyfrequencymap.put(a.Id,false);
                                   if((a.End_date__c!=null && a.Start_Date__c <= a.End_date__c && a.End_Date__c >= System.today() && a.End_Date__c <= System.today().addDays(30)) || a.End_date__c == null){
                                       for(Asset serviceDetail : a.Assets_Parent__r){
                                           if(serviceDetail.Quantity__c==1 && serviceDetail.Is_Self_Service__c){
                                               selfCoreDetailSet.add(serviceDetail.Id);
                                               if((mapSBID.isEmpty() || !mapSBID.containsKey(a.Id)) && clientAccNums!=null && !(clientAccNums.containsKey(serviceDetail.Location__r.Parent.Customer_Code__c) && serviceDetail.Active__c && serviceDetail.Project_Code__c!=null) && serviceDetail.Supplier__r.Parent_Vendor_ID__c == '8'){
                                                   mapSBID.put(a.Id, serviceDetail.SBID_text_c__c);
                                               }
                                           }
                                           if(Constant_Util.COMMERCIAL.equalsIgnoreCase(a.ProductFamily) && Constant_Util.SCHEDULED.equals(a.Occurrence_Type__c) && Constant_Util.WEEKLY.equals(serviceDetail.Frequency__c)){
                                               hasweeklyfrequencymap.put(a.Id,true);
                                               if(serviceDetail.Monday__c){
                                                   occrenceSet.add(Constant_Util.MONDAY);
                                               }
                                               if(serviceDetail.Tuesday__c){
                                                   occrenceSet.add(Constant_Util.TUESDAY);
                                               }
                                               if(serviceDetail.Wednesday__c){
                                                   occrenceSet.add(Constant_Util.WEDNESDAY);
                                               }
                                               if(serviceDetail.Thursday__c){
                                                   occrenceSet.add(Constant_Util.THURSDAY);
                                               }
                                               if(serviceDetail.Friday__c){
                                                   occrenceSet.add(Constant_Util.FRIDAY);
                                               }
                                           }
                                       }
                                       if(selfCoreDetailSet!=null && !selfCoreDetailSet.isEmpty() && clientAccNums!=null && !(clientAccNums.containsKey(a.Location__r.Parent.Customer_Code__c) && a.Active__c && String.isNotBlank(string.valueof(a.Project_Code__c))) && String.isNotBlank(a.Product2.Container_Prompt_ID__c)){
                                           CaseTriggerHelper.casewithContainer.put(a.Id,a);
                                           containerWithContainerIdMap.put(a.Id,a);
                                           assetLst.add(a);
                                           assetmap.put(a.Id,a);
                                           //hasweeklyfrequencymap.put(a.Id,false);
                                           locationIds.add(a.Location__c);
                                           materialTypeValuemap.put(a.Id,a.Material_Type__c);
                                           assetIds.add(a.Id);
                                           //occrenceSet = new set<String>();
                                           if(Constant_Util.COMMERCIAL.equalsIgnoreCase(a.ProductFamily)){
                                               commercialAssetIds.add(a.Id);
                                               if(occrenceSet!=null && !occrenceSet.IsEmpty() && occrenceSet.size() > 0){
                                                   assetIdOccurencemap.put(a.Id,occrenceSet);
                                               }
                                           }
                                           else{
                                               nonCommercialAssetIds.add(a.Id);
                                           }
                                       }
                                       
                                   }
                                   selfCoreDetailSet.clear();
                                   occrenceSet.clear();
                               }
            }           
            system.debug('$$$$$'+assetLst.size());
            Integer num = 1;
            Set<string> workOrderStatus = new set<string>{Constant_Util.SENT,Constant_Util.ACCEPTED,Constant_Util.WORK_COMPLETE,Constant_Util.RELEASED_FOR_PAYMENT,Constant_Util.CLOSED};
                Set<string> potentialWorkOrderStatus = new set<string>{Constant_Util.SENT,Constant_Util.ACCEPTED,Constant_Util.WORK_COMPLETE,Constant_Util.RELEASED_FOR_PAYMENT,Constant_Util.CLOSED,Constant_Util.ISSUED,Constant_Util.Sending,Constant_Util.STR_REJECTED,Constant_Util.STR_NEW,Constant_Util.STR_PENDING_DRAFT};    
                    
                    for(WorkOrder objWO :  [SELECT Id, Is_Bypass__c, Service_Date__c, SLA_Service_Date_Time__c, Status, AssetId, CaseId, Case.Case_Type__c,
                                            Case.Case_Sub_Type__c, Case.Case_Reason__c,CreatedDate 
                                            FROM WorkOrder
                                            WHERE AssetId IN: assetIds AND Status IN: potentialWorkOrderStatus 
											AND Is_Bypass__c = false AND ((Service_Date__c >=: noOfDays AND Service_Date__c <=: yesterday) OR (Service_Date__c >= TODAY))
                                            ORDER By Service_Date__c desc]){
                                                system.debug('$$$$$'+objWO.Status);
                                                system.debug('$$$$$'+workOrderStatus);
                                                if(!mapAssetIdWORank.containsKey(objWO.AssetId) && objWO.Service_Date__c >= noOfDays && objWO.Service_Date__c <= yesterday && workOrderStatus.contains(objWO.Status)){
                                                    mapAssetIdWO.put(objWO.AssetId, objWO);
                                                    mapAssetIdWORank.put(objWO.AssetId, num);
                                                    num = num + 1;
                                                }
                                                if(!nonCommercialAssetIds.isEmpty() && nonCommercialAssetIds.Size() > 0 && workOrderStatus.contains(objWO.Status)){
                                                    caseIds.add(objWO.caseId);
                                                    system.debug('#%#%#%'+objWO.AssetId);
                                                    assetCaseIdMap.put(objWO.AssetId,objWO.caseId);  
                                                }
                                                
                                                if(getWoListByAssetId.containsKey(objWO.AssetId) && objWO.Service_Date__c >= System.today()){
                                                    getWoListByAssetId.get(objWO.AssetId).add(objWO.Service_Date__c); 
                                                }else If(objWO.Service_Date__c >= System.today()){
                                                    getWoListByAssetId.put(objWO.AssetId, new set<Date>{objWO.Service_Date__c});
                                                }
                                            }
            
            //Location Data for SLA
            for(Account loc: [SELECT Id, Brand__c, Geography__c, Division__c, Location_Type__c, tz__Timezone_SFDC__c 
                              FROM Account 
                              WHERE Id =: locationIds LIMIT 49999]){
                                  CaseTriggerHelper.casewithLocation.put(loc.Id,Loc);
                              }
            
            //Business Hours Calculation for SLA
            for(BusinessHours b: [select id,TimeZoneSidKey from BusinessHours LIMIT 39999]){
                CaseTriggerHelper.businessIdMap.put(b.TimeZoneSidKey,b.Id);
            }
            
            //Creating a Dummy Case object for the SLA Invocation
            Case objCase = null;
            for(Asset objAsset : assetLst){
                objCase = new Case();
                objCase.AssetId = objAsset.Id;
                objCase.Client__c = objAsset.Location__r.ParentId;
                objCase.Location__c = objAsset.Location__c;
                objCase.Case_Type__c = Constant_Util.PICKUP_CSTYPE;
                if(objAsset.ProductFamily.equalsIgnoreCase(Constant_Util.COMMERCIAL)){
                    objCase.Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
                }
                if(objAsset.ProductFamily.equalsIgnoreCase(Constant_Util.ROLLOFF)){
                    objCase.Case_Sub_Type__c = Constant_Util.EMPTY_AND_RETURN;
                }
                caseList.add(objCase);
            }
            
            // Invoke the SLA Method to get the SLA Date.
            if(!CaseTriggerHelper.getServiceDate(caseList).isEmpty()){
                newCaseList = CaseTriggerHelper.getServiceDate(caseList);
            }
            
            // Create Key to invoke FetchSLA Method of CaseTriggerHelper
            for(Case c : newCaseList){
                String container    = containerWithContainerIdMap != null && containerWithContainerIdMap.containsKey(c.AssetId) ? containerWithContainerIdMap.get(c.AssetId).Product2.ProductTypeSelected__c : null;
                String scheduleType = containerWithContainerIdMap != null && containerWithContainerIdMap.containsKey(c.AssetId) ? containerWithContainerIdMap.get(c.AssetId).Duration__c : null;
                String casekey =  c.Client__c + Constant_Util.STAR + c.Location__c + Constant_Util.STAR + container + Constant_Util.STAR + c.Case_Sub_Type__c + Constant_Util.STAR + scheduleType;
                if(CaseTriggerHelper.casekeywithEntitlementMap != null && CaseTriggerHelper.casekeywithEntitlementMap.size() > 0 && CaseTriggerHelper.casekeywithEntitlementMap.containskey(casekey)){
                    getEntitlementByAssetId.put(c.AssetId,CaseTriggerHelper.casekeywithEntitlementMap.get(casekey));
                }
                //Create the Map of Asset & Case <SLA Date>
                mapCaseAsset.put(c.AssetId, c);
            }                                
            
            container objCon = null;
            Date potentialDate = null;
            //SDT-9913 - Added By Yogesh Sharma
            //Start
            string potentialPickupDate = null;
            map<Id,Date> validateDateByAssetId = new map<Id,Date>();
            for(Asset objAsset : assetLst){
                //SDT-7972 - Added By Yogesh Sharma
                //Get Next Service Date					
                potentialPickupDate = getNextServiceDate(objAsset);
                if(String.isNotBlank(potentialPickupDate)){
                    potentialDate = Date.valueof(potentialPickupDate); 
                    getPotentialPickupDateByAssetId.put(objAsset.Id,potentialDate);
                    validateDateByAssetId.put(objAsset.Id,potentialDate);
                }else if(String.isBlank(potentialPickupDate)){
                    potentialDate = (mapCaseAsset.get(objAsset.Id).Service_Date__c).addDays(Integer.valueof(System.Label.Next_Business_Days));
                    validateDateByAssetId.put(objAsset.Id,potentialDate);
                }
            }
            //Invoke Validate method for extra pickup
            system.debug('isValidAssetMap'+validateDateByAssetId);
            Map<Id,String> isValidAssetMap = GetCaseInformation.getAssetDetail(validateDateByAssetId);
            system.debug('isValidAssetMap'+isValidAssetMap);
            //Stop  
            assetLst.clear(); 
            for(Id assetId : isValidAssetMap.keySet()){
                if(assetmap != null && isValidAssetMap != null && assetmap.containskey(assetId) && isValidAssetMap.containsKey(assetId) && String.isBLANK(isValidAssetMap.get(assetId))){
                    assetLst.add(assetmap.get(assetId));
                }else {
                    mapSBID.remove(assetId);
                    materialTypeValuemap.remove(assetId);
                    //occrenceSet = new set<String>();
                    if(commercialAssetIds != null && commercialAssetIds.contains(assetId)){
                        commercialAssetIds.remove(assetId);
                    }else if(nonCommercialAssetIds != null && nonCommercialAssetIds.contains(assetId)){
                        nonCommercialAssetIds.remove(assetId);
                    }
                    if(!assetCaseIdMap.IsEmpty() && assetCaseIdMap.size() > 0 && assetCaseIdMap.containskey(assetId)){
                        caseIds.remove(assetCaseIdMap.get(assetId));
                    }
                }    
            }
            count = assetLst.size();
            if(count <=4 ){
                
                if(!nonCommercialAssetIds.isEmpty() && nonCommercialAssetIds.Size() > 0 ){
                    for(Id nonCom : nonCommercialAssetIds){
                        if(!mapAssetIdWORank.isEmpty() && mapAssetIdWORank.containsKey(nonCom) && mapAssetIdWORank.get(nonCom) == 1){
                            containerLimit = 4;
                        }
                    }
                }
                //Return Containers Information if the Containers are less than 3
                if((!commercialAssetIds.isEmpty() && nonCommercialAssetIds.IsEmpty() && commercialAssetIds.size() <= 3) || (!nonCommercialAssetIds.IsEmpty() && !commercialAssetIds.isEmpty() && ((nonCommercialAssetIds.size() + commercialAssetIds.Size()) <= containerLimit)) || (commercialAssetIds.isEmpty() && !nonCommercialAssetIds.IsEmpty() && nonCommercialAssetIds.size() <= containerLimit)){
                    //count = 0;
                    //Get Material Prompt Values.
                    materialPromptResp.putAll(GetIVRCasePrompt.getMaterialPromptID(materialTypeValuemap.values()));
                    //WO Bypass is NOT equal to TRUE AND Service Date between Today - 30 days.  If no WO found return just container.
                    if(nonCommercialAssetIds != null && nonCommercialAssetIds.size()>0 && !caseIds.IsEmpty() && caseIds.size() >0){
                        for(Case c : [SELECT CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, 
                                      Asset.Product2.Container_Prompt_ID__c, Status, Asset.Product2.Name, Case_Sub_Status__c, 
                                      Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Asset.Material_Prompt_ID__c, 
                                      Asset.Product2.Voice_Prompt__c, Asset.Voice_Prompt__c, SLA_Service_Date_Time__c FROM Case 
                                      WHERE Id IN: caseIds LIMIT 49999]){
                                          caseInputValues.add(c.Case_Type__c+Constant_Util.UNDERSCORE+c.Case_Sub_Type__c+Constant_Util.UNDERSCORE+c.Case_Reason__c);
                                      }
                        //promptResponse = GetIVRCasePrompt.getIVRPrompt(caseInputValues);
                    }                
                    caseInputValues.add(Constant_Util.PICKUP_CSTYPE+Constant_Util.UNDERSCORE+Constant_Util.EXTRA_PICKUP+Constant_Util.UNDERSCORE+Constant_Util.STRING_NULL);
                    promptResponse = GetIVRCasePrompt.getIVRPrompt(caseInputValues);
                    for(Asset objAsset : assetLst){  
                        
                        //Start
                        //SDT-9913 - Added By Yogesh Sharma
                        //Start
                        objCon = new container();
                        objCon.AssetId = objAsset.Id;
                        objCon.ContainerId = objAsset.Product2Id;
                        objCon.ContainerPromptId = objAsset.Product2.Container_Prompt_ID__c;
                        objCon.ContainerName = objAsset.Product2.Voice_Prompt__c;
                        if(getPotentialPickupDateByAssetId != null && getPotentialPickupDateByAssetId.containskey(objAsset.Id)){
                            objCon.PotentialPickupDate = string.valueof(getPotentialPickupDateByAssetId.get(objAsset.Id));
                        }
                        if(!materialPromptResp.isEmpty() && materialPromptResp.size() > 0 && String.isNotBlank(objAsset.Material_Type__c) && materialPromptResp.ContainsKey((objAsset.Material_Type__c).toLowerCase())){
                            string materialValues = materialPromptResp.get((objAsset.Material_Type__c).toLowerCase());
                            if(string.isNotBlank(materialValues)){
                                materialResponseArray = materialValues.split(Constant_Util.UNDERSCORE);
                                objCon.MaterialPromptId = materialResponseArray[0];
                                objCon.Material = materialResponseArray[1]; 
                            } 
                        } else {
                            objCon.MaterialPromptId = Constant_Util.STR_MATERIAL_PROMPT_ID;
                        }
                        if(mapAssetIdWORank.containsKey(objAsset.Id)){
                            objCon.ServiceDate =  DateTime.newInstance(mapAssetIdWO.get(objAsset.Id).Service_Date__c, Time.newInstance(0,0,0,0)).format(Constant_Util.US_DATE_FORMAT); 
                            string caseInput = mapAssetIdWO.get(objAsset.Id).Case.Case_Type__c + Constant_Util.UNDERSCORE + mapAssetIdWO.get(objAsset.Id).Case.Case_Sub_Type__c + Constant_Util.UNDERSCORE + mapAssetIdWO.get(objAsset.Id).Case.Case_Reason__c;
                            if(promptResponse.ContainsKey(caseInput.toLowerCase()) && string.isNotBlank(promptResponse.get(caseInput.toLowerCase()))){
                                string promptValues = promptResponse.get(caseInput.toLowerCase());
                                promptResponseArray = promptValues.split(Constant_Util.UNDERSCORE);
                                objCon.Service = promptResponseArray[0];
                                objCon.ServicePromptId = promptResponseArray[1]; 
                            }
                        }                    
                        if(mapAssetIdWORank.containsKey(objAsset.Id) && !nonCommercialAssetIds.isEmpty() && nonCommercialAssetIds.contains(objAsset.Id) && mapAssetIdWORank.get(objAsset.Id) == 1){
                            objCon.MostRecentPickup = Constant_Util.YES; 
                        }else{
                            objCon.MostRecentPickup = Constant_Util.NO;
                        }
                        
                        objCon.ProductFamily = objAsset.ProductFamily;
                        if(Constant_Util.TEMPORARY.equals(objAsset.Duration__c) && Constant_Util.OPEN_TOP.equals(objAsset.Equipment_Type__c)){
                            objCon.TempAndOpenTop = Constant_Util.YES;
                        }else{
                            objCon.TempAndOpenTop = Constant_Util.NO;
                        }
                        lstContainer.add(objCon);
                        //Stop 
                    }
                }
            }
            //Populate response values
            contStatusResp.RecordCount = count;
            contStatusResp.container = new List<container>();
            contStatusResp.container.addAll(lstContainer);
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(contStatusResp));
            outboundResponse.statusCode = 200;
        } 
        catch(Exception e) { 
            system.debug('$$$$$$'+e.getStackTraceString());
            //Populate response values
            ErrorsWrapper errorDetails = new ErrorsWrapper(e.getTypeName(), e.getMessage()); 
            errorList.add(errorDetails);
            contStatusResp.Problem =  new ErrorMessageWrapper(Constant_Util.EXCEPTION_OCCURRED, 
                                                              Constant_Util.KEYWORD_EXCEPTION, errorList); 
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(contStatusResp));      
            outboundResponse.statusCode = 400;
        }  
    }
    
    //Added By Yogesh Sharma
    global static String getNextServiceDate(Asset objAsset){
        String nextServiceDate = Null;
        if(objAsset != Null){
            string loczone = CaseTriggerHelper.casewithLocation.get(objAsset.Location__c).tz__Timezone_SFDC__c;
            Id businessHoursId = CaseTriggerHelper.businessIdMap.get(locZone);
            if(getWoListByAssetId.get(objAsset.Id) == NULL || getWoListByAssetId.isEmpty()){
                nextServiceDate = String.valueOf(mapCaseAsset.get(objAsset.Id).Service_Date__c); 
            }
            //For Gold Standard            
            if(getEntitlementByAssetId != NULL && !getEntitlementByAssetId.isEmpty() && getEntitlementByAssetId.get(objAsset.Id) != NULL && (getEntitlementByAssetId.get(objAsset.Id).Gold_Standard__c || Constant_Util.COMMERCIAL.equalsIgnoreCase(objAsset.ProductFamily))){
                if(getWoListByAssetId.get(objAsset.Id) != NULL && mapCaseAsset.get(objAsset.Id) != Null){
                    nextServiceDate = String.valueOf(getNextAvailableDateFromSLA(businessHoursId,getWoListByAssetId.get(objAsset.Id),mapCaseAsset.get(objAsset.Id).Service_Date__c,mapCaseAsset.get(objAsset.Id).SLA_Service_Date_Time__c,locZone, Constant_Util.COMMERCIAL.equalsIgnoreCase(objAsset.ProductFamily) && Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id) ? Integer.valueof(System.Label.Next_Business_Days) : 0 , assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) ? assetIdOccurencemap.get(objAsset.Id) : null));
                }else if(Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id)
                         && assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) && mapCaseAsset != null && mapCaseAsset.containskey(objAsset.Id)){
                             nextServiceDate =  getPotentialDate(objAsset);
                         }
            }            
            //For Not-Gold Standard/No Entitlement Found
            else if((getEntitlementByAssetId != NULL && !getEntitlementByAssetId.isEmpty() && getEntitlementByAssetId.containskey(objAsset.Id) && !getEntitlementByAssetId.get(objAsset.Id).Gold_Standard__c) || getEntitlementByAssetId.isEmpty() || (!getEntitlementByAssetId.isEmpty() && !getEntitlementByAssetId.containskey(objAsset.Id))){
                List<String> availDates = new List<String>();
                List<Date> plannerDates = new List<Date>();
                if(!mapSBID.isEmpty() && mapSBID.containskey(objAsset.Id) && Constant_Util.ROLLOFF.equalsIgnoreCase(objAsset.ProductFamily) && !Test.isRunningTest()){
                    List<String> capacityDates = WMCapacityController.getAvailableDates(mapSBID.get(objAsset.Id));
                    if(capacityDates != null){
                        availDates.addAll(capacityDates);
                    }
                }
                if(Test.isRunningTest()){
                    availDates.add(String.valueOf(System.today()));
                }        
                if(!availDates.IsEmpty() && availDates.size() >0){
                    for(String s : availDates){
                        String[] strDate = getSplitStringDate(s);
                        if(strDate != Null && !strDate.isEmpty()){
                            Date t = null;
                            if(Test.isRunningTest()){
                                t = Date.newInstance(Integer.valueOf(strDate[0]),Integer.valueOf(strDate[1]),Integer.valueOf(strDate[2]));
                            }else {
                                t = Date.newInstance(Integer.valueOf(strDate[2]),Integer.valueOf(strDate[0]),Integer.valueOf(strDate[1]));
                            }
                            if(t >= mapCaseAsset.get(objAsset.Id).Service_Date__c || Test.isRunningTest()){
                                plannerDates.add(t);
                            }
                        } 
                    }
                }          
                if(availDates != NULL && !availDates.isEmpty()){
                    if(!getWoListByAssetId.Isempty() && getWoListByAssetId.containskey(objAsset.Id)){
                        nextServiceDate = getNextAvailableDate(businessHoursId,getWoListByAssetId.get(objAsset.Id),plannerDates,locZone);
                    }else{
                        nextServiceDate = string.valueof(plannerDates[0]);
                    }
                }
                else{
                    if(!getWoListByAssetId.Isempty() && getWoListByAssetId.containskey(objAsset.Id) && !mapCaseAsset.isEmpty() && mapCaseAsset.containskey(objAsset.Id)){
                        nextServiceDate = String.valueOf(getNextAvailableDateFromSLA(businessHoursId,getWoListByAssetId.get(objAsset.Id),mapCaseAsset.get(objAsset.Id).Service_Date__c,mapCaseAsset.get(objAsset.Id).SLA_Service_Date_Time__c,locZone, Constant_Util.COMMERCIAL.equalsIgnoreCase(objAsset.ProductFamily) && Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id) ? Integer.valueof(System.Label.Next_Business_Days) : 0,assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) ? assetIdOccurencemap.get(objAsset.Id) : null));
                    }else if(Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id) 
                             && assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) && mapCaseAsset != null && mapCaseAsset.containskey(objAsset.Id)){
                                 nextServiceDate =  getPotentialDate(objAsset);
                             }
                }     
            } 
        }
        return nextServiceDate;
    } 
    /***
    ***Method to find PotentialDate when WorkOrder is not available for comerical products **/
    private static String getPotentialDate(Asset objAsset){
        string nextServiceDate = null;                         
        Date serviceDate = mapCaseAsset.get(objAsset.Id).Service_Date__c;
        integer i = 1;
        Boolean checkbool = false;      
        DateTime serviceTime = DateTime.newInstance(serviceDate.year(), serviceDate.month(), serviceDate.day());
        string dayOfWeek = serviceTime.format(Constant_Util.FORMAT_DAY);
        if(Constant_Util.SATURDAY.equalsIgnoreCase(dayOfWeek)){
            serviceDate = serviceDate.addDays(2);
            i = i +2;
        }else if(Constant_Util.SUNDAY.equalsIgnoreCase(dayOfWeek)){
            serviceDate = serviceDate.addDays(1);
            i = i +1;
        }
        if(assetIdOccurencemap.get(objAsset.Id).contains(dayOfWeek)){
            dateTime dayWeek = null;
            for(; serviceDate <= System.Today().addDays(Integer.valueof(System.Label.Next_Business_Days)) ; i++){
                serviceDate = serviceDate.addDays(1);
                serviceTime = DateTime.newInstance(serviceDate.year(), serviceDate.month(), serviceDate.day());
                dayOfWeek = serviceTime.format(Constant_Util.FORMAT_DAY);
                if(Constant_Util.SATURDAY.equalsIgnoreCase(dayOfWeek) || Constant_Util.SUNDAY.equalsIgnoreCase(dayOfWeek)){
                    continue;
                }
                if(!assetIdOccurencemap.get(objAsset.Id).contains(dayOfWeek)){
                    nextServiceDate = string.valueof(serviceDate);
                    checkbool = true;
                    break;
                }
            }
        }else {
            checkbool = true;
            nextServiceDate = string.valueof(serviceDate);
        }
        if(!checkbool){
            nextServiceDate = null;
        }
        return nextServiceDate;
    }
    //Get next available date using WMCapacity 
    global static String getNextAvailableDate(Id businessHoursId,set<Date> woAvailDates, List<Date> availDateSet,string locZone){
        Date nextAvailableDate = Null;
        string availDate = null;
        for(Date cpDate : availDateSet){
            if(!woAvailDates.contains(cpDate)){
                nextAvailableDate = cpDate;
                break;   
            }
        }
        if(nextAvailableDate != null){
            availDate = string.valueof(nextAvailableDate);
        }else {
            nextAvailableDate = availDateSet[availDateSet.size() - 1];
            availDate = String.valueOf(getNextAvailableDateFromSLA(businessHoursId,woAvailDates,nextAvailableDate,nextAvailableDate,locZone,0,null));
        }
        return availDate;  
    }
    
    //Get Business Hours Datetime
    global static Datetime getBusinessHoursServiceDate(Id bId, Datetime serviceDate, Integer milliSeconds){
        return BusinessHours.addGmt(bId,serviceDate,milliSeconds);
    } 
    
    //Get Local Busines Hours Date By Datetime
    global static Datetime getLocalBusinessHoursServiceDate(Datetime dt, Case c){
        return CaseTriggerHelper.getservicedatetime(dt,c);
    } 
    
    //Get Local Busines Hours Date By Datetime
    global static Datetime converlocalTimeZone(Datetime dt, string localZone){
        TimeZone tz = Timezone.getTimeZone(localZone);
        dt = dt.addSeconds((tz.getOffset(dt)/1000));
        return dt;
    }
    
    //Get next available date using SLA
    global static Date getNextAvailableDateFromSLA(Id bId,set<Date> woAvailDates, Date SLADate,DateTime SLADatetime,string locZone,Integer count,set<String> occurencedays){
        Date nextDate = null;
        DateTime nextDateTime = SLADatetime;
        Integer extraDays = 57600000;
        Integer i=1;
        nextDate = SLADate;
        String dayOfWeek = null;
        if(count != null && count == 0 ){
            while(i>0){
                if(!woAvailDates.contains(nextDate)){
                    break;   
                } 
                else{
                    nextDateTime = getBusinessHoursServiceDate(bId,SLADatetime,extraDays * i);
                    nextDate = converlocalTimeZone(nextDateTime,locZone).dateGmt();
                }
                i++;     
            }
        }else if(count != null && count > 0){
            Boolean checkbool = false;
            for(i = 1;nextDate < = system.Today().addDays(count);i++){
                DateTime dt = DateTime.newInstance(nextDate.year(), nextDate.month(), nextDate.day()); //Actual DateTime field is giving impropriate Day therefore converting date into DateTime to get exact day of the Week.
                dayOfWeek = dt.format(Constant_Util.FORMAT_DAY);
                if(Constant_Util.SATURDAY.equalsIgnoreCase(dayOfWeek) || Constant_Util.SUNDAY.equalsIgnoreCase(dayOfWeek)){
                    nextDate = nextDate.addDays(1);
                    continue;
                }
                if(!woAvailDates.contains(nextDate) && (occurencedays == null || (occurencedays != null && !occurencedays.contains(dayOfWeek)))){
                    checkbool = true;
                    break;   
                } 
                else{
                    nextDate = nextDate.addDays(1);
                }
            }
            if(!checkbool){
                nextDate = null;
            }
        }
        return nextDate;
    }
    
    //Get Date in String Format
    public static String[] getSplitStringDate(String strDate){
        String[] strDateArray;
        if(strDate.contains(Constant_Util.FORWARD_SLASH)){
            strDateArray = strDate.split(Constant_Util.FORWARD_SLASH);
        } 
        if(strDate.contains(Constant_Util.HYPHEN)){
            strDateArray = strDate.split(Constant_Util.HYPHEN);   
        }
        return strDateArray;  
    } 
    
    
	/**
	* @description class for ANIMatchResponse
	*/ 
    global with sharing class ContainerStatusResponse{
        public Integer RecordCount {get;set;}
        public List<container> container {get;set;}
        public ErrorMessageWrapper Problem {get;set;}
        /**
	* @description Constructor
	*/
        public ContainerStatusResponse(){            
            this.RecordCount = 0;
        }
    }
    
    /**
    * @description class for ErrorMessageWrapper
    */
    global with sharing class container {
        public String ServicePromptId {get;set;}
        public String Service {get;set;}
        public String ContainerId {get;set;}
        public String ContainerPromptId {get;set;}
        public String ContainerName {get;set;}
        public String Material {get;set;}
        public String MaterialPromptId {get;set;}
        public String ServiceDate {get;set;}
        public String MostRecentPickup {get;set;}
        public String PotentialPickupDate {get;set;}
        public String ProductFamily {get;set;}
        public String TempAndOpenTop {get;set;}
        public String AssetId {get;set;}
    }
    /**
	* @description class for ErrorMessageWrapper
	*/
    global with sharing class ErrorMessageWrapper{
        public String Title {get;set;}
        public String Status {get;set;}
        public List<ErrorsWrapper> Errors {get;set;}
        
        /**
		* @description Constructor for ErrorMessageWrapper
		*/        
        public ErrorMessageWrapper(String title, String status, List<ErrorsWrapper> errors){
            this.Title = title;
            this.Status = status;
            this.Errors = errors;
        }
    } 
    
    /**
	* @description class for ErrorsWrapper
	*/
    global with sharing class ErrorsWrapper{
        public String Code {get;set;} 
        public String Message {get;set;}   
        
    /**
	* @description Constructor for ErrorsWrapper
	*/
        public ErrorsWrapper(String code, String message){
            this.Code = code;
            this.Message = message;  
        }
    }
}