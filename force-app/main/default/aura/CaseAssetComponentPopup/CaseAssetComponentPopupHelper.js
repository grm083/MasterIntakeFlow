({
    getAssetServiceHelper : function(component,event, helper) {
        //component.set("v.selectAsset",false);
        var action = component.get("c.serviceAssetDetail");
        var assetList =[];
        var assetString = '';       
        var recId = component.get("v.caseRecordId");
        
        action.setParams({
            "recId":recId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === "SUCCESS"){
                if(resp != null && resp != [] && resp != undefined && resp.length > 0){
                    component.set("v.AvailableCaseAssetList",resp);
                    //component.set("v.selectAsset",true);                
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    handleSelectAllHelper: function(component, event, helper) {
        var getID = component.get("v.AvailableCaseAssetList");
        var checkvalue = component.find("assetSelectAll").get("v.value");        
        var availableAsset = component.find("availableAsset"); 
        if(checkvalue == true){
            if(!Array.isArray(availableAsset)){
                availableAsset.set("v.value",true);
                component.set("v.showSave",false);    
            }else{
                for(var i=0; i<availableAsset.length; i++){
                    availableAsset[i].set("v.value",true);
                    component.set("v.showSave",false);
                }
            }
        }
        else{ 
            if(!Array.isArray(availableAsset)){
                availableAsset.set("v.value",false);
                component.set("v.showSave",true);    
            }else{
                for(var i=0; i<availableAsset.length; i++){
                    availableAsset[i].set("v.value",false);
                    component.set("v.showSave",true);
                }
            }
        }
    },
    
    handleSelectedAssetHelper: function(component, event, helper) {
        var selectedAssets = [];
        var availableAsset = component.find("availableAsset");
        var availableAssetList = component.get("v.AvailableCaseAssetList");
        var count = 0;
        if(!Array.isArray(availableAsset)){
            if (availableAsset.get("v.value") == true) {
                selectedAssets.push(availableAsset.get("v.text"));
            }
        }else{
            for (var i = 0; i < availableAsset.length; i++) {
                if (availableAsset[i].get("v.value") == true) {
                    selectedAssets.push(availableAsset[i].get("v.text"));
                }
            }
        }
        console.log('selectedAssets-' + selectedAssets);
        var assetCreateList = [];
        for(var i=0;i<availableAssetList.length; i++){
            if(selectedAssets.includes(availableAssetList[i].Id)){
                assetCreateList.push(availableAssetList[i]);
            }
        }
		
       
        component.set("v.selectedCaseAssetList",assetCreateList);
        this.createAssetHelper(component, event, helper,assetCreateList);
    
    },
    createAssetHelper: function(component, event, helper,selectedAssets) {
        component.set("v.spinner",true);
        var action = component.get("c.createAsset");
        action.setParams({
            "assetString" : JSON.stringify(selectedAssets),
            "CaseId" : component.get("v.caseRecordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state == 'SUCCESS'){
                helper.getAssetServiceHelper(component,event, helper);
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Service Detail added to Case Asset",
                    "type": "success"
                });
                toastEvent.fire();
                //helper.refreshFocusedTab(component);
                $A.get('e.force:refreshView').fire(); 
                //window.location.reload();
                
                
            }
            component.set("v.spinner",false);
            component.set("v.selectAsset",false);
        });
        $A.enqueueAction(action);
    },
    refreshFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var result = workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
            console.log('inside refresh tab');
            //alert('result==='+JSON.stringify(result));
        })
        
        .catch(function(error) {
            console.log(error);
        });
    }
})