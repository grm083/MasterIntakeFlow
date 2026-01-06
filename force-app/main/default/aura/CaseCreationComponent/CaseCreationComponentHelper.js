({
    //get the list of record types for case
	getRecordTypeList : function(component){
        var action = component.get("c.getCaseRecordTypes");
        action.setCallback(this, function(response) {
            var retval = response.getReturnValue();         
            /*Request to reorder starts here*/
            
            var caseRecordTypeOrder=$A.get("$Label.c.CaseRecordType");       
            
            var properOrder = caseRecordTypeOrder.split('|');
            var newOrder = component.get('v.recordTypeList');
            for (var x in properOrder) {
                for (var i in retval) {
                    if (retval[i].Name == properOrder[x]) {
                        newOrder.push(retval[i]);
                        break;
                    } else if (i == retval.length) {
                        newOrder.push(retval[i]);
                    }
                }
            }
            component.set('v.recordTypeList', newOrder);
            /*Request to reorder ends here*/
            
            //component.set('v.recordTypeList',retval);
    		});  
        $A.enqueueAction(action);
    },
    
    createCase : function(component){
        var recordId = component.get("v.recordId");
    	var recordType = component.get("v.selectedRecordType");
        var action = component.get("c.customCaseCreation");
        var caseData = component.get('v.caseData');
        action.setParams({ recordtypeName :  recordType , recordId : recordId, caseTypeData : JSON.stringify(caseData)});   
        action.setCallback(this, function(response) {
            if(response.getReturnValue().success == true){
                $A.enqueueAction(component.get("c.cancelPopup"));
                var retval = response.getReturnValue().message;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : "/lightning/r/Case/"+retval+"/view"
                });
                urlEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getReturnValue().message,
                    "type": "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            component.set("v.IsSpinner" , false);
        });  
        $A.enqueueAction(action);
    },

    createCaseWithCopyData : function(component){
        var recordType = component.get('v.selectedRecordType');
        var copyOptions = component.get('v.selectedCopyOptions');
        var recordId = component.get('v.recordId');
        var emailIds = component.get('v.selectedEmails');
        var caseData = component.get('v.caseData');
        var action = component.get("c.CaseCreationwithCopyData");
        action.setParams({recordtypeName : recordType , recordId : recordId , copyoptions : copyOptions, emailIds : emailIds, caseTypeData : JSON.stringify(caseData)});
        action.setCallback(this, function(response) {
            var retvalue = response.getReturnValue().message;
            //console.log('returnVal -- ' + retvalue);
            if(response.getReturnValue().success == true){
                component.set("v.IsSpinner", false);
                var retval = response.getReturnValue().message;
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url" : "/lightning/r/Case/"+retval+"/view"
                });
                urlEvent.fire();
            }else{
                component.set("v.IsSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getReturnValue().message,
                    "type": "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);

    },

    getEmails: function(component){
        var caseId = component.get("v.recordId");
        var action = component.get("c.GetEmails");
        action.setParams({caseId : caseId})

        action.setCallback(this, function(response){
            var retVal = response.getReturnValue();
            //console.log('retVal!!! --- ' +retVal);
            component.set("v.emailData",retVal);
        });
        $A.enqueueAction(action);
    }
})