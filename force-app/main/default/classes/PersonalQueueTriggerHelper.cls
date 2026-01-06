/*************************************************************
@Name: PersonalQueueTriggerHelper
@Author: WM
@CreateDate: 10/07/2023
@Description: Handler Class to Perform operations on PersonalQueueInfo
@UsedBy: PersonalQueueTriggerHandler
**************************************************************/
public class PersonalQueueTriggerHelper {
    /*
    * This method will identify whether the user is a CAT user or a team user. 
    * @owner : WM
    * @param :  Map,Map,Boolean
    */
    public static void isWorkflowTeamOrCatUser(Map<Id, Personal_Queue_Info__c> newPersQueueMap,Map<Id, Personal_Queue_Info__c> oldPersQueueMap, Boolean isUpdate,List<Personal_Queue_Info__c> pqueueList)
    {
        List<String> teamName = new List<String>();
        Map<String,Id> userDetailMap = new Map<String,Id>();
        Map<String,Id> teamUserDetailMap = new Map<String,Id>();
        Personal_Queue_Info__c oldPqueueRecord = new Personal_Queue_Info__c();
        try{
            for(CSR_User_Data_Setup__mdt teamMetaName : [select Id,Acorn_Team__c, SFDC_Team__c,Team_User_Name__c,SFDC_user_Id__c,Acorn_Team_Queue__c from CSR_User_Data_Setup__mdt where Team_User_Name__c like 'Sales%'])
            {
                teamUserDetailMap.put(teamMetaName.Team_User_Name__c,teamMetaName.SFDC_user_Id__c);
                teamUserDetailMap.put(teamMetaName.Acorn_Team_Queue__c,teamMetaName.SFDC_user_Id__c);
                if(teamMetaName.Team_User_Name__c.contains('/'))
                {
                    String replacedTeamname = teamMetaName.Team_User_Name__c.replace('/', ' ');
                    teamUserDetailMap.put(replacedTeamname,teamMetaName.SFDC_user_Id__c);
                }
            }
            for(User u : [select Id,Username from user where profile.name = 'Customer Account Team' AND IsActive = True])
            {
                List<String> splitUsername = u.Username.split('@');
                userDetailMap.put(splitUsername[0],u.Id);
            }
            if(!isUpdate)
            {
                for(Personal_Queue_Info__c pqInfo : pqueueList)
                {
                    if(teamUserDetailMap.containsKey(pqInfo.Workflow_TeamUser__c))
                    {
                        pqInfo.isWorkflowTeam__c = True;
                        pqInfo.Workflow_TeamUserId__c = teamUserDetailMap.get(pqInfo.Workflow_TeamUser__c);
                    }
                    else if(userDetailMap.containsKey(pqInfo.Workflow_TeamUser__c))
                    {
                        pqInfo.isWorkflowCatUser__c = True;
                        pqInfo.Workflow_TeamUserId__c = userDetailMap.get(pqInfo.Workflow_TeamUser__c);
                    }
                }
            }
            else
            {
                for(Personal_Queue_Info__c thisPqueue : newPersQueueMap.values()){
                    oldPqueueRecord = oldPersQueueMap.get(thisPqueue.Id);
                    if(oldPqueueRecord.Workflow_TeamUser__c != thisPqueue.Workflow_TeamUser__c)
                    {
                        if(teamUserDetailMap.containsKey(thisPqueue.Workflow_TeamUser__c))
                        {
                            thisPqueue.isWorkflowTeam__c = True;
                            thisPqueue.isWorkflowCatUser__c = false;
                            thisPqueue.Workflow_TeamUserId__c = teamUserDetailMap.get(thisPqueue.Workflow_TeamUser__c);
                        }
                        else if(userDetailMap.containsKey(thisPqueue.Workflow_TeamUser__c))
                        {
                            thisPqueue.isWorkflowCatUser__c = True;
                            thisPqueue.isWorkflowTeam__c = false;
                            thisPqueue.Workflow_TeamUserId__c = userDetailMap.get(thisPqueue.Workflow_TeamUser__c);
                        }
                        else
                        {
                            thisPqueue.isWorkflowTeam__c = False;
                            thisPqueue.isWorkflowCatUser__c = False;
                        }
                    }
                    
                } 
            }
        }
        catch(Exception e)
        {
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
}