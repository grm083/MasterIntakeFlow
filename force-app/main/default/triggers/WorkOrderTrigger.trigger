/*************************************************************
@Name: WorkOrderTrigger
@Author: Accenture
@CreateDate: 01/02/2019
@Description: Trigger to Perform operations on WorkOrder
**************************************************************/
trigger WorkOrderTrigger on WorkOrder (before insert, before update, after delete, after undelete, after insert, after update) 
{
    TriggerDispatcher.dispatch(workorder.sObjectType);

    
}