({
    
    doInit: function(component, event, helper) {
        var action = component.get('c.returnButtonAccess');
        var createRecordEvent = $A.get("e.force:createRecord");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var showQuoteCreatePage = response.getReturnValue();
                if(showQuoteCreatePage){
                    createRecordEvent.setParams({
                        "entityApiName": "SBQQ__Quote__c"
                    });
                    createRecordEvent.fire(); 
                }
                else{
                    //var toastEvent = $A.get("e.force:showToast");
                    //toastEvent.setParams({
                        //"title": "Error!",
                        //"message": "You Can't create Quote directly.",
                        //"type" :"error"
                    //});
                    //toastEvent.fire();
                    component.set("v.noAccess",true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})