({
    updateCase : function(component, event, helper) {
        var instance = component.get("c.updateSingleAssetCases");
        instance.setParams({
            "ignoreCheck" : component.get("v.ignore"),
            "caseComments" : component.get("v.comments"),
            "dupList" : component.get("v.MultiAssetWrapperList")
        });
        instance.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                //$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(instance);
    },
    
    searchHelper : function(component, event, helper) {
        var action = component.get("c.fetchMultiAssetWrapper");
          var caseDuplicateCheckEvent = $A.get("e.c:CaseDuplicateCheckEvent"); 
        action.setParams({
            "caseId" : component.get("v.currentCaseID")
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.showList", false);
                    caseDuplicateCheckEvent.setParams({"isDuplicate" : false});
                }else if (storeResponse.multiAssetWrapperList.length == 0){
                    component.set("v.showList", false);
                    caseDuplicateCheckEvent.setParams({"isDuplicate" : false}); 
                }
                    else{
                        component.set("v.showList", true);
                        caseDuplicateCheckEvent.setParams({"isDuplicate" : true}); 
                    }
                
                caseDuplicateCheckEvent.fire();
                
                component.set("v.MultiAssetWrapperList", storeResponse.multiAssetWrapperList);
                
                component.set("v.TotalNumberOfRecord", storeResponse.multiAssetWrapperList.length);
                
                if(storeResponse.multiAssetWrapperList.length != 0)
                {
                    var totalCases = [];
                    var wrapperList= component.get("v.MultiAssetWrapperList");
                    for(var i=0; i < wrapperList.length; i++){
                        var caseObj = wrapperList[i].caseID;
                        totalCases.push(caseObj);
                    }
                    
                    component.set('v.totalCaseIds',totalCases);
                    var unSelectedCases = component.get("v.totalCaseIds");
                    component.set('v.unSelectedCaseId',unSelectedCases);
                } 
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log(errors);
                } 
            }
            
        });
        $A.enqueueAction(action);
        
    },
    
    updateMultiCase :  function(component, event, helper) {
        
        var action = component.get("c.updateMultiAssetCases");
        action.setParams({
            "selectedCaseIds" : component.get("v.selectedCaseId"),
            "unSelectedCaseId" : component.get("v.unSelectedCaseId"),
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                //$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    closeDuplicatePopup : function(component, event, helper) {
        var duplicateCheckEvent = $A.get("e.c:DuplicateCheckClose"); 
        duplicateCheckEvent.fire();
        
    }
})