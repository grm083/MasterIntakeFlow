public with sharing class CreateCaseHistory 
{
    /*
     * This method is used to create Case_History_Tracker__c records when the case related records are created.
	* @owner : Saranya Gali
	* @param : Map<Id,Sobject>
	*/
    public static void createHistoryRecordOnRecordCreate(Map<Id,SObject> objMap)
    {
        List<Case_History_Tracker__c> trackers = new List<Case_History_Tracker__c>();
        ContentDocumentLink docLink = new ContentDocumentLink();
        System.debug('in createHistoryRecordOnRecordCreate --->');
        String sObjNameStr;
        for(Id objId : objMap.keySet())
        {
            String prefix = ((String)objId).left(3);
            if(prefix == Constant_Util.CASE_COMMENT_TOKEN){
            	sObjNameStr = Constant_Util.CASE_COMMENT_NAME;
            }
            else{
                sObjNameStr = objId.getSObjectType().getDescribe().getName();
            }
            String changedObjLabel = Schema.getGlobalDescribe().get(sObjNameStr).getDescribe().getLabel();
            SObject thisObjRec = objMap.get(objId); // sobject record
            Case_History_Tracker__c tracker = new Case_History_Tracker__c();
            tracker.Description__c = Constant_Util.STATUS_NEW+Constant_Util.EMPTY_SPACE;
            if(Constant_Util.OBJECT_TASK.equals(sObjNameStr)) // to track tasks
            {
                tracker.Action__c = Constant_Util.CREATED;
                tracker.Case__c = (Id)thisObjRec.get(Constant_Util.WHAT_ID);
                tracker.Name__c = (String)thisObjRec.get(Constant_Util.SUBJECT);
            }
            if(Constant_Util.WorkOrder.equals(sObjNameStr)) //to track wo
            {
                tracker.Action__c = Constant_Util.CREATED;
                tracker.Case__c = (Id)thisObjRec.get(Constant_Util.CASEID);
                tracker.Name__c = '#'+(String)thisObjRec.get(Constant_Util.WONUMBER);
            }
            if(Constant_Util.CASE_COMMENT_NAME.equals(sObjNameStr)) // to track casecomments
            {
                tracker.Action__c = Constant_Util.ADDED;
                tracker.Case__c = (Id)thisObjRec.get(Constant_Util.PARENTID);
                tracker.Name__c = (String)thisObjRec.get(Constant_Util.COMMENTBODY);
            }
            if(Constant_Util.OBJECT_COMMENT.equals(sObjNameStr)) // to track casecomments
            {
                tracker.Action__c = Constant_Util.ADDED;
                tracker.Case__c = (Id)thisObjRec.get(Constant_Util.CASE_C);
                tracker.Name__c = (String)thisObjRec.get(Constant_Util.OBJECT_COMMENT);
            }
            if(Constant_Util.OBJECT_EMAILMESSAGE.equals(sObjNameStr)) // totrack emails
            {
                if((Boolean)thisObjRec.get(Constant_Util.INCOMING)){
                    tracker.Action__c = Constant_Util.RECEIVED;
                }else{
                    tracker.Action__c = Constant_Util.SENT;
                }
                tracker.Case__c = (Id)thisObjRec.get(Constant_Util.RELATED_TO_ID);
                tracker.Name__c = (String)thisObjRec.get(Constant_Util.SUBJECT);
            }
            if(Constant_Util.OBJECT_CDL.equals(sObjNameStr)) // totrack attachments(content document link)
            {
                docLink = (ContentDocumentLink)thisObjRec;
                changedObjLabel = changedObjLabel.substringBetween(' ',' ');
                tracker.Action__c = Constant_Util.ADDED;
                tracker.Case__c = (Id)docLink.LinkedEntityId;
                tracker.Name__c = (String)docLink.ContentDocument.Title;
            }
            if(Constant_Util.OBJECT_APPROVALLOG.equals(sObjNameStr)) // to track aprovallog
            {
                tracker.Action__c = Constant_Util.CREATED;
                tracker.Case__c = (Id)thisObjRec.get(Constant_Util.CASEID_C);
                tracker.Name__c = (String)thisObjRec.get(Constant_Util.NAME);
            }
            if(Constant_Util.KEYWORD_CASE.equals(sObjNameStr)) //to track related cases
            {
                if((Id)thisObjRec.get(Constant_Util.PARENTID) !=null){
                    tracker.Action__c = Constant_Util.CREATED;
                    tracker.Case__c = (Id)thisObjRec.get(Constant_Util.PARENTID);
                    tracker.Name__c = '#'+(String)thisObjRec.get(Constant_Util.CASENUMBER);
                    tracker.Description__c += Constant_Util.RELATED;
                }
            }
            tracker.Description__c += changedObjLabel+Constant_Util.EMPTY_SPACE;
            tracker.Description__c += tracker.Action__c;
            if(sObjNameStr == Constant_Util.OBJECT_EMAILMESSAGE){
                tracker.Description__c += Constant_Util.FROM_ETA+Constant_Util.EMPTY_SPACE+thisObjRec.get('FromAddress')+Constant_Util.EMPTY_SPACE+Constant_Util.TO_ETA+Constant_Util.EMPTY_SPACE+thisObjRec.get('ToAddress');
            }
            tracker.Related_Object__c = sObjNameStr;
            if(sObjNameStr == Constant_Util.OBJECT_CDL){
                tracker.Related_Record_Id__c =  (String)docLink.ContentDocumentId;
                tracker.User__c = (String)docLink.ContentDocument.CreatedById;
                tracker.Time_Stamp__c = (DateTime)docLink.ContentDocument.CreatedDate;
            }
            else{
                tracker.Related_Record_Id__c =  (String)thisObjRec.get('Id');
                tracker.User__c = (String)thisObjRec.get(Constant_Util.CREATEDBYID);
                tracker.Time_Stamp__c = (DateTime)thisObjRec.get(Constant_Util.CREATEDDATE);
            }
            if(tracker.Name__c != null && tracker.Name__c.length() > Constant_Util.MAX_LENGTH){
                tracker.Name__c = tracker.Name__c.substring(0, Constant_Util.MAX_LENGTH);
            }
            trackers.add(tracker);
            
        }
        try{
            Boolean isRecurrsiveactive = false;
            if(TriggerDispatcher.skipTriggerExecutionMap==null || TriggerDispatcher.skipTriggerExecutionMap.get(Case.sobjectType.getDescribe().getName())==null
       		|| !TriggerDispatcher.skipTriggerExecutionMap.get(Case.sobjectType.getDescribe().getName())){//!RecurrsiveTriggerHandler.isSkipcaseTrigger
                //RecurrsiveTriggerHandler.isSkipcaseTrigger = True;
                TriggerDispatcher.skipTriggerExecutionMap.put(Case.sobjectType.getDescribe().getName(),true);
                isRecurrsiveactive = true;
            }
            Database.insert(Trackers);
            if(isRecurrsiveactive){
            	//RecurrsiveTriggerHandler.isSkipcaseTrigger = False;
                TriggerDispatcher.skipTriggerExecutionMap.put(Case.sobjectType.getDescribe().getName(),false);
            }
        }catch(Exception ex){
            system.debug(ex.getStackTraceString());
        }
        
    }
    
    
    /*
     * This method is used to create Case_History_Tracker__c records when the case related records are updated.
	* @owner : Saranya Gali
	* @param : Map<Id,Sobject>, Map<Id,Sobject>
	*/
    public static void createHistoryRecord(Map<Id,SObject> objMap, Map<Id,SObject> oldObjMap)
    {
        Map <String, List<String>> objFieldMap = new Map <String, List<String>>();
        for(Case_Hisory_Tracking__mdt rcrds : [Select MasterLabel,Fields__c from Case_Hisory_Tracking__mdt]){
            List<String> fieldNames = rcrds.Fields__c.split(',');
            objFieldMap.put(rcrds.MasterLabel,fieldNames);
        }
        
        List<Case_History_Tracker__c> trackers = new List<Case_History_Tracker__c>();
        List<Id> singleId = new List<Id>(objMap.keySet());
        String sObjNameStr = singleId[0].getSObjectType().getDescribe().getName();
        SObjectType objToken = Schema.getGlobalDescribe().get(sObjNameStr);
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap(); 
        for(Id objId : objMap.keySet())
        {
            SObject thisObjRec = objMap.get(objId);
            SObject thisObjOldRec = oldObjMap.get(objId);
            
            for(String fName : objFieldMap.get(sObjNameStr))
            {
                if(thisObjRec.get(fields.get(fName)) != thisObjOldRec.get(fields.get(fName)))
                {
                    Case_History_Tracker__c tracker = new Case_History_Tracker__c();
                    String changedRecName ='';
                    tracker.Related_Record_Id__c =  (String)thisObjRec.get('Id');     
                    tracker.Changed_Field__c = fields.get(fName).getDescribe().getLabel();
                    String changedFieldName = fields.get(fName).getDescribe().getLabel();
                    tracker.Related_Object__c = objId.getSObjectType().getDescribe().getName();
                    String changedObjName = objId.getSObjectType().getDescribe().getLabel();
                    tracker.Old_Value__c =  (String)thisObjOldRec.get(fields.get(fName)); 
                    String oldValue =  (String)thisObjOldRec.get(fields.get(fName));
                    tracker.New_Value__c =  (String)thisObjRec.get(fields.get(fName)); 
                    String newValue =  (String)thisObjRec.get(fields.get(fName)); 
                    tracker.User__c = (String)thisObjRec.get(Constant_Util.LASTMODIFIEDID);
                    tracker.Time_Stamp__c = (DateTime)thisObjRec.get(Constant_Util.LASTMODIFIEDDATE);
                    tracker.Action__c = Constant_Util.UPDATED;
                    tracker.Description__c = changedFieldName+Constant_Util.EMPTY_SPACE;
                    tracker.Description__c += Constant_Util.CHANGED+Constant_Util.EMPTY_SPACE;
                    tracker.Description__c += Constant_Util.FROM_ETA+Constant_Util.EMPTY_SPACE+oldValue+Constant_Util.EMPTY_SPACE;
                    tracker.Description__c += Constant_Util.TO_ETA+Constant_Util.EMPTY_SPACE+newValue+Constant_Util.EMPTY_SPACE+'.';
                    
                    if(Constant_Util.OBJECT_TASK.equalsIgnoreCase(sObjNameStr))
                    {
                        tracker.Case__c = (Id)thisObjRec.get(Constant_Util.WHAT_ID);
                        tracker.Name__c = (String)thisObjRec.get(Constant_Util.SUBJECT);
                    }
                    if(Constant_Util.WorkOrder.equalsIgnoreCase(sObjNameStr))
                    {
                        tracker.Case__c = (Id)thisObjRec.get(Constant_Util.CASEID);
                        tracker.Name__c = '#'+(String)thisObjRec.get(Constant_Util.WONUMBER);
                    }
                    if(Constant_Util.OBJECT_APPROVALLOG.equalsIgnoreCase(sObjNameStr))
                    {
                        tracker.Case__c = (Id)thisObjRec.get(Constant_Util.CASEID_C);
                        tracker.Name__c = (String)thisObjRec.get(Constant_Util.NAME);
                    }
                    if(Constant_Util.KEYWORD_CASE.equalsIgnoreCase(sObjNameStr))
                    {
                        tracker.Case__c = (Id)thisObjRec.get('Id');
                        tracker.Name__c = '#'+(String)thisObjRec.get(Constant_Util.CASENUMBER);
                    }
                    if(tracker.Name__c != null && tracker.Name__c.length() > Constant_Util.MAX_LENGTH){
                        tracker.Name__c = tracker.Name__c.substring(0, Constant_Util.MAX_LENGTH);
                    }
                    trackers.add(tracker) ;   
                }
            }
        }
        try{
            Boolean isRecurrsiveactive = false;
            if(TriggerDispatcher.skipTriggerExecutionMap==null || TriggerDispatcher.skipTriggerExecutionMap.get(Case.sobjectType.getDescribe().getName())==null
       		|| !TriggerDispatcher.skipTriggerExecutionMap.get(Case.sobjectType.getDescribe().getName())){//!RecurrsiveTriggerHandler.isSkipcaseTrigger
                //RecurrsiveTriggerHandler.isSkipcaseTrigger = True;
                TriggerDispatcher.skipTriggerExecutionMap.put(Case.sobjectType.getDescribe().getName(),true);
                isRecurrsiveactive = true;
            }
            Database.insert(Trackers);
            if(isRecurrsiveactive){
            	//RecurrsiveTriggerHandler.isSkipcaseTrigger = False;
                TriggerDispatcher.skipTriggerExecutionMap.put(Case.sobjectType.getDescribe().getName(),false);
            }
        }catch(Exception ex){
            system.debug(ex.getStackTraceString());
        }
        
    }
    
    /*
    * This method is used to return create Case_History_Tracker__c records to the custom CaseActivityTimeline lightning component.
	* @owner : Saranya Gali
	* @param : Map<Id,Sobject>, Map<Id,Sobject>
	*/
    @AuraEnabled
    public static List<Case_History_Tracker__c> fetchHistoryRecords(Id caseId){
        try{
            List<Case_History_Tracker__c> history = new List<Case_History_Tracker__c>();
            for(Case_History_Tracker__c activity : [SELECT Name__c,Description__c,User__c,User__r.Name,Time_Stamp__c,View__c,Related_Record_Id__c,Related_Object__c FROM Case_History_Tracker__c WHERE Case__c =: caseId ORDER BY Time_Stamp__c DESC]){
                history.add(activity);
            }
            return history;
        }catch(Exception ex){
            return null;
        }
        
    }
    
     /*
    * This method is used to return csr assign tasks  to the custom CaseTaskAssignmentPopup lightning component.
	* @owner : Saqib Qamar - WM
	* @story : SDT-7112
	* @param : Case Id
	*/
    
    @AuraEnabled
    public static List<task> getRelatedtask(string caseId){
        return [SELECT Id,Process__c,Outcome__c, Owner.Name, CreatedDate, WhatId,WhoId,Status, Subject, Description__c
						FROM Task where whatid= : caseId and OwnerId= :UserInfo.getUserID() and Status ='Open' and Process__c !='' order by CreatedDate desc];        
    } 
}