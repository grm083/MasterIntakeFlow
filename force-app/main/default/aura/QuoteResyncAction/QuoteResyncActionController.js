({
	handleSaveRecord: function(component, event, helper) {
        component.set("v.recordQuote.Resubmit_Flag__c",true);
        //added as part of SDT-25114
        component.set("v.recordQuote.ErrorComments__c",null);
        component.set("v.recordQuote.Integration_Status__c",null);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('user ID :: '+userId);
        // Removed Last_Submitted_Modified_User__c from fields for Story 23394
        //component.set("v.recordQuote.Last_Submitted_Modified_User__c",userId);
        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            console.log("saveResult :: " + saveResult.state);
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                //console.log("Save completed successfully." );
                // record is saved successfully
                // show toast message on the top
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Saved",
                        "message": "The record was saved. Resync submit successfully."
                    });
                    resultsToast.fire();
                
                // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' +
                           JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
     }
})