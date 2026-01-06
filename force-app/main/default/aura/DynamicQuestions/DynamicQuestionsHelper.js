({
    FirstQuestion : function(cmp, helper) {
        //Nested function to return both the first question and the outcomes
        var firstQAction = cmp.get('c.getFirstQuestion');
        var getOutcomes = cmp.get('c.getOutcomes');
        var CaseId = cmp.get('v.CaseId');
        firstQAction.setParams({
            CaseId: CaseId
        });
        console.log('Calling for first question');
        firstQAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var retQuestion = response.getReturnValue();
                cmp.set('v.Question', retQuestion);
                if (!retQuestion.Id) {
                    console.log('Moving along in the flow, no questions found');
                    cmp.set('v.boolEnd', true);
                    var actionClicked = 'NEXT';
                    var navigate = cmp.get('v.navigateFlow');
                    navigate(actionClicked);
                }
                console.log('Got question, calling for outcomes');
                console.log('Question Id is: ' + retQuestion.Id + ' and the question is: ' + retQuestion.Question__c);
                getOutcomes.setParams({
                    Question: retQuestion.Id
                });
                getOutcomes.setCallback(this, function(response) {
                    var state2 = response.getState();
                    if (state2 == 'SUCCESS') {
                        var retOutcomes = response.getReturnValue();
                        cmp.set('v.Outcomes', retOutcomes);
                        console.log('Got outcomes');
                        //Debug line only to validate outcomes
                        console.log('Outcome: ' + JSON.stringify(retOutcomes));
                    }
                });
                $A.enqueueAction(getOutcomes);
            } else {
                console.log('Moving along in the flow, no questions found');
                cmp.set('v.boolEnd', true);
                var actionClicked = 'NEXT';
                var navigate = cmp.get('v.navigateFlow');
                navigate(actionClicked);
            }
        });
        $A.enqueueAction(firstQAction);
    },
    NextQuestion: function(cmp) {
        //Nested function to return both the next question and the outcomes
        var nextQAction = cmp.get('c.getNextQuestion');
        var getOutcomes = cmp.get('c.getOutcomes');
        var QuestionId = cmp.get('v.QuestionId');
        nextQAction.setParams({
            QuestionId: QuestionId
        });
        console.log('Calling for Next Action');
        nextQAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var retQuestion = response.getReturnValue();
                cmp.set('v.Question', retQuestion);
                console.log('Got question, calling for outcomes');
                console.log('Expected Format Is: ' + retQuestion.Input_Type__c);
                getOutcomes.setParams({
                    Question: retQuestion.Id
                });
                getOutcomes.setCallback(this, function(response) {
                    var state2 = response.getState();
                    if (state2 == 'SUCCESS') {
                        var retOutcomes = response.getReturnValue();
                        cmp.set('v.Outcomes', retOutcomes);
                        console.log('Got outcomes');
                        //Debug line only to validate outcomes
                        console.log('Outcome: ' + JSON.stringify(retOutcomes));
                    }
                });
                $A.enqueueAction(getOutcomes);
            }
        });
        $A.enqueueAction(nextQAction);
    },
    updateCase: function(cmp, Outcome) {
        console.log('in update case>>>');
        var currentCase = cmp.get('v.caseRecord');
        var recordType = Outcome.Case_Record_Type__c;
        var type = Outcome.Case_Type__c;
        var subtype = Outcome.Case_Sub_Type__c;
        var reason = Outcome.Case_Reason__c;
        var status = Outcome.Case_Status__c
        console.log('type11>>>'+type);
        console.log('subtype11>>>'+subtype);
        console.log('reason11>>>'+reason);
        
        if (!recordType) {
            recordType = 'EMPTY';
        };
        if (!type) {
            type = 'EMPTY';
        };
        if (!subtype) {
            subtype = 'EMPTY';
        };
        if (!reason) {
            reason = 'EMPTY';
        };
        if(!status) {
            status = 'EMPTY';
        };
        console.log('type22>>>'+type);
        console.log('subtype22>>>'+subtype);
        console.log('reason22>>>'+reason);
        var CaseId = cmp.get('v.CaseId');
        var updateCase = cmp.get('c.updateCaseDetails');        
        updateCase.setParams({
            CaseId: CaseId,
            recordTypeName: recordType,
            CaseType: type,
            SubType: subtype,
            Reason: reason,
            Status: status
        });
        console.log('Attempting case update now');
        console.log(CaseId);
        console.log(recordType);
        console.log(type);
        console.log(subtype);
        console.log(reason);
        updateCase.setCallback(this, function(response) {
            var state = response.getState();
            console.log('The update state is: ' + state);
            if (state === 'SUCCESS') {
                var returnedCase = response.getReturnValue();
                var message = 'Your case has been updated! <br/><br/>';
                message = message + 'Case Type: ' + returnedCase.Case_Type__c + '<br/>';
                message = message + 'Case Sub-Type: ' + returnedCase.Case_Sub_Type__c + '<br/>';
                message = message + 'Case Reason: ' + returnedCase.Case_Reason__c
                var toastMessage = $A.get('e.force:showToast');
                toastMessage.setParams({
                    "title": "Case Updated!",
                    "message": message,
                    "type": "success"
                });
                toastMessage.fire();
               // $A.get('e.force:refreshView').fire();
            } else {
                var toastMessage = $A.get('e.force:showToast');
                toastMessage.setParams({
                    "title": "Case Could Not Be Updated",
                    "message": response.getError() + ' - Please provide this error to your administrator',
                    "type": "error"
                });
                toastMessage.fire();
                //$A.get('e.force:refreshView').fire();
            }
        });
        console.log('Enqueuing');
        $A.enqueueAction(updateCase);
    },
    doUpdates : function(cmp, Outcome) {
        var CaseId = cmp.get('v.CaseId');
        var doCaseUpdates = cmp.get('c.doCaseUpdates');
        
        doCaseUpdates.setParams({
            CaseId: CaseId,
            OutcomeId: Outcome.Id
        });
        
        doCaseUpdates.setCallback(this, function(response) {
            if (repsonse.getState() === 'SUCCESS') {
                console.log('Successfully updated case');
            } else {
                console.log('Could not update case');
            }
        });
        $A.enqueueAction(doCaseUpdates);
    },
    updateAssignment : function(cmp, Outcome) {
        var CaseId = cmp.get('v.CaseId');
        var updateAssign = cmp.get('c.updateAssignment');
        updateAssign.setParams({
            CaseId: CaseId,
            teamAssigned: Outcome.Queue_Assigned__c,
            teamName: Outcome.Team_Name__c
        });
        updateAssign.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                console.log('Successfully updated assignment');
            } else {
                console.log('Could not update case');
            }
        });
        $A.enqueueAction(updateAssign);
    },
    createTask : function(cmp, OutcomeChoice) {
        var createTask = cmp.get('c.createTask');
        var caseId = cmp.get('v.CaseId');
        var queueName;
        if (!OutcomeChoice.Queue_Assigned__c) {
            queueName = 'EMPTY';
        } else {
            queueName = OutcomeChoice.Queue_Assigned__c;
        }
        
        window.localStorage.setItem("masterIntakeTask"+caseId, true); 
        
        createTask.setParams({
            CaseId: cmp.get('v.CaseId'),
            TaskType: OutcomeChoice.Task_Type__c,
            TaskProcess: OutcomeChoice.Task_Process__c,
            Queue: queueName
        });
        createTask.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var returnValue = response.getReturnValue();
                if (returnValue = TRUE) {
                    var toastMessage = $A.get('e.force:showToast');
                    toastMessage.setParams({
                        "title": "Task Created!",
                        "message": "A task has been created!",
                        "type": "success"
                    });
                   // toastMessage.fire();
                  //  $A.get('e.force:refreshView').fire();
                } else {
                    var toastMessage = $A.get('e.force:showToast');
                    toastMessage.setParams({
                        "title": "Case Could Not Be Updated",
                        "message": 'A task could not be created at this time',
                        "type": "error"
                    });
                    //toastMessage.fire();
                   // $A.get('e.force:refreshView').fire();
                }
            }
            
        });
        $A.enqueueAction(createTask);
    }
})