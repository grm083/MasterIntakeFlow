/*************************************************************
@Name: AccountContactRelationTriggerHelper
@Author: Adil Aleem
@CreateDate: 06/07/2020
@Description: Helper Class to Perform operations on AccountContactRelation trigger events
@UsedBy: AccountContactRelationTriggerHandler
**************************************************************/
public without sharing class AccountContactRelationTriggerHelper {
	
	/*******************************************************************************************************
    * @description fetch the No_Of_Locations_Assoc_With_Contact__c of Contact and increment it by one if Account record type is "Location"
    * @param newACRList list of AccountContactRelation
	* @param newACRMap map of id , AccountContactRelation  
	* @param oldACRList list of AccountContactRelation  
	* @param oldACRMap map of id , AccountContactRelation
	* @param isInsert Boolean
    * @param isDelete Boolean
    * @return null
    */
    public static void getNumberOfLocationOnContact(List<AccountContactRelation > newACRList, Map<Id,AccountContactRelation> newACRMap, List<AccountContactRelation > oldACRList, Map<Id,AccountContactRelation> oldACRMap, Boolean isInsert, Boolean isDelete){
    	Set<Id> contactIds = new Set<Id>();
    	if(isInsert){
			for(AccountContactRelation acr : newACRList){
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

	/*******************************************************************************************************
    * @description update No_Of_Locations_Assoc_With_Contact__c by 1 on contact object
    * @param contactIds set of id
    * @return null
    */
	public static void updateNumberOfLocationOnContact(Set<Id> contactIds){
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
	
	/*******************************************************************************************************
    * @description Helper method to check if object's record type is "Location". If yes returns true
    * @param objectName String
	* @param strRecordTypeName String
    * @return Boolean
    */
    public static Boolean getRecordTypeIdbyName(String objectName, String strRecordTypeName){
        Id recordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
        String recordTypeName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
        if(recordTypeName.equalsIgnoreCase(Constant_Util.LOCATION)){
        	return true;
        }
        else{
        	return false;
        }
    }
    
    
    /*******************************************************************************************************
    * @description Before Insert Event method 
    * @param NewACRList list of AccountContactRelation
    * @return null
    */
    public static void validateBeforeInsert(List<AccountContactRelation> NewACRList){         
       ValidateNPOfCont(NewACRList); 
    }
    
    
	/*******************************************************************************************************
    * @description Before Update Event method 
    * @param NewACRList list of AccountContactRelation
	* @param oldACRMap map of id , AccountContactRelation
    * @return null
    */
    public static void validateBeforeUpdate(List<AccountContactRelation > NewACRList, Map<Id,AccountContactRelation> oldACRMap){
       ValidateNPOfCont(NewACRList); 
    }
    
  
    /*******************************************************************************************************
    * @description validate the record to throw error if Notification_Point_Of_Contact__c and Account record type is "Location"
    * @param NewACRList list of AccountContactRelation
    * @return null
    */
    
    public static void ValidateNPOfCont(List<AccountContactRelation> NewACRList)
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

	/*******************************************************************************************************
    * @description update Dispatch Email on change of AccountContactRelation
    * @param newACRList list of AccountContactRelation
	* @param oldACRList list of  AccountContactRelation  
	* @param triggerEvent String 
	* @return null
    */
	public static void updateDispatchEmail(List<AccountContactRelation > newACRList, List<AccountContactRelation > oldACRList, String triggerEvent){
		Set<Id> vendorAccountIds = new Set<Id>();
		List<WorkOrder> woList = new List<WorkOrder>();
		Map<String , String> acrMap = new Map<String , String>();
		List<String> woStatus = new List<String>{Constant_Util.RELEASED_FOR_PAYMENT,Constant_Util.WORK_COMPLETE,Constant_Util.CANCELLED};
		if(triggerEvent == 'isInsert' || triggerEvent == 'isUpdate' ){
			for(AccountContactRelation acr : newACRList){
				if(acr.AccountId != null)
                {
                    vendorAccountIds.add(acr.AccountId);
                }
			}
		}	
		else if(triggerEvent == 'isDelete' ){
			for(AccountContactRelation acr : oldACRList){
				if(acr.AccountId != null)
                {
                    vendorAccountIds.add(acr.AccountId);
                }
			}
		}	
		
		List<AccountContactRelation> acrList = [Select Id, ContactId, Contact.email, AccountId FROM  AccountContactRelation WHERE AccountId IN :vendorAccountIds AND Roles INCLUDES ('Dispatch') order by createddate desc];
        for(AccountContactRelation acr : acrList){
            if(!acrMap.containsKey(acr.AccountId)){
                acrMap.put(acr.AccountId , acr.Contact.Email);
            }
        }

		if(!vendorAccountIds.isEmpty()) {
			for(WorkOrder wo : [Select Id, Dispatch_Email__c, Vendor_Account_Id__c FROM WorkOrder WHERE Vendor_Account_Id__c IN : vendorAccountIds AND status NOT IN : woStatus]) {
				if(!acrMap.isEmpty() && acrMap.containsKey(wo.Vendor_Account_Id__c) && wo.Dispatch_Email__c != acrMap.get(wo.Vendor_Account_Id__c)) {
					wo.Dispatch_Email__c = acrMap.get(wo.Vendor_Account_Id__c);
					woList.add(wo);
				}					
				else if(wo.Dispatch_Email__c != null) {
					wo.Dispatch_Email__c = null;
					woList.add(wo);
				}				
			}	
			if(!woList.isEmpty()){
				try{
                    Database.update(woList,false);
                }
                catch(Exception ex)
                {
                    UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
                }
			}
		}
		
	}
}