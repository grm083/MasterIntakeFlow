({
    /*
     * Initially this Method will be called and will fetch the records from the Salesforce Org 
     * Then we will hold all the records into the attribute of Lightning Component
     */
	doFetchTask : function(component) {
		var action = component.get('c.showTeamTasks');
        
       // var urltonavigate = component.get('c.getTeamOpenTaskUrl');
        action.setCallback(this, function(response){
            var state = response.getState();
                 
            if(state === 'SUCCESS' && component.isValid()){
                var pageSize = component.get("v.pageSize");
                 var res = response.getReturnValue();
                // hold all the records into an attribute named "TaskData"
             
                res.forEach(function(record){
                   if(record.WhatId != null){
                    record.RelatedTo = '/'+record.WhatId;                   
                    record.RelatedToName = record.Name ;
                    } 
                    
                    if(record.LocationId != null){
                    record.Location = '/'+record.LocationId;                   
                    record.LocName = record.LocationName ;
                    }
                    record.AssignedTo = '/'+record.ownerId;
                    record.AssigneeName = record.AssigneeName ;
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
               
                component.set('v.PaginationList', PaginationList);
                component.set('v.isSending',false);
            }else{
                alert('An Error Occured...');
            }
            
            
        });
        $A.enqueueAction(action);
      
        var taburl = $A.get("$Label.c.Team_Open_Task_Tab_URL");
        component.set("v.teamOpenTaskUrl",taburl);
        
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
})