({
	newTitle : function(cmp, event) {
        var acctId = cmp.get('v.accountId');
        var titleVal = cmp.get('v.titleVal')
        var newTitle = cmp.get('c.newTitle');

        console.log('Title Val ' + titleVal);

        newTitle.setParams({
            acct : acctId,
            title : titleVal
        });
        newTitle.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === 'SUCCESS') {
                cmp.set('v.newTitle', returnVal);
            }
        });
        $A.enqueueAction(newTitle);
	}
})