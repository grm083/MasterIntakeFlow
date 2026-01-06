({
    handleApplicationEvent : function(component, event, helper) {
        var showTaskDashboard = event.getParam("showTaskDashboard");
        var showWorkflowTaskDashboard = event.getParam("showWorkflowTaskDashboard");
        var showCaseDashboard = event.getParam("showCaseDashboard");
        var showTicketDashboard = event.getParam("showTicketDashboard");
        component.set("v.showTaskDashboard", showTaskDashboard);
        component.set("v.showWorkflowTaskDashboard", showWorkflowTaskDashboard);
        component.set("v.showCaseDashboard", showCaseDashboard);
        component.set("v.showTicketDashboard", showTicketDashboard);
        if(component.get("v.showTaskDashboard")){
            event.getSource().set("v.isLoading", true); 
			helper.taskSubDashboard(component, event,helper);
        }
        if(component.get("v.showWorkflowTaskDashboard")){
            event.getSource().set("v.isLoading", true); 
            helper.workflowSubDashboard(component, event,helper);
            helper.workflowTaskGroupingDashboard(component, event,helper);
        }
        if(component.get("v.showCaseDashboard")){
            event.getSource().set("v.isLoading", true); 
			helper.caseDashboard(component, event,helper);
        }
        if(component.get("v.showTicketDashboard")){
            event.getSource().set("v.isLoading", true); 
            helper.ticketSubDashboard(component, event,helper);
            helper.ticketGroupingDashboard(component, event, helper);
        }
    },
    
    getSelectedRow : function(component, event, helper) {
        
		if(component.get("v.showWorkflowTaskDashboard")){
			helper.workflowTaskSelected(component, event,helper);
		}
		else if(component.get("v.showTaskDashboard")){
			helper.taskSelected(component, event,helper);
        }
        else if(component.get("v.showCaseDashboard")){
			helper.caseSelected(component, event,helper);
        } 
        else if(component.get("v.showTicketDashboard")){
			helper.ticketSelected(component, event,helper);
        }
	},
    
    doInit : function(component, event, helper) {
        var act = component.get("c.getFewUsers");
        var workflowDataset = $A.get("$Label.c.WorkflowTaskAssignmentDataset");
        var ticketDataset = $A.get("$Label.c.TicketCaseCommentDataset");
        var caseDataset = $A.get("$Label.c.CaseDataset");
        
        act.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var currentUserRoleName = a.getReturnValue();
                var listAgentCSR = [];
                for(var i = 0; i< currentUserRoleName.length;i++){
                    listAgentCSR.push({ value: currentUserRoleName[i].Id, label: currentUserRoleName[i].Name });
                }
                component.set("v.listAgentCSR",listAgentCSR);
                
                var userLoggedInIds ='';
                for(var i = 0; i< currentUserRoleName.length;i++){
                    if(userLoggedInIds != undefined){
                        userLoggedInIds = userLoggedInIds + "'"+currentUserRoleName[i].Id+"',";
                    }
                    else{
                        userLoggedInIds = "'"+currentUserRoleName[i].Id+"',";
                    }
                }
                
                var superVisorLoggedInKPI = '';
                superVisorLoggedInKPI = "{'fields': ['OwnerId'], 'selection': ["+ userLoggedInIds +"]}";
                var workflowLoggedInUserKPIFilter = '';
                var caseLoggedInUserKPIFilter = '';
                var ticketLoggedInUserKPIFilter = '';
                
                workflowLoggedInUserKPIFilter = "{'datasets':{'"+workflowDataset+"':["+superVisorLoggedInKPI+"]}}";
                caseLoggedInUserKPIFilter = "{'datasets':{'"+caseDataset+"':["+superVisorLoggedInKPI+"]}}";
                ticketLoggedInUserKPIFilter = "{'datasets':{'"+ticketDataset+"':["+superVisorLoggedInKPI+"]}}"; 
                
                component.set('v.workflowLoggedInUserKPIFilter',workflowLoggedInUserKPIFilter);
                component.set('v.caseLoggedInUserKPIFilter',caseLoggedInUserKPIFilter);
                component.set('v.ticketLoggedInUserKPIFilter',ticketLoggedInUserKPIFilter);
                component.set('v.superVisorLoggedInKPI',superVisorLoggedInKPI);

                helper.workflowSubDashboard(component, event,helper);
                helper.workflowTaskGroupingDashboard(component, event,helper);
            }
        }); 
        
        $A.enqueueAction(act);
        
        var queueAction = component.get("c.getQueuePicklistvalues");
        
        queueAction.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.QueueList", response.getReturnValue());
			}
		});
        $A.enqueueAction(queueAction);

        /*var queueTeam = component.get("c.getTaskQueuePicklistvalues");
        
        queueTeam.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                
                component.set("v.teamQueueName", response.getReturnValue());
			}
		});
        $A.enqueueAction(queueTeam);*/

        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);

        var activeUsers = component.get("c.getAllActiveUsers");
        
        activeUsers.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var currentActiveUser = response.getReturnValue();
                var listActiveUser = [];
                for(var i = 0; i< currentActiveUser.length;i++){
                    listActiveUser.push({ value: currentActiveUser[i].Id, label: currentActiveUser[i].Name });
                }
                component.set("v.allActiveUser",listActiveUser);
			}
		});
        $A.enqueueAction(activeUsers);
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = component.find("selectTicketTeam").get("v.value"); // get selected controller field value
        component.set("v.selectedTeamName",controllerValueKey);
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
                    
	handleSelectionChanged : function(component, event,helper) {
		if(component.get("v.showWorkflowTaskDashboard")){
				helper.workflowSubDashboardFilter(component, event,helper);
		}
		else if(component.get("v.showTaskDashboard")){
				helper.taskSubDashboardFilter(component, event,helper);
        }
		else if(component.get("v.showTicketDashboard")){
            helper.ticketSubDashboardFilter(component, event,helper);
        }
	},
	
    assignmentModalPopup : function(component, event, helper){
        if(component.get("v.showWorkflowTaskDashboard")){
            if(component.get("v.selectedCSRUser") != 'None' && component.get("v.selectedCSRUser")){
                if(component.get("v.workflowTaskUpdateList").length > 0){
                    var startdateValue = new Date();
                    startdateValue.setDate(startdateValue.getDate());
                    component.set("v.datetime", startdateValue.toISOString());
                    component.set("v.isOpen", true);
                    component.set("v.modalPopupHeaderName", "Workflow Task Assignment");    
                }
                else{
                    component.set("v.isOpen", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please select any Task record!!"
                    });
                    toastEvent.fire();
                }
            }
            else{
                component.set("v.isOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select the User!!"
                });
                toastEvent.fire();
            }
		}
		else if(component.get("v.showTaskDashboard")){
            if(component.get("v.selectedCSRUser") != 'None' && component.get("v.selectedCSRUser")){
                if(component.get("v.taskUpdateList").length > 0){
                    var startdateValue = new Date();
                    startdateValue.setDate(startdateValue.getDate());
                    component.set("v.datetime", startdateValue.toISOString());
                    component.set("v.isOpen", true);
                    component.set("v.modalPopupHeaderName", "Task Assignment");
                }
                else{
                    component.set("v.isOpen", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please select any Task record!!"
                    });
                    toastEvent.fire();
                }
            }
            else{
                component.set("v.isOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select the User!!"
                });
                toastEvent.fire();
            }
        } 
            else if(component.get("v.showCaseDashboard")){
                if(component.get("v.caseUpdateList").length > 0){
                    if(event.getSource().get("v.name") == 'Assign To Owner'){
                        var startdateValue = new Date();
                        startdateValue.setDate(startdateValue.getDate());
                        component.set("v.datetime", startdateValue.toISOString());
                        component.set("v.selectedCSRUser",null);
                        component.set("v.modalPopupHeaderName", "Case Assignment");
                        component.set("v.isOpen", true);
                    }
                    else if(event.getSource().get("v.name") == 'Assign'){
                        if(component.get("v.selectedCSRUser") != 'None' && component.get("v.selectedCSRUser")){
                            var startdateValue = new Date();
                            startdateValue.setDate(startdateValue.getDate());
                            component.set("v.datetime", startdateValue.toISOString());
                            component.set("v.isOpen", true);
                            component.set("v.modalPopupHeaderName", "Case Assignment");
                        }
                        else{
                            component.set("v.isOpen", false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Please select the User!!"
                            });
                            toastEvent.fire();
                        }
                    }
                }else{
                    component.set("v.isOpen", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please select any Case record!!"
                    });
                    toastEvent.fire();
                }
        } 
        else if(component.get("v.showTicketDashboard")){
            if(component.get("v.selectedCSRUser") != 'None' && component.get("v.selectedCSRUser")){
                if(component.get("v.ticketUpdateMap") && component.get("v.ticketUpdateMap").length > 0){
                    var startdateValue = new Date();
                    startdateValue.setDate(startdateValue.getDate());
                    component.set("v.datetime", startdateValue.toISOString());
                    component.set("v.isOpen", true);
                    component.set("v.modalPopupHeaderName", "Ticket Assignment");    
                }
                else{
                    component.set("v.isOpen", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please select any Case record!!"
                    });
                    toastEvent.fire();
                }
            }
            else{
                component.set("v.isOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select the User!!"
                });
                toastEvent.fire();
            }
        } 
	},
    
    assignmentTeamPopup: function(component, event, helper){
        if(component.get("v.showTicketDashboard")){
            if(component.get("v.selectedTeamQueue") != 'None' && component.get("v.selectedTeamQueue")){
                if(component.get("v.ticketUpdateMap") && component.get("v.ticketUpdateMap").length > 0){
                    var startdateValue = new Date();
                    startdateValue.setDate(startdateValue.getDate());
                    component.set("v.datetime", startdateValue.toISOString());
                    component.set("v.isOpen", true);
                    component.set("v.modalPopupHeaderName", "Ticket Assignment Team");    
                }
                else{
                    component.set("v.isOpen", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please select any Case record!!"
                    });
                    toastEvent.fire();
                }
            }
            else{
                component.set("v.isOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select any team!!"
                });
                toastEvent.fire();
            }
        }
    },

	closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
		component.set("v.isOpen", false);
		component.set("v.isOpenSubModal", false);
    },
    
    caseRadioSelected: function(component, event, helper) {
        component.set("v.radioCaseSelected",event.getParam("value"));
        helper.ticketSubDashboard(component, event,helper);
        helper.ticketGroupingDashboard(component, event,helper);
    },
    
    userRadioselected: function(component, event, helper) {
        component.set("v.radioUserSelected",event.getParam("value"));
    },
	
	saveAndClose: function(component, event, helper) {
        if(component.find("today").get("v.value")){
            if(component.get("v.showWorkflowTaskDashboard")){
                helper.workflowTaskUpdate(component, event,helper);
            }
            else if(component.get("v.showTaskDashboard")){
                helper.taskUpdate(component, event,helper);
            }
            else if(component.get("v.showCaseDashboard")){
				helper.caseUpdate(component, event,helper);
			}
			else if(component.get("v.showTicketDashboard")){
				helper.ticketUpdate(component, event,helper);
		    }
            component.set("v.isOpen", false);
        }
        else{
            component.set("v.isOpen", true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please enter the date!!"
            });
            toastEvent.fire();
        }
	},
	
    selectPriority : function(component, event, helper) {
		var prioritySelected = event.getParam("value");
		component.set("v.selectedTaskPriority", prioritySelected);
	}, 
    
    handleCloseTask : function(component, event, helper) {
        component.set("v.modalPopupHeaderName", "Close Workflow Task");
        component.set("v.isOpenSubModal", true);
	},
	
    saveAndCloseWorkFlowTask : function(component, event, helper) {
        if(component.get("v.workflowTaskUpdateList").length > 0){
            helper.workflowTaskClose(component, event,helper);
            component.set("v.modalPopupHeaderName", "Close Workflow Task");
            component.set("v.isOpenSubModal", false);    
        }
         else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": "Please select any record."
            });
            toastEvent.fire();
        }
	}, 
    
    onUserSelect : function(component, event, helper) {
        if(component.get("v.showWorkflowTaskDashboard")){
			component.set("v.selectedCSRUser",component.find("selectWorkflow").get("v.value"));
		}
		else if(component.get("v.showTaskDashboard")){
			component.set("v.selectedCSRUser",component.find("selectTask").get("v.value"));
        }
        else if(component.get("v.showCaseDashboard")){
			component.set("v.selectedCSRUser",component.find("selectCase").get("v.value"));
        }
		else if(component.get("v.showTicketDashboard")){
            if(component.get("v.radioUserSelected") == 'yourteam'){
                component.set("v.selectedCSRUser",component.find("selectTicketTeamUser").get("v.value"));
            }
            else{
				component.set("v.selectedCSRUser",component.find("selectTicketAllUser").get("v.value"));                
            }
	    }
    },
    
    onTeamSelect: function(component, event, helper) {
        if(component.get("v.showTicketDashboard")){
    		component.set("v.selectedTeamQueue",component.find("selectTicketQueue").get("v.value"));
	    }
    },
    
    /*onFilterSelect : function(component, event, helper) {
        if(component.get("v.showWorkflowTaskDashboard")){
        	component.set("v.removeWorkflowSelectedFilter",component.find("workflowFilter").get("v.value"));
    	}
 		else if(component.get("v.showTaskDashboard")){
        	component.set("v.removeTaskSelectedFilter",component.find("taskFilter").get("v.value"));
    	}
		else if(component.get("v.showTicketDashboard")){
        	component.set("v.removeTicketSelectedFilter",component.find("ticketFilter").get("v.value"));
    	}
     },*/
     
     onTaskTypeSelect : function(component, event, helper) {
        if(component.get("v.showWorkflowTaskDashboard")){
            component.set("v.workflowTaskTypeSelected",component.find("workflowTaskType").get("v.value"));
            var filterTaskType = component.get("v.workflowTaskTypeSelected");
            var filterOnDashboard = component.get("v.workflowDashboardFilter");
            var dashboardFilterMap = component.get("v.workflowdashboardFilterMap");
            
            for(var i = 0; i< dashboardFilterMap.length;i++){  
                if(dashboardFilterMap[i].step == 'TaskType'){
                    dashboardFilterMap.splice(i,1);
                }
            }

            if(filterTaskType == 'Customer Services'){
                if(filterOnDashboard != undefined){
                    filterOnDashboard = filterOnDashboard + "{'fields': ['Case.Case_CSPS_Flag'], 'filter': {'operator': 'in', 'values':['CS']}},";
                }
                else{
                    filterOnDashboard = "{'fields': ['Case.Case_CSPS_Flag'], 'filter': {'operator': 'in', 'values':['CS']}},";
                }
                dashboardFilterMap.push({step: 'TaskType',label:'Case.Case_CSPS_Flag', fieldName:filterTaskType});
            }
            else if(filterTaskType == 'Project Services'){
                if(filterOnDashboard != undefined){
                    filterOnDashboard = filterOnDashboard + "{'fields': ['Case.Case_CSPS_Flag'], 'filter': {'operator': 'in', 'values':['PS']}},";
                }
                else{
                    filterOnDashboard = "{'fields': ['Case.Case_CSPS_Flag'], 'filter': {'operator': 'in', 'values':['PS']}},";
                }
                dashboardFilterMap.push({step: 'TaskType',label:'Case.Case_CSPS_Flag', fieldName:filterTaskType});
            }
            component.set("v.workflowDashboardFilter",filterOnDashboard);
            component.set("v.workflowdashboardFilterMap",dashboardFilterMap);
            helper.workflowSubDashboard(component, event, helper);
            helper.workflowTaskGroupingDashboard(component, event,helper);
    	}
 	},
    
    removeSelectedFilter : function(component, event, helper) {
        var dashboardFilterMap = [];
        var dashboardFilter = [];
        if(component.get("v.showWorkflowTaskDashboard")){
            component.set("v.workflowdashboardFilterMap",dashboardFilterMap);
            component.set("v.workflowDashboardFilter",dashboardFilter);
            component.find("workflowTaskType").set("v.value", "All");
            helper.workflowSubDashboard(component, event, helper);
    	}
 		else if(component.get("v.showTaskDashboard")){
            component.set("v.taskdashboardFilterMap",dashboardFilterMap);
            component.set("v.taskDashboardFilter",dashboardFilter);
            helper.taskSubDashboard(component, event, helper);
    	}
		else if(component.get("v.showTicketDashboard")){
            component.set("v.ticketdashboardFilterMap",dashboardFilterMap);
            component.set("v.ticketDashboardFilter",dashboardFilter);
            //component.find("Queue").set("v.value", "--None--");
            helper.ticketSubDashboard(component, event, helper);
    	}
 	},
    
    /*onQueueSelect : function(component, event, helper) {
        
        var dataList = [];
        var filterOnDashboard = component.get("v.ticketDashboardFilter");
        var dashboardFilterMap = component.get("v.ticketdashboardFilterMap");
        var queueName = component.find("Queue").get("v.value");
        
        var originalData = component.get("v.originalTicketList");
        
        for(var idx=0; idx<originalData.length; idx++){
            if((originalData[idx].Queue == queueName)&& (originalData[idx].Queue != '--None--')){
                dataList.push(originalData[idx]);
            }
            else if(queueName == '--None--') {
                dataList.push(originalData[idx]);   
            }
        }
        
        for(var i = 0; i< dashboardFilterMap.length;i++){  
            if(dashboardFilterMap[i].step == 'CaseComment_Workflow_1' && queueName == '--None--'){
                dashboardFilterMap.splice(i,1);
            }
        }
        
        if(queueName != null && queueName != '--None--'){
            if(filterOnDashboard != undefined){
                filterOnDashboard = filterOnDashboard + "{'fields': ['CaseComment.Workflow_TeamQueue__c'], 'filter': {'operator': 'in', 'values':['"+queueName+"']}},";
                dashboardFilterMap.push({step: 'CaseComment_Workflow_1',label:'CaseComment.Workflow_TeamQueue__c', fieldName:queueName});    
            }
            else{
                filterOnDashboard = "{'fields': ['CaseComment.Workflow_TeamQueue__c'], 'filter': {'operator': 'in', 'values':['"+queueName+"']}},";
                dashboardFilterMap.push({step: 'CaseComment_Workflow_1',label:'CaseComment.Workflow_TeamQueue__c', fieldName:queueName});
            }
        }
        else if(queueName == '--None--'){
            filterOnDashboard = '';
        }
        component.set("v.ticketDashboardFilter",filterOnDashboard);
        component.set("v.ticketdashboardFilterMap",dashboardFilterMap);
        helper.ticketSubDashboard(component, event, helper);
        helper.ticketGroupingDashboard(component, event, helper);
    },*/
                    
	loadMoreData : function(component, event, helper) {
		if(component.get("v.showWorkflowTaskDashboard")){
			helper.loadMoreWorkflowTableData(component, event,helper);
		}
		else if(component.get("v.showTaskDashboard")){
			helper.loadMoreWorkflowTableData(component, event,helper);
        }
        else if(component.get("v.showCaseDashboard")){
			helper.loadMoreCaseTableData(component, event,helper);
        }
        else if(component.get("v.showTicketDashboard")){
			helper.loadMoreTicketTableData(component, event,helper);
        }
	},
    
    searchWorkflowTaskCase : function(component, event, helper) {
    	var searchText = component.get("v.searchText");
        var originalWorkflowList = component.get("v.originalWorkflowTaskList");
        var filterOnDashboard = component.get("v.workflowDashboardFilter");
        var dashboardFilterMap = component.get("v.workflowdashboardFilterMap");
        var filteredWorkflowList = [];
        
        if(searchText != null && searchText != ""){
            /*for(var i=0;i<originalWorkflowList.length;i++){
                if(originalWorkflowList[i].CaseNumber == searchText){
                    filteredWorkflowList.push(originalWorkflowList[i]);
                }
            }
            component.set("v.workflowTaskList",filteredWorkflowList);
            component.set("v.enableInfiniteLoading",false);*/
            
            /*if(filterOnDashboard != undefined){
                filterOnDashboard = filterOnDashboard + "{'fields': ['Case.CaseNumber'], 'filter': {'operator': 'in', 'values':['CS']}},";
            }
            else{
                filterOnDashboard = "{'fields': ['Case.CaseNumber'], 'filter': {'operator': 'in', 'values':['CS']}},";
            }*/
            dashboardFilterMap.push({step: 'CaseSearch',label:'Case.CaseNumber', fieldName:searchText});
            component.set("v.workflowdashboardFilterMap",dashboardFilterMap);
            helper.workflowSubDashboard(component, event, helper);
        }
        else{
            for(var i = 0; i< dashboardFilterMap.length;i++){  
                if(dashboardFilterMap[i].step == 'CaseSearch'){
                    dashboardFilterMap.splice(i,1);
                }
            }
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": "Please enter any text."
            });
            toastEvent.fire();
            component.set("v.workflowdashboardFilterMap",dashboardFilterMap);
            helper.workflowSubDashboard(component, event, helper);
            helper.workflowTaskGroupingDashboard(component, event,helper);
        }
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },

    // function for sorting the table based on the selected column.
    updateColumnSorting: function (component, event, helper) {
        component.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout($A.getCallback(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            component.set("v.sortedBy", fieldName);
            component.set("v.sortedDirection", sortDirection);
            helper.sortData(component, fieldName, sortDirection);
            component.set('v.isLoading', false);
        }), 0);
    }
})