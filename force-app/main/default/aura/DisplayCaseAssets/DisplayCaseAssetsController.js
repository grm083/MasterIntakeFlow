({
	initAction : function(component, event, helper) {
        helper.fetchData(component, event, helper);
	},
    onChangeClientPrice: function (component, event, helper) {
        helper.onChangeClientPriceHelper(component, event, helper);
    },
    closeModel : function(component, event, helper) {
        component.set("v.showForm",false);
    },
    onChangeReasonDescription: function (component, event, helper) {
        helper.onChangeReasonCodeHelper(component, event, helper);
    },
    handleSave: function (component, event, helper) {
        helper.onChangeReasonCodeHelper(component, event, helper);
        helper.handleSaveHelper(component, event, helper);
    }
})