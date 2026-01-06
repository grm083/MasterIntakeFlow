trigger WorkOrderLineItemTrigger on WorkOrderLineItem (before update, after Update) {
    if(Trigger.IsAfter && Trigger.IsUpdate){
        WorkOrderLineItemTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.IsBefore && Trigger.IsUpdate){
        WorkOrderLineItemTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
}