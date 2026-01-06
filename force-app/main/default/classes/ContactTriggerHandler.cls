/*************************************************************
@Name: ContactTriggerHandler
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Handler Class to Perform operations on Contact
@UsedBy: ContactTrigger
**************************************************************/
public without sharing  class ContactTriggerHandler {
    
    /*
	* It is invoked on before updating the case
	* @owner : Anupreethy
	* @param : Contact List
	*/
    public static void onbeforeUpdate(List<Contact> newContactList,Map<Id,Contact> oldContactMap,Map<Id,Contact> newContactMap){
            ContactTriggerHelper.checkContactInServiceApprover(newContactList,false);
			ContactTriggerHelper.updateDateValidated(newContactList, oldContactMap, newContactMap,false);
            if(userInfo.getUserId() != System.label.UserCheckId && Boolean.valueOf(System.label.IsActiveOptinOptout))
            {        
                ContactTriggerHelper.onBeforeContactMerge(oldContactMap,newContactMap);
            }			
    }
    
    /*
	* It is invoked on after updating the Case.
	* @owner : Anupreethy
	* @param : Contact List
	*/
    public static void onbeforeDelete(List<Contact> newContactList){
        
            ContactTriggerHelper.checkContactInServiceApprover(newContactList,true);
			ContactTriggerHelper.validateDeletion(newContactList);
    }
    /*
	* It is invoked on after deleting the Contact.
	* @owner : WM
	* @param : Contact List
	*/
    public static void onAfterDelete(List<Contact> oldContactList){
        
        if(userInfo.getUserId() != System.label.UserCheckId && Boolean.valueOf(System.label.IsActiveOptinOptout))
        {
            ContactTriggerHelper.checkDeletedContact(oldContactList);
        }   
    }

    /*
	* It is invoked on after updating the Case.
	* @owner : WM
	* @param : Map<Id,Contact> for Old Contacts and Map<Id,Contact> for New Contacts
	*/
    public static void onAfterUpdate(Map<Id,Contact> oldContactMap,Map<Id,Contact> newContactMap){
        
        if(RecurrsiveTriggerHandler.getRunTimes() < 1 && userInfo.getUserId() != System.label.UserCheckId && Boolean.valueOf(System.label.IsActiveOptinOptout))
        {
            RecurrsiveTriggerHandler.setRunTimes();
            ContactTriggerHelper.onContactMerge(oldContactMap,newContactMap);   
        }
        
    }

	 public static void onbeforeInsert(List<Contact> newContactList,Map<Id,Contact> newContactMap){
        ContactTriggerHelper.updateDateValidated(newContactList, null, newContactMap,true);
    }	
}