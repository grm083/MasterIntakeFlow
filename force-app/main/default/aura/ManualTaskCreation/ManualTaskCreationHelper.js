({
	 invokeServiceIssue: function (component,event,helper) {
        var caseId = component.get("v.currentCaseID");
        var selValue = component.get("v.selectedValue");
        var action = component.get('c.updateServiceClassfication');
        action.setParams({
            "caseRecId": caseId,
            "caseReason":selValue
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('@@@'+state);
            if (state == "SUCCESS") {
		    var data = response.getReturnValue();
		   if(data == 'Success'){ 
                $A.get('e.force:refreshView').fire();
                component.destroy();
		   }
            }            
        });
          $A.enqueueAction(action);
     }			
})