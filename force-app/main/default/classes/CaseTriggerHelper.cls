/**
* @author Waste Management
* @date 2021
*
* @group Cases
* @group-content ../../ApexDocContent/Cases.htm
*
* @description Helper class for having all the business logic for CaseTriggerHandler events. 
*              This class generally getting executed from all the CaseTriggerHandler.
*/
                                                                                                  

public without sharing class CaseTriggerHelper { 
    private static Map<Id,string> caseContainerMap = new Map<Id,string>();
    public static Map<Id,Asset> casewithContainer = new Map<Id,Asset>();
    public static Map<Id,Account> casewithLocation = new Map<Id,Account>();
    public static Map<String,Integer> caseWorkOrderCount = new Map<String,Integer>();
    public static Map<String,Id> businessIdMap = new Map<String,Id>();
    public static set<Id> locationIdSet = new set<Id>();
    public static set<Id> parentAccountIdset = new set<Id>();
    private static set<Id> contactIdset = new set<Id>();
    public static set<String> serviceset = new set<String>();
    private static set<Id> containerIdSet = new set<Id>();
    private static Map<String,Industry_Standard_SLA__mdt> industyStandardSLAMap = new Map<String,Industry_Standard_SLA__mdt>();
    private Enum SERVICETYPE {DAYS, HOURS}
    private static map<Id,List<Approval_Log__c>> approvalLogmap = new map<Id,List<Approval_Log__c>>();
    public static map<string,Entitlement> casekeywithEntitlementMap = new map<string,Entitlement>();
    private static String CaseOrigin;
	private static String bypassApp;
	private static String bypassCSR;
    private static String bypassCAT;
    private static String bypassEmail;
    public static List<Approval_Log__c> appLogList = new List<Approval_Log__c>();
	public static Integer runCount = 0;
    public static Boolean originActiveApprover = false;
    public static Boolean isSingleOriginApprover = false; 
    /*
* This method is to get the Service Date for the respective case based on the Entitlement availability or based on Industry Standard SLA.
* @owner : Priyadharshini R
* @param : CaseList
*/    public static List<Case> getServiceDate(List<Case> newCaseList){
        
        map<string,case> caseMap = new map<string,case>();
        map<string,case> resultmap = new map<string,case>();
        List<Case> caseList=new List<Case>();
        string container = null;
        string casekey = null;
        DateTime serviceTime = DateTime.newInstance(0, 0, 0, 0, 0, 0);
        string scheduleType = null;
        Boolean isBackDatedCase = false;
        
        try{
            for(Industry_Standard_SLA__mdt sla :Industry_Standard_SLA__mdt.getAll().values()){ 
                industyStandardSLAMap.put(sla.Service__c,sla);
            }
            for(Case thisCase :newCaseList){
                if(String.ISBlank(thisCase.Case_Type__c) || (businessIdMap != null && !businessIdMap.isEmpty() && !businessIdMap.containsKey(casewithLocation.get(thisCase.Location__c).tz__Timezone_SFDC__c))){
                    continue;
                }
                if(thisCase.Service_Date__c != null && thisCase.Service_Date__c < date.today()){
                    isBackDatedCase = true;
                }           
                
                thisCase.SlaStartDate = getservicedatetime(System.now(),thisCase);
                parentAccountIdset.add(thisCase.Client__c);
                serviceset.add(thisCase.Case_Sub_Type__c);
                if(String.ISNotBlank(thisCase.Case_Type__c) && thisCase.Case_Type__c.equalsIgnoreCase(CONSTANT_UTIL.NEW_SERVICE)){
                    container = thisCase.Equipment_Type_Code__c != Null? thisCase.Equipment_Type_Code__c : Null;
                    casekey = thisCase.Client__c + Constant_Util.STAR + thisCase.Location__c + Constant_Util.STAR + container + Constant_Util.STAR + thisCase.Case_Sub_Type__c + Constant_Util.STAR + scheduleType;
                }
                else{
                    container = casewithContainer != null && casewithContainer.containsKey(thisCase.AssetId) ? casewithContainer.get(thisCase.AssetId).Product2.ProductTypeSelected__c : null;
                    scheduleType = casewithContainer != null && casewithContainer.containsKey(thisCase.AssetId) ? casewithContainer.get(thisCase.AssetId).Duration__c : null;
                    casekey = thisCase.Client__c + Constant_Util.STAR + thisCase.Location__c + Constant_Util.STAR + container + Constant_Util.STAR + thisCase.Case_Sub_Type__c + Constant_Util.STAR + scheduleType;
                }
                
                caseMap.put(casekey,thisCase);
                
            }
            If(!caseMap.isEmpty() && caseMap.size() > 0){
                casekeywithEntitlementMap = fetchSLA(caseMap);
                DateTime additionalDate;
                Boolean isDay = false;
                Boolean isDefault = false;
                DateTime localdate = null;
                Date targetDate = null;
                Time targetTime = null;
                
                for(String key : caseMap.keySet()){
                    additionalDate = null;
                    /*SDT-4751 changes start*/
                    If(!casekeywithEntitlementMap.IsEmpty() && casekeywithEntitlementMap.size() > 0 && casekeywithEntitlementMap.containskey(key)){                        
                        isDay = casekeywithEntitlementMap.get(key).Service_Guarantee_Category__c.equalsIgnorecase(string.valueof(SERVICETYPE.DAYS)) ? True : false;
                        if(casekeywithEntitlementMap.get(key).Service_Guarantee_Category_Value__c != null && (Constant_Util.VALUE_ZERO).Equals(String.valueOf(casekeywithEntitlementMap.get(key).Service_Guarantee_Category_Value__c))){
                            casekeywithEntitlementMap.get(key).Service_Guarantee_Category_Value__c = Constant_Util.VALUE_ONE;
                            additionalDate = getdate(Constant_Util.BEFORE,CaseMap.get(key).SlaStartDate, isDay ? SERVICETYPE.DAYS : SERVICETYPE.HOURS,CaseMap.get(key));
                            serviceTime = getSLADateTime(casekeywithEntitlementMap.get(key),additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                        }else if(casekeywithEntitlementMap.get(key).Service_Guarantee_Category_Value__c != null && (Constant_Util.VALUE_ONE).Equals(String.valueOf(casekeywithEntitlementMap.get(key).Service_Guarantee_Category_Value__c))){
                            additionalDate = getdate(Constant_Util.AFTER,CaseMap.get(key).SlaStartDate, isDay ? SERVICETYPE.DAYS : SERVICETYPE.HOURS,CaseMap.get(key));
                            serviceTime = getSLADateTime(casekeywithEntitlementMap.get(key),additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                        }else if(casekeywithEntitlementMap.get(key).Call_Time__c!=null){
                            additionalDate = getdate(casekeywithEntitlementMap.get(key).Before_After__c,CaseMap.get(key).SlaStartDate, isDay ? SERVICETYPE.DAYS : SERVICETYPE.HOURS,CaseMap.get(key));
                            serviceTime = getSLADateTime(casekeywithEntitlementMap.get(key),additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                        }else{
                            Integer t = CaseMap.get(key).SlaStartDate.hourGmt();
                            if(CaseMap.get(key).SlaStartDate.hourGmt() > 14 || (CaseMap.get(key).SlaStartDate.hourGmt() == 14 && CaseMap.get(key).SlaStartDate.minuteGmt() > 0)){
                                additionalDate = getdate(Constant_Util.AFTER,CaseMap.get(key).SlaStartDate, isDay ? SERVICETYPE.DAYS : SERVICETYPE.HOURS,CaseMap.get(key));
                                serviceTime = getSLADateTime(casekeywithEntitlementMap.get(key),additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));   
                            } else {
                                additionalDate = getdate(Constant_Util.BEFORE,CaseMap.get(key).SlaStartDate, isDay ? SERVICETYPE.DAYS : SERVICETYPE.HOURS,CaseMap.get(key));
                                serviceTime = getSLADateTime(casekeywithEntitlementMap.get(key),additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                            }
                        }
                    }else { 
                             // SDT - 11658
                        String con;
                        if(String.isBlank(CaseMap.get(key).Case_Reason__c) && (CONSTANT_UTIL.PICKUP_CSTYPE.equalsIgnoreCase(CaseMap.get(key).case_type__c))
  
                            || (String.isBlank(CaseMap.get(key).Case_Reason__c ) && !CONSTANT_UTIL.PICKUP_CSTYPE.equalsIgnoreCase(CaseMap.get(key).case_type__c)) 
                            || ((String.isNotBlank(CaseMap.get(key).Case_Reason__c )&& (CONSTANT_UTIL.PICKUP_CSTYPE.equalsIgnoreCase(CaseMap.get(key).case_type__c))))){
                                  System.debug('In first Loop');
                                  con = CaseMap.get(key).Case_Type__c+Constant_Util.UNDERSCORE+CaseMap.get(key).Case_Sub_Type__c;                                
                        } 
                        // For Non-Pickup 
                        else if(String.isNotBlank(CaseMap.get(key).Case_Reason__c) && !CONSTANT_UTIL.PICKUP_CSTYPE.equalsIgnoreCase(CaseMap.get(key).case_type__c) && !CONSTANT_UTIL.NEW_SERVICE.equalsIgnoreCase(CaseMap.get(key).case_type__c) ) {
                        con = CaseMap.get(key).Case_Type__c+Constant_Util.UNDERSCORE+CaseMap.get(key).Case_Sub_Type__c+Constant_Util.UNDERSCORE+CaseMap.get(key).Case_Reason__c;      
                        }
                        
                        // SDT-9498 (New Service Flow)
                        else if(CaseMap.get(key).case_type__c.equalsIgnoreCase(CONSTANT_UTIL.NEW_SERVICE)) {
                            System.debug('In Second');
                            con = CaseMap.get(key).Case_Type__c+Constant_Util.UNDERSCORE+CaseMap.get(key).Case_Sub_Type__c+Constant_Util.UNDERSCORE+CaseMap.get(key).LOB__c;      
                        }
                        
                        
                        
                        isDefault = true;
                        
                        //logic for same day             
                        if(!casekeywithEntitlementMap.IsEmpty() && casekeywithEntitlementMap.size() > 0 &&(Constant_Util.VALUE_ZERO).Equals(String.valueOf(industyStandardSLAMap.get(con).after__c))){
                             additionalDate = getdate(Constant_Util.BEFORE,CaseMap.get(key).SlaStartDate,SERVICETYPE.DAYS ,CaseMap.get(key));
                             serviceTime = getIndustryStandards(Constant_Util.BEFORE,con,additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                        }
                        
                        //logic for Next day
                        else if(!casekeywithEntitlementMap.IsEmpty() && casekeywithEntitlementMap.size() > 0 &&(Constant_Util.VALUE_ONE).Equals(String.valueOf(industyStandardSLAMap.get(con).before__c))){
                            additionalDate = getdate(Constant_Util.AFTER,CaseMap.get(key).SlaStartDate,SERVICETYPE.DAYS ,CaseMap.get(key));
                            serviceTime = getIndustryStandards(Constant_Util.AFTER,con,additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                        }            
                        else if(CaseMap.get(key).SlaStartDate.hourGmt() > 14 || (CaseMap.get(key).SlaStartDate.hourGmt() == 14 && CaseMap.get(key).SlaStartDate.minuteGmt() > 0)){
                            additionalDate = getdate(Constant_Util.AFTER,CaseMap.get(key).SlaStartDate,SERVICETYPE.DAYS ,CaseMap.get(key));
                            serviceTime = getIndustryStandards(Constant_Util.AFTER,con,additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                        }
                        else{
                            additionalDate = getdate(Constant_Util.BEFORE,CaseMap.get(key).SlaStartDate,SERVICETYPE.DAYS ,CaseMap.get(key));
                            serviceTime = getIndustryStandards(Constant_Util.BEFORE,con,additionalDate,businessIdMap.get(casewithLocation.get(CaseMap.get(key).Location__c).tz__Timezone_SFDC__c));
                        }
                    }
                    /*SDT-4751 Changes End*/
                    If(!CaseMap.IsEmpty() && String.isNotBlank(CaseMap.get(Key).SLA_Override_Reason__c) && Constant_Util.SLA_OVERRIDE_REASON.equals(CaseMap.get(Key).SLA_Override_Reason__c) && CaseMap.get(key).SLA_Service_Date_Time__c != null){
                        continue;
                    }
                    else If(((!CaseMap.IsEmpty()  && CaseMap.get(Key).Service_Date__c!=null && serviceTime.date()!= CaseMap.get(Key).Service_Date__c && serviceTime.date() < CaseMap.get(Key).Service_Date__c&& !Constant_Util.SLA_OVERRIDE_REASON.equals(CaseMap.get(Key).SLA_Override_Reason__c) && String.isNotBlank(CaseMap.get(Key).SLA_Override_Reason__c)) || isBackDatedCase ) && CaseMap.get(Key).Source_System__c != Constant_Util.ACORN) {
                        targetDate = Date.newInstance((CaseMap.get(Key).Service_Date__c).year(), (CaseMap.get(Key).Service_Date__c).month(), (CaseMap.get(Key).Service_Date__c).day());
                        targetTime = Time.newInstance(21, 0, 0, 0);
                        CaseMap.get(Key).SLA_Service_Date_Time__c = getadditionalDate(targetDate,targetTime,casewithLocation.get(CaseMap.get(Key).Location__c).tz__Timezone_SFDC__c);
                    }
                    else If(((casekeywithEntitlementMap.get(key) != null && isDay) || isDefault )) {
  			//SDT-32837 to prevent SLA recalculation if condition added
                    if(CaseMap.get(key).SLA_Service_Date_Time__c == null|| (CaseMap.get(key).SLA_Service_Date_Time__c != null && CaseMap.get(key).SLA_Service_Date_Time__c < serviceTime)){                      
                        CaseMap.get(key).SLA_Service_Date_Time__c = serviceTime;
                      }
                    }else {
                    if(CaseMap.get(key).SLA_Service_Date_Time__c == null|| (CaseMap.get(key).SLA_Service_Date_Time__c != null && CaseMap.get(key).SLA_Service_Date_Time__c < serviceTime)){
                        CaseMap.get(key).SLA_Service_Date_Time__c = serviceTime; 
                    	   }
                        
                    }
                    If(string.isBlank(string.valueOf(CaseMap.get(key).Service_Date__c))){
                        localdate = getservicedatetime(ServiceTime,CaseMap.get(key));
                        CaseMap.get(key).Service_Date__c = localdate.dateGmt();
                    }      
                    if(string.isblank(CaseMap.get(key).User_Input_Work_Order_Instructions__c) && casekeywithEntitlementMap.containskey(key)&& !string.isblank(casekeywithEntitlementMap.get(key).SLA_Ins__c)){
                        CaseMap.get(key).User_Input_Work_Order_Instructions__c = casekeywithEntitlementMap.get(key).SLA_Ins__c;
                    }
                    else if(!string.isblank(CaseMap.get(key).User_Input_Work_Order_Instructions__c)&& casekeywithEntitlementMap.containskey(key)&& !string.isblank(casekeywithEntitlementMap.get(key).SLA_Ins__c)
                    && !CaseMap.get(key).User_Input_Work_Order_Instructions__c.contains(casekeywithEntitlementMap.get(key).SLA_Ins__c)){
                        CaseMap.get(key).User_Input_Work_Order_Instructions__c += CONSTANT_UTIL.NEW_LINE+casekeywithEntitlementMap.get(key).SLA_Ins__c;
                        
                    }
                   
                }
                //changes Starts for SDT-7641
                
                for(case c : newCaseList){
                    container = casewithContainer != null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Product2.ProductTypeSelected__c : null;
                    scheduleType = casewithContainer != null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Duration__c : null;
                    casekey = c.Client__c + Constant_Util.STAR + c.Location__c + Constant_Util.STAR + container + Constant_Util.STAR + c.Case_Sub_Type__c + Constant_Util.STAR + scheduleType;
                    DateTime updatedSLADate;
                    if(CaseMap.containskey(casekey)){
                        c.Service_Date__c = string.isBlank(String.valueof(c.Service_Date__c)) ? CaseMap.get(casekey).Service_Date__c : c.Service_Date__c;
                        c.SLA_Service_Date_Time__c = CaseMap.get(casekey).SLA_Service_Date_Time__c;
                        //SDT-32837 to prevent SLA miscalculation from service channel
                        
                       
		        updatedSLADate = getSLACorrectedDate(c);
                        if(updatedSLADate != null){
                        	c.SLA_Service_Date_Time__c = updatedSLADate;
			}
                        //SDT-32837
                    }
                    caseList.add(c);
                }
            }
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
        }
        return caseList;
    }
    /*******************************************************
    *author : rajan Sajani
    *Description : to prevent SlA date from going to back date
    *JIRA : SDT-32837
    *date : 9/19/2024
    ********************************************************/
    
    public static Datetime getSLACorrectedDate(Case c){
       
       DateTime newSLADatetime;
       DateTime locDate;
       Integer Difference; 
                        locDate = getservicedatetime(c.SLA_Service_Date_Time__c,c); 
                        Date date1;
                        Date date2;
                        if(c.Service_Date__c!= null && c.SLA_Service_Date_Time__c != null){
                            date1 = c.Service_Date__c;
                            date2 = c.SLA_Service_Date_Time__c.dateGMT();
                        }
                        if(date2 != null && date1 != null){
                             difference = date2.daysBetween(date1);
                        }
                        if(c.Service_Date__c>locdate && difference != null && difference == 0){
                            newSLADatetime = c.SLA_Service_Date_Time__c.addDays(1);
                        }
        return newSLADatetime;
    }
    
    /*******************************************************************************************************
    * @description Method to get the Service Date time based on the location
    * @param localdate of type Datetime
    * @param c of type Case
    * @return List<Case>
    * @example
    */
    public static Datetime getservicedatetime(Datetime localdate,Case c){
        Timezone tz;
        System.debug('casewithLocation---'+casewithLocation);
        if(string.isNotBlank(c.Location__c) && casewithLocation != null && casewithLocation.containsKey(c.Location__c) && String.isNotBlank(casewithLocation.get(c.Location__c).tz__Timezone_SFDC__c)){
            tz = Timezone.getTimeZone(casewithLocation.get(c.Location__c).tz__Timezone_SFDC__c);
            localdate = localdate.addSeconds((tz.getOffset(localdate)/1000));        
        }
        return localdate;
    }

    /*******************************************************************************************************
    * @description Method to get the Service Date time based on the location
    * @param serviceDate of type Datetime
    * @param currentSLADate of type Datetime
    * @param c of type Case
    * @return List<Case>
    * @example
    */
    //Commenting this method as SDT-38039 will move to SP-04.24
    public static Datetime getIntakeSLADatetime(Datetime serviceDate, Datetime currentSLADate, Case c){
        Datetime updatedSLA;        
        if(string.isNotBlank(c.Location__c) && casewithLocation != null && casewithLocation.containsKey(c.Location__c) 
        && String.isNotBlank(casewithLocation.get(c.Location__c).tz__Timezone_SFDC__c))
        {
            //we need to add time zone offset hour to 21 hour
            // Time targetTime = Time.newInstance(currentSLADate.hour(), currentSLADate.minute(), currentSLADate.second(), currentSLADate.millisecond());
            Date targetDate = Date.newInstance(serviceDate.year(), serviceDate.month(), serviceDate.day());
            Time targetTime = Time.newInstance(21, 0, 0, 0);
            // system.debug('@@@~Before Merge : ' + targetDate + '' + targetTime);
            updatedSLA =  getadditionalDate(targetDate, targetTime, casewithLocation.get(c.Location__c).tz__Timezone_SFDC__c);
            updatedSLA = updatedSLA.addDays(1);
        }
        return updatedSLA;
    }
    
    /*******************************************************************************************************
    * @description Method to get the Service Date time based on the location
    * @param localdate of type Datetime
    * @param c of type Case
    * @return DateTime
    * @example
    */
    private static Datetime getadditionalDate(Date targetDate,Time targetTime,String Totimezone){
        TimeZone targetTimezone;
        Integer offsetSeconds;
        DateTime additionalDate;
        
        targetTimezone = TimeZone.getTimeZone(Totimezone);
        offsetSeconds = targetTimezone.getOffset(targetDate) / 1000;
        additionalDate = Datetime.newInstanceGmt(targetDate, targetTime).addSeconds(-offsetSeconds);
        return additionalDate;
    }

    /*******************************************************************************************************
    * @description Method to identify Entitlement for the respective case. 
    * @param Before_After of type String
    * @param SlaStartDate of type DateTime
    * @param service of type CaseTriggerHelper.SERVICETYPE
    * @param ca of type Case
    * @return DateTime
    * @example
    */
     private static DateTime getdate(String Before_After, DateTime SlaStartDate,CaseTriggerHelper.SERVICETYPE service,Case ca){
        DateTime additionalDate;
        Date targetDate;
        Time targetTime;
        
        try{
            switch on service {
                when DAYS {
                    If(Before_After != null && (Constant_Util.BEFORE).equalsIgnorecase(Before_After)){
                        targetDate = Date.newInstance((SlaStartDate).yearGmt(), (SlaStartDate).monthGmt(), (SlaStartDate).dayGmt());
                        targetTime = Time.newInstance(5, 0, 0, 0);
                        additionalDate = getadditionalDate(targetDate,targetTime,casewithLocation.get(ca.Location__c).tz__Timezone_SFDC__c);
                    }else {
                        targetDate = Date.newInstance((SlaStartDate).yearGmt(), (SlaStartDate).monthGmt(), ((SlaStartDate).dayGmt())+1);
                        targetTime = Time.newInstance(5, 0, 0, 0);
                        additionalDate = getadditionalDate(targetDate,targetTime,casewithLocation.get(ca.Location__c).tz__Timezone_SFDC__c);
                    }
                }
                when HOURS {
                    additionalDate = System.now();
                }
            }
        }
        catch(exception e){
            system.debug('Exception:::::'+e.getStackTraceString());
        }
        return additionalDate;
    }
    
    
    /*******************************************************************************************************
                                                                       
                        
                           
  
    * @description Method to to fetch SLA based on Asset and Project after that Schedule Type,Container and Location.
    * @param caseMap of type map<string,case>
    * @return map<string,Entitlement>
    * @example
    */
    public static map<string,Entitlement> fetchSLA(map<string,case> caseMap){
        string entitlementKey = null;
        map<string,Entitlement> caseEntitlementMap = new map<string,Entitlement>();
        map<String,List<Entitlement>> entitlementmap = new map<String,List<Entitlement>>();
        List<Entitlement> entlst = null;
        //modified query as part of SDT-42452
        for(Entitlement e :[Select id,Gold_Standard__c,AccountId,Call_On__c,AssetId,Project_Code__c,Before_After__c,Call_Time__c, Container__c,Service_Guarantee_Category__c,Service_Guarantee_Category_Value__c,Location__c,Service__c,Schedule_Type__c, Status__c,StartDate,EndDate,SLA_Ins__c, Override_Business_Hours__c, recordtype.name, Contractual__c from Entitlement where AccountId IN :parentAccountIdset and Status__c =: Constant_Util.APPROVED and service__c IN :serviceset LIMIT 49999]){ 
            entitlementKey = e.AccountId + Constant_Util.STAR + e.Service__c;
            if(entitlementmap.isEmpty() || !entitlementmap.containskey(entitlementKey)){
                entlst = new List<Entitlement>();
                entitlementmap.put(entitlementKey,entlst);
            }
            If(!entitlementmap.isEmpty() && entitlementmap.containskey(entitlementKey)){
                entitlementmap.get(entitlementKey).add(e);
            }
        }
        
        entitlementKey = null;
        List<String> entitlelst = new List<String>();
        Entitlement actualent = null;
        Map<String,String> keylst;
        Map<String,Entitlement> enlst;
        for(String caseKey : caseMap.keySet()){
            entitlelst = caseKey.split(Constant_Util.STAR);
            keylst = new Map<String,String>();
            enlst = new Map<String,Entitlement>();
            actualent = new Entitlement();
            if(!entitlementmap.IsEmpty() && entitlementmap.containskey(entitlelst[0] + Constant_Util.STAR + entitlelst[3])){
                for(Entitlement en : entitlementmap.get(entitlelst[0] + Constant_Util.STAR + entitlelst[3])){
                    if(string.isNotBlank(en.AssetId)){
                        if(!keylst.containskey(Constant_Util.ASSET)&& caseMap.get(caseKey).AssetId != null && (en.AssetId).equals(caseMap.get(caseKey).AssetId)
                           && ((String.isNotBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)))){
                               actualent = getactualSLA(en,caseMap.get(casekey));
                               if(actualent != null) {
                                   keylst.put(Constant_Util.ASSET,casekey);
                                   enlst.put(caseKey + Constant_Util.ASSET,en);
                               }
                           }
                    }
                    else{
                        if(!keylst.containskey(Constant_Util.PROJECT_LOCATION)&& caseMap.get(caseKey).AssetId != null && (!string.isBlank(en.Project_Code__c) && !string.isBlank(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c))
                           && (en.Project_Code__c).equals(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c) && (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))){
                               actualent = getactualSLA(en,caseMap.get(casekey));
                               if(actualent != null) {
                                   keylst.put(Constant_Util.PROJECT_LOCATION,casekey);
                                   enlst.put(caseKey+Constant_Util.PROJECT_LOCATION,en);
                               }
                           }else if(!keylst.containskey(Constant_Util.FLOW_PROJECT)&& caseMap.get(caseKey).AssetId != null && (!string.isBlank(en.Project_Code__c) && !string.isBlank(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c))
                                    && (en.Project_Code__c).equals(casewithContainer.get(caseMap.get(caseKey).AssetId).Project_Code__c) && string.IsBlank(en.Location__c)){
                                        actualent = getactualSLA(en,caseMap.get(casekey));
                                        if(actualent != null) {
                                            keylst.put(Constant_Util.FLOW_PROJECT,casekey);
                                            enlst.put(caseKey+Constant_Util.FLOW_PROJECT,en);
                                        }
                                    }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                             && (!String.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))
                                             && (!String.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) ){
                                                 actualent = getactualSLA(en,caseMap.get(casekey));
                                                 if(actualent != null) {
                                                     keylst.put(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION,casekey);
                                                     enlst.put(caseKey+Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION,en);
                                                 }
                                             }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_LOCATION)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                      && (!String.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) 
                                                      && String.IsBlank(en.Container__c)){
                                                          actualent = getactualSLA(en,caseMap.get(casekey));
                                                          if(actualent != null) {
                                                              keylst.put(Constant_Util.SCHEDULETYPE_LOCATION,casekey);
                                                              enlst.put(caseKey+Constant_Util.SCHEDULETYPE_LOCATION,en);
                                                          }
                                                      }else if(!keylst.containskey(Constant_Util.CONTAINER_LOCATION)&& (!string.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) 
                                                               && (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) && String.IsBlank(en.Schedule_Type__c)){
                                                                   actualent = getactualSLA(en,caseMap.get(casekey));
                                                                   if(actualent != null) {
                                                                       keylst.put(Constant_Util.CONTAINER_LOCATION,casekey);
                                                                       enlst.put(caseKey+ Constant_Util.CONTAINER_LOCATION,en);
                                                                   }
                                                               }else if(!keylst.containskey(Constant_Util.LOCATION)&&(!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c)) 
                                                                        && string.IsBlank(en.Container__c) && String.IsBlank(en.Schedule_Type__c)){
                                                                            actualent = getactualSLA(en,caseMap.get(casekey));
                                                                            if(actualent != null) {
                                                                                keylst.put(Constant_Util.LOCATION,casekey);
                                                                                enlst.put(caseKey+Constant_Util.LOCATION,en);
                                                                            }
                                                                        }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                                                 && String.IsBlank(en.Location__c) && (!String.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) ){
                                                                                     actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                     if(actualent != null) {
                                                                                         keylst.put(Constant_Util.SCHEDULETYPE_CONTAINER,casekey);
                                                                                         enlst.put(caseKey+Constant_Util.SCHEDULETYPE_CONTAINER,en);
                                                                                     }
                                                                                 }else if(!keylst.containskey(Constant_Util.SCHEDULETYPE)&& (!string.isBlank(entitlelst[4]) && (entitlelst[4]).equals(en.Schedule_Type__c)) 
                                                                                          && string.IsBlank(en.Location__c)&& String.IsBlank(en.Container__c)){
                                                                                              actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                              if(actualent != null) {
                                                                                                  keylst.put(Constant_Util.SCHEDULETYPE,casekey);
                                                                                                  enlst.put(caseKey+Constant_Util.SCHEDULETYPE,en);
                                                                                              }
                                                                                          }else if(!keylst.containskey(Constant_Util.CONTAINER)&& (!string.IsBlank(entitlelst[2]) && (entitlelst[2]).equals(en.Container__c)) 
                                                                                                   && string.Isblank(en.Location__c) && String.IsBlank(en.Schedule_Type__c)){
                                                                                                       actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                                       if(actualent != null) {
                                                                                                           keylst.put(Constant_Util.CONTAINER,casekey);
                                                                                                           enlst.put(caseKey+ Constant_Util.CONTAINER,en);
                                                                                                       }
                                                                                                   }else if(!keylst.containskey(Constant_Util.ACCOUNT) && (String.IsBlank(en.Schedule_Type__c) || (!String.IsBlank(en.Schedule_Type__c) && (en.Schedule_Type__c).equals(entitlelst[4]))) 
                                                                                                            && (String.IsBlank(en.Container__c) || (!String.IsBlank(en.Container__c) && (en.Container__c).equals(entitlelst[2])))
                                                                                                            && (en.Location__c == null || (!string.IsBlank(entitlelst[1]) && (entitlelst[1]).equals(en.Location__c))) ){
                                                                                                                system.debug('entered account and service++++');
                                                                                                                actualent = getactualSLA(en,caseMap.get(casekey));
                                                                                                                system.debug('actualent++++'+actualent);
                                                                                                                if(actualent != null) {
                                                                                                                    keylst.put(Constant_Util.ACCOUNT,casekey); 
                                                                                                                    enlst.put(caseKey+Constant_Util.ACCOUNT,en);
                                                                                                                }
                                                                                                            }
                        else{
                            //novacop fix
                        }
                    }
                }
            }
            
            if(keylst!=null && enlst!=null){
                String c = null;
                String Key =null;
                if(keylst.containskey(Constant_Util.ASSET)){
                    c = keylst.get(Constant_Util.ASSET);
                    key = c+Constant_Util.ASSET;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.PROJECT_LOCATION)){
                    c = keylst.get(Constant_Util.PROJECT_LOCATION);
                    key = c+Constant_Util.PROJECT_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.FLOW_PROJECT)){
                    c = keylst.get(Constant_Util.FLOW_PROJECT);
                    key = c+Constant_Util.FLOW_PROJECT;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION);
                    key = c+Constant_Util.SCHEDULETYPE_CONTAINER_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE_LOCATION)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE_LOCATION);
                    key = c+Constant_Util.SCHEDULETYPE_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.CONTAINER_LOCATION)){
                    c = keylst.get(Constant_Util.CONTAINER_LOCATION);
                    key = c+Constant_Util.CONTAINER_LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.LOCATION)){
                    c = keylst.get(Constant_Util.LOCATION);
                    key = c+Constant_Util.LOCATION;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE_CONTAINER)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE_CONTAINER);
                    key = c+Constant_Util.SCHEDULETYPE_CONTAINER;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.SCHEDULETYPE)){
                    c = keylst.get(Constant_Util.SCHEDULETYPE);
                    key = c+Constant_Util.SCHEDULETYPE;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.CONTAINER)){
                    c = keylst.get(Constant_Util.CONTAINER);
                    key = c+Constant_Util.CONTAINER;
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
                if(keylst.containskey(Constant_Util.ACCOUNT)){
                    c = keylst.get(Constant_Util.ACCOUNT);
                    key = c+Constant_Util.ACCOUNT;
                    actualent = getactualSLA(enlst.get(key),caseMap.get(c));
                    caseEntitlementMap.put(c,enlst.get(key));
                    continue;
                }
            }
        }
        return caseEntitlementMap;
    }

    /*******************************************************************************************************
    * @description Method to identify the particular Entitlement based on the field Call_Time__c for the respective case. 
    * @param et of type Entitlement
    * @param ca of type Case
    * @return Entitlement
    * @example
    */
    private static Entitlement getactualSLA(Entitlement et, Case ca){
        Entitlement e = null;
        Integer ct = 0;
        Integer callmin = 0;
        Integer difference = 0;
        Time callTime = Time.newInstance(0, 0, 0, 0);
        if(ca !=null && String.IsNotBlank(et.Call_On__c)  && et.Call_On__c.contains(ca.SlaStartDate.format(Constant_Util.DAY_FORMAT)) && et.StartDate <= ca.SlaStartDate 
           && (et.EndDate == null || et.EndDate >= ca.SlaStartDate)){
               If(et.Call_Time__c!= null){
                   callmin = Integer.valueOf((et.Call_Time__c).split(Constant_Util.COLON)[1]);
                   ct = Integer.valueOf((et.Call_Time__c).split(Constant_Util.COLON)[0]);
                   if(callmin > 0){
                       ct += 1;
                   }
                   
                   callTime = Time.newInstance(ct, 0, 0, 0);
                   Integer callhour = callTime.hour();
                   if(callhour == 0){
                       callhour += 24;
                   }
                   difference  = (ca.SlaStartDate).hourGmt() - callhour;
                   integer mins = (ca.SlaStartDate).minuteGmt();
                   if( (difference > 0 || (difference == 0 && mins > 0)) && (Constant_Util.AFTER).equals(et.Before_After__c)){
                       e = et;
                   }else if(difference < 0 && (Constant_Util.BEFORE).equals(et.Before_After__c)){
                       e = et;
                   }
               } else {
                   e = et;
               }
           }
        return e;
    }
    
    /*******************************************************************************************************
    * @description Utility Method to add business hours using business id 
    * @param en of type Entitlement
    * @param caseCtDate of type DateTime
    * @param businessId of type Id
    * @return Datetime
    * @example
    */
    Private Static Datetime getSLADateTime(Entitlement en ,DateTime caseCtDate, Id businessId){
        Integer extradays = 0;
        Long milliSec = 0;
        DateTime businesshours;
        extradays = Integer.valueof(en.Service_Guarantee_Category_Value__c);
        if(en.Service_Guarantee_Category__c.equalsIgnorecase(string.valueof(SERVICETYPE.DAYS))){
            milliSec = getmillisecs(SERVICETYPE.DAYS,extradays,caseCtDate);      
            //adding as part of SDC-6171/SDT-42452
            if(en.recordtype.name.equalsIgnoreCase('SLA') && en.Override_Business_Hours__c) {
                try{
                    millisec = (extradays * 86400000) - 28800000;
                }
                catch(exception e){
                    system.debug('Exception:::::'+e.getStackTraceString());
                    millisec = 0;
                }
                Integer secs = (Integer) milliSec/1000;
                businesshours = caseCtDate.addSeconds(secs);
            }
            else {
                businesshours = getBusinessHours(businessId, caseCtDate, millisec);
            }
            
        } else {
            businesshours = caseCtDate.addHours(extradays);
        }
        Return businesshours;
    }
    
    /*******************************************************************************************************
    * @description Utility Method to add business hours using business id 
    * @param before_after of type String
    * @param service of type String
    * @param caseCtDate of type DateTime
    * @param businessId of type Id
    * @return Datetime
    * @example
    */
    Private Static DateTime getIndustryStandards(String before_after,String service,DateTime caseCtDate,Id businessId){
        Integer extradays = 0;
        Integer differenceIndays = 0;
        Long milliSec = 0;
        
        if(before_after!=null && (Constant_Util.BEFORE).equals(before_after)){
            extradays = INTEGER.valueOf(industyStandardSLAMap.get(service).Before__c);
        }
        else{
            extradays = INTEGER.valueOf(industyStandardSLAMap.get(service).After__c);
        }
        milliSec = getmillisecs(SERVICETYPE.DAYS,extradays,caseCtDate); 
        return getBusinessHours(businessId, caseCtDate, millisec);
    }
    
    /*******************************************************************************************************
    * @description Utility Method to add business hours using business id 
    * @param businessHoursId of type Id
    * @param startDate of type DateTime
    * @param intervalMilliseconds of type Long
    * @return Datetime
    * @example
    */
    Private Static DateTime getBusinessHours(Id businessHoursId,DateTime startDate, Long intervalMilliseconds){
        return BusinessHours.addGmt(businessHoursId,startDate,intervalMilliseconds);
    }
    
    /*******************************************************************************************************
    * @description Utility Method to add business hours using business id 
    * @param before_after of type String
    * @param service of type String
    * @param caseCtDate of type DateTime
    * @param businessId of type Id
    * @return Datetime
    * @example
    */
    private Static Long getmillisecs(CaseTriggerHelper.SERVICETYPE service,Integer extraDays,DateTime cDate){
        Long millisec = 0;
        try{
            switch on service {
                when DAYS {
                    millisec = extradays * 57600000;
                }
            }
        }
        catch(exception e){
            system.debug('Exception:::::'+e.getStackTraceString());
            millisec = 0;
        }
        return millisec;
    }
    
    
   
    
  
    /*
* This method is used to insert Approval Logs for the respective Case
* @owner : DineshKumar S
* @param : map<Id,case> newCasemap
*/
    Public static void insertApprovalLog(map<Id,case> newCasemap,map<Id,case> oldCasemap){
        
        try{
            List<Approval_Log__c> approvalLoglst = new List<Approval_Log__c>();
            Set<Id> approvalLogIds = new Set<Id>();
            if(approvalLogmap != null && approvalLogmap.size() > 0){
                for(Id caseId : approvalLogmap.keySet()){
                    if(string.isNotBlank(newCasemap.get(caseId).Approval_Status__c) && !oldCasemap.isEmpty() && oldCasemap.containskey(caseId) && string.isBlank(oldCasemap.get(caseId).Approval_Status__c) ){
                        approvalLoglst.addAll(approvalLogmap.get(caseId));  
                    }
                }
            }
            if(!approvalLoglst.isEmpty() && approvalLoglst.size() > 0){
                Database.SaveResult[] appLst = Database.insert(approvalLoglst, true);
                for(Database.SaveResult appr : appLst){
                    if (appr.isSuccess()) {
                        approvalLogIds.add(appr.getId());
                    }
                }
                //RecurrsiveTriggerHandler.isSkipcaseTrigger = true;
                createApprovalTask(approvalLogIds,newCasemap);              
            }
            //RecurrsiveTriggerHandler.isSkipcaseTrigger = true;
        TriggerDispatcher.skipTriggerExecutionMap.put(Case.sobjectType.getDescribe().getName(),true);
        }catch(Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
            system.debug('DmlException caught: ' + e.getMessage());
        }
    }
    /*
* This method is used to insert Approval Task for the respective Case
* @owner : Priyadharshini R
* @param : Set<Id> approvalLogIds,map<Id,case> newCasemap
*/
    private static void createApprovalTask(Set<Id> approvalLogIds,map<Id,case> newCasemap){
        List<Task> approvTask = new List<Task>();
        String taskOwner= null ;
        Map<String,Id> approverMap = new Map<String,Id>();

        Id businessHoursId = (Generic_Values__mdt.getInstance(Constant_Util.BUSINESSHOURSID) != null)
                                ? Generic_Values__mdt.getInstance(Constant_Util.BUSINESSHOURSID).Id__c : null;

        Id groupUser = (Generic_Values__mdt.getInstance(Constant_Util.GROUPUSER) != null) 
                         ? Generic_Values__mdt.getInstance(Constant_Util.GROUPUSER).Id__c : null;
          
        //Added as part of SDT-9745 to fetch Genesys user id for obtain service approval task assignment
        Id genesysUserId = (Generic_Values__mdt.getInstance(Constant_Util.GENESYS_USER) != null) 
                            ? Generic_Values__mdt.getInstance(Constant_Util.GENESYS_USER).Id__c : null;
      
        string referenceNumber = null;
        string caseNumber = null;
         
        List<Service_Approver__c> serviceApprovalListToUpdate = new List<Service_Approver__c>();
        List<Approval_Log__c> apList = new List <Approval_Log__c>([select Id,CaseId__c,Required_Approver__c,Required_Approver_Contact__c,Required_Approver_Contact__r.Account_Title__r.Name,Approver_Type__c,BusinessRuleId__c,BusinessRuleId__r.Is_Auto_Email__c,BusinessRuleId__r.Multiple_Mandatory_Approvers__c,Required_Approver_Title__c,Required_Approver_Contact__r.Preferred_Method__c,Phone__c,Email__c,Required_Approver_Contact__r.Email,
                                     Required_Approver_Contact__r.Phone,Required_Approver_Contact__r.MobilePhone,Is_Required__c,ServiceApprovers__c,CaseId__r.Is_Multiple_Asset__c from Approval_Log__c where Id IN : approvalLogIds and Status__c =: Constant_Util.APPROVAL_REQUESTED Order by CaseId__r.CaseNumber ASC LIMIT 49999 ]);
    
        Set<ID> brSet = new Set<ID>();
       
        if(apList!= null && !apList.isEmpty()){
          for(Approval_Log__c albr : apList)
          {
           brSet.add(albr.BusinessRuleId__c);   
          }
        }
          system.debug('$$$$ BR Set'+brSet);
        
        Map<Id,List<Service_Approver__c>> mapBrIdServiceApproverList = new Map<Id,List<Service_Approver__c>>();
        List<Service_Approver__c> saList = [Select Business_Rule__c,Active__c,Requester_Only__c,Approver_Type__c,Preferred_Method__c,Approver_Contact__c from Service_Approver__c where Business_Rule__c IN: brSet];
        List<Service_Approver__c> serviceApproverListToAdd = new List<Service_Approver__c>();
        system.debug('####Service Approvers List'+saList);
        
         for(Service_Approver__c sa : saList){
           if(String.isNotBlank(sa.Business_Rule__c)){
               System.debug('INIFFFF');
                if(mapBrIdServiceApproverList.containsKey(sa.Business_Rule__c)) {
                    System.debug('Map for AL'+mapBrIdServiceApproverList);
                    serviceApproverListToAdd = mapBrIdServiceApproverList.get(sa.Business_Rule__c);
                    serviceApproverListToAdd.add(sa);
                    system.debug('$$$$**** Service Approvers List'+serviceApproverListToAdd);
                    mapBrIdServiceApproverList.put(sa.Business_Rule__c,serviceApproverListToAdd); 
                    System.debug('@@@@@List of Service Approver'+serviceApproverListToAdd);
                    System.Debug('&&&&Map of Service Approver'+mapBrIdServiceApproverList);
                }                 
                else {
                    mapBrIdServiceApproverList.put(sa.Business_Rule__c, new List<Service_Approver__c> {sa});
                }
           }  
         }
        system.debug('$$$$(((( BR Map'+mapBrIdServiceApproverList);
        
        for(Id br : mapBrIdServiceApproverList.keySet()){
        List<Service_Approver__c> saaList = mapBrIdServiceApproverList.get(br);
             System.debug('@@@@@@@@ Service Approver from MAP'+saaList);
        for(Service_Approver__c sa2 : saaList){ 
              System.debug('***************Service Approver'+sa2);
           if(mapBrIdServiceApproverList.containsKey(sa2.Business_Rule__c) 
              && sa2.Active__c 
              && !(sa2.Requester_Only__c) 
              &&(
   (Constant_Util.CONTACT_RECORD_TYPE.equalsIgnoreCase(sa2.Approver_Type__c) 
    && Constant_Util.ORIGIN_EMAIL.equalsIgnoreCase(sa2.Preferred_Method__c) 
    && String.isNotBlank(sa2.Approver_Contact__c))
||  Constant_Util.ORIGIN_EMAIL.equalsIgnoreCase(sa2.Approver_Type__c) 
||  Constant_Util.USER_RECORDTYPE.equalsIgnoreCase(sa2.Approver_Type__c)
                )
              ) { 
                  serviceApprovalListToUpdate.add(sa2);   
             }
         }
          system.debug('$$$$() Service Approvers'+serviceApprovalListToUpdate);
        }    
        Task appTask;
        try{
            for(Approval_Log__c al : apList){
                                         appTask = new Task();
                                         appTask.ActivityDate = System.today();
                                         appTask.Approval_Log__c = al.Id;
                                         appTask.Approver_Type__c = al.Approver_Type__c;
                                         appTask.Attempt__c = 1;
                                         appTask.Business_Rule__c = al.BusinessRuleId__c;
                                         appTask.ContactEmail__c = String.isNotBlank(al.Email__c) ? al.Email__c : al.Required_Approver_Contact__r.Email;
                                         appTask.Contact_Number__c = String.isNotBlank(al.Phone__c) ? al.Phone__c : ((Constant_Util.PHONE).equals(al.Required_Approver_Contact__r.Preferred_Method__c) ? al.Required_Approver_Contact__r.Phone : al.Required_Approver_Contact__r.MobilePhone);
                                         appTask.Contact_Title__c = String.isNotBlank(al.Required_Approver_Contact__c) ? al.Required_Approver_Contact__r.Account_Title__r.Name : (String.isNotBlank(al.Required_Approver_Title__c) && String.isNotBlank(al.Approver_Type__c) && al.Approver_Type__c.contains(Constant_Util.FLOW_TITLE) ? al.Required_Approver_Title__c : null);
                                         appTask.Department_Name__c = String.isNotBlank(al.Approver_Type__c) && al.Approver_Type__c.contains(Constant_Util.DEPARTMENT_RECORDTYPE) ? al.Required_Approver_Title__c : null;
                                         appTask.Due_Date_Time__c = BusinessHours.add(businessHoursId,system.now(),4*3600000);
                                         appTask.If_Required__c = al.Is_Required__c;
                                         
                                         appTask.Is_Primary__c = newCasemap.get(al.CaseId__c) != null && (newCasemap.get(al.CaseId__c).CaseNumber).equals(newCasemap.get(al.CaseId__c).Reference_Number__c) ? true : false;
                                         appTask.Last_Agent_ID__c = null;
                                         appTask.Preferred_Contact_Method__c = String.isNotBlank(al.Approver_Type__c) ? (al.Approver_Type__c.contains(Constant_Util.CONTACT_RECORD_TYPE) ? al.Required_Approver_Contact__r.Preferred_Method__c : (al.Approver_Type__c.contains(Constant_Util.ORIGIN_EMAIL) ? Constant_Util.ORIGIN_EMAIL : null)): null; 
                                         
                                         if(String.isNotBlank(al.BusinessRuleId__c) && (al.BusinessRuleId__r.Is_Auto_Email__c) && (serviceApprovalListToUpdate != null) && !serviceApprovalListToUpdate.isEmpty() && !al.CaseId__r.Is_Multiple_Asset__c){
                                          System.debug('@@@@ Business Rule'+al.BusinessRuleId__c);
                                          System.debug('$$$$ IS Auto Email'+al.BusinessRuleId__r.Is_Auto_Email__c);
                                          System.debug('^^^^ Service Approvers List'+serviceApprovalListToUpdate);
                                              
                                           
                                              appTask.OwnerId = groupUser;
                                              //Added this line - 21227 & 17976, and 21921, 21946, 22394
                                              //Updated by Soham Datta as part of BRE-11
                                              appTask.Outcome__c = al.BusinessRuleId__r.Multiple_Mandatory_Approvers__c && 
                                                                    appTask.Preferred_Contact_Method__c != null && 
                                                                    appTask.Preferred_Contact_Method__c != Constant_Util.ORIGIN_EMAIL ? null : Constant_Util.OUTCOME_ON_TASK; 
                                         //  appTask.Status = Constant_Util.COMPLETED;
                                         //  appTask.Outcome__c = Constant_Util.NO_OR_PENDING_RESPONSE;
                                         }
                                         else{
                                                //SDT-31851
                                            if(newCasemap.get(al.CaseId__c) != null && newCasemap.get(al.CaseId__c).Last_Agent_Id_ForTaskAssignment__c != null){
                                            User userRec =[Select Id,Profile.Name,User_categorization_code__c From User where Id=:newCasemap.get(al.CaseId__c).Last_Agent_Id_ForTaskAssignment__c];
                                            if(userRec.User_categorization_code__c != null){
                                            CSR_User_Data_Setup__mdt userDataSetup = CSR_User_Data_Setup__mdt.getInstance(userRec.User_categorization_code__c);
                                            if(userDataSetup != null && userDataSetup.Is_Genesys_User__c){
                                                appTask.OwnerId =genesysUserId; //SDT-38453
                                                taskOwner =genesysUserId;//SDT-38453

                                            }else{
                                            appTask.OwnerId = newCasemap.get(al.CaseId__c).Last_Agent_Id_ForTaskAssignment__c;
                                            }

                                            }
                                        }else{ //SDT-38460
                                            appTask.OwnerId= genesysUserId;
                                            taskOwner =genesysUserId;
                                        }
                                       // appTask.OwnerId = String.isNotBlank(al.Required_Approver__c) ? al.Required_Approver__c : (newCasemap.get(al.CaseId__c) != null && newCasemap.get(al.CaseId__c).Last_Agent_Id_ForTaskAssignment__c != null ? newCasemap.get(al.CaseId__c).Last_Agent_Id_ForTaskAssignment__c : genesysUserId);                                       
                                       //taskOwner  =String.isNotBlank(al.Required_Approver__c) ? al.Required_Approver__c : (newCasemap.get(al.CaseId__c) != null && newCasemap.get(al.CaseId__c).Last_Agent_Id_ForTaskAssignment__c != null ? newCasemap.get(al.CaseId__c).Last_Agent_Id_ForTaskAssignment__c : genesysUserId);  
                                         }
  
                                         //appTask.Preferred_Contact_Method__c = String.isNotBlank(al.Approver_Type__c) ? (al.Approver_Type__c.contains(Constant_Util.CONTACT_RECORD_TYPE) ? al.Required_Approver_Contact__r.Preferred_Method__c : (al.Approver_Type__c.contains(Constant_Util.ORIGIN_EMAIL) ? Constant_Util.ORIGIN_EMAIL : null)): null;
                                         appTask.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
                                         appTask.RecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.APPROVALS).getRecordTypeId();
                                         appTask.Subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
                                         appTask.WhatId = al.CaseId__c;
                                         appTask.WhoId = String.isNotBlank(al.Required_Approver_Contact__c) ? al.Required_Approver_Contact__c : null;
                Case relCase= [Select Origin from Case where id =:al.CaseId__c LIMIT 1];
                if(String.isNotBlank(al.Approver_Type__c) && (al.Approver_Type__c.startsWith('Origin-'))){
                    //appTask.Description += 'Scenaio -1 The submitted request is from an unapproved origin and cannot proceed without the correct approval. Please inform the customer to resubmit their request through the approved portal (e.g., Service Channel, Office Trax, Monitor) to ensure proper processing.';
                    if(relCase.Origin == 'E-Business'){
                        appTask.Description = 'Since the intake method is E-business - contact the customer back';
                    }
                    else {
                        appTask.Description = 'Case coming from -'+ relCase.Origin;
                    }
                }
                /*else {
appTask.Description = '----- contain other RT';
}*/
		    
                
                                         
                                         //Commented for 22394
                                         // Started - 21227 & 17976, and 21921, 21946
                                         //if(String.isNotBlank(al.BusinessRuleId__c) && (al.BusinessRuleId__r.Is_Auto_Email__c)){
                                          //  appTask.Outcome__c = Constant_Util.OUTCOME_ON_TASK;
                                        // }
                                         // Ended

                                         if(approverMap.isEmpty() || !approverMap.containskey(al.ServiceApprovers__c) || approverMap.get(al.ServiceApprovers__c).equals(al.CaseId__c)){
                                             approverMap.put(al.ServiceApprovers__c,al.CaseId__c);
                                             appTask.Is_Primary__c = true;
                                             appTask.Is_Genesys_User__c = String.isNotBlank(taskOwner) && String.isNotBlank(String.valueof(genesysUserId))&& (taskOwner.equals(String.valueof(genesysUserId))) ? true : false;
                                             appTask.MultiCaseId__c = al.CaseId__c;
                                         }else {
                                             System.debug('in last else');
                                             appTask.OwnerId = groupUser;
                                             appTask.Is_Genesys_User__c = false;
                                             appTask.MultiCaseId__c = approverMap.get(al.ServiceApprovers__c);
                                             referenceNumber = newCasemap != null && newCasemap.containskey(al.CaseId__c)? newCasemap.get(al.CaseId__c).Reference_Number__c : null;
                                             caseNumber = newCasemap != null && newCasemap.containskey(approverMap.get(al.ServiceApprovers__c)) ? newCasemap.get(approverMap.get(al.ServiceApprovers__c)).CaseNumber : null; 
                                             appTask.Description = Constant_Util.TASK_COMMENTS1+referenceNumber+Constant_Util.TASK_COMMENTS2+caseNumber;
                                         }
										 appTask.isSystemGenerated__c = true;
                                         approvTask.add(appTask);
                                     }
            if(approvTask != null && approvTask.size() > 0){
                Database.SaveResult[] svRes = Database.insert(approvTask,false);
                UTIL_LoggingService.logDmlResults(svRes, null, approvTask, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
            }
        }catch(Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
            system.debug('DmlException caught: ' + e.getMessage());
        }
        
    }
        //SDT-48000
    /*
* This method is used to insert Approval Task for the Origin Approvers
* @owner : Harsha K. Warjurkar
* @param : Id appLogId,List<Business_Rule__c> bRuleList, Map<Id, Case> newCasemap
*/
    public static void createApprovalTaskForOriginApprovers(Id appLogId,List<Business_Rule__c> bRuleList, Map<Id, Case> newCasemap) {
    List<Task> approvTask = new List<Task>();
    Id groupUser = (Generic_Values__mdt.getInstance(Constant_Util.GROUPUSER) != null) 
                    ? Generic_Values__mdt.getInstance(Constant_Util.GROUPUSER).Id__c : null;
    
    Id genesysUserId = (Generic_Values__mdt.getInstance(Constant_Util.GENESYS_USER) != null)
                        ? Generic_Values__mdt.getInstance(Constant_Util.GENESYS_USER).Id__c : null;

    Id businessHoursId = (Generic_Values__mdt.getInstance(Constant_Util.BUSINESSHOURSID) != null)
                          ? Generic_Values__mdt.getInstance(Constant_Util.BUSINESSHOURSID).Id__c : null;
    Id lastAgentId;
    CSR_User_Data_Setup__mdt userDataSetup;
    for (Case c : newCasemap.values()) {
        Task appTask = new Task();
        appTask.ActivityDate = System.today();
        appTask.WhatId = c.Id; 
        appTask.Subject = Constant_Util.OBTAIN_SERVICE_APPROVAL;
        appTask.RecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK)
                                .getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.APPROVALS).getRecordTypeId();
        appTask.Due_Date_Time__c = BusinessHours.add(businessHoursId, System.now(), 4 * 3600000);
        //appTask.Due_Date_Time__c = DateTime.newInstance(c.service_Date__c, Time.newInstance(0, 0, 0, 0));
        appTask.Approval_Log__c = appLogId;
        if(newCasemap.get(c.Id) != null && newCasemap.get(c.Id).Last_Agent_Id_ForTaskAssignment__c != null){
            User userRec =[Select Id,Profile.Name,User_categorization_code__c From User where Id=:newCasemap.get(c.Id).Last_Agent_Id_ForTaskAssignment__c LIMIT 1];
            lastAgentId = userRec.Id;
            appTask.Last_Agent_ID__c = userRec.Id;
            if(userRec.User_categorization_code__c != null){
                userDataSetup = CSR_User_Data_Setup__mdt.getInstance(userRec.User_categorization_code__c);
                if(userDataSetup != null && userDataSetup.Is_Genesys_User__c){
                    appTask.OwnerId =genesysUserId;
                }
                else{
                    appTask.OwnerId = newCasemap.get(c.Id).Last_Agent_Id_ForTaskAssignment__c;
                }
            }
        }
        else{ 
                appTask.OwnerId= genesysUserId;              
            }
             appTask.Is_Genesys_User__c = String.isNotBlank(appTask.OwnerId) && String.isNotBlank(String.valueof(genesysUserId))&& (appTask.OwnerId.equals(String.valueof(genesysUserId))) ? true : false;
        appTask.Attempt__c = 1;
        appTask.Process__c = Constant_Util.OBTAIN_SERVICE_APPROVAL;
        appTask.Is_Primary__c = c.CaseNumber == c.Reference_Number__c;
        if(isSingleOriginApprover){
            if(CaseOrigin == 'E-Business'){
                appTask.Description = 'Since the intake method is E-business - contact the customer back';
            }
            else {
                appTask.Description = 'Case coming from -'+ CaseOrigin;
            }
        }
        if(!bRuleList.isEmpty()){
            appTask.Business_Rule__c = bRuleList[0].Id;
        }
        approvTask.add(appTask);
    }
    if (approvTask.size() > 0) {
        Database.SaveResult[] svRes = Database.insert(approvTask, false);
      /*  if (userDataSetup != null) {
            if(userDataSetup.Is_Genesys_User__c){
                CreatePendingInformationTask.createGeneysRouting(approvTask.get(0), userDataSetup.GR_Service_Flag__c, userDataSetup.SFDC_Task_User__c);
                approvTask.get(0).OwnerId =genesysUserId;
            }
            else{
                approvTask.get(0).OwnerId = lastAgentId;
            }
            update approvTask.get(0);
        } */
    } 
}
    
    /*******************************************************************************************************
    * @description Method to get business rules related to Cases
    * @param newcasemap of type Map<Id,Case>
    * @param oldCasemap of type Map<Id,Case>
    * @param subtypeSet of type Set<String>
    * @param startDate of type Map<string,Date>
    * @param endDate of type Map<string,Date>
    * @return void
    * @example
    */
    Public static void getbusinessRules(map<Id,Case> newcasemap,map<Id,case> oldCasemap,set<String> subtypeSet,Map<string,Date> startDate,Map<string,Date> endDate){
        map<Id,Case> newbrcasemap = new map<Id,Case>();
        set<Id> recordTypeIdSet = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> ServiceTypeSet = new Set<string>();
        Boolean isAutoApproved = true;
        DateTime slaDateTime = null;
        string woKey = null;
        Set<String> workOrderStatus = new Set<String>{Constant_Util.INPROGRESS,Constant_Util.STATUS_NEW,Constant_Util.COMPLETED,Constant_Util.CLOSED};
        List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = new List<BusinessRuleHelper.BusinessRulewrapper>();
        map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
        map<Id,Business_Rule__c> approvalmap = new map<Id,Business_Rule__c>();
        map<Id,Boolean> autoApprovalmap = new map<Id,Boolean>();
        set<Id> accountIdset = new set<Id>();
        List<Business_Rule__c> bRuleList = new List<Business_Rule__c>();
        Map<Id,List<Service_Approver__c>> bruleServiceMap = new Map<Id,List<Service_Approver__c>>();
        Boolean isOrigin = true;
        String originName;
		Boolean byPassApproval = true;
        
        integer woNum = 1;
        //SDT-48000
        String CaseContactEmail;
        //
        if(!startDate.IsEmpty() && startDate.size() > 0 && !endDate.IsEmpty() && endDate.size() > 0 && !subtypeSet.IsEmpty() && subtypeSet.size() > 0){
            for(WorkOrder wo : [Select Id,AssetId,Customer_Location__c,Case_Subtype__c,Service_Date__c from WorkOrder where AssetId IN:casewithContainer.keySet() and Customer_Location__c IN:casewithLocation.keySet() and StatusCategory IN:workOrderStatus and Case_Subtype__c IN :subtypeSet and Is_Bypass__c = false LIMIT 49999]){
                woKey = String.valueOf(wo.AssetId) + String.valueOf(wo.Customer_Location__c) + String.valueOf(wo.Case_Subtype__c);
                if(!startDate.IsEmpty() && startDate.containsKey(woKey) && !endDate.IsEmpty() && endDate.containsKey(woKey) && wo.Service_Date__c >=  startDate.get(woKey) && wo.Service_Date__c <=  endDate.get(woKey)){
                    if(caseWorkOrderCount.IsEmpty() || (!caseWorkOrderCount.IsEmpty() && !caseWorkOrderCount.containsKey(woKey))){
                        caseWorkOrderCount.put(woKey,1);
                    }else if(!caseWorkOrderCount.IsEmpty() && caseWorkOrderCount.containsKey(woKey)){
                        woNum = caseWorkOrderCount.get(woKey) + 1;
                        caseWorkOrderCount.put(woKey,woNum);
                    }
                }
            }
        }
		
		Id userId = userinfo.getUserId();
	    User userDetails =[SELECT Id,title,  Profile.Name, UserRole.Name FROM User where Id=:userId ];
        System.debug('newcasemap.keySet()>>>'+newcasemap.keySet());  
        List<EmailMessage> lstEmailMsg = [select id,FromAddress from EmailMessage where ParentId IN: newcasemap.keySet() limit 1];
        system.debug('Profile Name:' + userDetails.Profile.Name);
        system.debug('Role Name:' + userDetails.UserRole.Name);
        
        if(userDetails.Profile.Name == 'Customer Account Team' || userDetails.UserRole.Name == 'Program Manager' || userDetails.UserRole.Name == 'National Account Manager' || userDetails.title == 'Corporate Services Specialist'){
                bypassApp = 'trueee';
				bypassCAT = 'trueee';
            }
        
        else if(userDetails.Profile.Name != null){  //SDT-25577 
            List<Contact> con = new List<Contact>();
            con = [select id,Internal_User_ID__c from contact where id =: newcasemap.values()[0].ContactId limit 1];
            if(!con.isEmpty() && null != con[0].Internal_User_ID__c){
                User conDetails = [Select Id,title,  Profile.Name, UserRole.Name from user where id =: con[0].Internal_User_ID__c];
            if(conDetails.Profile.Name == 'Customer Account Team' || conDetails.UserRole.Name == 'Program Manager' || conDetails.UserRole.Name == 'National Account Manager' || conDetails.title == 'Corporate Services Specialist'){
                bypassApp = 'trueee';
				bypassCSR = 'trueee';
            }
            }
            
        } 
       else if(!lstEmailMsg.isEmpty()){
             List<User> userDetails2 =[SELECT Id,title,  Profile.Name, UserRole.Name FROM User where email =: lstEmailMsg[0].FromAddress AND IsActive = true];
             for(User u : userDetails2){
            if(newcasemap.values()[0].Origin == 'Email' && (u.Profile.Name == 'Customer Account Team' || u.UserRole.Name == 'Program Manager' || u.UserRole.Name == 'National Account Manager' || u.title == 'Corporate Services Specialist')){
                bypassApp = 'trueee';
				bypassEmail = 'trueee';
            }
        }
        }
		
        for(Case c : newcasemap.values()){
            CaseOrigin = c.Origin;
            //SDT-48000
            CaseContactEmail = c.ContactEmail;
            //
            If(c.SLA_Service_Date_Time__c != null){
                slaDateTime = DateTime.newInstanceGmt(c.SLA_Service_Date_Time__c.dateGmt(), c.SLA_Service_Date_Time__c.TimeGmt());
                slaDateTime =  getservicedatetime(slaDateTime,c);
            }
            if(!oldCasemap.isEmpty() && oldCasemap.containskey(c.Id) && !(c.Status).equals(oldCasemap.get(c.Id).Status) && (string.isBlank(c.Case_Sub_Status__c)) && !String.ISBlank(c.Case_Sub_type__c) && Constant_Util.PENDING.equals(c.Status)){// 
                newbrcasemap.put(c.Id,c);
                accountIdset.add(c.Client__c); 
                requestTypeSet.add(c.Case_Type__c);
                ServiceTypeSet.add(c.Case_Sub_type__c);
            }
           else if((!oldCasemap.isEmpty() && oldCasemap.containskey(c.Id) && !string.isBlank(c.Case_Sub_Status__c) && Constant_Util.PENDING_VENDOR_INFORMATION.equals(c.Case_Sub_Status__c) && !(c.Case_Sub_Status__c).equals(oldCasemap.get(c.Id).Case_Sub_Status__c)) && (c.Service_Date__c >= slaDateTime.dateGmt() || c.Service_Date__c < Date.Today())){
                // SDT-16989 : This will handle the logic for Create Multiple Cases per Service Date.Start 
                if(c.Case_Type__c==Constant_Util.PICKUP_CSTYPE && c.CaseNumber!=c.Reference_Number__c && c.Is_Multiple_Case_Per_ServiceDT__c && !c.Is_Multiple_Asset__c && checkParentWithIn15Min(c.Id) )
                {
                    c.Status = Constant_Util.PENDING;
                    c.Case_Sub_Status__c = Constant_Util.PENDING_VENDOR_INFORMATION;
                    c.Approval_Status__c = Constant_Util.APPROVED; 
                    c.Bypass_WO_Duplicate__c=true;
                }
                //SDT-16989 : This will handle the logic for Create Multiple Cases per Service Date.End 
                else{ 
                    c.Status = Constant_Util.OPEN;
                    c.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
                    c.Approval_Status__c = Constant_Util.APPROVED;
                }
            }
            else{
                //NovaCop Fix
            }
        }
        system.debug('Case%%%'+newbrcasemap);
        try{
            Id approvalRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
            Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            Id originRecTypeId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByName().get('Origin').getRecordTypeId();
            recordTypeIdSet.add(approvalRecTypeId);
            recordTypeIdSet.add(reqInfoRecTypeId);
	    Map<Id, Case> newCaseBRMap = new Map<Id, Case>();
            if(newbrcasemap != null && newbrcasemap.size() > 0){	
		for (Case c : newbrcasemap.values()) {
		    if (c.Status != 'Open' && c.Status != 'Closed' && c.Source_System__c == 'Salesforce') newCaseBRMap.put(c.Id, c);
		}
                businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(newCaseBRMap.values(),recordTypeIdSet,accountIdset,requestTypeSet,ServiceTypeSet,casewithContainer,casewithLocation);
                
                system.debug('%%%%'+businessRulewrapperlst);
                if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
                    for(BusinessRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                        if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                            reqInfomap.put(brw.caseId,brw.bRule);
                        }else if( approvalRecTypeId.equals(brw.bRule.RecordTypeId)){
                            approvalmap.put(brw.caseId,brw.bRule);
                            bRuleList.add(brw.bRule);
                        }
                    }
                    for(Service_Approver__c orgSA:[Select id,Fuzzy_Search__c,RecordTypeId,Origin__c,Business_Rule__c,
                                                   Name,Account__c,Account_Department__c,Account_Team_Member__c,
                                                   Account_Title__c,Active__c,Approver__c,Approver_Contact__c,
                                                   Approver_Type__c,Department__c,Approver_Email__c,Email__c,
                                                   External_Approver_Email__c,External_Approver_Name__c,
                                                   External_Approver_Phone_Number__c,is_Auto_Email__c,Location__c,
                                                   Approver_Phone__c,Preferred_Method__c,Requester_Only__c,
                                                   Request_Type_Service__c,ServiceApprover__c,SortBy__c,Title__c,User__c
                                                   from Service_Approver__c where Business_Rule__c IN:bRuleList AND Active__c = true])
                    {
                        if(CaseOrigin != null)
                        {
                            if(originRecTypeId.equals(orgSA.RecordTypeId) && CaseOrigin.equalsIgnoreCase(orgSA.Origin__c))
                            {
                                originName = orgSA.Origin__c;
                                isOrigin = false;
                            }
                        }
						
						 if(bypassApp != null){
                            byPassApproval = false;
                        }
						
                         if(bruleServiceMap.containsKey(orgSA.Business_Rule__c) && !originRecTypeId.equals(orgSA.RecordTypeId))
                         {
                             List<Service_Approver__c> serviceList = bruleServiceMap.get(orgSA.Business_Rule__c);
                             serviceList.add(orgSA);
                             bruleServiceMap.put(orgSA.Business_Rule__c, serviceList);
                         }
                        else if(!bruleServiceMap.containsKey(orgSA.Business_Rule__c) && !originRecTypeId.equals(orgSA.RecordTypeId))
                        {
                            bruleServiceMap.put(orgSA.Business_Rule__c, new List<Service_Approver__c>{orgSA});
                        }
                    }
                    //SDT-48000
                    if (!bRuleList.isEmpty()) {
                        List<Service_Approver__c> originApprovers = [Select Business_Rule__c,Approver_Email__c,Active__c,Requester_Only__c,Approver_Type__c,Origin__c,Preferred_Method__c,Approver_Contact__c from Service_Approver__c where Business_Rule__c =:bRuleList[0].id 
                                                            AND Active__c = true 
                                                            AND Requester_Only__c = true];
                        List<Service_Approver__c> otherApprovers = [Select Business_Rule__c,Approver_Email__c,Active__c,Requester_Only__c,Approver_Type__c,Origin__c,Preferred_Method__c,Approver_Contact__c from Service_Approver__c where Business_Rule__c =:bRuleList[0].id 
                                                            AND Active__c = true];                                    
                        List<Service_Approver__c> saList;  
                        Boolean hasOriginApprover = false;
                        Boolean hasOtherApprover = false; 
                        system.debug('Case Contact: '+CaseContactEmail); 
                        if (!otherApprovers.isEmpty()) {
                            Boolean hasActiveOriginApprover = false;
                            for (Service_Approver__c sa : otherApprovers) {
                                if (sa.Approver_Type__c == Constant_Util.ORIGIN && sa.Active__c == true && sa.Requester_Only__c == true) {
                                    hasActiveOriginApprover = true;
                                }
                                else if (sa.Approver_Type__c != Constant_Util.ORIGIN && sa.Active__c == true && sa.Requester_Only__c == false) {
                                    hasOtherApprover = true;
                                }
                            }
                            if (hasActiveOriginApprover && hasOtherApprover) {
                                hasOtherApprover = true;
                                System.debug('Inside other approvers');
                            }
                        }                                  
                        if(!originApprovers.isEmpty() && !hasOtherApprover){
                            if(originApprovers.size()==1 && originApprovers[0].Approver_Type__c == Constant_Util.ORIGIN && originApprovers[0].Requester_Only__c == true && CaseOrigin != originApprovers[0].Origin__c){
                                originActiveApprover = true;
                                isSingleOriginApprover = true;
                                isAutoApproved = false; // Do not run below isAutoApproved conditions
                                byPassApproval = false; // Do not run the below if condition
                            }else {
                                for (Service_Approver__c sa : originApprovers) {
                                    if (sa.Approver_Type__c == Constant_Util.ORIGIN && sa.Active__c == true && sa.Requester_Only__c == true && CaseOrigin != sa.Origin__c) {
                                        hasOriginApprover = true;
                                    }
                                } 
                            }
                        }
                        if (hasOriginApprover) {     
                            for (Service_Approver__c sa : originApprovers) {
                                if (sa.Approver_Type__c != Constant_Util.ORIGIN && sa.Approver_Email__c != CaseContactEmail) {
                                    originActiveApprover = true;
                                    isAutoApproved = false; // Do not run below isAutoApproved conditions
                                    byPassApproval = false; // Do not run the below if condition
                                }
                            }
                        }
                    }
                     // End 
                    BusinessRuleHelper.bruleSerMap = bruleServiceMap;
                    if(approvalmap != null && approvalmap.Size() > 0 && isOrigin && byPassApproval){
                        BusinessRuleHelper.wrapperResult brwrapper = BusinessRuleHelper.getapprovallog(approvalmap,newbrcasemap.values(),caseWorkOrderCount);
                        approvalLogmap = brwrapper != null && brwrapper.apprLogMap!=null ? brwrapper.apprLogMap: null;
                        autoApprovalmap = brwrapper != null && brwrapper.autoApprovemap!=null ? brwrapper.autoApprovemap: null;
                        system.debug('%%%%'+brwrapper);
                    }
                }
                Business_Rule__c brule = null;
                for(case ca : newcasemap.values()){
                    If(ca.SLA_Service_Date_Time__c != null){
                        slaDateTime = DateTime.newInstanceGmt(ca.SLA_Service_Date_Time__c.dateGmt(), ca.SLA_Service_Date_Time__c.TimeGmt());
                        slaDateTime =  getservicedatetime(slaDateTime,ca);
                    }
                    if(newbrcasemap != null && newbrcasemap.size() > 0 && newbrcasemap.containsKey(ca.Id)){
                        brule = reqInfomap != null && reqInfomap.size() > 0 && reqInfomap.containskey(ca.Id) ? reqInfomap.get(ca.Id) : null;
                        if(brule != null && (brule.Required_Information__c.contains(Constant_Util.PO_NUMBER) || brule.Required_Information__c.contains(Constant_Util.PROFILE_NUMBER)  || brule.Required_Information__c.contains(Constant_Util.COMPANY_CATEGORY) )){
                            ca.PurchaseOrder_Required__c = true;                                      
                        }
                        isAutoApproved = autoApprovalmap != null && autoApprovalmap.size() > 0  ? autoApprovalmap.containsKey(ca.Id) ? autoApprovalmap.get(ca.Id) : true : true;
                        System.debug('autoApprovalmap@@@@'+autoApprovalmap);
                        system.debug('isAutoApproved@@@@'+isAutoApproved);
                        system.debug('approvalLogmap@@@@'+approvalLogmap);
                        //SDT-48000
                        if(originActiveApprover){
                            isAutoApproved = false; // Do not run the below if
                            byPassApproval = true; // To stop creation of approval log in byPassApproval if
                        }
                        //
                        If(isAutoApproved && ca.Service_Date__c != null && ca.SLA_Service_Date_Time__c != null 
                           && ca.Service_Date__c < slaDateTime.dateGmt() && ca.Service_Date__c >= Date.Today() 
                           && ca.Case_Type__c != Constant_Util.NEW_SERVICE){ // Added backdated case logic for SDT-7300 
                           if(ca.Availability_Confirmed__c){
                                ca.Status = Constant_Util.OPEN;
                                ca.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
                                ca.Approval_Status__c = Constant_Util.APPROVED;
                            }
                            else{
                                ca.Status = Constant_Util.PENDING;
                                ca.Case_Sub_Status__c = Constant_Util.PENDING_VENDOR_INFORMATION;
                                ca.Approval_Status__c = Constant_Util.APPROVED;
                            }
                        }else if(isAutoApproved){
                          // SDT-16989 : This will handle the logic for Create Multiple Cases per Service Date.Start
                          if(ca.Case_Type__c==Constant_Util.PICKUP_CSTYPE && ca.CaseNumber!=ca.Reference_Number__c && ca.Is_Multiple_Case_Per_ServiceDT__c  && !ca.Is_Multiple_Asset__c && checkParentWithIn15Min(ca.Id))
                           {
                                ca.Status = Constant_Util.PENDING;
                                ca.Case_Sub_Status__c = Constant_Util.PENDING_VENDOR_INFORMATION;
                                ca.Approval_Status__c = Constant_Util.APPROVED; 
                                ca.Bypass_WO_Duplicate__c=true;
                           }
                            else if(ca.Case_Type__c== Constant_Util.NEW_SERVICE && ca.IsOpportunity_Created__c == true)
                            {
                                ca.Status = Constant_Util.PENDING;
                                ca.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_PROCURMENT;
                            }
                            //SDT-16989 : This will handle the logic for Create Multiple Cases per Service Date.End 
                            else{
                            ca.Status = Constant_Util.OPEN;
                            ca.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
                            ca.Approval_Status__c = Constant_Util.APPROVED;
                           }
                        }
                        else {
                            ca.Status = Constant_Util.PENDING;
                            ca.Case_Sub_Status__c = Constant_Util.PENDING_REQUEST_APPROVAL;
                            ca.Approval_Status__c = Constant_Util.APPROVAL_REQUIRED;
                        }
                    }
                    if(!isOrigin)
                    {
                        Approval_Log__c appLog = new Approval_Log__c();
                        appLog.Status__c = Constant_Util.APPROVED;
                        appLog.CaseId__c = ca.id;
                        appLog.BusinessRuleId__c = approvalmap.get(ca.id).id;
                        appLog.Approval_Description__c = Constant_Util.APPROVAL_MESSAGE;
                        appLog.Decision_Date_Time__c = System.now();
                        appLog.Approval_Comments__c = Constant_Util.APPROVAL_COMMENT;
                        appLog.Actual_Approver_Origin__c = originName;
                        appLogList.add(appLog);
                    } 
						   if(!byPassApproval)
                    {
                        Approval_Log__c appLog = new Approval_Log__c();
                        appLog.Status__c = Constant_Util.APPROVED;
                        appLog.CaseId__c = ca.id;
                        appLog.BusinessRuleId__c = approvalmap.get(ca.id).id;
                        appLog.Approval_Description__c = Constant_Util.APPROVAL_MESSAGE;
                        appLog.Decision_Date_Time__c = System.now();
                        appLog.Approval_Comments__c = Constant_Util.APPROVAL_COMMENT;
                        appLog.Actual_Approver_Origin__c = originName;
                        if(bypassCSR != null || bypassEmail != null){
                           appLog.Actual_Approver_Contact__c = ca.ContactId;
                           appLog.Required_Approver_Contact__c = ca.ContactId; 
                        }
                         if(bypassCAT != null){
                           appLog.Required_Approver__c = userinfo.getUserId();
                           appLog.Actual_Approver__c = userinfo.getUserId(); 
                        }
                        
                        appLogList.add(appLog);
                    }
                    //SDT-48000
                    if(originActiveApprover){
                        List<Approval_Log__c> apprLogList = new List<Approval_Log__c>();
                        Approval_Log__c appLog = new Approval_Log__c();
                        appLog.Status__c = Constant_Util.APPROVAL_REQUESTED;
                        appLog.CaseId__c = ca.id;
                        appLog.BusinessRuleId__c = approvalmap.get(ca.id).id;
                        appLog.Approval_Description__c = Constant_Util.ORIGIN_APPROVAL ;
                        appLog.Decision_Date_Time__c = System.now();
                        appLog.Actual_Approver_Origin__c = originName;
                        apprLogList.add(appLog);
                        Database.SaveResult[] appLst = Database.insert(apprLogList, true);
                        if(appLst != null && appLog.Id != null){
                            createApprovalTaskForOriginApprovers(appLog.Id,bRuleList,newCasemap);
                        }
                    }
                    //
                }                
            }
            
        }catch (Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
            system.debug('DmlException caught: ' + e.getMessage());
        }
        
    }
  /*  // ES - SDT-4513 - Tasks - Close All Tasks when Case Closed by Integration
    public static void closeTasks( Map<Id,Case> casemap){
        Set<Id> caseIds = new Set<Id>();
        try{ //added for novasuite fix - Priya
            for(case caseValue : casemap.values())
            {
                if(caseValue.Status == 'Closed') //&& caseValue.Source_System__c == 'Acorn')
                {
                    caseIds.add(caseValue.Id);
                }
            }
            
            list<Task> taskList  = new List<Task>();
            if(!caseIds.isEmpty() && caseIds.size() > 0 )
            {   
                set<string> processSet = new set<string>();
                processSet.add(Constant_Util.OBTAIN_SERVICE_APPROVAL);
                processSet.add(Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL);
                processSet.add(Constant_Util.VALIDATE_EMAIL_COMMENTS);
                processSet.add(Constant_Util.NOTIFY_CUSTOMER_OF_DECLINE);
                list<Task> taskDataList =  [Select Id, Status From Task where WhatId in :caseIds and Process__c not In :processSet LIMIT 49999];
                for(Task  taskData : taskDataList) 
                {
                    if(taskData.Status == 'Open'){
                        taskData.Status = 'Completed';
                        taskData.Description = Constant_Util.TASK_COMMENTS;
                        taskData.IsAcornCase__c = true;
                        taskList.add(taskData);
                    }
                }
                if(taskList.size() > 0){
                    update taskList;
                }
            }
            
        }catch (Exception e){
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
            system.debug('DmlException caught: ' + e.getMessage());
        }
    }
    */
   
    /*******************************************************************************************************
    * @description Method to Close all previous tasks
    * @param casemap of type Map<Id,Case>
    * @param caseOldmap of type Map<Id,Case>
    * @return void
    * @example
    */
    public static void closeOldTasks(Map<Id,Case> casemap, Map<Id,Case> caseOldmap){        
        Set<Id> caseIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        List<Task> taskToCloseList = new List<Task>();
        if(casemap != null && !casemap.isEmpty()){  
            List<String> processToExcludeLst = System.Label.Processes_to_Exclude.split(Constant_Util.COMMA);
            for(Task thisTask: [SELECT Id, Status, Process__c, WhatId, Description, RecordType.DeveloperName FROM Task WHERE Status =: Constant_Util.OPEN AND WhatId IN : casemap.keySet()]) {
                if(!Constant_Util.NOTIFY_CUSTOMER_OF_DECLINE.equals(thisTask.Process__c) && 
                        caseMap.get(thisTask.WhatId).status == Constant_Util.CLOSED){
                    thisTask.status = Constant_Util.COMPLETED;
                    thisTask.Description = Constant_Util.TASK_COMMENTS;
                } else if(thisTask.RecordType.DeveloperName != Constant_Util.QUICK_TASK && 
                        thisTask.RecordType.DeveloperName != Constant_Util.INTEGRATION_ERROR_TASK && 
                        thisTask.RecordType.DeveloperName != Constant_Util.EMAILTOCASERECORD && 
                        caseMap.get(thisTask.WhatId).status != Constant_Util.CLOSED &&
                        !processToExcludeLst.Contains(thisTask.Process__c)){
                            thisTask.status = Constant_Util.COMPLETED;
                            thisTask.Description = Constant_Util.TASK_COMMENTS;
                } 
                else{}
                taskToCloseList.add(thisTask);
            }            
            if(taskToCloseList!= null && !taskToCloseList.isEmpty()) {
               // Added this line SDT-22017
                if(system.isFuture() || system.isBatch()){
                    Database.SaveResult[] svRes = Database.update(taskToCloseList,false);
             	    UTIL_LoggingService.logDmlResults(svRes, null, taskToCloseList, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
                }else{
                    closeOldTasks(JSON.serialize(taskToCloseList));
                }
            }
        }
    }
    
    /* Started SDT-22017 added this method */
    @future
    public static void closeOldTasks(String strTask){
        List<Task> taskToCloseList = (List<Task>)JSON.deserialize(strTask, List<Task>.class);
        Database.SaveResult[] svRes = Database.update(taskToCloseList,false);
        UTIL_LoggingService.logDmlResults(svRes, null, taskToCloseList, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
    
    } 
    /* Ended */
    

    /*******************************************************************************************************
    * @description Method - SDT-21970 Associated quotes to case moved to Decline status (Quote Status should not Approved)..
    * @param newMap of type Map<Id,Case>
    * @return void
    * @example
    */
    
    public static void declineRelatedQuote(Map<Id,Case> closedCaseMap){  
        system.debug('closedCaseMap--->'+ closedCaseMap);
        Set<Id> caseIds = new Set<Id>();
        List<SBQQ__Quote__c> quotesTobeDeclined = new List<SBQQ__Quote__c>();
        set<String> caseNumberSet = new set<String>();
        if(closedCaseMap != null && !closedCaseMap.isEmpty()){ 
            for (Case caseDetail : closedCaseMap.values())
            {
               caseNumberSet.add(caseDetail.CaseNumber);
            }
            for (SBQQ__Quote__c quoteDetail : [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Case_Number__c IN : caseNumberSet])
            {
                // Changes for Story #23803- added 'Cancelled' check
                if (quoteDetail.SBQQ__Status__c != 'Approved' && quoteDetail.SBQQ__Status__c != 'Cancelled' && quoteDetail.SBQQ__Status__c != 'Declined'){
                    quoteDetail.Cancellation_Reason__c = 'This quote was canceled because the associated case was closed.';
                    quoteDetail.SBQQ__Status__c = 'Cancelled';
                    quotesTobeDeclined.add(quoteDetail);
                }
            }
            if(quotesTobeDeclined != null){
                Database.SaveResult[] svRes = Database.update(quotesTobeDeclined,false);
            }
        }
     }
	
    /*******************************************************************************************************
    * @description Method to capture update on Parent Case.
    * @param newMap of type Map<Id,Case>
    * @return void
    * @example
    */
    public static void logRelatedCases(Map<Id,Case> newMap){
        Map<Id,Case> filteredMap = new Map<ID,Case>();
        for(Case record : newMap.values()){
            if(record.parentId != null){
                filteredMap.put(record.Id,record);
            }   
        }
        if(filteredMap.size() > 0){
            CreateCaseHistory.createHistoryRecordOnRecordCreate(filteredMap);
        }
        
    }
    
    /*******************************************************************************************************
    * @description Method to capture update on Case Status and Case Sub Status in Case History
    * @param newMap of type Map<Id,Case>
    * @param oldMap of type Map<Id,Case>
    * @return void
    * @example
    */                                                                                                          
    public static void logStatusUpdates(Map<Id,Case> newMap,Map<Id,Case> oldMap){
        Map<Id,Case> filteredNewMap = new Map<ID,Case>();
        Map<Id,Case> filteredOldMap = new Map<ID,Case>();
        for(Case cse : newMap.values()){
            if(cse.Status != oldMap.get(cse.id).Status || cse.Case_Sub_Status__c != oldMap.get(cse.id).Case_Sub_Status__c){
                filteredNewMap.put(cse.Id,cse);
                filteredOldMap.put(cse.Id,oldMap.get(cse.id));
            }
        }
        if(filteredNewMap.size() > 0 && filteredOldMap.size() > 0){
            CreateCaseHistory.createHistoryRecord(filteredNewMap, filteredOldMap);
        }
        
    }
    
    /*******************************************************************************************************
    * @description Method to update Last_Activity_Date__c field of Contact and Sorting Location Contact based on Last_Activity_Date__c date.
    * @param contactIdSet of type Set<id>
    * @return void
    * @example
    */
     public static void lastContactActivityDate(Set<Id> contactIdSet){
        
        List<Contact> contactListToUpdate=new List<Contact>();
        try
        {
            if(!contactIdSet.isEmpty()){
                for(Contact con : [Select id, Last_Activity_Date__c, lastName, Contact_Status__c from Contact Where Id in:contactIdSet LIMIT 49999]){
                    con.Last_Activity_Date__c=Datetime.now();
                    if(con.Contact_Status__c != Constant_Util.ACTIVE){
                        con.Contact_Status__c = Constant_Util.ACTIVE;
                    }
                    contactListToUpdate.add(con);
                }
            }
            
            if(contactListToUpdate != null){
                Database.SaveResult[] svRes = Database.update(contactListToUpdate,false);
                UTIL_LoggingService.logDmlResults(svRes, null, contactListToUpdate, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
            }
        }
        catch(Exception e)
        {
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
    
    /*******************************************************************************************************
    * @description Method to update case subtype, Last Modified Agent, service date based on the case asset linked to it.
    * @param caseList of type List<Case>
    * @param oldCasemap of type Map<Id,case>
    * @param caseWithContainerMap of type Map<id,Asset>
    * @param caseWithLocationMap of type Map<id,Account>
    * @param isInsert of type Boolean
    * @return List<Case>
    * @example
    */
    Public static List<Case> updateCaseDetails(List <Case> caseList,Map<id,Case> oldCaseMap,Map<id,Asset> caseWithContainerMap, Map<id,Account> caseWithLocationMap,Boolean isInsert ){
        Map<id,case> caseUpdateMap = new Map<id,case>();
		Set<Id> parentIDsetAfterFilterRolOf =  new Set<Id>();//added for 18374
        List<case> returncaselst = new List<case>();
        try{
			Boolean  skipLastAgentIdupdate = false;
			Boolean  skipslaupdatestd = true ; 
            Map<Id,Boolean> detailMap = new Map<Id,Boolean>();
            List<case> processServiceDateList = new List<case>();
            Map<id,case> returnmap = new Map<id,case>(); 
            set<String> subtypeSet = new set<String>();
            Map<string,Date> startDate = new Map<string,Date>();
            Map<string,Date> endDate = new Map<string,Date>();
            Id pickupRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.PICKUP).getRecordTypeId();            
            //string corporateServiceQueueId = [select id from group where DeveloperName = 'CorporateServicesQueue' limit 1].Id;
            asset asst = new asset();
            
            //user loggedInUser= [select id,firstname,lastname,username,email,Profile.Name from User where id=:UserInfo.getUserId() Limit 1];
            String loggedInUserProfileName = null; 
            if(!Test.isRunningTest()){
	    //soql 101 issue fix - sdt-40083
                //loggedInUserProfileName = [SELECT Id, Name FROM Profile WHERE Id=:UserInfo.getProfileId()].Name;
                Id UserProfileId = UserInfo.getProfileId();
                loggedInUserProfileName = SystemObjectSelector.getLoggedInUserProfile(UserProfileId );
            }else {
                loggedInUserProfileName = Constant_Util.CUSTOMER_SERVICE;
            }
            
            System.debug('$$$$caseList'+caseList);
            if(!caseList.isEmpty() && caseList != null){
			
			   /*SDT-18374*/   If(!caseWithContainerMap.isEmpty()){
                   parentIDsetAfterFilterRolOf = checkLogicToupDateCaseSubtype(caseWithContainerMap);
                    
                }  /*SDT-18374*/
                
                for(Case cse : caseList){                                    
                   // if(!string.isBlank(cse.AssetId) && string.isBlank(cse.Case_sub_type__c)){
                    if((!string.isBlank(cse.AssetId) && string.isBlank(cse.Case_sub_type__c)) || (oldCaseMap.size() > 0 && oldCaseMap.get(cse.id).AssetId != cse.AssetId && !string.isBlank(cse.Case_sub_type__c))){
                        if(cse.RecordTypeId == pickupRcdType && string.isblank(cse.Case_Type__c)){
                            cse.Case_Type__c = CONSTANT_UTIL.PICKUP_CSTYPE;
                        }                    
                        asst = (caseWithContainerMap!=null && caseWithContainerMap.containsKey(cse.assetId))?caseWithContainerMap.get(cse.assetId): new asset();
                        /*As a part of SDT-24201 Added Case Sub-type condition in IF Condition below*/
                        if(cse.Case_Type__c == Constant_Util.PICKUP_CSTYPE && cse.Case_Sub_Type__c != Constant_Util.EMPTY_AND_DONOT_RETURN)
                        {
                            if(asst.product2.family == Constant_Util.COMMERCIAL && asst.Occurrence_Type__c == Constant_Util.ON_CALL){
                                cse.Case_Sub_Type__c = Constant_Util.ON_CALL_PICK;
                            //SDT-42644 - Commented out for updating case subtype for Hand Pickups
                            //}else if(asst.product2.family == Constant_Util.COMMERCIAL && Constant_Util.HAND_PICKUP.equals(asst.product2.Equipment_Type__c) && asst.Duration__c.equals(Constant_Util.PERMANENT)){
                                //cse.Case_Sub_Type__c = '';
                            }else if(asst.product2.family == Constant_Util.COMMERCIAL && (asst.Occurrence_Type__c == Constant_Util.SCHEDULED || asst.Occurrence_Type__c == Constant_Util.SCHEDULED_ON_CALL)){
                                cse.Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;                        
                            }else if(asst.product2.family == Constant_Util.ROLLOFF && asst.product2.Equipment_Type__c != Constant_Util.Baler){
							
							
							 /* SDT-18374*/
                                if(!parentIDsetAfterFilterRolOf.isEmpty() && asst.Id !=NULL && parentIDsetAfterFilterRolOf.contains(asst.Id) && (asst.Occurrence_Type__c == Constant_Util.SCHEDULED)){
                                        cse.Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP; 
                                }else if(!parentIDsetAfterFilterRolOf.isEmpty() && asst.Id !=NULL && parentIDsetAfterFilterRolOf.contains(asst.Id) && (asst.Occurrence_Type__c == Constant_Util.ON_CALL)){
                                    cse.Case_Sub_Type__c = Constant_Util.ON_CALL_PICK;
                                }else{
                                    
                                  cse.Case_Sub_Type__c = Constant_Util.EMPTY_AND_RETURN;   
                                }
                                /* SDT-18374*/
								
                            }else if(Constant_Util.Baler.equals(asst.product2.Equipment_Type__c)){
                                cse.Case_Sub_Type__c = Constant_Util.Bales;
                            }else if(( asst.product2.family == Constant_Util.SERVICES && asst.Name.equals(Constant_Util.Bulk_Service_Type))){
                                cse.Case_Sub_Type__c = Constant_Util.Bulk_Service_Type;
                            }else if((asst.product2.family == Constant_Util.SERVICES  && asst.Name.equals(Constant_Util.Haul_Away_Service))){
                                cse.Case_Sub_Type__c = Constant_Util.Haul_Away_No_Equipment;
                            }
                            //changes related to SDT-42644 
                            //this condition updates the case subtype for Services Hand Pickups for extra pickup & On-call Pickup case.
                            else if (asst.product2.family == Constant_Util.SERVICES && asst.Name.contains(Constant_Util.HAND_PICKUP))
                            {
                                if (asst.Occurrence_Type__c == Constant_Util.ON_CALL)
                                {
                                    cse.Case_Sub_Type__c = Constant_Util.ON_CALL_PICK;
                                }
                                else if (asst.Occurrence_Type__c == Constant_Util.SCHEDULED || asst.Occurrence_Type__c == Constant_Util.SCHEDULED_ON_CALL)
                                {
                                    cse.Case_Sub_Type__c  = Constant_Util.EXTRA_PICKUP;  
                                }
                            } 
                            else{
                                cse.Case_Sub_Type__c = '';
                            }
                        }
                        else if(cse.Case_Type__c== Constant_Util.NEW_SERVICE && cse.IsOpportunity_Created__c == true)
                        {
                            cse.Status = Constant_Util.PENDING;
                            cse.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_PROCURMENT;
                        }
                        /*
                        else
                        {
                            cse.Case_Sub_Type__c = '';
                        }*/
                    }
                    if(Constant_Util.CUSTOMER_SERVICE.equalsIgnoreCase(loggedInUserProfileName) && 
                       ((cse.Last_Agent_ID__c != null && cse.Last_Agent_ID__c != UserInfo.getUserName().substringBefore(Constant_Util.AT_SYMBOL ))
                        || string.isBlank(cse.Last_Agent_ID__c ))
                      ){
                          if(!isInsert ){
                              skipLastAgentIdupdate = skipLastAgentIdupdate(cse ,oldCaseMap.get(cse.id),isInsert);
                          }
                          if(!skipLastAgentIdupdate && runCount <= 1){
                              cse.Last_Agent_ID__c = UserInfo.getUserName().substringBefore(Constant_Util.AT_SYMBOL );
                          }
                      }
                    System.debug('case subtype----'+cse.Case_Sub_Type__c);
                    
                    //onsite contact info in WO instruct
                    String contactInfo;

                    if(!string.isBlank(cse.Site_Contact__c) && !string.isBlank(cse.Site_Contact_Phone__c)){
                        contactInfo = Constant_Util.New_Line + Constant_Util.ONSITE_CONTACT_NAME 
                                        + cse.Site_Contact__c + Constant_Util.NEW_LINE 
                                        + CONSTANT_UTIL.ONSITE_CONTACT_PHONE + cse.Site_Contact_Phone__c 
                                        + Constant_Util.NEW_LINE;
                    }
                    if(!string.isBlank(cse.Site_Contact__c) && string.isBlank(cse.Site_Contact_Phone__c)){
                        contactInfo = Constant_Util.New_Line + Constant_Util.ONSITE_CONTACT_NAME 
                                        + cse.Site_Contact__c + Constant_Util.NEW_LINE;
                    }
                    if(string.isBlank(cse.Site_Contact__c) && !string.isBlank(cse.Site_Contact_Phone__c)){
                        contactInfo = Constant_Util.NEW_LINE + CONSTANT_UTIL.ONSITE_CONTACT_PHONE 
                                        + cse.Site_Contact_Phone__c + Constant_Util.NEW_LINE;
                    }
                    if(string.isBlank(cse.Site_Contact__c) && string.isBlank(cse.Site_Contact_Phone__c)){
                        contactInfo = '';
                    }
                    
                    if(!cse.Is_Clone__c && cse.Create_AM_and_PM_Pickups__c ){
                        cse.System_Gen_WO_Instructions__c = CONSTANT_UTIL.AM_CASE + CONSTANT_UTIL.NEW_LINE;
                        
                        if(cse.System_Gen_WO_Instructions__c!=null){
                            cse.Work_Order_Instructions__c = cse.System_Gen_WO_Instructions__c + contactInfo 
                                                            + Constant_Util.NEW_LINE;
                            
                            if(cse.User_Input_Work_Order_Instructions__c !=null){
                                cse.Work_Order_Instructions__c += cse.User_Input_Work_Order_Instructions__c;
                            }
                            
                        }
                    }
                    // for multidate cases
                    else if(cse.Is_Clone__c){
                         if(cse.System_Gen_WO_Instructions__c!=null){
                            cse.Work_Order_Instructions__c = cse.System_Gen_WO_Instructions__c + Constant_Util.NEW_LINE + contactInfo + Constant_Util.NEW_LINE;
                            if(cse.User_Input_Work_Order_Instructions__c !=null){
                                cse.Work_Order_Instructions__c += cse.User_Input_Work_Order_Instructions__c;
                            }
                        }
                        if(cse.System_Gen_WO_Instructions__c==null && cse.User_Input_Work_Order_Instructions__c != null){
                                cse.Work_Order_Instructions__c = cse.User_Input_Work_Order_Instructions__c + Constant_Util.NEW_LINE;
                            }
                    }
                    
                    //WO fix                                      
                    if(oldCaseMap != null && oldCaseMap.containskey(cse.id) && string.isBlank(oldCaseMap.get(cse.id).User_Input_Work_Order_Instructions__c) && string.isBlank(cse.User_Input_Work_Order_Instructions__c)){
                        //do nothing
                        if(!string.isBlank(cse.Site_Contact__c) || !string.isBlank(cse.Site_Contact_Phone__c)){
                            cse.Work_Order_Instructions__c = contactInfo;
                        }
                    }
                    else{
                        if(oldCaseMap != null && oldCaseMap.containskey(cse.id) && string.isBlank(oldCaseMap.get(cse.id).User_Input_Work_Order_Instructions__c)&& !string.isBlank(cse.User_Input_Work_Order_Instructions__c)){
                            if(!string.isBlank(cse.System_Gen_WO_Instructions__c)){
                                cse.Work_Order_Instructions__c = cse.System_Gen_WO_Instructions__c + Constant_Util.NEW_LINE + cse.User_Input_Work_Order_Instructions__c + contactInfo;
                            }else{
                                cse.Work_Order_Instructions__c = cse.User_Input_Work_Order_Instructions__c + contactInfo;
                            }
                        }else if(oldCaseMap != null && oldCaseMap.containskey(cse.id) && !cse.User_Input_Work_Order_Instructions__c.equals(oldCaseMap.get(cse.id).User_Input_Work_Order_Instructions__c)){
                            if(!string.isBlank(cse.System_Gen_WO_Instructions__c)){
                                cse.Work_Order_Instructions__c = cse.System_Gen_WO_Instructions__c + Constant_Util.NEW_LINE + cse.User_Input_Work_Order_Instructions__c + contactInfo;
                            }else{
                                cse.Work_Order_Instructions__c = cse.User_Input_Work_Order_Instructions__c + contactInfo;
                            }
                        }
                    }
                    If(String.isNotBlank(cse.Status) && !Constant_Util.CLOSED.equals(cse.Status) && (String.isNotBlank(cse.Case_type__c) && sla_calculation__c.getValues(cse.Case_type__c) != null  && sla_calculation__c.getValues(cse.Case_type__c).Enabled__c) 
                       && ((string.isNotBlank(cse.Location__c)  && String.isNotBlank(cse.Case_Sub_Type__c) && String.isNotBlank(cse.Status)  && Constant_Util.STATUS_New.equals(cse.Status) && String.isNotBlank(cse.Client__c) && string.isBlank(string.valueOf(cse.SlaStartDate))) 
                           || (oldCasemap !=null && !oldCasemap.IsEmpty() && ( (!string.isBlank(string.valueOf(cse.SlaStartDate)) && oldCasemap.get(cse.Id).SlaStartDate != cse.SlaStartDate && string.isBlank(cse.SLA_Override_Reason__c)) || (oldCasemap.get(cse.Id).Client__c != cse.Client__c) || (string.isNotBlank(cse.Location__c) && oldCasemap.get(cse.Id).Location__c != cse.Location__c)
                           ||(String.isNotBlank(cse.AssetId) && oldCasemap.get(cse.Id).AssetId != cse.AssetId) 
                           || (String.isNotBlank(cse.Case_Sub_Type__c) && !cse.Case_Sub_Type__c.equals(oldCasemap.get(cse.Id).Case_Sub_Type__c)) 
                           || (String.isNotBlank(cse.Case_Sub_Type__c) && cse.Case_Sub_Type__c.equals(oldCasemap.get(cse.Id).Case_Sub_Type__c) && !cse.Case_Type__c.equals(oldCasemap.get(cse.Id).Case_Type__c))
                           || (String.isNotBlank(cse.Case_Sub_Type__c) && cse.Case_Sub_Type__c.equals(oldCasemap.get(cse.Id).Case_Sub_Type__c) && cse.Case_Type__c.equals(oldCasemap.get(cse.Id).Case_Type__c) && (String.isNotBlank(cse.Case_Reason__c) && !cse.Case_Reason__c.equals(oldCasemap.get(cse.Id).Case_Reason__c))))))){
                              processServiceDateList.add(cse);
                    }
                    else {
                              returncaselst.add(cse);
                    }
					if(cse.Case_Type__c == 'Activate' || cse.Case_Type__c == 'Modify' || cse.Case_Type__c == 'Deactivate'){
                        skipslaupdatestd = false;
                    }
					
                }
                System.debug('processServiceDateList ===='+processServiceDateList );
                list<Case> updatedservicelst = new list<case>();
                if(!processServiceDateList.isEmpty() && processServiceDateList.size() > 0){
                    PopulateTeamNameandQueue(processServiceDateList);
                         if(skipslaupdatestd){
                         updatedservicelst = updateServiceDateAlwaysRun(processServiceDateList,oldCaseMap,caseWithContainerMap,caseWithLocationMap);

                    }
                }
                if(updatedservicelst != null && !updatedservicelst.isEmpty()){
                    returncaselst.addALL(updatedservicelst);
                }
                if(!returncaselst.isEmpty() && returncaselst.size() > 0){
                          if(skipslaupdatestd){
                         CaseTriggerHelper.serviceDatetoSLA(returncaselst,oldCaseMap);
                    }
                    Map<Id,Case> calculatebrRulemap = new Map<Id,case>();
                    string woKey = null;
                    for(Case c : returncaselst){
                        if(string.isNotBlank(c.Status) && oldCaseMap != null && oldCaseMap.containskey(c.Id) && (!c.Status.equals(oldCaseMap.get(c.Id).Status) || (string.isNotBlank(c.Case_Sub_Status__c) && !c.Case_Sub_Status__c.equals(oldCaseMap.get(c.Id).Case_Sub_Status__c))) && Constant_Util.PENDING.equals(c.Status) && !String.Isblank(c.Case_Sub_type__c)){
                            subtypeSet.add(c.Case_Sub_type__c);
                            calculatebrRulemap.put(c.Id,c);
                            if(c.Service_Date__c != null){
                                woKey = String.valueOf(c.AssetId) + String.valueOf(c.Location__c) + String.valueOf(c.Case_Sub_type__c);
                                startDate.put(woKey,(c.Service_Date__c).toStartOfMonth());
                                endDate.put(woKey,(c.Service_Date__c).addMonths(1).toStartofMonth().addDays(-1));
                            }
                        }
                    }
                    system.debug('####'+calculatebrRulemap);
                    if(!calculatebrRulemap.IsEmpty() && calculatebrRulemap.size() >0 ){
                        CaseTriggerHelper.getbusinessRules(calculatebrRulemap, oldCaseMap,subtypeSet,startDate,endDate);
                    }
               }
            }
            System.debug('returncaselst ---'+returncaselst );
            
            if(returncaselst != null && !returncaselst.isEmpty()){
                for(Case cs : returncaselst ){
                    Datetime createdDateGmt;
                    if(IsInsert){
                        createdDateGmt = DateTime.newInstanceGmt(System.now().dateGmt(), System.now().TimeGmt()); 
                    } else{
                        createdDateGmt = DateTime.newInstanceGmt(cs.createdDate.dateGmt(), cs.createdDate.TimeGmt()); 
                    }
                    
                    if(createdDateGmt != null && !String.isBlank(cs.Location__c)){ 
                            Datetime localdateTime = getservicedatetime(createdDateGmt,cs);
                            DateTime dT = localdateTime;
                            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                            cs.Service_Date_from_Local_Time__c = myDate;
                    }
                    if(cs.Description != null && Constant_Util.ORIGIN_EMAIL.equals(cs.Origin)){
                        cs.Description= Constant_Util.EMPTY_STRING;
                    }
                    System.debug('cs.Service_Date_from_Local_Time__c---'+cs.Service_Date_from_Local_Time__c);
                }
            }
            System.debug('returncaselst ---'+returncaselst );
        }catch (Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        return returncaselst;
    }
     
    /*******************************************************************************************************
    * @description Method to update Service Date for the respective case based on the Entitlement availability or based on Industry Standard SLA.
    * @param caseNewList of type List<Case>
    * @param oldCasemap of type Map<Id,case>
    * @param caseWithContainerMap of type Map<id,Asset>
    * @param caseWithLocationMap of type Map<id,Account>
    * @return List<Case>
    * @example
    */
    public static List<case> updateServiceDateAlwaysRun(List<case> caseNewList,Map<Id,case> oldCasemap,Map<id,Asset> caseWithContainerMap, Map<id,Account> caseWithLocationMap){
        caseWithLocation = new Map<Id,Account>();
        caseWithLocation = caseWithLocationMap;
        casewithContainer = caseWithContainerMap;
        List<case> returncaselst = new List<case>();
        System_Log__c  sysLog = new System_Log__c();
        DateTime slaDateTime = null;
        try{
            //returncaselst = caselist;
            if(businessIdMap.isEmpty() || businessIdMap == null){
                for(BusinessHours b: [select id,TimeZoneSidKey from BusinessHours LIMIT 39999]){
                    businessIdMap.put(b.TimeZoneSidKey,b.Id);
                }
            }
            returncaselst = CaseTriggerHelper.getServiceDate(caseNewList);
        }
        Catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        return returncaselst ;
    }
    
    /*******************************************************************************************************
    * @description Method to update SLA Service Data time from Service Date
    * @param caseNewList of type List<Case>
    * @param oldCasemap of type Map<Id,case>
    * @return void
    * @example
    */  
    public static void serviceDatetoSLA(List<case> caseNewList,Map<Id,case> oldCasemap){
        DateTime slaDateTime = null;
        try{
            for(Case c: caseNewList){
                //SDT-38039 : Changes for Intake Pickup Case SLA Date
                //Logic Start
                // System.debug('@@@~Login User : ' +UserInfo.getName());
                if(UserInfo.getName() != null && UserInfo.getName().equals(Constant_Util.API_USER_ONLY_NAME)
                    && (c.status.equals(Constant_Util.STATUS_NEW))
                    && c.Case_Type__c.equals(Constant_Util.PICKUP_CSTYPE)
                    && c.Service_Date__c != null && c.SLA_Service_Date_Time__c != null
                    && (c.Service_Date__c > c.SLA_Service_Date_Time__c.dateGmt()))
                {
                    c.SLA_Service_Date_Time__c =  getIntakeSLADatetime(c.Service_Date__c, c.SLA_Service_Date_Time__c, c);
                }//Logic End
                else if(c.SLA_Service_Date_Time__c != null)
                {
                    
                    slaDateTime = DateTime.newInstanceGmt(c.SLA_Service_Date_Time__c.dateGmt(), c.SLA_Service_Date_Time__c.TimeGmt());
                    
                    slaDateTime =  getservicedatetime(slaDateTime,c);
                // }//Logic End
                    //Changes related to SDT-32829 - added conditions -oldCasemap.get(c.id).Service_Date__c !=null && c.RecordTypeId == oldCasemap.get(c.id).RecordTypeId 
                    //&& !resetSLAandServiceDate(c,oldCasemap.get(c.id)) 
                    if((c.ParentId != null && c.Service_Date__c != null && c.Check_Case__c ) 
                        || (!oldCasemap.isEmpty() && oldCasemap.containskey(c.Id)  && oldCasemap.get(c.id).Service_Date__c !=null && c.RecordTypeId == oldCasemap.get(c.id).RecordTypeId && !resetSLAandServiceDate(c,oldCasemap.get(c.id)) && c.Service_Date__c != null && oldCasemap.get(c.Id).Service_Date__c != c.Service_Date__c
                            && slaDateTime != null && c.Service_Date__c >= slaDateTime.dateGmt() && !Constant_Util.SLA_OVERRIDE_REASON.equals(c.SLA_Override_Reason__c))  
                        || (c.Service_Date__c != null && c.Service_Date__c < date.today() && (Constant_Util.STATUS_NEW).Equals(c.status))){
                                Date targetDate = Date.newInstance(c.Service_Date__c.year(), c.Service_Date__c.month(), c.Service_Date__c.day());
                                Time targetTime = Time.newInstance(21, 0, 0, 0);
                                c.SLA_Service_Date_Time__c =  getadditionalDate(targetDate,targetTime,casewithLocation.get(c.Location__c).tz__Timezone_SFDC__c);
                                c.Check_Case__c = false;                                                                                                            
                            }
                }
            }
        }Catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    //Trimming description SDT-8845 
    /*******************************************************************************************************
    * @description Method to trim the description
    * @param newcaselst of type List<Case>
    * @return void
    * @example
    */                                                                                                     
    public static void UpdateAndTrimDescription(List<Case> newcaselst){  
        for(Case cs: newcaselst){
            if( !string.isBlank(cs.Description) && cs.Origin == Constant_Util.ORIGIN_EMAIL){
                cs.Description= '';
            }
        }
        
    }
    
    /*******************************************************************************************************
    * @description Method to populate PO field with officetraxno
    * @param newcaselst of type List<Case>
    * @return void
    * @example
    */
    public static void UpdatePoWithOfficetraxno(List<Case> newcaselst){

        Config_PO__c cp = Config_PO__c.getinstance('PO_Number_Digits');
        if(cp !=null){  
            integer num = Integer.valueOf(cp.POCharacters__c);
            
            for(Case cc: newcaselst){
                if(Constant_Util.Officetrax.equalsIgnoreCase(cc.Origin)){
                    if(cc.Case_Information__c !=null)
                    {
                        integer valueIndex =  cc.Case_Information__c.indexOf('Request Number:') + 16;     
                        
                        cc.PurchaseOrder_Number__c = cc.Case_Information__c.substring(valueIndex , valueIndex + num);
                    }
                }
            }
        }
    }
    
  
    /*******************************************************************************************************    
    * @description Method to handle the logic for updating the Last Agent Id on the case
    * @param casemap of type Map<Id,Case>
    * @param IsInsertForLocalAgentId of type Boolean
    * @return List<Case>
    * @example
    */
    public static List<Case> UpdateLocalAgentId(Map<Id, Case> casemap,Map<Id, Case> oldCaseMap,Boolean IsInsertForLocalAgentId){  
        try{
			Boolean skipLastAgentIdupdate = false;
            String strUsername = '';
            Set<Id> lastAgentIdset = new Set<Id>();
            List<Case> caselstToUpdate = new List<Case>();
            Map<Id, User> lastAgentProfileMap = new Map<Id, User>();

            for(Case cse: casemap.values()){
                if(!IsInsertForLocalAgentId && userinfo.getuserId() != null){
                    lastAgentIdset.add(userinfo.getuserId());
                }
				if(IsInsertForLocalAgentId && cse.OwnerId !=Null ){
                    lastAgentIdset.add(cse.OwnerId);
                }
                if(cse.OwnerId != null && cse.CreatedById != null){
                    lastAgentIdset.add(cse.OwnerId);
                    lastAgentIdset.add(cse.CreatedById);
                }
            }

            List<User> myUserList = new List<User>();
            //myUserList = [SELECT Id, Profile.Name, Username FROM User WHERE Id IN:lastAgentIdset];
            //soql 101 issue sprint 8
            myUserList = SystemObjectSelector.getUsersByIds(lastAgentIdset);
           // System.debug('myUserList^^^ ' +myUserList);
            for(User u : myUserList){
                lastAgentProfileMap.put(u.Id, u);
            }
            
            //SDT-39638 
            List<String> LastagentProfileList = new List<String>();
            String profileValues = System.Label.LastAgentIdProfile ;
            LastagentProfileList = profileValues.split(';');
            
            for(Case csee: casemap.values()){
                if(!lastAgentProfileMap.isEmpty() 
                    && lastAgentProfileMap.containsKey(csee.CreatedById) 
                    && lastAgentProfileMap.get(csee.CreatedById).Profile.Name == Constant_Util.CUSTOMER_SERVICE 
                    && IsInsertForLocalAgentId)
                {
                    strUsername = lastAgentProfileMap.get(csee.CreatedById).Username;
                    csee.Last_Agent_ID__c = strUsername.substringBefore(Constant_Util.AT_SYMBOL);
                    csee.Last_Agent_Id_ForTaskAssignment__c = csee.CreatedById;
                    caselstToUpdate.add(csee);
                }

                else if(!lastAgentProfileMap.isEmpty() 
                        && lastAgentProfileMap.containsKey(userinfo.getuserid()) 
                        && LastagentProfileList.contains(lastAgentProfileMap.get(userinfo.getuserid()).Profile.Name) //SDT-39638
                        //&& lastAgentProfileMap.get(userinfo.getuserid()).Profile.Name == Constant_Util.CUSTOMER_SERVICE //SDT-39616
                        && !IsInsertForLocalAgentId)
                {
                    if(!oldCaseMap.isEmpty() &&  oldCaseMap.containsKey(csee.Id)){
                        skipLastAgentIdupdate =  skipLastAgentIdupdate(csee ,oldCaseMap.get(csee.Id),IsInsertForLocalAgentId );
                    }
                    if(!skipLastAgentIdupdate && runCount <= 1){
                        strUsername = lastAgentProfileMap.get(userinfo.getuserid()).Username;
                        csee.Last_Agent_ID__c =   strUsername.substringBefore(Constant_Util.AT_SYMBOL);
                    }
					csee.Last_Agent_Id_ForTaskAssignment__c = userinfo.getuserid(); 
                    caselstToUpdate.add(csee);
                }
                    
                else if(!lastAgentProfileMap.isEmpty() 
                        && lastAgentProfileMap.containsKey(csee.OwnerId) 
                        && LastagentProfileList.contains(lastAgentProfileMap.get(csee.OwnerId).Profile.Name) //SDT-39638
                        //&& lastAgentProfileMap.get(csee.OwnerId).Profile.Name == Constant_Util.CUSTOMER_SERVICE //SDT-39616
                        ) 
                {
                    if(!IsInsertForLocalAgentId && !oldCaseMap.isEmpty() &&  oldCaseMap.containsKey(csee.Id)){ 
                        skipLastAgentIdupdate =  skipLastAgentIdupdate(csee ,oldCaseMap.get(csee.Id),IsInsertForLocalAgentId );
                    }
                    if(!skipLastAgentIdupdate && runCount <= 1){
                        strUsername = lastAgentProfileMap.get(csee.OwnerId).Username;
                        csee.Last_Agent_ID__c = strUsername.substringBefore(Constant_Util.AT_SYMBOL);
                    }
					csee.Last_Agent_Id_ForTaskAssignment__c = csee.OwnerId;
                    caselstToUpdate.add(csee);
                } 
                
                else{
                    csee.Last_Agent_Id_ForTaskAssignment__c = null;
                    caselstToUpdate.add(csee);
                }
            }
                return caselstToUpdate;
        }catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
        }
        return null;
    }   

    
	 public static List<Case> UpdateCallCentreId(Map<Id, Case> casemap,Map<Id, Case> oldCaseMap, Boolean IsInsertForLocalAgentId){  
        try{
           
            Set<Id> lastAgentIdset = new Set<Id>();
            List<Case> caselstToUpdate = new List<Case>();
            Set<Id> callCentreIdSet = new Set<Id>();

            for(Case cse: casemap.values()){
                if( cse.CreatedById != null){
                    lastAgentIdset.add(cse.CreatedById);
                }
            }
            List<User> myUserList = new List<User>();
            myUserList = [SELECT Id, Profile.Name, Username,CallCenterId FROM User WHERE Id IN:lastAgentIdset];

            for(User u : myUserList){
                if(u.CallCenterId != null){
                   callCentreIdSet.add(u.Id); 
                }
               
            }

            for(Case csee: casemap.values()){
                if(!callCentreIdSet.isEmpty() )
                {
                    csee.CallCentreText__c = 'test';
                    caselstToUpdate.add(csee);
                }
            }
                return caselstToUpdate;
        }catch(Exception e){
            
            System.debug('Exception::::'+e.getStackTraceString());
        }
        return null;
    }
    
	
    /*******************************************************************************************************
    * @description Method to update the genesys record based on the case details.
    * @param newMap of type Map<Id,Case>
    * @param oldMap of type Map<Id,Case>
    * @return void
    * @example
    */
    public static void updateGenesysTaskRouting(Map<Id,Case> newMap, map<Id,Case> oldMap){
        List<Case> lstCase = new List<Case>();
        Set<Id> CaseIds = new Set<Id>();
        Boolean CaseIdsForBatch=false;
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> cancelCaseIdSet = new Set<Id>();
        set<string> processSet = new set<string>();
        Generic_Values__mdt objGV= new Generic_Values__mdt();
        String objuser = null;
        Genesys_Routing__c gr;
        map<string,TaskDesc__mdt> tskdescmap = new map<string,TaskDesc__mdt>();
        map<Id,Case> caseIdMap = new map<Id,case>();
        map<Id,EmailMessage> msgIdMap = new map<Id,EmailMessage>();                                                        
        List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
        Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        Id GroupUserId = null;
        for( Generic_Values__mdt objGenericValues : Generic_Values__mdt.getAll().values()){
            if(Constant_Util.GENESYSUSER.equals(objGenericValues.DeveloperName)){
                objUser = objGenericValues.Id__c; 
            }
            if(Constant_Util.GROUPUSER.equals(objGenericValues.DeveloperName)){
                GroupUserId = objGenericValues.Id__c;
            }
        }
        for(Case thisCase : newMap.values()) {
            if(oldMap!=null && oldMap.get(thisCase.Id).OwnerId != thisCase.OwnerId && oldMap.get(thisCase.Id).OwnerId == objuser && thisCase.OwnerId != GroupUserId && !thisCase.Is_From_ScreenPop__c){
                cancelCaseIdSet.add(thisCase.Id);
                CaseIds.add(thisCase.Id);
            }
            if(oldMap!=null && oldMap.get(thisCase.Id).status != thisCase.Status && thisCase.Status == Constant_Util.CLOSED && thisCase.OwnerId == objUser){
                
                CaseIds.add(thisCase.Id);
            }
            
        }  
        //soql 101 issue SDT- 40083
        if(!CaseIds.isEmpty()){
        for(EmailMessage objEM : [select Id,ToAddress, FromAddress, Subject,ParentId from EmailMessage where ParentId IN: CaseIds order by CreatedDate Limit 49999]){
            if(!msgIdMap.containsKey(objEM.ParentId)){
                msgIdMap.put(objEM.ParentId,objEM);
            }
        }  
        }      
        if(CaseIds != null && CaseIds.size() > 0){
            lstCase = [SELECT Id,status,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,
                       Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,
                       Supplier__r.Name,Supplier__r.Vendor_ID__c,Subject,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,
                       AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c FROM Case WHERE Id IN: CaseIds LIMIT 49999];
        }
        
        if(!lstCase.IsEmpty()){
            for(Case objCase : lstCase){
                gr = new Genesys_Routing__c();
                gr.LastAgentId__c = String.isNotBlank(objCase.Last_Agent_ID__c) ? objCase.Last_Agent_ID__c : null;
                gr.MediaType__c = Constant_Util.SFDCEMAILCASE;
                gr.RecordTypeId = genesysRoutingRec;
                gr.SFDCAcctID__c = objCase.Client__r.Customer_Code__c;
                gr.SFDCAcctLocationTimeZone__c = objCase.Location__r.tz__Timezone__c;
                gr.SFDCAcctLocation__c = objCase.Location__r.Location_Code__c;
                gr.SFDCAcctSegment__c = objCase.Client__r.Primary_Segment__c;
                gr.SFDCCaseNumber__c = objCase.CaseNumber;
                gr.SFDCCaseReason__c = string.isNotBlank(objCase.Case_Reason__c) ? objCase.Case_Reason__c : null;
                gr.SFDCCaseRefNo__c = objCase.Reference_Number__c;
                gr.SFDCCaseSubCaseType__c = objCase.Case_Sub_Type__c;
                gr.SFDCCaseType__c = objCase.Case_Type__c;
                gr.SFDCChildVendorName__c = objCase.Supplier__r.Name;
                gr.SFDCChildVendorAcctNo__c = objCase.Supplier__r.Vendor_ID__c;
                gr.SFDCObjName__c = Constant_Util.OBJECT_CASE;
                gr.SFDCObjRecordID__c = msgIdMap.get(objCase.Id) != null ?msgIdMap.get(objCase.Id).Id : objCase.Id;
                gr.SFDCObjType__c =  msgIdMap.get(objCase.Id) != null ? Constant_Util.OBJECT_EMAILMESSAGE :Constant_Util.OBJECT_CASE;
                gr.SFDCParentVendorAcctNo__c = objCase.Supplier__r.Parent.Vendor_ID__c;
                gr.SFDCParentVendorName__c = objCase.Supplier__r.Parent.Name;
                gr.SFDCRecordType__c = objCase.RecordType.Name;
                gr.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
                gr.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
                gr.EmailSubject__c = objCase.Subject;
                gr.SFDCServiceFlag__c = string.isNotBlank(String.valueof(objCase.Asset.Project_Code__c)) && objCase.Asset.Active__c ? Constant_Util.PS : Constant_Util.CS;    
                gr.SFDCTaskCaseId__c = objCase.Id; 
                gr.Integrate_with_Genesys_Routing__c = true;     
                if(cancelCaseIdSet != null && cancelCaseIdSet.size() > 0 && cancelCaseIdSet.contains(objCase.Id)){
                        gr.Action__c = Constant_Util.CANCEL;
                        gr.Action_Reason__c = Constant_Util.TRANSFERRED;
                }
                else if(objCase.status == Constant_Util.CLOSED){
                        gr.Action__c = Constant_Util.CANCEL;
                        gr.Action_Reason__c = Constant_Util.COMPLETED;
                }
                else{
                }
                gr.EmailTo__c = msgIdMap.get(objCase.Id) != null  ? msgIdMap.get(objCase.Id).ToAddress : '';
                gr.EmailFrom__c = msgIdMap.get(objCase.Id) != null ? msgIdMap.get(objCase.Id).FromAddress : '' ;
                lstGR.add(gr);
            }
        }
        try{
            if(lstGR != null && lstGR.size() >0){
                Database.SaveResult[] svRes = Database.insert(lstGR,false);
                UTIL_LoggingService.logDmlResults(svRes, null, lstGR, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
            }
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        } 
    }
    
    /*******************************************************************************************************
    * @description Method to delete the case asset when asset is changed or service date is changed.
    * @param oldCaseAssetIdMap of type Map<String,String>
    * @return void
    * @example
    */
    public static void deleteOldCaseAssets(Map<string,string> oldCaseAssetIdMap){
        List<SBS_Case_Asset__c> caseAssetOldParentList = new List<SBS_Case_Asset__c>();
        caseAssetOldParentList = [SELECT id, CaseId__c, AssetId__c,Asset_Header__c 
                                  FROM SBS_Case_Asset__c
                                  WHERE caseId__c in : oldCaseAssetIdMap.keyset() and (Asset_Header__c in: oldCaseAssetIdMap.values() or Asset_Header__c = NULL) LIMIT 10000];
        
        if(caseAssetOldParentList != null && !caseAssetOldParentList .isEmpty()){
            List<Database.DeleteResult> srList = new List<Database.DeleteResult>();
            srList = Database.delete(caseAssetOldParentList , false);
            UTIL_LoggingService.logDmlResults(null, srList, caseAssetOldParentList, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER,LoggingLevel.ERROR);
            /*for(Database.DeleteResult sr : srList){
                if(sr.isSuccess()){
                    system.debug('delete success--'+sr.getId());
                }
                else{
                    for(Database.error err : sr.getErrors()){
                        system.debug('Error ocurred ---'+ err.getMessage()+'===Fields----'+err.getFields());
                    }
                }
            }*/
        }
    }
    
    /*******************************************************************************************************                       
    * @description Method to create the case asset and link to the case.
    * @param caseNewMap of type Map<id,case>
    * @param oldcaseMap of type Map<id,case>
    * @param assetMap of type Map<id,Asset>
    * @return void
    * @example
    */
    public static void addCaseAssets(Map<id,Case> caseNewMap,Map<id,Case> oldCaseMap,Map<id,Asset> assetMap){
        Map<string,Map<string,List<Asset>>> assetByServiceHeaderMap = new Map<string,Map<string,List<Asset>>>();
        Map<string,string> oldCaseAssetIdMap = new Map<string,string>();
        Map<string,string> assetProductFamilyMap = new Map<string,string>();
        case oldCase = new case();
        
        Map<string,List<Asset>> assetbyServiceTypeMap= new Map<string,List<Asset>>();
        for(Case caseRecord : caseNewMap.values()){
            //if(!String.isBlank(caseRecord.AssetId)){
                if(oldCaseMap != null && !oldCaseMap.isEmpty() && oldCaseMap.containskey(caseRecord.Id)){
                    oldCase = oldCaseMap.get(caseRecord.Id);
                    if((caseRecord.AssetId != oldCase.AssetId) || (caseRecord.Service_Date__c!= oldCase.Service_Date__c)){
                        oldCaseAssetIdMap.put(caseRecord.Id, oldCase.AssetId);
                    }
                }
            //}             
        }
        if(oldCaseAssetIdMap!= null && !oldCaseAssetIdMap.isEmpty()){
            deleteOldCaseAssets(oldCaseAssetIdMap); 
        }
        if(assetMap != null && !assetMap.isEmpty()){
            for(asset asst : assetMap.values()){                
                if(asst.Service_Header_Id__c != null && asst.Is_Active__c){
                    assetbyServiceTypeMap= new Map<string,List<Asset>>();
                    system.debug('@@@@assetbyServiceTypeMap'+assetbyServiceTypeMap);
                    if(assetByServiceHeaderMap != null && !assetByServiceHeaderMap.isEmpty() && assetByServiceHeaderMap.containsKey(asst.Service_Header_Id__c)){
                        //assetbyServiceTypeMap= new Map<string,List<Asset>>();
                       
                        assetbyServiceTypeMap= assetByServiceHeaderMap.get(asst.Service_Header_Id__c);
                        if(assetbyServiceTypeMap!= null && !assetbyServiceTypeMap.isEmpty() && assetbyServiceTypeMap.containsKey(asst.Service_Type__c)){
                            assetbyServiceTypeMap.get(asst.Service_Type__c).add(asst);
                        }
                        else{
                            assetbyServiceTypeMap.put(asst.Service_Type__c,new List<asset>{asst});
                            assetByServiceHeaderMap.put(asst.Service_Header_Id__c, assetbyServiceTypeMap);
                        }
                    }
                    else{
                        assetbyServiceTypeMap.put(asst.Service_Type__c,new List<asset>{asst});
                        assetByServiceHeaderMap.put(asst.Service_Header_Id__c, assetbyServiceTypeMap);     
                    }
                }
            }
            System.debug('assetByServiceHeaderMap----'+assetByServiceHeaderMap);
        }
        
        Asset asstRecord = new Asset();
        List<SBS_Case_Asset__c> caseAssetList = new List<SBS_Case_Asset__c>();
        Map<string,List<Asset>> childAssetMap = new Map<string,List<Asset>>();
        List<asset> childAsstList = new List<Asset>();
        for(case caseRecord : caseNewMap.values()){        
            if(!String.isBlank(caseRecord.AssetId) && (assetMap!= null && !assetMap.isEmpty() && assetMap.containskey(caseRecord.AssetId))){
                childAsstList = new List<Asset>();
                asstRecord = assetMap.get(caseRecord.AssetId);
                System.debug('asstRecord.productFamily===='+asstRecord.productFamily);
                if(Constant_Util.ROLLOFF.equalsIgnoreCase(asstRecord.productFamily)){
                    if(assetByServiceHeaderMap !=null && !assetByServiceHeaderMap.isEmpty() && assetByServiceHeaderMap.containsKey(asstRecord.id)){
                        childAssetMap = assetByServiceHeaderMap.get(asstRecord.id);
                        if(childAssetMap != null && !childAssetMap.isEmpty()){
                            for(string asstKey : childAssetMap.keyset()){
                                if(Constant_Util.DISPOSAL.equalsIgnoreCase(asstKey) || Constant_Util.RECYCLING.equalsIgnoreCase(asstKey)){                                    
                                    for(Asset asstRec : childAssetMap.get(asstKey)){
                                        if(!asstRec.Is_Core_Service__c){
                                            childAsstList.add(asstRec);  
                                        }
                                    }
									/*  SDT-18374 */
                                }
								else if(Constant_Util.PICKUP_CSTYPE.equalsIgnoreCase(asstKey)){
                                    for(Asset asstRec : childAssetMap.get(asstKey)){
                                        if((Constant_Util.SCHEDULED.equalsIgnoreCase(asstRec.Occurrence_Type__c) && asstRec.Has_Extra_Pickup__c ==true)  || Constant_Util.ON_CALL.equalsIgnoreCase(asstRec.Occurrence_Type__c)){
                                            childAsstList.add(asstRec);  
                                        }
                                    }  
                                    
                                }
                              /*  SDT-18374 */
                                else{
                                    for(Asset asstRec : childAssetMap.get(asstKey)){
                                        if(asstRec.Is_Core_Service__c){
                                            childAsstList.add(asstRec);  
                                        }
                                    } 
                                }                            
                            }
                        }
                    }
                }
                else if(Constant_Util.COMMERCIAL.equalsIgnoreCase(asstRecord.productFamily)){
                    if(assetByServiceHeaderMap !=null && !assetByServiceHeaderMap.isEmpty() && assetByServiceHeaderMap.containsKey(asstRecord.id)){
                        childAssetMap = assetByServiceHeaderMap.get(asstRecord.id);
                        system.debug('*****childAssetMap:'+childAssetMap);
                        if(childAssetMap != null && !childAssetMap.isEmpty()){
                            for(string asstKey : childAssetMap.keyset()){
                                //SDT-47293 - Add condition to check if the service type = Hand Pickup, add asset to childAsstList
                                if(Constant_Util.PICKUP_CSTYPE.equalsIgnoreCase(asstKey) || Constant_Util.HAND_PICKUP.equalsIgnoreCase(asstKey)){                                    
                                    for(Asset asstRec : childAssetMap.get(asstKey)){
                                        if(Constant_Util.SCHEDULED.equalsIgnoreCase(asstRec.Occurrence_Type__c) || Constant_Util.ON_CALL.equalsIgnoreCase(asstRec.Occurrence_Type__c)){
                                            childAsstList.add(asstRec);  
                                        }
                                    }                                    
                                }
                                /*else{
                                    for(Asset asstRec : childAssetMap.get(asstKey)){
                                        if(asstRec.Is_Core_Service__c){
                                            childAsstList.add(asstRec);  
                                        }
                                    } 
                                }*/
                            } 
                            system.debug('*****childAsstList:'+childAsstList);
                        }
                    }
                    
                }
                else {
                    if(Constant_Util.SERVICES.equalsIgnoreCase(asstRecord.productFamily)){
                        if(assetByServiceHeaderMap !=null && !assetByServiceHeaderMap.isEmpty() && assetByServiceHeaderMap.containsKey(asstRecord.id)){
                            childAssetMap = assetByServiceHeaderMap.get(asstRecord.id);
                            if(childAssetMap != null && !childAssetMap.isEmpty()){
                                
                                if(childAssetMap.containskey(Constant_Util.BULKSTRING )){
                                    childAsstList.addAll(childAssetMap.get(Constant_Util.BULKSTRING ));
                                }
                                if(childAssetMap.containskey(Constant_Util.Haul_Away_Service)){
                                    childAsstList.addAll(childAssetMap.get(Constant_Util.Haul_Away_Service));
                                }
                                //Changes related to SDT-42644
                                if(childAssetMap.containsKey(Constant_Util.HAND_PICKUP)){
                                    childAsstList.addAll(childAssetMap.get(Constant_Util.HAND_PICKUP));
                                }                            
                            }
                        }
                    }                    
                }
            }
            System.debug('childAsstList 0--==='+childAsstList );
            if(childAsstList != null && !childAsstList.isEmpty()){
                for(asset asstVal : childAsstList ){
                    if(((asstVal.Start_Date__c != null && asstVal.Start_Date__c <= caseRecord.Service_Date__c) && (asstVal.End_Date__c == null || asstVal.End_Date__c >= caseRecord.Service_Date__c ))
                       || (asstVal.Start_Date__c == null && asstVal.End_Date__c == null)){
                           SBS_Case_Asset__c caseAsset = new SBS_Case_Asset__c();
                           caseAsset.CaseId__c = caseRecord.Id;
                           caseAsset.Asset_Header__c = caseRecord.AssetId;
                           caseAsset.AssetId__c = asstVal.Id;
                           caseAssetList.add(caseAsset);
                       }                           
                }
            }
            System.debug('caseAssetList0--==='+caseAssetList);
        }
        if(caseAssetList != null && !caseAssetList.isEmpty()){
            List<Database.saveResult> srList = new List<Database.saveResult>();
            srList = Database.insert(caseAssetList, false);
            UTIL_LoggingService.logDmlResults(srList, null, caseAssetList, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
            /*for(Database.saveResult sr : srList){
                if(sr.isSuccess()){
                    system.debug('insert success--'+sr.getId());
                }
                else{
                    for(Database.error err : sr.getErrors()){
                        system.debug('Error ocurred ---'+ err.getMessage()+'===Fields----'+err.getFields());
                    }
                }
            }*/
        }        
    }
    
    /*******************************************************************************************************
    * @description Method to Tracking number in the case comments and publish the comments for the service not performed cases.
    * @param caseNewMap of type Map<id,case>
    * @param oldcaseMap of type Map<id,case>
    * @return void
    * @example
    */
    public static void updateCommentsTrackingNumber(Map<id,case> caseNewMap,Map<id,case> oldcaseMap){
        set<Id> caseIdSet = new set<id>();
        List<CaseComment> caseCommentList = new List<CaseComment>();
        Map<string,case> referenceSnpCaseMap = new Map<string,case>();
        List<CaseComment> caseCommentPublishedList = new LIst<CaseComment>();
        Map<string,string> serviceNotPerformedCaseMap = new Map<string,string>();
        List<Comment__c> commentList = new List<Comment__c>();
        Map<string,set<string>> serviceNotPerformedCaseListMap = new Map<string,set<string>>();
        Id acornCommentRecordtypeId = Schema.SobjectType.Comment__c.getRecordTypeInfosByName().get(Constant_Util.ACORNTICKETCOMMENT).getRecordTypeId();
        comment__c commentRecord = null;
        set<Id> updateTrackingIdSet = new set<Id>();
        for(case caseRecord : caseNewMap.values()){
            if(!String.isBlank(caseRecord.Tracking_Number__c)){
                if(oldcaseMap != null && oldcaseMap.containskey(caseRecord.Id) && !(caseRecord.Tracking_Number__c).equals(oldcaseMap.get(caseRecord.Id).Tracking_Number__c)){
                    updateTrackingIdSet.add(caseRecord.Id);
                }
                if(Constant_Util.HAULER_REPORTED.equalsIgnoreCase(caseRecord.Case_Reason__c) && constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION.equalsIgnoreCase(caseRecord.Case_Sub_Status__c)){
                    serviceNotPerformedCaseMap.put(caseRecord.id,caseRecord.Reference_Number__c);
                    referenceSnpCaseMap.put(caseRecord.Id,caseRecord);
                }
                else{
                    caseIdSet.add(caseRecord.id);
                }
            }
        }
        if(!updateTrackingIdSet.isEmpty() && updateTrackingIdSet.size() > 0){
            for(Comment__c c : [select Id,Acorn_Tracking_Number__c,Type__c,Case__c from Comment__c where Case__c In : caseNewMap.keySet() Limit 49999]){
                 c.Acorn_Tracking_Number__c = caseNewMap.get(c.Case__c).Tracking_Number__c;
                 commentList.add(c);
            }
        }
        if(serviceNotPerformedCaseMap != null && !serviceNotPerformedCaseMap.isEmpty()){
            List<case> referenceSNPCaseList = new LIst<case>();
            referenceSNPCaseList = [SELECT id,Case_Number__c,Reference_Number__c 
                                    FROM case
                                    WHERE Reference_Number__c IN: serviceNotPerformedCaseMap.values() AND Case_Sub_Status__c =: Constant_Util.SERVICE_NOT_PERFORMED 
                                    LIMIT 40000];
            
            if(referenceSNPCaseList != null && !referenceSNPCaseList.isEmpty()){
                for(case snpCase : referenceSNPCaseList ){
                    if(serviceNotPerformedCaseListMap != null && !serviceNotPerformedCaseListMap.isEmpty() && serviceNotPerformedCaseListMap.containskey(snpCase.Reference_Number__c)){
                        serviceNotPerformedCaseListMap.get(snpCase.Reference_Number__c).add(snpCase.Id) ;
                    }else{
                        serviceNotPerformedCaseListMap.put(snpCase.Reference_Number__c,new set<string>{snpCase.Id});
                    }                     
                }
            }
            if(referenceSnpCaseMap != null && !referenceSnpCaseMap.isEmpty()){
                for(case caseRec : referenceSnpCaseMap .values()){
                    if(serviceNotPerformedCaseListMap != null && !serviceNotPerformedCaseListMap.isEmpty() && serviceNotPerformedCaseListMap.containskey(caseRec.Reference_Number__c )){
                        for(string parentCase : serviceNotPerformedCaseListMap.get(caseRec.Reference_Number__c)){
                            string commentBody = Constant_Util.KEYWORD_CASE + Constant_Util.BLANKSPACE +caseRec.caseNumber+ Constant_Util.COMMA + 
                                Constant_Util.REFERENCENUMBER + Constant_Util.BLANKSPACE +caseRec.Reference_Number__c+ Constant_Util.COMMA +
                                Constant_Util.TICKET + Constant_Util.BLANKSPACE +caseRec.Tracking_Number__c+ Constant_Util.BLANKSPACE +
                                Constant_Util.COMMENTSTRING ;
                            CaseComment caseCommentVal = new CaseComment();
                            caseCommentVal.ParentId = parentCase ;
                            caseCommentVal.CommentBody = commentBody;
                            caseCommentList.add(caseCommentVal);
                        }
                    }
                }
            }
            
            if(caseCommentList!= null && !caseCommentList.isEmpty()){
                List<Database.saveResult> srList = new List<database.saveResult>();
                srList = database.insert(caseCommentList,false);
                UTIL_LoggingService.logDmlResults(srList, null, caseCommentList, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
            } 
        }
        if(caseIdSet != null && !caseIdSet.isEmpty()){
            List<CaseComment> caseCommentUnPublishedList = new LIst<CaseComment>();
            caseCommentUnPublishedList = [SELECT id,isPublished,ParentId,CommentBody
                                          FROM CaseComment
                                          WHERE IsPublished = false AND ParentId in : caseIdset
                                          LIMIT 40000];
            if(caseCommentUnPublishedList != null && !caseCommentUnPublishedList.isEmpty()){
                for(caseComment comment : caseCommentUnPublishedList ){
                    case caseRecord = caseNewMap.get(comment.ParentId);
                    commentRecord = new comment__c();
                    commentRecord.Comment__c = comment.commentBody;
                    commentRecord.Acorn_Tracking_Number__c = caseRecord.Tracking_Number__c;
                    commentRecord.Case_Number__c = caseRecord.CaseNumber;
                    commentRecord.RecordTypeId = acornCommentRecordtypeId ;
                    commentRecord.Case__c = caseRecord.Id;
                    commentList.add(commentRecord);    
                    
                    //Update the caseComments as published once we created Comment record
                    comment.isPublished = true;
                    caseCommentPublishedList.add(comment);                
                }
                
            }                                
        }
        try{
            if(commentList!= null && !commentList.isEmpty()){
                Database.upsert(commentList,false);
            }  
        }Catch (Exception ex){
            system.debug('Exception:::'+ex.getStackTraceString());
        }
        if(caseCommentPublishedList!= null && !caseCommentPublishedList.isEmpty()){
            List<Database.saveResult> srList = new List<database.saveResult>();
            srList = database.update(caseCommentPublishedList,false);
            UTIL_LoggingService.logDmlResults(srList, null, caseCommentPublishedList, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
        } 
    }
    
    /*******************************************************************************************************
    * @description Method to do create extra cases for AM,PM scenario & Multivendor scenarios.
    * @param caseList of type List<case>
    * @param assetMap of type Map<id,Asset>
    * @return void
    * @example
    */ 
    public static void createAmPmVendorCases(List<case> caseList, Map<id,Asset> assetMap){
        MultipleWorkorderController.getAMPMCaseBulk(caseList/*,assetMap*/);
    }
    
    /*******************************************************************************************************
    * @description Method to update User_Name__c field on Case with logged in user id.
    * @param newMap of type Map<id,Case>    
    * @param oldCaseMap of type Map<id,Case>
    * @param caseList of type List<case>
    * @return void
    * @example
    */  
    public static void updateAssignment(Map<Id,Case> newMap, Map<Id,Case> oldMap, List<Case> caselst){

        Id pickuprecordtype = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.Pickup).getRecordTypeId();
        Id newServiceRecordType = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
        Id UserId = UserInfo.getUserId();
        
        for(Case c : caselst){
                if(c.RecordTypeId != pickuprecordtype && c.RecordTypeId != newServiceRecordType && (c.Status.equals(Constant_Util.OPEN) || c.Status.equals(Constant_Util.Pending)) && oldMap.get(c.id).Status.equals(Constant_Util.STATUS_New) && string.isBlank(c.User_Name__c) && string.isBlank(c.Team_Name__c)){
                    c.User_Name__c = UserId;

            }

        }

    }

    /*******************************************************************************************************
    * @description Method to Populate Service Classification on Case.
    * @param caseList of type List<case>
    * @param oldCaseMap of type Map<id,Case>
    * @return void
    * @example
    */ 
    public static void PopulateServiceClassification(List<case> newcaseList, Map<id,Case> oldCaseMap){
        Id snpRecId =  Schema.SobjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Util.R_STATUS_CASE).getRecordTypeId();
        if(!newcaseList.isEmpty() && newcaseList.size() > 0){
            try {
                Case oldsnp = null; 
                for(case snp : newcaseList){
                    if(Constant_Util.SERVICE_NOT_PERFORMED.equals(snp.Case_Sub_Type__c) && snpRecId.equals(snp.RecordTypeId)){
                        oldsnp = !oldCaseMap.isEmpty() && oldCaseMap.size() > 0 && oldCaseMap.containsKey(snp.Id) ? oldCaseMap.get(snp.Id)  : new case(); 
                        if( string.IsNotBlank(snp.Status) && string.IsNotBlank(snp.Case_Sub_Status__c) && (Constant_Util.OPEN).equals(snp.Status) 
                            && (Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION).equals(snp.Case_Sub_Status__c) && string.IsNotBlank(snp.Case_Reason__c)
                            &&  (oldsnp == null || !((snp.Case_Reason__c).equals(oldsnp.Case_Reason__c)) || !((snp.Status).equals(oldsnp.Status)) || !((snp.Case_Sub_Status__c).equals(oldsnp.Case_Sub_Status__c)) )){
                            snp.Service_Classification__c = (Constant_Util.HAULER_REPORTED).equals(snp.Case_Reason__c) ? Constant_Util.STANDARD : (Constant_Util.CUSTOMER_REPORTED).equals(snp.Case_Reason__c) ? Constant_Util.EMERGENCY: null; 
                        }
                    }
                }
            }catch(Exception ex){
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
    }
    
    /*******************************************************************************************************
    * @description Method to Send Email to Contact based using Selected Email Template.
    * @param emailCaseList of type List<case>
    * @param emailTemplate of type String
    * @return void
    * @example
    */ 
    public static void sendEmailOnWOcreation(List<Case> emailCaseList,String emailTemplate){    
           
            List<String> emailLst = new List<String>();
            String conEmail;
            
             List<Approval_Log__c> apList= [Select id,CaseId__c from Approval_Log__c where CaseId__c IN: emailCaseList]; 
            Map<id,List<Approval_Log__c>>appTocaseMap = new Map<id,List<Approval_Log__c>>();
        
        if(apList != null){
            for(Approval_Log__c aplog :apList ){
                appTocaseMap.put(aplog.CaseId__c,new List<Approval_Log__c>{aplog} );
                }
        }    
                  
        try{
            List<Case> cseEmailList = [Select id,ContactId,Contact.Email,Contact.Preferred_Method__c from Case where id in : emailCaseList ];           
            List<Messaging.SingleEmailMessage> msgList=new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
            EmailTemplate singleCaseTemplate = [SELECT Id, Name 
                                            FROM EmailTemplate 
                                            WHERE Name =:emailTemplate LIMIT 1];
                 
        for(Case cs : cseEmailList){
           
            if(CONSTANT_UTIL.ORIGIN_EMAIL.equalsIgnoreCase(cs.Contact.Preferred_Method__c)&& appTocaseMap.containsKey(cs.Id)){                     
                conEmail = cs.Contact.Email;
                emailLst.add(conEmail);
                
             if(singleCaseTemplate != null &&  singleCaseTemplate.Id != null){
                msg = Messaging.renderStoredEmailTemplate(String.valueof(singleCaseTemplate.Id), String.valueof(cs.ContactId), String.valueof(cs.Id));                
                msg.setToAddresses(emailLst);
                msg.setTargetObjectId(cs.ContactId);
                msg.setWhatId(cs.Id);
                msg.setTemplateId(singleCaseTemplate.Id);
                msg.saveAsActivity = true; 
                msgList.add(msg);
             }
           }
        }         
               
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(msgList);  
                }
                catch (Exception ex){
                    //To handle Error in future Sprints
                    UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
                  
                }      
        }   

    /*******************************************************************************************************
    * @description Method to Populate Team Name and Team Queue based on Case Type and Case Sub-Type.
    * @param caseList of type List<case>
    * @return void
    * @example
    */
    public static void PopulateTeamNameandQueue(List<case> newcaseList){
        if(!newcaseList.isEmpty() && newcaseList.size() > 0){
            set<String> caseTypeSet = new set<String>();
            set<String> caseSubTypeSet = new set<String>();
            map<String,Allocate_Team_Name_and_Queue__mdt> teamNameandMap = new map<String,Allocate_Team_Name_and_Queue__mdt>();
            
            try {
                for(Case c: newcaseList){
                    if(string.IsNotBlank(c.Case_Type__c) && string.IsNotBlank(c.Case_Sub_Type__c) ){
                        caseTypeSet.add(c.Case_Type__c);
                        caseSubTypeSet.add(c.Case_Sub_Type__c);
                    }   
                            if((c.Case_Type__c == 'Pickup' && c.Case_Sub_Type__c == 'Bale(s)' ) 
               || ( c.Case_Type__c == 'Special Request' &&
                             ( c.Case_Sub_Type__c == 'Electronic Recycling (Computers, Laptops, etc.)' ||
                              c.Case_Sub_Type__c == 'Universal Waste (Lamps, Batteries, etc.)' ))){
                                  system.debug('in if block>>>');   
                              }else{
                                   system.debug('in else block>>>');
                                   c.Team_Name__c =  ' ';
                                c.Team_Queue__c = ' ';
                              }
                }
                if(!caseTypeSet.isEmpty() && caseTypeSet.size() > 0 && !caseSubTypeSet.isEmpty() && caseSubTypeSet.size() > 0){
                    string mapKey = null;
                    for(Allocate_Team_Name_and_Queue__mdt tnq : Allocate_Team_Name_and_Queue__mdt.getAll().values()) {
                        if(caseTypeSet.contains(tnq.Case_Type__c) && caseSubTypeSet.contains(tnq.Case_Sub_Type__c) )  {               
                            
                            
                            mapKey = tnq.Case_Type__c + tnq.Case_Sub_Type__c;
                            teamNameandMap.put(mapKey,tnq);
                        }    
                    }
                    if(!teamNameandMap.isEmpty() && teamNameandMap.size() > 0){
                        string key = null;
                        for(Case ca: newcaseList){
                            key = ca.Case_Type__c + ca.Case_Sub_Type__c;
                            if((ca.Case_Type__c == 'Pickup' && ca.Case_Sub_Type__c == 'Bale(s)' ) 
               || ( ca.Case_Type__c == 'Special Request' &&
                             ( ca.Case_Sub_Type__c == 'Electronic Recycling (Computers, Laptops, etc.)' ||
                              ca.Case_Sub_Type__c == 'Universal Waste (Lamps, Batteries, etc.)' ))){
                                  system.debug('in if block>>>');
                                   if(string.IsNotBlank(ca.Case_Type__c) && string.IsNotBlank(ca.Case_Sub_Type__c) &&
                              // string.IsBlank(ca.Team_Name__c)  && teamNameandMap.containsKey(key)){
                                  teamNameandMap.containsKey(key)){
                                ca.Team_Name__c =  teamNameandMap.get(key).Team_Name__c;
                                ca.Team_Queue__c = teamNameandMap.get(key).Team_Queue__c;
                            }
                              }
                               //added for SDT-38008

                              if(ca.Case_Type__c == 'Billing' && ca.Case_Sub_Type__c == 'Invoice Charge Dispute' && string.IsNotBlank(ca.Case_Reason__c)  && (ca.Case_Reason__c == 'Customer Questions' || ca.Case_Reason__c == 'Customer Short Pay')){
                                 
                                   if(string.IsNotBlank(ca.Case_Type__c) && string.IsNotBlank(ca.Case_Sub_Type__c) && teamNameandMap.containsKey(key)){
                                        ca.Team_Name__c =  teamNameandMap.get(key).Team_Name__c;
                                        ca.Team_Queue__c = teamNameandMap.get(key).Team_Queue__c;
                                    }
                                }
                                
                              //added for SDT-38008
                        }
                    }
                }
    
                
            }catch(Exception ex){
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
    }
    
/*
    public static void addContactNameTitleCase(String name, String clientId, List<Case> newcaselst){

          if(String.isNotEmpty(name) 
           && !name.contains('AutomatedWorkOrders.Engine')
           && !name.contains('FAX, FRIDAY')
           && !name.contains('@'))
        { 
             String contactFullName, fName, lName;
            
            if(name.containsAny('-')){
                string[] lstContact = name.split('-');
                contactFullName = lstContact[0];
            }
            else
                contactFullName = name;
             
            List<String> lstName = contactFullName.split(',');
            
            if(lstName.size() > 0)
                lName = lstName[0];
            
            if(lstName.size() > 1)
                fName = lstName[1];

            List<Contact> contactList = [SELECT id FROM Contact 
                                         WHERE Account.id =: clientId  
                                         AND FirstName =: fName.trim()
                                         AND LastName =: lName.trim()
                                         LIMIT 2];

            if(contactList != null && contactList.size() == 1){
                for(Case cs: newcaselst){
                    if(string.isBlank(cs.ContactId)){
                        cs.ContactId = contactList[0].id;
                    }
                }

            }
        }

    }
    */
    
    /*******************************************************************************************************
    * @description  Method to create genesys reporting records.
    * @param caseNewMap of type Map<Id, Case>
    * @param oldcaseMap of type Map<Id, Case>
    * @return void
    * @example
    */
    public static void CreateGenRoutingReporting (Map<id,case> caseNewMap,Map<id,case> oldcaseMap){
        List<Genesys_Routing__c> genRoutingRecords = new List<Genesys_Routing__c>();
        Set<Id> caseSet = new Set<Id>();
        Map<String,Genesys_Routing__c> genesysMap = new Map<String,Genesys_Routing__c>();
        Map<String,Case> caseNumberMap = new Map<String,Case>();
        List<Genesys_Reporting__c> genesysReportingList = new List<Genesys_Reporting__c>();

        for(Case c : caseNewMap.values()){
            Case oldCase = (Case) oldCaseMap.get(c.Id);
            if(c.Case_Type__c != oldCase.Case_Type__c || c.Case_Sub_Type__c != oldCase.Case_Sub_Type__c || c.Reference_Number__c != oldCase.Reference_Number__c || c.Location__c != oldCase.Location__c){
                caseSet.add(c.Id);
            }
        }

        for(Case c : [SELECT Id, CaseNumber, Case_Type__c, Case_Sub_Type__c, Reference_Number__c, Location__c, Location__r.Location_Code__c, Location__r.Primary_Segment__c, Client__r.Customer_Code__c FROM Case WHERE Id IN : caseSet]){
            caseNumberMap.put(c.CaseNumber, c);
        }

        
        if(!caseNumberMap.isEmpty()){
            genRoutingRecords = [SELECT Id,SFDCObjRecordID__c, SFDCCaseNumber__c, SFDCCaseRefNo__c FROM Genesys_Routing__c WHERE SFDCCaseNumber__c IN : caseNumberMap.keySet()];
            for(Genesys_Routing__c g : genRoutingRecords){
                Genesys_Reporting__c gr = new Genesys_Reporting__c();
                gr.SFDCAcctID__c = caseNumberMap.get(g.SFDCCaseNumber__c).Client__r.Customer_Code__c;
                gr.SFDCCaseNumber__c = g.SFDCCaseNumber__c;
                gr.SFDCAcctLocation__c = caseNumberMap.get(g.SFDCCaseNumber__c).Location__r.Location_Code__c; 
                gr.SFDCAcctSegment__c = caseNumberMap.get(g.SFDCCaseNumber__c).Location__r.Primary_Segment__c;
                gr.SFDCCaseSubType__c = caseNumberMap.get(g.SFDCCaseNumber__c).Case_Sub_Type__c;
                gr.SFDCCaseType__c = caseNumberMap.get(g.SFDCCaseNumber__c).Case_Type__c;
                gr.SFDCObjRecord_Id__c = g.SFDCObjRecordId__c;
                genesysReportingList.add(gr);
            }
        }

        if(!genesysReportingList.isEmpty()){
            try{
                Database.insert(genesysReportingList);
            }Catch(Exception ex){
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
    }
    
    /*******************************************************************************************************
    * @description This method is to handle the logic for Create Multiple Cases per Service Date.
    * @param newCaseMap of type Map<Id, Case>
    * @return void
    * @example
    */
    public static void updateDuplicateCheck(Map<Id, Case> newCaseMap)
    {
        if(!newCaseMap.isEmpty())
        {
            Id caseId;
            for(Id cId : newCaseMap.keySet())
            {
                caseId=cId;
            }
            Case cs = newCaseMap.get(caseId);
            //Get the List of Other Cases which are created with 15 mins time period.
            List<Case> lstCase = [select id, CaseNumber, Client__c, AssetId, Service_Date__c, Case_Type__c, Status__c, 
                                  CreatedDate, CreatedById, Reference_Number__c from Case
                                  where Client__c=:cs.Client__c AND AssetId=: cs.AssetId AND Service_Date__c=:cs.Service_Date__c 
                                  AND Case_Type__c=:cs.Case_Type__c AND Reference_Number__c=:cs.Reference_Number__c
                                  AND (Status=:Constant_Util.PENDING OR Status=:Constant_Util.OPEN) AND CreatedDate >= :Datetime.now().addMinutes(-15)
                                  AND CreatedById=:UserInfo.getUserId() AND Id !=: caseId
                                 ];
            if(lstCase.size()>0)
            { 
                for(case ca : newcasemap.values()){                 
                   ca.Is_Multiple_Case_Per_ServiceDT__c=true;
                }
            }
        }
    }
    
    /*******************************************************************************************************
    * @description This method is to handle the logic for Create Multiple Cases per Service Date within 15min..
    * @param caseId
    * @return Boolean
    * @example
    */
    public static Boolean checkParentWithIn15Min(Id caseId){
        Boolean isWithIn15Min=false;
        if (caseId !=null){
           Case cse = [Select CreatedDate, Parent.CreatedDate, ParentId From Case Where id =: caseId LIMIT 1];
            if(cse != null && cse.ParentId !=null && cse.Parent.CreatedDate !=null ){                
                if(cse.CreatedDate <= cse.Parent.CreatedDate.addMinutes(15)){
                    isWithIn15Min=true;
                }
            }
        }
        return isWithIn15Min;
    }
       
    /*******************************************************************************************************
    * @description This method is to create case comment record for accepted/rejected WO related cases.
    * @param List<case> caseLst
    * @return void
    * @example
    */
    public static void insertCaseComment(List<case> caseLst){
        List<Comment__c> commentLst = new List<Comment__c>();
        Comment__c commentObj;
        Map<Id, Case> parentCaseMap = new Map<Id, Case>();
        Id recordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_COMMENT).getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        //Decimal acornUserId = [SELECT Acorn_SUser_ID__c FROM User WHERE Id =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
        //soql 101 issue sprint 8
         Id userId = System.UserInfo.getUserId();
        Decimal acornUserId = SystemObjectSelector.acornUserId(userId);
        set<Id> caseIds = new set<Id>();
        for(Case caseObj : caseLst){
            caseIds.add(caseObj.ParentId);
        }
        
        for(Case parentCase : [SELECT Id, Work_order__r.status, Work_order__r.Acorn_WorkOrder_Number__c, Tracking_Number__c, Work_order__r.WO_Accepted_Rejected_Comments__c FROM Case WHERE Id IN: caseIds]){
            parentCaseMap.put(parentCase.Id, parentCase);
        }
        for(Case caseObj : caseLst){
            commentObj = new Comment__c();
            string trackingNumber;
            string acornWoNumber;
            string wostatus;
            string woRejectionComment;
            if(parentCaseMap.ContainsKey(caseObj.parentId)){
                case cse = parentCaseMap.get(caseObj.parentId);
                trackingNumber = cse.Tracking_Number__c != null ? cse.Tracking_Number__c : Constant_Util.EMPTY_STRING;
                acornWoNumber = cse.Work_order__r.Acorn_WorkOrder_Number__c != null ? cse.Work_order__r.Acorn_WorkOrder_Number__c : Constant_Util.EMPTY_STRING;
                wostatus = cse.Work_order__r.status != null ? cse.Work_order__r.status : Constant_Util.EMPTY_STRING;
                woRejectionComment = cse.Work_order__r.WO_Accepted_Rejected_Comments__c != null ? cse.Work_order__r.WO_Accepted_Rejected_Comments__c : Constant_Util.EMPTY_STRING;
            }
            if(wostatus != null && (Constant_Util.ACCEPTED.equalsIgnoreCase(wostatus) ||
                                    Constant_Util.REJECTED.equalsIgnoreCase(wostatus))){
                commentObj.Case__c = caseObj.Id;
                commentObj.RecordTypeId = recordTypeId;
                commentObj.Case_Number__c = caseObj.CaseNumber;
                commentObj.Acorn_Tracking_Number__c = trackingNumber;
                commentObj.Workflow_Action__c = Constant_Util.EMPTY_STRING;
                commentObj.Acorn_SUser_ID__c = acornUserId;
                commentObj.Type__c = Constant_Util.OBJECT_CASE;
                commentObj.Communication_Log_Type_Name__c = Constant_Util.INTERNAL;
                commentObj.Workflow_TeamUser__c = System.UserInfo.getName();
                string comment = 'The case is created because the vendor conditionally '+wostatus.toLowerCase()+' the work order number '+acornWoNumber
                                        +' corresponding to ticket number '+ trackingNumber +' on '+system.now();
                if(Constant_Util.REJECTED.equalsIgnoreCase(wostatus)){
                    comment += ' Rejection Reason : '+ woRejectionComment;
                }
                commentObj.Comment__c = comment;
                
                commentLst.add(commentObj);
            }
        }
        if(commentLst != null && !commentLst.isEmpty()){
            insert commentLst;
        }
    }
    /*******************************************************************************************************
    * @description Insert Approval Log
    * @param void
    * @return void
    * @example
    */
    public static void insertAutoApprovalLog()
    {
        Database.SaveResult[] appLst = Database.insert(appLogList, true);
        UTIL_LoggingService.logDmlResults(appLst, null, appLogList, '', UTIL_ErrorConstants.CASE_TRIGGER_CLASS,'',UTIL_ErrorConstants.CASE_TRIGGER, LoggingLevel.ERROR);
    }
	

	/*******************************************************************************************************
    * @description For skipping last agent id update SDT-11140
    * @param case,case,boolean
    * @return Boolean
    */	
	public static Boolean  skipLastAgentIdupdate(case CaseOBj,Case OldcaseObj,Boolean IsInsert) {
        
        runCount++;
        Boolean skipAgentIdUpdte = false ;
        
        if(!IsInsert && CaseOBj.Last_Agent_ID__c != NULL  &&((String.isNotBlank(CaseOBj.AssetId) && CaseOBj.AssetId != OldcaseObj.AssetId  ) || (CaseOBj.ContactId != OldcaseObj.ContactId) ||((CaseOBj.origin != NULL) && (CaseOBj.origin != OldcaseObj.Origin)) 
                                                             || (CaseOBj.Case_Type__c!=NULL && CaseOBj.Case_Type__c != OldcaseObj.Case_Type__c)||( CaseOBj.Case_Sub_Type__c !=NULL && CaseOBj.Case_Sub_Type__c != OldcaseObj.Case_Sub_Type__c) ||(CaseOBj.Site_Contact__c !=NULL && CaseOBj.Site_Contact__c != OldcaseObj.Site_Contact__c)
                                                             ||(CaseOBj.Site_Contact_Phone__c !=NULL && CaseOBj.Site_Contact_Phone__c != OldcaseObj.Site_Contact_Phone__c)
                                                             ||(CaseOBj.User_Input_Work_Order_Instructions__c !=NULL && CaseOBj.User_Input_Work_Order_Instructions__c != OldcaseObj.User_Input_Work_Order_Instructions__c) || (CaseOBj.Ignore_Duplicate__c != OldcaseObj.Ignore_Duplicate__c) || (CaseOBj.CaseComment_CreateDate__c != OldcaseObj.CaseComment_CreateDate__c)  ||(CaseOBj.Service_Date__c!=Null &&CaseOBj.Service_Date__c != OldcaseObj.Service_Date__c ) )){
                                                                 skipAgentIdUpdte = true ;
                                                             }
        return skipAgentIdUpdte;
    }
  
	       /**- Code Chnage for SDT-18374*/
    Public static set<Id> checkLogicToupDateCaseSubtype(Map<id,Asset> caseWithContainerMap){
        Set<Id> assetIdSetafterFilter = new Set<Id>();
        set<Id> parentAssetIdSetAfterFilter = new set<Id>();
        for(Asset asst : caseWithContainerMap.values() ){
            if(asst.product2.family == Constant_Util.ROLLOFF){
                assetIdSetafterFilter.add(asst.Id);
            }
        }
        if(!assetIdSetafterFilter.IsEmpty()){
            for(Asset asst : [select Id, (select Id,ParentId,Service_Type__c,Is_Core_Service__c from ChildAssets) from Asset where Id IN:assetIdSetafterFilter]){
                List<Asset> childAssetList = asst.ChildAssets ;
                if(!childAssetList.isEmpty()){
                    for(Asset childAsset  : childAssetList){
                        if(childAsset.Service_Type__c== Constant_Util.PICKUP_CSTYPE && childAsset.Is_Core_Service__c== true){
                            parentAssetIdSetAfterFilter.add(childAsset.ParentId);
                        }
                    }
                }
            }
        }
        return parentAssetIdSetAfterFilter;
    }


    /*******************************************************************************************************
    * @description : Update ANI on Contact
    * @param void
    * @return void
    * @Jira Id : SDT-18823, SDT-24429
    */
    public static void updateANIOnContact(Map<Id,Case> caseNewMap, map<Id,Case> oldCaseMap){
        Set<Id> caseIds = new Set<Id>();
        String INBOUND_CUSTOMER_INTERACTION_TASK = 'Inbound Customer Interaction';
        String BROKER = 'Broker';
        String STR_UNSPECIFIED = 'Unspecified';
        String NEW_STATUS = 'New';
        
        for(Case caseObj : caseNewMap.values()){
            system.debug('caseObj :' + caseObj);
            Case oldCase = (Case) oldCaseMap.get(caseObj.Id);
            if(caseObj.ContactId != null && caseObj.Status != NEW_STATUS && caseObj.Status != oldCase.Status ) {
                caseIds.add(caseObj.Id);
            }
        }
        
        system.debug('caseIds :' + caseIds);
        if(caseIds!=null && !caseIds.isEmpty()){
            Map<String,String> mapCaseVsContact = new Map<String,String>();
            for(Case cse : [Select Id, Client__r.Name,ContactId,Contact.LastName,Contact.FirstName from Case where Id IN : caseIds AND Contact.Account_Record_Type__c !=: Constant_Util.VENDOR AND Location__r.Primary_Segment__c !=: BROKER ]){
                if( cse.ContactId != null && cse.Contact.FirstName != STR_UNSPECIFIED && cse.Contact.LastName != cse.Client__r.Name ){
                    mapCaseVsContact.put(cse.Id,cse.ContactId);
                }
        	}
            
            if(mapCaseVsContact!=null && !mapCaseVsContact.isEmpty()){
                Map<String,String> mapCaseContactvsANI = new Map<String,String>();
                for(Task tsk : [Select Id, WhatId, ANI__c from Task where whatId IN : mapCaseVsContact.keySet() AND Subject =: INBOUND_CUSTOMER_INTERACTION_TASK ]){
                    if(tsk.ANI__c != null  && mapCaseVsContact.containsKey(tsk.WhatId)){
                        mapCaseContactvsANI.put(mapCaseVsContact.get(tsk.WhatId),tsk.ANI__c);
                    }
                }
                
                system.debug('mapCasevsANI :' + mapCaseContactvsANI);
                if(mapCaseContactvsANI != null && !mapCaseContactvsANI.isEmpty()){
                    List<Contact> updateContactList = new List<Contact>();
                    for(Contact conObj : [Select Id,ANI__c from Contact where Id IN : mapCaseContactvsANI.keySet()]){
                        conObj.ANI__c = mapCaseContactvsANI.get(conObj.Id);
                        updateContactList.add(conObj);
                    }
                    
                    system.debug('updateContactList :' + updateContactList);
                    if(updateContactList!=null && !updateContactList.isEmpty()){
                        update updateContactList;
                    }
                }
                
            }
        }
        
    }
	 /*******************************************************************************************************
* @description Method to create the genesys cancellation record for deleted standard case .
* @param newMap of type Map<Id,Case>
* @param oldMap of type Map<Id,Case>
* @return void
* @example
*/
    public static void createCacelCompletedGenesysRecord(Map<Id,Case> newMap){ // system.debug('DEBUGDAS' + newMap );
	     system.debug('CASEBEFOREDELETE');
        List<String> caseReffNumberList  = new List<String> ();
        Map<Id,case> updateMap = new Map<Id,Case> ();
        Map<String,Genesys_Routing__c> mapofNewGnsysesRec = new Map<String,Genesys_Routing__c> ();
        Map<String,Genesys_Routing__c> cancelGnsysesRecMap = new Map<String,Genesys_Routing__c> ();
        Map<String,Genesys_Routing__c> createGenysesRecMap = new Map<String,Genesys_Routing__c> ();
        List<Genesys_Routing__c> listTocreateGrecord =  new List<Genesys_Routing__c> (); 
         Set<Id> CasetaskId = new  Set <Id> ();
		 Id genesysRoutingRec = null ;
        try{
		String objuser = null;
            for( Generic_Values__mdt objGenericValues : Generic_Values__mdt.getAll().values()){
            if(Constant_Util.GENESYSUSER.equals(objGenericValues.DeveloperName)){
                objUser = objGenericValues.Id__c; 
            }
        }
            if(Trigger.IsUpdate && !Trigger.Isdelete){
			
			 for(case cse :  newMap.values()){
                    if(cse.ownerId == objUser){
                        newMap.remove(cse.Id);
                    }
                    
                }
            
                for(Task tsk : [Select Id,WhatId from Task  where  WhatId IN:newMap.KeySet() AND OWner.Id =:objUser AND RecordType.DeveloperName =:'Email_to_Case' AND Status ='Open']){
                    newMap.remove(tsk.WhatId);
                }
            }
            for(case cse :  newMap.values() ){
			if(cse.Reference_Number__c != null && string.isNotEmpty(cse.Reference_Number__c)){
			 caseReffNumberList.add(cse.Reference_Number__c); 
			}
              //  system.debug('DEBUGDAS' +cse.Reference_Number__c );
                }
				 system.debug('CASEBEFOREDELETE'+ caseReffNumberList);
	        if(!caseReffNumberList.isEmpty()){
            for(Genesys_Routing__c gr : [select id,LastAgentId__c,SFDCAcctID__c,SFDCAcctLocationTimeZone__c,SFDCAcctLocation__c,SFDCAcctSegment__c,SFDCCaseNumber__c,
                                             SFDCCaseReason__c,SFDCCaseRefNo__c,SFDCCaseSubCaseType__c,SFDCCaseType__c,SFDCChildVendorName__c,
                                             SFDCChildVendorAcctNo__c,SFDCObjRecordID__c,SFDCParentVendorAcctNo__c,SFDCParentVendorName__c,SFDCObjType__c,
                                             SFDCRecordType__c,EmailSubject__c,SFDCServiceFlag__c,SFDCTaskCaseId__c,Action__c,MediaType__c
                                             from Genesys_Routing__c where SFDCCaseRefNo__c != null AND SFDCCaseRefNo__c IN:caseReffNumberList 
                                             AND SFDCObjType__c =:Constant_Util.OBJECT_EMAILMESSAGE  AND CreatedDate = LAST_N_DAYS:30 ORDER BY SFDCCaseRefNo__c LIMIT 49999
                                        ])
            {
              //  system.debug('GRrecord' +gr );
                if(gr.Action__c =='New'){
                    createGenysesRecMap.put(gr.SFDCObjRecordID__c , gr);
                    mapofNewGnsysesRec.put(gr.SFDCObjRecordID__c , gr); 
                 //   system.debug('GRrecord' +createGenysesRecMap );
                }else if(gr.Action__c =='Cancel'){
                    cancelGnsysesRecMap.put(gr.SFDCObjRecordID__c , gr);
                }
            }
            for(string gObjecRectId :mapofNewGnsysesRec.keySet() ){
                if(cancelGnsysesRecMap.containsKey(gObjecRectId)){
                    createGenysesRecMap.remove(gObjecRectId);
                //    system.debug('GRrecord' +createGenysesRecMap );
                }
            }
           // system.debug('DEBUG33' + createGenysesRecMap );
		    if(!createGenysesRecMap.isEmpty()){
                    genesysRoutingRec =  Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
                }
            for(string gObjecRectId :createGenysesRecMap.keySet()){
                 Genesys_Routing__c objGRnewRec = createGenysesRecMap.get(gObjecRectId);
                    Genesys_Routing__c objGR = new Genesys_Routing__c();
                    objGR.LastAgentId__c = objGRnewRec.LastAgentId__c ;
                    objGR.MediaType__c =  objGRnewRec.MediaType__c ;
                    objGR.RecordTypeId = genesysRoutingRec;
                    objGR.SFDCAcctID__c = objGRnewRec.SFDCAcctID__c;
                    objGR.SFDCAcctLocationTimeZone__c = objGRnewRec.SFDCAcctLocationTimeZone__c;
                    objGR.SFDCAcctLocation__c = objGRnewRec.SFDCAcctLocation__c;
                    objGR.SFDCAcctSegment__c =  objGRnewRec.SFDCAcctSegment__c;
                    objGR.SFDCCaseNumber__c = objGRnewRec.SFDCCaseNumber__c;
                    objGR.SFDCCaseReason__c = objGRnewRec.SFDCCaseReason__c ;
                    objGR.SFDCCaseRefNo__c = objGRnewRec.SFDCCaseRefNo__c;
                    objGR.SFDCCaseSubCaseType__c = objGRnewRec.SFDCCaseSubCaseType__c;
                    objGR.SFDCCaseType__c = objGRnewRec.SFDCCaseType__c;
                    objGR.SFDCChildVendorName__c = objGRnewRec.SFDCChildVendorName__c;
                    objGR.SFDCChildVendorAcctNo__c = objGRnewRec.SFDCChildVendorAcctNo__c;
                    objGR.SFDCObjName__c = Constant_Util.OBJECT_CASE;
                    objGR.SFDCObjRecordID__c =  objGRnewRec.SFDCObjRecordID__c;
                    objGR.SFDCObjType__c =  objGRnewRec.SFDCObjType__c;
                    objGR.SFDCParentVendorAcctNo__c = objGRnewRec.SFDCParentVendorAcctNo__c;
                    objGR.SFDCParentVendorName__c = objGRnewRec.SFDCParentVendorName__c;
                    objGR.SFDCRecordType__c = objGRnewRec.SFDCRecordType__c;
                    objGR.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
                    objGR.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
                    objGR.EmailSubject__c = objGRnewRec.EmailSubject__c;
                    objGR.SFDCServiceFlag__c = objGRnewRec.SFDCServiceFlag__c; 
                    objGR.SFDCTaskCaseId__c = objGRnewRec.SFDCTaskCaseId__c;
                    objGR.Integrate_with_Genesys_Routing__c = true;  
                    objGR.Action__c = 'Cancel';
                    objGR.Action_Reason__c = 'Completed';
                    listTocreateGrecord.add(objGR);
            }
            if(!listTocreateGrecord.IsEmpty()){
                 system.debug('CASEBEFOREDELETE'+listTocreateGrecord);
                Insert listTocreateGrecord ;
                
            } 
			
			}
            
        } catch (Exception ex){
		  system.debug('CASEBEFOREDELETE'+ex);
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            
        }  
        
        
    }
    /*************************************************************
     *author : Rajan Sajani
     * Description : to not allowing csr user to edit closed cases
     *  SdT-29498
     **********************************************************/ 
    public static void showErrorOnCloseCase(Map<Id,Case> newMap){
    
    String loggedInUserProfileName = null; 
    Id UserProfileId = UserInfo.getProfileId();
    loggedInUserProfileName = SystemObjectSelector.getLoggedInUserProfile(UserProfileId );
    
    if(Trigger.IsUpdate && Trigger.IsBefore){
                for(case cse :  newMap.values()){
                    if(!String.isBlank(loggedInUserProfileName) && loggedInUserProfileName == Constant_Util.CUSTOMER_SERVICE && !Test.isRunningTest()){
                        cse.addError(Constant_Util.CLOSE_CASE_ERROR_CSR);
                    }
                    
                }
               
                
            }
  }
    
     public static List<Case> getServiceDateStandard(List<Case> newCaseList){
    
    map<string,case> caseMap = new map<string,case>();
    map<string,case> resultmap = new map<string,case>();
    List<Case> caseList=new List<Case>();
    string container = null;
    string casekey = null;
    DateTime serviceTime = DateTime.newInstance(0, 0, 0, 0, 0, 0);
    string scheduleType = null;
    Boolean isBackDatedCase = false;
    
    try{
        for(Industry_Standard_SLA__mdt sla :Industry_Standard_SLA__mdt.getAll().values()){ 
            industyStandardSLAMap.put(sla.Service__c,sla);
        }
        system.debug('newCaseList>>'+ newCaseList);
        for(Case thisCase :newCaseList){
            if(String.ISBlank(thisCase.Case_Type__c) || (businessIdMap != null && !businessIdMap.isEmpty() && !businessIdMap.containsKey('America/New_York'))){
                system.debug('thisCase.Case_Type__c>>'+ thisCase.Case_Type__c);
                continue;
            }
            if(thisCase.Service_Date__c != null && thisCase.Service_Date__c < date.today()){
                system.debug('thisCase.Service_Date__c>>'+ thisCase.Service_Date__c);
                isBackDatedCase = true;
            }           
            system.debug('thisCase.SlaStartDate1>>'+ thisCase.SlaStartDate);
            thisCase.SlaStartDate = getservicedatetimestandard(System.now(),thisCase);
            system.debug('thisCase.SlaStartDate2>>'+ thisCase.SlaStartDate);
           // parentAccountIdset.add(thisCase.Client__c);
            serviceset.add(thisCase.Case_Sub_Type__c);
           
               // container = casewithContainer != null && casewithContainer.containsKey(thisCase.AssetId) ? casewithContainer.get(thisCase.AssetId).Product2.ProductTypeSelected__c : null;
               // scheduleType = casewithContainer != null && casewithContainer.containsKey(thisCase.AssetId) ? casewithContainer.get(thisCase.AssetId).Duration__c : null;
                casekey = '' + Constant_Util.STAR + '' + Constant_Util.STAR + '' + Constant_Util.STAR + thisCase.Case_Sub_Type__c + Constant_Util.STAR + '';
            
            
            caseMap.put(casekey,thisCase);
            system.debug('caseMap>>'+ caseMap);
        }
        If(!caseMap.isEmpty() && caseMap.size() > 0){
           // casekeywithEntitlementMap = fetchSLA(caseMap);
            DateTime additionalDate;
            Boolean isDay = false;
            Boolean isDefault = false;
            DateTime localdate = null;
            Date targetDate = null;
            Time targetTime = null;
            
            for(String key : caseMap.keySet()){
                additionalDate = null;
                /*SDT-4751 changes start*/
                { 
                    // SDT - 11658
                    String con;
                   
                    // For Non-Pickup 
                    if(String.isNotBlank(CaseMap.get(key).Case_Reason__c) && !CONSTANT_UTIL.PICKUP_CSTYPE.equalsIgnoreCase(CaseMap.get(key).case_type__c) && !CONSTANT_UTIL.NEW_SERVICE.equalsIgnoreCase(CaseMap.get(key).case_type__c) ) {
                        con = CaseMap.get(key).Case_Type__c+Constant_Util.UNDERSCORE+CaseMap.get(key).Case_Sub_Type__c+Constant_Util.UNDERSCORE+CaseMap.get(key).Case_Reason__c;      
                    }
                    
                    isDefault = true;
                    
                    //logic for same day             
                   
                    
                    //logic for Next day
                              
                    
                     if(CaseMap.get(key).SlaStartDate.hourGmt() > 14 || (CaseMap.get(key).SlaStartDate.hourGmt() == 14 && CaseMap.get(key).SlaStartDate.minuteGmt() > 0)){
                        additionalDate = getdatestandard(Constant_Util.AFTER,CaseMap.get(key).SlaStartDate,SERVICETYPE.DAYS ,CaseMap.get(key));
                        serviceTime = getIndustryStandards(Constant_Util.AFTER,con,additionalDate,businessIdMap.get('America/New_York'));
                    }
                    else{
                        System.debug('In else');
                        System.debug('==CaseMap.get(key).SlaStartDate=='+CaseMap.get(key).SlaStartDate);
                        System.debug('==SERVICETYPE.DAYS=='+SERVICETYPE.DAYS);
                        System.debug('==CaseMap.get(key)=='+CaseMap.get(key));
                        additionalDate = getdatestandard(Constant_Util.BEFORE,CaseMap.get(key).SlaStartDate,SERVICETYPE.DAYS ,CaseMap.get(key));
                        System.debug('==additionalDate=='+additionalDate);
                        serviceTime = getIndustryStandards(Constant_Util.BEFORE,con,additionalDate,businessIdMap.get('America/New_York'));
                    }
                }
                
                /*SDT-4751 Changes End*/
                If(!CaseMap.IsEmpty() && String.isNotBlank(CaseMap.get(Key).SLA_Override_Reason__c) && Constant_Util.SLA_OVERRIDE_REASON.equals(CaseMap.get(Key).SLA_Override_Reason__c) && CaseMap.get(key).SLA_Service_Date_Time__c != null){
                    continue;
                }
                else If(((!CaseMap.IsEmpty()  && CaseMap.get(Key).Service_Date__c!=null && serviceTime.date()!= CaseMap.get(Key).Service_Date__c && serviceTime.date() < CaseMap.get(Key).Service_Date__c&& !Constant_Util.SLA_OVERRIDE_REASON.equals(CaseMap.get(Key).SLA_Override_Reason__c) && String.isNotBlank(CaseMap.get(Key).SLA_Override_Reason__c)) || isBackDatedCase ) && CaseMap.get(Key).Source_System__c != Constant_Util.ACORN) {
                    targetDate = Date.newInstance((CaseMap.get(Key).Service_Date__c).year(), (CaseMap.get(Key).Service_Date__c).month(), (CaseMap.get(Key).Service_Date__c).day());
                    targetTime = Time.newInstance(21, 0, 0, 0);
                    CaseMap.get(Key).SLA_Service_Date_Time__c = getadditionalDate(targetDate,targetTime,'America/New_York');
                }
                else If(((casekeywithEntitlementMap.get(key) != null && isDay) || isDefault )) {
                    CaseMap.get(key).SLA_Service_Date_Time__c = serviceTime;
                }else {
                    CaseMap.get(key).SLA_Service_Date_Time__c = serviceTime;
                }
                system.debug('Value=====' + string.valueOf(CaseMap.get(key).Service_Date__c));
                If(string.isBlank(string.valueOf(CaseMap.get(key).Service_Date__c))){
                    system.debug('whoami'+CaseMap.get(key).Service_Date__c);
                    localdate = getservicedatetime(ServiceTime,CaseMap.get(key));
                    CaseMap.get(key).Service_Date__c = localdate.dateGmt();
                }      
                
               
                
            }
            //changes Starts for SDT-7641
            for(case c : newCaseList){
                casekey = '' + Constant_Util.STAR + '' + Constant_Util.STAR + '' + Constant_Util.STAR + c.Case_Sub_Type__c + Constant_Util.STAR + '';
                if(CaseMap.containskey(casekey)){
                    c.Service_Date__c = string.isBlank(String.valueof(c.Service_Date__c)) ? CaseMap.get(casekey).Service_Date__c : c.Service_Date__c;
                    c.SLA_Service_Date_Time__c = CaseMap.get(casekey).SLA_Service_Date_Time__c;
                }
                caseList.add(c);
            }
        }
    }
    catch(Exception e){
        //To handle Error in future Sprints
        System.debug('Exception::::'+e.getStackTraceString());
    }
    return caseList;
}
    

    public static Datetime getservicedatetimestandard(Datetime localdate,Case c){
        Timezone tz;
        System.debug('casewithLocation---'+casewithLocation);
         if(c.Case_Type__c == 'Activate' || c.Case_Type__c == 'Modify' || c.Case_Type__c == 'Deactivate'){
tz = Timezone.getTimeZone('America/New_York');
System.debug('tz>>>222'+tz);
localdate = localdate.addSeconds((tz.getOffset(localdate)/1000));
}
        return localdate;
    }
    

    private static DateTime getdatestandard(String Before_After, DateTime SlaStartDate,CaseTriggerHelper.SERVICETYPE service,Case ca){
        DateTime additionalDate;
        Date targetDate;
        Time targetTime;
        
        try{
            switch on service {
                when DAYS {
                    If(Before_After != null && (Constant_Util.BEFORE).equalsIgnorecase(Before_After)){
                        targetDate = Date.newInstance((SlaStartDate).yearGmt(), (SlaStartDate).monthGmt(), (SlaStartDate).dayGmt());
                        targetTime = Time.newInstance(5, 0, 0, 0);
                        additionalDate = getadditionalDate(targetDate,targetTime,'America/New_York');
                    }else {
                        targetDate = Date.newInstance((SlaStartDate).yearGmt(), (SlaStartDate).monthGmt(), ((SlaStartDate).dayGmt())+1);
                        targetTime = Time.newInstance(5, 0, 0, 0);
                        additionalDate = getadditionalDate(targetDate,targetTime,'America/New_York');
                    }
                }
                when HOURS {
                    additionalDate = System.now();
                }
            }
        }
        catch(exception e){
            system.debug('Exception:::::'+e.getStackTraceString());
        }
        return additionalDate;
    }
	
	 public static List<case> updateServiceDateAlwaysRunStandard(List<case> caseNewList,Map<Id,case> oldCasemap,Map<id,Asset> caseWithContainerMap, Map<id,Account> caseWithLocationMap){
        caseWithLocation = new Map<Id,Account>();
        caseWithLocation = caseWithLocationMap;
        casewithContainer = caseWithContainerMap;
        List<case> returncaselst = new List<case>();
        System_Log__c  sysLog = new System_Log__c();
        DateTime slaDateTime = null;
       
        if(businessIdMap.isEmpty() || businessIdMap == null){
            for(BusinessHours b: [select id,TimeZoneSidKey from BusinessHours LIMIT 39999]){
                businessIdMap.put(b.TimeZoneSidKey,b.Id);
                
            }
            //businessIdMap.put('America/test','01m1I000000XaR5QAK');
        }
        returncaselst = CaseTriggerHelper.getServiceDatestandard(caseNewList);
  
        return returncaselst ;
    }
	
	 public static void serviceDatetoSLAstandard(List<case> caseNewList,Map<Id,case> oldCasemap){
        DateTime slaDateTime = null;
        try{
             for(Case c: caseNewList){
                If(c.SLA_Service_Date_Time__c != null){
                    slaDateTime = DateTime.newInstanceGmt(c.SLA_Service_Date_Time__c.dateGmt(), c.SLA_Service_Date_Time__c.TimeGmt());
                    slaDateTime =  getservicedatetimestandard(slaDateTime,c);
                }
              /**  Date targetDate = Date.newInstance(c.Service_Date__c.year(), c.Service_Date__c.month(), c.Service_Date__c.day());
                Time targetTime = Time.newInstance(21, 0, 0, 0);
                c.SLA_Service_Date_Time__c =  getadditionalDate(targetDate,targetTime,'America/New_York');**/
              //  c.Check_Case__c = false;  
              system.debug('createddateofcase>>>'+c.createddate);
             /**    c.SLA_Service_Date_Time__c = c.Service_Date__c;
                c.Check_Case__c = false; **/
                
                Datetime dt = System.now() + .04;
				system.debug('dt>>'+dt);
                String datetimeESTStr = dt.format('yyyy-MM-dd\'T\'HH:mm:ssZ', 'EST');
				system.debug('datetimeESTStr>>>'+datetimeESTStr);
				String[] abc2     = datetimeESTStr.split('T');
				String serDate         =     abc2[0]; 
				system.debug('serDate'+serDate);
                Date sdt = Date.valueOf(serDate);
				system.debug('sdt'+sdt);
				String dtIST = dt.format('yyyy-MM-dd HH:mm:ss', 'IST');
				system.debug('dtIST>>'+dtIST);
				String dtEST = dt.format('HH:mm:ss', 'EST');
				System.debug('dtEST>>' + dtEST);
				String[] abc     = dtEST.split(':');
				String hours         =     abc[0]; 
				system.debug('hours'+hours);
				integer hq = Integer.valueof(hours.trim());
				    
                if(hq<14){
                    if(c.Case_Type__c == 'Activate' || c.Case_Type__c == 'Modify'){
   				    c.SLA_Service_Date_Time__c = sdt;
                    c.Service_Date__c = sdt;
                        c.Check_Case__c = false; 
                    }
                    else{
                        c.SLA_Service_Date_Time__c = sdt + 1;
                    c.Service_Date__c = sdt + 1;
                         c.Check_Case__c = false; 
                    }
                }else{
                    if(c.Case_Type__c == 'Activate' || c.Case_Type__c == 'Modify'){
                          c.SLA_Service_Date_Time__c = sdt + 1;
                    	  c.Service_Date__c = sdt + 1;
                          c.Check_Case__c = false; 
                    }else{
                        c.SLA_Service_Date_Time__c = sdt + 2;
                    	  c.Service_Date__c = sdt + 2;
                          c.Check_Case__c = false; 
                    }
                  
                     }
            }
        }Catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }}


// Update Company Category and Customer PO 
    public static void updateCCandPO(List<case> caseNewList,Map<Id,case> oldCasemap){
        Set<String> caseIds = new Set<String>();
        Map<String,String> mapCC = new Map<String,String>();
        Map<String,String> mapCCode = new Map<String,String>();
        Map<String,String> mapPO = new Map<String,String>();
        Map<Id,String> mapCasePO = new Map<Id,String>();
        for(Case c: caseNewList){
            System.debug('oldCasemap : ' + oldCasemap);
            if( oldCasemap!=null && c.Case_Record_Type__c == Constant_Util.New_Service_Case){
                if(String.isNotEmpty(c.Company_Category__c) && c.Company_Category__c!=oldCasemap.get(c.Id).Company_Category__c){
                    caseIds.add(c.Reference_Number__c);
                    mapCC.put(c.Reference_Number__c, c.Company_Category__c);
                	mapCCode.put(c.Reference_Number__c, c.CompanyCategoryCode__c);
                }
                if(String.isNotEmpty(c.PurchaseOrder_Number__c) && c.PurchaseOrder_Number__c!=oldCasemap.get(c.Id).PurchaseOrder_Number__c){
                    caseIds.add(c.Reference_Number__c);
                	mapPO.put(c.Reference_Number__c, c.PurchaseOrder_Number__c);
                    mapCasePO.put(c.Id,c.PurchaseOrder_Number__c);
                }
            }
        }System.debug('caseIds + ' + caseIds + ' mapCC : ' + mapCC + ' mapPO : ' + mapPO);
        if(!caseIds.isEmpty() && (!mapCC.isEmpty() || !mapPO.isEmpty()) ){
            Set<Id> quoteIds = new Set<Id>();
            Map<String,String> mapCustPO = new Map<String,String>();
            List<SBQQ__QuoteLine__c> updateQuoteLine = new List<SBQQ__QuoteLine__c>();
            List<Quote_Order__c> updateQuoteOrder = new List<Quote_Order__c>();
            List<Task> updateTask = new List<Task>();
            for(SBQQ__QuoteLine__c ql : [Select Id,SBQQ__Quote__r.Case_Number__c,SBQQ__Quote__r.SBQQ__Status__c,CompanyCategoryName__c,CompanyCategoryCode__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c !=null AND SBQQ__Quote__r.Case_Number__c =: caseIds]){
                System.debug('ql : : ' + ql);
                if(	ql !=null && (ql.SBQQ__Quote__r.SBQQ__Status__c.containsIgnoreCase('Draft') || ql.SBQQ__Quote__r.SBQQ__Status__c.containsIgnoreCase('Product Configured')) ){
                    if(mapCC.containsKey(ql.SBQQ__Quote__r.Case_Number__c) && ql.CompanyCategoryName__c != mapCC.get(ql.SBQQ__Quote__r.Case_Number__c)){
                       System.debug('inside if ql : : ' + ql);
                        ql.CompanyCategoryName__c = mapCC.get(ql.SBQQ__Quote__r.Case_Number__c);
                       ql.CompanyCategoryCode__c = mapCCode.get(ql.SBQQ__Quote__r.Case_Number__c);
                       updateQuoteLine.add(ql); 
                    }
                    if(!mapPO.isEmpty() && mapPO.containsKey(ql.SBQQ__Quote__r.Case_Number__c)){
                      mapCustPO.put(ql.Id, mapPO.get(ql.SBQQ__Quote__r.Case_Number__c));   
                    }
                }
            }System.debug('updateQuoteLine : ' + updateQuoteLine); System.debug('mapCustPO : ' + mapCustPO);
            if(!mapCustPO.isEmpty()){
                for(Quote_Order__c qo : [Select Id,Service_Type__c,Cust_Ref_Number__c,Service_Quote_Line__c from Quote_Order__c WHERE Service_Quote_Line__c IN : mapCustPO.KeySet()]){
                    System.debug('qo :: ' + qo);
                    if(qo!=null && qo.Service_Type__c == 'Delivery' && mapCustPO.containsKey(qo.Service_Quote_Line__c) && qo.Cust_Ref_Number__c != mapCustPO.get(qo.Service_Quote_Line__c)){
                        qo.Cust_Ref_Number__c = mapCustPO.get(qo.Service_Quote_Line__c);
                    	updateQuoteOrder.add(qo);
                    }
            	}System.debug('updateTask mapCasePO case class : ' + mapCasePO);
                for(Task tsk : [Select Id,WhatId,PurchaseOrder_Number__c from Task WHERE WhatId =: mapCasePO.keySet() AND Subject = 'Obtain Customer Info' AND Status = 'Open']){
                    if(tsk!=null){
                        System.debug('updateTask tsk case class : ' + tsk);
                        tsk.PurchaseOrder_Number__c = mapCasePO.get(tsk.WhatId);
                        updateTask.add(tsk);
                    }
                }
            }System.debug('updateQuoteOrder : ' + updateQuoteOrder);
            if(!updateQuoteLine.isEmpty()){
                update updateQuoteLine;
            }
            if(!updateQuoteOrder.isEmpty()){
                update updateQuoteOrder;
            }System.debug('updateTask case class : ' + updateTask);
            if(!updateTask.isEmpty()){
                update updateTask;
            }
        }
    }
    
    public static void updateNSCCase(Map<Id,case> newCaseMap,Map<Id,case> oldCasemap){
        Set<Id> brIdSet = new Set<Id>();
        Set<String> caseTypeSet = new Set<String>();
        Set<String> caseSubTypeSet = new Set<String>();
        List<Case> caseRecList = new List<Case>();
        system.debug('newCaseMap.values() : ' + newCaseMap.values());
        system.debug('oldCasemap : ' + oldCasemap);
        for(Case cs : newCaseMap.values()){
            system.debug('cs : ' + cs);
            if(oldCasemap!=null && cs.Case_Record_Type__c == Constant_Util.New_Service_Case && cs.Status == Constant_Util.STATUS_NEW && String.isNotBlank(cs.Location__c) && !cs.PurchaseOrder_Required__c && String.isNotBlank(cs.Case_Type__c) && String.isNotBlank(cs.Case_Sub_Type__c) && String.isNotBlank(cs.Case_Reason__c)  && cs.Business_RuleId__c !=null ){
                system.debug('if cs : ' + cs);
                brIdSet.add(cs.Business_RuleId__c);
                caseTypeSet.add(cs.Case_Type__c);
                caseSubTypeSet.add(cs.Case_Sub_Type__c);
            }
        }
        if(!brIdSet.isEmpty() && brIdSet!=null){
            Set<Id> brIds = new Set<Id>();
          //  System.debug('locationId : ' + locationId);
            Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
            for(Business_Rule__c br : [Select Id,Request_Type__c,Service__c,Required_Information__c from Business_Rule__c WHERE Id IN :brIdSet AND  RecordTypeId =: reqInfoRecTypeId AND Required_Information__c!=null  AND Request_Type__c =: caseTypeSet AND Service__c =: caseSubTypeSet ]){
                if(br != null && (br.Required_Information__c.contains(Constant_Util.PO_NUMBER) || br.Required_Information__c.contains(Constant_Util.PROFILE_NUMBER) || br.Required_Information__c.contains(Constant_Util.COMPANY_CATEGORY) )){
                    brIds.add(br.Id);
                }
            }System.debug('brIds : ' + brIds);
            if(!brIds.isEmpty() && brIds !=null){
                for(Case cs : newCaseMap.values()){
                    if(!cs.PurchaseOrder_Required__c){
                        cs.PurchaseOrder_Required__c = true;
                    }
                }
            }
        }
        
    }
	
	 @future(callout=true)
     public static void updateReassignField(Set<Id> caselst){
          List<Case> caseReassignFalse = new List<case>();
          List<Case> caseReassignCheck = [SELECT Id,CheckReassignment__c FROM Case WHERE Id = : caselst];
        for(Case c : caseReassignCheck){
            system.debug('caseReassignCheck1>>>'+c.CheckReassignment__c);
           c.CheckReassignment__c = false;
           caseReassignFalse.add(c);
            system.debug('caseReassignCheck2>>>'+c.CheckReassignment__c);
        }
        update caseReassignFalse;
        system.debug('CheckReassignment__c>>>'+caseReassignCheck);
       
    }
	
	 public static void updateChargeable(Set<Id> caselst) {
        list<case> caseList= new list<case>();
       list<case> caseList2= new list<case>();
        
        try{
             List<Case> caseCharg = new List<case>();
          //List<Case> caseChargeup = [SELECT Id,Chargeable__c,ParentId FROM Case WHERE Id = : caselst];
          //soql 101 issue sprint 8
          List<Case> caseChargeup = SystemObjectSelector.getCasesByIds(caselst);
            System.debug('caseChargeup^^^^ ' +caseChargeup);
        for(Case c : caseChargeup){
            //soql 101 issue sprint 8
            if(c.ParentId != null){
                List<Case> caseChargeup2 = [SELECT Id,Chargeable__c FROM Case WHERE Id = : c.ParentId];
                for(Case c2 : caseChargeup2){
                    c2.Chargeable__c = c.Chargeable__c;
                    caseList2.add(c2);
                }
            }
       
        }update caseList2;
         
        }catch(Exception ex){  // Catch block to catch error messages  
          
        }
    }
    
         public static void updateChargeablechild(Set<Id> caselst) {
        list<case> caseList= new list<case>();
              list<case> caseList2= new list<case>();
        try{
             List<Case> caseCharg = new List<case>();
          //List<Case> caseChargeup = [SELECT Id,Chargeable__c,Reference_Number__c,ParentId FROM Case WHERE Id = : caselst];
        	//soql 101 issue sprint 8
        	List<Case> caseChargeup = SystemObjectSelector.getCasesByIds(caselst);
            for(Case c : caseChargeup){
            List<Case> caseChargeup2 = [SELECT Id,Chargeable__c,Reference_Number__c,ParentId FROM Case WHERE Reference_Number__c = : c.Reference_Number__c];
            for(Case c2 : caseChargeup2){
                if(c2.ParentId != null){
                    c2.Chargeable__c = c.Chargeable__c;
                     caseList2.add(c2);
                }
            }
        }update caseList2;
        }catch(Exception ex){  // Catch block to catch error messages  
          
        }
    }
    
    /*******************************************************************************************************
    * @description Method to get insert comment whenever chargeability field changes
    * @param newcaseList of type List<case>
    * @return void
    * @example
    */
    public static void addCommentForChargeability(List<case> newcaseList){
        try {
            Map<String , Comment_Log_Detail__mdt> commentLogTemplateData = new Map<String , Comment_Log_Detail__mdt>();
            for(Comment_Log_Detail__mdt c : Comment_Log_Detail__mdt.getAll().values()){
                commentLogTemplateData.put(c.DeveloperName , c);
            }
            Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
            Comment_Log_Detail__mdt chargeableMetadata = commentLogTemplateData.get('Case_Chargeability');
            List<Comment__c> commentList = new  List<Comment__c>();
            Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
            for(Case caserec : newcaseList){
                if(chargeableMetadata != null) {
                    String chargeableval = caserec.Chargeable__c != null ? caserec.Chargeable__c : 'None';
                    String commentBody = chargeableMetadata.Comment__c.replaceAll('<Chargeable__c>',chargeableval);
                    Comment__c comment = new Comment__c();
                    comment.Comment__c = commentBody;
                    comment.is_Log__c = false;
                    comment.Case__c = caserec.id;
                    comment.recordTypeId = recordTypeId;
                    comment.Communication_Log_Type_Name__c = 'Internal';
                    comment.Workflow_TeamUser__c = System.UserInfo.getName();
                    comment.Acorn_SUser_ID__c = acornUserId;
                    comment.Type__c = Constant_Util.OBJECT_CASE;
                    comment.Case_Number__c = caserec.CaseNumber;
                    if (String.isNotEmpty(caserec.Tracking_Number__c))  {
                        comment.Acorn_Tracking_Number__c = caserec.Tracking_Number__c;
                    }
                    commentList.add(comment);
                }   
            }
   
            insert commentList; 
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
   //Changes related to SDT-32829
   public static Boolean resetSLAandServiceDate(Case caseRecord,Case oldCaseRecord){
        Boolean resetSla = False;
        // ||(!string.isBlank(caseRecord.Case_Reason__c) && !caseRecord.Case_Reason__c.equals(oldCaseRecord.Case_Reason__c))
     	if(((!string.isBlank(caseRecord.Case_Type__c) && !caseRecord.Case_Type__c.equals(oldCaseRecord.Case_Type__c)) || 
          (!string.isBlank(caseRecord.Case_Sub_Type__c) && !caseRecord.Case_Sub_Type__c.equals(oldCaseRecord.Case_Sub_Type__c)) || 
          (!string.isBlank(caseRecord.Location__c) && !caseRecord.Location__c.equals(oldCaseRecord.Location__c)) ||
          (!string.isBlank(caseRecord.AssetId) && !caseRecord.AssetId.equals(oldCaseRecord.AssetId))))
              {
				resetSla = True;
              }
       Return resetSla;
    }

    // Gunjan Shah - SDT-48583
    public static void createAcornComment(Case caseRecord, Case oldCaseRecord){
        if(caseRecord.SLA_Override_Reason__c != oldCaseRecord.SLA_Override_Reason__c || caseRecord.SLA_Override_Comment__c != oldCaseRecord.SLA_Override_Comment__c) {
            String Comment = '';
            Comment = String.isEmpty(caseRecord.SLA_Override_Reason__c) == false ? Constant_Util.SLA_OVERRIDE_RSN + Constant_Util.COLON + Constant_Util.BLANKSPACE + caseRecord.SLA_Override_Reason__c + '<br/>' : Constant_Util.EMPTY_STRING;
            Comment = Comment + (String.isEmpty(caseRecord.SLA_Override_Comment__c) == false ? Constant_Util.SLA_OVERRIDE_COMMENT + Constant_Util.COLON + Constant_Util.BLANKSPACE + caseRecord.SLA_Override_Comment__c : Constant_Util.EMPTY_STRING);
            AcornController.createAcornComment(Comment, caseRecord.Id);
            
        }
    }

}
