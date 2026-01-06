({
	updateHeader : function(cmp) {
		
	},
	// added for SDT 29392
	setTaskGridAndByPassCheckBoxes : function(cmp)
	{
        var BypassTaskTicketCheckcmp=cmp.find("BypassTaskTicket");
        if(BypassTaskTicketCheckcmp != null)
        {
            var BypassTaskTicketCheck=BypassTaskTicketCheckcmp.get("v.checked");
            if(BypassTaskTicketCheck)
            {
                cmp.find("BypassPrice").set("v.checked", false);
                cmp.find("BypassPrice").set("v.disabled", true);
            }
            else{
                cmp.find("BypassPrice").set("v.disabled", false);
            }
        }
	},
    showToast : function(title, msg, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type" : type
        });
        toastEvent.fire();
    } 
})