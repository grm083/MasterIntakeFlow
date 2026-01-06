({
    refreshFocusedTab: function(cmp, event) {
        var workspaceAPI = cmp.find('workspace');
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.refreshTab({
                tabId : focusedTabId,
                includeAllSubtabs : true
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
	updateCase : function(cmp, event) {
		var updateCase = cmp.get('c.updateCase');
        var caseId = cmp.get('v.recordId');
        var serviceDate = cmp.get('v.selectedDate')
        
        updateCase.setParams({
            caseId : caseId,
            serviceDate : serviceDate
        })
        updateCase.setCallback(this, function(response) {
            var status = response.getState()
            if (status === 'SUCCESS') {
                var parentId = cmp.get("v.parentId");
                if(parentId != "undefined" && parentId != null && parentId != ""){
                    var caseId = parentId;
                    const payload = {
                        caseId: caseId,
                    };
                    console.log('payload'+payload);
                    cmp.find("lmschannel").publish(payload);
                }
                 cmp.set("v.loadingSpinner", false);
                cmp.set("v.closeParent",false) ;
                cmp.set('v.loaded', false);
                 var appEvent = cmp.getEvent("SingleTabRefreshEvent");
                	appEvent.setParams({ "reload" : "true" });
					appEvent.fire();
                var updatedServiceDate = cmp.get('v.selectedDate')
                /* var compEvent = cmp.getEvent("returnUpdatedServiceDate");
               	compEvent.setParams({ "updatedServiceDate" : updatedServiceDate });
				compEvent.fire(); */
                $A.get('e.force:refreshView').fire();
                cmp.destroy();
            }
        })
        $A.enqueueAction(updateCase);
	},
    confirmCheck : function(cmp, event) {
        cmp.set("v.loadingSpinner", true);
		var availDate = cmp.get('v.isDateAvailable');
        cmp.getEvent("opensla").setParams({
            isOpenSLAComp : true,
			isAvailDate : availDate
        }).fire();
    },
    getAcornBaseline : function(cmp, event) {
        var caseId = cmp.get('v.recordId');
        console.log('Case Id is ' + caseId);
        var getAcornBaseline = cmp.get('c.getAcornBaseline');
        getAcornBaseline.setParams({
            caseId : caseId
        });
        console.log('Getting baseline');
        getAcornBaseline.setCallback(cmp, function(response) {
            var state = response.getState();
            var results = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set('v.baseline', results);
                var getSLA = cmp.get('c.getSLADate');
                console.log('Baseline is ' + cmp.get('v.baseline'));
				getSLA.setParams ({
					caseId : caseId
				});
                console.log('Getting SLA');
				getSLA.setCallback(cmp, function(response) {
					if (response.getState() === 'SUCCESS') {
						cmp.set('v.SLADate', response.getReturnValue());
						var baseline = cmp.get('v.baseline');
						var requestedDate = cmp.get('v.SLADate');
                        console.log('SLA Date is ' + requestedDate);
						var getAvailableDates = cmp.get('c.getAvailableDates');
						getAvailableDates.setParams({
							baseline : baseline
						});
                        console.log('Getting available dates');
						getAvailableDates.setCallback(cmp, function(response) {
							var state = response.getState();
							var results = response.getReturnValue();
                            console.log('Returned values are ' + results);
							if (state === 'SUCCESS') {
                                if (results.length > 0) {
                                    cmp.set('v.loaded', false);
                                    cmp.set('v.availDates', results);
									cmp.set('v.isDateAvailable', true);
                                } else {
                                    cmp.set('v.boolDisplay', false);
                                    cmp.set('v.loaded', false);
                                }
							};
						});
						$A.enqueueAction(getAvailableDates);
					}
				});
				$A.enqueueAction(getSLA);
            }
        });
        $A.enqueueAction(getAcornBaseline);
    }
})