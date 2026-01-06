// The trigger gets fired when STP Process Event Platform Event triggers
// This ensures the process is occuring after future call.
// @Vendor - TCS
// @Story/defect - SDT-29849
trigger STPProcessEventTrigger on STPProcessEvent__e (after insert) {    
    STPProcessEventTriggerHandler handler = new STPProcessEventTriggerHandler();
    handler.run();
}