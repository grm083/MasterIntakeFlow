({
	getCaseDetails : function(cmp, event) {
		var recordId = cmp.get('v.recordId');
        var getCaseDetails = cmp.get('c.getCaseDetails');
        getCaseDetails.setParams({
            recordId : recordId
        })
        getCaseDetails.setCallback(cmp, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var results = response.getReturnValue();
                cmp.set('v.locationId', results.Location__c);
            } else {
                console.log(response);
            }
        })
        $A.enqueueAction(getCaseDetails);
	}
})