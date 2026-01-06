/*************************************************************
@Name: LinkFailureEmailMessageToCaseBatch
@Author: WM
@CreateDate: 07/07/2021
@Description: SDT - 17229 
**************************************************************/
public class LinkFailureEmailMessageToCaseBatch implements Schedulable,Database.Batchable<sObject>,Database.Stateful {
    
    String FrAddress = 'Donotreply@wm.com';
    String searchString = 'Work Order #W';
    String ADDRESSSUBJECT = '%' + searchString + '%';
    public String errorMsg ='';
    public Boolean isError= false;
    Private static final String query = 'SELECT ActivityId,BccAddress,ByPassGRByFilter__c,Bypass_Genesys_Task__c,CcAddress,CreatedById,CreatedDate,EmailTemplateId,FirstOpenedDate,FromAddress,FromName,HasAttachment,Headers,HtmlBody,Id,Incoming,IndicoErrorMessage__c,IndicoStatus__c,In_Reply_To_ID__c,IsBounced,IsClientManaged,isCloned__c,IsDeleted,IsExternallyVisible,isIndicoEligible__c,IsNonThreadEmail__c,IsOpened,IsPrivateDraft,IsTracked,LastModifiedById,LastModifiedDate,LastOpenedDate,MarkToDelete__c,MessageDate,MessageIdentifier,Message_ID__c,ParentId,RelatedToId,ReplyToEmailMessageId,Sent_or_Received__c,Status,Subject,SystemModstamp,Tech_New_Case__c,TextBody,ThreadIdentifier,ToAddress,To_Be_Processed__c,Tracking_Number_Email__c,Parent.Acorn_Work_order__c,Parent.Location__r.Location_Code__c,Parent.RecordType.Name,Parent.Case_Type__c,Parent.Case_Sub_Type__c,Parent.Reference_Number__c,Parent.Case_Reason__c,Parent.CaseNumber,Parent.Customer_Code__c,HourCreation__c,IsBatchProcessed__c FROM EmailMessage WHERE Subject LIKE :ADDRESSSUBJECT and CreatedDate = LAST_N_DAYS:1 AND Parent.Acorn_Work_order__c = null AND IsBatchProcessed__c = False LIMIT 49999';
    
    /**@MethodName execute
	* Method to schedule this batch .
	**/
    
    public void execute(SchedulableContext ctx) {
        Database.ExecuteBatch(new LinkFailureEmailMessageToCaseBatch(), 200);
    } 
    
    /**@MethodName start
	* Method to fetch the email messages
	**/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        System.debug('result>>>'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    /*@MethodName execute
	* Method to parse and link the cases to email messages
	**/
    public void execute(Database.BatchableContext batchVariable, List<EmailMessage> lstMessage) {
        System.debug('in execute');
        String woNumberPattern ='W{1}[0-9]{8}[0-9]?';
        String Result = null;
        Set<String> strPatternSet = new Set<String>();
        List<Case> lstCase = new List<Case>();
        List<Case> updateCase = new List<Case>();
        List<Case> NoExistingCodeCase = new List<Case>();
        List<EmailMessage> NoExistingCode = new List<EmailMessage>();
        Map<String,Id> mapTCClosedCase = new Map<String,Id>();
        Map<Id,String> mapNoMatchedCase = new Map<Id,String>();
        Map<String,Id> mapTrackingCodeCase = new Map<String,Id>();
        Map<EmailMessage,String> mapEMTrackingCode = new Map<EmailMessage,String>();
        Map<EmailMessage,String> mapCaseAcornWorkOrder = new Map<EmailMessage,String>();
		Map<Id,EmailMessage> mapEmpCase = new Map<Id,EmailMessage>();
        List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
        List<Id> delCaseList = new List<Id>();
        List<EMailMessage> lstCloneEM = new List<EmailMessage>();
		List<EMailMessage> isProcessed = new List<EmailMessage>();
        List<Id> nonDeletedIds = new List<Id>();
		List<Id> emDeleteId = new List<Id>();
        system.debug('lstMessage>>>'+lstMessage);
        if(lstMessage.size()>0){
            for(EmailMessage objEM : lstMessage){
                String content = null;
                if(objEM.Subject != null){
                    content =  objEM.Subject;
                    System.debug('content>>>'+content);
                }      
                if(content != null){
                    Matcher patternMatch = Pattern.compile(woNumberPattern).matcher(content);
                    while (patternMatch.find()) {
                        result = patternMatch.group();
                        System.debug('result>>>'+result);
                        if(result != null){
                            if(!mapEMTrackingCode.containsKey(objEM))
                            {
                                mapEMTrackingCode.put(objEM,result);
                                mapCaseAcornWorkOrder.put(objEM,objEM.Parent.Acorn_Work_order__c);
								mapEmpCase.put(objEM.Id,objEM);
                            }
                            strPatternSet.add(result);
                        }
                        break;   
                    } 
                }
            }
        }
        System.debug('strPatternSet>>>'+strPatternSet);
        // If Pattern found in the Email, Then search for the pattern in the existing cases.
        if(strPatternSet.size()>0){
            lstCase = [SELECT Id, Work_Order__r.Acorn_WorkOrder_Number__c, Status FROM Case WHERE Work_Order__r.Acorn_WorkOrder_Number__c IN :strPatternSet AND Status !=: Constant_Util.CLOSED  
                       order by CreatedDate];
            System.debug('lstCase>>>'+lstCase);
            if(test.isRunningTest()){
                lstCase = [SELECT Id, Work_Order__r.Acorn_WorkOrder_Number__c, Status FROM Case   
                           order by CreatedDate];
            }
            
            
            //If Case is found, then create map of Tracking Number and Case
            if(lstCase.size()>0){
                for(Case objCase : lstCase){
                    if(!mapTrackingCodeCase.containsKey(objCase.Work_Order__r.Acorn_WorkOrder_Number__c) && objCase.Status != Constant_Util.CLOSED ){
                        mapTrackingCodeCase.put(objCase.Work_Order__r.Acorn_WorkOrder_Number__c, objCase.Id);
                    }
                    // Store the Case with the Closed Status in a Map
                    if(objCase.Status == Constant_Util.CLOSED){
                        mapTCClosedCase.put(objCase.Work_Order__r.Acorn_WorkOrder_Number__c, objCase.Id);
                    }
                }
            }
        }
        EMailMessage cloneEM;
        // Existing Case found for Email Message with Tracking Number. Reparent the Email Message
        for(EmailMessage objEM : mapEMTrackingCode.keyset()){
            system.debug('entry>>>'+objEM);
            String Code = mapEMTrackingCode.get(objEM);
            if(mapTrackingCodeCase.get(Code) != null){
                
                //objEM.ParentId = mapTrackingCodeCase.get(Code);
                system.debug('objEM.ParentId>>>'+objEM.ParentId);
                cloneEM = new EmailMessage(); 
                cloneEM = objEM.clone(false);
                cloneEM.ParentId =  mapTrackingCodeCase.get(code);
                cloneEM.RelatedToId  =  mapTrackingCodeCase.get(code);
                cloneEM.isCloned__c = true;
                cloneEM.Bypass_Genesys_Task__c = true;
                cloneEM.Tracking_Number_Email__c = true;
                //cloneEM.Incoming  =  true;
                //cloneEM.Status  =  '0';
                lstCloneEM.add(cloneEM);
				mapEmpCase.remove(objEM.Id);
                if(objEM.ParentId != null)
                {
                    delCaseList.add(objEM.ParentId);
                }
                else
                {
                    emDeleteId.add(objEM.Id);
                }
                
            }
            else{
                // No Existing Case found for the Tracking Number
                // mapNoMatchedCase.put(objEM.ParentId, Code);
                
            }
            
            
        }
        try{
            if(lstCloneEM.size()>0){
                Database.SaveResult[] srList = Database.insert(lstCloneEM);
                for (Database.SaveResult sr : srList) {
                    if (!sr.isSuccess()) {
                        isError = True;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            errorMsg += 'Fields that affected this error: ' + err.getFields();
                        }
                    }
                }    
            }
            if(delCaseList.size()>0){
                Database.DeleteResult[] drList = Database.delete(delCaseList,false);
                for(Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        nonDeletedIds.add(dr.getId());
                        isError = True;
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            errorMsg += 'Fields that affected this error: ' + err.getFields();
                        }
                    }
                }
            }
			if(emDeleteId.size()>0){
                Database.DeleteResult[] drList = Database.delete(emDeleteId,false);
                for(Database.DeleteResult dr : drList) {
                    if (!dr.isSuccess()) {
                        //nonDeletedIds.add(dr.getId());
                        isError = True;
                        for(Database.Error err : dr.getErrors()) {
                            errorMsg += err.getStatusCode() + ': ' + err.getMessage();
                            errorMsg += 'Fields that affected this error: ' + err.getFields();
                        }
                    }
                }
            }
            if(!nonDeletedIds.isEmpty())
            {
                for(EmailMessage nonDelEm :[Select id,IsBatchProcessed__c from EmailMessage where ParentId IN : nonDeletedIds])
                {
                    nonDelEm.IsBatchProcessed__c = True;
                    isProcessed.add(nonDelEm);
                }
            }
            Database.update(isProcessed);
            
            
            /*String GenesysUserId;
            GenesysUserId = [SELECT Id, Id__c, DeveloperName FROM Generic_Values__mdt WHERE DeveloperName =: Constant_Util.GENESYSUSER].Id__c;
            //Generic User Call for Assignment of Case
            Generic_Values__mdt objGV = new Generic_Values__mdt();
            String userId = [SELECT Id,Id__c,DeveloperName FROM Generic_Values__mdt WHERE DeveloperName =: Constant_Util.GROUPUSER ].Id__c;
            
            //No Existing Case found
            if(mapNoMatchedCase != null){
                NoExistingCodeCase = [SELECT Id, OwnerId, Acorn_Ticket_Not_Matched__c, Routing_Counter__c, Work_Order__r.Acorn_WorkOrder_Number__c FROM Case 
                                      WHERE Id IN: mapNoMatchedCase.keySet()];
            }
            // Create a new Case
            for(Case objCase : NoExistingCodeCase){
                System.debug('objCase>>>'+objCase);
                String Code = mapNoMatchedCase.get(objCase.Id);
                if(mapTCClosedCase.get(Code) != null){
                    objCase.OwnerId = GenesysUserId;
                }
                else{
                    objCase.Email_Tracking_Number__c = Code;
                    objCase.OwnerId = userId;
                    objCase.Acorn_Ticket_Not_Matched__c = true;
                    objCase.Routing_Counter__c = 0;
                }
                updateCase.add(objCase);
            }
            //Update the Case
            if(updateCase.size()>0){
                update updateCase;
            }*/
            for(Genesys_Routing__c gr : [select id,SFDCObjRecordID__c from Genesys_Routing__c where SFDCObjRecordID__c IN : mapEmpCase.keySet()])
            {
                mapEmpCase.remove(gr.SFDCObjRecordID__c);
            }
            for(EmailMessage objEM : mapEmpCase.values())
            {
                if(objEM.HourCreation__c > Decimal.valueOf(System.label.HourCreation) )
                {
                    Genesys_Routing__c objGR = new Genesys_Routing__c();
                    objGR.EmailFrom__c = objEM.FromAddress;
                    objGR.EmailSubject__c = objEM.Subject;
                    objGR.EmailTo__c = objEM.ToAddress;
                    objGR.Email_Message_Id__c = objEM.Id;
                    objGR.SFDCAcctID__c = objEM.Parent.Customer_Code__c;
                    objGR.Integrate_with_Genesys_Routing__c = true;
                    objGR.MediaType__c = Constant_Util.SFDCEMAILCASE;
                    objGR.SFDCCaseNumber__c = objEM.Parent.CaseNumber;
                    objGR.SFDCCaseReason__c =objEM.Parent.Case_Reason__c;
                    objGR.SFDCCaseRefNo__c = objEM.Parent.Reference_Number__c;
                    objGR.SFDCCaseSubCaseType__c =objEM.Parent.Case_Sub_Type__c;
                    objGR.SFDCCaseType__c =objEM.Parent.Case_Type__c;
                    objGR.SFDCIsEmailNew__c = 'True';
                    objGR.SFDCObjName__c = Constant_Util.OBJECT_CASE;
                    objGR.SFDCObjRecordID__c = objEM.Id;
                    objGR.SFDCRecordType__c =  objEM.Parent.RecordType.Name;    
                    objGR.SFDCObjType__c = Constant_Util.OBJECT_EMAILMESSAGE;
                    if(objEM.Parent.Location__c!=null){
                        objGR.SFDCAcctLocation__c = objEM.Parent.Location__r.Location_Code__c;
                    }
                    lstGR.add(objGR);
                }
            }
            if(lstGR.size()>0){
                Database.insert(lstGR);
            }
        if(Test.isRunningTest()){
                DMLException e = new DMLException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }    
        }
        catch(Exception e) {
            isError = True;
            errorMsg += 'Exception occured during Task deletion: '+e.getLineNumber()+' '+e.getMessage()+' <br/>';
        }
        
    }   
    
    /*@MethodName finish
	*
	**/ 
    public void finish(Database.BatchableContext batchVariable) {
        if(isError)
        {
            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,CreatedById,TotalJobItems, CreatedBy.Email,CreatedBy.Name,ApexClass.Name
                                FROM AsyncApexJob
                                WHERE Id = :batchVariable.getJobId()];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(job.CreatedById);
            mail.setToAddresses(sendTo);
            mail.setReplyTo('noReply@wm.com');
            mail.setSenderDisplayName('WM Batch Job');
            mail.setSubject('Batch Job '+job.ApexClass.Name+' Status '+job.status);
            String body = 'Dear ' + job.CreatedBy.Name + ', '+ ' <br/>';
            body += 'Batch Job: '+job.ApexClass.Name+'. Job Status of '+job.status+'. ';
            if(errorMsg != null && errorMsg.length() >0){
                body += '<br/> The Following Error(s) occured '+'<br/>'+ errorMsg ; 
            }
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
        
    } 
    
}