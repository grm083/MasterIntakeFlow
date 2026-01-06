({
    /*
     * Initially this Method will be called and will fetch the records from the Salesforce Org 
     * Then we will hold all the records into the attribute of Lightning Component
     */
    doFetchCase : function(component) {
        var action = component.get('c.getCaseList');
        
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
                    
                });
                if(res.length > 0) {
                    component.set('v.CaseData', res);    
                    for(var i = 0; i <component.get("v.CaseData").length; i++){
                        if (component.get("v.CaseData").length> i && component.get("v.CaseData")[i].Status == "Open"){
                            selectedList.push(response.getReturnValue()[i]);
                        } 
                        if(component.get("v.CaseData").length> i && component.get("v.CaseData")[i].Status == "Open" && paginationList.length < 15){
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