({
   init: function (cmp, event, helper) {
    helper.callRefresh(cmp, event, helper);   
    // cmp.set('v.columns', [
    //         { label: 'Action', initialWidth: 120, fieldName: 'Workflow_Action__c', type: 'text'},
    //         { label: 'User/Team', initialWidth: 120, fieldName: 'Workflow_TeamUser__c', type: 'text'},
    //         { label: 'Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
    //                                                                         day: 'numeric',  
    //                                                                         month: 'short',  
    //                                                                         year: 'numeric',  
    //                                                                         hour: '2-digit',  
    //                                                                         minute: '2-digit',  
    //                                                                         hour12: true}},
    //         { label: 'Comments', fieldName: 'Comment__c', type: 'text'},
    //         { label: 'Source', initialWidth: 120, fieldName: 'Communication_Log_Type_Name__c', type: 'text'} 
    //     ]);
    //     var action = cmp.get("c.getAcornComments");
    //     action.setParams({ 
    //         caseId : cmp.get("v.recordId")
    //     });
    //     action.setCallback(this, function(response){
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             cmp.set("v.notes", response.getReturnValue());
    //         }
    //         //event.getSource().set("v.isLoading", false);
    //     });
    //     $A.enqueueAction(action);
    },
    handleClick : function (cmp, event, helper) {
        var portal_link = cmp.get('v.url.Portal_Messages_URL__c');
        window.open(portal_link, '_blank');
    },
    getComment : function (cmp, event, helper) {
       try{
        var selectedRows = event.getParam('selectedRows');
        var commentId = selectedRows[0].Id;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": commentId
        });
        editRecordEvent.fire();
        }
        catch(e){
            console.log('error '+e);
        }

    },
    onTabClosed : function (cmp, event, helper) {
        var tabId = event.getParam('tabId');
        console.log("tabId " +tabId);
        helper.confirmExit(cmp, event, helper);
    },

    onTabFocus : function (cmp, event, helper) {
        var workspaceAPI = cmp.find("workspace");
        var focusedTabId = event.getParam('currentTabId');
        var prevTabId = event.getParam('previousTabId');
        
        helper.confirmExit(cmp, event, helper);
        
        workspaceAPI.getTabInfo({
                tabId : focusedTabId
            }).then(function(response) {
                if(response != null){
                    if(response.recordId.startsWith('500')) {
                        helper.callRefresh(cmp, event, helper);  
                        cmp.set("v.focusedTabIsCase",true);
                    }
                }
                else {
                    cmp.set("v.focusedTabIsCase",false);
                    helper.confirmExit(cmp, event, helper);
                }
            
            }).catch(function(error) {
                cmp.set("v.focusedTabIsCase",false);
            });       
    }
})