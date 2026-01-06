({
    SearchHelper: function (component, event, pageNumber, pageSize) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var action = component.get('c.fetchVendorOrClientWrapper');
        console.log('RecordID '+ component.get('v.recordId'));
        console.log(pageNumber + pageSize);
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'selectedFilter': component.get("v.selectedAccountFilter"),
            'pageNumber': pageNumber,
            'pageSize': pageSize,
            'CaseId':component.get('v.recordId'),
            'recordType' : 'Client'
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
    updateCaseforClient: function (component, event, helper, clientId, caseIDStr) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var action = component.get("c.updateCaseOnVendorClientSelection");
        action.setParams({
            'accountId': clientId,
            'caseId': caseIDStr,
            'recordType' : 'Client'
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