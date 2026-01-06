({
    doInit : function(component, event, helper) {
        var taskId = component.get("v.recordId");
        var action = component.get('c.getTaskList');
        action.setParams({
            "taskId" : taskId,
            "isPopUp" : true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                if( result != "undefined" && result != null && result != ""){
                    if(result.wrapperlist != "undefined" && result.wrapperlist != null && result.wrapperlist != ""){
                        component.set('v.wrapperlist',result.wrapperlist);
                        component.set('v.showPopup',true);
                    }
                    if(result.multiCaseTask.Process__c != "undefined" && result.multiCaseTask.Process__c != null && result.multiCaseTask.Process__c != ""){
                        if(result.multiCaseTask.Process__c === "Multi Case Approval Task" || result.multiCaseTask.Process__c === "Escalation Obtain Service Approval" || result.multiCaseTask.Process__c === "Obtain Service Approval"){
                            if(result.multiCaseTask.Process__c === "Multi Case Approval Task" || result.multiCaseTask.Process__c === "Escalation Obtain Service Approval"){
                                var options = [];
                                options.push({'label': 'Request Approved', 'value': 'Approved'});
                                options.push({'label': 'Request Not Approved', 'value': 'Rejected'});
                                component.set('v.options',options);
                            }
                            component.set('v.process','Approval');
                        }else if(result.multiCaseTask.Process__c === "Obtain Customer Info" || result.multiCaseTask.Process__c === "Escalation Obtain Customer Info"){
                            component.set('v.process','CustomerInfo');
                            var options = [];
                            options.push({'label': 'Information Obtained', 'value': 'Information Obtained'});
                            options.push({'label': 'Information Not Obtained', 'value': 'Information Not Obtained'});
                            component.set('v.options',options);
                        }else if(result.multiCaseTask.Process__c === "Escalation Confirm Vendor Availability" || result.multiCaseTask.Process__c === "Confirm Vendor Availability"){
                            component.set('v.process','VendorInfo');
                            var options = [];
                            if(result.multiCaseTask.Process__c === "Escalation Confirm Vendor Availability"){
                                options.push({'label': 'Vendor Available', 'value': 'Vendor Available'});
                                options.push({'label': 'Vendor Unavailable', 'value': 'Vendor Unavailable'});
                            }else{
                                options.push({'label': 'No Response/Pending Response', 'value': 'No Response/Pending Response'});
                                options.push({'label': 'Vendor Available', 'value': 'Vendor Available'});
                                options.push({'label': 'Vendor Unavailable', 'value': 'Vendor Unavailable'});
                                console.log(options);
                            }
                            component.set('v.options',options);
                        }
                    }
                    console.log('result.emailMsg'+result.emailMsg);
                    if( result.emailMsg != "undefined" && result.emailMsg != null && result.emailMsg != ""){
                    	component.set('v.emailMsg',result.emailMsg);
                        component.set('v.showEmail',true);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "showPopup" attribute to "False"  
        component.set("v.showPopup", false);
    },
    profileNumUpdate: function (component, event) {
        var val = event.getSource().get("v.value");
        var tskid = event.getSource().get("v.class")
        var arrayMapKeys = [];
        arrayMapKeys = component.get("v.profileoutput");
        var keys = [];
        //keys = component.get("v.index");
        for(var i=0 ; i<arrayMapKeys.length;i++){
            keys.push(arrayMapKeys[i].key);
        }
        if(keys.includes(tskid)){
            var index = keys.indexOf(tskid);
            arrayMapKeys.splice(index, 1);
            keys.splice(index, 1);
        }
        arrayMapKeys.push({value:val, key:tskid});
        component.set("v.profileoutput",arrayMapKeys);
    },
    poNumUpdate: function (component, event) {
        var val = event.getSource().get("v.value");
        var tskid = event.getSource().get("v.class")
        var arrayMapKeys = [];
        arrayMapKeys = component.get("v.pooutput");
        var keys = [];
        for(var i=0 ; i<arrayMapKeys.length;i++){
            keys.push(arrayMapKeys[i].key);
        }
        //keys = component.get("v.index");
        if(keys.includes(tskid)){
            var index = keys.indexOf(tskid);
            arrayMapKeys.splice(index, 1);
            keys.splice(index, 1);
        }
        arrayMapKeys.push({value:val, key:tskid});
        component.set("v.pooutput",arrayMapKeys);
    },
    proDateUpdate: function (component, event) {
        var val = event.getSource().get("v.value");
        var tskid = event.getSource().get("v.class")
        var arrayMapKeys = [];
        arrayMapKeys = component.get("v.proDateoutput");
        var keys = [];
        //keys = component.get("v.index");
        for(var i=0 ; i<arrayMapKeys.length;i++){
            keys.push(arrayMapKeys[i].key);
        }
        if(keys.includes(tskid)){
            var index = keys.indexOf(tskid);
            arrayMapKeys.splice(index, 1);
            keys.splice(index, 1);
        }
        arrayMapKeys.push({value:val, key:tskid});
        component.set("v.proDateoutput",arrayMapKeys);
    },
    handleSave: function (component, event, helper) {
        var draftValues = component.get("v.selectedOutcomes");
        var wrlst = component.get("v.wrapperlist");
        var tsklst = [];
        var taskId = component.get("v.recordId");
        for(var wr =0 ; wr < wrlst.length; wr++ ){
            tsklst.push(wrlst[wr].resultTask);
        }
        console.log('draftValues@@'+draftValues);
        console.log('tsklst@@'+tsklst);
        if(tsklst.length != draftValues.length){
            alert('Please ensure to choose all the Outcome before clicking on Save.');
            event.stopPropagation();
        }else {
            var arrayMapKeys = [];
            var arrprofile = [];
            var arrpo = [];
            var arrproDate = [];
            arrayMapKeys = component.get("v.selectedOutcomes");
            arrprofile = component.get("v.profileoutput");
            arrpo = component.get("v.pooutput");
            arrproDate = component.get("v.proDateoutput");
            var process = component.get("v.process");
			for (const [key, value] of arrayMapKeys.entries()) {
				for(var i=0 ; i < tsklst.length; i++){
					if(arrayMapKeys[key].key === tsklst[i].Id){
						tsklst[i].Outcome__c = arrayMapKeys[key].value;
					}
				}
			}
			if( process === 'CustomerInfo' ){
                for(const [key, value] of arrprofile.entries()){
                    for(var i=0 ; i < tsklst.length; i++){
                        if(arrprofile != "undefined" && arrprofile != null && arrprofile != "" && arrprofile[key].key === tsklst[i].Id){
                            tsklst[i].Profile_Number__c = arrprofile[key].value;
                        }
					}
				}
				for(const [key, value] of arrpo.entries()){
                    for(var i=0 ; i < tsklst.length; i++){
                        if(arrpo != "undefined" && arrpo != null && arrpo != "" && arrpo[key].key === tsklst[i].Id){
                            tsklst[i].PurchaseOrder_Number__c = arrpo[key].value;
                        }
                    }
                }
            }else if(process === 'VendorInfo'){
                for(const [key, value] of arrproDate.entries()){
                    for(var i=0 ; i < tsklst.length; i++){
                        if(arrproDate != "undefined" && arrproDate != null && arrproDate != "" && arrproDate[key].key === tsklst[i].Id){
                            tsklst[i].Proposed_Service_Date__c = arrproDate[key].value;
                        }
                    }
                }
            }
            var action = component.get('c.populateOutcome');
            action.setParams({
                "drafTasklst" : tsklst,
                "taskId" : taskId
            });
            action.setCallback(this, function(response) {
                for(var wr =0 ; wr < tsklst.length; wr++ ){
                    wrlst[wr].resultTask = tsklst[wr];
                }
                var state = response.getState();
                console.log(response.getReturnValue());
                var evt = $A.get("e.c:updateMultiTaskTable");
                var toastEvent = $A.get("e.force:showToast");
                //evt.setParams({"wrapperlist" : wrlst,"taskId" : taskId});
                
                if (state == "SUCCESS" && response.getReturnValue() === 'Success') {
                    component.set("v.showPopup", false);
                    component.set("v.process", "");
                    component.set("v.selectedOutcomes", "");
                    component.set("v.proDateoutput", "");
                   	component.set("v.profileoutput", "");
                    component.set("v.pooutput", "")
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The records has been updated successfully.",
                        "type": "success"
                    });
                }else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue(),
                        "type": "error"
                    }); 
                }
                evt.fire();
                toastEvent.fire();
            });
            $A.enqueueAction(action);
        }
    },
    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var val = event.getParam("value");
        var item = event.getSource().get("v.label");
        var arrayMapKeys = [];
        arrayMapKeys = component.get("v.selectedOutcomes");
        var keys = [];
        keys = component.get("v.index");
        if(keys.includes(item)){
            var index = keys.indexOf(item);
            arrayMapKeys.splice(index, 1);
            keys.splice(index, 1);
        }
        keys.push(item);
        arrayMapKeys.push({value:val, key:item});
        component.set("v.selectedOutcomes",arrayMapKeys);        
    }
})