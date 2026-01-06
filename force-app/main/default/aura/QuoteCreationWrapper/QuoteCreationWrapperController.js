({
    doInit : function(cmp,event,helper) {
        var getDetails = cmp.get('c.getQuoteStatusDetails');
        var recordId = cmp.get('v.recordId');
        getDetails.setParams({
            quoteId: recordId
        });
        getDetails.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var quoteStatus = response.getReturnValue().SBQQ__Status__c;
                var caseId = response.getReturnValue().SBQQ__Opportunity2__r.Case__c;
                var procuredStatus = response.getReturnValue().QuoteProcuredStatus__c;
                var caseType = response.getReturnValue().SBQQ__Opportunity2__r.Case__r.RecordType.Name;
                cmp.set('v.procuredStatus' ,procuredStatus );
                cmp.set('v.quoteStatus', quoteStatus);
                cmp.set('v.CaseId', caseId);
                console.log('Case Id is: ' + caseId);
                cmp.set('v.caseType', caseType);
                console.log('Current status is: ' + quoteStatus);
                if (quoteStatus != 'Draft') {
                    cmp.set('v.retainState', 'Pricing');
                    cmp.set('v.currentState', 'Pricing');
                    cmp.set('v.pricingAvailable', true);
                    console.log('Current state of component is: ' + cmp.get('v.currentState'));
                }
                else{
                    helper.checkQuotelines(cmp,recordId,caseId);
                }
                //SDT-29101 
                var caseRecordType = response.getReturnValue().SBQQ__Opportunity2__r.Case__r.RecordType.Name;
                if(caseRecordType === 'New Service Case'){
		    //SDT-20689 Changes by Chandu Kari
                    //Fetching multi vendor pricing record
                    helper.getPricingDetails(cmp,event,recordId);
                    //Fetching multi vendor switch
                    helper.getMultiVendorSwitch(cmp,event);
                    var hasAssetAvailabilityPermissionWithHaulAway = cmp.get('c.hasAssetAvailabilityPermissionWithHaulAway');
                    
                    hasAssetAvailabilityPermissionWithHaulAway.setParams({ caseId: caseId });
                    //hasAssetAvailabilityPermission.setParams({});
                    hasAssetAvailabilityPermissionWithHaulAway.setCallback(this, function(response) {
                        if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
                            console.log('hasAssetAvailabilityPermissionWithHaulAway ->True');
                            cmp.set('v.assetAvailabilityAccess',true);
                        }
                    });
                    $A.enqueueAction(hasAssetAvailabilityPermissionWithHaulAway);  

                }
            };
        });
        $A.enqueueAction(getDetails);
    },
    updatePricing : function(cmp, event) {
        var pricingResponse = event.getParam('IsPricingAvailable');
        cmp.set('v.pricingAvailable', pricingResponse);
    },
    updateDetails : function(cmp, event, helper) {
        cmp.set('v.istabsAvailable', false);
        var newState = event.getParam('currentState');
        var productId = event.getParam('currentProductId');
        var targetProduct = event.getParam('targetProduct');
        cmp.set('v.retainState', newState);
        
        var placementInstructions = event.getParam('placementInstructions');
        console.log('placementInstructions==>'+placementInstructions);

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
        //SDT-29789 :start
        if(cmp.get('v.assetAvailabilityAccess') && newState){
            helper.updateAlternateContainersComp(cmp,(newState == 'Service'));
        }
        //SDT-29789 :end
        //Additional Services
        var selectedAccessoryList = event.getParam('selectedAccessoryList');
        var keyQuantityList = event.getParam('keyQuantityList');
        var extraParams = event.getParam('extraParams');

        // Method to calling update details in Quote Product list to handle SDT-24972
        helper.updateQuoteProducts(cmp,event,selectedAccessoryList,keyQuantityList,extraParams);
	
    },
    preventSelect: function(cmp) {
        var retainedState = cmp.get('v.retainState');
        cmp.set('v.currentState', retainedState);
    },
    /*handleStateChange: function(cmp, event, helper,newState,oldState) {
        //var newState = event.getParam('value');
        //var oldState = event.getParam('oldValue');
        var preventRecurrsionOnError = cmp.get('v.preventRecurssionOnError'); 
        if (newState == 'Pricing' && oldState != 'Product' && !preventRecurrsionOnError) {
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
        else
        {
           //cmp.set('v.preventRecurssionOnError',false);  
        }
    },*/
    fullBar : function(cmp) {
        var progressBar = cmp.get('v.progressBar');
        if (progressBar > 100) {
            cmp.set('v.pricingAvailable', true);
        }
    },
    updateQuoteProductList : function(cmp,event,helper)
    {
        // New event for SDT-24972
        helper.updateQuoteProducts(cmp,event,null,null,null);
    },
    //SDT-30963
    handleAlternateContainer :function (cmp,event,helper){
        try{
            cmp.find("Id_spinner").set("v.class", 'slds-show');
            let updatedProduct = event.getParam('updatedProduct');
            let activeTab = cmp.get('v.quoteActiveTabId');
            if(updatedProduct && activeTab == updatedProduct.activeTabId) {
                helper.updatedCurrentProduct(cmp,updatedProduct);
            }
                 
            cmp.find("Id_spinner").set("v.class", 'slds-hide');           
        }
        catch(error){
            console.error('error->',error);
        }
    }
    
    // returnToCase: function(cmp) {
    //     var navEvent = $A.get('e.force:navigateToSObject');
    //     navEvent.setParams({
    //         'recordId': cmp.get('v.CaseId'),
    //         'isredirect': true
    //     });
    //     navEvent.fire();
    // }
})
