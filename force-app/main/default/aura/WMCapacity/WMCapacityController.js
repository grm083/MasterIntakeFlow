({
	init : function(cmp, event, helper) {
        
        //Get today's date and pass it into the component
        cmp.set('v.today', $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"));
        
        helper.getAcornBaseline(cmp, event);
	},
    closeModal : function(cmp, event, helper) {
		helper.confirmCheck(cmp, event);
        
	},
    handleReceiveMessage : function(component, event, helper) {
        
    },
    handleDate : function(cmp, event, helper) {
         cmp.set("v.loadingSpinner", true);
        var selectedDate = event.getSource().get('v.label');
        console.log(selectedDate);
        cmp.set('v.selectedDate', selectedDate);
        if (selectedDate != null) {
            cmp.set('v.loaded', true);
            helper.updateCase(cmp, event);
        } else {
            alert('You must select a date prior to pressing save');
        }
        
         cmp.set("v.loadingSpinner", false);        
    }
})