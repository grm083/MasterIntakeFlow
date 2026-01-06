/**
* @date 5/12/2022
* @description : Get Location Account Name 
**/
public class WorkOrderReportCtrl {
    
    @AuraEnabled
    public static String getRecordDetails(String recordId){
        List<Account> accList = [Select Id, Name from Account where Id =: recordId];
        return accList.size()>0 ? accList[0].Name : '';
    }

}