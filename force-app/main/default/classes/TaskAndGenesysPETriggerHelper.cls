public class TaskAndGenesysPETriggerHelper {
    
    //public statis string NEW_STORE_EMAIL='newstoresteam@wm.com%';
    Public static string CREATED_FROM_PETRIGGER='Created from PE Trigger';
    Public static string UPDATE_QUOTE_STARTDATE='Update Quote start date';
    Public static string TASK_DESC='The start date for this quote is in the past. Please update the start date to a current or future date before proceeding with syncing to Acorn.';
    Public static string VENDOR_COMMIT_DATE_UPDATED='Vendor Commit Date has been updated to today or future date.';
    Public static string VENDOR_COMMIT_DATE_PAST='Quote Vendor Commit Date is in past.';
    Public static string SFDCTASK='SFDCTask';
    Public static string UPDATEDATE='UpdateDate';
    Public static string CANCELLATION_RECORD='Cancellation Record';
    public static void createTaskAndGenesysRecord(Id quoteId){
        // Perform asynchronous logic here
        Task taskForUser = new Task();
        Id TaskRecType = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.INTEGRATION_ERROR_TASK).getRecordTypeId();  
        Id genesysRoutingRec = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
        
        
        SBQQ__Quote__c relatedQuote= [SELECT id,LastModifiedBy.Alias,LastModifiedBy.UserName,Next_Action_Due_Date__c,LastModifiedById,case__c,Case_Number__c,SBQQ__ShippingName__c,STP__c,SBQQ__Status__c  from SBQQ__Quote__c where id=:quoteId];
        case relatedCase=[SELECT id,Client__r.Customer_Code__c,Case_Number__c,CaseNumber,Case_Type__c,Case_Reason__c, 
                          Client__r.Primary_Segment__c,Case_Sub_Type__c,Last_Agent_ID__c,
                          account.Vendor_ID__c, account.Primary_Segment__c,Location__r.tz__Timezone__c,
                          Supplier__r.Name,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,
                          Asset.Project_Code__c, Asset.Active__c,SLA_Service_Date_Time__c,
                          account.Acorn_Location_Code__c,account.tz__Timezone__c ,RecordType.Name
                          from case where caseNumber =:relatedQuote.Case_Number__c];
        User NewStoresUser = [SELECT Id,Alias FROM User WHERE  Email LIKE 'newstoresteam@wm.com%'LIMIT 1];
        
        list<task> taskList=[SELECT Id from Task where Sys_Created_From__c=:CREATED_FROM_PETRIGGER AND WhatID = :relatedQuote.Id and status=:Constant_Util.Case_Open_Status ];
        list<Genesys_Routing__c> genesysList= [SELECT Id from Genesys_Routing__c where Sys_Created_From__c=:CREATED_FROM_PETRIGGER AND  SFDCObjRecordID__c =: relatedQuote.Id  ];
        
        if(taskList.size() == 0 && genesysList.size() == 0 ){
        taskForUser.Subject= UPDATE_QUOTE_STARTDATE;
        taskForUser.Status=Constant_Util.Case_Open_Status ; 
        taskForUser.Priority=Constant_Util.PRIORITYNORMAL; 
        taskForUser.WhatID = relatedQuote.Id; 
        taskForUser.CreatedById= relatedQuote.LastModifiedById;
        taskForUser.ownerId = relatedQuote.LastModifiedById;
        taskForUser.Sys_Created_From__c=CREATED_FROM_PETRIGGER;
        if(relatedQuote.STP__c==true)
        {
            taskForUser.ownerId = NewStoresUser.Id;
        }
        taskForUser.Description = TASK_DESC;
        taskForUser.Description__c=VENDOR_COMMIT_DATE_PAST;
        taskForUser.Recordtypeid = TaskRecType;
        taskForUser.ActivityDate = system.Today();
        insert taskForUser;
        
        Genesys_Routing__c gr = new Genesys_Routing__c();
        gr.Action__c = Constant_Util.STR_NEW;
        gr.MediaType__c =Constant_Util.SFDCWORKFLOWTASK;
        gr.SFDCCaseNumber__c=relatedCase.CaseNumber;
        gr.SFDCCaseType__c=relatedCase.Case_Type__c;
        gr.CreatedById= relatedQuote.LastModifiedById;
        gr.SFDCCaseReason__c=relatedCase.Case_Reason__c;
        gr.SFDCAcctSegment__c=relatedCase.Client__r.Primary_Segment__c;
        gr.Action_Reason__c='';
        gr.LastAgentId__c=relatedQuote.LastModifiedBy.UserName.substringBefore(Constant_Util.AT_SYMBOL);
        gr.ownerId=relatedQuote.LastModifiedById;
        gr.Sys_Created_From__c=CREATED_FROM_PETRIGGER;
        if(relatedQuote.STP__c==true)
        {
            gr.ownerId = NewStoresUser.Id;
            gr.LastAgentId__c=relatedQuote.LastModifiedBy.UserName.substringBefore(Constant_Util.AT_SYMBOL);
        }
        gr.SFDCCaseRefNo__c=relatedCase.CaseNumber;
        gr.SFDCCaseSubCaseType__c= relatedCase.Case_Sub_Type__c;
        gr.SFDCTaskDescription__c=UPDATE_QUOTE_STARTDATE;
        gr.SFDCTaskDescCode__c=UPDATEDATE;  
        gr.SFDCObjRecordID__c = relatedQuote.Id;
        gr.RecordTypeId=genesysRoutingRec;
        gr.SFDCAcctID__c=relatedCase.account.Vendor_ID__c;
        gr.SFDCAcctLocation__c=relatedQuote.SBQQ__ShippingName__c;
        gr.SFDCAcctSegment__c=relatedCase.account.Primary_Segment__c;
        gr.SFDCAcctLocationTimeZone__c=relatedCase.Location__r.tz__Timezone__c;
        gr.Send_to_Genesys_Time__c = system.Datetime.now();
        gr.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
        gr.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
        gr.SFDCTaskCaseId__c=relatedCase.Id;
        gr.SFDCChildVendorName__c = relatedCase.Supplier__r.Name;    
        gr.SFDCFunction__c = Constant_Util.FOLLOW_UP;
        gr.SFDCObjName__c = Constant_Util.OBJECT_TASK;
        gr.SFDCParentVendorAcctNo__c = relatedCase.Supplier__r.Parent.Vendor_ID__c;
        gr.SFDCParentVendorName__c = relatedCase.Supplier__r.Parent.Name;
        gr.SFDCRecordType__c = relatedCase.RecordType.Name;
        gr.SFDCTaskDueDateTime__c = relatedQuote.Next_Action_Due_Date__c;
        HaulAwayService.genUserDetalsWrapper genUserDetalsWrapperRec = HaulAwayService.getIfGenesysEnabledUser(relatedQuote.LastModifiedById);
        
        Boolean isGenesysEnabledUser = genUserDetalsWrapperRec.isGenesysEnabledUser;
        String genServiceFlag  = genUserDetalsWrapperRec.genFlag;
        gr.SFDCServiceFlag__c = isGenesysEnabledUser== true  ? genServiceFlag :'';
        insert gr;
        
        }
    }
}
