({
    doinit : function(cmp, event, helper) {
        let extraParams = cmp.get("v.extraParams");
        if(extraParams != undefined && extraParams != null){
            if(extraParams.hasOwnProperty("placementInstructions") && extraParams.placementInstructions !=null && extraParams.placementInstructions !='' ){
                cmp.set("v.placementInstructions", extraParams.placementInstructions);
            }
            if(extraParams.hasOwnProperty("onsiteContact") && extraParams.onsiteContact !=null && extraParams.onsiteContact !='' ){
                cmp.set("v.onsiteContact", extraParams.onsiteContact);
            }
            if(extraParams.hasOwnProperty("onsitePhone") && extraParams.onsitePhone !=null && extraParams.onsitePhone !='' ){
                cmp.set("v.onsitePhone", extraParams.onsitePhone);
            }
            if(extraParams.hasOwnProperty("onsitePhoneExt") && extraParams.onsitePhoneExt !=null && extraParams.onsitePhoneExt !='' ){
                cmp.set("v.onsitePhoneExt", extraParams.onsitePhoneExt);
            }
            if(extraParams.hasOwnProperty("customerPO") && extraParams.customerPO !=null && extraParams.customerPO !='' ){
                cmp.set("v.customerPO", extraParams.customerPO);
            }
        }
        //SDT-30864
        helper.getDeliveryOverrideReasons(cmp);
        //-- SDT-27107 - Added
        const targetProductVar = cmp.get("v.targetProduct"); 
        cmp.set("v.slaCommentsExists",false);
        if(targetProductVar.hasOwnProperty('slaOverrideReason')){
            const slaOverrideReason = targetProductVar.slaOverrideReason;
            if (slaOverrideReason){
                cmp.set("v.slaCommentsExists",true);
            }
        }
        //---SDT-29507 start
        if (targetProductVar.duration == 'Permanent') {
                cmp.set('v.endDisabled', true);
            }
        //---SDT-29507 end
        //-- SDT-27107 - End
        var isAsset = cmp.get('v.isAssetAvailable');
        if(!isAsset)
        {
            if (targetProductVar.duration == 'Permanent') {
                cmp.set('v.endDisabled', true);
            }
        }
        else{
            // Changes for SDT-28572
            cmp.set('v.assetStartDate', targetProductVar.startDate);
        }
        //Get initial BR for the required information, scoped to New Service
        var recordId = cmp.get('v.recordId');
        var targetProductId = cmp.get('v.targetProductId');
        var orderWrapper = cmp.get('c.generateOrderWrapper');
        var getQuote = cmp.get('c.getQuoteStatusDetails');
        var getQuoteLine = cmp.get('c.getQuoteLineForOrdersWrapper');
        getQuote.setParams({
            quoteId: recordId
        });
        getQuoteLine.setParams({
            qlid: targetProductId
        });
        orderWrapper.setCallback(this, function(response) {
            cmp.set('v.orderWrapper', response.getReturnValue());            
            getQuote.setCallback(this, function(response) {
                var contactState = response.getState();
                if (contactState === 'SUCCESS' ) {
                    var returnedQuote = response.getReturnValue();
                    if(cmp.get('v.onsiteContact') == null || cmp.get('v.onsiteContact') == undefined || cmp.get('v.onsiteContact') == ''){
                        cmp.set('v.onsiteContact', returnedQuote.SBQQ__PrimaryContact__r.Name);    
                    }
                    if(cmp.get('v.onsitePhone') == null || cmp.get('v.onsitePhone') == undefined || cmp.get('v.onsitePhone') == ''){
                        cmp.set('v.onsitePhone', returnedQuote.SBQQ__PrimaryContact__r.Phone);    
                    }

                    //SDT-42651
                    if(cmp.get('v.vendorServiceId') == null || cmp.get('v.vendorServiceId') == undefined || cmp.get('v.vendorServiceId') == ''){
                        cmp.set('v.vendorServiceId', returnedQuote.SBQQ__Opportunity2__r.Case__r.Vendor_Service_Id__c);    
                    }
                    
                    //SDT-41538
                     
                    if(cmp.get('v.chargeAbility') == null || cmp.get('v.chargeAbility') == undefined || cmp.get('v.chargeAbility') == ''){
                        cmp.set('v.chargeAbility', returnedQuote.SBQQ__Opportunity2__r.Case__r.Chargeable__c);    
                    }
                    
                    //pkulkarn-TCS-SDT-41184-Added following code
                    if(returnedQuote.SBQQ__Type__c != 'Quote')
                    {
                        if(returnedQuote.SBQQ__Type__c == 'Amendment')
                        {
                            cmp.set('v.endDisabled', true);
                        }
                        else
                        {
                            cmp.set('v.endDisabled', false);
                        }
                    }
                    //pkulkarn-TCS-SDT-38283-End
                        
                    cmp.set('v.currentQuote',returnedQuote);
                    getQuoteLine.setCallback(this, function(response) {
                        var qlState = response.getState();
                        if (qlState === 'SUCCESS') {
                            var resp = response.getReturnValue();
                            console.log('resp==>'+JSON.stringify(resp));
                            cmp.set('v.currentQuoteLine', resp.cQLine);
                            console.log("cQLine==>"+JSON.stringify(resp.cQLine));
                            //SDT-27107 Start 
                            var ParentQL=cmp.get('v.currentQuoteLine');
                            var getSLADate = cmp.get('c.callDetermineSLA');
                            getSLADate.setParams({
                                parentQuoteLineId: ParentQL.Id
                            });
                            getSLADate.setCallback(this, function(response) {
                                var slaDate = response.getReturnValue();
                                    //SDT-30963 :condition added to avoid override of SLA date in case updates from alternate container
                                    if(!targetProductVar.alternateContainerFlag){
                                        cmp.set('v.targetProduct.startDate', slaDate);
                                        //SDT-41473-41542
                                        var isHaulAway = cmp.get('v.targetProduct.isHaulAway');
                                        console.log('isHaulAway'+isHaulAway);
                                        if(isHaulAway){
                                        var endDate = helper.addDaysToDate(slaDate+'T00:00:00',7);
                                        cmp.set('v.targetProduct.endDate', endDate);
                                        console.log('###! endDate'+endDate);
                                        }
                                        

                                    }
                                    cmp.set('v.slaDate', slaDate);
                            });
                            $A.enqueueAction(getSLADate);
                            //SDT-27107 End
                            helper.prepopulateQLine(cmp,resp.cQLine, resp.serviceStartTime, resp.serviceEndTime);
                            //Changes for SDT-26541
                            cmp.set('v.hasDelivery',resp.hasDelivery);                            
                        }
                    });
                    $A.enqueueAction(getQuoteLine);
                    
                    //SDT-27107 Start -PavanK
                    var getPicklists = cmp.get('c.getSLAOverrideReasons');
                    getPicklists.setCallback(this, function(response) {
                        var slaReasons = response.getReturnValue();
                        cmp.set('v.slaReasons', slaReasons);
                    });
                    $A.enqueueAction(getPicklists);
                    //SDT-27107 End 
                    
                }
            });
            $A.enqueueAction(getQuote);
        });
        $A.enqueueAction(orderWrapper);
    },
    saveValues : function(cmp, event, helper){
        //SDT-27107 Start -PavanK
        var validationError = false;
        var errorMessage = '';
        var currentProduct = cmp.get('v.targetProduct');
        var slaDate = cmp.get('v.slaDate');
        
        //SDT-30864 :Asset Availability
        if(cmp.get("v.aavDeliveryOverrideFlag")){
            if(!currentProduct.deliveryOverrideReason){
                validationError = true;
                errorMessage = errorMessage + 'Override Reason must be provided. \n';
            }
            if(currentProduct.deliveryOverrideReason.toLowerCase() == 'other' 
                    && !currentProduct.deliveryOverrideComment){
                validationError = true;
                errorMessage = errorMessage + 'Override Comment must be provided. \n';
            }
        }

        if (currentProduct.startDate == null) {
            validationError = true;
            errorMessage = errorMessage + 'The start date cannot be null. \n'
        }
        if (currentProduct.startDate > currentProduct.endDate) {
            validationError = true;
            errorMessage = errorMessage + 'The end date cannot occur before the start date. \n'
        }
        if (slaDate > currentProduct.startDate && (currentProduct.slaOverrideReason==null || currentProduct.slaOverrideReason=='')) {
            validationError = true;
            errorMessage = errorMessage + 'An SLA Override Reason must be provided. \n'
        }
        if (slaDate > currentProduct.startDate && (currentProduct.slaOverrideComment==null  || currentProduct.slaOverrideComment=='')) {
            validationError = true;
            errorMessage = errorMessage + 'When overriding sla date, SLA Override comment must be provided. \n'
        }
         // Changes for SDT-28572
         var isAsset = cmp.get('v.isAssetAvailable');
         if(isAsset)
         {
             var assetStartDate = cmp.get('v.assetStartDate');
             var today = new Date();
             today = $A.localizationService.formatDate(today ,"YYYY-MM-DD");
             var isLessthanCurrentDate = false;

             if(assetStartDate > today)
                isLessthanCurrentDate = true;
             if (currentProduct.startDate <= assetStartDate && currentProduct.startDate < today) {
                 validationError = true;
                 if(isLessthanCurrentDate)
                    errorMessage = errorMessage + 'Start Date cannot occur before current date. \n'
                 else
                    errorMessage = errorMessage + 'Start Date cannot occur before Asset start date. \n'
             }
         }

        if (validationError) {
            cmp.find("Id_spinner").set("v.class", 'slds-hide');
            var warningToast = $A.get('e.force:showToast');
            warningToast.setParams({
                'title': 'Review Errors Below',
                'message': errorMessage,
                'type': 'warning'
            });
            warningToast.fire();
            return;
        }
        //SDT-27107 End -PavanK
        
        const  EMPTY_STRING = '';
        const GATE_CODE = 'gateCode';
        const START_TIME = 'startTime';
        const CERTIFICATE_VALUE = 'certificateValue';
        const PLACEMENT_INSTRUCTIONS = 'placementInstructions';
        const SERVICE_DESCRIPTION = 'serviceDescription';
        const SERVICE_INSTRUCTIONS = 'serviceInstructions';
        const CONTACT = 'contact';
        const PHONE = 'phone';
        const VENDORSERVICEID = 'vendorServiceId'; //SDT-41473 -41966
        const CHARGEABILITY = 'chargeAbility'; //SDT-41538

        
        var allValid = cmp.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;}, true);
        
        if(allValid === false)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                
                
                "message": $A.get("$Label.c.Error_Message_for_Quote"),
                "type": "Error"
            });
            toastEvent.fire();
            
        }
        else{
            cmp.find("Id_spinner").set("v.class", 'slds-show');
            var qo = cmp.get('v.orderWrapper');
            var targetProduct = cmp.get('v.targetProduct');
            var targetProductId = cmp.get('v.targetProductId');
            var currQ = cmp.get('v.currentQuote'); 
            var currQL = cmp.get('v.currentQuoteLine');
            
            var updateQ = cmp.get('c.updateQuoteForOrders');
            //var updateQL = cmp.get('c.updateQuoteLineForOrders');
            
            //Build Order Wrapper
            qo.parentQuoteLine = targetProductId;
            
            
            //qo.serviceDate = targetProduct.startDate;
            qo.serviceDate = currentProduct.startDate;
            qo.serviceEndDate = currentProduct.endDate;
            qo.serviceType = 'Delivery';
            qo.quantity = targetProduct.quantity;
            qo.onsiteContact = cmp.get('v.onsiteContact');
            //SDT-41473 - 41625 - 41966
            qo.vendorServiceId = cmp.get('v.vendorServiceId');

            qo.onsitePhone = (cmp.get('v.onsitePhoneExt') == '') ? cmp.get('v.onsitePhone') : cmp.get('v.onsitePhone') + ', ' + cmp.get('v.onsitePhoneExt');
            //SDT-22014 Changes 
            //Build service instructions
            currQL.Service_Start_Time__c = cmp.get('v.startTime');
            currQL.Service_End_Time__c = cmp.get('v.endTime');
            let instructionMap1 = helper.prepareInstructionMap(qo, CONTACT, PHONE, cmp, EMPTY_STRING, GATE_CODE, START_TIME, CERTIFICATE_VALUE, PLACEMENT_INSTRUCTIONS, SERVICE_DESCRIPTION, SERVICE_INSTRUCTIONS,VENDORSERVICEID,CHARGEABILITY, currQL.Service_Start_Time__c,currQL.Service_End_Time__c );
            //Build service acorn instructions 
            helper.createInstructions(instructionMap1, qo, EMPTY_STRING, CONTACT, PHONE);
            //qo.instructions = serviceInstructions;
            console.log('qo.instructions>>>'+qo.instructions);  
            //qo.acornInstructions = serviceAcornInstructions;
            console.log('qo.acornInstructions>>>'+qo.acornInstructions);
            var custPO = cmp.get('v.customerPO');
            if(custPO!='undefined' && custPO !=null && custPO !=''){
                qo.PONumber = custPO;
            }            console.log (targetProduct)
            console.log ('targetProduct.duration' +targetProduct.duration); 
            console.log ('targetProduct>>>' +targetProduct); 
            if(targetProduct.duration ==  'Permanent'){
                qo.duration = 'PERM';
            }
            if(targetProduct.duration ==  'Temporary'){
                qo.duration = 'TEMP';
            }
            //qo.duration = targetProduct.duration;
            //qo.Duration__c = getQuoteLine.Duration__c;
            //console.log ('getQuoteLine.Duration__c--->' + getQuoteLine.Duration__c)
            qo.quoteId = currQ.Id;
            cmp.set('v.orderWraper', qo);
            //End Building Order Wrapper
            
            //Build Quote
            currQ.Project_Services_Request__c = cmp.get('v.projectServices');
            currQ.Project__c = cmp.get('v.selectedProject');
            
            //Added Quote_SLA_Date__c update for SDT-30514
            currQL.Quote_SLA_Date__c = currentProduct.startDate; 
            //pkulkarn-TCS-7-Aug-23-Added Vendor_Commit_Date__c update for SDT-31408
            currQL.Vendor_Commit_Date__c = currentProduct.startDate;
            
            //Build Quote Line
            currQL.Onsite_Contact_Name__c = cmp.get('v.onsiteContact');
            currQL.Onsite_Contact_Number__c = cmp.get('v.onsitePhone');
            //SDT-41473 - 41625 - 41966
            currQL.Vendor_Service_Id__c = cmp.get('v.vendorServiceId');

            currQL.Onsite_Contac_Number_Extension__c = cmp.get('v.onsitePhoneExt');
            var certificateType = cmp.get('v.certificateValue');
            if(typeof certificateType !== 'undefined' && certificateType == 'Destruction'){
                currQL.Certificate_of_Destruction__c = true;
                currQL.Certificate_of_Disposal__c = false; 
            }
            if(typeof certificateType !== 'undefined' && certificateType == 'Disposal'){
                currQL.Certificate_of_Disposal__c = true; 
                currQL.Certificate_of_Destruction__c = false;
            }
            currQL.Profile_Number__c = cmp.get('v.profileNumber');
            var landFillTicket = cmp.get('v.landfillTickets');
            if(typeof landFillTicket !== 'undefined' && landFillTicket == true){
                currQL.Landfill_Tickets__c = true; 
            }
            
            currQL.Special_Disposal_Description__c = cmp.get('v.serviceDescription');
            
            currQL.Gate_Code__c = cmp.get('v.gateCode');
            currQL.Restriction_Details__c = cmp.get('v.serviceInstructions');

            // SDT-27107 - Added - PavanK
            currQL.SLA_Override_Reason__c = targetProduct.slaOverrideReason;
            currQL.SLA_Override_Comment__c = targetProduct.slaOverrideComment;
            // SDT - 27107 - End
            //SDT-29156 :start
            if (cmp.get("v.assetAvailabilityAccess")) {
                currQL.AAV_Delivery_Availability__c = cmp.find('aavCustomDatePicker').getDeliveryDateConditions();
                //SDT-30864 :START
                let overrideFlag = cmp.get("v.aavDeliveryOverrideFlag");
                currQL.AAV_Delivery_Override_Reason__c = overrideFlag ? targetProduct.deliveryOverrideReason : '';
                currQL.AAV_Delivery_Override_Comment__c = overrideFlag ? targetProduct.deliveryOverrideComment : '';
                currQL.AAV_Asset_Availability_API_Errors__c = cmp.get("v.msgAssetAPIErrorsBE");//SDT-31583
                //SDT-30864 :END
            }
            //SDT-29156 :end
            //currQL.SetupComment__c = cmp.get("v.serviceInstructions"); //this is to save the driver instructions for fututr purpose
            var createDelivery = cmp.get('c.createDelivery');
            // var updateQ = cmp.get('c.updateQuoteForOrders');
            var updateQL = cmp.get('c.updateQuoteLineForOrders');
            createDelivery.setParams({
                ow: qo, 
                orderType: 'Delivery',
                placementInstructions : cmp.get("v.placementInstructions")
            });
            updateQ.setParams({
                updatedQuote: currQ
            });
            updateQL.setParams({
                updatedQuoteLine: currQL
            });
            /*SDT-25328 Changes */
            updateQ.setCallback(this, function(response) {
                updateQL.setCallback(this, function(updateQLresponse) {
                    createDelivery.setCallback(this, function(responseCD) {
                        var state = responseCD.getState();                        
                        console.log('Create Delivery State: ' + state);
                        if (state === 'SUCCESS') {
                            
                            cmp.find("Id_spinner").set("v.class", 'slds-show');
                            var wrapper = responseCD.getReturnValue();
                            var updateState = cmp.getEvent('UpdateWrapperState');
                            console.log('Asset Change State - QR: ' + wrapper.isAssetChanged);
                            console.log('Response of Delivery creation is: ' + wrapper.result);
                            let extraParams = cmp.get("v.extraParams");
                            if(extraParams == null || extraParams == undefined){
                                extraParams = {};
                            }
                            extraParams.placementInstructions = cmp.get("v.placementInstructions");
                            extraParams.onsiteContact = cmp.get("v.onsiteContact");
                            extraParams.onsitePhone = cmp.get("v.onsitePhone");
                            extraParams.onsitePhoneExt = cmp.get("v.onsitePhoneExt");
                            extraParams.customerPO = cmp.get("v.customerPO");
                            extraParams.isAssetChanged = wrapper.isAssetChanged;
                            cmp.set("v.extraParams",extraParams);
                            
                            updateState.setParams({
                                "currentState": "Summary",
                                "currentProductId": targetProductId,
                                "targetProduct": targetProduct,
                                "extraParams" : cmp.get("v.extraParams")
                            });
                            updateState.fire();
                            var updateQLstate = updateQLresponse.getState();
                            if (updateQLstate === 'SUCCESS') {
                                cmp.find("Id_spinner").set("v.class", 'slds-hide');
                            }
                            
                        } else {
                            
                            //SDT-33378
                            let error = responseCD.getError();
                            if(error){
                                cmp.find("Id_spinner").set("v.class", 'slds-hide');
                                var warningToast = $A.get('e.force:showToast');
                                warningToast.setParams({
                                    'title': 'Review Errors Below',
                                    'message': error[0].message,
                                    'type': 'warning'
                                });
                                warningToast.fire();
                            }
                            
                            console.log('Returned error is: ' + JSON.stringify(responseCD.getError()));
                        }
                    });
                    $A.enqueueAction(createDelivery);
                    
                });
                $A.enqueueAction(updateQL);
                
            });
            $A.enqueueAction(updateQ);
        }
        
        
        
    },
    
    searchProjects : function(cmp, event, helper) {
        helper.getActiveProjects(cmp);
    },
    selectProject: function(cmp, event) {
        var selectedProject = event.getSource().get('v.value');
        cmp.set('v.selectedProject', selectedProject);
    },
    deSelectProject: function(cmp, event) {
        cmp.set('v.selectedProject', '');
    },
    goBack : function(cmp, event){
        cmp.find("Id_spinner").set("v.class", 'slds-show');
        var updateState = cmp.getEvent('UpdateWrapperState');
        var targetProductId = cmp.get('v.targetProductId');
        var targetProduct = cmp.get('v.targetProduct');
        var populateQLStartEndDate = cmp.get('c.removeStartAndEndDateOnRelatedQL');
        populateQLStartEndDate.setParams({
            parentQuoteLineId: targetProductId
        });
        populateQLStartEndDate.setCallback(this, function(response) {
            const state = response.getState();
            if(state === 'SUCCESS') {
                
                let resp = response.getReturnValue();
                    updateState.setParams({
                        "currentState": "Overview",
                        "currentProductId": targetProductId,
                        "targetProduct": targetProduct
                    });
                    updateState.fire();
            }else{
                    console.log('Fail');
                }
                cmp.find("Id_spinner").set("v.class", 'slds-hide');
        });
        $A.enqueueAction(populateQLStartEndDate);
    },
    //SDT-29101 : update new Start date for Asset Availability
    updateDeliveryInfo: function (component, event) {
        let newStartDate = event.getParam("date");
        if(newStartDate){
            component.set("v.targetProduct.startDate",newStartDate );
        }
        component.set("v.aavDeliveryOverrideFlag",event.getParam('deliveryOverrideFlag'));//SDT-30864 
        //SDT-31583 :START
        let errorMsgforUI = event.getParam('errorMsgforUI');
        if(errorMsgforUI && errorMsgforUI.length){
            component.set("v.classAssetAPIErrors",errorMsgforUI.length === 1 ?
                        'warning-text-single' : 'warning-text-list');
            component.set("v.msgAssetAPIErrors",errorMsgforUI);
            component.set("v.showAssetAPIError",true);
        }
        component.set("v.msgAssetAPIErrorsBE",event.getParam('errorMsgforBE'));
        //SDT-31583 :END

    },

    //SFT-41473-41625- 41542
    handleDateChange :function(component,event,helper){
        var isHaulAway = component.get('v.targetProduct.isHaulAway');
        console.log(isHaulAway);
        if(isHaulAway){
        var newStartValue = component.get("v.targetProduct.startDate");
        console.log('@@@ newStartValue'+event.getParam("value")+'type of'+typeof(newStartValue));
        console.log('newStartValue'+newStartValue+'type of'+typeof(newStartValue));
        if(newStartValue){
            console.log('inside if newStartValue'+newStartValue+'type of'+typeof(newStartValue));

            //SDT-41473
            var newEndDate = helper.addDaysToDate(newStartValue,7);
            console.log('the newenddate'+newEndDate);

            component.set("v.targetProduct.endDate",newEndDate);
        }
    }else{

    }
    },
    //SDT-30864 :Asset availability
    handledeliveryOverrideChange :function(cmp,event){
        let newValue = event.getSource().get("v.value")
        cmp.find('deliveryOverrideComment').set("v.required",(newValue.toLowerCase() == 'other'));
    }
})
