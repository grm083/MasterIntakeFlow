({
	doInit : function(component, event, helper) {
        var taskId = component.get("v.recordId");
        var action = component.get("c.getcaseId");
        action.setParams({
            "taskId" : taskId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('REsult'+response.getReturnValue());
                component.set("v.caseId", response.getReturnValue());
                component.set("v.invoke", true);
                
                
                
            }
        });
        $A.enqueueAction(action);
	}
})