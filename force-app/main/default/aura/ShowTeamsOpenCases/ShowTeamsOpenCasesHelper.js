({
    
    doFetchCase : function(component) {
        var action = component.get('c.getTeamCasesList');
        // var urltonavigate = component.get('c.getOpenTaskUrl');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var pageSize = component.get("v.pageSize");
                var res = response.getReturnValue();
                var paginationList = [];
                var selectedList =[];
                
                res.forEach(function(record){
                    record.Id = '/'+record.Id;
                    record.CaseNumber = record.CaseNumber ;
                    record.OwnerId = '/'+record.OwnerId;
                    record.CaseOwner = record.Owner.Name ;
                    if(record.User_Name__c == 'undefined' || record.User_Name__c == null )
                    {
                        record.UserName= ''; 
                    }
                    else
                    {
                        record.UserId = '/'+record.User_Name__c;
                        record.UserName = record.User_Name__r.Name;  
                    }
                });
                
                if(res.length > 0) {
                    component.set('v.CaseData', res);    
                    for(var i = 0; i <component.get("v.CaseData").length; i++){
                        if (component.get("v.CaseData").length> i && component.get("v.CaseData")[i].Status == "Open"){
                            selectedList.push(response.getReturnValue()[i]);
                        }
                        if(component.get("v.CaseData").length> i && component.get("v.CaseData")[i].Status == "Open" && paginationList.length < 4){
                            paginationList.push(response.getReturnValue()[i]); 
                        
                    }}
                }
                if(paginationList.length >0)
                { 
                    component.set("v.hideNoRecordSection" , false);
                    component.set('v.paginationList', paginationList);
                    component.set("v.totalRecords", selectedList.length);    
                    component.set('v.pageLoadList',selectedList);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize);
                }
                
                component.set('v.isSending',false);
            }
            
        });
        $A.enqueueAction(action);
        
        var tabName = $A.get("$Label.c.Team_Open_Case_Tab_URL");
        component.set('v.teamOpenCaseTabUrl', tabName);
        
        
    },
    /*
     * Method will be called when use clicks on next button and performs the 
     * calculation to show the next set of records
     */
    next : function(component, event){
        var sObjectList = component.get("v.pageLoadList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i=end; i<end+pageSize; i++){
            if(sObjectList.length > i){
                paginationList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.paginationList', paginationList);
    },
    /*
     * Method will be called when use clicks on previous button and performs the 
     * calculation to show the previous set of records
     */
    previous : function(component, event){
        var sObjectList = component.get("v.pageLoadList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.paginationList', paginationList);
    },
})