({
	productNotListed : function(component) {
        console.log('Print2');
		component.find("Id_spinner").set("v.class", 'slds-show');
        var CaseId = component.get('v.caseId');
        var addId = component.get('v.productId');
        var checkQuote = component.get('c.addQuoteAsProductNotListed');
        checkQuote.setParams({
            CaseId: CaseId
        });
               
                checkQuote.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log ('state'+ state);
                    if(state === "SUCCESS") {
                        var quoteID = response.getReturnValue();
                        component.set('v.OppId', quoteID);
                        var urlEventToCreate = $A.get('e.force:navigateToURL');
                        urlEventToCreate.setParams({
                           "url": '/apex/sbqq__sb?scontrolCaching=1&id=' + quoteID + '#/product/lookup?qId=' + quoteID + '&aId=' + addId
                        });
                        urlEventToCreate.fire();
                        component.find("Id_spinner").set("v.class", 'slds-hide');
                    };
                });
                $A.enqueueAction(checkQuote);
	}
})