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
            {label: 'Name', fieldName: 'Process', type: 'text', sortable : true},
            {label: 'Due', fieldName: 'dueDate', type: 'Date', sortable : true},
        ]);
            
           
            
            helper.doFetchTask(component);
            
            
               },
  
 next: function (component, event, helper) {
    helper.next(component, event);
},
    previous: function (component, event, helper) {
    helper.previous(component, event);
},
          
    openTab : function(component, event, helper) {
        
      var openTaskTabUrl = component.get("v.teamOpenTaskUrl");
      var openTaskTabName = component.get("v.teamOpenTaskTabName");
        var workspaceAPI = component.find("workspace");
            

        workspaceAPI.openTab({
            url: openTaskTabUrl,
            focus: true ,
            attributes: {
                    "pageSize":"15",
            "Homepage":"False" }
        }).then(function(response) {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: openTaskTabName
            }).then(function(tabInfo) {
           
            });
        }).catch(function(error) {
               
        });
    },
           
})