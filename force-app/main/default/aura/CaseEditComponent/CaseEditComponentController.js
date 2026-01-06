({
    doInit:function(component, event, helper) {
        helper.getRecordtypeList(component, event, helper);
    },
    save : function(component, event, helper) {
        component.set("v.spinner",true);
        helper.getCaseRecordtypeIdByName(component, event, helper);
        
    },
    cancelBtn :  function(component, event, helper) {
        var cmpEvent = component.getEvent("closeModalBoxEvent");
        
        cmpEvent.fire();
    },
    saveResult : function(component, event, helper) {
        //component.set("v.spinner",true);
        alert('save success');
      //  var modalBox = component.find("modalBox");
        //alert(modalBox);
       // $A.util.addClass(modalBox,'slds-hide');
       // $A.get("e.force:closeQuickAction").fire();
        //alert('recId---'+component.get("v.recordId"));
        var cmpEvent = component.getEvent("BoxEvent"); 
        cmpEvent.fire();
        var payload = event.getParams().response;
        //alert(payload.id);
        var navService = component.find("navService");
    
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": payload.id,
                "objectApiName": 'Case',
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
        
        
      
       /* var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        urlEvent.fire();*/
        
    },
    handleLoad : function(component,event,helper){
        component.set("v.spinner",false);
        var loadCmp = component.get("v.loadCmp");
        //alert('loadcmp==='+loadCmp);
        if(loadCmp == true || loadCmp == 'true'){
            //alert('inside load');
            helper.getCaseRecordtypeId(component,event,helper);
            component.set("v.loadCmp",false);
        }
    },
    recordTypeChange : function(component,event,helper){       
        
        var recordType  = component.find("recordtypeId").get("v.value");		
		component.set('v.recordTypeName',recordType);
        helper.decideVisibility(component,recordType);
		console.log('changed recordType----'+component.get("v.recordType"));
        helper.getCaseRecordtypeIdByName(component, event, helper);
    },
    toggleMethod : function(component, event, helper) {
        helper.toggleAction(component, event, 'panelOne');
    },
})