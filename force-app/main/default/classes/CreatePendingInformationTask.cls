/**
* @author Waste Management - Vishnu
* @date 2022-7-15
* @ User Story - SDT -- 21626
* @ Description - Class Used CreatePendingInformationTask Aura component Controller
*/  

public without sharing  class  CreatePendingInformationTask {
    Public Static Final string COMPLETED = 'Completed';
    Public Static Final string OPEN = 'Open';
    Public Static Final string GRTASKDES_OBTAININTERNAL = 'ObtainInternalResponse';
	Public Static Final string GRTASKDES_SPECPROCESSING = 'SpecProcessing';
    Public Static Final string GRTASKDES_INITSERVREQUEST = 'InitiateServiceRequest';
    Public Static Final string GRTASKDES_SERVICEESCALATION = 'ServiceEscalation';
    Public Static Final string GRTASKDES_OBTAINSERVICEAPPROVAL = 'ObApprov';
    Public Static Final string TASKSUB_OBTAININTERNAL = 'Obtain Internal Response';
    Public Static Final string TASKSUB_INITSERVREQUEST = 'Initiate Service Request';
    Public Static Final string TASKSUB_SERVICEESCALATION = 'Service Escalation';
	Public Static Final string TASKSUB_SPECPROCESSING = 'Spec Processing';
    Public Static Final string TASKSUB_OBTAINSERVICEAPPROVAL = 'Obtain Service Approval';
    Public Static Final string   priorityP1= 'P1';
    Public Static Final string     priorityP2= 'P2';
    Public Static Final string     priorityP3= 'P3';
    Public Static Final string     priorityP4= 'P4';
    
    
    public  class  filedWrapper{
        @AuraEnabled
        public Map<string,List<String>> teamNameQueData{get;set;}
        @AuraEnabled
        public List<String> followUpReasons{get;set;}
     /*   @AuraEnabled
        public List<String> sfdcTeams{get;set;}*/
         @AuraEnabled
        public Map<string,List<String>> sfdcTeamData{get;set;}
        
    }
    public  class  caseDetails{
        @AuraEnabled
        public Case caseObj{get;set;}
        @AuraEnabled
        public Boolean showButton{get;set;}
        @AuraEnabled
        public User currentUserRec{get;set;}
    }
    /**
* @author Waste Management - Vishnu
* @date 2022-7-15
* @ User Story - SDT -- 21626
* @ Description - Method  Used  To Field values 
*/
    @AuraEnabled
    public static filedWrapper filedWrapperDataSet(String whatId){
        //List<String> sfdcTeamUserList = new List<String>();
        List<String> followUpResonValues =  new List<String>();
        Map<string,List<String>> teamNameDataSet = new Map<String,List<String>>() ;
        Map<string,List<String>> sfdcTeamMap = new Map<String,List<String>>() ;
        // call method to get picklist values of follow up reasons
        followUpResonValues = getPickListValues('Task','Follow_Up_Reasons__c');
        //  call method to get Team Name/Team Queue value 
        teamNameDataSet =   getDependentPicklistValues(Task.Task_Team_Queue__c);
        List<CSR_User_Data_Setup__mdt> sfdcTeamUserData = CSR_User_Data_Setup__mdt.getAll().values();
        for(CSR_User_Data_Setup__mdt teamUser :sfdcTeamUserData ){
            if(teamUser.Team_User_Name__c != Null && teamUser.SFDC_Team__c != null){
                // teamUser
              //  sfdcTeamUserList.add(teamUser.Team_User_Name__c);
            if(!sfdcTeamMap.containsKey(teamUser.SFDC_Team__c)){
                sfdcTeamMap.put(teamUser.SFDC_Team__c,new List<string>{teamUser.Team_User_Name__c}); 
            }else{
                List<String> teamUserList = sfdcTeamMap.get(teamUser.SFDC_Team__c);
                teamUserList.add(teamUser.Team_User_Name__c);
                 sfdcTeamMap.put(teamUser.SFDC_Team__c,teamUserList);
            }
            }
        }
        filedWrapper wrapper = new filedWrapper ();
        wrapper.teamNameQueData = teamNameDataSet ;
        wrapper.followUpReasons = followUpResonValues ;
       // sfdcTeamUserList.sort();
       // wrapper.sfdcTeams = sfdcTeamUserList ;
        wrapper.sfdcTeamData = sfdcTeamMap ;
        return wrapper;
    }
    public Static List<String> getPickListValues(String ObjectApiName, String fieldName){
        List<String> values = new List<String>();
        List<String> types =  new List<String>{ObjectApiName};
            List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.add(entry.getValue());
                }
            }
        }
        return values ;
    }
    @AuraEnabled
    public static string createPsiTask(Task taskObj,String whatId){
        string returnString = '';
        String followupReason = taskObj.Follow_Up_Reasons__c ;
        List<Task> taskList = [Select Id,Follow_Up_Reasons__c From Task Where WhatId=:whatId AND Status = 'Open' AND Subject =:taskObj.Subject AND Follow_Up_Reasons__c =:taskObj.Follow_Up_Reasons__c  AND Last_Agent_ID__c=:UserInfo.getUserId() LIMIT 1];
        if(!taskList.isEmpty()){
            returnString = 'Duplicate Task Found' ;
            
        }else if(taskList.isEmpty()){
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Pending_Information').getRecordTypeId();
            Task newPendingInfoTask = new Task();
            newPendingInfoTask.RecordTypeId = recordTypeId;
            newPendingInfoTask.Subject = taskObj.Subject ;
            newPendingInfoTask.Description = taskObj.Description ;
            newPendingInfoTask.Due_Date_Time__c = taskObj.Due_Date_Time__c ;
            DateTime duedateTime = taskObj.Due_Date_Time__c ;
            newPendingInfoTask.ActivityDate = duedateTime.date() ;
            newPendingInfoTask.Process__c = taskObj.Subject ;
            newPendingInfoTask.Last_Agent_ID__c = UserInfo.getUserId() ;
            newPendingInfoTask.Follow_Up_Reasons__c = taskObj.Follow_Up_Reasons__c ;
            newPendingInfoTask.WhatId = whatId;
            newPendingInfoTask.Attempt__c = 1;
            newPendingInfoTask.OwnerId = UserInfo.getUserId() ;
// Modified for SDT-33460 Start
            if(newPendingInfoTask != null){
            insert newPendingInfoTask ;
}
            // Modified for SDT-33460 End
            returnString = 'Task Created';
        }
        
        return returnString ;
        
    }
    
    @AuraEnabled
    public static void createObtainInternalRespoTask(Task taskObj,String whatId, String sfdcTeam){
       case caseRec = [Select Id,CheckReassignment__c,Service_Date__c,Service_Date_Time_Formula__c,Tracking_Number__c FROM Case where Id =:whatId];
        caseRec.CheckReassignment__c = true;
        update caseRec;
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Initiate_Task').getRecordTypeId();
        //  Initiate_Task
        Boolean sfdcTeamuserAssingment = false ;
        Boolean createGeneysisRouting = false ;
        Boolean updateTaskOwner = false ;
        String userGrServiceFlag = null ;
        Task ObtainInternalRespoTask = new Task();
        ObtainInternalRespoTask.RecordTypeId = recordTypeId ;
        ObtainInternalRespoTask.Subject = taskObj.Subject ;
        ObtainInternalRespoTask.Description = taskObj.Description ;
        ObtainInternalRespoTask.Process__c = 'Case Assignment' ;
        ObtainInternalRespoTask.WhatId = whatId;
         //@@@ SDT-38282
        ObtainInternalRespoTask.Attempt__c = 1;
        Date serviceDate = caseRec.Service_Date__c;
        DateTime localMidnight = DateTime.newInstance(serviceDate, Time.newInstance(0, 0, 0, 0));
        ObtainInternalRespoTask.Due_Date_Time__c = localMidnight;
        ObtainInternalRespoTask.ActivityDate = date.valueOf(caseRec.Service_Date_Time_Formula__c);
        if(String.isNotBlank(taskObj.OwnerId) || String.isNotBlank(sfdcTeam) ){
            List<CSR_User_Data_Setup__mdt> sfdcTeamUserDate = CSR_User_Data_Setup__mdt.getAll().values();
            if(String.isNotBlank(taskObj.OwnerId)){
                // Logic for User assingment
                // changes related to SDT-36177 - added profile name and isActive in query
                user userObj = [Select Id,User_categorization_code__c,isActive,Profile.Name FROM USER WHERE Id=:taskObj.OwnerId];
                for(CSR_User_Data_Setup__mdt userDataSetup : sfdcTeamUserDate){
                    if(userObj.User_categorization_code__c != null && userObj.User_categorization_code__c == userDataSetup.User_categorization_code__c && userObj.Profile.Name !='Deactivated Users'){
                        createGeneysisRouting = userDataSetup.Is_Genesys_User__c ;
                        userGrServiceFlag = userDataSetup.GR_Service_Flag__c ;
                        ObtainInternalRespoTask.Last_Agent_ID__c = taskObj.OwnerId ;
                        ObtainInternalRespoTask.OwnerId = taskObj.OwnerId  ;
                        ObtainInternalRespoTask.Task_Team_Name__c = null;
                        ObtainInternalRespoTask.Task_Team_Queue__c = null ;
                        ObtainInternalRespoTask.Status = (createGeneysisRouting || userDataSetup.SFDC_Task_User__c) ? OPEN:COMPLETED ;
                        //system.debug('DAS1');
                        //   ObtainInternalRespoTask.Description = ObtainInternalRespoTask.Status ;
                        
                    //Changes related to SDT-36177    
                    }else if(userObj.User_categorization_code__c == null || userObj.Profile.Name =='Deactivated Users'){
                        //system.debug('DAS2');
                        //   user User_categorization_code__c is null 
                        ObtainInternalRespoTask.Last_Agent_ID__c = taskObj.OwnerId ;
                        ObtainInternalRespoTask.OwnerId = taskObj.OwnerId  ;
                        ObtainInternalRespoTask.Task_Team_Name__c = null;
                        ObtainInternalRespoTask.Task_Team_Queue__c = null ;
                        ObtainInternalRespoTask.Status = COMPLETED;
                    }
                }
            }else if(String.isNotBlank(sfdcTeam)){
                //    Logic for Salesforce team User Assingment
                //system.debug('DAS3');
                for(CSR_User_Data_Setup__mdt userDataSetup : sfdcTeamUserDate){
                    if(userDataSetup.Team_User_Name__c == sfdcTeam ){
                        createGeneysisRouting = userDataSetup.Is_Genesys_User__c ;
                        sfdcTeamuserAssingment = true ;
                        userGrServiceFlag = userDataSetup.GR_Service_Flag__c ;
                        updateTaskOwner = createGeneysisRouting ? false : true ;
                        ObtainInternalRespoTask.Last_Agent_ID__c = userDataSetup.SFDC_user_Id__c ;
                        ObtainInternalRespoTask.OwnerId = UserInfo.getUserId()  ;
                        if(string.isNotBlank(caseRec.Tracking_Number__c)){
                        ObtainInternalRespoTask.Task_Team_Name__c = userDataSetup.Acorn_Team__c;
                        ObtainInternalRespoTask.Task_Team_Queue__c = userDataSetup.Acorn_Team_Queue__c ;
                        }
                        ObtainInternalRespoTask.Status = (createGeneysisRouting || userDataSetup.SFDC_Task_User__c) ? OPEN:COMPLETED ;
                        
                    }
                }
                
            }
        }else if(String.isNotBlank(taskObj.Task_Team_Name__c) && String.isNotBlank(taskObj.Task_Team_Queue__c)){
            //system.debug('DAS4');
            // Logic for Acorn Team/Queue Assingment
            ObtainInternalRespoTask.Last_Agent_ID__c = UserInfo.getUserId() ;
            ObtainInternalRespoTask.OwnerId = UserInfo.getUserId()  ;
            ObtainInternalRespoTask.Task_Team_Name__c = taskObj.Task_Team_Name__c;
            ObtainInternalRespoTask.Task_Team_Queue__c = taskObj.Task_Team_Queue__c ;
            ObtainInternalRespoTask.Status =  COMPLETED ;
            
        }
        //system.debug('status+BeforeUpdate' +ObtainInternalRespoTask.Status );
// Modified for SDT-33460 Start
        if(ObtainInternalRespoTask != null){
        insert ObtainInternalRespoTask ; 
}

         // Modified for SDT-33460 End        
        if(createGeneysisRouting && !updateTaskOwner){  //SDT-38282 
             createGeneysRouting(ObtainInternalRespoTask,userGrServiceFlag,sfdcTeamuserAssingment);        
            Generic_Values__mdt objGenericValues = [Select Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER];
            ObtainInternalRespoTask.OwnerId =  objGenericValues.Id__c;
                       if(ObtainInternalRespoTask != null){
            Update ObtainInternalRespoTask;
}
        } 
       else{
            
            ObtainInternalRespoTask.OwnerId = ObtainInternalRespoTask.Last_Agent_ID__c ;
            // Modified for SDT-33460 Start
            if(ObtainInternalRespoTask != null){
            Update ObtainInternalRespoTask;
}
            // Modified for SDT-33460 End
            
        }
       
    }
    @AuraEnabled
    public static caseDetails getCaseObject(String caseId){
        Boolean showButton = false;
        User userRec =[Select Id,Profile.Name,User_categorization_code__c From User where Id=:UserInfo.getUserId()];
        Case caseObj= [Select Id,Status,Tracking_Number__c from case where Id =:caseId];
        //List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        //system.debug('@@@@DAS' + PROFILE);
        
        String proflieName = userRec.Profile.Name;
        if(caseObj.Status != 'Closed' && (proflieName == 'System Administrator' || ( userRec.User_categorization_code__c!=null) )){
            if(proflieName == 'System Administrator'){
                showButton = true;
            }else{
                CSR_User_Data_Setup__mdt userDataSetup = CSR_User_Data_Setup__mdt.getInstance(userRec.User_categorization_code__c);
                if(userDataSetup!= null){
                    showButton =  userDataSetup.SFDC_Task_User__c;
                }
            }
        }
        caseDetails wrapper = new caseDetails ();
        wrapper.caseObj = caseObj ;
        wrapper.currentUserRec = userRec ;
        wrapper.showButton = showButton ;
        return wrapper;
    }
    public static Map<String, List<String>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        //Logic to remove Team from UI Starts Here -->
         String acornTeamToRemove = System.Label.AcornTeamNamesToRemove;
       // AcornTeamQueue__mdt acronTeamstoRemove = AcornTeamQueue__mdt.getInstance('AcornTeam');
        if(String.isNotBlank(acornTeamToRemove)){
            List<String> teamsToRemoveList = new List<String> ();
         //   String teamList = acronTeamstoRemove.Teams__c  ;
            if(acornTeamToRemove.contains(':')){
                teamsToRemoveList = acornTeamToRemove.split(':');
            }else{
                teamsToRemoveList.add(acornTeamToRemove);
            }
            for(string teamQ : teamsToRemoveList){
                if(dependentPicklistValues.containsKey(teamQ)){
                    dependentPicklistValues.remove(teamQ);
                }
            }
        }        //<--Logic to remove Team from UI Ends Here 
        //Logic to remove specific Team Queue value form Initiate Task Popup from UI Starts Here SDT-26313 -->
        //Logic Using Custom Label -- Starts Here
       List<String> acornQueuesToRemove = new List<String>();
       Set<String> teamNameSet = new Set<String> () ;
        String acornQString = System.Label.Acron_Team_Queues_To_Remove;
        if (acornQString.contains(':')){
            acornQueuesToRemove  = acornQString.split(':');
        }else{
            acornQueuesToRemove.add(acornQString);
        }
       if(!acornQueuesToRemove.isEmpty()){
            for(string teamName : dependentPicklistValues.keySet()){
                List<String> acornTeamsQvalues = dependentPicklistValues.get(teamName);
                for(string acornQtoRemove :  acornQueuesToRemove){
                    if(acornTeamsQvalues.contains(acornQtoRemove)){
                        integer intex =  acornTeamsQvalues.indexOf(acornQtoRemove);
                        acornTeamsQvalues.remove(intex);
                    }
                }
               dependentPicklistValues.put(teamName,acornTeamsQvalues); 
            }
        }
            //Logic Using Custom Label -- Ends Here
        
         //Logic Using Custom Custom MetaData 
        List<AcornTeamQueue__mdt> acornTeamQ = AcornTeamQueue__mdt.getAll().values();
        for(AcornTeamQueue__mdt acronTeam : acornTeamQ){
            if(dependentPicklistValues.containsKey(acronTeam.MasterLabel)){ 
                List<String> teamQValuesToremove = new List<String>();
                List<String> teamQueueList =  dependentPicklistValues.get(acronTeam.MasterLabel);
                if(acronTeam.Teams__c != Null && acronTeam.Teams__c.contains(':') ){
                    teamQValuesToremove = acronTeam.Teams__c.split(':'); 
                }else if(acronTeam.Teams__c != Null){
                    teamQValuesToremove.add(acronTeam.Teams__c);
                }
                for(String teamQ : teamQValuesToremove ){
                    if(teamQueueList.contains(teamQ)){
                        integer intex =  teamQueueList.indexOf(teamQ);
                        teamQueueList.remove(intex);
                    }
                }
                dependentPicklistValues.put(acronTeam.MasterLabel ,teamQueueList);
            }
        }
        //<--Logic to remove specific Team Queue value form Initiate Task Popup from UI Ends Here 
        return dependentPicklistValues;
    }
    /*    @AuraEnabled
public static Boolean checkOpenPITask(Task taskObj,String whatId){
List<Task>opentaskList = new List<Task> ();
Boolean openTasksFound = false ;
Set<String> folloWupSet = new Set<String> ();
for(Task taskrRec : [Select Id,Follow_Up_Reasons__c From Task Where WhatId=:whatId AND Status = 'Open' AND Subject =:taskObj.Status AND Follow_Up_Reasons__c =:taskObj.Follow_Up_Reasons__c  AND Last_Agent_ID__c=:UserInfo.getUserId() LIMIT 1]){

openTasksFound = true ;

if(!string.isBlank(tsk.Follow_Up_Reasons__c)){
folloWupSet.add(tsk.Follow_Up_Reasons__c);
}
}
if(!folloWupSet.isEmpty() && folloWupSet.Contains('Customer') && folloWupSet.Contains('Vendor') && folloWupSet.Contains('Internal WM')){
openTasksFound = true ;
}
return openTasksFound ;
} */
    @AuraEnabled 
    Public Static void   createGeneysRouting(Task tsk,String grSreviceFlag, Boolean sfdcTeamuserAssingment){
        Map<Id,String> casePriorityFlag = new Map<Id,String> ();
        Map<Id,Case> caseIdMap = new Map<Id,Case> ();
        String grLastAgentId = null ;
        Generic_Values__mdt objGenericValues = [Select Id__c, DeveloperName from Generic_Values__mdt where DeveloperName =: Constant_Util.GENESYSUSER];
        Id taskOwnerId =   objGenericValues.Id__c;
        String grTaskDescCode ;
        Id genesysRoutingRec   = Schema.getGlobalDescribe().get(Constant_Util.Genesys_Routing).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.OBJECT_TASK).getRecordTypeId();
        case ca = [Select Id,OwnerId,RecordType.Name,CaseNumber,Case_Reason__c,Reference_Number__c,Case_Sub_Type__c,Case_Type__c,Location__c,Supplier__c,Client__c,
                   Client__r.Customer_Code__c,Client__r.Primary_Segment__c,Client__r.ParentId,Client__r.Vendor_ID__c,Location__r.tz__Timezone__c,Location__r.Location_Code__c,
                   Supplier__r.Name,Supplier__r.Vendor_ID__c,Supplier__r.ParentId,Supplier__r.Parent.Vendor_ID__c,Supplier__r.Parent.Name,Supplier__r.Parent.ParentId,
                   AssetId,Asset.Project_Code__c,Asset.Project_Code__r.Active__c, Asset.Active__c,Case_Sub_Status__c,Service_Date__c from case where Id =: tsk.WhatId Limit 1];
        if(!sfdcTeamuserAssingment){
            user useObj = [Select Id,Username from USER where Id=:tsk.Last_Agent_ID__c];
            grLastAgentId = useObj.UserName.substringBefore(Constant_Util.AT_SYMBOL);
        }
        if(ca.Service_Date__c != null || ca.Service_Date__c > (date.today())){
            caseIdMap.put(ca.Id,ca);
            casePriorityFlag = getNoOfBusinessDaysfromCurrentDate(caseIdMap);
            
        }
        
        
        if(tsk.Subject == TASKSUB_OBTAININTERNAL ){
            grTaskDescCode = GRTASKDES_OBTAININTERNAL;
        }else if(tsk.Subject == TASKSUB_INITSERVREQUEST){
            grTaskDescCode = GRTASKDES_INITSERVREQUEST;
            
        }else if(tsk.Subject == TASKSUB_SERVICEESCALATION){
            grTaskDescCode = GRTASKDES_SERVICEESCALATION;
            
        }else if(tsk.Subject == TASKSUB_SPECPROCESSING){
            grTaskDescCode = GRTASKDES_SPECPROCESSING;
            
        }else if(tsk.Subject == TASKSUB_OBTAINSERVICEAPPROVAL){
            grTaskDescCode = GRTASKDES_OBTAINSERVICEAPPROVAL;
        }
        
        
        
        //  Case ca = caseIdMap.get(tsk.WhatId);
        Genesys_Routing__c gr = new Genesys_Routing__c();
        gr.LastAgentId__c = grLastAgentId;
        gr.OwnerId = tsk.Last_Agent_ID__c ;
        gr.MediaType__c =  Constant_Util.SFDCWORKFLOWTASK  ;      //      Constant_Util.SFDCWORKFLOWTASK;
        gr.RecordTypeId = genesysRoutingRec;
        gr.SFDCAcctID__c = ca.Client__r.Customer_Code__c;
        gr.SFDCAcctLocationTimeZone__c = ca.Location__r.tz__Timezone__c;
        gr.SFDCAcctLocation__c = ca.Location__r.Location_Code__c;
        gr.SFDCAcctSegment__c = ca.Client__r.Primary_Segment__c;
        gr.SFDCCaseNumber__c = ca.CaseNumber;
        gr.SFDCCaseReason__c = string.isNotBlank(ca.Case_Reason__c) ? ca.Case_Reason__c : null;
        gr.SFDCCaseRefNo__c = ca.Reference_Number__c;
        gr.SFDCCaseSubCaseType__c = ca.Case_Sub_Type__c;
        gr.SFDCCaseType__c = ca.Case_Type__c;
        gr.SFDCChildVendorName__c = ca.Supplier__r.Name;
        gr.SFDCChildVendorAcctNo__c = ca.Supplier__r.Vendor_ID__c;
        gr.SFDCFunction__c = Constant_Util.FOLLOW_UP;
        gr.SFDCObjName__c = Constant_Util.OBJECT_TASK;
        gr.SFDCObjRecordID__c = tsk.Id;
        gr.SFDCObjType__c = Constant_Util.OBJECT_TASK;
        gr.SFDCParentVendorAcctNo__c = ca.Supplier__r.Parent.Vendor_ID__c;
        gr.SFDCParentVendorName__c = ca.Supplier__r.Parent.Name;
        gr.SFDCRecordType__c = ca.RecordType.Name;
        gr.SFDCRouteEndTime__c = string.valueof(system.today()) + Constant_Util.END_TIME_TEXT;
        gr.SFDCRouteStartTime__c = string.valueof(system.today()) + Constant_Util.START_TIME_TEXT;
        gr.SFDCServiceFlag__c =  grSreviceFlag; //string.isNotBlank(String.valueof(ca.Asset.Project_Code__c)) && ca.Asset.Active__c || ca.Client__r.Primary_Segment__c == Constant_Util.CONSTRUCTION_AND_DEMOLITION ? Constant_Util.PS : Constant_Util.CS;
        gr.SFDCTaskCaseId__c = tsk.WhatId;
        gr.SFDCTaskDescCode__c = grTaskDescCode;
        gr.SFDCTaskDescription__c = tsk.Process__c;		
        gr.SFDCTaskDueDateTime__c = tsk.Due_Date_Time__c;
        gr.CreatedById = tsk.Last_Agent_ID__c ;
        gr.LastModifiedById = tsk.Last_Agent_ID__c ;
        gr.SFDCRoutePriority__c = (!casePriorityFlag.isEmpty() && casePriorityFlag.containsKey(tsk.WhatId)) ? casePriorityFlag.get(tsk.WhatId) : priorityP2   ;
        // Modified for SDT-33460 Start
        if(gr != null){
            insert gr;               
        }
        // Modified for SDT-33460 End
        tsk.OwnerId = taskOwnerId ;
        // Modified for SDT-33460 Start
        if(tsk != null){
            update tsk;              
        }
        // Modified for SDT-33460 End      
        
        
        
    }
    public static Map<Id,String> getNoOfBusinessDaysfromCurrentDate(Map<Id,Case> caseIdMap){
        Map<Id,String> caseIdPriorityMap = new map<Id,string>();
        String priority = null ;
        List<BusinessHours>   bHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        BusinessHours bHour = new BusinessHours();
        //checking if business hour is empty and null
        if(!bHours.isEmpty() && bHours !=null){
            //system.debug('bHour'+   bHour);
            for(case cse : caseIdMap.Values()){
                bHour = bHours[0];
                datetime startDate = Datetime.now();
                //system.debug(startDate);
                Integer count = 0;
                while(startDate <= cse.service_Date__c){
                    //system.debug('Inside');
                    
                    if(BusinessHours.isWithin(bHour.Id, startDate)){
                        //system.debug(bHour.Id);
                        count++;
                    }
                    startDate = startDate.addDays(1);
                }
                if(count==0)
                {
                    priority = priorityP1;
                }
                //start Date equal to next business day then assign P2
                else if(count==1)
                {
                    priority=priorityP2;
                }
                //start Date equal to T+2 to T+10 then assign P3
                else if(count>1 && count<=10)
                {
                    priority = priorityP3;
                }
                //start Date equal to T+11 or greater then assign P4
                else if(count>=11)
                {
                    priority = priorityP4;
                }
                caseIdPriorityMap.put(Cse.Id,priority);
                //system.debug('DAS123'+ caseIdPriorityMap );
            }
        }
        return caseIdPriorityMap;
    }
     @AuraEnabled 
    Public Static Boolean   checkUserIsTaskUser(String userCatCode){
        Boolean isSfdcTaskUser = false;
        CSR_User_Data_Setup__mdt userDatasetup  = CSR_User_Data_Setup__mdt.getInstance(userCatCode);
                if(userDataSetup!= null && userDatasetup!= null ){
                    isSfdcTaskUser =  userDataSetup.SFDC_Task_User__c;
                }
        return isSfdcTaskUser ;
    }
}
