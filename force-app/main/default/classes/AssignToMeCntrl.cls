/**************************************************
* ClassName:AssignToMeCntrl
* Author:Niranjan 
* Description:This class was created as part of Release1-Sprint3 which changes the task assignment to the logged in user
* CreatedDate:23/7/2019
* Modified on 09/23/2020 for SDT-13544
* **************************************************/
public Without Sharing class AssignToMeCntrl{
	@AuraEnabled
	public static string TaskAssignmentChange(Id recordId) {    
        string toastInfoMsg = '';

		List<Task> taskLst = [SELECT Id, OwnerId, Owner.Name, Status, Outcome__c, RecordType.DeveloperName FROM Task WHERE (Id =: recordId AND 
					(Status =: Constant_Util.OPEN OR (Status =: Constant_Util.COMPLETED AND outcome__c = null)) AND OwnerId !=: UserInfo.getUserId())];
		try{
			if(taskLst != null && !taskLst.isEmpty()){
				//Assigning Task ownerId to LoggedinUserId 
				if(taskLst[0].RecordType.DeveloperName.equals(Constant_Util.EMAILTOCASERECORD)) {
					if(taskLst[0].OwnerId != null && !taskLst[0].Owner.Name.equals(Constant_Util.GROUP_USERNAME)){
						taskLst[0].OwnerId = UserInfo.getUserId();
						update taskLst;
					} else {
						toastInfoMsg = Constant_Util.ASSIGN_TO_ME_EMAIL_TASK_TOAST_MSG;
					}
				} else {
					taskLst[0].OwnerId = UserInfo.getUserId();
					update taskLst;
				}
			} else{
				toastInfoMsg = Constant_Util.ASSIGN_TO_ME_TOAST_MSG;
			}
		} catch(Exception ex){
			UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);            
		}
		return toastInfoMsg;
	}
}