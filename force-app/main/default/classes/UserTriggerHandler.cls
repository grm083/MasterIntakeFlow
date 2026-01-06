/*************************************************************
@Name: UserTriggerHandler
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Handler Class to Perform operations on User
@UsedBy: UserTrigger
**************************************************************/
public without sharing class UserTriggerHandler {
    
    /*
	* It is invoked on before updating the case
	* @owner : Anupreethy
	* @param : User List
	*/
    public static void onbeforeUpdate(Map<Id,User> newMap,Map<Id,User> oldMap){
            UserTriggerHelper.checkRelatedServiceApprover(newMap,oldMap);
        }
}