({
	showComments : function (cmp, event, helper) {
    	var evt = $A.get("e.force:navigateToComponent");
    	evt.setParams({
        componentDef : "c:PortalMessages",
        componentAttributes: {
            recordId : cmp.get("v.recordId"),
            refresh : false
        }
        
    });
    evt.fire();
    }
})