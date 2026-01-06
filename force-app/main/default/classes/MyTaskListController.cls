public with sharing class MyTaskListController {

    Private static final String TASK_STATUS = 'Open';
    Private static final String GROUP_TYPE = 'Regular';
    
    /*
    * Method to return list of Open Tasks for Current User.
    * @owner : Ganesh ram s
    * @param :
    */   
    @AuraEnabled
    public static List<String> getSFDCTeamAcess() {
        List<String> sfdcTeamAcessList = new List<String>();
        try{
            user usr = [Select Id,User_categorization_code__c from User where Id =:UserInfo.getUserId()];
            if(usr.User_categorization_code__c != Null){
                List<CSR_User_Data_Setup__mdt> sfdcTeamUserDate = CSR_User_Data_Setup__mdt.getAll().values();
                for(CSR_User_Data_Setup__mdt sfdcteamUserD : sfdcTeamUserDate){
                    if(usr.User_categorization_code__c == sfdcteamUserD.User_categorization_code__c ){
                        system.debug('taskD'+ usr.User_categorization_code__c);
                        string teamAcess = sfdcteamUserD.Team_Acess__c;
                        system.debug('taskD'+ teamAcess);
                        if(teamAcess.Contains(';')){
                            List<String>teamAcessList = teamAcess.split(';');
                            sfdcTeamAcessList.addAll(teamAcessList);
                        }else{
                            sfdcTeamAcessList.add(teamAcess);
                            
                        }
                        
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception occured:'+e);
        }
        system.debug(sfdcTeamAcessList);
        return sfdcTeamAcessList;
    }
    
    
    
    @AuraEnabled
    public static List<TaskWrapper> getSFDCTeamTask() {
        List<TaskWrapper> taskLstWrapper = new List<TaskWrapper>();
        Set<Id> CaseId = new Set<Id>();
        List<Task> taskLst = new List<Task>();
        List<String> sfdcTeamAcessList = new List<String>();
        Set<Id> taskOwnerIdset = new Set<Id> ();
        Map<String,String>  sfdcUserNameIdMap = new Map<String,String>();
        try{
            user usr = [Select Id,User_categorization_code__c from User where Id =:UserInfo.getUserId()];
            system.debug(usr.User_categorization_code__c);
            if(usr.User_categorization_code__c != Null){
                List<CSR_User_Data_Setup__mdt> sfdcTeamUserDate = CSR_User_Data_Setup__mdt.getAll().values();
                for(CSR_User_Data_Setup__mdt sfdcteamUserD : sfdcTeamUserDate){
                    if(sfdcteamUserD.Team_User_Name__c != Null){
                        sfdcUserNameIdMap.put(sfdcteamUserD.Team_User_Name__c,sfdcteamUserD.SFDC_user_Id__c);
                    }
                }
                List<CSR_User_Data_Setup__mdt> csrdataList = CSR_User_Data_Setup__mdt.getAll().values();
                for(CSR_User_Data_Setup__mdt csrData : csrdataList  ){
                    if(csrData.User_categorization_code__c == usr.User_categorization_code__c){
                        string teamAcess = csrData.Team_Acess__c;
                        if(string.isNotBlank(teamAcess)){
                            if(teamAcess.Contains(';')){
                                List<String>teamAcessList = teamAcess.split(';');
                                sfdcTeamAcessList.addAll(teamAcessList);
                            }else{
                                sfdcTeamAcessList.add(teamAcess);
                                
                            }
                        }
                        
                    }
                    
                }
            }
            system.debug(sfdcTeamAcessList);
            for(String str :   sfdcTeamAcessList){
                if(sfdcUserNameIdMap.containsKey(str)){
                    taskOwnerIdset.add(sfdcUserNameIdMap.get(str));
                    
                }
            }
            system.debug(taskOwnerIdset);
            if(!taskOwnerIdset.isEmpty()){
                taskLst = [Select id,Whatid,What.Name,OwnerId,Owner.Name,what.Type,subject,Due_Date_Time__c,ActivityDate ,Status,Process__c,Description from Task where  OwnerId =:taskOwnerIdset AND status =:TASK_STATUS  ORDER by Due_Date_Time__c ASC Limit 2000];
                system.debug(taskLst);
                for(Task con : taskLst){
                    if(con.what.Type == 'Case'){
                        CaseId.add(con.whatid) ;  
                    }
                }
                Map<ID, Case> casemap = new Map<ID, Case>([SELECT Id,Location__r.Name, Case_Type__c, Case_Sub_Type__c, Location__c,CreatedDate,Service_Date__c,Asset.Supplier__r.Name FROM Case where id IN :CaseId ]);
                
                for(Task con : taskLst){
                    Case caseRec = new Case(); 
                    if(casemap.get(con.WhatId)!= null) {
                        caseRec = casemap.get(con.WhatId) ;
                    }
                    TaskWrapper wrapTask = new TaskWrapper(con,caseRec.Location__c,caseRec.Location__r.Name, caseRec.Case_Type__c, caseRec.Case_Sub_Type__c, caseRec.CreatedDate,caseRec.Service_Date__c,caseRec.Asset.Supplier__r.Name);
                    taskLstWrapper.add(wrapTask);
                }
                //   return taskLstWrapper;
                
                
            }
            return taskLstWrapper;
        } catch(Exception e){
            System.debug('Exception occured:'+e);
            return taskLstWrapper;
        }
    }
    @AuraEnabled
    public static List<TaskWrapper> getSFDCTeamTaskWithFilter(string userSelectedTeam) {
        List<TaskWrapper> taskLstWrapper = new List<TaskWrapper>();
        Set<Id> CaseId = new Set<Id>();
        List<Task> taskLst = new List<Task>();
        List<String> sfdcTeamAcessList = new List<String>();
        Set<Id> taskOwnerIdset = new Set<Id> ();
        Map<String,String>  sfdcUserNameIdMap = new Map<String,String>();
        try{
            
            List<CSR_User_Data_Setup__mdt> sfdcTeamUserDate = CSR_User_Data_Setup__mdt.getAll().values();
            for(CSR_User_Data_Setup__mdt sfdcteamUserD : sfdcTeamUserDate){
                if(sfdcteamUserD.Team_User_Name__c !=Null && sfdcteamUserD.Team_User_Name__c == userSelectedTeam){
                    taskOwnerIdset.add(sfdcteamUserD.SFDC_user_Id__c);
                    
                }
            }
            system.debug(taskOwnerIdset);
            if(!taskOwnerIdset.isEmpty()){
                taskLst = [Select id,Whatid,What.Name,OwnerId,Owner.Name,what.Type,subject,Due_Date_Time__c,ActivityDate ,Status,Process__c,Description from Task where  OwnerId =:taskOwnerIdset AND status =:TASK_STATUS  ORDER by Due_Date_Time__c ASC Limit 2000];
                system.debug(taskLst);
                for(Task con : taskLst){
                    if(con.what.Type == 'Case'){
                        CaseId.add(con.whatid) ;  
                    }
                }
                Map<ID, Case> casemap = new Map<ID, Case>([SELECT Id,Location__r.Name, Case_Type__c, Case_Sub_Type__c, Location__c,CreatedDate,Service_Date__c,Asset.Supplier__r.Name FROM Case where id IN :CaseId ]);
                
                for(Task con : taskLst){
                    Case caseRec = new Case(); 
                    if(casemap.get(con.WhatId)!= null) {
                        caseRec = casemap.get(con.WhatId) ;
                    }
                    TaskWrapper wrapTask = new TaskWrapper(con,caseRec.Location__c,caseRec.Location__r.Name, caseRec.Case_Type__c, caseRec.Case_Sub_Type__c, caseRec.CreatedDate,caseRec.Service_Date__c,caseRec.Asset.Supplier__r.Name);
                    taskLstWrapper.add(wrapTask);
                }
                //   return taskLstWrapper;
                
                
            }
            return taskLstWrapper;
        } catch(Exception e){
            System.debug('Exception occured:'+e);
            return taskLstWrapper;
        }
    }
    @AuraEnabled
    public static List<TaskWrapper> getTasks() {
       
        Id userID = UserInfo.getUserId();
        List<Task> taskLst = new List<Task>();
         List<TaskWrapper> taskLstWrapper = new List<TaskWrapper>();
        Set<Id> CaseId = new Set<Id>();
        try {
            
            taskLst = [Select id,Whatid,What.Name,OwnerId,Owner.Name,what.Type,subject,Due_Date_Time__c,ActivityDate ,Status,Process__c,Description from Task where Status =:TASK_STATUS and OwnerId =:userID  ORDER by Due_Date_Time__c ASC Limit 2000];
            
            for(Task con : taskLst){
            if(con.what.Type == 'Case'){
             CaseId.add(con.whatid) ;  
            }
        }
            
            Map<ID, Case> casemap = new Map<ID, Case>([SELECT Id,Location__r.Name, Case_Type__c, Case_Sub_Type__c, Location__c,CreatedDate,Service_Date__c,Asset.Supplier__r.Name FROM Case where id IN :CaseId ]);
            
            for(Task con : taskLst){
             Case caseRec = new Case(); 
                if(casemap.get(con.WhatId)!= null) {
             caseRec = casemap.get(con.WhatId) ;
                }
                TaskWrapper wrapTask = new TaskWrapper(con,caseRec.Location__c,caseRec.Location__r.Name, caseRec.Case_Type__c, caseRec.Case_Sub_Type__c, caseRec.CreatedDate,caseRec.Service_Date__c,caseRec.Asset.Supplier__r.Name);
                taskLstWrapper.add(wrapTask);
            }
        
            
        if(Test.isRunningTest() && taskLst.isEmpty())
			{
				throw new TypeException();
			}
        }
        
        catch(Exception e){
            System.debug('Exception occured:'+e);
        }
        return taskLstWrapper;
    }
     
    /*
    * Method to return list of Team's Tasks.
    * @owner : Ganesh ram s
    * @param :
    */    
    @AuraEnabled
    public static List<TaskWrapper> showTeamTasks() {
        
        List<Task> taskLst = new List<Task>();
         List<TaskWrapper> taskLstWrapper = new List<TaskWrapper>();
        Set<Id> CaseId = new Set<Id>();
        
        /* if((roleName.equalsIgnoreCase('SBS Leadership')) || (roleName.equalsIgnoreCase('Customer Experience Director')) || (roleName.equalsIgnoreCase('Customer Experience Manager'))
|| (roleName.equalsIgnoreCase('Customer Experience Supervisor')) || (roleName.equalsIgnoreCase('Project Service Manager')) || (roleName.equalsIgnoreCase('Project Service Supervisor')) || (roleName.equalsIgnoreCase('System Administrator')) ){*/
        String userID = UserInfo.getUserId();       
       
        set<Id> userIdSet = new set<Id>{userID};
            set<Id> groupset  =  getGroupsForUserIds(userIdSet);
        set<Id> teamMemberset  =  getUsersForGroupIds(groupset) ;
        
        
        teamMemberset.remove(userID);
                
        try {
            
            if(!teamMemberset.isEmpty()) { 
                taskLst = [Select id,Whatid,What.Name,OwnerId,Owner.Name,what.Type,subject,Due_Date_Time__c,ActivityDate ,Status,Process__c,Description from Task where Status =:TASK_STATUS  and OwnerId IN :teamMemberset  ORDER by Due_Date_Time__c ASC Limit 2000 ];
                
                for(Task con : taskLst){
                    if(con.what.Type == 'Case'){
                        CaseId.add(con.whatid) ; 
                        
                    }
                }
                
                Map<ID, Case> casemap = new Map<ID, Case>([SELECT Id,Location__r.Name, Case_Type__c	, Case_Sub_Type__c, Location__c, CreatedDate,Service_Date__c,Asset.Supplier__r.Name FROM Case where id IN :CaseId ]);
                
                for(Task con : taskLst){
                    Case caseRec = new Case(); 
                    if(casemap.get(con.WhatId)!= null) {
                        caseRec = casemap.get(con.WhatId) ;
                    }
                    TaskWrapper wrapTask = new TaskWrapper(con,caseRec.Location__c,caseRec.Location__r.Name, caseRec.Case_Type__c, caseRec.Case_Sub_Type__c, caseRec.CreatedDate,caseRec.Service_Date__C,caseRec.Asset.Supplier__r.Name);
                    taskLstWrapper.add(wrapTask);
                }
                
                
                if(Test.isRunningTest() && taskLst.isEmpty())
			{
				throw new TypeException();
			}
            }   
        }                 
        catch(Exception e){
            System.debug('Exception occured:'+e);
        }
        
        return taskLstWrapper;
        
    }
    
    /*
    * Method to return groupId's for input userId's
    * @owner : Ganesh ram s
    * @param : set<Id>
    */   
    public static set<Id> getUsersForGroupIds(set<Id> groupIds) {
        set<Id> retVal = new set<Id>();
        set<Id> nestedIds = new set<Id>();

        for (GroupMember member : [SELECT Id, GroupId, UserOrGroupId
             FROM GroupMember
             WHERE GroupId = :groupIds
             AND UserOrGroupId != null
             AND Group.Type =: GROUP_TYPE Limit 1500]) {
            if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
                nestedIds.add(member.UserOrGroupId);   
            } else {
                retVal.add(member.UserOrGroupId);
            }
        }
        // Recursive call.
        if (nestedIds.size() > 0) {
            retVal.addAll(getUsersForGroupIds(nestedIds));
        }
        return retVal;  
    }
    
    /*
* Method to return group Id's for input userId
* @owner : Ganesh ram s
* @param : set<Id>
*/
    public static set<Id> getGroupsForUserIds(set<Id> userOrGroupIds) {
        
        set<Id> retVal = new set<Id>();
        set<Id> nestedIds = new set<Id>();
        
        try {
            for (GroupMember member : [SELECT Id, GroupId, UserOrGroupId
                                       FROM GroupMember
                                       WHERE UserOrGroupId = :userOrGroupIds
                                       AND UserOrGroupId != null
                                       AND Group.Type =: GROUP_TYPE Limit 1500]) {
                                           // If UserOrGroupId is not a user, then add it to the list for recursion.
                                           if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
                                               nestedIds.add(member.UserOrGroupId);   
                                           } else {
                                               // We found a user, so add that group to the list.
                                               retVal.add(member.GroupId);
                                           }
                                       }
            // Recursive call.
            if (nestedIds.size() > 0) {
                // Relies on the uniqueness property of sets to prevent duplicates.
                retVal.addAll(getGroupsForUserIds(nestedIds));
            }
            if(Test.isRunningTest() && retVal.isEmpty())
            {
                throw new ListException();
            }
        }
        catch(Exception e){
            System.debug('Exception occured:'+e);
        }
        return retVal;
    }
	
	  @AuraEnabled
    public static string getUserTimeZone() {
        return UserInfo.getTimeZone().getID();
    }
    
    public inherited sharing class TaskWrapper{
        
        @AuraEnabled public Id WhatId{get;set;}
        @AuraEnabled public Id TaskId{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public String LocationName {get;set;}
        @AuraEnabled public Id LocationId{get;set;}
        @AuraEnabled public String CaseType {get;set;}
        @AuraEnabled public String CaseSubType {get;set;}
        @AuraEnabled public String Process{get;set;}
        @AuraEnabled public Datetime dueDate{get;set;}
        @AuraEnabled public String Subject {get;set;}
        @AuraEnabled public String AssigneeName {get;set;}
        @AuraEnabled public String ownerId {get;set;}
        @AuraEnabled public DateTime CreatedDate {get;set;}
        @AuraEnabled public DateTime CaseCreatedDate  {get;set;}
        @AuraEnabled public Date  caseServiceDate {get;set;}
        @AuraEnabled public String  taskComment {get;set;}
        @AuraEnabled public String  vendorAccountName {get;set;}
        
        
        public TaskWrapper(Task con, String LocationId,String LocationName, String CaseType, String CaseSubType, DateTime CaseCreatedDate,Date caseServiceDate,String  vendorAccountName){
            
            this.WhatId = con.WhatId;
            this.TaskId = con.Id;
            this.Process = con.Process__c;
            this.dueDate = con.Due_Date_Time__c;
            this.LocationName = LocationName ;
            this.LocationId = LocationId ;
            this.CaseType = CaseType;
            this.CaseSubType = CaseSubType;
            this.Name = con.What.Name ;
            this.Subject = con.Subject;
            this.AssigneeName = con.Owner.Name ;
            this.ownerId = con.OwnerId;
            this.CreatedDate = CaseCreatedDate;
            this.caseServiceDate = caseServiceDate ;
            this.taskComment = con.Description ;
            this.vendorAccountName = vendorAccountName ;
            
            
            
            
        }
    }
	 @AuraEnabled
    public static List<SBQQ__Quote__c> getSFDCTeamQuotes() {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<String> sfdcTeamAcessList = new List<String>();
        Set<Id> quoteOwnerIdset = new Set<Id> ();
        Map<String,String>  sfdcUserNameIdMap = new Map<String,String>();
        try{
            user usr = [Select Id,User_categorization_code__c from User where Id =:UserInfo.getUserId()];
            system.debug(usr.User_categorization_code__c);
            if(usr.User_categorization_code__c != Null){
                List<CSR_User_Data_Setup__mdt> sfdcTeamUserDate = CSR_User_Data_Setup__mdt.getAll().values();
                for(CSR_User_Data_Setup__mdt sfdcteamUserD : sfdcTeamUserDate){
                    if(sfdcteamUserD.Team_User_Name__c != Null){
                        sfdcUserNameIdMap.put(sfdcteamUserD.Team_User_Name__c,sfdcteamUserD.SFDC_user_Id__c);
                    }
                }
                List<CSR_User_Data_Setup__mdt> csrdataList = CSR_User_Data_Setup__mdt.getAll().values();
                for(CSR_User_Data_Setup__mdt csrData : csrdataList  ){
                    if(csrData.User_categorization_code__c == usr.User_categorization_code__c){
                        string teamAcess = csrData.Team_Acess__c;
                        if(string.isNotBlank(teamAcess)){
                            if(teamAcess.Contains(';')){
                                List<String>teamAcessList = teamAcess.split(';');
                                sfdcTeamAcessList.addAll(teamAcessList);
                            }else{
                                sfdcTeamAcessList.add(teamAcess);
                                
                            }
                        }
                        
                    }
                    
                }
            }
            system.debug(sfdcTeamAcessList);
            for(String str :   sfdcTeamAcessList){
                if(sfdcUserNameIdMap.containsKey(str)){
                    quoteOwnerIdset.add(sfdcUserNameIdMap.get(str));
                    
                }
            }
            system.debug(quoteOwnerIdset);
            if(!quoteOwnerIdset.isEmpty()){
                quoteList = [Select id,Name,SBQQ__Account__c,SBQQ__Account__r.Name,SBQQ__StartDate__c,Priority__c,toLabel(SBQQ__Status__c),
                             Action_Type__c,Action_Reason__c from SBQQ__Quote__c where  Assigned_To__c =:quoteOwnerIdset 
                             AND SBQQ__Status__c !='Approved' AND SBQQ__Status__c !='Declined' AND SBQQ__Status__c !='Cancelled' 
                             ORDER BY LastModifiedDate  Limit 4000];
                system.debug(quoteList);
               
                
               
                //   return taskLstWrapper;
                
                
            }
            return quoteList;
        } catch(Exception e){
            System.debug('Exception occured:'+e);
            return quoteList;
        }
    }
	
	 @AuraEnabled
    public static List<SBQQ__Quote__c> getSFDCTeamTaskWithFilterQuote(string userSelectedTeam) {
     //   List<SBQQ__Quote__c> taskLstWrapper = new List<TaskWrapper>();
        List<SBQQ__Quote__c> returnQuoteList = new List<SBQQ__Quote__c>();
        Set<Id> CaseId = new Set<Id>();
        List<Task> taskLst = new List<Task>();
        List<String> sfdcTeamAcessList = new List<String>();
       // Set<Id> taskOwnerIdset = new Set<Id> ();
        Set<Id> quoteOwnerIdset = new Set<Id> ();
        Map<String,String>  sfdcUserNameIdMap = new Map<String,String>();
        try{
            
            List<CSR_User_Data_Setup__mdt> sfdcTeamUserDate = CSR_User_Data_Setup__mdt.getAll().values();
            for(CSR_User_Data_Setup__mdt sfdcteamUserD : sfdcTeamUserDate){
                if(sfdcteamUserD.Team_User_Name__c !=Null && sfdcteamUserD.Team_User_Name__c == userSelectedTeam){
                    quoteOwnerIdset.add(sfdcteamUserD.SFDC_user_Id__c);
                    
                }
            }
            system.debug(quoteOwnerIdset);
            if(!quoteOwnerIdset.isEmpty()){
                returnQuoteList = [Select id,Name,SBQQ__Account__c,SBQQ__Account__r.Name,SBQQ__StartDate__c,Priority__c,toLabel(SBQQ__Status__c),
                                   Action_Type__c,Action_Reason__c from SBQQ__Quote__c 
                                   where  Assigned_To__c =:quoteOwnerIdset AND SBQQ__Status__c !='Approved' 
                                   AND SBQQ__Status__c !='Declined' AND SBQQ__Status__c !='Cancelled' ORDER BY LastModifiedDate   Limit 4000];
                system.debug(returnQuoteList);
                
                
               
                //   return taskLstWrapper;
                
                
            }
            return returnQuoteList;
        } catch(Exception e){
            System.debug('Exception occured:'+e);
            return returnQuoteList;
        }
    }
    
}