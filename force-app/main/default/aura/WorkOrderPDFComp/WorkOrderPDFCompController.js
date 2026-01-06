({
   doInit: function(component, event, helper) {         
        var recId = component.get("v.recordId");
        // Create the action
        var action = component.get("c.getPDF");
            action.setParams({recordId : recId});
            // Add callback behavior for when response is received
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oURL = component.find("oURL");
                var msg = 'Click here to download Work Order PDF';
                if(response.getReturnValue != null){
                    component.set("v.lstContentDoc", response.getReturnValue());
                    component.set("v.stopLoad", true);
                    document.getElementsByClassName("api_spinner")[0].style.display = 'none';
                    document.getElementsByClassName("success")[0].style.display = 'block';   
                }
                else{
                    document.getElementsByClassName("failed")[0].style.display = 'block';
                    document.getElementsByClassName("api_spinner")[0].style.display = 'none';
                }
            }
            else {
                console.log("Failed with state: " + state);
                document.getElementsByClassName("api_spinner")[0].style.display = 'none';
                document.getElementsByClassName("failed")[0].style.display = 'block';
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
   },
   getSelected : function(component,event,helper){
        // display modle and set seletedDocumentId attribute with selected record Id   
        component.set("v.hasModalOpen" , true);
        component.set("v.selectedDocumentId" , event.currentTarget.getAttribute("data-Id"));  
    },
    closeModel: function(component, event, helper) {
        // for Close Model, set the "hasModalOpen" attribute to "FALSE"  
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null); 
    },

 })