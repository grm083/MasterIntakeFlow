({
    initAction:function(component, event, helper) {
        var changeType = event.getParams().changeType;
        if(changeType === "LOADED" || changeType == "CHANGED"){
            var caseRecord = component.get("v.caseRecord");
            if(caseRecord && (caseRecord.Case_Type__c && caseRecord.Case_Type__c == 'Pickup') || caseRecord.Status == 'Closed'){
                if(caseRecord.Case_Sub_Type__c && caseRecord.Case_Sub_Type__c == 'Bale(s)' && caseRecord.Status != 'Closed'){
                    component.set("v.isNotPickup",true);
                }else{           
                    component.set("v.isNotPickup",false);
                }
            }
            
            if(caseRecord && caseRecord.ContactId && caseRecord.Case_Type__c && caseRecord.Case_Sub_Type__c && ((caseRecord.Case_Type__c == 'Status' && caseRecord.AssetId) || caseRecord.Case_Type__c != 'Status')){
                component.set("v.enableProgress",false);
                component.set("v.subTypeBtn",false);
				$A.createComponent(
                        "c:DuplicateCheckOnCase",
                        {
                            "currentCaseID": component.get("v.recordId"),
                			"isMultiAssetCase": false
                        },
                        function (msgBox) {
                            if (component.isValid()) {
                                var targetCmp = component.find('duplicateCheck');
                                if(targetCmp){
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body);
                               }     
                            }
                        }
                    );
            }
            else{
                component.set("v.enableProgress",true);
                component.set("v.subTypeBtn",false);
            }
            
            //Get Approver Details.		
            var cId = caseRecord.Id;		
            var action = component.get('c.getServiceApprovers');		
            action.setParams({		
                "caseId" : cId 		
            });		
            action.setCallback(this, function(response) {		
                var state = response.getState();		
                console.log(state);		
                if (state == "SUCCESS") {		
                    var wrapper = response.getReturnValue();		
                    console.log('Wrapper::'+wrapper);		
                    if(cId == wrapper.caseId && wrapper.approvalInfo != "undefined" && wrapper.approvalInfo != null && wrapper.approvalInfo != ""){		
                        component.set('v.approvalInfo',wrapper.approvalInfo);		
                        console.log('$$$'+wrapper.occurrenceLimit);		
                        if(wrapper.occurrenceLimit != "undefined" && wrapper.occurrenceLimit != null && wrapper.occurrenceLimit != "" && wrapper.occurrenceLimit != 0){		
                            component.set('v.occurrenceLimit',wrapper.occurrenceLimit);		
                            component.set('v.displayOccurrence',true);		
                        }		
                        console.log('$$$'+component.get("v.occurrenceLimit"));		
                        component.set('v.approvalInfoMsg',true);		
                    }else if(wrapper.enableapprovalInfo){		
                        component.set('v.approvalInfo', 'Case will be auto Approved');		
                        component.set('v.approvalInfoMsg',true);		
                        
                    }else{		
                        component.set('v.approvalInfoMsg',false);		
                    }		
                }		
            });		
            $A.enqueueAction(action);
        }
    },
    
    handleClick : function(component, event, helper) {
        $A.createComponent(
            "c:OpenCloseModal",
            {
                "caseRecordId" : component.get("v.recordId"), 
                "showButtons": true,
                "caseStatus": component.get("v.caseRecord.Status") 
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('showModal');
                    if(targetCmp ){
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                    }     
                }
            }
        );
    },
    
    showSubTypeComp : function(component, event, helper) {
        $A.createComponent(
            "c:FillCaseSubType",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('subTypeComp');
                    if(targetCmp ){
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                    }     
                }
            }
        );
    },
     showCaseAssignment : function(component, event, helper){
        $A.createComponent(
            "c:CaseReassignment",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('CaseAssignmentComp');
                    if(targetCmp ){
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                    }     
                }
            }
        );
    }
})