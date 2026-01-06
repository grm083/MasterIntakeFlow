({
    doInit : function(component, event, helper) {
        window.setTimeout(
     			$A.getCallback(function() {
                    
                    let redirect = function(){
                        var eUrl= $A.get("e.force:navigateToURL");
                        eUrl.setParams({ 
                            "url": $A.get("$Label.c.Green_Page_Link")
                        });
                        eUrl.fire();
                    }
                    
         		var utilityBarAPI = component.find("utilitybar");     
        		var eventHandler = function(response){
                console.log(response);
                console.log('Onclick action captured');
                    
                redirect();
                
        	};
        
            utilityBarAPI.onUtilityClick({ 
                eventHandler: eventHandler 
            }).then(function(result){
                
                console.log(result);
                 redirect();               
                
            }).catch(function(error){
                console.log(error);
            });
            }), 500	);
       
    }
   
    
})