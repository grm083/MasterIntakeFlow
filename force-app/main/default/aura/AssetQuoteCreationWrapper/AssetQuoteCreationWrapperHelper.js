({
    showToast : function(title, msg, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type
        });
        toastEvent.fire();
    },//SDT 33101 new
    handleDoInit : function(cmp){
        cmp.set('v.loadingSpinner' , true);
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
                cmp.set('v.caseType', caseType);
                console.log('Case Id is: ' + caseId);
                console.log('Current status is: ' + quoteStatus);

                    if (quoteStatus != 'Draft') {
                        cmp.set('v.retainState', 'Pricing');
                        cmp.set('v.currentState', 'Pricing');
                        cmp.set('v.pricingAvailable', true);
                        console.log('Current state of component is: ' + cmp.get('v.currentState'));
                        cmp.set('v.loadingSpinner' , false);
                    }
                    else{
                        // Changes for SDT-24401
                        var assetId = response.getReturnValue().SBQQ__Opportunity2__r.Case__r.AssetId;
                        // Get the case record type
                        var caseRecordType = response.getReturnValue().SBQQ__Opportunity2__r.Case__r.RecordType.Name;
                        var cpqProduct = '';
                        if(response.getReturnValue().SBQQ__Opportunity2__r.Case__r.Asset !=null && response.getReturnValue().SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Product__c !=null)
                        {
                            cpqProduct =response.getReturnValue().SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Product__c;
                        }
                        
                        // Check if product and Asset are available and Case record Type Should be 'Update Asset'
                        // Changes for SDT-26868
                        if(caseRecordType!= '' && caseRecordType != 'New Service Case' && cpqProduct !=null && cpqProduct!= undefined && assetId !=null && assetId != undefined)
                        {
                            console.log('under break');
                            this.checkQuotelines(cmp,recordId,cpqProduct, caseId, assetId,false,false);//SDT 33101 new adding last attribute as false which means this it not called from child component
                        }
                        else{
                            cmp.set('v.loadingSpinner' , false);
                        }
                    }
                };
            });
            $A.enqueueAction(getDetails);
    },
    //SDT 33101 New Adding last argument calledFromQuoteSummaryConfirmation(boolean)
    //calledFromQuoteSummaryConfirmation = true if it is called from Add More Quote Only Service button of Aura-QuoteSummaryConfirmation
    //else calledFromQuoteSummaryConfirmation = false 
    //if true we should not call c.checkAssetQuoteLines ie. qlresult should be empty which will convert asset into new bundle 
    checkQuotelines : function(cmp,quoteId, productId, caseId, assetId, calledFromQuoteSummaryConfirmation,refreshParent ){
         console.log('PK Before Inside AssetQuoteCreationWrapperHelper - checkQuotelines' + JSON.stringify(cmp.get('v.assetProducts')));
        // Check for Existing Asset Quote Lines
        
         var checkAssetQuoteLines = cmp.get('c.checkAssetQuoteLines');
         checkAssetQuoteLines.setParams({
             quoteId: quoteId,
             cpqProductId: productId
         });
         checkAssetQuoteLines.setCallback(this, function(response) {
             var state = response.getState();
             if (state === 'SUCCESS') {
        
                var assetProductList=[];
                 //PK
                 var qlCount = 0;
                 var qlList =response.getReturnValue();
                 qlCount = qlList.length;
                 //PK
                 
                 // get the quotelines for Asset
                 if(!calledFromQuoteSummaryConfirmation)
                     var qlresult =response.getReturnValue();
                 else
                 	var qlresult=[];
                 // Check if quoteline available 
                 if(qlresult !=null && qlresult.length > 0 )
                 {
                     let existingRecords = cmp.get('v.assetProducts');
                     // if Asset Product refreshed
                     if(existingRecords!=null && existingRecords !='[]' )
                     {
                         assetProductList =existingRecords;
                         //SDT33101
                         if(cmp.get('v.isCalledFromQuoteSummaryConfirmation'))
                         {
                             cmp.set('v.isCalledFromQuoteSummaryConfirmation', false);
                             var activeTabNew = cmp.get('v.assetActiveTabId');
                             cmp.set('v.assetActiveTabId', activeTabNew.toString());
                         }  
                         else
                         {
                             cmp.set('v.assetActiveTabId', '1');
                         }
                         
                         //cmp.set('v.assetActiveTabId','1');//assetProductList[0].productName);SDT 33101 
                     }
                     else
                     {
                         // else pull all the Asset details to bind to the Tab
                         var firstitemName='';
                         
                         for (var i = 0; i < qlresult.length; i++) {
                             var mapTabIndexProductName = {};//SDT 33101
                             const assetProd={};
                             assetProd.assetId= assetId;
                             assetProd.quoteId= quoteId;
                             assetProd.tabIndex= i +1;
                             assetProd.productId = qlresult[i].SBQQ__Product__c;
                             assetProd.SID = qlresult[i].SID__c;
                             //SDT 33101 ,SBQQ__Quote__r.SBQQ__Type__c
                             var tabName = '';
                             if(qlresult[i].SBQQ__Quote__r.SBQQ__Type__c === $A.get('$Label.c.Amendment'))
                                 tabName = (i +1)+ '-' +(qlresult[i].SID__c !=undefined ? qlresult[i].SID__c : qlresult[i].Name) + '-' + qlresult[i].SBQQ__Product__r.ProductCode + '-' +qlresult[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Material__r.ProductCode+ '-' +qlresult[i].Equipment_Size__c;
                             else 
                                 tabName = (qlresult[i].SID__c !=undefined ? qlresult[i].SID__c : qlresult[i].Name) + '-' + qlresult[i].SBQQ__Product__r.ProductCode + '-' +qlresult[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Material__r.ProductCode+ '-' +qlresult[i].Equipment_Size__c;
                             mapTabIndexProductName[assetProd.tabIndex] = tabName ;
                             assetProd.mapTabIndexProductName= mapTabIndexProductName;
                             //SDT 33101 
                             assetProd.productName =tabName;
                             assetProd.currentState ='Overview';
                             assetProd.wasteStreamId = qlresult[i].SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__r.Asset.CPQ_Material__c;
                             assetProd.equipmentSize = qlresult[i].Equipment_Size__c;
                             assetProd.targetProductId= qlresult[i].Id;
                             assetProd.targetProduct='[]';
                             //assetProd.selectedProduct=[];
                             assetProd.keyQuantityList=[];
                             //assetProd.extraParams=[];
                             assetProd.selectedAccessoryList=[];
                             if(i==0)
                                 firstitemName = assetProd.tabIndex;//tabName; SDT33101
                             assetProductList.push(assetProd);
                             
                         }
                         cmp.set('v.retainState','Overview');
                         cmp.set('v.currentState','Overview');
                         cmp.set('v.assetActiveTabId', firstitemName.toString()); 
                         cmp.set('v.assetProducts', assetProductList);
                         
                         // calling click method to create the Quotelines if not exists 
                         this.handleclick(cmp, calledFromQuoteSummaryConfirmation, assetProductList); 
                     }
                 }
                 else {
                     // if no quote line found then create new quote lines
                     // use session to populate multiple or single tab
                     var getAssetheaders = cmp.get('c.getQuoteAssetHeaders');
                     getAssetheaders.setParams({
                         caseId: caseId
                     });

                     getAssetheaders.setCallback(this, function(response) {
                         var headerstate = response.getState();
                         if (headerstate === 'SUCCESS') {
                             //SDT33101 new
                             var result = response.getReturnValue();

                             var firstitemName='';
                             
                             for (var i = 0; i < result.length; i++) {
                                 var mapTabIndexProductName = {};//SDT 33101
                                 const assetProd={};
                                 assetProd.assetId= result[i].assetId;
                                 assetProd.quoteId= quoteId;
                                 assetProd.tabIndex = qlCount + i + 1;
                                 assetProd.SID = result[i].Acorn_SID;
                                 assetProd.productId = result[i].CPQ_Product;
                                 //SDT 33101 
                                 var tabName = '';
                                 if(qlList.length > 0)
                                 {
                                     if(qlList[i].SBQQ__Quote__r.SBQQ__Type__c === $A.get('$Label.c.Amendment'))
                                     	tabName = assetProd.tabIndex + '-' + result[i].Acorn_SID + '-' + result[i].ProductCode + '-' + result[i].MaterialCode + '-' + result[i].Equipment_Size;
                                 }
                                 else
                                     tabName = result[i].Acorn_SID + '-' + result[i].ProductCode + '-' + result[i].MaterialCode + '-' + result[i].Equipment_Size;
                                 mapTabIndexProductName[assetProd.tabIndex] = tabName ;
                                 assetProd.mapTabIndexProductName= mapTabIndexProductName;
                                 //SDT 33101
                                 assetProd.productName =tabName;
                                 assetProd.currentState ='';
                                 assetProd.wasteStreamId = result[i].CPQ_Material;
                                 assetProd.equipmentSize = result[i].Equipment_Size;
                                 assetProd.targetProductId='';
                                 assetProd.targetProduct='[]';
                                 //assetProd.selectedProduct=[];
                                 assetProd.keyQuantityList=[];
                                 //assetProd.extraParams=[];
                                 assetProd.selectedAccessoryList=[];
                                 //if(i==0)
                                     firstitemName = assetProd.tabIndex//tabName; SDT 33101
                                 assetProductList.push(assetProd);
                                 
                             }
                             
                             //PK
                             //var temporaryassetProductList = [];
                             //temporaryassetProductList = cmp.get('v.assetProducts');
                             //temporaryassetProductList.push(assetProd);
                             //cmp.set('v.assetProducts', temporaryassetProductList);
                             //PK
                             if(!calledFromQuoteSummaryConfirmation)
                                 cmp.set('v.assetProducts', assetProductList);
                             cmp.set('v.assetActiveTabId', firstitemName.toString()); 
                             // calling click method to create the Quotelines if not exists 
                             this.handleclick(cmp, calledFromQuoteSummaryConfirmation, assetProductList);
                         }
                         else{
                             cmp.set('v.loadingSpinner' , false); 
                         }
                     });
                     $A.enqueueAction(getAssetheaders);
                 }
                 cmp.set('v.loadingSpinner' , false);    
             }
             else
             {
                this.showToast('Error', 'There was an error while processing the request' , 'error');
                cmp.set('v.loadingSpinner' , false); 
             }
             cmp.set('v.loadingSpinner' , false); 
         });
         $A.enqueueAction(checkAssetQuoteLines);
        
    },

    handleclick : function(cmp, calledFromQuoteSummaryConfirmation, assetProductList){
        cmp.set('v.loadingSpinner' , true);
        var isQuoteLineCreationCalled = cmp.get('v.isQuoteLineCreationCalled');
        cmp.set('v.isAssetAvailable', false);
        var tempassetProductList= [];
        console.log('values Seema>>'+ JSON.stringify(cmp.get('v.assetProducts')));
        if(calledFromQuoteSummaryConfirmation)
        {   
            cmp.set('v.isCalledFromQuoteSummaryConfirmation', true);
        	tempassetProductList = assetProductList;
        }
        else
            tempassetProductList = cmp.get('v.assetProducts');
        // get the active tab
        //var activeId = '1';
        //if(tempassetProductList != null && tempassetProductList != '[]')
         var   activeId= this.getProductName(cmp,cmp.get('v.assetActiveTabId'),tempassetProductList);// SDT 33101 cmp.get('v.assetActiveTabId');
        
        // Name should be same as Asset Product name and Tab Name
        //var filteredproduct= tempassetProductList.filter(j=>j.productName == activeId);
        var filteredproduct= tempassetProductList.filter(j=>j.mapTabIndexProductName[cmp.get('v.assetActiveTabId')] == activeId);           
        console.log('active Id> '+ activeId);
        if( !isQuoteLineCreationCalled && filteredproduct !=null && (filteredproduct[0].targetProductId =='' || filteredproduct[0].targetProductId ==null))
        {
            //if Quote LIne creation method already not isQuoteLineCreationCalled
            if(isQuoteLineCreationCalled ==null || isQuoteLineCreationCalled == undefined || !isQuoteLineCreationCalled)
            {
                cmp.set('v.isQuoteLineCreationCalled',true);
                isQuoteLineCreationCalled=true;
            }
            // calling method to create the Quotelines based on Active tab
            // var createAction = cmp.get('c.createAssetQuoteLines');
            // createAction.setParams({
            //     assetId : filteredproduct[0].assetId,
            //     quoteId: filteredproduct[0].quoteId,
            //     productId: filteredproduct[0].productId,
            //     wastestreamId: filteredproduct[0].wasteStreamId,
            //     equipmentSize: filteredproduct[0].equipmentSize
            // });

            var createAction = cmp.get('c.createBulkAssetQuoteLines');
            createAction.setParams({
                assetProducts: tempassetProductList
            });
            createAction.setCallback(this, function(response) {
                var state = response.getState();
                var firstProduct='';
                if (state === 'SUCCESS') {
                    var results = response.getReturnValue();
                    for (var i = 0; i < results.length; i++)
                    {
                        tempassetProductList.filter(function(asset) {
                            if(asset.assetId == results[i].assetId)
                            {
                                asset.targetProductId =results[i].quoteLineId;
                                asset.targetProduct =results[i].quoteLineId;
                                asset.currentState = 'Overview';
                            }
                        });
                        if(i===0)
                        {
                            firstProduct =results[i].quoteLineId; 
                        }
                    }
                    cmp.set('v.createdProduct', firstProduct);

                    cmp.set('v.isAssetAvailable', true);
                    if(calledFromQuoteSummaryConfirmation)
                    {
                        var latestAssetProdList = [];
                        latestAssetProdList = cmp.get('v.assetProducts');
                        latestAssetProdList.push(tempassetProductList[0]);
                        cmp.set('v.assetProducts', latestAssetProdList);
                    }
                    else
                    {
                        cmp.set('v.assetProducts', tempassetProductList);
                    }
                    
                    //cmp.set('v.createdProduct', currentQLIds[0]);
                    // Calling update state event
                    
                    var updateState = cmp.getEvent('UpdateWrapperState');
                    updateState.setParams({
                        "currentState": "Overview",
                        "currentProductId": firstProduct,
                        "targetProduct" : firstProduct
                    });
                    console.log('comp value >'+ JSON.stringify(cmp.get('v.assetProducts')));
                    updateState.fire();

                    // Calling Configured product event to refresh the product
                    var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
                    refreshConfiguredProduct.setParams({
                        "reload": true
                    });
                    console.log('comp value >'+ JSON.stringify(cmp.get('v.assetProducts')));
                    refreshConfiguredProduct.fire();
                    
                    cmp.set('v.isQuoteLineCreationCalled',false);
                    isQuoteLineCreationCalled=false;

                    cmp.set('v.loadingSpinner' , false);
                    //cmp.set('v.assetActiveTab', false);
                }
                else{
                    this.showToast('Error', 'There was an error while processing the request' , 'error');
                    cmp.set('v.loadingSpinner' , false);
                    cmp.set('v.isQuoteLineCreationCalled',false);
                    isQuoteLineCreationCalled=false;
                    }
            });
            $A.enqueueAction(createAction);
        }
        else{
            cmp.set('v.loadingSpinner' , false);
            cmp.set('v.isAssetAvailable', true);
            cmp.set('v.assetProducts', tempassetProductList);
        }
        
    },//SDT 33101
    getProductName : function(cmp,activeTab,assetProducts){
        var assetProduct = assetProducts.filter(j=>j.mapTabIndexProductName[activeTab]);//assetProducts[0].mapTabIndexProductName;
        var tabName = assetProduct[0].mapTabIndexProductName[activeTab] ;
        return tabName;
    },
    updateQuoteProducts : function(cmp,event,selectedAccessoryList,keyQuantityList,extraParams)
    {
        cmp.set('v.isAssetAvailable', false);
        var updatedstateasset = cmp.get('v.assetProducts');
        var currentTab = this.getProductName(cmp,cmp.get('v.assetActiveTabId'),updatedstateasset);//SDT 33101 cmp.get('v.assetActiveTabId');
        var tabCount = cmp.get('v.tabCount');

        var newState = event.getParam('currentState');
        var productId = event.getParam('currentProductId');
        var targetProduct = event.getParam('targetProduct');
        cmp.set('v.retainState', newState);
        var wasteStreamName = event.getParam('wasteStreamName');
        var QLName = event.getParam('QLName');
        var equipmentSize = event.getParam('productSize');

        //Equipment Size index
        //need to change the index in case there is any change in tab name
        // SID[1] + Product Code[2] + Waste Stream[3] + equipmentSize[4]

        cmp.set('v.currentProductId', productId);
        cmp.set('v.currentState', newState);
        cmp.set('v.currentProduct', targetProduct);

        
        if(updatedstateasset != null && updatedstateasset != undefined && updatedstateasset != '[]')
        {
            // Based to current tab filter the Product list 
            var filteredproduct= updatedstateasset.filter(j=>j.mapTabIndexProductName[cmp.get('v.assetActiveTabId')] == currentTab);
            
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
            //resetting tab count and tab name
            if(newState != undefined && newState != null && newState === 'Product')
            {
                currentTab = filteredproduct[0].productName = 'Service-' + filteredproduct[0].tabIndex;
            }
            // Logic to replace the Equipment Size
            if(newState != undefined && newState != null && newState === 'Service')
            {
                currentTab= this.replaceEquipmentSize(currentTab,equipmentSize);
                currentTab= filteredproduct[0].productName= currentTab.join("-");
            }

             if(selectedAccessoryList != undefined && selectedAccessoryList != null)
                filteredproduct[0].selectedAccessoryList =selectedAccessoryList;
            
            if(keyQuantityList != undefined && keyQuantityList != null)
                filteredproduct[0].keyQuantityList =keyQuantityList;

            if(extraParams != undefined && extraParams != null)
                filteredproduct[0].extraParams =extraParams;
            
            cmp.set('v.isAssetAvailable', true);
            cmp.set('v.assetProducts',updatedstateasset);
            cmp.set('v.assetActiveTabId',filteredproduct[0].tabIndex);//SDT 33101 currentTab); 
        }
    },
    replaceEquipmentSize : function(tabName, updatedSize)
    {
        let resultArray  = tabName.split('-');
        // find the equipmentSize to replaced with New size
        if(resultArray.length >3 && updatedSize != undefined)
        {
            resultArray[resultArray.length - 1] = updatedSize;
        }
        return resultArray;
    },
    //Changes related to SDT-39632
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
                console.log('Update State is: ' + state);
                console.log('update responsett '+response);
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
    returnToCase: function(cmp) {
        var navEvent = $A.get('e.force:navigateToSObject');
        navEvent.setParams({
            'recordId': cmp.get('v.CaseId'),
            'isredirect': true
        });
        navEvent.fire();
    }
})