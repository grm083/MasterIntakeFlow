({    
	assetdetail : function(component, event) {
        /*var assetHeadetId = component.get('v.assetHeadetId');
        console.log('v.assetHeadetId@@@'+assetHeadetId);
        if(component.get('v.assetHeadetId') == null || (component.get('v.assetHeadetId') != null && component.get('v.assetHeadetId') != component.get('v.CaseDetails.AssetId'))){*/
            var action = component.get('c.getServiceDetails');
            var cseDetails = component.get('v.CaseDetails');
            var astDetails = null;
            action.setParams({
                "caserec" : cseDetails 
            });
            action.setStorable();
            action.setCallback(this, function(a){
                var state = a.getState(); // get the response state
                if(state == 'SUCCESS') {
                    astDetails = a.getReturnValue();
                    component.set('v.assetdetails', astDetails);
                    //component.set('v.assetHeadetId', cseDetails.AssetId);
                    if(astDetails.pickUpCost != null){
                        component.set('v.pickUpCost', true);
                    }
                    if(astDetails.pickUpPrice != null){
                        component.set('v.pickUpPrice', true);
                    }
                    if(astDetails.extraPickUpPrice != null){
                        component.set('v.extraPickUpPrice', true);
                    }
                    if(astDetails.extraPickUpCost != null){
                        component.set('v.extraPickUpCost', true);
                    }
                    if(astDetails.haulCost != null){
                        component.set('v.haulCost', true);
                    }
                    if(astDetails.haulPrice != null){
                        component.set('v.haulPrice', true);
                    }
                    if(astDetails.disposalCost != null){
                        component.set('v.disposalCost', true);
                    }
                    if(astDetails.disposalPrice != null){
                        component.set('v.disposalPrice', true);
                    }
                }
            });
            $A.enqueueAction(action);
        //}
	},
    handleClick : function(component, event, helper) {
        var recordId = event.currentTarget.dataset.value;
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        sObectEvent.fire();
    }
})