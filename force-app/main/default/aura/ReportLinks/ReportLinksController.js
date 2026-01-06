({
	openActionWindow : function(component, event, helper) {
        var URL = $A.get("$Label.c.MicroStrategy_Dashboard_URL");
        
		 window.open(URL);
	},
    
    
    gotoReportHome : function (component, event, helper) {
    var homeEvent = $A.get("e.force:navigateToObjectHome");
    homeEvent.setParams({
        "scope": "Report"
    });
    homeEvent.fire();
},
    
    gotoVendorReport : function (component, event, helper) {
    var tabName = $A.get("$Label.c.TaskByVendorReport_URL");
        
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": tabName
    });
    urlEvent.fire();
},
    
    gotoLocationReport : function (component, event, helper) {
    var tabName = $A.get("$Label.c.TaskByLocationReport_URL");
        
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": tabName
    });
    urlEvent.fire();
}
           
})