/*************************************************************
@Author: Ayushi Sharma
@Date: 26/03/2019
@group:EmailMessage
@Description: Helper Class to Perform operations on EmailMessage :PareseTracking number, Parse WO Number,check EmilMessage WithOutReferenceNo,
              create the Existing Reply-MessageId,check EmailMessage ForServiceConfirmed ,handleClosedCaseMessage ,EmailsWithReferenceNo
              updateFromAddress ,checking the Email With Alias,checkIndicoEmailMessage,checking the Email With Indico FIlter
              createSFDCEmailMessageForIndico,stop Genesys task creation for Mailer-Daemon emails.
**************************************************************/
public without sharing class EmailMessageTriggerHelper {
    
    public static final String str_MESSAGE_ID ='Message-ID: <';
    public static final String str_REPLYTO_ID ='In-Reply-To: <';
    public static final String str_REFERENCE_ID ='References: <';
    public static final String str_AT ='@';
    public static final String str_REF ='ref:';
    public static final String trackingNumberPattern ='T{1}[0-9]{8}[0-9]?';
    public static final String caseNumberPattern ='[0-9]{8,9}';
    public static  List<EmailMessage> lstEmailMessages = new List<EmailMessage>();
    public static final boolean bypassIndicoProcessing;
    public  static String indicoFilterConditionColName='';	
    public  static String indicoFilterConditionColValue='';
	public  static List<Contact> contactsToDelete = new List<Contact>();
 
/*************************************************************
@Description: This method is called for Before Insert of the Trigger to parse the Tracking Number
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/

    public static void parseTrackingNumber(List<EmailMessage> lstMessage)
    {
        String Result = null;
        Set<Id> deleteCaseIds = new Set<Id>();
        Set<String> strPatternSet = new Set<String>();
        List<Case> lstCase = new List<Case>();
        List<Case> updateCase = new List<Case>();
        List<Case> NoExistingCodeCase = new List<Case>();
        List<EmailMessage> NoExistingCode = new List<EmailMessage>();
        Map<String,Id> mapTCClosedCase = new Map<String,Id>();
        Map<Id,String> mapNoMatchedCase = new Map<Id,String>();
        Map<String,Id> mapTrackingCodeCase = new Map<String,Id>();
        Map<EmailMessage,String> mapEMTrackingCode = new Map<EmailMessage,String>();
		Boolean parentCaseUpdated = false;
        List<Case> reopenCase = new List<Case>();
        Map<String,String> mapTrackingMessageId = new Map<String,String>();
        
        for(EmailMessage objEM : lstMessage){
            String content = null;
            if(objEM.Subject != null){
                content =  objEM.Subject;
            }
            if(objEM.TextBody != null){
                content = content + objEM.TextBody;
            }
             if(objEM.FromAddress != null && objEM.FromAddress.contains(System.Label.Label_EmailFrom_Indico) && objEM.Subject == System.Label.Label_EMAILSUBJECT)
            {
              objEM.ByPassGRByFilter__c = true;
              
            }
            // Run for Incoming Email Message and Search for the Tracking Pattern
           if(objEM.Incoming && !lstEmailMessages.contains(objEM) && !content.contains(str_REF)){
                if(content != null){
                    Matcher patternMatch = Pattern.compile(trackingNumberPattern).matcher(content);
                    while (patternMatch.find()) {
                        result = patternMatch.group();
                        if(Result != null){
                            mapEMTrackingCode.put(objEM,result);
							mapTrackingMessageId.put(objEM.MessageIdentifier,result);
                            strPatternSet.add(result);
							objEM.To_Be_Closed__c = True;
                        }
                        break;   
                    } 
                }
            }
        }
        
        // If Pattern found in the Email, Then search for the pattern in the existing cases.
        if(strPatternSet.size()>0){
            lstCase = [Select Id, Email_Tracking_Number__c, Tracking_Number__c, Status,(select OldValue, NewValue from Histories where field = 'Status' order by CreatedDate desc limit 1),ClosedDate  from Case where Email_Tracking_Number__c IN :strPatternSet AND Email_Tracking_Number__c != null 
                       order by CreatedDate];
            
            //If Case is found, then create map of Tracking Number and Case
            if(lstCase.size()>0){
                for(Case objCase : lstCase){
                    if(!mapTrackingCodeCase.containsKey(objCase.Email_Tracking_Number__c) && objCase.Status != Constant_Util.CLOSED ){
                        mapTrackingCodeCase.put(objCase.Email_Tracking_Number__c, objCase.Id);
                    }
                    
                    if(objCase.Status == Constant_Util.CLOSED){
                        //mapTCClosedCase.put(objCase.Email_Tracking_Number__c, objCase.Id);
                        Long closetime = (System.now().getTime()-objCase.ClosedDate.getTime())/3600000;
                        if(closetime <= Integer.valueOf(System.label.CaseReopenTime))
                        {
                           objCase.status = String.valueOf(objCase.Histories[0].OldValue);
                           objCase.Close_Irrelevant_Case__c = false;
                           objCase.Close_Case_Reason__c= '';
                           reopenCase.add(objCase);
                            if(!mapTrackingCodeCase.containsKey(objCase.Email_Tracking_Number__c))
                            {
                                mapTrackingCodeCase.put(objCase.Email_Tracking_Number__c, objCase.Id);
                            }
                            
                        }
                        else
                        {
                            mapTCClosedCase.put(objCase.Email_Tracking_Number__c, objCase.Id);
                        }
                    }
                }
                if(!reopenCase.isEmpty())
                {
                    Update reopenCase;
                }
                
            } else {
                parseWONumber(lstMessage);
            }
        } else {
       parseWONumber(lstMessage);
        }
        String GenesysUserId;
        GenesysUserId = (Generic_Values__mdt.getInstance(Constant_Util.GENESYSUSER) != null)
                        ? Generic_Values__mdt.getInstance(Constant_Util.GENESYSUSER).Id__c : null;

        // Existing Case found for Email Message with Tracking Number. Reparent the Email Message, Create Task and Genesys Payload.
        for(EmailMessage objEM : mapEMTrackingCode.keyset()){
            String Code = mapEMTrackingCode.get(objEM);
			if(code == null)
            {
                code = mapTrackingMessageId.get(objEM.MessageIdentifier);
            }
            if(mapTrackingCodeCase.get(Code) != null){
               if(objEM.ParentId != mapTrackingCodeCase.get(Code)){
                    deleteCaseIds.add(objEm.ParentId);
                }
                objEM.ParentId = mapTrackingCodeCase.get(Code);
                objEm.Bypass_Genesys_Task__c = true;
                objEm.Tracking_Number_Email__c = true;
                //Changes related to SDT-48088
                objEm.RelatedToId = null;   
				parentCaseUpdated = true;
            }
            else{
                // No Existing Case found for the Tracking Number
                mapNoMatchedCase.put(objEM.ParentId, Code);
                if(mapTCClosedCase.get(Code) != null){
                   objEm.Bypass_Genesys_Task__c = false;
                } 
                else{
                    objEm.Bypass_Genesys_Task__c = true;
                }
            }
        }
        
        List<case> lstDeleteCases = new List<Case>();
        
        // Delete the Email to Case created cases
        if(deleteCaseIds.size() >0)
        {
           lstDeleteCases = [Select Id,Status from Case where Id IN: deleteCaseIds AND Status =: Constant_Util.STATUS_NEW];
            delete lstDeleteCases; 
        }
        
        //Generic User Call for Assignment of Case
        Generic_Values__mdt objGV = new Generic_Values__mdt();
        String userId = (Generic_Values__mdt.getInstance(Constant_Util.GROUPUSER) != null)
                        ? Generic_Values__mdt.getInstance(Constant_Util.GROUPUSER).Id__c : null;

        //No Existing Case found
        if(mapNoMatchedCase != null){
          NoExistingCodeCase = [Select Id, OwnerId, Acorn_Ticket_Not_Matched__c, Routing_Counter__c, Tracking_Number__c, Email_Tracking_Number__c from Case 
                              where Id IN: mapNoMatchedCase.keySet()];
        }
        
        // Create a new Case, Add it in the queue to search for 10, 20 intervals of the time.
        for(Case objCase : NoExistingCodeCase){
            
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
        }
		
        //This code is not bulkified if tracking number not found above
		if(!parentCaseUpdated){
			parseReferenceNumber(lstMessage);
		}
    }

	/*************************************************************
    @Description: This method is called for when tracking search failed and it tries to search reference number in the subject
    @param :objectName EmailMessage List<EmailMessage>
    @return:void

    **************************************************************/
	public static void parseReferenceNumber(List<EmailMessage> lstMessage){
        List<Case> lstCase = new List<Case>();
        Set<String> allMatchedCaseNumber = new Set<String>();
        Map<EmailMessage,Set<String>> mapEMCaseNumber = new Map<EmailMessage,Set<String>>();
		List<Case> refCaseReopen = new List<Case>();
		List<Id> delRefParentId = new List<Id>();
        
        for(EmailMessage objEM : lstMessage){
            // Run for Incoming Email Message and Search for the Case Number in the subject
            if(objEM.Incoming && objEM.Subject != null &&  (objEM.TextBody == null || !objEM.TextBody.contains(str_REF))){
                Matcher patternMatch = Pattern.compile(caseNumberPattern).matcher(objEM.Subject);
                Set<String> strPatternCaseNumberSet = new Set<String>();
                while (patternMatch.find()) {
                    String caseNumberResult = patternMatch.group();
                    if(caseNumberResult != null){
                        strPatternCaseNumberSet.add(caseNumberResult.trim());
                        allMatchedCaseNumber.add(caseNumberResult.trim());
                    }
                } 
                if(!strPatternCaseNumberSet.isEmpty()) {
                    mapEMCaseNumber.put(objEM,strPatternCaseNumberSet);
                }                       
            }
        }
        
		 Map<EmailMessage , String> emCaseMap = new Map<EmailMessage , String>();
        // If Case Number Pattern found in the Email Subject, Then search for the pattern in the existing cases.
        if(mapEMCaseNumber.size()>0){
            lstCase = [Select Id, Email_Tracking_Number__c, Tracking_Number__c, Status, CaseNumber,(select OldValue, NewValue from Histories where field = 'Status' order by CreatedDate desc limit 1),ClosedDate  from Case where CaseNumber IN :allMatchedCaseNumber 
                       order by CreatedDate];
            
            //If Case is found, then create map of Tracking Number and Case
            if(lstCase.size()>0){
                for(Case cas : lstCase){
                    for(EmailMessage em: mapEMCaseNumber.keySet()){
                        Long closetime = 25;
                        if(mapEMCaseNumber.get(em).contains(cas.CaseNumber) && cas.Status != Constant_Util.CLOSED){
                            emCaseMap.put(em , cas.Id);
                        }
                        else if(mapEMCaseNumber.get(em).contains(cas.CaseNumber) && cas.Status == Constant_Util.CLOSED)
                        {
                            closetime = (System.now().getTime()-cas.ClosedDate.getTime())/3600000;
                        }
                        
                        if(mapEMCaseNumber.get(em).contains(cas.CaseNumber) && cas.Status == Constant_Util.CLOSED && closetime <= Integer.valueOf(System.label.CaseReopenTime)){
                            emCaseMap.put(em , cas.Id);
                            cas.status = String.valueOf(cas.Histories[0].OldValue);
                           	cas.Close_Irrelevant_Case__c = false;
                           	cas.Close_Case_Reason__c= '';
                          	refCaseReopen.add(cas);
                        }
                    }
                }
            }  
        }
		if(!refCaseReopen.isEmpty())
        {
            update refCaseReopen;
        }
        for(EmailMessage objEM : emCaseMap.keyset()){
            String casId = emCaseMap.get(objEM);
			if(objEM.ParentId !=  casId){
                delRefParentId.add(objEM.ParentId);
            }
			objEM.ParentId = casId;
			objEm.Bypass_Genesys_Task__c = false;
             //Changes related to SDT-48088
            objEm.RelatedToId = null; 
			objEM.To_Be_Closed__c = True;
        }
		if(!delRefParentId.isEmpty()){
            Database.delete(delRefParentId, false);
        }	
    }
	
/*************************************************************
@Description: This method is called for Before Insert of the Trigger to parse the workorder Number
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/
    public static void parseWONumber(List<EmailMessage> lstMessage)
    {
        String woNumberPattern ='W{1}[0-9]{8}[0-9]?';
		String Result = null;
        Set<Id> deleteCaseIds = new Set<Id>();
        Set<String> strPatternSet = new Set<String>();
        List<Case> lstCase = new List<Case>();
        List<Case> updateCase = new List<Case>();
        List<Case> NoExistingCodeCase = new List<Case>();
        List<EmailMessage> NoExistingCode = new List<EmailMessage>();
        Map<String,Id> mapTCClosedCase = new Map<String,Id>();
        Map<Id,String> mapNoMatchedCase = new Map<Id,String>();
        Map<String,Id> mapTrackingCodeCase = new Map<String,Id>();
        Map<EmailMessage,String> mapEMTrackingCode = new Map<EmailMessage,String>();
		List<Case> reopenWoCase = new List<Case>();
        Map<String,String> mapWorkOrderMessageId = new Map<String,String>();
        
        for(EmailMessage objEM : lstMessage){
            String content = null;
            if(objEM.Subject != null){
                content =  objEM.Subject;
            }
            if(objEM.TextBody != null){
                content = content + objEM.TextBody;
            }
            
            // Run for Incoming Email Message and Search for the Tracking Pattern
            if(objEM.Incoming && !lstEmailMessages.contains(objEM) && !content.contains(str_REF)){  
                if(content != null){
                    Matcher patternMatch = Pattern.compile(woNumberPattern).matcher(content);
                    while (patternMatch.find()) {
                        result = patternMatch.group();
                        if(Result != null){
                            mapEMTrackingCode.put(objEM,result);
                            strPatternSet.add(result);
							objEM.To_Be_Closed__c = True;
							mapWorkOrderMessageId.put(objEM.MessageIdentifier,result);
                        }
                        break;   
                    } 
                }
            }
        }
        
        // If Pattern found in the Email, Then search for the pattern in the existing cases.
        if(strPatternSet.size()>0){
            lstCase = [SELECT Id, Work_Order__r.Acorn_WorkOrder_Number__c, Status,(select OldValue, NewValue from Histories where field = 'Status' order by CreatedDate desc limit 1),ClosedDate FROM Case WHERE Work_Order__r.Acorn_WorkOrder_Number__c IN :strPatternSet  
                       order by CreatedDate];
            
            //If Case is found, then create map of Tracking Number and Case
            if(lstCase.size()>0){
                for(Case objCase : lstCase){
                    if(!mapTrackingCodeCase.containsKey(objCase.Work_Order__r.Acorn_WorkOrder_Number__c) && objCase.Status != Constant_Util.CLOSED ){
                        mapTrackingCodeCase.put(objCase.Work_Order__r.Acorn_WorkOrder_Number__c, objCase.Id);
                    }
                    // Store the Case with the Closed Status in a Map
                    if(objCase.Status == Constant_Util.CLOSED){
                        Long closetime = (System.now().getTime()-objCase.ClosedDate.getTime())/3600000;
                        if(closetime <= Integer.valueOf(System.label.CaseReopenTime))
                        {
                           objCase.status = String.valueOf(objCase.Histories[0].OldValue);
                           objCase.Close_Irrelevant_Case__c = false;
                           objCase.Close_Case_Reason__c= '';
                           reopenWoCase.add(objCase);
                            if(!mapTrackingCodeCase.containsKey(objCase.Work_Order__r.Acorn_WorkOrder_Number__c))
                            {
                                mapTrackingCodeCase.put(objCase.Work_Order__r.Acorn_WorkOrder_Number__c, objCase.Id);
                            }
                            
                        }
                        else
                        {
                            mapTCClosedCase.put(objCase.Work_Order__r.Acorn_WorkOrder_Number__c, objCase.Id);
                        }
                    }
                }
                if(!reopenWoCase.isEmpty())
                {
                    update reopenWoCase;
                }
            }
        }
        String GenesysUserId;
        GenesysUserId = [SELECT Id, Id__c, DeveloperName FROM Generic_Values__mdt WHERE DeveloperName =: Constant_Util.GENESYSUSER].Id__c;
        
        // Existing Case found for Email Message with Tracking Number. Reparent the Email Message, Create Task and Genesys Payload.
        for(EmailMessage objEM : mapEMTrackingCode.keyset()){
            String Code = mapEMTrackingCode.get(objEM);
			if(code == null)
            {
                code = mapWorkOrderMessageId.get(objEM.MessageIdentifier);
            }
            if(mapTrackingCodeCase.get(Code) != null){
                if(objEM.ParentId != mapTrackingCodeCase.get(Code)){
                    deleteCaseIds.add(objEm.ParentId);
                }
                objEM.ParentId = mapTrackingCodeCase.get(Code);
                objEm.Bypass_Genesys_Task__c = true;
                objEm.Tracking_Number_Email__c = true;
                       //Changes related to SDT-48088
            objEm.RelatedToId = null; 
			objEm.To_Be_Closed__c = True;
            }
            else{
                // No Existing Case found for the Tracking Number
                mapNoMatchedCase.put(objEM.ParentId, Code);
                if(mapTCClosedCase.get(Code) != null){
                    objEm.Bypass_Genesys_Task__c = false;
                } 
                else{
                    objEm.Bypass_Genesys_Task__c = true;
                }
            }
        }
        List<case> lstDeleteCases = new List<Case>();
        // Delete the Email to Case created cases
        if(deleteCaseIds.size() >0)
        {
            lstDeleteCases = [SELECT Id,Status FROM Case WHERE Id IN: deleteCaseIds AND Status =: Constant_Util.STATUS_NEW];
            delete lstDeleteCases; 
        }
        
        //Generic User Call for Assignment of Case
        Generic_Values__mdt objGV = new Generic_Values__mdt();
        String userId = [SELECT Id,Id__c,DeveloperName FROM Generic_Values__mdt WHERE DeveloperName =: Constant_Util.GROUPUSER ].Id__c;
        
        //No Existing Case found
        if(mapNoMatchedCase != null){
            NoExistingCodeCase = [SELECT Id, OwnerId, Acorn_Ticket_Not_Matched__c, Routing_Counter__c, Work_Order__r.Acorn_WorkOrder_Number__c FROM Case 
                                  WHERE Id IN: mapNoMatchedCase.keySet()];
        }
        
        // Create a new Case, Add it in the queue to search for 10, 20 intervals of the time.
        for(Case objCase : NoExistingCodeCase){
            
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
        }
    }
       
/*************************************************************
@Description: This method is called for Before Insert of the Trigger to check EmailMessage Without ReferenceNo
@param :objectName EmailMessage List<EmailMessage>
@return:void

**************************************************************/
    public static void checkEMWithOutReferenceNo(List<EmailMessage> lstMessage) {
        Set<Id> deleteCaseIds = new Set<Id>();
        Set<Id> lstUpdateCase = new Set<Id>();
        Map<String, EmailMessage> existingMsgMap = getExistingEmailMessage(lstMessage);

        for(EmailMessage objMessage : lstMessage) {    
			String content = null;
				if(objMessage.Subject != null){
					content =  objMessage.Subject;
				}
				if(objMessage.TextBody != null){
					content = content + objMessage.TextBody;
				}
            String messageToId;
            
            //Search for Message Id
            if(objMessage.Incoming && objMessage.Headers != null  && objMessage.Headers.Contains(str_MESSAGE_ID))
            {
                Integer startChar = objMessage.Headers.indexOf(str_MESSAGE_ID)+13;
                Integer endChar = objMessage.Headers.indexOf(str_AT,startChar);
                messageToId = objMessage.Headers.substring(startChar, endChar);
                objMessage.Message_ID__C = messageToId;
            }

            //Set flag as false if messageId is still null
            if(objMessage.Incoming && string.isBlank(objMessage.Message_ID__C)){
                objMessage.To_Be_Processed__c = false;
            }

            if(objMessage.Incoming  && RecurrsiveTriggerHandler.getRunTimes() < 1  && !content.contains(str_REF)) {          
                RecurrsiveTriggerHandler.setRunTimes();
    
                //Search for Reply Id
                if(objMessage.Headers != null  && objMessage.Headers.Contains(str_REPLYTO_ID) )
                {
                    Integer startCharReply = objMessage.Headers.indexOf(str_REPLYTO_ID)+14;
                    Integer endCharReply = objMessage.Headers.indexOf(str_AT,startCharReply);
                    String replyToId = objMessage.Headers.substring(startCharReply, endCharReply);                   
                    //Search Existing Case
                    if(existingMsgMap != null && existingMsgMap.keySet().contains(replyToId))
                    {	
                        objMessage.In_Reply_To_ID__C = replyToId;
                        if(objMessage.ParentId != existingMsgMap.get(replyToId).RelatedToId ){
                            deleteCaseIds.add(objMessage.ParentId);
                        }
                        objMessage.ParentId = existingMsgMap.get(replyToId).ParentId;
                        objMessage.RelatedToId = existingMsgMap.get(replyToId).RelatedToId;
                        objMessage.Tech_New_Case__c = false;
                        lstEmailMessages.add(objMessage);
                    } 
                    
                }
                                                
            }else if(objMessage.Incoming && RecurrsiveTriggerHandler.getRunTimes() < 1 && content.contains(str_REF)) {
            		RecurrsiveTriggerHandler.setRunTimes(); //Need to check setRuntimes method should be invoked before for or inside for. Going now as per existing logic.
                    objMessage.In_Reply_To_ID__C = str_REF;
            }
        }
         
        List<case> lstDeleteCases = new List<Case>();
        if(deleteCaseIds.size() >0)
        {
            lstDeleteCases = [Select Id,Status from Case where Id IN: deleteCaseIds And Status =: Constant_Util.STATUS_NEW];
            delete lstDeleteCases; // uncommented as part of SDT-18110
        }
    }
    

/*************************************************************
@Description: This method is used to create the Existing Reply-MessageId 
@param :objectName EmailMessage List<EmailMessage>
@return: Map<String, EmailMessage>

				  

**************************************************************/    
    
    private static Map<String, EmailMessage> getExistingEmailMessage(List<EmailMessage> lstMessage)
    {
        Set<String> replyToIDSet = new Set<String>();
        Map<String, EmailMessage> msgMap= new Map<String, EmailMessage>();
        for(EmailMessage objMessage : lstMessage)
        {
            if(objMessage.Headers != null && objMessage.Headers.Contains(str_REPLYTO_ID))
            {
                Integer startCharReply = objMessage.Headers.indexOf(str_REPLYTO_ID)+14;
                Integer endCharReply = objMessage.Headers.indexOf(str_AT,startCharReply);
                String replyToId = objMessage.Headers.substring(startCharReply, endCharReply);
                replyToIDSet.add(replyToId);
            }
        }
        if(replyToIDSet != null)
        {
            List<EmailMessage> existingCaseEmailList = [SELECT Id,In_Reply_To_ID__c, CreatedDate, Message_ID__c,ParentId,RelatedToId FROM 
                                                        EmailMessage where DAY_ONLY(CreatedDate) >= LAST_N_DAYS:90 and  Message_ID__c in: replyToIDSet AND ParentId != null
                                                        AND Parent.Status !=: Constant_Util.Closed order by Parent.CaseNumber ASC];
            for(EmailMessage objMessage : existingCaseEmailList)
            {
                if(!msgMap.containsKey(objMessage.Message_ID__c)){
                    msgMap.put(objMessage.Message_ID__c, objMessage);
                }
            }
        }
        return msgMap;
    }
   

/*************************************************************
@Description: This method is used to check EmailMessage ForServiceConfirmed 
@param :objectName EmailMessage List<EmailMessage>
@return: void

**************************************************************/ 

    public static void checkEMForServiceConfirmed(List<EmailMessage> lstMessage){
        list<case> caseList= new list<case>();
        list<task> taskList= new list<task>();
        
        map<string,string> mapOfCaseIdWithEmailMessage= new map<string,string>();
        
        for(EmailMessage objMessage : lstMessage)
        {          
            if(objMessage.Incoming  && RecurrsiveTriggerHandler.getRunTimes() < 2)
            {                
                RecurrsiveTriggerHandler.setRunTimes();
				if(objMessage.subject != null)
                {
                if(objMessage.subject.contains(Constant_Util.SERVICE_CONFIRMED) || objMessage.subject.contains(Constant_Util.SERVICE_NOT_PERFORMED)){
                    objMessage.Bypass_Genesys_Task__c= false;
                    if(objMessage.parentId !=null){
                        mapOfCaseIdWithEmailMessage.put(objMessage.parentId,objMessage.subject);                        
                    }
                }
				}
            }
        }
        if(mapOfCaseIdWithEmailMessage.keySet().size() > 0){
            caseList = [select id, (SELECT Id,Process__c,Outcome__c, subject FROM Tasks where TaskSubtype='Task' order by Createddate desc LIMIT 1) from case where ID IN :mapOfCaseIdWithEmailMessage.keySet()];
            
            for(Case casObj :caseList){
                for(Task tskObj :casObj.tasks){
                    if(tskObj.Process__c!=null && tskObj.Process__c!=''){
                        if(tskObj.Process__c==Constant_Util.CONFIRM_SERVICE_COMPLETION_LOCATION){
                            if(mapOfCaseIdWithEmailMessage.get(casObj.id).contains(Constant_Util.SERVICE_CONFIRMED)){                            
                                tskObj.outcome__c= Constant_Util.SERVICE_CONFIRMED;
                            }else{                            
                                tskObj.outcome__c= Constant_Util.SERVICE_NOT_PERFORMED;
                            }
                            
                            taskList.add(tskObj);                            
                        }
                    }    
                }
            }
        }
        if(taskList.size() > 0){ 
            Database.update(taskList,false);            
        }
        
    }
    
 
/*************************************************************
@Description: This method is used to handle closed caseMessage
@param :objectName EmailMessage List<EmailMessage>
@return: void

**************************************************************/   
    
    public static void handleClosedCaseMessage(List<EmailMessage> msgs)
    {
        List<EmailMessage> emailWithRFNo = new List<EmailMessage>();
        List<String> refIdLst = new List<String>();
        list<EmailMessage> newMsglist = new list<EmailMessage>();
        for(EmailMessage msg : msgs)
        {   
            if(msg.Incoming){
                    emailWithRFNo.add(msg);
            }
        }
        if(emailWithRFNo.size() > 0){
            EmailsWithReferenceNo(emailWithRFNo);
        }
    }
    
/*************************************************************
@Description: Emails With ReferenceNo
@param :objectName EmailMessage List<EmailMessage>
@return: void

**************************************************************/
    
    public static void EmailsWithReferenceNo(List<EmailMessage> msgs)
    {
        Set<Id> setIds = new Set<Id>();
        List<Case> reopeningCase = new List<Case>();
        for(EmailMessage objEM : msgs){
            setIds.add(objEM.ParentId);
        }
        
        List<Case> caseList  = [Select Id, Status,(select OldValue, NewValue from Histories where field = 'Status' order by CreatedDate desc limit 1),ClosedDate from case where status = 'Closed' AND Id IN:setIds LIMIT 49999];
        List<Case> insertCases = new List<Case>();
        Map<Id,Case> mapIDCase = new Map<Id,Case>();
        Map<String,Id> mapSubjectCase = new Map<String,Id>();
        for(Case ObjCase : caseList){
            
            Long closedtime = (System.now().getTime()-ObjCase.ClosedDate.getTime())/3600000;
            if(closedtime <= Integer.valueOf(System.label.CaseReopenTime))
            {
                ObjCase.status = Test.isRunningTest() ? 'New' : String.valueOf(ObjCase.Histories[0].OldValue);
                ObjCase.Close_Irrelevant_Case__c = false;
                ObjCase.Close_Case_Reason__c= '';
                reopeningCase.add(ObjCase);
            }
            else
            {
               mapIDCase.put(objCase.Id, objCase); 
            }
        }
        if(!reopeningCase.isEmpty())
        {
            update reopeningCase;
        }
        List<Case> insertCase = new List<Case>();
        for(EmailMessage msg : msgs)
        {   
            if(mapIDCase.containsKey(msg.ParentId))
            {
                Case newCase = new Case(Subject = msg.Subject, Origin = 'Email', SuppliedEmail = msg.FromAddress);
                insertCases.add(newCase);
            }
            else
            {
                msg.Tech_New_Case__c = false;
            }
            
        }
        if(insertCases.size()>0){
            Database.insert(insertCases);
            for(Case objCase : insertCases){
                mapSubjectCase.put(objCase.Subject,objCase.Id);    
            }
            for(EmailMessage msg : msgs){
                if(mapSubjectCase.containskey(msg.Subject)){
                    msg.ParentId = mapSubjectCase.get(msg.Subject);
                    msg.relatedtoId = mapSubjectCase.get(msg.Subject);
                    msg.ActivityId = null;
                    msg.To_Be_Closed__c = True;
                    
                } 
            }
        }
    }
   
/*************************************************************
@Description: This method is to update 'From Address' of Email when email is being forwarded(For Email TO Quote)
@param :objectName EmailMessage List<EmailMessage>
@return: void

**************************************************************/
    public static void updateFromAddress(List<EmailMessage> lstEmailMessage){
        
        if(lstEmailMessage != null){
        for(EmailMessage eml : lstEmailMessage){
                      
            if(eml.Subject != null && eml.Subject.contains('##$$')){
                  
                String fromAddress = eml.Subject.substringAfter('##$$');
                eml.Subject = eml.Subject.substringbefore('##$$');                
                eml.FromAddress = fromAddress;
            }
        }
    }
  
    }     
/*************************************************************
@Description: This method is to prevent Delete of Email Message
@param :objectName EmailMessage List<EmailMessage>
@return: void

**************************************************************/    
 
    public static void preventDelete (List<EmailMessage> lstEmailMessage){
        Id currentUserId = UserInfo.getUserId();
        Id UserProfId = UserInfo.getProfileId();
		Id catProfId;
        Id adminProfId;
        List<Profile> adminprof = [SELECT Id, Name FROM Profile WHERE Name = :Constant_Util.SYSTEM_ADMINISTRATOR OR Name = 'Customer Account Team' LIMIT 2];
		if(adminprof[0].Name == 'Customer Account Team')
        {
            catProfId = adminprof[0].Id;
            adminProfId = adminprof[1].Id;
        }
        else
        {
            catProfId = adminprof[1].Id;
            adminProfId = adminprof[0].Id;
        }
        for(EmailMessage eml : lstEmailMessage){
            if(userProfId != adminProfId && !eml.IsClientManaged){
                if(currentUserId == eml.CreatedById && eml.Status =='5'){
                    continue ; 
                }
                eml.addError('You do not have the ability to delete Email Message records.  Please see your System Administrator.');
            }
            else if(userProfId == catProfId && eml.IsClientManaged && currentUserId == eml.CreatedById)
            {
                if(eml.HourCreation__c > 1)
                {
                    eml.addError('Deletion is no longer available for this email.');
                }
            }
            else if(eml.IsClientManaged)
            {
                eml.addError('You do not have the ability to delete Email Message records.');
            }
        }
    }

/*************************************************************
@Description: This method is used for checking the Email With Alias
@param :objectName EmailMessage List<EmailMessage>
@return: void

**************************************************************/    
    public static Void checkEmailWithAlias(List<EmailMessage> lstEmailMessage){
        
        try{
            set<string> owaSet = new set<String>();
            map<string,Integer> aliasCountermap = new map<String,Integer>();
            for(Email_Alias__mdt ea : Email_Alias__mdt.getAll().values()){
               owaSet.add(ea.Label);
            }
            if(!lstEmailMessage.isEmpty() && lstEmailMessage.size() > 0 && owaSet != null && owaSet.size() > 0){
                integer counter = 0;
                for(EmailMessage em : lstEmailMessage){
                    counter = 0;
                    system.debug('###'+em.In_Reply_To_ID__c);
                    for(String dl : owaSet){
                        if((em.ToAddress != null && em.ToAddress.contains(dl)) || (em.BccAddress != null && em.BccAddress.contains(dl)) || (em.CcAddress != null && em.CcAddress.contains(dl))){
                            counter++;
                            if(counter > 1) {
                                em.To_Be_Processed__c = true;
                                continue;
                            }
                        }
                    }
                }
            }
        }catch(Exception ex){
            //To handle Error in future Sprints
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
     
/*************************************************************
@Description: Method to check if EmailMessage needs Indico Processing
@param :objectName EmailMessage List<EmailMessage>
@return: void

**************************************************************/ 
    public static Void checkIndicoEmailMessage(List<EmailMessage> lstEmailMessage){
        
        try{           
            
            if(!lstEmailMessage.isEmpty() && lstEmailMessage.size() > 0){              
            
                for(EmailMessage em : lstEmailMessage){

                List<EmailMessage> emlst =[Select id from EmailMessage where ParentId =: em.ParentId];
				Case cs = [Select id,Email_Tracking_Number__c,Work_Order__c from Case where Id =: em.ParentId LIMIT 1];
                    
					Boolean isEmailExist = checkIndicoEmailFilter(em);                    
		   // if(emlst.isEmpty() && isEmailExist  && !em.ByPassGRByFilter__c && !em.Tracking_Number_Email__c && String.isBlank(cs.Email_Tracking_Number__c))
                    if(emlst.isEmpty() && isEmailExist  && !em.ByPassGRByFilter__c && ((!em.Tracking_Number_Email__c && String.isBlank(cs.Email_Tracking_Number__c))
                                                                                      || String.isBlank(cs.Work_Order__c)))
                    {
                        em.isIndicoEligible__c = true; 
                        em.IndicoStatus__c = Constant_Util.PENDINGINDICOPROCESSING;
                    }
                }	
                 
               }
            }        
        catch(Exception ex){
            //To handle Error in future Sprints
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    

/*************************************************************
@Description: This method is used for checking the Email With Indico FIlter
@param :objectName EmailMessage 
@return: Boolean

**************************************************************/     
public static Boolean checkIndicoEmailFilter(EmailMessage em){
        
    Boolean isEmailExist = false;
    try{
        set<string> indicoEmailSet = new set<String>();
    
        for(IndicoEmailMessageFilter__c ea : [Select Id,FilterConditionColumnName__c,FilterConditionValue__c from IndicoEmailMessageFilter__c ]){
            indicoEmailSet.add(ea.FilterConditionValue__c);
        }
       
            for(String indicoFilterId : indicoEmailSet){

                indicoFilterConditionColName = (em.ToAddress != null && em.ToAddress.contains(indicoFilterId))? 'ToAddress':  (em.BccAddress != null && em.BccAddress.contains(indicoFilterId))?'BccAddress': (em.CcAddress != null && em.CcAddress.contains(indicoFilterId))?'CcAddress':'';
                
                if(String.isNotBlank(indicoFilterConditionColName))
                {
                String emailAddresses = (String)em.get(indicoFilterConditionColName);
                List<String> emailList = emailAddresses.split(';');
                List<String> indicoEmailList = new List<string>();
                
                for(String email: emailList){indicoEmailList.add(email.trim());}                
                
                if(indicoEmailList.contains(indicoFilterId)){
                        isEmailExist = true;                          
                        indicoFilterConditionColValue= indicoFilterId;                       
                        continue;                     
                    }
                } 
            }
            }catch(Exception ex){
                //To handle Error in future Sprints
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
 
    return isEmailExist;
}
 

/*************************************************************
@Description: This method is used to createSFDCEmailMessageForIndico
@param :objectName EmailMessage  Map<Id,EmailMessage>
@return: void

**************************************************************/     
     public static void createSFDCEmailMessageForIndico(Map<Id,EmailMessage> newMap){
        
        List<SFDCEmailMessage__c> sfdcEmailMsg = new List<SFDCEmailMessage__c>();
         
         IndicoEmailMessageFilter__c indicoEmailType = [Select Type__c from IndicoEmailMessageFilter__c where FilterConditionValue__c = :indicoFilterConditionColValue LIMIT 1];
         
         for(EmailMessage emsg:newMap.values()){
             
             SFDCEmailMessage__c smsg = new SFDCEmailMessage__c();
             smsg.EmailMessageId__c = emsg.id;
             smsg.SFDCEmailMessageFromAddress__c = emsg.FromAddress;
             smsg.SFDCEmailMessageToAddress__c= emsg.ToAddress;
             smsg.SFDCEmailMessageCcAddress__c= emsg.CcAddress;
             smsg.SFDCEmailMessageSubject__c =emsg.Subject;
             smsg.SFDCEmailMessageCcAddress__c= emsg.CcAddress;
             smsg.SFDCEmailMessageParentId__c =emsg.ParentId;
             smsg.SFDCEmailMessageTextBody__c = emsg.TextBody;
             smsg.SFDCEmailMessageType__c = indicoEmailType.Type__c;
             smsg.SFDCEmailMessageParentCaseNumber__c = emsg.Parent.CaseNumber;
             smsg.SFDCEmailMessageParentReferenceNumber__c = emsg.Parent.Reference_Number__c;
             sfdcEmailMsg.add(smsg);             
         }
         
           if(!sfdcEmailMsg.isEmpty()){
            try{
                Database.insert(sfdcEmailMsg);
            }Catch(Exception ex){
                UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            }
        }
    }
	

/*************************************************************
@Description: Method to stop Genesys task creation for Mailer-Daemon emails
@param :objectName EmailMessage  List<EmailMessage>
@return: void

**************************************************************/    
    public static Void stopGenesysTaskMailerDaemon(List<EmailMessage> lstEmailMessage)
    {
        try{
            if(!lstEmailMessage.isEmpty())
            {               
                for(EmailMessage em : lstEmailMessage)
                {
                    if(em.Incoming && em.FromAddress.contains(Constant_Util.NO_TASK_GENESYS_EMAIL))
                    {
                        em.Bypass_Genesys_Task__c = true;
                    }
					if(em.IsClientManaged)
                    {
                        em.Bypass_Genesys_Task__c = true;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }	

     /**@MethodName createCaseComment
    * Method to create Comment related to Case for SDT-18820
    **/
    public Static void createCaseComment(Map<String ,List<EmailMessage>> commentEmailMap){
        
        Map<String , Comment_Log_Detail__mdt> commentLogTemplateData = new Map<String , Comment_Log_Detail__mdt>();
        for(Comment_Log_Detail__mdt c : Comment_Log_Detail__mdt.getAll().values()){
            commentLogTemplateData.put(c.DeveloperName , c);
        }
        Map<String , String> fieldTemplateMap = new Map<String , String>();
        List<Comment__c> commentList = new List<Comment__c>();
        Set<String> dateTimeFields = new Set<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('EmailMessage');
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
        for(Schema.SObjectField field : fieldMap.values()) {
            fieldTemplateMap.put('<' + field.getDescribe().getName() + '>' , field.getDescribe().getName());
            if(field.getDescribe().getType() == Schema.DisplayType.DateTime || field.getDescribe().getType() == Schema.DisplayType.Date){
                dateTimeFields.add('<' + field.getDescribe().getName() + '>');
            }   
        }
        try {
            for(String key : commentEmailMap.keySet()){
                for(EmailMessage em : commentEmailMap.get(key)){
                    String commentBody = commentLogTemplateData.containsKey(key) ? commentLogTemplateData.get(key).Comment__c : '';
                    Comment__c comment = new Comment__c();
                    comment.Case__c = em.ParentId;
                    for(String field : fieldTemplateMap.keySet()){
                        if(fieldTemplateMap.get(field) != null && commentBody.contains(field)) {
                            String fieldValue = '';
                            if(field == '<Subject>'){
                                if(em.get(fieldTemplateMap.get(field)) == null) {
                                    fieldValue = '';
                                }
                                else if(String.valueOf(em.get(fieldTemplateMap.get(field))).length() > 50){
                                   fieldValue = String.valueOf(em.get(fieldTemplateMap.get(field))).subString(0 , 50) + '...';
                                } else {
                                    fieldValue = String.valueOf(em.get(fieldTemplateMap.get(field)));
                                }
                            }
                            else if(dateTimeFields.contains(field)){
                                fieldValue = em.get(fieldTemplateMap.get(field)) != null ? Date.valueOf(em.get(fieldTemplateMap.get(field))).format() : '';
                            } else {
                                fieldValue = em.get(fieldTemplateMap.get(field)) != null ? String.valueOf(em.get(fieldTemplateMap.get(field))) : '';
                            }
                            commentBody = commentBody.replaceAll(field , fieldValue);
                        }   
                    }
                    comment.Comment__c = commentBody;
                    comment.Workflow_Action__c = Constant_Util.EMAIL_ACTION_TYPE;
                    comment.Related_SObject_Id__c = em.id;
                    comment.Related_SObject_Key__c = em.Subject != null ? (em.Subject.length() > 50 ? em.Subject.subString(0 , 50) + '...' :  em.Subject) : '';
                    comment.CreatedDate = System.now();
                    comment.is_Log__c = true;
                    commentList.add(comment);
                }
            }
			 Database.saveResult[] insertResult = Database.insert(commentList, false);

        } catch(exception excp){
            UTIL_LoggingService.logHandledException(excp, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
       /*************************************************************
    @Description: Method to update the subject of outgouing email 
                from the subject of the email from where reply is done.
    @param :objectName Set<String> , EmailMessage  List<EmailMessage>
    @return: void

    **************************************************************/    
    public static void updateSubject(List<EmailMessage> lstEmailMessage , Map<Id, EmailMessage> oldMap) {
        try{
            Set<String> replyMessageIdSet = new Set<String>();
            for(EmailMessage msg : lstEmailMessage){
                if(msg.ParentId != null && msg.ParentId.getSObjectType().getDescribe().getName() == 'Case' && !msg.QuickEmail__c){
                    replyMessageIdSet.add(msg.ReplyToEmailMessageId);
                }      
            }

            Map<Id , EmailMessage> emMap = new Map<Id , EmailMessage>([Select Id, Subject FROM EmailMessage WHERE ID IN :replyMessageIdSet]);

            for(EmailMessage em : lstEmailMessage){
                if(emMap.containsKey(em.ReplyToEmailMessageId)){
                    em.Subject = emMap.get(em.ReplyToEmailMessageId) != null ? emMap.get(em.ReplyToEmailMessageId).Subject : em.Subject;
                }
            }    
        }
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }	

    /*************************************************************
@Description: sentChatNowAutoReply
@param : EmailMessage  List<EmailMessage>
@return: void
@User Story: SDT-25807
@Author : 

**************************************************************/  
    
    public static void sentChatNowAutoReply(List<EmailMessage> lstEmailMessage){
        try{
            List<String> fromAdd = new List<String>();
            List<Id> caseId = new List<Id>();
            Map<String,Boolean> metaMap = new Map<String,Boolean>();
            Map<String,Boolean> metaMapToEmail = new Map<String,Boolean>();
            Map<String,Boolean> finalEmailMap = new Map<String,Boolean>();
            Map<Id,String> caseAutoEmailMap = new Map<Id,String>();
            Map<String,Id> emailContaMap = new Map<String,Id>();
            Map<String,EmailMessage> fromAddEmailMessageMap = new Map<String,EmailMessage>();
			List<String> identifiedThread = new List<String>();
            
            List<Emails_to_Exclude_ChatNow_AutoReply__mdt> chatNowMeta = Emails_to_Exclude_ChatNow_AutoReply__mdt.getAll().values();
            
            for(Emails_to_Exclude_ChatNow_AutoReply__mdt meta : chatNowMeta)
            {
                
                if(meta.Domain__c){
                    metaMap.put(meta.Label.toUpperCase(), meta.Send_Auto__c);
                }else if(meta.To_Email__c){
                    metaMapToEmail.put(meta.Label.toUpperCase(), meta.Send_Auto__c);
                }
            }
            
            for(EmailMessage em : lstEmailMessage)
            {
                if(em.Incoming)
                {
                    fromAdd.add(em.FromAddress.toUpperCase());
                    caseId.add(em.ParentId);
                    caseAutoEmailMap.put(em.ParentId,em.FromAddress.toUpperCase());
                    finalEmailMap.put(em.FromAddress.toUpperCase(),true);
                    emailContaMap.put(em.FromAddress.toUpperCase(), em.ParentId);
                    fromAddEmailMessageMap.put(em.FromAddress.toUpperCase(),em);
					identifiedThread.add(em.Id);
                }
            }
            
            
            if(finalEmailMap.size() > 0)
            {
                finalEmailMap = validateCase(caseId,metaMap,finalEmailMap,caseAutoEmailMap);
            }
            if(finalEmailMap.size() > 0)
            {
                finalEmailMap = validateFromAddress(fromAdd,metaMap);
                
            }
            if(finalEmailMap.size() > 0)
            {
              
                finalEmailMap = validateToAddress(metaMapToEmail,finalEmailMap,fromAddEmailMessageMap);
            }
            Map<String,Id> contMapEmailSend = findOrInsertContact(finalEmailMap.keySet());
            if(contMapEmailSend.size() > 0)
            {
                sendAutoEmail(contMapEmailSend,emailContaMap,identifiedThread);
            }
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
        
    }
    
    public static Map<String,Boolean> validateFromAddress(List<String> emailAdd, Map<String,Boolean> fromMetaMap){
       
        
        Map<String,Boolean> returnEmailMap = new Map<String,Boolean>();
        Map<String,Boolean> returnEmailMap2 = new Map<String,Boolean>();
        Map<String,Boolean> returnEmailMap3 = new Map<String,Boolean>();
        Map<String,Boolean> returnEmailMapFinal = new Map<String,Boolean>();
        for(String emp : emailAdd)
        {
            List<String> splitFromaddress = emp.split('@');
            if(!fromMetaMap.containsKey(splitFromaddress[1]))
            {
                returnEmailMap.put(emp,true);
                returnEmailMap2.put(emp,true);
               
            }
        }
      
        String chatNowEmailExcludeValue = System.Label.ChatNowEmailExcludeList;
        for(string excludevalue : chatNowEmailExcludeValue.split(';')){
            for(string email : returnEmailMap.keySet()){
                if(email.contains(excludevalue.toUpperCase()) &&  returnEmailMap2.containsKey(email) ){
                    returnEmailMap2.remove(email);
                }
            }
        }
        
        // exculed values form Domain. Contains
        if(!returnEmailMap2.isEmpty()){
            returnEmailMapFinal = returnEmailMap2.clone(); 
        }
        for(string email : returnEmailMap2.keySet()){
            for(string emailFromExludeList : fromMetaMap.keyset()){
                List<String> splitFromaddress = email.split('@');
                string emailDomain  = splitFromaddress[1];
                if(emailDomain.contains(emailFromExludeList) && returnEmailMapFinal.containsKey(email)){
                    returnEmailMapFinal.remove(email);
                }
            }
        }      
        
        return returnEmailMapFinal;
    }
    
    public static Map<String,Boolean> validateToAddress(Map<String,Boolean> fromMetaMap, Map<String,Boolean> returnToEmailMap,Map<String,EmailMessage> fromAddEmailMessageMap){
        
        Map<String,String> splittedToEmailMap = new Map<String,String>();
        List<String> finalToList = new List<String>();
        Map<String,Boolean> toAddressToRemoveMap = new Map<String,Boolean>();
        for(String emp : returnToEmailMap.keySet())
        {
            string toAddressString = fromAddEmailMessageMap.get(emp).ToAddress ;
            for(string toStr : toAddressString.split(';') ){
                string afterTrim = toStr.trim() ;
                string upperCaseToEmail = afterTrim.toUpperCase() ;
                if(fromMetaMap.containsKey(upperCaseToEmail)){
                    system.debug(toStr);
                    if(fromMetaMap.get(upperCaseToEmail)){
                        toAddressToRemoveMap.put(emp,false);
                        break;
                    }else{
                        toAddressToRemoveMap.put(emp,true);
                    }
                    
                }else{
                    toAddressToRemoveMap.put(emp,true);
                   
                }
            }
        }
        // removing ToAddress from the map depends up on set auto replay of fromAddress.
        for(String toaddress : toAddressToRemoveMap.keySet()){
            if(returnToEmailMap.containsKey(toaddress) && toAddressToRemoveMap.get(toaddress) ){
                returnToEmailMap.remove(toaddress);
            }
        }
      
        return returnToEmailMap;
    }
    
    public static Map<String,Boolean> validateCase(List<Id> caseId, Map<String,Boolean> fromMetaMap, Map<String,Boolean> returnCaseEmailMap, Map<Id,String> cseAutoMap){
        
        for(Case cse : [SELECT Id,Origin,IsAutoReplySent__c FROM CASE WHERE Id IN:caseId ]){
            if(cse.IsAutoReplySent__c)
            {
                if(cseAutoMap.containsKey(cse.Id))
                {
                    if(returnCaseEmailMap.containsKey(cseAutoMap.get(cse.Id)))
                    {
                        returnCaseEmailMap.remove(cseAutoMap.get(cse.Id));
                    }
                }
            }
        }
        return returnCaseEmailMap;
    }
    
    public static Map<String,Id> findOrInsertContact(Set<String> conEmail){
        
        Map<String,Id> conMap = new Map<String,Id>();
        List<Contact> conList =  new List<Contact>();
        List<String> conInsert = new List<String>();
        //conlist = [SELECT Id,Email FROM Contact WHERE Email IN:conEmail];
        for(Contact con : [SELECT Id,Email FROM Contact WHERE Email IN:conEmail])
        {
           conMap.put(con.Email.toUpperCase(),con.Id);
        }
        for(String eml : conEmail)
        {
            if(!conMap.containsKey(eml))
            {
                conInsert.add(eml);
            } 
        }
        if(!conInsert.isEmpty())
        {
            for(String contaEmail : conInsert)
            {
                list<String> splitEmlAdd = contaEmail.split('@');
                Contact cont = new Contact();
                cont.LastName = splitEmlAdd[0];
                cont.Email = contaEmail;
                conList.add(cont);
            }
            if(!conList.isEmpty())
            {
                Database.insert(conList);
            }
            // add all newly creatd contacts to delete
            contactsToDelete.addAll(conList);
            
        }
        for(Contact conlistFin : conList)
        {
            conMap.put(conlistFin.Email,conlistFin.Id);
        }
        return conMap;
    }
    
    public static void sendAutoEmail(Map<String,Id> contactMapFin,Map<String,Id> emlCaseMapFin,List<String> idTh){
        List<Messaging.SingleEmailMessage> msgList=new List<Messaging.SingleEmailMessage>();
        EmailTemplate singleCaseTemplate = [SELECT Id, Name 
                                            FROM EmailTemplate 
                                            WHERE Name = 'Chat Now Automated Email' LIMIT 1];
        String donotReplyLabel = System.Label.DoNotReplyEmail;
        List<String> dnotreplyEmailValue =donotReplyLabel.split(';');
        List<OrgWideEmailAddress> donotReplayList =[SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName =:dnotreplyEmailValue[0] AND Address =:dnotreplyEmailValue[1]] ;
        List<Case> caseListToupdate = new List<Case>();
        Set<string>caseIdSet = new Set<string>();
        for(String emlList : contactMapFin.keySet())
        {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            List<String> emailLst = new List<String>();
            emailLst.add(emlList);
            msg = Messaging.renderStoredEmailTemplate(String.valueof(singleCaseTemplate.Id), String.valueof(contactMapFin.get(emlList)), String.valueof(emlCaseMapFin.get(emlList)));                
            msg.setToAddresses(emailLst);
            msg.setTargetObjectId(contactMapFin.get(emlList));
            msg.setWhatId(emlCaseMapFin.get(emlList));
            caseIdSet.add(emlCaseMapFin.get(emlList));
            msg.setTemplateId(singleCaseTemplate.Id);
           
            if(!donotReplayList.isEmpty()){
            msg.setOrgWideEmailAddressId(donotReplayList[0].Id); 
            }
            msg.saveAsActivity = true; 
            msgList.add(msg);
        }
        if(!msgList.isEmpty())
        {
            Messaging.sendEmail(msgList);
			
        }
        // delete newly creted contact
        if(!contactsToDelete.isEmpty()){
            Delete contactsToDelete;
        }
        if(!caseIdSet.isEmpty()){
         UpdateCaseAndDeleteNewContacts(caseIdSet,idTh);
        }
		RecurrsiveTriggerHandler.isSkipsentChatNowAutoReply = true;
    }
	@future
    public static void UpdateCaseAndDeleteNewContacts(Set<String> caseIdsToUpdate,List<String> ideThr){
    List<Case> caseListToupdate = new List<Case>();
	Set<String> idThread = new Set<String>();
	try{
	for(EmailMessage em : [Select Id,ParentId from EmailMessage where To_Be_Closed__c = True AND Id In:ideThr])
        {
            if(em.ParentId != null)
            {
                idThread.add(em.ParentId);
            }
        }
    //Changes related to SDT-38012 - added RecordType.Name in the query
    
    for(case cseobj : [SELECT Id,Origin,IsAutoReplySent__c,Tracking_Number__c,RecordType.Name FROM CASE WHERE Id IN:caseIdsToUpdate ]){
            cseobj.IsAutoReplySent__c = true;
            //Changes related to SDT-38012 - Adding additional logic to check the case recordtype and 
            //if it is new service or modify then don't close the case. 
            //&& cseobj.RecordType.Name != Constant_Util.MODIFY_EXISTING_SERVICE_CASE
			if(cseobj.Tracking_Number__c== null && !idThread.contains(cseobj.Id) && cseobj.Origin == 'Email' && (cseobj.RecordType.Name != Constant_Util.New_Service_Case && cseobj.RecordType.Name != 'Modify Existing Service Case'))
            {
                cseobj.Status = 'Closed';
            }
            caseListToupdate.add(cseobj);
            
        }
         if(!caseListToupdate.isEmpty()){
             update caseListToupdate ;
        }
       
    }
	catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
	}
      
     // SDT-44631 - Changes to grab the reference Id from the reference number
    // The earlier logic was not able to pick the number correctly using regex.
    public static string getReferenceId(string text){
       final String key = 'lst';
       /* string[] splittedReferenceString = text.split(key);
		string result = '';
        if(splittedReferenceString.size()>1){
            result = splittedReferenceString[1];
        }
        
        return string.format('{1}{0}{1}', new string[]{result,key}) ;*/

        //TCS-av4-SDT-46928-23/04/25-Added to extract reference id 
        EmailMessageProcessorExtension emailMsgProcessor = new EmailMessageProcessorExtension();
        String refId = emailMsgProcessor.getReferenceId(text, key);
        return refId;
        //TCS-av4-SDT-46928-23/04/25-End
	}
    
    //SDT-41263
    public static void updateMessageIdForOutboundQuoteEmails(List<EmailMessage> emMsgList){
        
        //SDT-41263
        for(EmailMessage em  :emMsgList){
            if(em.RelatedToId != null && em.RelatedToId.getSObjectType().getDescribe().getName() == 'SBQQ__Quote__c' 
               && (em.Message_ID__c == NULL || String.IsEmpty(em.Message_ID__c)) && em.Status == '3' ) {
                //added by av4 for SDT-41263
                //trigger.new[0].Message_ID__c = UserInfo.getUserId();
                String agentThreadId =  getReferenceId(em.htmlBody);
                   
                if(agentThreadId != null) {
                    system.debug('agentThreadId >> ' + agentThreadId);
                    em.Message_ID__c = agentThreadId + UserInfo.getUserName().substringBefore(Constant_Util.AT_SYMBOL);
                }
            }
        }
    }
}
