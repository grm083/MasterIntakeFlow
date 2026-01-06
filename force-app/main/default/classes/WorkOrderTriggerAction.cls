/*************************************************************************************************************************************************************
@ Class:          WorkOrderTriggerAction 
@ Version:        1.0
@ Author:         Accenture team
@ Purpose:        This class is used to handle the trigger parameters      
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.27.2019 / Nandhini / Created the class
**************************************************************************************************************************************************************/
/*@Class Name- WorkOrderTriggerAction 
*@description- This class is used to handle the trigger parameters
*/
public without sharing class WorkOrderTriggerAction extends TriggerActionBase{

	public WorkOrderTriggerAction (){
        if(!RecurrsiveTriggerHandler.bypassValidation){
            RecurrsiveTriggerHandler.getByPassValidation();
        }
    }

    public virtual override void beforeInsert(TriggerParameters triggerParam){
        WorkOrderTriggerHandler.beforeInsert(triggerParam);
    }
    public virtual override void beforeUpdate(TriggerParameters triggerParam){
        WorkOrderTriggerHandler.beforeUpdate(triggerParam);
    }
    public virtual override void beforeDelete(TriggerParameters triggerParam){
    }
    public virtual override void afterInsert(TriggerParameters triggerParam){
        WorkOrderTriggerHandler.afterInsert(triggerParam);
    }
    public virtual override void afterUpdate(TriggerParameters triggerParam){
        WorkOrderTriggerHandler.afterUpdate(triggerParam);
    }
    public virtual override void afterDelete(TriggerParameters triggerParam){
       //CaseTriggerUtils.afterDelete(triggerParam);
    }
    public virtual override void afterUnDelete(TriggerParameters triggerParam){
    }

}