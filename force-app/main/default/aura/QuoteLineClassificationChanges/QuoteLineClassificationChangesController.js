({
    doInit : function(cmp, event, helper) {
        console.log('doInit parentQuoteLineId'+cmp.get("v.parentQuoteLineId"));
        helper.getData(cmp, event, helper);
        // - SDT-42334 -> start
        helper.getIsHaulAway(cmp, event, helper);
        // - SDT-42334 -> End
    },
    hndleReloadChange : function(cmp, event, helper) {
        console.log('hndleReloadChange parentQuoteLineId'+cmp.get("v.parentQuoteLineId"));
        if(cmp.get("v.reload")){
            helper.getData(cmp, event, helper);   
        }
    },
    //TCS-SDT-31265-Added follwing methods
    showToolTip : function(cmp, event, helper) {
        var tdId = event.target.getAttribute('id');
        var divId = tdId + 'div';
        let elementObj = document.getElementById(divId);
        if(!$A.util.isUndefinedOrNull(elementObj))
        {
            elementObj.className = elementObj.className.replace(" slds-hide", "") + " slds-show";
        }
    },

    HideToolTip : function(cmp, event, helper){
        var tdId = event.target.getAttribute('id');
        var divId = tdId + 'div';
        let elementObj = document.getElementById(divId);
        if(!$A.util.isUndefinedOrNull(elementObj))
        {
            elementObj.className = elementObj.className.replace(" slds-show", "") + " slds-hide";
        }
    },
    //TCS-SDT-31265-End 
})