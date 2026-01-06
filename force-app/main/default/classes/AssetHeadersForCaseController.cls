/**
* @author Accenture
* @date 2/25/2019
* @description : Apex class AssetHeadersForCaseController 
**/
public without sharing class AssetHeadersForCaseController {
    public inherited sharing class DataWrapper{
        @AuraEnabled public Id assetId;
        @AuraEnabled public String assetName;
        @AuraEnabled public String Acorn_SID;
        @AuraEnabled public String Material_Type;
        @AuraEnabled public String Duration;
        @AuraEnabled public String Occurrence_Type;
        @AuraEnabled public String Schedule;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public String Category;
        @AuraEnabled public String Container_Position;
        @AuraEnabled public Boolean Has_Extra_Pickup;
        @AuraEnabled public String Supplier_Name;
        @AuraEnabled public String Vendor_ID;
        @AuraEnabled public String Sensitivity_Code;
        @AuraEnabled public String Vendor_Account_Number;
        @AuraEnabled public String MAS_Company_Account_Number;
        @AuraEnabled public Decimal MAS_Customer_Unique_Id;
        @AuraEnabled public String MAS_Library;
        @AuraEnabled public Date Start_Date;
        @AuraEnabled public Date End_Date;
        @AuraEnabled public String Equipment_Owner;
        @AuraEnabled public Boolean highlightRow = false;
        @AuraEnabled public Boolean isParent = false;
        @AuraEnabled public String isProjectActive;
        @AuraEnabled public Boolean isActiveAsset;
        @AuraEnabled public String[] preSelectedAssets;
        @AuraEnabled public String EquipmentType;
	}
    
    /**
* @author Accenture
* @date 2/25/2019
* @description : Apex method getAssetHeaders 
**/
    @AuraEnabled
    public static List<DataWrapper> getAssetHeaders(String caseId) {
        List<Asset> assetHeaders = null;
        Asset coreassetDetail = null;
        Set<Id> headerIds = new Set<Id>();
        Map<Id,Asset> coreDetailMap = new MAp<Id,Asset>();
        Set<Id> highlightIds = new Set<Id>();
        List<Id> highlightRelatedIds = new List<Id>();
        List<DataWrapper> wrapperList = new List<DataWrapper>();
        String recordType = Constant_Util.SERVICE_HEADER;
        String detailRecordType = Constant_Util.SERVICE_DETAILS;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        Case currentCase = Database.query('select AssetId,ParentId,Location__c,CaseNumber,Reference_Number__c,Is_Multiple_Asset__c,RecordType.Name from case where id = :caseId limit 1');
        String locationId = currentCase.Location__c;
        
        if(locationId != null){
            //If-Else added for story SDT-24993 start. Additional filter CPQ_Product__c != null for Update asset case.
           //Changes for SDT-26868
           if(currentCase.RecordType.Name == Constant_Util.New_Service_Case){
            assetHeaders = Database.query('select id,Name,Active__c,Acorn_SID__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Equipment_Type__c from asset where AccountId = :locationId and RecordType.DeveloperName = :recordType');
            }
            else{
                // Changes for SDT-29408 HotFix
                // if(GetCaseInformation.getActiveAssetUserDetail())
                //  assetHeaders = Database.query('select id,Name,Active__c,Acorn_SID__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Equipment_Type__c from asset where AccountId = :locationId and RecordType.DeveloperName = :recordType and CPQ_Product__c != null');
                // else
                  assetHeaders = Database.query('select id,Name,Active__c,Acorn_SID__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Equipment_Type__c from asset where AccountId = :locationId and RecordType.DeveloperName = :recordType');
            }
            //End
            List<Case> caseList = new List<Case>();
            caseList = [SELECT id,AssetId,ParentId,Is_Multiple_Asset__c 
                        FROM Case
                        WHERE Reference_Number__c =: currentCase.Reference_Number__c 
                        AND Location__c = : currentCase.Location__c 
                        AND id !=: currentCase.Id];

            for(Case cse : caseList){ //and Is_Multiple_Asset__c = true 
                if(cse.AssetId != null && cse.Is_Multiple_Asset__c 
                    && currentCase.Is_Multiple_Asset__c 
                    && cse.ParentId==currentCase.ParentId){
                    highlightIds.add(cse.AssetId);
                }
            }

            if(currentCase.AssetId != null){
                highlightIds.add(currentCase.AssetId);
            }

            if(sessionPart.contains(caseId)){
                String[] assets= (String[])sessionPart.get(caseId);
                for(String s : assets){
                    highlightIds.add(s);
                }
            }
        }   

        for(Asset asset : assetHeaders){
            headerIds.add(asset.Id);
        }
        for(Asset assetDetail : [Select id, MAS_Customer_Unique_Id__c,Schedule__c,Quantity__c,RootAssetId from asset where RootAssetId IN: headerIds and Is_Active__c = true and Is_Core_Service__c = true and RecordType.DeveloperName = :detailRecordType]){
            coreDetailMap.put(assetDetail.RootAssetId,assetDetail);
        }
        if(!assetHeaders.isEmpty()){
            for(Asset asset : assetHeaders){
                DataWrapper recordWrap = new DataWrapper();
                if(coreDetailMap.containskey(asset.Id)){
                    coreassetDetail = coreDetailMap.get(asset.Id);
                }
                if(coreassetDetail != null){
                    recordWrap.MAS_Customer_Unique_Id = coreassetDetail.MAS_Customer_Unique_Id__c;
                    recordWrap.Schedule = coreassetDetail.Schedule__c;
                    recordWrap.Quantity = coreassetDetail.Quantity__c;
                }
                if(highlightIds.contains(asset.Id)){
                    recordWrap.highlightRow = true;
                }
                recordWrap.assetId = asset.Id;
                recordWrap.assetName = asset.Name;
                recordWrap.Acorn_SID = asset.Acorn_SID__c;
                recordWrap.Material_Type = asset.Material_Type__c;
                recordWrap.Duration = asset.Duration__c;
                recordWrap.Occurrence_Type = asset.Occurrence_Type__c;
                recordWrap.Category = asset.Category__c;
                recordWrap.Container_Position = asset.Container_Position__c;
                recordWrap.Has_Extra_Pickup = asset.Has_Extra_Pickup__c;
                recordWrap.Supplier_Name = asset.Supplier__r.Name;
                recordWrap.Vendor_ID = asset.Vendor_ID__c;
                recordWrap.Sensitivity_Code = asset.Sensitivity_Code__c;
                recordWrap.Vendor_Account_Number = asset.Vendor_Account_Number__c;
                recordWrap.MAS_Company_Account_Number = asset.MAS_Company_Account_Number__c;
                recordWrap.MAS_Library = asset.MAS_Library__c;
                recordWrap.Start_Date = asset.Start_Date__c;
                recordWrap.End_Date =asset.End_Date__c;
                recordWrap.Equipment_Owner =asset.Equipment_Owner__c;
                recordWrap.isParent = asset.Id == currentCase.AssetId ? true : false;
                recordWrap.isProjectActive = asset.Active__c ? 'Yes' : 'No';
                recordWrap.isActiveAsset = asset.Is_Active__c ? true : false;
                recordWrap.EquipmentType = asset.Equipment_Type__c;
                wrapperList.add(recordWrap);
            }
        }
        return wrapperList;
    }
    
    
    /**
* @author Accenture
* @date 2/25/2019
* @description : Apex method showMutipleAssetCases 
**/
    //method saves the selected asset in the case
    @AuraEnabled
    public static List<Case> showMutipleAssetCases(String caseId){
        List<Case> caseList = null;
        Boolean Is_Multiple_Asset = true;
        Case currentCase = Database.query('select id,ParentId,CaseNumber,Asset_Material__c,Work_Order__c,Status,Case_Sub_Status__c,isWorkOrderCreated__c,Reference_Number__c,Is_Multiple_Asset__c from case where id = :caseId limit 1');   
        String caseNo = currentCase.CaseNumber;
        String refernceNumber = currentCase.Reference_Number__c;
        String parentId = currentCase.ParentId;
        caseList = Database.query('select id,CaseNumber,Asset_Material__c,Asset.Acorn_SID__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Service_Date_Text__c,SLA_Service_DateTime__c,Service_Date__c,Status,Case_Sub_Status__c,Asset.Name,isWorkOrderCreated__c,Reference_Number__c from case where (Reference_Number__c = :refernceNumber OR Reference_Number__c =:caseNo) AND Is_Multiple_Asset__c =:Is_Multiple_Asset and ParentId =:parentId ORDER BY CaseNumber desc');  
        for(Integer i = 0; i < caseList.size(); i++){
            if(caseList[i].Service_Date__c!= null){
                caseList[i].Service_Date_Text__c = caseList[i].Service_Date__c.format();
            }else{
                //nova cop fix
            }
            
        } 
        return caseList;
    }
    /**
	* @author Accenture
	* @date 2/25/2019
	* @description : Apex method showMutipleAssetCasesInfo 
    **/
    //method saves the selected asset in the case
    @AuraEnabled(cacheable=true)
    public static MultiAssetwrapper showMutipleAssetCasesInfo(String caseNo,String recId,String parentId,Integer iteration){
        MultiAssetwrapper result = new MultiAssetwrapper();
        
        List<Case> caseList = new List<Case>();
        List<MultiAssetCase> resultlst = new List<MultiAssetCase>();
        set<Id> accountIdset = new set<Id>();
        set<Id> recordTypeIdSet = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> serviceTypeSet = new Set<string>();
        set<string> assetIdSet = new Set<string>();
        set<string> locationIdSet = new Set<string>();
        MultiAssetCase mac = null;
        set<Id> CaseIdSet = new Set<Id>();
        map<Id,List<Task>> casetaskmap = new map<Id,List<Task>>();
        map<Id, Date> assetParam = new map<Id, Date>();
        map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
        map<Id,GetCaseInformation.Wrapper> caseMessageWrapper = new map<Id,GetCaseInformation.Wrapper>();
        Id groupUser = [SELECT Id,Id__c FROM Generic_Values__mdt where DeveloperName =: Constant_Util.GROUPUSER LIMIT 1].Id__c;
        Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        Id newServiceRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
        for(Case c : [select Id,CPQ_New_Service__c, ParentId,RecordTypeId,Client__c,accountId,CaseNumber,IsOpportunity_Created__c,Tracking_Number__c,Reference_Number__c,Profile_Number__c,Override_Profile_Number_Task__c,
					  Asset.Supplier__r.Parent_Vendor_ID__c, Availability_Checked__c, Location_Code__c, Asset.Product2.Family,Asset.Equipment_Type__c,Asset.Duration__c, 
                      AssetId,Status,Case_Sub_Status__c,EmailofContact__c,SLA_Service_Date_Time__c,Override_PO_Create_Task__c,SuppliedEmail,Case_Reason__c,                
                      PSI_Override_Reason__c,PSI_Comments__c,createdDate,Show_Multiple_Asset_Cases__c,Is_Multiple_Asset__c,Service_Date__c,Origin,PSI__c,OwnerId,
                      PurchaseOrder_Number__c,SlaStartDate,ContactDepartment__c,isMultiCalendarChecked__c,(select id,Name,Asset_Header__r.Name,Asset_Header__r.Occurrence_Type__c,IsManual__c, AssetId__r.Occurrence_Type__c from Case_Assets1__r),
                      Asset_Material__c,Asset.Acorn_SID__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Service_Date_Text__c,SLA_Service_DateTime__c,Asset.Name,isWorkOrderCreated__c, Company_Category__c, Override_Company_Category_Create_Task__c,
                      Location__c,ContactId, Contact_Title__c,Case_Type__c,Case_Sub_type__c,Case_Record_Type__c,Equipment_Size_Code__c,Equipment_Type_Code__c,Material_Type__c, Chargeable__c From case 
                      Where Reference_Number__c =:caseNo and Is_Multiple_Asset__c = true and ParentId=:parentId ORDER BY CaseNumber ASC]){	
                          
                          if((!caseNo.equals(c.caseNumber) && !string.valueof(c.Id).equals(string.valueof(recId))) || (newServiceRecTypeId.equals(c.RecordTypeId)) ) {
                              
                              accountIdset.add(c.Client__c); 
                              requestTypeSet.add(c.Case_Type__c);
                              serviceTypeSet.add(c.Case_Sub_type__c);
                              assetIdSet.add(c.AssetId);
                              locationIdSet.add(c.Location__c);
                              if(c.Service_Date__c!= null){
                                  c.Service_Date_Text__c = c.Service_Date__c.format();
                              }else{
                                  //nova cop fix
                              }
                              if(c.Status.equals(Constant_Util.STATUS_New)){
                                  recordTypeIdSet.add(reqInfoRecTypeId);
                              }
                              caseList.add(c);
                              CaseIdSet.add(c.Id);
                          }
                      }
        for(Asset a : [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Material_Type__c,Project_Code__c,Active__c,Sensitivity_Code__c,End_Date_Based_on_Project_code__c
                       FROM Asset WHERE Id in :assetIdSet LIMIT 49999]){
                           CaseTriggerHelper.casewithContainer.put(a.Id,a);
                       }
        for(Account loc: [SELECT Id,Brand__c,Geography__c,Division__c,Location_Type__c 
                          FROM Account WHERE Id in :locationIdSet LIMIT 49999]){
                              CaseTriggerHelper.casewithLocation.put(loc.Id,Loc);
                          }
        //List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(caseList,recordTypeIdSet,accountIdset,requestTypeSet,ServiceTypeSet,CaseTriggerHelper.casewithContainer,CaseTriggerHelper.casewithLocation);
       List<BusinessRuleHelper.BusinessRulewrapper> brwl = new List<BusinessRuleHelper.BusinessRulewrapper>();
       for(Case c : caseList) {
            List<BusinessRuleHelper.BusinessRulewrapper> brIteration = new List<BusinessRuleHelper.BusinessRulewrapper>();
            brIteration = BusinessRuleHelper.businessRuleSelection(c.Id,recordTypeIdSet);
            if(brwl.isEmpty()) {
                brwl = brIteration;
            } else {
                brwl.addAll(brIteration);
            }
       }
       
	    /* Changed by Srishti-- replacing businessRulewrapperlst with brwl*/
       if(brwl != null && brwl.size() > 0){
            for(BusinessRuleHelper.BusinessRulewrapper brw : brwl){
                if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                    reqInfomap.put(brw.caseId,brw.bRule);
                }
            }
        }
	
        caseMessageWrapper = GetCaseInformation.getCaseValidationMessages(caseList,reqInfomap);
        for(Task t : [Select Id,Subject,WhatId,OwnerId From Task where WhatId In: CaseIdSet and Status =: Constant_Util.OPEN]){
            if(!string.valueof(groupUser).equals(string.valueof(t.OwnerId))){
                if(casetaskmap.IsEmpty() || (!casetaskmap.IsEmpty() && !casetaskmap.containskey(t.WhatId))){
                    casetaskmap.put(t.WhatId, new List<Task>{});
                }
                casetaskmap.get(t.WhatId).add(t);    
            }
            
        }
        Boolean showSummarybtn = true;
        GetCaseInformation.Wrapper caseMsg = null;
        for(Case ca : caseList){
            mac = new MultiAssetCase();
            mac.isWmCapacityEligible = false;
			if(ca.Asset.Supplier__r.Parent_Vendor_ID__c == '8' && ca.Status.equalsIgnoreCase(Constant_Util.Case_New_Status) && 
				 (!ca.Availability_Checked__c) && !string.isBlank(ca.Location_Code__c) && !string.isBlank(ca.SLA_Service_DateTime__c ) 
				 && !string.isBlank(ca.Client__c) && ca.Asset.Product2.Family.equalsIgnoreCase(Constant_Util.ROLLOFF)) {
				mac.isWmCapacityEligible = true;
			}
            caseMsg = caseMessageWrapper != null && caseMessageWrapper.size() > 0 && caseMessageWrapper.containskey(ca.Id) ? caseMessageWrapper.get(ca.Id) : null; 
            mac.isInfoRequired = String.Isblank(caseMsg.reqInfo) ? false : true;
            mac.reqInfo = caseMsg.reqInfo;
            if(!Constant_Util.PICKUP.equals(ca.Case_Record_Type__c)){
                caseMsg.caseInfo = caseMsg.assetValidation ? Constant_Util.READY : caseMsg.caseInfo;
                caseMsg.assetValidation = false;
            }
            if(!Constant_Util.CLOSED.equals(ca.status) && caseMsg.assetValidation){
                mac.assetValidation = caseMsg.caseInfo;
            }else {
                mac.assetValidation = Constant_Util.EMPTY_STRING;
            }
            if( mac.isWmCapacityEligible || ca.isWorkOrderCreated__c || (showSummarybtn && ( (string.IsBlank(ca.Case_Sub_Type__c) && !Constant_Util.CLOSED.equals(ca.status) )|| (string.IsBlank(ca.Service_Date_Text__c) && !Constant_Util.CLOSED.equals(ca.status))|| (!Constant_Util.CLOSED.equals(ca.status) && caseMsg.assetValidation) || (!caseMsg.assetValidation && ((!Constant_Util.READY.equals(caseMsg.caseInfo) && !Constant_Util.CLOSED.equals(ca.status))|| mac.isInfoRequired) ) ))){
                showSummarybtn = false;
            }
            mac.ca = ca;
            if(Constant_Util.STATUS_NEW.equals(ca.status)){
                mac.isEditable = true;
            }else {
                mac.isEditable = false;
            }
            mac.tasklst = !casetaskmap.IsEmpty() && casetaskmap.Size() > 0 && casetaskmap.containskey(ca.Id) ? JSON.serialize(casetaskmap.get(ca.Id)) : null;
            mac.isOpenTask = !casetaskmap.IsEmpty() && casetaskmap.Size() > 0 && casetaskmap.containskey(ca.Id) ? true : false;
            
            resultlst.add(mac);     
        }
        result.MultiAssetCases = resultlst;
        result.shownSummarybtn = showSummarybtn;  
        return result;
    }
    
    /**
* @author Dinesh
* @date 4/9/2019
* @description : Wrapper class to send front end. 
**/
    public inherited sharing class  MultiAssetCase {
        @AuraEnabled public case ca {get;set;}
        @AuraEnabled public string tasklst {get;set;}
        @AuraEnabled public boolean isInfoRequired {get;set;}
        @AuraEnabled public boolean isOpenTask {get;set;}
        @AuraEnabled public string assetValidation {get;set;}
        @AuraEnabled public string reqInfo {get;set;}
        @AuraEnabled public boolean isEditable {get;set;}
		@AuraEnabled public boolean isWmCapacityEligible {get;set;}
    }
    public inherited sharing Class MultiAssetwrapper {
        @AuraEnabled Public List<MultiAssetCase> MultiAssetCases {get;set;}
        @AuraEnabled Public Boolean shownSummarybtn {get;set;}
    }
    
    /**
* @author Accenture
* @date 2/25/2019
* @description : Apex method moveToNextRelatedAssetCase 
**/
    @AuraEnabled
    public static string moveToNextRelatedAssetCase(String caseId){
        List<Case> caseList = null;
        String caseIdToNavigate = '';
        Boolean Is_Multiple_Asset = true;
        String case_status = Constant_Util.STATUS_NEW;
        Case currentCase = Database.query('select id,CaseNumber,Status,Case_Sub_Status__c,isWorkOrderCreated__c,Reference_Number__c,Is_Multiple_Asset__c from case where id = :caseId limit 1');   
        String caseNo = currentCase.CaseNumber;
        String refernceNumber = currentCase.Reference_Number__c;
        caseList = Database.query('select id,CaseNumber,Status,Case_Sub_Status__c,Asset.Name,isWorkOrderCreated__c,Reference_Number__c from case where Reference_Number__c = :refernceNumber AND CaseNumber !=:caseNo AND Is_Multiple_Asset__c =:Is_Multiple_Asset and status =:case_status ORDER BY CaseNumber desc');
        if(!caseList.isEmpty()){
            caseIdToNavigate = caseList[0].id;
        }
        return caseIdToNavigate;
    }
    
     @AuraEnabled
    public static Case getCaseDetails(String caseId){
        String case_status = Constant_Util.STATUS_NEW;
        Case currentCase = Database.query('select id,Location__r.Name,Location__c,AssetId,Asset.Name,Asset_Material__c,Service_Date_Text__c,Contact.Name,Contact_Title__c,Case_Type__c,Case_Sub_Type__c,Reference_Number__c,SLA_Service_DateTime__c,Service_Date__c,Work_Order__r.WorkOrderNumber,Acorn_Work_order__c,Tracking_Number__c,Case_Record_Type__c,Status,Case_Sub_Status__c,Case_Reason__c,PurchaseOrder_Number__c from case where id = :caseId limit 1');  
        if(currentCase.Service_Date__c!= null){
            currentCase.Service_Date_Text__c = currentCase.Service_Date__c.format();
        }else{
            //nova cop fix
        }
        return currentCase;
    }
    
    @AuraEnabled
    public static String getRecordTypeId(Id caseId){
        return [Select recordTypeId from Case where Id =: caseId].recordTypeId;
    }
    
    @AuraEnabled
    public static String getStatusForCase(Id caseId){
        return [Select Status from Case where Id =: caseId].Status;
    }
    
    @AuraEnabled
    public static LIst<Case> disableCheck(Id caseId){
        return [SELECT Status, Case_Sub_Status__c , Asset.Name , RecordType.Name, Case_Type__c, Case_Sub_Type__c, Case_Reason__c, isWorkOrderCreated__c, Acorn_Work_order__c, Origin,Reference_Number__c,AssetId,Is_Multiple_Asset__c, Show_Multiple_Asset_Cases__c FROM Case WHERE Id = : caseId];
    }
    @AuraEnabled
    public static void replaceAssetHeader(String caseId,String assetValue,String[] selectedAssets){
        List<Case> caseList = new list<Case>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        Case currentCase = Database.query('select Id,AssetId from case where id = :caseId limit 1');
        if(!String.isBlank(assetValue)){
            currentCase.AssetId=assetValue;
        }
        if(selectedAssets!=null && !selectedAssets.isEmpty() && selectedAssets.size() > 0){ //Mofdified for SDT-33436
            sessionPart.put(caseId, selectedAssets,3600,Cache.Visibility.ALL,true);
            //currentCase.Is_Multiple_Asset__c=true;
        }
/* 
        //Commented becuase both combination are same, It will never execute! SDT-33436
        else if(selectedAssets!=null && selectedAssets.isEmpty()){
            //currentCase.Is_Multiple_Asset__c=false;
            sessionPart.put(caseId, selectedAssets,3600,Cache.Visibility.ALL,true);
        }
//Commented becuase both combination are same, It will never execute! SDT-33436
		*/

        //TCS-pkulkarn-SDT-42417-20-Nov-2024-Added to capture Selected Assets (quote creation) on Case
        String[] assetIdArray = selectedAssets;
        if(String.isBlank(currentCase.AssetId) == false)
        {
            assetIdArray.add(currentCase.AssetId);
        }
        currentCase.Selected_Asset_Header_Ids__c = AssetQuerySelector.covertStringArrayToDelimiterSeparatedString(assetIdArray, ';');
        //TCS-pkulkarn-SDT-42417-20-Nov-2024-End
		
        try{
if(currentCase != null){ //Mofdified for SDT-33436
            update currentCase;
}             
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            throw new AuraHandledException('Exception occurred');
        }
    }
    /**
	* @author Accenture
	* @date 6/23/2020
	* @description : Apex method fetchCaseSummary 
    **/
    //method to return New Service Case Summary.
    @AuraEnabled(cacheable=true)
    public static String fetchCaseSummary(String recId){
    	List<Comment__c> caCom = [Select Id,Comment__c from Comment__c where Case__c =:recId Order By CreatedDate ASC Limit 1];
        string comment = caCom[0].Comment__c;
        comment = comment.replace('True','Yes');
        comment = comment.replace('true', 'Yes');
        comment = comment.replace('False', 'No');
        comment = comment.replace('false', 'No');
        return comment;
    }
}
