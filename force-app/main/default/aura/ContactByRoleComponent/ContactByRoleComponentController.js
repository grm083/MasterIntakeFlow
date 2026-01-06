({
    handleSectionToggle: function (cmp, event) {
        
        var openSections = event.getParam('openSections');
        alert('openSections===='+openSections);
        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
        
    },
    doInit : function(component,event,helper){
        var action = component.get("c.isCommChannelEnabled");
        action.setParams({
            "recId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var stateCheck = response.getState();
            var isflag = response.getReturnValue();
            
            if(stateCheck == 'SUCCESS'){
                if(isflag)
                {
                    component.set("v.isCommEnable",true);
                }
                else
                {
                    helper.getContactRole(component,event,helper);
                }
                    
            }
        });
        $A.enqueueAction(action);
        //helper.getContactRole(component,event,helper);        
    },
    openContact : function(component,event,helper){
        var index = event.currentTarget.getAttribute('data-index');   
        var conId = event.currentTarget.getAttribute('data-Id');
        //alert(conId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+conId
        });
        urlEvent.fire();
    },
    selectUpdateCaseAction : function( cmp, event, helper) {
        var actionAPI = cmp.find("quickActionAPI");
        var args = {actionName: "SendEmail"};
        alert('args---'+JSON.stringify(args));
        actionAPI.selectAction(args).then(function(result){
            //Action selected; show data and set field values
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component
            }
        });
    },
});