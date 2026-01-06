/*************************************************************************************************************************************************************
@ Class:          TriggerParameters 
@ Version:        1.0
@ Author:         Accenture team
@ Purpose:        This class is used to handle the trigger parameters      
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.18.2019 / Nandhini / Created the class
**************************************************************************************************************************************************************/
/*@Class Name- TriggerParameters
*@description- This class is used to handle the trigger parameters
*/
public without sharing class CaseTriggerAction extends TriggerActionBase{
    public CaseTriggerAction (){
        if(!RecurrsiveTriggerHandler.bypassValidation 
            && (TriggerDispatcher.skipTriggerExecutionMap==null 
                || TriggerDispatcher.skipTriggerExecutionMap.get(Case.sobjectType.getDescribe().getName())==null
       		    || !TriggerDispatcher.skipTriggerExecutionMap.get(Case.sobjectType.getDescribe().getName()))){
            RecurrsiveTriggerHandler.getByPassValidation();
        }
    }
    public virtual override void beforeInsert(TriggerParameters triggerParam){
        CaseTriggerHandler.beforeInsert(triggerParam);
    }
    public virtual override void beforeUpdate(TriggerParameters triggerParam){
        CaseTriggerHandler.beforeUpdate(triggerParam);
    }
    public virtual override void beforeDelete(TriggerParameters triggerParam){
    }
    public virtual override void afterInsert(TriggerParameters triggerParam){
        CaseTriggerHandler.afterInsert(triggerParam);
    }
    public virtual override void afterUpdate(TriggerParameters triggerParam){
        CaseTriggerHandler.afterUpdate(triggerParam);
    }
    public virtual override void afterDelete(TriggerParameters triggerParam){
       //CaseTriggerUtils.afterDelete(triggerParam);
    }
    public virtual override void afterUnDelete(TriggerParameters triggerParam){
    }

}