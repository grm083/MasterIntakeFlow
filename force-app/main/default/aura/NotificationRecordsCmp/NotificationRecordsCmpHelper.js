({
	getAssets: function (component, event, helper) {
		var objname = component.get("v.sObjName");
		var instance = component.get("c.getAssetHeaders");
        var caseLocId = component.get("v.recordId");
        var IsLocation = false;
        /*if(caseLocId.includes('001')){
            IsLocation = true;
            
        }*/
		if(objname == 'Account'){
            IsLocation = true;
        }
		instance.setParams({
			"caseId": component.get("v.recordId"),
             "IsLocation":IsLocation
		});
		instance.setCallback(this, function (response) {
			if (response.getState() == "SUCCESS") {
				var returnVal = response.getReturnValue();
				if (returnVal) {
					component.set("v.assetOptions", returnVal);
				}
			}
		});
		$A.enqueueAction(instance);
	},
	getNTDataFromAPI: function (component, event, helper) {
		component.set("v.IsSpinner", true);
		var instance = component.get("c.getTrackingData");
		instance.setParams({
			"assetHeaderId": component.get("v.selectedAsset"),
			"pageNumber": component.get("v.pageNumber"),
			"pageSize": component.get("v.pageSize")

		});
		instance.setCallback(this, function (response) {
			component.set("v.IsSpinner", false);
			component.set("v.hideFooter", false);
			if (response.getState() == "SUCCESS") {
				var returnVal = response.getReturnValue();
				if (returnVal) {
					var NotifMsg = returnVal.notifMessage;
					if (NotifMsg) {
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Notification Window",
							"message": NotifMsg,
							"type": "info",
							"mode": "sticky"
						});
						toastEvent.fire();
					} else {
						component.set("v.notiTrackingDataLst", response.getReturnValue().dataWrapNotifTrackLst);
						var pageSize = component.get("v.pageSize");
						component.set("v.totalRecords", response.getReturnValue().count);
						var total = parseInt(component.get("v.totalRecords") / pageSize);
						if (component.get("v.totalRecords") % pageSize > 0) {
							total = total + 1;
						}
						component.set('v.totalPage', parseInt(total));
					}

				}

			} else if (response.getState() == "ERROR") {
				let errors = response.getError();
				let message = 'Unknown error'; // Default error message
				// Retrieve the error message sent by the server
				if (errors && Array.isArray(errors) && errors.length > 0) {
					message = errors[0].message;
				}
				// Display the message
				let toastParams = {
					title: "Error",
					message: "Unknown error", // Default error message
					type: "error"
				};
				// Pass the error message if any
				if (errors && Array.isArray(errors) && errors.length > 0) {
					toastParams.message = errors[0].message;
				}
				// Fire error toast
				let toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams(toastParams);
				toastEvent.fire();
			} else {
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Error",
					"message": 'Something went wrong.Please try again.',
					"type": "error",
					"mode": "sticky"
				});
				toastEvent.fire();
			}
		});
		$A.enqueueAction(instance);
	},
})