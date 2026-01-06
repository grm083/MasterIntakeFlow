({
	doInit : function(component, event, helper) {          
        //get case highlight panel data
       // $A.get("e.force:closeQuickAction").fire();
        helper.getPricingResponseStatus(component);
    },
    navigateTosObject : function(component, event, helper) {
        var recordId = event.currentTarget.dataset.id;
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        sObectEvent.fire();
    },
})