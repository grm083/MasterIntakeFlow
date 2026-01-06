({
	doInit : function(component, event, helper) {
		helper.getAssetServiceHelper(component, event, helper);
	},
    handleSelectAllAsset : function(component, event, helper){        
        helper.handleSelectAllHelper(component, event, helper);
    },
    handleSelectedAsset : function(component, event, helper){
        helper.handleSelectedAssetHelper(component, event, helper);
    },
    onChangeSave : function(component,event,helper){
        var checkBox = component.find("availableAsset");
        var show;
        if(!Array.isArray(checkBox)){
            if (checkBox.get("v.value") == true) {
                show = true;
            }
        }else{
            for(var i=0; i<checkBox.length; i++){
                if(checkBox[i].get("v.value")){
                    show = true;
                    break;
                }
            }
        }
        if(show){
            component.set("v.showSave",false);
        }else{
            component.set("v.showSave",true);
        }
    },
    closeModel : function(component, event, helper) {
		component.set("v.selectAsset",false);
	}
       
})