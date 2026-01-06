({
	callApex : function(component, event, helper) {
		var action = component.get('c.getRecordTypeId');
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.recordTypeId",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    resetCloseReason : function(component, event, helper) {
        component.find('closereason').set('v.value', "");
    }
})