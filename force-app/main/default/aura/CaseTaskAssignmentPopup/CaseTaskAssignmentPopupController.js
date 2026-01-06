({  
    navigateRecord : function(component, event, helper) {
        var objRecord = component.get("v.taskdata");
        
        //var indexID = event.currentTarget.attributes[0].textContent;
        
        //var task
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+ event.currentTarget.attributes[0].textContent
        })
        component.set("v.showPopup", false);
        
        urlEvent.fire();
        
    },
     
    closeModel: function(component, event, helper) {
       /*
       var modalId = document.getElementById('modal');
       modalId.style.display = 'none';
       console.log('Modal id');
       console.log(modalId);
        
       var modalBD = document.getElementById('backDrop');
       modalBD.style.display = 'none';
       console.log('Modal BD');
       console.log(modalBD);
        
       component.set("v.showPopup", false);
        */
        var recordId = component.get("v.recordId");
        var masterInTakeFlow = "masterIntakeTask" + recordId;
        
        var isMasterIntakeFlow = window.localStorage.getItem(masterInTakeFlow);
        /* below caused cmp error due to forEach not being a function of element
        var element = document.getElementsByClassName("slds-modal slds-fade-in-open");    
        element.forEach(function(e, t) {
            $A.util.addClass(e, 'slds-hide');
        });     
        var element = document.getElementsByClassName("slds-backdrop slds-backdrop_open");    
        element.forEach(function(e, t) {
            $A.util.addClass(e, 'slds-hide');  
        }); 
        */
        component.set("v.showPopup", false);
        if(!isMasterIntakeFlow)
        {
        	$A.get("e.force:refreshView").fire();
        }
        else
        {
            window.localStorage.removeItem(masterInTakeFlow);
        }
       
     }
})