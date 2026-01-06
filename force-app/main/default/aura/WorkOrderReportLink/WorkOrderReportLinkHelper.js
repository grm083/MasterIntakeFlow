({
	gotoWOReport : function(component, event, helper, locationCode){
        var tabName = $A.get("$Label.c.WorkOrderReport_URL");
        //var reportURL = '/lightning/r/Report/00O8A000001IZbMUAW/view?fv0='+locationCode;
        var reportURL = tabName+locationCode; 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": reportURL
        });
        urlEvent.fire();  
    }
})