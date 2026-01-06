({
	init : function(cmp, event, helper) {
        helper.doInit(cmp, event,helper); 
    },
    storeOffsiteClick : function(cmp,helper) {
        
        var OffsitePosition = cmp.get('v.altPosition');
        var street = cmp.get('v.altStreet');
        var city = cmp.get('v.altCity');
        var state = cmp.get('v.altState');
        var postal = cmp.get('v.altPostal');
        
        //cmp.set('v.positionName', 'OFFSITE ADDRESS: ' + position + ' at ' + street + ', ' + city + ', ' + state + ', ' + postal);

        if(OffsitePosition === undefined ||OffsitePosition === '' || OffsitePosition === null ){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Fail!",
                    "message": "Offsite Position is required.",
                    "type": "Error"
                });
                toastEvent.fire();
        }
        else
        {
        cmp.set("v.loadingSpinner", true);
        var storeOffsite = cmp.get('c.storeOffsite');
        storeOffsite.setParams({
            header: cmp.get('v.productWrapper'),
            OffsitePosition:OffsitePosition,
            street:street,
            city:city,
            state:state,
            postal:postal
        });
        storeOffsite.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var Status = response.getReturnValue();

                if (Status === 'Duplicate'){
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Fail!",
                    "message": "Duplicate Offsite account position.",
                    "type": "error"
                });
                toastEvent.fire();
                cmp.set("v.loadingSpinner", false);
                }
                else
                {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Offsite account position added successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
                cmp.set("v.loadingSpinner", false);
                var CloseModalEvent = cmp.getEvent('closeLocationModal');
                CloseModalEvent.setParams({
                    "closeLocationModal" : "false"
                });
                CloseModalEvent.fire();
                
            }
            };
        });
		$A.enqueueAction(storeOffsite);
   
    }
    },
    storeOnsiteClick : function(cmp,helper) {
        var positionName = cmp.get('v.positionName');
        if(positionName === undefined ||positionName === '' || positionName === null ){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Fail!",
                    "message": "Position name is required.",
                    "type": "Error"
                });
                toastEvent.fire();
        }
        else
        {
        cmp.set("v.loadingSpinner", true);
        var storeOnsite = cmp.get('c.storeOnsite');
        storeOnsite.setParams({
            header: cmp.get('v.productWrapper'),
            positionName:positionName
        });
        storeOnsite.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var Status = response.getReturnValue();

                if (Status === 'Duplicate'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Fail!",
                        "message": "Duplicate Onsite account position.",
                        "type": "error"
                    });
                    toastEvent.fire();
                    cmp.set("v.loadingSpinner", false);
                }
                else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Onsite account position added successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
                cmp.set("v.loadingSpinner", false);
                var CloseModalEvent = cmp.getEvent('closeLocationModal');
                CloseModalEvent.setParams({
                    "closeLocationModal" : "false"
                });
                CloseModalEvent.fire();
                   
            }
            };
        });
		$A.enqueueAction(storeOnsite);
    }
    },
    handleEnter : function(cmp,event) {
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows'+JSON.stringify(selectedRows));
        
        for (var i = 0; i < selectedRows.length; i++){
            
           console.log('inside selectedRows'+JSON.stringify(selectedRows));
           cmp.set('v.Selectedvalue', selectedRows[i].Id);
           cmp.set('v.SelectedPositionName' ,selectedRows[i].Container_Position__c);
        }
    },
    handleClick : function(cmp, event, helper){
        var searchString =cmp.get('v.searchresult');
        if(searchString!=undefined && searchString!=null && searchString != '' && searchString.length>=3){
         	helper.handleSearch(cmp);   
        }else{
            helper.showToast('Warning', 'Please Provide atleast three characters', 'warning');
        }
    },
    handleStrChange :function(cmp, event, helper) {
        var searchString =cmp.get('v.searchresult');
        console.log('searchString==>'+searchString);
        console.log('searchString length==>'+searchString.length);
        if(searchString!=undefined && searchString!=null && searchString != '' && searchString.length>=3){
         	helper.handleSearch(cmp);   
        }else{
            helper.doInit(cmp, event);
        }
    },
    
    handleAddChange :function(cmp, event, helper) {
        var updateALPOnQuoteLine = cmp.get('c.updateALPOnQuoteLine');
        updateALPOnQuoteLine.setParams({
            header: cmp.get('v.productWrapper'),
            ALPId:cmp.get('v.Selectedvalue'),
            setupComments:cmp.get('v.SelectedPositionName'),
            isOffsite:'False'

        });
       
    },
    saveVendor :function(cmp,event) {
        var updateALPOnQuoteLine = cmp.get('c.updateALPOnQuoteLine');
        updateALPOnQuoteLine.setParams({
            header: cmp.get('v.productWrapper'),
            ALPId:cmp.get('v.Selectedvalue'),
            setupComments:cmp.get('v.SelectedPositionName'),
            isOffsite:'False'

        });
        updateALPOnQuoteLine.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Saved successfully!!",
                    "type": "success"
                });
                toastEvent.fire();
                var CloseModalEvent = cmp.getEvent('closeLocationModal');
                CloseModalEvent.setParams({
                    "closeLocationModal" : "false"
                });
                CloseModalEvent.fire();
            };
        });
		$A.enqueueAction(updateALPOnQuoteLine);
        
    }
})