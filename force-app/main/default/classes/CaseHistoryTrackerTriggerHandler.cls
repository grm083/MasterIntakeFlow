public class CaseHistoryTrackerTriggerHandler {
    
    /* This method is used to handle after insert event.
    * @owner : Saranya Gali
    * @param : List<Case_History_Tracker__c>
    */ 
    public static void onAfterInsert(List<Case_History_Tracker__c> newList){
        system.debug('inside tracker trigger');
        /*
        List<Task_Create_Update_Event__e> notifications = new List<Task_Create_Update_Event__e>();
        for(Case_History_Tracker__c tracker : newList){
            notifications.add(new Task_Create_Update_Event__e(Refresh__c = true,CaseId__c = tracker.Case__c));
        }
        List<Database.SaveResult> results = EventBus.publish(notifications); //publish event
        for (Database.SaveResult result : results) { // for error handling
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error returned: ' +
                                 error.getStatusCode() +' - '+
                                 error.getMessage());
                }
            }
        }
        */
    } 
}