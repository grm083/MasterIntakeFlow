({
    doinit : function(cmp, event, helper) {
        
        cmp.set('v.showSpinner', true);
        var caseId = cmp.get('v.recordId');
        console.log('Record Id is: ' + caseId);
        var caseQuotes = cmp.get('c.getCaseQuotes');
        caseQuotes.setParams({
            CaseId: caseId
        });
        caseQuotes.setCallback(this, function(response) {
            //cmp.set('v.showSpinner', false);
            console.log('Status is: ' + response.getState());
            if (response.getState() === 'SUCCESS') {
                var returnVal = response.getReturnValue();
                if (returnVal[0].configuredProducts) {
                    cmp.set('v.showAddQuote', false);
                	cmp.set('v.productWrapper', returnVal);
                    cmp.set('v.showSpinner', false);
                } else {
                    cmp.set('v.showSpinner', false);
                    var singleQuoteId = returnVal[0].singleQuoteId;
                    var sObjectEvent = $A.get('e.force:navigateToSObject');
                    sObjectEvent.setParams({
                        'recordId': singleQuoteId,
                        'slideDevName': 'detail'
                    });
                    sObjectEvent.fire();
                }
            }
        });
        $A.enqueueAction(caseQuotes);        
    },
    
    closeModal : function(cmp) {
        
        var closeModalEvent = cmp.getEvent('CloseModalEvent');
        closeModalEvent.setParams({
            "showModal" : "false"
        });
        closeModalEvent.fire();
        
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
    /*
    navigate : function(cmp, event) {
        var navURL = event.currentTarget.dataset.value;
        var recordId = cmp.get('v.recordId');
        var workspace = cmp.find('workspace');
        workspace.openTab({
            url: '/' + recordId,
            focus: true
        }).then(function (response) {
            workspace.openSubtab({
                parentTabId: response,
                url: navURL,
                focus: true
            });
        });
    }*/
})