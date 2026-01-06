({
    getData : function(component, event, helper){
        var instance = component.get("c.checkSrvcDate");
        instance.setParams({
            "woId" : component.get("v.recordId")
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.srvcDateCheck",response.getReturnValue());
                if(response.getReturnValue().isToday){
                    var Interface_Name = $A.get("$Label.c.Work_Order_ETA");
                    helper.getETAWindow(component, event, helper,component.get("v.recordId"),Interface_Name,response.getReturnValue().caseId);
                }
            }
        });
        $A.enqueueAction(instance);
    },
    
    
	getETAWindow : function(component, event, helper, idOfWO,Interface_Name,CaseId){
        var instance = component.get("c.getETAWindowForWO");
        instance.setParams({
            "Wo_Id" : idOfWO,
            "InterfaceName" : Interface_Name,
            "CaseId" : CaseId
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ETA Window",
                    "message": response.getReturnValue(),
                    "type": "info",
                    "mode": "sticky"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(instance);
    }
})