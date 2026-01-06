({
    initAction : function(component, event, helper) {
        component.set('v.statusColumns', [
            {label: 'Service Date', fieldName: 'serviceDate', type: 'date'},
            {label: 'Asset Name', fieldName: 'assetName', type: 'text'},
            {label: 'ETA Window', fieldName: 'etaWindow', type: 'text'},
            {label: 'Truck Position', fieldName: 'truckPosition', type: 'text'},
            {label: 'Customer Position', fieldName: 'customerPosition', type: 'text'},
            {label: 'Service Status', fieldName: 'serviceStatus', type: 'text'},
            {label: 'Exception Reason', fieldName: 'exceptionReason', type: 'text'},
            {label: 'Service Status Date', fieldName: 'serviceStatusDate', type: 'text'},
            {label: 'Reschedule Date', fieldName: 'rescheduleDate', type: 'text'},
            {label: 'W/O #', fieldName: 'woNumber', type: 'text'},
            {label: 'Material', fieldName: 'materialTypeName', type: 'text'},
            {label: 'Occurrence', fieldName: 'occurrenceType', type: 'text'},
            {label: 'Photo (URL)', fieldName: 'imageUrl', type: 'text'},
            {label: 'SID', fieldName: 'serviceOfferingDefinitionId', type: 'text'},
            {label: 'WO Description', fieldName: 'woDescription', type: 'text'},
            {label: 'VID', fieldName: 'vendorCode', type: 'text'},
            {label: 'Vendor Name', fieldName: 'vendorName', type: 'text'},
            {label: 'Schedule Type', fieldName: 'scheduleType', type: 'text'},
            {label: 'Mas#', fieldName: 'masUniqueId', type: 'text'},
            {label: 'Vendor Account Number', fieldName: 'vendorAccountNumber', type: 'text'}]);

        helper.getAssets(component,event,helper);
    },
    getETAStatus : function(component, event, helper) {
        component.set("v.IsSpinner",true);
        helper.callApex(component, event, helper);
    },
    onChange : function(component, event, helper) {
        var assetId = component.find("selectAsset").get("v.value");
        
        component.set("v.selectedAsset",assetId);
        if(assetId == 'default'){
            component.set("v.disable",true);
        }else{
            component.set("v.disable",false);
        }
    },
    ManualTaskInvocation : function(component,event,helper){   
        var workOrderRec = component.get("v.workOrderRecord");
        var caseRecordId = workOrderRec.CaseId;
        var action = component.get("c.getManualInvocation");    
        action.setParams({"caseId" : caseRecordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS" ){
                var isReportServiceIssue = response.getReturnValue();
                if( workOrderRec.CaseId != null && (isReportServiceIssue || workOrderRec.Case.Status != 'Open'|| workOrderRec.Case.Acorn_Work_order__c == null || workOrderRec.Case.Case_Type__c == 'Status' )){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'A Service Issue Resolution task already exists or there is no WO associated to the case.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }                
                else{
                    $A.createComponent(
                        "c:ManualTaskCreation",
                        {
                            "currentCaseID": caseRecordId          
                        },
                        function (msgBox) {
                            if (component.isValid()) {
                                var targetCmp = component.find('ManualTaskCreationComp');
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body);
                            }
                        }
                    );
                }               
            }                              
        });
        $A.enqueueAction(action);
     }
} )