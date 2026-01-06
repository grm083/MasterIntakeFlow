/*
* @Name         : CommentController
* @Author       : TCS
* @Date         : 
* @Vendor    : TCS
* @Description  : This class is the apex controller of the 'AddComment', 'UpdateStatus' and 'UpdateScheduled' aura components.         
*/
public class CommentController {
    
    /*
	* @Method Name    : createComment
	* @Author         : TCS
	* @description    : 
	* @param          : Comment body(String) and Case record id(Id).
	* @return         : The return message which is a string value.
	*/
    //Changes related to SDT -31863 - adding new argument for adding email- List<String>values
    @AuraEnabled
    public static TwoWayService.responseBodyObjForAddComment createComment(List<String>values,String commentBody, String caseId) {
        String returnMessage;
        Case currentCase =TwoWayService.returnCaseDetails(caseId);
        //making changes for passing reference number instead of case number
        //Changes related to SDT -31863 - adding email as argument - values
        TwoWayService.responseBodyObjForAddComment returnResponseObj = TwoWayService.returnResponseBodyObj(values,commentBody, currentCase.Origin, currentCase.Reference_Number__c, UserInfo.getName());
        system.debug(returnResponseObj);
        return returnResponseObj;
    }
   
}