({
	createflowpath : function(component) {
		/*var flow = component.find('flow');
        if(flow != "undefined" && flow != null && flow != ""){
            flow.destroy();    
        }
        $A.createComponent(
            'lightning:flow', 
            {
                'aura:id' : 'flow'
            },
            function(newFlow, status, errorMessage) {
                console.log('status'+status);
                if (status==='SUCCESS') {
                    var flowHolder = component.find('flowHolder');
                    var flowBody = flowHolder.get('v.body');
                    console.log('####'+newFlow);
                    flowBody.push(newFlow);
                    flowHolder.set('v.body',flowBody);
                    var inputVariables = [ {
                                                name : 'recordId',
                                                type : 'String',
                                                value : component.get('v.recordId')
                                            } ];
                    newFlow.startFlow('Case_Sub_Status', inputVariables);
                } else{
                    console.log(status);
                    console.log('Error: ' + errorMessage);
                }
            }
        );*/
        const recId = component.get("v.recordId");
        var action = component.get('c.getflowpath');
        action.setParams({
            "caseId" : recId 
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            const result = response.getReturnValue();
			console.log('###'+result);
            if(!$A.util.isEmpty(state) && !$A.util.isEmpty(result) && !$A.util.isUndefined(result) && state == "SUCCESS"){
                const rValue = JSON.parse(result);
                if(rValue.CurrentCaseType && rValue.caseType!=="Closed"){
             	component.set("v.currentStage",rValue.CurrentCaseType);
                component.set("v.allStages",rValue.caseTypeList);
                component.set('v.isFlowVisible',true);
                }
                else{
                  component.set('v.isFlowVisible',false);  
                }
            }
        });
        $A.enqueueAction(action);
        
	}
})