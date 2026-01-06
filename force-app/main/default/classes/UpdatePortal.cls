/*
* @Name         : UpdatePortal
* @Author       : TCS
* @Date         : 21/03/2024
* @Vendor       : TCS
* @Description  : This class is the apex controller of the 'UpdatePortal' component.        
*/
public class UpdatePortal
{
    /*
     * @Method Name    : responseBodyObjForGetServiceStatus
     * @Author         : TCS
     * @description    : Gets the External System Status list from TwoWayService class.
     * @param          : RecordId of the Case.
     * @return         : 
     */
    @AuraEnabled
    public static TwoWayServiceRevision.responseBodyObjForGetServiceStatus getExternalStatus(Id caseId){
        Case caseRecord = TwoWayService.returnCaseDetails(caseId);
        return  TwoWayServiceRevision.getServiceStatus(caseRecord.Reference_Number__c);
    }

    /*
     * @Method Name    : updateRecordToExSystem
     * @Author         : TCS
     * @description    : Saved the service date and status to external system
     * @param          : 
     * @return         : 
     */
    @AuraEnabled
    public static TwoWayServiceRevision.responseBodyObjForServiceRevision updateRecordToExSystem(Datetime serviceDate, String serviceStatus, Id caseId){
        
        Case caseRecord = TwoWayService.returnCaseDetails(caseId);
        system.debug('serviceDate...' + serviceDate);
        system.debug('serviceStatus...' + serviceStatus);
        system.debug('caseId...' + caseId);
        //making changes for passing reference number instead of case number
        return  TwoWayServiceRevision.returnResponseBodyObjForServiceRevision(caseRecord.Reference_Number__c, caseRecord.Origin, serviceDate, serviceStatus, UserInfo.getName());
    } 

    /*
     * @Method Name    : getServiceRevisionsList
     * @Author         : TCS
     * @description    : List of previously changed service date and status
     * @param          : Case record Id
     * @return         : TwoWayService.DisplayServiceRevisionWrapper object with values IN THE JSON received from api utility class. 
     */
    @AuraEnabled(cacheable=true)
    public static TwoWayServiceRevision.DisplayServiceRevisionWrapper getServiceRevisionsHistoryRecord(Id caseId, Integer pageIndex, Integer pageSize) {
        //System.debug('pageIndex'+pageIndex+'pagesize'+pageSize);
        Case caseObj = TwoWayService.returnCaseDetails(caseId);
        //System.debug('>>>caseObj'+caseObj);
        //making changes for passing reference number instead of case number
        return TwoWayServiceRevision.displayServiceRevision(caseObj.Reference_Number__c, pageIndex, pageSize);
    }

     /*
     * @Method Name    : getOfficetraxServiceStatus
     * @Author         : TCS
     * @description    : This method returns the value of codeswitch for the codename 'OfficeTraxServiceStatus'
     * @return         : getServiceStatus boolean value
     */
    //SDT-40151
    @AuraEnabled(cacheable=true)
    public static Boolean getOfficetraxServiceStatus() {
        
      Boolean getServiceStatus = CodeSwitchUtility.getCodeSwitchOn('OfficeTraxServiceStatus');
      return getServiceStatus;

    }
}