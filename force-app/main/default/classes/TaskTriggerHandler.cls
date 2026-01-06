/*************************************************************
@Name: TaskTriggerHandler
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: Handler Class to Perform operations on Task
@UsedBy: TaskTrigger
**************************************************************/
public with sharing class TaskTriggerHandler {
   
    /*
    * It is invoked on before Insert the Task 
    * @owner : DineshKumar S
    * @param : map<Id,Task>
    */
    public static void onbeforeInsert(list<Task> newTaskList){
        try{  
			System.debug('in before insert>>>');            
            TaskTriggerHelper.validateCase(true,newTaskList,new map<Id,Task>()); 
            //TaskTriggerHelper.routeAllTasks(newTaskList);
	    TaskTriggerHelper.updateRequireInfo(newTaskList);
            //Changes Related to SDT-38038
            //Due_Date_Time__c value for Portal Tasks
            TaskTriggerHelper.updateDueDateForPortalTasks(newTaskList);
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured::::'+e.getStackTraceString());
        }
    }
    /*
* It is invoked on After Insert the Task 
* @owner : Ayushi Sharma
* @param : map<Id,Task>
*/
   public static void onafterInsert(map<Id,Task> newTaskMap,map<Id,Task> oldTaskMap){
        try{
        Map<Id,Task> newmapwithfilterforGR = newTaskMap.deepClone();
           for(Task t : newTaskMap.values()){
                if(System.Label.Trun_off_task == 'true' &&(t.Process__c == 'Confirm Service Completion' || t.Process__c == 'Obtain Schedule Confirmation' ||t.Process__c == 'Confirm Service Completion with Location')){
                    newmapwithfilterforGR.remove(t.Id);
                }
            }
            //if(!RecurrsiveTriggerHandler.isSkiptaskInsertTrigger){
            if(System.Label.Trun_off_task == 'true'){
                TaskTriggerHelper.deleteTask(newTaskMap);
            }
             
            List<Task> taskList2 = [SELECT Id,WhatId,Process__c,Attempt__c,Business_Rule__c,Business_Rule__r.Is_Auto_Email__c from Task where Id IN:newTaskMap.keyset()];
                       
        /**    for(Task tsk : taskList2 ){
                if((tsk.Process__c == 'Escalation Obtain Service Approval') && (tsk.Attempt__c ==1) && (tsk.Business_Rule__r.Is_Auto_Email__c) ){
                     newmapwithfilterforGR.remove(tsk.Id);

                }  
            }**/
            
              for(Task tsk : taskList2 ){
                if((tsk.Process__c == 'Escalation Obtain Service Approval' || tsk.Process__c == 'Escalation Obtain Customer Info') && (tsk.Attempt__c ==1) ){
                     newmapwithfilterforGR.remove(tsk.Id);

                }  
            }
                TaskTriggerHelper.createTaskRouting(newmapwithfilterforGR); 
				TaskTriggerHelper.logActivityForCase(newTaskMap,null);
				TaskTriggerHelper.sendEmail(newTaskMap);
				TaskTriggerHelper.insertCaseComment(newTaskMap);
                TaskTriggerHelper.createCaseComment(newmapwithfilterforGR , null);            
            	TaskTriggerHelper.updateCaseDetails(newTaskMap);
                TaskTriggerHelper.generateTaskEvent(newTaskMap, null);
				TaskTriggerHelper.updatetaskassign(newTaskMap);
		//TaskTriggerHelper.createGRbyPendingInfoTask(newTaskMap);
                RecurrsiveTriggerHandler.isSkiptaskInsertTrigger = true;
            //}   
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured::::'+e.getStackTraceString());
        }
    }
    /*
* It is invoked on before Update the Task 
* @owner : DineshKumar S
* @param : map<Id,Task>
*/
    public static void onbeforeupdate(list<Task> newTaskList,map<Id,Task> oldTaskMap,map<Id,Task> newmap){
        try{
            if(!RecurrsiveTriggerHandler.isSkiptaskTrigger){
                if(System.Label.Trun_off_task == 'true'){
                  TaskTriggerHelper.autocompleteTask(newmap);  
                }
                TaskTriggerHelper.validateCase(false,newTaskList,oldTaskMap);   
                TaskTriggerHelper.updateValidateEmailApproval(newmap,oldTaskMap);
            }    
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured::::'+e.getStackTraceString());
        }
    }
    
    /*
* It is invoked on After Update the Task 
* @owner : Ayushi Sharma
* @param : map<Id,Task>
*/
    public static void onafterUpdate(list<Task> newTaskList,map<Id,Task> newTaskMap,map<Id,Task> oldTaskMap){
        try{
            if(!RecurrsiveTriggerHandler.isSkiptaskTrigger){
                //TaskTriggerHelper.toRejectChildCases(newTaskMap, oldTaskMap);
				TaskTriggerHelper.lastAgentIdUpdate(newTaskList, false);
                RecurrsiveTriggerHandler.isSkiptaskTrigger = true;
                
            }
			TaskTriggerHelper.cancelTaskRouting(newTaskMap, oldTaskMap);
            TaskTriggerHelper.completeTaskRouting(newTaskMap, oldTaskMap);
            TaskTriggerHelper.CopyTaskCommentOnCase(newTaskMap, oldTaskMap);
            TaskTriggerHelper.logActivityForCase(newTaskMap,oldTaskMap);
            TaskTriggerHelper.generateTaskEvent(newTaskMap, oldTaskMap);
            TaskTriggerHelper.updateResubmitFlagTrue(newTaskMap, oldTaskMap);
            TaskTriggerHelper.updateResubmitFlagFalse(newTaskMap, oldTaskMap);
            TaskTriggerHelper.createCaseComment(newTaskMap , oldTaskMap); 
			TaskTriggerHelper.createEscTask(newTaskMap , oldTaskMap); 
            TaskTriggerHelper.updateStatusSubStatus(newTaskMap);	
			TaskTriggerHelper.createEscTaskObtainCustInfo(newTaskMap , oldTaskMap); 
        }
        catch(Exception e){
            //To handle Error in future Sprints
            System.debug('Exception occured::::'+e.getStackTraceString());
        }
	}
}
