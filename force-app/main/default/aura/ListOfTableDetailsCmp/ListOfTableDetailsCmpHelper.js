({
    Init : function(component, event, helper,message) {
      
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objDetail");
                
        var pageSize = component.get("v.pageSize");
        var taskData = component.get("v.data");
       // component.set('v.PaginationList', null);
        if(taskData != undefined){
            component.set("v.totalRecords", taskData.length);
        }
        component.set("v.startPage",0);
        component.set("v.endPage",pageSize);
        var PaginationList = [];
        if((message == "Tab Event") || (message == "")){
            
            for(var i=0; i< pageSize; i++){
                if( taskData != undefined && component.get("v.totalRecords")> i ) {
                    PaginationList.push(taskData[i]); 
                }
            }
        }
        else {
            
            for(var i=0; i< component.get("v.totalRecords"); i++){
                if(taskData[i].acc == message){
                    var disableNext = component.get("v.totalRecords")+1;
                    component.set("v.endPage",disableNext);
                    PaginationList.push(taskData[i]); 
                }
            }
            
        }
        if(component.get("v.isFirstTime")){
            var action = component.get("c.getDependentMap");
        action.setParams({
            'objDetail' : objDetails,
            'contrfieldApiName': controllingFieldAPI,
            'depfieldApiName': dependingFieldAPI 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                component.set("v.isFirstTime",false)
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.dependentFieldMap",StoreResponse);
               
                component.set('v.PaginationList', PaginationList);
                component.set('v.isRowSelected',"true");
                
            }
        });
        $A.enqueueAction(action);
        }
        else {
            component.set('v.PaginationList', PaginationList);
            component.set('v.isRowSelected',"true");
            component.set('v.loaded',false);    
            var vx = component.get("v.spinnerFunctionClose");
            //fire event from child and capture in parent
            $A.enqueueAction(vx);
        }
    },
    
    userPressHelper : function(component, event, helper){
        
        var selectedRows = component.get('v.selectedRows');
        var selectedRowMap = [];
        var columnName = component.get('v.columns');
        var dataValue = component.get('v.PaginationList');
        var dataMap = [];
        
        for(var key in selectedRows){
            selectedRowMap.push(selectedRows[key]);
        }
        
        for(var key in dataValue){
            for(var taskKey in dataValue[key].tasklist){
                if(!dataValue[key].tasklist[taskKey].acc){
                    var wrapper = { 'acc' : dataValue[key].tasklist[taskKey]
                                  };
                    dataValue[key].tasklist.splice(taskKey,1,wrapper);
                }
                for(var selected in selectedRowMap){
                    if(dataValue[key].tasklist[taskKey].acc.TaskId === selectedRowMap[selected].acc.TaskId){
                        dataValue[key].tasklist[taskKey].acc.AssignedTo = component.get('v.selectedLookUpRecord.Id');
                        dataValue[key].tasklist[taskKey].acc.AssignedToName = component.get('v.selectedLookUpRecord.Name');
                    }
                }
            }
            dataMap.push(dataValue[key]);
            //var callChildDashboard = component.find("dashboardChild");
            //callChildDashboard["0"].sampleMethod();
        }
        
        component.set('v.PaginationList', dataMap);
        
    },
    
    next : function(component, event){
        var sObjectList = component.get("v.data");
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
        var sObjectList = component.get("v.data");
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
    }
})