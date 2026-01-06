({
    getCaseNumberHelper : function(component,event,helper){
       var action = component.get("c.getCaseNumber");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp==='+JSON.stringify(resp));
            if(state == 'SUCCESS'){
                component.set('v.caseNumber',resp);
            }
        });
        $A.enqueueAction(action);
    },
    showPopupHelper: function(component, componentId, className){
        var modal = component.find(componentId);
        $A.util.removeClass(modal, className + 'hide');
        $A.util.addClass(modal, className + 'open');
    },
     hidePopupHelper: function(component, componentId, className){
        var modal = component.find(componentId);
        $A.util.addClass(modal, className+'hide');
        $A.util.removeClass(modal, className+'open');
        component.set("v.body", "");
    },
    toggleAction : function(component, event, secId) {
        var renderComponent = component.get("v.renderComponent");
       // alert('renderComponent==='+renderComponent);
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        if(renderComponent == true || renderComponent == 'true'){
            component.set('v.renderComponent',false);
        }
        else{
            component.set('v.renderComponent',true);
        }
        
    }
})