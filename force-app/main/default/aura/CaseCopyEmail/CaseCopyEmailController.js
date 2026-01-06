({
    cancelAction : function(component, event, helper) {
        component.set("v.showBox",false);
    },
    nullCheck : function(component, event, helper) {
        var btn = component.find("saveButton");
        if(component.get("v.selectedLookUpRecord").CaseNumber){
            btn.set("v.disabled",false);
        }
        else{
            btn.set("v.disabled",true);
        }
    },
     saveAction : function(component, event, helper){
         var toastEvent = $A.get("e.force:showToast");
         var ca = component.get("v.selectedLookUpRecord");
		     var btnaction = event.getSource().get("v.alternativeText");
         if(!$A.util.isEmpty(ca)){
             console.log('Inside lookup Action');
             var cmpEvent = component.getEvent("lookUpAction");
             cmpEvent.setParams({
                 "caseNumber" :  ca.CaseNumber,
                 "lookUpId" : ca.Id,
				 "action" : btnaction
             });
             cmpEvent.fire();
             component.set("v.showBox",false);             
         }else if(!$A.util.isEmpty(btnaction) && btnaction === 'Go Back'){
            var cmpEvent = component.getEvent("lookUpAction");
            cmpEvent.setParams({
                "caseNumber" :  null,
                "lookUpId" : null,
                "action" : btnaction
            });
            cmpEvent.fire();
            component.set("v.showBox",false);
         }else{
               toastEvent.setParams({
                        "title": "Warning!",
                        "message": $A.get("$Label.c.NO_CASE_SELECT"),
                        "type": "warning"
                    });
             toastEvent.fire();
         }   
    }
})