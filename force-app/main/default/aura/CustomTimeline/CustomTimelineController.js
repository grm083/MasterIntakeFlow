({
    navigateUser : function(component, event, helper) {
        var objRecord = component.get("v.item");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+objRecord.User__c
        });
        urlEvent.fire();
    },
    navigateRecord : function(component, event, helper) {
        var objRecord = component.get("v.item");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+objRecord.Related_Record_Id__c
        });
        urlEvent.fire();
    }
})