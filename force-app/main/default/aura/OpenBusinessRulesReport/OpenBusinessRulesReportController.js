({
    init: function(component, event, helper) {
        
        const action = component.get("c.getReportId");
        action.setParams({ reportName: "All Business Rules by Customer"});

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const reportId = response.getReturnValue();
                const url = `/lightning/r/Report/${reportId}/view`;

                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": url
                });
                urlEvent.fire();
                
            }
        });

        $A.enqueueAction(action);
    }
})