({
    doInit: function(component, event, helper) {
        var act = component.get("c.getFewUsers");
        var workflowDataset = $A.get("$Label.c.WorkflowTaskAssignmentDataset");
        var ticketDataset = $A.get("$Label.c.TicketCaseCommentDataset");
        var caseDataset = $A.get("$Label.c.CaseDataset");
        
        act.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var currentUserRoleName = a.getReturnValue();
                
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
                var loggedInUserKPIFilter = '';
                loggedInUserKPIFilter = "{'datasets':{'"+workflowDataset+"':["+superVisorLoggedInKPI+"], '"+caseDataset+"':["+superVisorLoggedInKPI+"]}}";
                
                component.set("v.loggedInTeamKPI",loggedInUserKPIFilter);
                component.set("v.superVisorLoggedInKPI",superVisorLoggedInKPI);
                var developerName = component.get("v.developerName");
                var config = {"developerName": developerName,
                              "showHeader": true,
                              "showTitle": true, 
                              "height": 250};
                $A.createComponent("wave:waveDashboard", config, 
                                    function(dashboard, status, err) {
                                        if (status === "SUCCESS") {
                                            dashboard.set("v.rendered", true);
                                            dashboard.set("v.showHeader", true);
                                            dashboard.set("v.filter", loggedInUserKPIFilter);
                                            dashboard.set("v.title", true);
                                            component.set("v.body", dashboard);
                                        } else if (status === "INCOMPLETE") {
                                            console.log("No response from server or client is offline.")
                                        } else if (status === "ERROR") {
                                            console.log("Error: " + err);
                                        }
                                    }
                                );
                
            }
        }); 
        
        $A.enqueueAction(act);

        var appEvent = $A.get("e.c:AnalyticsApplicationEvent");
        appEvent.setParams({
            "showCaseDashboard" : false,
            "showTaskDashboard" : false,
            "showWorkflowTaskDashboard" : true,
            "showTicketDashboard" : false,
        });

        appEvent.fire();
    },
    
    showWorkflowGroupingDashboard: function(component, event, helper) {
        var buttonClicked = event.getSource().get("v.label");
        if(buttonClicked == 'WORKFLOW TASK'){
            component.set("v.workflowVariant","brand");
            component.set("v.taskVariant","brand-outline");
            component.set("v.caseVariant","brand-outline");
            component.set("v.ticketVariant","brand-outline");
        }
        var appEvent = $A.get("e.c:AnalyticsApplicationEvent");
        appEvent.setParams({
            "showCaseDashboard" : false,
            "showTaskDashboard" : false,
            "showWorkflowTaskDashboard" : true,
            "showTicketDashboard" : false,
        });
        appEvent.fire();
    },
    
    showTaskGroupingDashboard: function(component, event, helper) {
        
        var appEvent = $A.get("e.c:AnalyticsApplicationEvent");
        
        var buttonClicked = event.getSource().get("v.label");
        if(buttonClicked == 'TASKS'){
            component.set("v.taskVariant","brand");
            component.set("v.workflowVariant","brand-outline");
            component.set("v.caseVariant","brand-outline");
            component.set("v.ticketVariant","brand-outline");
        }
        
        appEvent.setParams({
            "showCaseDashboard" : false,
            "showTaskDashboard" : true,
            "showWorkflowTaskDashboard" : false,
            "showTicketDashboard" : false,
        });
        appEvent.fire();
    },
    
    showCaseDashboard: function(component, event, helper) {
        
        var appEvent = $A.get("e.c:AnalyticsApplicationEvent");
        
        var buttonClicked = event.getSource().get("v.label");
        if(buttonClicked == 'CASES'){
            component.set("v.caseVariant","brand");
            component.set("v.taskVariant","brand-outline");
            component.set("v.workflowVariant","brand-outline");
            component.set("v.ticketVariant","brand-outline");
        }
        
        appEvent.setParams({
            "showCaseDashboard" : true,
            "showTaskDashboard" : false,
            "showWorkflowTaskDashboard" : false,
            "showTicketDashboard" : false,
        });
        appEvent.fire();
    },
    
    showTicketDashboard: function(component, event, helper) {
        
        var appEvent = $A.get("e.c:AnalyticsApplicationEvent");
        
        var buttonClicked = event.getSource().get("v.label");
        if(buttonClicked == 'TICKETS'){
            component.set("v.ticketVariant","brand");
            component.set("v.workflowVariant","brand-outline");
            component.set("v.caseVariant","brand-outline");
            component.set("v.taskVariant","brand-outline");
        }
        
        appEvent.setParams({
            "showCaseDashboard" : false,
            "showTaskDashboard" : false,
            "showWorkflowTaskDashboard" : false,
            "showTicketDashboard" : true,
        });
        appEvent.fire();
    }
})