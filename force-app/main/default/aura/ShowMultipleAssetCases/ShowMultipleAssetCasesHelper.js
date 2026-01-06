({
	getMultipleCases : function(component) {
		//get the case recordId
        var caseId = component.get("v.recordId");
		var action = component.get('c.showMutipleAssetCases');
        action.setParams({"caseId" : caseId});
        action.setCallback(this, function(response) {
                var data = response.getReturnValue(); 
                component.set('v.multipleAssetCases',data);
                });
            $A.enqueueAction(action);
	},
    
    moveToNextCase : function(component){
        var caseId = component.get("v.recordId");
        var action = component.get('c.moveToNextRelatedAssetCase');
         action.setParams({"caseId" : caseId});
        action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                if(data != ''){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url" : "/lightning/r/Case/"+data+"/view"
                    });
                    urlEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set('v.nextCaseEnabled',true);                    
                }
                });
            $A.enqueueAction(action);
    }
})