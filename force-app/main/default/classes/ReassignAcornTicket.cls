/*************************************************************
@Name: ReassignAcornTicket
@Author: Kyle Homovec
@CreateDate: 6/27/2019
@Description: Handles Ticket Reassignment update to Acorn
@UsedBy: 
**************************************************************/
public without sharing class ReassignAcornTicket {
 
    //@InvocableMethod(label='Invocable Reassign Acorn Ticket Method' description='It is invocable method for the Reassign Acorn Ticket Method')

    public static void reassignTicket(List<Case> caselst, Map<Id,Case> oldCaseMap){
        Set<Id> setCaseIds = new Set<Id>();
        String jsonOldMap = JSON.serialize(oldCaseMap);
        for(Case c : caselst){
            Case oldCase = (Case) oldCaseMap.get(c.id);
            setCaseIds.add(c.id);
            /*
            if(!oldCase.Status.equals(Constant_Util.NEW_STATUS)){
                setCaseIds.add(c.id);
            }
            */
        }
        
        if(!setCaseIds.isempty() && !string.isblank(jsonOldMap)){
        sendToAcorn(setCaseIds, jsonOldMap);
    }
    }
    
	@future(callout=true)
    
    public static void sendToAcorn(Set<Id> caselst, String jsonOldMap){
        Map<Id,Case> oldCaseMap = (Map<Id, Case>) JSON.deserialize(jsonOldMap, Map<Id,Case>.class);
        Map<Id,Case> revertedCases = new Map<Id,Case>();
        Set<Id> caseComment = new Set<Id>();
        Set<Id> taskErrorCases = new Set<Id>();
        Map<Id,String> resultMap = new Map<Id,String>();
        Map<Id,Case> errorCaseMap = new Map<Id,Case>();
        String oldAssignment;
        List<Case> includeCases = [SELECT Id, User_Name__c, Team_Name__c, Team_Queue__c, Tracking_Number__c FROM Case WHERE Id = : caselst];
        for(Case c : includeCases){
            //gathering old values from oldmap
            Case c2 = (Case) oldCaseMap.get(c.id);
            //System.debug('c2.User_Name__r.Name '+ c2.User_Name__r.Name);
            //System.debug('c2.User_Name__c ' + c2.User_Name__c);
            if(c2.User_Name__c != null){
				oldAssignment = c2.User_Name__c;
            }
            // SDT-48534 - Revert back to old behaviour
            if(c2.Team_Queue__c != null){
				oldAssignment = c2.Team_Queue__c;
            }  

            

            System.debug('Reassigning Acorn Ticket' + c.id);
            String result = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.REASSIGN_TICKET,c,oldAssignment);
            System.debug('Result: ' + result);

            RESTHelper.AcornResponse jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
            System.debug('jsonResp ' + jsonResp);
            if (jsonResp.hasProblems()){
                revertedCases.put(c.id, c.clone(true,true,false,true));
                taskErrorCases.add(c.Id);
                errorCaseMap.put(c.id,c);
            }
             
           
            /*
            if(!jsonResp.hasProblems()){
                caseComment.add(c.id);
                createComment(caseComment);	
            }
			*/
    
        }
        if(revertedCases.size() > 0){
            handleTaskError(errorCaseMap);
            revertCases(revertedCases);

        }
    }
    //SFDC side comment creation.  Currently done on the Acorn side.
   /* public static void createComment(Set<Id> caseset){
		User u = [SELECT Id, Acorn_SUser_ID__c, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        List<Comment__C> comments = new List<Comment__c>();
        for(Case c : [SELECT Id, Tracking_Number__c, Team_Queue__c, User_Name__c, User_Name__r.Name, CaseNumber From Case WHERE Id In :caseset]){
        		Comment__c comment = new Comment__c();
                comment.Case__c = c.id;
                comment.Type__c = Constant_Util.OBJECT_CASE;
                comment.Comment__c = Constant_Util.TICKET_REASSIGNED_IN_SALESFORCE_BY + u.Name;
            	comment.Acorn_SUser_ID__c = u.Acorn_SUser_ID__c;
            	comment.Acorn_Tracking_Number__c = c.Tracking_Number__c;
            	comment.RecordTypeId = recordTypeId;
            	comment.Case_Number__c = c.CaseNumber;
            	if(c.Team_Queue__c !=null){
                    comment.Workflow_TeamUser__c = c.Team_Queue__c;
                }else if(c.User_Name__c !=null){
                    comment.Workflow_TeamUser__c = c.User_Name__r.Name;
                }else{}
            	comments.add(comment);
        }
        if(comments.size()>0){
        	insert comments;
        }
    }
*/

    public static void revertCases(Map<Id,Case> revertedCases){
        Boolean USER_REVERT_COMPLETE =false;
        Boolean TEAM_QUEUE_REVERT_COMPLETE = false;
        Boolean TEAM_NAME_REVERT_COMPLETE = false;
        Map<Id, Case> updatedCases = new Map<Id, Case>();
        
        //new method to null out assignment fields on api failure
        List<Case> updateCaseList = new List<Case>();

        for(Case c : revertedCases.values()){
            c.User_Name__c = null;
            c.Team_Name__c = null;
            c.Team_Queue__c = null;
            updateCaseList.add(c);
        }



        /* prior method of reverting case.. reliant on case history tracking
        List<Case> revertedCaseHistory = [select Id, User_Name__c , Team_Name__c, Team_Queue__c, LastModifiedDate, (select Field, OldValue, NewValue, CreatedDate from Histories where Field in ('Team_Queue__c', 'User_Name__c', 'Team_Name__c') order by CreatedDate DESC limit 2) from Case where Id in:revertedCases.keySet()];
        for(Case c : revertedCaseHistory){
            Case revertedCase = (Case) revertedCases.get(c.id);
            List<CaseHistory> itr = new List<CaseHistory>();
            if(c.Histories!=null || !c.Histories.isEmpty() ){
                    itr = c.Histories ;
                } 
            if(Test.isRunningTest()){  //if TEST, create dummy CaseHistory
                    list<CaseHistory> chList = TestDataFactory.CaseHistory(c.id);
                    itr = chList ;        
                }
            
            
            for(CaseHistory ch : itr){
                if(Test.isRunningTest()||c.LastModifiedDate.date() == ch.CreatedDate.date()){
                    if(ch.Field == 'User_Name__c'){
                        revertedCase.User_Name__c = String.valueOf(ch.OldValue); USER_REVERT_COMPLETE = true;
                    }
                    if(ch.Field == 'Team_Queue__c'){
                        revertedCase.Team_Queue__c = String.valueOf(ch.OldValue); TEAM_QUEUE_REVERT_COMPLETE = true;
                    }
                    if(ch.Field == 'Team_Name__c'){
                        revertedCase.Team_Queue__c = String.valueOf(ch.OldValue); TEAM_NAME_REVERT_COMPLETE = true;
                    }
                }
                if(USER_REVERT_COMPLETE || TEAM_QUEUE_REVERT_COMPLETE || TEAM_NAME_REVERT_COMPLETE){
                    updatedCases.put(revertedCase.id, revertedCase);
                }
                if(USER_REVERT_COMPLETE && TEAM_QUEUE_REVERT_COMPLETE && TEAM_NAME_REVERT_COMPLETE){
                    break;
                }
            }
            
        }
        if(USER_REVERT_COMPLETE || TEAM_QUEUE_REVERT_COMPLETE || TEAM_NAME_REVERT_COMPLETE){
            update updatedCases.values();
        }
        */

        if(updateCaseList.size()>0){
            update updateCaseList;
        }
    }

    public static void handleTaskError(Map<Id,Case> errorCaseMap){
        Set<Id> errorCaseSet = new Set<Id>();
        List<Task> errorTasks = new List<Task>();
        Set<Id> errorTaskIds = new Set<Id>();
        
        errorCaseSet = errorCaseMap.keySet();
        try{
            List<AggregateResult> assignmentTasks = [SELECT MAX(Id)Id, MAX(CreatedDate)CreatedDate, WhatId FROM Task WHERE Process__c = 'Case Assignment' AND WhatId IN :errorCaseSet GROUP BY WhatId LIMIT 49999];
        
            for(AggregateResult ar : assignmentTasks){
                errorTaskIds.add(ar.Id);
            }
        
        for(Task t : [SELECT Id, CreatedById, Subject, whatId FROM Task WHERE Id IN :errorTaskIds]){
            
            Case errCase = (Case) errorCaseMap.get(t.WhatId);
            //creating error task
            Task myTask = new Task();
            myTask.Subject = 'Reassignment Error';
            myTask.Description = 'Error While Reassigning--- UserName= ' + errCase.User_Name__c + ', TeamQueue: ' + errCase.Team_Queue__c + ', TeamName: ' + errCase.Team_Name__c;
            myTask.OwnerId = t.CreatedById;
            myTask.WhatId = t.WhatId;

            errorTasks.add(myTask);
        }

        insert errorTasks;
        }catch(Exception e){
            System.debug('Exception upsert task --- ' + e.getMessage());
        }
    }

}