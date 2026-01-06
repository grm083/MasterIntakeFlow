({
	doInit : function(component, event, helper) {        
        //location.reload(true);  
       // $A.get("e.force:closeQuickAction").fire();
      // Changes related to SDT-33633
        var showQuoteCreatePage;
        var action = component.get('c.returnButtonAccess');
        // var createRecordEvent = $A.get("e.force:createRecord");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                this.showQuoteCreatePage = response.getReturnValue();  
                if(this.showQuoteCreatePage){
        var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : "/lightning/n/Pricing"
                });
                urlEvent.fire(); 
        
        //Close Current Tab
         var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
        
        workspaceAPI.openTab({
            url: '/lightning/n/Pricing',
        }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
       })
        .catch(function(error) {
            console.log(error);
        });
}
                else{
                    component.set("v.noAccess",true);
                }
            }
        });
        $A.enqueueAction(action);
        
    }
    
})