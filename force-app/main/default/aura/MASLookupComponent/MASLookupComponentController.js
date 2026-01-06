({
	doinit : function(cmp, event, helper) {
		var header = cmp.get('v.productWrapper');
        cmp.set('v.origProductWrapper', header);
        
        //var MASInfo = cmp.get('c.returnMASDetails');
        /*MASInfo.setParams({
            businessUnit: header.vendorBU
        });*/
        //SDT-29645 - Start
        var qLineTest = cmp.get('v.productWrapper.parentId');
        
        var MASInfo = cmp.get('c.returnUniqueMASDetails');
        MASInfo.setParams({
            quoteLineId: qLineTest
        });
        //SDT-29645 - End
        
        MASInfo.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS'){
                cmp.set('v.MASInfo', response.getReturnValue());
            }
        });
        $A.enqueueAction(MASInfo); 
		var quoteLineId = cmp.get('v.productWrapper.parentId');
        var getQuotelinesforMAS = cmp.get('c.getMasDetails');
        getQuotelinesforMAS.setParams({
            quoteLineId : quoteLineId
        });
        getQuotelinesforMAS.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                if (data) 
                {
                    cmp.set('v.productWrapper.MAS.MASLibrary', data.MASLibrary);
                    cmp.set('v.productWrapper.MAS.MASCompany', data.MASCompany);
                    cmp.set('v.productWrapper.MAS.MASBypassPrice', data.MASBypassPrice);
                    cmp.set('v.setupCommentSize',data.MASCommentSize);
                    // Changes for SDT-29392
                    if(data.IsDoNotCreateTaskGridTicketVisible != null && data.IsDoNotCreateTaskGridTicketVisible != undefined)
                    {
                        cmp.set('v.IsVisibleDoNotCreateTaskGridAndMASTicket', true);
                    }
                
                    helper.setTaskGridAndByPassCheckBoxes(cmp);
                }
            }
        });
        $A.enqueueAction(getQuotelinesforMAS);

	},
    pushValues: function(cmp, event) {
        var quoteLineId = cmp.get('v.productWrapper.parentId');
        
        var selection = event.getParam('selectedRows');
        cmp.set('v.productWrapper.MAS.MASLibrary', selection[0].MAS_Library__c);
        cmp.set('v.productWrapper.MAS.MASCompany', selection[0].MAS_Company_Code__c);

        var getbypassPriceReview = cmp.get('c.bypassPriceReview');
        getbypassPriceReview.setParams({
            quoteLineId : quoteLineId,
            masLibrary : selection[0].MAS_Library__c
        });
        getbypassPriceReview.setCallback(this, function(response) {
            var state = response.getState()
            console.log(response.getState());
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                cmp.set('v.productWrapper.MAS.MASBypassPrice', data);
               console.log(data);
            }
        });
        $A.enqueueAction(getbypassPriceReview);

        //Comment below code for SDT-28904
        // var marketRestriction = cmp.get('v.productWrapper.sCode');
        // console.log('sCode is ' + marketRestriction);
        // var restrictedMarkets = ['FRCH', 'UTL', 'LL', 'CAM', 'CTY'];
        
        // if (!restrictedMarkets.includes(marketRestriction)) {
        // 	cmp.set('v.productWrapper.MAS.MASBypassPrice', selection[0].Bypass_Price_Review__c);
        // }
    },
    showFields: function(cmp) {
    	var showFields = cmp.get('v.showFields');
        cmp.set('v.showFields', !showFields);
        if (!showFields) {
            cmp.set('v.showhide', 'Hide Fields');
        } else {
            cmp.set('v.showhide', 'Show Fields');
        }
    },
    saveMAS: function(cmp, event, helper) {
        
        var updatedWrapper = cmp.get('v.productWrapper');
        var updateQLI = cmp.get('c.writeMASDetails');
        updateQLI.setParams({
            headerRecord : updatedWrapper
        });
        updateQLI.setCallback(this, function(response) {
            var state = response.getState()
            console.log(response.getState());
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                {
                    if(data.IsSuccess)
                    {
                        var closeSIDModalEvent = cmp.getEvent('CloseSIDModalEvent');
                        closeSIDModalEvent.setParams({
                            "showSIDModal" : "false"
                        });
                        closeSIDModalEvent.fire();
                    }
                    else{
                        helper.showToast('Error', data.ErrorMessage, 'error');  
                    }
                }
                
            }
        });
        $A.enqueueAction(updateQLI);
    },
    // added for SDT 29392
    handleBypassTaskTicketCheckboxCheck : function(component, event, helper) {
        //var BypassPriceDisable=component.find("BypassPrice").get("v.disabled");
        helper.setTaskGridAndByPassCheckBoxes(component);
	}
})