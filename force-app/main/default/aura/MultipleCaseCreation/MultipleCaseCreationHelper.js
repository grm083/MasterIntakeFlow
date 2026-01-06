({
    createMultipleCases : function(component, event, helper) {
        
        var recordTypeLabel = component.find("selectid").get("v.value");        
        var action = component.get("c.multipleCasesInvoke");  
        
        action.setParams({
            'selectedDueDateStr' : component.get("v.selectedDate"),
            'selectedRecType' : recordTypeLabel
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(' response ' + response.getState());
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                alert(' Case Id ' + storeResponse);
				/*var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                   "recordId": storeResponse,
                   "isredirect": "true"
                });
                urlEvent.fire();*/               
            }                       
        });
        $A.enqueueAction(action);        
    },
    
    callRecType : function(component, event, helper) {
      var action = component.get("c.fetchCaseRecordTypeValues");
      action.setCallback(this, function(response) {
         component.set("v.lstOfRecordType", response.getReturnValue());
      });
      $A.enqueueAction(action);
   }
})