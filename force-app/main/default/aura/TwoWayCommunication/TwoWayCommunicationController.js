({
    doInit : function(component, event, helper) {
        var emptyString = '';
        if(component.get("v.caseId") === null || component.get("v.caseId") === emptyString) {
            let ref = component.get('v.pageReference');
            let caseId = ref.state.c__caseId;
            component.set('v.caseId', caseId);
        }

        if(component.get("v.caseOrigin") === null || component.get("v.caseOrigin") === emptyString) {
            let ref = component.get('v.pageReference');
            let caseOrigin = ref.state.c__caseOrigin;
            component.set('v.caseOrigin', caseOrigin);
        }
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {}).then(function(subtabId) {
            // the subtab has been created, use the Id to set the label
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "Two Way Communication"
            });
            workspaceAPI.setTabIcon({
                tabId: subtabId,
                icon: "standard:merge",
                iconAlt: "Two Way Communication"
            });
            
            workspaceAPI.focusTab({tabId : subtabId});
        }).catch(function(error) {
            console.log(error);
        });
    }, 
    
    refreshView: function(component, event) {
        console.log('in refreshview'); 
        // refresh the view
        $A.get('e.force:refreshView').fire();
    },
    

    createviewComments: function(component,event,helper){
        var viewCommTab = component.find('viewcommentstab');
        $A.createComponent("c:viewComments", {
                    "aura:id": "viewcomments_comp",
                    "recordId": component.get("v.caseId")
                }, function (newContent, status, error) {
                    if (status === "SUCCESS") {
                        viewCommTab.set('v.body', newContent);
                    } else {
                        throw new Error(error);
                    }
                })

    },
    //this function is for refreshing the datatable whenever a new comment is added.
    // refreshtable: function(component, event, helper){
    //     console.log('getevetn'+event.getSource());
    //     console.log('table refreshing')
    //     //var selTabId = component.get("v.selTabId");
    //     //console.log(selTabId);
    //     // if(event.getSource().get("v.id") === "View"){
    //          var action = component.get('c.refreshView');
    //          $A.enqueueAction(action);
    //          component.find("viewcomments_comp").refreshDatatable();
    //         //var methodName = 'refreshDatatable';
    //         //var childCmp = component.find('viewcomments_comp');
    //         //childCmp[methodName]();


    //      }
        
    //}
   
        
   
})