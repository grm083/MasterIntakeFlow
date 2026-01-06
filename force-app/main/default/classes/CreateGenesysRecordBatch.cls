/*************************************************************
@Name: CreateGenesysRecordBatch
@Author: Accenture
@CreateDate: 27/2/2020
**************************************************************/
public class CreateGenesysRecordBatch implements Database.Batchable<sObject>,Database.Stateful{
    private final static String cStatus = 'Closed';
    private final static Boolean isOpen = true;
    Complete_Task__c ct = Complete_Task__c.getValues('Complete_Genesys_Routing');
    private DateTime dateCheck = ct.Recent_Run__c != null ? ct.Recent_Run__c : system.now();
    public String qry = 'select id,ToAddress,FromAddress,ParentId from EmailMessage where Parent.LastModifiedDate>=:dateCheck and Parent.Status =:cStatus limit 49999';
    
    public Boolean isError = false;
    public Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator scope = Database.getQueryLocator(qry);
        ct.Recent_Run__c = system.now();
        return scope;
    }
    
    public void execute(Database.BatchableContext BC, List<EmailMessage> emailMessageList){
        Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
        List<Genesys_Routing__c> GRtoInsert = new List<Genesys_Routing__c>();
        Map<String,List<Id>> mapList=new Map<String,List<Id>>();
        set<Id> caseIds = new set<Id>();
        set<Id> emailMsgIds = new set<Id>();
        List<EmailMessage> updateCaselst = new List<EmailMessage>();
        List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
        set<Id> cancelGRRec = new set<Id>();
        set<Id> newGRRec = new set<Id>();
        Map<Id,Case>  caseMap= new Map<Id,Case>();
        Map<Id,EmailMessage> emailRecordMap = new Map<Id,EmailMessage>();
        Map<id,Case> caseEmailMap=new Map<id,Case>();
        for(EmailMessage e  : emailMessageList) {
				emailMsgIds.add(e.id);
           		caseIds.add(e.ParentId);
            
        }
        for(Case c : [select id,case_sub_type__c,location__c,Subject,Last_Agent_ID__c,Client__r.Customer_Code__c,Location__r.tz__Timezone__c,Asset.Project_Code__c,Asset.Active__c,RecordType.Name,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Case_Reason__c,Supplier__r.Name,Supplier__r.Vendor_ID__c,Reference_Number__c,Case_Type__c,Location__r.Location_Code__c,Client__r.Primary_Segment__c,CaseNumber from case where id in :caseIds]){
            caseMap.put(c.Id,c);
        }
        for(Genesys_Routing__c gr: [select id,Action__c,SFDCObjRecordID__c, Action_Reason__c, SFDCTaskDescription__c from Genesys_Routing__c where SFDCObjRecordID__c in :emailMsgIds and RecordTypeId=:Schema.SObjectType.Genesys_Routing__c.getRecordTypeInfosByName().get('Email to Case').getRecordTypeId()]){
            if(gr.action__c=='Cancel'){
                cancelGRRec.add(gr.SFDCObjRecordID__c);
            }
            else if(gr.action__c=='New'){
                newGRRec.add(gr.SFDCObjRecordID__c);
            }
            else{
                
            }
        }
        //This logic of creating GR records is being copied from the CaseTriggerHelper which is existing code.
        if(emailMessageList!=null){
            for(EmailMessage rec : emailMessageList){
                if(newGRRec!=null && !newGRRec.isEmpty() && newGRRec.contains(rec.Id) && (cancelGRRec==null || cancelGRRec.isEmpty() || (!cancelGRRec.isEmpty() && !cancelGRRec.contains(rec.Id)))){
					Case objCase = caseMap.get(rec.ParentId);
                    Genesys_Routing__c gr = new Genesys_Routing__c();
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
                    gr.SFDCObjRecordID__c = rec.Id;
                    gr.SFDCObjType__c =  Constant_Util.OBJECT_EMAILMESSAGE;
                    gr.SFDCParentVendorAcctNo__c = objCase.Supplier__r.Parent.Vendor_ID__c;
                    gr.SFDCParentVendorName__c = objCase.Supplier__r.Parent.Name;
                    gr.SFDCRecordType__c = objCase.RecordType.Name;
                    gr.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
                    gr.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
                    gr.EmailSubject__c = objCase.Subject;
                    gr.SFDCServiceFlag__c = string.isNotBlank(String.valueof(objCase.Asset.Project_Code__c)) && objCase.Asset.Active__c ? Constant_Util.PS : Constant_Util.CS;    
                    gr.SFDCTaskCaseId__c = objCase.Id; 
                    gr.Integrate_with_Genesys_Routing__c = true; 
                    gr.Action__c = Constant_Util.CANCEL; 
                    gr.Action_Reason__c = Constant_Util.COMPLETED;
                    gr.EmailTo__c = rec.ToAddress + '';
                    gr.EmailFrom__c = rec.FromAddress + '' ;
                    lstGR.add(gr);
                }
                
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
    public void finish(Database.BatchableContext BC){
        If(!isError){
            update ct;
        }
        if(!Test.isRunningTest()){
            String day = string.valueOf(system.now().day());
            String month = string.valueOf(system.now().month());
            String hour = string.valueOf(system.now().hour());
            String minute = string.valueOf(system.now().minute() + Integer.ValueOf(System.Label.Genesys_Record_Creation_Interval));
            String second = string.valueOf(system.now().second());
            String year = string.valueOf(system.now().year());
            String strJobName = 'CreateGenesysRecordBatch-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
			system.scheduleBatch(new CreateGenesysRecordBatch(), strJobName, Integer.ValueOf(System.Label.Genesys_Record_Creation_Interval), 200);
        }
    }
    
    
}