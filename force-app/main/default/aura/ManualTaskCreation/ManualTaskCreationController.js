({
	closeModel: function (component, event, helper) {
		component.destroy();       
    },
    
    SaveReason: function (component, event, helper) {
        helper.invokeServiceIssue(component,event, helper);
    },
     handleReceiveMessage: function (component, event, helper) {
     }
})