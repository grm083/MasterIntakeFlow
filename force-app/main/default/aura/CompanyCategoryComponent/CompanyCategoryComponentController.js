({
	doinit : function(cmp) {
		var ccs = cmp.get('v.productWrapper');
        var compCategories = [];
        for (var entry in ccs.companyCategories) {
            compCategories.push({value:ccs.companyCategories[entry], key:entry});
        }
        cmp.set('v.companyCategories', compCategories);
        window.setTimeout(
            $A.getCallback(function() {
                cmp.find('ccPicklist').set('v.value', ccs.companyCategory);
            }));
	},
    saveCC: function(cmp, event) {
		var selectedValue = cmp.find('ccPicklist').get('v.value');
        cmp.set('v.productWrapper.companyCategory', selectedValue);
        var action = cmp.get('c.updateCompanyCategories');
        action.setParams({
            headerRecord: cmp.get('v.productWrapper')
        });
        action.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var closeSIDModalEvent = cmp.getEvent('CloseSIDModalEvent');
                closeSIDModalEvent.setParams({
                    "showModal" : "false"
                });
                closeSIDModalEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})