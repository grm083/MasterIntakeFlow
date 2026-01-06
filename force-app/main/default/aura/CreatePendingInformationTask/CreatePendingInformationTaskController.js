({
    doInit : function(component, event, helper) {
        helper.getCaseDetails(component, event, helper);
        console.log('DAS'+component.get("v.openPSItask",false));
    },
    handlePendingInfoTask : function(component, event, helper) {
        var taskTyesFormLabel = $A.get("$Label.c.Pending_Information_Tasks")
        component.set("v.taskTypes",taskTyesFormLabel.split(';'));
        //    component.set("v.openPSItask",true);
        var taskObject = {sobjectType:"Task",Subject:"",Description:"",Due_Date_Time__c:"",Follow_Up_Reasons__c:""} ;
        component.set("v.task",taskObject) ; 
        component.set("v.showTaskCreatePopUpPI", true);
        component.set("v.showPendingInfoTask", true);
        component.set("v.headerMessage","Create Pending Information Task") ; 
        
    },
    handleInitateTask : function(component, event, helper) {
        if(!component.get("v.isTaskUser")){
        !component.set("v.isTaskUser",true);
    }
         component.set("v.sfdcTeamValue",'');
        component.set("v.salesforceTeamUserList",[]);
        var taskTyesFormLabel = $A.get("$Label.c.Initiate_Task")
        component.set("v.taskTypes",taskTyesFormLabel.split(';'));
        helper.getCaseTrackingNumber(component, event, helper);
        component.set("v.selectedLookUpRecord" ,{});
        component.set("v.teamQueValues",[]);
        component.set("v.disabledTeamQ",true);
        component.set("v.showPendingInfoTask", false);
        component.set("v.disabledSfdcTeam", false);
        component.set("v.disabledTeamUser", true);
        var caseRec = component.get("v.caseRecObj");
        var taskObject = {sobjectType:"Task",Subject:"",Description:"",Task_Team_Name__c:"",Task_Team_Queue__c:"",OwnerId:null};
        component.set("v.task",taskObject) ; 
        //  helper.getCaseDetails(component, event, helper);
        helper.getFeildValues(component, event, helper);
        component.set("v.showInternalResponseTask", true);
        component.set("v.showTaskCreatePopUpPI", true);
        component.set("v.headerMessage",'Create Initiate Task');
        /*  if(!component.get("v.caseTrackingNumber")){
            component.set("v.disabledAcornTeam",true);
        }*/
    },
    closeModal : function(component,event,helper){
        component.set("v.showTaskCreatePopUpPI", false);
        component.set("v.showPendingInfoTask", false);
        component.set("v.showInternalResponseTask", false);
        component.set("v.requiredField",false);
        component.set("v.taskTypes",[]);
        var taskObject = {sobjectType:"Task",Subject:"",Description:"",Due_Date_Time__c:"",Follow_Up_Reasons__c:"",Task_Team_Name__c:"",Task_Team_Queue__c:"",OwnerId:null};
        component.set("v.selectedLookUpRecord" ,{});
        component.set("v.disabledTeamUser",true);
        component.set("v.disabledAcornTeam",false);
        component.set("v.salesforceTeamUserValue",'');
        component.set("v.isValid",false);
        component.set("v.sfdcTeamValue",'');
        component.set("v.salesforceTeamUserList",[]);
        
        
        
        
    },
    onAcornTeamchange : function (component,event,helper){
        if(component.get(" v.task").Task_Team_Name__c.length === 0){
            helper.enableSfdcTeam(component,event,helper);
            component.set("v.disabledTeamQ",true);
        }else{
            helper.disableSfdcTeam(component,event,helper);
            component.set("v.disabledTeamQ",false);
        }
        var teamName = component.find("acornteamName").get("v.value");
        var teamNameQueMap =   component.get("v.teamNameQueMap");
        if(teamNameQueMap){
            component.set("v.teamQueValues",teamNameQueMap[teamName]); 
        }
    },
    subjectChange: function (component,event,helper){
    },
    changeOutcome: function (component,event,helper){
    },
    changeDueDate: function (component,event,helper){
    },
    saveTask : function (component,event,helper){
        
        if(component.get("v.showPendingInfoTask")){
            helper.savePsiTask(component,event,helper);  
        }else if(component.get("v.showInternalResponseTask")){
            helper.saveInternalRespoTask(component,event,helper);
        }
        //   helper.filedValidation(component,event,helper);
    },
    taskTypeChange : function (component,event,helper){
        
    },
    sfdcTeamUserChange : function (component,event,helper){
        /*   if(component.get("v.salesforceTeamUserValue").length === 0){
            helper.enableAcornTeam(component,event,helper);
        }else{
             helper.disableAcornTeam(component,event,helper);
        }*/
    },
    handleComponentEvent : function(component,event,helper){
     
        component.set("v.isTaskUser",true);
        component.set("v.disabledSfdcTeam",true);
        component.set("v.disabledAcornTeam",true);
        // component.set("v.disabledTeamQ",true);
        if(!component.get("v.caseTrackingNumber") && component.get("v.selectedLookUpRecord") && component.get("v.selectedLookUpRecord").Id && component.get("v.selectedLookUpRecord").User_categorization_code__c ){
            helper.checkAssingedToUser(component,event,helper);
        }
    },
    handleRecordRemove : function(component,event,helper){
        component.set("v.disabledSfdcTeam",false);
        component.set("v.disabledAcornTeam",false);
    },
    sfdcTeamValueChange:function(component,event,helper){
        //component.set("v.disabledAcornTeam",false);
        if(component.get("v.sfdcTeamValue").length === 0){
            component.set("v.salesforceTeamUserValue",'');
            component.set("v.disabledTeamUser",true);
            var divuserlookUp = component.find('userLookUp');
            $A.util.removeClass(divuserlookUp, 'disableDiv'); 
            if(component.get("v.caseTrackingNumber")){
                // alert(component.get("v.caseTrackingNumber"));
                helper.enableAcornTeam(component,event,helper)
            }
        }else{
            component.set("v.disabledTeamUser",false);
            helper.disableAcornTeam(component,event,helper);
        }
         var salesforceTeamselected = component.find("salesforceTeam").get("v.value");
        var sfdcteamUserQueMap =   component.get("v.sfdcTeamUserNameMap");
        if(sfdcteamUserQueMap){
         component.set("v.salesforceTeamUserList",sfdcteamUserQueMap[salesforceTeamselected]); 
        }
    }
})