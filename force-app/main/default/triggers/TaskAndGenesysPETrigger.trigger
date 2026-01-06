// The trigger gets fired when Task and Genesys Platform Event triggers
// @Vendor - TCS
// @Story/defect - SDT-40723

trigger TaskAndGenesysPETrigger on Task_and_Genesys_Platform_Event__e (after insert) {
   
    for(Task_and_Genesys_Platform_Event__e evt : trigger.New){
        
            TaskAndGenesysPETriggerHelper.createTaskAndGenesysRecord(evt.Payload__c);
        }

}
