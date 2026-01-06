({
    doInit : function(component, event, helper){
        component.set("v.showSpinner",true);
        var action = component.get("c.getParentQuote");
        action.setParams({ parentQuoteLineId : component.get("v.parentQuoteLineId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()==>'+JSON.stringify(response.getReturnValue()));
                component.set("v.supplement", response.getReturnValue());
                component.set("v.showSpinner",false);
            }
            else {
                console.log("Failed with state: " + state);
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    updateQLines : function(component, event, helper){
        component.set("v.showSpinner",true);
        let supp = component.get("v.supplement");
        var action = component.get("c.updateQuoteLines");
        action.setParams({ sWrapJson : JSON.stringify(supp) });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()==>'+JSON.stringify(response.getReturnValue()));
                var resp = response.getReturnValue();
                if(resp==='SUCCESS'){
                    helper.showToast('Success', 'Sucesfully updated', 'success' );
                    component.set("v.showSupplementModal", false);
                }
                else{
                    helper.showToast('Error', resp, 'error' );
                }
                component.set("v.showSpinner",false);
            }
            else {
                console.log("Failed with state: " + state);
                component.set("v.showSpinner",false);
            }
        });
            $A.enqueueAction(action);
        },
    assignDestructionDisposalType : function(component, event, helper) {
        let changeValue = event.getParam("value");
        console.log('changeValue==>'+changeValue);
        let supplement = component.get("v.supplement");
        console.log('supplemen==>'+JSON.stringify(supplement));
    },
    cancelSupplement : function(component){
        component.set("v.showSupplementModal", false);
    }
})