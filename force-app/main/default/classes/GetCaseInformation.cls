/**
* @author Accenture
* @date 3/1/2019
* @description : Apex class GetCaseInformation 
**/
public with sharing class GetCaseInformation { 
    private static List<Case> myCases = new List<case>();
    public static Map<Id,Asset> casewithContainer = new Map<Id,Asset>();
    public static Map<Id,Account> casewithLocation = new Map<Id,Account>();
    private static Flow.Interview.Business_Rule_with_Accounts brFlow {get; set;}
    private static boolean isAutoApproved;
    private static boolean ruleMatched;
    private static boolean occurenceLimit;
    private static string caseAssetValidationMessage;
    //SDT 39047
    public static string  LoggedInUserProfile ='';
	//changes for SDT - 31503
    //public static string  ADD_QUOTE_ERROR_MODIFY_CASE = 'The request type is not yet available in Salesforce, please use Acorn to execute the request.';
    public static string  ADD_QUOTE_ERROR_SERVICE_REQ_CASE = 'If you are trying to create a Bulk Pickup, Check Sammy, or Got Junk request, please use Acorn to execute this request';
    /**
* @author Accenture
* @date 3/1/2019
* @description : Apex method getMessage to display the business rule related information of case landing page
**/ 
    @AuraEnabled
    public static Wrapper getMessage(Id caseId){
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        set<Id> accountIdset = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> ServiceTypeSet = new Set<string>();
        set<Id> relatedCaseIdSet = new set<Id>();
        set<Id> recordTypeIdSet = new set<Id>();
        List<Id> preSelectedAssets =new List<Id>();
        map<Id,Business_Rule__c> approvalmap = new map<Id,Business_Rule__c>();
        map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
        map<Id,date> caseAssetParam = new map<Id,date>();
        Set<String> workOrderStatus = new Set<String>{Constant_Util.INPROGRESS,Constant_Util.STATUS_NEW,Constant_Util.COMPLETED,Constant_Util.CLOSED};
            myCases = [SELECT Id, ParentId,Client__c,CPQ_New_Service__c,accountId,CaseNumber,Reference_Number__c,Profile_Number__c,Override_Profile_Number_Task__c,Location__c,ContactId, Contact_Title__c,Case_Type__c,Case_Sub_type__c,
                       AssetId,Status,Case_Sub_Status__c, EmailofContact__c,SLA_Service_Date_Time__c,Override_PO_Create_Task__c,SuppliedEmail,Case_Reason__c,                
                       PSI_Override_Reason__c,PSI_Comments__c,createdDate,Show_Multiple_Asset_Cases__c,Is_Multiple_Asset__c,Service_Date__c,Origin,PSI__c,OwnerId,RecordTypeId,
                       PurchaseOrder_Number__c,SlaStartDate,ContactDepartment__c,isMultiCalendarChecked__c,Is_Haul_Away_Service__c,Haul_Away_information__c, Haul_Away_Vendor__c,(select id,Name,Asset_Header__r.Name from Case_Assets1__r) FROM CASE WHERE id =:caseId LIMIT 1]; //41473 - added Is_Haul_Away_Service__c,Haul_Away_information__c field
        accountIdset.add(myCases[0].Client__c); 
        requestTypeSet.add(myCases[0].Case_Type__c);
        ServiceTypeSet.add(myCases[0].Case_Sub_type__c);
        // Start SDT- 4890
        List<SBS_Case_Asset__c> caseAssetList = (List<SBS_Case_Asset__c>) myCases[0].Case_Assets1__r;
        // END
        List<Case> relatedCaseList = new List<Case>();
        List<Case> relCaseList = new List<Case>();
        List<Case> feedRelatedCaseList = new List<Case>();
        List<Case> newStatusCaseList = new List<Case>();
        for(Case c : [SELECT Id,CaseNumber,Status,Show_Multiple_Asset_Cases__c,Case_Sub_Status__c,Asset.Name,Reference_Number__c,Is_Multiple_Asset__c,ParentId from case where Reference_Number__c = :myCases[0].Reference_Number__c]){
            if(c.Is_Multiple_Asset__c){
                if(Constant_Util.STATUS_NEW.equals(c.status)){
                    relatedCaseIdSet.add(c.Id);
                    if(c.Reference_Number__c==myCases[0].CaseNumber){
                        relCaseList.add(c); 
                    }
                }
                if(Constant_Util.PENDING.equals(c.status)){
                    relatedCaseIdSet.add(c.Id);
                }
                if(string.IsNotBlank(String.valueof(c.ParentId)) && !Constant_Util.OPEN.equals(c.status)){
                    feedRelatedCaseList.add(c);
                }
                relatedCaseList.add(c);
            }
            if(c.Id != myCases[0].id && Constant_Util.STATUS_NEW.equals(c.status) && myCases[0].ParentId==c.ParentId){
                newStatusCaseList.add(c); 
            }
            
        }
        List<Task> openTasks = [SELECT Id, Status, Priority, IsClosed From Task where WhatId IN :relatedCaseIdSet AND Status =: Constant_Util.OPEN];
        for(Asset a : [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Material_Type__c,Project_Code__c,Active__c,Sensitivity_Code__c,End_Date_Based_on_Project_code__c
                       FROM Asset WHERE Id =: myCases[0].AssetId LIMIT 49999]){
                           CaseTriggerHelper.casewithContainer.put(a.Id,a);
                       }
        for(Account loc: [SELECT Id,Brand__c,Geography__c,Division__c,Location_Type__c 
                          FROM Account WHERE Id =: myCases[0].Location__c LIMIT 49999]){
                              CaseTriggerHelper.casewithLocation.put(loc.Id,Loc);
                          }
        string woKey = null;
        if(myCases[0].Service_Date__c != null){
            Date startDate = (myCases[0].Service_Date__c).toStartOfMonth();
            Date endDate = (myCases[0].Service_Date__c).addMonths(1).toStartofMonth().addDays(-1);
            for(AggregateResult wo : [Select COUNT(Id)num,AssetId,Customer_Location__c,Case.Case_Sub_Type__c  from WorkOrder where AssetId IN:CaseTriggerHelper.casewithContainer.keySet()  and Customer_Location__c IN:CaseTriggerHelper.casewithLocation.keySet() and StatusCategory IN:workOrderStatus and Case_Subtype__c =: myCases[0].Case_Sub_type__c and Is_Bypass__c = false and Service_Date__c >=: startDate and Service_Date__c <=: endDate Group by AssetId,Customer_Location__c,Case.Case_Sub_Type__c]){
                woKey = (String)wo.get('AssetId') + (String)wo.get('Customer_Location__c') + (String)wo.get('Case_Sub_Type__c');
                CaseTriggerHelper.caseWorkOrderCount.put(woKey,(Integer)wo.get('num'));
            }
        }
        List<WorkOrder> workOrderList = [SELECT id,caseId from WorkOrder where caseId= :caseId and case.isWorkOrderCreated__c = true];
        caseAssetParam.put(myCases[0].AssetId,myCases[0].Service_Date__c);
        
        Wrapper wrapperClass = new Wrapper();
        wrapperClass.caseInfo = Constant_Util.EMPTY_STRING;
        wrapperClass.caseId = myCases[0].Id;
        wrapperClass.disableMultiCase = myCases[0].isMultiCalendarChecked__c;
        
        if(myCases[0].AssetId != null && !String.isBlank(myCases[0].AssetId)){
            wrapperClass.AssetSCode = (CaseTriggerHelper.casewithContainer).get(myCases[0].AssetId).Sensitivity_Code__c;
        }
        if(sessionPart.contains(caseId)){
            String[] assets= (String[])sessionPart.get(caseId);
            for(String s : assets){
                preSelectedAssets.add(s);
            }
        }
        wrapperClass.CaseType = myCases[0].Case_Type__c;
        wrapperClass.CaseReason = myCases[0].Case_Reason__c;
        wrapperClass.CaseSubType = myCases[0].Case_Sub_type__c;
        wrapperClass.CaseStatus = myCases[0].Status;       
        wrapperClass.relatedCaseList = relatedCaseList;
        wrapperClass.multiAssetSelections = preSelectedAssets;
        try{
            if(myCases[0].Status.equals(Constant_Util.STATUS_New) || myCases[0].Status.equals(Constant_Util.PENDING)){
                Id approvalRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
                Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
                recordTypeIdSet.add(approvalRecTypeId);
                if(myCases[0].Status.equals(Constant_Util.STATUS_New)){
                    recordTypeIdSet.add(reqInfoRecTypeId);
                }
                //List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCases,recordTypeIdSet,accountIdset,requestTypeSet,ServiceTypeSet,CaseTriggerHelper.casewithContainer,CaseTriggerHelper.casewithLocation);
                List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCases[0].Id,recordTypeIdSet);
                if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
                    for(BusinessRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                        if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                            reqInfomap.put(brw.caseId,brw.bRule);
                        }else if( approvalRecTypeId.equals(brw.bRule.RecordTypeId)){
                            approvalmap.put(brw.caseId,brw.bRule);
                        }
                    }
                }
            }
            Business_Rule__c thisBusinessRule = new Business_Rule__c();
            if(myCases[0].Status == Constant_Util.PENDING){
                if(newStatusCaseList.size() >= 1){
                    wrapperClass.caseInfo = Constant_Util.WORKORDER_INITIATED_RELATEDCASES;
                }else{
                    wrapperClass.caseInfo = Constant_Util.WO_INITIATED;
                }
            }
            else if((myCases[0].Status == Constant_Util.OPEN || myCases[0].Status == Constant_Util.INTEGRATION_ERROR) /*&& myCases[0].Is_Multiple_Asset__c == false*/){
                List<String> sCodeList = new List<String>{Constant_Util.UTILITY, Constant_Util.UTL, Constant_Util.CAM};
                    if(newStatusCaseList.size() >= 1){
                        wrapperClass.caseInfo = Constant_Util.WORKORDER_CREATED_RELATEDCASES;
                    }else if(String.isBlank(myCases[0].Case_Sub_Status__c) && myCases[0].AssetId != null && !String.isBlank(myCases[0].AssetId) && sCodeList.contains((CaseTriggerHelper.casewithContainer).get(myCases[0].AssetId).Sensitivity_Code__c)){
                        String sCode = (CaseTriggerHelper.casewithContainer).get(myCases[0].AssetId).Sensitivity_Code__c;
                        if(sCode == Constant_Util.UTILITY || sCode == Constant_Util.UTL || sCode == Constant_Util.CAM){
                            wrapperClass.caseInfo = Constant_Util.PROGRESS_CASE;
                        }
                    }
                else if(workOrderList.size() == 0)
                {
                    wrapperClass.caseInfo = Constant_Util.PROGRESS_CASE;
                }
                else{
                    wrapperClass.caseInfo = Constant_Util.WO_CREATED;
                }
            }
            else if(myCases[0].CaseNumber != myCases[0].Reference_Number__c &&  myCases[0].Status==Constant_Util.STATUS_New && myCases[0].Show_Multiple_Asset_Cases__c == true && String.isBlank(myCases[0].ParentId)){                
                wrapperClass.caseInfo += Constant_UTIL.MULTIPLE_ASSET_CASES;
            }
 
			else if((String.isBlank(myCases[0].AssetId) || (Constant_Util.UNKNOWN).equals(myCases[0].AssetId)) && myCases[0].Case_Sub_type__c != Constant_Util.BALES )
            {
                wrapperClass.caseInfo += Constant_Util.SELECT_ASSET;
            }																																						 
		    else if(String.isBlank(myCases[0].ContactId) || (Constant_Util.UNKNOWN).equals(myCases[0].ContactId))
            {
                wrapperClass.caseInfo += Constant_Util.SELECT_CONTACT;
            }
			  
            else if(String.isBlank(myCases[0].Case_Sub_type__c) || (Constant_Util.UNKNOWN).equals(myCases[0].Case_Sub_type__c))
            {
                wrapperClass.caseInfo += Constant_Util.SELECT_CASESUBTYPE;
            }
            // SDT-7903 - SLA Date 
            else if(myCases[0].SLA_Service_Date_Time__c == null)
            {
                wrapperClass.caseInfo += Constant_Util.SELECT_CASESLADATE;
            } 
            else if(!preSelectedAssets.isEmpty() && preSelectedAssets.size() > 0 && myCases[0].Status==Constant_Util.STATUS_New && myCases[0].Show_Multiple_Asset_Cases__c == false && myCases[0].Is_Multiple_Asset__c == true){ //&& myCases[0].Is_Multiple_Asset__c == true
                wrapperClass.caseInfo += Constant_Util.MULTIPLE_ASSET;
            }
            else if(!feedRelatedCaseList.isEmpty() && feedRelatedCaseList.size() >= 1 && myCases[0].Show_Multiple_Asset_Cases__c == false && myCases[0].Is_Multiple_Asset__c == true){ //&& myCases[0].Is_Multiple_Asset__c == true
                wrapperClass.caseInfo += Constant_Util.MULTIPLE_ASSET;
            }
            // Start SDT- 4890
            else if(caseAssetList.isEmpty() && wrapperClass.CaseType.equals(Constant_Util.PICKUP_CSTYPE))
            {
                List<Asset> caseAssetDetailEndDateList = [Select ID,Name, ParentId,Service_Type__c,Has_Extra_Pickup__c,End_Date__c From Asset where ParentId=:myCases[0].AssetId and End_Date__c != null and End_date__c < TODAY and Is_Active__c = true];
                
                if(!caseAssetDetailEndDateList.isEmpty())
                {
                    wrapperClass.caseInfo += Constant_Util.CASE_ASSETS_END_DATE_PASSED;
                }
                else
                {
                    wrapperClass.caseInfo += Constant_Util.NO_CASE_ASSETS;
                }
            }
            // END 
            else if(!string.isBlank(getAssetDetail(caseAssetParam).values().get(0))) // Asset Validation
            {
                wrapperClass.caseInfo += caseAssetValidationMessage;
            }    
            else if(myCases[0].Status.equals(Constant_Util.STATUS_New)){
                wrapperClass.reqInfo = Constant_Util.EMPTY_STRING;
                Business_Rule__c caseRule = new Business_Rule__c(); //= CaseTriggerHelper.getbusinessRule(myCases[0],Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId(),false,false);
                caseRule = reqInfomap != null && reqInfomap.size() > 0 && reqInfomap.containskey(myCases[0].Id) ? reqInfomap.get(myCases[0].Id) : null;
                if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PO_NUMBER) && String.isBlank(myCases[0].PurchaseOrder_Number__c) && !(myCases[0].Override_PO_Create_Task__c)){
                    wrapperClass.reqInfo += Constant_Util.PO_MSG + Constant_Util.NEW_LINE;            
                }
                //commented as part of sdt 33312
                /*if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PROFILE_NUMBER) && String.isBlank(myCases[0].Profile_Number__c) && !(myCases[0].Override_Profile_Number_Task__c)){
                    wrapperClass.reqInfo += Constant_Util.PROFILE_MSG + Constant_Util.NEW_LINE;            
                }*/
                if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PSI) && myCases[0].PSI__c == null){
                    if(myCases[0].PSI_Override_Reason__c == null){ 
                        wrapperClass.reqInfo += Constant_Util.PSI_REQUIRED + Constant_Util.NEW_LINE;
                    }
                    else if(myCases[0].PSI_Override_Reason__c != null && myCases[0].PSI_Override_Reason__c == Constant_Util.OTHER_API && myCases[0].PSI_Comments__c == null)  {
                        wrapperClass.reqInfo += Constant_Util.PSI_COMMENTS + Constant_Util.NEW_LINE;
                    }
                    else{
                        //Nova cop fix
                    }
                }
                if(string.IsBlank(wrapperClass.reqInfo)){
                    if((myCases[0].CaseNumber == myCases[0].Reference_Number__c || (!feedRelatedCaseList.isEmpty() && feedRelatedCaseList.size() >= 1)) && myCases[0].Show_Multiple_Asset_Cases__c == true){                
                        wrapperClass.caseInfo = Constant_Util.READY_MULTIASSET;
                    }else{
                        wrapperClass.caseInfo = Constant_Util.READY;
                    }
                }
            }
            If( myCases[0].Status.equals(Constant_Util.STATUS_New) || (myCases[0].Status.equals(Constant_Util.PENDING) && (Constant_Util.PENDING_CUSTOMER_INFORMATION.equals(myCases[0].Case_Sub_Status__c) || Constant_Util.PENDING_REQUEST_APPROVAL.equals(myCases[0].Case_Sub_Status__c)) ) ){
                BusinessRuleHelper.wrapperResult brwrapper = null;
                map<Id,Boolean> autoApprovalmap = new map<Id,Boolean>();
                map<Id,Boolean> rulematchedmap = new map<Id,Boolean>();
                map<Id,Boolean> occurenceLimitmap = new map<Id,Boolean>();
                if(approvalmap != null && approvalmap.size() > 0){
                    brwrapper = BusinessRuleHelper.getapprovallog(approvalmap,myCases,CaseTriggerHelper.caseWorkOrderCount);
                    autoApprovalmap = brwrapper.autoApprovemap;
                    rulematchedmap = brwrapper.rulematchedmap;
                    occurenceLimitmap = brwrapper.occurenceLimitmap;
                }
                thisBusinessRule = approvalmap != null && approvalmap.size() > 0 && approvalmap.containskey(myCases[0].Id) ? approvalmap.get(myCases[0].Id) : null;
                isAutoApproved = autoApprovalmap != null && autoApprovalmap.size() > 0 ? autoApprovalmap.containskey(myCases[0].Id) ? autoApprovalmap.get(myCases[0].Id) : true : true;
                ruleMatched = rulematchedmap != null && rulematchedmap.size() > 0 && rulematchedmap.containskey(myCases[0].Id) ? rulematchedmap.get(myCases[0].Id) : false;
                occurenceLimit = occurenceLimitmap != null && occurenceLimitmap.size() > 0 && occurenceLimitmap.containskey(myCases[0].Id) ? occurenceLimitmap.get(myCases[0].Id) : false;
                wrapperClass.approvalInfo = Constant_Util.EMPTY_STRING;
                wrapperClass.enableapprovalInfo = (String.isNotBlank(myCases[0].Client__c) && String.isNotBlank(myCases[0].Case_Sub_type__c)) ? true : false;
                String requestorOnlyAppr = Constant_Util.EMPTY_STRING;
                String notRequestorOnlyAppr = Constant_Util.EMPTY_STRING;
                if(isAutoApproved && !ruleMatched && String.isNotBlank(myCases[0].Client__c) && String.isNotBlank(myCases[0].Case_Sub_type__c)){
                    wrapperClass.approvalInfo += Constant_Util.NO_APPROVAL_REQUIRED;
                }
                else if(thisBusinessRule != null){
                    //wrapperClass.occurrenceLimit = Integer.valueof(thisBusinessRule.Occurrence_Limit__c);
                    List<Service_Approver__c> serviceapproverlst = [Select id,Requester_Only__c,Account_Team_Member__c,Approver_Type__c,Approver_Contact__c,Title__c,Account_Department__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,
                                                                    Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,Email__c,User__c,User__r.FirstName,User__r.LastName from Service_Approver__c where Business_Rule__c =: thisBusinessRule.Id and Active__c = true LIMIT 49999];
                    Boolean flag = false;
                    string approver ='';
                    Boolean isRequestor = false;
                    if(isAutoApproved && ruleMatched){
                        wrapperClass.approvalInfo += Constant_Util.AUTO_APPROVED;
                    }
                    else if(thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null){
                        
                        for(Service_Approver__c sap :serviceapproverlst){
                            approver = (sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName;
                            if(!sap.Requester_Only__c){
                                if(!flag){
                                    notRequestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                    flag= true;
                                }else{
                                    notRequestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                                }
                            }else if(sap.Requester_Only__c){
                                if(!isRequestor){
                                    isRequestor = true;
                                    requestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                }else{
                                    requestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                                }
                            }
                        }
                        if(flag){
                            wrapperClass.approvalInfo += notRequestorOnlyAppr;
                            wrapperClass.approvalInfo += isRequestor ? Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + '<div style="color: #3c8a2e;">' + RequestorOnlyAppr + '</div>': ''; 
                        }
                    }else if(!thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null ){
                        for(Service_Approver__c sap :serviceapproverlst){
                            approver = (sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName;
                            if(!sap.Requester_Only__c){
                                if(!flag){
                                    notRequestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                    flag= true;
                                }else{
                                    notRequestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                                }
                            }else if(sap.Requester_Only__c){
                                if(!isRequestor){
                                    isRequestor = true;
                                    requestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                }else{
                                    requestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                                }
                            }
                        }
                        if(flag){
                            wrapperClass.approvalInfo += notRequestorOnlyAppr;
                            wrapperClass.approvalInfo += isRequestor ? Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + '<div style="color: #3c8a2e;">' + RequestorOnlyAppr + '</div>': ''; 
                        }
                    }
                    else{
                        //Nova cop fix
                    }
                    If(isRequestor){
                        wrapperClass.approvalInfo += '<div class = "spl">' + system.Label.ForRequestorOnly + '</div>';
                    }
                    If(!occurenceLimit && thisBusinessRule.Occurrence_Limit__c != null && !isAutoApproved && thisBusinessRule.Occurrence_Limit__c > 0){
                        wrapperClass.approvalInfo += '<div class = "spl">'+ 'The account has Occurrence Limit of ' + String.valueof(thisBusinessRule.Occurrence_Limit__c) + '. Approval is required' + '</div>';
                    }
                    If(String.isNotBlank(thisBusinessRule.Special_Instructions_Approval__c)){
                        wrapperClass.approvalInfo += '<div class = "spl">' + '<strong>' + 'Approval Instructions' + '</strong>' + '</div>';
                        wrapperClass.approvalInfo += '<div>' + thisBusinessRule.Special_Instructions_Approval__c + '</div>';
                    }
                }
            }
        }
        Catch(exception ex){
            System.debug('Exception::::'+ex.getStackTraceString());
            System.debug('Exception::::'+ex.getMessage());
            wrapperClass = new Wrapper();
        }
        return wrapperClass;
    }
    
    /**
* @author WM
* @date 9/4/2019
* @description : Apex method getAssetDetail to get the Aseet details on case summary page.
**/
    public static map<Id, String> getAssetDetail(map<Id, Date> assetParam){
        
        
        
        boolean isParentActive = false, isActive = false; 
		boolean isEndedExtendedAssets = false; //SDT-33377
        Map<Id,String> assetStatus =new Map<Id,String>();
        if(!assetParam.isEmpty()) {
            for(Asset header : [ Select Id,Name,Occurrence_Type__c,(Select Id,Name, ParentId,Service_Type__c,Start_Date__c,End_Date__c,ProductFamily,Occurrence_Type__c, Material_Type__c,Has_Extra_Pickup__c,Is_Active__c, Is_Core_Service__c from ChildAssets),Product2.Equipment_Type__c,ProductFamily,Material_Type__c,Is_Active__c,Start_Date__c,End_Date__c From Asset where Id IN: assetParam.keySet() Limit 49000]){
                integer isCoreServiceActive = 0, isScheduleActiveHasXPUTrue = 0, isScheduleActiveHasXPUFalse = 0, isScheduleActiveFalseHasXPUTrue = 0, isScheduleActiveFalseHasXPUFalse = 0,
                    isOnCallActiveHasXPUTrue = 0, isOnCallActiveHasXPUFalse = 0, isOnCallActiveFalseHasXPUTrue = 0, isOnCallActiveFalseHasXPUFalse = 0,
                    isHaulActive = 0, IsCoreActiveTrue = 0, isActiveOnCall = 0, IsRecyclingActiveTrue = 0, IsBalerTrue = 0;
                string smsg = Constant_Util.EMPTY_STRING;
				//SDT-33377
				Datetime serviceDateCase = assetParam.get(header.Id);
				isEndedExtendedAssets = getExtendedAssetDetail(header,serviceDateCase);

				
				//SDT-33377
                //system.debug('Validation message'+smsg);
                for(Asset assetDetail : header.ChildAssets){
                    Datetime caseServiceDate = assetParam.get(header.Id);
                    //isParentActive = header.End_Date__c == null ? true : header.Start_Date__c <= caseServiceDate && header.End_Date__c >= caseServiceDate ? true : false;
                    //SDT-12849
                    //Start
                    isParentActive = false;
                    
                    if(header.End_Date__c == Null){
                    	if(header.Start_Date__c <= caseServiceDate){
                    		isParentActive = true;
                    	}
                    } 
                    else{
                    	if(header.Start_Date__c <= caseServiceDate && header.End_Date__c >= caseServiceDate){
                    		isParentActive = true;
                    	}   
                    } 
                    //Stop 
                    
                    if(isParentActive || isEndedExtendedAssets){ // SDT-33377 condition added
                        //isActive =  String.isBlank(String.valueOf(assetDetail.End_Date__c)) ? true :assetDetail.Start_Date__c <= caseServiceDate && assetDetail.End_Date__c >= caseServiceDate ? true : false;
                         
                        //SDT-11621
                        //Start
                        isActive = false;
                        
                        if(assetDetail.End_Date__c == Null){
                        	if(assetDetail.Start_Date__c <= caseServiceDate){
                        		isActive = true;
                        	}
                        } 
                        else{
                        	if(assetDetail.Start_Date__c <= caseServiceDate && assetDetail.End_Date__c >= caseServiceDate){
                        		isActive = true;
                        	}
                        } 
                        //Stop
                        
                        IsCoreActiveTrue = assetDetail.Is_Core_Service__c && isActive ? IsCoreActiveTrue + 1 : IsCoreActiveTrue;
                        /*if(!isActive && assetDetail.Is_Core_Service__c){
						smsg = Constant_Util.CASE_ASSETS_END_DATE_PASSED;
						caseAssetValidationMessage = smsg;
						} */ 
                        
                         isCoreServiceActive = assetDetail.Is_Core_Service__c && isActive ? isCoreServiceActive + 1 : isCoreServiceActive;
                        
                        if(Constant_Util.COMMERCIAL.equals(header.ProductFamily) && Constant_Util.PICKUP_CSTYPE.equals(assetDetail.Service_Type__c)){
                            // Schedule Active - HasXPU Active
                            isScheduleActiveHasXPUTrue = assetDetail.Occurrence_Type__c == Constant_Util.SCHEDULED && 
                                assetDetail.Has_Extra_Pickup__c && 
                                isActive ? isScheduleActiveHasXPUTrue + 1 : isScheduleActiveHasXPUTrue;
                            
                            // Schedule Active - HasXPU In-Active
                            isScheduleActiveHasXPUFalse = assetDetail.Occurrence_Type__c == Constant_Util.SCHEDULED && 
                                !assetDetail.Has_Extra_Pickup__c && 
                                isActive ? isScheduleActiveHasXPUFalse + 1 : isScheduleActiveHasXPUFalse;
                            
                            // Schedule In-Active - HasXPU Active 
                            isScheduleActiveFalseHasXPUTrue = assetDetail.Occurrence_Type__c == Constant_Util.SCHEDULED && 
                                assetDetail.Has_Extra_Pickup__c && 
                                !isActive ? isScheduleActiveFalseHasXPUTrue + 1 : isScheduleActiveFalseHasXPUTrue;
                            
                            // Schedule In-Active - HasXPU In-Active
                            isScheduleActiveFalseHasXPUFalse = assetDetail.Occurrence_Type__c == Constant_Util.SCHEDULED && 
                                !assetDetail.Has_Extra_Pickup__c && 
                                !isActive ? isScheduleActiveFalseHasXPUFalse + 1 : isScheduleActiveFalseHasXPUFalse;
                            
                            // OnCall Active - HasXPU Active
                            isOnCallActiveHasXPUTrue = assetDetail.Occurrence_Type__c == Constant_Util.ON_CALL &&
                                assetDetail.Has_Extra_Pickup__c && 
                                isActive ? isOnCallActiveHasXPUTrue + 1 : isOnCallActiveHasXPUTrue;
                            
                            // OnCall Active - HasXPU False
                            isOnCallActiveHasXPUFalse = assetDetail.Occurrence_Type__c == Constant_Util.ON_CALL &&
                                !assetDetail.Has_Extra_Pickup__c && 
                                isActive ? isOnCallActiveHasXPUFalse + 1 : isOnCallActiveHasXPUFalse;
                            
                            // OnCall In-Active - HasXPU True
                            isOnCallActiveFalseHasXPUTrue = assetDetail.Occurrence_Type__c == Constant_Util.ON_CALL &&
                                assetDetail.Has_Extra_Pickup__c && 
                                !isActive ? isOnCallActiveFalseHasXPUTrue + 1 : isOnCallActiveFalseHasXPUTrue;
                            
                            // OnCall In-Active - HasXPU False
                            isOnCallActiveFalseHasXPUFalse = assetDetail.Occurrence_Type__c == Constant_Util.ON_CALL &&
                                !assetDetail.Has_Extra_Pickup__c && 
                                !isActive ? isOnCallActiveFalseHasXPUFalse + 1 : isOnCallActiveFalseHasXPUFalse;
                            
                            //isActiveOnCall = assetDetail.Occurrence_Type__c == Constant_Util.ON_CALL ? isOnCallActiveFalseHasXPUFalse + 1 : isActiveOnCall;
                            
                            if(Constant_Util.SCHEDULED.equals(header.Occurrence_Type__c)) {
                                if (isScheduleActiveHasXPUTrue > 0 && isOnCallActiveHasXPUFalse > 0)
                                {
                                    smsg = Constant_Util.EMPTY_STRING;
                                }

                                if(string.isBlank(smsg) && isCoreServiceActive == 0) // Validation 1
                                {
                                    smsg = Constant_Util.CASE_ASSETS_END_DATE_PASSED;
                                }
                                
                                else if(isScheduleActiveHasXPUTrue == 0) // Validation 2
                                {
                                    smsg = Constant_Util.HAS_XPU_COMPONENT_NOT_EXISTS;
                                }
                                else if(isScheduleActiveHasXPUTrue > 0 && isOnCallActiveHasXPUTrue > 0) // Validation 4
                                {
                                    smsg = Constant_Util.HAS_XPU_COMPONENT_CORRUPTED;
                                }     
                                else if(isScheduleActiveHasXPUTrue > 0 && isOnCallActiveHasXPUFalse == 0) // Validation 3
                                {
                                    smsg = smsg = Constant_Util.HAS_XPU_COMPONENT_NOT_ACTIVE_SERVICEDATE;
                                }
                                else if(isScheduleActiveHasXPUTrue > 1 || isOnCallActiveHasXPUFalse > 1) //
                                {
                                    smsg = Constant_Util.HAS_XPU_COMPONENT_CORRUPTED;
                                }

                                /*else if (isScheduleActiveFalseHasXPUTrue > 0 && isOnCallActiveFalseHasXPUFalse > 0)
                                {
                                    smsg = Constant_Util.HAS_XPU_COMPONENT_NOT_ACTIVE_SERVICEDATE;
                                }*/
                            } else if(Constant_Util.ON_CALL.equals(header.Occurrence_Type__c)){
                                if(isOnCallActiveHasXPUFalse > 1 || isOnCallActiveHasXPUTrue > 1)
                                {
                                    smsg = Constant_Util.ASSET_COMPONENT_CORRUPTED;
                                }
                                else if(isOnCallActiveHasXPUFalse == 0)
                                {
                                    smsg = Constant_Util.NO_CASE_ASSETS;
                                }
								else if(isOnCallActiveHasXPUFalse > 0)
                                {
                                    smsg = Constant_Util.EMPTY_STRING;
                                }
                            }
                            
                        } else if(Constant_Util.ROLLOFF.equals(header.ProductFamily) && (Constant_Util.ON_CALL.equals(header.Occurrence_Type__c) || (Constant_Util.SCHEDULED_ON_CALL).equals(header.Occurrence_Type__c))) {   
                            
                            IsRecyclingActiveTrue = Constant_Util.RECYCLING.equals(assetDetail.Service_Type__c) && isActive ? IsRecyclingActiveTrue + 1 : IsRecyclingActiveTrue;
                            IsBalerTrue = Constant_Util.BALER.equals(header.Product2.Equipment_Type__c) && Constant_Util.PICKUP_CSTYPE.equals(assetDetail.Service_Type__c) && isActive ? IsBalerTrue + 1 : IsBalerTrue;
                            if(IsCoreActiveTrue == 0 && IsRecyclingActiveTrue == 0 && IsBalerTrue == 0){
                                smsg = Constant_Util.ROLLOFF_ASSET_ERROR;
                            }else if(Constant_Util.ROLLOFF_ASSET_ERROR.equals(smsg) && (IsCoreActiveTrue != 0 || IsRecyclingActiveTrue != 0 && IsBalerTrue != 0)){
                                smsg = Constant_Util.EMPTY_STRING;
                            }
                        }
                        caseAssetValidationMessage = smsg;
                        
                    } else {
                       
                        if(!isEndedExtendedAssets){ //SDT-33377
                         //SDT-33377
                           // System.debug('inside this final^^^');
                      

                                           smsg = Constant_Util.ASSET_NOT_ACTIVE;
                                            caseAssetValidationMessage = smsg;
                        }
                                           
                    }
                }
                assetStatus.put(header.Id,smsg);
            }  
        }       
        return assetStatus;
        
    }  

    /**
* @author WM
* @date 6/5/2020
* @description : Apex method getAssetDetailNonPickup to get the Aseet details on case summary page - Non Pickup.
**/
public static map<Id, String> getAssetDetailNonPickup(map<Id, Date> assetParam){
        
        
        
    boolean isParentActive = false, isActive = false; 
    boolean isEndedExtendedAssets = false; //SDT-33377
    Map<Id,String> assetStatus =new Map<Id,String>();
    if(!assetParam.isEmpty()) {
        for(Asset header : [ Select Id,Name,Occurrence_Type__c,(Select Id,Name, ParentId,Service_Type__c,Start_Date__c,End_Date__c,ProductFamily,Occurrence_Type__c, Material_Type__c,Has_Extra_Pickup__c,Is_Active__c, Is_Core_Service__c from ChildAssets),Product2.Equipment_Type__c,ProductFamily,Material_Type__c,Is_Active__c,Start_Date__c,End_Date__c From Asset where Id IN: assetParam.keySet() Limit 49000]){
            integer isCoreServiceActive = 0, isScheduleActiveHasXPUTrue = 0, isScheduleActiveHasXPUFalse = 0, isScheduleActiveFalseHasXPUTrue = 0, isScheduleActiveFalseHasXPUFalse = 0,
                isOnCallActiveHasXPUTrue = 0, isOnCallActiveHasXPUFalse = 0, isOnCallActiveFalseHasXPUTrue = 0, isOnCallActiveFalseHasXPUFalse = 0,
                isActiveDetail = 0, IsCoreActiveTrue = 0, isActiveOnCall = 0, IsRecyclingActiveTrue = 0, IsBalerTrue = 0;
            string smsg = Constant_Util.EMPTY_STRING;
			//SDT-33377
			Datetime serviceDateCase = assetParam.get(header.Id);
			isEndedExtendedAssets = getExtendedAssetDetail(header,serviceDateCase);

            
			//SDT-33377
			
            //system.debug('Validation message'+smsg);
            for(Asset assetDetail : header.ChildAssets){
                Datetime caseServiceDate = assetParam.get(header.Id);
                //isParentActive = header.End_Date__c == null ? true : header.Start_Date__c <= caseServiceDate && header.End_Date__c >= caseServiceDate ? true : false;
                //SDT-12849
                //Start
                isParentActive = false;
                
                if(header.End_Date__c == Null){
                    if(header.Start_Date__c <= caseServiceDate){
                        isParentActive = true;
                    }
                } 
                else{
                    if(header.Start_Date__c <= caseServiceDate && header.End_Date__c >= caseServiceDate){
                        isParentActive = true;
                    }   
                } 
                //Stop 

                
                if(isParentActive || isEndedExtendedAssets){ //sdt-33377 condition added
                    
                   /*
                    if((Constant_Util.ON_CALL.equals(header.Occurrence_Type__c)) || ((Constant_Util.SCHEDULED_ON_CALL).equals(header.Occurrence_Type__c)))
                    {
                            isActive = false;
                            
                            if(assetDetail.End_Date__c == Null){
                                if(assetDetail.Start_Date__c <= caseServiceDate){
                                    isActive = true;
                                }
                            } 
                            else{
                                if(assetDetail.Start_Date__c <= caseServiceDate && assetDetail.End_Date__c >= caseServiceDate){
                                    isActive = true;
                                }
                            } 
                            //Stop
                            
                            isActiveDetail = isActive ? isActiveDetail + 1 : isActiveDetail;
                            caseAssetValidationMessage = smsg;
                    }
                    else {
                        smsg = Constant_Util.CASE_ASSET_NOT_ONCALL_SCHEDULED_ON_CALL;
                        caseAssetValidationMessage = smsg;
                    }
                    */

                    isActive = false;
                            
                    if(assetDetail.End_Date__c == Null){
                        if(assetDetail.Start_Date__c <= caseServiceDate){
                            isActive = true;
                        }
                    } 
                    else{
                        if(assetDetail.Start_Date__c <= caseServiceDate && assetDetail.End_Date__c >= caseServiceDate){
                            isActive = true;
                        }
                    } 
                    //Stop
                    
                    isActiveDetail = isActive ? isActiveDetail + 1 : isActiveDetail;                   
                    
                } 
                else {
                  
                    if(!isEndedExtendedAssets){ //SDT-33377
                  
                        smsg = Constant_Util.ASSET_NOT_ACTIVE;
                        caseAssetValidationMessage = smsg;
					}
                }
                
            }
            
            if(isActiveDetail == 0 && String.isBlank(smsg)){
                smsg = Constant_Util.CASE_ASSETS_END_DATE_PASSED;
                caseAssetValidationMessage = smsg;
            }

            assetStatus.put(header.Id,smsg);
        }  
    }       
    return assetStatus;
    
}  


    
    
    /**
* @author Accenture
* @date 3/1/2019
* @description : Apex method getCaseSummary to get the Case details on case summary page
**/
    @AuraEnabled
    public static List<Case> getCaseSummary(String caseId,String referenceNo,String parentId){
        List<Case> caseList = new List<Case>();
        Set<Id> multidateCaseIds = new Set<Id>();
		if(String.isBlank(referenceNo)){
            caseList = [SELECT id,Create_AM_and_PM_Pickups__c,Asset_Material__c,CaseNumber,Case_Sub_Type__c, case_type__c, Reference_Number__c,Contact.Name,Contact_Title__c,SLA_Date_Text__c,Service_Date_Text__c,Asset.Name,SLA_Service_Date_Time__c,SLA_Service_DateTime__c,Service_Date__c,Asset.Acorn_SID__c from case where (id = :caseId OR (ParentId =:caseId And Is_Clone__c = true)) AND ((Status =: Constant_Util.STATUS_NEW ) OR (Status =:Constant_Util.OPEN AND Case_Type__c !=: Constant_Util.PICKUP ))  ORDER BY Service_Date__c asc LIMIT 49999];
        }
        else{
			for(Case c : [SELECT id,isMultiCalendarChecked__c,Create_AM_and_PM_Pickups__c,Asset_Material__c,CaseNumber,Case_Sub_Type__c, case_type__c, Reference_Number__c,Contact.Name,Contact_Title__c,SLA_Date_Text__c,Service_Date_Text__c,Asset.Name,SLA_Service_Date_Time__c,SLA_Service_DateTime__c,Service_Date__c,Is_Clone__c,ParentId,Asset.Acorn_SID__c from case where Reference_Number__c=:referenceNo AND Status =: Constant_Util.STATUS_NEW and Is_Multiple_Asset__c=true ORDER BY Service_Date__c asc LIMIT 49999]) {//and ParentId = :currentCase.Parentid
                if((!string.IsBlank(string.valueof(c.ParentId)) && string.valueof(c.ParentId).equals(parentId)) || (string.IsBlank(string.valueof(c.ParentId)) && string.IsBlank(parentId))){
                    caseList.add(c);
                    if(c.isMultiCalendarChecked__c){
                   		multidateCaseIds.add(c.Id); 
                	}
                }
			}
            if(multidateCaseIds!=null && !multidateCaseIds.isEmpty()){
                for(Case c : [SELECT id,Create_AM_and_PM_Pickups__c,Asset_Material__c,CaseNumber,Case_Sub_Type__c, case_type__c, Reference_Number__c,Contact.Name,Contact_Title__c,SLA_Date_Text__c,Service_Date_Text__c,Asset.Name,SLA_Service_Date_Time__c,SLA_Service_DateTime__c,Service_Date__c,Asset.Acorn_SID__c from case where ParentId in :multidateCaseIds And Is_Clone__c = true AND Status =: Constant_Util.STATUS_NEW ORDER BY Service_Date__c asc LIMIT 49999]){
                    caseList.add(c);
                }
            }
		}
        try{
            for(Integer i = 0; i < caseList.size(); i++){
                if(caseList[i].Service_Date__c!= null){
                    caseList[i].Service_Date_Text__c = caseList[i].Service_Date__c.format();
                }else{
                    //nova cop fix
                }
                
            } 
            if(caseList[0].Create_AM_and_PM_Pickups__c){
                caseList.add(caseList[0]);
            }
        }
        Catch (Exception ex){
            return null;
        }
        return caseList;
    }
    
    /**
* @author Accenture
* @date 3/1/2019
* @description : Apex method initiateWorkOrder to initiate workorder creation
**/
    @AuraEnabled
    public static String initiateWorkOrder(String caseId,List<String> caseIdList){
        String status = null;
        Case newCase = null;
        List<Case> caseList = new List <Case>();
        Set<Case> caseset = new Set<Case>();
        set<string> caseIdset = new set<String>();
        Id pickupRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Constant_Util.Pickup_Case_Rec_Type).getRecordTypeId();
        caseIdset.addALL(caseIdList);
        for(case c : [SELECT id,Status,Case_Sub_Type__c,Case_Type__c,CaseNumber,Is_Clone__c,Chargeable__c,RecordTypeId from case where id IN:caseIdset Order by CaseNumber ASC]){
            if(c.RecordTypeId == pickupRecordType){
                c.Status = Constant_Util.PENDING;
            }else{
                c.Status = Constant_Util.OPEN; 
               c.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_INTEGRATION;
            }
            caseList.add(c);
        }
        if(!caseList.isEmpty()){               
            for(Case caseObj : caseList){
                if(caseObj.Is_Clone__c){                         
                    copyAcornCommentsToChildCase(caseId,caseObj);                        
                }
            }
        }
        try{
            database.update(caseList);
            status = Constant_Util.SUCCESS;
			for(Case caseObj : caseList){
                if(caseObj.Case_Type__c == 'Pickup' && caseObj.Case_Sub_Type__c == 'Haul Away - No Equipment' && (caseObj.Chargeable__c == 'No' || caseObj.Chargeable__c == 'Unknown')){                         
                  //System.debug('in pickuptest'+caseObj.Case_Sub_Type__c);
                    createMultipleCasesInvoke(caseId);                     
                }
               
            }
        }Catch(Exception ex){
            status = Constant_Util.Failure;
        }
        return status;
    }
    
	 /**
* @author WM
* @date 10/28/2021
* @description : Apex method SaveAdditionalTemplate to save Workorder Details on Case
**/
    @AuraEnabled
    public static String saveAdditionalTemplate(String emailTempDesc,List<String> caseId){
    	 String Status = null;
        //System.debug('======='+caseId);
        try{
            if(caseId !=null){
                Case c = new Case();
                c.Id = caseId[0] ;
                c.EmailTemplateAdditionalComments__c =emailTempDesc ;
            	database.update(c);            
            	status = Constant_Util.SUCCESS;
            }
          
        }Catch(Exception ex){
            status = Constant_Util.Failure;            
            System.debug('New Error:'+ ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        return status;
    
    } 
    
    /**
	
    /**
* @author WM
* @date 2/18/2020
* @description : Apex method addWorkOrderDetails to save Workorder Details on Case
**/
    @AuraEnabled
    public static String addWorkOrderDetails(Case caseWoFields,List<String>caseIdList){
        
        String Status = null;
        List<Case> caseList = new List <Case>(); 
        
        Set<string> caseIdset = new Set<String>();
        caseIdset.addALL(caseIdList);       
        
        for(case c : [SELECT id,Is_ByPassWO__c, Status,Site_Contact__c,Site_Contact_Phone__c,User_Input_Work_Order_Instructions__c,Quantity_Override__c,CaseNumber,Is_Clone__c from case where id IN:caseIdset Order by CaseNumber ASC]){            
            c.Site_Contact__c = caseWoFields.Site_Contact__c;
            c.Site_Contact_Phone__c = caseWoFields.Site_Contact_Phone__c;
            c.User_Input_Work_Order_Instructions__c = caseWoFields.User_Input_Work_Order_Instructions__c;
	    c.Is_ByPassWO__c = caseWoFields.Is_ByPassWO__c; // Added by SDT-18424
            caseList.add(c);
        }      
        
        try{
            database.update(caseList);            
            status = Constant_Util.SUCCESS;
            
        }Catch(Exception ex){
            status = Constant_Util.Failure;            
            System.debug('New Error:'+ ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        return status;
    }
    
    @AuraEnabled
    public static Case getCaseDetails(String caseRecId){  
        //system.debug('@@@caseRecId'+caseRecId);
        Case currentCase = Database.query('select id,Quantity_Override__c,CaseNumber,RecordTypeId from case where id = :caseRecId limit 1');  
        return currentCase;
    }
    
    /// Salesforce CPQ user Licence check ---                 PSLList = [SELECT id, AssigneeId,PermissionSetLicenseId, PermissionSetLicense.MasterLabel  From PermissionSetLicenseAssign WHERE PermissionSetLicense.MasterLabel = 'Salesforce CPQ License' AND AssigneeId =: UserInfo.getUserId()];//'0058A0000075dM6QAI'

    public static Boolean getUserDetail() { 
 		Boolean Is_CPQPermission = false;
         
        User u = [SELECT Id, CPQ_Active_User__c,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        //SDT39047
        LoggedInUserProfile = u.Profile.Name;
        List<PermissionSetLicenseAssign> PSLList = new List<PermissionSetLicenseAssign>();
        PSLList = [SELECT id, AssigneeId,PermissionSetLicenseId, PermissionSetLicense.MasterLabel  From PermissionSetLicenseAssign WHERE PermissionSetLicense.MasterLabel = 'Salesforce CPQ License' AND AssigneeId =: UserInfo.getUserId()];//'0058A0000075dM6QAI'
        if (PSLList.size() > 0)
          {
           if(PSLList[0].PermissionSetLicense.MasterLabel == 'Salesforce CPQ License'){
               Is_CPQPermission = true;
           }
          }
        
        if(Is_CPQPermission ==true && u.CPQ_Active_User__c == true)
        {
            return true;
        }
		return false;
    }

    public static Boolean getActiveAssetUserDetail() { 
        Boolean Is_CPQPermission = false;
        
       User u = [SELECT Id, Update_Asset_Active_User__c FROM User WHERE Id =: UserInfo.getUserId()];

       if( u.Update_Asset_Active_User__c == true)
       {
           return true;
       }
       return false;
   }
	
	@AuraEnabled
    public static Boolean getCopyCaseOpenTask(String caseId){
        List<Case> OpenTaskList = new List<Case>();
        Boolean isOpenActivity = false;
        
        Case ca = [SELECT id, Reference_Number__c FROM Case WHERE Id =: caseId LIMIT 1]; 
        List<Case> childCaseList = [SELECT id, isMultiCalendarChecked__c, Reference_Number__c, (SELECT id, Status, Subject FROM Tasks WHERE Status = 'Open' ) FROM Case WHERE Reference_Number__c =: ca.Reference_Number__c AND isMultiCalendarChecked__c = false];
        
        for(Case c : childCaseList)
        {
            if(c.tasks.size() != 0){
                isOpenActivity = true;
            }
        }
        return isOpenActivity;
    }
    
    @AuraEnabled
    public static List<case> getRelatedCase(string caseId){
        case caseObj = [SELECT Id, Reference_Number__c, CaseNumber FROM Case WHERE Id =: caseId];
        return [SELECT Id, Reference_Number__c, CaseNumber,isWorkOrderCreated__c,Status,Case_Sub_Status__c FROM Case WHERE Reference_Number__c =: caseObj.Reference_Number__c
                AND Status =: Constant_Util.STATUS_NEW AND Id !=: caseId];
    }
    
    public static void copyAcornCommentsToChildCase(string recordId, Case caseObj){
        List<Comment__c> updatedCommentsList = new List<Comment__c>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        List<Comment__c> notes= [SELECT Id, Name, Communication_Log_Type_Name__c,Case_Number__c,Case__c,Acorn_SUser_ID__c,Comment__c, CreatedDate,Workflow_Action__c,recordTypeId,Workflow_TeamUser__c from Comment__c 
                                 where Case__r.Id =: recordId and RecordTypeId =: recordTypeId order by CreatedDate DESC];
        if(notes.size()>0) {
            for(Comment__c comments : notes){
                Comment__c newComments= new Comment__c();
                newComments = comments.clone(false, false, false, false);
                newComments.Case__c = caseObj.Id;
                newComments.Case_Number__c = caseObj.CaseNumber;
                updatedCommentsList.add(newComments);                    
            }
        }else{}
        try {
            database.insert(updatedCommentsList);
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
        }
        
    }
    
    /**
* @author Accenture
* @date 3/1/2019
* @description : Apex method updateRelatedCases to update the related multiasset cases
**/
    @AuraEnabled
    public static String updateRelatedCases(String caseId,String[] multiAssetSelections){
        String status = null;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        List<Case> updatedCaseList = new List<Case>();
        List<EmailMessage> updatedEmailList = new List<EmailMessage>();
        List<EmailMessage> emailList = [SELECT id,Subject,FromAddress,ToAddress,HtmlBody,TextBody,ParentId,RelatedToId from EmailMessage where ParentId =: caseId LIMIT 49999];
        List<Case> caseList = [SELECT id,CaseNumber,Reference_Number__c,Origin,ContactId,RecordTypeId,Show_Multiple_Asset_Cases__c from case where id = :caseId LIMIT 1];
        string caseNumber = caseList[0].CaseNumber;
        List<Case> relatedCaseList = getMultiAssetCases(caseId,multiAssetSelections);
        List<Comment__c> updatedCommentsList = new List<Comment__c>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        List<Comment__c> notes= [SELECT Id, Name, Communication_Log_Type_Name__c,Case_Number__c,Case__c,Acorn_SUser_ID__c,Comment__c, CreatedDate,Workflow_Action__c,recordTypeId,Workflow_TeamUser__c from Comment__c 
                                 where Case__r.Id =: caseId and RecordTypeId =: recordTypeId order by CreatedDate DESC];
        try{
            if(relatedCaseList.size() > 0){
                caseList[0].Show_Multiple_Asset_Cases__c = true;
                caseList[0].Is_Multiple_Asset__c = true;
            }
            updatedCaseList.add(caseList[0]);
            TriggerDispatcher.skipTriggerExecutionMap.put(Case.sobjectType.getDescribe().getName(),false);
            for(Case caseObj : relatedCaseList){
                caseObj.ContactId = caseList[0].ContactId;
                caseObj.Origin = caseList[0].Origin;
                //caseObj.Show_Multiple_Asset_Cases__c = true;
                caseObj.RecordTypeId = caseList[0].RecordTypeId;
                updatedCaseList.add(caseObj);
                for(EmailMessage email : emailList){
                    EmailMessage newEmail= new EmailMessage();
                    newEmail = email.clone(false, false, false, false);
                    newEmail.ParentId = caseObj.Id;
                    newEmail.RelatedToId = caseObj.Id;
                    updatedEmailList.add(newEmail);
                    
                }
                if(notes.size()>0) {
                    for(Comment__c comments : notes){
                        Comment__c newComments= new Comment__c();
                        newComments = comments.clone(false, false, false, false);
                        newComments.Case__c = caseObj.Id;
                        newComments.Case_Number__c = caseObj.CaseNumber;
                        updatedCommentsList.add(newComments);                    
                    }
                }else{}
            }
            database.upsert(updatedCaseList);
            database.insert(updatedEmailList);
            database.insert(updatedCommentsList);
            sessionPart.put(caseId,null,3600,Cache.Visibility.ALL,true);
            status = Constant_Util.SUCCESS;
        }Catch(Exception ex){
            status = Constant_Util.Failure;
        }
        //system.debug('****status:'+status);
        return status;
    }
    
    /*
* This method is used to invoke the flow to find the Business Rule for the respective case.
* @owner : Anupreeethy
* @param : Case,RecordTypeId,Boolean, Boolean
*/
    /* Modified to pass the values of Asset and Project of Asset in Case to Business Rule Selection Flow */
    Public static Business_Rule__c getbrule(Case c,Id recordTypeId, boolean ChannelRequirements, boolean SpecialInstructions){
        Business_Rule__c brule = new Business_Rule__c();
        map<String, Object> flowInputMap = new map<String, Object>();
        flowInputMap.put(Constant_Util.FLOW_ACCOUNTID , c.Client__c);
        flowInputMap.put(Constant_Util.FLOW_CONTAINER , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Product2.ProductTypeSelected__c : null);
        flowInputMap.put(Constant_Util.FLOW_LOCATIONID , c.Location__c);
        flowInputMap.put(Constant_Util.FLOW_CASEREASON , c.Case_Reason__c);
        flowInputMap.put(Constant_Util.FLOW_MATERIAL , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Material_Type__c : null);
        flowInputMap.put(Constant_Util.FLOW_SERVICE , c.Case_Sub_Type__c);
        flowInputMap.put(Constant_Util.FLOW_SCHEDULETYPE , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) ? casewithContainer.get(c.AssetId).Duration__c : null);
        flowInputMap.put(Constant_Util.FLOW_RECORDTYPEID , recordTypeId);
        flowInputMap.put(Constant_Util.FLOW_ASSETID , c.AssetId);
        flowInputMap.put(Constant_Util.FLOW_CASETYPE , c.Case_Type__c);
        flowInputMap.put(Constant_Util.FLOW_PROJECT , casewithContainer!=null && casewithContainer.containsKey(c.AssetId) &&  casewithContainer.get(c.AssetId).Project_Code__c != null && casewithContainer.get(c.AssetId).Active__c ? casewithContainer.get(c.AssetId).Project_Code__c : null);
        flowInputMap.put(Constant_Util.FLOW_CHANNELREQ , ChannelRequirements);
        flowInputMap.put(Constant_Util.FLOW_SPECIALINS , SpecialInstructions);
        flowInputMap.put(Constant_Util.FLOW_BRAND , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Brand__c : null);
        flowInputMap.put(Constant_Util.FLOW_DIVISION , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Division__c : null);
        flowInputMap.put(Constant_Util.FLOW_GEOGRAPHY , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Geography__c : null);
        flowInputMap.put(Constant_Util.FLOW_LOCATIONTYPE , casewithLocation!=null && casewithLocation.containsKey(c.Location__c) ? casewithLocation.get(c.Location__c).Location_Type__c : null);
        //system.debug('flowInputMap:::'+flowInputMap);
        brFlow = new Flow.Interview.Business_Rule_with_Accounts(flowInputMap);
        brFlow.Start();
        brule = (Business_Rule__c)(brFlow.getVariableValue(Constant_Util.FLOW_BUSINESSRULEREC));
        return brule;
    }
    
    /**
* @author Accenture
* @date 21/3/2019
* @description : Apex method to get Channel Requirement & Special Instruction.
**/
    @AuraEnabled
    public static Wrapper getBusinessRule(Id caseId) {
        
        Wrapper wrapperClass = new Wrapper();
        try {
            If(myCases.isEmpty() && myCases.size() == 0){
                myCases = [SELECT Id, Client__c,accountId,CPQ_New_Service__c, Location__c,ContactId, Contact_Title__c,Case_Type__c,Case_Sub_type__c,
                           AssetId,Status,Case_Sub_Status__c,SLA_Service_Date_Time__c,Override_PO_Create_Task__c,PSI_Override_Reason__c,PSI_Comments__c,Service_Date__c,Origin,PSI__c,Case_Reason__c,
                           PurchaseOrder_Number__c,SlaStartDate from CASE where id =:caseId LIMIT 1];
            }
            
            // validation
            // if ((myCases[0].Status != 'Pending' || myCases[0].Status != 'New') || String.isEmpty(myCases[0].Case_Sub_Status__c)) return null; 
            
            // Build Map/List for Assets
            for(Asset a : [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Material_Type__c,Project_Code__c,Active__c,End_Date_Based_on_Project_code__c 
                           FROM Asset WHERE Id =: myCases[0].AssetId LIMIT 49999]){
                               casewithContainer.put(a.Id,a);
                           }
            for(Account loc: [SELECT Id,Brand__c,Geography__c,Division__c,Location_Type__c 
                              FROM Account WHERE Id =: myCases[0].Location__c LIMIT 49999]){
                                  casewithLocation.put(loc.Id,Loc);
                              }
            
            Business_Rule__c channelReq = getbrule(myCases[0], Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId(),true,false);
            Business_Rule__c specialInstruction = getbrule(myCases[0], Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId(),false,true);
            If(channelReq != null && string.isNotBlank(channelReq.Channel_Req__c) && string.isNotBlank(channelReq.Channel__c)){
                wrapperClass.channelReq = channelReq.Channel_Req__c;
                wrapperClass.channelName = channelReq.Channel__c;
            } 
            
            If(specialInstruction != null && string.isNotBlank(specialInstruction.Special_Ins__c)){
                wrapperClass.specialInstructions = specialInstruction.Special_Ins__c;
            }
            //system.debug('channelReq' +channelReq);
            //system.debug('specialInstruction' +specialInstruction);
        } catch (Exception e) {
            return null;
        }
        
        return wrapperClass;
    }
    
    /* Author- Prakhar
* Date- 09/04/2020
* Description- method to save the case close reason as comment. //Changing here related to comments also requires change in populateCaseSubType LWC.
*/
    
    @AuraEnabled
    public static String createAcornComment(String comment, String caseId) {
        //System.debug('Case Id: ' + caseId);
        if (!caseId.startsWith('500')) {
            return 'Invalid Case Id.  You need to be viewing a Case when creating an Acorn Note.';
        } else{}
        
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        Case curCase = [select CaseNumber, Tracking_Number__c from Case where Id =: caseId limit 1];
        
        Decimal acornUserId = [select Acorn_SUser_ID__c from User where ID =: System.UserInfo.getUserId()].Acorn_SUser_ID__c;
        //System.debug('Acorn User Id: ' + acornUserId);
        
        Comment__c note = new Comment__c();
        note.Case__c = caseId;
        note.Comment__c = 'Case Close Reason-'+comment;
        note.Communication_Log_Type_Name__c = 'Internal';
        note.Case_Number__c = curCase.CaseNumber;
        note.recordTypeId = recordTypeId;
        if (String.isNotEmpty(curCase.Tracking_Number__c)) note.Acorn_Tracking_Number__c = curCase.Tracking_Number__c;
        note.Workflow_Action__c = '';
        note.Workflow_TeamUser__c = System.UserInfo.getName();
        note.Acorn_SUser_ID__c = acornUserId;
        note.Type__c = Constant_Util.OBJECT_CASE;
        
// Modified for SDT-33453 Start
        if(note != null){
        insert note;
        }
        // Modified for SDT-33453 End
        return 'ok';
    }
    /*
* @author Accenture
* @date 22/3/2019
* @description : Apex method to get SLA Instructions from Entitlement.     
*/
    @auraEnabled
    public static wrapper getEntitlement(Id CaseId){
        
        String key='';
        Map<string,Entitlement> caseEntitlementMap = new map<string,Entitlement>();
        Map<String,Case> caseMap = new Map <String,Case>();
        Wrapper wrapperClass = new Wrapper();
        try{
            If(myCases.isEmpty() && myCases.size() == 0){
                myCases = [SELECT Id,CPQ_New_Service__c, Client__c,accountId, Location__c,ContactId, Contact_Title__c,Case_Type__c,
                           Case_Sub_type__c,AssetId,Status,Case_Sub_Status__c,SLA_Service_Date_Time__c,
                           Override_PO_Create_Task__c,PSI_Override_Reason__c,PSI_Comments__c,
                           Service_Date__c,Origin,PSI__c,PurchaseOrder_Number__c,SlaStartDate
                           FROM CASE WHERE id =:caseId LIMIT 1];
            }
            CaseTriggerHelper.parentAccountIdset.add(myCases[0].Client__c);
            CaseTriggerHelper.serviceset.add(myCases[0].Case_Sub_type__c);
            if(String.isEmpty(myCases[0].Case_Sub_type__c) && myCases[0].Status.equals(Constant_Util.STATUS_New)) {
                return null;
            }
            //system.debug('@@@@@'+myCases[0].AssetId);
            If(String.isblank(myCases[0].AssetId)){
                key = myCases[0].Client__c + Constant_Util.STAR + myCases[0].Location__c + Constant_Util.STAR + null + Constant_Util.STAR + myCases[0].Case_Sub_type__c + Constant_Util.STAR + null ;
                caseMap.put(Key,myCases[0]);
            }
            for(Asset a : [Select Id,Product2.ProductTypeSelected__c,Duration__c,Material_Type__c,Project_Code__c
                           FROM Asset WHERE Id =: myCases[0].AssetId LIMIT 49999]){
                               
                               Key = myCases[0].Client__c + Constant_Util.STAR + myCases[0].Location__c + Constant_Util.STAR + a.Product2.ProductTypeSelected__c + Constant_Util.STAR + myCases[0].Case_Sub_type__c + Constant_Util.STAR + a.Duration__c ; 
                               caseMap.put(Key,myCases[0]);
                               CaseTriggerHelper.casewithContainer.put(a.Id,a);            
                           }
            caseEntitlementMap = CaseTriggerHelper.fetchSLA(caseMap);
            //system.debug('caseEntitlementMap SLA' +caseEntitlementMap);
            //Added null pointer check
            If(caseEntitlementMap != null && !caseEntitlementMap.isEmpty()&& caseEntitlementMap.containskey(key) && caseEntitlementMap.get(key).SLA_Ins__c!=null && String.isNotBlank(caseEntitlementMap.get(key).SLA_Ins__c)){
                wrapperClass.slaInstrctuions = caseEntitlementMap.get(key).SLA_Ins__c; 
            }
            
            
        }
        Catch(Exception ex){
            System.debug('Exception::::'+ex.getStackTraceString());
            return null; 
        }
        return wrapperClass;
    } 
    /**
* @author Accenture
* @date 21/3/2019
* @description : wrapper Class.
**/
    public with sharing class Wrapper {
        //Changes added for SDT-26868 start
        @AuraEnabled public List<String> caseRecordTypeList {get;set;}
        @AuraEnabled public Id CPQProduct {get;set;}
        //Changes added for SDT-26868 end
        @AuraEnabled public String channelReq {get;set;}
        @AuraEnabled public String specialInstructions {get;set;}
        @AuraEnabled public string slaInstrctuions {get;set;}
        @AuraEnabled public string channelName {get;set;}
        @AuraEnabled public string reqInfo {get;set;}
        @AuraEnabled public string approvalInfo {get;set;}
        //@AuraEnabled public Integer occurrenceLimit {get;set;}
        @AuraEnabled public string caseInfo {get;set;}
        @AuraEnabled public Boolean enableapprovalInfo {get;set;}
        @AuraEnabled public Id caseId {get;set;}
        @AuraEnabled public String CaseSubType {get;set;}
        @AuraEnabled public Boolean disableMultiCase {get;set;}
        @AuraEnabled public List<Case> relatedCaseList {get;set;}
        @AuraEnabled public string assetSCode {get;set;}
        @AuraEnabled public string CaseType {get;set;}
        @AuraEnabled public string CaseReason {get;set;}
        @AuraEnabled public string CaseStatus {get;set;}
        @AuraEnabled public string[] multiAssetSelections;
        @AuraEnabled public Boolean assetValidation {get;set;}
        @AuraEnabled public String referenceNo {get;set;}
        @AuraEnabled public Boolean WorkOrderCreation {get;set;}
        @AuraEnabled public Boolean isManualCaseAsset{get;set;}
        @AuraEnabled public Case caseData {get;set;}
		@AuraEnabled public string caseAppliedRules {get;set;}
        @AuraEnabled public Boolean isAssetMandatory {get;set;}
		@AuraEnabled public Boolean isOpportunityCreated {get;set;}
        @AuraEnabled public Boolean Is_NewServiceCPQ {get;set;}
        @AuraEnabled public Boolean Is_UserHaveCPQLicence {get;set;}
        @AuraEnabled public String caseRecordType  {get;set;}
        @AuraEnabled public String assetId  {get;set;}
        @AuraEnabled public Boolean Is_UpdateAssetActiveUser {get;set;}	
        //addition for SDT -32426
        @AuraEnabled public Boolean progressCaseVisibility {get;set;}
		//addition for SDT -31981
        @AuraEnabled public Boolean addQuoteVisibility {get;set;}
		//addition for SDT -32767
        @AuraEnabled public Boolean isCaseInfoReady {get;set;}
        //SDT-41473
        @AuraEnabled public Boolean IsHaulAwayService {get;set;}

    } 
    //Changes added for SDT-26868
    //Description: This will return case record types
    //Developer : Seema Dhikale
   @AuraEnabled
    public static List<String> getCaseRecordTypeList(){
        List<RecordType> caseRecordTypeList=[select Name from RecordType where sObjectType='Case' And Name!=:Constant_Util.UPDATE_ASSET_CASE And Name!=:Constant_Util.New_Service_Case];
        List<String> caseRecordTypeNameList=new List<String>();
        for(RecordType recType : caseRecordTypeList)
        {
            caseRecordTypeNameList.add(recType.Name);
        }
        return caseRecordTypeNameList;
    }
    @AuraEnabled
    public static String getRecordTypeId(Id caseId){
        return [Select recordTypeId from Case where Id =: caseId].recordTypeId; 
    }
	
    @AuraEnabled
    public static List<String> getCaseRecordDetails(Id caseId){
        List<String> caseList = new List<String>();
        //SDT39047 ,Case_Type__c,Case_Sub_Type__c
        for(Case cs : [Select recordTypeId,Company_Category__c,CompanyCategoryCode__c,Is_Haul_Away_Service__c, Haul_Away_Vendor__c,Case_Type__c,Case_Sub_Type__c from Case where Id =: caseId]){   //SDT-41473 added Ishaulawayservice
            caseList.add(cs.recordTypeId);
            caseList.add(cs.Company_Category__c);
            caseList.add(cs.CompanyCategoryCode__c);
                //SDT-41473
                if(cs.Is_Haul_Away_Service__c){
                    caseList.add('true'); 
                } else{
                    caseList.add('false'); 
    
                } 
            //SDT-42651
            if(cs.Haul_Away_Vendor__c == HaulAwayService.Haul_Away_Vendor_Got_Junk_API && cs.Is_Haul_Away_Service__c){
                caseList.add('VendorServiceIdReq');
            }

            //SDT - 42886
            if(cs.Haul_Away_Vendor__c != 'Not Available' && cs.Is_Haul_Away_Service__c){
                caseList.add('HaulAwayBookedService');
        }
        //SDT 45074
        Code_Switch__c codeSwitchSetting = Code_Switch__c.getValues('HaulAwayUIEnable'); 
        boolean isHaulAwayUIEnable = codeSwitchSetting.Switch_Off__c;
        if(isHaulAwayUIEnable){
            caseList.add('HaulAwayUIEnabled'); 
        }
        //SDT-39047
            BillingService billing = new BillingService();
            if(cs.Case_Type__c == billing.CASE_TYPE_BILLING && cs.Case_Sub_Type__c == billing.CASE_SUB_TYPE_Invoice_Charge_Dispute){
                caseList.add('BillingInvoiceChargeDispute');
            }
        }
        return caseList;
    }

    private static List<Case> getMultiAssetCases(Id caseId,String[] multiAssetSelections){
        List<Case> multiAssetCases = new List<Case>();
        Case caseObj = null;
        Case currentCase = Database.query('select Id,AssetId,ContactId,Show_Multiple_Asset_Cases__c,Origin,ParentId,RecordTypeId,Client__c,Location__c,Is_Multiple_Asset__c,Reference_Number__c from case where id = :caseId limit 1'); 
        for(Integer i = 0; i < multiAssetSelections.size(); i++){
            caseObj = new Case(ParentId = currentCase.ParentId,Status = Constant_Util.NEW_STATUS ,RecordTypeId = currentCase.RecordTypeId,Is_Multiple_Asset__c = true,Reference_Number__c = currentCase.Reference_Number__c,AssetId = multiAssetSelections[i],Client__c =currentCase.Client__c,Location__c =currentCase.Location__c);
            multiAssetCases.add(caseObj);
        }
        return multiAssetCases;
    }
	/*************************
	* SDT-33377
	*author : Rajan Sajani
	********************************/
  	 public static Boolean getExtendedAssetDetail(Asset header,Datetime serviceDateCase){
			boolean isEndedExtendedAsset =false;
			for(Asset assetDetail : header.ChildAssets){
					if(assetDetail.End_date__c == Null || (assetDetail.End_date__c != null && assetDetail.End_date__c >= date.today())){
								if(assetDetail.Start_Date__c <= serviceDateCase){
									isEndedExtendedAsset = true;
									break;

					}
				}
			}
			return isEndedExtendedAsset;
	}
    @AuraEnabled
    public static Map<Id,Wrapper> getCaseValidationMessages(List<Case> relatedCases,map<Id,Business_Rule__c> reqInfomap){
        Map<Id,Wrapper> caseMessageWrapperMap = new Map<Id,Wrapper>();
        set<Id> accountIdset = new set<Id>();
        set<Id> recordTypeIdSet = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> serviceTypeSet = new Set<string>();
        set<string> assetIdSet = new Set<string>();
        set<string> locationIdSet = new Set<string>();
        Map<Id,date> caseAssetParam = new Map<Id,date>();
        List<Case> feedRelatedCaseList = new List<Case>();
        Map<Id,Asset> caseAssetMap;
        Map<Id,String> assetValidations = new Map<Id,String>();
        Map<string,List<WOCreation__mdt>> woCreationMap = new Map<string,List<WOCreation__mdt>>();
        Set<Id> assetDetailsSet = new Set<Id>();
		Set<Id> caseSetIds= new Set<Id>(); //SDT-15281 
        Map<Id,string> caseCaseAssetMap = new Map<Id,string>(); //SDT-15281 
		integer isOnCallScheduleOnCallCaseAsset = 0;
        Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        for(Case c : relatedCases){
            accountIdset.add(c.Client__c); 
            requestTypeSet.add(c.Case_Type__c);
            serviceTypeSet.add(c.Case_Sub_type__c);
            assetIdSet.add(c.AssetId);
            locationIdSet.add(c.Location__c);
            caseAssetParam.put(c.AssetId,c.Service_Date__c);
			caseSetIds.add(c.Id); // Added for SDT-15281
            if(c.Status.equals(Constant_Util.STATUS_New)){
                recordTypeIdSet.add(reqInfoRecTypeId);
            }
            if(string.IsNotBlank(String.valueof(c.ParentId)) && !Constant_Util.OPEN.equals(c.status)){
                feedRelatedCaseList.add(c);
            }
        }
        if(caseAssetParam!=null && !caseAssetParam.isEmpty()){
            assetValidations = getAssetDetail(caseAssetParam);
        }
        //system.debug('assetValidations'+assetValidations);
		
		//SDT-15281 Start
        if(caseSetIds !=null && !caseSetIds.isEmpty()){
            caseCaseAssetMap=caseAssetDateValidation(caseSetIds);
        }
        //SDT-15281 END
		
        //caseAssetMap = new Map<Id,Asset>([Select ID,Name, ParentId,Service_Type__c,Has_Extra_Pickup__c,End_Date__c From Asset where ParentId in :CaseTriggerHelper.casewithContainer.KeySet()  and End_Date__c != null and End_date__c < TODAY and Is_Active__c = true]);
        for(Asset a : [Select ID,Name, ParentId,Service_Type__c,Has_Extra_Pickup__c,End_Date__c From Asset where ParentId in :CaseTriggerHelper.casewithContainer.KeySet()  and End_Date__c != null and End_date__c < TODAY and Is_Active__c = true]){
            assetDetailsSet.add(a.ParentId);
        }
        string key = null;
        for(WOCreation__mdt wo : [SELECT WO_Needed__c,Case_Type__c,Case_Subtype__c ,Case_Reason__c,Is_Asset_Mandatory__c FROM WOCreation__mdt where Case_Type__c In: requestTypeSet and Case_Subtype__c In:serviceTypeSet] ){
        	key = wo.Case_Type__c+wo.Case_Subtype__c;
            if(woCreationMap.IsEmpty() || !woCreationMap.containskey(key)){
                woCreationMap.put(key, new List<WOCreation__mdt>());
            }
            woCreationMap.get(key).add(wo);
        }
        List<WOCreation__mdt> wolst = new List<WOCreation__mdt>();
        for(Case c : relatedCases){
            Wrapper wrapperClass = new Wrapper();
            wrapperClass.caseInfo = Constant_Util.EMPTY_STRING;
            wrapperClass.caseId = c.Id;
            wrapperClass.referenceNo = c.Reference_Number__c;
            wrapperClass.disableMultiCase = c.isMultiCalendarChecked__c;
            wrapperClass.CaseType = c.Case_Type__c;
            wrapperClass.CaseReason = c.Case_Reason__c;
            wrapperClass.CaseSubType = c.Case_Sub_type__c;
            wrapperClass.CaseStatus = c.Status;
            wrapperClass.assetValidation = false;
            wrapperClass.WorkOrderCreation = true;
            wrapperClass.isAssetMandatory = true;
			wrapperClass.isOpportunityCreated = c.IsOpportunity_Created__c;
            //Defect - George Martin 2021-06-25
            //Included to ensure that/add view quote is defined by the user who is viewing the quote, not the user who created it
            //The class for this was already written, simply piping the result into the wrapperClass           
            wrapperClass.Is_NewServiceCPQ = GetCaseInformation.getUserDetail();
            key = c.Case_Type__c + c.Case_Sub_type__c;
            if(c.AssetId != null && !String.isBlank(c.AssetId)){
                //System.debug(CaseTriggerHelper.casewithContainer);
                wrapperClass.AssetSCode = (CaseTriggerHelper.casewithContainer).get(c.AssetId).Sensitivity_Code__c;
            }
			
			//SDT-11068 - Start
            for(SBS_Case_Asset__c caseAsset: c.Case_Assets1__r)
            {                       
                isOnCallScheduleOnCallCaseAsset =  Constant_Util.ON_CALL.equalsIgnoreCase(caseAsset.AssetId__r.Occurrence_Type__c) || Constant_Util.SCHEDULED_ON_CALL.equalsIgnoreCase(caseAsset.AssetId__r.Occurrence_Type__c) ? isOnCallScheduleOnCallCaseAsset + 1 : isOnCallScheduleOnCallCaseAsset;
            }
            //SDT-11068 - End
			
            try{
                //SDT- 10794 - SDT-13757
                
                if(woCreationMap != null && woCreationMap.containskey(key) && !String.isBlank(c.Case_Type__c) && !Constant_Util.PICKUP_CSTYPE.equals(c.Case_Type__c) && !String.isBlank(c.Case_Sub_type__c)){
                    wolst = woCreationMap.get(key);
                    for(WOCreation__mdt womdt : wolst){
                        //null check added as part of sdt 32895
                        if(!String.isBlank(c.Case_Reason__c) && womdt.Case_Reason__c !=null &&  womdt.Case_Reason__c.equals(c.Case_Reason__c) ) {             
                            wrapperClass.WorkOrderCreation =  womdt.WO_Needed__c;
                            wrapperClass.isAssetMandatory = womdt.Is_Asset_Mandatory__c;
                            break;
                        } else if(String.isBlank(c.Case_Reason__c) ){
                            wrapperClass.WorkOrderCreation = womdt.WO_Needed__c;
                            wrapperClass.isAssetMandatory = womdt.Is_Asset_Mandatory__c;
                        }
                    }                    
                }
				if((String.isBlank(c.AssetId) || (Constant_Util.UNKNOWN).equals(c.AssetId)) && c.Case_Sub_type__c != Constant_Util.BALES && (wrapperClass.isAssetMandatory || (wrapperClass.WorkOrderCreation && !wrapperClass.isAssetMandatory && String.isNotBlank(c.ContactId))) && ((Constant_Util.OPEN.equals(c.Status)&& !Constant_Util.PICKUP_CSTYPE.equals(c.Case_Type__c)) || Constant_Util.NEW_STATUS.equals(c.Status)))
                {
                    wrapperClass.caseInfo += Constant_Util.SELECT_ASSET;
                }
                else if(String.isBlank(c.ContactId) || (Constant_Util.UNKNOWN).equals(c.ContactId)) {
                    wrapperClass.caseInfo += Constant_Util.SELECT_CONTACT;
				}
                else if(String.isBlank(c.Case_Sub_type__c) || (Constant_Util.UNKNOWN).equals(c.Case_Sub_type__c))
                {
                    wrapperClass.caseInfo += Constant_Util.SELECT_CASESUBTYPE;
                }
                else if(c.SLA_Service_Date_Time__c == null)
                {
                    wrapperClass.caseInfo += Constant_Util.SELECT_CASESLADATE;
                }
                /*else if(!feedRelatedCaseList.isEmpty() && feedRelatedCaseList.size() >= 1 && c.Show_Multiple_Asset_Cases__c == false && c.Is_Multiple_Asset__c == true){ //&& myCases[0].Is_Multiple_Asset__c == true
                    wrapperClass.caseInfo += Constant_Util.MULTIPLE_ASSET;
                }*/
                else if(c.Case_Assets1__r.isEmpty() && wrapperClass.WorkOrderCreation){
                    wrapperClass.assetValidation = true;
                    if(!assetDetailsSet.isEmpty() && !assetDetailsSet.contains(c.AssetId)){
                        wrapperClass.caseInfo += Constant_Util.CASE_ASSETS_END_DATE_PASSED;
                    }
                    else
                    {	//SDT-13575 P2
                        assetValidations = getAssetDetailNonPickup(caseAssetParam);
                        wrapperClass.caseInfo = assetValidations.get(c.AssetId);
			if((wrapperClass.caseInfo == null || wrapperClass.caseInfo == '') && Constant_Util.PICKUP_CSTYPE.equals(c.Case_Type__c)  && c.Case_Sub_Type__c != Constant_Util.BALES){
                            wrapperClass.caseInfo = Constant_Util.NO_CASE_ASSET_MSG;
                        }	    
                        //wrapperClass.caseInfo += Constant_Util.NO_CASE_ASSETS;
                    }
                }
               
			     //SDT-11068 - Start               
                else if(isOnCallScheduleOnCallCaseAsset == 0 && Constant_Util.PICKUP_CSTYPE.equals(c.Case_Type__c) && wrapperClass.WorkOrderCreation){
                                    
                    wrapperClass.caseInfo +=  Constant_Util.CASE_ASSETS_No_Call_OR_Scheduled_On_Call;
                    wrapperClass.assetValidation = true;
				
                }
                //SDT-11068 - End
				
                else if(!string.isBlank(assetValidations.get(c.AssetId)) && wrapperClass.CaseType == Constant_Util.PICKUP_CSTYPE && wrapperClass.WorkOrderCreation)
                {
                    wrapperClass.caseInfo += assetValidations.get(c.AssetId);
                    wrapperClass.assetValidation = true;
                }
                else if(wrapperClass.CaseType != Constant_Util.PICKUP_CSTYPE && wrapperClass.WorkOrderCreation ) // Non Pickup
                {
                    if(wrapperClass.CaseType != Constant_Util.STATUS)
                    {
                        assetValidations = getAssetDetailNonPickup(caseAssetParam);

                        wrapperClass.caseInfo += assetValidations.get(c.AssetId);
                        wrapperClass.assetValidation = true;
                    }

                    //getAssetDetailNonPickup(caseAssetParam);
                } 

				//SDT-15281 Start
                else if(Constant_Util.PICKUP_CSTYPE.equalsIgnoreCase(wrapperClass.CaseType) && wrapperClass.CaseStatus.equalsIgnoreCase(Constant_Util.STATUS_New)){
                    if(caseCaseAssetMap.containskey(c.Id)){
                        wrapperClass.caseInfo += caseCaseAssetMap.get(c.Id);
                        wrapperClass.assetValidation = true;
                    }
                }
                //SDT-15281 END	
				
				 //revert changes for SDT - 31503
                //added a new condition for SDT -32766 
                //changes related to SDT - 32895 -commented below if for new status check
                //if(c.Status.equals(Constant_Util.STATUS_New)){
                wrapperClass.isCaseInfoReady = true;         
                if((c.Case_Record_Type__c == Constant_Util.SERVICE_REQUEST_CASE) && wrapperClass.caseInfo == Constant_Util.EMPTY_STRING){
                        wrapperClass.caseInfo = ADD_QUOTE_ERROR_SERVICE_REQ_CASE ;
                        wrapperClass.isCaseInfoReady = false;
                    }  
                //}  				
                
                if(c.Status.equals(Constant_Util.STATUS_New)){
                    wrapperClass.reqInfo = Constant_Util.EMPTY_STRING;
                    Business_Rule__c caseRule = new Business_Rule__c(); 
					 if(c.Case_Type__c == 'Pickup' && c.Case_Sub_Type__c == 'Haul Away - No Equipment' && (c.Chargeable__c == '' || c.Chargeable__c == null)){                         
                          wrapperClass.reqInfo += Constant_Util.CHARG_MSG + Constant_Util.NEW_LINE;             
                }
                    caseRule = reqInfomap != null && reqInfomap.size() > 0 && reqInfomap.containskey(c.Id) ? reqInfomap.get(c.Id) : null;
                    if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PO_NUMBER) && String.isBlank(c.PurchaseOrder_Number__c) && !(c.Override_PO_Create_Task__c)){
                        wrapperClass.reqInfo += Constant_Util.PO_MSG + Constant_Util.NEW_LINE;            
                    }
                    //commented as part of sdt 33312
                    /*if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PROFILE_NUMBER) && String.isBlank(c.Profile_Number__c) && !(c.Override_Profile_Number_Task__c)){
                        wrapperClass.reqInfo += Constant_Util.PROFILE_MSG + Constant_Util.NEW_LINE;            
                    }*/
                    if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PSI) && c.PSI__c == null){
                        if(c.PSI_Override_Reason__c == null){ 
                            wrapperClass.reqInfo += Constant_Util.PSI_REQUIRED + Constant_Util.NEW_LINE;
                        }
                        else if(c.PSI_Override_Reason__c != null && c.PSI_Override_Reason__c == Constant_Util.OTHER_API && c.PSI_Comments__c == null)  {
                            wrapperClass.reqInfo += Constant_Util.PSI_COMMENTS + Constant_Util.NEW_LINE;
                        }
                        else{
                            //Nova cop fix
                        }
                    }
		    if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.COMPANY_CATEGORY) && String.isBlank(c.Company_Category__c) && !(c.Override_Company_Category_Create_Task__c)){
                        wrapperClass.reqInfo += Constant_Util.CC_MSG + Constant_Util.NEW_LINE;            
                    }
					
		    if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PSI)){
                        wrapperClass.caseAppliedRules=Constant_Util.PSI;
                    }
                    
                }
                if(string.IsBlank(wrapperClass.reqInfo) && string.IsBlank(wrapperClass.caseInfo) && Constant_Util.STATUS_New.equals(c.Status)){
                    if((c.CaseNumber == c.Reference_Number__c || (!feedRelatedCaseList.isEmpty() && feedRelatedCaseList.size() >= 1)) && c.Show_Multiple_Asset_Cases__c == true){                
                        wrapperClass.caseInfo = Constant_Util.READY_MULTIASSET;
                    }else{
                        wrapperClass.caseInfo = Constant_Util.READY;
                    }
                }
                
            }Catch(exception ex){
                if(Limits.getLimitDMLStatements() > 0 ){
                    UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
                }    
                wrapperClass = new Wrapper();
            }
            caseMessageWrapperMap.put(c.Id,wrapperClass);
        }
        return caseMessageWrapperMap;
    }
    
    @AuraEnabled
    public static Wrapper getCaseMessages(Id caseId){
        
        Boolean AddCaseAssets= false;
        set<Id> recordTypeIdSet = new set<Id>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_UTIL.MULTI_ASSET_PARTITION);
        map<Id,Business_Rule__c> approvalmap = new map<Id,Business_Rule__c>();
        map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
        set<string> assetIdSet = new Set<string>();
        set<string> locationIdSet = new Set<string>();
        Set<String> workOrderStatus = new Set<String>{Constant_Util.INPROGRESS,Constant_Util.STATUS_NEW,Constant_Util.COMPLETED,Constant_Util.CLOSED};
        set<Id> accountIdset = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> serviceTypeSet = new Set<string>();
        List<Id> preSelectedAssets =new List<Id>();
        Map<Id,Wrapper> caseMessageWrapper = new Map<Id,Wrapper>();
        Business_Rule__c thisBusinessRule = new Business_Rule__c();
        List<Case> newStatusCaseList = new List<Case>();
        myCases = [SELECT Id, Is_Haul_Away_Service__c, Haul_Away_Vendor__c,ParentId,Client__c,accountId,CaseNumber,Reference_Number__c,Profile_Number__c,Override_Profile_Number_Task__c,Location__c,ContactId, Contact_Title__c,Case_Type__c,Case_Sub_type__c,RecordType.Name,
                   AssetId,Asset.CPQ_Product__c,Status,Case_Sub_Status__c,IsOpportunity_Created__c,EmailofContact__c,SLA_Service_Date_Time__c,Override_PO_Create_Task__c,SuppliedEmail,Case_Reason__c,                
                   PSI_Override_Reason__c,PSI_Comments__c,Chargeable__c,createdDate,Show_Multiple_Asset_Cases__c,Is_Multiple_Asset__c,Service_Date__c,Origin,PSI__c,OwnerId,Company_Category__c,Override_Company_Category_Create_Task__c,RecordTypeId,
                   Location__r.Location_Type__c,Location__r.Geography__c,Location__r.Division__c,Location__r.Brand__c,Case_Record_Type__c,
		   PurchaseOrder_Number__c,SlaStartDate,ContactDepartment__c,isMultiCalendarChecked__c,CPQ_New_Service__c,(select id,Name,Asset_Header__r.Name,Asset_Header__r.Occurrence_Type__c,IsManual__c, AssetId__r.Occurrence_Type__c from Case_Assets1__r) FROM CASE WHERE id =:caseId LIMIT 1];
        accountIdset.add(myCases[0].Client__c); 
        requestTypeSet.add(myCases[0].Case_Type__c);
        ServiceTypeSet.add(myCases[0].Case_Sub_type__c);
        assetIdSet.add(myCases[0].AssetId);
        locationIdSet.add(myCases[0].Location__c);
        Id approvalRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        recordTypeIdSet.add(approvalRecTypeId);
        List<SBS_Case_Asset__c> caseAssetList = (List<SBS_Case_Asset__c>) myCases[0].Case_Assets1__r;
    	
        
        for(Case c : myCases){
            if(c.Status.equals(Constant_Util.STATUS_New)){
                recordTypeIdSet.add(reqInfoRecTypeId);
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
       
        if(myCases[0].Case_Record_Type__c == Constant_Util.New_Service_Case){
            //List<BusinessRuleNSCHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleNSCHelper.selectBusinessRules(myCases);
	    List<BusinessRuleHelper.BusinessRuleWrapper> businessRulewrapperlst = new List<BusinessRuleHelper.BusinessRuleWrapper>();
            for(Case c : myCases) {
                try {
                    businessRulewrapperlst.addAll(BusinessRuleHelper.businessRuleSelection(c.Id, recordTypeIdSet));
                } catch (exception e) {
                    
                }
            }
            if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
		//Replaced reference to BusinessRUleNSCHelper as part of BRE-12
                for(BusinessRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                    if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                        reqInfomap.put(brw.caseId,brw.bRule);
                    }
                }
            }
        }else{    
            //List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCases,recordTypeIdSet,accountIdset,requestTypeSet,ServiceTypeSet,CaseTriggerHelper.casewithContainer,CaseTriggerHelper.casewithLocation);
            List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCases[0].Id,recordTypeIdSet);
            if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
                for(BusinessRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                    if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                        reqInfomap.put(brw.caseId,brw.bRule);
                    }else if( approvalRecTypeId.equals(brw.bRule.RecordTypeId)){
                        approvalmap.put(brw.caseId,brw.bRule);
                    }
                }
            }
        }
        string woKey = null;
        if(myCases[0].Service_Date__c != null){
            Date startDate = (myCases[0].Service_Date__c).toStartOfMonth();
            Date endDate = (myCases[0].Service_Date__c).addMonths(1).toStartofMonth().addDays(-1);
            for(AggregateResult wo : [Select COUNT(Id)num,AssetId,Customer_Location__c,Case.Case_Sub_Type__c  from WorkOrder where AssetId IN:CaseTriggerHelper.casewithContainer.keySet()  and Customer_Location__c IN:CaseTriggerHelper.casewithLocation.keySet() and StatusCategory IN:workOrderStatus and Case_Subtype__c =: myCases[0].Case_Sub_type__c and Is_Bypass__c = false and Service_Date__c >=: startDate and Service_Date__c <=: endDate Group by AssetId,Customer_Location__c,Case.Case_Sub_Type__c]){
                woKey = (String)wo.get('AssetId') + (String)wo.get('Customer_Location__c') + (String)wo.get('Case_Sub_Type__c');
                CaseTriggerHelper.caseWorkOrderCount.put(woKey,(Integer)wo.get('num'));
            }
        }
        caseMessageWrapper = getCaseValidationMessages(myCases,reqInfomap);
        Wrapper wrapperClass = caseMessageWrapper.get(caseId);
         if(myCases != null && myCases.size() > 0 )
        wrapperClass.caseData=myCases[0];        
        for(SBS_Case_Asset__c caseAsset : caseAssetList){
            if(caseAsset.IsManual__c){
                AddCaseAssets= true;
            }
        }
        //Changes added for SDT-26868 start
        wrapperClass.caseRecordTypeList=getCaseRecordTypeList();
        wrapperClass.CPQProduct = myCases[0].Asset.CPQ_Product__c;
        //Changes added for SDT-26868 start
        wrapperClass.caseRecordType = myCases[0].RecordType.Name;
        wrapperClass.isManualCaseAsset = AddCaseAssets;
        wrapperClass.Is_UserHaveCPQLicence = getUserDetail();  
        //system.debug('myCases[0].AssetId >'+ myCases[0].AssetId);
        // added Asset Id to the wrapper
        wrapperClass.assetId = myCases[0].AssetId;
        wrapperClass.Is_UpdateAssetActiveUser = getActiveAssetUserDetail();  
		//changes for SDT -32426
        //calling method for asssigning value to modifyExistingProgressCase
		//Changes related to SDT-32895-Commented the code and moved to end of this method
        //wrapperClass.progressCaseVisibility = modifyExistingProgressCase('Progress Case',myCases[0].RecordType.Name,myCases[0].Case_Type__c,myCases[0].Case_Sub_type__c,myCases[0].Case_Reason__c);
        //addition for SDT -31981
		//Changes related to SDT-32895-Commented the code and moved to end of this method
        //wrapperClass.addQuoteVisibility = modifyExistingProgressCase('Add Quote',myCases[0].RecordType.Name,myCases[0].Case_Type__c,myCases[0].Case_Sub_type__c,myCases[0].Case_Reason__c);
        //SDT-41473
        wrapperClass.IsHaulAwayService = HaulAwayService.getIsHaulAwayService(myCases[0]); //41473

        if(sessionPart.contains(caseId)){
            String[] assets= (String[])sessionPart.get(caseId);
            for(String s : assets){
                preSelectedAssets.add(s);
            }
        }
        if(preSelectedAssets!=null && !preSelectedAssets.isEmpty()){
            wrapperClass.multiAssetSelections = preSelectedAssets;
        }
        else if((String.isBlank(myCases[0].AssetId) || (Constant_Util.UNKNOWN).equals(myCases[0].AssetId)) && myCases[0].Status == Constant_Util.STATUS_New )
            {
                // Call NTE Rules SDT-31000
                if(String.isNotBlank(myCases[0].Location__c) && String.isNotBlank(myCases[0].Client__c) 
                   && myCases[0].Case_Record_Type__c == 'Pickup Case' && String.isNotBlank(myCases[0].Case_Type__c) 
                   && myCases[0].Case_Type__c == 'Pickup' && String.isNotBlank(myCases[0].Case_Sub_Type__c) 
                   && (myCases[0].Case_Sub_Type__c == 'Bulk' || myCases[0].Case_Sub_Type__c == 'Haul Away - No Equipment') ){
                List<NTEBRRulesModalCtrl.BRWrapper> brList =  NTEBRRulesModalCtrl.getBRData(myCases[0].Case_Record_Type__c, myCases[0].Client__c, myCases[0].Location__c, myCases[0].Case_Type__c, myCases[0].Case_Sub_Type__c , 'caseReason');
                       if(brList!=null && !brList.isEmpty()){
                           
                               wrapperClass.caseInfo +=   ' NTE Approval Needed';
                           
                           
                       }
                       
                }//system.debug('NTE wrapperClass.caseInfo : ' + wrapperClass.caseInfo);
                // SDT-31000
            }
        List<WorkOrder> workOrderList = [SELECT id,caseId from WorkOrder where caseId= :caseId and case.isWorkOrderCreated__c = true];
        if(myCases[0].Status == Constant_Util.PENDING){
            if(newStatusCaseList.size() >= 1){
                wrapperClass.caseInfo = Constant_Util.WORKORDER_INITIATED_RELATEDCASES;
            }else{
                wrapperClass.caseInfo = Constant_Util.WO_INITIATED;
            }
        }
        else if((myCases[0].Status == Constant_Util.OPEN || myCases[0].Status == Constant_Util.INTEGRATION_ERROR) && (Constant_Util.READY.equals(wrapperClass.caseInfo) || Constant_Util.READY_MULTIASSET.equals(wrapperClass.caseInfo) || workOrderList.size() == 0 ) /*&& myCases[0].Is_Multiple_Asset__c == false*/){
            List<String> sCodeList = new List<String>{Constant_Util.UTILITY, Constant_Util.UTL, Constant_Util.CAM};
                if(newStatusCaseList.size() >= 1){
                    wrapperClass.caseInfo = Constant_Util.WORKORDER_CREATED_RELATEDCASES;
                }else if(String.isBlank(myCases[0].Case_Sub_Status__c) && myCases[0].AssetId != null && !String.isBlank(myCases[0].AssetId) && sCodeList.contains((CaseTriggerHelper.casewithContainer).get(myCases[0].AssetId).Sensitivity_Code__c)){
                    String sCode = (CaseTriggerHelper.casewithContainer).get(myCases[0].AssetId).Sensitivity_Code__c;
                    if(sCode == Constant_Util.UTILITY || sCode == Constant_Util.UTL || sCode == Constant_Util.CAM){
                        wrapperClass.caseInfo = Constant_Util.PROGRESS_CASE;
                    }
                }
            else if(workOrderList.size() == 0)
            {
                wrapperClass.caseInfo = Constant_Util.PROGRESS_CASE;
            }
            else{
                wrapperClass.caseInfo = Constant_Util.WO_CREATED;
            }
        }
        else if(wrapperClass.reqInfo =='' && !preSelectedAssets.isEmpty() && preSelectedAssets.size() > 0 && myCases[0].Status==Constant_Util.STATUS_New && myCases[0].Show_Multiple_Asset_Cases__c == false && myCases[0].Is_Multiple_Asset__c == false){ //&& myCases[0].Is_Multiple_Asset__c == true
            if(wrapperClass.caseInfo =='Ready' || wrapperClass.caseInfo == '')    
                wrapperClass.caseInfo = Constant_Util.MULTIPLE_ASSET; 
        }
        else if(myCases[0].CaseNumber != myCases[0].Reference_Number__c &&  myCases[0].Status==Constant_Util.STATUS_New && myCases[0].Show_Multiple_Asset_Cases__c == false && myCases[0].Is_Multiple_Asset__c == true && String.isBlank(myCases[0].ParentId)){                
            wrapperClass.caseInfo = Constant_UTIL.MULTIPLE_ASSET_CASES;
        }
        // 42650
        else if(myCases[0].Haul_Away_Vendor__c ==  'Not Available'){
        wrapperClass.caseInfo =   'Create a New Service Open Top request';
      } // 42650 end
        If(myCases[0].Status.equals(Constant_Util.STATUS_New) || (myCases[0].Status.equals(Constant_Util.PENDING) && (Constant_Util.PENDING_CUSTOMER_INFORMATION.equals(myCases[0].Case_Sub_Status__c) || Constant_Util.PENDING_REQUEST_APPROVAL.equals(myCases[0].Case_Sub_Status__c)) ) ){
            BusinessRuleHelper.wrapperResult brwrapper = null;
            map<Id,Boolean> autoApprovalmap = new map<Id,Boolean>();
            map<Id,Boolean> rulematchedmap = new map<Id,Boolean>();
            map<Id,Boolean> occurenceLimitmap = new map<Id,Boolean>();
            if(approvalmap != null && approvalmap.size() > 0){
                brwrapper = BusinessRuleHelper.getapprovallog(approvalmap,myCases,CaseTriggerHelper.caseWorkOrderCount);
                autoApprovalmap = brwrapper.autoApprovemap;
                rulematchedmap = brwrapper.rulematchedmap;
                occurenceLimitmap = brwrapper.occurenceLimitmap;
            }
            thisBusinessRule = approvalmap != null && approvalmap.size() > 0 && approvalmap.containskey(myCases[0].Id) ? approvalmap.get(myCases[0].Id) : null;
            isAutoApproved = autoApprovalmap != null && autoApprovalmap.size() > 0 ? autoApprovalmap.containskey(myCases[0].Id) ? autoApprovalmap.get(myCases[0].Id) : true : true;
            ruleMatched = rulematchedmap != null && rulematchedmap.size() > 0 && rulematchedmap.containskey(myCases[0].Id) ? rulematchedmap.get(myCases[0].Id) : false;
            occurenceLimit = occurenceLimitmap != null && occurenceLimitmap.size() > 0 && occurenceLimitmap.containskey(myCases[0].Id) ? occurenceLimitmap.get(myCases[0].Id) : false;
            wrapperClass.approvalInfo = Constant_Util.EMPTY_STRING;
            wrapperClass.enableapprovalInfo = (String.isNotBlank(myCases[0].Client__c) && String.isNotBlank(myCases[0].Case_Sub_type__c)) ? true : false;
            String requestorOnlyAppr = Constant_Util.EMPTY_STRING;
            String notRequestorOnlyAppr = Constant_Util.EMPTY_STRING;
            if(isAutoApproved && !ruleMatched && String.isNotBlank(myCases[0].Client__c) && String.isNotBlank(myCases[0].Case_Sub_type__c)){
                wrapperClass.approvalInfo += Constant_Util.NO_APPROVAL_REQUIRED;
            }
            else if(thisBusinessRule != null){
                //wrapperClass.occurrenceLimit = Integer.valueof(thisBusinessRule.Occurrence_Limit__c);
                List<Service_Approver__c> serviceapproverlst = [Select id,Requester_Only__c,Account_Team_Member__c,Approver_Type__c,Approver_Contact__c,Title__c,Account_Department__c,Title__r.Name,Approver_Contact__r.FirstName,Approver_Contact__r.LastName,
                                                                Account_Team_Member__r.FirstName,Account_Team_Member__r.LastName,Email__c,User__c,User__r.FirstName,User__r.LastName from Service_Approver__c where Business_Rule__c =: thisBusinessRule.Id and Active__c = true LIMIT 49999];
                Boolean flag = false;
                string approver ='';
                Boolean isRequestor = false;
                if(isAutoApproved && ruleMatched){
                    wrapperClass.approvalInfo += Constant_Util.AUTO_APPROVED;
                }
                else if(thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null){
                    
                    for(Service_Approver__c sap :serviceapproverlst){
                        approver = (sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName;
                        if(!sap.Requester_Only__c){
                            if(!flag){
                                notRequestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                flag= true;
                            }else{
                                notRequestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                            }
                        }else if(sap.Requester_Only__c){
                            if(!isRequestor){
                                isRequestor = true;
                                requestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                            }else{
                                requestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                            }
                        }
                    }
                    if(flag){
                        wrapperClass.approvalInfo += notRequestorOnlyAppr;
                        wrapperClass.approvalInfo += isRequestor ? Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + '<div style="color: #3c8a2e;">' + RequestorOnlyAppr + '</div>': ''; 
                    }
                }else if(!thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null ){
                    for(Service_Approver__c sap :serviceapproverlst){
                        approver = (sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName;
                        if(!sap.Requester_Only__c){
                            if(!flag){
                                notRequestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                flag= true;
                            }else{
                                notRequestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                            }
                        }else if(sap.Requester_Only__c){
                            if(!isRequestor){
                                isRequestor = true;
                                requestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                            }else{
                                requestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                            }
                        }
                    }
                    if(flag){
                        wrapperClass.approvalInfo += notRequestorOnlyAppr;
                        wrapperClass.approvalInfo += isRequestor ? Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + '<div style="color: #3c8a2e;">' + RequestorOnlyAppr + '</div>': ''; 
                    }
                }
                else{
                    //Nova cop fix
                }
                If(isRequestor){
                    wrapperClass.approvalInfo += '<div class = "spl">' + system.Label.ForRequestorOnly + '</div>';
                }
                If(!occurenceLimit && thisBusinessRule.Occurrence_Limit__c != null && !isAutoApproved && thisBusinessRule.Occurrence_Limit__c > 0){
                    wrapperClass.approvalInfo += '<div class = "spl">'+ 'The account has Occurrence Limit of ' + String.valueof(thisBusinessRule.Occurrence_Limit__c) + '. Approval is required' + '</div>';
                }
                If(String.isNotBlank(thisBusinessRule.Special_Instructions_Approval__c)){
                    wrapperClass.approvalInfo += '<div class = "spl">' + '<strong>' + 'Approval Instructions' + '</strong>' + '</div>';
                    wrapperClass.approvalInfo += '<div>' + thisBusinessRule.Special_Instructions_Approval__c + '</div>';
                }
            }
        }
		//Changes related to SDT -32895
        wrapperClass.progressCaseVisibility = buttonVisibilityLogic('Progress Case',myCases[0].RecordType.Name,myCases[0].Case_Type__c,myCases[0].Case_Sub_type__c,myCases[0].Case_Reason__c,wrapperClass);
        wrapperClass.addQuoteVisibility = buttonVisibilityLogic('Add Quote',myCases[0].RecordType.Name,myCases[0].Case_Type__c,myCases[0].Case_Sub_type__c,myCases[0].Case_Reason__c,wrapperClass);
        return wrapperClass;
    }
	/* Author- WM
	* Date- 04/30/2020
	* Description- method to get wm capacity planner visibility as per SDT-12786
	*/
    @AuraEnabled
    public static Boolean IsWMCapacityPlannerVisible(string caseRecId){
        Boolean isWMcapacityVisible;
        isWMcapacityVisible=ServiceDateContainerController.IsWMCapacityPlannerVisible(caseRecId);
        return isWMcapacityVisible;
    }
	
	   /* Author- Chetan Sriramla
	* Date- 10/29/2021
	* Description- method to get business rule visibility 
	*/
	@AuraEnabled
    public static Boolean IsTemplateVisible(string caseRecId){
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> containerIdSet = new Set<Id>();
        Set<Id> locationIdSet = new Set<Id>();
        set<Id> accountIdset = new set<Id>();
        set<Id> recordTypeIdSet = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> ServiceTypeSet = new Set<string>();
        
        Map<Id,Asset> casewithContainerMap = new Map<Id,Asset>();
        Map<Id,Account> casewithLocationMap = new Map<Id,Account>();
        List<Case> processCaseSubtypeList = new List<Case>();
        Id pickupRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.PICKUP).getRecordTypeId();
        Id newServiceRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
        Id IntegrationRcdType = Schema.getGlobalDescribe().get(Constant_Util.KEYWORD_CASE).getDescribe().getRecordTypeInfosByName().get(Constant_Util.Integration_Case).getRecordTypeId();
		Id approvalRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        recordTypeIdSet.add(approvalRecTypeId);
        recordTypeIdSet.add(reqInfoRecTypeId);
        
        for(Case caseRecord : [select id,contactId,RecordTypeId,Case_type__c,Is_Multivendor__c,AssetId,Case_Sub_Type__c,
                               Location__c,Client__c,Case_Sub_Status__c,Status,Case_Reason__c from case where id =: caseRecId]){
         
            if(caseRecord.RecordTypeId == newServiceRcdType || caseRecord.RecordTypeId == pickupRcdType || ((caseRecord.RecordTypeId == newServiceRcdType ||
                     caseRecord.RecordTypeId != IntegrationRcdType  ||
                     (caseRecord.RecordTypeId != IntegrationRcdType && (String.isNotBlank(caseRecord.Case_type__c) && 
                          sla_calculation__c.getValues(caseRecord.Case_type__c) != null  && 
                          sla_calculation__c.getValues(caseRecord.Case_type__c).Enabled__c))) && !caseRecord.Is_Multivendor__c && String.isBlank(caseRecord.Case_Sub_Type__c))){
                    
                    //System.debug('caseRecord.AssetId====='+caseRecord.AssetId+'====='+caseRecord.Location__c);          
                    if(String.isNotBlank(caseRecord.AssetId)){
                       containerIdSet.add(caseRecord.AssetId);   
                    }
                    if(String.isNotBlank(caseRecord.Location__c)){       
                   		locationIdSet.add(caseRecord.Location__c); 
                	}
                    if(String.isNotBlank(caseRecord.contactId)){       
                   		contactIdSet.add(caseRecord.contactId); 
                	}
                              
                              
                              
                    processCaseSubtypeList.add(caseRecord); 
                    
 			}
            if(!String.ISBlank(caseRecord.Case_Sub_type__c)){// 
                
                accountIdset.add(caseRecord.Client__c); 
                requestTypeSet.add(caseRecord.Case_Type__c);
                ServiceTypeSet.add(caseRecord.Case_Sub_type__c);
            }                       
                                   
        }
        
        	if(containerIdSet != null && !containerIdSet.isEmpty()){
                casewithContainerMap = CaseTriggerHandler.getAssetRecordValue(containerIdSet,true);
                //system.debug('casewithContainerMap===='+casewithContainerMap);
            } 
            if(locationIdSet != null && !locationIdSet.isEmpty()){
                casewithLocationMap = CaseTriggerHandler.getLocationRecordValue(locationIdSet);
                 //system.debug('casewithLocationMap===='+casewithLocationMap);
            }
        
        Boolean isTemplateVisible=false ;
        List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = new List<BusinessRuleHelper.BusinessRulewrapper>();
       if((processCaseSubtypeList != null && !processCaseSubtypeList .isEmpty()) && (casewithLocationMap != null && !casewithLocationMap.isEmpty())){
        //businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(processCaseSubtypeList,recordTypeIdSet,accountIdset,requestTypeSet,ServiceTypeSet,casewithContainerMap,casewithLocationMap);
        for (Case c : processCaseSubtypeList) {
            businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(c.Id,recordTypeIdSet);
        }
                
           //System.debug('&&&&'+businessRulewrapperlst);
          
       		if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
            
            	isTemplateVisible =true ;
                set<Id> businessruleIDSet = new Set<Id>();
                for(BusinessRuleHelper.BusinessRulewrapper businessWrap :businessRulewrapperlst){
                    businessruleIDSet.add(businessWrap.bRule.Id) ;
                    
                }
                for(Business_Rule__c rule : [select id,No_Approval_Required__c,Active__c,Is_Auto_Email__c from Business_Rule__c where Active__c =true AND id IN:businessruleIDSet]){
                    
                    if(rule.No_Approval_Required__c || !rule.Is_Auto_Email__c){
                         isTemplateVisible =false ;
                    }
                }
                for(Service_Approver__c serApprover : [Select id,Business_Rule__c,Email__c,Approver_Contact__c from Service_Approver__c where Business_Rule__c IN:businessruleIDSet and Approver_Contact__c IN :contactIdSet and Active__c=true]){
                    isTemplateVisible =false ;
                }
                
            
            }
       }         
     
        return isTemplateVisible;
    }
	
	  /* Author- WM - Ruchika
    * Date- 06/22/2020
    * Description- method to get possible CaseType that CSR can provide as per SDT-11657
    */
     @AuraEnabled(cacheable=true)
    public static List<Case> getcaseAssetDetails(string caseId){
        
        List<Case> caseAsset = new List<Case>();
        for(Case Casedetail : [Select Id,Asset.ProductFamily,Asset.Equipment_Type__c,Asset.Duration__c,Asset.Occurrence_Type__c, AssetId  from Case where Id =: CaseId  Limit 1]){
          caseAsset.add(Casedetail);
        }
            return caseAsset;
    }
	
	  /** @Author- WM 
* Date- 10/8/2020
* Description- Method to validate all case assets start and end date should fall under service date-SDT-15281
*/    
    public static Map<Id,string> caseAssetDateValidation(Set<Id> caseIdSet){        
        Map<Id,String> caseCaseAssetErrorMap =new Map<Id,String>();        
        Map<Id, List<SBS_Case_Asset__c>> caseAssetMap= new Map<Id, List<SBS_Case_Asset__c>> (); 
        try{
            if(!caseIdSet.isEmpty()) {
                for(SBS_Case_Asset__c caseAssetRec:  [ SELECT Id, CaseId__r.Service_Date__c,AssetId__r.End_Date__c, AssetId__r.Start_Date__c FROM SBS_Case_Asset__c WHERE caseId__c IN : caseIdSet]){                
                    if(caseAssetMap.containsKey(caseAssetRec.CaseId__c)){ 
                        caseAssetMap.get(caseAssetRec.CaseId__c).add(caseAssetRec); 
                    }
                    else{
                        caseAssetMap.put(caseAssetRec.CaseId__c, new List<SBS_Case_Asset__c>{caseAssetRec}); 
                    }
                }
                
                for(Id caseId:caseAssetMap.keySet()){
                    List<SBS_Case_Asset__c> caseAseetLst=   caseAssetMap.get(caseID);
                    for( SBS_Case_Asset__c caseAssetRec: caseAseetLst)
                    {
                        if(caseAssetRec.AssetId__r.End_Date__c != Null){
                            if(!(caseAssetRec.AssetId__r.Start_Date__c <= caseAssetRec.CaseId__r.Service_Date__c && caseAssetRec.AssetId__r.End_Date__c  >= caseAssetRec.CaseId__r.Service_Date__c)){
                                caseCaseAssetErrorMap.put(caseAssetRec.CaseId__c, System.Label.CASE_ASSET_VAL_ERR_MSG);
                                break;
                            }
                        }
                        else{
                            if(!(caseAssetRec.AssetId__r.Start_Date__c <= caseAssetRec.CaseId__r.Service_Date__c)){
                                caseCaseAssetErrorMap.put(caseAssetRec.CaseId__c, System.Label.CASE_ASSET_VAL_ERR_MSG);
                                break;
                            }                                
                        }                        
                    }
                }
            }
        }
        catch(Exception ex){
           UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);       
        }        
        return caseCaseAssetErrorMap;
    }
	
	  // Asset Management Launch Point - 'Add Quote'
    
    public with sharing class QLineWrapper {
        @AuraEnabled public String QuoteNumber {get;set;}
        @AuraEnabled public String QuoteId {get;set;}
        @AuraEnabled public String Status {get;set;}
        @AuraEnabled public String QuoteDuratioon {get;set;}
        @AuraEnabled public Date StartDate {get;set;}
        @AuraEnabled public String ProductName {get;set;}
        @AuraEnabled public String ProductSize {get;set;}
        @AuraEnabled public String PrimaryContact {get;set;}
       
    }
    
    @AuraEnabled
    public static Boolean updateThisCaseToClose(String CaseId){
    try{ 
            Case c = [Select Id,Close_Irrelevant_Case__c,Close_Case_Reason__c, Status from Case where Id =: caseId];
            c.Close_Irrelevant_Case__c = true;
            //Added for story SDT-21778
            c.Close_Case_Reason__c  = 'Duplicate';
            //END
            c.Case_Close_Reason__c = 'As Location already have active Quotes, This case not required any more.';
// Modified for SDT-33453 Start
            if(c != null) {
            update c;
}
            // Modified for SDT-33453 End
        }
    Catch(Exception ex){
            System.debug('Exception::::'+ex.getStackTraceString());
            return null; 
        }
            return true;
    }
    @AuraEnabled
    public static List<QuoteProcurementController.ProductsWrapper> ShowExistingQuotes(String CaseId) {
        List<QuoteProcurementController.ProductsWrapper> pwList = new List<QuoteProcurementController.ProductsWrapper>();
        pwList = QuoteProcurementController.getDuplicates(CaseId);
        return pwList;
    }
	
    /*@AuraEnabled
    public static List<QLineWrapper> ShowExistingQuotes(String CaseId) {
        
    String returnStr;  
    Case c = [SELECT Id, Service_Date__c, Location__c FROM Case WHERE Id =: CaseId];
    List <SBQQ__Quote__c> quoteListOnCaseLocation = new List <SBQQ__Quote__c>();
    List<QLineWrapper> qLIWrapperList = new List<QLineWrapper>();
	
	quoteListOnCaseLocation = [select id, Name, SBQQ__Status__c,Duration__c,SBQQ__PrimaryContact__r.name, SBQQ__StartDate__c, (Select id, SBQQ__Product__r.ProductCode, toLabel(Equipment_Size__c), SBQQ__RequiredBy__c from SBQQ__LineItems__r where SBQQ__Bundle__c = true AND SBQQ__RequiredBy__c = null) from SBQQ__Quote__c where SBQQ__Quote__c.SBQQ__Account__c =: c.Location__c AND SBQQ__StartDate__c <=: c.Service_Date__c+3 AND SBQQ__StartDate__c >=: c.Service_Date__c-3];

    
        if(quoteListOnCaseLocation.size() > 0)
        {
           for(SBQQ__Quote__c quotes : quoteListOnCaseLocation)
           {
               QLineWrapper qLineWrapper = new QLineWrapper();
               qLineWrapper.QuoteId = quotes.Id;
               qLineWrapper.QuoteNumber = quotes.Name;
               qLineWrapper.Status = quotes.SBQQ__Status__c;
               qLineWrapper.QuoteDuratioon = quotes.Duration__c;
               qLineWrapper.StartDate = quotes.SBQQ__StartDate__c;
               qLineWrapper.PrimaryContact = quotes.SBQQ__PrimaryContact__r.name;
               
               String fullProduct = '';
               String allProductsSizeTogether = '';
               for(SBQQ__QuoteLine__c Qline : quotes.SBQQ__LineItems__r)
               {
                   String product;
                   String productSize;
                   product = Qline.SBQQ__Product__r.ProductCode;
                   productSize = Qline.Equipment_Size__c;
                   if (String.isEmpty(fullProduct)|| String.isBlank(fullProduct))
                   {
                       fullProduct = product;
                       allProductsSizeTogether = productSize;
                   }
                   else if (String.isNotEmpty(fullProduct) || String.isNotBlank(fullProduct)|| Test.isRunningTest() )
                   {
                       fullProduct = fullProduct + ',' + product;
                       allProductsSizeTogether = allProductsSizeTogether + ', ' + productSize;
                   }
               }
               qLineWrapper.ProductName = fullProduct;
               qLineWrapper.ProductSize = allProductsSizeTogether;
               qLIWrapperList.add(qLineWrapper);
           }
        }
        return qLIWrapperList;
    }*/
    //closeThisCase
        
    @AuraEnabled
    public static String addQuoteCheck(String CaseId) {
        
    String returnStr;  
    //TCS-pkulkarn-22-Aug-2023-Add Asset Id, Product Id and RecordType.Name to SOQL for SDT-31259
    Case c = [SELECT Id, Service_Date__c, Location__c, AssetId, Asset.CPQ_Product__c,Haul_Away_information__c,Is_Haul_Away_Service__c, Haul_Away_Vendor__c, RecordType.Name FROM Case WHERE Id =: CaseId]; //SDT-41473
     
    //TCS-pkulkarn-22-Aug-2023-Added code for SDT-31259 // added Haul Away Check //SDT-41473 - SDT-41625
    if(c.Id != null && c.AssetId != null && c.RecordType.Name != Constant_Util.New_Service_Case && !HaulAwayService.getIsHaulAwayService(c))
    {
        String quoteCreationEligibilityCheckResult = CheckQuoteCreationEligibility(c.AssetId, c.Asset.CPQ_Product__c);
        if(quoteCreationEligibilityCheckResult != 'SUCCESS')
            return quoteCreationEligibilityCheckResult;
    }
    //TCS-pkulkarn-22-Aug-2023-End

    List <SBQQ__Quote__c> quoteListOnCaseLocation = new List <SBQQ__Quote__c>();
    List<QLineWrapper> qLIWrapperList = new List<QLineWrapper>();
	quoteListOnCaseLocation = [select id, Name, SBQQ__Status__c,Duration__c,SBQQ__PrimaryContact__r.name, SBQQ__StartDate__c, (Select id, SBQQ__Product__r.ProductCode, toLabel(Equipment_Size__c), SBQQ__RequiredBy__c from SBQQ__LineItems__r where SBQQ__Bundle__c = true AND SBQQ__RequiredBy__c = null) from SBQQ__Quote__c where SBQQ__Quote__c.SBQQ__Account__c =: c.Location__c AND SBQQ__StartDate__c <=: c.Service_Date__c+3 AND SBQQ__StartDate__c >=: c.Service_Date__c-3];

    
        if(quoteListOnCaseLocation.size() > 0)
        {
           for(SBQQ__Quote__c quotes : quoteListOnCaseLocation)
           {
               QLineWrapper qLineWrapper = new QLineWrapper();
               qLineWrapper.QuoteNumber = quotes.Name;
               qLineWrapper.Status = quotes.SBQQ__Status__c;
               qLineWrapper.QuoteDuratioon = quotes.Duration__c;
               qLineWrapper.StartDate = quotes.SBQQ__StartDate__c;
               qLIWrapperList.add(qLineWrapper);
           }
           returnStr = 'quoteExists';
        }
        
     return returnStr; 
    }
        
    @AuraEnabled    
    public static String createOppQuote(String CaseId) {
        
		
        //system.debug('createOppQuote--->');
        Opportunity opp = new Opportunity();
        String quoteStatus;
        
        //SDT38061 Case_Reason__c
        Case c = [SELECT Id, Status,AssetId, Asset.Duration__c, Location__c, ContactId, CaseNumber, Service_Date__c,Case_Sub_Type__c,Case_Reason__c, Reference_Number__c, Tracking_Number__c, Integrate_with_Acorn__c, Case_Type__c,
                 Case_Record_Type__c,Quote_Only__c,Is_Haul_Away_Service__c,Haul_Away_information__c, Haul_Away_Vendor__c //SDT-41473
                 FROM Case
                 WHERE Id =: CaseId];
        
        Account loc = [SELECT Id, Primary_Segment__c,ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode
                      FROM Account
                      WHERE Id =: c.Location__c];
        
           
        opp.Name = c.CaseNumber;
        opp.AccountId = loc.Id;
        opp.StageName = Constant_Util.PRODUCT_CONFIGURATION;
        opp.CloseDate = date.today() + 4;
        opp.SBQQ__QuotePricebookId__c = [SELECT Id FROM PriceBook2 WHERE Name = 'Standard Price Book' LIMIT 1].Id;
        opp.Case__c = c.Id;

        //SDT-41473
        Boolean isHaulAway = HaulAwayService.getIsHaulAwayService(c);

        // Changes for SDT-25790
        if(isHaulAway)  //SDT-41473
        opp.Duration__c = 'Temporary';       
        else if(!String.isempty(c.Case_Type__c) && c.Case_Type__c == Constant_Util.NEW_SERVICE)
            opp.Duration__c = c.Case_Sub_Type__c;
        else
            opp.Duration__c = c.Asset.Duration__c !=null ? c.Asset.Duration__c : c.Case_Sub_Type__c;
        //system.debug('Opp--->'+ opp);
        
        try {
// Modified for SDT-33453 Start
            if(opp != null){               
            insert opp;
            }
            // Modified for SDT-33453 End
            //system.debug('Opp1--->'+ opp);

        } catch (dmlException e) {
            system.debug(e.getMessage());
        }
                
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Opportunity2__c = opp.Id;
        q.SBQQ__Account__c = loc.Id;
        q.SBQQ__Primary__c = true;
       /* if (loc.Primary_Segment__c == Constant_Util.Broker){
            q.SBQQ__ExpirationDate__c = date.today() + 30;
        }
        else {
            q.SBQQ__ExpirationDate__c = date.today() + 60;
        } */
        q.SBQQ__StartDate__c = c.Service_Date__c;
        q.SBQQ__ShippingStreet__c = loc.ShippingStreet;
        q.SBQQ__ShippingCity__c = loc.ShippingCity;
        q.SBQQ__ShippingState__c = loc.ShippingState;
        q.SBQQ__ShippingPostalCode__c = loc.ShippingPostalCode;
        q.SBQQ__PrimaryContact__c = c.ContactId;
        q.Duration__c = opp.Duration__c;
		
		//Added by jatan for SDT-40344 IVR
        q.Quote_Only__c = c.Quote_Only__c;

        //pkulkarn-TCS-7-Mar-23-Added for SDT-26868-Start
        String quoteTypeConst = ''; 
        Schema.DescribeFieldResult quoteTypeDesc = SBQQ__Quote__c.SBQQ__Type__c.getDescribe();
        List<Schema.PicklistEntry> quoteTypes = quoteTypeDesc.getPicklistValues();

        Map<String, String> TypePLMap = new Map<String, String>();
        for(Schema.PicklistEntry plEntry : quoteTypes)
            if(plEntry.isActive())
                TypePLMap.put(plEntry.getValue(), plEntry.getLabel());

        //SDT 38061 adding 2nd if condition
        boolean isInternalCorrectionsTeamUser=UserServices.isInternalCorrectionTeamUser(UserInfo.getUserId());

        //SDT-41473
        if((c.Case_Record_Type__c == Constant_Util.New_Service_Case)||(c.Is_Haul_Away_Service__c))
            quoteTypeConst = Constant_Util.QUOTE;
        else if(c.Case_Record_Type__c == Constant_Util.MODIFY_EXISTING_SERVICE_CASE && c.Case_Type__c == Constant_Util.Change_Service 
                && c.Case_Sub_Type__c == Constant_Util.Change_Correction && c.Case_Reason__c == Constant_Util.CASE_REASON_DAYSOFSERVICE && !isInternalCorrectionsTeamUser)
            quoteTypeConst = Constant_Util.QUOTE_TYPE_AMEND;
        else if(c.Case_Record_Type__c == Constant_Util.UPDATE_ASSET_CASE)
            quoteTypeConst = Constant_Util.QUOTE_TYPE_AMEND;
        else if(c.Case_Record_Type__c == Constant_Util.MODIFY_EXISTING_SERVICE_CASE && c.Case_Type__c == Constant_Util.Change_Service && c.Case_Sub_Type__c == Constant_Util.Change_Correction)
            quoteTypeConst = Constant_Util.QUOTE_TYPE_CORRECTION;
    else if(c.Case_Record_Type__c == Constant_Util.MODIFY_EXISTING_SERVICE_CASE && c.Case_Type__c == Constant_Util.Change_Service && (c.Case_Sub_Type__c == Constant_Util.WASTE_STREAM || c.Case_Sub_Type__c == Constant_Util.Decrease || c.Case_Sub_Type__c == Constant_Util.Increase || c.Case_Sub_Type__c == Constant_Util.Rightsizing_Load_Max ||  c.Case_Sub_Type__c == Constant_Util.VENDOR))
      quoteTypeConst = Constant_Util.QUOTE_TYPE_AMEND;
        else
            quoteTypeConst = Constant_Util.KEYWORD_EXCEPTION;
        if(TypePLMap.containsKey(quoteTypeConst))
            q.SBQQ__Type__c = TypePLMap.get(quoteTypeConst);
        //pkulkarn-TCS-7-Mar-23-Added for SDT-26868-End

        try {
// Modified for SDT-33453 Start
            if(q != null){
            insert q;
}
            // Modified for SDT-33453 End
            SBQQ__Quote__c quote = [Select Id, Name from SBQQ__Quote__c Where Id =: q.Id];
            
            String sComments = 'SFDC Quote: '+ quote.Name +'\n';
            if (c.Tracking_Number__c != Null){
             sComments += 'SFDC Case: '+ c.CaseNumber + ' - Tracking Number: '+ c.Tracking_Number__c+'\n';
            }
            else {
              sComments += 'SFDC Case: '+ c.CaseNumber +'\n';
            }
            sComments += 'SFDC Reference #: '+ c.Reference_Number__c +'\n';

			q.Case_Comments__c = sComments;

            // Modified for SDT-33453 Start
            if(q != null){
            update q; 
}
            // Modified for SDT-33453 End
            c.IsOpportunity_Created__c = true;
			c.Integrate_with_Acorn__c = false; //21433
            c.Status = Constant_Util.OPEN; //21433
            //c.Status = Constant_Util.PENDING; //21433
            //SDT-26868 - Start - Set field 'Master_Intake_Complete__c' of case as True - by dojha
            c.Master_Intake_Complete__c = true;
            //SDT-26868 - End
            //Haul Away SDT 42654 Seema
            if(isHaulAway){
                c.Material_Grade__c = 'No Grade'; //Need to check where we use it
                c.Material_Type__c = Constant_Util.BULK_MATERIAL_PRODUCTCODE;
                c.Equipment_Type_Code__c = 'UNK';
                c.Equipment_Size_Code__c = 'UNK';
                c.Service_Occurrence_Type_Code__c = 'OC';
                // c.Origin = 'SFDC Default'; //Comment as a part of SDT-47951
            }
// Modified for SDT-33453 Start
            if(c != null){
            update c;
            //Haul Away SDT 42654 Seema
            if(isHaulAway){
                Map<String,sobject>  returnMap = new Map<String,sobject>();
                returnMap.put(String.valueof(c.Id),(SObject)c);
                returnMap.put(String.valueof(q.Id),(sObject)q);
                QuoteLineCreationHandler.execute(returnMap);
            }
            }
            // Modified for SDT-33453 End
        } catch (Exception e) {	//TCS-SDT-41546-Changed exception type from DmlException to Exception
            system.debug(e.getMessage());
            throw e;	//TCS-SDT-41546-Added
        }
              
      return q.Id;  
  }
    
    @AuraEnabled
    public static string getAddProductId() {
        
        String addProduct = [SELECT Id FROM SBQQ__CustomAction__c WHERE Name =: Constant_Util.ADD_PRODUCTS].Id;
        
        return addProduct;
        
    }
  
    // Go to Quote 
    @AuraEnabled
    public static List<Opportunity> getOpportunityID(String CaseId)
    {
        Case c = [SELECT CaseNumber from Case where id =: CaseId];
        List<Opportunity> OppDetail = new List<Opportunity>();
        OppDetail = [Select id, SBQQ__PrimaryQuote__c from  Opportunity where Name =: c.CaseNumber];
        
        return OppDetail;
    }
	
	//Added for SDT-16902
    @AuraEnabled
    public static void insertPlannerComment(Id caseId,String selectedDate,Boolean isAvailDates,Boolean isDateNotListed)
    {
        String comment;
        if(isAvailDates && !isDateNotListed)
        {
            comment = Constant_Util.CAPACITY_PLANNER_USERSELECT+selectedDate;
        }
        else if(isAvailDates && isDateNotListed)
        {
            comment = Constant_Util.CAPACITY_PLANNER_AVAILNOTSELECT;
        }
        else
        {
            comment = Constant_Util.CAPACITY_PLANNER_NOTAVAIL;
        }
        try{
            AcornController.createAcornComment(comment,caseId);
        }
        catch(Exception ex)
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);    
        }
    }

     /*
     * SDT-26287
     * Description: getCompanyCategory for seachable dropdown
     * 
     */ 
    @AuraEnabled
    public static List<Map<String, String>> getCompanyCategory(string caseId) {
		List<Map<String, String>> companyList = new List<Map<String, String>>();
        try{
            Case caseObj = [SELECT Id, Client__r.AccountNumber FROM Case WHERE Id =: caseId];
            Map<String, String> companyCategoriesMap = AcornCompanyDetails.getAcornCCMap(caseObj.Client__r.AccountNumber);
            List<sortingWrapper> sortedList = new List<sortingWrapper>();
    
            if(companyCategoriesMap != null && !companyCategoriesMap.isEmpty()) {
                for(string sobjName : companyCategoriesMap.keyset()) {
                    Map<String, String> sObjMap = new Map<String, String>();
                        sObjMap.put('label', companyCategoriesMap.get(sobjName));
                        sObjMap.put('value', sobjName);
                        sortedList.add(new sortingWrapper(sObjMap));
                }
            }
    
            sortedList.sort();
            for(sortingWrapper sortObjMap : sortedList) {
                companyList.add(sortObjMap.sObjFldsMap);
            }
        } catch(Exception ex)
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);    
        }
        return companyList;
    }
    
    /*
     * SDT-26287
     * Description: sort Company Category
     * 
     */
    public class sortingWrapper implements Comparable {
        public Map<String, String> sObjFldsMap;

        public sortingWrapper(Map<String, String> sObjFldsMap) {
            this.sObjFldsMap = sObjFldsMap;
        }

        public Integer compareTo(Object compareTo) {
            return sObjFldsMap.get('label').compareTo(((sortingWrapper)compareTo).sObjFldsMap.get('label'));
        }
    }
    
    public static String CheckQuoteCreationEligibility(Id RootAssetId, Id RootProductId) 
    {
        /* TCS: Added for SDT-31259
         * CreatedDate: 24-Aug-23
         * Story: SDT-31259
         * Comment: To check whether Quote can be created or not based on the Core Services
         * Input/Output: Root Asset Id and Root Product Id / Error message result
         */
        
        //Query Asset records with Product
        List<Asset> assetList = [SELECT RootAssetId, CPQ_Product__c, End_Date__c, Is_Null_End_Date__c, Start_Date__c FROM Asset WHERE RootAssetId = :RootAssetId];
        Set<Id> productIdsSet = new Set<Id>();
        Map<Id, Boolean> coreServiceMap = new Map<Id, Boolean>();
        String returnMessage = 'SUCCESS';

        for(Asset asset : assetList)
        {
            productIdsSet.add(asset.CPQ_Product__c);
        }
        
        //Query Core Service Product options of each product
        List<SBQQ__ProductOption__c> productOptions = new List<SBQQ__ProductOption__c>();
        productOptions = [ SELECT Id, Core_Service__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c = :RootProductId AND SBQQ__OptionalSKU__c  IN: productIdsSet AND Core_Service__c = true ];
        
        //Product to Core Service map
        for(SBQQ__ProductOption__c coreService : productOptions)
        {
            coreServiceMap.put(coreService.SBQQ__OptionalSKU__c, coreService.Core_Service__c);
        }
        
        //1. Multiple active specs of same core service exist
        /*Boolean multipleActiveCoreServicesExist = MultipleCoreServiceActiveCheck(assetList, coreServiceMap);
        if(multipleActiveCoreServicesExist)
        {
        	return System.Label.QuoteCreationCheckError1;
    	}*/
       
        //2. At least one active core service with future end date
        Boolean atLeastOneCoreServiceWithEndDate = AtLeastOneCoreServiceEndingInFutureCheck(assetList, coreServiceMap);
        if(atLeastOneCoreServiceWithEndDate)
        {
        	return System.Label.QuoteCreationCheckError2;
    	}
        
        //3. All Core services ended in the past
        Boolean allCoreServicesEndedInThePast = AllCoreServicesEndedInThePastCheck(assetList, coreServiceMap);
        if(allCoreServicesEndedInThePast)
        {
        	return System.Label.QuoteCreationCheckError3;
    	}
       
        //Return result
        return returnMessage;
    }
    
    public static Boolean MultipleCoreServiceActiveCheck(List<Asset> assets, Map<Id, Boolean> coreServiceMap) 
    {
        /* TCS: Added for SDT-31259
         * CreatedDate: 24-Aug-23
         * Story: SDT-31259
         * Comment: To check whether multiple active core services exist
         * Input/Output: List of assets and Core Services map / true/false flag true=eligibility failure, false=eligibility pass
         */
        //1. Multiple active specs of same core service exist
        //Compare Assets
        Boolean multipleActiveCoreServicesExist = false;
        for(Asset asset : assets)
        {
            if(coreServiceMap.containsKey(asset.CPQ_Product__c) && coreServiceMap.get(asset.CPQ_Product__c))
            {
                //Check if there is additional instance of the Product in the asset
                for(Asset asset1 : assets)
                {
                    //Check for the start date and end dates
                    if(asset.Id != asset1.Id && asset.CPQ_Product__c == asset1.CPQ_Product__c &&
                       (asset.End_Date__c > system.now().date() || asset.Is_Null_End_Date__c) &&
                       (asset1.Start_Date__c > system.now().date() || asset1.Is_Null_End_Date__c)
                      )
                    {
                        //Multiple core services exist for a given product
                        multipleActiveCoreServicesExist = true;
                    }
                }
            }
        }
        return multipleActiveCoreServicesExist;
    }
    
    public static Boolean AtLeastOneCoreServiceEndingInFutureCheck(List<Asset> assets, Map<Id, Boolean> coreServiceMap) 
    {
        /* TCS: Added for SDT-31259
         * CreatedDate: 24-Aug-23
         * Story: SDT-31259
         * Comment: To check whether at least one core service in ending in a future date
         * Input/Output: List of assets and Core Services map / true/false flag true=eligibility failure, false=eligibility pass
         */
        //Check for At least one active core service with future end date
        Boolean atLeastOneCoreServiceWithEndDate = false;
        for(Asset asset : assets)
        {
            if(coreServiceMap.containsKey(asset.CPQ_Product__c) && coreServiceMap.get(asset.CPQ_Product__c))
            {
                //Check if asset has an end date in future
                if(asset.Is_Null_End_Date__c == false && asset.End_date__c > system.now().date())
                {
                    return true;
                }
            }
        }
        return atLeastOneCoreServiceWithEndDate;
    }
    
    public static Boolean AllCoreServicesEndedInThePastCheck(List<Asset> assets, Map<Id, Boolean> coreServiceMap) 
    {
        /* TCS: Added for SDT-31259
         * CreatedDate: 24-Aug-23
         * Story: SDT-31259
         * Comment: To check whether all core services are ended in the past
         * Input/Output: List of assets and Core Services map / true/false flag true=eligibility failure, false=eligibility pass
         */
        //Check for At least one active core service with future end date
        Boolean allCoreServicesEndedInThePast = true;
        for(Asset asset : assets)
        {
            if(coreServiceMap.containsKey(asset.CPQ_Product__c) && coreServiceMap.get(asset.CPQ_Product__c))
            {
                if(asset.Is_Null_End_Date__c == false && asset.End_date__c <= system.now().date())
                    continue;
                else 
                    allCoreServicesEndedInThePast = false;
            }
        }
		return allCoreServicesEndedInThePast;
    }
	//addition for SDT - 32426
    //method for modifyExistingProgressCase value assignment
    //included button name in query
	//Changes related to SDT -32895
    private static Boolean buttonVisibilityLogic(String ButtonName,String RecordType,String CaseType, String CaseSubype, String CaseReason,Wrapper wrapperClass){
        
         //SDT-41473
         //SDT-41473-42045
         case csedata = wrapperClass.caseData;
         Boolean isHaulAway = HaulAwayService.getIsHaulAwayService(csedata);
         if(ButtonName == 'Add Quote' && isHaulAway && !wrapperClass.isOpportunityCreated  && wrapperClass.CaseStatus.equalsIgnoreCase(Constant_Util.STATUS_New)){   //SDT-41473-41538,41540
            return true;
         }else if (ButtonName == 'Add Quote' && isHaulAway && wrapperClass.isOpportunityCreated){
            return false;
         }
         else{

        //querying metadata for checking if progress case need to be shown or not
        Boolean checkforUCCCode;
        
        List<Case_Highlight_Panel_Button__mdt> buttonVisibilityMetadata = [SELECT Visibility__c FROM Case_Highlight_Panel_Button__mdt 
                                                                       WHERE Record_Type__c =:RecordType AND Case_Type__c =:CaseType AND Case_Sub_Type__c=:CaseSubype 
                                                                       AND Case_Reason__c=:CaseReason
                                                                       AND Button_Name__c =:ButtonName 
                                                                       AND isCPQ_Active_User__c =:wrapperClass.Is_UserHaveCPQLicence
                                                                       AND isUpdateAssetActiveUser__c =:wrapperClass.Is_UpdateAssetActiveUser LIMIT 1];
        if(buttonVisibilityMetadata.size()>0 ){
  

      if(ButtonName == 'Add Quote')
      {    
          
          if(buttonVisibilityMetadata[0].Visibility__c)
                return AddQuoteVisiblityLogicCheck(wrapperClass);
           //SDT- 33636 -Start- logic to show add quote button based on UCC 
        else
        {
            Boolean AddButtonCheck = AddQuoteVisiblityLogicCheck(wrapperClass);
            checkforUCCCode = getUserUCCDetail(wrapperClass);
            if(checkforUCCCode && AddButtonCheck){
            return true; }
            else return false;
        }
        
      }
            else
      {
            System.debug('here2^^ ' );
            //progresscase button visibility
            if(buttonVisibilityMetadata[0].Visibility__c)
            return ProgressCaseVisiblityLogicCheck(wrapperClass);
            else return false;
      }
        
        }
        
        else if(buttonVisibilityMetadata.size() == 0)
        { 
    
            checkforUCCCode = getUserUCCDetail(wrapperClass);
            if(checkforUCCCode){
            return true; }
            else return false;
            
        }
        //SDT- 33636 -End- logic to show add quote button based on UCC 
        else{
            return false;
        }
    }
    } 
	
		//changes related to SDT - 32895
	private static Boolean AddQuoteVisiblityLogicCheck(Wrapper wrapperClass){
	//logic to show add quote button
    if (wrapperClass.caseData.ContactId != NULL && wrapperClass.caseInfo != null && wrapperClass.caseInfo != '' && wrapperClass.caseInfo != Constant_Util.ASSET_NOT_ACTIVE && !wrapperClass.isOpportunityCreated && (wrapperClass.CaseStatus.equalsIgnoreCase(Constant_Util.STATUS_New) || wrapperClass.CaseStatus.equalsIgnoreCase(Constant_Util.Case_Open_Status) )) 
		{	
			if(wrapperClass.CaseType == 'New Service' && wrapperClass.CaseStatus.equalsIgnoreCase(Constant_Util.STATUS_New))
			{
			return true;
			}
			else if(wrapperClass.CaseType != 'New Service' && wrapperClass.assetId != null /*&& wrapperClass.CPQProduct !=null*/)
			{
			return true;
			}
            else
            {
             return false;
            }
		}
        else
        {
            return false;
        }
        
	}
    //changes related to SDT - 32895
	private static Boolean ProgressCaseVisiblityLogicCheck(Wrapper wrapperClass){
        //logic to show progress case button
        if(wrapperClass.CaseStatus != 'Closed')
        {
            
            //added additional logic to check if asset is mandatory related to SDT - 33376
            if(wrapperClass.CaseType != 'New Service' && wrapperClass.caseInfo != null && 
               ((wrapperClass.caseInfo.contains('Ready') ||!wrapperClass.isCaseInfoReady) 
                ||wrapperClass.caseInfo == Constant_Util.PROGRESS_CASE || 
                (wrapperClass.caseInfo != Constant_Util.ASSET_NOT_ACTIVE && wrapperClass.WorkOrderCreation && !wrapperClass.isAssetMandatory && wrapperClass.caseData.ContactId !=null)))
            {
            return true;
            }
            else if(wrapperClass.CaseType == 'New Service' && wrapperClass.caseInfo == null)
            {
            return true;    
            }
            else
            {
             return false;
            }
        }
        else
        {
            return false;
        }
	}
	
	public inherited sharing class CaseSuccess{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<WorkOrder> dupList = new List<WorkOrder>();
        @AuraEnabled public List<Case> childCases = new List<Case>();
    }
	
	
    public static CaseSuccess createMultipleCasesInvoke(string caseRecId) {
         //System.debug('createMultipleCasesInvokee>>>');
        list<case> caseList= new list<case>();
        DateTime slaDateTime = null;
      
        CaseSuccess wrap = new CaseSuccess();
        try{
            Case selectedCase = [SELECT id, SLA_Service_Date_Time__c,Chargeable__c, SLA_Service_DateTime__c,Is_MultiCase_TaskBundling__c, AccountId,CaseNumber,Case_Information__c,Override_PO_Create_Task__c,User_Input_Work_Order_Instructions__c,recordTypeId, Location__c, Reference_Number__c, AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,Site_Contact_Phone__c,SalesMeet_Container_Position__c,Supplier__c,PurchaseOrder_Number__c,PSI__c,Profile_Number__c,PSI_Required__c,Override_Profile_Number_Task__c,PurchaseOrder_Required__c,SLA_Override_Reason__c,/*Work_Order_Instructions__c,*/isMultiCalendarChecked__c,
                                 Company_Category__c,Override_Company_Category_Create_Task__c 
                                 FROM Case 
                                 WHERE id=:caseRecId]; 
            //System.debug('>>>selectedCase-->'+ selectedCase );
         Id standardRecType = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Standard Case').getRecordTypeId();
        Case newCase= new case();
                newCase = selectedCase.clone(false, false, false, false);
        //newCase.Check_Case__c = false;
         newCase.ParentId = selectedCase.Id; 
         newCase.Is_Clone__c = true;
         newCase.RecordTypeId = standardRecType;
         newCase.Case_Type__c = 'General';
         newCase.Case_Sub_Type__c = 'Other';
         newCase.Case_Reason__c = 'All Other Inquiries';
         newCase.Chargeable__c = selectedCase.Chargeable__c;
         caseList.add(newCase);      
            if(!caseList.isEmpty()){
                insert caseList;
                for(Case caseObj : caseList){
                    copyEmailToChildCase(selectedCase.Id,caseObj);
                    createObtainInternalRespoTask(caseObj.id);
                    
                }
            }
         
            wrap.success = true;
            return wrap;
        }catch(Exception ex){  // Catch block to catch error messages  
            wrap.success = false;
            wrap.message = ex.getMessage()+'\n'+ex.getStackTraceString();
            return wrap;
        }
    }
	
	 public static void createObtainInternalRespoTask(String whatId){
        case caseRec = [Select Id,CheckReassignment__c, Tracking_Number__c FROM Case where Id =:whatId ];
		 User u = [SELECT Id, name from user where name = 'Compliance Team' limit 1];
        caseRec.CheckReassignment__c = true;
        update caseRec;
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Initiate_Task').getRecordTypeId();
        //  Initiate_Task
        Boolean sfdcTeamuserAssingment = false ;
        Boolean createGeneysisRouting = false ;
        Boolean updateTaskOwner = false ;
        String userGrServiceFlag = null ;
	
       // Adding a flag to Stop task trigger BR-270
        BusinessRuleUtility.skipTaskTriggerBR =false;
		 
        Task ObtainInternalRespoTask = new Task();
        ObtainInternalRespoTask.RecordTypeId = recordTypeId ;
          ObtainInternalRespoTask.OwnerId = u.Id ;
        ObtainInternalRespoTask.Subject = 'Obtain Internal Response' ;
        ObtainInternalRespoTask.Description = 'test' ;
        ObtainInternalRespoTask.Process__c = 'Case Assignment' ;
        ObtainInternalRespoTask.WhatId = whatId;
        ObtainInternalRespoTask.Due_Date_Time__c = system.now() ;
        ObtainInternalRespoTask.ActivityDate = date.valueOf(system.now());
        insert ObtainInternalRespoTask ; 
       
    }
	
	 public static void copyEmailToChildCase(string recordId, Case caseObj){
        List<EmailMessage> updatedEmailList = new List<EmailMessage>();
        List<EmailMessage> emailList = [SELECT id,Subject,FromAddress,HtmlBody,TextBody,ToAddress,ParentId,RelatedToId from EmailMessage where ParentId =: recordId LIMIT 49999];
        if(emailList.size()>0) {
            for(EmailMessage email : emailList){
                EmailMessage newEmail= new EmailMessage();
                newEmail = email.clone(false, false, false, false);
                newEmail.ParentId = caseObj.Id;
                newEmail.RelatedToId = caseObj.Id;
                updatedEmailList.add(newEmail);                    
            }
        }else{}
        try {
            database.insert(updatedEmailList);
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
        }
                    
    }

     /* Author- TCS - Ruchika
    * Date- 05/07/2024
    * Story - SDT-33636
    * Description - method to return visibilty for Add Quote button based on User Categorization Code
    *             querying metadata for checking if Add Quote button visibilty need to be shown or not
    */
    
    public static Boolean getUserUCCDetail(Wrapper wrapperClass) { 
        Boolean Is_UCCUser = false;
        Boolean isCPQUser = false;
        Boolean isUpdateAssetActiveUser = false;
         
        isCPQUser = getUserDetail(); 
        isUpdateAssetActiveUser = getActiveAssetUserDetail();  
         
        User u = [SELECT Id, User_categorization_code__c FROM User WHERE Id =: UserInfo.getUserId()];

        if(u.User_categorization_code__c != null && (u.User_categorization_code__c == Constant_Util.CSRES || 
                                                     u.User_categorization_code__c == Constant_Util.CSDTRES ||
                                                     u.User_categorization_code__c == Constant_Util.SPCOR )
                                                     && isCPQUser)
        {
            if((wrapperClass.CaseStatus.equalsIgnoreCase(Constant_Util.STATUS_New) || 
             wrapperClass.CaseStatus.equalsIgnoreCase(Constant_Util.Case_Open_Status) || 
             wrapperClass.CaseStatus != Constant_Util.CLOSED) && 
             wrapperClass.caseData.ContactId != NULL && 
             wrapperClass.CaseType != Null &&    
             wrapperClass.CaseSubType!= Null || (wrapperClass.CaseReason != Null && wrapperClass.CaseType!='Standard Case'))  
         {           
            List<Add_Quote__mdt> buttonVisibilityMetadata = [SELECT Visibility__c FROM Add_Quote__mdt where Button_Name__c = 'Add Quote' AND UCC__c =: u.User_categorization_code__c LIMIT 1];
            if(buttonVisibilityMetadata.size()>0 && buttonVisibilityMetadata[0].Visibility__c)
                {
                    return true;
                }
             else
                {
                    return false;
                }  
          }  
          return false; 
        }
        return false;
    }
	
	@AuraEnabled
    public static Boolean launchCPQQuoteValidation(String CaseId) {
        //Call the validation flow for CPQ via Apex for the ShowCaseMessages aura bundle
        
        Boolean eligibility = false;
        
        Map<String, Object> flowParams = new Map<String, Object>();
        flowParams.put('caseRecordId', CaseId);
        Flow.Interview.Validation_Add_Change_Scope_Evaluation validationFlow = new Flow.Interview.Validation_Add_Change_Scope_Evaluation(flowParams);
        validationFlow.start();
        
        eligibility = (Boolean)validationFlow.getvariableValue('OutputQuoteEligible');
        
        return eligibility;
    }
	
}
