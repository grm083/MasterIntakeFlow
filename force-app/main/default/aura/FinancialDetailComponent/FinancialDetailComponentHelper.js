({
    showErrorForEmptyCC : function(component, event) {
        var errorToast = $A.get('e.force:showToast');
        errorToast.setParams({
            'title': 'Error',
            'message': 'Fill the Company Category Details.',
            'type': 'error'
        });
        errorToast.fire();
    },
    
    getReqBRCC : function(component,event,helper){
        //changes done for SDT-31830
        var action = component.get("c.getReqBusinessRulesCC");
        action.setParams({
          quoteId :component.get("v.productWrapper.quoteID")
        });
            action.setCallback(this, function(response) {
                let state = response.getState();
                console.log(state);
                if(state === "SUCCESS") {
                    console.log('isReqQuoteCC : '+response.getReturnValue());
                    component.set("v.isReqQuoteCC", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
          //SDT-31830 changes end
    }
})