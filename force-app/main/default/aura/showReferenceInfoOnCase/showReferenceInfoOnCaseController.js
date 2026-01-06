({    
    onload : function(component, event, helper) {
        var cId = component.get("v.recordId");
        helper.getbrInfo(component);
        helper.getSLAinstruction(component);
    } ,
    
    recordUpdated : function(component, event, helper){
    var cId = component.get("v.recordId");
    var changeType = event.getParams().changeType;
    if(changeType == "CHANGED"){
    helper.getbrInfo(component);
    helper.getSLAinstruction(component);
}
 
}
})