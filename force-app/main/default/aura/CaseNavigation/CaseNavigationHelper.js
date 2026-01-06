({
	getCases : function(component, event, helper) {
        var instance = component.get("c.getRelatedCase");  
        instance.setParams({
            recordId : component.get("v.recordId")
        });
		instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var res = response.getReturnValue();
                component.set("v.caseLst", res);
            }
        });
        $A.enqueueAction(instance);
	},
    navigateToCaseDetail: function (component, event, helper) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": event.currentTarget.dataset.id,
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
      }
})