({
    SearchHelper: function (component, event, pageNumber, pageSize) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var action = component.get("c.fetchAccountAssetWrapper");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'selectedFilter': component.get("v.selectedAccountFilter"),
            'pageNumber': pageNumber,
            'pageSize': pageSize,
            'assetFilter': component.get("v.inactiveAssets"),
            'CaseId':component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            component.find("Id_spinner").set("v.class", 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                component.set("v.AccountAssetWrapperList", storeResponse.assetWrapperList);
                component.set("v.PageNumber", storeResponse.pageNumber);
                component.set("v.TotalRecords", storeResponse.totalRecords);
                component.set("v.RecordStart", storeResponse.recordStart);
                component.set("v.RecordEnd", storeResponse.recordEnd);
                component.set("v.TotalPages", Math.ceil(storeResponse.totalRecords / pageSize));
                component.set("v.previousSearchKeyword", component.get("v.searchKeyword"));
                component.set("v.TotalNumberOfRecord", storeResponse.assetWrapperList.length);

            } else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                            errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    fetchAssetForLocation: function (component, event, locationIdStr) {

        var action = component.get("c.fetchAssetRecs");
        action.setParams({
            'locationId': locationIdStr
        });
        action.setCallback(this, function (response) {
            component.find("Id_spinner").set("v.class", 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                component.set("v.AssetList", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },

    updateCaseforLocation: function (component, event, helper, clientIDStr, locationIDStr, assetIDStr, caseIDStr) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var action = component.get("c.updateCase");
        action.setParams({
            'clientId': clientIDStr,
            'locationId': locationIDStr,
            'assetId': assetIDStr,
            'caseId': caseIDStr
        });
        action.setCallback(this, function (response) {
            component.find("Id_spinner").set("v.class", 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse == 'Success') {
                    var appEvent = component.getEvent("SingleTabRefreshEvent");
                    appEvent.setParams({ "reload": "true" });
                    appEvent.fire();
                } else {
                    alert(' Error message ' + storeResponse);
                }
            }

        });
        $A.enqueueAction(action);
    },


})