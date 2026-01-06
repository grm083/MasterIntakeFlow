({
	doinit : function(component, helper) {
        component.find("Id_spinner").set("v.class", 'slds-show');
        var getFavorites = component.get('c.getFavorites');
        
        getFavorites.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                var data = response.getReturnValue();
                console.log('Data length---'+ data.length);
                var items = [];
                if (data) 
                { 
                    component.set('v.QuotesWrapper', data);
                   	var getAction = component.get('c.getAddProductId');
                    getAction.setCallback(this, function(response) {
                        if (response.getState() === 'SUCCESS') {
                            var prodId = response.getReturnValue();
                            component.set('v.productId', prodId);
                            console.log('prodId--->'+ prodId);
                        }
                    });
        				$A.enqueueAction(getAction); 
                    component.find("Id_spinner").set("v.class", 'slds-hide');
                    
                } 
                else {
                    var toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({
                        'title': 'Error',
                        'message': 'No Data In Favorites.',
                        'type': 'error',
                        'mode': 'dismissible'
                    });
                    toastEvent.fire();
                    console.log('No Data--->'+ data);
                    component.find("Id_spinner").set("v.class", 'slds-hide');}
                
            }
        });
        $A.enqueueAction(getFavorites); 
	},
    
    closeFavoriteContanerModal : function(cmp) {
        cmp.set("v.showForm",false);
        var closeModalEvent = cmp.getEvent('CloseModalEvent');
        closeModalEvent.setParams({
            "AddFavroiteContainerModal" : "false"
        });
        closeModalEvent.fire();
        
    },
    
	//Error message updated
	
    addFavoriteProductToQuote : function(component, event, helper){
    component.find("Id_spinner").set("v.class", 'slds-show');
        var caseId = component.get('v.caseId');
        var quoteId= component.get('v.quoteId');
        var favroiteId = component.get('v.favroiteId');
        console.log('favroiteId>>addFavorite>>'+favroiteId);
        var createQuoteAndQLine = component.get('c.addQuoteAndQuoteine');
        var quoteScreen= component.get('v.quoteScreen');
        createQuoteAndQLine.setParams({
            caseId: caseId,
            favroiteId : favroiteId,
            quoteScreen : quoteScreen,
            quoteID: quoteId
        });
        if(favroiteId !="undefined" && favroiteId != null) {
            createQuoteAndQLine.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var quotesRespone = response.getReturnValue();
                if (quotesRespone.length > 0) 
                {
                    component.set('v.showForm', false);
                    var urlEvent = $A.get('e.force:navigateToURL');
                        urlEvent.setParams({
                      "url": "/lightning/r/SBQQ__Quote__c/"+quotesRespone+"/view" });
                        urlEvent.fire();
                    
                    component.find("Id_spinner").set("v.class", 'slds-hide');
                } else {
                    var toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({
                        'title': 'Validation Error',
                   		 'message': 'Apex Failure',
                        'type': 'error',
                        'mode': 'dismissible'
                    });
                    toastEvent.fire();
                    component.find("Id_spinner").set("v.class", 'slds-hide');
                }
                
            } 
            else {
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    'title': 'Error',
                    'message': 'Apex Failure',
                    'type': 'error',
                    'mode': 'dismissible'
                });
                toastEvent.fire();
                component.find("Id_spinner").set("v.class", 'slds-hide');
            }});
                    
          }
        else
        {
            var toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                        'title': 'Validation Error',
                        'message': 'Please Select Product Record First.',
                        'type': 'error',
                        'mode': 'dismissible'
                    });
                    toastEvent.fire();
                    component.find("Id_spinner").set("v.class", 'slds-hide');
        }
        
        $A.enqueueAction(createQuoteAndQLine);
        if(quoteScreen){
            var parentComponent = component.get("v.parent");
        	parentComponent.callInit();
        }
    },
    
     addProductNotListed : function(component, event, helper) {
      
        var quoteScreen= component.get('v.quoteScreen');
        console.log('quoteScreen>>'+quoteScreen);
        if(quoteScreen){
             var quoteId = component.get('v.quoteId');
             var getAction = component.get('c.getAddProductId');
             getAction.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    var addId = response.getReturnValue();
                    console.log('addId>>'+addId);
                    var urlEventToCreate = $A.get('e.force:navigateToURL');
                    urlEventToCreate.setParams({ 
                        "url": '/apex/sbqq__sb?scontrolCaching=1&id=' + quoteId + '#/product/lookup?qId=' + quoteId + '&aId=' + addId
                    });
                    urlEventToCreate.fire();
                    component.set('v.showForm',false);
                }
             });
             $A.enqueueAction(getAction); 
         }
         
         else{ helper.productNotListed(component); }
    },
    
    selectProduct: function(cmp,event){
        cmp.set('v.containerDetailsList',[]);
        var containerItem = event.getSource().get('v.value');
        cmp.set('v.selectedProduct', containerItem.productName);
        console.log('containerItem.listcontainerDetails>>'+JSON.stringify(containerItem.listcontainerDetails));
        cmp.set('v.containerDetailsList',containerItem.listcontainerDetails);
        cmp.set('v.columns', [
            {label: 'Size', fieldName: 'equipmentSize', type: 'text'},
            {label: 'Material Type', fieldName: 'materialType', type: 'text'}
        ]);
	},
    
    handleSelect: function(cmp, event) {
        cmp.set('v.favroiteId', '');
        var selectedRows = event.getParam('selectedRows');
       	if(selectedRows != "undefined" && selectedRows!=null && selectedRows.length != 0){
            var rowId = selectedRows[0].FavoriteID; 
            if(typeof rowId != "undefined"){
                cmp.set('v.favroiteId', rowId);
            }
        }
        
    }
})