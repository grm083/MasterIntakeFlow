/*
* @Name         : SendAlert
* @Author       : TCS
* @Date         : 
* @Vendor       : TCS
* @Description  : This class is the apex controller of the 'SendAlert' component.        
*/
public class SendAlert {
    
    /*
     * @Method Name    : getMap
     * @Author         : TCS
     * @description    : Gets the recipient list from TwoWayService class.
     * @param          : RecordId of the Case.
     * @return         : 
     */
    @AuraEnabled
    public static TwoWayService.responseBodyObjForGetRecipients getMap(Id caseId){
        Case caseRecord = TwoWayService.returnCaseDetails(caseId);
        //system.debug(TwoWayService.getRecipients(caseRecord.Origin, caseRecord.CaseNumber));
        //making changes for passing reference number instead of case number
        return  TwoWayService.getRecipients(caseRecord.Origin, caseRecord.Reference_Number__c);
    }
    
    /*
     * @Method Name    : getRecipientsMsg
     * @Author         : TCS
     * @description    : 
     * @param          : List of recipients and the message body
     * @return         : 
     */
     @AuraEnabled
    public static TwoWayService.responseBodyObjForAddComment getRecipientsMsg(List<String> values, List<String> textValues, String message, Id caseId){
        
        Case caseRecord =TwoWayService.returnCaseDetails(caseId);
        system.debug('values...'+values);
        system.debug('message...'+message);
        //making changes for passing reference number instead of case number
        return  TwoWayService.returnResponseBodyObjForSentAlert(values, textValues, caseRecord.Reference_Number__c, 
                                                                         caseRecord.Origin, message, UserInfo.getName());
    } 
}