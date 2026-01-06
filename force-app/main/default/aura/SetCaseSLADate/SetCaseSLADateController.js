({
	doInit : function(component, event, helper) {
        helper.callApex(component, event, helper);
    },
	closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
	},
    handleReceiveMessage : function(component, event, helper) {
        
    },
    handleSuccess : function(component, event, helper) {
        var parentId = component.get("v.parentId");
        if(parentId != "undefined" && parentId != null && parentId != ""){
            var caseId = parentId;
            const payload = {
                caseId: caseId,
            };
            console.log('payload'+payload);
            component.find("lmschannel").publish(payload);
        }
        component.set("v.showForm",false);
        component.set("v.closeParent",false) ;
        var appEvent = component.getEvent("SingleTabRefreshEvent");
        appEvent.setParams({ "reload" : "true" });
        appEvent.fire();
        $A.get('e.force:refreshView').fire();
	var updateEvent = new CustomEvent('caseUpdated', {
            detail: { caseId: component.get("v.recordId") }
        });
 
        window.dispatchEvent(updateEvent);
	},
    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        let isWMCapacity = component.get("v.isCapacityEligible");
        if(isWMCapacity){
            fields.Availability_Checked__c = true;
        }
        helper.handleFormSubmit(component,fields);
  //      component.find('recordViewForm').submit(fields);
         
        
    },
    handleError: function (component, event, helper) {
        component.set('v.loading', false);
        component.find('OppMessage').setError('Undefined error occured');
    },
})
