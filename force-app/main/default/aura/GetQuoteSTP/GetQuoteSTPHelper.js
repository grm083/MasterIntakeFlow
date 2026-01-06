({
    getQuoteStatusByCase: function (component) {
            let i = 1;
            let timmerInterval;
            var caseID = component.get("v.recordId");
            var action = component.get("c.getQuoteStatusByCase");
            action.setParams({ caseId: caseID });
    
            action.setCallback(this, function (response) {
                var state = response.getState();
    
                if (state === "SUCCESS") {

                    var wrapper = response.getReturnValue();
                    if(wrapper && wrapper != null){
                        console.log('In getQuoteStatusByCase---->');
                        if(wrapper.IsInvokeSTP == true 
                            && !$A.util.isUndefinedOrNull(wrapper.QuoteId)
                            &&  $A.util.isUndefinedOrNull(wrapper.QuoteProcuredStatus)
                            && wrapper.QuoteStatus == 'Product Configured'){

                            console.log('Invoke Apex -- STP---->' + wrapper);

                            i = 0;
                            

                            var actionSTP = component.get("c.processPricingRequest");
                            actionSTP.setParams({ quoteID: wrapper.QuoteId,
                                isFirstCall: true });
                            
                            actionSTP.setCallback(this, function (responsePR){
                                var stateSTP = responsePR.getState();
                                if (stateSTP === "SUCCESS") {
                                    console.log('In processPricingRequest---->');
                                    clearInterval(timmerInterval);
                                }

                            });
                            $A.enqueueAction(actionSTP);
                        }
                        else
                        {
                            if(!$A.util.isUndefinedOrNull(wrapper.QuoteProcuredStatus))
                            {
                                console.log('Invoke After QuoteProcuredStatus' + i);
                                i = 0;
                                clearInterval(timmerInterval);
                            }
                        }

                    }
                }
            });
            if(i > 0){
                timmerInterval = setInterval(function() {
                    $A.enqueueAction(action);
                }, 40000);
            }
            // else if(i == 0){
            //     console.log('When i = 0' + i);
            //     clearInterval(timmerInterval);
            // }
        },
});