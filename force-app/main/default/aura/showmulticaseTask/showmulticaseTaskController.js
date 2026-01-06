({
    doInit : function(component, event, helper) {
        var approvalTaskcolumns = [
            {label: 'Subject', fieldName: 'recId', type: 'url',typeAttributes: {label: { fieldName: 'Subject' }, target: '_Self'}},
            {label: 'Service', fieldName: 'Service', type: 'text', sortable: false, editable: false},
            {label: 'Business Rule No.', fieldName: 'brId', type: 'url',typeAttributes: {label: { fieldName: 'brName' }, target: '_Self'}},
            {label: 'Case Number', fieldName: 'caseId', type: 'url',typeAttributes: {label: { fieldName: 'caseNum' }, target: '_Self'}},
            {label: 'Service Date', fieldName: 'ServiceDate', type: 'Text', sortable: false, editable: false},
            {label: 'Outcome', fieldName: 'Outcome__c', type: 'Text', sortable: false, editable: false}
        ];
        var vendorAvailabilityTaskcolumns = [
            {label: 'Subject', fieldName: 'recId', type: 'url',typeAttributes: {label: { fieldName: 'Subject' }, target: '_Self'}},
            {label: 'Service Name', fieldName: 'Service', type: 'text', sortable: false, editable: false},
            {label: 'Case Number', fieldName: 'caseId', type: 'url',typeAttributes: {label: { fieldName: 'caseNum' }, target: '_Self'}},
            {label: 'Service Date', fieldName: 'ServiceDate', type: 'Text', sortable: false, editable: false},
            {label: 'Proposed service Date', fieldName: 'Proposed_Service_Date__c', type: 'Text', sortable: false, editable: false},
            {label: 'Outcome', fieldName: 'Outcome__c', type: 'Text', sortable: false, editable: false}
        ];
        var customerInfoTaskcolumns = [
            {label: 'Subject', fieldName: 'recId', type: 'url',typeAttributes: {label: { fieldName: 'Subject' }, target: '_Self'}},
            {label: 'Case Number', fieldName: 'caseId', type: 'url',typeAttributes: {label: { fieldName: 'caseNum' }, target: '_Self'}},
            {label: 'Description', fieldName: 'Description__c', type: 'Text', sortable: false, editable: false},
            {label: 'Customer PO #', fieldName: 'PurchaseOrder_Number__c', type: 'Text', sortable: false, editable: false},
            {label: 'Outcome', fieldName: 'Outcome__c', type: 'Text', sortable: false, editable: false}
        ];
        var cId = component.get("v.recordId");
        
        var action = component.get('c.getTaskList');
        action.setParams({
            "taskId" : cId,
            "isPopUp" : false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state == "SUCCESS") {
                
                var wrapper = response.getReturnValue();
                
                var result = wrapper.wrapperlist;
                var process = wrapper.multiCaseTask.Process__c ;
                var caseMap = new Map();
                caseMap =  wrapper.cseMap ;
                var ApprovalTask = ["Multi Case Approval Task", "Escalation Obtain Service Approval", "Obtain Service Approval"];
                var vendorAvailabilityTask = ["Confirm Vendor Availability", "Escalation Confirm Vendor Availability"];
                var customerInfo = ["Escalation Obtain Customer Info", "Obtain Customer Info"];
                console.log(wrapper);
                
                if(ApprovalTask.includes(process)){
                    component.set("v.columns",approvalTaskcolumns);
                    if( result != "undefined" && result != null && result != ""){
                        for (var i = 0; i < result.length; i++) {
                            result[i].recId = '/'+ result[i].resultTask.Id;
                            if (result[i].resultTask.Approval_Log__r) { 
                                result[i].Service =  result[i].resultTask.Approval_Log__r.CaseId__r.Case_Sub_Type__c;
                                result[i].caseNum =  result[i].resultTask.Approval_Log__r.CaseId__r.CaseNumber;
                                result[i].caseId = '/'+ result[i].resultTask.Approval_Log__r.CaseId__c;
                                result[i].ServiceDate = result[i].resultTask.Approval_Log__r.CaseId__r.Service_Date__c;
                                result[i].Outcome__c = result[i].resultTask.Outcome__c;
                                result[i].Subject = result[i].resultTask.Subject;
                            }
                            if(result[i].resultTask.Business_Rule__r.Name){
                                result[i].brName = result[i].resultTask.Business_Rule__r.Name;
                                result[i].brId = '/'+ result[i].resultTask.Business_Rule__c;
                            }
                            
                        }
                    }
                    component.set('v.tasklist',result);
                    component.set('v.showPopup',true);
                    
                }
                else if(vendorAvailabilityTask.includes(process)){
                    component.set("v.columns",vendorAvailabilityTaskcolumns);
                    if( result != "undefined" && result != null && result != ""){
                        for (var i = 0; i < result.length; i++) {
                            result[i].recId = '/'+ result[i].resultTask.Id;
                            result[i].Service = result[i].caseDetail.Case_Sub_Type__c;
                            result[i].caseNum =  result[i].caseDetail.CaseNumber;
                            result[i].caseId = '/'+ result[i].caseDetail.Id;
                            result[i].ServiceDate = result[i].caseDetail.Service_Date__c ;
                            result[i].Proposed_Service_Date__c = result[i].resultTask.Proposed_Service_Date__c;
                            result[i].Outcome__c = result[i].resultTask.Outcome__c;
                            result[i].Subject = result[i].resultTask.Subject;
                        }}
                    component.set('v.tasklist',result);
                    component.set('v.showPopup',true);
                }
                    else {
                        component.set("v.columns",customerInfoTaskcolumns);
                        if( result != "undefined" && result != null && result != ""){
                            for (var i = 0; i < result.length; i++) {
                                result[i].recId = '/'+ result[i].resultTask.Id;
                                result[i].caseNum =  result[i].caseDetail.CaseNumber;
                                result[i].caseId = '/'+ result[i].caseDetail.Id;
                                result[i].PurchaseOrder_Number__c = result[i].resultTask.PurchaseOrder_Number__c;
                                result[i].Profile_Number__c = result[i].resultTask.Profile_Number__c;
                                result[i].Description__c = result[i].resultTask.Description__c;
                                result[i].Outcome__c = result[i].resultTask.Outcome__c;
                                result[i].Subject = result[i].resultTask.Subject;
                            }}
                        component.set('v.tasklist',result);
                        component.set('v.showPopup',true);
                    }
            }
        });
        $A.enqueueAction(action);
    }/*,
    updateTable : function(component, event) {
        var ApprovalTask = ["Multi Case Approval Task", "Escalation Obtain Service Approval", "Obtain Service Approval"];
        var vendorAvailabilityTask = ["Confirm Vendor Availability", "Escalation Confirm Vendor Availability"];
        var customerInfo = ["Escalation Obtain Customer Info", "Obtain Customer Info"];
        var cId = component.get("v.recordId");
        var result = event.getParam("wrapperlist");
        var tskId = event.getParam("taskId");
        console.log(result);
        console.log('tskId@@@@'+tskId);
        console.log('cId@@@@'+cId);
        if( result != "undefined" && result != null && result != "" ){
            for (var i = 0; i < result.length; i++) {
                console.log('result[i].resultTask.Id@@@@'+result[i].resultTask.Id);
                if(ApprovalTask.includes(result[i].resultTask.Process__c) && (tskId === cId || result[i].resultTask.Id === cId)){
                    result[i].recId = '/'+ result[i].resultTask.Id;
                    if (result[i].resultTask.Approval_Log__r) { 
                        result[i].Service =  result[i].resultTask.Approval_Log__r.CaseId__r.Case_Sub_Type__c;
                        result[i].caseNum =  result[i].resultTask.Approval_Log__r.CaseId__r.CaseNumber;
                        result[i].caseId = '/'+ result[i].resultTask.Approval_Log__r.CaseId__c;
                        result[i].ServiceDate = result[i].resultTask.Approval_Log__r.CaseId__r.Service_Date__c;
                        result[i].Outcome__c = result[i].resultTask.Outcome__c;
                        result[i].Subject = result[i].resultTask.Subject;
                    }
                    if(result[i].resultTask.Business_Rule__r.Name){
                        result[i].brName = result[i].resultTask.Business_Rule__r.Name;
                        result[i].brId = '/'+ result[i].resultTask.Business_Rule__c;
                    }
                }else if(vendorAvailabilityTask.includes(result[i].resultTask.Process__c) && (tskId === cId || result[i].resultTask.Id === cId)){
                    result[i].recId = '/'+ result[i].resultTask.Id;
                    result[i].Service = result[i].caseDetail.Case_Sub_Type__c;
                    result[i].caseNum =  result[i].caseDetail.CaseNumber;
                    result[i].caseId = '/'+ result[i].caseDetail.Id;
                    result[i].ServiceDate = result[i].caseDetail.Service_Date__c ;
                    result[i].Proposed_Service_Date__c = result[i].resultTask.Proposed_Service_Date__c;
                    result[i].Outcome__c = result[i].resultTask.Outcome__c;
                    result[i].Subject = result[i].resultTask.Subject;
                }else if(customerInfo.includes(result[i].resultTask.Process__c)  && (tskId === cId || result[i].resultTask.Id === cId)){
                    result[i].recId = '/'+ result[i].resultTask.Id;
                    result[i].caseNum =  result[i].caseDetail.CaseNumber;
                    result[i].caseId = '/'+ result[i].caseDetail.Id;
                    result[i].PurchaseOrder_Number__c = result[i].resultTask.PurchaseOrder_Number__c;
                    result[i].Profile_Number__c = result[i].resultTask.Profile_Number__c;
                    result[i].Description__c = result[i].resultTask.Description__c;
                    result[i].Outcome__c = result[i].resultTask.Outcome__c;
                    result[i].Subject = result[i].resultTask.Subject;
                }
            }
            component.set('v.tasklist',result);
        }
    }*/
})