({
	doinit : function(component, event, helper) {
		var empApi = component.find("empApi");
		var channel = '/event/Task_Create_Update_Event__e';
		var replayId = -1;
		var callback = function (message) {
            if(message.data.payload.CaseId__c == component.get('v.recordId')){
                helper.callApex(component, event, helper);
                helper.callTaskAssignmentPopup(component, event, helper);
            }
		}.bind(this);
        var errorHandler = function (message) {
            console.log("Received error ", message);
        }.bind(this);
        // Register error listener and pass in the error handler function.
        empApi.onError(errorHandler);
        //subscribe
        empApi.subscribe(channel, replayId, callback).then(function(value) {
            console.log("Subscribed to channel " + channel);
        });
        helper.callApex(component, event, helper);
	},
    refreshComp : function(component, event, helper) {
		var spin = component.find('spinner');
        $A.util.removeClass(spin,'slds-hide');
		helper.callApex(component, event, helper);
        helper.callTaskAssignmentPopup(component, event, helper);
	},
    hideSpinner : function(component, event, helper) {
        var spin = component.find('spinner');
        $A.util.addClass(spin, 'slds-hide');
    }
})