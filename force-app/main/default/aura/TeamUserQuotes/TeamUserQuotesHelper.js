({
    
    doFetchTask : function(component) {
         this.getUserTime(component);
        //  alert(component.get("v.OpenTaskTabUrl"));
        var action = component.get('c.getSFDCTeamQuotes');
        // var urltonavigate = component.get('c.getOpenTaskUrl');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                
                var pageSize = component.get("v.pageSize");
                var res = response.getReturnValue();
                console.log( 'Qresponse' +JSON.stringify(res));
               // alert(res);
                
                res.forEach(function(record){
                    
                        record.IdLink = '/'+record.Id; 
                        record.accountLink = '/'+record.SBQQ__Account__c;
                        record.accountName =  record.SBQQ__Account__r.Name;
                       // record.RelatedToName = record.Name ;
                   
                    
                    if(record.LocationId != null){
                        record.Location = '/'+record.LocationId;                   
                        record.LocName = record.LocationName ;
                    }
                    
                   // record.SubjectId = '/'+record.TaskId;
                   // record.Subject = record.Subject ;
                    if(record.Subject == null){
                        record.Subject = 'Task' ;
                    }
                });
                
                if(res.length > 0) {
                    component.set('v.QuoteData', res);              
                    component.set("v.totalRecords", component.get("v.QuoteData").length);
                    
                    component.set("v.startPage",0);
                    component.set("v.hideNoRecordSection" , false);
                    component.set("v.endPage",pageSize);
                    
                    var PaginationList = [];
                    
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.QuoteData").length> i)
                            PaginationList.push(response.getReturnValue()[i]); 
                        
                    }}
                
                component.set('v.PaginationList', PaginationList);
                component.set('v.isSending',false);
            }
            
        });
        $A.enqueueAction(action);
        
        var tabName = $A.get("$Label.c.open_Team_Quote");
        component.set('v.OpenQuoteTabUrl', tabName);
        
        
    },
    /*
     * Method will be called when use clicks on next button and performs the 
     * calculation to show the next set of records
     */
    next : function(component, event){
        var sObjectList = component.get("v.QuoteData");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end; i<end+pageSize; i++){
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
        var sObjectList = component.get("v.QuoteData");
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
      getUserTime : function (component) {
         component.set('v.isSending',true);
         var action = component.get('c.getUserTimeZone');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
            component.set("v.userTimezone",response.getReturnValue());
                 component.set('v.isSending',false);
            component.set('v.columns', [
            {label: 'Quote Number', fieldName: 'IdLink', type: 'url', 
             typeAttributes: {label: { fieldName: 'Name' } ,target: '_parent'},sortable : true},
                {label: 'Priority', fieldName: 'Priority__c', type: 'text', sortable : true},
            {label: 'Status', fieldName: 'SBQQ__Status__c', type: 'text', sortable : true},
                 {label: 'Action Type', fieldName: 'Action_Type__c', type: 'text', sortable : true},
                {label: 'Action Reason', fieldName: 'Action_Reason__c', type: 'text', sortable : true},
            {label: 'Start Date', fieldName: 'SBQQ__StartDate__c', type: 'date-local',sortable : true},
                          {label: 'Account', fieldName: 'accountLink', type: 'url', 
             typeAttributes: {label: { fieldName: 'accountName' } ,target: '_parent'},sortable : true}
        ]);
            }
            });
          $A.enqueueAction(action); 
        }
  
})