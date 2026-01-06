({
    doInit : function(component, event, helper) {
        helper.callApex(component, event, helper);
	},
   
	closeModel : function(component, event, helper) {
		component.set("v.showForm",false);
	},
    handleSuccess : function(component, event, helper) {
		component.set("v.showForm",false);
        //$A.get('e.force:refreshView').fire();
	},
    
    handleOnChange : function(component, event, helper) {
        let selectedLabel = event.getParam('label');
        component.set("v.selectedLabel",selectedLabel);
        //console.log('selectedLabel value : ' + selectedLabel);
        //let value = component.get("v.value");
        //console.log('valueChange : ' + value );
    },

    //SDT-41473
    handleHaulAwayChange : function(component, event, helper) {
        var isChecked = event.getSource().get("v.value");
        component.set("v.isHaulAwayChecked",isChecked);
        var isSelected = component.get("v.vendorSelected");
        component.set("v.vendorIdRequired",isSelected == '223110_5378' && component.get("v.isHaulAwayChecked") );

    },

    //SDT-42651
    handleHaulAwayVendorChange : function(component, event, helper) {

        var isSelected= event.getSource().get("v.value");
        component.set("v.vendorSelected",isSelected);
        component.set("v.vendorIdRequired",isSelected == '223110_5378' && component.get("v.isHaulAwayChecked") );

        // SDT - 42886
        var isBooked = event.getSource().get("v.value");
        component.set("v.haulAwayBookedRequired",isBooked != 'Not Available' && component.get("v.isHaulAwayChecked") );
       
        
    },


    handleOnSave : function(component, event, helper) {
        //let selectedLabel = event.getParam('label');
        //console.log('selectedLabel : ' + selectedLabel);
        //let value = component.get("v.value");
        //let label = component.get("v.label");
        //console.log('value : ' + value );
        //console.log('label : ' + label);
        var companyCategoryName = component.get("v.selectedLabel");
        var companyCategory = component.get("v.value");
        console.log('companyCategoryName label : ' + companyCategoryName);
        event.preventDefault();
        const fields = event.getParam('fields');
        if((companyCategoryName != undefined && companyCategoryName != null && companyCategoryName.length > 0 ) &&
           (companyCategory != undefined && companyCategory != null && companyCategory.length > 0)
        ){
            fields.Company_Category__c = companyCategoryName;
            fields.CompanyCategoryCode__c = companyCategory;
        }
        component.find('recordViewForm').submit(fields);
        
    },
    handleOnSuccess : function(component, event, helper) {
        component.set("v.showForm",false);
    }
    
})