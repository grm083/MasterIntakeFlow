({
   openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
    
    checkOwner: function(component, event, helper) {
        //call check owner method
        //$A.get("e.force:closeQuickAction").fire()
        var action = component.get("c.taskOwnerCheck");
        action.setParams({
            "messageId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState()=="SUCCESS"){
                var res = response.getReturnValue();
                if(res == true){
                    component.set("v.openOwnerWarn",true);
                }else{
                    var a = component.get('c.completeTasks');
                    $A.enqueueAction(a);
                }
                component.set("v.openWarning",false);
            }
        })
        $A.enqueueAction(action);
    },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      //component.set("v.openWarning", false);
      //component.set("v.openOwnerWarn", false);
      $A.get("e.force:closeQuickAction").fire()
   },
    
    completeTasks: function(component, event, helper) {
      // complete the tasks
      
      var action = component.get("c.EmailTaskComplete");
        action.setParams({
            "messageId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState()=="SUCCESS"){
                var res = response.getReturnValue();
                if(res == true){
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Email Task Completion Success",
                            "message": "You have successfully completed the email tasks!",
                            "type": "success",
                            "mode": "sticky",
                            "duration": "5000"
                        });
                        toastEvent.fire();
                    	$A.get("e.force:closeQuickAction").fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Email Task Completion",
                            "message": "All email tasks have already been completed for this case.",
                            "type": "info",
                            "mode": "sticky",
                            "duration": "5000"
                        });
                        toastEvent.fire();
                    	$A.get("e.force:closeQuickAction").fire();
                }
            }
        })
        $A.enqueueAction(action);
        component.set("v.openOwnerWarn",false);
        
        
   },
    
    closeQuickAction: function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
   
})