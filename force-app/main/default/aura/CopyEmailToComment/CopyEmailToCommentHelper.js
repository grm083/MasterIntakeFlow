({
	getEmail : function(component, event, helper) {
        component.set("v.Message",false);
		var action = component.get("c.getCopyEmailList");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                if(!$A.util.isEmpty(response.getReturnValue()) && !$A.util.isUndefined(response.getReturnValue())){
                    var resp = JSON.parse(response.getReturnValue());
                    console.log('$$$$$'+resp);
                    component.set('v.emailMessageList',resp);
                }
                else{
                    component.set("v.Message",true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})