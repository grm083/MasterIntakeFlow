({
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "showPopup" attribute to "False"  
        component.set("v.showPopup", false);
    },
    showDetails: function(component,event,helper){
        const pop = component.get("v.showPopup");
        if(pop){
            component.set("v.showPopup", false);
            var cmpTarget = component.find('phoneIconDiv');
           $A.util.removeClass(cmpTarget, 'actv');
        }else {
            component.set("v.showPopup", true);
           var cmpTarget = component.find('phoneIconDiv');
           $A.util.addClass(cmpTarget, 'actv');
        }
    },
    doinit : function(component, event, helper) {
        const screenPop = component.get("v.pop");
        console.log('screenPop'+$A.util.isEmpty(screenPop)+ 'ScreenPOP'+$A.util.isUndefined(screenPop));
        if($A.util.isEmpty(screenPop) || $A.util.isUndefined(screenPop)){
            var caseId = component.get("v.recordId");
            var action = component.get('c.getIvrDetails');
            action.setParams({
                "caseId" : caseId
            });
            action.setCallback(this, function(response) {
                const state = response.getState();
                const result = response.getReturnValue();
                console.log(state);
                console.log('Sticky Result'+JSON.stringify(result));
                if(!$A.util.isEmpty(state) && !$A.util.isEmpty(result) && !$A.util.isUndefined(result) && state == "SUCCESS"){
                    /*const rValue = JSON.parse(result);  
            component.set("v.IVRQueue", rValue.ivrQueue);
            component.set("v.IVRLanguage", rValue.ivrLang);
            component.set("v.IVRLOB", rValue.ivrLOB);*/
                component.set("v.pop", result); 
                component.set("v.showPopup", true);  
                component.set("v.showlogo", true);  
                var cmpTarget = component.find('phoneIconDiv');
                $A.util.addClass(cmpTarget, 'actv');
                helper.showFields(component);
            }else{
                component.set("v.showPopup", false);
            }
        });
            $A.enqueueAction(action);
        }
    }
})