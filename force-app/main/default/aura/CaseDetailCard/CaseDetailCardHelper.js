({
    fetchOriginPicklist : function(component,event,elementId){
        var caseId = component.get("v.recordId");
        var action = component.get("c.getselectOptions");
        var caseDetailsOrigin = component.get("v.CaseDetails.Origin");
        console.log(caseDetailsOrigin);
        action.setParams({
            "caseId" : caseId
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                component.set("v.availableOptions",allValues);
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "External System",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    if(allValues[i]===caseDetailsOrigin){
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i],
                            selected : true
                        });
                    }
						else{
                            opts.push({
                                class: "optionClass",
                                label: allValues[i],
                                value: allValues[i]
                            });
                        }
                }
                if(caseDetailsOrigin && !allValues.includes(caseDetailsOrigin)){
                    opts.push({
                            class: "optionClass",
                            label: caseDetailsOrigin,
                            value: caseDetailsOrigin,
                            selected : true
                        });
                    component.set("v.saveEnabled",true);
                    component.find(elementId).set("v.disabled", true);
                }
                component.find(elementId).set("v.options", opts);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getCaseDetails : function(component,helper) {
        var caseId = component.get("v.recordId");
        var action = component.get('c.getCaseDetails');
        action.setParams({"caseId" : caseId});
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
            var data = response.getReturnValue(); 
            component.set('v.CaseDetails',data);
            component.set("v.caseOrigin",data.Origin);
            this.fetchOriginPicklist(component,event,'caseorigin');
            if(data.Status==='New'){
                component.set("v.saveEnabled",false);
                //component.find("caseorigin").set("v.disabled", false);
            }
            else{
                component.set("v.saveEnabled",true);
                component.find("caseorigin").set("v.disabled", true);  
            }
            
            }
        });
        $A.enqueueAction(action);
    }
})