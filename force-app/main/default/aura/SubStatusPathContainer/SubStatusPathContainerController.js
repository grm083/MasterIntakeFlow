({
    init : function(component, event, helper) {
		//var cId = component.get("v.recordId");
        //helper.createflowpath(component);
    },
    recordUpdated: function(component, event, helper) {
        helper.createflowpath(component);
    },
})