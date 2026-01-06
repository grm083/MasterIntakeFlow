/*************************************************************
@Name: ServiceStatusTriggerHelper
@Author: Devendra Patel
@CreateDate: 07/27/2020
@Description: Helper Class to Perform operations on service status record
@UsedBy: ServiceStatusTriggerHandler.
*************************************************************
*/
public without sharing class ServiceStatusTriggerHelper {
    
    public static final string NOTIFICATION_STATUS_ON ='On';
    public static final string MESSAGE_STATUS_COMPLETE ='Complete';
    public static final string NOTIFICATION_PREF_DONOTNOTIFY ='Do Not Notify';
    public static final string MESSAGE_STATUS_PENDING ='Pending';
    
/*
* This method is used to process pending records on service status on after update.
* @owner : Devendra Patel
* @param : list<Service_Status__C>  
*/
    public static void ProcessPendingRecords(list<Service_Status__c> newSSList){
        Map<id, Service_Status__c>serviceStatusMap = new Map<Id, Service_Status__c>();
        Map<id, string>serviceStatusLocationMap = new Map<Id, string>();
        Map<id, List<Id>> ACRMap = new   Map<id, List<id>>();
        List<Service_Status__c> updatedServiceStatusList = new List<Service_Status__c>();
        set<Id> contantIdSet= new set<Id> ();
        Map<id, List<Notification_Asset__c>> notificationAssetMap = new Map<id, List<Notification_Asset__c>> ();
        List<Notification_Contact__c> insertNotificationContactList = new List<Notification_Contact__c>();
        List<Notification_Asset__c> notifiAssetList= new   List<Notification_Asset__c>();
        Boolean isNoAssetFound= false;
        Boolean isEligibleAssetFound= false;
        Set<string> accNotifEnabled= new Set<string>();
        Map<id,id> locationClientMap = new Map<Id,Id>();
        Map<string,string> contactPrefMap = new Map<string,string>();
        
        try{
            for(Service_Status__C serviceStatusRec : newSSList)
            {   // check if new message status is pending 
                if(MESSAGE_STATUS_PENDING.equalsIgnoreCase(serviceStatusRec.Message_Status__c) ){                
                    serviceStatusMap.put(serviceStatusRec.id, serviceStatusRec);   // created a servicestatusMap of records to be processed
                    serviceStatusLocationMap.put(serviceStatusRec.id, serviceStatusRec.Location__c );//// created a servicestatusLocationMap of Locations to be processed
                }
            }
            
            //List<Notification_Asset__c> notificationAssetList= [SELECT id,Service_StatusId__c, Is_Eligible_for_Notification__c FROM Notification_Asset__c WHERE Service_StatusId__c IN :serviceStatusMap.Keyset() ];
            
            for(Notification_Asset__c notificatioAssRec :[SELECT id,Service_StatusId__c, Is_Eligible_for_Notification__c FROM Notification_Asset__c WHERE Service_StatusId__c IN :serviceStatusMap.Keyset() ]){            
                if(notificationAssetMap.containsKey(notificatioAssRec.Service_StatusId__c)){ 
                    notificationAssetMap.get(notificatioAssRec.Service_StatusId__c).add(notificatioAssRec); // preparing a map of notification assets corresponding to service status
                }
                else{
                    notificationAssetMap.put(notificatioAssRec.Service_StatusId__c, new List<notification_asset__c>{notificatioAssRec}); 
                }
            }
            
            for(Account_Notification_Preference__c anpRec : [SELECT id, Notification_Status__c, Notification_Type__c, Account_Name__c FROM Account_Notification_Preference__c  WHERE Account_Name__c IN  (SELECT parentID FROM Account WHERE Id IN :serviceStatusLocationMap.values() )]){
                if(NOTIFICATION_STATUS_ON.equalsIgnoreCase(anpRec.Notification_Status__c))  {
                    accNotifEnabled.add(anpRec.Account_Name__c+ anpRec.Notification_Type__c);  // preparing set of Accounts and notification types for which notification is turned on
                }
            }
            
            for(AccountContactRelation acrRec:   [SELECT ContactId,AccountId,Account.ParentId,  id,Notification_Point_of_Contact__c  FROM AccountContactRelation acr WHERE AccountId IN: serviceStatusLocationMap.values() ]){
                if(!locationClientMap.containsKey(acrRec.AccountId)){
                    locationClientMap.put(acrRec.AccountId,acrRec.Account.ParentId);   // preparing map of location and parent account for all of the service status records
                }
                
                if(acrRec.Notification_Point_of_Contact__c  ){   // check for POC
                    contantIdSet.add(acrRec.ContactId);
                    if(ACRMap !=null && ACRMap.containsKey(acrRec.AccountId) ){
                        ACRMap.get(acrRec.AccountID).add(acrRec.ContactId);  // preparing Account contact relationship map of location and its all POC contacts
                    }
                    else{
                        List<id> contactids= new  List<id>();
                        contactids.add(acrRec.ContactId);
                        ACRMap.put(acrRec.AccountId,contactids);
                    }
                }
            }
            
              for(Contact_Notification_Preference__c cnrRec :[SELECT id, Contact_Name__c,Notification_Preference__c, Notification_Type__c FROM Contact_Notification_Preference__c WHERE Contact_Name__c IN: contantIdSet AND Notification_Preference__c !=: NOTIFICATION_PREF_DONOTNOTIFY ] ){
                   
               
                contactPrefMap.put(cnrRec.Contact_Name__c+cnrRec.Notification_Type__c, cnrRec.id);// preparing a map of contact name + notification type and CNP ID only for those preference which are not having do not notify
            }
            
            for(Service_Status__c ssRec : serviceStatusMap.values()){  // loop through all the pending service status records
                isEligibleAssetFound =false;
                isNoAssetFound=false;
                if(notificationAssetMap != null && notificationAssetMap.containsKey(ssRec.id) ){  // check notification asset has any record cooresponding to service status record
                    notifiAssetList= notificationAssetMap.get(ssRec.id) ; 
                    for(Notification_asset__C NArec:notifiAssetList ){   // we got the notification asset record , now check for the eligibility flag
                        if(NArec.Is_Eligible_For_Notification__c){
                            isEligibleAssetFound=true;
                            break;
                        }
                    }                        
                }else{
                    isNoAssetFound=true;
                }   
                
                //Proceed further only in  case if we found eligible asset or no asset found. 
                if(isEligibleAssetFound ||isNoAssetFound ){
                    if( locationClientMap.containsKey(ssRec.Location__c) &&  accNotifEnabled.contains(locationClientMap.get(ssRec.Location__c) + ssRec.Message_Type__c ) ){ // check if notification is on at account level
                        if( ACRMap != null && ACRMap.containsKey(ssRec.Location__c)){  // check if Account Contant Releation is having any point of contact
                            for(Id contId: ACRMap.get(ssRec.Location__c) ){  // Loop through all the notification point of contacts 
                                if(contactPrefMap.containsKey(contId+ssRec.Message_Type__c)){   // check if contact preferect exists for the contact and notification type
                                        // insert contact record under notification contact and update the flag on service status
                                        Notification_Contact__c notiCont = new Notification_Contact__c();   // create a new object to insert under notification contact
                                        notiCont.Contact_Name__c=contId;
                                        notiCont.Service_StatusId__c= ssRec.id;
                                        noticont.Contact_Notification_Preference__c=contactPrefMap.get(contId+ssRec.Message_Type__c); // associating correct preference with notification contact
                                        insertNotificationContactList.add(notiCont);
                                        ssRec.Is_Ready_For_Notification__c = true;  // set the is ready for notificaiton on service status as true
                                    
                                }
                            }
                        }
                    }
                }
                
                // at the end we are done with service status record
                ssRec.Message_Status__c = MESSAGE_STATUS_COMPLETE; // set the message status as complete on service status
                updatedServiceStatusList.add(ssRec); 
            } 
            if(insertNotificationContactList.size()>0){
                Database.insert(insertNotificationContactList) ; 
            }
            Database.update(updatedServiceStatusList);
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
}