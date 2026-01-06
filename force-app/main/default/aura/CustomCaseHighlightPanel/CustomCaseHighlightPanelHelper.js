({
    getCaseDetails : function(component) {
        var caseId = component.get("v.recordId");
        var action = component.get('c.getCaseHighlightDetails');
        action.setParams({"caseId" : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var wrapper = response.getReturnValue();
                if(wrapper){
		    component.set('v.isReqInfoEmpty',wrapper.isReqInfoEmpty);
		    console.log('BRRules wrapper : ' + wrapper.businessRuleId );
                    console.log('ReqInfoRules wrapper : ' + wrapper.requiredInfo );
                    if(wrapper.myCase.PurchaseOrder_Number__c == "undefined" || wrapper.myCase.PurchaseOrder_Number__c == null || wrapper.myCase.PurchaseOrder_Number__c == ""){
                        component.set('v.poValue','-');
                    }else{
                        component.set('v.poValue',wrapper.myCase.PurchaseOrder_Number__c);
                    }
                    if(wrapper.myCase.Chargeable__c == "undefined" || wrapper.myCase.Chargeable__c == null || wrapper.myCase.Chargeable__c == ""){
                        component.set('v.chargeableValue','-');
                    }else{
                        component.set('v.chargeableValue',wrapper.myCase.Chargeable__c);
                    }
                    if(wrapper.myCase.PSI__c == "undefined" || wrapper.myCase.PSI__c == null || wrapper.myCase.PSI__c == ""){
                        component.set('v.psiValue','-');
                    }else{
                        component.set('v.psiValue',wrapper.myCase.PSI__c);
                    }
                    if(wrapper.myCase.Company_Category__c == "undefined" || wrapper.myCase.Company_Category__c == null || wrapper.myCase.Company_Category__c == ""){
                        component.set('v.ccValue','-');
                    }else{
                        component.set('v.ccValue',wrapper.myCase.Company_Category__c);
                    }
                    component.set('v.CaseDetails',wrapper.myCase);
                    if(wrapper.reqInfo != "undefined" && wrapper.reqInfo != null && wrapper.reqInfo != ""){
                        component.set('v.isReqInfo',true);
                    }else{
                        component.set('v.isReqInfo',false);
                    }
					
					  if(wrapper.myCase.Case_Type__c == 'Pickup' && wrapper.myCase.Case_Sub_Type__c == 'Haul Away - No Equipment' && wrapper.myCase.Chargeable__c == null){
                       component.set('v.isReqInfo',true);
                    }else
                    {
                      
                    }
                    //Changes for SDT 39047-  Gunjan
                    if(wrapper.allowProgressCase==false){
                       component.set('v.isReqInfo',true);
                    }
					
                    component.set('v.isOpenTask',wrapper.isOpenTask);
                    if(wrapper.myCase.Status != 'New'){
                        component.set('v.isNew',false);
                    }
                    if(wrapper.myCase.Case_Record_Type__c == 'New Service Case'){
                        if(wrapper.CPQUser == true){
                            component.set('v.isCPQ',true);
                        }
                        component.set('v.isNewService',true);
                        if((wrapper.businessRuleId !="undefined" && wrapper.myCase.Business_RuleId__c!=wrapper.businessRuleId ) 
                           || (wrapper.requiredInfo !="undefined" && wrapper.myCase.Required_Information__c!=wrapper.requiredInfo)){
                            this.updateBRonCase(component,wrapper.businessRuleId,wrapper.requiredInfo);    
                        }
                    }  

                    if(wrapper.myCase.Case_Record_Type__c == 'Standard Case'){
                        if((wrapper.myCase.Case_Type__c == 'Activate' && wrapper.myCase.Case_Sub_Type__c == 'New Vendor')
                            || (wrapper.myCase.Case_Type__c == 'Modify' && wrapper.myCase.Case_Sub_Type__c == 'Vendor Record')
                            || (wrapper.myCase.Case_Type__c == 'Deactivate' && wrapper.myCase.Case_Sub_Type__c == 'Deactivate Vendor')) {
                                component.set('v.isVendor',true);
                                component.set('v.isLocation',false);
                                component.set('v.isClient',false);
                        } else {
                                component.set('v.isVendor',false);
                        }

                        if((wrapper.myCase.Case_Type__c == 'Activate' && wrapper.myCase.Case_Sub_Type__c == 'New Client')
                            || (wrapper.myCase.Case_Type__c == 'Modify' && wrapper.myCase.Case_Sub_Type__c == 'Client Record')
                            || (wrapper.myCase.Case_Type__c == 'Deactivate' && wrapper.myCase.Case_Sub_Type__c == 'Deactivate Client')) {
                                component.set('v.isClient',true);
                                component.set('v.isVendor',false);
                                component.set('v.isLocation',false);
                        } else {
                                component.set('v.isClient',false);
                        }  

                    }  
                                                       
                    if(!component.get('v.isVendor') && !component.get('v.isClient')){
                        component.set('v.isLocation',true);
                    }
                    
                    if((wrapper.myCase.AssetId == "undefined" || wrapper.myCase.AssetId == null || wrapper.myCase.AssetId == "") && wrapper.isAssetMandatory){
                     // commented last codition in if to make asset mandetory for all record types except 'New Service Case'
                    //if((wrapper.myCase.AssetId == "undefined" || wrapper.myCase.AssetId == null || wrapper.myCase.AssetId == "") && wrapper.myCase.Case_Record_Type__c != 'New Service Case'){
                        component.set('v.isAssetReq',false);
                        // Started SDT-31000
                        if(wrapper.myCase.Case_Record_Type__c == 'Pickup Case' && wrapper.myCase.Case_Type__c == 'Pickup' 
                           && (wrapper.myCase.Case_Sub_Type__c == 'Bulk' || wrapper.myCase.Case_Sub_Type__c == 'Haul Away - No Equipment')
                           && (wrapper.myCase.Client__c != "undefined" && wrapper.myCase.Client__c != null) 
                           && (wrapper.myCase.Location__c != "undefined" && wrapper.myCase.Location__c != null)
                          ){
                            //component.set("v.isModalNTERule",true);
                           // console.log('isModalOpenNTERules ' + component.get("v.isModalNTERule"));
                           // console.log('lwc Comp :: ' + component.find('lWCChild'));
                        	component.find('lWCChild').showBusinessRules(wrapper.myCase.Client__c,wrapper.myCase.Location__c, 
                                                                         wrapper.myCase.Case_Record_Type__c,wrapper.myCase.Case_Type__c,
                                                                         wrapper.myCase.Case_Sub_Type__c,'Reason');
                            
                        }
                        // Ended SDT-31000
                    }else{
                        component.set('v.isAssetReq',true);
                    }
                    if(!$A.util.isUndefinedOrNull(wrapper.IsPOProfileDisable)){
                        component.set('v.IsPOProfileDisable',wrapper.IsPOProfileDisable);                        
                    }
                    if(wrapper.myCase.Tracking_Number__c == null || wrapper.myCase.Tracking_Number__c == "" || wrapper.myCase.Status == "Closed" || component.get("v.queueName") != '')
                    {
                        var myQueue = component.find("queue");
                        $A.util.removeClass(myQueue, "actionColor");
						$A.util.addClass(myQueue, "queueDisabled");
                    }
                    else
                    {
                        var myQueue = component.find("queue");
                        $A.util.removeClass(myQueue, "queueDisabled");
                        $A.util.addClass(myQueue, "actionColor");
                    }
                   
                }
            }
        });
        $A.enqueueAction(action);
    },
    hovercall : function(component,objecttype,targetId) {
        $A.createComponent(
            "c:HoverOverCards",
            {
                "objecttype" : objecttype, 
                "CaseDetails": component.get('v.CaseDetails')
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find(targetId);
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    },
    sleep:function(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    },
    isCapacityEligible: function(component){
        var caseId = component.get("v.recordId");
        var action = component.get('c.getCapacityEligibilty');
        action.setParams({"caseId" : caseId});
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
    queueCheck: function(component){
        var caseId = component.get("v.recordId");
        var action = component.get('c.getQueueName');
        action.setParams({"caseId" : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var Queue= response.getReturnValue();
                component.set("v.queueName",Queue);
                
    		}
        });
        $A.enqueueAction(action);
    },

    updateBRonCase: function(component,bRule,reqInfo){
        var isNewService = component.get("v.isNewService");
        if(isNewService){
            console.log('updating Case Record');
        	var caseId = component.get("v.recordId");
            var action = component.get('c.updateBRonCase');
        	action.setParams({"caseId" : caseId,"brId":bRule,"reqInfo":reqInfo});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log('return type : ' + response.getReturnValue());
                }
            });
            $A.enqueueAction(action); 
        }
    },	
	
})