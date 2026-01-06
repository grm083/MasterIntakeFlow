({
	getSubject : function(component, event, helper) {
		var action = component.get("c.getEmailSubject");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp==='+JSON.stringify(JSON.parse(resp)));
           
            if(state == 'SUCCESS'){
                var opts = [];
                opts = JSON.parse(resp);
                component.set('v.emailMessageList',opts);
               
                //console.log('email message ==='+JSON.stringify(component.get("v.emailMessageList")));
            }
        });
        $A.enqueueAction(action);
	}
})