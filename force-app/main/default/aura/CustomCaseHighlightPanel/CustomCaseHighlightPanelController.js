({
    doInit : function(component, event, helper) {          
        //get case highlight panel data
        component.set("v.isNewService",false);
        component.set("v.isCPQ",false);
		//helper.queueCheck(component);
        helper.getCaseDetails(component);
        helper.isCapacityEligible(component);
    },    
    handleClick : function(component, event, helper) {
        var recordId = event.currentTarget.dataset.value;
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        sObectEvent.fire();
    },
    handleReceiveMessage : function(component, event, helper){
        if (event != null) {
            const caseId = event.getParam('caseId');
            const parentId = event.getParam('parentId');
            const isCapacityEligible = event.getParam('isCapacityEligible');
             console.log('caseId');
            console.log(caseId);
            console.log('component.get("v.recordId")');
             console.log(component.get("v.recordId"));
            if(component.get("v.recordId") === parentId ){
                component.set("v.isModalOpenServiceDate", true);
                $A.createComponent(
                    "c:ServiceDateContainer",
                    {
                        "recordId" : caseId, 
                        "showForm": true,
                        "parentId": component.get("v.recordId"),
                        "isCapacityEligible": isCapacityEligible,
                    },
                    function(msgBox){                
                        if (component.isValid()) {
                            var targetCmp = component.find('SLADateComp');
                            if(targetCmp){
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body);
                            }
                        }
                    }
                );
            }
        }
    },
    recordUpdated : function(component, event, helper){
        var cId = component.get("v.recordId");
        var changeType = event.getParams().changeType;
        if(changeType == "CHANGED" || changeType == "LOADED" || changeType == "REMOVED"){ 
            helper.getCaseDetails(component, event, helper);
            helper.isCapacityEligible(component);
			//helper.queueCheck(component);
        }
        
    },
    onTabFocused : function(component, event, helper){
        var LDSPanel=component.find("recordLoaderHightLightpPanel");
        var workspaceAPI = component.find("workspace");
        var currentTab = event.getParam("currentTabId");
        if(workspaceAPI && currentTab){
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                if(LDSPanel && response.focused && response.url.includes('lightning/r/Case/')){
                    window.setTimeout(function() {
                        LDSPanel.reloadRecord(true);
                        $A.get('e.force:refreshView').fire();
                    }, 1500);
                }
            });
        }
    },
    
    openModelLoc: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenLoc", true);
        component.set("v.isModalOpen", true);
    },
     openModelVendor: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenLoc", true);
        component.set("v.isModalOpen", true);
    },
    openModelContact: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenContact", true);
        component.set("v.isModalOpen", true);
    },
    openModelClose: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        component.set("v.isModalOpenClose", true)
    },
    openModelRecordType: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        component.set("v.isModalOpenRecord", true)
    },
    openCloseCasePop: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        component.set("v.isModalOpenForCloseCasePop", true)
    },
    openModelAsset: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        component.set("v.isModalOpenAsset", true)
    },
    openModelRelatedCases: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        component.set("v.isModelOpenRelatedCases", true)
    },
    openModelCaseType: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
        component.set("v.isModelOpenCaseType", true)
    },
    openModelServiceDate: function(component, event, helper) {
        component.set("v.isModalOpenServiceDate", true);
        $A.createComponent(
            "c:ServiceDateContainer",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true,
                "isCapacityEligible": component.get("v.isCapacityEligible"),
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('SLADateComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    },
    openModelCaseType: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModelOpenCaseType", true)
        $A.createComponent(
            "c:FillCaseSubType",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('CaseTypeComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    },
    openModelCustomerInfo: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModelOpenCustomerInfo", true)
        $A.createComponent(
            "c:SetCaseCustomerInfo",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('CustomerInfoComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body); 
                    }
                }
            }
        );
    },
    openCloseCasePop: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenForCloseCasePop", true)
        $A.createComponent(
            "c:CloseCasePop",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('CloseCaseComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    },
    openModelContact: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenContact", true);
        component.set("v.showForm", true);
       
      //  component.set("v.isModalOpen", true);
       /* $A.createComponent(
            "c:SearchExistingContact",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ContactComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        ); */
    },
    
    openModelLoc: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenLoc", true)
        $A.createComponent(
            "c:LocationContainer",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('LocationComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    },
      openModelVendor: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenLoc", true)
        $A.createComponent(
            "c:VendorContainer",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('LocationComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    }, 

    openModelClient: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpenLoc", true)
        $A.createComponent(
            "c:ClientContainer",
            {
                "recordId" : component.get("v.recordId"), 
                "showForm": true
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('LocationComp');
                    if(targetCmp){
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body);
                    }
                }
            }
        );
    }, 
    
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.isModalOpenLoc", false);
        component.set("v.isModalOpenContact", false);
        component.set("v.isModalOpenClose", false);
        component.set("v.isModalOpenRecord", false);
        component.set("v.isModalServiceDate", false);
        component.set("v.isModalOpenForCloseCasePop", false);
        component.set("v.isModalOpenAsset", false);
        component.set("v.isModelOpenCaseType", false);
        component.set("v.isModelOpenRelatedCases", false);
        component.set("v.isModelOpenCustomerInfo", false)
        component.set("v.isModalOpenServiceDate",false);
    },
    assetenter: function(component, event, helper) {
        var timer = setTimeout(function(){
            var isHover = component.get('v.assethovercard');
            if(!isHover){
                component.set("v.assethover",true);
                component.set("v.assethovercard",true);
                helper.hovercall(component,'Asset','assetComp');
            } 
        },$A.get("$Label.c.HoverDelay"));
        component.set("v.timer",timer);
    },
    assetMouseHover: function(component, event, helper) {
        component.set("v.assethovercard",false);
    },
    assetout: function(component, event, helper) {
        var timer = component.get('v.timer');
        clearTimeout(timer);
        helper.sleep($A.get("$Label.c.SleepDelay")).then(() => { 
            var isHover = component.get('v.assethovercard');
            if(isHover){
            component.set("v.assethover",false);
            component.set('v.assethovercard',false);
        }
                                                         });
    },
    assetMouseHoverOut: function(component, event, helper) {
        component.set("v.assethovercard",false);
        component.set("v.assethover",false);
    },
    locationenter: function(component, event, helper) {
        var timer = setTimeout(function(){
            var isHover = component.get('v.locationhovercard');
            if(!isHover){
                component.set("v.locationhover",true);
                component.set("v.locationhovercard",true);
                helper.hovercall(component,'Location','locationComp');
            } 
        },$A.get("$Label.c.HoverDelay"));
        component.set("v.timer",timer);
    },
    locationMouseHover: function(component, event, helper) {
        component.set("v.locationhovercard",false);
    },
    locationout: function(component, event, helper) {
        var timer = component.get('v.timer');
        clearTimeout(timer);
        helper.sleep($A.get("$Label.c.SleepDelay")).then(() => { 
            var isHover = component.get('v.locationhovercard');
            if(isHover){
            component.set("v.locationhover",false);
            component.set('v.locationhovercard',false);
        }
                                                         });
    },
    locationMouseHoverOut: function(component, event, helper) {
        component.set("v.locationhovercard",false);
        component.set("v.locationhover",false);
    },
    contactenter: function(component, event, helper) { 
        var timer = setTimeout(function(){
            var isHover = component.get('v.contacthovercard');
            if(!isHover){
                component.set("v.contacthover",true);
                component.set("v.contacthovercard",true);
                helper.hovercall(component,'Contact','contactComp');
            } 
        },$A.get("$Label.c.HoverDelay"));
        component.set("v.timer",timer);
    },
    contactMouseHover: function(component, event, helper) {
        component.set("v.contacthovercard",false);
    },
    contactout: function(component, event, helper) {
        var timer = component.get('v.timer');
        clearTimeout(timer);
        helper.sleep($A.get("$Label.c.SleepDelay")).then(() => { 
            var isHover = component.get('v.contacthovercard');
            if(isHover){
            component.set("v.contacthover",false);
            component.set('v.contacthovercard',false);
        }
                                                         });
    },
    contactMouseHoverOut: function(component, event, helper) {
        component.set("v.contacthovercard",false);
        component.set("v.contacthover",false);
    },
    
    navigate : function(component, event, helper) {       
        component.set("v.isModalOpen", false);
        component.set("v.isModalOpenAsset", false);
        component.set("v.isModalOpenRecord", false); 
        component.set("v.isNewService",false);
        component.set("v.isCPQ",false);
        component.set("v.isModalOpenLoc",false);
        component.set("v.isModalOpenContact",false);
        component.set("v.isModalOpenServiceDate",false);
        component.set("v.isModelOpenCaseType",false);
        component.set("v.isModelOpenCustomerInfo",false);
        component.set("v.isModalOpenForCloseCasePop",false);
        component.find("recordLoaderHightLightpPanel").reloadRecord(true);
    },
    handleApplicationEvent : function(component, event, helper) {
        var assetList = event.getParam("multiAssetIds");
        var caseId = event.getParam("caseId");
        if(component.get("v.recordId")===caseId){
            component.set("v.selectedAssets",assetList);
        }
        
    },
    showQueue : function(component, event, helper) {
        var trackingNumber = component.get("v.CaseDetails.Tracking_Number__c");
        var action = component.get('c.getQueueName');
        action.setParams({"trackingNumber" : trackingNumber});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var myQueue = component.find("queue");
                $A.util.removeClass(myQueue, "actionColor");
				$A.util.addClass(myQueue, "queueDisabled");
                var Queue= response.getReturnValue();
                if(Queue.includes("Error:"))
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": Queue,
                        "type" : "Error"
                    });
                    toastEvent.fire();
                }
                else
                {
                    component.set("v.queueName",Queue);
                } 
    		}
        });
        $A.enqueueAction(action);
    },
  
    
})