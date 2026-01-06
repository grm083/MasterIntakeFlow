({
    doInit : function(cmp,event,helper) {
        helper.handleDoInit(cmp)
    },
    handleActive: function (cmp,event, helper) {
        helper.handleclick(cmp);
    },
    updatePricing : function(cmp, event) {
        var pricingResponse = event.getParam('IsPricingAvailable');
        cmp.set('v.pricingAvailable', pricingResponse);
    },
    updateDetails : function(cmp, event, helper) {
        var newState = event.getParam('currentState');
        var productId = event.getParam('currentProductId');
        var targetProduct = event.getParam('targetProduct');
        console.log('targetProduct==>'+JSON.stringify(targetProduct));
        cmp.set('v.retainState', newState);
        
        var placementInstructions = event.getParam('placementInstructions');
        console.log('placementInstructions==>'+placementInstructions);

        //Additional Services
        var selectedAccessoryList = event.getParam('selectedAccessoryList');
        var keyQuantityList = event.getParam('keyQuantityList');
        var extraParams = event.getParam('extraParams');


        console.log('Updating to a new state of: ' + newState);
        console.log('Updating to a new productId of: ' + productId);

        cmp.set('v.currentProductId', productId);
        
        //Changes related to SDT-39632 - Added a condition to check the newstate is Pricing, 
        //then call handleStateChange method.
        if(newState === 'Pricing')
        {
            helper.handleStateChange(cmp,newState,cmp.get('v.currentState'),productId,targetProduct);
        }
        cmp.set('v.currentState', newState);
        cmp.set('v.currentProduct', targetProduct);

        var updatedstateasset = cmp.get('v.assetProducts');
        var currentTab = cmp.get('v.assetActiveTabId');
        helper.updateQuoteProducts(cmp,event,selectedAccessoryList,keyQuantityList,extraParams);
    },
    updateQuoteProductList : function(cmp,event,helper)
    {
        // New event for SDT-24972
        helper.updateQuoteProducts(cmp,event,null,null,null);
    },
    preventSelect: function(cmp) {
        var retainedState = cmp.get('v.retainState');
        cmp.set('v.currentState', retainedState);
    },
    //Changes related to SDT-39632
    /*handleStateChange: function(cmp, event, helper) {
        var newState = event.getParam('value');
        var oldState = event.getParam('oldValue');
        if (newState == 'Pricing' && oldState != 'Product') {
            var recordId = cmp.get('v.recordId');
            var updateStatus = cmp.get('c.updateStatus');
            updateStatus.setParams({
                quoteId: recordId,
                newStatus: 'Product Configured',
                quoteOnly: cmp.get('v.currentProduct.quoteOnly')
            });
            updateStatus.setCallback(this, function(response) {
                var state = response.getState();
                console.log('Update State is: ' + state);
               // this.returnToCase(cmp);
                cmp._interval = setInterval($A.getCallback(function() {
                    var progress = cmp.get('v.progressBar');
                    cmp.set('v.progressBar', progress === 100 ? 0 : progress + 7);
                }), 1500);
                const resp = response.getReturnValue();
                if(state === "SUCCESS"){
                    if(!resp === 'SUCCESS'){
                        helper.showToast('Error', resp, 'error');
                    }   
                }
            });
            $A.enqueueAction(updateStatus);
        }
    },*/
    fullBar : function(cmp) {
        var progressBar = cmp.get('v.progressBar');
        if (progressBar > 100) {
            cmp.set('v.pricingAvailable', true);
        }
    },//SDT33101 New
    checkQuotelines: function (cmp,event,helper) {
        var data= cmp.get('v.data');
        var recordId = data.recordId;
        var cpqProduct = data.cpqProduct;
        var caseId = data.caseId;
        var assetId = data.assetId;
        var calledFromQuoteSummaryConfirmation = data.calledFromQuoteSummaryConfirmation;
        helper.checkQuotelines(cmp,recordId,cpqProduct, caseId, assetId,calledFromQuoteSummaryConfirmation);
    }
})