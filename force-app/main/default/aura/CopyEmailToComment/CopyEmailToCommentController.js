({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Subject', fieldName: 'Subject', type: 'text'},
            {label: 'From Address', fieldName: 'FromAddress', type: 'Email'},
            {label: 'To Address', fieldName: 'ToAddress', type: 'Email'},
            {label: 'Message Status', fieldName: 'Status', type: 'text'},
            {label: 'Message Date', fieldName: 'MessageDate', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}}
            
        ]);
        helper.getEmail(component,event,helper);
    },
    handleNextAction : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        let lines = [];
        lines = component.find('emailMessages').getSelectedRows();
        if(lines.length === 0){
            toastEvent.setParams({
                "title": "Warning!",
                "message": $A.get("$Label.c.No_Email_Select"),
                "type": "warning"
            });
            toastEvent.fire();
        }else {
            component.set("v.searchCase",true);
            component.set("v.showTable",false);
            component.set("v.selectedList",JSON.stringify(lines));
        }
        console.log(JSON.stringify(lines));
    },
    handlelookUpEvent : function(component, event){
        let destinatedCase = event.getParam("caseNumber");
        let destinatedId = event.getParam("lookUpId");
        let btnaction = event.getParam("action");
        let lines = component.get("v.selectedList");
        var toastEvent = $A.get("e.force:showToast");
        var caseRecord =component.get("v.caseRecord.CaseNumber");
        if(!$A.util.isEmpty(btnaction) && btnaction === 'Copy Email as Comments'){
            var action = component.get("c.emailToComments");
            action.setParams({
                "recId" : destinatedId,
                "caseNumber" : caseRecord,
                "emails" : lines
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var resp = response.getReturnValue();
                    console.log('resp'+resp);
                    if(resp != null && resp != '' && resp != undefined){
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": resp,
                            "type": "error"
                        });
                    } else{
                        component.set("v.isSuccess",true);
                        component.set("v.selectedCaseNumber",destinatedCase);
                        component.set("v.selectedCaseId",destinatedId);
                    }
                }else{
                    let errors = response.getError();
                    console.log('-------'+JSON.stringify(response.getError()));
                    toastEvent.setParams({
                            "title": "Error!",
                            "message": errors[0].message,
                            "type": "error"
                        });
                }
                toastEvent.fire();
            });
            $A.enqueueAction(action);
        }else if(!$A.util.isEmpty(btnaction) && btnaction === 'Go Back'){
            component.set("v.searchCase",false);
            component.set("v.showTable",true);
            let lines = JSON.parse(component.get("v.selectedList"));
            let rows = [];
            for(var i=0; i < lines.length; i++){
                rows.push(lines[i].Id);
            }
            console.log('$$$$'+rows);
            component.set("v.selectedRows",rows);
        }
    },
    navigateToCase :function(component, event){
        let destinatedId = component.get("v.selectedCaseId");
        if(!$A.util.isEmpty(destinatedId)){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": destinatedId
            });
            navEvt.fire();
        }
    }
})