({    
    SetMultiDateVisibility:function(component,helper){        
         var cId = component.get("v.recordId");
        var assetCode = ["Utility", "UTL", "CAM"];
        var action = component.get('c.IsMultiVisible');
           action.setParams({
            "caseRecId": cId
        });
          action.setCallback(this, function (response) {
              var state = response.getState();
              if (state == "SUCCESS") {
                var wrapper = response.getReturnValue();
                if (wrapper) {
                  var sMsg = null;
                    component.set("v.caseRecord",wrapper.caseData );
                  if (wrapper.caseInfo != "undefined" && wrapper.caseInfo != null && wrapper.caseInfo != "") {
                      sMsg = wrapper.caseInfo;
                  }
                  if (wrapper.reqInfo != "undefined" && wrapper.reqInfo != null && wrapper.reqInfo != "") {
                      if (wrapper.reqInfo.includes('PSI is Required.Provide valid PSI or Bypass reason')) {
                          component.set('v.psiReq', false);
                      }
                  }
				  if(wrapper.caseAppliedRules != null && wrapper.caseAppliedRules.includes('PSI')){
                     component.set('v.psiReq', false);
                 }

                  if (wrapper.disableMultiCase) {
                      component.set('v.isMultiCheckedVisible', false);
                  }
                  else {
                      component.set('v.isMultiCheckedVisible', true);
                  }
                  if (wrapper.CaseSubType == "Empty and Do NOT Return") {
                      component.set('v.showMultipleCaseLabel', false);
                  }
                  else {
                      component.set('v.showMultipleCaseLabel', true);
                  }
                  if (cId == wrapper.caseId) {
                      if (sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg.includes("Ready")) {
                          var caseRecord = component.get("v.caseRecord");
                          if(caseRecord && caseRecord.Is_Multiple_Asset__c && !caseRecord.Show_Multiple_Asset_Cases__c){
                              component.set('v.displaySummary', false);                                
                              component.set('v.showOnRelatedMultiAssetCase',true);
                          }
                          else{                                
                              component.set('v.displaySummary', true);                               
                          }
                           if (wrapper.CaseSubType == "Empty and Do NOT Return") {
                   			   component.set('v.showMultipleCaseLabel', false);
                  			}
                          //component.set('v.showMultipleCaseLabel', true);
                          if (assetCode.indexOf(wrapper.assetSCode) > -1) {
                              component.set('v.showMultipleCaseLabel', false);                                
                          }
                          else if (wrapper.CaseSubType == "Bale(s)") {
                            
                              component.set('v.showMultipleCaseLabel', false);                               
                              component.set('v.displaySummary', false);
                          }
                      }
                      else if (sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg.includes("Multi Asset")) {
                          var caseRecord = component.get("v.caseRecord");
                           if(wrapper.reqInfo==="" && caseRecord && caseRecord.Is_Multiple_Asset__c && caseRecord.Show_Multiple_Asset_Cases__c ){
                              component.set('v.showOnRelatedMultiAssetCase',true);
                          }
						  if(wrapper.CaseSubType == "Bale(s)"){
                               component.set('v.showMultipleCaseLabel', false);
                              }
						  
                      }
                      else if (sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg.includes("Complete the intake of related cases(if any) from the parent case")) {
                          var caseRecord = component.get("v.caseRecord");
                          if(caseRecord.Status ==='New'){                             
                              if(wrapper.reqInfo === "" && caseRecord && caseRecord.Location__c && caseRecord.AssetId && caseRecord.Service_Date__c  && caseRecord.Case_Sub_Type__c){
                                  component.set('v.showMultipleCaseLabel', true);
                                  component.set('v.showOnRelatedMultiAssetCase',true);
                                 }
								if(wrapper.CaseSubType == "Bale(s)"){
                               component.set('v.showMultipleCaseLabel', false);
                              }
                          }
                      }
                          else if (sMsg != "undefined" && sMsg != null && sMsg != "" && (sMsg.includes("Workorder has been initiated. Please complete any open tasks if created.") || sMsg.includes("* Workorder has been Created\n"))) {
                              component.set("v.displaySummary", false);
                          } else if (sMsg != "undefined" && sMsg != null && sMsg != "" && (sMsg.includes("* Workorder has been created. Please check Related Cases tab to complete intake") || sMsg.includes("* Workorder has been initiated. Please check Related Cases tab to complete intake"))) {
                            component.set("v.displaySummary", false);
                          } else if (sMsg != "undefined" && sMsg != null && sMsg.includes("Complete the intake of related cases(if any) from the above list")) {
                               component.set("v.displaySummary", false);
                          } else if (sMsg != "undefined" && sMsg != null && sMsg.includes("Create multiple cases for selected assets")) {
                            component.set("v.displaySummary", false);
                              
                          } else if (sMsg != "undefined" && sMsg != null && sMsg.includes("Select Case Subtype to Progress Case ")) {                             
                              component.set("v.displaySummary", false); 
                          }
                              else if (sMsg != "undefined" && sMsg != null && sMsg != "" && sMsg == "Progress Case") {                                   
                                  component.set('v.showMultipleCaseLabel', false);
                                  component.set("v.displaySummary", false);
                              }
                                  else if (sMsg != "undefined" && sMsg != null && sMsg != "") {                                      
                                      component.set("v.displaySummary", false);
                                  } else {                                       
                                      component.set("v.displaySummary", false);
                                  }
                      if (wrapper.reqInfo != "undefined" && wrapper.reqInfo != null && wrapper.reqInfo != "" && (wrapper.caseInfo ==='' || wrapper.caseInfo ==='Ready' || wrapper.caseInfo ==='Multi Asset')) {
                          component.set("v.displaySummary", false);                         
                      } 
                      if(wrapper.CaseType !='Pickup'){                         
                        component.set('v.showMultipleCaseLabel', false);   
                    }
                  }
              }
          }
          });
        $A.enqueueAction(action);
    },
    
    SetWMCapacityVisibility:function(component,helper){
          var cId = component.get("v.recordId");
          var action = component.get('c.IsWMCapacityPlannerVisible');
           action.setParams({
            "caseRecId": cId
        });
         
        action.setCallback(this, function (response) {  
            var state = response.getState();
            if (state == "SUCCESS"){
                var isCapacityVisible=response.getReturnValue();
                if(isCapacityVisible){                 
                    component.set("v.isOpenWMCapacityComp", true);    
                    component.set("v.isOpenSetCaseDateComp", false);                    
                }else{
                    component.set("v.isOpenWMCapacityComp", false);    
                    component.set("v.isOpenSetCaseDateComp", true);
                }
             }            
         });
        $A.enqueueAction(action);        
    },
    
})