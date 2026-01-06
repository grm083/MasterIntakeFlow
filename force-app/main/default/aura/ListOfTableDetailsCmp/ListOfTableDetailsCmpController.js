({
    doInit : function(component, event, helper) {
        component.set('v.isRowSelected',"true");
        helper.Init(component, event, helper,"");
    },
    
    parentPress : function(component, event, helper) {
        
        var callChildDashboard = component.find("dashboardChild");
        var selectedRows = [];
        if(callChildDashboard["0"] == undefined){
            component.set('v.isRowSelected',callChildDashboard.get("v.isRowSelected"));
            component.set('v.selectedRows',callChildDashboard.get("v.selectedRows"));
        }
        else{
            for(var i=0;i<callChildDashboard.length;i++){
                if(callChildDashboard[i].get("v.selectedRows") != undefined && 
                   callChildDashboard[i].get("v.selectedRows").length > 0){
                    for(var key=0;key<callChildDashboard[i].get("v.selectedRows").length;key++){
                        selectedRows.push(callChildDashboard[i].get("v.selectedRows")[key]); 
                    }
                }
            } 
        }
        if(selectedRows.length > 0){
            component.set('v.isRowSelected',false);
        }
        else{
            component.set('v.isRowSelected',true);
        }
        component.set('v.selectedRows',selectedRows);
        
    },
    
    saveUpdatedTasks : function(component, event, helper) {
        
        var selectedTasks = component.get("v.selectedRows");
        var selectedRowMap = [];
        
        for(var key in selectedTasks){
            if(selectedTasks[key].acc.Outcome == '--- None ---'){
                selectedTasks[key].acc.Outcome = '';
            }
            delete selectedTasks[key].acc.DueDateTime;
            delete selectedTasks[key].isChecked;
            selectedRowMap.push(selectedTasks[key].acc);
        }
        
        var act = component.get("c.updateSelectedTasks");
        act.setParams(
            {
                "taskList":selectedRowMap
            }
        );
        
        act.setCallback(this,function(a){
            var state = a.getState();
            var response = a.getReturnValue();
            if(state === "SUCCESS"){
                if (response == 'Records Updated') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been updated successfully.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    
                    location.reload(true);
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "No record selected.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            }
            else 
            {
                var errors = a.getError(); 
                var length = errors.length;
                var ErrorMessage = errors[0].message;
                var array = [];
                array = ErrorMessage.split(',');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": array[1],
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(act);
        
    },
    
    userPress : function(component, event, helper) {
        
        var callUserModal = component.find("customLookup");
        component.set('v.selectedLookUpRecord',callUserModal.get("v.selectedRecord"));
        component.set('v.showHide',callUserModal.get("v.showHide"));
        
        helper.userPressHelper(component, event, helper);
        //var callChildDashboard = component.find("dashboardChild");
        //callChildDashboard.init();
        var appEvent = $A.get("e.c:DashboardDatatableRefreshEvent");
        appEvent.setParams({
            "UserDropdownValue" : component.get("v.selectedUserView") ,
            "AccountName" :  'Reload' ,
            "TaskDropdownValue" : component.get("v.taskType") 
        });
        appEvent.fire();
    },
    
    userPressfromLookup : function(component, event, helper) {
        
        var callUserModal = component.find("customLookup");
        component.set('v.selectedLookUpRecord',callUserModal.get("v.selectedRecord"));
        component.set('v.showHide',callUserModal.get("v.showHide"));
        
        helper.userPressHelper(component, event, helper);
        //var callChildDashboard = component.find("dashboardChild");
        //callChildDashboard.init();
        
    },
    
    reassignButtonClick : function(component, event, helper) {
        component.set('v.showHide', true); 
        component.get('v.selectedRows');
    },
    
    closeModel: function(component, event, helper) {
        component.set('v.showHide', false);
    },
    
    handleComponentEvent : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var message = params.selectedAccountName;
            
            helper.Init(component, event, helper,message);
        }
    },
    previous : function(component, event,helper){
        helper.previous(component, event);
    },
    next : function(component, event,helper){
        helper.next(component, event);
    }  
})