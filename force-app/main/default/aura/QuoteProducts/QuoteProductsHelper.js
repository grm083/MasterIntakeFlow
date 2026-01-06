({
	assignccObj : function(cmp,event, helper) {
        var resp = cmp.get('v.serviceWrapper');
        console.log('before resp==>'+JSON.stringify(resp));
        if(!$A.util.isEmpty(resp) && resp.hasOwnProperty("configuredProducts") && !$A.util.isEmpty(resp.configuredProducts)){
            if(resp.configuredProducts.length>0){
                for(let i=0;i<resp.configuredProducts.length;i++){
                    resp.configuredProducts[i].showClassificationChanges = false;
                }
            }
            console.log('after resp==>'+JSON.stringify(resp));
            cmp.set('v.serviceWrapper',resp);   
        }
    },
    //SDT-31110 - disable button for Non New Service cases
    isNewService : function(cmp,product) {
        return cmp.get('v.NewServiceRecordType')=== product.caseRecordType || cmp.get('v.isHaulAway');
    },
    //SDT 33101
    getIfAmendmentQuote: function (cmp) {
        var action = cmp.get("c.getIsAmendmentQuote");
        var quoteId = cmp.get("v.recordId");
        action.setParams({
            quoteId: quoteId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var respons = response.getReturnValue();
                if (respons != null && respons != undefined) {
                    cmp.set('v.IsAmendmentQuote', respons);
                } else {
                    console.warn('Received null or undefined response from Apex.');
                }
            }
        });
        $A.enqueueAction(action);
    },
    //SDT 33101
    getDisplayApprovalButton: function (cmp, event,helper) {
        var action = cmp.get("c.displayApprovalButton");
        var quoteId = cmp.get("v.recordId");
        action.setParams({
            quoteId: quoteId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var respons = response.getReturnValue();
                if (respons != null && respons != undefined) {
                    cmp.set('v.DisplayApprovalButton', respons);
                } else {
                    console.error('Received null or undefined response from Apex.');
                }
            }
        });
        $A.enqueueAction(action);
    },//SDT33101
    refreshConfiguredProductComp :function(cmp){
        // Calling Configured product event to refresh the product
        var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
        refreshConfiguredProduct.setParams({
            "reload": true
        });
        refreshConfiguredProduct.fire();
    }
})