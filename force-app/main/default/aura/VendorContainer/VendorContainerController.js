({
    doInit : function(component, event, helper) {
        var action = component.get("c.getIsWorkOrderCreated");
        action.setParams({
            'caseRecId': component.get("v.recordId")
		});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                //alert(storeResponse);
                if (storeResponse == 'New'){
                  //  alert('abc');
                    component.set("v.statusData", true);
                  //alert(component.get("v.statusData"));
                } 
                else{
                    //alert('def');
                    component.set("v.statusData", false);
                    //alert(component.get("v.statusData"));
                }
			}else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }, 
    closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
	},
    vendorSearch : function(component, event, helper) {
        component.set("v.showVendorSearch",true);
        var data=component.get("v.statusData");
        //alert(data);
        component.set("v.statusData",data);
        //alert(component.get("v.statusData"));
    },
    navigate : function(component, event, helper) {
        component.set("v.showForm",false);
       
    }
})