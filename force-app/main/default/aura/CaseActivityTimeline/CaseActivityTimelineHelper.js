({
	callApex : function(component, event, helper) {
		var instance = component.get("c.fetchHistoryRecords");
        instance.setParams({
            "caseId" : component.get("v.recordId")
        });
        instance.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                if(response.getReturnValue().length > 0){
                    component.set("v.dataList",response.getReturnValue());
                    const monthNames = ["January", "February", "March", "April", "May", "June",
                                        "July", "August", "September", "October", "November", "December"
                                       ];
                    /*var formattedData;
                    formattedData = response.getReturnValue().map(function (record){
                        //record.UserLink = record.User__r.Name;
                        var timestamp = new Date(record.Time_Stamp__c);
                        var dateFormat = monthNames[timestamp.getMonth()]+' '+timestamp.getDate()+' '+timestamp.getFullYear();
                        var ab = record.Time_Stamp__c.search('T');
                        var hours = record.Time_Stamp__c.substring(ab+1,ab+3);
                        var cd = record.Time_Stamp__c.search(':');
                        var minutes = record.Time_Stamp__c.substring(cd+1,cd+3);
                        var timeFormat;
                        if(hours > 12){
                            timeFormat =  hours-12+':'+minutes+' '+'PM';
                        }else{
                            timeFormat = hours+':'+minutes+' '+'AM';
                        }
                        record.Time_Stamp__c = dateFormat+','+timeFormat;
                        return record;
                    });*/
                }
                
            }
        });
        $A.enqueueAction(instance);
	},
    callTaskAssignmentPopup : function(component, event, helper)
    {        
                var cId = component.get("v.recordId");
                var action = component.get('c.getRelatedtask');
        		var isShowPopUp = false;
                action.setParams({
                    "caseId" : cId 
                });
                action.setCallback(this, function(response) {
                var statetask = response.getState();
                    
                if (statetask == "SUCCESS") {
                    var datatask = response.getReturnValue();                    
                    
                    if(datatask.length > 0)
                    { 
                        component.set("v.showPopup", false);
                        var userName = datatask[0].Owner.Name;
                        
                        $A.createComponent(
                            "c:CaseTaskAssignmentPopup",
                            {
                                "recordId" : component.get("v.recordId"), 
                                "showPopup": true,
                                "taskdata" : datatask,
                                "TaskDetail":datatask,
                                "assingneeName":userName
                            },
                            function(msgBox){    
                                
                                if (component.isValid()) {                                    
                                    var targetCmp = component.find('casePopupHolder');   
				    targetCmp.set("v.body",[]);		
                                    var body = targetCmp.get("v.body");
                                    body.push(msgBox);
                                    targetCmp.set("v.body", body);
                                     component.set('v.isShowPopup', false);
                                }
                            }
                        );  
                    }
                    else
                    {
                        component.set("v.isShowPopup", true);
                    }                   
                }
                });
                $A.enqueueAction(action);
        
	}
})