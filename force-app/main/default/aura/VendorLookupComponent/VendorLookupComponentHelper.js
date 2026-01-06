({
    searchVendor : function(cmp) {
        var searchTerm = cmp.find('vendorSearch').get('v.value');
        if (searchTerm.length < 2) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                'title': 'Broad Search Warning',
                'message': 'Please ensure you are search for at least 2 characters to prevent querying too many records',
                'mode': 'dismissable'
            });
            toastEvent.fire();
        } else {
            var searchAction = cmp.get('c.searchVendors');
            searchAction.setParams({
                searchString : searchTerm
            });
            searchAction.setCallback(this, function(response) {
                cmp.set('v.vendorInfo', '[]');
                var state = response.getState();
                if (state === 'SUCCESS') {
                    cmp.set('v.vendorInfo', response.getReturnValue());
                };
            });
            $A.enqueueAction(searchAction);
        }
    }
})