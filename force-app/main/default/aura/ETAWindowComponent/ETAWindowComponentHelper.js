({
    callApex : function(component, event, helper) {
        var caseLocId = component.get("v.recordId");
		var objname = component.get("v.sObjName");
        if(objname == 'Account'){
            
             var instance = component.get("c.getStatusDataLocation");
            
        }else{
            
            var instance = component.get("c.getStatusData");
        }
        instance.setParams({
            "caseId" : component.get("v.recordId"),
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
		var objname = component.get("v.sObjName");
        var instance = component.get("c.getAssetHeaders");
        var caseLocId = component.get("v.recordId");
        var IsLocation = false;
        /*if(caseLocId.includes('001')){
             component.set("v.caseVisibility",false);
            IsLocation = true;
            
        }*/
		if(objname == 'Account'){
             component.set("v.caseVisibility",false);
            IsLocation = true;
        }
        instance.setParams({
            "caseId" : component.get("v.recordId"),
            "IsLocation":IsLocation
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