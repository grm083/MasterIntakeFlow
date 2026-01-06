({
	callApex : function(component, event, helper) {
		var action = component.get('c.getRecordTypeId');
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.recordTypeId",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
	
	handleFormSubmit: function(component, event, helper) {
        var action = component.get('c.getcaseAssetDetails');
        var showValidationError = false;
        var vaildationFailReason = '';
        var eventFields = event.getParam("fields");        
        
            action.setParams({
                "caseId" : component.get("v.recordId"),
               
            });
            action.setCallback(this, function(response){
                if(response.getState() == "SUCCESS"){
                    var wrapper = response.getReturnValue();
					var newcasesubtype = eventFields["Case_Sub_Type__c"];
                    var newcasetype = eventFields["Case_Type__c"];
					                    
                   if(wrapper.length > 0 && wrapper[0].Asset > 0 && wrapper[0].Asset.ProductFamily && wrapper[0].Asset.ProductFamily === 'Rolloff' && !(wrapper[0].Asset.Equipment_Type__c === "Open Top" && wrapper[0].Asset.Duration__c === "Temporary") && (newcasesubtype != 'Empty and Return' && newcasesubtype != 'Empty and Do NOT Return' && newcasesubtype != 'Bale(s)'))
                   {
                    showValidationError = true; 
                    vaildationFailReason = "For Product Family RollOff we can only select Empty and Return,Empty And DO NOT Return and Bale(s)";
                   }
                   else if(wrapper.length > 0 && wrapper[0].Asset > 0 && wrapper[0].Asset.ProductFamily && wrapper[0].Asset.ProductFamily === 'Commercial' && wrapper[0].Asset.Equipment_Type__c !== "Hand Pickup" && (newcasesubtype != 'Extra Pickup' && newcasesubtype != 'On Call' && newcasesubtype != 'Bale(s)'))
                   {
                    showValidationError = true;
                    vaildationFailReason = "For Product Family Commercial we can only select Extra Pickup, On-Call and Bale(s)";      
                   } 
                   else 
                   {
                   showValidationError = false; 
                   } 
                   
                    if(!showValidationError){
                        component.set('v.showError', false);
                        component.find("recordViewForm").submit();
                        
                        }else{
                        component.set('v.showError', true);                            
                        component.set('v.caseMessage', vaildationFailReason); 
                        component.set('v.showForm', true); 
                        }
                }
            });
            $A.enqueueAction(action);
              
    }
})