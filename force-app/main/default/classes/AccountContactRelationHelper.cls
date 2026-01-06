/*************************************************************
@Name: AccountContactRelationHelper
@Author: Yogesh Sharma
@CreateDate: 01/05/2020
@Description: Helper Class to Perform operations on AccountContactRelation
@UsedBy: AccountContactRelationHandler
**************************************************************/
public without sharing class AccountContactRelationHelper {

	/*
	* This method is used to get Number of Locations on contact.
	* @owner : Yogesh Sharma
	* @param : 
	*/
   /* public static void getNumberOfLocationOnContact(List<AccountContactRelation > newACRList, Map<Id,AccountContactRelation> newACRMap, List<AccountContactRelation > oldACRList, Map<Id,AccountContactRelation> oldACRMap, Boolean isInsert, Boolean isDelete){
    	Set<Id> contactIds = new Set<Id>();
    	if(isInsert){
			for(AccountContactRelation acr : newACRList){
				System.debug('>>>getRecordTypeIdbyName(Constant_Util.ACCOUNT,acr.Account_Record_Type__c)'+getRecordTypeIdbyName(Constant_Util.ACCOUNT,acr.Account_Record_Type__c));
				if(getRecordTypeIdbyName(Constant_Util.ACCOUNT,acr.Account_Record_Type__c)){
					contactIds.add(acr.ContactId);
				}	 
			}
			if(!contactIds.isEmpty()){
				updateNumberOfLocationOnContact(contactIds);
			} 
		}	
		
		if(isDelete){
			for(AccountContactRelation acr : oldACRList){
				if(getRecordTypeIdbyName(Constant_Util.ACCOUNT,acr.Account_Record_Type__c)){
					contactIds.add(acr.ContactId);
				}	
			}  
			if(!contactIds.isEmpty()){
				updateNumberOfLocationOnContact(contactIds);
			}
		}	
    } 
	/*
	* This method is used to update Number of Locations on contact.
	* @owner : Yogesh Sharma
	* @param : 
	*/
	/* public static void updateNumberOfLocationOnContact(Set<Id> contactIds){
		List<Contact> contactListToUpdate = new List<Contact>();
    	Map<Id,Integer> getNumberOfLocationByContactId = new Map<Id,Integer>();
    	
		if(!contactIds.isEmpty()){
			List<AccountContactRelation> acrList = [SELECT id, AccountId, ContactId, Account_Record_Type__c FROM AccountContactRelation WHERE Account_Record_Type__c =: Constant_Util.LOCATION AND ContactId IN : contactIds];
			if(acrList != Null && !acrList.isEmpty()){
				for(AccountContactRelation acr : acrList){
					if(getNumberOfLocationByContactId.containsKey(acr.ContactId)){
						getNumberOfLocationByContactId.put(acr.ContactId,getNumberOfLocationByContactId.get(acr.ContactId)+1);
					}
					else{
						getNumberOfLocationByContactId.put(acr.ContactId,1);
					}  
				}
			}
			List<Contact> conList = [SELECT Id, No_Of_Locations_Assoc_With_Contact__c FROM Contact WHERE Id IN : contactIds];
			if(conList != Null && !conList.isEmpty()){
				for(Contact con : conList){
					if(getNumberOfLocationByContactId.get(con.Id) != Null){
						con.No_Of_Locations_Assoc_With_Contact__c = getNumberOfLocationByContactId.get(con.Id);
					}
					else{
						con.No_Of_Locations_Assoc_With_Contact__c = 0; 
					}
					contactListToUpdate.add(con);
				}
			}
			if(!contactListToUpdate.isEmpty()){  
				Database.update(contactListToUpdate,false);
			}
			
		}
	}
	*/

 /*   public static Boolean getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
        String recordTypeName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        if(recordTypeName.equalsIgnoreCase(Constant_Util.LOCATION)){
        	return true;
        }
        else{
        	return false;
        }
    }
    */
    
     /*
	* New methods added for Notification- SDT-9649 to validate record beore insert
	* @owner : Devendra Patel
	* @param : List<AccountContactRelation> 
	*/
   /* public static void validateBeforeInsert(List<AccountContactRelation> NewACRList){         
       ValidateNPOfCont(NewACRList); 
    }
    */
    
     /*
	* New methods added for Notification- SDT-9649 to validate record beore update.
	* @owner : Devendra Patel
	* @param : List<AccountContactRelation> ,Map<Id,AccountContactRelation> 
	*/
   /* public static void validateBeforeUpdate(List<AccountContactRelation > NewACRList, Map<Id,AccountContactRelation> oldACRMap){
       ValidateNPOfCont(NewACRList); 
    }
    */
  
    /*
	* Method to validate POC to be set only for contact associated location record type.
	* @owner : Devendra Patel
	* @param : List<AccountContactRelation> 
	*/
    
   /* public static void ValidateNPOfCont(List<AccountContactRelation> NewACRList)
    {
        // check for the notification point of contact checked then its accout record type should be location
        // if account record type is anything other throw the error
        for(AccountContactRelation ACRrec: NewACRList)
        {
            if(ACRrec.Notification_Point_Of_Contact__c && ! Constant_Util.LOCATION.equalsIgnoreCase(ACRrec.Account_Record_Type__c) ){
                ACRrec.addError(System.Label.NotiPointContactErrMsg);
            } 
        }
    }
	*/
}