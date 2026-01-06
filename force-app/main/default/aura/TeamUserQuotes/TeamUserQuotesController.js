({
    doInit: function (component, event, helper) {
        
        /*  component.set('v.isSending',true);
        component.set('v.columns', [
            {label: 'Task', fieldName: 'SubjectId', type: 'url', 
             typeAttributes: {label: { fieldName: 'Subject' } ,target: '_parent'}},
			{label: 'Case Creation Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { 
                															month: 'numeric',
                                                                            day: 'numeric',   
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                															hour12: true},sortable : true},
            {label: 'Case', fieldName: 'RelatedTo', type: 'url', 
             typeAttributes: {label: { fieldName: 'RelatedToName' } ,target: '_parent'}},
             {label: 'Location', fieldName: 'Location', type: 'url', 
             typeAttributes: {label: { fieldName: 'LocName' } ,target: '_parent'}},
            {label: 'Case Type', fieldName: 'CaseType', type: 'text', sortable : true},
            {label: 'Case Sub-Type', fieldName: 'CaseSubType', type: 'text', sortable : true},
            {label: 'Name', fieldName: 'Process', type: 'text', sortable : true},
            {label: 'Due', fieldName: 'dueDate', type: 'date', typeAttributes: { 
                															month: 'numeric',
                                                                            day: 'numeric',   
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                															hour12: true},sortable : true},
        ]);*/
  /*      component.set('v.columns', [
            {label: 'Task Type', fieldName: 'SubjectId', type: 'url', 
             typeAttributes: {label: { fieldName: 'Subject' } ,target: '_parent'},sortable : true},
            {label: 'Task Due', fieldName: 'dueDate', type: 'date', typeAttributes: { 
                month: 'numeric',
                day: 'numeric',   
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                hour12: true},sortable : true},
            {label: 'Task Comment', fieldName: 'taskComment', type: 'textArea',sortable : true},                                                               
            {label: 'Case Creation Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { 
                month: 'numeric',
                day: 'numeric',   
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                hour12: true},sortable : true},
            
            
            {label: 'Case', fieldName: 'RelatedTo', type: 'url', 
             typeAttributes: {label: { fieldName: 'RelatedToName' } ,target: '_parent'},sortable : true},
            {label: 'Case Type', fieldName: 'CaseType', type: 'text', sortable : true},
            {label: 'Case Sub-Type', fieldName: 'CaseSubType', type: 'text', sortable : true},
            
            {label: 'Case Service Date', fieldName: 'caseServiceDate', type: 'date-local',sortable : true},
            {label: 'Vendor Account Name ', fieldName: 'vendorAccountName', type: 'textArea',sortable : true},
              {label: 'Location', fieldName: 'Location', type: 'url', 
             typeAttributes: {label: { fieldName: 'LocName' } ,target: '_parent'},sortable : true}
    
        ]);*/
            
            
            helper.doFetchTask(component);
            
            
            },
            
            next: function (component, event, helper) {
            helper.next(component, event);
            },
            previous: function (component, event, helper) {
            helper.previous(component, event);
            },
            
            
            openTab : function(component, event, helper) {
            var taburl = component.get("v.OpenQuoteTabUrl");
            var tabName = component.get("v.OpenQuoteTabName");
            var workspaceAPI = component.find("workspace");
            
            workspaceAPI.openTab({
            url: taburl,
            focus: true ,
            
            }).then(function(response) {
            workspaceAPI.setTabLabel({
            tabId: response,
            label: tabName
            }).then(function(tabInfo) {
            
            });
            }).catch(function(error) {
            
            });
            },
            
            // function for sorting the table based on the selected column.
            updateColumnSorting: function (component, event, helper) {
            helper.handleSort(component, event);
            }
            
            })