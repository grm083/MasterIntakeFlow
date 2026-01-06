({
	doInit : function(component, event, helper) {
        helper.updateTask(component,event, helper);
        component.set("v.loadingSpinner", true);
                setTimeout(function(){
            component.set("v.loadingSpinner", false);
                }, 6000);
    }
    
})