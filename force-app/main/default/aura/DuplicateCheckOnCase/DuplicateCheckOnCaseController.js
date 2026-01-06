({ 
    doInit : function(component, event, helper) {
        
        helper.searchHelper(component, event, helper);
        },
    
    ignoreAction : function(component, event, helper) {
        component.set("v.showList",false);
        component.set("v.showBox",true);
        var reason = component.find("igReason");
        $A.util.removeClass(reason, 'slds-hide');
        component.set("v.ignore",true); 
        helper.closeDuplicatePopup(component, event, helper);
    },
    
    closeAction : function(component, event, helper){
        component.set("v.showList",false);
        component.set("v.showBox",true);
        var cmnt = component.find("clsComments");
        $A.util.removeClass(cmnt, 'slds-hide');
        helper.closeDuplicatePopup(component, event, helper);
    },
    saveAction : function(component, event, helper){
        component.set("v.showBox",false);
        component.set("v.showList",false);
        helper.updateCase(component, event, helper);
        component.destroy();
        helper.closeDuplicatePopup(component, event, helper);
    },
    closeModel : function(component, event, helper){
        component.destroy();
        component.set("v.showList",false);
        component.destroy();
        helper.closeDuplicatePopup(component, event, helper);
    },
    
    nullCheck : function(component, event, helper) {
        var btn = component.find("saveButton");
        if(component.get("v.comments")){
            btn.set("v.disabled",false);
        }
        else{
            btn.set("v.disabled",true);
        }
    },
    
    getSelectedData : function(component, event, helper) {
        component.set("v.showList",false);
        var unSelectedCaseId = component.get('v.unSelectedCaseId');
        var selectedCaseId = component.get('v.selectedCaseId');
        helper.updateMultiCase(component, event, helper);
        component.destroy();
    },
    
    checkBoxClick : function(component, event, helper) {
        
        var case_id = event.currentTarget.dataset.value;
        var index = event.currentTarget.dataset.record;
        var caseIds = component.get('v.selectedCaseId');
        var unSelectedCases = component.get('v.unSelectedCaseId');
        
        if(caseIds.includes(case_id)){
            var index = caseIds.indexOf(case_id);
            if (index > -1) {
                caseIds.splice(index, 1);
            }
            unSelectedCases.push(case_id);
        }else{
            caseIds.push(case_id);
            var index = unSelectedCases.indexOf(case_id);
            if (index > -1) {
                unSelectedCases.splice(index, 1);
            }
        }
        component.set('v.selectedCaseId',caseIds);
        component.set('v.unSelectedCaseId',unSelectedCases);
        
    }     
})