({
	getPricingResponseStatus : function(component) {
		var quoteID = component.get("v.recordId"); 
        component.set("v.loadingSpinner", true);     
        var action = component.get('c.getPricingResponseStatus');
        action.setParams({"quoteID" : quoteID});
        action.setCallback(this, function(response) {
        var state = response.getState();
            
            if(state === "SUCCESS"){
                
                var wrapper = response.getReturnValue();
                console.log('Wrapper-->'+ wrapper);
                if (wrapper) {
                    component.set('v.QuotePringRequestList', wrapper);
                    component.set('v.IsMultiVendorPriceOn', true);  
                        
                }
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
    },
})