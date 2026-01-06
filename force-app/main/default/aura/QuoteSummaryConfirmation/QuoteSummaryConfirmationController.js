({
    doinit: function (cmp, event, helper) {
        var quoteId = cmp.get('v.recordId');
        var parentQuoteLine = cmp.get('v.targetProductId');
        const targetProduct = cmp.get("v.targetProduct");
        //SDT-37527
        var Materialgrade = cmp.get("v.targetProduct.selectedMaterialGrade");
        if(Materialgrade != '' && Materialgrade != undefined){
            cmp.set('v.showMaterialGrade', true);
        }
        else{
             cmp.set('v.showMaterialGrade', false);
        }
        //SDT-37527
        
        console.log('Quote summary targetProduct ==>' + JSON.stringify(targetProduct));
        helper.refreshTargetProduct(cmp, event);
        var quoteInfo = cmp.get('c.getQuoteStatusDetails');
        var orderInfo = cmp.get('c.getOrders')
        var statusDescription = $A.get("$Label.c.QuoteDraftDescription");
        var isAsset = cmp.get('v.isAssetAvailable');
        //Change for SDT-28571
        var checkAssetChange = cmp.get('v.extraParams.isAssetChanged');
        console.log('Asset Change State - QS: ' + checkAssetChange);


        // Changes for SDT-24401
        var existingRecords = cmp.get('v.assetProducts');
        var isTabsStateSame = true;
        if (isAsset != null && isAsset != undefined && isAsset) {
            if (existingRecords != null && existingRecords != '[]') {
                // this.assetProductList=[];
                var assetProductList = existingRecords;
                for (var i = 0; i < assetProductList.length; i++) {
                    if (assetProductList[i].currentState != 'Summary') {
                        isTabsStateSame = false;
                    }
                }
            }
            cmp.set('v.isAssetConfirmAvailable', isTabsStateSame);

            //Changes for SDT-28571
            if (checkAssetChange != null && checkAssetChange != undefined) {
                if (!checkAssetChange) {
                    cmp.set('v.isAssetChangeDisable', true);
                    var btnAddWO = cmp.find("btnAddWO");
                    btnAddWO.set("v.title", "Button Disabled Because No Service change has been detected");
                    var btnConfirmConfig = cmp.find("btnConfirmConfig");
                    if (!$A.util.isUndefinedOrNull(btnConfirmConfig))
                        btnConfirmConfig.set("v.title", "Button Disabled Because No Service change has been detected");
                }
            }
        }
        else {
            // Changes for SDT-24972
            var quoteexistingRecords = cmp.get('v.quoteProducts');
            var isquoteTabsStateSame = true;

            if (quoteexistingRecords != null && quoteexistingRecords != '[]') {
                let quoteProductList = quoteexistingRecords;
                for (var i = 0; i < quoteProductList.length; i++) {
                    if (quoteProductList[i].currentState != 'Summary' && quoteProductList[i].targetProductId != '') {
                        isquoteTabsStateSame = false;
                    }
                }
            }
            cmp.set('v.isAssetConfirmAvailable', isquoteTabsStateSame);
        }
        quoteInfo.setParams({
            quoteId: quoteId
        });
        orderInfo.setParams({
            quoteLineId: parentQuoteLine
        });
       
        quoteInfo.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                cmp.set('v.quoteStatus', response.getReturnValue().SBQQ__Status__c);
//SDT-30089 - start
    helper.getByPassSTPReasonList(cmp,response.getReturnValue().Special_Handling__c,response.getReturnValue().Special_Handling_Reason__c, response.getReturnValue().Special_Handling_Reason_Details__c);
//SDT-30089 - end
                cmp.set('v.statusDescription', statusDescription);
                cmp.set('v.currentAssignment', response.getReturnValue().Assigned_To__r.Name);
                cmp.set('v.quoteOnly', response.getReturnValue().Quote_Only__c);
                cmp.set('v.quoteType', response.getReturnValue().SBQQ__Type__c);	//TCS-pkulkarn-SDT-42718-31-Jan-2025-Added
                //SDT 33101
                cmp.set('v.showSpinner', true);
                helper.getShowQuoteOnlyButton(cmp);
                helper.getDisableQuoteOnly(cmp, event, helper);
                cmp.set('v.showSpinner', false);
                //SDT 33101 end
                orderInfo.setCallback(this, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        cmp.set('v.configuredOrders', response.getReturnValue());
                        var getPickList = cmp.get('c.getPicklistSchema');
                        getPickList.setCallback(this, function (response) {
                            if (response.getState() === 'SUCCESS') {
                                var pickListValues = response.getReturnValue();
                                //console.log('pickListValues>>>'+JSON.stringify(pickListValues));
                                cmp.set('v.servicePicklistValues', pickListValues);

                            }
                        });
                        $A.enqueueAction(getPickList);
                    }
                });
                $A.enqueueAction(orderInfo);
            }
        });
        $A.enqueueAction(quoteInfo);
    },
    handleQuoteOnly: function (cmp) {
        var quoteState = cmp.get('v.quoteOnly');
        console.log('Quote only state is: ' + quoteState);
        cmp.set('v.quoteOnly', quoteState);
        
        //SDT 33101
        var action = cmp.get("c.saveQuoteOnly");
        var quoteId = cmp.get("v.recordId");
        var quoteType = cmp.get('v.quoteType');	//TCS-pkulkarn-SDT-42718-31-Jan-2025-Added
        
        action.setParams({
            quoteId: quoteId,
            quoteOnly : quoteState, 
            quoteType : quoteType	//TCS-pkulkarn-SDT-42718-31-Jan-2025-Added
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var respons = response.getReturnValue();
                if (respons != null && respons != undefined) {
                    if(cmp.get('v.quoteOnly', true)){
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
                    }else if(cmp.get('v.quoteOnly', false)){
                        cmp.set('v.addQuoteOnlyService', false);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    //SDT33101
    addMoreQuoteOnly: function (cmp,event,helper) {
        var parent = cmp.get('v.parent');
        var recordId = cmp.get('v.recordId');
        var data = {};
        data.recordId=recordId;
        data.cpqProduct=cmp.get('v.assetProducts')[0].productId;
        data.caseId=cmp.get('v.caseId');
        data.assetId=cmp.get('v.assetProducts')[0].assetId;
        data.calledFromQuoteSummaryConfirmation = true;
        parent.set('v.data',data);
        parent.checkQuotelines();
    },
      updateStatus: function (cmp, event, helper) {
        //SDT-30108
        if(cmp.get('v.assetAvailabilityAccess')){
            helper.addAdditionalservicesComment(cmp);
        }
            //SDT-29084 - start
            var validToProcess = true;
            //var updateAssetCase = cmp.get('v.isAssetAvailable');
            var byPassStpCheckBox = cmp.get("v.byPassStpCheckBox");
            var byPassStpSelectedReasonVal = cmp.get("v.byPassStpSelectedReasonVal");
            var stpOtherReasonText = cmp.get("v.stpOtherReasonText");
            if (byPassStpCheckBox == true) {
                if (byPassStpSelectedReasonVal == '-1' || byPassStpSelectedReasonVal == undefined) {
                    validToProcess = false;
                    helper.showToast('Error', 'Please select the reason for special handling.', 'error');
                }
                if (byPassStpSelectedReasonVal == 'Other' && (stpOtherReasonText === undefined || stpOtherReasonText == '')) {
                    validToProcess = false;
                    helper.showToast('Error', 'If Special Handling Reason of �Other� is chosen, then Special Handling Details must be provided.', 'error');
                }
                // helper.saveByPassSTPValues(cmp);
            }
            if (validToProcess) {
                helper.saveByPassSTPValues(cmp);
                //SDT-29084 - End

                //changes related to SDT-25005 //modified for SDT-45088
                var addComment = cmp.get("c.addCommentForSLAOverrideFromIntake");
                addComment.setParams({
                    caseId: cmp.get('v.caseId')
                });
                addComment.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //console.log('succesfully executed backend method call');
                    }
                });
                $A.enqueueAction(addComment);
                //changes related to SDT-25005 ends

                var QuoteComment = cmp.find('Comments').get('v.value');
                console.log('QuoteComment ', QuoteComment);
                var quoteOnly = cmp.get('v.quoteOnly');
                var productWrapper = cmp.get('v.targetProduct');
                productWrapper.quoteOnly = quoteOnly;
                var updateState = cmp.getEvent('UpdateWrapperState');
                updateState.setParams({
                    "currentState": "Pricing",
                    "currentProductId": cmp.get('v.targetProductId'),
                    "targetProduct": productWrapper
                });
                updateState.fire();
                //Changes related to SDT-39632
                /*var navEvent = $A.get('e.force:navigateToSObject');
                navEvent.setParams({
                    'recordId': cmp.get('v.caseId'),
                    'isredirect': true
                });
                navEvent.fire();
                */
                if (QuoteComment || QuoteComment !== "") {
                    //Changes done for SDT-26026
                    var action = cmp.get("c.createQuoteComment");
                    action.setParams({
                        quoteComment: QuoteComment,
                        caseId: cmp.get('v.caseId')
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        console.log('Comment State ' + state);
                        if (state === "SUCCESS") {
                            // to do: refresh grid component
                            var resp = response.getReturnValue();
                            var toastEvent = $A.get("e.force:showToast");
                            if (typeof (toastEvent) != 'undefined') {
                                if (resp == 'ok') {
                                    toastEvent.setParams({
                                        "title": "Success!",
                                        "message": "A new Acorn Comment has been created successfully.",
                                        "type": "success"
                                    });
                                } else {
                                    toastEvent.setParams({
                                        "title": "Error!",
                                        "message": resp,
                                        "type": "error"
                                    });
                                }
                                //cmp.set("v.AcornComment", "");
                                // utilityAPI.minimizeUtility();
                            }
                        }
                    });
                    $A.enqueueAction(action);
                }
            }

    },
    addMore: function (cmp,event,helper) {
        //Changes done by jatan for SDT-31144 Start here
        var validToProcess = true;
        //Setion Start to udpate Spcial handling Flag
        var byPassStpCheckBox = cmp.get("v.byPassStpCheckBox");
        var byPassStpSelectedReasonVal = cmp.get("v.byPassStpSelectedReasonVal");
        var stpOtherReasonText = cmp.get("v.stpOtherReasonText");
        if (byPassStpCheckBox == true) {
            if (byPassStpSelectedReasonVal == '-1' || byPassStpSelectedReasonVal == undefined) {
                validToProcess = false;
                helper.showToast('Error', 'Please select the reason for special handling.', 'error');
            }
            if (byPassStpSelectedReasonVal == 'Other' && (stpOtherReasonText === undefined || stpOtherReasonText == '')) {
                validToProcess = false;
                helper.showToast('Error', 'If Special Handling Reason of “Other” is chosen, then Special Handling Details must be provided.', 'error');
            }
          //  helper.saveByPassSTPValues(cmp);
        }
        //Setion End to udpate Spcial handling Flag
        if (validToProcess) {
            helper.saveByPassSTPValues(cmp);
            //SDT-29084 - End
            var QuoteComment = cmp.find('Comments').get('v.value');
            //console.log('QuoteComment ', QuoteComment);
            
          
            if (QuoteComment || QuoteComment !== "") {
                //Changes done for SDT-26026
                var action = cmp.get("c.createQuoteComment");
                action.setParams({
                    quoteComment: QuoteComment,
                    caseId: cmp.get('v.caseId')
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    //console.log('Comment State ' + state);
                    if (state === "SUCCESS") {
                        // to do: refresh grid component
                        var resp = response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        if (typeof (toastEvent) != 'undefined') {
                            if (resp == 'ok') {
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "message": "A new Acorn Comment has been created successfully.",
                                    "type": "success"
                                });
                            } else {
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "message": resp,
                                    "type": "error"
                                });
                            }
                            toastEvent.fire();
                        }
                    }
                });


                $A.enqueueAction(action);
            }
       
        //} removed this closing bracket from here and end at last when updateState.fire is invoked
        //Changes done by jatan for SDT-31144 End here 
               
        // Changes for SDT-24972
        let existingRecords = [];
        var isAsset = cmp.get('v.isAssetAvailable');
        if (isAsset != null && isAsset != undefined && isAsset) {
            existingRecords = cmp.get('v.assetProducts');
        }
        else {
            existingRecords = cmp.get('v.quoteProducts');
        }

        if (existingRecords != null && existingRecords != '[]') {
            var tabCount = cmp.get('v.tabCount');

            const quoteProd = {};
            quoteProd.quoteId = cmp.get('v.recordId');
            quoteProd.tabId = 'tab' + tabCount;
            quoteProd.tabIndex = existingRecords.length + 1;
            quoteProd.productId = '';

            var tabName = 'Service' + quoteProd.tabIndex;;
            quoteProd.productName = tabName;
            quoteProd.currentState = 'Product';
            quoteProd.equipmentSize = '';
            quoteProd.targetProductId = '';
            quoteProd.targetProduct = [];
            quoteProd.keyQuantityList = [];
            quoteProd.selectedAccessoryList = [];
            existingRecords.push(quoteProd);
            tabCount = tabCount + 1;

            if (isAsset != null && isAsset != undefined && isAsset) {
                
                var mapTabIndexProductName = existingRecords[0].mapTabIndexProductName; //SDT-33101
                 mapTabIndexProductName[quoteProd.tabIndex] = tabName ; //SDT-33101
                 quoteProd.mapTabIndexProductName= mapTabIndexProductName; //SDT-33101
                 existingRecords[0].mapTabIndexProductName = mapTabIndexProductName; 
                cmp.set('v.assetProducts', existingRecords);
                cmp.set('v.assetActiveTabId', quoteProd.tabIndex); //SDT-33101
            }
            else {
                cmp.set('v.quoteProducts', existingRecords);
                cmp.set('v.quoteActiveTabId', tabName);
            }
            cmp.set('v.tabCount', tabCount);
        }



        //Resetting Accessory List to null: SDT-22397 - Start
        cmp.set('v.selectedAccessoryList', []);
        var updateState = cmp.getEvent('UpdateWrapperState');
        updateState.setParams({
            "currentState": "Product",
            "currentProductId": '',
            "targetProduct": []
        });
        updateState.fire();
        }
    },
    addPickUp: function (cmp) {
        cmp.set('v.serviceWrapper', '[]');
        var recordId = cmp.get('v.recordId');
        var getWrapper = cmp.get('c.buildWrapper');
        getWrapper.setParams({
            quoteId: recordId
        });
        getWrapper.setCallback(this, function (response) {
            var state = response.getState();
            console.log('Response is: ' + response.getState());
            if (state === 'SUCCESS') {
                var products = response.getReturnValue();
                cmp.set('v.serviceWrapper', products);
                console.log('products==>' + JSON.stringify(products));
                var showToast = false;
                let parentQLId = cmp.get('v.targetProductId');
                const selectedProduct = cmp.get("v.currentProduct");
                console.log('line#208 selectedProduct==>' + JSON.stringify(selectedProduct));
                const configuredOrders = cmp.get("v.configuredOrders");
                console.log('line#208 configuredOrders==>' + JSON.stringify(configuredOrders));
                if (configuredOrders.length > 0) {
                    cmp.set("v.inlineProdId", configuredOrders[0].Quote_Line__c);
                }
                else {
                    cmp.set("v.inlineProdId", parentQLId);
                }
                if (products.configuredProducts.length) {
                    console.log('inside 99');
                    cmp.set("v.currentProduct", products.configuredProducts[0]);
                    cmp.set("v.showOrderModal", true);
                    cmp.find('workOrderLwc1').openModal();
                    setTimeout(() => {
                        cmp.find('workOrderLwc1').getChildProducts();
                    }, 1000);
                }
            }
        });
        $A.enqueueAction(getWrapper);
    },
    msgFromChildLWC: function (cmp, event, helper) {
        console.log('msgFromChildLWC==>');
        const modelClosed = event.getParam('value');
        console.log('modelClosed==>' + modelClosed);
        if (modelClosed == true) {
            var quoteId = cmp.get('v.recordId');
            var parentQuoteLine = cmp.get('v.targetProductId');
            const targetProduct = cmp.get("v.targetProduct");
            console.log('Quote summary targetProduct ==>' + JSON.stringify(targetProduct));
            var quoteInfo = cmp.get('c.getQuoteStatusDetails');
            var orderInfo = cmp.get('c.getOrders')
            var statusDescription = $A.get("$Label.c.QuoteDraftDescription")
            quoteInfo.setParams({
                quoteId: quoteId
            });
            orderInfo.setParams({
                quoteLineId: parentQuoteLine
            });
            quoteInfo.setCallback(this, function (response) {
                if (response.getState() === 'SUCCESS') {
                    cmp.set('v.quoteStatus', response.getReturnValue().SBQQ__Status__c);
                    cmp.set('v.statusDescription', statusDescription);
                    cmp.set('v.currentAssignment', response.getReturnValue().Assigned_To__r.Name);
                    cmp.set('v.quoteOnly', response.getReturnValue().Quote_Only__c);
                    orderInfo.setCallback(this, function (response) {
                        if (response.getState() === 'SUCCESS') {
                            cmp.set('v.configuredOrders', response.getReturnValue());
                            var getPickList = cmp.get('c.getPicklistSchema');
                            getPickList.setCallback(this, function (response) {
                                if (response.getState() === 'SUCCESS') {
                                    var pickListValues = response.getReturnValue();
                                    //console.log('pickListValues>>>'+JSON.stringify(pickListValues));
                                    cmp.set('v.servicePicklistValues', pickListValues);

                                }
                            });
                            $A.enqueueAction(getPickList);
                        }
                    });
                    $A.enqueueAction(orderInfo);
                }
            });
            $A.enqueueAction(quoteInfo);
        }
    },
    goBack: function (component, event, helper) {
        var deleteQuoteOrders = component.get('c.deleteQuoteOrders');
        deleteQuoteOrders.setParams({
            quoteOrders: component.get("v.configuredOrders")
        });
        deleteQuoteOrders.setCallback(this, function (response) {
            const state = response.getState();
            console.log('state==>' + state);
            if (state === 'SUCCESS') {
                let resp = response.getReturnValue();
                console.log("resp==>" + JSON.stringify(resp));
                console.log('extraParams==>' + JSON.stringify(component.get("v.extraParams")));
                if (resp == 'SUCCESS') {
                    var updateState = component.getEvent('UpdateWrapperState');
                    updateState.setParams({
                        "currentState": "Service",
                        "currentProductId": component.get("v.targetProductId"),
                        "targetProduct": component.get("v.targetProduct"),
                        "extraParams": component.get("v.extraParams")
                    });
                    updateState.fire();
                } else {
                    helper.showToast('Error', resp, 'error');
                }
            }
        });
        $A.enqueueAction(deleteQuoteOrders);;
    },
})