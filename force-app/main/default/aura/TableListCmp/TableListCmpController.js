({
    doInit : function(component, event, helper) {
        var selectedAccountType = component.get("v.accountType");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        var act = component.get("c.getCurrentLoggedInUser");
        act.setParams(
            {
                "currentUserId":userId
            }
        );
        
        act.setCallback(this,function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var currentUserRoleName = a.getReturnValue();
                component.set("v.currentLoggedInUserRole",currentUserRoleName.currentUserRole);
            }
        }); 
        
        $A.enqueueAction(act);
        
        var vendorData = [];
        var vendor = [];
        var vendorDataCount = [];
        var dataWrapper = [] ;
        component.set('v.loaded', true);
        var actionVendor = component.get("c.getAccountDetails");
        actionVendor.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                //var allAccountTask = JSON.parse(response.getReturnValue());
                var allAccountTask = response.getReturnValue();
                var columnsMap = [];
                for(var i=0;i<allAccountTask.column.length;i++){
                    columnsMap.push({label:allAccountTask.column[i], fieldName:allAccountTask.fieldAPIName[i]});
                }
                
                for(var key in allAccountTask.vendor){
                    vendorData.push(allAccountTask.vendor[key]);
                    vendor.push(allAccountTask.vendor[key].AccountName);
                    vendorDataCount.push(allAccountTask.vendor[key].count);
                }
                component.set("v.vendorData", vendorData);
                component.set("v.vendor", vendor);
                component.set("v.vendorDataCount",vendorDataCount);
                component.set("v.columns", columnsMap);
                var vendorData_Top = vendorData.slice(0, 5);
                
                for (var i = 0; i < vendorData_Top.length; i++) {
                    var wrapper = { 'acc' : vendorData_Top[i].AccountName,
                                   'tasklist' : vendorData_Top[i].tasklist ,
                                   'accRecord' : vendorData_Top[i].accRecord ,
                                   'ast' : vendorData_Top[i].ast
                                  };
                    dataWrapper.push(wrapper);
                }
                component.set("v.data", dataWrapper);
                component.set("v.isTabSelected", true);
                var labelset_Top5 = vendor.slice(0, 5);
                var dataset_Top5 = vendorDataCount.slice(0, 5);
                var graphLimit = dataset_Top5[0];  
                helper.generateChart(component,dataset_Top5,labelset_Top5,graphLimit);
                component.set('v.loaded', false);
            }
        });
        $A.enqueueAction(actionVendor);
    },
    
    tabSelected: function(component,event,helper) {
        component.set('v.loaded', true);
        var selectedTab = component.get("v.topTabId");
        
        if(selectedTab == 'TabOne'){  
            component.set("v.numOfVendorDisplayed",5);
        }
        
        if(selectedTab == 'TabTwo'){
            component.set("v.numOfVendorDisplayed",10);
        }
        
        if(selectedTab == 'TabThree'){ 
            component.set("v.numOfVendorDisplayed",20);
        }
        
        if(selectedTab == 'TabFour'){ 	
            component.set("v.numOfVendorDisplayed",50);
        }
        
        var parentVendorData = [];
        var parentVendor = [];
        var parentVendorDataCount = [];
        var locationData = [];
        var location = [];
        var locationDataCount = [];
        var dataWrapper = [] ;
        
        component.set("v.isTabSelected", true);
        var selectedAccountType = component.get("v.selTabId");
        component.set("v.columns", component.get("v.columns"));
        var selectedUserView = component.get("v.selectedUserView");
        var taskType = component.get("v.taskType");
        
        var args = component.get("v.numOfVendorDisplayed");
        if(args!=undefined){
            var numOfVendorDisplayed = component.get("v.numOfVendorDisplayed");
        }
        
        if(selectedAccountType == 'parentVendor'){
            if(!component.get("v.isParentVendorTabSelectedFirstTime")){
                if(selectedUserView == "All" && taskType == "All" ){
                    var parentVendorData_Top = component.get("v.parentVendorData").slice(0, numOfVendorDisplayed);
                    
                    for (var i = 0; i < parentVendorData_Top.length; i++) {
                        var wrapper = { 'acc' : parentVendorData_Top[i].AccountName,
                                       'tasklist' : parentVendorData_Top[i].tasklist,
                                       'accRecord' : parentVendorData_Top[i].accRecord ,
                                       'ast' : parentVendorData_Top[i].ast
                                      };
                        dataWrapper.push(wrapper);
                    }
                    
                    var labelset_Top5 = component.get("v.parentVendor").slice(0, numOfVendorDisplayed);
                    var dataset_Top5 = component.get("v.parentVendorDataCount").slice(0, numOfVendorDisplayed);
                    var graphLimit = dataset_Top5[0];  
                    helper.generateChart(component,dataset_Top5,labelset_Top5,graphLimit);
                }
                else{
                    
                    helper.sortData(component, event, helper,numOfVendorDisplayed);  
                    
                    dataWrapper = component.get("v.VendorSortedData");
                    
                }
                component.set("v.data", dataWrapper);
                component.set("v.selChildTabId",selectedAccountType);
                helper.updateChartTableDataTabSelect(component,event,helper);
                //component.set('v.loaded', false);
                //var callChildDashboard = component.find("childComp");
                //component.set('v.loaded',callChildDashboard.get("v.loaded"));
            }
            else{
                var actionParent = component.get("c.getParentAccountDetails");
                actionParent.setCallback(this, function(response) {
                    //store state of response
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //var allAccountTask = JSON.parse(response.getReturnValue());
                        var allAccountTask = response.getReturnValue();
                        var columnsMap = [];
                        for(var i=0;i<allAccountTask.column.length;i++){
                            columnsMap.push({label:allAccountTask.column[i], fieldName:allAccountTask.fieldAPIName[i]});
                        }
                        
                        for(var key in allAccountTask.parentVendor){
                            parentVendorData.push(allAccountTask.parentVendor[key]);
                            parentVendor.push(allAccountTask.parentVendor[key].accRecord.Name);
                            parentVendorDataCount.push(allAccountTask.parentVendor[key].count);
                        }
                        
                        component.set("v.parentVendorData", parentVendorData);
                        component.set("v.parentVendor", parentVendor);
                        component.set("v.parentVendorDataCount",parentVendorDataCount);
                        
                        if(selectedUserView == "All" && taskType == "All" ){
                            var parentVendorData_Top = component.get("v.parentVendorData").slice(0, numOfVendorDisplayed);
                            
                            for (var i = 0; i < parentVendorData_Top.length; i++) {
                                var wrapper = { 'acc' : parentVendorData_Top[i].AccountName,
                                               'tasklist' : parentVendorData_Top[i].tasklist ,
                                               'accRecord' : parentVendorData_Top[i].accRecord ,
                                               'ast' : parentVendorData_Top[i].ast
                                              };
                                dataWrapper.push(wrapper);
                            }            
                            
                            var labelset_Top5 = component.get("v.parentVendor").slice(0, numOfVendorDisplayed);
                            var dataset_Top5 = component.get("v.parentVendorDataCount").slice(0, numOfVendorDisplayed);
                            var graphLimit = dataset_Top5[0];  
                            helper.generateChart(component,dataset_Top5,labelset_Top5,graphLimit);
                        }
                        else{
                            
                            helper.sortData(component, event, helper,numOfVendorDisplayed);  
                            
                            dataWrapper = component.get("v.VendorSortedData");
                            
                        }
                        component.set("v.data", dataWrapper);
                        component.set("v.columns", columnsMap);
                        component.set("v.isParentVendorTabSelectedFirstTime", false);
                        component.set("v.selChildTabId",selectedAccountType);
                        helper.updateChartTableDataTabSelect(component,event,helper);
                        component.set('v.loaded', false);
                    }
                });
                $A.enqueueAction(actionParent);
            }
        }
        else if(selectedAccountType == 'vendor'){
            if(selectedUserView == "All" && taskType == "All" ){
                
                var vendorData_Top = component.get("v.vendorData").slice(0, numOfVendorDisplayed);
                
                for (var i = 0; i < vendorData_Top.length; i++) {
                    var wrapper = { 'acc' : vendorData_Top[i].AccountName,
                                   'tasklist' : vendorData_Top[i].tasklist ,
                                   'accRecord' : vendorData_Top[i].accRecord ,
                                   'ast' : vendorData_Top[i].ast
                                  };
                    dataWrapper.push(wrapper);
                }
                
                var labelset_Top5 = component.get("v.vendor").slice(0, numOfVendorDisplayed);
                var dataset_Top5 = component.get("v.vendorDataCount").slice(0, numOfVendorDisplayed);
                var graphLimit = dataset_Top5[0];  
                helper.generateChart(component,dataset_Top5,labelset_Top5,graphLimit);
            }
            else{ 
                helper.sortData(component, event, helper,numOfVendorDisplayed);  
                
                dataWrapper = component.get("v.VendorSortedData");
                
            }
            component.set("v.data", dataWrapper);
            component.set("v.selChildTabId",selectedAccountType);
            helper.updateChartTableDataTabSelect(component,event,helper);
            //component.set('v.loaded', false);
            //var callChildDashboard = component.find("childComp");
            //component.set('v.loaded',callChildDashboard.get("v.loaded"));
        }
            else if(selectedAccountType == 'location'){
                if(!component.get("v.isLocationTabSelectedFirstTime")){
                    if(selectedUserView == "All" && taskType == "All" ){               
                        var locationData_Top = component.get("v.locationData").slice(0, numOfVendorDisplayed);
                        
                        for (var i = 0; i < locationData_Top.length; i++) {
                            var wrapper = { 'acc' : locationData_Top[i].AccountName,
                                           'tasklist' : locationData_Top[i].tasklist ,
                                           'accRecord' : locationData_Top[i].accRecord ,
                                           'ast' : locationData_Top[i].ast
                                          };
                            dataWrapper.push(wrapper);
                        }
                        
                        var labelset_Top5 = component.get("v.location").slice(0, numOfVendorDisplayed);
                        var dataset_Top5 = component.get("v.locationDataCount").slice(0, numOfVendorDisplayed);
                        var graphLimit = dataset_Top5[0];  
                        helper.generateChart(component,dataset_Top5,labelset_Top5,graphLimit);
                    }
                    else{ 
                        
                        helper.sortData(component, event, helper,numOfVendorDisplayed);  
                        
                        dataWrapper = component.get("v.VendorSortedData");
                    }
                    component.set("v.data", dataWrapper);
                    component.set("v.selChildTabId",selectedAccountType);
                    helper.updateChartTableDataTabSelect(component,event,helper);
                    //component.set('v.loaded', false);
                    //var callChildDashboard = component.find("childComp");
                    //component.set('v.loaded',callChildDashboard.get("v.loaded"));
                }
                else{
                    var actionLocation = component.get("c.getLocationAccountDetails");
                    actionLocation.setCallback(this, function(response) {
                        //store state of response
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            //var allAccountTask = JSON.parse(response.getReturnValue());
                            var allAccountTask = response.getReturnValue();
                            var columnsMap = [];
                            for(var i=0;i<allAccountTask.column.length;i++){
                                columnsMap.push({label:allAccountTask.column[i], fieldName:allAccountTask.fieldAPIName[i]});
                            }
                            
                            for(var key in allAccountTask.location){
                                locationData.push(allAccountTask.location[key]);
                                location.push(allAccountTask.location[key].AccountName);
                                locationDataCount.push(allAccountTask.location[key].count);
                            }
                            component.set("v.locationData", locationData);
                            component.set("v.location", location);
                            component.set("v.locationDataCount",locationDataCount);
                            
                            if(selectedUserView == "All" && taskType == "All" ){
                                
                                var locationData_Top = component.get("v.locationData").slice(0, numOfVendorDisplayed);
                                
                                for (var i = 0; i < locationData_Top.length; i++) {
                                    var wrapper = { 'acc' : locationData_Top[i].AccountName,
                                                   'tasklist' : locationData_Top[i].tasklist ,
                                                   'accRecord' : locationData_Top[i].accRecord ,
                                                   'ast' : locationData_Top[i].ast
                                                  };
                                    dataWrapper.push(wrapper);
                                }
                                
                                var labelset_Top5 = component.get("v.location").slice(0, numOfVendorDisplayed);
                                var dataset_Top5 = component.get("v.locationDataCount").slice(0, numOfVendorDisplayed);
                                var graphLimit = dataset_Top5[0]; 
                                helper.generateChart(component,dataset_Top5,labelset_Top5,graphLimit);
                            }
                            else{ 
                                
                                helper.sortData(component, event, helper,numOfVendorDisplayed);  
                                
                                dataWrapper = component.get("v.VendorSortedData");
                            }
                            component.set("v.data", dataWrapper);
                            component.set("v.columns", columnsMap);
                            component.set("v.isLocationTabSelectedFirstTime", false);
                            component.set("v.selChildTabId",selectedAccountType);
                            helper.updateChartTableDataTabSelect(component,event,helper);
                            component.set('v.loaded', false);
                        }
                    });
                    $A.enqueueAction(actionLocation);
                }
            }
    },
    
    spinnerCloseFunction : function(component,event,helper){
        var callChildDashboard = component.find("childComp");
        component.set('v.loaded',callChildDashboard.get("v.loaded"));
    }
})