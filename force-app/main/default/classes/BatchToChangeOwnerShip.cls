/**********************************************************************************************
@Name: BatchToChangeOwnerShip
@Author: WM
@CreateDate: 08/04/2020
@Description: Daily Batch to change ownership of Case to Genesys Integration and Create GR 
***********************************************************************************************/

public class BatchToChangeOwnerShip implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    List<case> updateCaseLst = new List<case>();
    List<Case> lstCase = new List<Case>();
    Genesys_Routing__c gr;
    List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
    map<Id,EmailMessage> msgIdMap = new map<Id,EmailMessage>();
    Id accRecordTypeId = Schema.SobjectType.Account.getRecordTypeInfosByName().get(Constant_Util.SUPPLIER).getRecordTypeId();    
    string caseStatus = Constant_Util.STATUS_NEW;
    string caseOrigin = Constant_Util.ORIGIN_EMAIL;
    Id groupUser = [SELECT Id__c FROM Generic_Values__mdt where DeveloperName =: Constant_Util.GROUPUSER LIMIT 1].Id__c;
    Id genesysUserId = [SELECT Id__c FROM Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYS_USER LIMIT 1].Id__c;
    Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId(); 
    String objuser = null;
    String checkContactAccountType = 'false';
    DateTime dt = System.now();
    DateTime endDateTime = dt.addHours(-1);
    DateTime startDateTime = endDateTime-1; 
    
    Private static final String QUERY = 'SELECT Id,Origin,CreatedDate,Contact.Account.RecordtypeId,OwnerId,ContactId,status,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Last_Agent_ID__c,Location__c,Supplier__c,Client__c,Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,Supplier__r.Name,Supplier__r.Vendor_ID__c,Subject,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c FROM Case WHERE status =:caseStatus AND origin=:caseOrigin AND Ownerid =:groupUser AND createddate <: endDateTime AND createddate >: startDateTime  LIMIT 49999';
  
    /**@MethodName start
* Method to return the case records for Batch Processing.
**/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(QUERY);
    }
    
    /*@MethodName execute
* Method to change ownership to Genesys Integration 
**/
    public void execute(Database.BatchableContext batchVariable, List<case> caseLst) {
        try {
            if(caseLst.size()>0 && caseLst != null) {
                for(case c : caseLst) {
                    c.OwnerId = genesysUserId;
                    updateCaseLst.add(c);
                } 
                if(updateCaseLst.size()>0 && updateCaseLst != null) {
                    Database.update(updateCaseLst,false);
                }   
            }
            
        } catch(Exception e) {
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }   
    /*@MethodName finish
* Method to create Genesys Routing Records after Case Owner Updation
**/ 
    public void finish(Database.BatchableContext batchVariable) {
        
        for(EmailMessage objEM : [select Id,ToAddress, FromAddress, Subject,ParentId from EmailMessage where ParentId IN: updateCaseLst order by CreatedDate Limit 49999]){
            if(!msgIdMap.containsKey(objEM.ParentId)){
                msgIdMap.put(objEM.ParentId,objEM);
            }
        } 
        
        if(!updateCaseLst.IsEmpty()){
            for(Case objCase : updateCaseLst){
                if(objCase.Contact.Account.RecordtypeId == accRecordTypeId) 
                {
                    checkContactAccountType = 'true';
                }
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
                gr.SFDCObjName__c = Constant_Util.OBJECT_CASE;
                gr.SFDCObjRecordID__c = msgIdMap.get(objCase.Id) != null ?msgIdMap.get(objCase.Id).Id : objCase.Id;
                gr.SFDCObjType__c =  msgIdMap.get(objCase.Id) != null ? Constant_Util.OBJECT_EMAILMESSAGE :Constant_Util.OBJECT_CASE;
                gr.SFDCRecordType__c = objCase.RecordType.Name;
                gr.EmailSubject__c = objCase.Subject;
                gr.Integrate_with_Genesys_Routing__c = true;     
                gr.SFDCIsEmailNew__c = 'true';
                gr.SFDCIsAcctVendor__c = checkContactAccountType;
                gr.EmailTo__c = msgIdMap.get(objCase.Id) != null && msgIdMap.get(objCase.Id).ToAddress.Length() > 255 ? msgIdMap.get(objCase.Id).ToAddress.left(254) :(msgIdMap.get(objCase.Id)!=null ? msgIdMap.get(objCase.Id).ToAddress: '');    
                gr.EmailFrom__c = msgIdMap.get(objCase.Id) != null ? msgIdMap.get(objCase.Id).FromAddress : '' ;
                lstGR.add(gr); 
            }
        }
        try{
            if(lstGR != null && lstGR.size() >0){
                Database.SaveResult[] svRes = Database.insert(lstGR,false);
                UTIL_LoggingService.logDmlResults(svRes, null, lstGR, '', UTIL_ErrorConstants.BATCH_TO_CHANGE_OWNERSHIP,'',UTIL_ErrorConstants.BATCH_CLASS, LoggingLevel.ERROR);
            }
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }     
    } 
    /* @Method execute
* Method to schedule the batch
**/    
    public void execute(SchedulableContext ctx) {
        BatchToChangeOwnerShip jobApex = new BatchToChangeOwnerShip();
        Database.ExecuteBatch(jobApex);   
    }
}