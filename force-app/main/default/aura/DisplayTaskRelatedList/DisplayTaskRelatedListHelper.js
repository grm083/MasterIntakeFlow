({
    getRelatedToId : function(component, event, helper) {
        var action = component.get("c.getRelatedTo");
        action.setParams({ "recId" : component.get("v.recordId") });
        action.setCallback(this, function(response) {            
            var state = response.getState();
			if (state === "SUCCESS") {
               component.set("v.relatedObjWrapper", response.getReturnValue());
                var objWrapper  = component.get("v.relatedObjWrapper");
                   if(objWrapper.fieldList !== undefined){
                        component.set("v.objFields", objWrapper.fieldList);
                	component.set("v.icon", 'standard:'+ objWrapper.objectName.toLowerCase());
                   }
			} 
            else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    }
})