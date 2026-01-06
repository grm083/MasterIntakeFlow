({
    refreshTargetProduct: function(cmp, event){
        var targetProductId = cmp.get('v.targetProductId');
        var recordId = cmp.get('v.recordId');
        var buildWrapper = cmp.get('c.buildWrapper');
        buildWrapper.setParams({
            quoteId: recordId
        });
        buildWrapper.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State is: ' + state);
            if (state === 'SUCCESS') {
                var allProducts = response.getReturnValue().configuredProducts;
                let tProduct;
                for (let i = 0; i < allProducts.length; i++){
                    console.log('Checking: ' + allProducts[i].parentId);
                    if (allProducts[i].parentId == targetProductId) {
                        tProduct = allProducts[i];
                        //cmp.set('v.targetProduct', allProducts[i]);
                        break;
                    }
                }
                let targetProduct = cmp.get('v.targetProduct');
                console.log('before refresh targetProduct==>'+JSON.stringify(targetProduct));
                if(tProduct!=null && tProduct.startDate!=null && tProduct.startDate != undefined && targetProduct != undefined)
                    targetProduct.startDate = tProduct.startDate;
                console.log('latest targetProduct==>'+JSON.stringify(targetProduct));
                cmp.set('v.targetProduct', targetProduct);
            } else {
                console.log('Error in creating bundle.  Error is: ' + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(buildWrapper);
    },
    showToast : function(strTitle, msg, strType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": strTitle,
            "message": msg,
            "type" : strType
        });
        toastEvent.fire();
    },
    //SDT-29084 Start
     getByPassSTPReasonList: function(cmp, byPassStpCheckBox, SpecialHandlingReason, specialHandlingDetailReason){
     	var byPass = cmp.get("c.getByPassSTPReasonList");
        //SDT-47978 - Added by Yugandhar Adem : START 
        var editableOptions = [
            { value: 'Delivery not needed/container on site', key: 'Delivery not needed/container on site'},
            { value: 'Non-Contractual Client Pricing', key: 'Non-Contractual Client Pricing'}
        ];
        //SDT-47978 - Added by Yugandhar Adem : END
        
        byPass.setCallback(this, function(response){
        	var state = response.getState();
            if (state === "SUCCESS"){
            	var returnVal = response.getReturnValue();
                if(returnVal){
                	var reasonList = [];

                    for (var entry in returnVal) {
                    	console.log('Key :: ' + entry + 'value :: '+ returnVal[entry])
            			reasonList.push({value:returnVal[entry], key:entry});
                        
                        if(SpecialHandlingReason != entry){
                            //SDT-47978 - Modified by Yugandhar Adem : START
                            //if(entry == 'Back-dated service requested' ||entry == 'Automatically flagged by system' || entry =='Certificate of Destruction/Disposal or offsite address or special restrictions'){
                            if(entry == 'Delivery not needed/container on site' || entry == 'Automatically flagged by system'){
                                reasonList.pop();
                            }
                        }
          			}
                    //SDT-47978 - Added by Yugandhar Adem : START
                    if(SpecialHandlingReason == 'Delivery not needed/container on site'){
                        reasonList = editableOptions;
                    }
                     //SDT-47978 - Added by Yugandhar Adem : END
          			cmp.set('v.byPassStpReasons', reasonList);
                }
            } else {
                console.log('Error in getting ByPass STP Reason List: ' + JSON.stringify(response.getError()));
            }

            if(byPassStpCheckBox == true)
            {
                //SDT-31144 added if condition to make fields readable only in case of automation
                //SDT-47978 - Modified by Yugandhar Adem : START
                //if(SpecialHandlingReason == 'Back-dated service requested' ||SpecialHandlingReason == 'Automatically flagged by system' || SpecialHandlingReason =='Certificate of Destruction/Disposal or offsite address or special restrictions')
                if(SpecialHandlingReason == 'Delivery not needed/container on site')
                {
                	cmp.set('v.specialHandlingEnable', true);
                    cmp.set('v.enableSpecialHandlingReason', false);
                }
                else if(SpecialHandlingReason == 'Automatically flagged by system')
                {
                	cmp.set('v.specialHandlingEnable', true);
                    cmp.set('v.enableSpecialHandlingReason', true);
                }
                //SDT-47978 - Modified by Yugandhar Adem : END
            cmp.set('v.byPassStpCheckBox', byPassStpCheckBox);
            cmp.set('v.byPassStpSelectedReasonVal', SpecialHandlingReason);
            cmp.set('v.stpOtherReasonText', specialHandlingDetailReason);
            }
        });
        $A.enqueueAction(byPass);
    },

    saveByPassSTPValues: function(cmp){
        console.log('Inside saveByPassSTPValues');
        var action = cmp.get("c.saveByPassSTPRequest");
        var quoteId = cmp.get("v.recordId");
        var byPassSTPFlag = cmp.get("v.byPassStpCheckBox");
        
        /*if( byPassSTPReason != '-1' && byPassSTPReason != undefined && byPassSTPReason != 'Other')
        {
			cmp.set('v.stpOtherReasonText','');                    
        }*/
        
        if(byPassSTPFlag != true){
            
            cmp.set('v.byPassStpSelectedReasonVal',' ');
            cmp.set('v.stpOtherReasonText','');
        }
        var byPassSTPOtherReason = cmp.get("v.stpOtherReasonText");
        var byPassSTPReason = cmp.get("v.byPassStpSelectedReasonVal");
        var quoteOnly = cmp.get("v.quoteOnly");
        action.setParams({
        "quoteId": quoteId,
        "byPassSTPFlag": byPassSTPFlag,
        "byPassSTPReason": byPassSTPReason,
        "byPassSTPOtherReason": byPassSTPOtherReason,
        "quoteOnly": quoteOnly
    });
        
        $A.enqueueAction(action);
    }, //SDT-29084 End
    //SDT-31396- issue fixed
    addAdditionalservicesComment: function(cmp){
        var action = cmp.get("c.addAdditionalServicesComment");
        action.setParams({
            "quoteId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('addAdditionalServicesComment Success');
            } else {
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    console.log("Error message: " + errors[0].message);
                    this.showToast('Error',errors[0].message,'error');
                }
            } else {
                console.log("Unknown error");
            }
            }
        });
        $A.enqueueAction(action);
    }
    //SDT 33101
    ,getDisableQuoteOnly : function (cmp) {
        var action = cmp.get("c.getDisableQuoteOnlyButtonForAmendment");
        var quoteId = cmp.get("v.recordId");
        action.setParams({
            quoteId: quoteId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var respons = response.getReturnValue();
                if (respons != null && respons != undefined) {
                    cmp.set('v.disableQuoteonly', respons);
                } else {
                    console.log('Received null or undefined response from Apex.');
                }
            }
        });
        $A.enqueueAction(action);
    },
    //33101
    getShowQuoteOnlyButton: function (cmp,event,helper) {
        var action = cmp.get("c.getshowAddQuoteOnlyServiceButtonForAmendment");
            var quoteId = cmp.get("v.recordId");
        action.setParams({
            quoteId: quoteId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var respons = response.getReturnValue();
                if (respons != null && respons != undefined) {
                    cmp.set('v.addQuoteOnlyService', respons);
                 } else {
                    console.warn('Received null or undefined response from Apex.');
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