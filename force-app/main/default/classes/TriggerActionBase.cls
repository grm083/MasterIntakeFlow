/*************************************************************************************************************************************************************
@ Class:          TriggerActionBase
@ Version:        1.0
@ Author:         Accenture Team
@ Purpose:        This class provides the default implementation for action methods so it is not mandatory to implement 
          all the action methods in the actual implementation
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 09.18.2019 /Nandhini/ Created the class
--------------------------------------------------------------------------------------------------------------------------------------------------------------
/*@Class Name- TriggerActionBase
 *@description- This class provides the default implementation for action methods so it is not mandatory to implement 
 *@all the action methods in the actual implementation   
 */
public virtual class TriggerActionBase implements iTriggerAction {//Added documentation to class
    /*@Method Name- beforeInsert
    *@description- This Method is used to handle the trigger events
    */    
    public virtual void beforeInsert(TriggerParameters triggerParam){}
    /*@Method Name- beforeUpdate
    *@description- This Method is used to handle the trigger events
    */
    public virtual void beforeUpdate(TriggerParameters triggerParam){}
    /*@Method Name- beforeDelete
    *@description- This Method is used to handle the trigger events
    */
    public virtual void beforeDelete(TriggerParameters triggerParam){}
    /*@Method Name- afterInsert
    *@description- This Method is used to handle the trigger events
    */
    public virtual void afterInsert(TriggerParameters triggerParam){}
    /*@Method Name- afterUpdate
    *@description- This Method is used to handle the trigger events
    */
    public virtual void afterUpdate(TriggerParameters triggerParam){}
    /*@Method Name- afterDelete
    *@description- This Method is used to handle the trigger events
    */
    public virtual void afterDelete(TriggerParameters triggerParam){}
    /*@Method Name- afterUnDelete
    *@description- This Method is used to handle the trigger events
    */
    public virtual void afterUnDelete(TriggerParameters triggerParam){}
    
}