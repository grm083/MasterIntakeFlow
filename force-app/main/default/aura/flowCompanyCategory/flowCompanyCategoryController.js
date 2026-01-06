({
    doinit : function(cmp) {
        var items = [];
        var stringList = cmp.get('v.picklistValues');
        items.push({
            'label': '--None--',
            'value': ''
        });
        for (var i = 0; i < stringList.length; i++) {
            var item = {
                'label': stringList[i],
                'value': stringList[i]
            };
            items.push(item);
        }
        cmp.set('v.formattedValues', items);
    },
    
    onChange : function(cmp, event, helper) {
		var inputPicklist = cmp.find("inputDynamicPicklist");
		var selection = inputPicklist.get("v.value");
		cmp.set("v.selectedValue", selection);
	}
})
