({
    doInit: function (component, event, helper) {
	component.set('v.duplicateModal', false);  
        helper.isCapacityEligible(component);
    },
    recordUpdated: function (component, event, helper) {
        var spin = component.find('spinner');
        $A.util.removeClass(spin, 'slds-hide');
		component.set("v.displayMultipleAssetCases", false);
        var caseRecord = component.get("v.caseRecord");
        if(caseRecord && caseRecord.Show_Multiple_Asset_Cases__c && caseRecord.Status ==='New' && caseRecord.AssetId && caseRecord.ContactId && caseRecord.Case_Sub_Type__c){
            if(component.get('v.CaseMsg')==='Multi Asset'){
				component.set('v.CaseMsg', 'Complete the intake of related cases(if any) from the below list');
            }
			else if(component.get('v.CaseMsg')==='Complete the intake of related cases(if any) from the below list')
            {
                component.set('v.displaySummary', false);
            }
            else
            {
				window.setTimeout(
                    $A.getCallback(function() {
                        component.set('v.displaySummary', true);
						component.set('v.displayMsg', true);
                        if(component.find("disablebuttonid") != undefined)
                        {
                            component.find("disablebuttonid").set("v.label",'View Multi Asset Case Summary');
                            helper.duplicateCheckInvocation(component,true);
                        }
                    }), 2000
                );
			}
           
		}
        else{
            component.set('v.showMultipleCaseLabel', false);
        	component.set('v.showOnRelatedMultiAssetCase',false);
            helper.getCaseMsg(component, false,helper);
			helper.isCapacityEligible(component);
        }
        
    },
    
    handleReceiveMessage: function (component, event, helper) {
        if (event != null) {
            const caseId = event.getParam('caseId');
            var enable = event.getParam('enable');
            if(component.get("v.recordId") === caseId && enable){
                var caseRecord = component.get("v.caseRecord");
                console.log('Invoked from LWC');
                if(caseRecord.Status ==='New'){
                    component.set('v.displayMsg', true);
                    component.set('v.displaySummary', true);
                    component.set('v.CaseMsg', '');
                    component.set('v.showMultipleCaseLabel', true);
                    component.set('v.showOnRelatedMultiAssetCase',true);
                    var isWMcapacityEligible = component.get('v.isCapacityEligible');
                     if(!isWMcapacityEligible)
                    component.find("disablebuttonid").set("v.label", 'View Multi Asset Case Summary');
                    component.set("v.multiAssetCaseReferenceNo", caseRecord.Reference_Number__c);
					helper.duplicateCheckInvocation(component,true);
                    
                }
            }else if(component.get("v.recordId") === caseId && !enable){
                component.set('v.displayMsg', true);
                component.set('v.displaySummary', false);
                component.set('v.CaseMsg', "* Please complete the intake of related cases if any in 'New' status.");
            }
        }
    }, 
    handleRelatedCaseListenerEvent: function (component, event, helper) {
        var triggerCase = event.getParam("triggeringCase");
        var relatedCaseList = event.getParam("relatedCases");
        if (component.get("v.recordId") !== triggerCase) {
            if (relatedCaseList && relatedCaseList.includes(component.get("v.recordId"))) {
                //helper.getCaseMsg(component, true);
            }
        }
    },
    
    closeModel: function (component, event, helper) {
        component.set("v.viewCaseSummary", false);
    },
    CancelModel: function (component, event, helper) {
        component.set("v.WOInstructions", false);
		component.set("v.caseEmailTemp", false);
        component.set("v.CaseObj", { 'sobjectType': 'Case' });
    },
    
    caseSelect: function (component, event, helper) {
        helper.enableWorkorderButton(component);
        var id_str = event.currentTarget.dataset.value;
        var index = event.currentTarget.dataset.record;
        var caseIds = component.get('v.selectedCases');
        if (caseIds.includes(id_str)) {
            var index = caseIds.indexOf(id_str);
            if (index > -1) {
                caseIds.splice(index, 1);
            }
        } else {
            caseIds.push(id_str);
        }
        component.set('v.selectedCases', caseIds);
    },
    
       showCaseSummary: function (component, event, helper) {
        component.set("v.viewCaseSummary", true);
        component.find("workOrderButton").set("v.disabled", false);
        var btnValue = event.getSource().get('v.label');
        helper.getCaseSummary(component, helper);
        if(btnValue !='View Case Summary'){
			 component.set("v.isTempVisible",false);
        }
        else{
            helper.isTemplateVisible(component);
        }
    },
    openWorkOrderPopup: function (component, event, helper) {
        helper.getQAOverride(component, helper);
        component.set("v.WOInstructions", true);
    },
    openEmailTemplatePopup: function (component, event, helper) {
        helper.getQAOverride(component, helper);
        component.set("v.caseEmailTemp", true);
    },
    saveWorkOrderDetails: function (component, event, helper) {
        var validcontact = component.find('WOdetailsform').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if (validcontact) {
            helper.addWODetails(component, helper);
        }
    },
	saveCaseTemplate: function (component, event, helper) {
    helper.AdditionalEmailTemplate(component, helper);
      
    },
    
    //initiate the work order creation flow
    initiateWorkorder: function (component, event, helper) {
        helper.initiateWo(component, helper);
    },
    updatedRelatedCases: function (component, event, helper) {
        helper.updatedRelatedCases(component, helper);
    },
    // Commeting out multi date button from showcasemssage component as per 12786
   /* createCasesComp: function (component, event, helper) {
        $A.createComponent(
            "c:CustomCalendar",
            {
                "recordId": component.get("v.recordId"),
                "showModal": true,
                "servicedate": component.get("v.caseRecord.Service_Date__c")
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('calendarHolder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },*/
    
    expand: function (component, event, helper) {
        component.set("v.showContent", true);
        component.set("v.showredicon", false);
    },
    collapse: function (component, event, helper) {
        component.set("v.showContent", false);
        component.set("v.showredicon", true);
    },
    showSubTypeComp: function (component, event, helper) {
        $A.createComponent(
            "c:FillCaseSubType",
            {
                "recordId": component.get("v.recordId"),
                "showForm": true
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('subTypeComp');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    showSLADateComp: function (component, event, helper) {
        $A.createComponent(
            "c:SetCaseSLADate",
            {
                "recordId": component.get("v.recordId"),
                "showForm": true
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('SLADateComp');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    showPOPSI: function (component, event, helper) {
        $A.createComponent(
            "c:SetCaseCustomerInfo",
            {
                "recordId": component.get("v.recordId"),
                "showForm": true
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('POPSIComp');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    /*
     * Comment this function as we need to remove Assign Case button from Case Page
     * SDT-11777
    showCaseAssignment: function (component, event, helper) {
        $A.createComponent(
            "c:CaseReassignment",
            {
                "recordId": component.get("v.recordId"),
                "showForm": true
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('CaseAssignmentComp');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
	*/
    showPgrsBtns: function (component, event, helper) {
        $A.createComponent(
            "c:OpenCloseModal",
            {
                "caseRecordId": component.get("v.recordId"),
                "showButtons": true,
                "caseStatus": component.get("v.caseRecord.Status")
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('progressComp');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    
     addCaseAsset: function (component, event, helper) {
        $A.createComponent(
            "c:CaseAssetComponentPopup",
            {
                "caseRecordId": component.get("v.recordId"),
               "selectAsset": true
            },
            function (msgBox,status,error) {
                
             if(status === 'SUCCESS'){
                if (component.isValid()) {
                    var targetCmp = component.find('CaseAssetComp');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
                else if(status ==="INCOMPLETE" ){
                    console.log('INCOMPLETE');
                }    
                    else if(status ==="ERROR" ){
                        console.log('ERROR '+error);
                    }
           } 
        );
    },
    
    handleFetchServiceApproverEvent: function (component, event, helper) {
        var approverInfo = component.get('v.approvalInfo');
        if (approverInfo && component.get("v.recordId") === event.getParam("caseId")) {
            var SAEvent = $A.get("e.c:ServiceApproverEvent");
            SAEvent.setParams({ "serviceApprovers": approverInfo, "caseId": component.get("v.recordId") });
            SAEvent.fire();
        }
    },
    navigate: function (component, event, helper) {
        var eventName = event.getSource().getName();
        var lastEventName = component.get('v.lastEventName');
        if (!lastEventName || eventName != lastEventName) {
            helper.getCaseMsg(component);
            component.set('v.lastEventName', eventName);
        }
    },
    opencaseAssetPopup: function (component, event, helper) {
	var selectedCaseIds = component.get("v.selectedCases");
        if(selectedCaseIds.length >0){
	$A.createComponent(
            "c:DisplayCaseAssets",
            {
                "recordId": selectedCaseIds[0],
                "showForm": true
            },
            function (msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('dispCaseAsset');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
	}
    },
    checkCaseWorkOrderDuplicate: function (component, event, helper) {
        var isWorkOrderDuplicate = event.getParam("isDuplicate");
        component.set('v.singleAssetDupCheck',isWorkOrderDuplicate);
    },

    closeDuplicatePopup: function (component, event, helper) {
        component.set('v.duplicateModal', false);  
    },
    
	goToQuote: function (cmp, event, helper){
        /*cmp.find("Id_spinner").set("v.class", 'slds-show');
        var CaseId = cmp.get('v.recordId');
        var getOppID = cmp.get('c.getOpportunityID');
        getOppID.setParams({
            CaseId: CaseId }
        );
        getOppID.setCallback(this, function(response){
            //component.set("v.loadingSpinner", false);
            if(response.getState() === 'SUCCESS'){
                var OpportunityResponse = response.getReturnValue();
                var OppID = OpportunityResponse[0].Id;
                var primaryQID = OpportunityResponse[0].SBQQ__PrimaryQuote__c;
                var urlEvent = $A.get('e.force:navigateToURL');
                        urlEvent.setParams({
                      "url": "/lightning/r/SBQQ__Quote__c/"+primaryQID+"/view" });
                        urlEvent.fire();
            }
            cmp.find("Id_spinner").set("v.class", 'slds-hide');
        });
        $A.enqueueAction(getOppID);*/
        cmp.set('v.showModal', true);
    },
    
     closeQuotes: function(cmp) {
        cmp.set('v.showModal', 'false');
         cmp.set('v.showQuoteModal', 'false');
        $A.get('e.force:refreshView').fire();
    },
    
    
    createQuote: function(cmp, event, helper) {
        
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        var CaseId = cmp.get('v.recordId');
        var checkQuote = cmp.get('c.addQuoteCheck');
        var getAction = cmp.get('c.getAddProductId');
        
        checkQuote.setParams({
            CaseId: CaseId
        });
        getAction.setCallback(this, function(response) {

            if (response.getState() === 'SUCCESS') {
             
                var addId = response.getReturnValue();
                checkQuote.setCallback(this, function(response) {
                    var state = response.getState();

                    if(state === 'SUCCESS') {
                        //TCS-pkulkarn-25-Aug-2023-Added for SDT-31259
                        var responseMessage = response.getReturnValue();
                        if (responseMessage != 'SUCCESS' && responseMessage != 'quoteExists' && responseMessage != null)
                        {
                            cmp.find("Id_spinner").set("v.class", 'slds-hide');
                            var warningToast = $A.get('e.force:showToast');
                            warningToast.setParams({
                                'title': 'Please review below error(s):',
                                'message': responseMessage,
                                'type': 'warning'
                            });
                            warningToast.fire();
                            return;
                        }
                        //TCS-pkulkarn-25-Aug-2023-End-SDT-31259

                        //if (response.getReturnValue() == 'quoteExists'){
                            
							cmp.set('v.showQuoteModal', true); 
                            cmp.find("Id_spinner").set("v.class", 'slds-hide');
                        /*}
                        else
                     {
						 // Code removed - to open Favroite Modal SDT-20853
						cmp.set('v.showFavroiteModal', 'true');
                        cmp.find("Id_spinner").set("v.class", 'slds-hide');
                     }*/
                  };
                });
                $A.enqueueAction(checkQuote);
            }
        });
        $A.enqueueAction(getAction);
        
    }
})