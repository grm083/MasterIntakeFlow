({
    callApex : function(component, event, helper) {
        var workOrderRec = component.get("v.workOrderRecord");
        var caseRecordId = workOrderRec.CaseId;
        var instance = component.get("c.getStatusData");
        instance.setParams({
            "caseId" : caseRecordId,
            "assetHeaderId" : component.get("v.selectedAsset")
        });
        instance.setCallback(this, function(response){
            component.set("v.IsSpinner",false);
            if(response.getState() == "SUCCESS"){
                var returnVal = response.getReturnValue();
                if(returnVal != null){
					var etaMsg = returnVal.ETAMessage;
                    if(etaMsg != "undefined" && etaMsg != null && etaMsg != ""){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ETA Window",
                            "message": etaMsg,
                            "type": "info",
                            "mode": "sticky"
                        });
                        toastEvent.fire();
                    } else {
                        component.set("v.etaStatusServiceLst",response.getReturnValue().dataWrapETAServicesLst);
                    }                    
                }
            } 
        });
        $A.enqueueAction(instance);
    },

    getAssets : function(component, event, helper){
        var workOrderRec = component.get("v.workOrderRecord");
        var caseRecordId = workOrderRec.CaseId;
        var instance = component.get("c.getAssetHeaders");
        instance.setParams({
            "caseId" : caseRecordId
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var returnVal = response.getReturnValue();
                if(returnVal != null){
                    console.log('returnVal -- ' + returnVal);
					component.set("v.assetOptions", returnVal);       
                }
            } 
        });
        $A.enqueueAction(instance);
    }
})