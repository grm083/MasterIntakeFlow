/**
* @author Accenture
* @date 3/25/2019
* @description : Controller class for EmailDetailViewComponent lightning component
**/

public with sharing class CaseDetailHelper {
    /**
* @author Accenture
* @date 3/25/2019
* @description : method to return the case number associated to the email message
**/
    @AuraEnabled
    public static string getCaseNumber(string recordId){
        case caseList = [select id,caseNumber from case where id =:recordId];
        return caseList.caseNumber;
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to return the case id related to the email message
**/
    @AuraEnabled
    public static string getCaseNumberFromEmail(string recordId){
        EmailMessage emailList = [SELECT Id, ParentId from EmailMessage where id=:recordId limit 1];
        Id caseId = (Id)emailList.ParentId;
        return caseId ;
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to retrieve the latest email id for the case
**/
    @AuraEnabled
    public static string getEmailListId(string recordId){
        Id emailmessageId;
        
        List<EmailMessage> emailList = [SELECT Id, ParentId, TextBody, HtmlBody, Subject, FromName, MessageDate,FromAddress, ToAddress, CcAddress, BccAddress, Status FROM EmailMessage
                                        where ParentId=:recordId ORDER BY LastModifiedDate DESC];
        
        if(emailList != null && !emailList.isEmpty()){
            emailmessageId = (Id)emailList[0].Id;
        }
        return emailmessageId;
    }
    /**
    * @author Accenture
    * @date 3/25/2019
    * @description : Method to get the subject of the email object
    **/
    @AuraEnabled
    public static string getEmailSubject(string recordId){
        string emailMessageString = '';
        List<EmailMessage> emailList = [SELECT Id, ParentId, TextBody, HtmlBody, Subject,MessageDate, FromName, FromAddress, ToAddress, CcAddress, BccAddress, Status FROM EmailMessage
                                        where id=:recordId or parentId=:recordId order by LastModifiedDate DESC limit 1];
        if(emailList != null && !emailList.isEmpty()){
            emailMessageString = JSON.serialize(emailList);
        }else{}               
        return emailMessageString  ;
    }
     /**
* @author Accenture
* @date 3/25/2019
* @description : Method to get the email associated with case
**/
    @AuraEnabled
    public static string getEmailList(Id recordId){
        string emailMessageString = '';
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        List<EmailMessage> emailList = new List<EmailMessage>();
        
        if(sObjectName == 'Case') {
            //Changes done SDT-21496 for fetching email from child record and show on parent record
            List<case> caseList = [SELECT Id,CaseNumber  FROM Case WHERE Id =: recordId];
            List<Case> parentchildcaseList = [SELECT Id FROM Case WHERE Reference_Number__c =: caseList[0].CaseNumber];
            if(parentchildcaseList.isEmpty())
            {
                Case cs = new Case();
                cs.Id=recordId;
                parentchildcaseList.add(cs);
            }
            List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Case__c =:parentchildcaseList];
            emailList = [SELECT Id, ParentId, TextBody, HtmlBody, Subject,MessageDate, FromName, FromAddress, ToAddress, CcAddress, BccAddress, toLabel(Status), RelatedToId FROM EmailMessage
                         where parentId in :parentchildcaseList OR RelatedToId IN :quoteList order by LastModifiedDate DESC limit 10];
        } else if (sObjectName == 'SBQQ__Quote__c') {
            SBQQ__Quote__c currentQuote = [SELECT Id, SBQQ__Opportunity2__r.Case__c FROM SBQQ__Quote__c WHERE Id=:recordId];

            emailList = [SELECT Id, ParentId, TextBody, HtmlBody, Subject,MessageDate, FromName, FromAddress, ToAddress, CcAddress, BccAddress, toLabel(Status), RelatedToId FROM EmailMessage
                         where parentId=:currentQuote.SBQQ__Opportunity2__r.Case__c OR RelatedToId =: recordId order by LastModifiedDate DESC limit 10];
        }
        if(emailList != null && !emailList.isEmpty()){
            emailMessageString = JSON.serialize(emailList);
        }else{}               
        return emailMessageString  ;
    }

/**
* @author Accenture
* @date 7/28/2020
* @description : Method to get the email associated with case for copy
**/
@AuraEnabled
public static string getCopyEmailList(string recordId){
    string emailMessageString = Constant_Util.EMPTY_STRING;
    List<EmailMessage> emailList = [SELECT Id, ParentId, TextBody, HtmlBody, Subject,MessageDate, FromName, FromAddress, ToAddress, CcAddress, BccAddress, toLabel(Status) FROM EmailMessage
                                    where parentId=:recordId AND toLabel(Status) !=: Constant_Util.DRAFT order by LastModifiedDate DESC limit 10];
    if(emailList != null && !emailList.isEmpty()){
        emailMessageString = JSON.serialize(emailList);
    }else{}               
    return emailMessageString  ;
}


    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to close the clone case if the CSR click on cancel button
**/
    @AuraEnabled
    public static void closedCloneCase(string recId){
        Case cloneCase;
        cloneCase = [SELECT id,Status FROM  Case
                     WHERE id=:recId LIMIT 1];
        cloneCase.Status = 'Closed';
        // Make the update call.
        // Modified for SDT-33447 Start
        try {
            if(cloneCase != null){
                update cloneCase;  
            }            
        } catch (DmlException e) {
            System.debug('A DML exception has occurred: ' + e.getMessage());
        }
        // Modified for SDT-33447 End
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to retireve the record type names for the case
**/
    @AuraEnabled
    public static List<string> fetchRecordTypeValues(){
        String recordtypeString = '';
        Map<Id,string> recordtypemap = new Map<Id,string>();
        List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master'){
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }        
        return recordtypemap.values();
        
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to retireve the case recordtype details
**/
    @AuraEnabled
    public static string getCaseRecordtyeIdfromCase(string recordId){
        case caseList = [select id,recordtype.id, recordtype.Name from case where id =:recordId];
        return caseList.recordtype.Name;
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to return the recordtype id associated to the record type name
**/
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeName){
        Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();        
        return recid;
    }   
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to create the clone case when the case with origin as Email is opened and click on the clone case button
**/
    @AuraEnabled
    public static string cloneCaseDetails(string referenceCase){
        string cloneCase = '';
        //system.debug('referenceCase===='+referenceCase);
        string fieldString = getFields();
        string queryString = 'Select'+' '+fieldString+' ' + ' from case where id=:referenceCase';
        //system.debug('queryString==='+queryString);
        case caseRec = database.query(queryString);
        case cloneCaseRec = caseRec.clone(false,true,false,false);
        cloneCaseRec.Reference_Number__c = caseRec.CaseNumber;
        //cloneCaseRec.ParentId = caseRec.Id;
        cloneCaseRec.RecordtypeId = caseRec.RecordTypeId;
        Database.saveResult sr = database.insert(cloneCaseRec,false);
        if(sr.isSuccess()){
            cloneCase = sr.getId();
        }
        else{
            for(database.Error err : sr.getErrors()){
                cloneCase += err.getMessage();
            }
        }
        //System.debug('caseRec---'+caseRec);
        return cloneCase;
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to Create account title record
**/
    @AuraEnabled
    public static String createContactTitle(String acctId, String newTitle) {
        Account_Title__c title = new Account_Title__c();
        title.Name = newTitle;
        title.Account__c = acctId;
        title.Status__c = 'Active';
        
// Modified for SDT-33447 Start
        try {
            if(title != null){
        insert title;
}            
        } catch (DmlException e) {
            System.debug('A DML exception has occurred: ' + e.getMessage());
        }
        // Modified for SDT-33447 End
        
        return title.Id;
    }
    /**
* @author Accenture
* @date 5/31/2019
* @description : Method to Create account title record
**/
    @AuraEnabled
    public static String createContactLocationAssociation(String contactId, String locationId) {
        AccountContactRelation acr = new AccountContactRelation();
        acr.ContactId = contactId;
        acr.AccountId = locationId;
        // Modified for SDT-33447 Start
        try {
            if(acr != null){
        insert acr;
}            
        } catch (DmlException e) {
            System.debug('A DML exception has occurred: ' + e.getMessage());
        }
        // Modified for SDT-33447 End        
        
        return acr.Id;
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to get the titles for the case
**/
    @AuraEnabled 
    public static Map<String, String> getAccountTitlesForCase(String caseId) {
        String acctId = [select Client__c from Case where Id =: caseId].Client__c;
        Map<String, String> options = new Map<String, String>();
        for (Account_Title__c title: [select Id, Name from Account_Title__c where Account__r.Id =: acctId order by Name ASC]) {
            options.put(title.Id, title.Name);
        }
        return options;          
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : method to return the contact associated to the case
**/
    @AuraEnabled
    public static string getCaseContactId(string recordId){
        return [select id,contactId from case where id =:recordId].contactId;
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description :method to set hte contact id associated to the case
**/
    @AuraEnabled
    public static void setCaseContactId(string recordId, Object contactId, Object locationId,Boolean isselectedRow){
        String cId = (String) contactId;
        String lId = (String) locationId;
        Boolean isDuplicate = false;
        contact con;
        //system.debug('values'+isselectedRow);
        if(!isselectedRow){
            con = [Select Id,Email,Phone,FirstName,LastName,AccountId from contact where id =: cId and Location__c =: lId Limit 1];
            for(Contact c : [Select Id from Contact where ((Email =: con.Email and Email != null) or (Phone =: con.Phone and Phone != null)) and FirstName =: con.FirstName and LastName =: con.LastName and AccountId=: con.AccountId and Id !=: con.Id Limit 1]){
                isDuplicate = true;
            }
        }
       
        If(!isDuplicate || isselectedRow){
            //System.debug('Contact Id: ' + cId);
            Case c = [select Id,ContactId,AccountId,Client__c,Account.Id,Account.Name,Acorn_Location_Id__c,Location__c,Location__r.Name from case where id =:recordId limit 1];
            c.ContactId = cId;
            c.Location__c = lId;
// Modified for SDT-33447 Start
            if(c != null){
            update c;
} 
        	// Modified for SDT-33447 End     
        }else {
// Modified for SDT-33447 Start
            if(con != null){
            Delete con;
        }
// Modified for SDT-33447 End
        }
        
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : mehtod to get the account contacts from case
**/
    @AuraEnabled
    public static List<Contact> getAccountContactsFromCase(String caseID, String searchContent) {
        //System.debug('Case Id: ' + caseID);
        Map<Id, Contact> returnConList = new Map<Id, Contact>();
        Case c = [select Id, Client__c, Location__c from Case where Id =: caseId limit 1];
        String acctId = c.Client__c;
        String locationId = c.Location__c;
        //System.debug('Account Id: ' + c.Client__c);
        //System.debug('Location Id: ' + c.Location__c);
        String val='\'%' + String.escapeSingleQuotes(searchContent.trim()) + '%\'';
        //system.debug('search value'+val);
        String soql = 'select Id, Account_Title__r.Name, Firstname, Lastname, Account.Name,Name,Description,Title from Contact where Name LIKE ' + val + ' and Location__r.Id =: locationId and AccountId =: acctId';                    
        List<Contact> contacts = database.query(soql);
        for (Contact c2: contacts) {
            returnConList.put(c2.Id, c2);
        }

        List<ID> ConIDaccConRel = new List<Id>();
        for(AccountContactRelation accCon : [Select ContactId From AccountContactRelation Where AccountId =: locationId AND Contact.AccountId =: acctId]){
            ConIDaccConRel.add(accCon.ContactId);
        }
        
        if(ConIDaccConRel!=null && ConIDaccConRel.size()>0) {
            soql = 'select Id, Account_Title__r.Name, Firstname, Lastname, Account.Name,Name,Description,Title from Contact where Name LIKE ' + val + ' and id IN :ConIDaccConRel';
            List<Contact> relatedContacts = database.query(soql);
            for (Contact c2: relatedContacts) {
                returnConList.put(c2.Id, c2);
            }
        }
        
        //System.debug('Found: ' + returnConList.size());
        return returnConList.values();
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : method to get the contact title form case
**/
    @AuraEnabled
    public static string getContactTitleId(string contactId){
        return [select Id, Account_Title__c from Contact where id =: contactId].Account_Title__c;
    }
    /**
* @author Accenture
* @date 3/25/2019
* @description : Method to return the list of fields for query
**/
    public static string getFields(){
        string queryFieldString = '';
        Schema.DescribeSObjectResult caseObjectResult = Case.sObjectType.getDescribe();
        List<String> fieldNameList =  new list<String>();
        for(string fields : caseObjectResult.fields.getMap().keySet()){
            queryFieldString += fields + ',';
        }
        return queryFieldString.removeEnd(',');
    }
    
    @AuraEnabled
    public static Boolean checkExisting(Id caseId,String jsonParams){
        Boolean isContactRel = false;
        List<Contact> errorRecs = new List<Contact>();
        Map<String, Contact> newContacts = new Map<String, Contact>();
        Contact newContact = (Contact)json.deserialize(jsonParams, Contact.class);
        //system.debug('con details'+jsonParams);
        Case currentCase = [Select id,AccountId,Location__c from case where id=: caseId limit 1];
        List<AccountContactRelation> contactRels = new List<AccountContactRelation>();
        AccountContactRelation contactRel;
        
        for(Contact c : [select Id, FirstName, LastName, Email, Location__c,AccountId from Contact where AccountId =: newContact.AccountId and FirstName =: newContact.FirstName 
                         and LastName =: newContact.LastName and ((Email =: newContact.Email and email != NULL ) or (Phone =: newContact.Phone and Phone != null))  LIMIT 1]){
                             contactRel = new AccountContactRelation();
                             contactRel.AccountId = newContact.Location__c;
                             contactRel.ContactId = c.Id;
                             contactRels.add(contactRel);
                             currentCase.ContactId = c.Id;
                             //system.debug('Inside For');
                         }
        if (contactRels.size() > 0){
            //system.debug('13'+contactRels);
            
            AccountContactRelation existingcontactRel; 
            for(AccountContactRelation a : [Select Id from AccountContactRelation where AccountId =: contactRels[0].AccountId and ContactId =: contactRels[0].ContactId Limit 1]){
                existingcontactRel = a;
            }
            If(existingcontactRel == null){
                Database.insert(contactRels);
            }
            Database.update(currentCase);
            //system.debug('relation insert');
            isContactRel = true;
        }
        return isContactRel;
    }

    

    @AuraEnabled
    public static parentWrapper checkChild(string recordId){
        Case myCase = [SELECT Id, ParentId, Parent.CaseNumber FROM Case WHERE Id = :recordId LIMIT 1];       
        parentWrapper wrap = new parentWrapper();
        wrap.CaseNumber = myCase.Parent.CaseNumber;
        wrap.ParentId=myCase.ParentId;
        return wrap;
        
    }


    public inherited sharing class parentWrapper{
        @AuraEnabled public String CaseNumber;
        @AuraEnabled public String ParentId;        
    }
	
    /**
    * @author Accenture
    * @date 7/7/2020
    * @description : Method to copy Email as Comments
    **/
    @AuraEnabled
    public static string emailToComments(string recId,String caseNumber,String emails){
        string result = null;
    	Id recordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_COMMENT).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.ACORN_TICKET_COMMENT).getRecordTypeId();
        User acornUser = [select Acorn_SUser_ID__c,Name from User where ID =: System.UserInfo.getUserId() Limit 1];
        Case curCase = [select Id,CaseNumber, Tracking_Number__c from Case where Id =: recId limit 1];
        List<Comment__c> emailToCaseComments = new List<Comment__c>();
        Comment__c note = null;
        string comment = null;
		List<EmailMessage> emailList = (List<EmailMessage>)JSON.deserialize(emails,List<EmailMessage>.class);
        for(EmailMessage e : emailList){
            note = new Comment__c();
            note.Case__c = curCase.Id;
            comment = Constant_Util.CASE_NUMBER + caseNumber + Constant_Util.New_Line + Constant_Util.FROM_ADDRESS + e.FromAddress + Constant_Util.New_Line + Constant_Util.TO_ADDRESS + e.ToAddress + Constant_Util.New_Line + Constant_Util.CC_ADDRESS + (e.CCAddress == null ? '' : e.CCAddress + Constant_Util.New_Line) + Constant_Util.SUBJECT_EMAIL + e.Subject + Constant_Util.New_Line + Constant_Util.MESSAGE_DATE + e.MessageDate.format() + Constant_Util.New_Line;
            comment = comment + Constant_Util.TEXT_BODY_EMAIL + e.TextBody;
            note.Comment__c = comment;
            note.Communication_Log_Type_Name__c = Constant_Util.INTERNAL;
            note.Case_Number__c = curCase.CaseNumber;
            note.recordTypeId = recordTypeId;
            if (String.isNotEmpty(curCase.Tracking_Number__c)){
                note.Acorn_Tracking_Number__c = curCase.Tracking_Number__c;
            }
            note.Workflow_Action__c = Constant_Util.EMPTY_STRING;
            note.Workflow_TeamUser__c = acornUser.Name;
            note.Acorn_SUser_ID__c = acornUser.Acorn_SUser_ID__c;
            note.Type__c = Constant_Util.OBJECT_CASE;
            emailToCaseComments.add(note);
        }
        try {
            if(!emailToCaseComments.IsEmpty() && emailToCaseComments.Size() > 0){
            	Database.insert(emailToCaseComments, false);
            }
        }catch(Exception ex){
            result = ex.getMessage();
        }
        return result;
    }
}