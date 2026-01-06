({
    doInit : function(cmp, event, helper) {
        
	},
    createNote : function(cmp, event, helper) {
        //Changes related to SDT-42554
        //var utilityAPI = cmp.find("utilitybar");
        
        var href = window.location.href.toString().split(window.location.host)[1];
              
            var action = cmp.get("c.createAcornComment");
            action.setParams({ 
                comment : cmp.get("v.AcornComment"),
                caseId : cmp.get("v.recordId")
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
                                "message": "A new Acorn Comment has been created successfully.",
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
                    cmp.set("v.AcornComment", "");
                    //Changes related to SDT-42554
                    //utilityAPI.minimizeUtility();
                }
            });
            $A.enqueueAction(action);           
        }
   
})