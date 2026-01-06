/*************************************************************
@Name: BatchToPurgeEmailMessage
@Author: DineshKumar S
@CreateDate: 10/16/2019
@Description: SDT-8622 : Used to delete the Email Alias.
*************************************************************/
public class EmailAliasProcessBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    public Map<Id,EmailMessage> updateEMessagemap = new map<Id,EmailMessage>();    
    public Integer filteringDate = null;
    /*@MethodName Start - */
    public Database.QueryLocator start (Database.BatchableContext bc) {
        if(filteringDate == null){
            filteringDate = 4;
        }
        String query = 'SELECT ID, RelatedToId, ParentId, Incoming, Message_ID__c, To_Be_Processed__c FROM EmailMessage  WHERE Incoming=true AND To_Be_Processed__c = true AND CreatedDate >= LAST_N_DAYS:' + filteringDate  + ' ORDER BY parent.CaseNumber ASC'  ;
        return Database.getQueryLocator(query);
    }
    /*method used to purge Duplicate EmailMessage*/
    public void execute (Database.BatchableContext bc, List<EmailMessage> scope){
        
        set<String> messageIdset = new set<String>();
        set<Id> caseIdset = new set<Id>();
        List<Id> deleteCasehistoryIds = new List<Id>();
        List<Id> deleteEMessagelistIds = new List<Id>();
        List<EmailMessage> deleteEMessagelist = new List<EmailMessage>();
        List<Case> deleteCaselst = new List<Case>();
        EmailMessage emessage = null;
        set<String> processedEmailIdSet = new set<String>();
        Set<Id> processedCaseIdSet = new Set<Id>();        
        updateEMessagemap = new map<Id,EmailMessage>();         
        List <String> msgIdProcessList = new List <String>();
        //Delete duplicate records from CaseHistory component
        List<Case_History_Tracker__c> casehistIdsfordelete = new List<Case_History_Tracker__c>();
		map<Id,Case_History_Tracker__c> mapcasehistory = new map<Id,Case_History_Tracker__c>();
        List<EmailMessage> updateEmailMessagesList = new List<EmailMessage>();
        try{
            for(EmailMessage emsgb : scope) {
                if(!string.isBlank(emsgb.Message_ID__c)){
                    msgIdProcessList.add(emsgb.Message_ID__c);
                }
            }
            
            for(EmailMessage emsg : [Select Id,MarkToDelete__c,Message_ID__c, ParentId from EmailMessage where Message_ID__c IN : msgIdProcessList and To_Be_Processed__c = false]){
                processedEmailIdSet.add(emsg.Message_ID__c);
                processedCaseIdSet.add(emsg.ParentId);
            }       
            
            for (EmailMessage emObj : scope) {
                emessage = new EmailMessage();
                if(!processedEmailIdSet.isEmpty() && processedEmailIdSet.contains(emObj.Message_ID__c)){
                    deleteEMessagelist.add(emObj);
                    deleteEMessagelistIds.add(emObj.Id);   
                    if(emObj.ParentId !=null && !processedCaseIdSet.contains(emObj.ParentId) && !caseIdset.contains(emObj.ParentId)){
                            deleteCaselst.add(new Case(Id = emObj.ParentId));
                    }
                }else if(!messageIdset.IsEmpty() && messageIdset.contains(emObj.Message_ID__c)){                 
                    deleteEMessagelist.add(emObj);
                    deleteEMessagelistIds.add(emObj.Id);
                    if(emObj.ParentId !=null && !processedCaseIdSet.contains(emObj.ParentId) && !caseIdset.contains(emObj.ParentId)){
                            deleteCaselst.add(new Case(Id = emObj.ParentId));
                    }                
                }else {
                    messageIdset.add(emObj.Message_ID__c);
                    caseIdset.add(emObj.ParentId);
                    emessage = emObj;
                    emessage.To_Be_Processed__c = false;
                    updateEMessagemap.put(emObj.ParentId,emessage);
                    updateEmailMessagesList.add(emessage);
                }
            } 
            for(Case_History_Tracker__c cht : [Select id,Related_Record_Id__c from Case_History_Tracker__c where Related_Record_Id__c in:deleteEMessagelistIds])	{
                mapcasehistory.put(cht.Related_Record_Id__c,cht);
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        
        //Delete Email Message
        if(!deleteEMessagelist.IsEmpty() && deleteEMessagelist.size() > 0){
            List<Database.DeleteResult> delemResults = Database.Delete(deleteEMessagelist,false);
            UTIL_LoggingService.logDmlResults(null,delemResults,deleteEMessagelist,UTIL_ErrorConstants.ERROR_APPLICATION,Constant_Util.EMAILALIAS,Constant_Util.EXECUTE,null,LoggingLevel.ERROR);
            // Iterate through each returned result
            for(Database.DeleteResult dr : delemResults) {
                if (dr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    casehistIdsfordelete.add(mapcasehistory.get(dr.getId()));  
                }						
            }
            if(casehistIdsfordelete!=null && casehistIdsfordelete.size()>0 && casehistIdsfordelete[0]!=null ){
                List<Database.DeleteResult> delResults = Database.Delete(casehistIdsfordelete,false);
                UTIL_LoggingService.logDmlResults(null,delResults,casehistIdsfordelete,UTIL_ErrorConstants.ERROR_APPLICATION,Constant_Util.EMAILALIAS,Constant_Util.EXECUTE,Constant_Util.EMPTY_STRING,LoggingLevel.ERROR);
            }
        }
        
        if(deleteCaselst != null && deleteCaselst.size() > 0){
            List<Database.DeleteResult> delcaseResults = Database.Delete(deleteCaselst,false);
            UTIL_LoggingService.logDmlResults(null,delcaseResults,deleteCaselst,UTIL_ErrorConstants.ERROR_APPLICATION,Constant_Util.EMAILALIAS,Constant_Util.EXECUTE,Constant_Util.EMPTY_STRING,LoggingLevel.ERROR);
        }
        if(!updateEMessagemap.isEmpty() && updateEMessagemap.size() > 0){
            Id tskRecId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            set<Id> openwhatIdset = new set<Id>();
            for(Task tsk : [Select Id,WhatId,Status from Task where RecordTypeId =:tskRecId and whatId IN:updateEMessagemap.keySet() Limit 49999]){
                if(updateEMessagemap.containsKey(tsk.WhatId) && Constant_Util.COMPLETED.equals(tsk.Status) && (openwhatIdset.isEmpty() || (!openwhatIdset.isEmpty() && !openwhatIdset.contains(tsk.WhatId)))){
                    updateEMessagemap.get(tsk.WhatId).Bypass_Genesys_Task__c = true;
                }else if(updateEMessagemap.containsKey(tsk.WhatId) && Constant_Util.OPEN.equals(tsk.Status)){
                    updateEMessagemap.get(tsk.WhatId).Bypass_Genesys_Task__c = false;
                    openwhatIdset.add(tsk.WhatId);
                }
            }
            //List<Database.SaveResult> svResults = Database.update(updateEMessagemap.values(),false);
            List<Database.SaveResult> svResults = Database.update(updateEmailMessagesList,false);
            UTIL_LoggingService.logDmlResults(svResults,null,updateEmailMessagesList,UTIL_ErrorConstants.ERROR_APPLICATION,Constant_Util.EMAILALIAS,Constant_Util.EXECUTE,Constant_Util.EMPTY_STRING,LoggingLevel.ERROR);
        }
    }
    /*@MethodName finish - **/ 
    public void finish(Database.BatchableContext batchVariable) {

    } 
}