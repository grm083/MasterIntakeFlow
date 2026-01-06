({
	init : function(component, event, helper) {
		var progressIndicator = component.find('progressIndicator');
        for (let step of component.get('v.stages')) {
            $A.createComponent(
                "lightning:progressStep",
                {
                    "aura:id": "step_" + step,
                    "label": step,
                    "value": step
                },
                function(newProgressStep, status, errorMessage) {
                    //Adds new steps to progress array
                    if (status === "SUCCESS") {
                        var body = progressIndicator.get("v.body");
                        body.push(newProgressStep);
                        progressIndicator.set("v.body",body);
                    }
                    else if (status === "INCOMPLETE") {
                        // Shows offline error
                        console.log("No response from server, or client is offline");
                    }
                        else if (status === "ERROR") {
                            // Show Error message
                            console.log("Error: " + errorMessage);
                        }
                    }
            );
        }
	}
})