public class ContactNotifyPrefTriggerHelper {

/*
* This method is used to ValidateOnInsert CNP record before inserting.
* @owner : Devendra Patel
* @param : list<Contact_Notification_Preference__c>
*/
    public static void validateOnInsert(list<Contact_Notification_Preference__c> newCNPList){
        duplicateCheck(newCNPList);
    }
 
/*
* This method is used to ValidateOnUpdate CNP record before inserting.
* @owner : Devendra Patel
* @param : list<Contact_Notification_Preference__c>
*/
    
    public static void validateOnUpdate(list<Contact_Notification_Preference__c> newCNPList,map<Id,Contact_Notification_Preference__c> oldCNPMap,map<Id,Contact_Notification_Preference__c> newmap){
        List<Contact_Notification_Preference__c> cnpDupList= new List<Contact_Notification_Preference__c> ();
        for(Contact_Notification_Preference__c cnpItem: newCNPList ){
            if(oldCNPMap.get(cnpItem.id).Notification_Type__c != cnpItem.Notification_Type__c ||
              oldCNPMap.get(cnpItem.id).Contact_Name__c != cnpItem.Contact_Name__c){
                cnpDupList.add(cnpItem);
            }   
        }
        if(cnpDupList.size() > 0){        
            duplicateCheck(cnpDupList);
        }
    }
   
/*
 * This method used to check duplicate contact with same notification type
 * @owner : Devendra Patel
 * @param: list<Contact_Notification_Preference__c> 
*/
    public static void duplicateCheck(list<Contact_Notification_Preference__c> newCNPList){
          set<Id> cnpContactIdset = new set<Id>();
        Map<string,id> avlbNotification = new Map<string,id>();
           for(Contact_Notification_Preference__c cnp : newCNPList){  
               If(newCNPList !=null && newCNPList.size() > 0 ){
                cnpContactIdset.add(cnp.Contact_Name__c);
            }
        }
        
       for(contact_notification_Preference__c cnpItem : [SELECT  id,Contact_Name__c, Notification_Type__c  FROM contact_notification_Preference__c WHERE Contact_Name__c IN:cnpContactIdset ]){
            avlbNotification.put(cnpItem.Contact_Name__c + cnpItem.Notification_Type__c, cnpItem.id );
        }
            for(Contact_notification_Preference__c cnpRec :newCNPList){
                Id cnpId= avlbNotification.get(cnpRec.Contact_Name__c+cnpRec.Notification_Type__c);
                if(cnpId !=null ){  
                     cnpRec.addError(System.Label.DupContSameNotiErrMsg);
                    } 
            }
    }    
}