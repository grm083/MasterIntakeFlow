({
    init: function (cmp, event, helper) {
     helper.callRefresh(cmp, event, helper);   
     // cmp.set('v.columns', [
     //         { label: 'Action', initialWidth: 120, fieldName: 'Workflow_Action__c', type: 'text'},
     //         { label: 'User/Team', initialWidth: 120, fieldName: 'Workflow_TeamUser__c', type: 'text'},
     //         { label: 'Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
     //                                                                         day: 'numeric',  
     //                                                                         month: 'short',  
     //                                                                         year: 'numeric',  
     //                                                                         hour: '2-digit',  
     //                                                                         minute: '2-digit',  
     //                                                                         hour12: true}},
     //         { label: 'Comments', fieldName: 'Comment__c', type: 'text'},
     //         { label: 'Source', initialWidth: 120, fieldName: 'Communication_Log_Type_Name__c', type: 'text'} 
     //     ]);
     //     var action = cmp.get("c.getAcornComments");
     //     action.setParams({ 
     //         caseId : cmp.get("v.recordId")
     //     });
     //     action.setCallback(this, function(response){
     //         var state = response.getState();
     //         if (state === "SUCCESS") {
     //             cmp.set("v.notes", response.getReturnValue());
     //         }
     //         //event.getSource().set("v.isLoading", false);
     //     });
     //     $A.enqueueAction(action);
     },
/*
    oncaserecordloaded : function (cmp, event, helper) { 
        
        var changeType = event.getParams().changeType;
		//console.log('testing>>>'+changeType);
       // cmp.set("v.isPortalButtonActive",false);
    	if (changeType  !== "ERROR") { 
           cmp.set('v.isPortalButtonActive',false);
        }
        
   	 //Other Evenets  LOADED,REMOVED,CHANGED
    
    },
    
    */
    
     handleClick : function (cmp, event, helper) {
        var action = cmp.get("c.returnTwoWayResponse");
          action.setParams({ 
              caseId : cmp.get("v.recordId")
          });         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var responseValue= response.getReturnValue();
                if(responseValue.isTwoWayCommunication === true) {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:TwoWayCommunication",
                        componentAttributes: {
                            caseId : cmp.get("v.recordId"),
                            caseOrigin : responseValue.caseOrigin,
                        }
                    });
                    evt.fire();
                }
                else {
                    var portal_link = cmp.get('v.url.Portal_Messages_URL__c');
                    window.open(portal_link, '_blank');  
                }
            }
            
        });
        $A.enqueueAction(action);
    },
     getComment : function (cmp, event, helper) {
        try{
         var selectedRows = event.getParam('selectedRows');
         var commentId = selectedRows[0].Id;
         var editRecordEvent = $A.get("e.force:editRecord");
         editRecordEvent.setParams({
             "recordId": commentId
         });
         editRecordEvent.fire();
         }
         catch(e){
             console.log('error '+e);
         }
 
     },
     onTabClosed : function (cmp, event, helper) {
         var tabId = event.getParam('tabId');
         console.log("tabId " +tabId);
         helper.confirmExit(cmp, event, helper);
     },
 
     onTabFocus : function (cmp, event, helper) {
         var workspaceAPI = cmp.find("workspace");
         var focusedTabId = event.getParam('currentTabId');
         var prevTabId = event.getParam('previousTabId');
         
         helper.confirmExit(cmp, event, helper);
         
         workspaceAPI.getTabInfo({
                 tabId : focusedTabId
             }).then(function(response) {
                 if(response != null){
                     if(response.recordId.startsWith('500')) {
                         helper.callRefresh(cmp, event, helper);  
                         cmp.set("v.focusedTabIsCase",true);
                     }
                 }
                 else {
                     cmp.set("v.focusedTabIsCase",false);
                     helper.confirmExit(cmp, event, helper);
                 }
             
             }).catch(function(error) {
                 cmp.set("v.focusedTabIsCase",false);
             });       
     },
     handleCommentClick: function (component, event, helper) {
         var recId = event.currentTarget.dataset.id;
         if(recId != null){
             var navEvt = $A.get("e.force:navigateToSObject");
             navEvt.setParams({
             "recordId": recId,
             "slideDevName": "Detail"
             });
             navEvt.fire();
         }
     },
     showHover: function (component, event, helper) {
         var recId = event.currentTarget.dataset.id;
         var objecttype = '';
         var title = '';
         var left = event.srcElement.getBoundingClientRect().left + window.scrollX;
         var top = event.srcElement.getBoundingClientRect().top + window.scrollY;
         console.log('left : '+ left);
         console.log('top : '+ top);
         component.set("v.showHover" , true);
         if(recId != null) {
             if(recId.startsWith('0WO')){
                 objecttype = 'WorkOrder';
                 title = 'Work Order';
             } else if(recId.startsWith('00T')) {
                 objecttype = 'Task';
                 title = 'Task';
             } else if(recId.startsWith('02s')) {
                 objecttype = 'EmailMessage';
                 title = 'Email';
             }    
         }
         helper.hovercall(component, objecttype, recId, title , 'hoverCmp', left, top);
         
     },
     hideHover: function (component, event, helper) {
        var recId = event.currentTarget.dataset.id;
        if(recId != null) {
            if(!recId.startsWith('02s')) {
                console.log('hide');
                component.set("v.showHover" , false);
            }    
        }
     },
 
     showComments : function (cmp, event, helper) {
         var evt = $A.get("e.force:navigateToComponent");
         evt.setParams({
         componentDef : "c:customCaseCommentAura",
         componentAttributes: {
             caseId : cmp.get("v.recordId"),
         }
         
     });
     evt.fire();
     },

     sortColumn: function (cmp, event, helper) {
        cmp.set("v.loadingSpinner", true);
        cmp.set("v.sortAsc" , !cmp.get("v.sortAsc"));
        if(event.target.name != cmp.get("v.sortCol")){
            cmp.set("v.sortAsc" , true);
        }
        cmp.set("v.sortCol" , event.target.name);
        try{
            var action = cmp.get("c.getCommentData");
            action.setParams({ 
                caseId : cmp.get("v.recordId"),
                size : 500,
                sortAsc : cmp.get("v.sortAsc"),
                sortColumn : event.target.name
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.notes", response.getReturnValue());
                }
                //event.getSource().set("v.isLoading", false);
                cmp.set("v.loadingSpinner", false);
            });
            $A.enqueueAction(action);
            }
        catch(e){
            console.log(e);   
        }
    }    
 
 })