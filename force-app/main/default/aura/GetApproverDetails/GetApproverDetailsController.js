({
	doInit : function(component, event, helper) {
        var taskId = component.get("v.recordId");
        //var taskId = '00T0U00000EHqGQUA1';
        var action = component.get("c.getApprover");
        action.setParams({
            "taskId" : taskId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.serviceApproverlst", response.getReturnValue());//The attribute that you are iterating has to be set here
                
            }
        });
        $A.enqueueAction(action);
	}
})