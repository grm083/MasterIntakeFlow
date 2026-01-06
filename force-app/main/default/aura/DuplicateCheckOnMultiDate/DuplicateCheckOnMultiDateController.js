({
	myAction : function(component, event, helper) {
		component.set('v.columns', [            
            {label: 'WO Number', fieldName: 'woURL', type: 'url', typeAttributes: { label: { fieldName: 'WorkOrderNumber' },target: '_blank' } },
            {label: 'Asset', fieldName: 'AssetName', type: 'String'},
            {label: 'Asset Material', fieldName: 'Asset_Material__c', type: 'String'},
            {label: 'Case Type', fieldName: 'Case_Type__c', type: 'String'},
            {label: 'Case Sub Type', fieldName: 'Case_Subtype__c', type: 'String'},
            {label: 'Service Date', fieldName: 'ServiceDate', type: 'String'},
            {label: 'Created By', fieldName: 'CreatedByName', type: 'String'}]);
        
        var formattedData = component.get("v.workorders").map(function (record){
            			record.woURL = '/'+ record.Id;
                        record.AssetName = record.Asset.Name;
                        record.CreatedByName = record.CreatedBy.Name;
            			var sDate = record.Service_Date__c.split('-');                       
                        sDate = sDate[1] + '/' + sDate[2] + '/' + sDate[0];
                        var srvc = new Date(sDate);
                        record.ServiceDate = (srvc.getMonth()+1)+'/'+srvc.getDate()+'/'+srvc.getFullYear();
                        return record;
                    });
        component.set("v.data",formattedData);
	},
    closeModel : function(component, event, helper) {
        component.set("v.showModal",false);
    },
    getSelectedData : function(component, event, helper) {
        //var selectedrows = component.find('table').getSelectedRows();
        //alert("rows"+selectedrows);
        helper.callApex(component, event, helper);
        
        component.getEvent("CloseParent").setParams({
            isParentContaineClosed : true
        }).fire();
    }
})