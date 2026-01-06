({
    savePsiTask : function(component, event, helper) {
        component.get("v.isValid");
        helper.filedValidation(component,event,helper);
        if(!component.get("v.isValid"))  {
            return ;
        }
        component.set("v.showSpinner",true);
        var action = component.get('c.createPsiTask'); 
        action.setParams({
            "taskObj" : component.get("v.task"),
            "whatId" : component.get("v.caseId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var taskSubject =   component.get("v.task").Subject ;
                var returnString = a.getReturnValue();
                if(returnString == 'Duplicate Task Found'){
                    component.set("v.showSpinner",false);
                    component.set("v.toastMessage","Please Complete Open" +" "+taskSubject+" "+"Task");
                    helper.showToast(component,helper,'Error','Error');
                    return ; 
                }else if(returnString == 'Task Created'){
                    component.set("v.showSpinner",false);
                    component.set("v.toastMessage",taskSubject +" "+"Task"+" "+"Was Created.");
                    this.showToast(component,helper,'success','success');
                    $A.get('e.force:refreshView').fire();
                    component.set("v.showTaskCreatePopUpPI", false);
                    component.set("v.isValid",false);
                }else{
                    component.set("v.showSpinner",false);
                    component.set("v.isValid",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getFeildValues : function(component, event, helper) {
        var action = component.get('c.filedWrapperDataSet'); 
        action.setParams({
            "whatId" : component.get("v.caseId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var wrapper = a.getReturnValue();
                if(wrapper.teamNameQueData){
                    component.set("v.teamNameQueMap",wrapper.teamNameQueData);
                    var teamNameQueData = wrapper.teamNameQueData;
                    var teamNameList = [];
                    for (var key in wrapper.teamNameQueData) {
                        teamNameList.push(key);
                    }  
                    if(teamNameList){
                        teamNameList.sort();
                    }
                    component.set("v.teamName",teamNameList);
                    // component.set("v.salesforceTeamUserList",wrapper.sfdcTeams);
                    if(wrapper.sfdcTeamData){
                        component.set("v.sfdcTeamUserNameMap",wrapper.sfdcTeamData);
                        //    var teamNameQueData = wrapper.teamNameQueData;
                        var sfdcTeamList = [];
                        for (var key in wrapper.sfdcTeamData) {
                            sfdcTeamList.push(key);
                        }  
                        if(sfdcTeamList){
                            sfdcTeamList.sort();
                            
                        }
                        component.set("v.sfdcteamNameList",sfdcTeamList);
                        //  console.log('sfdcTeam' +salesforTeamUserList );
                        //   component.set("v.salesforceTeam",wrapper.sfdcTeams);
                        
                    }
                }
                component.set("v.teamNameQue",wrapper.teamNameQueData);
                console.log('DAS' + JSON.stringify(wrapper.teamNameQueData));
                console.log('DAS' +   JSON.stringify(wrapper.followUpReasons));
                console.log('DAS' +    JSON.stringify(wrapper.processOutcomeData));
            }
            
        });
        $A.enqueueAction(action);
    },
    showToast : function(component,helper,title,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: component.get("v.toastMessage"),
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    saveInternalRespoTask : function(component, event, helper) {
        // validation for Task type
        var isValidTaskType = component.find("taskType").get("v.validity");
        if(!isValidTaskType.valid){
            component.set("v.showSpinner",false);
            component.set("v.toastMessage","Please Select Task Type");
            this.showToast(component,helper,'Error','Error');
            return ;
        }
        // validation for comment
        var isValidTaskType = component.find("commentRequired").get("v.validity");
        if(!isValidTaskType.valid){
            component.set("v.showSpinner",false);
            component.set("v.toastMessage","Please Fill Comment");
            this.showToast(component,helper,'Error','Error');
            return ;
        }
        // all field validation
        var taskObj = component.get("v.task");
        var sfdcTeamvalue =       component.get("v.salesforceTeamUserValue")
        var assingedToUser = component.get("v.selectedLookUpRecord");
        var salesforceTeamvalue =  component.get("v.sfdcTeamValue");
        //validation assingedtouser
        
        if(assingedToUser && assingedToUser.Id && !component.get("v.isTaskUser") && !component.get("v.caseTrackingNumber") ){
            //component.set("v.isTaskUser",sfdcTaskUser);
            component.set("v.toastMessage","An Acorn Ticket Number is required to assign a Task to a Non SFDC user");
            this.showToast(component,helper,'Error','Error');  
            return;
        }
        
        //validation for  SFDC Team User
        if(salesforceTeamvalue && salesforceTeamvalue.length > 0 && (!sfdcTeamvalue || sfdcTeamvalue && sfdcTeamvalue.length == 0)){
            component.set("v.showSpinner",false);
            component.set("v.toastMessage","Please select SFDC Team User");
            this.showToast(component,helper,'Error','Error');
            return ; 
        }
        /* if(salesforceTeamvalue && sfdcTeamvalue && sfdcTeamvalue.length == 0 && component.get("v.caseTrackingNumber")){
            component.set("v.showSpinner",false);
            component.set("v.toastMessage","Please select SFDC Team User");
            this.showToast(component,helper,'Error','Error');
            return ; 
        }*/
        
        // validation for Assign To User Or SFDC Team User for case with no tracking number
        if(!sfdcTeamvalue &&  !assingedToUser.Id && !component.get("v.caseTrackingNumber")){
            component.set("v.showSpinner",false);
            component.set("v.toastMessage","Please select a Assign To User Or SFDC Team User");
            this.showToast(component,helper,'Error','Error');
            return ;
        }else if(!taskObj.Task_Team_Name__c && !sfdcTeamvalue && !assingedToUser.Id && component.get("v.caseTrackingNumber")){
            component.set("v.showSpinner",false);
            component.set("v.toastMessage","Please select a Assign To User Or Acorn Team and Queue or SFDC Team User");
            this.showToast(component,helper,'Error','Error');
            return ;
        }
        
        // validation for Team Queue
        if(taskObj.Task_Team_Name__c && (!taskObj.Task_Team_Queue__c || taskObj.Task_Team_Queue__c.length == 0 )){
            component.set("v.toastMessage","Team Queue is Mandatory.");
            this.showToast(component,helper,'Error','Error');
            component.set("v.showSpinner",false);
            return ;
        }
        var assingedToUser = component.get("v.selectedLookUpRecord");
        if(assingedToUser && assingedToUser.Id){
            //     alert('OwnerId' +JSON.stringify(assingedToUser));
            taskObj.OwnerId = assingedToUser.Id
        }else{
            taskObj.OwnerId = null ;
            
        }
        component.set("v.showSpinner",true);
        var action = component.get('c.createObtainInternalRespoTask'); 
        action.setParams({
            "taskObj" : taskObj,
            "whatId" : component.get("v.caseId"),
            "sfdcTeam" : component.get("v.salesforceTeamUserValue")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                component.set("v.showSpinner",false);
                var taskName = taskObj.Subject ;
                component.set("v.toastMessage",taskName +" "+"Task"+" "+"Was Created.");
                this.showToast(component,helper,'success','success');
                $A.get('e.force:refreshView').fire();
                component.set("v.showTaskCreatePopUpPI", false);
                component.set("v.selectedLookUpRecord" ,{});
                component.get("v.task",{});
                component.set("v.disabledTeamUser",false);
                component.set("v.disabledAcornTeam",false);
                component.set("v.salesforceTeamUserValue",'');
            }else{
                component.set("v.showSpinner",false); 
                $A.get('e.force:refreshView').fire();
                component.set("v.showTaskCreatePopUpPI", false);
                component.set("v.selectedLookUpRecord" ,{});
                component.get("v.task", {});
                component.set("v.showTaskCreatePopUpPI", false);
                component.set("v.disabledTeamUser",false);
                component.set("v.disabledAcornTeam",false);
                component.set("v.salesforceTeamUserValue",'');
            }
        });
        $A.enqueueAction(action);
    },
    getCaseDetails : function(component, event, helper) {
        var action = component.get('c.getCaseObject'); 
        action.setParams({
            "caseId" : component.get("v.caseId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var wrapper = a.getReturnValue();
                component.set("v.caseRecObj", wrapper.caseObj);
                if(wrapper && wrapper.caseObj &&  wrapper.caseObj.Tracking_Number__c){
                    component.set("v.caseTrackingNumber", true);
                    component.set("v.disabledAcornTeam",false);
                }
                component.set("v.showTaskButtons", wrapper.showButton);
                component.set("v.loggedInUserId", wrapper.currentUserRec);
            }
        });
        $A.enqueueAction(action);
    },
    getCaseTrackingNumber : function(component, event, helper) {
        var action = component.get('c.getCaseObject'); 
        action.setParams({
            "caseId" : component.get("v.caseId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var wrapper = a.getReturnValue();
                /* if( wrapper &&  wrapper.caseObj && !wrapper.caseObj.Tracking_Number__c){
                    
                    component.set("v.showInternalResponseTask", true);
                    component.set("v.showTaskCreatePopUpPI", true);
                }else*/ if(wrapper && wrapper.caseObj &&  wrapper.caseObj.Tracking_Number__c){
                    //changes - SDT-26312 -- disbale acorn team in UI Pop up 
                    component.set("v.caseTrackingNumber", true);
                    component.set("v.disabledAcornTeam",false);
                } 
            }
        });
        $A.enqueueAction(action);
    },
    disableAcornTeam: function(component,event,helper) {
        var divuserlookUp = component.find('userLookUp');
        $A.util.addClass(divuserlookUp, 'disableDiv'); 
        component.set("v.disabledAcornTeam",true);
        /* var divAcornTeam = component.find('acronTeamName');
        $A.util.addClass(divAcornTeam, 'disableDiv'); */
        
    },
    enableAcornTeam : function(component,event,helper){
        var divuserlookUp = component.find('userLookUp');
        $A.util.removeClass(divuserlookUp, 'disableDiv'); 
        component.set("v.disabledAcornTeam",false);
    },
    disableSfdcTeam :function(component,event,helper){
        var divuserlookUp = component.find('userLookUp');
        $A.util.addClass(divuserlookUp, 'disableDiv'); 
        component.set("v.disabledSfdcTeam",true);
        component.set("v.disabledTeamQ",false);
    },enableSfdcTeam :function(component,event,helper){
        var divuserlookUp = component.find('userLookUp');
        $A.util.removeClass(divuserlookUp, 'disableDiv'); 
        component.set("v.disabledSfdcTeam",false);
    },filedValidation :function(component,event,helper){
        if(component.get("v.showPendingInfoTask")){
            var allValid = component.find("requiredFiled").reduce(function (validSoFar, inputCmp) {
                //  inputCmp.reportValidity();
                //  alert(JSON.stringify(inputCmp));     
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                //  alert('All form entries look valid. Ready to submit!');
                var taskObj = component.get("v.task");
                var DuedateTime = taskObj.Due_Date_Time__c ;
                var dueDateConverted = new Date(DuedateTime);
                var currentDateTime = new Date();
                if(dueDateConverted && dueDateConverted <= currentDateTime){
                    component.set("v.showSpinner",false);
                    component.set("v.toastMessage","Please Select a Future Due date Time");
                    this.showToast(component,helper,'Error','Error');
                    return ;
                }
                component.set("v.isValid",true);
                return ;
            } else {
                component.set("v.toastMessage","Please Fill All The Required Fields");
                this.showToast(component,helper,'Error','Error');
                //  return ;
                component.set("v.isValid",false);
            } 
            
            /* var divuserlookUp = component.find('userLookUp');
        $A.util.removeClass(divuserlookUp, 'disableDiv'); 
         component.set("v.disabledTeams",false); */
        }
    },
    checkAssingedToUser : function(component, event, helper) {
        var action = component.get('c.checkUserIsTaskUser'); 
        action.setParams({
            "userCatCode" : component.get("v.selectedLookUpRecord").User_categorization_code__c
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var sfdcTaskUser = a.getReturnValue();
                if(!sfdcTaskUser){
                    component.set("v.isTaskUser",sfdcTaskUser);
                    component.set("v.toastMessage","An Acorn Ticket Number is required to assign a Task to a Non SFDC user");
                    this.showToast(component,helper,'Error','Error');     
                    
                }
            }
        });
        $A.enqueueAction(action);   
    }
})