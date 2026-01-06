({
	callApex : function(component, event, helper) {
		var action = component.get('c.getRecordTypeId');
        action.setParams({
            "caseId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                component.set("v.recordTypeId",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
	
	
    addMinutes:function(date, minutes) {
    return new Date(date.getTime() + minutes*60000);
    },
    
    
   handleFormSubmit: function(component,fields) {
        var showValidationError = false; 
        var vaildationFailReason = '';
        var currentDate = new Date();
        //var todayDate =new Date(currentDate.getFullYear()+'-'+(currentDate.getMonth())+'-'+currentDate.getDate());
        
        var todayDateGMT =currentDate.getFullYear()+'-'+(currentDate.getMonth()+1)+'-'+currentDate.getDate()+ ' 00:00:00 GMT';
        var newTodayDate =new Date(todayDateGMT);
         var todayDate =  this.addMinutes(newTodayDate,newTodayDate.getTimezoneOffset()) ;
        
        
        let slaOverrideReason =fields["SLA_Override_Reason__c"];
        let slaOverrideComment =fields["SLA_Override_Comment__c"];
        
      //  var serviceDate =new Date(fields["Service_Date__c"]);
        var serviceDateGMT = fields["Service_Date__c"] + ' 00:00:00 GMT' ;
        var newServiceDate =new Date(serviceDateGMT);
        var serviceDate =  this.addMinutes(newServiceDate,newServiceDate.getTimezoneOffset()) ;
        
        var slaSrvDate = component.get("v.simpleNewCase.SLA_Service_DateTime__c");
        var getDateValuefromSLA = slaSrvDate.substring(0, 10);
        let slaServiceDate = new Date(getDateValuefromSLA);
       // var srvdate = new Date(serviceDate.getFullYear()+'-'+(serviceDate.getMonth())+'-'+serviceDate.getDate());
        
        
        // service date is equal to and greater than today date, then the validation error will come
        if( serviceDate.getTime() < slaServiceDate.getTime() && serviceDate.getTime() >= todayDate.getTime()){
            if(slaOverrideReason === null || slaOverrideComment === null ||slaOverrideComment==='' ||slaOverrideReason===''){
                showValidationError = true;
                vaildationFailReason = "Please fill SLA Override Reason and SLA Override Comment";   
            }}
        
        if (showValidationError) {
            console.log('show Error :: ' + showValidationError);
            component.find('OppMessage').setError(vaildationFailReason);
            component.set('v.loading', false);
        } else {
            component.set('v.loading', true); 
            component.find("recordViewForm").submit(fields);
            var isAvailDate = component.get("v.isAvailDate");
            var isDateNotListedCl = component.get("v.isDateNotListedCl"); 			
            if(isDateNotListedCl)
            {
                var action = component.get('c.insertPlannerComment');
                action.setParams({
                    "caseId" : component.get("v.recordId"),
                    "selectedDate" : '',
                    "isAvailDates" : isAvailDate,
                    "isDateNotListed" : isDateNotListedCl
                });
                action.setCallback(this, function(response){
                    if(response.getState() == "SUCCESS"){
                        console.log('@@ Inserted comment');
                    }
                });
                $A.enqueueAction(action);
            }			
        }
    },
})