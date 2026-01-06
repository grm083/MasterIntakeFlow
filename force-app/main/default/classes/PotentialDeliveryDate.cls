/* Apex Class : getDeliveryDateForIVR
 * Description : This class is used as external API to fetch the SLA date calculation from entitlement and industry SLA for IVR.
 * Developer : Jatan Sharma
 * Date : 12-Sep-2024
 * Edit Comments :
 * //------------------------------------------------------------------------------
 * 
 * Example: /services/apexrest/getDeliveryDateForIVR?caseType=New+Service&locationCode=HMD000601&containerCode=Open+Top&duration=Temporary
 * //------------------------------------------------------------------------------
 */
@RestResource(urlMapping='/PotentialDeliveryDate/V1/*') 
global with sharing class PotentialDeliveryDate {
    @HttpPost
    global static void getData() {

        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        Entitlement relEntitlement = new Entitlement();
        DateTime SLADate = system.now() + 2; // Adding 2 addition days as default in case of failure, as we can not deliver on same day.
        wrapper wr = new wrapper();

        try{
            String jsonRequest = inboundRequest.requestBody.toString();
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            String locationCode = string.valueOf(requestDataMap.get('locationCode'));// HMD000601
            String duration = string.valueOf(requestDataMap.get('duration'));// Temporary
            String container = string.valueOf(requestDataMap.get('containerCode'));// Open Top
            String caseType = string.valueOf(requestDataMap.get('caseType')); //New Service
            String productFamily;
            BusinessHours businessHourId;

            List<Account> acc = [select id,Name,ParentId, Parent.name, tz__Timezone_SFDC__c from account where name=: locationCode limit 1];
            Account locationDetial =  acc!=null && acc.size()>0 ? acc[0] : null;

        
            List<Product2> productDetail = [select id,name,ProductCode, Family from product2 where ProductCode=:container];
            productFamily = productDetail !=null && productDetail.size()>0 ? productDetail[0].Family:null;
            String containerCode = productDetail[0].name;// Open Top

            BusinessHours defaultHours = [SELECT Id FROM BusinessHours WHERE isDefault = true LIMIT 1];
            system.debug('locationDetial.tz__Timezone_SFDC__c '+locationDetial.tz__Timezone_SFDC__c);
            if(!QuoteFavoritesController.getSLASwitch()){
                List<BusinessHours> locationBusinessHours = QuoteFavoritesController.getBusinessIdByTimeZone(locationDetial.tz__Timezone_SFDC__c);
                if(locationBusinessHours != null && locationBusinessHours.size() > 0)
                {
                    businessHourId = locationBusinessHours[0];
                }
                else
                {
                    businessHourId = defaultHours;
                }
                system.debug('businessHourId ' +businessHourId);
            }
            else{
                businessHourId = defaultHours;
            }

            relEntitlement = getRelatedEntitleMent(locationDetial, duration,containerCode,caseType);
            
            if (relEntitlement == null || relEntitlement.id==null)
            {
                Industry_Standard_SLA__mdt IndStSLA ;
                
                List<Industry_Standard_SLA__mdt> industryStandards = [SELECT Id, Service__c, After__c, Before__c
                                                                    FROM Industry_Standard_SLA__mdt
                                                                    WHERE Service__c LIKE 'New Service%'];
                
                for(Industry_Standard_SLA__mdt ind : industryStandards) {
                
                    if (ind.Service__c.contains(productFamily) && ind.Service__c.contains(duration)) {
                        IndStSLA = ind;
                        break;
                    }  
                    else if (ind.Service__c.contains('Service') && ind.Service__c.contains(duration)) {
                        IndStSLA = ind;
                    }
                }
                if(!QuoteFavoritesController.getSLASwitch()){
                    SLADate = QuoteFavoritesController.calculateISSLA_LocTimezone(IndStSLA, businessHourId, null, locationDetial.tz__Timezone_SFDC__c);
                }
                else{
                    SLADate = QuoteFavoritesController.calculateISSLA(IndStSLA, businessHourId);
                }
            }
            else
            {
                if(!QuoteFavoritesController.getSLASwitch()){
                    SLADate = QuoteFavoritesController.calculateEntitlementSLA_LocTimezone(relEntitlement, businessHourId , locationDetial.tz__Timezone_SFDC__c);
                }
                else{
                    SLADate = QuoteFavoritesController.calculateEntitlementSLA(relEntitlement, businessHourId);
                }
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug('Exception Occure : ' +ex.getMessage()+ ' In line :'+ ex.getLineNumber());
            //wr.errorMessage = 'Exception Occure : ' +ex.getMessage()+ ' In line :'+ ex.getLineNumber();
        }
        wr.deliveryDate = SLADate;
        outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
        outboundResponse.responseBody = Blob.valueOf(JSON.serialize(wr));
        outboundResponse.statusCode = 200;
    }

    public static Entitlement getRelatedEntitleMent(Account locationDetial, string duration, string containerCode, string caseType){
        system.debug('Inside Entitlement fetch');
        system.debug('locationDetial '+locationDetial+'duration '+duration+'containerCode '+containerCode+'caseType '+caseType);
        List<Entitlement> entList = new List<Entitlement>();
        List<Entitlement> filterListByTime = new List<Entitlement>();
        Entitlement e = new Entitlement();
        //Adding Order By Container Condition in the Query for Priority Logic - SDT-24925
        entList = [SELECT Id, Request_Type__c, Service__c, AccountId, Project_Code__c, Container__c,
           Service_Guarantee_Category__c, Service_Guarantee_Category_Value__c, Call_On__c, 
           Project__c, Location__c, Schedule_Type__c, Before_After__c,Call_Time__c 
           FROM Entitlement WHERE Request_Type__c =: Constant_Util.NEW_SERVICE 
           AND Status__c =:  Constant_Util.APPROVED
           AND (Container__c =: containerCode OR Container__c = '' OR Container__c = null ) 
           AND ((AccountId =: locationDetial.ParentId AND Location__c =: locationDetial.id) 
                OR (AccountId =: locationDetial.ParentId AND Location__c = null)) 
           AND StartDate <= TODAY AND (EndDate = null OR EndDate >= TODAY) ORDER BY Container__c DESC];

        if(!QuoteFavoritesController.getSLASwitch()){
            system.debug('entList ' +entList);
            system.debug('entList count ' +entList.size());
            QuoteFavoritesController.currentDateTime currDateTime = new QuoteFavoritesController.currentDateTime(locationDetial.tz__Timezone_SFDC__c);
            system.debug('currDateTime '+currDateTime);
            //Added for defect SDT-48518 Jatan Sharma
            
            for(Entitlement e1 : entList){
                integer currentHour = Integer.valueOf(currDateTime.hours.split(':')[0]);
                integer callTime = Integer.valueOf(e1.Call_Time__c.split(':')[0]);
                If(e1.Before_After__c != null && (Constant_Util.BEFORE).equalsIgnorecase(e1.Before_After__c)){
                    if(currDateTime.hours <= e1.Call_Time__c)
                    {
                        filterListByTime.add(e1);
                    }
                }
                else If(e1.Before_After__c != null && (Constant_Util.AFTER).equalsIgnorecase(e1.Before_After__c)){
                    if(currDateTime.hours >= e1.Call_Time__c)
                    {
                        filterListByTime.add(e1);
                    }
                }
            }
        }
        else{
            filterListByTime = entList;
        }
        system.debug('filterListByTime ' +filterListByTime);
        system.debug('filterListByTime ' +filterListByTime.size());

        for(Entitlement ent: filterListByTime){
            //Duration and Container Match for Location - - Priority 3
            if(duration == ent.Schedule_Type__c && containerCode == ent.Container__c && 
                locationDetial.id  == ent.Location__c)
            {
                e = ent;
                break;
            }
            //Duration Match for Location - - Priority 4
            else if(duration == ent.Schedule_Type__c && locationDetial.id == ent.Location__c)
            {
                e = ent;
                break;                        
            }
            //Duration and Container Match for Location's Parent Account - - Priority 5
            else if(duration == ent.Schedule_Type__c && containerCode == ent.Container__c && 
                    locationDetial.ParentId == ent.AccountId)
            {
                e = ent;
                break;
            }
            //Duration Match for Location's Parent Account - Priority 6
            else if(duration == ent.Schedule_Type__c && locationDetial.ParentId == ent.AccountId)
            {
                e = ent;
                break;
            }
        }
        return e;
    } 

    global with sharing class wrapper{
        public Datetime deliveryDate {get;set;}
        //public string errorMessage {get;set;}
    }
}