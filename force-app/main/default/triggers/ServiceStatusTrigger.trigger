/*************************************************************
@Name: ServiceStatusTrigger 
@Author: Devendra Patel
@CreateDate: 07/27/2020
@Description: Trigger to Perform operations on Service Status object
**************************************************************/

trigger ServiceStatusTrigger on Service_Status__c (after update) {
    
    //Invokes After Update
    try{
        if(!RecurrsiveTriggerHandler.bypassValidation && Trigger.IsAfter && Trigger.IsUpdate){
            
            Set<id> ssRecId = new Set<id>();
            List<Service_Status__c> ssList= new List<Service_Status__c> ();
            for(Service_status__c ssRec: Trigger.new){
                Service_status__c  newRec = new Service_status__c  (id=ssRec.id , Location__c=ssRec.Location__c, Message_Type__c = ssRec.Message_Type__c, 
                                                                    Is_Ready_For_Notification__c = ssRec.Is_Ready_For_Notification__c, Message_Status__c = ssRec.Message_Status__c  );
                
                ssList.add(newRec);
            }
            ServiceStatusTriggerHandler.AfterUpdate(ssList);
        }
    }
    catch(Exception ex){  
        UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
    }
    
}