/*************************************************************************************************************************************************************
@ Class:          iTriggerAction 
@ Version:        1.0
@ Author:         Accenture Team
@ Purpose:        Intergace for the trigger framework
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 18.09.2019 / Nandhini  / created the class.
*************************************************************************************************************************************************************/

/*@Class Name  - iTriggerAction 
* @Description  - iTriggerAction interface for the trigger framework
*/

public interface iTriggerAction {
    // event handlers       
    void beforeInsert(TriggerParameters tp);
    void beforeUpdate(TriggerParameters tp);
    void beforeDelete(TriggerParameters tp);
    void afterInsert(TriggerParameters tp);
    void afterUpdate(TriggerParameters tp);
    void afterDelete(TriggerParameters tp);
    void afterUnDelete(TriggerParameters tp); 
}