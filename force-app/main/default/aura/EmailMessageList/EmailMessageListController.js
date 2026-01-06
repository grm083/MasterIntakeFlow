({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'From Address', fieldName: 'FromAddress', type: 'text',"cellAttributes": {
                "class": {
                    "fieldName": "showClass"
                }
            }},
            
            {label: 'Subject', fieldName: 'linkSubject', type: 'url', 
             typeAttributes: {label: { fieldName: 'Subject' }, target: '_parent'}},
            {label: 'Case', fieldName: 'CaseLink', type: 'url', 
            typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_parent'}},
            {label: 'Case Type', fieldName: 'CaseType', type: 'text'},
            {label: 'Case Sub Type', fieldName: 'CaseSubType', type: 'text'},
            {label: 'Case Status', fieldName: 'CaseStatus', type: 'text'},
            {label: 'Case Sub Status', fieldName: 'CaseSubStatus', type: 'text'},
            {label: 'Case Location', fieldName: 'CaseLocation', type: 'text'},
            {label: 'Message Status', fieldName: 'Status', type: 'text',"cellAttributes": {
                "class": {
                    "fieldName": "showClass"
                }
            }},
            { 
                label: 'Message Date', 
                fieldName: 'MessageDate', 
                type: 'date', 
                typeAttributes: {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    timeZone : $A.get("$Locale.timezone"),
                    hour12: true
                },
                sortable: false
                ,"cellAttributes": {
                    "class": {
                        "fieldName": "showClass"
                    }
                }}
            
        ]);
        component.set("v.spinner",true);
        let action=component.get("c.getAllRelatedEmailTasks");
        action.setParams({
            'eMessageId': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner",false);
                var records = response.getReturnValue();
                console.log(records);
                records.forEach(function(record){
                    record.linkSubject = '/'+record.Id;
                    if(record.Parent){
                        record.CaseLink = '/'+record.ParentId;
                        record.CaseNumber = record.Parent.CaseNumber;
                        record.CaseType = record.Parent.Case_Type__c;
                            record.CaseSubType = record.Parent.Case_Sub_Type__c;
                            record.CaseLocation = record.Parent.Location_Code__c;
                            record.CaseSubStatus = record.Parent.Case_Sub_Status__c;
                            record.CaseStatus = record.Parent.Status;
                    }
                    if(record.Id==component.get("v.recordId")){
                        record.showClass = 'greencolor'
                    }
                    else{
                        record.showClass = 'blackcolor'
                    }
                    
                });
                component.set("v.data",records);
			}else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) { 
                        alert("Error message: " + 
                              errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
		});
        $A.enqueueAction(action);
        
    },
    
})