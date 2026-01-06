({
	myAction : function(component, event, helper) {
       // var taskRec = component.get("v.taskRecord");
       // if(((taskRec.Process__c == "Manually Dispatch" || taskRec.Process__c == "Rejected Work Order" || 
                    //	taskRec.Process__c == "Obtain Schedule Confirmation") && taskRec.Outcome__c == "Service Error") || 
                     //  (taskRec.Process__c == "Obtain Schedule Confirmation" && taskRec.Outcome__c == "Service Not Performed")) {
       // if(taskRec.Outcome__c == "Service Error"){    
        helper.callApex(component, event, helper);
        helper.callValidateOutcome(component, event, helper);
        },
	//},
    navigateToCase : function(component, event, helper) {
       helper.navigateToCaseDetail(component, event, helper);                      
	},
       cancelAction : function(component, event, helper) {
		component.destroy();
    },
})