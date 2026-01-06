({
    cloneCase : function(component, event, helper) {
        helper.cloneCaseHelper(component,event,helper);
    },
    cancelButton :  function(component, event, helper) {
        component.set("v.isModalOpen", true);
        
      //  var modalBox = component.find("modalBox");
      // $A.util.addClass(modalBox,'slds-hide');
      // $A.get("e.force:closeQuickAction").fire();
    },
    subButton :  function(component, event, helper) {
       // component.set("v.isModalOpen", true);
        
        var modalBox = component.find("modalBox");
       $A.util.addClass(modalBox,'slds-hide');
       $A.get("e.force:closeQuickAction").fire();
    },
    yesBtn: function(component, event, helper) {
       // component.set("v.isModalOpen", false);
       // var modalBox = component.find("modalBox");
      //  $A.util.addClass(modalBox,'slds-hide');
      //  $A.get("e.force:closeQuickAction").fire();
       var id = component.get("v.childCase");
        var action = component.get("c.closedCloneCase");
       var cloneId = component.get("v.childCase");
        //alert("parentCase==="+parentCase);
        action.setParams({
            "recId" : cloneId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            
            var resp = response.getReturnValue();
            if(state == 'SUCCESS'){
                 var navService = component.find("navService");
    
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": cloneId,
                "objectApiName": 'Case',
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
            }    
       
     });
        $A.enqueueAction(action);
        component.set("v.isModalOpen", false);
         var modalBox = component.find("modalBox");
        $A.util.addClass(modalBox,'slds-hide');
        $A.get("e.force:closeQuickAction").fire();
    },
    noBtn: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    HideMe: function(component, event, helper) {
        component.set("v.ShowModule", false);
    },
    ShowModuleBox: function(component, event, helper) {
        component.set("v.ShowModule", true);
    },
    doInit : function(component, event, helper) {
        helper.getEmailMessageId(component,event,helper);
    },
})