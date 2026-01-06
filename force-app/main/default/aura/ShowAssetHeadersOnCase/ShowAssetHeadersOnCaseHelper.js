({
    getAssetHeaders: function (component, event, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get('c.getAssetHeaders');
        var alreadySelected = [];
        var preSelectedAssets = component.get("v.preAssetSelections");
        action.setParams({ "caseId": caseId });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var data = response.getReturnValue();
                for (var i in data) {
                    if (data[i].Start_Date != null) {
                        data[i].Start_Date = data[i].Start_Date.split('-')[1] + '/' + data[i].Start_Date.split('-')[2] + '/' + data[i].Start_Date.split('-')[0];
                    }
                    if (data[i].End_Date != null) {
                        data[i].End_Date = data[i].End_Date.split('-')[1] + '/' + data[i].End_Date.split('-')[2] + '/' + data[i].End_Date.split('-')[0];
                    }
                    if (data[i].highlightRow) {
                        alreadySelected.push(data[i].assetId);
                    }
                }
                component.set('v.assetHeaders', data);
                component.set('v.selectedOptions', alreadySelected);
            }
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
    },

    getStatusForCase: function (component, event, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get('c.getStatusForCase');
        action.setParams({ "caseId": caseId });
        action.setCallback(this, function (response) {
            var data = response.getReturnValue();
            if (data == 'New' || data == 'Open') {
                component.set('v.DoDisable', false);
            }
            else {
                component.set('v.DoDisable', true);
            }
        });
        $A.enqueueAction(action);
    },

    saveDisableCheck: function (component, event, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get('c.disableCheck');
        action.setParams({ "caseId": caseId });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.assetIdOnCase", data[0].AssetId);
                var selectedoptions = component.get('v.selectedOptions');
                if (data[0].AssetId) {
                    selectedoptions.splice(selectedoptions.indexOf(data[0].AssetId), 1);
                    selectedoptions.unshift(data[0].AssetId);
                }
                component.set("v.selectedOptions", selectedoptions);
                component.set("v.selectedAssetHeaders", selectedoptions);
                if (data[0].hasOwnProperty('Origin')) {
                    if (data[0].Origin.toLocaleLowerCase().includes('officetrax')) {
                        component.set('v.officetrax', true);
                    }
                }
                if ((data[0].Status == 'New' && !data[0].Is_Multiple_Asset__c) || (data[0].Status == 'Open' && !data[0].Acorn_Work_order__c && ((data[0].RecordType.Name == 'Standard Case' && data[0].Case_Type__c == 'General') ||
                                                                                                                                                                    (data[0].RecordType.Name == 'Standard Case' && data[0].Case_Type__c == 'Payment Inquiries' && data[0].Case_Sub_Type__c == 'Past Due') ||
                                                                                                                                                                    (data[0].RecordType.Name == 'Repair Case' && data[0].Case_Type__c == 'Hauler Damage' && data[0].Case_Sub_Type__c == 'Equipment/Property')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Add' && data[0].Case_Sub_Type__c == 'Equipment' && data[0].Case_Reason__c == 'Compactor')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Add' && data[0].Case_Sub_Type__c == 'Equipment' && data[0].Case_Reason__c == 'Compactor Accessories')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Add' && data[0].Case_Sub_Type__c == 'Fee(s)' && data[0].Case_Reason__c == 'General Fees')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Add' && data[0].Case_Sub_Type__c == 'Services' && data[0].Case_Reason__c == 'Missing Service')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Special Request' && data[0].Case_Sub_Type__c == 'Dumpster Fresh')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Special Request' && data[0].Case_Sub_Type__c == 'Lamptracker/Batterytracker/MedWaste')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Special Request' && data[0].Case_Sub_Type__c == 'Event Box(es)')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Special Request' && data[0].Case_Sub_Type__c == 'General Supplies')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Pickup Case' && data[0].Case_Type__c == 'Pickup' && data[0].Case_Sub_Type__c == 'Bale(s)')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Modify Existing Service Case' && data[0].Case_Type__c == 'Change Service' && data[0].Case_Sub_Type__c == 'Change/Correction' && data[0].Case_Reason__c == 'Remove End Dates')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Special Request' && data[0].Case_Sub_Type__c == 'Electronic Recycling (Computers, Laptops, etc.)' && data[0].Case_Reason__c == 'Electronic Recycling Collection')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Service Request Case' && data[0].Case_Type__c == 'Special Request' && data[0].Case_Sub_Type__c == 'Universal Waste (Lamps, Batteries, etc.)' && data[0].Case_Reason__c == 'Universal Waste Collection')||
                                                                                                                                                                    (data[0].RecordType.Name == 'Status Case' && data[0].Case_Type__c == 'Status' && data[0].Case_Sub_Type__c == 'ETA')||
																																									(data[0].RecordType.Name == 'Status Case' && data[0].Case_Type__c == 'Status' && data[0].Case_Sub_Type__c == 'Service Not Performed' && (data[0].Case_Reason__c == 'Customer Reported') || (data[0].Case_Reason__c == 'Hauler Reported')))))
     
																																																																																																					  
					
                {
                    component.set('v.DoDisable', false);
                } 
                else 
                { component.set('v.DoDisable', true); }
            }
        });
        $A.enqueueAction(action);

    },

	showToast: function (component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration: 1000,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
    refreshFocusedTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            var result = workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: false
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    },
    replaceAssetOrStoreSelectionOnCase: function (component, event, asset, assetsToBeStored) {
        var saveAction = component.get('c.replaceAssetHeader');
        saveAction.setParams({ "caseId": component.get("v.recordId"), "assetValue": asset, "selectedAssets": assetsToBeStored });
        saveAction.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var appEvent = component.getEvent("SingleTabRefreshEvent");
                appEvent.setParams({ "reload": "true" });
                appEvent.fire();
                component.updateAssetHeaders();
                component.find("recordLoader").reloadRecord(true);
		var updateEvent = new CustomEvent('caseUpdated', {
                    detail: { caseId: component.get("v.recordId") }
                });
                window.dispatchEvent(updateEvent);
            } else {
                if (component.get('v.officetrax') == true) {
                    this.showToast(component, 'Error', 'You may only select Got Junk Assets for Officetrax cases.');
                } else {
                    this.showToast(component, 'Error', $A.get("$Label.c.Save_Asset_Header_Failure"));
                }

            }
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(saveAction);
    },
    checkContainer: function (assetIds, alreadySelectedAssets) {
        var returnFlag = true;
        alreadySelectedAssets.forEach(function (response) {
            if (!assetIds.includes(response)) {
                returnFlag = false;
            }
        });
        return returnFlag;
    }
})
