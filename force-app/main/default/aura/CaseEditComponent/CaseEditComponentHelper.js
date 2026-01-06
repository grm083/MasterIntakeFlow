({
    getRecordtypeList : function(component,event,handler) {
        var action = component.get("c.fetchRecordTypeValues");
        action.setParams({
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp=get reocdtype list=='+resp+'Sstate==='+state);
            if(state == 'SUCCESS'){
                var opts=[];
                opts.push('--Select--'); 
                for(var i=0;i<resp.length;i++){
                    opts.push(resp[i]);
                }
                console.log('opts===='+opts);
                component.set("v.recordtypeList",opts);    
                console.log('record typelist==='+component.get("v.recordtypeList"));
            }
        });
        $A.enqueueAction(action);
    },
    getCaseRecordtypeId : function(component,event,helper) {
		
        var action = component.get("c.getCaseRecordtyeIdfromCase");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            //alert('rsp==='+JSON.stringify(resp));
            if(state == 'SUCCESS'){				
                component.set("v.recordTypeName",resp);
				var recordType = component.get("v.recordTypeName");		
                helper.decideVisibility(component,recordType);
            }
        });
        $A.enqueueAction(action);
    },
    decideVisibility : function(component,recordType){
        component.set("v.pickUp",false);
        component.set("v.repair",false);
        component.set("v.newService",false);
        component.set("v.standardCase",false);
        component.set("v.changeAssetCase",false);
        component.set("v.siteSurveyCase",false);
        if(recordType == 'Service Request' || recordType == 'Email Case'){
            component.set("v.pickUp",true);
        }
        else  if(recordType == 'Repair Case'){
            component.set("v.repair",true);
        }	
        else  if(recordType == 'New Service Case'){
            component.set("v.newService",true);
        }
        else  if(recordType == 'Standard Case' || recordType == 'Interruption Case'){
            component.set("v.standardCase",true);
        }
        else  if(recordType == 'Add/Change Case'){
            component.set("v.changeAssetCase",true);
        }
        else  if(recordType == 'Site Survey Case'){
            component.set("v.siteSurveyCase",true);
        }
        
    },
    getCaseRecordtypeIdByName : function(component,event,helper) {
        var action = component.get("c.getRecTypeId");
        var recordType = component.get("v.recordTypeName");
        console.log('recd type name==='+component.get("v.recordTypeName"));
        action.setParams({
            "recordTypeName" : recordType
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            component.set("v.spinner",false);
           // alert('rsp==='+JSON.stringify(resp));
            if(state == 'SUCCESS'){
                component.set("v.recordTypeId",resp);	
                 helper.decideVisibility(component,recordType);
            }
        });
        $A.enqueueAction(action);
    },
    toggleAction : function(component, event, secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },

})