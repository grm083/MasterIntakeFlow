({
    doInit : function(cmp,event,helper){
        
        var getPositions = cmp.get('c.allPositions');
        
        getPositions.setParams({
            header: cmp.get('v.productWrapper')
        });
        getPositions.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                cmp.set('v.positions', response.getReturnValue());
                this.selectedPosition(cmp,event,response.getReturnValue()); 
            };
        });
		$A.enqueueAction(getPositions);        
    },
    
    selectedPosition : function(cmp,event,data){
        var product = cmp.get('v.productWrapper');
        var getPositions = cmp.get('c.showLocationPosition');
     
        getPositions.setParams({
            quoteLineId: product.parentId   
        });
        getPositions.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') { 
                var quotelines = response.getReturnValue();
                //console.log('Result product Id line is: '+ locationPositionId);
                const selectedRecords = new Array();
                if (quotelines !== null) {
                    selectedRecords.push(quotelines[0].Location_Position_Name__c); 
                    cmp.set('v.selectedRecords',selectedRecords);
                    cmp.set('v.Selectedvalue', quotelines[0].Location_Position_Name__c);
                    cmp.set('v.SelectedPositionName', quotelines[0].LocationPositionName__c);
                }
            };
        });
        $A.enqueueAction(getPositions);
    },
    
	handleSearch : function(cmp) {
		var searchPositions = cmp.get('c.searchPositions');
        var searchString =cmp.get('v.searchresult');
        cmp.set('v.selectedRecords','');
        searchPositions.setParams({
            header: cmp.get('v.productWrapper'),
            searchString:searchString
        });
        searchPositions.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                cmp.set('v.positions', response.getReturnValue())
            };
        });
        $A.enqueueAction(searchPositions);
    },
    showToast : function(title, msg, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type": type
        });
        toastEvent.fire();
    }
})