({
	  closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
	},   
    recordUpdated: function(component, event, helper) {
        
    },
     navigate : function(component, event, helper) {
        component.set("v.showForm",false);
    },
    openSetSlaCompFromPlanner:function(component, event, helper) {        
        component.set("v.isModalOpenServiceDate",true);       
        component.set("v.isOpenSetCaseDateComp",true);        
        component.set("v.isOpenWMCapacityComp", false);
		var isAvailDate = event.getParam("isAvailDate");
        var isDateNotListed = event.getParam("isOpenSLAComp");
        component.set("v.isAvailDate",isAvailDate);
        component.set("v.isDateNotListedCl",isDateNotListed);		
},
    
    doInit:function(component, event, helper) {
        // call visibility methods
        // set the visibility of components
        component.set("v.loadingSpinner", true);
        component.set("v.isModalOpenServiceDate", true);     
        helper.SetMultiDateVisibility(component,helper);
        helper.SetWMCapacityVisibility(component,helper);        
    },
    
    handleServDateClick:function(component, event, helper) {        
        component.set("v.isModalOpenServiceDate", true);
        component.set("v.isOpenMultiDateComp", false);
    },
    
    handleMultiDateClick:function(component, event, helper) {        
        component.set("v.isOpenMultiDateComp", true);
        component.set("v.isModalOpenServiceDate", false);
    },
})