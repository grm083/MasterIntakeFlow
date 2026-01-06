/**
* @author Waste Management
* @date 2021
*
* @group Cases
* @group-content ../../ApexDocContent/Cases.htm
*
* @description Trigger Handler on Case that handles all the events and ensuring the field population on Case, 
*			   add related record to case in before/after insert and before/after update.
								 
																
*/                                                               
															   
public without sharing class CaseTriggerHandler {
    
    public static map<id,case> newcasemap = new map<Id,case>();
    public static Map<Id,Asset> casewithContainerMap = new Map<Id,Asset>();
    public static Set<id> containerIdSet = new set<id>();
    public static Map<Id,string> caseContainerMap = new Map<Id,string>();
    public static Map<Id,Account> casewithLocationMap = new Map<Id,Account>();
    public static set<id> locationIdSet = new set<id>();
    public static Map<id,case> caseAssetCreationMap = new Map<id,case>();
    public static Boolean isInsertForLocalAgentId = false;
    private static Map<Id,Account> locationAccountMap = new Map<Id,Account>();
    
    
    /*******************************************************************************************************
* @description Method to handle before insert event of Case
* @param triggerParam of type TriggerParameters
* @return void
* @example
*/  
    Public static void beforeInsert(TriggerParameters triggerParam){
        try{
            List<case> caseNewList = new List<case>();
            casewithContainerMap = new Map<Id,Asset>();
            List<case> processServiceDateList = new List<case>();
            List<case> processCaseSubtypeList = new List<case>();
            List<case> processofficetraxxlst = new List<case>();
            containerIdSet = new set<id>();
            locationIdSet = new set<id>();
            Map<id,Case> caseUpdatedSubtypeMap = new Map<id,Case>();
            Map<id,Case> caseNewMap = new Map<id,Case>();
            Map<id,Case> caseOldMap = new Map<id,Case>();
            List<case> caseServiceDateList = new List<case>();
            Set<id> contactIdSet = new Set<Id>();
            Case caseRecord = new Case();
            casewithLocationMap = new Map<id,Account>();
            

            Id IntegrationRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.Integration_Case).getRecordTypeId();
            
            //String corporateServiceQueueId = [SELECT Id FROM Group WHERE DeveloperName =: Constant_Util.CORPORATESERVICESQUEUE LIMIT 1].Id;
            String DeveloperName = Constant_Util.CORPORATESERVICESQUEUE;
            String corporateServiceQueueId = SystemObjectSelector.getGroupId(DeveloperName); // Soql 101 issue - 6/3/2024
            //System.debug('corporateServiceQueueId ^^^' +corporateServiceQueueId );
            for(sObject sobjVal : triggerParam.newList){
                caseRecord = (Case)sobjVal ;     
                
               /* Added code for migrating workflows to code  */
               if(Test.isRunningTest()){
                        TestDataFactory.createProcessBuilderTOFlow();                       
                }
               Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('Process_Builder_to_Flow');
               If(!codeSwitchSetting.Switch_Off__c){
                WorkFlowMigration.RecreatedWorkOrderSuccessful(caseRecord);
                //WorkFlowMigration.SetReferenceNumber(caseRecord);
                WorkFlowMigration.WorkOrderCreated(caseRecord);
                }
                   
                //Moved from pb node to apex SDT-8433
                if(Constant_Util.CLOSED.equalsIgnoreCase(caseRecord.status) && 
                    CONSTANT_UTIL.PICKUP_CSTYPE.equalsIgnoreCase(caseRecord.case_type__c) && !Constant_Util.SERVICE_NOT_PERFORMED.equalsIgnoreCase(caseRecord.Case_Sub_Status__c) ){
                    caseRecord.Case_Sub_Status__c = Constant_Util.SERVICE_NOT_PERFORMED;
                } 
                if(caseRecord.Case_Type__c == Constant_Util.STATUS_CSTYPE && caseRecord.Source_System__c == Constant_Util.ACORN && caseRecord.Status == Constant_Util.OPEN){
                    caseRecord.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION;
                    caseRecord.Service_Classification__c = caseRecord.Case_Reason__c == Constant_Util.HAULER_REPORTED ? Constant_Util.STANDARD :
                                    caseRecord.Case_Reason__c == Constant_Util.CUSTOMER_REPORTED ? Constant_Util.EMERGENCY : Constant_Util.EMPTY_STRING;
                }
                if(String.isNotBlank(caseRecord.AssetId) && !RecurrsiveTriggerHandler.bypassValidation){
                    processCaseSubtypeList.add(caseRecord);
                    containerIdSet.add(caseRecord.AssetId);
                }                
                if( caseRecord.RecordTypeId != IntegrationRcdType && string.isNotBlank(caseRecord.Location__c)  && String.isNotBlank(caseRecord.Case_Sub_Type__c) && string.isBlank(string.valueOf(caseRecord.SlaStartDate)) && String.isNotBlank(caseRecord.Status)  && Constant_Util.STATUS_New.equals(caseRecord.Status)  
                       && (String.isNotBlank(caseRecord.Client__c))  &&  String.isNotBlank(caseRecord.AssetId) && sla_calculation__c.getValues(caseRecord.Case_type__c) != null  && sla_calculation__c.getValues(caseRecord.Case_type__c).Enabled__c && RecurrsiveTriggerHandler.bypassValidation) {
                           processofficetraxxlst.add(caseRecord);
                           containerIdSet.add(caseRecord.AssetId);
                           locationIdSet.add(caseRecord.Location__c);
                }
                if(String.isNotBlank(caseRecord.Location__c) && !RecurrsiveTriggerHandler.bypassValidation) {    
                    locationIdSet.add(caseRecord.Location__c); 
                }
                if(String.isNotBlank(caseRecord.ContactId)){
                    contactIdSet.add(caseRecord.ContactId);
                }
                if(caseRecord.OwnerId.equals(corporateServiceQueueId) && !caseRecord.BackOffice_Case__c ){
                    caseRecord.BackOffice_Case__c = true;
                }
				
				
                if(caseRecord.Create_AM_and_PM_Pickups__c == true ||  caseRecord.Is_Multivendor__c == true ){
                    caseRecord.Bypass_WO_Duplicate__c = true;
                }
				
                caseNewMap.put(caseRecord.id,caseRecord); 
            }
            
            isInsertForLocalAgentId= true;
            CaseTriggerHelper.UpdateLocalAgentId(caseNewMap,caseOldMap,IsInsertForLocalAgentId);
			CaseTriggerHelper.UpdateCallCentreId(caseNewMap,caseOldMap,IsInsertForLocalAgentId);
            
            if(containerIdSet != null && !containerIdSet.isEmpty()){
                casewithContainerMap = getAssetRecordValue(containerIdSet,true);           
            }        
            if(locationIdSet != null && !locationIdSet.isEmpty()){
                casewithLocationMap = getLocationRecordValue(locationIdSet);
            }
            CaseTriggerHelper.casewithContainer = casewithContainerMap;
            CaseTriggerHelper.casewithLocation = casewithLocationMap;
            if((processCaseSubtypeList!= null && !processCaseSubtypeList.isEmpty()) && 
                (casewithContainerMap != null && !casewithContainerMap.isEmpty()) && 
                (casewithLocationMap != null && !casewithLocationMap.isEmpty())
            ){
                    if(!RecurrsiveTriggerHandler.bypassValidation){
                     
                        caseNewList = CaseTriggerHelper.updateCaseDetails(processCaseSubtypeList,caseOldMap,casewithContainerMap,casewithLocationMap,(Boolean)triggerParam.isInsert);
                        
                    }
                    else{
                       if(caserecord.Case_Type__c != 'Activate' && caserecord.Case_Type__c != 'Modify' && caserecord.Case_Type__c != 'Deactivate'){
         
                      CaseTriggerHelper.updateServiceDateAlwaysRun(processofficetraxxlst,null,casewithContainerMap,casewithLocationMap);
                           CaseTriggerHelper.serviceDatetoSLA(processofficetraxxlst,null);}
                  }
            }
			
			if(caserecord.Case_Type__c == 'Activate' || caserecord.Case_Type__c == 'Modify' || caserecord.Case_Type__c == 'Deactivate'){
                     system.debug('in activate>>');
                   casewithLocationMap = getLocationRecordValueStandardCase();
                     system.debug('in casewithLocationMap>>>'+casewithLocationMap);
processofficetraxxlst.add(caseRecord);
CaseTriggerHelper.updateServiceDateAlwaysRunstandard(processofficetraxxlst,null,null,casewithLocationMap);
CaseTriggerHelper.serviceDatetoSLAstandard(processofficetraxxlst,null);
}
			
            if(!contactIdSet.isEmpty() &&  contactIdset.size()>0){
                CaseTriggerHelper.lastContactActivityDate(contactIdSet);
            }
            CaseTriggerHelper.UpdatePoWithOfficetraxno(triggerParam.newList);
            CaseTriggerHelper.UpdateAndTrimDescription(triggerParam.newList);
            //SDT-13085
            CaseTriggerHelper.PopulateServiceClassification((List<Case>)triggerParam.newList,new map<Id,Case>());
            //SDT-9736 SFDC - Acorn IssueRequestedBy to Salesforce Case - Ali added
            /*
            if(Constant_Util.ACORN.equalsIgnoreCase(caseRecord.Source_System__c) && caseRecord.ContactId == null){
                CaseTriggerHelper.addContactNameTitleCase(caseRecord.Requested_By__c, caseRecord.Client__c, triggerParam.newList);
            }
            */

        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
    /*******************************************************************************************************
    * @description Method to handle before update event of Case
	* @param triggerParam of type TriggerParameters
    * @return void
    * @example
    */  
    public static void beforeUpdate(TriggerParameters triggerParam){
        try{
            List<Case> caseNewList = new List<Case>();
            List<Case> processCaseSubtypeList = new List<Case>();
            Map<Id, Case> oldCaseMap = new Map<Id, Case>();
            Map<Id, Case> caseNewMap = new Map<Id, Case>();
            Map<Id, Case> showErrorMap= new Map<Id, Case>();   //SdT-29498
            
            
            locationIdSet = new set<Id>();
			 Map<Id,Account> casewithLocationMap1 = new Map<id,Account>();
 			Map<Id,Asset> casewithContainerMap1 = new Map<Id,Asset>();
 			List<case> processofficetraxxlst1 = new List<case>();   
			
            Map<Id , Case> parentRecordMap = new Map<Id, Case>();
            Set<String> parentIdList = new Set<String>();     
            //Soql 101 issue fix 
            //String corporateServiceQueueId = [SELECT Id FROM Group WHERE DeveloperName =: Constant_Util.CORPORATESERVICESQUEUE LIMIT 1].Id;
            String DeveloperName = Constant_Util.CORPORATESERVICESQUEUE;
            String corporateServiceQueueId = SystemObjectSelector.getGroupId(DeveloperName); 
            
            Map<Id, Case> caseUpdatedSubtypeMap = new Map<Id,Case>();
            containerIdSet = new Set<Id>();
            Case caseRecord = new Case();
            Id pickupRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.PICKUP).getRecordTypeId();
            Id newServiceRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
            Id IntegrationRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.Integration_Case).getRecordTypeId();
            Id SRCRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.SERVICE_REQUEST_CASE).getRecordTypeId();
            Id InterruptionRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.INTERRUPTION).getRecordTypeId();
            Id StandardRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.STANDARD_CASE).getRecordTypeId();
            Id VendorRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.VENDOR_CASE).getRecordTypeId();
            Id RepairRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.REPAIR).getRecordTypeId();
            
            for(sObject sobjVal : triggerParam.newList){
                caseRecord = (Case)sobjVal;
                if(caseRecord.ParentId != null){
                    parentIdList.add(caseRecord.ParentId);
                }   
                
            /* Added code for migrating workflows to code  */
            if(Test.isRunningTest()){
                        TestDataFactory.createProcessBuilderTOFlow();                       
                }
            Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('Process_Builder_to_Flow');
            If(!codeSwitchSetting.Switch_Off__c) {
                WorkFlowMigration.RecreatedWorkOrderSuccessful(caseRecord);
                WorkFlowMigration.WorkOrderCreated(caseRecord);
                }
            }
            If(!parentIdList.isEmpty()){ //Soql 101 error SDT-40083
                parentRecordMap = new Map<Id,Case>([SELECT Id, Reference_Number__c FROM Case WHERE ID IN :parentIdList]);
            }
            for(sObject sobjVal : triggerParam.newList) {
                caseRecord = (Case)sobjVal; 
                Case oldCaseRecord = (Case)triggerParam.OldMap.get(caseRecord.Id);
                oldCaseMap.put(oldCaseRecord.id, oldCaseRecord);
            
            
                if(!Constant_Util.CLOSED.equalsIgnoreCase(caseRecord.Status) && caseRecord.Close_Irrelevant_Case__c ){
                    caseRecord.Status = Constant_Util.CLOSED;
                }
                
            if(caseRecord != Null && oldCaseRecord != Null){
            
                if(!caseRecord.ownerId.equals(oldCaseRecord.ownerId) && caseRecord.OwnerId.equals(corporateServiceQueueId) && !caseRecord.BackOffice_Case__c ){
                    caseRecord.BackOffice_Case__c = true;
                }
				
				 
                if(((caseRecord.Create_AM_and_PM_Pickups__c != oldCaseRecord.Create_AM_and_PM_Pickups__c) && caseRecord.Create_AM_and_PM_Pickups__c == true) ||  ( (caseRecord.Is_Multivendor__c != oldCaseRecord.Is_Multivendor__c) && (caseRecord.Is_Multivendor__c == true) )){
                    caseRecord.Bypass_WO_Duplicate__c = true;
                }
				
                
             /*   if(!caseRecord.RecordTypeId.equals(oldCaseRecord.RecordTypeId) && !string.isBlank(caseRecord.Case_Type__c) && !string.isBlank(caseRecord.Case_Sub_Type__c) ){
                    caseRecord.Case_Type__c = Constant_Util.EMPTY_STRING;
                    caseRecord.Case_Sub_Type__c = Constant_Util.EMPTY_STRING;
                    caseRecord.SLA_Service_Date_Time__c = Null;
                    caseRecord.Service_Date__c = Null;
                }   */
                
                if(!caseRecord.RecordTypeId.equals(oldCaseRecord.RecordTypeId)){
                        caseRecord.SLA_Service_Date_Time__c = Null;
                        caseRecord.Service_Date__c = Null;
                    }
                    //Changes related to SDT-32829 -additional method to reset SLA and ServiceDate
                    else if(CaseTriggerHelper.resetSLAandServiceDate(caseRecord,oldCaseRecord)){
                    caseRecord.SLA_Service_Date_Time__c = Null;
                    caseRecord.Service_Date__c = Null;
                }
                
               
                if (caseRecord.RecordTypeId != newServiceRcdType && caseRecord.RecordTypeId != pickupRcdType &&
                     caseRecord.RecordTypeId != IntegrationRcdType && 
                     (caseRecord.RecordTypeId.equals(oldCaseRecord.RecordTypeId)) && ((!string.isBlank(caseRecord.Case_Type__c) && !caseRecord.Case_Type__c.equals(oldCaseRecord.Case_Type__c)) || (!string.isBlank(caseRecord.Case_Sub_Type__c) && !caseRecord.Case_Sub_Type__c.equals(oldCaseRecord.Case_Sub_Type__c)) ||( !string.isBlank(caseRecord.Case_Reason__c) && !caseRecord.Case_Reason__c.equals(oldCaseRecord.Case_Reason__c))))
                 {
                    
                    caseRecord.SLA_Service_Date_Time__c = Null;
                    caseRecord.Service_Date__c = Null;
                 } 
                
                //caseNewList.add(caseRecord);   // && !(caseRecord.Is_Clone__c || caseRecord.Is_Multivendor__c)//caseRecord.RecordTypeId == pickupRcdType && 
                 if(caseRecord.RecordTypeId == newServiceRcdType || caseRecord.RecordTypeId == pickupRcdType || ((caseRecord.RecordTypeId == newServiceRcdType ||
                     caseRecord.RecordTypeId != IntegrationRcdType  ||
                     (caseRecord.RecordTypeId != IntegrationRcdType && (String.isNotBlank(caseRecord.Case_type__c) && 
                          sla_calculation__c.getValues(caseRecord.Case_type__c) != null  && 
                          sla_calculation__c.getValues(caseRecord.Case_type__c).Enabled__c))) && !caseRecord.Is_Multivendor__c && 
                    ((String.isNotBlank(caseRecord.AssetId) && caseRecord.AssetId != oldCaseMap.get(caseRecord.id).AssetId) || !String.isBlank(caseRecord.Case_Sub_Type__c)))){
                    if(String.isNotBlank(caseRecord.AssetId)){
                    
                    containerIdSet.add(caseRecord.AssetId);   
                     }
                    processCaseSubtypeList.add(caseRecord); 
                    
                } 
            }
                if(String.isNotBlank(caseRecord.Location__c)){       
                    locationIdSet.add(caseRecord.Location__c); 
                }
		    
		if(caseRecord.ParentId == null && caseRecord.Reference_Number__c == null ){
                    caseRecord.Reference_Number__c = caseRecord.CaseNumber;
                }  else  if(caseRecord.ParentId != null && caseRecord.Reference_Number__c == null ){
                    caseRecord.Reference_Number__c = parentRecordMap.containsKey(caseRecord.ParentId) 
                                                     ? parentRecordMap.get(caseRecord.ParentId).Reference_Number__c
                                                     : caseRecord.Reference_Number__c;
                }
                caseNewMap.put(caseRecord.id,caseRecord);
                //SdT-29498
                
                if(oldCaseRecord!= null && oldCaseRecord.status == 'Closed' && oldCaseRecord.status != caseRecord.status) {
                        showErrorMap.put(caseRecord.id,caseRecord);
                         
                    }
                    
                //SDT-48538 Added by Gunjan Shah
                if(caseRecord.RecordTypeId == pickupRcdType || caseRecord.RecordTypeId == SRCRcdType || caseRecord.RecordTypeId == InterruptionRcdType || caseRecord.RecordTypeId == StandardRcdType || caseRecord.RecordTypeId == VendorRcdType || caseRecord.RecordTypeId == RepairRcdType){
                    CaseTriggerHelper.createAcornComment(caseRecord, oldCaseRecord);
                } 
                
            }
            
            isInsertForLocalAgentId = false;
            CaseTriggerHelper.UpdateLocalAgentId(caseNewMap,oldCaseMap,isInsertForLocalAgentId);

            if(containerIdSet != null && !containerIdSet.isEmpty()){
                casewithContainerMap = getAssetRecordValue(containerIdSet,true);   
            } 
            if(locationIdSet != null && !locationIdSet.isEmpty()){
                casewithLocationMap = getLocationRecordValue(locationIdSet);
            }
            CaseTriggerHelper.updateAssignment(newcasemap, oldcasemap, triggerparam.newList);
            CaseTriggerHelper.casewithContainer =casewithContainerMap;
            CaseTriggerHelper.casewithLocation = casewithLocationMap;
            List<case> caseUpdatedServiceDateList = new List<case>(); 
            if((processCaseSubtypeList != null && !processCaseSubtypeList .isEmpty()) &&            
            (casewithLocationMap != null && !casewithLocationMap.isEmpty())
            ){           
                caseUpdatedServiceDateList = CaseTriggerHelper.updateCaseDetails(processCaseSubtypeList,oldCaseMap ,casewithContainerMap,casewithLocationMap,(Boolean)triggerParam.isInsert);
                
            
            
            } 
			    if((caserecord.Case_Type__c == 'Activate' || caserecord.Case_Type__c == 'Modify' || caserecord.Case_Type__c == 'Deactivate') && caserecord.Service_Date__c == null && caserecord.SLA_Service_Date_Time__c == null){
                     system.debug('in activate>>');
                   casewithLocationMap1 = getLocationRecordValueStandardCase();
                     system.debug('in casewithLocationMap>>>'+casewithLocationMap);
processofficetraxxlst1.add(caseRecord);
CaseTriggerHelper.updateServiceDateAlwaysRunstandard(processofficetraxxlst1,null,null,casewithLocationMap1);
CaseTriggerHelper.serviceDatetoSLAstandard(processofficetraxxlst1,null);
}
				
            //SDT-13085
            CaseTriggerHelper.PopulateServiceClassification((List<Case>)triggerParam.newList,(map<Id,Case>)triggerParam.OldMap);
            /*if(caseUpdatedServiceDateList != null && !caseUpdatedServiceDateList.isEmpty()) {
                Map<Id,Case> caseReturnedMap = new Map<Id,case>(caseUpdatedServiceDateList);
                //CaseTriggerHelper.casewithContainer = casewithContainerMap;
                //CaseTriggerHelper.casewithLocation = casewithLocationMap;
                CaseTriggerHelper.getbusinessRules(caseReturnedMap, oldCaseMap);
            }*/
	  //SdT-29498
           
            if(showErrorMap != null){
            CaseTriggerHelper.showErrorOnCloseCase(showErrorMap);
       		 }
             //SdT-29498
        //SDT-16989 - Bypass Duplicate Checkbox value to True.
            CaseTriggerHelper.updateDuplicateCheck(caseNewMap);
	CaseTriggerHelper.updateNSCCase(caseNewMap,oldcasemap);
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
    /*******************************************************************************************************
    * @description Method to handle after insert event of Case
	* @param triggerParam of type TriggerParameters
    * @return void
    * @example
    */  
    public static void afterInsert(TriggerParameters triggerParam){
        try{
            List<case> caseNewList = new List<case>();
            List<case> processCaseSubtypeList = new List<case>();
            caseAssetCreationMap = new Map<id,case>();
            Map<id,Case> oldCaseMap = new Map<id,case>();
            Map<id,Case> caseNewMap = new Map<id,Case>();
            Case caseRecord = new Case();
			 List<Case> caseChargeabilityList = new List <Case>();
            for(sObject sobjVal : triggerParam.newList){
                caseRecord = (Case)sobjVal ; 
                //SDT-8435 Add_case_Asset flow converted into Apex
                if(caseRecord.Service_Date__c != null && !String.isBlank(caseRecord.AssetId) && !caseRecord.Is_Multivendor__c &&
                   (Constant_Util.ACORN.equalsIgnoreCase(caseRecord.Source_System__c) || Constant_Util.SALESFORCE.equalsIgnoreCase(caseRecord.Source_System__c) || Constant_Util.OFFICETRAX.equalsIgnoreCase(caseRecord.origin) || Constant_Util.EBUSSINESS.equalsIgnoreCase(caseRecord.origin))){
                    caseAssetCreationMap.put(caseRecord.Id,caseRecord);
                }
                if(caseRecord.ParentId != null ){
                    caseNewList.add(caseRecord);
                }
                caseNewMap.put(caseRecord.id,caseRecord);
				
				if(caseRecord.Chargeable__c != null) {
                        caseChargeabilityList.add(caseRecord);
                     
                    } 
            }
			
			 if(!caseChargeabilityList.isEmpty()){
                caseTriggerHelper.addCommentForChargeability(caseChargeabilityList);            
            }
			
            if(caseNewMap != null && !caseNewMap.isEmpty()){
                CaseTriggerHelper.logRelatedCases(caseNewMap);
            }
            //SDT-11758
            if(caseNewList != null && !caseNewList.isEmpty()){
                CaseTriggerHelper.insertCaseComment(caseNewList);
            }
            //SDT-8435 Add_case_Asset flow converted into Apex
            if(caseAssetCreationMap != null && !caseAssetCreationMap.isEmpty()){
                caseTriggerHelper.addCaseAssets(caseAssetCreationMap,oldCaseMap,casewithContainerMap );
            }
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
    /*******************************************************************************************************
    * @description Method to handle after update event of Case
	* @param triggerParam of type TriggerParameters
    * @return void
    * @example
    */ 
    public static void afterUpdate(TriggerParameters triggerParam){
        try{
            List<case> caseNewList = new List<case>();
            List<case> multipleAmPmVendorCaseList= new List<case>();
            List<case> reassignCaseList = new List<case>();
            List<case> processCaseSubtypeList = new List<case>();
            List<Case> updatePOList = new List <Case>();
			List<Case> caseChargeabilityList = new List <Case>();
			List<case> haulCaseList = new List<case>();
            Map<id,Case> oldCaseMap = new Map<id,case>();
            Map<id,Case> closeCaseMap = new Map<id,case>();
            Map<id,Case> asyncCloseCaseMap = new Map<id,case>();
            Set<Id> contactIdSet=new Set<Id>();
            Map<id,Case> caseCommentProcessMap = new Map<id,case>();
            Map<id,Case> caseNewMap = new Map<id,Case>();
            List<Case>updateAssets = new List<Case>();
            Map<string,string> oldCaseAssetIdMap = new Map<string,string>();
	        Map<id,Case> closeMapGRcancel = new Map<id,case>();
			Set<String> reopenTrackNumber = new Set<String>();

            caseAssetCreationMap = new Map<id,case>();
            Case caseRecord = new Case();
            Id pickuprecordtype = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.Pickup).getRecordTypeId();
            Id newServiceRecordType = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
            /*Map<String,Boolean> asyncProcessmap = new Map<String,Boolean>();
            for(Asynchronous_Process__mdt ap : [Select Id,DeveloperName,Enable__c from Asynchronous_Process__mdt]){
                asyncProcessmap.put(ap.DeveloperName,ap.Enable__c);
            }*/
            List<Case> caseWOEmailLst = new List<Case>();
            for(sObject sobjVal : triggerParam.newList){
                caseRecord = (Case)sobjVal ; 
                caseNewMap.put(caseRecord.id,caseRecord);
                //Case oldCaseRecord = (Case)triggerParam.mostRecentOldMap.get(caseRecord.id); 
                Case oldCaseRecord = (Case)triggerParam.OldMap.get(caseRecord.id);
                oldCaseMap.put(oldCaseRecord.id, oldCaseRecord);
				if(oldCaseRecord!= null && (caseRecord.status != oldCaseRecord.status && Constant_Util.CLOSED.equalsIgnoreCase(caseRecord.status))) {
                        closeMapGRcancel.put(caseRecord.id,caseRecord);
                    }
                if(caseRecord.Service_Date__c != null && !caseRecord.Is_Multivendor__c && 
                (((caseRecord.AssetId != oldCaseRecord.AssetId ) || (caseRecord.Service_Date__c!= oldCaseRecord.Service_Date__c && caseRecord.RecordTypeId == pickuprecordtype ) || (caseRecord.RecordTypeId != pickuprecordtype && oldCaseRecord.Service_Date__c == null))
                && (Constant_Util.ACORN.equalsIgnoreCase(caseRecord.Source_System__c) || Constant_Util.SALESFORCE.equalsIgnoreCase(caseRecord.Source_System__c) || Constant_Util.OFFICETRAX.equalsIgnoreCase(caseRecord.origin) || Constant_Util.EBUSSINESS.equalsIgnoreCase(caseRecord.origin)))){
                    
                    caseAssetCreationMap.put(caseRecord.Id,caseRecord);
                }
                /*if(((caseRecord.AssetId != oldCaseRecord.AssetId) && string.isBlank(caseRecord.AssetId)) ||((caseRecord.Service_Date__c!= oldCaseRecord.Service_Date__c) && caseRecord.Service_Date__c == null)) {
                    oldCaseAssetIdMap.put(caseRecord.Id,oldCaseRecord.AssetId);
                }*/
                //Uncomment it when we converted all the flow into Apex
                /*if(((caseRecord.status != oldCaseRecord.Status) || (caseRecord.Case_Sub_Status__c != oldCaseRecord.Case_Sub_Status__c) || (caseRecord.Create_AM_and_PM_Pickups__c != oldCaseRecord.Create_AM_and_PM_Pickups__c)) && 
                    (caseRecord.Create_AM_and_PM_Pickups__c || caseRecord.Is_Multivendor__c) && 
                    (caseRecord.status == Constant_Util.OPEN && caseRecord.Case_Sub_Status__c == Constant_Util.PENDING_SERVICE_INTEGRATION)){
                multipleAmPmVendorCaseList.add(caseRecord);
                }*/
				 haulCaseList.add(caseRecord);
                 Set<Id> setCaseIds2 = new Set<Id>();
                  for(Case c : haulCaseList){
            setCaseIds2.add(c.id);
        }
                 if((caseRecord.Case_Sub_Type__c == 'Haul Away - No Equipment' || (caseRecord.Case_Type__c == 'General' && caseRecord.Case_Sub_Type__c == 'Other')) && caseRecord.Chargeable__c != null){
                     CaseTriggerHelper.updateChargeable(setCaseIds2);
                 	 CaseTriggerHelper.updateChargeablechild(setCaseIds2);
                }
                 if((caseRecord.Status == Constant_Util.OPEN && oldcaseRecord.Status == Constant_Util.OPEN)  || (caseRecord.Status == Constant_Util.OPEN && oldcaseRecord.Status == Constant_Util.Case_New_Status && !string.isBlank(caseRecord.Tracking_Number__c) && !caseRecord.isWorkOrderCreated__c)){
                    if(((caseRecord.Team_Queue__c != oldCaseRecord.Team_Queue__c || caseRecord.User_Name__c != oldCaseRecord.User_Name__c) && !string.isBlank(caseRecord.Tracking_Number__c)) || (caseRecord.CheckReassignment__c && !string.isBlank(caseRecord.Tracking_Number__c))){
                        reassignCaseList.add(caseRecord);
                        System.debug('reassignCaseList===='+reassignCaseList);
                    }
                }
                System.debug('caseRecord.Status===='+caseRecord.Status+'===='+caseRecord.Tracking_Number__c+'======'+caseRecord.isWorkOrderCreated__c);
                if((caseRecord.Status == 'New' && oldcaseRecord.Status == 'New') || (caseRecord.Status == 'Pending' && oldcaseRecord.Status == 'Pending') && !string.isBlank(caseRecord.Tracking_Number__c) ){
                    // if((caseRecord.Team_Queue__c != oldCaseRecord.Team_Queue__c || caseRecord.User_Name__c != oldCaseRecord.User_Name__c) && !string.isBlank(caseRecord.Tracking_Number__c)){
                    //* SDT-21359 Commented 22 Nov 2021  */ if(caseRecord.Team_Queue__c != null && caseRecord.Team_Name__c !=null && !string.isBlank(caseRecord.Tracking_Number__c)){
                    /* Added Below Line SDT-21359 */  
                     if(((caseRecord.Team_Queue__c != null && caseRecord.Team_Queue__c != oldCaseRecord.Team_Queue__c) || ( caseRecord.Team_Name__c !=null && caseRecord.Team_Name__c != oldCaseRecord.Team_Name__c)) && !string.isBlank(caseRecord.Tracking_Number__c) || (caseRecord.CheckReassignment__c && !string.isBlank(caseRecord.Tracking_Number__c))){
                        reassignCaseList.add(caseRecord);
                        System.debug('reassignCaseList===='+reassignCaseList);
                    }
                }
                if(caseRecord.Tracking_Number__c != null && caseRecord.Tracking_Number__c != oldCaseRecord.Tracking_Number__c ){
                    caseCommentProcessMap.put(caseRecord.Id,caseRecord);
                }
                if(caseRecord.Override_PO_Create_Task__c == true && caseRecord.PurchaseOrder_Number__c != null && caseRecord.Work_Order__c != null &&  caseRecord.PurchaseOrder_Number__c != oldCaseRecord.PurchaseOrder_Number__c)
                {
                    updatePOList.add(caseRecord);
                }
																						  
                //9485 - Update Asset on Case
                if(!string.isBlank(oldcaseRecord.AssetId) && !string.isBlank(oldCaseRecord.Origin)){
                    if(!string.isBlank(oldCaseRecord.AssetId) && !caseRecord.AssetId.equals(oldCaseRecord.AssetId) && caseRecord.Status.equals(Constant_Util.New_Status) && caseRecord.Origin.equals(Constant_Util.OfficeTrax)){
                        updateAssets.add(caseRecord);
                    }
                }
                //allow for updateAsset when original AssetId is null
                if(string.isBlank(oldcaserecord.AssetId) && !string.isBlank(caseRecord.AssetId) && !string.isBlank(caseRecord.Origin)){
                    if(caseRecord.Status.equals(Constant_Util.New_Status) && caseRecord.Origin.equals(Constant_Util.OfficeTrax)){
                        updateAssets.add(caserecord);
                    }
                }

                /*if(oldCaseRecord!= null && ((String.isNotBlank(caseRecord.Case_Sub_Status__c) && string.isNotBlank(oldCaseRecord.Case_Sub_Status__c) 
                                        &&  (caseRecord.Case_Sub_Status__c != oldCaseRecord.Case_Sub_Status__c)) || (caseRecord.status != oldCaseRecord.status && Constant_Util.CLOSED.equalsIgnoreCase(caseRecord.status) && !asyncProcessmap.isEmpty() && !asyncProcessmap.get(Constant_Util.COMPLETE_TASK)))) {
                                    closeCaseMap.put(caseRecord.id,caseRecord);
                }else if(oldCaseRecord!= null && caseRecord.status != oldCaseRecord.status && Constant_Util.CLOSED.equalsIgnoreCase(caseRecord.status) && !asyncProcessmap.isEmpty() && asyncProcessmap.get(Constant_Util.COMPLETE_TASK)){
                                    asyncCloseCaseMap.put(caseRecord.id,caseRecord);  
                }*/
                
            if(caseNewMap!=null  && caseNewMap.get(caseRecord.Id).contactId!=oldCaseMap.get(caseRecord.Id).contactId){
                    contactIdSet.add(caseNewMap.get(caseRecord.Id).contactId);
                }
            //Start of SDT-16427        
               if(caseNewMap.get(caseRecord.Id).Case_Sub_Status__c != oldCaseMap.get(caseRecord.Id).Case_Sub_Status__c && CONSTANT_UTIL.PENDING_SERVICE_INTEGRATION.equalsIgnoreCase(caseNewMap.get(caseRecord.Id).Case_Sub_Status__c) && string.IsNotBlank(caseRecord.ContactId) ){
                caseWOEmailLst.add(caseRecord);   
                }
			//SDT-25229
                if(oldCaseRecord!= null && (caseRecord.status != oldCaseRecord.status && Constant_Util.CLOSED.equalsIgnoreCase(oldCaseRecord.status))) {
                    if(caseRecord.Tracking_Number__c != null)
                    {
                        reopenTrackNumber.add(caseRecord.Tracking_Number__c);
                    }    
                }
				if(oldCaseRecord!= null && (caseRecord.Chargeable__c != oldCaseRecord.Chargeable__c)) {
                        caseChargeabilityList.add(caseRecord);
                     
                    }
				
            }
			 if(!caseChargeabilityList.isEmpty()){
                caseTriggerHelper.addCommentForChargeability(caseChargeabilityList);            
            }
            /*commenting out SDT-16427
            if(caseWOEmailLst!= null && !(test.isRunningTest())){
                CaseTriggerHelper.sendEmailOnWOcreation(caseWOEmailLst,Constant_Util.WO_Email_TEMPLATE);
            }
            */
            //End of SDT-16247
            System.debug('caseAssetCreationMap===='+caseAssetCreationMap);
            if(!RecurrsiveTriggerHandler.bypassValidation && (caseAssetCreationMap != null && !caseAssetCreationMap.isEmpty())){
                system.debug('casewithContainerMap =='+casewithContainerMap );
                caseTriggerHelper.addCaseAssets(caseAssetCreationMap,oldCaseMap,casewithContainerMap );
            }
            /*if(oldCaseAssetIdMap != null && !oldCaseAssetIdMap.isEmpty()){
                caseTriggerHelper.deleteOldCaseAssets(oldCaseAssetIdMap);
            }*/
            if(!RecurrsiveTriggerHandler.bypassValidation && (caseNewMap != null && !caseNewMap.isEmpty()) && (oldCaseMap != null && !oldCaseMap.isEmpty())){
                if(TriggerDispatcher.skipTriggerExecutionMap==null || !TriggerDispatcher.skipTriggerExecutionMap.containsKey(Case.sobjectType.getDescribe().getName())
            || (TriggerDispatcher.skipTriggerExecutionMap.containsKey(Case.sobjectType.getDescribe().getName()) && !TriggerDispatcher.skipTriggerExecutionMap.get(Case.sobjectType.getDescribe().getName()))){
                    CaseTriggerHelper.insertApprovalLog(caseNewMap ,oldCaseMap);
                }
                CaseTriggerHelper.logStatusUpdates(caseNewMap ,oldCaseMap);
            }
            if(RecurrsiveTriggerHandler.isRecurrsiveToAcorn && !RecurrsiveTriggerHandler.bypassValidation && (reassignCaseList!= null && !reassignCaseList.isEmpty())){
				RecurrsiveTriggerHandler.isRecurrsiveToAcorn =false;
                ReassignAcornTicket.reassignTicket(reassignCaseList,oldCaseMap);
				 Set<Id> setCaseIds = new Set<Id>();
        for(Case c : reassignCaseList){
            setCaseIds.add(c.id);
        }
                CaseTriggerHelper.updateReassignField(setCaseIds);
            }
            //Uncomment it when we converted all the flow into Apex
            /* if(multipleAmPmVendorCaseList != null && !multipleAmPmVendorCaseList.isEmpty()){
            CaseTriggerHelper.createAmPmVendorCases(multipleAmPmVendorCaseList,casewithContainerMap);
            }*/
            if(!RecurrsiveTriggerHandler.bypassValidation && caseCommentProcessMap != null && !caseCommentProcessMap.isEmpty()){
                CaseTriggerHelper.updateCommentsTrackingNumber(caseCommentProcessMap,oldCaseMap);
            }
            
           /*if(asyncCloseCaseMap != null && !asyncCloseCaseMap.isEmpty()){
                // instantiate a new instance of the Queueable class
                AsyncCompleteTask updateJob = new AsyncCompleteTask(asyncCloseCaseMap.keyset());
                // enqueue the job for processing
                ID jobID = System.enqueueJob(updateJob);
            }*/
            if(updatePOList != null &&!updatePOList.isEmpty()){
                UpdateCasePO.updateCasePO(updatePOList);
            }
            if(updateAssets.size()>0 && !updateAssets.isEmpty()){
                UpdateAssetOnCase.updateAsset(updateAssets,oldcasemap);
            }
            if(contactIdSet!=null){
                CaseTriggerHelper.lastContactActivityDate(contactIdSet);
            }
            //Added triggerParam parameter as part of fix to SDT-10762
            if(caseNewMap != null && oldCaseMap != null){
              CaseTriggerHelper.updateGenesysTaskRouting(caseNewMap,oldCaseMap);
              CaseTriggerHelper.updateANIOnContact(caseNewMap,oldCaseMap); // Added SDT-18823
CaseTriggerHelper.updateCCandPO(caseNewMap.values(),oldCaseMap); //
            }
            /*
            if(!RecurrsiveTriggerHandler.bypassValidation){
                CaseTriggerHelper.CreateGenRoutingReporting(caseNewMap,oldCaseMap);
            }
            */
			if(!CaseTriggerHelper.appLogList.isEmpty())
            {
                CaseTriggerHelper.insertAutoApprovalLog();
            }
			 if(!closeMapGRcancel.IsEmpty() && closeMapGRcancel != null && System.Label.Create_cancel_GR_record_On_Update == 'ON' && !test.isRunningTest() ){
                CaseTriggerHelper.createCacelCompletedGenesysRecord(closeMapGRcancel);
            }
			//SDT-25229
            if(RecurrsiveTriggerHandler.isReopenRecurrsiveToAcorn && !RecurrsiveTriggerHandler.bypassValidation && (reopenTrackNumber!= null && !reopenTrackNumber.isEmpty())){
                RecurrsiveTriggerHandler.isReopenRecurrsiveToAcorn = false;
                ReopenAcornTicket.reassignTicket(reopenTrackNumber);
            }
			
			
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    } 

/*******************************************************************************************************
* @description Method to handle before delete event of Case
* @param triggerParam of type TriggerParameters
* @return void
* @example
*/ 
    public static void beforeDelete(TriggerParameters triggerParam){
        try{
            Case caseRecord = new Case();
            Map<Id,case> caseMap = new Map<Id,case> ();
            for(sObject sobjVal : triggerParam.oldList){
                caseRecord = (Case)sobjVal ; 
                caseMap.put(caseRecord.id,caseRecord);
            }
           if(System.Label.Create_cancel_GR_record == 'ON'){
                CaseTriggerHelper.createCacelCompletedGenesysRecord(caseMap);
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }  
    
    
    
    
    	

    /*******************************************************************************************************
    * @description Method to handle after update event of Case
	* @param triggerParam of type TriggerParameters
    * @return void
    * @example
    */   
    public static void afterUpdateAlways(TriggerParameters triggerParam){
        try{
            List<case> multipleAmPmVendorCaseList= new List<case>();
            Map<id,Case> caseNewMap = new Map<id,Case>();
            Map<id,Case> oldCaseMap = new Map<id,case>();
            Map<id,Case> closeCaseMap = new Map<id,case>();
			Map<id,Case> AM_closedCaseMap = new Map<id,case>();

            case caseRecord  = new Case();
            for(sObject sobjVal : triggerParam.newList){
                caseRecord = (Case)sobjVal ; 
                caseNewMap.put(caseRecord.id,caseRecord);
                //Case oldCaseRecord = (Case)triggerParam.mostRecentOldMap.get(caseRecord.id);
                Case oldCaseRecord = (Case)triggerParam.OldMap.get(caseRecord.id);
                if(oldCaseRecord != null && oldCaseRecord.id != null){
                    oldCaseMap.put(oldCaseRecord.id, oldCaseRecord);
                    
                    if(((caseRecord.status != oldCaseRecord.Status) || (caseRecord.Case_Sub_Status__c != oldCaseRecord.Case_Sub_Status__c) || (caseRecord.Create_AM_and_PM_Pickups__c != oldCaseRecord.Create_AM_and_PM_Pickups__c)) && 
                    /*(caseRecord.Create_AM_and_PM_Pickups__c || caseRecord.Is_Multivendor__c) && */
                    (caseRecord.status == Constant_Util.OPEN && caseRecord.Case_Sub_Status__c == Constant_Util.PENDING_SERVICE_INTEGRATION)){
                        multipleAmPmVendorCaseList.add(caseRecord);
                    }
                    if(oldCaseRecord!= null && ((String.isNotBlank(caseRecord.Case_Sub_Status__c) && string.isNotBlank(oldCaseRecord.Case_Sub_Status__c) 
                                        &&  (caseRecord.Case_Sub_Status__c != oldCaseRecord.Case_Sub_Status__c)) || (caseRecord.status != oldCaseRecord.status && Constant_Util.CLOSED.equalsIgnoreCase(caseRecord.status)))) {
                        closeCaseMap.put(caseRecord.id,caseRecord);
                    }
					if(oldCaseRecord!= null && (caseRecord.status != oldCaseRecord.status && Constant_Util.CLOSED.equalsIgnoreCase(caseRecord.status))) {
                        AM_closedCaseMap.put(caseRecord.id,caseRecord);
                    }
                }
            }
            if(!RecurrsiveTriggerHandler.bypassValidation && multipleAmPmVendorCaseList != null && !multipleAmPmVendorCaseList.isEmpty()){
                CaseTriggerHelper.createAmPmVendorCases(multipleAmPmVendorCaseList,casewithContainerMap);
            }
            if(closeCaseMap!= null && !closeCaseMap.isEmpty()){
                CaseTriggerHelper.closeOldTasks(closeCaseMap,oldCaseMap);
            }
			if(AM_closedCaseMap!= null && !AM_closedCaseMap.isEmpty()){
                CaseTriggerHelper.declineRelatedQuote(AM_closedCaseMap);
            }
			
			
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
	/*******************************************************************************************************
    * @description Method to query the Asset Record 
	* @param assetIdset of type Set<Id>
	* @param serviceHeaderCheck of type Boolean
    * @return Map<id,Asset>
    * @example
    */   
    public static Map<id,Asset> getAssetRecordValue(set<id> assetIdset,boolean serviceHeaderCheck){        
        Map<id,Asset> assetMap = new Map<id,Asset>();
        try{
            List<Asset> assetList = new List<Asset>();
            string queryString = System.label.AssetQuery ;
            if(assetIdSet != null && !assetIdSet.isEmpty()){
                if(!serviceHeaderCheck){
                    queryString += Constant_Util.BLANKSPACE + Constant_Util.ASSETWHEREQUERY;
                }
                else{
                    queryString += Constant_Util.BLANKSPACE  + Constant_Util.ASSETWHEREQUERY_SERVICEHEADER ;
                }
            }
            queryString += Constant_Util.BLANKSPACE + Constant_Util.LIMITVAL ;
            assetList = Database.query(queryString);   
            if(assetList != null && !assetList.isEmpty()){
                assetMap = new Map<id,Asset>(assetList);
            }
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        return assetMap;
    } 
    
	/*******************************************************************************************************
    * @description Method to query the Location Record 
	* @param locationIdSet of type Set<Id>
    * @return Map<id,Account>
    * @example
    */   
    public static Map<id,Account> getLocationRecordValue(set<id> locationIdSet){
        //private static Map<Id,Account> locationAccountMap = new Map<Id,Account>(); static declared at top
        //added for soql 101 issue 6/3/2024 - SDT-40083
        Map<Id,Account> LocationAccountTempMap = new Map<Id,Account>();
        Set<Id> idsToQuery = new Set<Id>();
        try{
        for(Id locationId : locationIdSet){
            if(!locationAccountMap.containsKey(locationId)){      
                idsToQuery.add(locationId);            
            }
        }
        //added for soql 101 issue 6/3/2024 - SDT-40083
        if(!idsToQuery.isEmpty()){   
            LocationAccountTempMap= new Map<Id,Account>([Select Id,Brand__c,Geography__c,Division__c,Location_Type__c,tz__Timezone_SFDC__c from Account where Id IN: idsToQuery LIMIT 49999]); //use Try-Catch as query may return empty list
          //System.debug('LocationAccountTempMapafter^^' +LocationAccountTempMap);
          }
          locationAccountMap.putAll(LocationAccountTempMap);
           // System.debug('locationAccountMap final^^' +locationAccountMap);
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        return locationAccountMap;
    }
	
	
      public static Map<id,Account> getLocationRecordValueStandardCase(){
        Map<Id,Account> locationAccountMap = new Map<Id,Account>();
        try{
            locationAccountMap = new Map<Id,Account>([Select Id,name,Brand__c,Geography__c,Division__c,Location_Type__c,tz__Timezone_SFDC__c from Account where tz__Timezone_SFDC__c = 'America/New_York' and recordtype.name = 'location' and Status__c = 'Active' limit 1]); 
            system.debug('in locationAccountMap2>>>'+locationAccountMap);
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        return locationAccountMap;
    }
	
}
