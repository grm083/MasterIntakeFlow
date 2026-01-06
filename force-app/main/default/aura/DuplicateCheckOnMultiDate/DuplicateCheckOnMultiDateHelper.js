({
	callApex : function(component, event, helper) {
        var selectedrows = component.find('table').getSelectedRows();
		var action = component.get("c.updateClosehandler"); 
        action.setParams({
                'childCases' : component.get("v.caseList"),
                'dupWorkOrders' : component.get("v.workorders"),
                'selectedList' : selectedrows
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){
                //alert('success');
                component.set("v.showModal",false);
                $A.get("e.force:refreshView").fire();
            }
        });
        $A.enqueueAction(action); 
	}
})