({
    getContactRole : function(component,event,helper) {
        var action = component.get("c.retrieveContact");
        action.setParams({
            "recId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp==='+JSON.stringify(JSON.parse(resp)));
            
            if(state == 'SUCCESS'){
                var opts = [];
                if(resp != null && resp != '' && resp != undefined){
                    opts = JSON.parse(resp);
                    component.set('v.levelList',opts);
                    component.set("v.showError",false);
                }
                else{
                     component.set("v.showError",true);
                }
                //console.log('email message ==='+JSON.stringify(component.get("v.emailMessageList")));
            }
        });
        $A.enqueueAction(action);
    }
})