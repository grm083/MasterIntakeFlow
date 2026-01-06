({
    doInit : function(component,event,helper){
       // alert('doInit');  
       helper.getCaseNumberHelper(component,event,helper);
      //  helper.showPopupHelper(component, 'modaldialog', 'slds-fade-in-');
       // helper.showPopupHelper(component,'backdrop','slds-backdrop--');
    },
    cancelButton : function(component,event,helper){
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');        
    },
    toggleMethod : function(component, event, helper) {
        helper.toggleAction(component, event, 'panelOne');
    },

})