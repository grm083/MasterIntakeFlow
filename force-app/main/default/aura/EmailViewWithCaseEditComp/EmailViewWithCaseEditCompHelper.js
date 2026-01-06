({
	getCaseNumber : function(component, event, helper) {
		var action = component.get("c.getCaseNumberFromEmail");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp==='+JSON.stringify(resp));
            if(state == 'SUCCESS'){
                component.set('v.caseId',resp);
            }
        });
        $A.enqueueAction(action);
	}
})