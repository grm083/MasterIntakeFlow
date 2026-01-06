({
    
  doInit : function(cmp) {
		var getCaseId = cmp.get('c.getCaseId');
    getCaseId.setParams({
        recordId: cmp.get('v.recordId')
    });
    getCaseId.setCallback(this, function(response) {
        if (response.getState() === 'SUCCESS') {
            cmp.set('v.caseId',response.getReturnValue());
        };
    });
    $A.enqueueAction(getCaseId);
  },
    
  refreshCaseRule: function(component, event, helper){
  component.find('caseRuleCmp').reloadCaseRules();   
  },

  refreshAllRule: function(component, event, helper){
    component.find('allRuleCmp').reloadAllRules();   
  }
    
});