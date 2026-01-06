({
	onInit : function(component, event, helper) {
		const empApi = component.find('empApi');
        empApi.setDebugFlag(false);		// set to true for debugging

        var recordId = component.get("v.recordId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        empApi.onError($A.getCallback(error => {
            // Error can be any type of error (subscribe, unsubscribe...)
            console.error('EMP API error: ', error);
        }));
            
        empApi.subscribe('/event/System_Log_Event__e', -1, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
            var result = eventReceived.data.payload;
            if (typeof(result.Message__c) != 'undefined') { 
            	// verify user and Parent Id
            	var eventUserId = result.User_ID__c;
            	var eventLevel = result.Level__c;
            	var eventParentId = result.Parent_ID__c; 
            	var msg = result.Message__c;
            	//console.log('error handler debug:');
            	//console.log('Event Level: ' + eventLevel);
            	//console.log('Logged-In User Id: '+ userId);
            	//console.log('Event User Id:' +  eventUserId);
            	//console.log('Record Id: ' + component.get("v.recordId"));	// undefined from utility component, using URL hack
            	//console.log('Event Record Id: ' + eventParentId);
            	
                if ((eventLevel == 'ERROR' || eventLevel == 'EXCEPTION') && userId == eventUserId &&
            		(typeof(eventParentId) == 'undefined' || eventParentId == '' || window.location.href.includes(eventParentId))) {
            		
            		if (typeof(result.Log_Id__c) != 'undefined') msg += '  Log ID: ' + result.Log_Id__c;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
            			title: "Error:",
                        message: msg,
                        type: "error",
                        mode: "sticky"
                    });
                    toastEvent.fire();
    			}
   				
                if(eventLevel == 'INFO' && userId == eventUserId && 
    			(typeof(eventParentId) == 'undefined' || eventParentId == '' || window.location.href.includes(eventParentId))){                   				
                    var toastEvent = $A.get("e.force:showToast");
   					toastEvent.setParams({           			
                        message: msg,
                        type: "success",
                        mode: "dismissible",
    					duration :5000
                    });
                    toastEvent.fire();
    			}
    		}
        }))
        .then(subscription => {
            // Confirm that we have subscribed to the event channel.
            // We haven't received an event yet.
            console.log('Subscribed to channel ', subscription.channel);
            // Save subscription to unsubscribe later
            component.set('v.subscription', subscription);
            //alert('Subscribed to System Log Event!');
        });
	}
})