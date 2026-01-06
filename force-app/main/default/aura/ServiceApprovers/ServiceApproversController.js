({
	
    handleServiceApproverEvent : function(component, event, helper) {
		var approverInfo = event.getParam("serviceApprovers");
        if(approverInfo && component.get("v.recordId")===event.getParam("caseId")){
            
            component.set("v.showErrorSA",false);
            component.set("v.SAlist",approverInfo);
            
        }
},
    doInit : function(component, event, helper) {
		var fetchSAEvt = $A.get("e.c:FetchServiceApproverEvent");
        fetchSAEvt.setParams({ "callServiceApprover" : true ,"caseId" : component.get("v.recordId")});
        fetchSAEvt.fire();
	},
})