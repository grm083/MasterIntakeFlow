/*************************************************************************************************************************************************************
@ Class:          TriggerDispatcher
@ Version:        1.0
@ Author:         Accenture Team
@ Purpose:        Class to Dispatch Trigger methods for right object and dynamically creates the triggerAction class for each object and helps to identify the execution counter for each trigger Action with respect to trigger events
-------------------------------------------------------------------------------------------------------------------------------------
@Change History : 09/23/2019 / Nandhini  - Created the class
**************************************************************************************************************************************************************/
public without sharing class TriggerDispatcher {
    
    private static map<string,Integer> mapTriggerExecutionCounter= new map<string,Integer>();
    private static map<string,Map<Id, SObject>> mostRecentOldMap=new map<string,Map<Id, SObject>>();
    private static map<string,Map<Id, SObject>> previousNewMap=new map<string,Map<Id, SObject>>();  
    private static Exception ex; 
    private static TriggerParameters tp;
    
    private static boolean skipFlagonProfile = false;
    public static Profile loggedinUserProfileName ;
    public static Map<String,Boolean> skipTriggerExecutionMap = new Map<String,Boolean>();
    
    
    /*@methodName- dispatch
    *@description- Method used to dispatch trigger 
    *@param- sObjectType 
    *@return- Null
    */     
    public static void dispatch(Schema.sObjectType soType) {        
        List<sObject> triggerNewCaseList = new List<sObject>(); //Added for SDT-33638
        triggerNewCaseList = RecursionCheck.checkRecusrion(Trigger.new);  //Added for SDT-33638        
        
        string objectTypeName;
        if(Constant_Util.skipTriggerExecution){
            return;
        }
        objectTypeName=soType.getDescribe().getName(); 
        /*System.debug('triggerExecutionMap'+skipTriggerExecutionMap.get(objectTypeName));
        if(skipTriggerExecutionMap!=null && skipTriggerExecutionMap.get(objectTypeName)!=null && skipTriggerExecutionMap.get(objectTypeName)){
            return;
        }*/       
        ITriggerAction action = getTriggerAction(objectTypeName); 
        tp = new TriggerParameters(Trigger.old, triggerNewCaseList,Trigger.oldMap, Trigger.newMap, //Modified for SDT-33638
                                   Trigger.isBefore, Trigger.isAfter,Trigger.isDelete,Trigger.isInsert,
                                   Trigger.isUpdate, Trigger.isUnDelete,Trigger.isExecuting,objectTypeName);
        boolean recursive = False;         
        // set the execution trigger count for this event only for Case records      
        if(Constant_Util.KEYWORD_CASE.equalsIgnoreCase(objectTypeName)) {
            incrementTriggerExecutionCounter(tp.eventKey);   
            tp.triggerExecutionCounter=mapTriggerExecutionCounter.get(tp.eventKey);
            recursive = tp.isRecursive;
        }   
        system.debug('recursive..'+recursive );
        //system.debug('Constant_Util.isComingFromInsert..'+Constant_Util.isComingFromInsert );
        // call the corresponding action method               
        if (tp.isBefore && tp.isInsert){           
            if (Test.isRunningTest() || !recursive){
                action.beforeInsert(tp);
            }
        } else if (tp.isBefore && tp.isUpdate){           
            if ((Test.isRunningTest() || !recursive)) {       //&& !Constant_Util.isComingFromInsert        
                setMostRecentOldMap();                 
                tp.mostRecentOldMap=mostRecentOldMap.get(objectTypeName);
                action.beforeUpdate(tp);
                setPreviousNewMap();
            }
        } else if (tp.isBefore && tp.isDelete){
            if (Test.isRunningTest() || !recursive) {
                setMostRecentOldMap();
                tp.mostRecentOldMap=mostRecentOldMap.get(objectTypeName);                 
                action.beforeDelete(tp);
				CaseTriggerHandler.beforeDelete(tp);

            }else{
            setMostRecentOldMap();
                tp.mostRecentOldMap=mostRecentOldMap.get(objectTypeName);                 
                action.beforeDelete(tp);
                CaseTriggerHandler.beforeDelete(tp);
            }                  

			
		

        } else if (tp.isAfter && tp.isInsert) {   
            /*if (Test.isRunningTest() || !recursive){                 
                if(!system.isBatch() && Constant_Util.KEYWORD_CASE.equalsIgnoreCase(objectTypeName) && !Test.isRunningTest()){
                    Constant_Util.isComingFromInsert = true;  
                }
            }*/                   
            tp.mostRecentOldMap=mostRecentOldMap.get(objectTypeName);                            
            action.afterInsert(tp);                 
        } else if (tp.isAfter && tp.isUpdate) {        
            if ((Test.isRunningTest() || !recursive)) { //&& !Constant_Util.isComingFromInsert
                setMostRecentOldMap();
                tp.mostRecentOldMap=mostRecentOldMap.get(objectTypeName);
                action.afterUpdate(tp); 
            }   
            //Comment it when we converted all the flow into Apex
            if(Constant_Util.KEYWORD_CASE.equalsIgnoreCase(objectTypeName)){ //&& !Constant_Util.isComingFromInsert
                setMostRecentOldMap();
				setPreviousNewMap();
                tp.mostRecentOldMap=mostRecentOldMap.get(objectTypeName);
                if(tp.mostRecentOldMap != null){
                    CaseTriggerHandler.afterUpdateAlways(tp);
                }
            }  // End if           
        } else if (tp.isAfter && tp.isDelete) {
            if (Test.isRunningTest() || !recursive) {
                setMostRecentOldMap();
                tp.mostRecentOldMap=mostRecentOldMap.get(objectTypeName);
                action.afterDelete(tp);        
            }         
        } else if (tp.isAfter && tp.isUnDelete){
            if (Test.isRunningTest() || !recursive){
                action.afterUndelete(tp);  
            }                                     
        }// end if 
    }

    /*@methodName- getTriggerAction
    *@description- Creates a new instance if one doesn't exist already else returns an existing instance 
    *@param- String 
    *@return- ITriggerAction
    */  
    private static ITriggerAction getTriggerAction(string objectTypeName) {       
        String actionTypeName = null;
        if (objectTypeName.toLowerCase().endsWith(Constant_Util.CUSTOMOBJSTR) || objectTypeName.toLowerCase().endsWith(Constant_Util.EVENTSTR)) {
            Integer index;
            if(objectTypeName.toLowerCase().endsWith(Constant_Util.CUSTOMOBJSTR)){
              index = objectTypeName.toLowerCase().indexOf(Constant_Util.CUSTOMOBJSTR);
            }
            else if(objectTypeName.toLowerCase().endsWith(Constant_Util.EVENTSTR)){
                index = objectTypeName.toLowerCase().indexOf(Constant_Util.EVENTSTR);
            }
            actionTypeName = objectTypeName.substring(0, index) + Constant_Util.TRIGGERSTR;
        }else{
            actionTypeName = objectTypeName + Constant_Util.TRIGGERSTR;
        } // end if (objectTypeName.toLowerCase().endsWith('__c'))
        actiontypename=actiontypename.remove(Constant_Util.UNDERSCORE);
        Type obType = Type.forName(actionTypeName);
        ITriggerAction action =(ITriggerAction)obType.newInstance();        
        return action;
    }

    /*@methodName- incrementTriggerExecutionCounter
    *@description- To increment Trigger Counter
    *@param- String 
    *@return- Null
    */ 
    private static void incrementTriggerExecutionCounter(string key){
        integer executionCounter=(mapTriggerExecutionCounter.containsKey(key))?(mapTriggerExecutionCounter.get(key)+1):1;
        mapTriggerExecutionCounter.put(key,executionCounter);
    }

    /*@methodName- bProcessPreviousNewMap
    *@description- To set Previous Old map counter
    *@param- Null
    *@return- Boolean
    */ 
    private static boolean bProcessPreviousNewMap() {
        boolean bProcess=true;
        string targetKey=tp.objectTypeName+ Constant_Util.BEFOREUPDARE;     
        // if the event is not before update check if before update is defined for the object.
        // If so there is no need to process the previous new map      
        if(tp.eventKey!=targetKey && mapTriggerExecutionCounter.containsKey(targetKey)){        
            bProcess=false;
        }
        return bProcess;     
    }

    /*@methodName- setPreviousNewMap
    *@description- To set Previous and New maps
    *@param- Null
    *@return- null
    */  
    private static void setPreviousNewMap()
    {
        if(Trigger.NewMap!=null){    
            previousNewMap.put(tp.objectTypeName,tp.newMap);
        }// end if(Trigger.NewMap!=null)        
    }
    
    /*@methodName- setMostRecentOldMap
    *@description- Update most recent old and new maps
    *@param- Null
    *@return- null
    */     
    public static void setMostRecentOldMap(){
        string key=tp.objectTypeName; 
	if(key.equals(Constant_Util.WorkOrder) && Constant_Util.skipWOTrigger){
            return;
        }
        boolean bProcess=bProcessPreviousNewMap();
        if(!bProcess){
            return;      
        }   
        // if most recent old map has some values refresh the values instead of overwriting
        Map<id,sObject> existingOldMap= new Map<id,sObject>();
        
        if (mostRecentOldMap.containsKey(key)){
            existingOldMap=mostRecentOldMap.get(key);
        }
        // overwrite/add from previousNewMap 
        if(previousNewMap.containsKey(key)){
            Map<Id, SObject> tempMap=previousNewMap.get(key);                   
            for(sObject s1:tempMap.values()){
                existingOldMap.put(s1.Id,s1);               
            }// end for         
        }// end if(previousNewMap.containsKey(key))       
        
        // if oldmap has different ids (recurisve trigger for different data)
        if(tp.OldMap !=null)
        {
            for(sObject s2:tp.OldMap.values())
            {
                if(!existingOldMap.containsKey(s2.Id)){
                    existingOldMap.put(s2.Id,s2);
                }//end if(!existingOldMap....
            }// end for(sObject s2:.........
        }// end if(Trigger.OldMap !=null)      
        mostRecentOldMap.put(key,existingOldMap);
    } 
}