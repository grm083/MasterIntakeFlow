({
    getCaseMsg: function (component, selfFlag,helper) {
        var cId = component.get("v.recordId");
        var action = component.get('c.getCaseMessages');
        var assetCode = ["Utility", "UTL", "CAM"];
        var caseSubType = ["Empty and Return", "Extra Pickup", "On Call"];
        var errNoCaseAsset =  'No Asset Details have been added to the Case, To continue, create a new case to have components added.';
        //SDT-13757 - Task 3
        var errAssetPst = "The asset has ended for this service date. Please select the service date in the past to continue with the case";    
        var i;
        if (i == null || i == "undefined") {
            i = 0;
        }
        i++;
        var j = i;
        var caseIdset = [];
        caseIdset.push(cId);
        action.setParams({
            "caseId": cId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var wrapper = response.getReturnValue();
                if (wrapper) {
                    component.set("v.multiAssetSelections", wrapper.multiAssetSelections);
                    if (wrapper.relatedCaseList && wrapper.relatedCaseList.length > 1 && !selfFlag) { // 
                        var relatedIdList = '';
                        wrapper.relatedCaseList.forEach(function (res) {
                            relatedIdList += res.Id + '|';
                        });
                        var relatedCaseEvt = $A.get("e.c:RelatedCaseListener");
                        relatedCaseEvt.setParams({ "triggeringCase": component.get("v.recordId"), "relatedCases": relatedIdList })
                        relatedCaseEvt.fire();
                    }
                    var sMsg = null;
                    console.log('wrapper.caseInfo'+wrapper.caseInfo);
                    if (wrapper.caseInfo != "undefined" && wrapper.caseInfo != null && wrapper.caseInfo != "") {
                        sMsg = wrapper.caseInfo;
			if(sMsg.includes('NTE Approval Needed')){
                            component.set('v.showMsgNTE', true);
                            //component.set('v.NTEMsg', msgNte);
                            
                        }
                        // 42650
                        if(sMsg.includes('Create a New Service Open Top request')){
                            component.set('v.CaseMsg', wrapper.caseInfo);
                            component.set("v.viewCaseRed", true);
                            
                        } // 42650
                    }
                    if (wrapper.reqInfo != "undefined" && wrapper.reqInfo != null && wrapper.reqInfo != "") {
                        if (wrapper.reqInfo.includes('PSI is Required.Provide valid PSI or Bypass reason')) {
                            component.set('v.psiReq', false);
                        }
                    }
                    if (wrapper.disableMultiCase) {
                        component.set('v.isMultiCheckedVisible', false);
                    }
                    else {
                        component.set('v.isMultiCheckedVisible', true);
                    }
                    if (wrapper.CaseStatus === "Open") {
                        component.set('v.isShowAssignCase', true);
                    }
                    else {
                        component.set('v.isShowAssignCase', false);
                    }
                    if (wrapper.CaseSubType == "Empty and Do NOT Return") {
                        component.set('v.showMultipleCaseLabel', false);
                    }
                    else {
                        component.set('v.showMultipleCaseLabel', true);
                    }
                    
                    console.log("sMsg>>>"+sMsg);
                    //Non Pickup Conditions
                    var caseRecordNonPickup = component.get("v.caseRecord");
                    //SDT-13757 - Task 3
                    console.log("sMsg>>" + sMsg);
                    console.log('wrapper.isManualCaseAsset' + wrapper.isManualCaseAsset);
                    console.log('wrapper.Is_UpdateAssetActiveUser >' + wrapper.Is_UpdateAssetActiveUser);
                    console.log('wrapper.assetId >' + wrapper.assetId);
		    var caseRecordTypeList = wrapper.caseRecordTypeList;
                    //start enable add Quote for all Case record type except New Service Case SDT-26868
					//Changes related to SDT-32895
                    if(wrapper.addQuoteVisibility)
                    {
                    component.set('v.isAddQuote', true);
					 //Agent Swivel for CPQ
                        console.log('Evaluating for CPQ Eligibility here');
						component.set('v.disableAddQuote', false);
                        if (wrapper.CaseStatus == 'New' && wrapper.caseData.AssetId){
                            var getValidationFlow = component.get('c.launchCPQQuoteValidation');
                            getValidationFlow.setParams({
                                'CaseId': component.get('v.recordId')
                            });
                            getValidationFlow.setCallback(this, function(response) {
                                var state = response.getState();
                                console.log('Entered the validation flow for CPQ')
                                if (state == 'SUCCESS') {
                                    var returnVal = response.getReturnValue();
                                    console.log('Returned the response value from the validation flow for CPQ')
                                    if (returnVal) {
                                        var caseMessage = "Your case is eligible to be worked in CPQ!  Please use the 'Add Quote' button to configure the customer's requested change."
                                        console.log('Attempted to set the case message for the validation flow')
                                        component.set('v.CaseMsg', caseMessage);
                                    } else {
                                        var caseMessage = "Your case is not eligible to be worked in CPQ.  Please utilize tasking functionality to engage the setup teams.";
										component.set('v.disableAddQuote', true);
                                        component.set('v.CaseMsg', caseMessage);
                                    }
                                }
                            });
                            $A.enqueueAction(getValidationFlow);
                        }
                        //End Agent Swivel for CPQ
                    }
                    else
                    {
                    component.set('v.isAddQuote', false);
                    }
                    if(wrapper.progressCaseVisibility)
                    {
                    component.set('v.isShowProgressCase',true);
                    }
                    else
                    {
                    component.set('v.isShowProgressCase',false);
                    }
                  /*   if (caseRecordTypeList.includes(wrapper.caseRecordType) && wrapper.Is_UserHaveCPQLicence === true && wrapper.Is_UpdateAssetActiveUser === true && wrapper.assetId != '' && wrapper.assetId != undefined && wrapper.CPQProduct != '' && wrapper.CPQProduct != undefined) {
                        
                        if (!($A.util.isEmpty(wrapper.CaseType)) && !$A.util.isEmpty(wrapper.CaseSubType) && !($A.util.isEmpty(wrapper.caseData.ContactId)) && sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg != errAssetPst) 
                        {
                            if (wrapper.isOpportunityCreated) {
                                component.set('v.isAddQuote', false);
                                component.set('v.isOpportunityAdded', true);
                            }
                            else if (wrapper.CaseStatus !== 'Closed' && wrapper.caseRecordType !== 'Modify Existing Service Case') {
                                //addition for SDT -31981
                                //if(wrapper.caseRecordType === 'Pickup Case' || wrapper.caseRecordType === 'Status Case'){
                                    if(wrapper.addQuoteVisibility){
                                        component.set('v.isAddQuote', true);
                                    }else{
                                        console.log('in here***');
                                        component.set('v.isAddQuote', false);
                                    }
                                    
                                //}
                                //else{
                                    //changes related to SDT - 32895
                                    //component.set('v.isAddQuote', true);
                                    
                                //}
                            }
                        }
                        else
                        {
                            component.set('v.isAddQuote', false);  
                        }
                    } */

                   //SDT-41473 SDT-41538,41540
                   if(wrapper.isOpportunityCreated && wrapper.IsHaulAwayService)
                    {
                    component.set('v.isOpportunityAdded', true);    
                    }

                    //Changes related to SDT -32895 - For making view quote button visible for service request cases. 
                   if (caseRecordTypeList.includes(wrapper.caseRecordType) && wrapper.Is_UserHaveCPQLicence === true && wrapper.Is_UpdateAssetActiveUser === true && wrapper.assetId != '' && wrapper.assetId != undefined && wrapper.CPQProduct != '' && wrapper.CPQProduct != undefined) {
                    if (!($A.util.isEmpty(wrapper.CaseType)) && !$A.util.isEmpty(wrapper.CaseSubType) && !($A.util.isEmpty(wrapper.caseData.ContactId)) && sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg != errAssetPst) 
                    {
                        if (wrapper.isOpportunityCreated) {
                            component.set('v.isOpportunityAdded', true);
                        }

                    }
                } 
					
                    //enable add Quote for Modify Existing Service Case record type end SDT-26868
                    //Condition added for Add change story SDT-19922
                   //alert('CaseType>>'+wrapper.CaseType);
                    //alert('CaseData>>'+wrapper.caseData.Case_Type__c);
                   // if (wrapper.caseRecordType === 'Update Asset Case' && wrapper.Is_UserHaveCPQLicence === true && wrapper.Is_UpdateAssetActiveUser === true && wrapper.assetId != '' && wrapper.assetId != undefined) {
                    if (wrapper.CaseType !== 'Cancellation' && wrapper.CaseType !== 'Change Vendor' &&  wrapper.caseRecordType === 'Modify Existing Service Case' &&  wrapper.Is_UserHaveCPQLicence === true && wrapper.Is_UpdateAssetActiveUser === true && wrapper.assetId != '' && wrapper.assetId != undefined) {
                        if (!($A.util.isEmpty(wrapper.CaseType)) && !($A.util.isEmpty(wrapper.caseData.ContactId))) {
                            if (wrapper.isOpportunityCreated) {
                                //Changes for SDT -32895
                                //component.set('v.isAddQuote', false)
                                component.set('v.isOpportunityAdded', true);
                            }
                            else if (wrapper.CaseStatus !== 'Closed') {
                               //component.set('v.isAddQuote', true); 
                                //addition for SDT - 31503
                                if(wrapper.addQuoteVisibility){
									//Changes for SDT -32895
                                   //component.set('v.isAddQuote', true);
                                    //testing for alert message
                                   component.set("v.actionReqRed", false);
                                   component.set('v.CaseMsg', '');
                                }else{
                                    console.log('thisplace');
									//Changes for SDT -32895
                                    //component.set('v.isAddQuote', false);
                                    //testing for alert message
                                   component.set("v.actionReqRed", true);
                                   component.set('v.CaseMsg', sMsg);
                                }
								
								//addition for SDT -32426
                                if(wrapper.progressCaseVisibility){
                                    component.set('v.displayMsg', true);
									//Changes for SDT -32895
                                    //component.set('v.isShowProgressCase',true);
								}
                                else if(!wrapper.progressCaseVisibility){
                                    component.set('v.displayMsg', false);
									//Changes for SDT -32895
                                    //component.set('v.isShowProgressCase',false);
								}
                            }
                        }
                    }
					else if (wrapper.caseRecordType === 'Modify Existing Service Case' && ( wrapper.CaseType === 'Cancellation' || wrapper.CaseType === 'Change Vendor')){
						//Changes for SDT -32895
                        //component.set('v.isAddQuote', false);
                        component.set('v.displayMsg', true);
                        component.set('v.isAddCaseAsset', true);
						//Changes for SDT -32895
                        //component.set('v.isShowProgressCase',true);
                        if(!$A.util.isUndefinedOrNull(wrapper.assetId) &&!($A.util.isEmpty(wrapper.caseData.ContactId)) && wrapper.isManualCaseAsset){
                            if(wrapper.CaseStatus == "New"){
                                component.set('v.displaySummary',true);
                       			component.set('v.isAddCaseAsset',false);
								//addition for SDT - 31503
                                //addition for SDT -32822
                                if(wrapper.CaseType === 'Change Vendor' && wrapper.Is_UserHaveCPQLicence === true){
                                     if(wrapper.addQuoteVisibility){
                                    //testing for alert message
                                   component.set("v.actionReqRed", false);
                                   component.set('v.CaseMsg', '');
                                }else{
                                    //testing for alert message
                                   component.set("v.actionReqRed", true);
                                   component.set('v.CaseMsg', sMsg);
                                	} 	
                                }
                            }else{
                                component.set('v.displaySummary',false);
                       			component.set('v.isAddCaseAsset',false);
                            }
                        }
                    }
					//addition for SDT -32766
					//need to comment this part 
					//uncommented this part for SDT- 32766
                 /*   else if (wrapper.CaseType !== 'Cancellation' && wrapper.CaseType !== 'Change Vendor' && wrapper.caseRecordType === 'Modify Existing Service Case' && (wrapper.Is_UserHaveCPQLicence === false || wrapper.Is_UpdateAssetActiveUser === false)) {
                    //else if (wrapper.caseRecordType === 'Update Asset Case' && (wrapper.Is_UserHaveCPQLicence === false || wrapper.Is_UpdateAssetActiveUser === false)) {
                       // var validationMessage = sMsg;
                       sMsg = '';
                        //var caseRecordNonPickup = component.get("v.caseRecord");
                        component.set('v.isOpportunityAdded', false);
                        component.set('v.isAddQuote', false);
						//variable is set to true for SDT - 32766
                        component.set('v.displayMsg', true);
                        component.set("v.actionReqRed", false);
                        component.set('v.CaseMsg', sMsg);
                        component.set('v.showMultipleCaseLabel', false);
                        component.set('v.displayMultipleAssetCases', false);
                        component.set('v.isShowProgressCase', true);
                        component.set('v.displaySummary', false);
                        //component.set('v.CaseMsg', ' Read the Authorization Notes ');
                        component.set("v.isAddCaseAsset", true);

                    }  */
					
					//addition for SDT -32766
                    //adding condition to check isCaseInfoReady variable is true or not -SDT-32766
                    else if (wrapper.CaseType != "Pickup" && wrapper.CaseType != "New Service" && sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg != errAssetPst && (wrapper.CaseStatus == "New" && !sMsg.includes("Ready") && wrapper.isCaseInfoReady || wrapper.CaseStatus == "Open" && !sMsg.includes("Progress Case"))) {
                        console.log('Inside 1nd if' + sMsg);
                        var validationMessage = sMsg;
                        
                        component.set('v.displayMsg', true);
                        component.set("v.actionReqRed", true);
                        component.set('v.CaseMsg', sMsg);
                        component.set('v.showMultipleCaseLabel', false);
                        component.set('v.displayMultipleAssetCases', false);                          
                        component.set('v.displaySummary', false);
                        //Changes for SDT -32895
                        //component.set('v.isShowProgressCase',false);   
                        component.set("v.isAddCaseAsset",false);
                        console.log('wrapper.caseData.ContactId'+wrapper.caseData.ContactId);
                        if(wrapper.WorkOrderCreation && !wrapper.isAssetMandatory && wrapper.caseData.ContactId !=null){
                            console.log('inside new method');
							//Changes for SDT -32895
                            //component.set('v.isShowProgressCase',true); 
                            component.set("v.actionReqRed", false);
                        }
						//logic for SDT-31503 is moved from here as part of SDT -32766
                        //addition for SDT - 31503
                        //needs to add logic for checking if the case is 'Service Request Case' we need to add the error message
                        /*if(wrapper.caseRecordType == 'Service Request Case' && wrapper.addQuoteVisibility){
                             component.set("v.actionReqRed", true);
                             component.set('v.CaseMsg', sMsg);
                        }
                        else if(wrapper.caseRecordType == 'Service Request Case' && !wrapper.addQuoteVisibility){
                             component.set("v.actionReqRed", false);
                             component.set('v.CaseMsg', '');
                        }	*/					
                    }
                    else if (wrapper.CaseType != "Pickup" && wrapper.CaseType != "New Service" && wrapper.CaseStatus == "New" && sMsg != "undefined" && sMsg != null && sMsg != "" &&  (sMsg == errNoCaseAsset || sMsg == errAssetPst) && wrapper.WorkOrderCreation && !wrapper.isManualCaseAsset)            
                    {//SDT-13757 - Task 3
                        var validationMessage = sMsg;
                        console.log('Inside 2nd if'+sMsg);
                        component.set('v.displayMsg', true);
                        component.set("v.actionReqRed", true);
                        component.set('v.CaseMsg', sMsg);
                        component.set('v.showMultipleCaseLabel', false);
                        component.set('v.displayMultipleAssetCases', false);                          
                        
                        component.set('v.displaySummary', false);
                        if(sMsg == errNoCaseAsset) {
                            component.set("v.isAddCaseAsset",true);
                        }else {
                            component.set("v.isAddCaseAsset",false);
                        }
                        //SDT-13757 - Task 3
                        if(sMsg == errAssetPst ) {
                            component.set("v.isShowProgressCase",true);
                            component.set("v.isAddCaseAsset",false);
                        }else {
                            component.set('v.isShowProgressCase',false);
                        }
                        
                        
                    }
                    
                        else if (wrapper.CaseType != "Pickup" && wrapper.CaseType != "New Service" && wrapper.CaseStatus == "New" && sMsg != "undefined" && sMsg != null && sMsg != "" &&  sMsg == errNoCaseAsset && !wrapper.WorkOrderCreation )            
                        {
                            console.log('Inside 3rd if'+sMsg);
                            var validationMessage = sMsg;
                            
                            component.set('v.displayMsg', true);
                            component.set("v.actionReqRed", true);
                            component.set('v.CaseMsg', sMsg);
                            component.set('v.showMultipleCaseLabel', false);
                            component.set('v.displayMultipleAssetCases', false);                          
                           //Changes for SDT -32895 //component.set('v.isShowProgressCase',false);            
                            component.set('v.displaySummary', false);
                            component.set("v.isAddCaseAsset",false);
                            
                        }
                            //adding condition to check isCaseInfoReady variable is true or not - SDT-32766
                            else if (wrapper.CaseType != "Pickup" && wrapper.CaseType != "New Service" && wrapper.CaseStatus == "New" && sMsg != "undefined" && sMsg != null && sMsg != "" && ((sMsg.includes("Ready") ||!wrapper.isCaseInfoReady) && wrapper.WorkOrderCreation && !wrapper.isManualCaseAsset ))
                            {
                                console.log('Inside 4th if'+sMsg);
                                // var validationMessage = sMsg;
                                sMsg = '';
                                var caseRecordNonPickup = component.get("v.caseRecord");
                                component.set('v.displayMsg', true);
                                component.set("v.actionReqRed", false);
                                component.set('v.CaseMsg', sMsg);
                                component.set('v.showMultipleCaseLabel', false);
                                component.set('v.displayMultipleAssetCases', false); 
						        //Changes for SDT -32895								
                                //component.set('v.isShowProgressCase',true);
                                component.set('v.displaySummary', false);
                                component.set("v.isAddCaseAsset",false);
								// logic for showing error message for SDT-31503 is moved to here
                                //addition for SDT - 31503
                                //needs to add logic for checking if the case is 'Service Request Case' we need to add the error message
                                if(wrapper.caseRecordType == 'Service Request Case' && wrapper.addQuoteVisibility && wrapper.Is_UserHaveCPQLicence === true){
                                     component.set("v.actionReqRed", true);
                                     component.set('v.CaseMsg', wrapper.caseInfo);
                                }else{
                                     component.set('v.CaseMsg', ' Read the Authorization Notes ');
                                }
                                //component.set('v.CaseMsg', ' Read the Authorization Notes ');
                                
                                var singleAssetDupCheck = component.get('v.singleAssetDupCheck');
                                if(caseRecordNonPickup.Location__c && caseRecordNonPickup.AssetId && caseRecordNonPickup.Service_Date__c && caseRecordNonPickup.Case_Type__c != 'Pickup' && caseRecordNonPickup.Case_Sub_Type__c && !caseRecordNonPickup.Ignore_Duplicate__c && !caseRecordNonPickup.Is_Clone__c && !singleAssetDupCheck)
                                {
                                    //component.set('v.singleAssetDupCheck',true);
                                    helper.duplicateCheckInvocation(component,false);
                                }
                                
                                if(caseRecordNonPickup.AssetId != "undefined" && caseRecordNonPickup.AssetId != null && caseRecordNonPickup.AssetId != "" && sMsg != errAssetPst){
                                    component.set("v.isAddCaseAsset",true);
                                }
                            }
								//adding condition to check isCaseInfoReady variable is true or not - SDT-32766
                                else if (wrapper.CaseType != "Pickup" && wrapper.CaseType != "New Service" && wrapper.CaseStatus == "New" && sMsg != "undefined" && sMsg != null && sMsg != "" && (sMsg.includes("Ready")||!wrapper.isCaseInfoReady) && wrapper.WorkOrderCreation && wrapper.isManualCaseAsset)
                                {
                                    // var validationMessage = sMsg;
                                    sMsg = '';
                                    var caseRecordNonPickup = component.get("v.caseRecord");
                                    component.set('v.displayMsg', true);
                                    component.set("v.actionReqRed", false);
                                    component.set('v.CaseMsg', sMsg);
                                    component.set('v.showMultipleCaseLabel', false);
                                    component.set('v.displayMultipleAssetCases', false);  
									//Changes for SDT -32895									
                                    //component.set('v.isShowProgressCase',true);
                                    component.set('v.displaySummary',true);
									// logic for showing error message for SDT-31503 is moved to here
                                    //addition for SDT - 31503
                                    if(wrapper.caseRecordType == 'Service Request Case' && wrapper.addQuoteVisibility && wrapper.Is_UserHaveCPQLicence === true){
                                         component.set("v.actionReqRed", true);
                                         component.set('v.CaseMsg', wrapper.caseInfo);
                                    }else{
                                         component.set('v.CaseMsg', ' Read the Authorization Notes ');
                                    }
                                    //component.set('v.CaseMsg', ' Read the Authorization Notes ');
                                    component.set("v.isAddCaseAsset",false);
                                    
                                }
									//adding condition to check isCaseInfoReady variable is true or not - SDT-32766
                                    else if (wrapper.CaseType != "Pickup" && wrapper.CaseType != "New Service" && wrapper.CaseStatus == "New" && sMsg != "undefined" && sMsg != null && sMsg != "" && (sMsg.includes("Ready") ||!wrapper.isCaseInfoReady) && !wrapper.WorkOrderCreation)
                                    {
                                        // var validationMessage = sMsg;
                                        //sMsg = '';                          
                                        
                                        component.set('v.displayMsg', true);
                                        component.set("v.actionReqRed", false);
                                        component.set('v.CaseMsg', '');
                                        component.set('v.showMultipleCaseLabel', false);
                                        component.set('v.displayMultipleAssetCases', false);  
										//Changes for SDT -32895
                                        //component.set('v.isShowProgressCase',true);
                                        component.set('v.displaySummary',false);
                                        component.set("v.isAddCaseAsset",false);
                                        
                                    }
                    
                                        else if (wrapper.CaseType != "Pickup" && wrapper.CaseStatus == "Open"  && sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg.includes("* Workorder has been Created\n"))
                                        {
                                            // var validationMessage = sMsg;
                                            
                                            component.set('v.displayMsg', true);
                                            component.set("v.actionReqRed", false);
                                            component.set('v.CaseMsg', sMsg);
                                            component.set('v.showMultipleCaseLabel', false);
                                            component.set('v.displayMultipleAssetCases', false);
                                            component.set('v.isShowProgressCase',true);
                                            component.set('v.displaySummary', false);
                                            component.set("v.isAddCaseAsset",false);
                                            
                                        }
                                            else if (wrapper.CaseType === "New Service"  && wrapper.Is_UserHaveCPQLicence === true)
                                            {
												//Changes for SDT -32895
                                                //component.set('v.isAddQuote', false);
                                                component.set('v.isOpportunityAdded', false);
                                                if(wrapper.Is_UserHaveCPQLicence === true && !($A.util.isEmpty(wrapper.CaseReason)) && !($A.util.isEmpty(wrapper.caseData.ContactId)))
                                                {
                                                    if(wrapper.isOpportunityCreated){
														//Changes for SDT -32895
                                                        //component.set('v.isAddQuote', false);
                                                        component.set('v.isOpportunityAdded', true);
                                                    }
                                                    else if (wrapper.CaseStatus !== 'Closed')
                                                    {
														//Changes for SDT -32895
                                                        //component.set('v.isAddQuote', true);
                                                    }
                                                }
                                                component.set('v.displayMsg', false);
                                                component.set("v.actionReqRed", false);
                                                component.set('v.CaseMsg', sMsg);
                                                component.set('v.showMultipleCaseLabel', false);
                                                component.set('v.displayMultipleAssetCases', false); 
											    //Changes for SDT -32895
                                                //component.set('v.isShowProgressCase',false);
                                                component.set('v.displaySummary', false);
                                                component.set("v.isAddCaseAsset",false);
						// SDT-SDT // Show Error Message
                                                if (wrapper.reqInfo != "undefined" && wrapper.reqInfo != null && wrapper.reqInfo != "" ) {
                                                    component.set('v.reqInfo', wrapper.reqInfo);
                                                    component.set('v.reqInfoMsg', true);
                                                    component.set("v.displaySummary", false);
                                                    component.set('v.caseServiceDateBtn', true);
                                                } else {
                                                    component.set('v.reqInfoMsg', false);
                                                }
                                                //
                                                
                                            }
                    //Changes added for 21793
                    					else if (wrapper.CaseType === "New Service"  && wrapper.Is_UserHaveCPQLicence === false)
                                            {
												//Changes for SDT -32895
                                                //component.set('v.isAddQuote', false);
                                                component.set('v.isOpportunityAdded', false);
                                                // var validationMessage = sMsg;
                                                component.set('v.displayMsg', false);
                                                component.set("v.actionReqRed", false);
                                                component.set('v.CaseMsg', sMsg);
                                                component.set('v.showMultipleCaseLabel', false);
                                                component.set('v.displayMultipleAssetCases', false);  
											    //Changes for SDT -32895
                                                //component.set('v.isShowProgressCase',false);
                                                component.set('v.displaySummary', false);
                                                component.set("v.isAddCaseAsset",false);
                                                
                                            }    
                                                else if (wrapper.CaseType != "Pickup" && wrapper.CaseStatus == "Open"  && !wrapper.WorkOrderCreation )
                                                {
                                                    // var validationMessage = sMsg;
                                                    
                                                    component.set('v.displayMsg', true);
                                                    component.set("v.actionReqRed", false);
                                                    //component.set('v.CaseMsg', sMsg);
                                                    component.set('v.showMultipleCaseLabel', false);
                                                    component.set('v.displayMultipleAssetCases', false); 
													//Changes for SDT -32895                         
                                                    //component.set('v.isShowProgressCase',true);
                                                    component.set('v.displaySummary', false);
                                                    component.set("v.isAddCaseAsset",false);
                                                    
                                                }
                    
                                                    else if (wrapper.CaseType != "Pickup" && wrapper.CaseStatus == "Open"  && wrapper.WorkOrderCreation && !wrapper.isManualCaseAsset){
                                                        
                                                        var caseRecordNonPickup = component.get("v.caseRecord");
                                                        component.set('v.displayMsg', true);
                                                        component.set("v.actionReqRed", false);                    
                                                        component.set('v.showMultipleCaseLabel', false);
                                                        component.set('v.displayMultipleAssetCases', false);
														//Changes for SDT -32895                          
                                                        //component.set('v.isShowProgressCase',true);
                                                        component.set('v.displaySummary', false);
                                                        component.set("v.isAddCaseAsset",false);
                                                        if(caseRecordNonPickup.AssetId != "undefined" && caseRecordNonPickup.AssetId != null && caseRecordNonPickup.AssetId != "" && sMsg != errAssetPst){
                                                            component.set("v.isAddCaseAsset",true);
                                                        }
                                                        //component.set('v.CaseMsg', ' Read the Authorization Notes ');
                                                        if(sMsg && sMsg == 'Select the appropriate asset header to Progress Case'){
                                                            component.set('v.CaseMsg', sMsg);
                                                            component.set("v.actionReqRed", true);
                                                        }else {
                                                            component.set('v.CaseMsg', ' Read the Authorization Notes ');
                                                        }
                                                    }
                    
                                                        else if (wrapper.CaseType != "Pickup" && wrapper.CaseType != "New Service" && wrapper.CaseStatus == "Open"  && wrapper.WorkOrderCreation && wrapper.isManualCaseAsset){
                                                            
                                                            component.set('v.displayMsg', true);
                                                            component.set("v.actionReqRed", false);
                                                            //component.set('v.CaseMsg', sMsg);
                                                            component.set('v.showMultipleCaseLabel', false);
                                                            component.set('v.displayMultipleAssetCases', false); 
														    //Changes for SDT -32895
                                                            //component.set('v.isShowProgressCase',true);
                                                            component.set('v.displaySummary', true);
                                                            component.set('v.CaseMsg', ' Read the Authorization Notes ');
                                                            component.set("v.isAddCaseAsset",false);
                                                            
                                                            if(wrapper.caseData.Case_Sub_Status__c != "undefined" && wrapper.caseData.Case_Sub_Status__c != null && wrapper.caseData.Case_Sub_Status__c != ""){
                                                                component.set('v.displaySummary', false);
                                                            }
                                                            
                                                        }
                    
                                                            else if (wrapper.CaseType != "Pickup" && wrapper.CaseStatus == "Closed" )
                                                            {
                                                                // var validationMessage = sMsg;
                                                                
                                                                component.set('v.displayMsg', true);
                                                                component.set("v.actionReqRed", false);
                                                                component.set('v.CaseMsg', sMsg);
                                                                component.set('v.showMultipleCaseLabel', false);
                                                                component.set('v.displayMultipleAssetCases', false);
																//Changes for SDT -32895                          
                                                                //component.set('v.isShowProgressCase',false);
                                                                component.set('v.displaySummary', false);
                                                                component.set("v.isAddCaseAsset",false);
                                                                
                                                            }
                                                                
                    
                   
                    
                    
                    //Non Pickup Validation End
                    console.log("sMsg+++"+sMsg);
                    console.log('276component.get(v.isShowProgressCase'+component.get('v.isShowProgressCase'));
                    if (cId == wrapper.caseId && wrapper.CaseType == "Pickup") {
																	   
                        if (sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg.includes("Ready")) {
							var caseRecord = component.get("v.caseRecord");
                            if(caseRecord && caseRecord.Is_Multiple_Asset__c && !caseRecord.Show_Multiple_Asset_Cases__c && !caseRecord.isMultiCalendarChecked__c){
                                component.set('v.CaseMsg', "Complete the intake of related cases(if any) from the parent case");
                                component.set('v.displaySummary', false);
                                component.set('v.displayMsg', true);
                                component.set('v.showOnRelatedMultiAssetCase',true);
                                
                                
                            }
                            else{
                                
                                component.set('v.CaseMsg', '');
                                component.set('v.displaySummary', true);
                                component.set('v.displayMsg', true);
                                var isWMcapacityEligible = component.get('v.isCapacityEligible');
                                if(!isWMcapacityEligible)
                                    component.find("disablebuttonid").set("v.label", 'View Case Summary');
                                var singleAssetDupCheck = component.get('v.singleAssetDupCheck');
                                if(caseRecord.Location__c && caseRecord.AssetId && caseRecord.Service_Date__c && caseRecord.Case_Type__c == 'Pickup' && caseRecord.Case_Sub_Type__c && !caseRecord.Ignore_Duplicate__c && !caseRecord.Is_Clone__c && !singleAssetDupCheck)
                                {
                                    component.set('v.singleAssetDupCheck',true);
                                    helper.duplicateCheckInvocation(component,false);
                                }
                            }
                            component.set("v.actionReqRed", false);
                            component.set('v.subTypeBtn', false);
                            component.set('v.caseServiceDateBtn', true);
                            component.set('v.isShowPOPSI', true);
                            component.set('v.showMultipleCaseLabel', true);
                            
                            
                            if (assetCode.indexOf(wrapper.assetSCode) > -1) {
								//Changes for SDT -32895
                                //component.set('v.isShowProgressCase', true);
                                component.set('v.showMultipleCaseLabel', false);
                                
                            }
                            else if (wrapper.CaseSubType == "Bale(s)") {
                                component.set('v.CaseMsg', '');
								//Changes for SDT -32895
                                //component.set('v.isShowProgressCase', true);
                                component.set('v.displayMultipleAssetCases', false);
                                component.set('v.showMultipleCaseLabel', false);
                                component.set('v.caseServiceDateBtn', false);
                                component.set('v.displaySummary', false);
                            }
                            else {
															
															   
																			
																					
																				
																			 
																									 
																			
																	
									  
																			   
								 
																	 
							 
									//Changes for SDT -32895  
                                    //component.set('v.isShowProgressCase', false);
                                }
                            
                        }
                        else if (sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg.includes("Complete the intake of related cases(if any) from the parent case")) {
                            var caseRecord = component.get("v.caseRecord");
                            if(caseRecord.Status ==='New'){
                                component.set('v.displayMsg', true);
                                component.set("v.actionReqRed", false);
                                component.set('v.subTypeBtn', false);
                                component.set('v.caseServiceDateBtn', false);
                                component.set('v.isShowPOPSI', false);
                                component.set('v.CaseMsg', sMsg);
                                
                                
                                if(wrapper.reqInfo === "" && caseRecord && caseRecord.Location__c && caseRecord.AssetId && caseRecord.Service_Date__c  && caseRecord.Case_Sub_Type__c){
                                    component.set('v.showMultipleCaseLabel', true);
                                    component.set('v.showOnRelatedMultiAssetCase',true);
                                    /*if(caseRecord && caseRecord.Location__c && caseRecord.AssetId && caseRecord.Service_Date__c  && caseRecord.Case_Sub_Type__c){
                                        component.set('v.showMultipleCaseLabel', true);
                                        component.set('v.showOnRelatedMultiAssetCase',true);
                                    }
                                    else{
                                        component.set('v.showMultipleCaseLabel', false);
                                    }*/
                                }else{
                                    
                                }
                            }
                        }
                            else if (sMsg != "undefined" && sMsg != null && sMsg != "" && (sMsg.includes("Workorder has been initiated. Please complete any open tasks if created.") || sMsg.includes("* Workorder has been Created\n"))) {
                                component.set('v.CaseMsg', sMsg);
                                component.set("v.displaySummary", false);
                                component.set('v.displayMsg', true);
                                component.set('v.subTypeBtn', false);
                                component.set('v.caseServiceDateBtn', false);
                                component.set('v.isShowPOPSI', false);
                                if (sMsg == '* Workorder has been Created\n') {
                                    component.set("v.actionReqRed", false);
                                    helper.getOpenTask(component,event);
                                    
                                }
                                else if (sMsg != '* Workorder has been created. Please check Related Cases tab to complete intake' && sMsg != '* Workorder has been Created\n') {
                                    component.set("v.actionReqRed", true);
                                }
                                
                                if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                                    component.set('v.isShowProgressCase', false);
                                }
                            } else if (sMsg != "undefined" && sMsg != null && sMsg != "" && (sMsg.includes("* Workorder has been created. Please check Related Cases tab to complete intake") || sMsg.includes("* Workorder has been initiated. Please check Related Cases tab to complete intake"))) {
                                component.set('v.CaseMsg', sMsg);
                                component.set("v.displaySummary", false);
                                component.set('v.displayMsg', true);
                                component.set('v.subTypeBtn', false);
                                component.set('v.caseServiceDateBtn', false);
                                component.set('v.isShowPOPSI', false);
                                if (sMsg != '* Workorder has been created. Please check Related Cases tab to complete intake' && sMsg != '* Workorder has been Created\n') {
                                    component.set("v.actionReqRed", true);
                                    component.set('v.ShowRelatedCases', true);
                                }
                                
                                if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                                    component.set('v.isShowProgressCase', false);
                                }
                            } else if (sMsg != "undefined" && sMsg != null && sMsg.includes("Complete the intake of related cases(if any) from the above list")) {
                                component.set('v.CaseMsg', sMsg);
                                component.set('v.displayMsg', true);
                                component.set("v.displaySummary", false);
                                component.set("v.displayMultipleAssetCases", false);
                                component.set('v.subTypeBtn', false);
                                component.set('v.caseServiceDateBtn', false);
                                component.set('v.isShowPOPSI', false);
                                
                                if (sMsg != '* Workorder has been created. Please check Related Cases tab to complete intake' && sMsg != '* Workorder has been Created\n') {
                                    component.set("v.actionReqRed", true);
                                    component.set('v.ShowRelatedCases', true);
                                }
                                
                                if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                                    component.set('v.isShowProgressCase', false);
                                }
                            } else if (sMsg != "undefined" && sMsg != null && sMsg.includes("Create multiple cases for selected assets")) {
                                component.set('v.CaseMsg', sMsg);
                                component.set('v.displayMsg', true);
                                component.set("v.displaySummary", false);
                                component.set("v.displayMultipleAssetCases", true);
                                component.set('v.subTypeBtn', false);
                                component.set('v.caseServiceDateBtn', true);
                                
                                
                                if (sMsg != '* Workorder has been created. Please check Related Cases tab to complete intake' && sMsg != '* Workorder has been Created\n') {
                                    component.set("v.actionReqRed", true);
                                }
                                
                                if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                                    component.set('v.isShowProgressCase', false);
                                }
                                
                            } else if (sMsg != "undefined" && sMsg != null && sMsg.includes("Select Case Subtype to Progress Case ")) {
                                component.set('v.CaseMsg', sMsg);
                                component.set('v.displayMsg', true);
                                component.set("v.displaySummary", false);
                                component.set('v.subTypeBtn', true);
                                component.set('v.caseServiceDateBtn', false);
                                if (sMsg != '* Workorder has been created. Please check Related Cases tab to complete intake' && sMsg != '* Workorder has been Created\n') {
                                    component.set("v.actionReqRed", true);
                                    component.set('v.ShowRelatedCases', true);
                                }
                                
                                if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                                    component.set('v.isShowProgressCase', false);
                                }
                                
                            }
                                else if (sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg == "Progress Case") {
																				   
                                    component.set('v.displayMsg', true);
                                    component.set("v.displayMultipleAssetCases", false);
                                    component.set('v.caseServiceDateBtn', false);
                                    component.set('v.showMultipleCaseLabel', false);
                                    component.set("v.displaySummary", false);
                                    component.set('v.isShowPOPSI', false);
                                    component.set('v.isShowProgressCase', true);
    

																																																						  
																											 
																					
																			
											  
																					   
										 
																		   
																																																																				  
										 
																						
																							 
										 
										 
                                }
                                                                        
																	
																		 
																					 
																							
																						
																					 
																			
																				 
																			 
										 
																																																																																					   
																	
																		 
																					
																							
																						
																					 
																			
																				 
																			 
									 
									
                                    else if (sMsg != "undefined" && sMsg != null && sMsg != "") {
                                        component.set('v.CaseMsg', sMsg);
                                        component.set('v.displayMsg', true);
                                        component.set("v.displaySummary", false);
                                        component.set('v.subTypeBtn', false);
                                        
                                        if (sMsg.includes('Provide SLA Service Date/Time to Progress Case ')) {
                                            component.set('v.caseServiceDateBtn', true);
                                        }
                                        else if (sMsg.includes('The Asset details have already passed the end date')) {
                                            component.set('v.caseServiceDateBtn', true);
                                            
                                        }
                                        
                                            else {
                                                component.set('v.caseServiceDateBtn', false);
                                            }
                                        
                                        if (sMsg != '* Workorder has been created. Please check Related Cases tab to complete intake' && sMsg != '* Workorder has been Created\n') {
                                            component.set("v.actionReqRed", true);
                                            component.set('v.ShowRelatedCases', true);
                                        }
                                        
                                         if (assetCode.indexOf(wrapper.assetSCode) > -1) {
											component.set('v.isShowProgressCase', false);
                                        }
                                    } else {
																	   
                                        component.set('v.displayMsg', false);
                                        component.set("v.displaySummary", false);
                                        component.set('v.subTypeBtn', false);
                                        component.set('v.caseServiceDateBtn', true);
                                        component.set('v.isShowPOPSI', true);
                                        
                                        if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                                            component.set('v.isShowProgressCase', false);
                                        }
                                        
                                    }
                        if (wrapper.reqInfo != "undefined" && wrapper.reqInfo != null && wrapper.reqInfo != "" && (wrapper.caseInfo ==='' || wrapper.caseInfo ==='Ready' || wrapper.caseInfo ==='Multi Asset')) {
                            component.set('v.reqInfo', wrapper.reqInfo);
                            component.set('v.reqInfoMsg', true);
                            component.set("v.displaySummary", false);
                            component.set('v.caseServiceDateBtn', true);
                            if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                                component.set('v.isShowProgressCase', false);
                            }
                        } else {
                            component.set('v.reqInfoMsg', false);
                        }
						
                        if (wrapper.approvalInfo != "undefined" && wrapper.approvalInfo != null && wrapper.approvalInfo != "") {
                            component.set('v.approvalInfo', wrapper.approvalInfo);
                            if (wrapper.occurrenceLimit != "undefined" && wrapper.occurrenceLimit != null && wrapper.occurrenceLimit != "" && wrapper.occurrenceLimit != 0) {
                                component.set('v.occurrenceLimit', wrapper.occurrenceLimit);
                                component.set('v.displayOccurrence', true);
                            }
                            component.set('v.approvalInfoMsg', true);
                            
                        } else if (wrapper.enableapprovalInfo) {
                            component.set('v.approvalInfo', 'Case will be auto Approved');
                            component.set('v.approvalInfoMsg', true);
                            
                        } else {
                            component.set('v.approvalInfoMsg', false);
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getCaseSummary: function (component, helper) {
        var cId = component.get("v.recordId");
        var referenceNo = component.get("v.multiAssetCaseReferenceNo");
        var action = component.get('c.getCaseSummary');
        action.setParams({
            "caseId": cId,
            "referenceNo": referenceNo,
            "parentId" : component.get("v.caseRecord").ParentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                component.set('v.caseSummary', data);
                helper.populateCheckboxField(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    getQAOverride: function (component, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get('c.getCaseDetails');
        action.setParams({
            "caseRecId": caseId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                component.set('v.caseRec', data);
            }
        });
        $A.enqueueAction(action);
    },
    
    getOpenTask: function (component, event) {
        var selectedCase = component.get("v.recordId");
        var action = component.get('c.getCopyCaseOpenTask');
        
        action.setParams({
            "caseId": selectedCase
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                if(data){
                    
                    component.set('v.CaseMsg', " Workorder has been created. Please check Related Cases tab to complete intake. ");
                }
                else {
                    component.set('v.CaseMsg', " Workorder has been Created.");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    addWODetails: function (component, helper) {
        var selectedCaseList = component.get("v.selectedCases");
        var caseObjFields = component.get("v.CaseObj");
	caseObjFields.Is_ByPassWO__c = component.get("v.isByPassWO"); // Added by SDT-18424
        var action = component.get('c.addWorkOrderDetails');
        
        action.setParams({
            "caseWoFields": caseObjFields,
            "caseIdList": selectedCaseList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.WOInstructions", false);
                component.set("v.CaseObj", { 'sobjectType': 'Case' });
                if (data == 'Success') {
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);    
    },
    
    initiateWo: function (component, helper) {
		component.set("v.viewCaseSummary", false);
        component.set("v.loaded", true);
        var selectedCaseList = component.get("v.selectedCases");
        var selectedCase = component.get("v.recordId");
        var action = component.get('c.initiateWorkOrder');
        action.setParams({
            "caseId": selectedCase,
            "caseIdList": selectedCaseList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                if (data == 'Success') {
                    
                    
                    component.find("recordLoader").reloadRecord(true);
                    
					
					const label = component.find("disablebuttonid").get("v.label"); 
					
                    if(component.find("workOrderButton")){
                        var initiatebtn = component.find("workOrderButton").get("v.disabled");
                    }  
                    component.set("v.viewCaseSummary", false);
                    component.set("v.loaded", false);
                    window.setTimeout(function () {
                        helper.refreshFocusedTab(component);
                        if(label == "View Multi Asset Case Summary" && !initiatebtn){
                            const payload = {
                                caseId: component.get("v.recordId"),
                            };
                            component.find("lmschannel").publish(payload);
                        }
                    }, 3000);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    updatedRelatedCases: function (component, helper) {
		component.set("v.loaded", true);
        var cId = component.get("v.recordId");
        var action = component.get('c.updateRelatedCases');
        var multiAssetSelections = component.get("v.multiAssetSelections");
        action.setParams({
            "caseId": cId,
            "multiAssetSelections": multiAssetSelections
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.displayMultipleAssetCases", false);
                component.find("recordLoader").reloadRecord(true);
				component.set("v.loaded", false);
                helper.getCaseMsg(component, false,helper);
            }
        });
        $A.enqueueAction(action);
    },
    refreshFocusedTab: function (component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            var result = workspaceAPI.refreshTab({
                tabId: focusedTabId,
                includeAllSubtabs: true
            });
        })
        
        .catch(function (error) {
            console.log(error);
        });
    },
    
    navigateToCaseDetail: function (component, event, helper) {
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": event.currentTarget.dataset.id,
            "slideDevName": "detail"
        });
        sObjectEvent.fire();
    },
    populateCheckboxField: function (component) {
        let array = component.find("multiSelect");
        var selectedCase = [];
        if (Array.isArray(array) && array.length > 1) {
            component.find("woUpdates").set("v.disabled", true);
            array.forEach(function (res) {
                res.set("v.value", true);
            });
        }
        else if (array) {
            component.find("multiSelect").set("v.value", true);
        }
        let caseList = component.get("v.caseSummary");
        if (caseList) {
            caseList.forEach(function (res) {
                selectedCase.push(res.Id);
            });
        }
        component.set('v.selectedCases', selectedCase);
        if(selectedCase.length == 1){
            component.find("woUpdates").set("v.disabled", false);
        } else {
            component.find("woUpdates").set("v.disabled", true);
        }
    },
    enableWorkorderButton: function (component) {
        var checkboxes = component.find("multiSelect");
        var chkflag = false;
        var count = 0;
        if (checkboxes.length != undefined) {
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].get("v.value") == true) {
                    chkflag = true;
                    count++;
                }
            }
        } else {
            checkboxes = [component.find("multiSelect")];
            if (checkboxes[0].get("v.value") == true){
                chkflag = true;
                count++; 
            }  
        }
        component.find("workOrderButton").set("v.disabled", !chkflag);
        component.find("workOrderButtonInst").set("v.disabled", !chkflag);
        
        if(count == 1){
            component.find("woUpdates").set("v.disabled", false);
        } else {
            component.find("woUpdates").set("v.disabled", true);
        }
    },
    getCaseMsg_new_trail: function (component){
        var action = component.get('c.getCaseMessages_new');
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var wrapper = response.getReturnValue();
                if (wrapper) {
                }
            }
        });
        $A.enqueueAction(action);
    },
     duplicateCheckInvocation: function (component, flag) {
        if(!component.get('v.duplicateModal')) {
            var x = component.get("v.recordId");
            $A.createComponent(
                "c:DuplicateCheckOnCase",
                {
                    "currentCaseID": component.get("v.recordId"),
                    "isMultiAssetCase": flag
                },
                function (msgBox) {
                    if (component.isValid()) {
                        var targetCmp = component.find('duplicateCheck');
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                        component.set('v.duplicateModal', true);  
                    }
                }
            );
        }
    },
	
	AdditionalEmailTemplate: function (component, helper) {
        var selectedCaseId = component.get("v.selectedCases");
        var caseRec = component.get("v.CaseObj");
        console.log('selectedCaseList===='+selectedCaseId);
        console.log('caseObjFields===='+caseRec.EmailTemplateAdditionalComments__c);
        var action = component.get('c.saveAdditionalTemplate');        
        action.setParams({
            "emailTempDesc": caseRec.EmailTemplateAdditionalComments__c,
            "caseId": component.get("v.selectedCases")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            
            console.log('state==='+state);
            if (state == "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.caseEmailTemp", false);
               // component.set("v.CaseObj", { 'sobjectType': 'Case' });
                if (data == 'Success') {
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);    
    },
	
	isTemplateVisible: function(component){
        var caseId = component.get("v.recordId");
        var action = component.get('c.IsTemplateVisible');
        action.setParams({"caseRecId" : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var isEligible= response.getReturnValue();
                
                if(isEligible)
                    component.set("v.isTempVisible",true); 
                else
                    component.set("v.isTempVisible",false);
            }
        });
        $A.enqueueAction(action);
    },
	
    isCapacityEligible: function(component){
        var caseId = component.get("v.recordId");
        var action = component.get('c.IsWMCapacityPlannerVisible');
        action.setParams({"caseRecId" : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var isEligible= response.getReturnValue();
                if(isEligible)
                    component.set("v.isCapacityEligible",true);
                else
                    component.set("v.isCapacityEligible",false);
            }
        });
        $A.enqueueAction(action);
    },
})