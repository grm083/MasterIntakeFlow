({
	fetchQuoteLineChanges : function(component) {
		var action = component.get("c.getQuoteLineHistories");
       action.setParams({ quoteId : component.get("v.recordId") });
       action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               component.set("v.quoteLineHistories", response.getReturnValue());
                component.set("v.hasError", false);
           }
           else{
               component.set("v.hasError", true);
               component.set("v.errorMessage", "An error occurred while fetching quote line changes.");
           }
          component.set("v.isLoading",false);
       });
       $A.enqueueAction(action);
	}
})