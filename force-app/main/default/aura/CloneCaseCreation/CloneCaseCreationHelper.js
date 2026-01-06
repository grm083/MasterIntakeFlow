({
    cloneCaseHelper : function(component, event, helper) {
        component.set("v.showPopup",false);
        var action = component.get("c.cloneCaseDetails");
        var parentCase = component.get("v.recordId");
        //alert("parentCase==="+parentCase);
        action.setParams({
            "referenceCase" : parentCase
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            
            var resp = response.getReturnValue();
          //  alert('state---'+state+'---resp---'+resp);
            if(state == 'SUCCESS'){
                component.set("v.childCase",resp);
                component.set("v.showPopup",true);
            }
        });
        $A.enqueueAction(action);
    },
    getEmailMessageId  : function(component, event, helper) {
        var action = component.get("c.getEmailListId");
        var recordId = component.get("v.recordId");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();            
            var resp = response.getReturnValue();
            //alert('state---'+state+'---resp---'+resp);
            if(state == 'SUCCESS'){
               component.set("v.emailMessageId",resp);
            }
        });
        $A.enqueueAction(action);
    }
})