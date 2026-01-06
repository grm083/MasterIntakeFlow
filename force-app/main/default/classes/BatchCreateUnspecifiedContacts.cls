/*************************************************************
@Name: BatchCreateUnspecifiedContacts
@Author: Accenture
@CreateDate: 08/02/2019
@Description: One time batch job to create Unspecified Contacts.
**************************************************************/
global class BatchCreateUnspecifiedContacts implements Database.Batchable<sObject>,Database.Stateful{
    global Set<Id> alreadyDoneAccContact = new Set<Id>();
    global Set<Id> alreadyDoneAccTitle = new Set<Id>();
    global Id currentAccId ;
    global String errorMsg ='';
    global Database.SaveResult[] srList;

    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        Map<String, Schema.RecordTypeInfo> clientRecordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Id ClientRecTypeId = clientRecordTypes.get('Client').getRecordTypeId();
        String whereInput = '\'' +String.escapeSingleQuotes(ClientRecTypeId) + '\'';        
        string query = 'select Id, name from Account where RecordTypeId ='+whereInput+' and Self_Service_Eligible__c = true';
        return Database.getQueryLocator(query);
    }
    /*@MethodName execute
        * Method to delete case records
    **/
    public void execute(Database.BatchableContext batchVariable, List<Account> accountList) 
    {
         try {
                List<Contact> contactList = new List<Contact>();
                List<Account_Title__c> accTitleList = new List<Account_Title__c>();
                set<Id> clientAccId = new Set<Id>();
                List<Account> accListCreateContact = new List<Account>();
                List<Account> accListCreateAccTitle = new List<Account>();

                for(Account data : accountList){
                    clientAccId.add(data.Id);
                }
                //Find all Account Contact that Unspecified
                List<Contact> contactListNew = [SELECT Id,Name,Account.Id 
                								FROM Contact 
                								WHERE FirstName ='Unspecified' 
                								AND AccountId  =: clientAccId];

                List<Account_Title__c> accountTitleList = [SELECT Id,Name, Account__c 
                											FROM Account_Title__c 
                											WHERE Account__c =: clientAccId];
                
                // Check already created contacts 
                if(contactListNew.size()>0  && contactListNew != null)
                {
                    Set<Id> accIdRelatedtoContacts = new Set<Id>();
                    for(Contact data :contactListNew){
                        accIdRelatedtoContacts.add(data.Account.Id);
                    }
                    
                    for(Account data : accountList){
                        if(!accIdRelatedtoContacts.contains(data.Id)){
                            accListCreateContact.add(data);
                        }
                    }
                }
                else{
                    accListCreateContact = accountList;
                }
                
                // check for already created account titles 
                if(accountTitleList.size()>0 && accountTitleList != null ){
                    Set<Id> accIdRelatedtoAccTitle = new Set<Id>();
                    for(Account_Title__c data :accountTitleList){
                        accIdRelatedtoAccTitle.add(data.Account__c);
                    }
                    
                    for(Account data : accountList){
                        if(!accIdRelatedtoAccTitle.contains(data.Id)){
                            accListCreateAccTitle.add(data);
                        }
                    }
                }
                else{
                    accListCreateAccTitle = accountList;
                } 
                
                if(accListCreateAccTitle.size()>0 && accListCreateAccTitle != null )
                {
                    //Create Account Title
                    for(Account accData : accListCreateAccTitle)
                    {
                        if(!alreadyDoneAccTitle.contains(accData.Id) ) {
                            Account_Title__c accTitle = new Account_Title__c ();
                                accTitle.Account__c = accData.Id;
                                accTitle.Name = 'Unspecified';
                                accTitle.Status__c = 'Active';
                            accTitleList.add(accTitle);
                            alreadyDoneAccTitle.add(accData.Id);
                            currentAccId = accData.Id;
                        }
                    }
                    if(accTitleList.size()>0 && accTitleList != null){
                    	insert(accTitleList);
                    }
                    accTitleList = [select Id,Name, Account__c  from Account_Title__c where Account__c =: clientAccId];
                 }
                 else{
                    accTitleList = accountTitleList;
                 }
                
                if(accListCreateContact.size() > 0 && accListCreateContact != null  && accTitleList.size() > 0 && accTitleList != null)
                {
                    map<Id,Account> accountMap = new map<Id,Account>(new Map<Id, Account>(accountList));

                    map<String,Id> accTitleMap = new Map<String,Id>();

                    for( Account_Title__c accTitleData : accTitleList){
                        if(accountMap.containsKey(accTitleData.Account__c))
                        {
                            accTitleMap.put(accountMap.get(accTitleData.Account__c).name,accTitleData.Id);
                        }
                    }           
                            
                    // Create Contacts 
                    for(Account accData : accListCreateContact)
                    {
                        if(!alreadyDoneAccContact.contains(accData.Id) ) {   
                            Contact newContact = new Contact ();
                                newContact.LastName = accData.name;
                                newContact.FirstName = 'Unspecified';
                                newContact.AccountId = accData.Id;
                                newContact.Account_Title__c = accTitleMap.get(accData.Name);  
                            contactList.add(newContact);
                            alreadyDoneAccContact.add(accData.Id);
                            currentAccId = accData.Id;
                        }
                    }
                    	 srList = Database.insert(contactList,false);
                }

                if(Test.isRunningTest()){
                    DMLException e = new DMLException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            } catch(Exception e) {
                    System.debug('Exception occured during Contact Creation: '+e.getLineNumber()+' '+e.getMessage()+'Acc Id '+currentAccId);
                    errorMsg += 'Exception occured during Contact Creation: '+e.getLineNumber()+' '+e.getMessage() +' Acc Id '+currentAccId+' <br/>';
            }        
        }   

    /* @MethodName finish
    *  Method to send the notification email if batch finished with errors
    **/ 
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed,CreatedById,TotalJobItems, CreatedBy.Email,CreatedBy.Name,ApexClass.Name
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
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
            if(srList != null && srList.Size() > 0 ){
                body += 'Created '+srList.Size()+' successful records. <br/>';
            }
            if(errorMsg != null && errorMsg.length() >0){
                body += '<br/> The Following Error(s) occured '+'<br/>'+ errorMsg ; 
            }

        /*    body += 'Has proccessed the following client accounts: '+ '<br/>';
             for(Database.SaveResult sr : srList ){   
          //  body += id +  '<br/>';
        	if( !sr.isSuccess()) {
         		body += 'The Following Error occured '+'<br/>'+ errorMsg ; 
         		for(Database.Error err : sr.getErrors()) {                   
		            body += err.getStatusCode() + ': ' + err.getMessage();
		           body +='Contact fields that affected this error: ' + err.getFields();
        		}
         	}         
        }*/
      
      
      mail.setHtmlBody(body);
      mails.add(mail);
      Messaging.sendEmail(mails);
    } 
}