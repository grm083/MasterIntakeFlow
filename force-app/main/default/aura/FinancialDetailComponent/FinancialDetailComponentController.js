({
  doInit: function (component, event, helper) {
    var ccs = component.get("v.productWrapper");
    var QuotelineID = component.get("v.productWrapper.parentId");

    // Call Helper Function
    helper.getReqBRCC(component, event, helper);

    // var compCategories = [];
    // for (var entry in ccs.companyCategories) {
    //   compCategories.push({ value: ccs.companyCategories[entry], key: entry });
    // }
    // component.set("v.companyCategories", compCategories);
    //changes done for SDT-26217
    var action = component.get("c.getCompanyCategory");
    action.setParams({
      quoteId :component.get("v.productWrapper.quoteID")
    });
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.options", response.getReturnValue());
                component.set("v.label", response.getReturnValue()[0].label);
                component.set("v.value", response.getReturnValue()[0].value);
                //component.set("v.selected", response.getReturnValue()[0].label);
            }
        });
        $A.enqueueAction(action);
      //SDT-26217 changes end

    //Get Financial details from QuoteLine and quote.
    var action = component.get("c.getQLFinancialDetail");
    action.setParams({
      quoteLineId :QuotelineID
    });
    action.setCallback(this,function(response){
      var state = response.getState();
      if (state == "SUCCESS") {
        var result = response.getReturnValue();
        component.set("v.GeneralLedgerNumber" ,result.clientGLNo );
        component.set("v.CustomerCostCenter" ,result.customerCostCenter );
        component.set("v.productWrapper.quoteOnly" ,result.quoteOnly );
        component.set("v.value" ,result.companyCategory );
      }
    });
    $A.enqueueAction(action);
  },
  cancelSupplement: function (component) {
    component.set("v.showFinancialDetails", false);
  },
    updateQLines: function (cmp, event, helper) {
    var GeneralLedgerNumber = cmp.get("v.GeneralLedgerNumber");
    var CustomerCostCenter = cmp.get("v.CustomerCostCenter");
    var quoteOnly = cmp.get("v.productWrapper.quoteOnly");
    var companyCategory = cmp.get("v.value");
    var companyCategoryName = cmp.get("v.selectedLabel");
    var QuotelineID = cmp.get("v.productWrapper.parentId");
    var isReqQuoteCC = cmp.get("v.isReqQuoteCC");
    if(companyCategory!=null &&  companyCategory == 'EPR' && companyCategoryName.length == 0){
        companyCategoryName = 'Equipment Repair';
    }
    
    console.log('companyCategoryName +  : ' + companyCategoryName + ' companyCategory : '+ companyCategory);  
    if( isReqQuoteCC && (companyCategoryName == undefined || companyCategoryName == null || companyCategoryName.length == 0 ) &&
       (companyCategory == undefined || companyCategory == null || companyCategory.length == 0)
      ){
        helper.showErrorForEmptyCC(cmp, event);
    }else{ 
        var action = cmp.get("c.updateFinancialDetail");
        action.setParams({
          quoteLineId: QuotelineID,
          isQuoteOnly: quoteOnly,
          companyCategory: companyCategory,
          companyCategoryName:companyCategoryName,
          generalLedgerNo: GeneralLedgerNumber,
          customerCostCenter: CustomerCostCenter,
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state == "SUCCESS") {
            var result = response.getReturnValue();
            if (result == "Success") {
              var resultsToast = $A.get("e.force:showToast");
              resultsToast.setParams({
                title: "Financial Detail",
                message: "Financial Detail Saved Succesfully.",
                type: "success",
                mode: "default",
              });
              resultsToast.fire();
                cmp.set("v.showFinancialDetails", false);
    
            } else {
              var resultsToast = $A.get("e.force:showToast");
              resultsToast.setParams({
                title: "Financial Detail",
                message: "Unable to save financial detail",
                type: "error",
                mode: "default",
              });
              resultsToast.fire();
            }
          } else {
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
              title: "Financial Detail",
              message: "Unable to save financial detail",
              type: "error",
              mode: "default",
            });
            resultsToast.fire();
          }
        });
    
        $A.enqueueAction(action);
 	 }
    },
  
  handleOnChange : function(component, event, helper) {
    let selectedValue = event.getParam('value');
    let selectedLabel = event.getParam('label');

    console.log('value '+selectedValue)
    console.log('label '+selectedLabel)
    component.set("v.selectedLabel",selectedLabel);
}
});