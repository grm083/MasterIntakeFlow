({
	CopyEmail : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        var instance = component.get("c.copyEmailtoAnotherCase");
        instance.setParams({
            "sourceCaseId" : component.get("v.recordId"),            
            "TargetCaseNumber" : component.get("v.selectedLookUpRecord").CaseNumber            
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                 toastEvent.setParams({
                        "title": "Success!",
                        "message": $A.get("$Label.c.Case_Email_Copy") +' '+ component.get("v.selectedLookUpRecord").CaseNumber,
                        "type": "success"
                    });
                //$A.get('e.force:refreshView').fire();
            }
            else
            {
                toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue().message,
                        "type": "error"
                    });
            }
            
            toastEvent.fire();
            component.set("v.showBox",false);
        });
        $A.enqueueAction(instance);
    }
})