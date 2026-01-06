/*************************************************************
@Name: BusinessRuleTriggerHelper
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Helper Class to Perform operations on Business Rule
@UsedBy: BusinessRuleTriggerHandler

@Last Updated Date  : 28-01-2025
@Last Updated By    : Srishti Gupta
@description   : Modified methods as per BRE-6 || Retiring Duplicate rule logic on bussiness rule as it will automatically get covered with OOTB functionality.
**************************************************************/
public without sharing class BusinessRuleTriggerHelper {
    Public static final string QUERY1 = 'SELECT Id,AccountId__c,Container__c,Service__c,Schedule_Type__c,LocationId__c,Project_Code__c,AssetId__c,RecordTypeId,Special_Ins__c,Channel_Req__c,Category_Type__c,Group__c,Material__c,Case_Reason__c FROM Business_Rule__c WHERE AccountId__c IN : clientNameSet AND Container__c IN: containerSet AND Service__c IN: serviceSet AND Schedule_Type__c IN: scheduleTypeSet AND LocationId__c IN: locationIdSet AND Project_Code__c IN: projectset AND AssetId__c IN: assetset AND RecordTypeId IN: recordTypeIdSet AND Group__c IN: groupSet AND Category_Type__c IN: categoryTypeSet';
    Public static final string QUERY2 = ' AND Id NOT IN:idSet LIMIT 49999';
    Public static final string QUERY3 = ' LIMIT 49999';
   /*   
* This method is used to validate the Business Rule whether the duplication is created or not 
* @owner : DineshKumar S
* @param : BusinessRuleList */
  public static void validateBR(List<Business_Rule__c > newbrList,Boolean isUpdate){
        set<Id> clientNameSet = new Set<Id>();
        set<string> containerSet = new set<string>();
        set<string> serviceSet = new set<string>();
        set<string> scheduleTypeSet = new set<string>();
        set<Id> locationIdSet = new set<Id>();
        set<Id> recordTypeIdSet = new set<Id>();   
        set<Id> projectset = new set<Id>();
        set<Id> assetset = new set<Id>();
        set<String> categoryTypeSet = new set<String>();
        set<Id> groupSet = new set<Id>();
        set<Id> idSet = new set<Id>();
        string query = null;
        Map<string,Business_Rule__c> existingbrmap = new Map<string,Business_Rule__c>();
        query = QUERY1;
        for(Business_Rule__c br : newbrList){
            If(!Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.TASK_NOTIFICATION).getRecordTypeId().equals(br.RecordTypeId)){
                clientNameSet.add(br.AccountId__c);
                containerSet.add(br.Container__c);
                serviceSet.add(br.Service__c);
                scheduleTypeSet.add(br.Schedule_Type__c);
                locationIdSet.add(br.LocationId__c);
                projectset.add(br.Project_Code__c);
                assetset.add(br.AssetId__c);
                categoryTypeSet.add(br.Category_Type__c);
                groupSet.add(br.Group__c);
                recordTypeIdSet.add(br.RecordTypeId);
                If(isUpdate){
                    idSet.add(br.Id);
                 } 
            }
            If(!isUpdate && Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId().equals(br.RecordTypeId)){
                br.Active__c = false;
            }
        }
        If(!idSet.isEmpty() && idSet.size() > 0){
            query += QUERY2;
        }else{
           query += QUERY3;
        }
        string businesskey = null;
        system.debug('query+++'+query);
        for(Business_Rule__c br : Database.query(query)){
              businesskey = br.AccountId__c + Constant_Util.HYPHEN + br.LocationId__c + Constant_Util.HYPHEN + br.Service__c + Constant_Util.HYPHEN + br.Container__c + Constant_Util.HYPHEN + br.Schedule_Type__c + Constant_Util.HYPHEN + br.Project_Code__c + Constant_Util.HYPHEN + br.AssetId__c + Constant_Util.HYPHEN + br.Category_Type__c + Constant_Util.HYPHEN + br.Group__c + Constant_Util.HYPHEN + br.RecordTypeId + Constant_Util.HYPHEN + br.Material__c + Constant_Util.HYPHEN + br.Case_Reason__c;
           
              existingbrmap.put(businesskey,br);              
        }
        system.debug('existingbrmap++'+existingbrmap);

   /* As per BRE-6 : Retiring the custom duplicate rule logic as it will automatically get covered with OOTB functionality.
    businesskey = null;
        try{
            for(Business_Rule__c br : newbrList){
                businesskey = br.AccountId__c + Constant_Util.HYPHEN + br.LocationId__c 
                    + Constant_Util.HYPHEN + br.Service__c + Constant_Util.HYPHEN + br.Container__c + 
                    Constant_Util.HYPHEN + br.Schedule_Type__c + Constant_Util.HYPHEN + br.Project_Code__c +
                    Constant_Util.HYPHEN + br.AssetId__c + Constant_Util.HYPHEN + br.Category_Type__c +
                    Constant_Util.HYPHEN + br.Group__c + Constant_Util.HYPHEN + br.RecordTypeId + Constant_Util.HYPHEN + br.Material__c + Constant_Util.HYPHEN + br.Case_Reason__c;
            
                if(!existingbrmap.isEmpty() && existingbrmap.containskey(businesskey)
                   && !(br.RecordTypeId).equals(Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId())){
                   //  br.addError(system.Label.Duplicate_Business_Rule_Error);
                }
                else if(!existingbrmap.isEmpty() && (br.RecordTypeId).equals(Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId()) && 
                        ((String.isNotBlank(existingbrmap.get(businesskey).Special_Ins__c) && String.isNotBlank(br.Special_Ins__c)) 
                         || (String.isNotBlank(existingbrmap.get(businesskey).Channel_Req__c) && String.isNotBlank(br.Channel_Req__c)))){
                            // br.addError(system.Label.Duplicate_Business_Rule_Error);
                        }else{
                            //Nova cop fix.
                        }
            }
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
        }*/
    } 
    /*   
    * This method is used to deactivate Service Approvers when Business Rule is inactive 
    * @owner : Accenture
    * @param : BusinessRuleList
    */
    public static void deactivateServiceApprovers(List<Business_Rule__c > newBRLst){
        set<Id> businessRuleIds = new set<Id>();
        List<Service_Approver__c> serviceApproverLst = new List<Service_Approver__c>();
        
        for(Business_Rule__c businessRule : newBRLst){
            if(!businessRule.Active__c){
                businessRuleIds.add(businessRule.Id);
            }
        }
        for(Service_Approver__c serviceApprover : [SELECT Id, Active__c FROM Service_Approver__c WHERE Business_Rule__c IN: businessRuleIds]){
            serviceApprover.Active__c = false;
            serviceApproverLst.add(serviceApprover);
        }
        try{
            if(serviceApproverLst != null && !serviceApproverLst.isEmpty()){
                Database.update(serviceApproverLst, false);
            }
        } Catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }

    /*   
    * This method is used to remove the end date field while cloning Business Notification or Required Information
    * @Jira Id : BRE-310
    * @param :
    */
    public static void removeEndDateWhileCloning(List<Business_Rule__c> newBRLst){

        Id businessNotificationRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
        Id requiredInformationRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
        for (Business_Rule__c business : newBRLst) {
            if(business.isClone() && (business.RecordTypeId == businessNotificationRecordTypeId || business.RecordTypeId == requiredInformationRecordTypeId)) {
                if(business.End_Date__c != null){
                    business.End_Date__c = null;   
                }
                if(String.isNotblank(business.Active_Inactive_Reason__c)){
                    business.Active_Inactive_Reason__c = '';   
                }
            }
        }  
        
    }

    /*   
    * This method is used to check the user is having permission to create or edit the business rule with record type "Business Notification"
    * @Jira Id : SDT-30949
    * @param :
    */
    public static void brNotificationRuleUserCheck(List<Business_Rule__c > newBRLst){
        Id businessNotificationRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
        Boolean hasCustomPermission = FeatureManagement.checkPermission('BR_Notification');
        // Get the current user's profile
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        
        for (Business_Rule__c business : newBRLst) {
            if (business.RecordTypeId == businessNotificationRecordTypeId) {
                // Check if the user is a system admin
                if ((userProfile.Name != Constant_Util.SYSTEM_ADMINISTRATOR)) {
                    //check for custom permission of user
                    if(!hasCustomPermission){
                    // Get the custom label error message
                    String errorMessage = System.Label.BrNotificationError;
                    // Throw a custom exception with the error message
                    business.addError(errorMessage);
                    }
                }
            }
        }
    }

   /*   
    * This method is used to uncheck autoEmail when No approver required is true
    * @Jira Id : SDT-31225
    * @param :
    */
    public static void autoEmailCheck(List<Business_Rule__c > newBRLst){
        Id approverRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
          List<Business_Rule__c> brupdatedList = new List<Business_Rule__c>();
            for (Business_Rule__c business : newBRLst) {
                if((business.RecordTypeId == approverRecordTypeId)&&(business.No_Approval_Required__c)&&(business.Is_Auto_Email__c)) {
                    business.Is_Auto_Email__c = false;
                }
               
              
            }  
            
        }

}
