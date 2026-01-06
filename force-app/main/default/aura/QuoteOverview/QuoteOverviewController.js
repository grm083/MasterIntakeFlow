({
    doinit : function(cmp, event, helper) {
        var targetProduct = cmp.get("v.targetProduct");
        console.log('targetProduct==>'+JSON.stringify(targetProduct));
        var selectedProduct = cmp.get("v.selectedProduct");
        console.log('selectedProduct==>'+JSON.stringify(selectedProduct));
        var targetProductId = cmp.get('v.targetProductId');
        console.log('created target product id is ==>'+targetProductId);
        var recordId = cmp.get('v.recordId');
        // Checking for Asset to make controls enable SDT-24401
        var isAsset = cmp.get('v.isAssetAvailable');
        if(isAsset)
        {
            cmp.set('v.isDisabled', false);
        }else{
            cmp.set('v.isDisabled', true);
        }

	// Call Helper Function SDT-31830
    	helper.getReqBRCC(cmp, event, helper);

        //changes done for SDT-26217
        var action = cmp.get("c.getCompanyCategory");
        action.setParams({
        quoteId :recordId
        });
        console.log('Record ID ' +recordId)
        action.setCallback(this, function(response) {
            let state = response.getState();
            console.log('getCompanyCategory '+ state);
            if(state === "SUCCESS") {
                console.log(response.getReturnValue());
                cmp.set("v.options", response.getReturnValue());
                cmp.set("v.label", response.getReturnValue()[0].label);
                cmp.set("v.value", response.getReturnValue()[0].value);
                //component.set("v.selected", response.getReturnValue()[0].label);
            }
        });
        $A.enqueueAction(action);
      //SDT-26217 changes end
        var buildWrapper = cmp.get('c.buildWrapper');
        buildWrapper.setParams({
            quoteId: recordId
        });
        buildWrapper.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State is: ' + state);
            if (state === 'SUCCESS') {
                var allProducts = response.getReturnValue().configuredProducts;
                if(allProducts == undefined || allProducts == null || allProducts.length == 0){
                    allProducts = helper.retryProducts(cmp, event, helper);
                }
                console.log('allProducts==>'+JSON.stringify(allProducts));
                //console.log('allProducts.length==>'+allProducts.length);
                var prdSize = 0;
                if(allProducts && allProducts.length>0){
                    prdSize = allProducts.length;
                }
                for (let i = 0; i < prdSize; i++) {
                    console.log('Checking: ' + allProducts[i].parentId);
                    
                    //SDT-26217
                    cmp.set("v.value", allProducts[i].companyCategory);
                    //Get company Categories - Jatan
                    // var compCategories = [];
                    // for (var entry in allProducts[i].companyCategories) {
                    // compCategories.push({ value: allProducts[i].companyCategories[entry], key: entry });
                    // }
                    // cmp.set("v.companyCategories", compCategories);
                    //End
                   
            
                    if (allProducts[i].parentId == targetProductId) {
                        console.log('allProducts[i].parentId==>'+allProducts[i].parentId);
                        console.log('targetProductId==>'+targetProductId);
                        console.log('Returned quantity is: ' + allProducts[i].quantity);
                        if (typeof allProducts[i].quantity === 'undefined') {
                            allProducts[i].quantity = 1;
                        }
                        if(!isAsset)
                        {
                            if (allProducts[i].duration == 'Permanent') {
                                cmp.set('v.endDisabled', true);
                            }
                        }
                        cmp.set('v.targetProduct', allProducts[i]);
                        //cmp.set('v.slaDate', allProducts[i].startDate);
			            cmp.set('v.slaDate', allProducts[i].originalSLAstartDate);
                        let existingRecords = [];
                        if(isAsset)
                        {
                            existingRecords= cmp.get('v.assetProducts');
                        }
                        else{
                            existingRecords= cmp.get('v.quoteProducts');
                        }
                        if(existingRecords!=null && existingRecords !='[]')
                        {
                            // Based to current tab filter the Product list
                            var filteredproduct= existingRecords.filter(j=>j.targetProductId == targetProductId);
                            if(filteredproduct!=null && filteredproduct[0].productName !='' && filteredproduct[0].productName != null && filteredproduct[0].productName != undefined && filteredproduct[0].productName.includes('Service'))
                            {
                                var updateQuoteProduct = cmp.getEvent('UpdateQuoteProducts');
                                updateQuoteProduct.setParams({
                                    "wasteStreamName": allProducts[i].materialTypeCode,
                                    "QLName": allProducts[i].quoteLineName,
                                    "equipmentSize": allProducts[i].equipmentSize
                                });
                                updateQuoteProduct.fire();
                            } else if(cmp.get("v.assetAvailabilityAccess")) { // SDT-29100
                                    var childComponent = cmp.find("serviceSchedulerId");
                                    var message = childComponent.invokeAAVapi();
                                                                
                            }
                        }
                        
                        var getPicklists = cmp.get('c.getSLAOverrideReasons');
                        getPicklists.setCallback(this, function(response) {
                            var slaReasons = response.getReturnValue();
                            //Commented by Seema for STP-27107 
                            //cmp.set('v.slaReasons', slaReasons);
                            //Commented by Seema for STP-27107 end
                            helper.getConfigurations(cmp);
                            helper.getAccessories(cmp);
                            helper.getSizeOptions(cmp,event);
                            helper.getMaterialGrade(cmp,event); // SDT-37527
                        });
                        $A.enqueueAction(getPicklists);
                        break;
                    }
                }
             
                
                var quantityEditability = cmp.get('v.targetProduct.quantityEditable')
                console.log('Quantity editability should be: ' + !quantityEditability);
                // Changes for SDT-28572
                cmp.set('v.quantityDisabled', !quantityEditability);
                
                const targetProductVar = cmp.get("v.targetProduct"); 
                console.log('targetProductVar==>'+JSON.stringify(targetProductVar));
                /*cmp.set("v.slaCommentsExists",false);
                console.log('line 46-->'+targetProductVar.hasOwnProperty('slaOverrideReason'));
                if(targetProductVar.hasOwnProperty('slaOverrideReason')){
                    const slaOverrideReason = targetProductVar.slaOverrideReason;
                    console.log('slaOverrideReason-->'+slaOverrideReason);
                    if (slaOverrideReason){
                        cmp.set("v.slaCommentsExists",true);
                    }
                }*/
                console.log('slaCommentsExists==>'+cmp.get("v.slaCommentsExists"));
            } else {
                console.log('Error in creating bundle.  Error is: ' + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(buildWrapper);
    },
    saveValues: function(cmp, event, helper) {
        console.log('saveValues is called');
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        helper.refreshTargetProduct(cmp, event);
    },
    handleSectionOpen: function(cmp, event, helper) {
        cmp.set('v.configLoaded', false);
        cmp.set('v.attrLoaded', false);
        if (!cmp.get('v.configLoaded')) {
            helper.getConfigurations(cmp);
        }
        if (!cmp.get('v.attrLoaded')) {
            helper.getAccessories(cmp);
        }
    },
    updateConfig: function(cmp, event) {
 
        console.log('Updating configuration attributes.');
        cmp.set('v.configSpinner', true);
        var targetField = event.getSource().get('v.title');
        var targetValue = event.getSource().get('v.value');
        var targetQL = cmp.get('v.targetProductId');
        // Changes for SDT-30514
        var recordId = cmp.get('v.recordId');
        console.log('Attribute params are ' + targetField + targetValue + targetQL);
        var updateConfig = cmp.get('c.updateConfigAttribute');
        updateConfig.setParams({
            quoteLineId: targetQL,
            fieldName: targetField,
            fieldValue: targetValue,
            quoteId: recordId
        });
        updateConfig.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var toastEvent = $A.get('e.force:showToast');
               // toastEvent.setParams({
               //     'message': response.getReturnValue()
               // });
               // toastEvent.fire();
            } else {
                console.log('Error Returned is: ' + JSON.stringify(response.getError()));
            }
            cmp.set('v.configSpinner', false);
        });
        $A.enqueueAction(updateConfig);
    },
    onChange : function(cmp, event, helper) {
       var checkValue = event.getSource().get('v.checked');
       var selectedRecord =  event.getSource().get('v.value');
   
        if(checkValue){
            //SDT-23055:<start> adding logic for padlock-keys.
            let accessList = cmp.get('v.accessoryList');
            let keyOptionId ='';
            //console.log('accessList>>>'+JSON.stringify(accessList));
            if(accessList.length > 0){
                for(let i = 0; i < accessList.length; i++){
                    if(accessList[i].Id == selectedRecord && typeof accessList[i].key!== 'undefined' && accessList[i].key!== null && accessList[i].key!== ''){
                        accessList[i].showKey = true;
                        keyOptionId = accessList[i].keyId;
                    }
                }
                cmp.set('v.accessoryList',accessList);
                //console.log('accessoryList>>>>'+cmp.get('v.accessoryList'));
            }
            helper.addOptions(cmp, selectedRecord, keyOptionId);
            //SDT-23055:<stop>
            let selectedAccessoryList = cmp.get('v.selectedAccessoryList');
            selectedAccessoryList.push(selectedRecord);
            cmp.set('v.selectedAccessoryList',selectedAccessoryList);
            
        }
        else{
            //SDT-23055:<start> adding logic for padlock-keys.
            let accessList = cmp.get('v.accessoryList');
            let keyOptionId ='';
            //console.log('accessList>>>'+JSON.stringify(accessList));
            if(accessList.length > 0){
                for(let i = 0; i < accessList.length; i++){
                    if(accessList[i].Id == selectedRecord && typeof accessList[i].key!== 'undefined' && accessList[i].key!== null && accessList[i].key!== ''){
                        accessList[i].showKey = false;
                        keyOptionId = accessList[i].keyId;
                    }
                }
                cmp.set('v.accessoryList',accessList);
                //console.log('accessoryList>>>>'+cmp.get('v.accessoryList'));
            }
            helper.removeOptions(cmp, selectedRecord, keyOptionId);
            //SDT-23055:<stop>
            let selectedAccessoryList = cmp.get('v.selectedAccessoryList');
            selectedAccessoryList.pop(selectedRecord);
            cmp.set('v.selectedAccessoryList',selectedAccessoryList);
        }    
	},
    //SDT-23055 adding logic to update the quantity of keys
    handleKeysQuantity: function(cmp, event, helper){
        //var validity = cmp.find("keysquant").get("v.validity");
        let inputs = document.querySelectorAll('.slds-input');
        //console.log('inp>>>>'+inputs);
        //console.log('inp>>>'+JSON.stringify(inputs));
        let keyIdAndQuantity = [];
        let accessList = cmp.get('v.accessoryList');
        for (let i = 0 ; i < inputs.length ; i++) {
            console.log(inputs[i].id + ' ' + inputs[i].value);
            let entry = {id:inputs[i].id,value:inputs[i].value}
            const reg = new RegExp('^[0-9]+$');
            for(let j=0;j<accessList.length;j++){
                if(typeof accessList[j].keyId!== 'undefined' && accessList[j].keyId!== null && accessList[j].keyId!== '' && typeof inputs[i].id!== 'undefined' && inputs[i].id!== null && inputs[i].id!== '' && inputs[i].id === accessList[j].keyId){
                    if(typeof inputs[i].value !== 'undefined' && inputs[i].value !== null && inputs[i].value !== '' && reg.test(inputs[i].value)){
                        accessList[j].SBQQ__Quantity__c = inputs[i].value;
                    }else{
                        entry = {id:inputs[i].id,value:0}
                        accessList[j].SBQQ__Quantity__c = 0;
                    }
                }
            }
            keyIdAndQuantity.push(entry);
        }
        cmp.set('v.accessoryList',accessList);
        cmp.set('v.keyQuantityList',keyIdAndQuantity);
        helper.updateKeysQuantity(cmp);
    },
    
    validateParentFields : function(cmp, event, helper){
        console.log('validateParentFields is called');
        //var message = event.getParam("message");
        //console.log('message==>'+message);
        //Display Error
        var companyCategory = cmp.get("v.value");
        var companyCategoryName = cmp.get("v.selectedLabel");
        var isReqQuoteCC = cmp.get("v.isReqQuoteCC");
        
        console.log('companyCategory : ' + companyCategory + 'companyCategoryName : ' + companyCategoryName);
        // Show Error message is empty
        if( isReqQuoteCC && (companyCategoryName == undefined || companyCategoryName == null || companyCategoryName.length == 0 ) &&
           (companyCategory == undefined || companyCategory == null || companyCategory.length == 0) 
          ){
            helper.showErrorForEmptyCC(cmp, event);
        }else{
        	var validationError = false;
            var currentProduct = cmp.get('v.targetProduct');
            currentProduct.equipmentSize = cmp.find("sizeList").get("v.value");
            console.log('currentProduct==>'+JSON.stringify(currentProduct));
            var currentProductId = cmp.get('v.targetProductId');
           
            
            //Commented by Seema for STP-27107 
            /*var errorMessage = '';
            var slaDate = cmp.get('v.slaDate');
            
            if (currentProduct.startDate > currentProduct.endDate) {
                validationError = true;
                errorMessage = errorMessage + 'The end date cannot occur before the start date. \n'
            }
            if (slaDate > currentProduct.startDate && (currentProduct.slaOverrideReason==null || currentProduct.slaOverrideReason=='')) {
                validationError = true;
                errorMessage = errorMessage + 'An SLA Override Reason must be provided. \n'
            }
            if (slaDate > currentProduct.startDate && (currentProduct.slaOverrideComment==null  || currentProduct.slaOverrideComment=='')) {
                validationError = true;
                errorMessage = errorMessage + 'When overriding sla date, SLA Override comment must be provided. \n'
            }*/
            //Commented by Seema for STP-27107 end
            console.log('validationError :: ' + validationError);
            if (!validationError) {
                console.log('Inside validationError :: ' + validationError);
                var childComponent = cmp.find("serviceSchedulerId");
                var message = childComponent.fireSchedulerSubmit();
                console.log('message : ' + message);
            } else {
                console.log('Inside else if ' + errorMessage);
                cmp.find("Id_spinner").set("v.class", 'slds-hide');
                var warningToast = $A.get('e.force:showToast');
                warningToast.setParams({
                    'title': 'Review Errors Below',
                    'message': 'abc'+errorMessage,
                    'type': 'warning'
                });
                warningToast.fire();
            }    
            }
        
        
        
    },
    //SDT-26217
    handleOnChange : function(component, event, helper) {
        let selectedLabel = event.getParam('label');
        component.set("v.selectedLabel",selectedLabel);
    }
})