/**
* @author Devendra Patel
* @date 08/23/2020
* @description : Controller class for Notification Tracking Data lightning component
**/
public With Sharing class NotificationTrackingController {
    
    public static final string SID='SID';
    public static final string MATERIAL='Material';
    
    /* @author Devendra Patel
* @date 08/26/2020
* @description : Wrapper class to return data to the NotificationTrackingData lightning component
**/
    public inherited sharing class NotificationTrackingDataWrap{
        @AuraEnabled public List<NotifTrackingWrapper> dataWrapNotifTrackLst = new List<NotifTrackingWrapper>();
        @AuraEnabled public integer count;
        @AuraEnabled public String notifMessage;
    }  
    
    /**
* @author Devendra Patel
* @date  08/26/2020
* @description : method to display notification tracking data to the NotificationTrackingData lightning component
**/
    @AuraEnabled
    public static NotificationTrackingDataWrap  getTrackingData(string assetHeaderId,string pageNumber,String pageSize){
        string response;
        Id assetId;  
        Asset assetHeader = [SELECT Id, Name, AccountId,Account.tz__Timezone_SFDC__c, Account.tz__Timezone__c ,Acorn_SBID__c FROM Asset WHERE Id = :assetHeaderId];
        assetId = assetHeader != null && assetHeader.Acorn_SBID__c != null ? assetHeader.Id : null;
        
        if(assetId == null){
            List<Asset> assetList = [SELECT Id,AccountId,Account.tz__Timezone_SFDC__c, Account.tz__Timezone__c , Acorn_SBID__c FROM Asset WHERE RootAssetId =: assetHeaderId AND Is_Active__c = true
                                     AND RecordType.Name =: Constant_Util.SERVICE_DETAIL AND Is_Core_Service__c = true LIMIT 1];
            
            if(assetList !=null && assetList.size() > 0 ){
                Asset assetObj=assetList[0];
                assetId = assetObj != null && assetObj.Acorn_SBID__c != null ? assetObj.Id : null;
            }
        }
        NotificationTrackingDataWrap  wrap = new NotificationTrackingDataWrap();
        try{
            if(assetId == null){
                wrap.notifMessage = Constant_Util.ASSET_WITHOUT_SBID; 
            }
            else{
                response = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.NOTIFICATION_API, assetId,pageNumber,pageSize);
                if(Test.isRunningTest()){
                    response = MockNotificationResponse.NOTIFICATION_MOCK_RESPONSE;
                }
                if(String.isBlank(response)){
                    wrap.notifMessage = Constant_Util.NO_NOTIF_DATA;
                } else {
                    system.debug('response-!@' + response);
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response);
                    system.debug('results-!@' + results);
                    wrap.count=(Integer)results.get(Constant_Util.COUNT);
                    List<Object> currentNotifLst = (List<Object>)results.get(Constant_Util.DATA);
                    if(currentNotifLst != null && currentNotifLst.size()>0){
                        wrap.dataWrapNotifTrackLst.addAll(buildNotifWrapper(currentNotifLst,assetHeader)); 
                    }else{
                        wrap.notifMessage = Constant_Util.NO_NOTIF_DATA;
                         wrap.dataWrapNotifTrackLst=null;
                    }
                    Map<String, Object> problemMap =(Map<String, Object>) results.get(Constant_Util.PROBLEM);
                    if (problemMap !=null ) {
                        List<object> errorlist= (List<object>)problemMap.get(Constant_Util.Errors);
                        if(errorlist != null && errorlist.size()>0){
                            map<String,Object> errorobjMap = (map<String,Object>) errorlist[0];
                            if(errorobjMap !=null){
                                string message=(String)errorobjMap.get(Constant_Util.Message);
                                wrap.notifMessage = Constant_Util.NO_NOTIF_DATA;
                            }
                        }
                    } 
                }
            }
        } 
        catch (Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            
        }
        return wrap;
    }
    
    
    /**
* @author Devendra Patel
* @date  08/26/2020
* @description : method to prepare list of NotificationTrackingData to show on NotificationTrackingData lightning component
**/
    public Static List<NotifTrackingWrapper> buildNotifWrapper(List<Object> NotifLst, Asset assetRec) {
        List<NotifTrackingWrapper> nWrapLst = new List<NotifTrackingWrapper>();
        NotifTrackingWrapper nWrap;
        try{
            
            for (Object obj : NotifLst) {
                nWrap = new NotifTrackingWrapper();
                map<String,Object> objMap = (map<String,Object>) obj;
                string DateTimeSent = (String)objMap.get(Constant_Util.DATE_TIME_SENT);
                Datetime formattedDTTime = (DateTime)JSON.deserialize('"' + DateTimeSent + '"', DateTime.class);
                nWrap.dateTimeSent =formattedDTTime.format(Constant_Util.DATE_TIME_FORMAT_12H, assetRec.Account.tz__Timezone_SFDC__c);                
                nWrap.contactName = (String)objMap.get(Constant_Util.CONTACT_NAME);
                nWrap.contactId=(String)objMap.get(Constant_Util.CONTACT_ID);
                nWrap.emailAddress = (String)objMap.get(Constant_Util.EMAILADDRESSES);
                nWrap.phoneNumber=(String)objMap.get(Constant_Util.PHONE_NUM); 
                nWrap.emailSMSType = (String)objMap.get(Constant_Util.EMAIL_SMS_TYPE);
                nWrap.emailSubBody = (String)objMap.get(Constant_Util.EMAIL_SUB_TEXT_BODY); 
                nWrap.status = (String)objMap.get(Constant_Util.READ_STATUS);  
                nWrap.messageType = (String)objMap.get(Constant_Util.NOTIF_MSG); 
                nWrap.imageURL= (String)objMap.get(Constant_Util.IMAGE_TRUCK_URL);           
                
                if( Constant_Util.ORIGIN_EMAIL.equalsIgnoreCase(nWrap.emailSMSType) ){
                    nWrap.emailAddPhoneNum=nWrap.emailAddress;
                }else{
                    nWrap.emailAddPhoneNum=nWrap.phoneNumber;
                }
                nWrapLst.add(nWrap); 
            }
            
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        return nWrapLst;
    }
    
    
    /**
* @author Accenture
* @date 6/15/2020
* @description : method to get Asset Headers for selection drop down
**/
    @AuraEnabled
    public static List<assetWrapper> getAssetHeaders(Id caseId,boolean IsLocation){
        List<Asset> assetHeaders = new List<Asset>();
        List<assetWrapper> returnWrap = new List<assetWrapper>();
        if(caseId !=null){
            try{
                
                if(!IsLocation){
                    
                
                Case caseRec = [SELECT Id, Location__c, AssetId FROM Case WHERE Id = :caseId];
                if(!string.isBlank(caseRec.Location__c)){
                    assetHeaders = [SELECT Id, Acorn_SBID__c, Name, Material_Type__c, Supplier__r.Parent_Vendor_ID__c,  Acorn_SID__c FROM Asset WHERE Location__c = : caseRec.Location__c AND Is_Active__c = true AND Service_Header_Id__c = null];
                }
                }else{
                     assetHeaders = [SELECT Id, Acorn_SBID__c, Name, Material_Type__c, Supplier__r.Parent_Vendor_ID__c,  Acorn_SID__c FROM Asset WHERE Location__c = : caseId AND Is_Active__c = true AND Service_Header_Id__c = null];
             
                }
                assetWrapper aWrapBlank = new assetWrapper();
                aWrapBlank.assetLabel = System.Label.Notification_Default;
                aWrapBlank.assetValue =  Constant_Util.DEFAULT_ASSET_VAL; 
                returnWrap.add(aWrapBlank);
                for(Asset a : assetHeaders){
                    assetWrapper aWrap = new assetWrapper();
                    aWrap.assetLabel = a.Name +  Constant_Util.BLANKSPACE + Constant_Util.HYPHEN+  Constant_Util.BLANKSPACE + SID+ Constant_Util.COLON + Constant_Util.BLANKSPACE + a.Acorn_SID__c + Constant_Util.BLANKSPACE +Constant_Util.HYPHEN + Constant_Util.BLANKSPACE +MATERIAL+ Constant_Util.COLON  + Constant_Util.BLANKSPACE + a.Material_Type__c;                    
                    aWrap.assetValue = string.valueOf(a.Id);
                    returnWrap.add(aWrap);
                }
            }catch(Exception ex){
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
                returnWrap=null;
            }
        }
        return returnWrap;
    }
    public inherited sharing class assetWrapper{
        @AuraEnabled public string assetLabel;
        @AuraEnabled public string assetValue;
    }
}