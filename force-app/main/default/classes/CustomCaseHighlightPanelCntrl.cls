/**
* @author Accenture
* @date 2/28/2019
* @description : Apex class CustomCaseHighlightPanelCntrl 
**/
public without sharing class CustomCaseHighlightPanelCntrl {
    private static Case myCases = new case();
    private static List<Case> myCasesList = new List<case>();
    private static Map<String,Boolean> POProfileReqMap = new Map<String,Boolean>();
  
    //Method created to extract Custom Metadata  SDT-20936 . Custom Metadata controls visiblity of PO/Profile based on Case Type.
    public static Map<String,Boolean> getMetadata(){
        
        List<POProfileDisable__mdt> lstPOProfileReq = POProfileDisable__mdt.getAll().values();        
         for(POProfileDisable__mdt poPF :lstPOProfileReq){ 
           POProfileReqMap.put(poPF.CaseType__c,poPF.IsEnable__c);            
     }    
        return POProfileReqMap;
   }
         
/**
* @author Accenture
* @date 2/28/2019
* @description : Apex method getCaseHighlightDetails to display the case details in highlight panel
**/ 
    @AuraEnabled
    public static Wrapper getCaseHighlightDetails(Id caseId){
        Wrapper wrapperClass = new Wrapper();
        Boolean POFlag ;
      
    
      try{
            myCases = [SELECT Id, Client__c,accountId,CaseNumber,Reference_Number__c,Profile_Number__c,Override_Profile_Number_Task__c,Location__c,Supplier__c,Supplier__r.Name,Location__r.Name,ContactId,Contact.Name, Contact_Title__c,Case_Type__c,Case_Sub_type__c,
            Invoice_Number__c,Disputed_Amount__c,//SDT 39047           
            AssetId,Asset.Name,Asset_Material__c,Status,Case_Sub_Status__c,EmailofContact__c,SLA_Service_Date_Time__c,Override_PO_Create_Task__c,SuppliedEmail,Case_Reason__c,				
                       PSI_Override_Reason__c,PSI_Comments__c,Chargeable__c,createdDate,Show_Multiple_Asset_Cases__c,Is_Multiple_Asset__c,Service_Date__c,SLA_Service_DateTime__c,Service_Date_Text__c,Origin,PSI__c,OwnerId,
                       PurchaseOrder_Number__c,SlaStartDate,ContactDepartment__c,Case_Record_Type__c,isMultiCalendarChecked__c,Work_Order__c,Work_Order__r.WorkOrderNumber,Tracking_Number__c,Acorn_Work_order__c,Location__r.Customer_Location_Code__c,
                       Client__r.Name,Location__r.Location_Code__c,Location__r.ShippingStreet,Location__r.ShippingCity,Location__r.ShippingPostalCode,Location__r.ShippingState,Location__r.ShippingCountry,Location__r.Phone,Location__r.Primary_Segment__c, Location__r.Secondary_Segment__c,Location__r.tz__Local_Time_Short__c,Contact.Phone, 
                       Contact.MobilePhone, Contact.Preferred_Method__c,Contact.Email_Validated__c,Contact.Email,Asset.Material_Type__c,Asset.Duration__c,Asset.Occurrence_Type__c,Asset.Schedule__c, Asset.Quantity__c,Asset.Supplier__r.Name,Asset.Vendor_ID__c,Asset.Service_Type__c,Asset.Acorn_SID__c,Asset.Supplier__c,
                       Asset.Sensitivity_Code__c,Asset.Has_Extra_Pickup__c,Asset.Equipment_Owner__c,Asset.Start_Date__c,Asset.End_Date__c,Asset.Container_Position__c, Asset.Category__c,Asset.MAS_Customer_Unique_Id__c,Asset.Vendor_Account_Number__c,Company_Category__c, Override_Company_Category_Create_Task__c,RecordTypeId,
                       Business_RuleId__c,Required_Information__c,Location__r.Location_Type__c,Location__r.Geography__c,Location__r.Division__c,Location__r.Brand__c, Location__r.Is_Portal_Customer__c, Location__r.Portal_Name__c, 
                       Asset.MAS_Company_Account_Number__c,Asset.ProductFamily,Asset.Cost_Currency__c,Asset.Price_Currency__c,Asset.MAS_Library__c,Asset.Project_Code__r.ProjectCode_Id__c,CPQ_New_Service__c,(select id,Name,Asset_Header__r.Name from Case_Assets1__r) FROM CASE WHERE id =:caseId LIMIT 1];
            if(myCases.Service_Date__c!= null){
                myCases.Service_Date_Text__c = myCases.Service_Date__c.format();
                }else{
                    //nova cop fix
                }
	  if( String.isBlank(myCases.PurchaseOrder_Number__c) && String.isBlank(myCases.Chargeable__c) && String.isBlank(myCases.Company_Category__c) && myCases.PSI__c == null){
              wrapperClass.isReqInfoEmpty = true;
          }else{
              wrapperClass.isReqInfoEmpty = false;
          }
            wrapperClass.CPQUser = GetCaseInformation.getUserDetail();
            wrapperClass.myCase = myCases;         
	    List<String> resList = getRequiredInformation(myCases);
          //system.debug('resList :'+resList);
          if(resList.size() > 0 && resList!=null && !resList.isEmpty()){
              if(resList[0]!=null && String.isNotBlank(resList[0])){
                  wrapperClass.reqInfo = resList[0];
                  if(resList[1]!=null && String.isNotBlank(resList[1])){
                      wrapperClass.businessRuleId = resList[1];
                      wrapperClass.requiredInfo = resList[2];
                  }
              }else if(resList.size() > 1){
                  if(resList[1]!=null && String.isNotBlank(resList[1]) && String.isNotBlank(resList[2])){
                      wrapperClass.businessRuleId = resList[1];
                      wrapperClass.requiredInfo = resList[2];
                  }
              }
          }
            wrapperClass.isAssetMandatory = true;
             //SDT-39047 
            wrapperClass.allowProgressCase = true;
            if(myCases != null && string.isNotBlank(myCases.Case_Type__c) && string.isNotBlank(myCases.Case_Sub_type__c)){
                //SDT-39047
                BillingService billing = new BillingService();
                wrapperClass.allowProgressCase = billing.isBillingDataBlank(myCases,GetCaseInformation.LoggedInUserProfile);
                for(WOCreation__mdt wo : [SELECT Id,Case_Type__c,Case_Subtype__c ,Case_Reason__c,WO_Needed__c,Is_Asset_Mandatory__c 
                                          FROM WOCreation__mdt 
                                          WHERE Case_Type__c =: myCases.Case_Type__c and Case_Subtype__c =:myCases.Case_Sub_type__c]){                    
                    if(String.isNotBlank(myCases.Case_Reason__c) && myCases.Case_Reason__c.equals(wo.Case_Reason__c)){
                        wrapperClass.isAssetMandatory = wo.Is_Asset_Mandatory__c ;
			    break;
                    }else {
                        wrapperClass.isAssetMandatory = wo.Is_Asset_Mandatory__c ;
                    }
                }
            } 
	   if(myCases.Case_Sub_type__c == Constant_Util.BALES){
                wrapperClass.isAssetMandatory = FALSE;
            }
            /*if(string.IsBlank(wrapperClass.reqInfo)){
                wrapperClass.caseInfo = Constant_Util.READY;
            } */           
            List<String> processSet = System.Label.Process_List.split(Constant_Util.COMMA);
            List<Task> tskLst = [SELECT Id, WhatId, Process__c, status FROM Task WHERE WhatId =: caseId  
                                        AND status =: Constant_Util.OPEN AND Process__c IN: processSet];                                   
            if((!tskLst.isEmpty() && tskLst != null) || myCases.Case_Sub_Status__c == Constant_Util.INTEGRATION_ERROR) {
                wrapperClass.isOpenTask = true;
            }
      
       //Setting IsPOProfileDisable flag to disable PO/Profile -- SDT-20936
            POProfileReqMap = getMetadata();       
          if(POProfileReqMap.get(myCases.Case_Type__c) != null){
           wrapperClass.IsPOProfileDisable = POProfileReqMap.get(myCases.Case_Type__c);     
          }
                       
           
                             
        }Catch(exception ex){
            system.debug('ex Error :'+ ex.getMessage());
            return null;
        }		        
        return wrapperClass;
    }
    
    
/**
* @author Accenture
* @date 2/28/2019
* @description : Apex method to get po/profileNumber/psi information
**/ 
    public static List<String> getRequiredInformation(Case myCases) {
        String reqInfo = '';
        set<Id> accountIdset = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> ServiceTypeSet = new Set<string>();
        set<Id> relatedCaseIdSet = new set<Id>();
        set<Id> recordTypeIdSet = new set<Id>();
        accountIdset.add(myCases.Client__c); 
        requestTypeSet.add(myCases.Case_Type__c);
        ServiceTypeSet.add(myCases.Case_Sub_type__c);
        List<String> resultList = new List<String>();
        // for po/profile/psi
            myCasesList.add(myCases);
            map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
            if(myCases.Status.equals(Constant_Util.STATUS_New) || myCases.Status.equals(Constant_Util.PENDING) || (myCases.Status.equals(Constant_Util.OPEN) && myCases.Case_Record_Type__c == Constant_Util.New_Service_Case)){
            for(Asset a : [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Material_Type__c,Project_Code__c,Active__c,Sensitivity_Code__c,End_Date_Based_on_Project_code__c
                           FROM Asset WHERE Id =: myCases.AssetId LIMIT 49999]){
                               CaseTriggerHelper.casewithContainer.put(a.Id,a);
                           }
            for(Account loc: [SELECT Id,Brand__c,Geography__c,Division__c,Location_Type__c 
                              FROM Account WHERE Id =: myCases.Location__c LIMIT 49999]){
                                  CaseTriggerHelper.casewithLocation.put(loc.Id,Loc);
                              }
                Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
                if(myCases.Status.equals(Constant_Util.STATUS_New) || myCases.Status.equals(Constant_Util.OPEN)){
                    recordTypeIdSet.add(reqInfoRecTypeId);
                }
                if(myCases.Case_Record_Type__c == Constant_Util.New_Service_Case){
                    //List<BusinessRuleNSCHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleNSCHelper.selectBusinessRules(myCasesList);
                    List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = new List<BusinessRuleHelper.BusinessRulewrapper>();
                    for (Case c : myCasesList) {
                        businessRulewrapperlst.addAll(BusinessRuleHelper.businessRuleSelection(c.Id,recordTypeIdSet));
                    }
                    if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
                        //for(BusinessRuleNSCHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                        for(BusinessRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                            if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                                reqInfomap.put(brw.caseId,brw.bRule);
                            }
                        }
                	}
                }else{
                    List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCasesList,recordTypeIdSet,accountIdset,requestTypeSet,ServiceTypeSet,CaseTriggerHelper.casewithContainer,CaseTriggerHelper.casewithLocation);
                    //List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCases.Id,recordTypeIdSet);
                    if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
                        for(BusinessRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                            if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                                reqInfomap.put(brw.caseId,brw.bRule);
                            }
                        }
                    }
                }
            }
            if(myCases.Status.equals(Constant_Util.STATUS_New) || (myCases.Status.equals(Constant_Util.OPEN) && myCases.Case_Record_Type__c == Constant_Util.New_Service_Case)){
                reqInfo = Constant_Util.EMPTY_STRING;
                Business_Rule__c caseRule = new Business_Rule__c();
                caseRule = reqInfomap != null && reqInfomap.size() > 0 && reqInfomap.containskey(myCases.Id) ? reqInfomap.get(myCases.Id) : null;
                    if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PO_NUMBER) && String.isBlank(myCases.PurchaseOrder_Number__c) && !(myCases.Override_PO_Create_Task__c)){
                        reqInfo += Constant_Util.PO_MSG + Constant_Util.NEW_LINE;            
                    }
                    //commented as part of sdt 33312
                    /*if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PROFILE_NUMBER) && String.isBlank(myCases.Profile_Number__c) && !(myCases.Override_Profile_Number_Task__c)){
                        reqInfo += Constant_Util.PROFILE_MSG + Constant_Util.NEW_LINE;            
                    }*/
                    if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.PSI) && myCases.PSI__c == null){
                        if(myCases.PSI_Override_Reason__c == null){ 
                            reqInfo += Constant_Util.PSI_REQUIRED + Constant_Util.NEW_LINE;
                        }
                        else if(myCases.PSI_Override_Reason__c != null && myCases.PSI_Override_Reason__c == Constant_Util.OTHER_API && myCases.PSI_Comments__c == null)  {
                            reqInfo += Constant_Util.PSI_COMMENTS + Constant_Util.NEW_LINE;
                        }
                        else{
                            //Nova cop fix
                        }
                    }
                    if(caseRule !=null && caseRule.Required_Information__c.contains(Constant_Util.COMPANY_CATEGORY) && String.isBlank(myCases.Company_Category__c) && !(myCases.Override_Company_Category_Create_Task__c)){
                        reqInfo += Constant_Util.CC_MSG + Constant_Util.NEW_LINE;
                    }
                
                resultList.add(reqInfo);
                if(caseRule!=null && caseRule.Id!=null && caseRule.Required_Information__c!=null){
                    resultList.add(caseRule.Id);
                    resultList.add(caseRule.Required_Information__c);
            	}
            }        
   
        return resultList;//reqInfo;
    }
    
    public with sharing class Wrapper {
        @AuraEnabled public string reqInfo {get;set;}
        @AuraEnabled public Case myCase {get;set;}
        @AuraEnabled public Boolean CPQUser {get; set;}
        @AuraEnabled public Boolean isOpenTask {get;set;}   
        @AuraEnabled public Boolean isAssetMandatory {get;set;}   
        @AuraEnabled public Boolean IsPOProfileDisable {get;set;}
        @AuraEnabled public Boolean isReqInfoEmpty {get;set;}
        @AuraEnabled public String businessRuleId {get;set;}
        @AuraEnabled public String requiredInfo {get;set;}
        //SDT39047
        @AuraEnabled public Boolean allowProgressCase {get;set;}
    } 
    /* Author- WM
	* Date- 04/30/2020
	* Description- method to get wm capacity planner visibility as per SDT-12786
	*/
    @AuraEnabled
    public static Boolean getCapacityEligibilty(String caseId){
        Boolean isEligible=false;
        isEligible = ServiceDateContainerController.IsWMCapacityPlannerVisible(caseId);
        return isEligible;
    }
    /* Author- WM
	* Date- 03/01/2022
	* Description- method to get Queue name as per SDT-23166
	*/	
	@AuraEnabled
    public static String getQueueName(String trackingNumber){
        String queueName = '';
        RESTHelper.AcornResponse jsonResp;
        try{
            String result = IntegrationHandlerUtil.getQueueMetadataDetails('Get_Assignment',trackingNumber);
            Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(result);
            Map<String, Object> m2 = (Map<String, Object>) parsedResponse.get('data');
            if(m2 != null)
            {
                String teamName = (String)m2.get('teamName');
                String userName = (String)m2.get('userName');
                if(teamName != null && userName != null)
                {
                    queueName = userName+' / '+ teamName;
                }
                else if(teamName == null && userName != null)
                {
                    queueName = userName;
                }
                else if(teamName != null && userName == null)
                {
                    queueName = teamName;
                }
                else if(teamName == null && userName == null)
                {
                    jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
                    queueName = 'Error: '+jsonResp.Problem.Title + ': ' + jsonResp.Problem.Errors[0].Message;
                }
                return queueName;
            }
            else
            {
                jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
                queueName = 'Error: '+jsonResp.Problem.Title + ': ' + jsonResp.Problem.Errors[0].Message;
                return queueName;
            }
        }
        catch(Exception ex)
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            return queueName;
        }
    }

    @AuraEnabled
    public static String updateBRonCase(String caseId,String brId,String reqInfo){
// Modified for SDT-33454 Start
        try {
        If(String.isNotBlank(brId)){
            Case newUpdate = new Case(Id=caseId,Business_RuleId__c=brId,Required_Information__c=reqInfo);
if(newUpdate != null){
            update newUpdate;
        }
}
        } catch (DmlException e) {
            //System.debug('A DML exception has occurred: ' + e.getMessage());
            STPExceptionUtil.setStepByStepExceptionObj('updateBRonCase', 'Case Screen',e.getMessage());
        }
        // Modified for SDT-33454 End
        return 'success';
    }

}
