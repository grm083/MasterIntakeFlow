/*************************************************************
@Name: CaseApprovalHandler
@Author: DineshKumar S
@CreateDate: 22/03/2019
@Description: To capture the auto-response send by the Approver.
@UsedBy: Obtain Service Approval Email Service
**************************************************************/
global without sharing class CaseApprovalHandler implements Messaging.InboundEmailHandler {
    /** It is invoked When Email is send by the Approver for Approving/Rejecting the case.
    * @owner : DineshKumar S
    * @param : email, envelope*/
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String plainText= Constant_Util.EMPTY_STRING;
        // Add the email plain text into the local variable 
        plainText = email.plainTextBody;
        String[] emailBody = email.plainTextBody.split(Constant_Util.NEW_LINE, 0);
        If(emailBody != null && emailBody.size() > 2 && String.isBlank(emailBody[1])){
            plainText = emailBody[2].length() > 3999 ? emailBody[2].substring(0,3999) : emailBody[2];
        }else if(emailBody != null && emailBody.size() > 1){
            plainText = emailBody[1].length() > 3999 ? emailBody[1].substring(0,3999) : emailBody[1];
        }
        plainText = plainText.contains(Constant_Util.FOREMAILCHECK) ? plainText.substringBefore(Constant_Util.FOREMAILCHECK) : plainText.substringBefore(Constant_Util.FORWMEMAILCHECK);
        string subject = Constant_Util.EMPTY_STRING;
        subject = email.subject;
        List<String> sublst =  subject.split(Constant_Util.COLON);
        Id caseId = sublst != null && sublst.size() > 1 ? Id.valueof(sublst[1]) : null;
        String refNum = sublst != null && sublst.size() > 2 ? sublst[2] : null;
        String casetype = sublst != null && sublst.size() > 3 ? sublst[3] : null;
        
        Task tsk = null;
        Task tsk1 = null;
        Task newtask = null;
        List<Task> updateTasklst = new List<Task>();
        List<Task> taskList = new List<Task>();
        
        try 
        {            
            if(Constant_Util.PICKUP_CSTYPE.equals(casetype))
            {
                map<Id,Task> brIdmap = new Map<Id,Task>();
                Boolean notMultiApprover = false;
                Boolean singleApprChange = false;
                map<String,Id> emailConIdmap = new map<string,Id>();
                map<String,Id> emailUsermap = new map<string,Id>();
                for(Contact c:[select id,Email from Contact where Email =:email.fromAddress Limit 1]){
                    emailConIdmap.put(c.Email,c.Id);   
                }
                for(User u: [select id,Email from User where Email =: email.fromAddress Limit 1]){
                    emailUsermap.put(u.Email,u.Id); 
                }
                //for(Task tk : [SELECT Id,RecordTypeId,Description,MultiCaseId__c,OwnerId,Process__c,Outcome__c,WhoId,ContactEmail__c,Contact_Number__c,Department_Name__c,Preferred_Contact_Method__c,Business_Rule__c,Business_Rule__r.Multiple_Mandatory_Approvers__c,Approval_Log__c,Attempt__c,Approval_Log__r.Approver_Type__c,WhatId,Contact_Title__c FROM Task WHERE (Outcome__c =: Constant_Util.NO_OR_PENDING_RESPONSE or Outcome__c = null) and (Process__c =: Constant_Util.OBTAIN_SERVICE_APPROVAL OR Process__c=: Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL) AND WhatId =: caseId Order by Attempt__c DESC LIMIT 49999]){ //Included Outcome__c =: Constant_Util.NO_OR_PENDING_RESPONSE as part #7831
		for(Task tk : [SELECT Id,RecordTypeId,Description,MultiCaseId__c,OwnerId,Process__c,Outcome__c,WhoId,ContactEmail__c,Contact_Number__c,Department_Name__c,Preferred_Contact_Method__c,Business_Rule__c,Business_Rule__r.Multiple_Mandatory_Approvers__c,Approval_Log__c,Attempt__c,Approval_Log__r.Approver_Type__c,WhatId,Contact_Title__c FROM Task WHERE (Outcome__c =: Constant_Util.AUTO_APPROVAL_EMAIL_SENT or Outcome__c =: null or Outcome__c =: Constant_Util.FINAL_EMAIL_SENT) and (Process__c =:Constant_Util.OBTAIN_SERVICE_APPROVAL OR (Process__c=:Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL and Status =: Constant_Util.OPEN)) AND WhatId =:caseId Order by Attempt__c DESC LIMIT 49999]){ //Included Outcome__c =: Constant_Util.NO_OR_PENDING_RESPONSE as part #7831
                    If(String.isNotBlank(email.fromAddress) && email.fromAddress.equals(tk.ContactEmail__c) && tk.Business_Rule__r.Multiple_Mandatory_Approvers__c && (tsk == null || tsk != null && Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL.equals(tk.Process__c) && tsk.Approval_Log__c.equals(tk.Approval_Log__c))){
                        tsk = tk;                                            
                        /*}else if(!tk.Business_Rule__r.Multiple_Mandatory_Approvers__c && (brIdmap.IsEmpty() || (!brIdmap.IsEmpty() && brIdmap.containskey(tk.Business_Rule__c) && Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL.equals(tk.Process__c) && brIdmap.get(tk.Business_Rule__c).Approval_Log__c.equals(tk.Approval_Log__c)))){
                            brIdmap.put(tk.Business_Rule__c,tk); 
                          }*/
                    }else if(!tk.Business_Rule__r.Multiple_Mandatory_Approvers__c && (tsk == null || (tsk != null && Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL.equals(tk.Process__c) && tsk.Approval_Log__c.equals(tk.Approval_Log__c)))){ 
                        tsk = tk;
                        notMultiApprover = true; 
                    }else{
                        //Novacop fixes
                    }
                }
                
                Boolean isOwnerChanged = false;
                String oldEmail = null;
                Id oldWhoId =  null;
                if(notMultiApprover){
                    integer count = 0;
                    List<Service_Approver__c> salst = new List<Service_Approver__c>();
                    for(Service_Approver__c sa : [Select Id,Business_Rule__c,RecordType.DeveloperName,Approver_Email__c,Approver_Contact__c,Approver_Contact__r.Preferred_Method__c,Approver_Type__c,User__c from Service_Approver__c where Business_Rule__c =: tsk.Business_Rule__c and Active__c = true LIMIT 49999]){
                        if(Constant_Util.CONTACT_RECORD_TYPE.equals(sa.RecordType.DeveloperName) || Constant_Util.USER_RECORDTYPE.equals(sa.RecordType.DeveloperName) || Constant_Util.ORIGIN_EMAIL.equals(sa.RecordType.DeveloperName)){
                            salst.add(sa);
                        }
                        count +=1;
                    }
                    If(count == 1 && salst!=null && salst.size() > 0 && String.isNotBlank(email.fromAddress) && !(email.fromAddress).equals(salst[0].Approver_Email__c)){
                        singleApprChange = true;
                        //oldWhoId = tsk.WhoId;
                        tsk.WhoId = emailConIdmap != null && emailConIdmap.size() > 0 && ( tsk.WhoId != null && !(tsk.WhoId).equals(emailConIdmap.get(email.fromAddress)) ||  tsk.WhoId == null) ? emailConIdmap.get(email.fromAddress) : null;
                        //oldEmail = tsk.ContactEmail__c;
                        tsk.ContactEmail__c = email.fromAddress;
                        tsk.Preferred_Contact_Method__c = Constant_Util.ORIGIN_EMAIL;
                    }else if(salst!= null && salst.size() > 0 && count > 1){
                        for(Service_Approver__c sa : salst){
                            If(String.isNotBlank(email.fromAddress) && email.fromAddress.equals(sa.Approver_Email__c)){
                                If(Constant_Util.CONTACT_RECORD_TYPE.equals(sa.Approver_Type__c)){
                                    tsk.WhoId = sa.Approver_Contact__c;
                                    tsk.ContactEmail__c = email.fromAddress;
                                    tsk.Preferred_Contact_Method__c = Constant_Util.ORIGIN_EMAIL;
                                }else If(Constant_Util.USER_RECORDTYPE.equals(sa.Approver_Type__c)){
                                    isOwnerChanged = true;
                                    tsk.OwnerId = sa.User__c;
                                }else If(Constant_Util.ORIGIN_EMAIL.equals(sa.Approver_Type__c)){
                                    tsk.ContactEmail__c = email.fromAddress;
                                    tsk.Preferred_Contact_Method__c = Constant_Util.ORIGIN_EMAIL;
                                }else{
                                    //Novacop Fixes
                                }
                            }
                        }
                    }
                }
                //If Approve/Reject button is clicked
                if(subject.contains(Constant_Util.MIXED) && tsk!=null){
                    Generic_Values__mdt genysysUser = [Select Id,Id__c from Generic_Values__mdt where Label =: Constant_Util.GENYSYS_USER LIMIT 1];
                    Task mixedTask = tsk;
                    mixedTask.WhoId = String.isBlank(mixedTask.WhoId) ? (emailConIdmap != null && emailConIdmap.size() > 0 ? emailConIdmap.get(email.fromAddress) :null ) : mixedTask.WhoId;
                    mixedTask.ContactEmail__c = String.isBlank(mixedTask.ContactEmail__c) ? email.fromAddress : mixedTask.ContactEmail__c;
                    mixedTask.Preferred_Contact_Method__c = Constant_Util.ORIGIN_EMAIL;
                    mixedTask.OwnerId = genysysUser.Id__c;
                    mixedTask.Id = null;
                    mixedTask.Outcome__c = Constant_Util.EMPTY_STRING;
                    mixedTask.Process__c = Constant_Util.MULTI_CASE_APPROVAL_TASK;
                    mixedTask.Subject = Constant_Util.MULTI_CASE_APPROVAL_TASK;
                    mixedTask.Is_Genesys_User__c = true; 
                    updateTasklst.add(mixedTask);
                    If(singleApprChange){
                        for(Task tk : [SELECT Id,Description,Business_Rule__c,MultiCaseId__c,Business_Rule__r.Occurrence_Limit__c,Approval_Log__r.CaseId__r.Case_Sub_Type__c,Approval_Log__r.CaseId__r.Reference_Number__c,Approval_Log__r.CaseId__r.Service_Date__c,Approval_Log__r.CaseId__r.CaseNumber,Due_Date_Time__c,WhatId,OwnerId,Business_Rule__r.Name,Outcome__c,Approval_Log__r.Approver_Type__c,ContactEmail__c,Contact_Title__c,Department_Name__c,whoId,Preferred_Contact_Method__c FROM Task where MultiCaseId__c =: tsk.MultiCaseId__c and (Outcome__c =: Constant_Util.NO_OR_PENDING_RESPONSE or Outcome__c = null) and Process__c =: Constant_Util.OBTAIN_SERVICE_APPROVAL LIMIT 49999]){ 
                            tk.ContactEmail__c = tsk.ContactEmail__c;
                            tk.WhoId = tsk.WhoId;
                            tk.Preferred_Contact_Method__c = Constant_Util.ORIGIN_EMAIL;
                            updateTasklst.add(tk);
                        }
                    }
                }else if(tsk != null){
                    //get all Task list
                    taskList.add(tsk);
                    for(Task tk : [SELECT Id,status,Description,Business_Rule__c,MultiCaseId__c,Business_Rule__r.Occurrence_Limit__c,Approval_Log__r.CaseId__r.Case_Sub_Type__c,Approval_Log__r.CaseId__r.Reference_Number__c,Approval_Log__r.CaseId__r.Service_Date__c,Approval_Log__r.CaseId__r.CaseNumber,Due_Date_Time__c,WhatId,OwnerId,Business_Rule__r.Name,Outcome__c,Approval_Log__r.Approver_Type__c,ContactEmail__c,Contact_Title__c,Department_Name__c,whoId,Preferred_Contact_Method__c,Process__c FROM Task where MultiCaseId__c =: tsk.MultiCaseId__c and (Outcome__c =: Constant_Util.NO_OR_PENDING_RESPONSE OR Outcome__c = null OR Outcome__c =: Constant_Util.AUTO_APPROVAL_EMAIL_SENT) AND Is_Primary__c= false and Id !=: tsk.Id and (Process__c =: Constant_Util.OBTAIN_SERVICE_APPROVAL OR Process__c =: Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL) LIMIT 49999]){ 
                        
                        if((String.IsBlank(tk.Approval_Log__r.Approver_Type__c) && string.IsBlank(tsk.Approval_Log__r.Approver_Type__c)) || singleApprChange ){
                            tk.WhoId = tsk.WhoId ;
                            tk.ContactEmail__c = tsk.ContactEmail__c;
                            tk.Preferred_Contact_Method__c = tsk.Preferred_Contact_Method__c;
                            tk.OwnerId = tsk.OwnerId;
                            taskList.add(tk);
                        }else if(String.isNotBlank(tk.Approval_Log__r.Approver_Type__c) && (tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.CONTACT_RECORD_TYPE) && String.isNotBlank(tk.whoId) && String.isNotBlank(tsk.whoId) && tk.whoId.equals(tsk.whoId) ){
                            tk.OwnerId = tsk.OwnerId;
                            taskList.add(tk);
                        }else if(String.isNotBlank(tk.Approval_Log__r.Approver_Type__c) && (tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ORIGIN_EMAIL) && String.isNotBlank(tk.ContactEmail__c) && String.isNotBlank(tsk.ContactEmail__c) && tk.ContactEmail__c.equals(tsk.ContactEmail__c) ){
                            tk.OwnerId = tsk.OwnerId;
                            taskList.add(tk);
                        }else if(String.isNotBlank(tk.Approval_Log__r.Approver_Type__c) && (tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.DEPARTMENT_RECORDTYPE) && String.isNotBlank(tk.Department_Name__c) && String.isNotBlank(tsk.Department_Name__c) && tk.Department_Name__c.equals(tsk.Department_Name__c) ){
                            tk.OwnerId = tsk.OwnerId;
                            taskList.add(tk);
                        }else if(String.isNotBlank(tk.Approval_Log__r.Approver_Type__c) && (tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.FLOW_TITLE) && String.isNotBlank(tk.Contact_Title__c) && String.isNotBlank(tsk.Contact_Title__c) && tk.Contact_Title__c.equals(tsk.Contact_Title__c) ){
                            tk.OwnerId = tsk.OwnerId;
                            taskList.add(tk);
                        }else if(String.isNotBlank(tk.Approval_Log__r.Approver_Type__c) && ((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.USER_RECORDTYPE) || (tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ATM_RECORD_TYPE)) && tk.OwnerId.equals(tsk.OwnerId) ){
                            tk.OwnerId = tsk.OwnerId;
                            taskList.add(tk);
                        }
                    }
                }
                If(taskList != null){
                    for(Task t: taskList){
                        
                        If(String.isNotBlank(email.fromAddress) && String.isBlank(t.WhoId) && !isOwnerChanged ){
                            t.WhoId = emailConIdmap.get(email.fromAddress);
                            t.ContactEmail__c = String.isBlank(t.ContactEmail__c) ? email.fromAddress : t.ContactEmail__c;
                            t.Preferred_Contact_Method__c = String.isBlank(t.Preferred_Contact_Method__c) ? Constant_Util.ORIGIN_EMAIL : t.Preferred_Contact_Method__c;
                        } 
                        If(String.isNotBlank(email.fromAddress) && String.isBlank(t.WhoId) && !isOwnerChanged){
                            If(emailUsermap != null &&emailUsermap.size() > 0){
                                t.OwnerId = emailUsermap.get(email.fromAddress);
                                t.ContactEmail__c = String.isBlank(t.ContactEmail__c) ? email.fromAddress : t.ContactEmail__c;
                            }else{
                                t.ContactEmail__c = String.isBlank(t.ContactEmail__c) ? email.fromAddress : t.ContactEmail__c;
                                t.Preferred_Contact_Method__c = String.isBlank(t.Preferred_Contact_Method__c) ? Constant_Util.ORIGIN_EMAIL : t.Preferred_Contact_Method__c;
                            }
                        }
                        If(subject.Contains(Constant_Util.APPROVED)){
                            t.Outcome__c = Constant_Util.APPROVED;
                        }else if(subject.Contains(Constant_Util.REJECTED)){
                            t.Outcome__c = Constant_Util.REJECTED;
                        }else{
                            //Nova cop fix
                        }
                        t.Status = Constant_Util.COMPLETED;
                        if(string.isNotBlank(plainText) && !subject.contains(Constant_Util.MIXED)){
                            t.Description = string.isNotBlank(t.Description) ? t.Description + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + System.Label.Email_Approval : plainText + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + System.Label.Email_Approval;
                        }else if(string.isBlank(plainText) && !subject.contains(Constant_Util.MIXED)){
                            t.Description = string.isNotBlank(t.Description) ? t.Description + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + System.Label.Email_Approval : System.Label.Email_Approval;
                        }else{
                            //NovaCop Fix
                        }
                        updateTasklst.add(t);
                    }
                }
                // update the new Task 
                if(string.isNotBlank(plainText) && tsk != null && !subject.contains(Constant_Util.MIXED)){ // && !isSkip){
                    
                    map<String, Object> flowInputMap = new map<String, Object>();
                    flowInputMap.put(Constant_Util.INPUT_OBJECT_PARAMID , caseId);
                    flowInputMap.put(Constant_Util.INPUT_OBJECT_PARAMNAME , Constant_Util.OBJECT_CASE);
                    flowInputMap.put(Constant_Util.PROCESS_NAME , Constant_Util.VALIDATE_EMAIL_COMMENTS );
                    flowInputMap.put(Constant_Util.VAR_NUM_ATTEMPT ,Constant_Util.VALUE_NULL);
                    flowInputMap.put(Constant_Util.WHAT_ID , caseId);
                    flowInputMap.put(Constant_Util.VAR_ATTEMPT , 0);
                    flowInputMap.put(Constant_Util.VAR_SOURCE , Constant_Util.OBJECT_TASK);
                    flowInputMap.put(Constant_Util.WHOID , tsk.WhoId);
                    Flow.Interview.Create_Task_FrameWork_Process frameFlow = new Flow.Interview.Create_Task_FrameWork_Process(flowInputMap);
                    //system.debug('flowInputMap::'+flowInputMap);
                    frameFlow.Start();
                    newtask = (Task)(frameFlow.getVariableValue(Constant_Util.VARFOLLOWUPTASK));
                }
            }
        }
        // If an exception occurs when the query accesses 
        // the contact record, a QueryException is called.
        // The exception is written to the Apex debug log.
        catch (QueryException e) {
            //To handle Error in future Sprints
            system.debug('$$$$'+e.getStackTraceString());
            system.debug('DmlException caught: ' + e.getMessage());
        } finally {
            //Attaching recieved email to the case.
            EmailMessage msg = new EmailMessage(FromAddress = email.fromAddress,Subject = email.subject,HtmlBody = email.HtmlBody,IsIncoming__c = true,
                                                TextBody = email.plainTextBody,ParentId = caseId,relatedtoId = caseId,ActivityId = null);
            RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = True;
            RecurrsiveTriggerHandler.isSkiptaskTrigger = True;
            Database.insert(msg,false);
            RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = False;
            RecurrsiveTriggerHandler.isSkiptaskTrigger = False;
            if(tsk!= null && newtask!= null){
                newtask.ContactEmail__c = tsk.ContactEmail__c!= null? tsk.ContactEmail__c: null;
                newtask.Contact_Number__c = tsk.Contact_Number__c!= null? tsk.Contact_Number__c: null;
                newtask.Preferred_Contact_Method__c = tsk.Preferred_Contact_Method__c!= null ? tsk.Preferred_Contact_Method__c: null;
                newtask.Link__c = String.valueof(msg.Id);
                newtask.Process__c = Constant_Util.VALIDATE_EMAIL_COMMENTS;
                newtask.Outcome__c = Constant_Util.NOTREVIEWED;
                updateTasklst.add(newtask);  
            }
            If(!updateTasklst.isEmpty() && updateTasklst.size() > 0){
                if(!System.isFuture())
                {
                    updateTaskList(JSON.serialize(updateTasklst));
                }
                else
                {
                    Database.upsert(updateTasklst,true);
                }
            }    
        }
        return result;
    }
    @future
    public static void updateTaskList(String tskList)
    {
        List<Task> updateTasklst = (List<Task>)JSON.deserialize(tskList, List<Task>.class);
        Database.upsert(updateTasklst,true);
    }
}
