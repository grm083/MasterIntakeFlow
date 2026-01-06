({
	getCaseDetails : function(component) {
        var caseId = component.get("v.recordId");
		var action = component.get('c.getCaseDetails');
        action.setParams({"caseId" : caseId});
        action.setCallback(this, function(response) {
                var data = response.getReturnValue(); 
                component.set('v.CaseDetails',data);
                });
            $A.enqueueAction(action);
	},
})