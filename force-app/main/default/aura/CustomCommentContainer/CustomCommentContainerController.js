({
	doInit : function(cmp) {
		var getCaseId = cmp.get('c.getCaseId');
        getCaseId.setParams({
            recordId: cmp.get('v.recordId')
        });
        getCaseId.setCallback(this, function(response) {
            if (response.getState() === 'SUCCESS') {
                //Changes related to SDT-18095
                cmp.set('v.caseId',response.getReturnValue().Id);
                if(response.getReturnValue().Case_Record_Type__c === 'Repair Case'){
                    cmp.set('v.isRepairCase',true);
                    cmp.set('v.trackingNumber',response.getReturnValue().Tracking_Number__c);
                }
            };
        });
        $A.enqueueAction(getCaseId);

	},
    //Changes related to SDT-18095
    refreshNotes: function(component, event, helper){
        component.find('navNotes').loadNotesData();   
	}
})