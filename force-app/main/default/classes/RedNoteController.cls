public with sharing class RedNoteController {
	/*
    @AuraEnabled
    //The account Id is passed in through the Lightning component
    public static String getRedNotes(Id componentRecordId) {
        
        //Pass record ID and determine the type of object that the record resides on
        String objectType = componentRecordId.getSobjectType().getDescribe().getName();
        
        If (objectType == 'Case') {
            // Determine Account record based on Case ID
            Case cs1 = [SELECT Id, Client__c FROM Case WHERE Id =:componentRecordId];
            Id acctId = cs1.Client__c;
            
            //Return Red Notes as string based on Account ID
            Account Acct = [Select Id, Acorn_Red_Notes__c FROM Account WHERE Id=:acctId];
            String redNotes = Acct.Acorn_Red_Notes__c;
            
            //Pass red notes string to the removeHTML helper method to return a string
            //without the <a href=> tags
            String parsed = removeHTML(redNotes);
            return parsed;
        }else {
            //Return Red Notes as string based on Account ID
            Account Acct = [Select ID, Acorn_Red_Notes__c FROM Account WHERE Id=:componentRecordId];
            String redNotes = Acct.Acorn_Red_Notes__c;
            
            //Pass red notes string to the removeHTML helper method to return a string
            //without the <a href=> tags
            String parsed = removeHTML(redNotes);
            return parsed;
        }
        
        // Room for improvement with this method would be to also determine if the component resides
        // on a customer account location record type, and allowing us to insert this component on the 
        // customer account location as well
    }
	*/
    
    public static String removeHTML(String redNotes) {
        //Look for and replace references of <a href=> with nothing
        //George Note - HTML is not a regular language and RegExs is not best practice
        //This will work, however there may be a better way of handling this
        
        //Through spot testing there was a need to explain to the user why they may
        //receive nothing in their results.  The most logical place to incorporate
        //this contingency is within this method while we're already doing string
        //processing.
        
        If (String.isEmpty(redNotes) == TRUE) {
            String parsedNotes = 'No Authorization Notes are available on the account record.';
            return parsedNotes;
        } else {
            String parsedNotes = redNotes.replaceAll('(?i)<A href[^>]*>', '');
            return parsedNotes;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getRedNotesExternal(ID componentRecordId) {
        String accountNumber = '';
        String objectType = componentRecordId.getSobjectType().getDescribe().getName();
        
        If (objectType == 'Case') {
            Case c = [select Client__r.RecordType.Name, Client__r.AccountNumber from Case where Id =: componentRecordId limit 1];
            if (c.Client__r.RecordType.Name != 'Client'){
              return 'No Auth Notes Available.';
            }else{}
            accountNumber = c.Client__r.AccountNumber;
            
        } else if (objectType == 'WorkOrder') {
            List<WorkOrder> woList = [select Customer_Location__r.Parent.RecordType.Name, Customer_Location__r.Parent.AccountNumber from WorkOrder where Id =: componentRecordId limit 1];
            if (!woList.isEmpty()){
                if(woList[0].Customer_Location__r.Parent.RecordType.Name != 'Client'){
                    return 'No Auth Notes Available.';
                }
                accountNumber = woList[0].Customer_Location__r.Parent.AccountNumber; 
            }                     
        } else if (objectType == 'SBQQ__Quote__c') { 
            List<SBQQ__Quote__c> quoteList = [select SBQQ__Account__r.Parent.AccountNumber, SBQQ__Account__r.Parent.RecordType.Name from SBQQ__Quote__c where Id =: componentRecordId limit 1];
            if (!quoteList.isEmpty()){
                if (quoteList[0].SBQQ__Account__r.Parent.RecordType.Name != 'Client') {
                    return 'No Auth Notes Available.';
                }
                accountNumber = quoteList[0].SBQQ__Account__r.Parent.AccountNumber; 
            }                     
        } else {
            Account acct = [select RecordType.Name, Parent.AccountNumber, AccountNumber from Account where Id =: componentRecordId limit 1];
            if (acct.RecordType.Name != 'Client' && acct.RecordType.Name != 'Location'){
               return 'No Auth Notes Available.';
            }else{
                if (acct.RecordType.Name == 'Location') accountNumber = acct.Parent.AccountNumber;
                else accountNumber = acct.AccountNumber;
            }
        }
        System.debug('Account Number: ' + accountNumber);
        if (STring.isEmpty(accountNumber)){ 
            return 'Missing Client Account Number. No Auth Notes Available.';
        }else{}
        
        Integration_Request_URLs__mdt urlMD = [select DeveloperName,MasterLabel,Client_Key__c,Client_Token__c,Timeout__c, Content_Type__c,End_Point__c,Method__c from Integration_Request_URLs__mdt where DeveloperName = 'Get_Red_Notes'];
        
        String endpoint = urlMD.End_Point__c;
        endpoint = endpoint.replace('{AccountNumber}', accountNumber);
		System.debug(endpoint);	
	        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type',urlMD.Content_Type__c);
        req.setHeader('X-USERID', IntegrationHandlerUtil.getLoggedInUserAcornId());
        req.setHeader('X-PARTNER-KEY',urlMD.Client_Key__c);
        req.setHeader('Authorization',urlMD.Client_Token__c);
        req.setTimeout(urlMD.Timeout__c.intValue());
        String RequestBody;
        
        string result = '';
        RedNoteController.RedNotesResponse jsonResp;
        try {
            httpresponse res = h.send(req);
            result = res.getBody();               
            jsonResp = (RedNoteController.RedNotesResponse) JSON.deserialize(result, RedNoteController.RedNotesResponse.Class);           
            result = jsonResp.Data.AuthorizationNotes;
            if (String.isNotEmpty(result)){
                result = RedNoteController.removeHTML(result);
            }else{}
        } catch (Exception e) { }
        
        return result;
    }
    
    public class RedNotesResponse {
        public RedNotesData Data {get;set;}
        public WorkOrderWebservices.ErrorMessageWrapper Problem {get;set;}
        public RedNotesResponse() { }
    }
    
    public class RedNotesData {
        public String Code {get;set;}
        public String Name {get;set;}
        public String AuthorizationNotes {get;set;}
        public RedNotesData() {}
    }
}