({
    init : function(cmp, event, helper) {
        //On init, identify if a question was passed in to determine if we will be
        //querying to identify a question, or simply the outcomes
        
        var Case = cmp.get('v.CaseId');
        var Question = cmp.get('v.QuestionId');
        
        console.log('Case Id Is: ' + Case);
        console.log('Question Id Is: ' + Question)
        
        if (!Question) {
            helper.FirstQuestion(cmp);
        } else {
            helper.NextQuestion(cmp);
        }
    },
    handlePicklistChange : function(cmp,event) {
        var dynPicklist = cmp.find('DynamicPicklist').get('v.value');
        cmp.set('v.response', dynPicklist);
    },
    next : function(cmp, event, helper) {
        var caseRecord = cmp.get("v.caseRecord");
        var inputField = cmp.get('v.Question');
        var outcomes = cmp.get('v.Outcomes');
		var selOutcome;
        var responseCmp;
        var response;
        switch (inputField.Input_Type__c) {
            case 'Picklist':
                responseCmp = cmp.find('DynamicPicklist');
                break;
            case 'Phone':
                responseCmp = cmp.find('DynamicPhone');
                break;
            default:
                responseCmp = cmp.find('DynamicField');
                break;
        };
        if (responseCmp) {
        	response = responseCmp.get('v.value');
        } else {
            response = 'Instruction Only';
        }
        if (response != 0 && response) {
            console.log(outcomes.length + ' Outcomes Available');
            if (outcomes.length > 1) {
                for (var i = 0; i < outcomes.length; i++) {
                    if (outcomes[i].Outcome__c === response) {
						selOutcome = outcomes[i];
                    }
				};
			} else {
				selOutcome = outcomes[0];
			}
			
			if(selOutcome.Next_Question__c) {
				cmp.set('v.NextQuestionId', selOutcome.Next_Question__c);
			} else {
				cmp.set('v.EndStatement', selOutcome.Outcome_Statement__c);
				cmp.set('v.boolEnd', true);
			};
			
			if (selOutcome.Create_Task__c |
				selOutcome.Update_Case_Record_Type__c |
				selOutcome.Update_Case_Type__c |
				selOutcome.Update_Case_Sub_Type__c |
				selOutcome.Update_Case_Reason__c |
                selOutcome.Update_Case_Status__c |
				selOutcome.Queue_Assigned__c) {
					console.log('Conditions met for Master Intake case update or task creation');
                	cmp.set('v.FinalOutcome', selOutcome.Id);
					//helper.doUpdates(cmp, selOutcome);
			};	
            
            var CommentSection = '<font color="rgb(0,105,60)"><strong>' + inputField.Question__c + '</strong></font><br/>';
            CommentSection = CommentSection + response + '<br/><br/>';
            cmp.set('v.QuestionAnswer',CommentSection);
            console.log('Here are the values leaving the flow');
            console.log('End Statement: ' + cmp.get('v.EndStatement'));
            console.log('End Boolean: ' + cmp.get('v.boolEnd'));
            console.log('Next Question Id: ' + cmp.get('v.NextQuestionId'));
            console.log('Response: ' + cmp.get('v.response'));
            console.log('New Comment Line: ' + CommentSection);
            var actionClicked = 'NEXT';
            var navigate = cmp.get('v.navigateFlow');
            navigate(actionClicked);
        } else {
            var toastError = $A.get('e.force:showToast');
            toastError.setParams({
                "title": "Warning!",
                "message": "Please specify a value before proceeding",
                "type": "warning"
            });
            toastError.fire();
        }
    },
    back : function(cmp, event) {
        var actionClicked = 'BACK';
        var navigate = cmp.get('v.navigateFlow');
        navigate(actionClicked);
    },
})