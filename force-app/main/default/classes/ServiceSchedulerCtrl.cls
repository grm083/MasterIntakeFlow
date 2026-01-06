public class ServiceSchedulerCtrl {
    //TCS-pkulkarn-SDT-39016-Added following variables
    public static final String OCCURENCE_TYPE_ONCALL = 'OC';
    public static final String OCCURENCE_TYPE_SCHEDULED = 'SCH';
    public static final String OCCURENCE_TYPE_SCHEDULED_ON_CALL = 'SOC';
    //TCS-pkulkarn-SDT-39016-End

    //TCS-pkulkarn-SDT-38495-20-May-2024-Added the string variable
    //The validation rule : Validate_Day_of_Month has the same error message. If this error message is changed, please change the error message on validation rule
    public static final String sValidate_Day_of_Month_Error = 'Please provide a value between 1 to 30 for Day of Month';
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c retrieveParentQuoteLine(string parentQLineId){
        List<SBQQ__QuoteLine__c> parentQLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c parentQLine = new SBQQ__QuoteLine__c();
        //SDT-38285 start added Month_Relative_Interval__c,Month_Relative__c
        parentQLineList = [SELECT id, Name, Occurrence_Type__c, Schedule_Frequency__c, Frequency_Interval__c, Service_Days__c, SBQQ__ProductName__c,Day_of_Month__c,
                           ToLabel(Equipment_Size__c), ToLabel(Month_Relative_Interval__c), ToLabel(Month_Relative__c) 
                           FROM SBQQ__QuoteLine__c
                           WHERE id=:parentQLineId];
        if(parentQLineList.size()>0){
            parentQLine = parentQLineList[0];
        }
        return parentQLine;
    }
    @AuraEnabled
    public static string submitOnCall(string qId, string parentQLineId){
        string msg = '';
        if(qId!=null){
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            //SDT-38285 - Add in select query Day_of_Month__c, Month_Relative_Interval__c and Month_Relative__c
            qLineList = [SELECT id, Occurrence_Type__c, SBQQ__ProductFamily__c , Frequency_Interval__c, Schedule_Frequency__c,
                        Equipment_Size__c, SBQQ__ProductName__c,Day_of_Month__c, Month_Relative__c, Month_Relative_Interval__c 
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c=:qId AND (id=:parentQLineId OR (SBQQ__ProductOption__r.Core_Service__c = true AND SBQQ__RequiredBy__c=:parentQLineId))];
            if(qLineList.size()>0){
                for(SBQQ__QuoteLine__c qLine: qLineList){
                    qLine.Occurrence_Type__c = 'OC';
                    qLine.Schedule_Frequency__c = null;
                    qLine.Frequency_Interval__c = null;
                    qLine.Service_Days__c = null;
                    //SDT-38285 - Start                    
                    qLine.Day_of_Month__c = null;
                    qLine.Month_Relative_Interval__c = null;
                    qLine.Month_Relative__c = null;
                    //SDT-38285 - End
                }
                msg = updateQuoteLine(qLineList);
            }
        }
        return msg;
    }
    @AuraEnabled
    public static string submitDailyEveryDay(string qId,string parentQLineId,  string frequecny){
        string msg = '';
        //SDT 30079
        //added if to check number of days value- entered by user is from 1 to 500
        //this will work only from intake screen
        String isAllowedDaysSelected=QuoteLineServices.checkForMaxValueWhileSchedulingDays(frequecny);
        if(isAllowedDaysSelected!=''){
			msg = isAllowedDaysSelected;            
        }else if(qId!=null){
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            //SDT-38285 fetch Day_of_Month__c, Month_Relative_Interval__c, Month_Relative__c 
            qLineList = [SELECT id, Occurrence_Type__c, SBQQ__ProductFamily__c , Frequency_Interval__c, Schedule_Frequency__c,
                        Equipment_Size__c, SBQQ__ProductName__c, Day_of_Month__c, Month_Relative_Interval__c, Month_Relative__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c=:qId AND (id=:parentQLineId OR (SBQQ__ProductOption__r.Core_Service__c = true AND SBQQ__RequiredBy__c=:parentQLineId))];
            if(qLineList.size()>0){
                for(SBQQ__QuoteLine__c qLine: qLineList){
                    qLine.Occurrence_Type__c = getOccurenceType(qLine, parentQLineId, qLineList);	//TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
                    qLine.Frequency_Interval__c = frequecny;
                    qLine.Schedule_Frequency__c = 'D';
                    qLine.Service_Days__c = null;
                    //SDT-38285 set To Null
                    qLine.Day_of_Month__c = null;
                    qLine.Month_Relative_Interval__c = null;
                    qLine.Month_Relative__c = null;
                    //SDT-38285 end
                }
                msg = updateQuoteLine(qLineList);
            }
        }
        return msg;
    }
    @AuraEnabled
    public static string submitDailyEveryWeek(string qId, string parentQLineId){
        string msg = '';
        if(qId!=null){
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            //SDT-38285 fetch Day_of_Month__c, Month_Relative_Interval__c, Month_Relative__c
            qLineList = [SELECT id, Occurrence_Type__c, Frequency_Interval__c, Schedule_Frequency__c, Service_Days__c, SBQQ__ProductFamily__c,
                        Equipment_Size__c, SBQQ__ProductName__c,Day_of_Month__c, Month_Relative_Interval__c, Month_Relative__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c=:qId AND (id=:parentQLineId OR (SBQQ__ProductOption__r.Core_Service__c = true AND SBQQ__RequiredBy__c=:parentQLineId))];
            if(qLineList.size()>0){
                for(SBQQ__QuoteLine__c qLine: qLineList){
                    qLine.Occurrence_Type__c = getOccurenceType(qLine, parentQLineId, qLineList);	//TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
                    qLine.Frequency_Interval__c = null;
                    qLine.Schedule_Frequency__c = 'D';
                    qLine.Service_Days__c = 'M;T;W;T1;F';
                    //SDT-38285 - set To Null
                    qLine.Day_of_Month__c = null;
                    qLine.Month_Relative_Interval__c = null;
                    qLine.Month_Relative__c = null;
                }
                msg = updateQuoteLine(qLineList);
            }
        }
        return msg;
    }
    @AuraEnabled
    public static string submitWeekly(string qId, string parentQLineId, string frequency, string serviceDays){
        string msg = '';
        //SDT 31262
        //added if to check number of weeks value- entered by user is from 1 to 30
        //this will work only from intake screen
        String isAllowedDaysSelected=QuoteLineServices.checkForMaxValueWhileSchedulingWeeks(frequency);
        if(isAllowedDaysSelected!=''){
			msg = isAllowedDaysSelected;            
        }else if(serviceDays =='' || serviceDays==null){
            msg = QuoteLineServices.SERVICE_DAYS_ERROR;
        }else if(qId!=null){
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            //SDT-38285 - Adding Day_Of_Month, Month_Relative_Interval, Month_Relative and set to null
            qLineList = [SELECT id, Occurrence_Type__c, Frequency_Interval__c, Schedule_Frequency__c, Service_Days__c, SBQQ__ProductFamily__c,
                        Equipment_Size__c, SBQQ__ProductName__c, Day_of_Month__c, Month_Relative_Interval__c, Month_Relative__c 
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c=:qId AND (id=:parentQLineId OR (SBQQ__ProductOption__r.Core_Service__c = true AND SBQQ__RequiredBy__c=:parentQLineId))];
            if(qLineList.size()>0){
                for(SBQQ__QuoteLine__c qLine: qLineList){
                    qLine.Occurrence_Type__c = getOccurenceType(qLine, parentQLineId, qLineList);	//TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
                    qLine.Frequency_Interval__c = frequency;
                    qLine.Service_Days__c = serviceDays;
                    qLine.Schedule_Frequency__c = 'W';
                    //SDT-38285 - set to null as not required for weekly
                    qLine.Day_of_Month__c = null;
                    qLine.Month_Relative_Interval__c = null;
                    qLine.Month_Relative__c = null;
                    //SDT-38285 End
                }
                msg = updateQuoteLine(qLineList);
            }
        }
        return msg;
    }
    @AuraEnabled
    public static string submitMonthly(string qId, string parentQLineId, string frequency){
        string msg = '';
        //TCS-pkulkarn-SDT-38495-20-May-2024-Added following line to validate the Frequency Interval field for the Schedule Frequency of Monthly
        String isAllowedMonthsSelected = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly(frequency);
        if(isAllowedMonthsSelected!='')
        {
			msg = isAllowedMonthsSelected;            
        }
        else if(qId!=null)	//TCS-pkulkarn-SDT-38495-20-May-2024-End
        {
            //TCS-pkulkarn-SDT-38495-20-May-2024-Moved the SOQL to QuoteLineSelector class
            List<SBQQ__QuoteLine__c> qLineList = QuoteLineSelector.getQuoteLinesForMonthlyFrequency(qId, parentQLineId);
            if(qLineList.size()>0){
                for(SBQQ__QuoteLine__c qLine: qLineList){
                    qLine.Occurrence_Type__c = getOccurenceType(qLine, parentQLineId, qLineList);	//TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
                    qLine.Frequency_Interval__c = frequency;
                    qLine.Schedule_Frequency__c  = 'M';
                    qLine.Service_Days__c = null;
                    qLine.Day_of_Month__c = null;	//TCS-pkulkarn-SDT-38495-20-May-2024-Added to set Day of Month to null for Monthly schedule
                    //SDT-38285 set to null
                    qLine.Month_Relative_Interval__c = null;
                    qLine.Month_Relative__c = null;
                }
                msg = updateQuoteLine(qLineList);
            }
        }
        return msg;
    }
    @AuraEnabled
    public static string submitMonthlySpecific(string qId, string parentQLineId, string dayOfMonth, string frequency){
        string msg = '';
        //TCS-pkulkarn-SDT-38495-20-May-2024-Added following lines to validate the Frequency Interval field for the Schedule Frequency of Monthly
        String isAllowedMonthsSelected = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly(frequency);	//Check if the Frequency Interval is within the allowed Picklist values
        //TCS-pkulkarn-SDT-38495-20-May-2024-End
        if(isAllowedMonthsSelected != '')
        {
			msg = isAllowedMonthsSelected;            
        }   
        else if(qId != null)	//TCS-pkulkarn-SDT-38495-20-May-2024-End
        {
            try
            {
                //TCS-pkulkarn-SDT-38495-20-May-2024-Moved the SOQL to QuoteLineSelector class and added try block
            	List<SBQQ__QuoteLine__c> qLineList = QuoteLineSelector.getQuoteLinesForMonthlyFrequency(qId, parentQLineId);
                if(qLineList.size()>0){
                    for(SBQQ__QuoteLine__c qLine: qLineList){
                        qLine.Occurrence_Type__c = getOccurenceType(qLine, parentQLineId, qLineList);	//TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
                        qLine.Day_of_Month__c = integer.valueOf(dayOfMonth);
                        qLine.Frequency_Interval__c = frequency;
                        qLine.Schedule_Frequency__c  = 'M';
                        qLine.Service_Days__c = null;
                    }
                    msg = updateQuoteLine(qLineList);
                }
            }
            catch(Exception e)
            {
                msg = e.getMessage();
                system.debug('Error(s) occured : ' + msg);
            }
        }

        //TCS-pkulkarn-SDT-38495-20-May-2024-Added to handle runtime errors
        if(isAllowedMonthsSelected == '' && msg != 'SUCCESS')
        {
            msg = handleRuntimeValidationErrors(msg);
        }

        return msg;
    }
    @AuraEnabled
    public static string submitYearly(string qId, string parentQLineId, string frequency){
        string msg = '';
        if(qId!=null){
            List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
            //SDT-38285 fetch Day_of_Month__c, Month_Relative_Interval__c, Month_Relative__c
            qLineList = [SELECT id, Occurrence_Type__c, Frequency_Interval__c, Schedule_Frequency__c, Service_Days__c, SBQQ__ProductFamily__c,
                         Equipment_Size__c, SBQQ__ProductName__c, Day_of_Month__c, Month_Relative_Interval__c, Month_Relative__c
                         FROM SBQQ__QuoteLine__c 
                         WHERE SBQQ__Quote__c=:qId AND (id=:parentQLineId OR (SBQQ__ProductOption__r.Core_Service__c = true AND SBQQ__RequiredBy__c=:parentQLineId))];
            if(qLineList.size()>0){
                for(SBQQ__QuoteLine__c qLine: qLineList){
                    qLine.Occurrence_Type__c = getOccurenceType(qLine, parentQLineId, qLineList);	//TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
                    qLine.Frequency_Interval__c = frequency;
                    qLine.Schedule_Frequency__c  = 'Y';
                    qLine.Service_Days__c = null;
                    //SDT-38285 - set to null as not required for Yearly
                    qLine.Day_of_Month__c = null;
                    qLine.Month_Relative_Interval__c = null;
                    qLine.Month_Relative__c = null;
                }
                msg = updateQuoteLine(qLineList);
            }
        }
        return msg;
    }
    public static string updateQuoteLine(List<SBQQ__QuoteLine__c> qLineList){
        string msg='';
        try{
            update qLineList;
            msg = 'SUCCESS';
        }
        catch(exception ex){
            msg = ex.getMessage();
        }
        return msg;
    }

    //TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
    public static String getOccurenceType(SBQQ__QuoteLine__c parentLine, String parentQLineId, List<SBQQ__QuoteLine__c> qLineList) {
        String occurrenceType;
        //TCS-pkulkarn-13-Mar-2024-SDT-33176-Added
        if(parentLine.SBQQ__ProductFamily__c == Constant_Util.ROLLOFF)
        {
            occurrenceType = OCCURENCE_TYPE_SCHEDULED_ON_CALL;
        }
        else if(parentLine.SBQQ__ProductFamily__c == Constant_Util.COMMERCIAL)
        {
            occurrenceType = retrieveBundleOccuranceType(parentQLineId, qLineList);
            if(occurrenceType != OCCURENCE_TYPE_SCHEDULED_ON_CALL || occurrenceType == '')
            {
                occurrenceType = OCCURENCE_TYPE_SCHEDULED;
            }
        }
        //TCS-pkulkarn-13-Mar-2024-SDT-33176-End

        //TCS-pkulkarn-13-Mar-2024-SDT-33176-Commented
        /*if (parentLine.SBQQ__ProductName__c == 'Compactor') {
            List<String> splitSize = parentLine.Equipment_Size__c.split('-',2);
            if (splitSize.size() == 2) {
                Integer intSize = integer.valueOf(splitSize[1]);
                occurrenceType = (intSize < 10) ? 'SCH' : 'SOC'; 
            } else {
                occurrenceType = (parentLine.SBQQ__ProductFamily__c == 'Commercial') ? 'SCH' : 'SOC';
            }
        } else {
            //occurrenceType = (parentLine.SBQQ__ProductFamily__c == 'Commercial') ? 'SCH' : 'SOC';
            //SDT 33176
            occurrenceType = parentLine.Occurrence_Type__c;
        }*/
        //TCS-pkulkarn-13-Mar-2024-SDT-33176-End

        return occurrenceType;
    }
    @auraEnabled
    public static string deleteQuoteLine(id quoteLineId){
        string result='SUCCESS';
        try{
            List<SBQQ__QuoteLine__c> qLinesToDelete = [SELECT id FROM SBQQ__QuoteLine__c WHERE id=:quoteLineId OR SBQQ__RequiredBy__c=:quoteLineId OR SBQQ__RequiredBy__r.SBQQ__RequiredBy__c = :quoteLineId];
            delete qLinesToDelete;
        }
        catch(exception ex){
            system.debug('exception is '+ex.getMessage());
            result=ex.getMessage();
        }
        return result;
    }

    /*SDT-21804- 
        Dev: Rishi
        FC: Anmoal Bharti
        Description: added validation for description of waste field on quote line. 
        This validation is only applicable when Quote/Quote lines are being created/updated from CEI screen.
    */
    @AuraEnabled
    public static Map<String,List<String>> validateDescriptionOfWaste(QuoteProcurementController.HeaderWrapper productWrapper){
        try {
            return QuoteProcurementController.validateDescriptionOfWaste(productWrapper);
        } catch (Exception e) {
            List<String> failedList = new List<String>();
            failedList.add(e.getMessage());
            Map<String,List<String>> resultErrorMap = new Map<String,List<String>>();
            resultErrorMap.put('Failed',failedList);
            return resultErrorMap;
        }
    }
    /*
    *  Dev: Nikita
    *  Description: Return Asset Availability API response
    *  User Story : SDT-29100
    */

    @AuraEnabled
    public static AAV_Asset_Availability__c getAvailabilityResponse(String quoteLineId){
        return AAV_APIIntegration.getAvailabilityResponse(quoteLineId);
    }
    /*
    *  Dev: Satnam
    *  Description: Retry Asset Availability API Callout
    *  User Story : SDT-31583
    */
    @AuraEnabled
    public static AAV_Asset_Availability__c retryAvailabilityResponse(String quoteLineId){
        return AAV_APIIntegration.retryAvailabilityResponse(quoteLineId);
    }
    //SDT-29100 - Asset Availability: get Service Override Reasons Picklist Values
    @AuraEnabled
    public static List<String> getServiceOverrideReasons() {
        List<String> serviceOverrideReasons = new List<String>();
        for (Schema.PicklistEntry pick : SBQQ__QuoteLine__c.AAV_Service_Override_Reason__c.getDescribe().getPicklistValues()) 
        {
            if(pick.isActive())
                serviceOverrideReasons.add(pick.getValue());
        }
        return serviceOverrideReasons;
    }

    /*@methodName- updateAdditionalServices
    *@description- When the user chooses to opt for additional services, the aim is to update the additional services field on the Quote line record    *@param- Id : bundleId
    *@return- success
    *@Ticket - SDT-30108
    */  
    @AuraEnabled
    public static string updateAdditionalServices(String bundleId){
        string result;
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, SBQQ__Product__c,AAV_Requested_AdditionalServicesAccessor__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c 
                            FROM SBQQ__QuoteLine__c WHERE Id =:bundleId];
       
        list<SBQQ__QuoteLine__c> supplierList = AAV_AvailabilityUtility.getSelectedServices(bundleId, quoteLine.SBQQ__Product__c);
        //This field is utilized to store the outcome indicating whether a comment already exists or not.
        Boolean isCommentAvailable = true;        
        Comment__c comment;
        String requestedAdditionalServices;
        String caseId = quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c;
             
        if(supplierList != null && supplierList.size() > 0){
            system.debug('quoteLine '+supplierList.size());
            requestedAdditionalServices = 'Requested Additional Services & Accessories';
        } else {
            requestedAdditionalServices = 'NOT Requested Additional Services & Accessories';
        }
        //if change is there on supplier selection then update the quote line record
        try{
            if(quoteLine.AAV_Requested_AdditionalServicesAccessor__c != requestedAdditionalServices){
                quoteLine.AAV_Requested_AdditionalServicesAccessor__c = requestedAdditionalServices;
                update quoteLine;
            }
           
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return result='SUCCESS';
    }

    @AuraEnabled
    public static void saveServiceOverrideOptions(String quoteLineId,String overrideReason,String overrideComment,String serviceStatus,String serviceUnavailable){
        
        List<SBQQ__QuoteLine__c>  quoteLineItems = [SELECT Id, AAV_Service_Override_Reason__c,AAV_Service_Day_Override_Comment__c,AAV_Service_Days_Unavailable__c
        FROM SBQQ__QuoteLine__c 
        WHERE Id =: quoteLineId 
        AND SBQQ__RequiredBy__c = null ];
        if(quoteLineItems != null && quoteLineItems.size() > 0){
            quoteLineItems[0].AAV_Service_Override_Reason__c = overrideReason;
            quoteLineItems[0].AAV_Service_Day_Override_Comment__c = overrideComment;
            quoteLineItems[0].AAV_Service_Availability__c = serviceStatus;   
            quoteLineItems[0].AAV_Service_Days_Unavailable__c = serviceUnavailable;
        }
       update quoteLineItems[0];
    }

    // Method: retrieveBundleOccuranceType
    // Usage : To retrieve the Occurence Type of Bundle Quote Line
    // Defect/Story/Author: TCS-pkulkarn-27-Mar-2024-SDT-33176-Added
    public static String retrieveBundleOccuranceType(Id parentQuoteLineId, List<SBQQ__QuoteLine__c> qLineList)
    {
        String bundleOccuranceType = '';
        for(SBQQ__QuoteLine__c quoteLine : qLineList)
        {
            if(quoteLine.Id == parentQuoteLineId)
            {
                bundleOccuranceType = quoteLine.Occurrence_Type__c;
            }
            if(bundleOccuranceType != '')
                break;
        }

        return bundleOccuranceType;
    }

    //TCS-pkulkarn-SDT-38495-20-May-2024-Added following method to check and return validation errors for Schedule Frequency and Day of Month fields
    public static string handleRuntimeValidationErrors(String msg)
    {
        String strReturnMessage = '';
        if(msg.contains('Invalid integer') || msg.contains('NUMBER_OUTSIDE_VALID_RANGE'))	//Value out of 2 digits range for numeric field
        {
            strReturnMessage = sValidate_Day_of_Month_Error;
        }
        else if(msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
        {
            strReturnMessage = msg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ':');	//Error from custom validation rule for Day of Month field
        }
        else
        {
            strReturnMessage = System.Label.Generic_Error_Message;
        }
        return strReturnMessage;
    }
    //SDT-38285 - start - Fetch Month_Relative_Interval__c picklist values
    @AuraEnabled
    public static List<String> getMonthRelativeInterval() {
        List<String> monthRelativeInterval = new List<String>();
        for (Schema.PicklistEntry pick : Schema.SObjectType.SBQQ__QuoteLine__c.fields.Month_Relative_Interval__c.getPicklistValues()) 
        {
            if(pick.isActive())
                monthRelativeInterval.add(pick.getValue());
        }
        return monthRelativeInterval;
    }
    @AuraEnabled
    public static List<String> getMonthRelative() {
        List<String> monthRelative = new List<String>();
        for (Schema.PicklistEntry pick : Schema.SObjectType.SBQQ__QuoteLine__c.fields.Month_Relative__c.getPicklistValues()) 
        {
            if(pick.isActive())
                monthRelative.add(pick.getValue());
        }
        return monthRelative;
    }
    @AuraEnabled
    public static string submitMonthlyIntervalSpecificNew(string qId, string parentQLineId,string dayOfMonth,string dayFrequency,string monthRelativeInterval,string monthRelative,string relativeFrequency, string radioSelected ){
        string msg = '';
        String frequency;
        if(radioSelected=='ServiceDate'){
            frequency = dayFrequency;
        }else if(radioSelected=='ServiceDay'){
            frequency = relativeFrequency;
        }
        //TCS-pkulkarn-SDT-38495-20-May-2024-Added following lines to validate the Frequency Interval field for the Schedule Frequency of Monthly
        String isAllowedMonthsSelected = QuoteLineServices.checkForMaxValueWhileSchedulingMonthly(frequency);	//Check if the Frequency Interval is within the allowed Picklist values
        //TCS-pkulkarn-SDT-38495-20-May-2024-End
        if(isAllowedMonthsSelected != '')
        {
			msg = isAllowedMonthsSelected;            
        }   
        else if(qId != null)	//TCS-pkulkarn-SDT-38495-20-May-2024-End
        {
            try
            {
                //TCS-pkulkarn-SDT-38495-20-May-2024-Moved the SOQL to QuoteLineSelector class and added try block
            	List<SBQQ__QuoteLine__c> qLineList = QuoteLineSelector.getQuoteLinesForMonthlyFrequency(qId, parentQLineId);
                
                if(qLineList.size()>0){
                    for(SBQQ__QuoteLine__c qLine: qLineList){
                        qLine.Occurrence_Type__c = getOccurenceType(qLine, parentQLineId, qLineList);	//TCS-pkulkarn-27-Mar-2024-SDT-39016-Added parentQLineId and qLineList
                        qLine.Schedule_Frequency__c  = 'M';
                        qLine.Service_Days__c = null;                        
                        if(radioSelected=='ServiceDate'){
                            qLine.Day_of_Month__c = integer.valueOf(dayOfMonth);
                            qLine.Frequency_Interval__c = dayFrequency;
                            qLine.Month_Relative_Interval__c = null;
                        	qLine.Month_Relative__c = null;
                        }else if(radioSelected=='ServiceDay'){
                            qLine.Day_of_Month__c = null;
                            qLine.Month_Relative_Interval__c = monthRelativeInterval;
                        	qLine.Month_Relative__c = monthRelative;
                            qLine.Frequency_Interval__c = relativeFrequency;
                        }
                    }
                    msg = updateQuoteLine(qLineList);
                }
            }
            catch(Exception e)
            {
                msg = e.getMessage();
                system.debug('Error(s) occured : ' + msg);
            }
        }
        
        //TCS-pkulkarn-SDT-38495-20-May-2024-Added to handle runtime errors
        if(isAllowedMonthsSelected == '' && msg != 'SUCCESS')
        {
            msg = handleRuntimeValidationErrors(msg);
        }
		
        return msg;
    }
	/*
     * @Method Name    : getMonthRelatedPickLists
     * @author         : Digdershika Ojha
     * @description    : Fetch pick list values in form of map for month_relative_interval and Month_relative fields from Quote Line
     * @param          : Not Applicable
     * @return         : a Map<String,List<String>>
	 */
    @AuraEnabled
    public static Map<String,List<String>> getMonthRelatedPickLists() {
        Map<String,List<String>> mapOfMonthRelativePickList = new Map<String,List<String>>();
        List<String> monthRelativeInterval = new List<String>();
        List<String> monthRelative = new List<String>();
        monthRelativeInterval = getMonthRelativeInterval();
        monthRelative = getMonthRelative();
        mapOfMonthRelativePickList.put(Constant_Util.MONTH_RELATIVE_INTERVAL,monthRelativeInterval);
        mapOfMonthRelativePickList.put(Constant_Util.MONTH_RELATIVE,monthRelative);
        return mapOfMonthRelativePickList;
    }
	//SDT-38285 - end	
}