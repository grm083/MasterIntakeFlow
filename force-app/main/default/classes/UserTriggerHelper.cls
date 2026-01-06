/*************************************************************
@Name: UserTriggerHelper
@Author: Anupreethy
@CreateDate: 10/04/2019
@Description: Handler Class to Perform operations on User
@UsedBy: UserTriggerHandler
**************************************************************/
public without sharing class UserTriggerHelper {
    /*
* This method will check if the given User/Account Team Member is a Service Approver
* @owner : Anupreethy
* @param : User List
*/
    public static void checkRelatedServiceApprover(Map<Id,User> newUserMap , Map<Id,User> OldUserMap){
        Map<Id,Id> userSAmap = new Map<Id,Id>();
        Map<Id,Id> accTeamSAmap = new Map<Id,Id>();
        User oldUser = new User();
        try{ 
           // Include check for Active__c = TRUE
           for(Service_Approver__c thisApprover : [SELECT Id,User__c,Account_Team_Member__c 
                                                   FROM Service_Approver__c 
                                          		   WHERE ( User__c IN: newUserMap.keySet() 
                                                   OR Account_Team_Member__c IN: newUserMap.keySet()) AND Active__c = True LIMIT 49999 ])
            {
                if(String.isNotBlank(thisApprover.User__c)){
                    userSAmap.put(thisApprover.User__c,thisApprover.Id); 
                }
                else if (String.isNotBlank(thisApprover.Account_Team_Member__c)){
                    accTeamSAmap.put(thisApprover.Account_Team_Member__c,thisApprover.Id); 
                }
            }
           for(User thisUser: newUserMap.values()){
                 oldUser = OldUserMap.get(thisUser.id);
                if(!OldUserMap.isEmpty() && OldUserMap.containsKey(thisUser.id) 
                   && OldUserMap.get(thisUser.Id).isActive!= thisUser.IsActive ){
                    if (!userSAmap.isEmpty() && userSAmap.containsKey(thisUser.Id)){
                        thisUser.addError(Label.UserIsServiceApprover); 
                    }
                    else if (!accTeamSAmap.isEmpty() && accTeamSAmap.containskey(thisUser.Id)){
                        thisUser.addError(Label.AccTeamMemIsServiceApprover);
                    }  
                    else{
                        // Nova cop
                    }
                }
               else{
                   // Nova cop
               }
            }
        }
        Catch (Exception e){
            //To handle Error in future Sprints
            System.debug('Exception::::'+e.getStackTraceString());
           	
        }
    }
}