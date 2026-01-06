({
    workflowSubDashboardFilter : function(component, event,helper) {
        var dashboardFilterMap = component.get("v.workflowdashboardFilterMap");
        var currentSelection='';
        var fieldSelection = '';
        var filterOnDashboard = '';
        var step = '';
        var params = event.getParams();
        var payload = params.payload;
        if (payload) {
            step = payload.step;
            var data = payload.data;
            data.forEach(function(obj) {
                for (var k in obj) {
                    if(k != 'TaskAgeBucket' && k != 'Priority' && k != 'TaskOwnerName' && k != 'Task_SLA' && k != 'Case_SLA' && k != 'count'){
                        currentSelection = obj[k]; 
                        fieldSelection = k; 
                        break;
                    }
                }
            });
        }
        
        var dashboardFilterMapLength = dashboardFilterMap.length;
        
        for(var i = 0; i< dashboardFilterMapLength;i++){  
            if(dashboardFilterMap[i].step == step && (currentSelection == '' || dashboardFilterMap[i].fieldName == currentSelection)){
                dashboardFilterMap.splice(i,1);
                dashboardFilterMapLength = dashboardFilterMapLength - 1;
            }
        }
        
        if(currentSelection != ''){
            dashboardFilterMap.push({step: step,label:fieldSelection, fieldName:currentSelection});    
        }
        
        component.set("v.workflowdashboardFilterMap",dashboardFilterMap);
        
        for(var i = 0; i< dashboardFilterMap.length;i++){    
            if(filterOnDashboard != undefined){
                filterOnDashboard = filterOnDashboard + "{'fields': ['"+dashboardFilterMap[i].label+"'], 'filter': {'operator': 'in', 'values':['"+dashboardFilterMap[i].fieldName+"']}},";
            }
            else{
                filterOnDashboard = "{'fields': ['"+dashboardFilterMap[i].label+"'], 'filter': {'operator': 'in', 'values':['"+dashboardFilterMap[i].fieldName+"']}},";
            }
        }
        component.set("v.workflowDashboardFilter",filterOnDashboard);
        
        if(currentSelection != '' || payload.data.length == 0){
            helper.workflowSubDashboard(component, event,helper);
        }
        
    },
    
    workflowSubDashboard : function(component, event,helper) {
        component.set("v.enableInfiniteLoading", true);
        var dashboardFilterMap = component.get("v.workflowdashboardFilterMap");
		var workflowDataset = $A.get("$Label.c.WorkflowTaskAssignmentDataset");
        var filter = "";
        
        var mapToSendFilter = {};
        for(var i=0; i<dashboardFilterMap.length; i++){
            mapToSendFilter[dashboardFilterMap[i].label] = dashboardFilterMap[i].fieldName;
        }
        
        var actionTask = component.get("c.getTaskList");
        actionTask.setParams({
            'taskTab' : 'workflow',
            'dashboardFilter' : mapToSendFilter
        });
        
        actionTask.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataList = [];
                var originalData = response.getReturnValue();
                
                if(component.get('v.workflowDashboardFilter') != undefined){
                    filter = "{'datasets':{'"+workflowDataset+"':["+component.get('v.superVisorLoggedInKPI')+ "," + component.get('v.workflowDashboardFilter') +"]}}";
                }
                else{
                    filter = "{'datasets':{'"+workflowDataset+"':["+component.get('v.superVisorLoggedInKPI')+"]}}";
                }
                
                var developerName = component.get("v.Task_Assigned_Dashboard");
                var config = {"developerName": developerName,
                              "showHeader": false,
                              "showTitle": false, 
                              "height": 400};
                $A.createComponent("wave:waveDashboard", config, 
                                    function(dashboard, status, err) {
                                        if (status === "SUCCESS") {
                                            dashboard.set("v.rendered", true);
                                            dashboard.set("v.showHeader", false);
                                            dashboard.set("v.filter", filter);
                                            dashboard.set("v.title", false);
                                            component.set("v.taskbody", dashboard);
                                        } else if (status === "INCOMPLETE") {
                                            console.log("No response from server or client is offline.")
                                        } else if (status === "ERROR") {
                                            console.log("Error: " + err);
                                        }
                                    }
                                );
                                
                component.set("v.workflowTaskList", dataList);
                component.set("v.workflowTotalCount", originalData.length);
                component.set("v.originalWorkflowTaskList", originalData);
                
                for(var idx=0; idx<originalData.length && dataList.length < 50; idx++){
                    dataList.push(originalData[idx]);
                }
                component.set("v.workflowTaskList", dataList);
                
                component.set('v.workflowTaskColumns', [
                    {label: 'Case Number', fieldName: 'CaseNumber', type: 'text',initialWidth: 120},
                    {label: 'Task Age', fieldName: 'TaskAge', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Case SLA Date', fieldName: 'CaseSLADate', type: 'Date',initialWidth: 120, sortable: true},
                    {label: 'Due Date/Time', fieldName: 'DueDate', type: 'Date',initialWidth: 120, sortable: true},
                    {label: 'Process', fieldName: 'Process', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Attempt', fieldName: 'Attempt', type: 'integer',initialWidth: 120},
                    {label: 'Task Type', fieldName: 'TaskType', type: 'text',initialWidth: 120},
                    {label: 'Case Type', fieldName: 'CaseType', type: 'text',initialWidth: 120},
                    {label: 'Case SubType', fieldName: 'CaseSubType', type: 'text',initialWidth: 120},
                    {label: 'Case Service Date', fieldName: 'CaseServiceDate', type: 'date',initialWidth: 120, sortable: true},
                    {label: 'Company Category', fieldName: 'CompanyCategory', type: 'text',initialWidth: 120},
                    {label: 'Position', fieldName: 'Position', type: 'text',initialWidth: 120},
                    {label: 'MAS Account Number', fieldName: 'MASAccountNumber', type: 'text',initialWidth: 120},
                    {label: 'Client Name', fieldName: 'ClientName', type: 'text',initialWidth: 120},
                    {label: 'Client Code', fieldName: 'ClientCode', type: 'text',initialWidth: 120},
                    {label: 'Acorn WO Number', fieldName: 'AcornWONumber', type: 'text',initialWidth: 120},
                    {label: 'Parent Vendor', fieldName: 'ParentVendor', type: 'text',initialWidth: 120},
                    {label: 'Vendor BU', fieldName: 'VendorBU', type: 'text',initialWidth: 120},
                    {label: 'Vendor Name', fieldName: 'VendorName', type: 'Text',initialWidth: 120},
                    {label: 'WM Vendor', fieldName: 'WMVendor', type: 'Text',initialWidth: 120},
                    {label: 'Vendor Account Number', fieldName: 'VendorAccountNumber', type: 'text',initialWidth: 120},
                    {label: 'Location', fieldName: 'Location', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Location Address', fieldName: 'LocationAddress', type: 'text',initialWidth: 120},
                    {label: 'Location City', fieldName: 'LocationCity', type: 'text',initialWidth: 120},
                    {label: 'Location State', fieldName: 'LocationState', type: 'text',initialWidth: 120},
                    {label: 'Location Zip Code', fieldName: 'LocationZipCode', type: 'text',initialWidth: 120},
                    {label: 'Asset Name', fieldName: 'AssetName', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Equipment Size', fieldName: 'EquipmentSize', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Material Type', fieldName: 'MaterialType', type: 'text',initialWidth: 120, sortable: true}
                ]);
                event.getSource().set("v.isLoading", false); 
            }
        });
        $A.enqueueAction(actionTask);
    },

    workflowTaskGroupingDashboard: function(component, event,helper){
        var dashboardFilterMap = component.get("v.workflowdashboardFilterMap");
		var workflowDataset = $A.get("$Label.c.WorkflowTaskAssignmentDataset");
        var filter = "";

        if(component.get('v.workflowDashboardFilter') != undefined){
            filter = "{'datasets':{'"+workflowDataset+"':["+component.get('v.workflowDashboardFilter')+"]}}";
        }
        
        var developerName = component.get("v.WorkflowTaskGrouping");
        var config = {"developerName": developerName,
                      "showHeader": false,
                      "showTitle": false,
                      "height": 1000};
        $A.createComponent("wave:waveDashboard", config, 
                           function(dashboard, status, err) {
                               if (status === "SUCCESS") {
                                   dashboard.set("v.rendered", true);
                                   dashboard.set("v.showHeader", false);
                                   dashboard.set("v.filter", filter);
                                   dashboard.set("v.title", false);
                                   component.set("v.body", dashboard);
                               } else if (status === "INCOMPLETE") {
                                   console.log("No response from server or client is offline.")
                               } else if (status === "ERROR") {
                                   console.log("Error: " + err);
                               }
                           }
                          );
    },
    
    ticketSubDashboardFilter : function(component, event,helper) {
        var dashboardFilterMap = component.get("v.ticketdashboardFilterMap");
        var currentSelection='';
        var fieldSelection = '';
        var filterOnDashboard = '';
        var step = '';
        var params = event.getParams();
        var payload = params.payload;
        if (payload) {
            step = payload.step;
            var data = payload.data;
            data.forEach(function(obj) {
                for (var k in obj) {
                    if(k != 'TaskAgeBucket' && k != 'Priority' && k != 'TaskOwnerName' && k != 'Task_SLA' && k != 'Case_SLA' && k != 'Process__c' && k != 'count'){
                        currentSelection = obj[k]; 
                        fieldSelection = k; 
                        break;
                    }
                }
            });
        }
		var dashboardFilterMapLength = dashboardFilterMap.length;
        
        for(var i = 0; i< dashboardFilterMapLength;i++){  
            if(dashboardFilterMap[i].step == step && (currentSelection == '' || dashboardFilterMap[i].fieldName == currentSelection)){
                dashboardFilterMap.splice(i,1);
                dashboardFilterMapLength = dashboardFilterMapLength - 1;
            }
        }
        
        if(currentSelection != ''){
            dashboardFilterMap.push({step: step,label:fieldSelection, fieldName:currentSelection});    
        }
        
        component.set("v.ticketdashboardFilterMap",dashboardFilterMap);
        
        for(var i = 0; i< dashboardFilterMap.length;i++){    
            if(filterOnDashboard != undefined){
                filterOnDashboard = filterOnDashboard + "{'fields': ['"+dashboardFilterMap[i].label+"'], 'filter': {'operator': 'in', 'values':['"+dashboardFilterMap[i].fieldName+"']}},";
            }
            else{
                filterOnDashboard = "{'fields': ['"+dashboardFilterMap[i].label+"'], 'filter': {'operator': 'in', 'values':['"+dashboardFilterMap[i].fieldName+"']}},";
            }
        }
        component.set("v.ticketDashboardFilter",filterOnDashboard);

        if(currentSelection != '' || payload.data.length == 0){
            helper.ticketSubDashboard(component, event,helper);
        }
    },
    
    ticketSubDashboard : function(component, event,helper) {
        component.set("v.enableInfiniteLoading", true);
        var ticketDataset = $A.get("$Label.c.TicketCaseCommentDataset");
        var workflowDataset = $A.get("$Label.c.WorkflowTaskAssignmentDataset");
        var dashboardFilterMap = component.get("v.ticketdashboardFilterMap");
        var filter = "";
        
        if(event.getParam("value") == undefined){
            event.getSource().set("v.isLoading", true);
        } 
        
        var mapToSendFilter = {};
        var multiSelectFilterValues = "";
        for(var i=0; i<dashboardFilterMap.length; i++){
            if(dashboardFilterMap[i].label == 'CaseComment.Workflow_TeamQueue__c'){
                if(multiSelectFilterValues != undefined && multiSelectFilterValues != null && multiSelectFilterValues != ""){
                    multiSelectFilterValues = multiSelectFilterValues + ",\""+dashboardFilterMap[i].fieldName+"\"";
                }
                else{
                    multiSelectFilterValues = "\""+ dashboardFilterMap[i].fieldName+"\"";
                }
                mapToSendFilter[dashboardFilterMap[i].label] = multiSelectFilterValues;
            }
            else{
                mapToSendFilter[dashboardFilterMap[i].label] = dashboardFilterMap[i].fieldName;
            }
        }

        //Ticket Table Data 
        var actionTask = component.get("c.getTicketList");
        actionTask.setParams({
            'dashboardFilter' : mapToSendFilter,
            'ticketTabSelection' : component.get("v.radioCaseSelected")
        });
        
        actionTask.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataList = [];
                var ticketList = response.getReturnValue();
                
                if(component.get('v.ticketDashboardFilter') != undefined){
                    filter = "{'datasets':{'"+workflowDataset+"':["+component.get('v.superVisorLoggedInKPI')+ "," + component.get('v.ticketDashboardFilter') +"]}}";
                }
                else{
                    filter = "{'datasets':{'"+workflowDataset+"':["+component.get('v.superVisorLoggedInKPI')+"]}}";
                }
                
                var developerName = component.get("v.Task_Assigned_Dashboard");
                var config = {"developerName": developerName,
                              "showHeader": false,
                              "showTitle": false, 
                              "height": 400};
                $A.createComponent("wave:waveDashboard", config, 
                                    function(dashboard, status, err) {
                                        if (status === "SUCCESS") {
                                            dashboard.set("v.rendered", true);
                                            dashboard.set("v.showHeader", false);
                                            dashboard.set("v.filter", filter);
                                            dashboard.set("v.title", false);
                                            component.set("v.taskbody", dashboard);
                                        } else if (status === "INCOMPLETE") {
                                            console.log("No response from server or client is offline.")
                                        } else if (status === "ERROR") {
                                            console.log("Error: " + err);
                                        }
                                    }
                                );

                component.set("v.ticketList", dataList);
                component.set("v.originalTicketList", ticketList);
                component.set("v.ticketTotalCount", ticketList.length);
                
                for(var idx=0; idx<ticketList.length && dataList.length < 50; idx++){
                    dataList.push(ticketList[idx]);
                }
                component.set("v.ticketList", dataList);
                
                component.set('v.ticketColumns', [
                    {label: 'Case Number', fieldName: 'CaseNumber', type: 'text',initialWidth: 120},
                    {label: 'Team Queue', fieldName: 'TeamQueue', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Case SLA Date', fieldName: 'CaseSLADate', type: 'Date',initialWidth: 120},
                    {label: 'Ticket Age', fieldName: 'TicketAge', type: 'Date',initialWidth: 120, sortable: true},
					{label: 'Created Date', fieldName: 'CreatedDate', type: 'Date',initialWidth: 120, sortable: true},//added for 18165
                    {label: 'Acorn Tracking Number', fieldName: 'AcornTrackingNumber', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Acorn Work Order', fieldName: 'AcornWorkOrder', type: 'text',initialWidth: 120,sortable: true},
                    {label: 'Case Type', fieldName: 'CaseType', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Case SubType', fieldName: 'CaseSubType', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Case Reason', fieldName: 'CaseReason', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Case Service Date', fieldName: 'CaseServiceDate', type: 'date',initialWidth: 120, sortable: true},
                    {label: 'Location', fieldName: 'Location', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Client Name', fieldName: 'ClientName', type: 'text',initialWidth: 120},
                    {label: 'Client Code', fieldName: 'ClientCode', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Client Primary Segment', fieldName: 'ClientPrimarySegment', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Vendor Name', fieldName: 'VendorName', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Case Owner', fieldName: 'TicketOwner', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Parent Vendor', fieldName: 'ParentVendor', type: 'text',initialWidth: 120},
                    {label: 'Location Address', fieldName: 'LocationAddress', type: 'text',initialWidth: 120},
                    {label: 'Location City', fieldName: 'LocationCity', type: 'text',initialWidth: 120},
                    {label: 'Location State', fieldName: 'LocationState', type: 'text',initialWidth: 120},
                    {label: 'Location Zip Code', fieldName: 'LocationZipCode', type: 'text',initialWidth: 120},
                    {label: 'Location TimeZone', fieldName: 'LocationTimeZone', type: 'text',initialWidth: 120},
                    {label: 'Asset Name', fieldName: 'AssetName', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Equipment Size', fieldName: 'EquipmentSize', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Material Type', fieldName: 'MaterialType', type: 'text',initialWidth: 120, sortable: true}
                ]);
                if(event.getParam("value") == undefined){
                    event.getSource().set("v.isLoading", false); 
                }
                
            }
        });
        $A.enqueueAction(actionTask);
    },
    
    ticketGroupingDashboard : function(component, event,helper){
        var filterOnDashboard = component.get("v.ticketDashboardFilter");
        var ticketDataset = $A.get("$Label.c.TicketCaseCommentDataset");
        var teamQueuesList = component.get("v.QueueList");
        var filter = "";
        
        if(component.get("v.radioCaseSelected") == 'allCases'){
            var teamQueues ='';
            for(var i = 1; i< teamQueuesList.length;i++){
                if(teamQueues != undefined){
                    teamQueues = teamQueues + "'"+teamQueuesList[i]+"',";
                }
                else{
                    teamQueues = "'"+teamQueuesList[i]+"',";
                }
            }
            
            var teamQueuesFilter = '';
            var teamQueuesTaskFilter = '';
            teamQueuesFilter = "{'fields': ['TicketOpenTask.Subject'] , 'filter': {'operator': 'not in', 'values':["+ teamQueues +"]}},";
            teamQueuesTaskFilter = "{'fields': ['TicketOpenTask.Status'] , 'filter': {'operator': 'not in', 'values':['Open']}},";
            if(filterOnDashboard != undefined){
                //+ teamQueuesFilter
                filterOnDashboard = filterOnDashboard + teamQueuesFilter + teamQueuesTaskFilter;
            }
            else{
                //teamQueuesFilter +
                filterOnDashboard = teamQueuesFilter +teamQueuesTaskFilter;
            }
        }
        else {
            var teamQueuesAnyOpenTaskFilter = '';
            teamQueuesAnyOpenTaskFilter = "{'fields': ['HasOpenTask'] , 'filter': {'operator': 'in', 'values':['No']}},";
            
            if(filterOnDashboard != undefined){
                filterOnDashboard = filterOnDashboard + teamQueuesAnyOpenTaskFilter;
            }
            else{
                filterOnDashboard = teamQueuesAnyOpenTaskFilter;
            }
        }
        if(filterOnDashboard != undefined){
            filter = "{'datasets':{'"+ticketDataset+"':["+filterOnDashboard+"]}}";
        }
        
        var developerName = component.get("v.Ticket_Grouping_Dashboard");
        var config = {"developerName": developerName,
                      "showHeader": false,
                      "showTitle": false, 
                      "height": 1000};
        $A.createComponent("wave:waveDashboard", config, 
                           function(dashboard, status, err) {
                               if (status === "SUCCESS") {
                                   dashboard.set("v.rendered", true);
                                   dashboard.set("v.showHeader", false);
                                   dashboard.set("v.filter", filter);
                                   dashboard.set("v.title", false);
                                   component.set("v.body", dashboard);
                               } else if (status === "INCOMPLETE") {
                                   console.log("No response from server or client is offline.")
                               } else if (status === "ERROR") {
                                   console.log("Error: " + err);
                               }
                           }
                          );
    },

    taskSubDashboardFilter : function(component, event,helper) {
        var dashboardFilterMap = component.get("v.taskdashboardFilterMap");
        var currentSelection='';
        var fieldSelection = '';
        var filterOnDashboard = '';
        var params = event.getParams();
        var payload = params.payload;
        if (payload) {
            var step = payload.step;
            var data = payload.data;
            data.forEach(function(obj) {
                for (var k in obj) {
                    if(k != 'TaskAgeBucket' && k != 'Priority' && k != 'Task_SLA' && k != 'Case_SLA' && k != 'count'){
                        currentSelection = obj[k]; 
                        fieldSelection = k;
                        break;
                    }
                }
            });
        }
        var dashboardFilterMapLength = dashboardFilterMap.length;
        
        for(var i = 0; i< dashboardFilterMapLength;i++){  
            if(dashboardFilterMap[i].step == step && (currentSelection == '' || dashboardFilterMap[i].fieldName == currentSelection)){
                dashboardFilterMap.splice(i,1);
                dashboardFilterMapLength = dashboardFilterMapLength - 1;
            }
        }
        
        if(currentSelection != ''){
            dashboardFilterMap.push({step: step,label:fieldSelection, fieldName:currentSelection});    
        }
        
        component.set("v.taskdashboardFilterMap",dashboardFilterMap);
        
        for(var i = 0; i< dashboardFilterMap.length;i++){    
            if(filterOnDashboard != undefined){
                filterOnDashboard = filterOnDashboard + "{'fields': ['"+dashboardFilterMap[i].label+"'], 'filter': {'operator': 'in', 'values':['"+dashboardFilterMap[i].fieldName+"']}},";
            }
            else{
                filterOnDashboard = "{'fields': ['"+dashboardFilterMap[i].label+"'], 'filter': {'operator': 'in', 'values':['"+dashboardFilterMap[i].fieldName+"']}},";
            }
        }
        component.set("v.taskDashboardFilter",filterOnDashboard);

        helper.taskSubDashboard(component, event,helper);
    },
    
    taskSubDashboard : function(component, event,helper) {
        component.set("v.enableInfiniteLoading", true);
        var workflowDataset = $A.get("$Label.c.WorkflowTaskAssignmentDataset");
        var filter = "";
        if(component.get('v.taskDashboardFilter') != undefined){
            filter = "{'datasets':{'"+workflowDataset+"':["+component.get('v.superVisorLoggedInKPI')+ "," + component.get('v.taskDashboardFilter') +"]}}";
        }
        else{
            filter = "{'datasets':{'"+workflowDataset+"':["+component.get('v.superVisorLoggedInKPI')+"]}}";
        }
        var dashboardFilterMap = component.get("v.taskdashboardFilterMap");
        var developerName = component.get("v.TaskGroupingDashboard");
        var config = {"developerName": developerName,
                      "showHeader": false,
                      "showTitle": false, 
                      "height": 1000};
        $A.createComponent("wave:waveDashboard", config, 
                           function(dashboard, status, err) {
                               if (status === "SUCCESS") {
                                   dashboard.set("v.rendered", true);
                                   dashboard.set("v.showHeader", false);
                                   dashboard.set("v.filter", filter);
                                   dashboard.set("v.title", false);
                                   component.set("v.body", dashboard);
                               } else if (status === "INCOMPLETE") {
                                   console.log("No response from server or client is offline.")
                               } else if (status === "ERROR") {
                                   console.log("Error: " + err);
                               }
                           }
                          );
        
        event.getSource().set("v.isLoading", true); 
        
        var mapToSendFilter = {};
        for(var i=0; i<dashboardFilterMap.length; i++){
            mapToSendFilter[dashboardFilterMap[i].label] = dashboardFilterMap[i].fieldName;
        }
        
        var actionTask = component.get("c.getTaskList");
        actionTask.setParams({
            'taskTab' : 'task',
            'dashboardFilter' : mapToSendFilter
        });
        
        actionTask.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var dataList = [];
                var taskList = response.getReturnValue();
                
                var developerName = component.get("v.Task_Assigned_Dashboard");
                var config = {"developerName": developerName,
                              "showHeader": false,
                              "showTitle": false, 
                              "height": 400};
                $A.createComponent("wave:waveDashboard", config, 
                                    function(dashboard, status, err) {
                                        if (status === "SUCCESS") {
                                            dashboard.set("v.rendered", true);
                                            dashboard.set("v.showHeader", false);
                                            dashboard.set("v.filter", filter);
                                            dashboard.set("v.title", false);
                                            component.set("v.taskbody", dashboard);
                                        } else if (status === "INCOMPLETE") {
                                            console.log("No response from server or client is offline.")
                                        } else if (status === "ERROR") {
                                            console.log("Error: " + err);
                                        }
                                    }
                                );

                component.set("v.taskList", dataList);
                component.set("v.originalTaskList", taskList);
                component.set("v.taskTotalCount",taskList.length);
                
                for(var idx=0; idx<taskList.length && dataList.length < 50; idx++){
                    dataList.push(taskList[idx]);
                }
                component.set("v.taskList", dataList);
                
                component.set('v.taskColumns', [
                    {label: 'Case Number', fieldName: 'CaseNumber', type: 'text',initialWidth: 120},
                    {label: 'Task Age', fieldName: 'TaskAge', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Assigned To', fieldName: 'AssignedTo', type: 'text',initialWidth: 120},
                    {label: 'Case SLA Date', fieldName: 'CaseSLADate', type: 'Date',initialWidth: 120, sortable: true},
                    {label: 'Due Date/Time', fieldName: 'DueDate', type: 'Date',initialWidth: 120, sortable: true},
                    {label: 'Process', fieldName: 'Process', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Subject', fieldName: 'Subject', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Attempt', fieldName: 'Attempt', type: 'integer',initialWidth: 120},
                    {label: 'Case Type', fieldName: 'CaseType', type: 'text',initialWidth: 120},
                    {label: 'Case SubType', fieldName: 'CaseSubType', type: 'text',initialWidth: 120},
                    {label: 'Case Service Date', fieldName: 'CaseServiceDate', type: 'date',initialWidth: 120, sortable: true},
                    {label: 'Client Name', fieldName: 'ClientName', type: 'text',initialWidth: 120},
                    {label: 'Client Code', fieldName: 'ClientCode', type: 'text',initialWidth: 120},
                    {label: 'Vendor Name', fieldName: 'VendorName', type: 'text',initialWidth: 120},
                    {label: 'Parent Vendor', fieldName: 'ParentVendor', type: 'text',initialWidth: 120},
                    {label: 'Location', fieldName: 'Location', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Location Address', fieldName: 'LocationAddress', type: 'text',initialWidth: 120},
                    {label: 'Location City', fieldName: 'LocationCity', type: 'text',initialWidth: 120},
                    {label: 'Location State', fieldName: 'LocationState', type: 'text',initialWidth: 120},
                    {label: 'Location Zip Code', fieldName: 'LocationZipCode', type: 'text',initialWidth: 120},
                    {label: 'Asset Name', fieldName: 'AssetName', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Equipment Size', fieldName: 'EquipmentSize', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Material Type', fieldName: 'MaterialType', type: 'text',initialWidth: 120, sortable: true}
                ]);
                event.getSource().set("v.isLoading", false); 
            }
        });
        $A.enqueueAction(actionTask);
    },

    caseDashboard : function(component, event, helper) {
        //component.set("v.enableInfiniteLoading", true);

        var caseDataset = $A.get("$Label.c.CaseDataset");
        var actionTask = component.get("c.getCaseList");
        
        actionTask.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseList = response.getReturnValue();
                var dataList = [];

                component.set("v.originalCaseList", caseList);
                component.set("v.caseTotalCount", caseList.length);
                for(var idx=0; idx<caseList.length && dataList.length < 50; idx++){
                    dataList.push(caseList[idx]);
                }
                component.set("v.caseList", dataList);
                component.set('v.caseColumns', [
                    {label: 'Case Number', fieldName: 'CaseNumber', type: 'text',initialWidth: 120},
                    {label: 'Case Owner', fieldName: 'CaseOwner', type: 'text',initialWidth: 120},
                    {label: 'Case SLA Date', fieldName: 'CaseSLADate', type: 'Date',initialWidth: 120, sortable: true},
                    {label: 'Case Type', fieldName: 'CaseType', type: 'text',initialWidth: 120},
                    {label: 'Case SubType', fieldName: 'CaseSubType', type: 'text',initialWidth: 120},
                    {label: 'Case Service Date', fieldName: 'CaseServiceDate', type: 'date',initialWidth: 120, sortable: true},
                    {label: 'Client Name', fieldName: 'ClientName', type: 'text',initialWidth: 120},
                    {label: 'Client Code', fieldName: 'ClientCode', type: 'text',initialWidth: 120},
                    {label: 'Location', fieldName: 'Location', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Location Address', fieldName: 'LocationAddress', type: 'text',initialWidth: 120},
                    {label: 'Location City', fieldName: 'LocationCity', type: 'text',initialWidth: 120},
                    {label: 'Location State', fieldName: 'LocationState', type: 'text',initialWidth: 120},
                    {label: 'Location Zip Code', fieldName: 'LocationZipCode', type: 'text',initialWidth: 120},
                    {label: 'Asset Name', fieldName: 'AssetName', type: 'text',initialWidth: 120, sortable: true},
                    {label: 'Equipment Size', fieldName: 'EquipmentSize', type: 'text',initialWidth: 120 , sortable: true},
                    {label: 'Material Type', fieldName: 'MaterialType', type: 'text',initialWidth: 120 , sortable: true}
                ]);
                event.getSource().set("v.isLoading", false); 
            }
        });
        $A.enqueueAction(actionTask);
    },

    workflowTaskSelected : function(component, event,helper) {
        var newSelectedRows = event.getParam('selectedRows');
        var selectedRows = [];
        if(newSelectedRows != null){
            for(var i=0;i<newSelectedRows.length;i++){
                selectedRows.push(newSelectedRows[i].TaskId);
            }
        }
        component.set("v.workflowTaskUpdateList",selectedRows);
        component.set("v.workflowSelectedCount",newSelectedRows.length);
    },
    
    taskSelected : function(component, event,helper) {
        var newSelectedRows = event.getParam('selectedRows');
        var selectedRows = [];
        if(newSelectedRows != null){
            for(var i=0;i<newSelectedRows.length;i++){
                selectedRows.push(newSelectedRows[i].TaskId);
            }
        }
        component.set("v.taskUpdateList",selectedRows);
        component.set("v.taskSelectedCount",newSelectedRows.length);
    },
    
    caseSelected : function(component, event,helper) {
        var newSelectedRows = event.getParam('selectedRows');
        var selectedRows = [];
        if(newSelectedRows != null){
            for(var i=0;i<newSelectedRows.length;i++){
                selectedRows.push(newSelectedRows[i].CaseId);
            }
        }
        component.set("v.caseUpdateList",selectedRows);
        component.set("v.caseSelectedCount",newSelectedRows.length);
    },
    
    ticketSelected : function(component, event,helper) {
        var newSelectedRows = event.getParam('selectedRows');
        var selectedRows = [];
        if(newSelectedRows != null){
            for(var i=0;i<newSelectedRows.length;i++){
                selectedRows.push({key:newSelectedRows[i].CaseId, value: newSelectedRows[i].TeamQueue});
            }
        }
        component.set("v.ticketUpdateMap",selectedRows);
        component.set("v.ticketSelectedCount",newSelectedRows.length);
    },
    
    workflowTaskUpdate : function(component, event,helper) {
        var act = component.get("c.updateTheObjectList");
        
        act.setParams({
            'updateItemList' : component.get("v.workflowTaskUpdateList"),
            'dueDate' : component.find("today").get("v.value"),
            'prioritySelected' : component.get("v.selectedTaskPriority"),
            'primaryTab' : 'task',
            'selectedUser' : component.get("v.selectedCSRUser"),
            'taskComment' : component.get("v.taskComment")
        });
        
        act.setCallback(this,function(a){
            var state = a.getState();
            var response = a.getReturnValue();
            if (state === "SUCCESS") {
                var workflowList = component.get("v.originalWorkflowTaskList");
                var dataList = [];
                var workflowListLength = workflowList.length;
                for(var i=0;i<workflowListLength;i++){
                    for(var j=0;j<component.get("v.workflowTaskUpdateList").length;j++){
                        if(workflowList[i].TaskId == component.get("v.workflowTaskUpdateList")[j]){
                            workflowList.splice(i,1);
                            workflowListLength = workflowListLength - 1;
                        }    
                    }
                }
                
                component.set("v.originalWorkflowTaskList",workflowList);
                component.set("v.workflowTotalCount",workflowListLength);
                
                for(var idx=0; idx<workflowListLength && dataList.length < component.get("v.workflowCount"); idx++){
                    dataList.push(workflowList[idx]);
                }
                component.set("v.workflowTaskList",dataList);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The records has been updated successfully."
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response
                });
                toastEvent.fire();
            }
        }); 
        
        $A.enqueueAction(act);
    },
    
    taskUpdate : function(component, event,helper) {
        var act = component.get("c.updateTheObjectList");
        
        act.setParams({
            'updateItemList' : component.get("v.taskUpdateList"),
            'dueDate' : component.find("today").get("v.value"),
            'prioritySelected' : component.get("v.selectedTaskPriority"),
            'primaryTab' : 'task',
            'selectedUser' : component.get("v.selectedCSRUser"),
            'taskComment' : component.get("v.taskComment")
        });
        
        act.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The records has been updated successfully."
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "There is a error."
                });
                toastEvent.fire();
            }
        }); 
        
        $A.enqueueAction(act);
    },
    
    caseUpdate : function(component, event,helper) {
        var act = component.get("c.updateTheObjectList");
        
        act.setParams({
            'updateItemList' : component.get("v.caseUpdateList"),
            'dueDate' : component.find("today").get("v.value"),
            'prioritySelected' : component.get("v.selectedTaskPriority"),
            'primaryTab' : 'case',
            'selectedUser' : component.get("v.selectedCSRUser"),
            'taskComment' : component.get("v.taskComment")
        });
        
        act.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var caseList = component.get("v.originalCaseList");
                var caseListLength = caseList.length;
                var dataList = [];
                
                for(var i=0;i<caseListLength;i++){
                    for(var j=0;j<component.get("v.caseUpdateList").length;j++){
                        if(caseList[i].CaseId == component.get("v.caseUpdateList")[j]){
                            caseList.splice(i,1);
                            caseListLength = caseListLength - 1;
                        }    
                    }
                }
                component.set("v.originalCaseList",caseList);
                component.set("v.caseTotalCount",caseListLength);
                
                for(var idx=0; idx<caseListLength && dataList.length < component.get("v.caseCount"); idx++){
                    dataList.push(caseList[idx]);
                }
                component.set("v.caseList",dataList);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The records has been updated successfully."
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "There is a error."
                });
                toastEvent.fire();
            }
        }); 
        
        $A.enqueueAction(act);
    },
    
    ticketUpdate : function(component, event,helper) {
        // Send Updated list of selected ticket.
        var updateItemList = component.get("v.ticketUpdateMap");
        var updateItemMap = {};
        for(var i=0; i<updateItemList.length; i++){
            updateItemMap[updateItemList[i].key] = updateItemList[i].value;
        }
		
        var act = component.get("c.updateTheTicketList");
        
        if(component.get("v.modalPopupHeaderName") != "Ticket Assignment Team" ){
            act.setParams({
                'updateItemMap' : updateItemMap,
                'dueDate' : component.find("today").get("v.value"),
                'teamName' : null,
                'teamQueue' : null,
                'prioritySelected' : component.get("v.selectedTaskPriority"),
                'primaryTab' : 'ticket',
                'selectedUser' : component.get("v.selectedCSRUser"),
                'taskComment' : component.get("v.taskComment")
            });            
        } 
        else{
			act.setParams({
                'updateItemMap' : updateItemMap,
                'dueDate' : component.find("today").get("v.value"),
                'teamName' : component.get("v.selectedTeamName"),
                'teamQueue' : component.get("v.selectedTeamQueue"),
                'prioritySelected' : component.get("v.selectedTaskPriority"),
                'primaryTab' : 'ticket',
                'selectedUser' : null,
                'taskComment' : component.get("v.taskComment")
            });            
        }
        
        act.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var ticketList = component.get("v.originalTicketList");
                var ticketListLength = ticketList.length;
                var dataList = [];
                
                for(var i=0;i<ticketListLength;i++){
                    for(var ticketId of component.get("v.ticketUpdateMap")){
                        if(ticketList[i].CaseId == ticketId.key){
                            ticketList.splice(i,1);
                            ticketListLength = ticketListLength - 1;
                        }    
                    }
                }
                component.set("v.originalTicketList",ticketList);
                component.set("v.ticketTotalCount",ticketListLength);
                
                for(var idx=0; idx<ticketListLength && dataList.length < component.get("v.ticketCount"); idx++){
                    dataList.push(ticketList[idx]);
                }
                component.set("v.ticketList",dataList);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The records has been updated successfully."
                });
                toastEvent.fire();
            } 
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "There is a error."
                });
                toastEvent.fire();
            }
        }); 
        
        $A.enqueueAction(act);
    },
    
    loadMoreWorkflowTableData : function(component, event, helper) {
        
        if(component.get("v.showTaskDashboard")){
            var dashboardFilterMap = component.get("v.taskdashboardFilterMap");
            var taskListSize = component.get("v.taskList").length;
            var dataList = [];
            if(!(component.get("v.taskCount") >= component.get("v.taskTotalCount"))){
                event.getSource().set("v.isLoading", true); 
                
                var originalTaskList = component.get("v.originalTaskList");
                component.set("v.taskCount",(taskListSize + 50));
                if(dashboardFilterMap.length > 0){
                    for(var idx=0; idx<originalTaskList.length; idx++){
                        for(var i=0; i<dashboardFilterMap.length; i++){
                            if((originalTaskList[idx].ClientName != undefined && originalTaskList[idx].ClientName == dashboardFilterMap[i].fieldName)||
                               (originalTaskList[idx].AssignedTo != undefined && originalTaskList[idx].AssignedTo == dashboardFilterMap[i].fieldName)||
                               (originalTaskList[idx].CaseSubType != undefined && originalTaskList[idx].CaseSubType == dashboardFilterMap[i].fieldName)||
                               (originalTaskList[idx].CaseType != undefined && originalTaskList[idx].CaseType == dashboardFilterMap[i].fieldName)||
                               (originalTaskList[idx].Location != undefined && originalTaskList[idx].Location == dashboardFilterMap[i].fieldName)||
                               (originalTaskList[idx].ParentVendor != undefined && originalTaskList[idx].ParentVendor == dashboardFilterMap[i].fieldName)||
                               (originalTaskList[idx].VendorName != undefined && originalTaskList[idx].VendorName == dashboardFilterMap[i].fieldName)){
                                dataList.push(originalTaskList[idx]);
                            }
                        }
                    }
                    component.set("v.taskList", dataList);
                    component.set("v.enableInfiniteLoading",false);
                }
                else{
                    for(var idx=0; idx<originalTaskList.length && dataList.length < (taskListSize + 50); idx++){
                        dataList.push(originalTaskList[idx]);
                    }
                    component.set("v.taskList", dataList);
                }
                event.getSource().set("v.isLoading", false); 
            }
            else{
                component.set("v.enableInfiniteLoading",false);
                event.getSource().set("v.isLoading", false);
            }
        }
        else {
            var dashboardFilterMap = component.get("v.workflowdashboardFilterMap");
            var taskListSize = component.get("v.workflowTaskList").length;
            var dataList = [];
            if(!(component.get("v.workflowCount") >= component.get("v.workflowTotalCount"))){
                event.getSource().set("v.isLoading", true); 
                
                var originalWorkflowTaskList = component.get("v.originalWorkflowTaskList");
                component.set("v.workflowCount",(taskListSize + 50));
                if(dashboardFilterMap.length > 0){
                    for(var idx=0; idx<originalWorkflowTaskList.length; idx++){
                        for(var i=0; i<dashboardFilterMap.length; i++){
                            if((originalWorkflowTaskList[idx].ClientName != undefined && originalWorkflowTaskList[idx].ClientName == dashboardFilterMap[i].fieldName)||
                               (originalWorkflowTaskList[idx].Process != undefined && originalWorkflowTaskList[idx].Process == dashboardFilterMap[i].fieldName)||
                               (originalWorkflowTaskList[idx].CaseSubType != undefined && originalWorkflowTaskList[idx].CaseSubType == dashboardFilterMap[i].fieldName)||
                               (originalWorkflowTaskList[idx].CaseType != undefined && originalWorkflowTaskList[idx].CaseType == dashboardFilterMap[i].fieldName)||
                               (originalWorkflowTaskList[idx].Location != undefined && originalWorkflowTaskList[idx].Location == dashboardFilterMap[i].fieldName)||
                               (originalWorkflowTaskList[idx].VendorName != undefined && originalWorkflowTaskList[idx].VendorName == dashboardFilterMap[i].fieldName)||
                               (originalWorkflowTaskList[idx].ParentVendor != undefined && originalWorkflowTaskList[idx].ParentVendor == dashboardFilterMap[i].fieldName)){
                                dataList.push(originalWorkflowTaskList[idx]);
                            }
                        }
                    }
                    component.set("v.workflowTaskList", dataList);
                    component.set("v.enableInfiniteLoading",false);
                }
                else{
                    for(var idx=0; idx<originalWorkflowTaskList.length && dataList.length < (taskListSize + 50); idx++){
                        dataList.push(originalWorkflowTaskList[idx]);
                    }
                    component.set("v.workflowTaskList", dataList);
                }
                event.getSource().set("v.isLoading", false); 
                
            }
            else{
                component.set("v.enableInfiniteLoading",false);
                event.getSource().set("v.isLoading", false);
            }
        }
        
    },
    
    loadMoreCaseTableData : function(component, event, helper) {
        if(!(component.get("v.caseCount") >= component.get("v.caseTotalCount"))){
            event.getSource().set("v.isLoading", true); 
            var caseListSize = component.get("v.caseList").length;
            var originalCaseList = component.get("v.originalCaseList");
            var dataList = [];
            
            component.set("v.caseCount", (caseListSize + 50));
            for(var idx=0; idx<originalCaseList.length && dataList.length < (caseListSize + 50); idx++){
                dataList.push(originalCaseList[idx]);
            }
            component.set("v.caseList", dataList);
            event.getSource().set("v.isLoading", false); 
        }
        else{
            component.set("v.enableInfiniteLoading",false);
            event.getSource().set("v.isLoading", false);
        }
    },
    
    loadMoreTicketTableData : function(component, event, helper) {
        var dashboardFilterMap = component.get("v.ticketdashboardFilterMap");
        var dataList = [];
        var originalTicketList = [];
        var ticketListSize = component.get("v.ticketList").length;
        if(!(component.get("v.ticketCount") >= component.get("v.ticketTotalCount"))){
            event.getSource().set("v.isLoading", true); 
            
            originalTicketList = component.get("v.originalTicketList");
            component.set("v.ticketCount",(ticketListSize + 50))
            if(dashboardFilterMap.length > 0){
                for(var idx=0; idx<originalTicketList.length; idx++){
                    for(var i=0; i<dashboardFilterMap.length; i++){
                        if((originalTicketList[idx].ClientName != undefined && originalTicketList[idx].ClientName == dashboardFilterMap[i].fieldName)||
                           (originalTicketList[idx].TeamQueue != undefined && originalTicketList[idx].TeamQueue == dashboardFilterMap[i].fieldName)||
                           (originalTicketList[idx].CaseType != undefined && originalTicketList[idx].CaseType == dashboardFilterMap[i].fieldName)||
                           (originalTicketList[idx].Location != undefined && originalTicketList[idx].Location == dashboardFilterMap[i].fieldName)||
                           (originalTicketList[idx].CaseSubType != undefined && originalTicketList[idx].CaseSubType == dashboardFilterMap[i].fieldName)||
                           (originalTicketList[idx].ParentVendor != undefined && originalTicketList[idx].ParentVendor == dashboardFilterMap[i].fieldName)||
                           (originalTicketList[idx].VendorName != undefined && originalTicketList[idx].VendorName == dashboardFilterMap[i].fieldName)){
                            dataList.push(originalTicketList[idx]);
                        }
                    }
                }
                component.set("v.ticketList", dataList);
                component.set("v.enableInfiniteLoading",false);
            }
            else{
                for(var idx=0; idx<originalTicketList.length && dataList.length < (ticketListSize + 50); idx++){
                    dataList.push(originalTicketList[idx]);
                }
                component.set("v.ticketList", dataList);
            }
            event.getSource().set("v.isLoading", false); 
        }
        else{
            component.set("v.enableInfiniteLoading",false);
            event.getSource().set("v.isLoading", false);
        }
    },
    
    workflowTaskClose : function(component, event, helper) {
        var actionCase = component.get("c.updateWorkflowTaskClose");
        actionCase.setParams({
            'updateItemList' : component.get("v.workflowTaskUpdateList")
        });
        
        actionCase.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var workflowList = component.get("v.originalWorkflowTaskList");
                var workflowListLength = workflowList.length;
                var dataList = [];
                for(var i=0;i<workflowListLength;i++){
                    for(var j=0;j<component.get("v.workflowTaskUpdateList").length;j++){
                        if(workflowList[i].TaskId == component.get("v.workflowTaskUpdateList")[j]){
                            workflowList.splice(i,1);
                            workflowListLength = workflowListLength - 1;
                        }    
                    }
                }
                component.set("v.workflowTaskList",workflowList);
                component.set("v.originalWorkflowTaskList",workflowList);
                
                for(var idx=0; idx<workflowListLength && dataList.length < component.get("v.workflowCount"); idx++){
                    dataList.push(workflowList[idx]);
                }
                component.set("v.workflowTaskList",dataList);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The records has been closed successfully."
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "There is a error."
                });
                toastEvent.fire();
            }
        }); 
        
        $A.enqueueAction(actionCase);
    },

    sortData: function (component, fieldName, sortDirection) {
        var data = [];

        if(component.get("v.showWorkflowTaskDashboard")){
			data = component.get("v.workflowTaskList");
		}
		else if(component.get("v.showTaskDashboard")){
			data = component.get("v.taskList");
        }
        else if(component.get("v.showCaseDashboard")){
			data = component.get("v.caseList");
        } 
        else if(component.get("v.showTicketDashboard")){
			data = component.get("v.ticketList");
        }
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        component.set("v.data", data);
        if(component.get("v.showWorkflowTaskDashboard")){
            component.set("v.workflowTaskList", data);
		}
		else if(component.get("v.showTaskDashboard")){
            component.set("v.taskList", data);
        }
        else if(component.get("v.showCaseDashboard")){
            component.set("v.caseList", data);
        }
        else if(component.get("v.showTicketDashboard")){
            component.set("v.ticketList", data);
        }
    },

    fetchPicklistValues: function(component,objDetails,controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap",StoreResponse);
                
                // create a empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                
                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for lightning:select
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                // set the ControllerField variable values to country(controller picklist field)
                component.set("v.listControllingValues", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
        
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ? function(x) {
                            return primer(x[field]);
                            }
                        : function(x) {
                        return x[field];
                        };

        return function (a, b) {
            var A = key(a) ? key(a).toLowerCase() : '';
            var B = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((A > B) - (B > A));
        };
    }
})