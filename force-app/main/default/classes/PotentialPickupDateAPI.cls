/*************************************************************
@Name: PotentialPickupDateAPI
@Author: Accenture
@CreateDate: 11/17/2020
@UsedBy: SDT-17488
**************************************************************/
@RestResource(urlMapping='/PotentialPickupDate/V1/*') 
global with sharing class PotentialPickupDateAPI {        
    public static Map<Id,set<Date>> getWoListByAssetId = new Map<Id,set<Date>>();
    public static Map<Id,Asset> containerWithContainerIdMap = new Map<Id,Asset>();
    public static Map<Id,Entitlement> getEntitlementByAssetId = new Map<Id,Entitlement>(); 
    public static Map<Id,Case> mapCaseAsset = new Map<Id,Case>();
    public static map<Id,Boolean> hasweeklyfrequencymap = new map<Id,Boolean>();    
    public static Map<Id,String> mapSBID = new Map<Id,String>();
    public static map<Id,Set<string>> assetIdOccurencemap = new map<Id,Set<String>>();
    
    @HttpPost
    global static void getAssetDetail(){ 
        //Initialize RestContext
        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        List<Asset> assetLst = new List<Asset>();
        Set<Id> locationIds = new Set<Id>();
        List<Case> caseList = new List<Case>();
        List<Case> newCaseList = new List<Case>();
        set<String> occrenceSet = new set<String>();
        Set<Id> selfCoreDetailSet = new Set<Id>();
        List<container> lstContainer = new List<container>();
        List<ErrorsWrapper> errorList = new List<ErrorsWrapper>();
        Integer count = 0;        
        ContainerStatusResponse contStatusResp = new ContainerStatusResponse();  
        try{
            String jsonRequest = inboundRequest.requestBody.toString();
            //Convert request body to data structure, deserialize JSON
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            //Get values from map
            String connectionId = string.valueOf(requestDataMap.get(Constant_Util.CONNECTION_ID));
            string assetHeaderId = string.valueOf(requestDataMap.get(Constant_Util.ASSET_HEADER_ID));
            Id assetId;
            assetLst = [SELECT Id, Has_Extra_Pickup__c, Product2Id, Product2.Container_Prompt_ID__c, Location__r.ParentId, 
                        Is_Active__c,Location__c,Location__r.Parent.Customer_Code__c, Quantity__c, ProductFamily, Location_Code__c , Product2.Name , Equipment_Type__c, 
                        Duration__c, Material_Type__c, Location__r.Name,  RecordType.DeveloperName, Acorn_SBID__c,Product2.Voice_Prompt__c,Occurrence_Type__c,
                        Product2.ProductTypeSelected__c, Project_Code__c, Active__c, End_Date_Based_on_Project_code__c,End_Date__c,Start_Date__c,Frequency__c,
                        (SELECT Id,Quantity__c,SBID_Text_c__c,Is_Self_Service__c,Is_Core_Service__c,Supplier__r.Parent_Vendor_ID__c,Project_Code__c,Location__r.Parent.Customer_Code__c,Active__c,Frequency__c, Occurs__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c,Sunday__c,Service_Header_Id__c 
                         FROM Assets_Parent__r 
                         WHERE Is_Active__c = true)                                
                        FROM Asset  WHERE Id =: assetHeaderId AND RecordType.DeveloperName =: Constant_Util.SERVICE_HEADER LIMIT 1];
            if(assetLst !=null && !assetLst.isEmpty()) {
                Set<Id> assetIds = new Set<Id>();
                count = assetLst.size();
                assetId = assetLst[0].Id;
                for(Asset a: assetLst){
                    for(Asset serviceDetail : a.Assets_Parent__r){
                        if(serviceDetail.Quantity__c==1 && serviceDetail.Is_Self_Service__c){
                            selfCoreDetailSet.add(serviceDetail.Id);
                            if((mapSBID.isEmpty() || !mapSBID.containsKey(a.Id))  ){
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
                    if(selfCoreDetailSet!=null && !selfCoreDetailSet.isEmpty() ){
                        locationIds.add(a.Location__c);
                        CaseTriggerHelper.casewithContainer.put(a.Id,a);
                        containerWithContainerIdMap.put(a.Id,a);
                        if(Constant_Util.COMMERCIAL.equalsIgnoreCase(a.ProductFamily)){
                            if(occrenceSet!=null && !occrenceSet.IsEmpty() && occrenceSet.size() > 0){
                                assetIdOccurencemap.put(a.Id,occrenceSet);
                            }
                        }
                    }
                }
            }
            
            if(assetId !=null){
                //Location Data for SLA
                for(Account loc: [SELECT Id, Brand__c,  Geography__c, Division__c, Location_Type__c, tz__Timezone_SFDC__c 
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
                newCaseList = CaseTriggerHelper.getServiceDate(caseList);
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
                Set<string> potentialWorkOrderStatus = new set<string>{Constant_Util.SENT,Constant_Util.ACCEPTED,Constant_Util.WORK_COMPLETE,Constant_Util.RELEASED_FOR_PAYMENT,Constant_Util.CLOSED,Constant_Util.ISSUED,Constant_Util.Sending,Constant_Util.STR_REJECTED,Constant_Util.STR_NEW,Constant_Util.STR_PENDING_DRAFT};        
                for(WorkOrder objWO :  [SELECT Id, Is_Bypass__c, Service_Date__c, SLA_Service_Date_Time__c, Status, AssetId, CaseId, Case.Case_Type__c,
                                            Case.Case_Sub_Type__c, Case.Case_Reason__c,CreatedDate 
                                            FROM WorkOrder
                                            WHERE AssetId =: assetId AND Status IN: potentialWorkOrderStatus 
                                            AND Is_Bypass__c = false AND Service_Date__c >= TODAY
                                            ORDER By Service_Date__c DESC]) {          
                                                if(getWoListByAssetId.containsKey(objWO.AssetId) && objWO.Service_Date__c >= System.today()) {
                                                    getWoListByAssetId.get(objWO.AssetId).add(objWO.Service_Date__c); 
                                                } else if(objWO.Service_Date__c >= System.today()) {
                                                    getWoListByAssetId.put(objWO.AssetId, new set<Date>{objWO.Service_Date__c});
                                                }                  
                                            }
            }
            string potentialPickupDate = null;
            Date potentialDate = null;
            map<Id,Date> validateDateByAssetId = new map<Id,Date>();
            
            if(assetLst !=null && !assetLst.isEmpty() && assetId !=null){
                potentialPickupDate = getNextServiceDate(assetLst[0]);
                if(String.isNotBlank(potentialPickupDate)){
                    potentialDate = Date.valueof(potentialPickupDate); 
                    validateDateByAssetId.put(assetId,potentialDate);
                } else {
                    if(mapCaseAsset.containskey(assetId)){
                        potentialDate = (mapCaseAsset.get(assetId).Service_Date__c).addDays(Integer.valueof(System.Label.Next_Business_Days));
                        validateDateByAssetId.put(assetId,potentialDate);
                    }
                }
            }
                
            Map<Id,String> isValidAssetMap = GetCaseInformation.getAssetDetail(validateDateByAssetId);
                
                
                
                // Output generation
                contStatusResp.container = new List<container>();
                container objCon = null;        
                for(Asset objAsset : assetLst){  
                    objCon = new container();            
                    if(isValidAssetMap.containskey(objAsset.Id)){
                        if(String.isBLANK(isValidAssetMap.get(objAsset.Id))){
                            objCon.IsValidAsset = Constant_Util.YES;
                            objCon.PotentialPickupDate = potentialPickupDate;
                            objCon.AssetErrorMessage = Constant_Util.EMPTY_STRING;
                        } else {
                            objCon.IsValidAsset = Constant_Util.NO;
                            objCon.AssetErrorMessage = isValidAssetMap.get(assetId);
                            objCon.PotentialPickupDate = Constant_Util.EMPTY_STRING;
                        }
                    }
                    lstContainer.add(objCon);
                }
                contStatusResp.container.addAll(lstContainer);
                contStatusResp.RecordCount = count;
                outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
                outboundResponse.responseBody = Blob.valueOf(JSON.serialize(contStatusResp));
                outboundResponse.statusCode = 200;
            
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            ErrorsWrapper errorDetails = new ErrorsWrapper(ex.getTypeName(), ex.getMessage()); 
            errorList.add(errorDetails);
            contStatusResp.Problem =  new ErrorMessageWrapper(Constant_Util.EXCEPTION_OCCURRED, 
                                                              Constant_Util.KEYWORD_EXCEPTION, errorList); 
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(contStatusResp));      
            outboundResponse.statusCode = 400;
        }
    }
    
    global static String getNextServiceDate(Asset objAsset){
        String nextServiceDate = Null;
        if(objAsset != Null){
            string loczone = Constant_Util.EMPTY_STRING;
            if(CaseTriggerHelper.casewithLocation.containsKey(objAsset.Location__c)){
                loczone = CaseTriggerHelper.casewithLocation.get(objAsset.Location__c).tz__Timezone_SFDC__c;
            }
            
            Id businessHoursId = CaseTriggerHelper.businessIdMap.get(locZone);
            if(getWoListByAssetId.get(objAsset.Id) == NULL || getWoListByAssetId.isEmpty()){
                if(mapCaseAsset.containsKey(objAsset.Id)){
                    nextServiceDate = String.valueOf(mapCaseAsset.get(objAsset.Id).Service_Date__c); 
                }
            }
            //For Gold Standard and Contractual SLAs            
            if(getEntitlementByAssetId != NULL && !getEntitlementByAssetId.isEmpty() && getEntitlementByAssetId.get(objAsset.Id) != NULL && (getEntitlementByAssetId.get(objAsset.Id).Gold_Standard__c || getEntitlementByAssetId.get(objAsset.Id).Contractual__c || Constant_Util.COMMERCIAL.equalsIgnoreCase(objAsset.ProductFamily))){
                if(getWoListByAssetId.get(objAsset.Id) != NULL && mapCaseAsset.get(objAsset.Id) != Null) {
                    nextServiceDate = String.valueOf(getNextAvailableDateFromSLA(businessHoursId,getWoListByAssetId.get(objAsset.Id),mapCaseAsset.get(objAsset.Id).Service_Date__c,mapCaseAsset.get(objAsset.Id).SLA_Service_Date_Time__c,locZone, Constant_Util.COMMERCIAL.equalsIgnoreCase(objAsset.ProductFamily) && Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id) ? Integer.valueof(System.Label.Next_Business_Days) : 0 , assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) ? assetIdOccurencemap.get(objAsset.Id) : null));
                } else if(Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id)
                          && assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) && mapCaseAsset != null && mapCaseAsset.containskey(objAsset.Id)){
                              nextServiceDate =  getPotentialDate(objAsset);
                          }
            }            
            //For Not-Gold Standard/No Entitlement Found
            else if((getEntitlementByAssetId != NULL && !getEntitlementByAssetId.isEmpty() && getEntitlementByAssetId.containskey(objAsset.Id) && !getEntitlementByAssetId.get(objAsset.Id).Gold_Standard__c) && !getEntitlementByAssetId.get(objAsset.Id).Contractual__c || getEntitlementByAssetId.isEmpty() || (!getEntitlementByAssetId.isEmpty() && !getEntitlementByAssetId.containskey(objAsset.Id))){
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
                            if(Test.isRunningTest()) {
                                t = Date.newInstance(Integer.valueOf(strDate[0]),Integer.valueOf(strDate[1]),Integer.valueOf(strDate[2]));
                            } else {
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
                    } else {
                        nextServiceDate = string.valueof(plannerDates[0]);
                    }
                }
                else {
                    if(!getWoListByAssetId.Isempty() && getWoListByAssetId.containskey(objAsset.Id) && !mapCaseAsset.isEmpty() && mapCaseAsset.containskey(objAsset.Id)){
                        nextServiceDate = String.valueOf(getNextAvailableDateFromSLA(businessHoursId,getWoListByAssetId.get(objAsset.Id),mapCaseAsset.get(objAsset.Id).Service_Date__c,mapCaseAsset.get(objAsset.Id).SLA_Service_Date_Time__c,locZone, Constant_Util.COMMERCIAL.equalsIgnoreCase(objAsset.ProductFamily) && Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id) ? Integer.valueof(System.Label.Next_Business_Days) : 0,assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) ? assetIdOccurencemap.get(objAsset.Id) : null));
                    } else if(Constant_Util.SCHEDULED.equals(objAsset.Occurrence_Type__c) && !hasweeklyfrequencymap.isEmpty() && hasweeklyfrequencymap.containskey(objAsset.Id) && hasweeklyfrequencymap.get(objAsset.Id) 
                              && assetIdOccurencemap != null && assetIdOccurencemap.containskey(objAsset.Id) && mapCaseAsset != null && mapCaseAsset.containskey(objAsset.Id)){
                                  nextServiceDate = getPotentialDate(objAsset);
                              }
                }     
            } 
        }
        return nextServiceDate;
    }
    
    //Get Business Hours Datetime
    global static Datetime getBusinessHoursServiceDate(Id bId, Datetime serviceDate, Integer milliSeconds){
        return BusinessHours.addGmt(bId,serviceDate,milliSeconds);
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
        } else if(count != null && count > 0){
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
                else {
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
    
    /***
    ***Method to find PotentialDate when WorkOrder is not available for comerical products
    **/
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
        } else if(Constant_Util.SUNDAY.equalsIgnoreCase(dayOfWeek)){
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
        } else {
            checkbool = true;
            nextServiceDate = string.valueof(serviceDate);
        }
        if(!checkbool){
            nextServiceDate = null;
        }
        return nextServiceDate;
    }
    
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
    
    global with sharing class container {
        public String PotentialPickupDate {get;set;}
        public string IsValidAsset{get;set;}           
        public string AssetErrorMessage{get;set;}	
    }
}
