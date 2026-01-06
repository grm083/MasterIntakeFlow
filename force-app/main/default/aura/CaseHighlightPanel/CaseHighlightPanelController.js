({
	doInit : function(component, event, helper) {          
        //get case highlight panel data
        helper.getCaseDetails(component);
    },
    
     handleClick : function(component, event, helper) {
      	 var recordId = event.currentTarget.dataset.value;
            var sObectEvent = $A.get("e.force:navigateToSObject");
                sObectEvent.setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                });
                sObectEvent.fire();
    },
    
    recordUpdated : function(component, event, helper){
    var cId = component.get("v.recordId");
    var changeType = event.getParams().changeType;
    if(changeType == "CHANGED" || changeType == "LOADED"){
    helper.getCaseDetails(component);
		}
    }
})