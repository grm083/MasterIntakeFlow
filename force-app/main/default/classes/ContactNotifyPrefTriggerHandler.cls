/*************************************************************
@Name: ContactNotifyPrefTriggerHandler
@Author: Devendra Patel
@CreateDate: 07/15/2020
@Description: Handler Class to Perform operations on Contact Notification Preferrence
@UsedBy: ContactNotificationPreferenceTrigger
**************************************************************/
public class ContactNotifyPrefTriggerHandler {

     /*
    * It is invoked on before Insert the Contact Notification preference record 
    * @owner : Devendra Patel
    * @param : map<Id,Contact_Notification_Preference__c>
    */
    public static void onBeforeInsert(list<Contact_Notification_Preference__c> newCNPList){
        try{              
           ContactNotifyPrefTriggerHelper.validateOnInsert(newCNPList); 
        }
        catch(Exception ex){ 
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
    
     /*
    * It is invoked on before Update the Contact Notification preference record  
    * @owner : Devendra Patel
    * @param : map<Id,Contact_Notification_Preference__c>
    */
    public static void onBeforeUpdate(list<Contact_Notification_Preference__c> newCNPList,map<Id,Contact_Notification_Preference__c> oldCNPMap,map<Id,Contact_Notification_Preference__c> newmap){
        try{
            ContactNotifyPrefTriggerHelper.validateOnUpdate(newCNPList,oldCNPMap,newmap); 
           
        }  
        catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
    
}