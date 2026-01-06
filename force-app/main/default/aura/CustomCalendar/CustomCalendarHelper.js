({
	createMultipleCases : function(component, event, helper) {
        
        var action = component.get("c.createMultipleCasesInvoke"); 
        var today = new Date();
        var dates = [];
        var datesArray = [];
        var stopLoop = false;
        var serviceDate = component.get("v.servicedate");
        //var selectedDateList = serviceDate.split('-');
        //serviceDate = selectedDateList[1] + '/' + selectedDateList[2] + '/' + selectedDateList[0]; 
	   var is_AM_PM_Case = component.get("v.Create_AM_and_PM_Pickups");
        var isDuplicateFound= false;
       // serviceDate = serviceDate.getMonth() + '/' + serviceDate.getDate() + '/' + serviceDate.getFullYear();
        datesArray = ($('#mdp-demo')[0].value).split(',');
        
        for(var i = 0;i < datesArray.length;i++){
            dates.push(datesArray[i].trim());
        }
        
        if(dates.indexOf(serviceDate) > -1)
        {
            dates.splice(dates.indexOf(serviceDate), 1);
        }
        
        /*
       // dates = dates.filter(entry => entry.trim());
        var date_sort_asc = function (date1, date2) {
            if (date1 > date2) return 1;
            if (date1 < date2) return -1;
            return 0;
        };
        dates.sort(date_sort_asc);
        for(var i = 0;i < dates.length;i++){
            if(new Date(dates[i]) < today){
                stopLoop = true;
                break;
            }
        }
        if(stopLoop){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": $A.get("$Label.c.Select_future_date"),
                "type": "error"
            });
            toastEvent.fire();
            component.set("v.showModal",false);
        }else
        */
		if(dates.length > 0 || ( dates.length ==0 && is_AM_PM_Case))
        {        
            action.setParams({
                'selectedDueDateStr' : dates,
                'caseRecId' : component.get("v.recordId"),
                'doNotReturn' : component.get("v.NotReturn"),
				'Create_AM_PM_Pickup' :component.get("v.Create_AM_and_PM_Pickups")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                var toastEvent = $A.get("e.force:showToast");
                if (response.getReturnValue().success) {
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": $A.get("$Label.c.Case_success"),
                        "type": "success"
                    });
                    
                    if(response.getReturnValue().dupList.length > 0){
                        isDuplicateFound = true ;
                        $A.createComponent(
                            "c:DuplicateCheckOnMultiDate",
                            {
                                "workorders" : response.getReturnValue().dupList,
                                "caseList" : response.getReturnValue().childCases,
                                "showModal" : true
                            },
                            function(msgBox){                
                                if (component.isValid()) {
                                    var targetCmp = component.find('dupComp');
                                    var body = targetCmp.get("v.body");
                                    body.push(msgBox);
                                    targetCmp.set("v.body", body); 
                                }
                            }
                        );
                    }
 
                }
                else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue().message,
                        "type": "error"
                    });
                }
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
                component.set("v.loadingSpinner", false);
                
                if(!isDuplicateFound){
                component.set("v.showModal",false);
                component.set("v.closeParent",false) ;
                component.destroy();
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                        "title": "Warning!",
                        "message": "Please select a date in future or past from Service Date.",
                        "type": "warning"
                    });
            toastEvent.fire();
            component.set("v.loadingSpinner", false);
            component.set("v.showModal",false);            
            component.set("v.closeParent",false) ;
             
        }        
    }
})