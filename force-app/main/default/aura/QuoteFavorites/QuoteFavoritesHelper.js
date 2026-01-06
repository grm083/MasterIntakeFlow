({
    assignSelectedProduct : function(cmp, event, helper, productId, selectedProduct){
        cmp.set('v.showSpinner', true);
        console.log('function selectProduct productId==>'+JSON.stringify(productId));
        console.log('function selectProduct Selected Product Name Is: ' + productId.Name);
        console.log('function selectProduct Selected Product Id Is: ' + productId.Id);
        helper.getWasteStream(cmp, event);
        var favorites = cmp.get('c.getFavorites');
        favorites.setParams({
            productId: productId.Id
        });
        favorites.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var sortedFavorites = response.getReturnValue();
                sortedFavorites.sort(function(x, y){
                    let a = x.equipmentSize,
                        b = y.equipmentSize;
                    return a == b ? 0 : a > b ? 1 : -1;
                });
                console.log('Returned favorites is: ' + JSON.stringify(sortedFavorites));
                //new line for removing empty element
                sortedFavorites = helper.removeEmptyRow(sortedFavorites);
                console.log('after removal of empty row favorites is: ' + JSON.stringify(sortedFavorites));
                cmp.set('v.productFavorite', sortedFavorites)
                var getWasteStreams = cmp.get('c.getWasteStreams');
                getWasteStreams.setParams({
                    productId: productId.Id
                });
                getWasteStreams.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var wasteCategoryListResp = response.getReturnValue();
                        console.log('wasteCategoryListResp==>'+JSON.stringify(wasteCategoryListResp));
                        console.log('selectedProduct.materialType==>'+selectedProduct.materialType);
                        helper.assignSelectedMaterialId(cmp,wasteCategoryListResp,selectedProduct.materialType);
                        cmp.set('v.wasteCategoryList', response.getReturnValue());
                        var getSize = cmp.get('c.getSizes');
                        getSize.setParams({
                            productId: productId.Id,
                            returnAll: false
                        });
                        getSize.setCallback(this, function(response) {
                            console.log('Size call is: ' + response.getState());
                            if (response.getState() === 'SUCCESS') {
                                var sizesUnparsed = response.getReturnValue();
                                var sizes = [];
                                for (var key in sizesUnparsed) {
                                    sizes.push({
                                        value:sizesUnparsed[key],
                                        key:key
                                    });
                                }
                                cmp.set('v.eligibleSizes', sizes);
                                console.log('eligibleSizes==>'+JSON.stringify(sizes));
                                if(sizes && sizes.length>0){
                                    for(let i=0;i<sizes.length; i++){
                                        if(sizes[i].value==selectedProduct.equipmentSize){
                                            cmp.set("v.selectedProductEquipmentSize",sizes[i].key);
                                        }
                                    }
                                }
                                console.log('selectedProduct.equipmentSize==>'+selectedProduct.equipmentSize);
                                console.log('selectedProductEquipmentSize==>'+cmp.get("v.selectedProductEquipmentSize"));
                                cmp.set('v.showSpinner', false);
                            }
                        });
                        $A.enqueueAction(getSize);
                    }
                });
                $A.enqueueAction(getWasteStreams);
            }
        });
        $A.enqueueAction(favorites);
    },
    assignSelectedMaterialId : function(cmp,wasteCategoryList, materialType){
        if(wasteCategoryList && wasteCategoryList.length>0){
            for(let i=0;i<wasteCategoryList.length; i++){
                if(wasteCategoryList[i].SBQQ__OptionalSKU__r.Name==materialType){
                    //cmp.find("wasteList").set("v.value", wasteCategoryList[i].Id);
                    cmp.set("v.selectedProductMaterialType",wasteCategoryList[i].Id);
                }
            }
        }
    },
    getProducts : function(cmp, event, helper) {
        var getProducts = cmp.get('c.getProducts');
        getProducts.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
		const resp = response.getReturnValue();
                cmp.set('v.productList', response.getReturnValue());
                let selectedProduct = cmp.get('v.selectedProduct');
                console.log('selectedProduct==>'+JSON.stringify(selectedProduct));
                if(selectedProduct != undefined && selectedProduct.hasOwnProperty("equipmentType") && selectedProduct.equipmentType != null && selectedProduct.equipmentType != ''){
                    helper.getSelectedProductDetails(cmp, event, helper, selectedProduct);
                }
            }
        });
        $A.enqueueAction(getProducts);
    },
    getSelectedProductDetails : function(cmp, event, helper, selectedProduct){
        var action = cmp.get('c.getPreselectedProduct');
        action.setParams({
            selectedProductName: selectedProduct.equipmentType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state==>'+state);
            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();
                //cmp.set('v.productList', response.getReturnValue());
                console.log('resp==>'+JSON.stringify(resp));
                cmp.set('v.selectedProduct', resp);
                helper.assignSelectedProduct(cmp, event, helper, resp, selectedProduct);
            }
        });
        $A.enqueueAction(action);
    },
    getWasteStream : function(cmp, event) {
        var getWasteStreams = cmp.get('c.getWasteStreams');
        var productId = cmp.get('v.selectedProduct');
        getWasteStreams.setParams({
            productId: productId
        });
        getWasteStreams.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                cmp.set('v.wasteCategoryList', response.getReturnValue());
            }
        });
        $A.enqueueAction(getWasteStreams);
    },
    removeEmptyRow : function(arr){
       const newArr = [];
        for (let i = 0; i < arr.length; i++) {
            console.log('arr[i]==>'+JSON.stringify(arr[i]));
            if (this.isNotEmpty(arr[i])) {
                newArr.push(arr[i]);
            }
        }
        return newArr;
    },
    isNotEmpty : function(obj){
        if(Object.keys(obj).length === 0){
            return false;
        }
        return true;
    }
})