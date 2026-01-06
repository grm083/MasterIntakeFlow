({
	doInit : function(component, event, helper) {
        component.set("v.showPopUpUI",true);
        helper.getBusinessRules(component, event, helper);
    },
    
    handleCloseModel : function(component,event,helper){
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    handleSaveRecord : function (component,event,helper){
        helper.saveOutofOffice(component,event,helper);  
    },
    
    onhandleChange : function(component,event,helper){
        helper.onhandleChange(component,event,helper);
    }
    
})