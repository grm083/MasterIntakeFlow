({
	init : function(cmp) {
        
        var caseId = cmp.get('v.recordId');
        
        var getCaseDetails = cmp.get('c.getCaseDetails');
        var getQuestions = cmp.get('c.getFirstQuestion');
        
        
        getCaseDetails.setParams({
            CaseId: caseId,
            updateFlow: false
        });
        
        getCaseDetails.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var retVal = response.getReturnValue().Master_Intake_Complete__c;
                console.log("Master Intake is: " + retVal);
                if (!retVal) {
                    getQuestions.setParams({
                        CaseId: caseId
                    });
                    getQuestions.setCallback(this, function(response) {
                        var state = response.getState();
                        if(state === 'SUCCESS') {
                            cmp.set('v.Question', response.getReturnValue());
                            if(response.getReturnValue().Id) {
                                var flow = cmp.find('MasterIntake');
                                var inputVar = [{
                                    name: 'recordId',
                                    type: 'String',
                                    value: caseId
                                }];
                                flow.startFlow('Master_Intake_Flow', inputVar);
                            };
                        };
                    });
                    $A.enqueueAction(getQuestions);
                } else {
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(getCaseDetails);
          
	}
    
   
})