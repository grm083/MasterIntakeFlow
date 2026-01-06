({
	callApex : function(component, event, helper) {
         var instance = component.get("c.ValidateToPopUpMsg");  
		 //var instance = component.get("c.getRelatedCase");  
        instance.setParams({
            rec : component.get("v.recordId")
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                 var res = response.getReturnValue();
                if(res == true){
                 var instance = component.get("c.getRelatedCase");
                     instance.setParams({
            recordId : component.get("v.recordId")
        });
                 instance.setCallback(this, function(response){
                 if(response.getState() == "SUCCESS"){
                      var resv = response.getReturnValue(); 
                     component.set("v.caseLst", resv);
                         }
                 });
                                      $A.enqueueAction(instance);
                }
            }
        });
        $A.enqueueAction(instance);
	},
       navigateToCaseDetail: function (component, event, helper) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": event.currentTarget.dataset.id,
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
      },
    callValidateOutcome : function(component, event, helper) {
        var instance = component.get("c.ValidateOutcome");  
        instance.setParams({
            recordId : component.get("v.recordId")
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                 var returnVal = response.getReturnValue();
                 if(returnVal != "undefined" && returnVal != null && returnVal != ""){
                     component.set("v.caseObj", returnVal);
                 }
            }
        });
        $A.enqueueAction(instance);
    }
})