({
    doinit : function(cmp, event, helper) {
        
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        var CaseId = cmp.get('v.recordId');
        var existingQuote = cmp.get('c.ShowExistingQuotes');
        
        existingQuote.setParams({
            CaseId: CaseId
        });
        existingQuote.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var quotesRespone = response.getReturnValue();
                if (quotesRespone.length > 0) 
                {
                    cmp.set('v.QuotesWrapper', quotesRespone);
                    cmp.find("Id_spinner").set("v.class", 'slds-hide');
                } else {
                    cmp.find("Id_spinner").set("v.class", 'slds-hide');
                }
                
            }});
        $A.enqueueAction(existingQuote);
        
    },
    
    addQuote : function(component, event, helper) {
        //component.set('v.existingQuoteModal', false);
        //component.set('v.AddFavroiteContainerModal', true); 

        //With the implementation of the CE UI, we are now reverting the function of Add Quote to navigate directly to the quote page 
        
        component.find("Id_spinner").set("v.class", 'slds-show');
        var CaseId = component.get('v.recordId');
        var getAction = component.get('c.getAddProductId');
        var checkQuote = component.get('c.createOppQuote');
        
        
        checkQuote.setParams({
            CaseId: CaseId
        });
        getAction.setCallback(this, function(response) {
            
            if (response.getState() === 'SUCCESS') {
                
                var addId = response.getReturnValue();
                checkQuote.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === 'SUCCESS') {
                        var quoteID = response.getReturnValue();
                        component.set('v.OppId', quoteID);
                        /*var urlEventToCreate = $A.get('e.force:navigateToURL');
                        urlEventToCreate.setParams({
                            //"url": '/apex/sbqq__sb?scontrolCaching=1&id=' + 'a9L6t000000CoFaEAK' + '#/favorite/lookup?qId=' + 'a9L6t000000CoFaEAK' + '&aId=' + addId
                            //"url": "/lightning/o/SBQQ__Favorite__c/list?filterName=00B3u000008GfoREAS"
                            
                            "url": '/apex/sbqq__sb?scontrolCaching=1&id=' + quoteID + '#/product/lookup?qId=' + quoteID + '&aId=' + addId
                        });
                        urlEventToCreate.fire();*/
						//Uncommented code for SDT-21663
                        var action = component.get('c.closeExistingQuotes');
                        $A.enqueueAction(action);
                        var navEvent = $A.get('e.force:navigateToSObject');
                        navEvent.setParams({
                            'recordId': quoteID
                        });
                        navEvent.fire();
                        component.find("Id_spinner").set("v.class", 'slds-hide');
                    }else	//TCS-SDT-41546-Adding else part
                    {
                        let errors = response.getError();
                        let message = 'Unknown error'; // Default error message
                        if (errors && Array.isArray(errors) && errors.length > 0) {
                            message = errors[0].message;
                        }
                        var errormsg = $A.get("$Label.c.Case_Creation_Error")+' '+message;
                        var errorToast = $A.get('e.force:showToast');
                        errorToast.setParams({
                            'title': 'Error',
                            'message': errormsg,
                            'type': 'error'
                        });
                        errorToast.fire();
                        component.find("Id_spinner").set("v.class", 'slds-hide');
                    };
                });
                $A.enqueueAction(checkQuote);
            }
        });
        $A.enqueueAction(getAction); 
    },
    
    closeExistingQuotes : function(cmp) {
        
        var closeModalEvent = cmp.getEvent('CloseModalEvent');
        closeModalEvent.setParams({
            "showQuoteModal" : "false"
        });
        closeModalEvent.fire();
        
    },
    closeThisCase :function (cmp){
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        var CaseId = cmp.get('v.recordId');
        var closeCaseAction  = cmp.get('c.updateThisCaseToClose');
        closeCaseAction.setParams({
            CaseId: CaseId
        });
        closeCaseAction.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') { 
                var closedstatus = response.getReturnValue();
                if(closedstatus == true){
                    //console.log('Case has been closed.');
                }
                cmp.find("Id_spinner").set("v.class", 'slds-hide');
                var action = cmp.get('c.closeExistingQuotes');
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(closeCaseAction); 
    },
    
    navigate : function(cmp, event) {
        var recordId = event.currentTarget.dataset.value;
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        sObectEvent.fire();
    }
    
})