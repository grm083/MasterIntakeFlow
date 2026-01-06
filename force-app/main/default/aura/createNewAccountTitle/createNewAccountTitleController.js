({
	closeModal : function(cmp, event) {
		cmp.destroy();
	},
    handleSave : function(cmp, event, helper) {
        var titleVal = cmp.get('v.titleVal');
        
        if(titleVal != undefined && titleVal.trim() != ''){
        helper.newTitle(cmp, event);
        cmp.getEvent("createNewAccountTitleEvt").setParams({
            titleId : cmp.get('v.newTitle'),
            titleName : cmp.get('v.titleVal')
        }).fire();
        cmp.destroy();
        }
    }
})