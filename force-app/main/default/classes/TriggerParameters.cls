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
public without sharing class TriggerParameters { 
        
    public List<SObject> oldList { get; private set; }
    public List<SObject> newList { get; private set; }
    public Map<Id, SObject> oldMap { get; private set; }
    public Map<Id, SObject> newMap { get; private set; }
    public Boolean isExecuting { get; private set; }
    public String objectTypeName { get; private set; }  
    public Boolean isBefore { get; private set; }
    public Boolean isAfter { get; private set; }
    public Boolean isInsert { get; private set; }
    public Boolean isUpdate { get; private set; }
    public Boolean isDelete { get; private set; }
    public Boolean isUnDelete { get; private set; }

    /*@Method Name- TriggerEvent
    *@description- This class is used to handle the trigger events
    */   
    public Enum TriggerEvent { beforeInsert, 
                               beforeUpdate, 
                               beforeDelete, 
                               afterInsert, 
                               afterUpdate, 
                               afterDelete, 
                               afterUndelete }  
    private TriggerEvent tEvent; //Declared Private
    public string eventKey {get;private set;}   
        
    /*-------------------------------------------------------------------
    these value are set by the trigger dispatcher by event key type*/   
    public Integer triggerExecutionCounter{get;set;}    
    public Map<Id, SObject> mostRecentOldMap { get;set; }
   //------------------------------------------------------------------------
    
/*@Method Name- TriggerParameters
 *@description- This method is used to handle the trigger parameters
 */   
    public TriggerParameters(List<SObject> olist, 
                            List<SObject> nlist, 
                            Map<Id, SObject> omap, 
                            Map<Id, SObject> nmap,
                            Boolean isBefore, Boolean isAfter, Boolean isDelete,
                            Boolean isInsert, Boolean isUpdate, Boolean isUnDelete,
                            Boolean isExecuting, string typeName
                          //  Map<Id, SObject> mrOldMap,
                           )
    {
        this.oldList=olist;
        this.newList=nlist;
        this.oldMap = omap;
        this.newMap = nmap;
        this.isExecuting = isExecuting;
        this.objectTypeName = typeName;
        this.isBefore=isBefore;
        this.isAfter=isAfter;
        this.isInsert=isInsert;
        this.isUpdate=isUpdate;
        this.isDelete=isDelete;
        this.isUndelete=isUndelete;
        //this.mostRecentOldMap=mrOldMap;  
        try{           
            if (isBefore & isInsert) {
                tEvent = TriggerEvent.beforeInsert;
            } else if (isBefore && isUpdate) {
                tEvent = TriggerEvent.beforeUpdate;
            } else if (isBefore && isDelete) {
                tEvent = TriggerEvent.beforeDelete;
            } else if (isAfter && isInsert) {
            tEvent = TriggerEvent.afterInsert;
            } else if (isAfter && isUpdate) {
                 tEvent = TriggerEvent.afterUpdate;
            } else if (isAfter && isDelete) {
                tEvent = TriggerEvent.afterDelete;
            } else if (isAfter && isUndelete){
                 tEvent = TriggerEvent.afterUndelete;
            } // end if     
            eventKey=typeName+Constant_Util.UNDERSCORE+string.valueOf(tEvent);
        }
        catch(Exception ex) {
           UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        } 
     }
/*@Method Name- isRecursive
 *@description- This method is used to handle the trigger parameters
 */
        public boolean isRecursive
        {
            get{return (this.triggerExecutionCounter>Max_RecursiveCall__c.getOrgDefaults().Max_Call__c);}
        }
    
}