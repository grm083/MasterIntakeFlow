({
    doInit : function(cmp, event, helper) {
        console.log('Curent stage is: ' + cmp.get('v.currentStage'));
        cmp.set('v.selectedProduct', '[]');
        helper.getProducts(cmp, event, helper);
    },
    searchProductTable: function(cmp, event, helper) {
        var queryProducts = cmp.find('searchProducts').get('v.value');
        if(queryProducts.length > 3) {
            var searchProducts = cmp.get('c.searchProducts');
            searchProducts.setParams({
                queryString: queryProducts
            });
            searchProducts.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    cmp.set('v.productList', response.getReturnValue());
                }
            });
            $A.enqueueAction(searchProducts);
        } else if (queryProducts.length <= 3) {
            helper.getProducts(cmp, event);
        }
    },
    searchMaterialTable: function(cmp, event, helper) {
        var queryMaterials = cmp.find('searchMaterials').get('v.value');
        console.log('Query materials is: ' + queryMaterials);
        if(queryMaterials.length > 3) {
            var searchWasteStreams = cmp.get('c.searchWasteStreams');
            searchWasteStreams.setParams({
                queryString: queryMaterials
            });
            searchWasteStreams.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    cmp.set('v.wasteCategoryList', response.getReturnValue());
                }
            });
            $A.enqueueAction(searchWasteStreams);
        } else if (queryMaterials.length <= 3) {
            helper.getWasteStream(cmp, event);
        }
    },
    back : function(cmp, event, helper){
        const arr=[];
        cmp.set('v.selectedProduct', '[]');
    },
    selectProduct: function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        var productId = event.getSource().get("v.value");
        console.log('function selectProduct productId==>'+JSON.stringify(productId));
        console.log('function selectProduct Selected Product Name Is: ' + productId.Name);
        console.log('function selectProduct Selected Product Id Is: ' + productId.Id);
        cmp.set('v.selectedProduct', productId);
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
                        cmp.set('v.wasteCategoryList', response.getReturnValue());
                        // Changes done by jatan forSDT - 23951 start
                        var wasteCategoryListResp = response.getReturnValue();
                        if (wasteCategoryListResp && wasteCategoryListResp.length > 0) {
                            cmp.set("v.selectedProductMaterialType", wasteCategoryListResp[0].Id);
                        }
                        // End
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
                                    console.log(sizesUnparsed[key]);
                                    sizes.push({
                                        value:sizesUnparsed[key],
                                        key:key
                                    });
                                }
                                cmp.set('v.eligibleSizes', sizes);
                                //Changes done by jatan forSDT-23951 start
                                if (sizes && sizes.length > 0) {
                                    cmp.set("v.selectedProductEquipmentSize", sizes[0].key);
                                }
                                //end
                                cmp.set('v.showSpinner', false);
                                cmp.find("Id_spinner").set("v.class", 'slds-hide');
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
    addFavorite: function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        var quoteId = cmp.get('v.recordId');
        var favoriteId = event.getSource().get('v.value');
        console.log('Favorite Id is: ' + favoriteId);
        var createLines = cmp.get('c.addQuoteFavorite');
        createLines.setParams({
            favoriteId: favoriteId,
            quoteId: quoteId
        });
        createLines.setCallback(this, function(response) {
            var currentProductId = response.getReturnValue();
            cmp.set('v.createdProduct', currentProductId);
            var updateState = cmp.getEvent('UpdateWrapperState');
            updateState.setParams({
                "currentState": "Overview",
                "currentProductId": response.getReturnValue(),
                "targetProduct" : cmp.get("v.selectedProduct")
            });
            updateState.fire();

            // Calling Configured product event to refresh the product
             var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
             refreshConfiguredProduct.setParams({
                 "reload": true
             });
             refreshConfiguredProduct.fire();
             cmp.find("Id_spinner").set("v.class", 'slds-hide');
        });
        $A.enqueueAction(createLines);
    },
    saveValues: function(cmp, event) {
        cmp.set('v.showSpinner', true);
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        var recordId = cmp.get('v.recordId');
        var productId = cmp.get('v.selectedProduct.Id');
        var selectedWaste = cmp.find('wasteList').get('v.value');
        var selectedSize = cmp.find('sizeList').get('v.value');
        //var selectedSize = cmp.get("v.selectedProductEquipmentSize");
        var createAction = cmp.get('c.createNonFavoriteLine');
        console.log('Record Id is: ' + recordId);
        console.log('Product Id is: ' + productId);
        console.log('Waste stream Id is: ' + selectedWaste);
        console.log('Size is: ' + selectedSize);
        createAction.setParams({
            quoteId: recordId,
            productId: productId,
            wasteStream: selectedWaste,
            equipmentSize: selectedSize
        });
        createAction.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state==>'+state);
            if (state === 'SUCCESS') {
                var currentProductId = response.getReturnValue();
                console.log('Response from controller is: ' + currentProductId);
                cmp.set('v.createdProduct', currentProductId);
                var updateState = cmp.getEvent('UpdateWrapperState');
                updateState.setParams({
                    "currentState": "Overview",
                    "currentProductId": currentProductId,
                    "targetProduct" : cmp.get("v.selectedProduct")
                });
                updateState.fire();

                // Calling Configured product event to refresh the product
                var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
                refreshConfiguredProduct.setParams({
                    "reload": true
                });
                refreshConfiguredProduct.fire();
                cmp.find("Id_spinner").set("v.class", 'slds-hide');
            }
            else{
                cmp.set('v.showSpinner', false);
                cmp.find("Id_spinner").set("v.class", 'slds-hide');
            }
        });
        $A.enqueueAction(createAction);
    }
})