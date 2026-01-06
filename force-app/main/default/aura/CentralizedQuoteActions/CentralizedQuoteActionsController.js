({
	init : function(cmp, event, helper) {
		//Call to get quote details
		clearInterval(cmp.get('v.intervalId'));
		var getQuote = cmp.get('c.getQuote');
        var userId= $A.get('$SObjectType.CurrentUser.Id');
        console.log('userId-->'+userId);
        getQuote.setParams({
            recordId: cmp.get('v.recordId')
        });
        getQuote.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                cmp.set('v.currQuote', response.getReturnValue());
                var countDown = new Date(cmp.get('v.currQuote.Next_Action_Due_Date__c'));
                var assigneeId= cmp.get('v.currQuote.Assigned_To__c');
                console.log('assigneeId-->'+assigneeId);
                if(userId == assigneeId){
                    console.log('showQuote-->'+cmp.get('v.showQuoteActions'));
                    cmp.set('v.showQuoteActions',true);
                    console.log('showQuote-->'+cmp.get('v.showQuoteActions'));
                }else {
                    cmp.set('v.showQuoteActions',false);
                }
                var timer = setInterval(function() {
                    cmp.set('v.intervalId', timer);
                    var now = new Date().getTime();
                    var distance = countDown - now;
                    var days;
                    var hours;
                    var minutes;
                    var seconds;
                    if (distance > 86400000 || distance < -86400000) {
                        days = Math.floor((distance % (1000 * 60 * 60 * 24 * 365)) / (1000 * 60 * 60 * 24)) + "d ";
                    } else {
                        days = ""
                    }
                    if (distance > 3600000 || distance < -3600000) {
                        hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)) + "h ";
                    } else {
                        hours = ""
                    }
                    if (distance > 60000 || distance < -60000) {
                        minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60)) + "m ";
                    } else {
                        minutes = ""
                    }
            		var seconds = Math.floor((distance % (1000 * 60)) / 1000) + "s";
                    var timeLeft = days + hours + minutes + seconds
                    cmp.set('v.timeLeft', timeLeft);
                }, 1000);
            }
        });
        $A.enqueueAction(getQuote);
	},
    actionClick : function(cmp, event, helper) {
        
		var actionType = event.getSource().getLocalId();
        var quoteId = cmp.get('v.recordId');
        
        var actionAPI = cmp.find('quickActionAPI');
        switch (actionType) {
            case 'GoToCase':
                
                var goToCase = cmp.get('c.goToCase');
                goToCase.setParams({
                    //QuoteId: cmp.get('v.recordId')
                    quoteID: quoteId
                });
                goToCase.setCallback(this, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        
                        var oppId = response.getReturnValue();
                        console.log('oppId ',oppId);
                        cmp.set('v.OppId', oppId);
                        var navService = cmp.find('navService');
                        var pageReference = {
                            type: "standard__recordPage",
                            attributes: {
                                recordId: oppId,
                                objectApiName: 'Case',
                                actionName: 'view'
                            }
                        }
                        
                        navService.generateUrl(pageReference)
    					.then($A.getCallback(function(url) {
      					console.log('success: ' + url); //you can also set the url to an aura attribute if you wish
      					window.open(url,'_blank'); //this opens your page in a seperate tab here
    					}), 
    					$A.getCallback(function(error) {
      					console.log('error: ' + error);
    					}));
                    }
                });
                $A.enqueueAction(goToCase);
                break;
            case 'EditLines':
                var urlEvent = $A.get('e.force:navigateToURL');
                urlEvent.setParams({
                    "url": '/apex/sbqq__sb?scontrolCaching=1&id=' + cmp.get('v.recordId')
                });
                urlEvent.fire();
                break;
            case 'SubmitRequest':
                /*var submitAction = cmp.get('c.submitQuote');
                cmp.set('v.showModal', true);
                cmp.set('v.modalType', 'Pricing');
                submitAction.setParams({
                    QuoteId: quoteId
                });
                submitAction.setCallback(this, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        cmp.set('v.showModal', false);
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(submitAction);*/
                break;
            case 'ApproveOrder':
                var args = {actionName:'SBQQ__Quote__c.Approve_Quote'};
                actionAPI.selectAction(args).then(function(result) {
                    
                }).catch(function(e) {
                    console.error(e.errors);
                });
                break;
            case 'DeclineOrder':
                var args = {actionName:'SBQQ__Quote__c.Decline_Quote'};
                actionAPI.selectAction(args).then(function(result) {
                    
                }).catch(function(e) {
                    console.error(e.errors);
                });
                break;
            /* commenting below as a part of SDT-20939
            case 'orderRequest':
                cmp.set('v.modalType', 'NewOrders');
                cmp.find('workOrderLwc1').openModal();
                break;
            case 'viewOrderRequest':
                cmp.set('v.modalType', 'ViewOrders');
                cmp.find('workOrderLwc2').openModal();
                break;  */  
            case 'PendingInformation':
                var args = {actionName:'SBQQ__Quote__c.Pending_Information'};
                actionAPI.selectAction(args).then(function(result) {
                    
                }).catch(function(e) {
                    console.error(e.errors); 
                });
                break;
            case 'Escalate':
                var args = {actionName:'SBQQ__Quote__c.Escalate'};
                actionAPI.selectAction(args).then(function(result) {
                    
                }).catch(function(e) {
                    console.error(e.errors);
                });
                break;
        }
	}
})