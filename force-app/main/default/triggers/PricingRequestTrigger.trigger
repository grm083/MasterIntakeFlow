trigger PricingRequestTrigger on Pricing_Request__c (after update, after insert) {

    if(RecurrsiveTriggerHandler.invokeValidationforPricing){
        //RecurrsiveTriggerHandler.getByPassValidationForPricing();
    }

    //Invokes After Update
    if(Trigger.IsAfter && Trigger.IsUpdate){ //RecurrsiveTriggerHandler.invokeValidationforPricing &&
        // PricingRequestHandler.onAfterUpdate(Trigger.New, Trigger.oldMap,Trigger.newMap);
    }
      
    //Invokes After Insert
    if(RecurrsiveTriggerHandler.invokeValidationforPricing && Trigger.IsAfter && Trigger.IsInsert){
        PricingRequestHandler.onAfterInsert(Trigger.New,Trigger.newMap);
    }
    
}