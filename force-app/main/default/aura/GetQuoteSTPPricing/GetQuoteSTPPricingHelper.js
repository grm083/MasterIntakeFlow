({
	getPricingResponseStatus: function (component) {
	
    var procuredStatus = component.get('v.procuredStatus');
    //alert(procuredStatus);
    console.log('procuredStatus '+procuredStatus);
    var isFirstCall = false; 
    // if(procuredStatus== 'Success' || procuredStatus == 'Failed'){
    //   isFirstCall = false;
    // }
    // else{
    //   isFirstCall = true;
    // }
	  console.log('isFirstCall' + isFirstCall);
		var count = 0;
		var greenCount = 0;
		var quoteID = component.get("v.recordId");
		component.set("v.loadingSpinner", true);
		var action = component.get("c.processPricingRequest");
		action.setParams({ quoteID: quoteID ,
                      isFirstCall :isFirstCall });

		action.setCallback(this, function (response) {
			var state = response.getState();

			if (state === "SUCCESS") {
				var wrapper = response.getReturnValue();
				console.log("bundle @@@@@" + JSON.stringify(wrapper));
				if (wrapper) {
					// check to make sure the list isn't null
					if (wrapper != null) {
						component.set("v.QuotePringRequestList", wrapper);
						// get the length of the list (in this case number of rows/records)
						var listLength = wrapper.length;
						// loop through the list of records and stop once you are at the list length
						for (var i = 0; i < listLength; i++) {
							component.set("v.activesection", wrapper[0].BundleID);
							// below assumes the object has a field called 'field__c'
							if (wrapper[i].Problem) {
								count = count + 1;
							}

							if (wrapper[i].ProductDetails) {
								//Comment Code for SDT-31291 : Start
								// if (wrapper[i].ProductDetails.SubstituteMessage != null) {
								// 	component.set(
								// 		"v.SubstituteMsg",
								// 		wrapper[i].ProductDetails.SubstituteMessage
								// 	);
								// }
								var t = wrapper[i].ProductDetails;
								if (t.GreenPages) {
									count = count + 1;
								}
							}
						}
						if (listLength == count) {
							component.set("v.IsPricingAvailable", true);
							var PassPricingResult = component.getEvent("PassPricingResult");
						}

						$A.get("e.force:refreshView").fire();
						component.set("v.loadingSpinner", false);
					}
				}
			} else {
				var resultsToast = $A.get("e.force:showToast");
				resultsToast.setParams({
					title: "Data not received",
					message: "In Progress/Not get API response. Please refresh screen",
					type: "info",
				});
				resultsToast.fire();
				component.set("v.NoData", true);
			}
			component.set("v.loadingSpinner", false);
		});
		if(isFirstCall){
			window.setTimeout(function () {
				$A.enqueueAction(action);
			}, 60000);
		}
		else{
			window.setTimeout(function () {
				$A.enqueueAction(action);
			}, 5000);
		}
	},
    //added for 31114 to show asset error if no PR is created
    getPricingResponseAssetError: function (cmp){
    var quoteID = cmp.get('v.recordId');
        var getPricingResponseAssetError = cmp.get('c.getPriceAssetErrorMessageIfAny');
        getPricingResponseAssetError.setParams({
            quoteID : quoteID
        })
        getPricingResponseAssetError.setCallback(cmp, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var results = response.getReturnValue();
                cmp.set('v.QuotePricingRequestListAssetError', results);
            } else {
                console.log(response);
            }
        })
        $A.enqueueAction(getPricingResponseAssetError);
	}
});