({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'From Address', fieldName: 'FromAddress', type: 'text'},
            {label: 'Subject', fieldName: 'linkSubject', type: 'url', 
             typeAttributes: {label: { fieldName: 'Subject' }, target: '_parent'}},
            {label: 'Case', fieldName: 'CaseLink', type: 'url', 
             typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_parent'}},
            {label: 'Case Type', fieldName: 'CaseType', type: 'text'},
            {label: 'Case Sub Type', fieldName: 'CaseSubType', type: 'text'},
            {label: 'Case Status', fieldName: 'CaseStatus', type: 'text'},
            {label: 'Case Sub Status', fieldName: 'CaseSubStatus', type: 'text'},
            {label: 'Case Location', fieldName: 'CaseLocation', type: 'text'},
            {label: 'Message Status', fieldName: 'Status', type: 'text'},
            { 
                label: 'Message Date', 
                fieldName: 'MessageDate', 
                type: 'date', 
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit', 
                    minute: '2-digit',
                    second: '2-digit',
                    timeZone : $A.get("$Locale.timezone"),
                    hour12: true
                },
                sortable: false
            }
            
        ]);
        helper.getCount(component);
        helper.getData(component);
        var workspaceAPI = component.find("workspace");
        console.log("workspaceAPI: " + workspaceAPI);
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Email Messages"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:email"
			});
        })
        .catch(function(error) {
            console.log(error);
        });
        
    },
    loadMoreData: function (component, event, helper) { 
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        component.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.data').length >= component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
                component.set('v.loadMoreStatus', 'No more data to load');
            } else {
                console.log(data);
                var currentData = component.get('v.data');
                //Appends new data to the end of the table
                var newData = currentData.concat(data);
                component.set('v.data', newData);
                component.set('v.loadMoreStatus', '');
            }
            event.getSource().set("v.isLoading", false);
        }));
    },
    Search: function(component, event, helper) {
		component.set('v.loadMoreStatus', '');
		component.set('v.enableInfiniteLoading', true);
        var searchField = component.find('searchField');
        var isValueMissing = searchField.get('v.validity').valueMissing;
        // if value is missing show error message and focus on field
        if(isValueMissing) {
            searchField.showHelpMessageIfInvalid();
            //searchField.focus();
        }else{
            // else call helper function 
            helper.getCount(component);
            helper.getData(component);
        }
    },
})