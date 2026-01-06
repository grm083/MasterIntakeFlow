({
	callController : function(component, event, helper, methodName) {
        methodName.setParams({
            "caseId" : component.get("v.caseRecordId")
        });
        methodName.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                $A.get('e.force:refreshView').fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getReturnValue(),
                    "type": "error"
                });
                toastEvent.fire();
            }
            component.set("v.showButtons",false);
        });
            $A.enqueueAction(methodName);
    }
})