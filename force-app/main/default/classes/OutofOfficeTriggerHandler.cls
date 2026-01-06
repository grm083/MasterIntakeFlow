public class OutofOfficeTriggerHandler {
    
    public static void onBeforeInsert(List<Out_of_Office__c> newOutOfficeList){
        //try{
            //SDT-20715
            //if(newOutOfficeList != null && !newOutOfficeList.isEmpty()){
              //  OutofOfficeTriggerHelper.updateBusinessRules(newOutOfficeList);
              //  OutofOfficeTriggerHelper.validateDuplicateRecord(newOutOfficeList);
            //}
        //}
        //catch(Exception ex){
          //  UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        //}
    }
    
    public static void onBeforeUpdate(List<Out_of_Office__c> newOutOfficeList){
        OutofOfficeTriggerHelper.validateDuplicateRecord(newOutOfficeList);
    }

}