/*************************************************************
@Name: ContactTriggerHandler
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Handler Class to Perform operations on Contact
@UsedBy: ContactTriggerHandler
**************************************************************/
public without sharing class ContactTriggerHelper {
	
	public static Map<Id,List<Id>> masterId = new Map<Id,List<Id>>();
    /*
* This method will check if the given contact is a Service Approver
* @owner : Anupreethy
* @param : Contact List , Boolean
*/
    public static void checkContactInServiceApprover(List<Contact> contactList, Boolean isDelete){
        set<Id> conIdset = new set<Id>();
        Map<Id,Id> conSAmap = new Map<Id,Id>();
        try{
            for(Contact c : contactList){
                if(isDelete || c.Contact_Status__c == Constant_Util.INACTIVE || String.isEmpty(c.Contact_Status__c)){
                    conIdset.add(c.Id);
                }
            }
            for(Service_Approver__c sa : [SELECT Id,Approver_Contact__c,Business_Rule__r.Name from Service_Approver__c
                                          WHERE Approver_Contact__c IN: conIdset LIMIT 49999])
            {
                conSAmap.put(sa.Approver_Contact__c,sa.Id);
            }
            for(Contact thisContact : contactList){
                if(!conSAmap.isEmpty() && conSAmap.containsKey(thisContact.Id)){
                   thisContact.adderror(Label.ContactisServiceApprover);
                    
                }
            }
        }
        Catch (Exception e){
            // Nova cop
            //To handle Error in future Sprints
        }
    }
   /*
	* This method will check if the given contact is deleted on merge operation
	* @owner : WM
	* @param : Contact List
	*/
    public static void checkDeletedContact(List<Contact> contactList)
    {
        for(Contact con : contactList)
        {
            if(con.MasterRecordId != null && con.Text_Notifications_Opt_In__c )
            {
                if(masterId != null && masterId.containsKey(con.MasterRecordId))
                {
                    List<Id> conList = new List<Id>();
                    conList = masterId.get(con.MasterRecordId);
                    conList.add(con.Id);
                    masterId.put(con.MasterRecordId,conList);
                    
                }
                else
                {
                    masterId.put(con.MasterRecordId,new List<Id>{con.Id});
                }
            }
        }
    }
   /*
	* This method will check if the given contact is updated on merge operation
	* @owner : WM
	* @param : Map<Id,Contact> for Old Contacts and Map<Id,Contact> for New Contacts
	*/    
    public static void onContactMerge(Map<Id,Contact> oldContactMap,Map<Id,Contact> newContactMap)
    {
        List<Id> finalConList = new List<Id>();
        for(Contact newCon : newContactMap.values())
        {
            Contact oldCon = oldContactMap.get(newCon.Id);
            if(oldCon.MobilePhone != newCon.MobilePhone && newCon.Text_Notifications_Opt_In__c && !oldCon.Text_Notifications_Opt_In__c && masterId.containsKey(newCon.Id))
            {
                //Do nothing
            }
            else if(oldCon.MobilePhone != newCon.MobilePhone && newCon.Text_Notifications_Opt_In__c && oldCon.Text_Notifications_Opt_In__c && masterId.containsKey(newCon.Id))
            {
                //Do nothing
            }			
            else if(masterId.containsKey(newCon.Id))
            {
                //call Opt Out
                finalConList.addAll(masterId.get(newCon.Id));
            }
        }
        if(!finalConList.isEmpty())
        {
            ContactTextOptOutInvokableAPI.callOptOutAPI(finalConList);
        }
    }
   /*
	* This method will check if the given contact is updated on merge operation
	* @owner : WM
	* @param : Map<Id,Contact> for Old Contacts and Map<Id,Contact> for New Contacts
	*/    
    public static void onBeforeContactMerge(Map<Id,Contact> oldContactMap,Map<Id,Contact> newContactMap)
    {
        List<Id> finalConList = new List<Id>();
        for(Contact newCon : newContactMap.values())
        {
            Contact oldCon = oldContactMap.get(newCon.Id);
            if(oldCon.MobilePhone != newCon.MobilePhone && newCon.Text_Notifications_Opt_In__c && oldCon.Text_Notifications_Opt_In__c && masterId.containsKey(newCon.Id))
            {
                newCon.isMerged__c = true;
            }
        }
    }	
	
	 public static void updateDateValidated(List<Contact> contactList,Map<Id,Contact> oldContactMap,Map<Id,Contact> newContactMap,Boolean isInsert)
    {
        for(Contact newCon : contactList)
        {
            if(isInsert)
            {
                if(newCon.Email != null && newCon.Email != '')
                {
                    newCon.Email_Validated__c = true;
                    newCon.Date_Validated__c = System.today();
                }
                else if(newCon.Email_Validated__c)
                {
                    newCon.Date_Validated__c = System.today();
                }
            }
            else
            {
                Contact oldCon = oldContactMap.get(newCon.Id);
                if(oldCon.Email_Validated__c != newCon.Email_Validated__c && newCon.Email_Validated__c)
                {
                    newCon.Date_Validated__c = System.today();
                }
                else if(oldCon.Email_Validated__c != newCon.Email_Validated__c && !newCon.Email_Validated__c)
                {
                    newCon.Date_Validated__c = null;
                }
                else if(oldCon.Email != newCon.Email && (newCon.Email == '' || newCon.Email == null))
                {
                    newCon.Email_Validated__c = false;
                    newCon.Date_Validated__c = null;
                }
            }
        }
    }
   /*
	* This method will check if Service Channel contact is being deleted
	* @owner : WM
	* @param : Contact List
	*/
    public static void validateDeletion(List<Contact> contactList)
    {
        for(Contact con : contactList)
        {
            if(con.FirstName != null && con.LastName != null)
            {
                if(Constant_Util.SERVICE.equalsIgnoreCase(con.FirstName) && Constant_Util.SCHANNEL.equalsIgnoreCase(con.LastName))
                {
                    con.adderror(Constant_Util.SERVICE_CHANNEL_ERROR);
                }  
            }
        }
    } 	
	
}