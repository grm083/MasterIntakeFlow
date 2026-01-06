/*************************************************************
@Name: TrackingPattern
@Author: Ayushi Sharma
@CreateDate: 26/02/2019
@Description: Helper Class to Perform operations on EmailMessage
@UsedBy: 
**************************************************************/
public class TrackingPattern {
    public static final String trackingNumberPattern ='T{1}[0-9]{8}[0-9]?';
   //public static List<Task> lstTask = new List<Task>();
   // public static List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
            
    /*
	* This method is Invoked from the Process Builder
	* @owner : Ayushi Sharma
	* @param : List<EmailMessage>
	*/
    @InvocableMethod(label='Invocable Method for Pattern Tracking' description='It is invocable method for the Case to identify Acorn Tracking Number')
    public static void emailMessage(List<Case> lstCase){
        
      try{
            trackingNumberCheck(lstCase);
        } 
        catch(Exception e){
           System.debug('Exception::::'+e.getStackTraceString());
           System.debug('Exception::::'+e.getMessage());
        }
    }
    
    /*
	* This method is used to extract the Tracking Number
	* @owner : Ayushi Sharma
	* @param : List<Case>
	*/
    public static void trackingNumberCheck(List<Case> lstCase){
        List<Id> caseIds = new List<Id>();
        List<String> trackingNumbers = new List<String>();
        List<Id> deleteCaseId = new List<Id>();
        List<Id> lstCaseIds = new List<Id>();
		List<Case> lstCases = new List<Case>();
        List<Case> deleteCase = new List<Case>();
        List<Case> updateCase = new List<Case>();
        List<EmailMessage> lstEM = new List<EmailMessage>();
        List<EMailMessage> lstCloneEM = new List<EmailMessage>();
        List<EmailMessage> insertedEm = new List<EmailMessage>();
        List<EmailMessage> lstUpdateEM = new List<EmailMessage>();
        Map<String,Id> mapTrackingCodeCase = new Map<String,Id>();
		Boolean createTask = true;
        
        for(Case objCase : lstCase){
           lstCaseIds.add(objCase.Id);
        }
        
        //Query the Case Related fields
        lstCases = [Select Id,Email_Tracking_Number__c,Status,Routing_Counter__c from Case where Id IN: lstCaseIds];
        
        //Create a set for the Email Tracking Numbers
        for(Case objCase : lstCases){
            trackingNumbers.add(objCase.Email_Tracking_Number__c);
        }
        
        //Search another case with that Tracking Number
        List<Case> lstCaseCreated = [select id,Email_Tracking_Number__c, Source_System__c, Tracking_Number__c, Status, Acorn_Ticket_Not_Matched__c, Routing_Counter__c
                                     from Case where Email_Tracking_Number__c IN :trackingNumbers 
                                     And Id NOT IN :lstCaseIds AND Status !=: Constant_Util.CLOSED
                                     AND Acorn_Ticket_Not_Matched__c = false order by CreatedDate desc];
        
        // Store Tracking Number and New Case in a Map
        for(Case objCase : lstCaseCreated){
            if(!mapTrackingCodeCase.containsKey(objCase.Email_Tracking_Number__c) && objCase.Email_Tracking_Number__c != null){
                mapTrackingCodeCase.put(objCase.Email_Tracking_Number__c, objCase.Id);
            }
       }
       
        // Iterate Cases and Delete Cases if New Case found else Increase the Counter for Retry.
        for(Case objCase : lstCases){
            if(mapTrackingCodeCase.get(objCase.Email_Tracking_Number__c) != null && objCase.Status.equals(Constant_Util.NEW_STATUS)){
                deleteCase.add(objCase);
                deleteCaseId.add(objCase.Id);
             }
            else if(objCase.Routing_Counter__c == 0){
                updateCase.add(new Case(
                    Id = objCase.Id,
                    Routing_Counter__c = 1
                ));
            }
            else{
                // No case found
                caseIds.add(objCase.Id);
            }
        }
        
        // If new Case is found.
        if(deleteCaseId.size()>0){
            
            lstEM = [Select Id, ParentId,Parent.Email_Tracking_Number__c ,Parent.ContactId,Parent.CaseNumber, Parent.Case_Reason__c, 
                     parent.Reference_Number__c, parent.Case_Sub_Type__c, parent.Case_Type__c, FromAddress, Subject,RelatedToId, 
                     ToAddress, Message_ID__c, HtmlBody, Status,Incoming,TextBody from EmailMessage where ParentId IN: deleteCaseId];
            
            Map<Id,EmailMessage> mapCaseEM = new Map<Id,EmailMessage>();
            for(EMailMessage objEM : lstEM){
                if(!mapCaseEM.containsKey(objEM.ParentId)){
                    mapCaseEM.put(objEM.ParentId,objEM);
                }
            }
            
            Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER].Id__c;
            
            EMailMessage cloneEM;
            
            //Clone the Email Message and Reparent to New Case
            if(lstEM.size()>0){
               for(EmailMessage objEM : lstEM){
                    String code = objEM.Parent.Email_Tracking_Number__c;
                   	cloneEM = new EmailMessage(); 
                    cloneEM = objEM.clone(false);
                	cloneEM.ParentId =  mapTrackingCodeCase.get(code);
                    cloneEM.RelatedToId  =  mapTrackingCodeCase.get(code);
                    cloneEM.isCloned__c = true;
                   	//cloneEM.Incoming  =  true;
                   	//cloneEM.Status  =  '0';
                	lstCloneEM.add(cloneEM);
               }
                
            	if(lstCloneEM.size()>0){
                    Database.SaveResult[] srList = Database.insert(lstCloneEM);
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted log. Log ID: ' + sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Log fields that affected this error: ' + err.getFields());
                            }
                        }
                    }    
            	}
           }
            createTasKAndGR(lstCloneEM, createTask);
        }
       
       // Delete Earlier Cases 
       if(deleteCase.size()>0){
            Database.delete(deleteCase);
        }
        
        //Update the Routing Counter on the Cases for Retry
        if(updateCase.size()>0){
            Database.update(updateCase);
        }
        
        //If No Case found after the 10 and 20 mins delayed attempts
        if(!caseIds.IsEmpty()){
            
            List<EmailMessage> lstEmailMessage = new List<EmailMessage>();
            createTask = false;
            lstEmailMessage = [Select Id, ParentId,Parent.Email_Tracking_Number__c ,Parent.ContactId,Parent.CaseNumber, Parent.Case_Reason__c, 
                     parent.Reference_Number__c, parent.Case_Sub_Type__c, parent.Case_Type__c, FromAddress, Subject,RelatedToId, 
                     ToAddress, Message_ID__c, HtmlBody, TextBody from EmailMessage where ParentId IN: caseIds];
            createTasKAndGR(lstEmailMessage,createTask);
        }
    }
    
    /*
	* This method is used to create Task and Genesys Routing
	* @owner : Ayushi Sharma
	* @param : List<EmailMessage>
	*/
    public static void createTasKAndGR(List<EmailMessage> lstEmailMessages, Boolean createTask){
        	
        	List<Task> lstTask = new List<Task>();
   			List<Genesys_Routing__c> lstGR = new List<Genesys_Routing__c>();
      		
        	Id recordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            Id GRrecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.EMAILTOCASERECORD).getRecordTypeId();
            
        	Generic_Values__mdt objGV= new Generic_Values__mdt();
            String objuser;
            objUser = [Select Id, Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER].Id__c;
            
        	List<EmailMessage> insertedEm = new List<EmailMessage>();
        	insertedEm = [Select Id, ParentId,Parent.Email_Tracking_Number__c ,Parent.ContactId,Parent.CaseNumber, Parent.Case_Reason__c, Parent.Customer_Code__c, Parent.AccountId, 
                     parent.Reference_Number__c, parent.Case_Sub_Type__c, parent.Case_Type__c, FromAddress, Subject,RelatedToId, 
                     ToAddress, Message_ID__c, HtmlBody, TextBody, Parent.RecordType.Name, parent.Location__c, parent.Location__r.Location_Code__c from EmailMessage where Id IN: lstEmailMessages Limit 49999];
        	Set<Id> caseIds = new Set<Id>();
            Map<String , String> emailMsgToCaseMap = new Map<String , String>();
            Set<String> caseWithEmailSet = new Set<String>();
            for(EmailMessage objEM : insertedEm){
               emailMsgToCaseMap.put(objEM.id , objEM.ParentId);
            }  
            List<EmailMessage> emailMsgList = [Select Id, ParentId FROM EmailMessage WHERE ParentId IN : emailMsgToCaseMap.values() AND Id Not IN :emailMsgToCaseMap.keySet()];
            for(EmailMessage emailMsg : emailMsgList) {
                caseWithEmailSet.add(emailMsg.ParentId);
            }
        	Task objTask;
            Genesys_Routing__c objGR;
            if(insertedEm.size()>0){
                for(EmailMessage objEM : insertedEm){
                    if(createTask){
                        objTask = new Task();
                		objTask.ActivityDate = System.today();
                		objTask.Contact_Email__c = objEM.FromAddress;
                		objTask.OwnerId = objUser;
                		objTask.Priority = Constant_Util.PRIORITYNORMAL;
                		objTask.RecordTypeId = recordTypeId;
                		objTask.Status = Constant_Util.OPEN;
                		objTask.Message_Id__c = objEM.Id;
                		objTask.Subject = objEM.Subject;
               			objTask.WhatId = objEM.ParentId;
                		if(objEM.Parent.ContactId != null){
                    		objTask.WhoId = objEM.Parent.ContactId;
                		}
                	    lstTask.add(objTask); 
                    }
                
                    objGR = new Genesys_Routing__c();
                    objGR.EmailFrom__c = objEM.FromAddress;
                    objGR.EmailSubject__c = objEM.Subject;
                    objGR.EmailTo__c = objEM.ToAddress;
                    objGR.Email_Message_Id__c = objEM.Id;
                    objGR.SFDCAcctID__c = objEM.Parent.Customer_Code__c;
                    objGR.Integrate_with_Genesys_Routing__c = true;
                    objGR.MediaType__c = createTask ? Constant_Util.SFDCEMAILTASK : Constant_Util.SFDCEMAILCASE;
                    objGR.SFDCCaseNumber__c = objEM.Parent.CaseNumber;
                    objGR.SFDCCaseReason__c =objEM.Parent.Case_Reason__c;
                    objGR.SFDCCaseRefNo__c = objEM.Parent.Reference_Number__c;
                    objGR.SFDCCaseSubCaseType__c =objEM.Parent.Case_Sub_Type__c;
                    objGR.SFDCCaseType__c =objEM.Parent.Case_Type__c;
                    if(createTask){
                        if(!caseWithEmailSet.contains(objEM.ParentId)) {
                            objGR.SFDCIsEmailNew__c = 'True';
                            caseWithEmailSet.add(objEM.ParentId);
                        } else {
                            objGR.SFDCIsEmailNew__c = Constant_Util.FALSEVAL;
                        }     
                    } else {
                        objGR.SFDCIsEmailNew__c =  'True';
                    }
                    
                    objGR.SFDCObjName__c = Constant_Util.OBJECT_CASE;
                    objGR.SFDCObjRecordID__c = objEM.Id;
                    objGR.SFDCRecordType__c =  objEM.Parent.RecordType.Name;    
                    objGR.SFDCObjType__c = Constant_Util.OBJECT_EMAILMESSAGE;
                    if(objEM.Parent.Location__c!=null){
                        objGR.SFDCAcctLocation__c = objEM.Parent.Location__r.Location_Code__c;
                    }
                    if(!objEM.Subject.containsIgnoreCase(Constant_Util.WO_SUBJECT))
                    {
                        lstGR.add(objGR);
                    }
                
                    caseIds.add(objEm.ParentId);
                }
            }
            
        	if(caseIds.size()>0 && !createTask){
                List<Case> CaseOwner = new List<Case>();
                List<Case> updateCase = new List<Case>();
                CaseOwner = [Select Id, OwnerId from Case where Id IN : caseIds Limit 49999];
                for(Case objCase : CaseOwner){
                    objCase.OwnerId = objUser;
                    updateCase.add(objCase);
                }
                Database.update(updateCase);
            }
        	
            if(lstTask.size()>0){
                Database.insert(lstTask);
            }
            
            if(lstGR.size()>0){
                Database.insert(lstGR);
            }
    }
    
}