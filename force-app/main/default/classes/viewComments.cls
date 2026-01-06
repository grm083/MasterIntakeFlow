/*
* @Name         : viewComments
* @Author       : TCS
* @Date         : 
* @Vendor    : TCS
* @Description  : This class is the apex controller of the 'viewComments' LWC component.         
*/

public class viewComments {
    
    
    /*
     * @Method Name    : getcommentObjectList
     * @Author         : TCS
     * @description    : 
     * @param          : Case record Id
     * @return         : TwoWayService.DisplayCommentsWrapper object with values IN THE JSON received from api utility class. 
     */
    @AuraEnabled(cacheable=false)
    public static TwoWayService.DisplayCommentsWrapper getcommentObjectList(Id caseId,Integer pageIndex,Integer pageSize) {
        //System.debug('pageIndex'+pageIndex+'pagesize'+pageSize);
        Case caseObj =TwoWayService.returnCaseDetails(caseId);
        //System.debug('>>>caseObj'+caseObj);
        //making changes for passing reference number instead of case number
        return TwoWayService.displayComments(caseObj.Reference_Number__c,pageIndex,pageSize);
    } 
    
}