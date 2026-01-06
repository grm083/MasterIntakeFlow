({
    doInit : function(component, event, helper) {
        helper.callApex(component, event, helper); 
        helper.resetCloseReason(component, event, helper);
	},
   
    closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
	},
    
    
    
    handleSuccess : function(component, event, helper) {
        component.set("v.showForm",false);
        var addValue = ' ' ;
        if(component.get("v.showAdditionalfield")){
           addValue = component.find('field').get('v.value');
        }
        var action = component.get("c.createAcornComment");
            action.setParams({ 
                comment : component.find('closereason').get('v.value') + ' ' + addValue,
                caseId : component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    // to do: refresh grid component
                    var resp = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    if (typeof(toastEvent) != 'undefined') {
                        if (resp == 'ok') {
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "A new Comment has been added successfully.",
                                "type": "success"
                            }); 
                        } else {
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": resp,
                                "type" : "error"
                            });
                        }
                        toastEvent.fire(); 
                    }
                }
            });
            $A.enqueueAction(action); 
        $A.get('e.force:refreshView').fire();
	},
    
    hideUnhideAddField : function(component, event, helper) {
    
        if ( typeof(component.get("v.closecaseReason")) !== "undefined" && component.get("v.closecaseReason") !== null && component.get("v.closecaseReason") !== ''){
            if(component.get("v.closecaseReason") == 'No Action Needed' || component.get("v.closecaseReason") == 'Duplicate' || component.get("v.closecaseReason") == 'Call Issues'){
                component.set("v.showAdditionalfield",true);
            }else{
                 component.set("v.showAdditionalfield",false);
            }
            
        }else{
             component.set("v.showAdditionalfield",false);
        }
}
})