({
    doInit: function (component, event, helper) {
		  component.set('v.isSending',true);
      /*  component.set('v.columns', [
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
        ]);
      
            /*   component.set('v.columns', [
           {label: 'Task', fieldName: 'SubjectId', type: 'url', 
             typeAttributes: {label: { fieldName: 'Subject' } ,target: '_parent'}},
			{label: 'Case Creation Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { 
                															month: 'numeric',
                                                                            day: 'numeric',   
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                															hour12: true},sortable : true},
            {label: 'Case SLA Date', fieldName: 'caseServiceDate', type: 'date'},
            
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
           
           
           
           
           
           
           
           
           
           
           
           
           helper.doFetchTask(component);
           helper.getUserTeamAcess(component);
           
           },
           
           next: function (component, event, helper) {
           helper.next(component, event);
           },
           previous: function (component, event, helper) {
           helper.previous(component, event);
           },
           
           // function for sorting the table based on the selected column.
           // function for sorting the table based on the selected column.
           updateColumnSorting: function (component, event, helper) {
           helper.handleSort(component, event);
           },
           sfdcTeamChangeHandle : function (component, event, helper) {
           var selectedTeam =     component.get("v.selectedSfdcTeam");
           
           if(!selectedTeam){
           helper.doFetchTask(component);
           //  alert( component.get("v.selectedSfdcTeam"));
           }else if(selectedTeam && selectedTeam.length > 0){
           helper.doFetchTaskWithFilter(component);
           
           //  alert('filter is on');
           //  component.set("v.isSending",true);
           //  
           
           }
           
           // helper.sfdcTeamChange(component, event, helper);
           }
           })