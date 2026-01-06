/**************************************************
* ClassName:ChangeTaskAssignmentcntrl
* Author:Niranjan 
* Description:This class was created as part of Release1-Sprint3 which changes the task assignment to the logged in user
* CreatedDate:18/2/2019
* Modified on 09/23/2020 for SDT-13544
* **************************************************/
public Without Sharing class ChangeTaskAssignmentcntrl{
    @InvocableMethod
    public static void ChangeTaskAssignment(List<Task> taskLst) {   
        List<Task> updateTaskLst = new List<Task>();
        string userId = [SELECT Id, Name FROM User WHERE Name =: Constant_Util.GROUP_USERNAME LIMIT 1].Id;
        try{
            if(taskLst != null && !taskLst.isEmpty()){
                for(Task objTask : taskLst){
                    if(objTask.OwnerId.equals(userId) && objTask.Status.equals(Constant_Util.OPEN)){
                        objTask.OwnerId = UserInfo.getUserId();
                        updateTaskLst.add(objTask);
                    } 
                }
            }
        	if(updateTaskLst != null && !updateTaskLst.isEmpty()){
                update updateTaskLst;
            }    
        } catch(Exception ex){
			UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);            
        }
        
    }
}