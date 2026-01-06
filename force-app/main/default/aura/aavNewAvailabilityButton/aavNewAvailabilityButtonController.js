({
	doInit : function(component) {        
        let urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : "/lightning/n/Asset_Availability"
                });
        urlEvent.fire(); 

        //Close Current Tab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo()
        .then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        //
        workspaceAPI.openTab({
            url: '/lightning/n/Asset_Availability',
        }).then(function(response) {
            workspaceAPI.focusTab({tabId : response});
        })
            .catch(function(error) {
                console.log(error);
        });
    }

    
})