({
    onRefreshView : function(component, event, helper) {
        //alert('fire event');
        var message = event.getParam("reload");
		//alert('msg----'+message);
        //$A.get('e.force:refreshView').fire();
    },
    updateRecordView: function(component, event, helper) {
        var id = component.get("v.recordId");
        var container = component.find("container");
        $A.createComponent("force:recordView",
                           {recordId: id,type: "FULL"},
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
    },
    reloadView : function(component, event, helper) {
        var id = component.get("v.recordId");
        var container = component.find("container");
        $A.createComponent("c:CaseReadOnlyComponent",{"recordId":id,"renderRefresh":"false"},
                           function(cmp) {
                               container.set("v.body", [cmp]);
                           });
    }
})