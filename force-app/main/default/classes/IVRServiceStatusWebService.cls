/*************************************************************
@Name: IVRServiceStatusWebService
@Author: Kalaiselvi R
@CreateDate: 7/16/2019
@Description: Apex webservice to get WorkOrder and Service Status information
@UsedBy: SDT-7342
**************************************************************/
@RestResource(urlMapping='/ServiceStatus/V1/*')
global with sharing class IVRServiceStatusWebService {
    
    public static Boolean isSandbox = true;
    static {
        isSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
    }
    /**
    * @description Get WorkOrder & service status information, return WorkOrder & service status Information
    **/
    @HttpPost
    global static void getWorkOrder(){
        //Initialize RestContext
        RestResponse outboundResponse = RestContext.response;
        RestRequest inboundRequest = RestContext.request;
        
        Integer refNumSearchLimit = Integer.valueOf(System.Label.DB_Query_4_Ref_Num_Search_Limit);
        Set<String> woStatusSet = new Set<String>();
        woStatusSet.addAll(Constant_Util.WO_STATUSES.split(','));
        Set<String> caseStatusSet = new Set<String>();
        caseStatusSet.addAll(Constant_Util.CASE_STATUSES.split(','));
        List<Case> caseLst = new List<Case>();
        List<WorkOrder> workOrderLst = new List<WorkOrder>();
        List<Asset> assetLst = new List<Asset>();
        List<ServiceStatusWrapper> ssWrapper = new List<ServiceStatusWrapper>();
        List<ErrorsWrapper> errorList = new List<ErrorsWrapper>();  
        string ivrStatus = '';
        string promptId = '';
        string startTime = '';
        string endTime = '';
        Map<String, string> etaMap = new Map<String, string>();
        string[] resultArray;
        ServiceStatusResponse serviceStatusResp = new ServiceStatusResponse();   
        try {
            //Get request body
            String jsonRequest = inboundRequest.requestBody.toString();
            //Convert request body to data structure, deserialize JSON
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonRequest);
            
            //Get values from map
            String connectionId = string.valueOf(requestDataMap.get(Constant_Util.CONNECTION_ID));
            string workOrderNumber = string.valueOf(requestDataMap.get(Constant_Util.WONUMBER));
            string referenceNumber = string.valueOf(requestDataMap.get(Constant_Util.REF_NUMBER));
            string locationCode = string.valueOf(requestDataMap.get(Constant_Util.LOCATIONCODE));
            
            if(String.isNotBlank(referenceNumber) && !referenceNumber.equalsIgnoreCase('Null')){
                caseLst = [SELECT CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c, Status,
                           Asset.Product2.Name, Case_Sub_Status__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Asset.Material_Prompt_ID__c, 
                           SLA_Service_Date_Time__c, Location__r.tz__Timezone_SFDC__c FROM Case WHERE Reference_Number__c =: referenceNumber 
                           AND Status IN: caseStatusSet AND Work_Order__c != null AND (Service_Date__c = TODAY OR Service_Date__c = null) 
                           ORDER BY CreatedDate DESC LIMIT: refNumSearchLimit];
                //Today
                if(caseLst.size() < refNumSearchLimit){
                    caseLst = new List<case>();
                    workOrderLst = [SELECT case.CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c,        
                                    Vendor_Exception_Reason__c, Vendor_Service_Status__c, Rescheduled_Date__c, case.Status, Asset.Product2.Name, 
                                    case.Case_Sub_Status__c, Case_Type__c, Case_Subtype__c, Asset.Material_Prompt_ID__c, Actual_Service_Date__c,
                                    Case_Reason__c, case.SLA_Service_Date_Time__c, Acorn_WorkOrder_Number__c, IVR_Specific_Exception_Reason__c, 
                                    Service_Exception_Received_Date_Time__c, case.Location__c, Status, Asset.Product2.Voice_Prompt__c, 
                                    Asset.Acorn_SBID__c, Asset.Voice_Prompt__c, Vendor_Account_Id__r.Parent_Vendor_ID__c, case.Location__r.tz__Timezone_SFDC__c 
                                    FROM WorkOrder WHERE Case_Type__c =: Constant_Util.PICKUP_CSTYPE AND case.Reference_Number__c =: referenceNumber AND   
                                    Is_Bypass__c = false AND Service_Date__c = TODAY AND case.Status IN: caseStatusSet AND Status IN: woStatusSet 
                                    ORDER BY CreatedDate DESC LIMIT: refNumSearchLimit];
                    if(workOrderLst.size() > 0){
                        etaMap = IVRServiceStatusETA.ETACallout(Constant_Util.WORK_ORDER_ETA,workOrderLst, null);
                    }
                    if(workOrderLst.size() < refNumSearchLimit) {
                        Integer maxCount = refNumSearchLimit - workOrderLst.size();
                        if(maxCount > 0) {
                            List<WorkOrder> woServiceDatePastLst = [SELECT case.CaseNumber, AssetId, asset.Material_Type__c,Service_Date__c, Case_Type__c,
                                                                    Vendor_Exception_Reason__c, Vendor_Service_Status__c, Rescheduled_Date__c, Case.Status, Status,
                                                                    case.Case_Sub_Status__c, Case_Subtype__c, Case_Reason__c, Asset.Material_Prompt_ID__c, Actual_Service_Date__c,
                                                                    Asset.Product2.Container_Prompt_ID__c, Asset.Product2.Name, case.SLA_Service_Date_Time__c,Acorn_WorkOrder_Number__c, 
                                                                    Asset.Acorn_SBID__c, IVR_Specific_Exception_Reason__c, Service_Exception_Received_Date_Time__c, case.Location__c,
                                                                    Asset.Product2.Voice_Prompt__c, Asset.Voice_Prompt__c, Vendor_Account_Id__r.Parent_Vendor_ID__c, case.Location__r.tz__Timezone_SFDC__c 
                                                                    FROM WorkOrder WHERE Is_Bypass__c = false AND Status IN: woStatusSet AND Service_Date__c < TODAY 
                                                                    AND case.Reference_Number__c =: referenceNumber AND case.Status IN: caseStatusSet ORDER BY Service_Date__c DESC, CreatedDate 
                                                                    DESC LIMIT: maxCount];
                            workOrderLst.addAll(woServiceDatePastLst);
                        }
                    }
                    if(workOrderLst.size() < refNumSearchLimit) {
                        Integer maxCount = refNumSearchLimit - workOrderLst.size();
                        if(maxCount > 0) {
                            List<WorkOrder> woServiceDateFutureLst = [SELECT case.CaseNumber, AssetId, asset.Material_Type__c,Service_Date__c, Case_Type__c,
                                                                      Vendor_Account_Id__r.Parent_Vendor_ID__c, Status, Actual_Service_Date__c, case.Location__c, Case_Subtype__c,
                                                                      Vendor_Exception_Reason__c, Vendor_Service_Status__c, Rescheduled_Date__c, Case.Status, Acorn_WorkOrder_Number__c,
                                                                      case.Case_Sub_Status__c,  Case_Reason__c, Asset.Material_Prompt_ID__c, Asset.Product2.Container_Prompt_ID__c, 
                                                                      Asset.Product2.Name, case.SLA_Service_Date_Time__c, Asset.Product2.Voice_Prompt__c, Asset.Voice_Prompt__c, 
                                                                      case.Location__r.tz__Timezone_SFDC__c, Asset.Acorn_SBID__c, IVR_Specific_Exception_Reason__c, Service_Exception_Received_Date_Time__c
                                                                      FROM WorkOrder WHERE Is_Bypass__c = false AND Status IN: woStatusSet AND Service_Date__c > TODAY AND case.Reference_Number__c =: referenceNumber AND case.Status IN: caseStatusSet  
                                                                      ORDER BY Service_Date__c, CreatedDate DESC LIMIT: maxCount];
                            workOrderLst.addAll(woServiceDateFutureLst);
                        }
                    }
                    if(workOrderLst.size() < refNumSearchLimit){
                        Integer maxCount = refNumSearchLimit - workOrderLst.size();
                        if(maxCount > 0) {
                            caseLst = [SELECT CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c, Status,
                                       Asset.Product2.Name, Case_Sub_Status__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Asset.Material_Prompt_ID__c, 
                                       SLA_Service_Date_Time__c, Location__r.tz__Timezone_SFDC__c FROM Case WHERE Reference_Number__c =: referenceNumber AND
                                       Status IN: caseStatusSet AND Work_Order__c = '' ORDER BY CreatedDate DESC LIMIT: maxCount];
                        }
                    }
                } else {
                    caseLst = new List<case>();
                    caseLst = [SELECT CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c, Status,
                               Asset.Product2.Name, Case_Sub_Status__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Asset.Material_Prompt_ID__c, 
                               SLA_Service_Date_Time__c, Location__r.tz__Timezone_SFDC__c FROM Case WHERE Reference_Number__c =: referenceNumber AND 
                               Work_Order__c = '' AND Status IN: caseStatusSet AND (Service_Date__c = TODAY OR Service_Date__c = null) ORDER BY CreatedDate 
                               DESC LIMIT 3];
                    workOrderLst = [SELECT case.CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c,        
                                    Vendor_Exception_Reason__c, Vendor_Service_Status__c, Rescheduled_Date__c, case.Status, Asset.Product2.Name, 
                                    case.Case_Sub_Status__c, Case_Type__c, Case_Subtype__c, Asset.Material_Prompt_ID__c, Actual_Service_Date__c,
                                    Case_Reason__c, case.SLA_Service_Date_Time__c, Acorn_WorkOrder_Number__c, IVR_Specific_Exception_Reason__c, 
                                    Service_Exception_Received_Date_Time__c, case.Location__c, Status, Asset.Product2.Voice_Prompt__c, 
                                    Asset.Acorn_SBID__c, Asset.Voice_Prompt__c, Vendor_Account_Id__r.Parent_Vendor_ID__c, case.Location__r.tz__Timezone_SFDC__c
                                    FROM WorkOrder WHERE Case_Type__c =: Constant_Util.PICKUP_CSTYPE AND case.Reference_Number__c =: referenceNumber AND   
                                    Is_Bypass__c = false AND case.Status IN: caseStatusSet AND Status IN: woStatusSet AND (case.Service_Date__c = TODAY 
                                                                                                                           OR case.Service_Date__c = null) ORDER BY CreatedDate DESC LIMIT 3];
                    if(workOrderLst.size() > 0){
                        etaMap = IVRServiceStatusETA.ETACallout(Constant_Util.WORK_ORDER_ETA,workOrderLst, null);
                    }
                }    
            } else if(String.isNotBlank(locationCode) && !locationCode.equalsIgnoreCase('Null')) {
                workOrderLst = [SELECT Id, case.CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c,        
                                Vendor_Exception_Reason__c, Vendor_Service_Status__c, Rescheduled_Date__c, case.Status, Asset.Product2.Name,
                                case.Case_Sub_Status__c, Case_Type__c, Case_Subtype__c, Case_Reason__c, Asset.Material_Prompt_ID__c, Status,
                                Actual_Service_Date__c, case.SLA_Service_Date_Time__c, Acorn_WorkOrder_Number__c, IVR_Specific_Exception_Reason__c, 
                                Service_Exception_Received_Date_Time__c, Asset.Acorn_SBID__c, case.Location__c, Vendor_Account_Id__r.AccountNumber,
                                Vendor_Account_Id__r.ParentID, Vendor_Account_Id__r.Vendor_ID__c,Asset.Product2.Voice_Prompt__c, 
                                case.Location__r.tz__Timezone_SFDC__c, Asset.Voice_Prompt__c, Vendor_Account_Id__r.Parent_Vendor_ID__c FROM WorkOrder  
                                WHERE case.Location__r.name =: locationCode AND Service_Date__c = TODAY AND Is_Bypass__c = false AND 
                                Status IN: woStatusSet AND case.Status IN: caseStatusSet ORDER BY CreatedDate DESC LIMIT 49999];
                if(workOrderLst.isEmpty()) {                
                    assetLst = [SELECT Id, Acorn_SBID__c, Is_Active__c, Location__r.name, Product2.Voice_Prompt__c, Voice_Prompt__c, Service_Header_Id__c,
                                Product2.Container_Prompt_ID__c, Material_Prompt_ID__c, Product2.Name, Material_Type__c, Location__r.tz__Timezone_SFDC__c  
                                FROM Asset where RecordType.Name =: Constant_Util.SERVICE_DETAIL AND Is_Active__c = true AND Location__r.name =: locationCode
                                AND Acorn_SBID__c != null AND Quantity__c = 1 AND Is_Core_Service__c = true AND ProductFamily =: Constant_Util.COMMERCIAL
                                ORDER BY CreatedDate DESC LIMIT 3];
                    if(!assetLst.isEmpty()) {
                        etaMap = IVRServiceStatusETA.ETACallout(Constant_Util.Get_Service_ETA,null,assetLst);
                    }
                } else {
                    etaMap = IVRServiceStatusETA.ETACallout(Constant_Util.WORK_ORDER_ETA,workOrderLst,null);
                }
                if((assetLst.isEmpty() || assetLst.size() < 3) || (!workOrderLst.isEmpty() && workOrderLst.size() < 3)){
                    Integer maxCount = 3-(workOrderLst.size()+assetLst.size());
                    if(maxCount > 0 ){
                        List<WorkOrder> woServiceDatePastLst = [SELECT case.CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Case_Subtype__c,
                                                                Vendor_Exception_Reason__c, Vendor_Service_Status__c, Rescheduled_Date__c, Case.Status, Status, Case_Type__c,
                                                                case.Case_Sub_Status__c,Asset.Product2.Container_Prompt_ID__c,Asset.Material_Prompt_ID__c,Actual_Service_Date__c,
                                                                Case_Reason__c, Asset.Product2.Name, case.SLA_Service_Date_Time__c, Acorn_WorkOrder_Number__c, Asset.Acorn_SBID__c,
                                                                IVR_Specific_Exception_Reason__c, Service_Exception_Received_Date_Time__c, case.Location__c, case.Location__r.name, 
                                                                Asset.Product2.Voice_Prompt__c, Vendor_Account_Id__r.Parent_Vendor_ID__c, case.Location__r.tz__Timezone_SFDC__c,
                                                                Asset.Voice_Prompt__c FROM WorkOrder WHERE Is_Bypass__c = false AND case.Location__r.name =: locationCode AND 
                                                                Status IN: woStatusSet AND case.Status IN: caseStatusSet AND Service_Date__c = LAST_N_DAYS:3 AND Service_Date__c != TODAY
                                                                ORDER BY Service_Date__c DESC, CreatedDate DESC LIMIT: maxCount];
                        workOrderLst.addAll(woServiceDatePastLst);
                        
                    }
                    if((workOrderLst.size()+assetLst.size()) < 3) {
                        Integer maxWoFutureCount = 3-(workOrderLst.size()+assetLst.size());
                        if(maxWoFutureCount > 0 ){
                            List<WorkOrder> woServiceDateFutureLstLst = [SELECT case.CaseNumber, AssetId, asset.Material_Type__c,Service_Date__c, 
                                                                         Vendor_Exception_Reason__c, Vendor_Service_Status__c, Rescheduled_Date__c, Case.Status, Status, Case_Type__c,
                                                                         case.Case_Sub_Status__c,Asset.Product2.Container_Prompt_ID__c,Asset.Material_Prompt_ID__c,Actual_Service_Date__c,
                                                                         Case_Reason__c, Asset.Product2.Name, case.SLA_Service_Date_Time__c, Acorn_WorkOrder_Number__c, Asset.Acorn_SBID__c,
                                                                         IVR_Specific_Exception_Reason__c, Service_Exception_Received_Date_Time__c, case.Location__c, case.Location__r.name, 
                                                                         Asset.Product2.Voice_Prompt__c, Asset.Voice_Prompt__c, Vendor_Account_Id__r.Parent_Vendor_ID__c, Case_Subtype__c,
                                                                         case.Location__r.tz__Timezone_SFDC__c FROM WorkOrder WHERE Is_Bypass__c = false AND case.Location__r.name =: locationCode
                                                                         AND Status IN: woStatusSet AND case.Status IN: caseStatusSet AND Service_Date__c = NEXT_N_DAYS:3 AND 
                                                                         Service_Date__c != TODAY ORDER BY Service_Date__c, CreatedDate DESC LIMIT: maxWoFutureCount];
                            workOrderLst.addAll(woServiceDateFutureLstLst);    
                        }
                    }
                    if((workOrderLst.size()+assetLst.size()) < 3) {
                        Integer maxCaseCount = 3 - (workOrderLst.size() + assetLst.size());
                        caseLst = new List<case>();
                        if(maxCaseCount > 0 ){
                            caseLst = [SELECT CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c, Status,
                                       Asset.Product2.Name, Case_Sub_Status__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Asset.Material_Prompt_ID__c, 
                                       SLA_Service_Date_Time__c, Location__r.tz__Timezone_SFDC__c FROM Case WHERE case.Location__r.name =: locationCode AND 
                                       Status IN: caseStatusSet AND Work_Order__c = '' AND (Service_Date__c = TODAY OR Service_Date__c = null) ORDER BY 
                                       CreatedDate DESC LIMIT: maxCaseCount];
                        }
                    }
                    if((assetLst.size() + workOrderLst.size() + caseLst.size()) < 3) {
                        Integer maxPastCaseCount = 3 - (assetLst.size() + workOrderLst.size() + caseLst.size());
                        if(maxPastCaseCount > 0 ){
                            List<case> casePastLst = [SELECT CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c, 
                                                      Asset.Product2.Name, Case_Sub_Status__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Asset.Material_Prompt_ID__c, 
                                                      SLA_Service_Date_Time__c, Location__r.tz__Timezone_SFDC__c, Status FROM Case WHERE case.Location__r.name =: locationCode AND 
                                                      Status IN: caseStatusSet AND Work_Order__c = '' AND Service_Date__c = LAST_N_DAYS:3 AND Service_Date__c != TODAY ORDER BY 
                                                      Service_Date__c DESC, CreatedDate DESC LIMIT: maxPastCaseCount];
                            caseLst.addAll(casePastLst);
                        }
                    }
                    if((assetLst.size() + workOrderLst.size() + caseLst.size()) < 3) {
                        Integer maxFutureCaseCount = 3 - (assetLst.size() + workOrderLst.size() + caseLst.size());
                        if(maxFutureCaseCount > 0){
                            List<case> caseFutureLst = [SELECT CaseNumber, AssetId, asset.Material_Type__c, Service_Date__c, Asset.Product2.Container_Prompt_ID__c, 
                                                        Status, Asset.Product2.Name, Case_Sub_Status__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, Asset.Material_Prompt_ID__c, 
                                                        SLA_Service_Date_Time__c, Location__r.tz__Timezone_SFDC__c FROM Case WHERE case.Location__r.name =: locationCode AND 
                                                        Status IN: caseStatusSet AND Work_Order__c = '' AND Service_Date__c = NEXT_N_DAYS:3 AND Service_Date__c != TODAY ORDER BY 
                                                        Service_Date__c, CreatedDate DESC LIMIT: maxFutureCaseCount];
                            caseLst.addAll(caseFutureLst);
                        }   
                    }
                }
            } else{}
            
            serviceStatusWrapper serviceStatusValues;
            List<String> caseInputValues = new List<String>();
            Map<String,String> promptResponse = new Map<String,String>();
            List<String> materialTypeValues = new List<String>();
            Map<String,String> materialPromptResp = new Map<String,String>();
            string[] promptResponseArray;
            string promptName = '';
            string[] materialResponseArray;
            string materialPrompVal = '';
            string materialPromptId = '';
            Date actualCompletionDate;
            string actualCompletionTime;
            Date serviceExcepDate;
            string serviceExcepTime;
            
            if(workOrderLst.size() > 0) {
                for(WorkOrder wo: workOrderLst){
                    caseInputValues.add(wo.Case_Type__c+'_'+wo.Case_Subtype__c+'_'+wo.Case_Reason__c);
                    materialTypeValues.add(wo.asset.Material_Type__c);
                }
                promptResponse = GetIVRCasePrompt.getIVRPrompt(caseInputValues);
                materialPromptResp = GetIVRCasePrompt.getMaterialPromptID(materialTypeValues);
                
                for(WorkOrder wo: workOrderLst){
                    if(!string.isBlank(wo.Vendor_Service_Status__c) && wo.Vendor_Service_Status__c.equalsIgnoreCase('Rescheduled')){
                        ivrStatus = 'Rescheduled';
                    } else if(!string.isBlank(wo.Vendor_Service_Status__c) && wo.Vendor_Service_Status__c.equalsIgnoreCase('Confirmed Positive')){
                        ivrStatus = 'Completed';
                    } else if(!string.isBlank(wo.Vendor_Service_Status__c) && wo.Vendor_Service_Status__c.equalsIgnoreCase('Confirmed Negative')){
                        ivrStatus = 'Not Completed';
                    } else if(string.isBlank(wo.Vendor_Service_Status__c) && wo.Service_Date__c < system.today()){
                        ivrStatus = 'Past';
                    } else if(string.isBlank(wo.Vendor_Service_Status__c) && wo.Service_Date__c >= system.today()){
                        ivrStatus = 'Future';
                    } else {}
                    string caseInput = wo.Case_Type__c+'_'+wo.Case_Subtype__c+'_'+wo.Case_Reason__c;
                    if(promptResponse.ContainsKey(caseInput.toLowerCase())){
                        string promptValues = promptResponse.get(caseInput.toLowerCase());
                        if(!string.isBlank(promptValues)){
                            promptResponseArray = promptValues.split('_');
                            promptName = promptResponseArray[0];
                            promptId = promptResponseArray[1];
                        } 
                    }
                    //default value for material prompt
                    materialPromptId = Constant_Util.STR_MATERIAL_PROMPT_ID;
                    materialPrompVal = wo.asset.Material_Type__c;
                    if(materialPromptResp.ContainsKey((wo.asset.Material_Type__c).toLowerCase())){
                        string materialValues = materialPromptResp.get((wo.asset.Material_Type__c).toLowerCase());
                        if(!string.isBlank(materialValues)){
                            materialResponseArray = materialValues.split('_');
                            materialPromptId = materialResponseArray[0];
                            materialPrompVal = materialResponseArray[1];
                        } 
                    }
                    if(etaMap.containskey(wo.Id)){
                        string result = etaMap.get(wo.Id);
                        if(!string.isBlank(result) && !result.contains('Bad Request')){
                            resultArray = result.split('-');
                            if(resultArray != null && resultArray.size() > 0){
                                StartTime = resultArray[0];
                            }
                            if(resultArray != null && resultArray.size() > 1){
                                EndTime = resultArray[1];
                            }
                        }
                    }
                    Time serviceTime = Time.newInstance(00, 00, 00, 000);//12 AM
                    if(wo.Actual_Service_Date__c != null) {
                        actualCompletionDate = wo.Actual_Service_Date__c.date(); 
                        if(wo.Actual_Service_Date__c.time() != serviceTime) {
                            actualCompletionTime = wo.Actual_Service_Date__c.format('kk:mm');
                        }
                    }
                    if(wo.Service_Exception_Received_Date_Time__c != null){
                        serviceExcepDate = wo.Service_Exception_Received_Date_Time__c.date();
                        serviceExcepTime = wo.Service_Exception_Received_Date_Time__c.format('kk:mm');
                    }
                    date rescheduledDate;
                    date SLAServiceDate;
                    if(wo.Rescheduled_Date__c != null){
                        rescheduledDate = wo.Rescheduled_Date__c.date(); 
                    }
                    if(wo.case.SLA_Service_Date_Time__c != null){
                        SLAServiceDate = wo.case.SLA_Service_Date_Time__c.date(); 
                    }
                    string containerPromptId = wo.Asset.Product2.Container_Prompt_ID__c;
                    if(!String.isBlank(promptId) && !String.isBlank(promptName) && !String.isBlank(containerPromptId)
                       && !promptId.equalsIgnoreCase('Null') && !promptName.equalsIgnoreCase('Null') && !containerPromptId.equalsIgnoreCase('Null')) {
                           serviceStatusValues = new serviceStatusWrapper(promptId, promptName, string.valueOf(wo.AssetId), containerPromptId, 
                                                                          wo.Asset.Product2.Name, materialPromptId, materialPrompVal, wo.Service_Date__c,
                                                                          ivrStatus, wo.IVR_Specific_Exception_Reason__c, startTime, endTime, actualCompletionDate,
                                                                          actualCompletionTime, rescheduledDate, string.valueOf(wo.CaseId), wo.case.CaseNumber,
                                                                          wo.case.Status, wo.case.Case_Sub_Status__c, SLAServiceDate, serviceExcepDate,
                                                                          serviceExcepTime);
                           ssWrapper.add(serviceStatusValues);
                       }
                }
                serviceStatusResp.RecordCount = ssWrapper.size();
            } 
            if(caseLst.size() >0){
                for(Case c : caseLst){
                    caseInputValues.add(c.Case_Type__c+'_'+c.Case_Sub_Type__c+'_'+c.Case_Reason__c);
                    materialTypeValues.add(c.asset.Material_Type__c);
                }
                promptResponse = GetIVRCasePrompt.getIVRPrompt(caseInputValues);
                materialPromptResp = GetIVRCasePrompt.getMaterialPromptID(materialTypeValues);
                
                for(Case c : caseLst){
                    string caseInput = c.Case_Type__c+'_'+c.Case_Sub_Type__c+'_'+c.Case_Reason__c;
                    if(promptResponse.ContainsKey(caseInput.toLowerCase())) {
                        string promptValues = promptResponse.get(caseInput.toLowerCase());
                        if(!string.isBlank(promptValues)){
                            promptResponseArray = promptValues.split('_');
                            promptName = promptResponseArray[0];
                            promptId = promptResponseArray[1];
                        } 
                    }
                    //default value for material prompt
                    materialPromptId = Constant_Util.STR_MATERIAL_PROMPT_ID;
                    materialPrompVal = c.asset.Material_Type__c;
                    if(!string.isBlank(c.asset.Material_Type__c) && materialPromptResp.ContainsKey((c.asset.Material_Type__c).toLowerCase())){
                        string materialValues = materialPromptResp.get((c.asset.Material_Type__c).toLowerCase());
                        if(!string.isBlank(materialValues)){
                            materialResponseArray = materialValues.split('_');
                            materialPromptId = materialResponseArray[0];
                            materialPrompVal = materialResponseArray[1];
                        } 
                    }
                    string containerPromptId = c.Asset.Product2.Container_Prompt_ID__c;
                    if(!String.isBlank(promptId) && !String.isBlank(promptName) && !String.isBlank(containerPromptId)
                       && !promptId.equalsIgnoreCase('Null') && !promptName.equalsIgnoreCase('Null') && !containerPromptId.equalsIgnoreCase('Null')) {
                           serviceStatusValues = new serviceStatusWrapper(promptId, promptName, string.valueOf(c.AssetId), containerPromptId, 
                                                                          c.Asset.Product2.Name, materialPromptId, materialPrompVal, c.Service_Date__c,
                                                                          'No WO', null, null, null, null, null, null, string.valueOf(c.Id), c.CaseNumber,
                                                                          c.Status, c.Case_Sub_Status__c, c.Service_Date__c != null ? c.Service_Date__c : null, null,null);
                           ssWrapper.add(serviceStatusValues);
                       }
                }
                serviceStatusResp.RecordCount = ssWrapper.size();
            }
            if(assetLst.size()>0) {
                for(Asset asset : assetLst){
                    materialTypeValues.add(asset.Material_Type__c);
                }
                materialPromptResp = GetIVRCasePrompt.getMaterialPromptID(materialTypeValues);
                for(Asset asset : assetLst){
                    //default value for material prompt
                    materialPromptId = Constant_Util.STR_MATERIAL_PROMPT_ID;
                    materialPrompVal = asset.Material_Type__c;
                    if(!string.isBlank(asset.Material_Type__c) && materialPromptResp.ContainsKey((asset.Material_Type__c).toLowerCase())){
                        string materialValues = materialPromptResp.get((asset.Material_Type__c).toLowerCase());
                        if(!string.isBlank(materialValues)){
                            materialResponseArray = materialValues.split('_');
                            materialPromptId = materialResponseArray[0];
                            materialPrompVal = materialResponseArray[1];
                        }
                    }
                    if(etaMap.containskey(asset.Id)){
                        string result = etaMap.get(asset.Id);
                        if(!string.isBlank(result) && !result.contains('Bad Request')){
                            resultArray = result.split('-');
                            if(resultArray != null && resultArray.size() > 0){
                                StartTime = resultArray[0];
                            }
                            if(resultArray != null && resultArray.size() > 1){
                                EndTime = resultArray[1];
                            }
                            
                        }
                    }
                    if(!string.isBlank(startTime) && !string.isBlank(endTime) && !startTime.equalsIgnoreCase('Null')
                       && !endTime.equalsIgnoreCase('Null')) {
                           serviceStatusValues = new serviceStatusWrapper(Constant_Util.STR_PROMPT_ID, Constant_Util.PICKUP_CSTYPE, asset.Service_Header_Id__c, 
																		asset.Product2.Container_Prompt_ID__c, asset.Product2.Name, materialPromptId, materialPrompVal, system.today(), 
																		Constant_Util.STR_FUTURE, null, startTime, endTime,null, null, null, null, null, null, null, null, null,null);
                           ssWrapper.add(serviceStatusValues);   
                       }
                }
                serviceStatusResp.RecordCount = ssWrapper.size();
            }
            //Populate response values
            serviceStatusResp.Statuses = new List<ServiceStatusWrapper>();
            serviceStatusResp.Statuses.addAll(ssWrapper);
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(serviceStatusResp));
            outboundResponse.statusCode = 200;
        }
        catch (Exception e) {
            //Populate response values
            errorList.add(new ErrorsWrapper(e.getTypeName(), e.getMessage()));
            serviceStatusResp.Problem = new ErrorMessageWrapper(Constant_Util.EXCEPTION_OCCURRED, Constant_Util.KEYWORD_EXCEPTION, errorList); 
            outboundResponse.addHeader(Constant_Util.CONTENT_TYPE, Constant_Util.JSON_CONTENTTYPE);
            outboundResponse.responseBody = Blob.valueOf(JSON.serialize(serviceStatusResp));     
            outboundResponse.statusCode = 400;
        }   
    }
    /**
    * @description class for ServiceStatusResponse
    */
    global with sharing class ServiceStatusResponse{
        public Integer RecordCount {get;set;}
        public List<ServiceStatusWrapper> Statuses {get;set;}
        public ErrorMessageWrapper Problem {get;set;}
        /**
        * @description Constructor
        */
        public ServiceStatusResponse(){            
            this.RecordCount = 0;
        }
    }
    /**
    * @description class for serviceStatusWrapper
    */
    global with sharing class ServiceStatusWrapper {
        public String ServicePromptId {get;set;}
        public String Service {get;set;}
        public String ContainerId {get;set;}
        public String ContainerPromptId {get;set;}
        public String ContainerName {get;set;}
        public String MaterialPromptId {get;set;}
        public String Material {get;set;}
        public Date ServiceDate {get;set;}
        public String ServiceStatus {get;set;}
        public String ServiceException {get;set;}
        public string StartTime {get;set;}
        public string EndTime {get;set;}
        public Date ActualCompletionDate {get;set;}
        public string ActualCompletionTime {get;set;}
        public Date ReScheduledDate {get;set;}
        public String CaseId {get;set;}
        public String CaseNumber {get;set;}
        public string CaseStatus {get;set;}
        public string CaseSubStatus {get;set;}
        public Date CaseTargetCompletionDate {get;set;}
        public Date ServiceExceptionDate {get;set;}
        public string ServiceExceptionTime {get;set;}
        /**
        * @description Constructor
        */
        public ServiceStatusWrapper(string promptId,string service, String conId, string conPromptId, string conName, string materialPromptId, string material,
                                    Date serviceDate, string ivrStatus, String serviceException, string startTime, string endTime, Date actualCompDate,
                                    string actualCompTime, Date reScheduledDate, String caseId, String caseNumber, string caseStatus, string caseSubStatus,
                                    Date caseTargetCompletionDate, Date serviceExcpDate, string serviceExcpTime) { 
                                        this.ServicePromptId = promptId;
                                        this.Service = service;
                                        this.ContainerId = conId;
                                        this.ContainerPromptId = conPromptId;
                                        this.ContainerName = conName;
                                        this.MaterialPromptId = materialPromptId;
                                        this.Material = material;
                                        this.ServiceDate = serviceDate;
                                        this.ServiceStatus = ivrStatus;
                                        this.ServiceException = serviceException;
                                        this.StartTime = startTime;
                                        this.EndTime = endTime;
                                        this.ActualCompletionDate = actualCompDate;
                                        this.ActualCompletionTime = actualCompTime; 
                                        this.ReScheduledDate = reScheduledDate;
                                        this.CaseId = caseId;
                                        this.CaseNumber = caseNumber;
                                        this.CaseStatus = caseStatus;
                                        this.CaseSubStatus = caseSubStatus;
                                        this.CaseTargetCompletionDate = caseTargetCompletionDate;
                                        this.ServiceExceptionDate = serviceExcpDate;
                                        this.ServiceExceptionTime = serviceExcpTime;
                                    }
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