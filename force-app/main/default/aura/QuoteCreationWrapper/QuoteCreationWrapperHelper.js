({
    showToast : function(title, msg, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type
        });
        toastEvent.fire();
    },
    checkQuotelines : function(cmp,quoteId, caseId ){
        // Local Constants 
        const OVERVIEW_STATUS ='Overview';
        const PRODUCT_STATUS = 'Product';
        const EMPTY_STRING = '';

        // Check for Existing Quote Lines
        var checkQuoteLines = cmp.get('c.getQuoteLinesByQuote');
        checkQuoteLines.setParams({
            quoteId: quoteId
        });
        checkQuoteLines.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS')
            {
                // local variable to prepare Quote Product List
                var quoteProductList=[];
                var tabCount = cmp.get('v.tabCount');
                // get the quotelines for quote
                var qlresult =response.getReturnValue();
                // Check if quoteline available 
                if(qlresult !=null && qlresult.length > 0)
                {
                    let existingRecords = cmp.get('v.quoteProducts');
                    // if Quote Product refreshed
                    if(existingRecords!=null && existingRecords !='[]')
                    {
                        quoteProductList =existingRecords; 
                        cmp.set('v.assetActiveTabId',quoteProductList[0].productName); 
                    }
                    else
                    {
                        // else pull all the Asset details to bind to the Tab
                        var firstitemName=EMPTY_STRING;
                        var quoteLineId=EMPTY_STRING;
                        for (var i = 0; i < qlresult.length; i++) {
                            const quoteProd={};
                            quoteProd.quoteId= quoteId;
                            quoteProd.tabIndex= i +1;
                            quoteProd.tabId= 'tab'+tabCount;
                            quoteProd.productId= qlresult[i].productId;
                            // creating tab = QLName + EquipmentCode + WasteStreamCode + Size
                            var tabName = qlresult[i].quoteLineName + '-' + qlresult[i].equipmentTypeCode + '-' + qlresult[i].materialTypeCode + '-' + qlresult[i].equipmentSize;
                            quoteProd.productName =tabName;
                            quoteProd.currentState =OVERVIEW_STATUS;
                            quoteProd.equipmentSize = qlresult[i].equipmentSize;
                            quoteProd.targetProductId= qlresult[i].parentId;
                            quoteProd.targetProduct=EMPTY_STRING;
                            quoteProd.keyQuantityList=[];
                            quoteProd.selectedAccessoryList=[];
                            if(i==0)
                            {
                                firstitemName = tabName;
                                quoteLineId = qlresult[i].parentId;
                            }
                            quoteProductList.push(quoteProd);
                            tabCount = tabCount +1;
                        }
                        cmp.set('v.quoteActiveTabId',firstitemName); 
                        cmp.set('v.quoteProducts', quoteProductList);
                        cmp.set('v.tabCount',tabCount);
                       // cmp.set('v.istabsAvailable', true);
                        
                        var updateState = cmp.getEvent('UpdateWrapperState');
                        updateState.setParams({
                            "currentState": "Overview",
                            "currentProductId": quoteLineId,
                            "targetProduct" : quoteLineId
                        });
                        updateState.fire();

                        // var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
                        // refreshConfiguredProduct.setParams({
                        //     "reload": true
                        // });
                        // refreshConfiguredProduct.fire();
                        // cmp.set('v.loadingSpinner' , false);
                    }
                }
                else{
                    // resetting tab count
                    //tabCount = 1;
                   // if no quote line found  
                   var firstitemName=EMPTY_STRING;
                    const quoteProd={};
                    quoteProd.quoteId= quoteId;
                    quoteProd.tabIndex= 1;
                    quoteProd.tabId= 'tab'+tabCount;
                    quoteProd.productId= EMPTY_STRING;
                    var tabName = 'Service #'  +tabCount;
                    quoteProd.productName =tabName;
                    quoteProd.currentState =PRODUCT_STATUS;
                    quoteProd.equipmentSize = EMPTY_STRING;
                    quoteProd.targetProductId= EMPTY_STRING;
                    quoteProd.targetProduct=[];
                    quoteProd.keyQuantityList=[];
                    quoteProd.selectedAccessoryList=[];
                    firstitemName = tabName;
                    quoteProductList.push(quoteProd);
                    cmp.set('v.quoteActiveTabId',firstitemName); 
                    cmp.set('v.quoteProducts', quoteProductList);
                    cmp.set('v.tabCount',tabCount);
                    //cmp.set('v.istabsAvailable', true);
                    var updateState = cmp.getEvent('UpdateWrapperState');
                    updateState.setParams({
                        "currentState": "Product",
                        "selectedProductId": EMPTY_STRING,
                        "selectedProduct" : []
                    });
                    updateState.fire();
                }
            }
            else
            {
                this.showToast('Error', 'There was an error while processing the request' , 'error');
                //cmp.set('v.loadingSpinner' , false); 
            }
            //cmp.set('v.loadingSpinner' , false); 
        });
        $A.enqueueAction(checkQuoteLines);
    },
    updateQuoteProducts : function(cmp,event,selectedAccessoryList,keyQuantityList,extraParams)
    {
        cmp.set('v.istabsAvailable', false);
        let updatedstatequote = cmp.get('v.quoteProducts');
        var currentTab = cmp.get('v.quoteActiveTabId');
        var tabCount = cmp.get('v.tabCount');

        var newState = event.getParam('currentState');
        var productId = event.getParam('currentProductId');
        var targetProduct = event.getParam('targetProduct');

        var wasteStreamName = event.getParam('wasteStreamName');
        var QLName = event.getParam('QLName');
        var equipmentSize = event.getParam('equipmentSize');
        //Equipment Size index
        //need to change the index in case there is any change in tab name
        // QLName[1] + Product Code[2] + Waste Stream[3] + equipmentSize[4]
        const equipmentSizeIndex=4;
        
        if(updatedstatequote != null && updatedstatequote != undefined && updatedstatequote != '[]')
        {
            // Based to current tab filter the Product list
            var filteredproduct= updatedstatequote.filter(j=>j.productName == currentTab);
             // Based on the selected product list assigning items
             if(productId != undefined && productId != null)
             	filteredproduct[0].targetProductId =productId;
            if(newState != undefined && newState != null)
              filteredproduct[0].currentState =newState;
            if(targetProduct != undefined && targetProduct != null){
                 filteredproduct[0].targetProduct =targetProduct;
                 filteredproduct[0].selectedProduct =targetProduct;
            }
             // Logic to update the Tab name
             if(filteredproduct[0].targetProduct !=null && filteredproduct[0].targetProduct !='' && filteredproduct[0].targetProduct!= undefined && filteredproduct[0].targetProduct.ProductCode != undefined)
            {
                if(filteredproduct[0].productName !=null && filteredproduct[0].productName !='' && filteredproduct[0].productName!= undefined && QLName != undefined )
                {
                    currentTab = filteredproduct[0].productName =QLName +'-'+filteredproduct[0].targetProduct.ProductCode + '-' + wasteStreamName+ '-' +equipmentSize;
                }
            }

            // Logic to replace the Equipment Size
            if(newState != undefined && newState != null && newState === 'Service')
            {
                //index fo Equipment size- 
                currentTab= this.replaceEquipmentSize(currentTab,equipmentSize, equipmentSizeIndex);
                currentTab= filteredproduct[0].productName= currentTab.join("-");
            }

            //resetting tab count and tab name
            if(newState != undefined && newState != null && newState === 'Product')
            {
                //tabCount = updatedstatequote.length;
                currentTab = filteredproduct[0].productName = 'Service-' + filteredproduct[0].tabIndex;
            }

             if(selectedAccessoryList != undefined && selectedAccessoryList != null)
                filteredproduct[0].selectedAccessoryList =selectedAccessoryList;
            
            if(keyQuantityList != undefined && keyQuantityList != null)
                filteredproduct[0].keyQuantityList =keyQuantityList;

            if(extraParams != undefined && extraParams != null)
                filteredproduct[0].extraParams =extraParams;
            
            cmp.set('v.istabsAvailable', true);
            cmp.set('v.quoteProducts',updatedstatequote);
            cmp.set('v.quoteActiveTabId',currentTab); 
            cmp.set('v.tabCount',tabCount);
        }
    },
    replaceEquipmentSize : function(tabName, updatedSize,index)
    {
        let resultArray  = tabName.split('-');
        // find the equipmentSize to replaced with New size
        if(resultArray.length >0 && updatedSize != undefined && index ==4)
        {
            resultArray[index] = updatedSize;
        }
        return resultArray;
    },
    ////SDT-29789 :Helper method to show hide Alternate Containers
    updateAlternateContainersComp :function(cmp,showHideComp){
        try{
            let payload = {
                showAlternateContainers: showHideComp, 
                currentProduct : cmp.get('v.currentProduct'),
                activeTabId : cmp.get('v.quoteActiveTabId')
            };
            //SDT-31310
            let alternateCompMsg = cmp.find("alternateContainersChannel");
            if(alternateCompMsg){
            alternateCompMsg.publish(payload);
            cmp.set('v.alternateContainerVisibility',showHideComp);
            }
        }
        catch(error){
            console.error('updateAlternateContainersComp ->',error);
        }
    },
    //SDT-30963
    updatedCurrentProduct :function(cmp,updatedProduct){
        cmp.set('v.istabsAvailable',false)
        let quoteProducts = cmp.get('v.quoteProducts');
        let currentProduct = cmp.get('v.currentProduct');
        let newTabName;
        if(quoteProducts && quoteProducts.length){
            quoteProducts.forEach(product => {
                if(product.targetProductId === updatedProduct.parentId){
                    newTabName = product.productName = product.productName.replace(updatedProduct.oldEquipmentSize,updatedProduct.newEquipmentSize);
                    product.equipmentSize = updatedProduct.newEquipmentSize;
                    this.updateProductWrapper(product.selectedProduct,updatedProduct);
                    this.updateProductWrapper(product.targetProduct,updatedProduct);
                }
            });      
        }
        this.updateProductWrapper(currentProduct,updatedProduct);
        cmp.set('v.quoteProducts',quoteProducts);
        cmp.set('v.currentProduct',currentProduct);
        cmp.set('v.quoteActiveTabId',newTabName);
        cmp.set('v.istabsAvailable',true);
        this.refreshConfiguredProductComp();
        this.updateAlternateContainersComp(cmp,true);

    },
    //SDT-30963
    updateProductWrapper :function(product,updatedProduct){
        if(product){
            product.equipmentSize = updatedProduct.newEquipmentSize;
            product.startDate = updatedProduct.newContainerDate;
            product.alternateContainerFlag = true;
            product.slaOverrideComment = '';
            product.slaOverrideReason = '';
        }
    },
    //SDT-30963
    refreshConfiguredProductComp :function(){
        // Calling Configured product event to refresh the product
        var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
        refreshConfiguredProduct.setParams({
            "reload": true
        });
        refreshConfiguredProduct.fire();
    },
    //Changes related to SDT-39632
    returnToCase: function(cmp) {
        var navEvent = $A.get('e.force:navigateToSObject');
        navEvent.setParams({
            'recordId': cmp.get('v.CaseId'),
            'isredirect': true
        });
        navEvent.fire();
    },
    handleStateChange: function(cmp,newState,oldState,productId,targetProduct) {
    //var newState = event.getParam('value');
    //var oldState = event.getParam('oldValue');
    //var preventRecurrsionOnError = cmp.get('v.preventRecurssionOnError'); 
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
                cmp._interval = setInterval($A.getCallback(function() {
                    var progress = cmp.get('v.progressBar');
                    cmp.set('v.progressBar', progress === 100 ? 0 : progress + 7);
                }), 1500);
                //let resp = response.getReturnValue();
                if(state === "SUCCESS"){
                    this.returnToCase(cmp);
                }
                else if (state === "ERROR")
                {
                    //Changes related to SDT-39632
                    this.updateWrapperStateCall (cmp,'Summary', productId, targetProduct);
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var ErrorMessage = errors[0].message;
                            const regex = /(Update failed.*?FIELD_CUSTOM_VALIDATION_EXCEPTION,)/;
                            ErrorMessage = ErrorMessage.replace(regex,'');
                            this.showToast('Error', ErrorMessage, 'error');
                        }
                        
                    }
                }
                
            });
            $A.enqueueAction(updateStatus);
        }
},
updateWrapperStateCall : function(cmp,currentState, productId, targetProduct) {
    var updateState = cmp.getEvent('UpdateWrapperState');
    updateState.setParams({
        "currentState": currentState,
        "currentProductId": productId,
        "targetProduct": targetProduct
    });
    updateState.fire();
},
	  getPricingDetails : function(cmp, event,recordId) {
         var action = cmp.get("c.getMultivendorPricingRecord");
                    action.setParams({ quoteId: recordId});
                    action.setCallback(this, function (res) {
                        var state = res.getState();
                         if (res.getState() === 'SUCCESS' && res.getReturnValue() != [] && res.getReturnValue().length >0) {
                                let priceRec = res.getReturnValue();
                                if(priceRec!=null && priceRec !=undefined){
                                    //cmp.set('v.isMultiVendor',priceRec[0].Is_Multi_Vendor__c);
                                    if('v.quoteStatus' == 'Cost Configured'){
                                        cmp.set('v.isMultiVendor',false);
                                    }else{
                                        cmp.set('v.isMultiVendor',priceRec[0].Is_Multi_Vendor__c);
                                    }
                                    console.log('isMultiVendor===>'+priceRec[0].Is_Multi_Vendor__c);
                                }
                        }
                    });
                    $A.enqueueAction(action);
    },
    getMultiVendorSwitch : function(cmp, event) {
	//Fetching multi vendor switch
                    var action = cmp.get("c.getAMMultiVendorSwitch");
                    //action.setParams();
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                         if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
                            cmp.set('v.multiVendorAMSwitch',response.getReturnValue());
                            console.log('Multi Vender Switch==>'+response.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action);        
}
})

