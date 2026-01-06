({
    getBusinessRules: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get('c.getBusinessRulesData');
        
        action.setParams({"recordId" : recordId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state : ' + state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var brValues = [];
                for (var i = 0; i < result.length; i++) {
                    brValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                //console.log('brOptions : ' + JSON.stringify(response.getReturnValue()));
                component.set("v.options", result);
                component.set("v.brOptions", brValues);
            }
        });
        $A.enqueueAction(action);
        /*var items = [];
        for (var i = 0; i < 15; i++) {
            var item = {
                "label": "Option " + i,
                "value": "opt" + i
            };
            items.push(item);
        }
        cmp.set("v.options", items);
        // "values" must be a subset of values from "options"
        cmp.set("v.values", ["opt10", "opt5", "opt7"]); */
    },
    
    saveOutofOffice: function (component, event, helper) {
        var businessRulesList = [];
        businessRulesList = component.get("v.values");
        var checkboxValue = component.find("checkboxId").get("v.checked");
        console.log('businessRulesList : ' + businessRulesList);
        if(!checkboxValue && businessRulesList.length == 0){
            var message = "Please select applicable Business Rule(s) before saving.";
            this.showMessageEmptyError(component, event, helper,message);
        }else{
            if(checkboxValue){
                this.saveAllBRs(component, event, helper);
            }else{
                var recordId = component.get("v.recordId");
                var action = component.get('c.updateOutofOfficeRecord');
                action.setParams({"recordId" : recordId,
                                  "selectedBusinessRules": businessRulesList});
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log('state : ' + state);
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        var errorMessagelabel = $A.get("$Label.c.OOODuplicateErrorMessage");
                        if(result !=null && result == errorMessagelabel){
                            console.log('result :: '+result);
                        	this.showMessageEmptyError(component, event, helper,result);
                        }else{
                            this.showMessageAndCloseAction(component, event, helper);
                        	$A.get('e.force:refreshView').fire();
                        }
                    }/*else{
                        var errroMessageResult = response.getReturnValue();
                        console.log('errroMessageResult :: '+errroMessageResult);
                        this.showMessageEmptyError(component, event, helper,errroMessageResult);
                    }*/
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    showMessageAndCloseAction: function(component, event, helper) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": "Success",
            "message": "Record has been updated successfully"
        });
        resultsToast.fire();
        
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
    showMessageEmptyError: function(component, event, helper,message) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": "Error",
            "message": message
        });
        resultsToast.fire();
	},
    
    saveAllBRs: function (component, event, helper) {
       /* var businessRulesList = [];
        businessRulesList = component.get("v.options");
        var allBusinessRulesList = [];
        for (var i = 0; i < businessRulesList.length; i++) {
            allBusinessRulesList=businessRulesList[i];
        }*/
        var recordId = component.get("v.recordId");
        var action = component.get('c.updateOutofOfficeRecord');
        action.setParams({"recordId" : recordId,
                          "selectedBusinessRules": component.get("v.options")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state : ' + state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var errorMessagelabel = $A.get("$Label.c.OOODuplicateErrorMessage");
                if(result !=null && result == errorMessagelabel){
                    console.log('result :: '+result);
                    this.showMessageEmptyError(component, event, helper,result);
                }else{
                    this.showMessageAndCloseAction(component, event, helper);
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    onhandleChange : function (component, event, helper) {
        var businessRulesList = [];
        businessRulesList = component.get("v.values");
        var checkboxValue = component.find("checkboxId").get("v.checked");
        if(businessRulesList.length > 0 && checkboxValue){
            component.find("checkboxId").set("v.checked",false);
        }
    }
    
})