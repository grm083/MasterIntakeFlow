({        
    doInit: function(component, event, helper) {
    	var action = component.get("c.getRedNotes");
        action.setParams({
            componentRecordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            component.set("v.cval", response.getReturnValue());
        });
        $A.enqueueAction(action);
	},
    init: function(component, event, helper) {
        var action = component.get("c.getRedNotesExternal");
        action.setParams({
            componentRecordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            component.set("v.cval", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    waiting: function(component, event, helper) {
 	 	component.set("v.HideSpinner", true);
 	},
 	doneWaiting: function(component, event, helper) {
  		component.set("v.HideSpinner", false);
 	}
})