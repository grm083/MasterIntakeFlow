({
    getSLAinstruction : function(component) {
        var recordID = component.get("v.recordId");
        var action = component.get('c.getEntitlement');
        action.setParams({
            "CaseId" : recordID
        });
        action.setCallback(this,function(response){
            var status = response.getState();
          
            if(status == "SUCCESS"){
                var result = response.getReturnValue();
                 if(result != null && result.slaInstrctuions != null && result.slaInstrctuions != "" && result.slaInstrctuions != "undefined" ){
                    console.log('SLA Instructions'+result.slaInstrctuions);
                    component.set('v.SLAinstructions',result.slaInstrctuions);
                    component.set('v.displaySLAInstruction', true);
                }
                else{
                     component.set('v.displaySLAInstruction', false);
                }
            }
        });
        $A.enqueueAction(action); 
    },    
    getbrInfo : function(component) {
       var caseRecId = component.get("v.recordId");
       var action = component.get('c.getBusinessRule');
        action.setParams({  
            "caseId" : caseRecId
        });
        
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state == "SUCCESS" ) {
               //set response value in wrapperList attribute on component.
                var businessInfo = response.getReturnValue();
               
                if(businessInfo != null && businessInfo != "undefined" && businessInfo != "") {
                    if (businessInfo.specialInstructions != null && businessInfo.specialInstructions != "undefined" && businessInfo.specialInstructions != "") {
                        console.log('Special'+businessInfo.specialInstructions);
                        component.set('v.specialInstructions', businessInfo.specialInstructions); 
                        component.set('v.displaySpecialInstructions', true);
                        console.log('Sp::::'+component.get("v.specialInstructions"));
                    }
                    else{
                          component.set('v.displaySpecialInstructions', false);
                    }
                    if (businessInfo.channelReq != null && businessInfo.channelReq != "undefined" && businessInfo.channelReq != ""
                        && businessInfo.channelName !=null && businessInfo.channelName != "undefined" && businessInfo.channelName !="" ) {
                        console.log('channelReq'+businessInfo.channelReq);
                        component.set('v.channelRequirements', businessInfo.channelReq);
                        console.log('channelName'+ businessInfo.channelName);
                        component.set('v.channelName', businessInfo.channelName);
                        component.set('v.displayChannelRequirements', true);
                    }
                    else{
                        component.set('v.displayChannelRequirements', false); 
                    }
                }
            } else {
                var errors = response.getError();                      
                //alert('Error: ' + errors[0].message);  
            }
        });
        $A.enqueueAction(action);
    }
    
})