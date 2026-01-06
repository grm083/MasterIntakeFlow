({
	doInit : function(component, event, helper) {
        var caseClone = component.get("v.caseClone");
        //alert('caseClone----'+caseClone);
        if(caseClone == false || caseClone == 'caseClone'){
            //alert('caseNumber inside');
            helper.getCaseNumber(component, event, helper);
        }
	},
    cancelButton :  function(component, event, helper) {
        var modalBox = component.find("modalBox");
        $A.util.addClass(modalBox,'slds-hide');
        $A.get("e.force:closeQuickAction").fire()
    }
})