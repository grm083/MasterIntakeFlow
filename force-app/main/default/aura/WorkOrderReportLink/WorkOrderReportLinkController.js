({
	handleOnClick : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getRecordDetails');
        action.setParams(
            {
                "recordId":recordId
            }
        );
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state:' + state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result:' + result);
                helper.gotoWOReport(component, event, helper, result);
            }
        });
        $A.enqueueAction(action);
	}
    
})