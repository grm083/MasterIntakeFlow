({
	 loadJquery : function(component, event, helper) {
         component.set("v.loadingSpinner", true);
        	var SelectedDate = [];
        	//alert('js loaded');
       	 	var arr = [];
        
            jQuery(document).ready(function(){
                
                	
                    var addDates =[];
                    var selectDate = component.get("v.servicedate");
                    if(selectDate){
                	var selectedDateList = selectDate.split('-');
                	selectDate = selectedDateList[1] + '/' + selectedDateList[2] + '/' + selectedDateList[0]; 
               
                    var date = new Date(selectDate);                   
                	
                    $('#mdp-demo').multiDatesPicker({
                        // preselect the 14th and 19th of the current month
                        addDates: [date],
                        defaultDate: date
                    });               
                	
                    component.set("v.servicedate",$('#mdp-demo')[0].value);
                }
                component.set("v.loadingSpinner", false);
            })
        },
     createCase : function(component, event, helper) {        
        //alert('*** in controller' + component.get("v.recordId"));
        component.set("v.loadingSpinner", true);
        helper.createMultipleCases(component, event, helper);
        var parentId = component.get("v.parentId");
        if(parentId != "undefined" && parentId != null && parentId != ""){
            var caseId = parentId;
            const payload = {
                caseId: caseId,
            };
            component.find("lmschannel").publish(payload);
        }
    },
    handleReceiveMessage : function(component, event, helper) {
		
	},
    closeModel : function(component, event, helper) {
        component.set("v.showModal",false);
    },
    
    closeParentContainer: function(component, event, helper) {       
        		component.set("v.showModal",false);
                component.set("v.closeParent",false) ;
                component.destroy();
    }
})