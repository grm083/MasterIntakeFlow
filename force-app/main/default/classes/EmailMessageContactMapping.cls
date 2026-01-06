/*************************************************************
@Name: EmailMessageContactMapping
@Author: WM
@CreateDate: 14/07/2020
@Description: SDT-14108 - Class to Update Contact on Case
@UsedBy: 
**************************************************************/
public without sharing class EmailMessageContactMapping {
    
    /*
* This method is Invoked from the Process Builder
* @owner : WM
* @param : List<EmailMessage>
*/
    @InvocableMethod(label='Email Message Method for Contact' description='It is invocable method for the EmailMessage for contact')
    public static void emailMessageContact(List<EmailMessage> lstEmailMessage){
        try{
            mapContact(lstEmailMessage);
        }
        catch(Exception ex){
            
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        } 
    }
    
    public static void mapContact(List<EmailMessage> lstEmailMessage){
        Set<String> emailAddressSet = new Set<String>();
        Map<String,List<Id>> mapOfEmailContact= new map<String,List<Id>>();
        Map<String,List<Id>> mapOfServiceContact= new map<String,List<Id>>();
        Map<String,Id> mapOfFinalContact= new map<String,Id>();
        Set<Id> setofContacts = new Set<Id>();
        String updateContact;
        
        for(EmailMessage eml : lstEmailMessage){
            if(eml.FromAddress != null){
                emailAddressSet.add(eml.FromAddress);
            }
        }
        
        List<Case> lstCase = [Select Id,ContactId,EmailofContact__c from Case where CreatedDate = LAST_N_DAYS:60 and ContactId IN (SELECT ID FROM Contact WHERE Email IN: emailAddressSet AND Contact_Status__c =: Constant_Util.ACTIVE) order by CreatedDate DESC];
        for(Case caseRecord : lstCase){
            setofContacts.add(caseRecord.ContactId);
            if(mapOfEmailContact != null && mapOfEmailContact.containskey(caseRecord.EmailofContact__c)){
                if(!mapOfEmailContact.get(caseRecord.EmailofContact__c).contains(caseRecord.ContactId)){
                    mapOfEmailContact.get(caseRecord.EmailofContact__c).add(caseRecord.ContactId);
                }
            } else {
                mapOfEmailContact.put(caseRecord.EmailofContact__c, new List<Id>{caseRecord.ContactId});
            }
        }
        
        for(Service_Approver__c sa : [Select Id,Business_Rule__c,Business_Rule__r.Active__c,Active__c,Approver_Type__c,Approver_Contact__r.Email,Approver_Contact__c from Service_Approver__c where Business_Rule__r.Active__c = true and Approver_Type__c =: Constant_Util.CONTACT_RECORD_TYPE and Approver_Contact__c IN :setofContacts]){
            if(mapOfServiceContact != null && mapOfServiceContact.containskey(sa.Approver_Contact__r.Email)){
                if(!mapOfServiceContact.get(sa.Approver_Contact__r.Email).contains(sa.Approver_Contact__c)){
                    mapOfServiceContact.get(sa.Approver_Contact__r.Email).add(sa.Approver_Contact__c);
                }
            } else {
                mapOfServiceContact.put(sa.Approver_Contact__r.Email, new List<Id>{sa.Approver_Contact__c});
            }
        }
        if(!mapOfEmailContact.isEmpty() && mapOfEmailContact.Size() > 0){
            for(string em : mapOfEmailContact.keySet()){
                if(mapOfEmailContact.containsKey(em) && mapOfEmailContact.get(em).Size() == 1){
                    mapOfFinalContact.put(em,mapOfEmailContact.get(em)[0]);
                }else if( mapOfEmailContact.containsKey(em) && !mapOfServiceContact.isEmpty() && mapOfServiceContact.size() > 0 && mapOfServiceContact.containsKey(em) && mapOfServiceContact.get(em).Size() == 1){
                    mapOfFinalContact.put(em,mapOfServiceContact.get(em)[0]);
                }else if(mapOfEmailContact.containsKey(em)){
                    mapOfFinalContact.put(em,mapOfEmailContact.get(em)[0]);
                }
            } 
        }
        
        List<case> listCase = new List<case>();
        for(EmailMessage eml : lstEmailMessage){
            if(eml.FromAddress != null && mapOfFinalContact.containsKey(eml.FromAddress)){
                case updateCase = new case(Id = eml.ParentID, ContactId = mapOfFinalContact.get(eml.FromAddress));
                listCase.add(updateCase);
            }
			  else
            {
                case updateCase = new case(Id = eml.ParentID, ContactId = null);
                listCase.add(updateCase);    
            }
        }
        Database.update(listCase);
    }
}