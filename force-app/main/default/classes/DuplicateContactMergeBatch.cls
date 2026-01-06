/***********************************************************************
Class Name: DuplicateContactMergeBatch
Dependent Classes: DuplicateContactMergeSched, DuplicateContactMergeBatchTest 
Date: 
Jira ID:
Description : 
************************************************************************/

global class DuplicateContactMergeBatch Implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT id, name 
            FROM DuplicateRecordSet
            Where DuplicateRuleId =: System.Label.ContactDuplicateRuleId AND RecordCount > 1
        ]);  
        
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> scope) {
        mergeContacts(scope);     
    }
    
    public static void mergeContacts(List<DuplicateRecordSet> dupset){
        String dupSetId;
        if(dupset!=null && !dupset.isEmpty()){
            dupSetId = dupset[0].id;
        }	
        system.debug('dupset Id ----' + dupSetId);
        Map<Id, Set<Id>> mapDuplicateRecordItem =  new Map<Id, Set<Id>>();
        Set<Id>  setContactId = new set<id>();
        for(DuplicateRecordItem drI : [SELECT Id,RecordId, DuplicateRecordSetId FROM DuplicateRecordItem 
                                       WHERE DuplicateRecordSetId = :dupSetId]){                                       
        	setContactId.add(drI.RecordId);
		}  

        Contact mastercontact = null;
        List<Contact> contactList = [SELECT Id, lastname,email, ownerid,phone,Business_Rule_Association__c, Notification_Associated__c, Last_Activity_Date__c
                                     FROM Contact WHERE Id In : setContactId AND (Account_Record_Type__c = :Constant_Util.CLIENT OR Account_Record_Type__c = null) AND Name != 'Service Channel' ORDER BY Last_Activity_Date__c DESC NULLS LAST LIMIT 3];

        Map<Id,Contact> mapContact = new Map<Id,Contact>([Select Id, lastname, email,phone,AccountId from Contact where Id In : contactList  ORDER BY Last_Activity_Date__c DESC NULLS LAST]);
        Integer businessRuleCount = 0;
		Integer notificationCount = 0;
		for(Contact con : contactList){												   
            if(con.Business_Rule_Association__c == 'Yes' ){
                mastercontact = con;
				businessRuleCount++;
            }
        }
        
        if(mastercontact == null) {
            for(Contact con : contactList){												   
                if(con.Notification_Associated__c){
                    mastercontact = con;
					notificationCount++;
                }
            }
        }
        
        if(mastercontact == null && contactList.size()>0 ) {
            mastercontact = contactList[0];
        }
        
        Savepoint sp = Database.setSavepoint();
        if(businessRuleCount < 2 && notificationCount < 2 && mapContact != null && mastercontact != null && mapContact.containsKey(mastercontact.Id) ){
            mastercontact = mapContact.get(mastercontact.Id);
            List<Contact> merCon = new List<Contact>();
            for(Contact c : mapContact.values()){
                if(c.id != mastercontact.Id){
                    merCon.add(c);
                }
            }
			
			
            system.debug('mastercontact Id ----' + mastercontact);
            system.debug('merCon Id ----' + merCon);
			if(merCon.size() > 0 && merCon.size() <= 2){
				try {
					//Pre-merge task
					List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
					for(AccountContactRelation acr : [select id, AccountId , Contact.accountid from AccountContactRelation WHERE ContactId IN :merCon]){
						if(acr.Contact.AccountId != acr.AccountId){
							accountContactList.add(acr);
						}
					}
					if(accountContactList != null  && !accountContactList.isEmpty() ) {
						delete accountContactList;
					}
					merge mastercontact merCon;
				} catch (DmlException e) {
					Database.rollback( sp );
					System.debug('An unexpected error has occurred: ' + e.getMessage()); 
				}
			} 
        }
        
    }
    
    global void finish(Database.BatchableContext BC){} 
    
    global void execute(SchedulableContext sc){
		DuplicateContactMergeBatch mergeBatch = new DuplicateContactMergeBatch();
		Database.executeBatch(mergeBatch , 1);
    }
    
}