({
    getSizeOptions : function(cmp, event){
        var targetProduct = cmp.get("v.targetProduct");
        var getSize = cmp.get('c.getSizes');
        getSize.setParams({
            productId: targetProduct.productId,
            returnAll: false
        });
        getSize.setCallback(this, function(response) {
           	console.log('Size call is: ' + response.getState());
            if (response.getState() === 'SUCCESS') {
                var sizesUnparsed = response.getReturnValue();
                console.log('sizesUnparsed==>'+JSON.stringify(sizesUnparsed));
                var sizes = [];
                for (var key in sizesUnparsed) {
                    console.log(sizesUnparsed[key]);
                    sizes.push({
                        value:sizesUnparsed[key],
                        key:key
                    });
                }
                console.log('sizes==>'+JSON.stringify(sizes));
                let finalSizeList = [];
                //cmp.set('v.eligibleSizes', sizes);
                //cmp.find("sizeList").set("v.value", targetProduct.equipmentSize);
                for(let i=0;i<sizes.length; i++){
                    finalSizeList.push(sizes[i].value);
                }
                console.log('finalSizeList==>'+JSON.stringify(finalSizeList));
                cmp.set('v.eligibleSizes', finalSizeList);
                console.log('targetProduct.equipmentSize==>'+targetProduct.equipmentSize);
                cmp.find("sizeList").set("v.value", targetProduct.equipmentSize);
            }
        });
        $A.enqueueAction(getSize);
    },
    //SDT-37527
    getMaterialGrade : function(cmp, event, helper) {
       var action = cmp.get("c.getMaterialTypes");
        var targetProduct = cmp.get("v.targetProduct");
        var materialNameVar = cmp.get('v.targetProduct.materialType');
        
        if(materialNameVar == 'Trash' || materialNameVar == 'Cardboard'){
                 cmp.set('v.showMaterialGrade', true);
				 action.setParams({ material : materialNameVar });
				   action.setCallback(this, function(response) {
				   var state = response.getState();
                       		   var returnval = response.getReturnValue();
					   
				 if (state === "SUCCESS") {
	                           cmp.set("v.materialTypes", response.getReturnValue());
	                           //console.log('targetProduct.selectedMaterialGrade==>'+targetProduct.selectedMaterialGrade);
	                           cmp.find("materialTypeSelect").set("v.value",targetProduct.selectedMaterialGrade); 
	                           //console.log('cmp.get("v.materialTypes")^^^ ' +cmp.get("v.materialTypes"));
	                           //var materialT = cmp.get("v.materialTypes");
                             } 
                       		 else {
					console.log("Failed with state: " + state);
				 }
			     });
        }
        else{
            cmp.set('v.showMaterialGrade', false);
        }
       
       $A.enqueueAction(action);
   
    },
    //SDT-37527
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
                targetProduct.lineFrequency = tProduct.lineFrequency;
                console.log('latest targetProduct==>'+JSON.stringify(targetProduct));
                cmp.set('v.targetProduct', targetProduct);
                this.saveWrapperValues(cmp, event);
            } else {
                console.log('Error in creating bundle.  Error is: ' + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(buildWrapper);
    },
    saveWrapperValues : function(cmp, event){
        console.log('saveWrapperValues is called');
        var validationError = false;
        var saveValues = cmp.get('c.updateQuoteOverview');
        //SDT-26217
        var companyCategory = cmp.get("v.value");
        var companyCategoryName = cmp.get("v.selectedLabel");

        var selectedMaterialGrade = cmp.get("v.targetProduct.selectedMaterialGrade"); //sdt-32757
	if(companyCategory!=null &&  companyCategory == 'EPR' && companyCategoryName.length == 0){
            companyCategoryName = 'Equipment Repair';
        }
        cmp.set('v.targetProduct.companyCategory',companyCategory)
        cmp.set('v.targetProduct.companyCategoryName',companyCategoryName)
        //sdt-32757
        cmp.set('v.targetProduct.selectedMaterialGrade',selectedMaterialGrade) 
        //End SDT-26217
        var currentProduct = cmp.get('v.targetProduct');
        currentProduct.equipmentSize = cmp.find("sizeList").get("v.value");
        console.log('currentProduct==>'+JSON.stringify(currentProduct));
        var currentProductId = cmp.get('v.targetProductId');
        /*var errorMessage = '';
        var slaDate = cmp.get('v.slaDate');
        if (currentProduct.startDate > currentProduct.endDate) {
            validationError = true;
            errorMessage = errorMessage + 'The end date cannot occur before the start date. \n'
        }
        if (slaDate > currentProduct.startDate && currentProduct.slaOverrideReason == '') {
            validationError = true;
            errorMessage = errorMessage + 'An SLA Override Reason must be provided. \n'
        }
        
        if (currentProduct.slaOverrideReason == 'Other' && currentProduct.slaOverrideComment == null) {
            validationError = true;
            errorMessage = errorMessage + 'When selecting other, a comment must be provided. \n'
        }
        //Commenting above part and adding below piece of code as a part os SDT-26016 to make SLA Override Comments mandatory incase of SLA Override
        if (slaDate > currentProduct.startDate && currentProduct.slaOverrideComment == null) {
            validationError = true;
            errorMessage = errorMessage + 'When overriding sla date, SLA Override comment must be provided. \n'
        }*/
        if (!validationError) {
            saveValues.setParams({
                productWrapper: currentProduct
            });
            saveValues.setCallback(this, function(response) {
                console.log('response==>'+JSON.stringify(response.getState()));
                //this.validateRemovalDate(cmp, event);
				this.fireCompEvent(cmp);
            });
            $A.enqueueAction(saveValues);
        } else {
            cmp.find("Id_spinner").set("v.class", 'slds-hide');
            var warningToast = $A.get('e.force:showToast');
            warningToast.setParams({
                'title': 'Review Errors Below',
                'message': errorMessage,
                'type': 'warning'
            });
            warningToast.fire();
        }
    },
    validateRemovalDate : function(cmp, event){
        var currentProduct = cmp.get('v.targetProduct');
        if(currentProduct.hasOwnProperty('endDate') && currentProduct.endDate!= undefined && currentProduct.endDate!= ''){
			this.validateHaulOrRemovalqLine(cmp, event);       
        }/*else if(!currentProduct.hasOwnProperty('endDate') && currentProduct.duration == 'Temporary' && currentProduct.endDate!= undefined && (currentProduct.endDate == '' || currentProduct.endDate == null)){
            this.deleteHaulorRemovalqLine(cmp, event); 
        }*/
        else{
            this.deleteHaulorRemovalqLine(cmp, event);
        }
    },
    /*SDT-25277 Deleting Removal Quoteline*/
    deleteHaulorRemovalqLine: function(cmp,event){
        const targetProduct  = cmp.get("v.targetProduct");
        var deleteHaulRemovalqLine = cmp.get('c.deleteHaulRemovalqLine');
        deleteHaulRemovalqLine.setParams({
            parentQLineId: targetProduct.parentId
        });
        deleteHaulRemovalqLine.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if(state==='SUCCESS'){
                console.log('response==>'+response.getReturnValue());
                if(response.getReturnValue()=='SUCCESS'){
                    // Calling Configured product event to refresh the product
                    var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
                    refreshConfiguredProduct.setParams({
                        "reload": true
                    });
                    refreshConfiguredProduct.fire();
                    
                    this.fireCompEvent(cmp);
                }else{
                    var warningToast = $A.get('e.force:showToast');
                    warningToast.setParams({
                        'title': 'Review Errors Below',
                        'message': response,
                        'type': 'warning'
                    });
                    warningToast.fire();
                }   
            }
        });
        $A.enqueueAction(deleteHaulRemovalqLine); 
    },
    validateHaulOrRemovalqLine : function(cmp, event){
        console.log('validateHaulOrRemovalqLine');
        const targetProduct  = cmp.get("v.targetProduct");
        console.log('targetProduct==>'+targetProduct);
        console.log('parent Quote line id==>'+targetProduct.parentId);
        var vHaulRemovalqLine = cmp.get('c.validateHaulRemovalqLine');
        vHaulRemovalqLine.setParams({
            parentQLineId: targetProduct.parentId,
            endDate : targetProduct.endDate
        });
        vHaulRemovalqLine.setCallback(this, function(response){
            var state = response.getState();
            console.log('state==>'+state);
            if(state==='SUCCESS'){
                console.log('response==>'+response.getReturnValue());
                if(response.getReturnValue()=='SUCCESS'){

                    // Calling Configured product event to refresh the product
                    var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
                    refreshConfiguredProduct.setParams({
                        "reload": true
                    });
                    refreshConfiguredProduct.fire();

                    this.fireCompEvent(cmp);
                }else{
                    var warningToast = $A.get('e.force:showToast');
                    warningToast.setParams({
                        'title': 'Review Errors Below',
                        'message': response,
                        'type': 'warning'
                    });
                    warningToast.fire();
                }   
            }
        });
        $A.enqueueAction(vHaulRemovalqLine);   
    },
    fireCompEvent : function(cmp){
        var currentProductId = cmp.get('v.targetProductId');
        var currentProduct = cmp.get('v.targetProduct');
        var updateState = cmp.getEvent('UpdateWrapperState');
        var selectedAccessoryList = cmp.get('v.selectedAccessoryList');
        var keyQuantityList = cmp.get('v.keyQuantityList');
        var equipmentSize= cmp.find("sizeList").get("v.value");

        updateState.setParams({
            "currentState": "Service",
            "currentProductId": currentProductId,
            "targetProduct": currentProduct,
            "selectedAccessoryList": selectedAccessoryList,
            "keyQuantityList": keyQuantityList,
            "productSize": equipmentSize
        });
        updateState.fire();
    },
    getConfigurations : function(cmp) {
        cmp.set('v.configSpinner', true);
        var productId = cmp.get('v.targetProduct.productId');
        var parentId = cmp.get('v.targetProduct.parentId')
        console.log('Product Id is: ' + productId + 'and Quote Line Id is: ' + parentId);
        var getConfigAttributes = cmp.get('c.getConfigAttributes');
        getConfigAttributes.setParams({
            productId: productId,
            quoteLineId: parentId
        });
        getConfigAttributes.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State is: ' + state);
            if (state === 'SUCCESS') {
                cmp.set('v.configList', response.getReturnValue());
                cmp.set('v.configSpinner', false);
                var returnVal = response.getReturnValue();
                console.log(returnVal.length);
                for (let i = 0; i < returnVal.length; i++) {
                    returnVal[i].Picklist_Values__c = JSON.parse(returnVal[i].Picklist_Values__c);
                    returnVal[i].SelectedValue = '';
                }
                console.log('Returned configs are: ' + JSON.stringify(returnVal));
                cmp.set('v.configList', returnVal);
            } else {
                console.log('Error with returning configs is: ' + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(getConfigAttributes);
    },
    getAccessories : function(cmp) {
        cmp.set('v.attrSpinner', true);
        var productId = cmp.get('v.targetProduct.productId');
        var keyQuantityList = cmp.get('v.keyQuantityList');
        console.log('keyQuantityList>>>1'+JSON.stringify(keyQuantityList));
       
        //SDT-31752 - Introduced a new Aura method utilizing earlier getAccessories
        var getAccessories = cmp.get('c.getAccessoriesWithSelection');
        //var getAccessories = cmp.get('c.getAccessories');
        getAccessories.setParams({
            productId: productId,
            quoteId	 : cmp.get('v.recordId')
        });
        getAccessories.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                let result = response.getReturnValue();
                // SDT-31752
                var returnVal = result["AllAccessory"];
                let selectedAccessory = result["SelectedAccessory"];
                let mapOptionIdAndOptionSKUId = result["mapOptionIdAndOptionSKUId"];
                let disabledAccessoryList = result["disabledAccessoryList"];
                
                cmp.set('v.mapOptionIdAndOptionSKUId',mapOptionIdAndOptionSKUId[0]);
                cmp.set('v.selectedAccessoryList',selectedAccessory);
                cmp.set('v.disabledAccessoryList',disabledAccessoryList); // Changes for SDT-31752
                let padLockProdIdSet = [];
                for (let i = 0; i < returnVal.length; i++) {
                    
                    returnVal[i].ProductName = returnVal[i].SBQQ__OptionalSKU__r.Name;
                    returnVal[i].ContainerName = returnVal[i].SBQQ__ConfiguredSKU__r.Name;
                    returnVal[i].ProductSelected = this.checkIfAlreadySelected(cmp,returnVal[i].SBQQ__OptionalSKU__c); //SDT-31752
                    // Changes for SDT-31752
                    returnVal[i].productDisabled = this.checkIfProductDisabled(cmp,returnVal[i].SBQQ__OptionalSKU__c); //SDT-31752
                    if(returnVal[i].ContainerName === 'Dumpster'){
                        padLockProdIdSet.push(returnVal[i].SBQQ__OptionalSKU__c);
                    }
                }
                             
                
                if(padLockProdIdSet.length > 0){

                    var getPadLockKeys = cmp.get('c.getPadlockKeys');
                    getPadLockKeys.setParams({
                        padLockIdList: padLockProdIdSet
                    });
                    getPadLockKeys.setCallback(this,function(response) {
                        var state = response.getState();
                        if (state === 'SUCCESS') {
                            var padlockOptions = response.getReturnValue();
                            if(padlockOptions){
                                for (let i = 0; i < returnVal.length; i++) {
                                    for(let j = 0; j < padlockOptions.length; j++){
                                        if(returnVal[i].SBQQ__OptionalSKU__c == padlockOptions[j].SBQQ__ConfiguredSKU__c){
                                            returnVal[i].key = padlockOptions[j].SBQQ__OptionalSKU__r.Name;
                                            console.log('returnVal[i].ProductSelected>>'+returnVal[i].ProductSelected);
                                            returnVal[i].showKey = returnVal[i].ProductSelected;
                                            returnVal[i].keyId = padlockOptions[j].SBQQ__OptionalSKU__r.Name == 'Keys' ? padlockOptions[j].Id : '';
                                            for(let k = 0;k<keyQuantityList.length;k++){
                                                if(keyQuantityList[k].id == returnVal[i].keyId){
                                                    returnVal[i].SBQQ__Quantity__c = keyQuantityList[k].value;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            cmp.set('v.accessoryList', returnVal);
                            
                        }
                    });
                    $A.enqueueAction(getPadLockKeys);
                }else{
                    cmp.set('v.accessoryList', returnVal);
                }
                cmp.set('v.attrSpinner', false);
            }
        });
        $A.enqueueAction(getAccessories);
    },
    checkIfAlreadySelected : function(cmp,Id) {        
     	// It carries the ProductOption Id of the Quotelines.
        var selectedAccessoryList = cmp.get('v.selectedAccessoryList');
		
        // SDT-31752 - In order to compare the Product on ProductOption 
        // with the Product on ProductOption on the Quoteline.
        let mapOptionIdAndOptionSKUId = cmp.get('v.mapOptionIdAndOptionSKUId');
		
        if($A.util.isUndefinedOrNull(selectedAccessoryList)){return false;}
        
        for(let i=0;i<selectedAccessoryList.length;i++){
            
            if(mapOptionIdAndOptionSKUId[selectedAccessoryList[i]]===Id){
                return true;
            }                        
        }
        return false;  
    },
    // Changes for SDT-31752
    checkIfProductDisabled : function(cmp,Id) {        
        // It carries the ProductOption Id of the Quotelines.
        var disabledAccessoryList = cmp.get('v.disabledAccessoryList');
        
        if($A.util.isUndefinedOrNull(disabledAccessoryList)){return false;}
        
        for(let i=0;i<disabledAccessoryList.length;i++){
            
            if(disabledAccessoryList[i] ==Id){
                return true;
            }                        
        }
        return false;  
    },
    addOptions : function(cmp, selectedRecord, keyOptionId) {
        cmp.set('v.attrSpinner', true);
        var parentId = cmp.get('v.targetProduct.parentId');      
        var addOption = cmp.get('c.addProductOption');
        
        addOption.setParams({
            quoteLineId: parentId,
            productOptionId: selectedRecord            
        });
        addOption.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                //console.log('Response from Apex: ' + response.getReturnValue());
                let qlineId = response.getReturnValue();
                //console.log('Response from Apex: ' + qlineId);
                if(typeof keyOptionId!== 'undefined' && keyOptionId!== null && keyOptionId!== ''){
                    this.addKeys(cmp, qlineId, keyOptionId);
                }
            } else {
                console.log('Error adding option: ' + JSON.stringify(response.getError()));
            }
            cmp.set('v.attrSpinner', false);
        });
        $A.enqueueAction(addOption)
    },
    getOptionalSKU : function(accessoryList, selectedRecord) {
	    //SDT-31752
        for(let i=0;i<accessoryList.length; i++){
            
            if(accessoryList[i].Id===selectedRecord){
                return accessoryList[i].SBQQ__OptionalSKU__c;
            }
        }
    },		
    removeOptions : function(cmp, selectedRecord, keyOptionId) {
        cmp.set('v.attrSpinner', true);
        var parentId = cmp.get('v.targetProduct.parentId');
        var remOption = cmp.get('c.removeProductOption');
        //SDT-23055: fetching keys quantity and accessory to remove the unchecked options and its quantites.
        let keyQuantityList = cmp.get('v.keyQuantityList');
        let accessList = cmp.get('v.accessoryList');
	let selectedOptionSKU = this.getOptionalSKU(accessList,selectedRecord);// 31752
	    
        if(typeof keyOptionId!== 'undefined' && keyOptionId!== null && keyOptionId!== ''){
            remOption.setParams({
                quoteLineId: parentId,
                productOptionId: selectedOptionSKU, //31752
		keyOptionId: keyOptionId
            });
        }else{
            remOption.setParams({
                quoteLineId: parentId,
                productOptionId: selectedOptionSKU, //31752
            });
        }
        
        remOption.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                for(let k = 0;k<keyQuantityList.length;k++){
                    if(keyQuantityList[k].id == keyOptionId){
                        keyQuantityList.pop(keyQuantityList[k]);
                    }
                }
                for(let k = 0;k<accessList.length;k++){
                    if(accessList[k].keyId == keyOptionId){
                        accessList[k].SBQQ__Quantity__c = 1;
                    }
                }
                cmp.set('v.accessoryList',accessList);
                cmp.set('v.keyQuantityList',keyQuantityList);
                //console.log('Response from Apex: ' + response.getReturnValue());
            } else {
                console.log('Error adding option: ' + JSON.stringify(response.getError()));
            }
            cmp.set('v.attrSpinner', false);
        });
        $A.enqueueAction(remOption)
    },
    addKeys: function(cmp, selectedRecord, selectedKey){
        cmp.set('v.attrSpinner', true);
        var parentId = selectedRecord;    
        var addOption = cmp.get('c.addProductOption');

        addOption.setParams({
            quoteLineId: parentId,
            productOptionId: selectedKey            
        });
        addOption.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Response from Apex: ' + response.getReturnValue());
            } else {
                console.log('Error adding option: ' + JSON.stringify(response.getError()));
            }
            cmp.set('v.attrSpinner', false);
        });
        $A.enqueueAction(addOption)
    },
    updateKeysQuantity : function(cmp){
        cmp.set('v.attrSpinner', true);
        let parentId = cmp.get('v.targetProduct.parentId');
        let keyRec = cmp.get('v.keyQuantityList');
        //console.log('keyRec>>>'+keyRec);
        //console.log('keyRec>>>'+JSON.stringify(keyRec));
        var updateKey = cmp.get('c.updateKeysQuantity');
        updateKey.setParams({
            parentId : parentId,
            keyObj : keyRec
        });
        updateKey.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Response from Apex: ' + response.getReturnValue());
            } else {
                console.log('Error adding option: ' + JSON.stringify(response.getError()));
            }
            cmp.set('v.attrSpinner', false);
        });
        $A.enqueueAction(updateKey);
	},
    retryProducts : function(cmp, event, helper){
        var allProducts;
        var recordId = cmp.get('v.recordId');
        var buildWrapper = cmp.get('c.buildWrapper');
        buildWrapper.setParams({
            quoteId: recordId
        });
        buildWrapper.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State is: ' + state);
            if (state === 'SUCCESS') {
                allProducts = response.getReturnValue().configuredProducts;
                if(allProducts && allProducts.length>0){
                    return allProducts;
                }else{
                    var errorToast = $A.get('e.force:showToast');
                    errorToast.setParams({
                        'title': 'Error',
                        'message': 'There are no Products available.',
                        'type': 'error'
                    });
                    errorToast.fire();
                    return null;
                }
            }else {
                console.log('Error in creating bundle.  Error is: ' + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(buildWrapper);
    },
    
    showErrorForEmptyCC : function(cmp, event) {
        var errorToast = $A.get('e.force:showToast');
        errorToast.setParams({
            'title': 'Error',
            'message': 'Fill the Company Category Details.',
            'type': 'error'
        });
        errorToast.fire();
    },
    
    getReqBRCC : function(cmp,event,helper){
        //changes done for SDT-31830
        var action = cmp.get("c.getReqBusinessRulesCC");
        action.setParams({
          quoteId :cmp.get('v.recordId')
        });
            action.setCallback(this, function(response) {
                let state = response.getState();
                console.log('1 state '+state);
                console.log('1 isReqQuoteCC :: '+response.getReturnValue());
                if(state === "SUCCESS") {
                    console.log('2 isReqQuoteCC :: '+response.getReturnValue());
                    cmp.set("v.isReqQuoteCC", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
          //SDT-31830 changes end
    }

})