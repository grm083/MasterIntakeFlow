({
    doInit : function(component, event, helper) {
        if(component.get("v.caseStatus") == 'Open'){
            component.set("v.disableOpen",true);
        }
    },
	closeModel : function(component, event, helper) {
        component.set("v.showButtons",false);
    },
    
    openAction : function(component, event, helper) {
        helper.callController(component, event, helper, component.get("c.openCase"));
    },
    
    closeAction : function(component, event, helper) {
        helper.callController(component, event, helper, component.get("c.closeCase"));
    },
})