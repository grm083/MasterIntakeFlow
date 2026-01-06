({
	doInit : function(component, event, helper) {          
        //get list of asset headers for the location
        helper.getMultipleCases(component);
    },
    recordUpdated: function(component, event, helper) {
        helper.getMultipleCases(component); 
    },
    handleRelatedCaseListenerEvent : function(component, event, helper) {
        var triggerCase = event.getParam("triggeringCase");
        var relatedCaseList = event.getParam("relatedCases");
        if(component.get("v.recordId")!==triggerCase)
        {
            console.log('inside relatedMultiCase refresh');
            if(relatedCaseList && relatedCaseList.includes(component.get("v.recordId"))){
             helper.getMultipleCases(component); 
        	}
        }
    },
    handleClick : function(component, event, helper) {
      	 var recordId = event.target.dataset.caseid;
            var sObectEvent = $A.get("e.force:navigateToSObject");
                sObectEvent.setParams({
                    "recordId": recordId,
                    "slideDevName": "detail"
                });
                sObectEvent.fire();
    },
    
    moveToNextCase : function(component, event, helper){
        helper.moveToNextCase(component);
    }
})