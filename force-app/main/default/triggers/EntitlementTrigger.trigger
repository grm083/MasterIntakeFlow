trigger EntitlementTrigger on Entitlement (before insert,before update){
    //added as part of SDT-42452
    if(trigger.isUpdate && trigger.isbefore){
    	EntitlementTriggerHelper.validateOverrideCheckbox(trigger.new);
    }
    
    EntitlementTriggerHelper.validateNewSeviceEntitlement(Trigger.New);
}