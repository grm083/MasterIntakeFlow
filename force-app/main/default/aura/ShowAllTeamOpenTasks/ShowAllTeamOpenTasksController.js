({
    doInit: function (component, event, helper) {
       
        component.set('v.isSending',true);
        component.set('v.columns', [
            {label: 'Assignee', fieldName: 'AssignedTo', type: 'url', 
             typeAttributes: {label: { fieldName: 'AssigneeName' } ,target: '_parent'}},
            {label: 'Task', fieldName: 'SubjectId', type: 'url', 
             typeAttributes: {label: { fieldName: 'Subject' } ,target: '_parent'}},
            {label: 'Case', fieldName: 'RelatedTo', type: 'url', 
             typeAttributes: {label: { fieldName: 'RelatedToName' } ,target: '_parent'}},
            {label: 'Location', fieldName: 'Location', type: 'url', 
             typeAttributes: {label: { fieldName: 'LocName' } ,target: '_parent'}},
            {label: 'Name', fieldName: 'Process', type: 'text', sortable : true},
            {label: 'Due', fieldName: 'dueDate', type: 'Date', sortable : true},
        ]);
            helper.doFetchTask(component);
            
    },
  /*getSelectedName: function (component, event) {
            var selectedRows = event.getParam('selectedRows');
            // Display that fieldName of the selected rows
            for (var i = 0; i < selectedRows.length; i++){
            
    }
   },*/
 next: function (component, event, helper) {
    helper.next(component, event);
},
    previous: function (component, event, helper) {
    helper.previous(component, event);
},
          
   
           
})