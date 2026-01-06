({
    updateChartTableDataTabSelect: function (component, event, helper) {
        
        var childComp = component.find('childComp');
        childComp.callChild("Tab Event");
        
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    sortData: function (component, event, helper,numOfVendorDisplayed) {
        
        var data = [];
        var selectedAccountType = component.get("v.selTabId");
        var chartMap = new Map();
        var totalAccountMap = new Map();
        var dataWrapper = new Map();
        var dataList = [];
        //var dataWrapper = [];
        var userTypeSelected = component.get("v.selectedUserView");
        var accountTypeServiceSelected = component.get("v.taskType");
        
        component.set("v.VendorSortedData",null);
        if(selectedAccountType == 'parentVendor'){
            dataList = component.get("v.parentVendorData");
            if(component.get("v.parentVendorMap")== null){
                for(var i = 0; i < dataList.length; i++){
                    data.push(dataList[i]);
                    totalAccountMap.set(dataList[i].AccountName ,dataList[i]);
                    
                }
                component.set("v.parentVendorMap",totalAccountMap);
            }
            
            else {
                totalAccountMap = component.get("v.parentVendorMap"); 
                data = dataList ;
            }
            var count = 0;
            //var data = component.get("v.data");
            if(userTypeSelected == "Genesys Integration" && userTypeSelected != "All" ){
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                                taskList.push(data[i].tasklist[k]);
                            }  
                            
                        }
                        if(count > 0){
                            var wrapper = { 'acc' : data[i].AccountName,
                                           'tasklist' : taskList ,
                                           'accRecord' : data[i].accRecord ,
                                           'ast' : data[i].ast
                                          };                  
                            chartMap.set(data[i].AccountName,count);
                            dataWrapper.set(data[i].AccountName ,wrapper);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                                taskList.push(data[i].tasklist[k]);
                            }   
                            
                        }
                        if(count > 0){                        
                            var wrapper = { 'acc' : data[i].AccountName,
                                           'tasklist' : taskList,
                                           'accRecord' : data[i].accRecord ,
                                           'ast' : data[i].ast
                                          };                  
                            chartMap.set(data[i].AccountName,count);
                            dataWrapper.set(data[i].AccountName ,wrapper);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    count=count+1;
                                    taskList.push(data[i].tasklist[k]); 
                                }   
                                
                            }
                            if(count > 0){                        
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
            }
            else if (userTypeSelected == "Others") {
                if(userTypeSelected != "" && userTypeSelected != "Reload"){
                    component.set('v.userName',userTypeSelected);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                                taskList.push(data[i].tasklist[k]);
                            }  
                            
                        }
                        if(count > 0){                       
                            var wrapper = { 'acc' : data[i].AccountName,
                                           'tasklist' : taskList,
                                           'accRecord' : data[i].accRecord ,
                                           'ast' : data[i].ast
                                          };                  
                            chartMap.set(data[i].AccountName,count);
                            dataWrapper.set(data[i].AccountName ,wrapper);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        for(var k = 0; k < data[i].tasklist.length; k++){
                        if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                            count=count+1;
                            taskList.push(data[i].tasklist[k]);
                        }   
                        } 

                    if(count > 0){                        
                        var wrapper = { 'acc' : data[i].AccountName,
                                       'tasklist' : taskList ,
                                       'accRecord' : data[i].accRecord ,
                                       'ast' : data[i].ast
                                      };                  
                        chartMap.set(data[i].AccountName,count);
                        dataWrapper.set(data[i].AccountName ,wrapper);
                    }}
                }
                
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                    count=count+1;
                                    taskList.push(data[i].tasklist[k]);
                                }  
                                
                            }
                            if(count > 0){                        
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
            }
                else if (userTypeSelected == "All" || userTypeSelected == "Reload") {
                    if(userTypeSelected != "" && userTypeSelected != "Reload"){
                        component.set('v.userName',userTypeSelected);
                    }
                    if(accountTypeServiceSelected == "Project Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                    count=count+1;
                                    taskList.push(data[i].tasklist[k]);
                                }     
                                
                            }
                            if(count > 0){                        
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                    count=count+1;
                                    taskList.push(data[i].tasklist[k]);
                                }    
                                
                            }
                            if(count > 0){                        
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            dataset = component.get("v.parentVendorDataCount");
                        }
                } }
        
        else if(selectedAccountType == 'vendor'){
            
            dataList = component.get("v.vendorData");
            if(component.get("v.vendorMap")== null){
                for(var i = 0; i < dataList.length; i++){
                    data.push(dataList[i]);
                    totalAccountMap.set(dataList[i].AccountName ,dataList[i]);
                    component.set("v.vendorMap" ,totalAccountMap)
                }
            }
            else{
                totalAccountMap = component.set("v.vendorMap");
                data = dataList ;
            }
            var count = 0;
            //var data = component.get("v.data");
            if(userTypeSelected == "Genesys Integration" && userTypeSelected != "All" ){
                
                if(userTypeSelected != "" && userTypeSelected != "Reload"){
                    component.set('v.userName',userTypeSelected);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            
                            
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                taskList.push(data[i].tasklist[k]);
                                count=count+1;
                            }  
                            
                        }
                        if(count > 0){
                            
                            var wrapper = { 'acc' : data[i].AccountName,
                                           'tasklist' : taskList ,
                                           'accRecord' : data[i].accRecord ,
                                           'ast' : data[i].ast
                                          };                  
                            chartMap.set(data[i].AccountName,count);
                            dataWrapper.set(data[i].AccountName ,wrapper);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                taskList.push(data[i].tasklist[k]);
                                count=count+1;
                            }    
                            
                        }
                        if(count > 0){
                            var wrapper = { 'acc' : data[i].AccountName,
                                           'tasklist' : taskList ,
                                           'accRecord' : data[i].accRecord ,
                                           'ast' : data[i].ast
                                          };                  
                            chartMap.set(data[i].AccountName,count);
                            dataWrapper.set(data[i].AccountName ,wrapper);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    taskList.push(data[i].tasklist[k]);
                                    count=count+1;
                                }
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
            }
            else if (userTypeSelected == "Others") {
                if(userTypeSelected != "" && userTypeSelected != "Reload"){
                    component.set('v.userName',userTypeSelected);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                taskList.push(data[i].tasklist[k]);
                                count=count+1;
                            }    
                            
                        }
                        if(count > 0){
                            var wrapper = { 'acc' : data[i].AccountName,
                                           'tasklist' : taskList ,
                                           'accRecord' : data[i].accRecord ,
                                           'ast' : data[i].ast
                                          };                  
                            chartMap.set(data[i].AccountName,count);
                            dataWrapper.set(data[i].AccountName ,wrapper);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        var taskList = [];
                        
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                taskList.push(data[i].tasklist[k]);
                                count=count+1;
                            }    
                            
                        }
                        if(count > 0){
                            var wrapper = { 'acc' : data[i].AccountName,
                                           'tasklist' : taskList ,
                                           'accRecord' : data[i].accRecord ,
                                           'ast' : data[i].ast
                                          };                  
                            chartMap.set(data[i].AccountName,count);
                            dataWrapper.set(data[i].AccountName ,wrapper);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                    taskList.push(data[i].tasklist[k]);
                                    count=count+1;
                                }    
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              }; 
                                
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
            }
                else if (userTypeSelected == "All" || userTypeSelected == "Reload") {
                    if(userTypeSelected != "" && userTypeSelected != "Reload"){
                        component.set('v.userName',userTypeSelected);
                    }
                    
                    if(accountTypeServiceSelected == "Project Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                    taskList.push(data[i].tasklist[k]);
                                    count=count+1;
                                }    
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                    taskList.push(data[i].tasklist[k]);
                                    
                                    count=count+1;
                                }   
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                    
                        else if(accountTypeServiceSelected == "All"){
                            
                            for (var i = 0; i < data.length; i++) {
                                count = 0;
                                var taskList = [];
                                for(var k = 0; k < data[i].tasklist.length; k++){
                                    
                                    if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                        taskList.push(data[i].tasklist[k]);
                                        count=count+1;
                                    }    
                                    
                                }
                                if(count > 0){
                                    var wrapper = { 'acc' : data[i].AccountName,
                                                   'tasklist' : taskList ,
                                                   'accRecord' : data[i].accRecord ,
                                                   'ast' : data[i].ast
                                                  };                  
                                    chartMap.set(data[i].AccountName,count);
                                    dataWrapper.set(data[i].AccountName ,wrapper);
                                }
                            }
                        }
                    
                }}
        
            else if(selectedAccountType == 'location'){
                dataList = component.get("v.locationData");
                
                if(component.get("v.locationMap")== null){
                    for(var i = 0; i < dataList.length; i++){
                        data.push(dataList[i]);
                        totalAccountMap.set(dataList[i].AccountName ,dataList[i]);                   
                    }
                    component.set("v.locationMap" ,totalAccountMap)
                }
                
                else{
                    totalAccountMap = component.set("v.locationMap");
                    data = dataList ;
                }
                
                var count = 0;
                //var data = component.get("v.data");
                if(userTypeSelected == "Genesys Integration" && userTypeSelected != "All" ){
                    
                    if(userTypeSelected != "" && userTypeSelected != "Reload"){
                        component.set('v.userName',userTypeSelected);
                    }
                    
                    if(accountTypeServiceSelected == "Project Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                    taskList.push(data[i].tasklist[k]);
                                    count=count+1;
                                }   
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                    taskList.push(data[i].tasklist[k]);
                                    count=count+1;
                                }    
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            for (var i = 0; i < data.length; i++) {
                                count = 0;
                                var taskList = [];
                                for(var k = 0; k < data[i].tasklist.length; k++){
                                    
                                    if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                        taskList.push(data[i].tasklist[k]);
                                        count=count+1;
                                    }    
                                    
                                }
                                if(count > 0){
                                    var wrapper = { 'acc' : data[i].AccountName,
                                                   'tasklist' : taskList ,
                                                   'accRecord' : data[i].accRecord ,
                                                   'ast' : data[i].ast
                                                  };                  
                                    chartMap.set(data[i].AccountName,count);
                                    dataWrapper.set(data[i].AccountName ,wrapper);
                                }
                            }
                        }
                }
                else if (userTypeSelected == "Others") {
                    if(userTypeSelected != "" && userTypeSelected != "Reload"){
                        component.set('v.userName',userTypeSelected);
                    }
                    
                    if(accountTypeServiceSelected == "Project Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                    taskList.push(data[i].tasklist[k]);
                                    count=count+1;
                                }   
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            var taskList = [];
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                
                                if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                    taskList.push(data[i].tasklist[k]);
                                    count=count+1;
                                }    
                                
                            }
                            if(count > 0){
                                var wrapper = { 'acc' : data[i].AccountName,
                                               'tasklist' : taskList ,
                                               'accRecord' : data[i].accRecord ,
                                               'ast' : data[i].ast
                                              };                  
                                chartMap.set(data[i].AccountName,count);
                                dataWrapper.set(data[i].AccountName ,wrapper);
                            }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            
                            for (var i = 0; i < data.length; i++) {
                                count = 0;
                                var taskList = [];
                                for(var k = 0; k < data[i].tasklist.length; k++){
                                    
                                    if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                        taskList.push(data[i].tasklist[k]);
                                        count=count+1;
                                    }   
                                    
                                }
                                if(count > 0){
                                    var wrapper = { 'acc' : data[i].AccountName,
                                                   'tasklist' : taskList ,
                                                   'accRecord' : data[i].accRecord ,
                                                   'ast' : data[i].ast
                                                  };                  
                                    chartMap.set(data[i].AccountName,count);
                                    dataWrapper.set(data[i].AccountName ,wrapper);
                                }
                            }
                        }
                }
                    else if (userTypeSelected == "All" || userTypeSelected == "Reload") {
                        if(userTypeSelected != "" && userTypeSelected != "Reload"){
                            component.set('v.userName',userTypeSelected);
                        }
                        if(accountTypeServiceSelected == "Project Services"){
                            for (var i = 0; i < data.length; i++) {
                                count = 0;
                                var taskList = [];
                                for(var k = 0; k < data[i].tasklist.length; k++){
                                    
                                    if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                        taskList.push(data[i].tasklist[k]); 
                                        count=count+1;
                                    }     
                                    
                                }
                                if(count > 0){
                                    var wrapper = { 'acc' : data[i].AccountName,
                                                   'tasklist' : taskList ,
                                                   'accRecord' : data[i].accRecord ,
                                                   'ast' : data[i].ast
                                                  };                  
                                    chartMap.set(data[i].AccountName,count);
                                    dataWrapper.set(data[i].AccountName ,wrapper);
                                }
                            }
                        }
                        else if(accountTypeServiceSelected == "Customer Services"){
                            for (var i = 0; i < data.length; i++) {
                                count = 0;
                                var taskList = [];
                                for(var k = 0; k < data[i].tasklist.length; k++){
                                    
                                    if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                        taskList.push(data[i].tasklist[k]);
                                        count=count+1;
                                    }    
                                    
                                }
                                if(count > 0){
                                    var wrapper = { 'acc' : data[i].AccountName,
                                                   'tasklist' : taskList ,
                                                   'accRecord' : data[i].accRecord ,
                                                   'ast' : data[i].ast
                                                  };                  
                                    chartMap.set(data[i].AccountName,count);
                                    dataWrapper.set(data[i].AccountName ,wrapper);
                                }
                            }
                        }
                        
                            else if(accountTypeServiceSelected == "All"){
                                for (var i = 0; i < data.length; i++) {
                                    
                                }
                            }
                        
                    }}
        
        var a = [];
        for(var x of chartMap) 
            a.push(x);
        
        a.sort(function(x, y) {
            return y[1] - x[1];
        });  
        
        var sorted = new Map(a);
        var vendorNames = Array.from(sorted.keys());
        vendorNames = vendorNames.slice(0,numOfVendorDisplayed);
        var accList = [];
        var countOfTask = [];
        for(var k = 0; k < numOfVendorDisplayed ; k++){
            var map = vendorNames[k] ;
            countOfTask.push(sorted.get(map));
            if(map != undefined){
                //accList.push(totalAccountMap.get(map));
                accList.push(dataWrapper.get(map)); 
            }
        }
        component.set("v.VendorSortedData",accList);
        var graphLimit = countOfTask[0];  
        this.generateChart(component,countOfTask,vendorNames,graphLimit);
    },
    generateChart: function (component,dataset,datalabel,xAxisLimit) {
        if(xAxisLimit == 1){
            xAxisLimit = 2 ;
        }
        if(xAxisLimit == 0){
            xAxisLimit = 2 ;
        }
        new Highcharts.Chart({
            chart: {
                type: 'bar',
                marginLeft: 150,
                renderTo: component.find("chart").getElement(),
            },
            title: {
                text: 'Task Count'
            },
            subtitle: {
                text: ''
            },
            colors: [
                "rgb(122, 184, 0)"
            ],
            xAxis: {
                type: 'category',
                title: {
                    text: null
                },
                min: 0,
                max: 4,
                categories: datalabel,
                scrollbar: {
                    enabled: true
                },
                tickLength: 0
            },
            yAxis: {
                min: 0,
                max: xAxisLimit,
                
                title: {
                    text: 'Count of Tasks',
                    align: 'high'
                }
            },
            plotOptions: {
                bar: {
                    dataLabels: {
                        enabled: true
                    }
                },
                series: {
                    cursor: 'pointer',
                    point: {
                        events: {
                            click: function() {
                                
                                var childComp = component.find('childComp');
                                childComp.callChild(this.category);
                            }
                        }
                    }
                }
            },
            legend: {
                enabled: false
            },
            credits: {
                enabled: false
            },
            series: [{
                name: 'Count of Tasks',
                data: dataset 
            }]
        });
        
        return component.Chart ;
    }
})