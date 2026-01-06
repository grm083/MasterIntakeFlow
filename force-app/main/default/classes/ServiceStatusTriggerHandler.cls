/*************************************************************
@Name: ServiceStatusTriggerHandler
@Author: Devendra Patel
@CreateDate: 07/27/2020
@Description: Handler Class to Perform operations on Service Status
@UsedBy: ServiceStatusTrigger
**************************************************************/

public class ServiceStatusTriggerHandler { 
    /*
* It is invoked on after Update the service status record  
* @owner : Devendra Patel
* @param : list<Service_Status__C>
*/ 
    public static void AfterUpdate(list<Service_Status__C> newSSList){
        try{
            ServiceStatusTriggerHelper.ProcessPendingRecords(newSSList);
        }
        catch(Exception ex){  
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }
    
}