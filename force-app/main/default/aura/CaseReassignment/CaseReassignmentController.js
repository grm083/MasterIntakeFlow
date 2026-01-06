({
	doInit : function(component, event, helper) {
		
	},
    closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
	},
    handleSuccess : function(component, event, helper) {
		component.set("v.showForm",false);
        $A.get('e.force:refreshView').fire();
	}
})