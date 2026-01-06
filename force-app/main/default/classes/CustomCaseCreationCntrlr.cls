/**
* @author AccenturegetCaseRecordTypes
* @date 2/25/2019
* @description : Controller class for CaseCreationComponent lightning component 
**/
public with sharing class CustomCaseCreationCntrlr {
    
    
    /**
    * @author Accenture
    * @date 3/25/2019
    * @description : Wrapper class to return data to the CaseCreationComponent lightning component
    **/
    public  inherited sharing class ResultWrapper{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
    }
    
    /**
    * @author Accenture
    * @date 2/25/2019
    * @description : method to handle creation of case 
    **/
    //creation of case from case home page or from asset page
    @AuraEnabled
    public static ResultWrapper customCaseCreation(String recordtypeName,String recordId, String caseTypeData) {
        ResultWrapper wrap = new ResultWrapper();  
        Case caseObj = null;
        case mainCaseObj = null;
        String parentAccId = null;
        String assetRecordType = Constant_Util.SERVICE_HEADER;
        Boolean isCaseFeed = false;
        List<AcornController.caseComments> caseComment;
        String caseType = '';
        String caseSubType = '';
        String caseReason = '';
            

        try{
            if(caseTypeData != null) {
                Map<String, object> queryParams = (Map<String, object>) JSON.deserializeUntyped(caseTypeData);
                if( queryParams != null && queryParams.containsKey('Case_Type__c')  && String.isNotBlank( (String)queryParams.get('Case_Type__c') ) ){
                    caseType = (String)queryParams.get('Case_Type__c');
                }  
                if( queryParams != null && queryParams.containsKey('Case_Sub_Type__c') && String.isNotBlank( (String)queryParams.get('Case_Sub_Type__c') ) ){
                    caseSubType = (String)queryParams.get('Case_Sub_Type__c');
                }  
                if( queryParams != null && queryParams.containsKey('Case_Reason__c') && String.isNotBlank( (String)queryParams.get('Case_Reason__c') ) ){
                    caseReason = (String)queryParams.get('Case_Reason__c');
                }
            }
            
            Id recordtype;
            if(recordtypeName != 'Pickup' && recordtypeName != 'New Service' && recordtypeName != 'SNP' && recordtypeName != 'ETA' ){
                recordtype = CustomCaseCreationCntrlr.getRecTypeId(recordtypeName);
            }

            if(recordId != null && recordId.startsWith(Constant_Util.STARTWITH_02I)){
                Asset assObj = Database.query('select Id, rootAssetId,AccountId,Location__c, Name, product2.family, Duration__c, Occurrence_Type__c, product2.Equipment_Type__c from asset where id =:recordId and RecordType.DeveloperName = :assetRecordType');
                parentAccId = assObj.AccountId;
                Account acc = Database.query('Select ParentId from account where id = :parentAccId');
                caseObj = new Case(Status = Constant_Util.NEW_STATUS ,RecordTypeId = recordtype,Client__c =acc.ParentId,Location__c =assObj.Location__c,AssetId =assObj.RootAssetId);
                caseObj = populateCaseSubType(null, assObj , caseObj, recordtypeName, caseType, caseSubType, caseReason);
            }else if(recordId != null && recordId.startsWith(Constant_Util.STARTWITH_500)) {
                //system.debug('recordId--->'+ recordId);
                case retrievedCaseObj = [SELECT Id,Client__c, Location__c,Origin,ContactId, ParentId, Reference_Number__c, Last_Customer_Interaction_ID__c, 
                                         				Last_Customer_Interaction_Type__c, 
                                                        AssetId,Asset.Name,Asset.product2.family,Asset.Duration__c,
                                                        Asset.Occurrence_Type__c,Asset.product2.Equipment_Type__c,Case_Type__c,
                                                        Case_Sub_Type__c,Case_Reason__c,CPQ_New_Service__c,Case_Record_Type__c,
                                                        LOB__c, RecordTypeId FROM Case WHERE Id =:recordId];
                if(retrievedCaseObj.ParentId != null) {
                    case parentCaseObj = [SELECT Id,Client__c, Location__c, ContactId,Origin,ParentId, Reference_Number__c, Last_Customer_Interaction_ID__c,
                                                 		Last_Customer_Interaction_Type__c, AssetId,Asset.Name,Asset.product2.family,Asset.Duration__c,
                                                         Asset.Occurrence_Type__c,Asset.product2.Equipment_Type__c,Case_Type__c,
                                                         Case_Sub_Type__c,Case_Reason__c,CPQ_New_Service__c,Case_Record_Type__c,
                                                         LOB__c, RecordTypeId FROM Case WHERE Id =:retrievedCaseObj.Id limit 1];
                    caseObj = new Case(Status = Constant_Util.NEW_STATUS , RecordTypeId = recordtype, Client__c = parentCaseObj.Client__c, Location__c = parentCaseObj.Location__c,
                                                       Reference_Number__c = parentCaseObj.Reference_Number__c, ContactId = parentCaseObj.ContactId,Origin = parentCaseObj.Origin,
                                                       ParentId = recordId, Last_Customer_Interaction_ID__c = parentCaseObj.Last_Customer_Interaction_ID__c,
                                                       Last_Customer_Interaction_Type__c = parentCaseObj.Last_Customer_Interaction_Type__c);
                } else {
                    caseObj = new Case(Status = Constant_Util.NEW_STATUS , RecordTypeId = recordtype, Client__c = retrievedCaseObj.Client__c, Location__c = retrievedCaseObj.Location__c,
                                                       Reference_Number__c = retrievedCaseObj.Reference_Number__c, ContactId = retrievedCaseObj.ContactId,Origin = retrievedCaseObj.Origin, ParentId = recordId,
                                                       Last_Customer_Interaction_ID__c = retrievedCaseObj.Last_Customer_Interaction_ID__c,
                                                       Last_Customer_Interaction_Type__c = retrievedCaseObj.Last_Customer_Interaction_Type__c);
                }
				isCaseFeed = true;
                mainCaseObj = [SELECT id,RecordType.Name FROM Case WHERE Id =:recordId];
                caseObj = populateCaseSubType(retrievedCaseObj, null , caseObj, recordtypeName, caseType, caseSubType, caseReason);
            } else {
                caseObj = new Case(Status = Constant_Util.NEW_STATUS ,RecordTypeId = recordtype);
                caseObj = populateCaseSubType(null, null, caseObj, recordtypeName, caseType, caseSubType, caseReason);
                //system.debug('caseObj--->'+ Constant_Util.R_NEW_SERVICE_CASE);
                //system.debug('recordtypeName--->'+ recordtypeName);
                
            }  
           caseObj.Check_Case__c = true;
         
           if(isCaseFeed && recordtypeName == Constant_Util.PICKUP && mainCaseObj.RecordType.Name == Constant_Util.PICKUP){
                caseComment = AcornController.getCommentData(recordId , 1000 , true, 'Date');
            }  
            
            if((recordtypeName == Constant_Util.NEW_SERVICE) || (recordtypeName == Constant_Util.MODIFY_EXISTING_SERVICE_CASE)){
					caseObj.CPQ_New_Service__c = permissionCheck_ForCPQ(recordtypeName);
				}
             //Changes related to SDT-39689 - Adding default Origin to Cases created from SFDC UI.
             caseObj.Origin = Constant_Util.ORIGIN_SFDC_DEFAULT;
            
// Modified for SDT-33452 Start
            if(caseObj != null){
            insert caseObj; 
}
            // Modified for SDT-33452 End
            if(isCaseFeed) {
                if(recordtypeName == Constant_Util.PICKUP && mainCaseObj != null && mainCaseObj.RecordType.Name == Constant_Util.PICKUP){
                    copyAcornCommentsToChildCase(recordId, caseObj, caseComment);
                }
                copyEmailToChildCase(recordId, caseObj);
                createInboundTask(recordId, caseObj);
            }
            wrap.success = true;
            wrap.message = caseObj.id;
            return wrap;
        }catch(Exception ex){
            wrap.success = false;
            wrap.message = ex.getMessage()+'\n'+ex.getStackTraceString();
            return wrap;
        }
    }
	
	public static Boolean permissionCheck_ForCPQ(String recordtypeName){
                List<PermissionSetLicenseAssign> PSLList = new List<PermissionSetLicenseAssign>();
                PSLList = [SELECT id, AssigneeId,PermissionSetLicenseId, PermissionSetLicense.MasterLabel  From PermissionSetLicenseAssign WHERE PermissionSetLicense.MasterLabel = 'Salesforce CPQ License' AND AssigneeId =: UserInfo.getUserId()];//'0058A0000075dM6QAI'
                if (PSLList.size() > 0)
                {
                    if(PSLList[0].PermissionSetLicense.MasterLabel == Constant_Util.Salesforce_CPQPermissionSetLicense){
                        return true;
                    }
                }
        return false;
    } 
    
    /**
    * @author Accenture
    * @date 2/25/2019
    * @description : Apex method getCaseRecordTypes 
    **/
    //get the list of case recordtypes accessible for the loggedin user 
    @AuraEnabled
    public static List<recordType> getCaseRecordTypes(){   
        Map<Id, String> recordtypemap = new Map<Id, String>();
        List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.isAvailable() && rt.getName() != Constant_Util.MASTER){
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            } 
        } 
        Set<ID>RecordTypeIdSet  = recordtypemap.keySet();
        List<recordType> recordTypeData = [SELECT id, Name, Description FROM RecordType WHERE id In :RecordTypeIdSet];
        return recordTypeData ;
    }
    
    public static Id getRecTypeId(String recordtypeName){
        Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        return recid;
    } 
    /**
    * @author Accenture
    * @date 05/04/2019
    * @description : Apex method to clone inbound task from parent case from case feed(Quick Action-Create Case)
    **/
    public static void createInboundTask(string originalCaseId, Case clonedCaseObj) {
        List<Task> taskLst = [SELECT Id, CreatedDate, WhoId, WhatId, Subject, Status, Priority, OwnerId, Description, Description__c FROM Task WHERE
                                WhatId =: originalCaseId AND Subject =: Constant_Util.TASK_SUBJECT ORDER BY CreatedDate DESC];
        //format task description
        String comments = 'MediaType: ' + clonedCaseObj.Last_Customer_Interaction_Type__c
            + '\nGenesys ID: ' + clonedCaseObj.Last_Customer_Interaction_ID__c;
        Task t;
        if(taskLst.size()>0) {
            t = new Task();
            t.OwnerId = UserInfo.getUserId();
            t.Subject = taskLst[0].Subject;
            t.Description = comments;
          	t.Description__c = clonedCaseObj.Last_Customer_Interaction_ID__c;
            t.Status = taskLst[0].Status;
            t.Priority = taskLst[0].Priority;
            t.WhatId = clonedCaseObj.Id;
        }else{}
    
        try {
// Modified for SDT-33452 Start
            if(t != null){
            insert t;
}
            // Modified for SDT-33452 End
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
        }
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
   
    public static boolean copyAcornCommentsToChildCase(string recordId, Case caseObj, List<AcornController.caseComments> acronComments){
        
        List<Comment__c> updatedCommentsList = new List<Comment__c>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();

        User acornUser = [select Acorn_SUser_ID__c,Name from User where ID =: System.UserInfo.getUserId() Limit 1]; 
        Case caseRecordChild = [Select CaseNumber from Case where id= :caseObj.Id LIMIT 1];

            try {
                   if(acronComments != null && acronComments.size()>0) {
                            for(AcornController.caseComments comments : acronComments){
                                Comment__c newComments= new Comment__c();

                                newComments.Case__c = caseObj.Id;
                                newComments.Case_Number__c = caseRecordChild.CaseNumber;
                                newComments.Comment__c= comments.Comment;
                                newComments.Communication_Log_Type_Name__c = Constant_Util.INTERNAL;
                                newComments.Acorn_SUser_ID__c = acornUser.Acorn_SUser_ID__c;
                                newComments.RecordTypeId = recordTypeId;
                                newComments.Workflow_TeamUser__c = comments.WorkflowTeamUser;
                                newComments.Workflow_Action__c = comments.WorkflowAction;
                                newComments.Related_SObject_Id__c = comments.sObjectId;
                                newComments.Related_SObject_Key__c = comments.sobjectKey;
                                newComments.is_Log__c = comments.isLog;
                            
                                updatedCommentsList.add(newComments);                    
                            }
                        }
                }
                catch(Exception e) {
                    System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
                    return false;
                }
          
        try {
        	database.insert(updatedCommentsList);
            return true;
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
            return false;
        }           
    }

    @AuraEnabled
    public static ResultWrapper CaseCreationwithCopyData(String recordtypeName,String recordId, List<String> copyoptions, List<String> emailIds, String caseTypeData){
        String caseType = '';
        String caseSubType = '';
        String caseReason = '';
            
        if(caseTypeData != null) {
            Map<String, object> queryParams = (Map<String, object>) JSON.deserializeUntyped(caseTypeData);
            if( queryParams != null && queryParams.containsKey('Case_Type__c')  && String.isNotBlank( (String)queryParams.get('Case_Type__c') ) ){
                caseType = (String)queryParams.get('Case_Type__c');
            }  
            if( queryParams != null && queryParams.containsKey('Case_Sub_Type__c') && String.isNotBlank( (String)queryParams.get('Case_Sub_Type__c') ) ){
                caseSubType = (String)queryParams.get('Case_Sub_Type__c');
            }  
            if( queryParams != null && queryParams.containsKey('Case_Reason__c') && String.isNotBlank( (String)queryParams.get('Case_Reason__c') ) ){
                caseReason = (String)queryParams.get('Case_Reason__c');
            }
        }
        //System.debug('paramsss --- '  + recordtypename + ' ' + recordId + ' ' + copyoptions + ' ' + emailIds);
        ResultWrapper wrap = new ResultWrapper();
        
        Id recordtype;
        if(recordtypeName != 'Pickup' && recordtypeName != 'New Service' && recordtypeName != 'SNP' && recordtypeName != 'ETA' ){
            recordtype = CustomCaseCreationCntrlr.getRecTypeId(recordtypeName);
        }

        Case parentCase = [SELECT Id,Client__c, Location__c, ContactId,Origin,ParentId, Reference_Number__c,Last_Agent_ID__c,Last_Customer_Interaction_ID__c,
        Last_Customer_Interaction_Type__c, CaseNumber, AssetId,Asset.Name,Asset.product2.family,Asset.Duration__c,
        Asset.Occurrence_Type__c,Asset.product2.Equipment_Type__c,Case_Type__c, Case_Sub_Type__c,Case_Reason__c,CPQ_New_Service__c,Case_Record_Type__c,
        LOB__c, RecordTypeId FROM Case WHERE Id = :recordId];

        List<AcornController.caseComments> caseComment = AcornController.getCommentData(recordId , 1000 , true, 'Date');

        try{
            Case myCase = new Case(Status = Constant_Util.NEW_STATUS , RecordTypeId = recordtype, Client__c = parentCase.Client__c, Location__c = parentCase.Location__c,
            Reference_Number__c = parentCase.Reference_Number__c, ContactId = parentCase.ContactId,Origin = parentCase.Origin,
            ParentId = recordId, Last_Customer_Interaction_ID__c = parentCase.Last_Customer_Interaction_ID__c,
            Last_Customer_Interaction_Type__c = parentCase.Last_Customer_Interaction_Type__c);
            myCase = populateCaseSubType(parentCase , null, myCase , recordtypeName, caseType , caseSubType , caseReason);
            if(!copyoptions.isEmpty()){
                if(copyOptions.contains('Asset')){
                    myCase.AssetId = parentCase.AssetId;
                }
            }
            
			if((recordtypeName == Constant_Util.NEW_SERVICE) || (recordtypeName == Constant_Util.MODIFY_EXISTING_SERVICE_CASE)){
              myCase.CPQ_New_Service__c = permissionCheck_ForCPQ(recordtypeName);
            }
			parentCase.Last_Agent_ID__c = UserInfo.getUserName().substringBefore(Constant_Util.AT_SYMBOL );
            Database.update(parentCase);
            Database.insert(myCase, false);
            //insert myCase;

            if(!copyoptions.isEmpty()){
                if(copyOptions.contains('Comments')){
                    copyAcornCommentsToChildCase(recordId, myCase, caseComment);
                }
                if(copyOptions.contains('Email') && !emailIds.isEmpty()){
                    emailToComments(emailIds, myCase, parentCase);
                    
                }
                if(copyOptions.contains('Attachments')){
                    copyAttachments(recordId, myCase);
                }
            }
            wrap.success = true;
            wrap.message = myCase.id;
            return wrap;
        }catch(Exception e){
            System.debug('Exception creating Case --' + e.getMessage());
            System.debug('Exception creatin Case stacktrace --' + e.getStackTraceString());
            wrap.success = false;
            wrap.message = e.getMessage()+'\n'+e.getStackTraceString();
            return wrap;
        }

    }
    
    public static void emailToComments(List<String> emailIds, Case myCase, Case parentCase){
        List<EmailMessage> recordEmails = new List<EmailMessage>();
        List<Comment__c> emailComments = new List<Comment__c>();

        recordEmails = [SELECT Id, ParentId, TextBody, FromAddress, ToAddress, CCAddress, Subject, MessageDate FROM EmailMessage WHERE Id In :emailIds];

        for(EmailMessage e : recordEmails){
            String concatInfo;
            String newEmailBod;

            concatInfo = 'Case Number: ' + parentCase.CaseNumber + Constant_Util.New_Line + 'From Address: ' + e.FromAddress + Constant_Util.New_Line + 'To Address: ' + e.ToAddress + Constant_Util.New_Line + 'CC Address: ' + (e.CCAddress == null ? '' : e.CCAddress + Constant_Util.New_Line) + 'Subject: ' + e.Subject + Constant_Util.New_Line + 'Message Date: ' + e.MessageDate.format() + Constant_Util.New_Line;
            newEmailBod = concatInfo + 'Text Body: ' + e.TextBody;
            AcornController.createAcornComment(newEmailBod, myCase.id);
        }

        try{
            insert emailComments;
        }catch(Exception e){
            System.debug('EmailComment insert exc -- ' + e.getMessage());
        }
    }
    

    public static void copyAttachments(string recordId, Case myCase){
        List<ContentDocumentLink> newContentLinks = new List<ContentDocumentLink>();
        List<ContentDocument> contentDocs = new List<ContentDocument>(); 
        Set<Id> contentDocSet = new Set<Id>();
        List<EmailMessage> recordEmails = new List<EmailMessage>();
        Set<Id> relatedIds = new Set<Id>();

        Id caseId = Id.valueOf(recordId);

        recordEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :caseId];
        
        if(!recordEmails.isEmpty()){
            for(EmailMessage e : recordEmails){
                relatedIds.add(e.Id);
            }
        }
        relatedIds.add(caseId);

        for(ContentDocumentLink cdlink : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : relatedIds]){
            ContentDocumentLink newcdlink = new ContentDocumentLink();
            newcdlink.ContentDocumentId = cdlink.ContentDocumentId;
            newcdlink.LinkedEntityId = myCase.id;

            newContentLinks.add(newcdlink);
        }

        try{
            insert newContentLinks;
        }catch(Exception e){
            System.debug('Insert attach exc--' + e.getMessage());
        }

    }

    //return list of emails for email to comment selection
    @AuraEnabled
    public static List<EmailMessage> GetEmails(Id caseId){
        List<EmailMessage> returnEmails = new List<EmailMessage>();

        returnEmails = [SELECT Id, Subject, FromAddress, ToAddress, MessageDate, toLabel(Status), ParentId FROM EmailMessage WHERE RelatedToId = :caseId order by MessageDate DESC];

        return returnEmails;
    }

    @AuraEnabled
    public static Case populateCaseSubType(Case c, Asset assetObj, Case newCase, String recordTypeName, String casetype, String caseSubType , String caseReason){
        if(recordTypeName == 'Pickup'){
		    Boolean  rolloffPickUP = false ;//added for 18374
            newCase.Case_Type__c = 'Pickup';
            newCase.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Pickup Case').getRecordTypeId();
            newCase.Case_Reason__c='';
            Asset asst;
            if(c != null ) {
                if(c.assetId != null){
                    asst = [select Id, rootAssetId,AccountId,Location__c, Name, product2.family, Duration__c, Occurrence_Type__c, product2.Equipment_Type__c from asset where id =:c.assetId];
					 /*SDT-18374*- Code Chnage */
                    if(asst.Id != Null && asst.product2.family == Constant_Util.ROLLOFF && (asst.Occurrence_Type__c == Constant_Util.SCHEDULED || asst.Occurrence_Type__c == Constant_Util.ON_CALL)){
                        rolloffPickUP = checkRollofStatusLogic(asst.Id);
                    }
                /*     SDT-18374*- Code Chnage */
                }     
            } else if(assetObj != null) {
                asst = assetObj;
				
				 /*SDT-18374*- Code Change */
                 if(asst.Id != Null && asst.product2.family == Constant_Util.ROLLOFF && (asst.Occurrence_Type__c == Constant_Util.SCHEDULED || asst.Occurrence_Type__c == Constant_Util.ON_CALL)){
                        rolloffPickUP = checkRollofStatusLogic(asst.Id);
                    }
               /*  SDT-18374*- Code Change*/
				
            }   
            
            if(asst != null) {
                if(asst.product2.family == Constant_Util.COMMERCIAL && asst.Occurrence_Type__c == Constant_Util.ON_CALL){
                    newCase.Case_Sub_Type__c = Constant_Util.ON_CALL_PICK;
                 }else if(asst.product2.family == Constant_Util.COMMERCIAL && Constant_Util.HAND_PICKUP.equals(asst.product2.Equipment_Type__c) && asst.Duration__c.equals(Constant_Util.PERMANENT)){
                    newCase.Case_Sub_Type__c = '';
                 }else if(asst.product2.family == Constant_Util.COMMERCIAL && (asst.Occurrence_Type__c == Constant_Util.SCHEDULED || asst.Occurrence_Type__c == Constant_Util.SCHEDULED_ON_CALL)){
                    newCase.Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;                        
                 }else if(asst.product2.family == Constant_Util.ROLLOFF && asst.product2.Equipment_Type__c != Constant_Util.Baler){
				 
				 
				  /*  SDT-18374 */
                     if(rolloffPickUP == true && (asst.Occurrence_Type__c == Constant_Util.SCHEDULED)){
                          newCase.Case_Sub_Type__c = Constant_Util.EXTRA_PICKUP;
                     }else if(rolloffPickUP == true && (asst.Occurrence_Type__c == Constant_Util.ON_CALL)){
                         newCase.Case_Sub_Type__c = Constant_Util.ON_CALL_PICK;
                     }else{
                        // newCase.Case_Sub_Type__c = Constant_Util.ON_CALL_PICK;
                        newCase.Case_Sub_Type__c = Constant_Util.EMPTY_AND_RETURN; 
                     }
                     /*  SDT-18374 */
                    
					
                 }else if(Constant_Util.Baler.equals(asst.product2.Equipment_Type__c)){
                    newCase.Case_Sub_Type__c = Constant_Util.Bales;
                 }else if(( asst.product2.family == Constant_Util.SERVICES && asst.Name.equals(Constant_Util.Bulk_Service_Type))){
                    newCase.Case_Sub_Type__c = Constant_Util.Bulk_Service_Type;
                 }else if((asst.product2.family == Constant_Util.SERVICES  && asst.Name.equals(Constant_Util.Haul_Away_Service))){
                    newCase.Case_Sub_Type__c = Constant_Util.Haul_Away_No_Equipment;
                 }else{
                    newCase.Case_Sub_Type__c = '';
                 }
            }    
        }
        else if(recordtypeName == 'New Service'){
            newCase.Case_Type__c = 'New Service';
            newCase.Case_Sub_Type__c = '';
            newCase.Case_Reason__c = '';     
            newCase.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get(Constant_Util.New_Service_Case).getRecordTypeId();
        }
        else if(recordtypeName == 'SNP'){
            newCase.Case_Type__c = 'Status';
            newCase.Case_Sub_Type__c = 'Service not performed';
			newCase.Case_Reason__c ='Customer Reported' ;
            newCase.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Status Case').getRecordTypeId();                          
        }
        else if(recordtypeName == 'ETA'){
            newCase.Case_Type__c = 'Status';
            newCase.Case_Sub_Type__c = 'ETA'; 
            newCase.Case_Reason__c = '';    
            newCase.RecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Status Case').getRecordTypeId();   
        }
        else{
            newCase.Case_Type__c = casetype ;
            newCase.Case_Sub_Type__c = caseSubType ;
            newCase.Case_Reason__c = caseReason ;
        }
        return newCase;
    }
	
	
	/*SDT-18374*- Code Change*/
     @AuraEnabled
    Public static boolean checkRollofStatusLogic(String AssetId){
        Boolean rolloffPickUP = false ;
      
        if(AssetId !=NUll){
            for(Asset asst : [select Id, (select Id,ParentId,Service_Type__c,Is_Core_Service__c from ChildAssets) from Asset where Id =:AssetId]){
                List<Asset> childAssetList = asst.ChildAssets ;
                if(!childAssetList.isEmpty()){
                    for(Asset childAsset  : childAssetList){
                        if(childAsset.Service_Type__c == Constant_Util.PICKUP_CSTYPE && childAsset.Is_Core_Service__c== true){
                            rolloffPickUP = true;
                           // parentAssetIdSetAfterFilter.add(childAsset.ParentId);
                        }
                    }
                }
            }
        }
        return rolloffPickUP ;
    }
	
}