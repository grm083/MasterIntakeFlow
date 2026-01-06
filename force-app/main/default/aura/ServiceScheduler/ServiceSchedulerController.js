({
    doInit : function(component, event, helper) {          
        var currentProduct = component.get("v.currentProduct");
        console.log('service scheduler currentProduct==>'+JSON.stringify(currentProduct));
        const showSIDModal = component.get("v.showSIDModal");
        console.log('showSIDModal==>'+showSIDModal);
        const previousScreen = component.get("v.previousScreen");
        console.log('previousScreen==>'+previousScreen);
        component.set("v.showSpinner", true);
        var action = component.get("c.retrieveParentQuoteLine"); 
        console.log('Within the scheduler component, the parent Id is : ' + component.get("v.parentId"));
        action.setParams({ 
            parentQLineId : component.get("v.parentId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('resp==>'+JSON.stringify(resp));
                component.set("v.pqLine",resp);
                console.log('showSIDModal==>'+showSIDModal);
                if(showSIDModal == false){
                    console.log('line#20');
                    helper.prepopulateSchedular(component, resp);
                    //helper.checkServiceDay(component);//SDT-31295
                }
                component.set("v.showSpinner", false);
            }
            else if (state === "ERROR") {
              
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action); 
        //SDT-29100
        helper.getServiceOverrideReasons(component);
        //SDT-38285 - start To fetch picklist values
        helper.getMonthRelativePickList(component);
        //helper.getMonthRelativeInterval(component);
        //helper.getMonthRelative(component);
        //SDT-38285 - end
    },
    handleClick: function(component, event, helper){
        helper.changeBtnColors(component);
        event.getSource().set("v.variant","brand");
        //SDT-29100 :START
        let labelName = event.getSource().get("v.label");
        component.set("v.clickedBtnName", labelName);
        if(labelName !== 'Weekly'){
            component.set('v.showOverrideDetails',false);
            component.set('v.serviceCommentError',false);
        }
        //SDT-29100 :END
    },
    onBlur: function(component, event, helper){
        component.set(event.currentTarget.getAttribute('data-customAttr'),event.currentTarget.value);
    },
    onSelect: function(component, event, helper){
        console.log('In select');
        component.set(event.currentTarget.getAttribute('data-customAttr'),event.currentTarget.value);
    },
    validateParent : function(cmp, event, helper){
        //SDT-29100 :START : ADDED IF condition
        let overrideComment = cmp.get("v.currentProduct.serviceOverrideComment");
        let overrideReason = cmp.get("v.currentProduct.serviceOverrideReason");
        let validationCheck = (cmp.get("v.showOverrideDetails") && (overrideReason
                                && overrideReason.toLowerCase()=='other') && !(overrideComment 
                                && overrideComment.trim()));
        if(validationCheck){
            cmp.set("v.serviceCommentError",true);
        }
        else{
            cmp.set("v.serviceCommentError",false);
            if(cmp.get("v.assetAvailabilityAccess")){ //check custom permission is given or not SDT-30108
                helper.updateAdditionalServices(cmp);
            }       
            var cmpEvent = cmp.getEvent("sendNotification");
            console.log('cmpEvent==>'+JSON.stringify(cmpEvent));
            //cmpEvent.setParams({"message" : "validate" });
            console.log('cmpEvent==>'+JSON.stringify(cmpEvent));
            cmpEvent.fire();
            console.log('fired');
        }
        //SDT-29100 :END
    },
    //SDT-21804- modified the finalSubmit button to accomodate the description of waste validation check.
    finalSubmit: function(component, event, helper){ 
        const showSIDModal = component.get("v.showSIDModal");
        if(showSIDModal){ //SDT-21804- [modified] when scheduler is being invoked from Configure Product screen. Dynamic actions are moved from controller to helper.
            helper.dynamicActionSelection(component, event);
        }else{ //SDT-21804- [Created] when scheduler is being invoked from CEI screen.
           console.log('Product Rule In>>');
            component.set("v.showSpinner", true);
            var validationVar = component.get("c.validateDescriptionOfWaste"); 
            var currentProduct = component.get("v.currentProduct");
            console.log('service scheduler currentProduct==>'+JSON.stringify(currentProduct));
            validationVar.setParams({
                productWrapper : currentProduct
            });
            validationVar.setCallback(this, function(response){
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set("v.validationResultsMap",response.getReturnValue());
                    var resultMap = component.get("v.validationResultsMap");
                    for(var k in resultMap){
                        console.log('k>>> '+k);
                        if(k == 'Success'){
                            helper.dynamicActionSelection(component, event, helper);
                        }else{
                            var errorList = resultMap[k];
                            var errorToast = $A.get('e.force:showToast');
                            errorToast.setParams({
                                'title': 'Validation Error',
                                'message': errorList[0],
                                'type': 'error'
                            });
                            errorToast.fire();
                            component.set("v.showSpinner", false);
                        }
                    }
                }
                component.set("v.showSpinner", false);
            });
            $A.enqueueAction(validationVar);
        }
        //SDT-29100 : START
        if(component.get("v.assetAvailabilityAccess")){
            let overrideFlag = component.get("v.showOverrideDetails");
            var actionSaveOverrideDetails = component.get("c.saveServiceOverrideOptions"); 
            actionSaveOverrideDetails.setParams({ 
                quoteLineId :component.get("v.pqLine").Id,
                overrideReason: overrideFlag ? component.get("v.currentProduct.serviceOverrideReason") :'',
                overrideComment: overrideFlag ? component.get("v.currentProduct.serviceOverrideComment") : '',
                serviceStatus:component.get("v.serviceStatus"),
                serviceUnavailable:component.get("v.selectedUnavailableDays")
            });   
            actionSaveOverrideDetails.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Saved');
                }
                else if (state === "ERROR") {
                    console.error("Error message: ",response.getError());
                }
                component.set("v.showSpinner", false);
            });
            $A.enqueueAction(actionSaveOverrideDetails);
        }
        //SDT-29100 : END
    },
    
    dailySelect: function(component, event, helper){
        helper.dailyBtnStateToggle(component);
        var curBtnId = event.getSource().getLocalId();
        if(curBtnId=='dailyEveryDayBtnId'){
            component.set('v.dailyEveryDayBtnstate', true); 
            component.set('v.dailyEveryWeekBtnstate', false);
        }else{
            component.set('v.dailyEveryDayBtnstate', false);
            component.set('v.dailyEveryWeekBtnstate', true);  
        }
    },
    monthlySelect: function(component, event, helper){
        helper.monthlyBtnStateToggle(component);
        var curBtnId = event.getSource().getLocalId();
        if(curBtnId=='monthlyEveryMonthBtnId'){
            component.set('v.monthlyEveryMonthBtnstate', true);  
            component.set('v.monthlySpecificMonthBtnstate', false); 
        }else{
            component.set('v.monthlyEveryMonthBtnstate', false); 
            component.set('v.monthlySpecificMonthBtnstate', true);  
        }
    },
    yearlySelect: function(component, event, helper){
        component.set('v.yearlyBtnstate', true);    
    },
    statebtnClicked: function(component, event, helper){
        var buttonstate = component.get('v.buttonstate');
        component.set('v.buttonstate', !buttonstate);        
    },
    dualListChange: function(component, event, helper){ 
        //SDT-29100
        helper.checkServiceDay(component);
    },
    radioChange: function(component, event, helper){
        var selVal = component.get("v.selectedRadioOptionValue");
        
        if(selVal=='MWF'){
            component.set("v.selectedOptions",["M","W","F"]);
            component.set("v.selectedWeekDayOption",'M;W;F');
        }else if( selVal=='TR'){
            component.set("v.selectedOptions",["T","T1"]);
            component.set("v.selectedWeekDayOption",'T;T1');
        }else{
            component.set("v.selectedOptions",["M","T","W","T1","F"]);
            component.set("v.selectedWeekDayOption",'M;T;W;T1;F');
        }
        helper.checkServiceDay(component); ////SDT-29100
    },
    //SDT-38285 - start onclick methods
    
    radioServiceDateChange: function(cmp,event, helper){
        var radioServiceDayChecked = false;
        helper.setEnabledDisabled(cmp,radioServiceDayChecked);
    },
	radioServiceDayChange: function(cmp,event, helper){
        var radioServiceDayChecked = true;
        helper.setEnabledDisabled(cmp,radioServiceDayChecked);
    },//SDT-38285 - End
    handleCancel: function(component){
        component.set("v.showSIDModal", false);
    },
    goBack : function(component, event, helper){
        //Resetting Accessory List to null: SDT-22397
        component.set('v.selectedAccessoryList',[]);
        //SDT-23055 Resetting keys quantity
        component.set('v.keyQuantityList',[]);
        component.set("v.showSpinner", true);
        var targetProductId = component.get("v.parentId");
        console.log('targetProductId==>'+targetProductId);
        var dQuote = component.get('c.deleteQuoteLine');
        dQuote.setParams({
            quoteLineId : targetProductId
        });
        dQuote.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state==>'+state);
            if (state === 'SUCCESS'){
                const resp = response.getReturnValue();
                console.log('resp==>'+resp);
                if(resp=='SUCCESS'){
                    let currentProduct = component.get("v.currentProduct");
                    console.log('currentProduct==>'+JSON.stringify(currentProduct));
                    // as current product has been removed so setting current product Id as blank
                    //component.set("v.currentProduct",'');
                    var updateState = component.getEvent('UpdateWrapperState');
                    updateState.setParams({
                        "currentState": "Product",
                        //"currentProductId": currentProduct.productId,
                        //"targetProduct": currentProduct
                        "currentProductId": '',
                        "targetProduct": ''
                    });
                    updateState.fire();
                    
                    // Calling Configured product event to refresh the product
                     var refreshConfiguredProduct = $A.get("e.c:RefreshConfiguredProducts");
                     refreshConfiguredProduct.setParams({
                         "reload": true
                     });
                     refreshConfiguredProduct.fire();
                    
                    component.set("v.showSpinner", false);
                    component.set("v.showSIDModal", false);
                }else{
                    var errorToast = $A.get('e.force:showToast');
                    errorToast.setParams({
                        'title': 'Error',
                        'message': resp,
                        'type': 'error'
                    });
                    errorToast.fire();
                    component.set("v.showSpinner", false);
                }
            }
        });
        $A.enqueueAction(dQuote);
    },
      ///this method build for SDT SDT-30035 and SDT-29100
      handleAvailability: function(component,event, helper) {
        component.set("v.showSpinner", true);
        let assetAvailabilityRes = component.get("c.getAvailabilityResponse");
        assetAvailabilityRes.setParams({
          quoteLineId: component.get("v.parentId")
        });
        assetAvailabilityRes.setCallback(this, function (response) {
            helper.handleAvailabilityResponse(component,response);
            component.set("v.showSpinner", false);
        });        
        $A.enqueueAction(assetAvailabilityRes);  
      },
    //SDT-29100 :Asset availability
    handleServiceOverrideChange :function(cmp,event){
        let newValue = event.getSource().get("v.value")
        cmp.find('servceOverrideComment').set("v.required",(newValue.toLowerCase() == 'other'));
    },
    //SDT-31583
    handleRetryAssetAPI :function(component,event,helper){
        component.set("v.showSpinner", true);
        let assetAvailabilityRes = component.get("c.retryAvailabilityResponse");
        assetAvailabilityRes.setParams({
          quoteLineId: component.get("v.parentId")
        });
        assetAvailabilityRes.setCallback(this, function (response) {
            component.set("v.msgAssetAPIErrors",[]);
            component.set("v.showAssetAPIError",false);
            component.set("v.showAssetAPIButton",false);
            component.set("v.assetAvailabilityError",'');
            component.set("v.serviceStatus",'');
            helper.handleAvailabilityResponse(component,response);
            component.set("v.showSpinner", false);
            if(!component.get("v.showAssetAPIError")){
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Availability API Information successfully fetched."
                });
                toastEvent.fire();
            }
        });        
        $A.enqueueAction(assetAvailabilityRes);  
    }
})