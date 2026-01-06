({
	doinit : function(cmp, event, helper) {
		
	},
    handleEnter : function(cmp, event, helper) {
        cmp.set('v.selectedRecords', '[]');
        var enterKey = event.keyCode === 13;
        if (enterKey) {
            helper.searchVendor(cmp);
        }
    },
    handleClick : function (cmp, event, helper) {
        helper.searchVendor(cmp);
    },
    pushValues : function(cmp, event) {
        cmp.set('v.selectedRecords', '[]');
        var selection = event.getParam('selectedRows');
        cmp.set('v.selectedRecords', selection);
        if (selection.length != 0 ){
            cmp.set('v.productWrapper.vendorId', selection[0].Id);
            cmp.set('v.productWrapper.vendorName', selection[0].Name);
            cmp.set('v.productWrapper.vendorNumber', selection[0].AccountNumber);
            cmp.set('v.productWrapper.vendorBU', selection[0].Vendor_Business_Unit__c);
            cmp.set('v.productWrapper.parentVendorId', selection[0].Parent_Vendor_ID__c);
            cmp.set('v.productWrapper.vendorFacilityCode', selection[0].FacilityCode__c);
        }
    },
    saveVendor : function(cmp) {
        var updatedWrapper = cmp.get('v.productWrapper');
        var updateQLI = cmp.get('c.updateVendorDetails');
        updateQLI.setParams({
            headerRecord : updatedWrapper
        });
        updateQLI.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var closeSIDModalEvent = cmp.getEvent('CloseSIDModalEvent');
                closeSIDModalEvent.setParams({
                    "showModal" : "false"
                });
                closeSIDModalEvent.fire();
            }
        });
        $A.enqueueAction(updateQLI);
    }
})