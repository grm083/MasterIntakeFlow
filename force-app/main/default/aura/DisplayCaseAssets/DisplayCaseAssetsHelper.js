({
    fetchData : function(component, event, helper) {
        var instance = component.get("c.getCaseAsset");
        instance.setParams({
            "caseId" : component.get("v.recordId"),
            "showForm": true
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var returnVal = response.getReturnValue();
                if(returnVal != "undefined" && returnVal != null && returnVal != ""){
                    component.set("v.caseAssetLst",response.getReturnValue());
                }                    
            } 
        });
        $A.enqueueAction(instance);
    },
    onChangeReasonCodeHelper: function(component, event, helper) {
        component.set('v.isError', false);
        var caseAssetLst = component.get("v.caseAssetLst");       
        for(var i=0; i<caseAssetLst.length; i++){
        	if(caseAssetLst[i].Reason_Code__c == 'OTHR' && (caseAssetLst[i].Reason_Description__c == "undefined" ||
              caseAssetLst[i].Reason_Description__c == "" || caseAssetLst[i].Reason_Description__c == null)){
                component.set('v.errorMsg', 'Reason Description is mandatory when you select Reason Code as Other');
                component.set('v.isError', true);
            } 
        }  
    },
    onChangeClientPriceHelper: function(component, event, helper) {
        var clientPrice = event.getParam("value");
        var currentRowId = event.target.attributes[2].textContent;
        var caseAssetLst = component.get("v.caseAssetLst");
        if(caseAssetLst[currentRowId].Occurrence__c != 'Scheduled'){
            var originalClientPrice = caseAssetLst[currentRowId].AssetId__r.Price__c
            component.set('v.warningMsg', 'You are about to adjust the cost/price of this work order from '+originalClientPrice+'  to '+clientPrice+'. If this is correct, hit Save. If you need to update this, select cancel to make necessary corrections');
            component.set('v.isWarning', true);
        }
        
    },
    handleSaveHelper : function(component, event, helper) {
        component.set('v.isWarning', false);
		var caseAssetLst = component.get("v.caseAssetLst");
        var isError = component.get("v.isError");
        if(!isError){
        	var action = component.get("c.updateCaseAsset");
            action.setParams({
                "caseAssetLst" : caseAssetLst
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(response.getState() == "SUCCESS"){
                    $A.get('e.force:refreshView').fire(); 
                    component.set("v.showForm",false);
                } else {
                    var errors = action.getError();
                    if(errors) {
                        if(errors[0] && errors[0].message) {
                            component.set('v.quantityErrorMsg', errors[0].message);
                    		component.set('v.isQuantityError', true);
                        }
                    }   
                }
            });
            $A.enqueueAction(action);    
        }
    },
})