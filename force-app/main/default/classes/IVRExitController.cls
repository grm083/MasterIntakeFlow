/*************************************************************
@Name: IVRExitController
@Author: DineshKumar S
@CreateDate: 10/28/2019
@Description: SDT-8961 : Used to show the IVR Attached Data.
              SDT-20721 : Added null check in the request data
*************************************************************/
public with sharing class IVRExitController {
    @AuraEnabled
    public static Screenpop getIvrDetails(string caseId){
        /*Start - SDT- 20721 Added the Lines - Arvind Kumar */
        String VALUE_NULL = 'Null';
        String EMPTY_STRING = '';
        /*End - SDT- 20721 */
        Screenpop result = null;
        case ca = null;
        WorkOrder wo = null;
        try{
            Id recordId = Id.Valueof(caseId);
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            string varFilter = 'null';
            
            if(sObjName == 'SBQQ__Quote__c'){
                SBQQ__Quote__c qoute = [select id,SBQQ__Opportunity2__r.Case__r.Last_Customer_Interaction_ID__c from SBQQ__Quote__c where id =:recordId ];
                varFilter = qoute.SBQQ__Opportunity2__r.Case__r.Last_Customer_Interaction_ID__c;   
            }
            if(Constant_Util.KEYWORD_CASE.equals(sObjName)){
                ca = [Select Id,Reference_Number__c,Last_Customer_Interaction_ID__c,Case_Type__c from case where id =: caseId Limit 1];
                varFilter = ca.Last_Customer_Interaction_ID__c;            
            }else if(Constant_Util.WorkOrder.equals(sObjName)){
                wo = [Select Id,Acorn_WorkOrder_Number__c,Customer_Interaction_ID__c from WorkOrder where Id =: caseId Limit 1];
                varFilter = wo.Customer_Interaction_ID__c;            
            }
            // Get partition
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(Constant_Util.IVREXIT);
            // Add cache value to the partition
            If(!String.isBlank(varFilter) && sessionPart.contains(varFilter)){
                string session = (String) sessionPart.get(varFilter);
                result = (Screenpop)System.JSON.deserialize(session, Screenpop.class);
                if(!String.isBlank(result.AcctLocationId)){
                    for(Account loc : [Select id,Name from Account where Id =: result.AcctLocationId Limit 1]){
                        result.AcctLocationId = loc.Name;
                    }
                }
                if(!String.isBlank(result.ContactId)){
                    for(Contact con : [Select id,Name from Contact where Id =: result.ContactId Limit 1]){
                        result.ContactId = con.Name;
                    }
                }
                /*Start - SDT- 20721 Added the Lines - Arvind Kumar */
                result.ivrSpokenName = result.ivrSpokenName == EMPTY_STRING || result.ivrSpokenName == VALUE_NULL ? EMPTY_STRING : result.ivrSpokenName;
                result.ivrSpokenIntent = result.ivrSpokenIntent == EMPTY_STRING || result.ivrSpokenIntent == VALUE_NULL ? EMPTY_STRING : result.ivrSpokenIntent;
                result.ivrSpokenLoc = result.ivrSpokenLoc == EMPTY_STRING || result.ivrSpokenLoc == VALUE_NULL ? EMPTY_STRING : result.ivrSpokenLoc;
                result.ivrani = result.ivrani == EMPTY_STRING || result.ivrani == VALUE_NULL ? EMPTY_STRING : result.ivrani;
                result.ivrSpokenRefNum = result.ivrSpokenRefNum == EMPTY_STRING || result.ivrSpokenRefNum == VALUE_NULL ? EMPTY_STRING : result.ivrSpokenRefNum;
                result.ivrLOB = result.ivrLOB == EMPTY_STRING || result.ivrLOB == VALUE_NULL ? EMPTY_STRING : result.ivrLOB;
                /*End - SDT- 20721 */
            }
        }catch(Exception ex){
            system.debug('Exception while inserting case:::'+ex.getStackTraceString());
        }system.debug('result::: ' + result);
        return result;
    }
    //Wrapper Class
    public inherited sharing class Screenpop {
        @AuraEnabled public String MediaType { get; set; }
        @AuraEnabled public String GenesysId { get; set; }
        @AuraEnabled public String Intent { get; set; }
        @AuraEnabled public String CaseRefNo { get; set; }
        @AuraEnabled public String AcctId { get; set; }
        @AuraEnabled public String AcctLocationId { get; set; }
        @AuraEnabled public String ContactId { get; set; }
        @AuraEnabled public String SFDCRecordId { get; set; } 
        @AuraEnabled public String ivrQueue { get;set; }
        @AuraEnabled public String ivrLang { get;set; }
        @AuraEnabled public String ivrLOB { get;set; }
        @AuraEnabled public String ivrexitpoint { get;set; }
        @AuraEnabled public String ivrsseligible { get;set; }
        @AuraEnabled public String ivrsseligiblestatus { get;set; }
        @AuraEnabled public String ivrsseligiblepickup { get;set; }
        @AuraEnabled public String ivrdnis { get;set; }
        @AuraEnabled public String ivrani { get;set; }
        @AuraEnabled public String ivrWorkOrder { get;set; }
        @AuraEnabled public String ivrVendor { get;set; }
        @AuraEnabled public String ivrR4C { get;set; }
        @AuraEnabled public String ivrContainerId { get;set; }
        // Added below properties as part of SDT-17701
        @AuraEnabled public String ivrSpokenName { get;set; }
        @AuraEnabled public String ivrIntentName { get;set; }
        @AuraEnabled public String ivrSpokenLoc { get;set; }
        @AuraEnabled public String ivrSpokenRefNum { get;set; }
        //Added as SDT-18313
        @AuraEnabled public String ivrSpokenIntent { get;set; }

        //SDT-41550 New fields for IVR New service.
        @AuraEnabled public string NSEqCode {get;set;}
        @AuraEnabled public string NSMatType {get;set;}
        @AuraEnabled public string NSEqSizeCode {get;set;}
        @AuraEnabled public string NSDeliveryDate {get;set;}
        @AuraEnabled public string NSRemovalDate {get;set;}
        @AuraEnabled public string NSEARDates {get;set;}
        @AuraEnabled public string NSPlacementInts {get;set;}
        @AuraEnabled public string NSSiteContName {get;set;}
        @AuraEnabled public string NSSiteContPhNum {get;set;}
        @AuraEnabled public string NSReason {get;set;}
        @AuraEnabled public string NSQuoteOnly {get;set;}
        @AuraEnabled public string NSQuoteContName {get;set;}
        @AuraEnabled public string NSQuoteContPhNum {get;set;}
        @AuraEnabled public string NSCompanyCategory {get;set;}

       
    }
}