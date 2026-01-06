({
	back : function(cmp, event) {
        var actionClicked = 'BACK';
        var navigate = cmp.get('v.navigateFlow');
        navigate(actionClicked);
    },
    next : function(cmp, event) {
        //location.reload();
        
        var caseId = cmp.get('v.caseRecord');
        var comment = cmp.get('v.comment');
        var addComment = cmp.get('v.CustomNotes');
        var updateCase = cmp.get('c.createComment');
        var finalOutcome = cmp.get('v.FinalOutcome');
        var doUpdates = cmp.get('c.doCaseUpdates');
        
        updateCase.setParams({
            CaseId: caseId,
            Comment: comment + addComment
        });
        
        doUpdates.setParams({
            CaseId: caseId,
            OutcomeId: finalOutcome
        });
        
        updateCase.setCallback(this, function(response) {
            var state = response.getState()
            if( state === 'SUCCESS' ){
                var caseStatus = response.getReturnValue();
                if (caseStatus === 'New') {
                    var toastMessage = $A.get('e.force:showToast');
                    toastMessage.setParams({
                        "title": "Case in New Status",
                        "message": 'Please remember to progress the case',
                        "type": "warning"
                    });
                    toastMessage.fire();
                }
                doUpdates.setCallback(this, function(response) {
                    var state = response.getState()
                    if (state === 'SUCCESS') {
                        console.log('Next function called');
                        var actionClicked = 'FINISH';
                        var navigate = cmp.get('v.navigateFlow');
                        navigate(actionClicked);
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(doUpdates);
            }
        });
        $A.enqueueAction(updateCase);
        
        /**
        console.log('method calledd');
        var actionClicked = 'NEXT';
        var navigate = cmp.get('v.navigateFlow');
        navigate(actionClicked);
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            console.log('focusIdof>>>'+focusedTabId);
            workspaceAPI.refreshTab({
                      tabId: focusedTabId,
                      includeAllSubtabs: true
             });
        })
        .catch(function(error) {
            console.log(error);
        }); **/
        
        $A.get('e.force:refreshView').fire();  
    }
})