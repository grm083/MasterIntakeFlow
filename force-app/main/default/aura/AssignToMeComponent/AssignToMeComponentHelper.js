({
	  updateTask : function(component, event, helper) {
        var instance = component.get("c.TaskAssignmentChange");  
        instance.setParams({
            "recordId" : component.get("v.recordId")
        });
          instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var res = response.getReturnValue();
                 $A.get("e.force:closeQuickAction").fire()
                console.log('>>>Id-->'+res);
                if(res == ''){
                $A.get("e.force:closeQuickAction").fire()
                $A.get('e.force:refreshView').fire()
                }
                else{
                  console.log('>>>IdNiranjan-->');
                    $A.get("e.force:closeQuickAction").fire()
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Task Assignment Request Message",
                            "message": res,
                            "type": "info",
                            "mode": "sticky",
                            "duration": "5000"
                        });
                        toastEvent.fire();
                } 
             }
             
          });
        $A.enqueueAction(instance);
         
          },
      
})