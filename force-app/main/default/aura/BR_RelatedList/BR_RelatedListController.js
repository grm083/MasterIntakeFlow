({
	 doInit : function(component, event, helper) {
      component.set("v.showDataTable",false );
     component.set("v.showSpinner",true );
           component.set('v.columns', [
                {label: 'Business Rule Name', fieldName: 'brNameLink', type: 'url',
             typeAttributes: { label: { fieldName: 'Name' }, target: '_self', tooltip: { fieldName: 'Name' } } },
                {label: 'Is Auto Email', fieldName: 'Is_Auto_Email__c', type: 'boolean'},
               {label: 'Request Type', fieldName: 'Request_Type__c', type: 'text'},
               {label: 'Service', fieldName: 'Service__c', type: 'text'},
               {label: 'Active', fieldName: 'Active__c', type: 'boolean'}
        ]);
       component.set("v.recordCount",0 );
        helper.getAllBrRecords(component, event, helper);
    },
})