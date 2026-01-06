({
    sendComment : function(component, event, helper) {
        
        var commentValue = component.get("v.Comment");
        
        if(commentValue !== null && commentValue !== "") {
            component.set("v.IsSpinner" , true);
            var action = component.get("c.createComment");
			//Changes related to SDT-31863
            action.setParams({ 
                commentBody : component.get("v.Comment"),
                caseId : component.get("v.recordId"),
                values : component.get("v.typedValueList")
            });
            //console.log('test');
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseValue = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    
                    if(responseValue.problem === undefined) {
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Successfully created",
                            "type": "success"
                        });
                       // console.log("$$$Return from the TwoWayServiceClass -->>" + responseMessage);
                    //    var action = component.get('c.fireComponentEvent');
                    //    $A.enqueueAction(action);
                        //   window.location.reload();
                        //   console.log('isrefreshhapp')
                        component.set("v.IsSpinner" , false);
                    }
                    else {
                        var responseMessage = responseValue.problem.errors[0].message;
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": responseMessage,
                            "type": "error"
                        });
                        component.set("v.IsSpinner" , false);
                    }
                    toastEvent.fire();
                    //console.log(component.get("v.Comment"));
                    //console.log(responseValue);
                    
                    component.set("v.Comment", "");
                }
                else {
                    const TwoWayAccessErrorMessage = $A.get("$Label.c.TwoWayAccessErrorMessage");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": TwoWayAccessErrorMessage,
                        "type": "error"
                    });
                    toastEvent.fire();
                    component.set("v.IsSpinner" , false);
                }
            });
            
            $A.enqueueAction(action);  
            
        }
        
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Field cannot be blank",
                "type": "error"
            });
            toastEvent.fire();
        }
        
    },
    
    
    validateInput : function(component, event, helper){
        var TwowayCommCharslimit = $A.get("$Label.c.TwowayCommCharslimit");
        var parsedCharlimit = parseInt(TwowayCommCharslimit);
        const inputField = event.getSource();
         var inputvalue= event.getSource().get("v.value");
         console.log(inputvalue);
         if(inputvalue.length>parsedCharlimit){
            inputField.set("v.value", inputvalue.substr(0,parsedCharlimit)); 
         }
         inputvalue = inputvalue; 
         if(inputvalue.length>=parsedCharlimit){
            inputField.setCustomValidity(`* Input Text cannot exceed ${parsedCharlimit} characters.`);
         }else {
            inputField.setCustomValidity('');
            
        }
        inputField.reportValidity();
    },
    // fireComponentEvent: function(component,event,helper){
    //     console.log('in firecomponenent evnt')
    //     var componentEvent = cmp.getEvent("cmpEvent");
    //     componentEvent.fire();
    // }
	//changes related to SDT - 31863
	getEmailFromInput : function(component, event, helper){
		component.set("v.typedValueList",event.getParam('typedValue'));
	}
		
})