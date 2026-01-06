({
    doInit : function(component, event, helper) {
        //alert("recordId---"+component.get("v.recordId"));
        helper.getSubject(component,event,helper);
    },
    replyAction : function(cmp,event,helper){
        var actionAPI = cmp.find("quickActionAPI");
        alert('actionApi---'+actionAPI);
        var args = {actionName: "EmailMessage._Reply" };
        alert('args---'+JSON.stringify(args));
        actionAPI.selectAction(args).then(function(result){
            //Action selected; show data and set field values
            alert(JSON.stringify(result));
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component 
            }
        });
    },
    viewAttachment : function(component,event,helper){
        
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "CombinedAttachments",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
        
    },
    
    
})