({
    /*
     * Initially this Method will be called and will fetch the records from the Salesforce Org 
     * Then we will hold all the records into the attribute of Lightning Component
     */
	doFetchTask : function(component) {
         this.getUserTime(component);
        component.set('v.isSending',true);
		var action = component.get('c.getSFDCTeamTask');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var pageSize = component.get("v.pageSize");
                 var res = response.getReturnValue();
              //  alert(JSON.stringify(res));
                
             
                res.forEach(function(record){
                     if(record.WhatId != null){
                    record.RelatedTo = '/'+record.WhatId;                   
                    record.RelatedToName = record.Name ;
                    } 
                    
                    if(record.LocationId != null){
                    record.Location = '/'+record.LocationId;                   
                    record.LocName = record.LocationName ;
                    }
                  
                    record.SubjectId = '/'+record.TaskId;
                    record.Subject = record.Subject ;
                    if(record.Subject == null){
                        record.Subject = 'Task' ;
                    }
                });
                if(res.length > 0) {
                component.set('v.TaskData', res);
                // get size of all the records and then hold into an attribute "totalRecords"
                component.set("v.totalRecords", component.get("v.TaskData").length);
                // set star as 0
                component.set("v.startPage",0);
                component.set("v.hideNoRecordSection" , false);
                
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.TaskData").length> i)
                        PaginationList.push(response.getReturnValue()[i]);    
                }}
                else {
                    component.set("v.noRecordsFound" , true);
                }
                component.set('v.PaginationList', PaginationList);
                component.set('v.isSending',false);
            }else{
                alert('ERROR');
            }
        });
        $A.enqueueAction(action);
	},
    /*
     * Method will be called when use clicks on next button and performs the 
     * calculation to show the next set of records
     */
    next : function(component, event){
        var sObjectList = component.get("v.TaskData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    /*
     * Method will be called when use clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    previous : function(component, event){
        var sObjectList = component.get("v.TaskData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    
    handleSort: function(component, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = component.get('v.PaginationList');
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        component.set('v.PaginationList', cloneData);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
    },
    
    sortBy: function (field, reverse, primer) {
         if(field === 'SubjectId'){
            field = 'Subject';
        }
        var key = primer ? function(x) {
                            return primer(x[field]);
                            }
                        : function(x) {
                        return x[field];
                        };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
     sfdcTeamChange : function (component, event, helper) {
         
            component.set("v.salesforceTeam",wrapper.sfdcTeams);
            },
     getUserTeamAcess : function (component, event, helper) {
         var action = component.get('c.getSFDCTeamAcess');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
            component.set("v.salesforceTeam",response.getReturnValue());
                if(component.get("v.salesforceTeam").length > 1){
                     component.set("v.showSfdcFilter",true);
                }
                
                
                
            }
            });
          $A.enqueueAction(action);
        },
    doFetchTaskWithFilter : function(component) {
        this.getUserTime(component);
        component.set('v.isSending',true);
        var action = component.get('c.getSFDCTeamTaskWithFilter'); 
	  action.setParams({
            "userSelectedTeam" : component.get("v.selectedSfdcTeam")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var pageSize = component.get("v.pageSize");
                 var res = response.getReturnValue();
                
             
                res.forEach(function(record){
                     if(record.WhatId != null){
                    record.RelatedTo = '/'+record.WhatId;                   
                    record.RelatedToName = record.Name ;
                    } 
                    
                    if(record.LocationId != null){
                    record.Location = '/'+record.LocationId;                   
                    record.LocName = record.LocationName ;
                    }
                  
                    record.SubjectId = '/'+record.TaskId;
                    record.Subject = record.Subject ;
                    if(record.Subject == null){
                        record.Subject = 'Task' ;
                    }
                });
                if(res.length > 0) {
                component.set('v.TaskData', res);
                // get size of all the records and then hold into an attribute "totalRecords"
                component.set("v.totalRecords", component.get("v.TaskData").length);
                // set star as 0
                component.set("v.startPage",0);
                component.set("v.hideNoRecordSection" , false);
                
                component.set("v.endPage",pageSize-1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.TaskData").length> i)
                        PaginationList.push(response.getReturnValue()[i]);    
                }}
                else {
                    component.set("v.noRecordsFound" , true);
                }
                component.set('v.PaginationList', PaginationList);
                component.set('v.isSending',false);
            }else{
                alert('ERROR');
            }
        });
        $A.enqueueAction(action);
	},
     getUserTime : function (component) {
         component.set('v.isSending',true);
         var action = component.get('c.getUserTimeZone');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
            component.set("v.userTimezone",response.getReturnValue());
                 component.set('v.isSending',false);
            component.set('v.columns', [
            {label: 'Task Type', fieldName: 'SubjectId', type: 'url', 
             typeAttributes: {label: { fieldName: 'Subject' } ,target: '_parent'},sortable : true},
            {label: 'Task Due', fieldName: 'dueDate', type: 'date', typeAttributes: { 
                month: 'numeric',
                day: 'numeric',   
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                hour12: true,
               timeZone: component.get('v.userTimezone')
            },sortable : true},
            {label: 'Task Comment', fieldName: 'taskComment', type: 'textArea',sortable : true},                                                               
            {label: 'Case Creation Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { 
                month: 'numeric',
                day: 'numeric',   
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                hour12: true},sortable : true},
            {label: 'Case', fieldName: 'RelatedTo', type: 'url', 
             typeAttributes: {label: { fieldName: 'RelatedToName' } ,target: '_parent'},sortable : true},
            {label: 'Case Type', fieldName: 'CaseType', type: 'text', sortable : true},
            {label: 'Case Sub-Type', fieldName: 'CaseSubType', type: 'text', sortable : true},
            {label: 'Case Service Date', fieldName: 'caseServiceDate', type: 'date-local',sortable : true},
            {label: 'Vendor Account Name ', fieldName: 'vendorAccountName', type: 'textArea',sortable : true},
            {label: 'Location', fieldName: 'Location', type: 'url', 
             typeAttributes: {label: { fieldName: 'LocName' } ,target: '_parent'},sortable : true},
            //SDT-34542 - start
            // {label: 'From Address ', fieldName: 'FromAddress', type: 'textArea',sortable : true},
            // {label: 'To Address ', fieldName: 'ToAddress', type: 'textArea',sortable : true},
            // {label: 'Case Status ', fieldName: 'CaseStatus', type: 'textArea',sortable : true},
            // {label: 'Case Sub Status ', fieldName: 'CaseSubStatus', type: 'textArea',sortable : true},
            // {label: 'Message Status ', fieldName: 'MessageStatus', type: 'textArea',sortable : true},
            // {label: 'Message Date ', fieldName: 'MessageDate',  type: 'date', typeAttributes: { 
            //     month: 'numeric',
            //     day: 'numeric',   
            //     year: 'numeric',  
            //     hour: '2-digit',  
            //     minute: '2-digit',  
            //     hour12: true},sortable : true}
            //SDT-34542  -end
               
        ]);
            }
            });
          $A.enqueueAction(action); 
        }
  
})