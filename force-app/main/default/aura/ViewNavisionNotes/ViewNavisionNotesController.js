({
    loadNotesData : function(component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.columnNames', [
            {label: 'Comment Date/Time', fieldName: 'commentStringDateTime', type: 'date',initialWidth:230,typeAttributes: {day: 'numeric',month: 'numeric',year: 'numeric',hour: '2-digit',minute: '2-digit',second: '2-digit',hour12:true}},
                {label: 'Navision Comments', fieldName: 'commentStringDesc', type: 'text',wrapText:true}
            ]);

        var action = component.get("c.getNavisionNotes");
        action.setParams({ 
            issueTrackingNumber : component.get("v.trackingNumber"),
            isFailureTest:false
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseValue = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if(responseValue.data){
                    if(responseValue.data.length===0){
                        component.set('v.showSpinner', false);
                        component.set("v.noRecordsToShow",true);
                    }
                    else{
                        let notesData = responseValue.data;
                        component.set("v.totalPages", Math.ceil(responseValue.data.length / component.get("v.pageSize")));
                            //console.log("countTotalPage: " + countTotalPage);
                            notesData.forEach(function(note){
                            //for avoiding timezone consideration while converting to date format from string
                            let modifiedDate = note.commentStringDateTime.replace(/T/g," ");
                            note.commentStringDateTime = modifiedDate;
                        
                        });
                        component.set("v.allNotes", notesData);
                        //component.set("v.navisionNotes", responseValue.data);)
                        helper.paginateRecords(component);
                        component.set("v.noRecordsToShow",false);
                        component.set('v.showSpinner', false);

                    }
                }
                else if(responseValue.problem!==undefined && responseValue.problem.errors.length!==0){
                    component.set('v.showSpinner', false);
                    component.set("v.noRecordsToShow",true);
                    helper.fireToastEvent(component,responseValue.problem.errors[0].message);
                }
                else{
                    component.set('v.showSpinner', false);
                    component.set("v.noRecordsToShow",true);
                }
            }
            else if(state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.fireToastEvent(component,errors[0].message);
                        component.set("v.IsSpinner" , false);
                    }


                }
            }
        });
        
        $A.enqueueAction(action); 
        component.set('v.isModalOpen', true);
    },
    
    closeNavisionModal: function(component, event, helper) {
        component.set('v.currentPageNumber', 1);
        component.set('v.allNotes', []);
        component.set('v.isModalOpen', false);

    },    
    previousPage: function(component, event, helper) {
        var currentPage = component.get("v.currentPageNumber");
        if (currentPage > 1) {
            component.set("v.currentPageNumber", currentPage - 1);
            helper.paginateRecords(component);
        }
    },
    
    nextPage: function(component, event, helper) {
        var currentPage = component.get("v.currentPageNumber");
        var totalPages = component.get("v.totalPages");
        if (currentPage < totalPages) {
            component.set("v.currentPageNumber", currentPage + 1);
            helper.paginateRecords(component);
        }
    }

})