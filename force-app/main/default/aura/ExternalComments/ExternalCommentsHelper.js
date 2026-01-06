({
    callRefresh : function(cmp, event, helper) { 
        var refresh =  cmp.get("v.refresh")
        helper.refreshPortal(cmp,helper); 
        /*if(refresh){
            //execute refreshPortal() again after 3 sec each   
            var intervalId =  window.setInterval(function(){ helper.refreshPortal(cmp,helper)}, 3000);
            cmp.set("v.intervalId",intervalId);
        }*/
    },

    confirmExit : function(cmp, event ,helper ) {
            var intervalId = cmp.get("v.intervalId");
            window.clearInterval(intervalId);
    },
    
	refreshPortal : function(cmp, helper) {
        console.log('Refreshing External Comments');
        cmp.set("v.loadingSpinner", true);
        try{
		cmp.set('v.columns', [
            { label: 'Action', initialWidth: 120, fieldName: 'Workflow_Action__c', type: 'text'},
            { label: 'User/Team', initialWidth: 120, fieldName: 'Workflow_TeamUser__c', type: 'text'},
            { label: 'Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                                                                            hour12: true}},
            { label: 'Comments', fieldName: 'Comment__c', type: 'text'},
            { label: 'Source', initialWidth: 120, fieldName: 'Communication_Log_Type_Name__c', type: 'text'} 
        ]);
        var action = cmp.get("c.getCommentData");
        action.setParams({ 
            caseId : cmp.get("v.recordId"),
            size : 500,
            sortAsc : cmp.get("v.sortAsc"),
            sortColumn : cmp.get("v.sortCol")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.notes", response.getReturnValue());
            }
            //event.getSource().set("v.isLoading", false);
            cmp.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
        }
        catch(e){
            console.log(e);   
        }
    },

    hovercall : function(component, objecttype, recordId, title, targetId, left, top) {
        $A.createComponent(
            "c:HoverCardAura",
            {
                "hoverRecordId" : recordId, 
                "sobjectType": objecttype,
                "title": title,
                "casenumber" : component.get('v.caseRecord.CaseNumber'),
                "left": left,
                "top": top
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find(targetId);
                    if(targetCmp){
                        targetCmp.set("v.body",[]);
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    }
})