({
        doInit : function(component, event, helper) {          
            helper.getCaseDetails(component,helper);
            //helper.fetchOriginPicklist(component,event,'caseorigin');
        },
        
        enableBtnAgn : function(component, event, helper){
            console.log(component.get("v.caseOrigin"));
        if(component.get("v.availableOptions").includes(component.get("v.caseOrigin")) || component.get("v.caseOrigin")==undefined){
            component.set('v.saveEnabled',false);
            //component.find("caseorigin").set("v.disabled", false);
            }
            else{
                component.set('v.saveEnabled',true);
                //component.find("caseorigin").set("v.disabled", true);
            }
             //$A.get('e.force:refreshView').fire();
        },
       
        
        recordUpdated : function(component, event, helper){
        var cId = component.get("v.recordId");
        var changeType = event.getParams().changeType;
        if(changeType == "CHANGED" || changeType == "LOADED" ){
            helper.getCaseDetails(component,helper);
            var recordTypeId = component.get("v.CaseDetails.RecordTypeId");
            //helper.fetchOriginPicklist(component,event,'caseorigin');
            component.find("recordLoader").reloadRecord();
            }
        },
        
        handleSaveRecord: function(component, event, helper){
            var origin= component.get("v.CaseDetails.Origin");
            var getCaseId= component.get("v.recordId");
            var action=component.get("c.callinvoke");
            action.setParams({"caseId":getCaseId,"originField":origin});
            action.setCallback(this, function(response) {
                if(response.getState() == "SUCCESS"){
                  helper.getCaseDetails(component);
                  $A.get('e.force:refreshView').fire();
                } 
                 
                });
                $A.enqueueAction(action);
            }  
 })