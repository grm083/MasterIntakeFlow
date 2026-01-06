({
    scriptsLoaded : function(component, event, helper) {
        
        var parentVendorData = [];
        var parentVendor = [];
        var parentVendorDataCount = [];
        var parentVendorDataTaskList = [];
        var vendorData = [];
        var vendor = [];
        var vendorDataCount = [];
        var vendorDataTaskList = [];
        var locationData = [];
        var location = [];
        var locationDataCount = [];
        var locationDataTaskList = [];
        
        var actionParent = component.get("c.getParentAccountDetailsForDashboard");
        
        actionParent.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allAccountTaskDashboard = response.getReturnValue();
                component.set('v.accountColumns', allAccountTaskDashboard);
                
                for(var key in allAccountTaskDashboard.parentVendor){
                    parentVendorData.push(allAccountTaskDashboard.parentVendor[key].accRecord.Name);
                    parentVendor.push(allAccountTaskDashboard.parentVendor[key]);
                    parentVendorDataCount.push(allAccountTaskDashboard.parentVendor[key].count);
                    parentVendorDataTaskList.push(allAccountTaskDashboard.parentVendor[key]);
                }
                
                component.set("v.parentVendorData", parentVendorData);
                component.set("v.parentVendor", parentVendor);
                component.set("v.parentVendorDataCount",parentVendorDataCount);
                component.set("v.parentVendorDataTaskList", parentVendorDataTaskList);
            }
        });
        
        $A.enqueueAction(actionParent);
        
        var actionVendor = component.get("c.getAccountDetailsForDashboard");
        
        helper.showSpinner(component);
        actionVendor.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allAccountTaskDashboard = response.getReturnValue();
                component.set('v.accountColumns', allAccountTaskDashboard);
                
                for(var key in allAccountTaskDashboard.vendor){
                    vendorData.push(allAccountTaskDashboard.vendor[key].AccountName);
                    vendor.push(allAccountTaskDashboard.vendor[key]);
                    vendorDataCount.push(allAccountTaskDashboard.vendor[key].count);
                    vendorDataTaskList.push(allAccountTaskDashboard.vendor[key]);
                }
                
                component.set("v.vendorData", vendorData);
                component.set("v.vendor", vendor);
                component.set("v.vendorDataTaskList",vendorDataTaskList);
                component.set("v.vendorDataCount",vendorDataCount);
                
                var labelset_Top5 = vendorData.slice(0, 5);
                var dataset_Top5 = vendorDataCount.slice(0, 5);
                var graphLimit = dataset_Top5[0];  
                helper.generateChart(component,dataset_Top5,labelset_Top5,graphLimit);
                
                helper.hideSpinner(component);
            }
        });
        
        $A.enqueueAction(actionVendor);
        
        var actionLocation = component.get("c.getLocationAccountDetailsForDashboard");
        
        actionLocation.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allAccountTaskDashboard = response.getReturnValue();
                component.set('v.accountColumns', allAccountTaskDashboard);
                
                for(var key in allAccountTaskDashboard.location){
                    locationData.push(allAccountTaskDashboard.location[key].AccountName);
                    location.push(allAccountTaskDashboard.location[key]);
                    locationDataCount.push(allAccountTaskDashboard.location[key].count);
                    locationDataTaskList.push(allAccountTaskDashboard.location[key]);
                }
                
                component.set("v.locationDataTaskList", locationDataTaskList);
                component.set("v.locationData", locationData);
                component.set("v.location", location);
                component.set("v.locationDataCount",locationDataCount);
            }
        });
        
        $A.enqueueAction(actionLocation);
       //helper.onChange(component, event, helper);
       //helper.onChange1(component, event, helper);
    },
    
    handleSelect: function (component, event, helper) {
        var selectedTab = component.get("v.selTabId");
        var childTableComponent = component.find("tableListId");
        
        if(selectedTab == 'TabOne'){  
            component.set("v.selectedNumberOfVendorTab",5);
            component.set("v.tabClicked",true);
            childTableComponent.displaySelectedTab(component.get("v.selectedNumberOfVendorTab"));
        }
        
        if(selectedTab == 'TabTwo'){
            component.set("v.selectedNumberOfVendorTab",10);
            component.set("v.tabClicked",true);
            childTableComponent.displaySelectedTab(component.get("v.selectedNumberOfVendorTab"));
        }
        
        if(selectedTab == 'TabThree'){ 
            component.set("v.selectedNumberOfVendorTab",20);
            component.set("v.tabClicked",true);
            childTableComponent.displaySelectedTab(component.get("v.selectedNumberOfVendorTab"));
        }
        
        if(selectedTab == 'TabFour'){ 	
            component.set("v.selectedNumberOfVendorTab",50);
            component.set("v.tabClicked",true);
            childTableComponent.displaySelectedTab(component.get("v.selectedNumberOfVendorTab"));
        }
    },
    parentPress : function (component, event, helper) {
        
        //helper.showSpinner(component);
        var selectedTab = component.get("v.selTabId");
        var chart = component.find("chart").getElement();
        var childTableComponent = component.find("tableListId");
        var currentAccountSelected = childTableComponent.get("v.selChildTabId");
        var selectedUserView = component.get("v.selectedUserView");
        var accountTypeServiceSelected = component.get("v.taskType");
        
        var dataLabel = [];
        var dataset = [];
        var data = [];
        var dataList = [];
        var chartMap = new Map();
        
        if(currentAccountSelected == 'parentVendor'){
            dataLabel = component.get("v.parentVendorData");
            dataList = component.get("v.parentVendor");
            for(var i = 0; i < dataList.length; i++){
                data.push(dataList[i]);
            }
            
            var count = 0;
            //var data = component.get("v.data");
            if((selectedUserView == "Genesys Integration" || selectedUserView =="Genesys Integration" ) && selectedUserView != "All" ){
                
                if(selectedUserView != "" && selectedUserView != "Reload"){
                    component.set('v.userName',selectedUserView);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                     for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                       if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                       }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition' && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                         if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
            }
            else if (selectedUserView == "Others") {
                if(selectedUserView != "" && selectedUserView != "Reload"){
                    component.set('v.userName',selectedUserView);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition' && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
            }
                else if (selectedUserView == "All" || selectedUserView == "Reload") {
                    if(selectedUserView != "" && selectedUserView != "Reload"){
                        component.set('v.userName',selectedUserView);
                    }
                    if(accountTypeServiceSelected == "Project Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if ((data[i].tasklist[k].AccountType == 'Construction and Demolition' )||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition' && data[i].tasklist[k].AssetProject == null){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            dataset = component.get("v.parentVendorDataCount");
                        }
                }
            
        }
        else if(currentAccountSelected == 'vendor'){
            dataLabel = component.get("v.vendorData");
            dataList = component.get("v.vendor");
            for(var i = 0; i < dataList.length; i++){
                data.push(dataList[i]);
            }
            
            var count = 0;
            //var data = component.get("v.data");
            if((selectedUserView == "Genesys Integration" || selectedUserView =="Genesys Integration" ) && selectedUserView != "All" ){
                
                if(selectedUserView != "" && selectedUserView != "Reload"){
                    component.set('v.userName',selectedUserView);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                         if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                             if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
            }
            else if (selectedUserView == "Others") {
                if(selectedUserView != "" && selectedUserView != "Reload"){
                    component.set('v.userName',selectedUserView);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration" ){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
            }
                else if (selectedUserView == "All" || selectedUserView == "Reload") {
                    if(selectedUserView != "" && selectedUserView != "Reload"){
                        component.set('v.userName',selectedUserView);
                    }
                    if(accountTypeServiceSelected == "Project Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||data[i].tasklist[k].AssetProject != null){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            dataset = component.get("v.vendorDataCount");
                        }
                }
        }
        
            else if(currentAccountSelected == 'location'){
                dataLabel = component.get("v.locationData");
                dataList = component.get("v.location");
                for(var i = 0; i < dataList.length; i++){
                    data.push(dataList[i]);
                }
                
                var count = 0;
                //var data = component.get("v.data");
                if((selectedUserView == "Genesys Integration" || selectedUserView =="Genesys Integration" ) && selectedUserView != "All" ){
                    
                    if(selectedUserView != "" && selectedUserView != "Reload"){
                        component.set('v.userName',selectedUserView);
                    }
                    
                    if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
            }
            else if (selectedUserView == "Others") {
                if(selectedUserView != "" && selectedUserView != "Reload"){
                    component.set('v.userName',selectedUserView);
                }
                
                if(accountTypeServiceSelected == "Project Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
            }
                else if (selectedUserView == "All" || selectedUserView == "Reload") {
                    if(selectedUserView != "" && selectedUserView != "Reload"){
                        component.set('v.userName',selectedUserView);
                    }
                    if(accountTypeServiceSelected == "Project Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            dataset = component.get("v.locationDataCount");
                        }
                }
            }
        
        var a = [];
          for(var x of chartMap) 
           a.push(x);

       a.sort(function(x, y) {
       return y[1] - x[1];
       }); 
        
        var sorted = new Map(a);
        
        var AccountName = Array.from(sorted.keys());
        var countOfTask = Array.from(sorted.values());
        
        if(selectedTab == 'TabOne'){  
            
           if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 5);
            dataset = countOfTask.slice(0, 5);
            
            }
            else {
               if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 5);
              dataset = dataset.slice(0, 5); 
               }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
            
            var graphLimit = 0 ;
            if (dataset.length > 0){               
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
            }
            
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",5);
        }
        
        if(selectedTab == 'TabTwo'){
            
            if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 10);
            dataset = countOfTask.slice(0, 10);
            
            }
            else {
              if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 10);
              dataset = dataset.slice(0, 10);
              }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
            
            var graphLimit = 0 ;
            if (dataset.length > 0){               
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
            }
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",10);
        }
        
        if(selectedTab == 'TabThree'){ 
            
            if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 20);
            dataset = countOfTask.slice(0, 20);
            
            }
            else {
              if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 20);
              dataset = dataset.slice(0, 20);
              }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
            
            var graphLimit = 0 ;
            if (dataset.length > 0){               
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
            }
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",20);
        }
        
        if(selectedTab == 'TabFour'){ 
            
            if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 50);
            dataset = countOfTask.slice(0, 50);
            
            }
            else {
              if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 50);
              dataset = dataset.slice(0, 50);
              }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
            
            var graphLimit = 0 ;
            if (dataset.length > 0){               
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
            }
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",50);
            
        }
        //helper.hideSpinner(component, event, helper);
    },
    userTypeonChange: function (component, event, helper) {
        //var UserDropdown  =  component.find('selectUserType').get('v.value');
        var UserDropdown  =  event.getSource().get('v.value');
        component.set("v.selectedUserView",UserDropdown);
        var appEvent = $A.get("e.c:TaskBundlingDashboardUserOnSelectEvent");
        
        appEvent.setParams({
            "UserDropdownValue" : UserDropdown ,
            "TaskDropdownValue" : component.get("v.taskType"),
            "AccountName" :  ''   
        });
        appEvent.fire();
    },
    
    taskTypeonChange: function (component, event, helper) {
        //var taskDropdownValue  =  component.find('selectTaskType').get('v.value');
        var taskDropdownValue  = event.getSource().get('v.value');
        var appEvent = $A.get("e.c:TaskBundlingDashboardUserOnSelectEvent");
        component.set("v.taskType",taskDropdownValue);
        appEvent.setParams({
            
            "TaskDropdownValue" : taskDropdownValue  ,
            "UserDropdownValue" : component.get("v.selectedUserView"),
            "TaskSelect" :  ''   
        });
        appEvent.fire();
        
    },
    
    handleDropdownOnclickEvent: function (component, event, helper) {
        var userTypeSelected = event.getParam("UserDropdownValue");
        var accountTypeServiceSelected = component.get("v.taskType");
        var userselected = component.get('v.userName');
        component.set('v.selectedUserView',userTypeSelected);
        
        var selectedTab = component.get("v.selTabId");
        var chart = component.find("chart").getElement();
        var childTableComponent = component.find("tableListId");
        var currentAccountSelected = childTableComponent.get("v.selChildTabId");
        
        var dataLabel = [];
        var dataset = [];
        var data = [];
        var dataList = [];
        var chartMap = new Map();
        
       if(currentAccountSelected == 'parentVendor'){
            dataLabel = component.get("v.parentVendorData");
            dataList = component.get("v.parentVendor");
            for(var i = 0; i < dataList.length; i++){
                data.push(dataList[i]);
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
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
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
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
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
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            dataset = component.get("v.parentVendorDataCount");
                        }
                }
        }
        else if(currentAccountSelected == 'vendor'){
            dataLabel = component.get("v.vendorData");
            dataList = component.get("v.vendor");
            for(var i = 0; i < dataList.length; i++){
                data.push(dataList[i]);
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
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
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
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
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
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            dataset = component.get("v.vendorDataCount");
                        }
                }
        }
        
            else if(currentAccountSelected == 'location'){
                dataLabel = component.get("v.locationData");
                dataList = component.get("v.location");
                for(var i = 0; i < dataList.length; i++){
                    data.push(dataList[i]);
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
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName == "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                       if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName == "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
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
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined))){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                else if(accountTypeServiceSelected == "Customer Services"){
                    for (var i = 0; i < data.length; i++) {
                        count = 0;
                        for(var k = 0; k < data[i].tasklist.length; k++){
                            if (data[i].tasklist[k].AssignedToName != "Genesys Integration" && (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null)){
                                count=count+1;
                            }
                        }
                        if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                    }
                }
                    else if(accountTypeServiceSelected == "All"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if(data[i].tasklist[k].AssignedToName != "Genesys Integration"){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
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
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType == 'Construction and Demolition'||(data[i].tasklist[k].AssetProject != null && data[i].tasklist[k].AssetProject != undefined)){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                    else if(accountTypeServiceSelected == "Customer Services"){
                        for (var i = 0; i < data.length; i++) {
                            count = 0;
                            for(var k = 0; k < data[i].tasklist.length; k++){
                                if (data[i].tasklist[k].AccountType != 'Construction and Demolition'  && data[i].tasklist[k].AssetProject == null){
                                    count=count+1;
                                }
                            }
                            if(count > 0){
                        dataset.push(count);                        
                        chartMap.set(data[i].AccountName,count);
                        }
                        }
                    }
                        else if(accountTypeServiceSelected == "All"){
                            dataset = component.get("v.locationDataCount");
                        }
                }
            }
        
         var a = [];
          for(var x of chartMap) 
           a.push(x);

       a.sort(function(x, y) {
       return y[1] - x[1];
       });  
  
        var sorted = new Map(a);
        
        var AccountName = Array.from(sorted.keys());
        var countOfTask = Array.from(sorted.values());
        
        if(selectedTab == 'TabOne'){  
            
            if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 5);
            dataset = countOfTask.slice(0, 5);
            
            }
            else {
                if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 5);
              dataset = dataset.slice(0, 5);
                }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
          
            var graphLimit = 0 ;
             if (dataset.length > 0){ 
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
             }
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",5);
        }
        
        if(selectedTab == 'TabTwo'){
            
            if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 10);
            dataset = countOfTask.slice(0, 10);
            
            }
            else {
                if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 10);
              dataset = dataset.slice(0, 10); 
                }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
            
            if (dataset.length > 0){ 
            var graphLimit = 0 ;
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
        }
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",10);
        }
        
        if(selectedTab == 'TabThree'){ 
            
            if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 20);
            dataset = countOfTask.slice(0, 20);
            
            }
            else {
              if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 20);
              dataset = dataset.slice(0, 20);  
              }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
         
            var graphLimit = 0 ;
            if (dataset.length > 0){ 
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
            }
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",20);
        }
        
        if(selectedTab == 'TabFour'){ 
            
            if(AccountName.length > 0){
                
            dataLabel = AccountName.slice(0, 50);
            dataset = countOfTask.slice(0, 50);
           
            }
            else {
              if(dataset != "undefined" && dataset != null && dataset.length >0){
              dataLabel = dataLabel.slice(0, 50);
              dataset = dataset.slice(0, 50);
              }
                else{
                 dataLabel = [];
              dataset = [];   
                }
            }
            
            var graphLimit = 0 ;
            if (dataset.length > 0){               
            graphLimit = dataset.reduce(function(a, b) {
             return Math.max(a, b);
              });
            }
            helper.generateChart(component,dataset,dataLabel,graphLimit);
            component.set("v.selectedNumberOfVendorTab",50);
        }
    },
    
    showSpinner: function (component, event, helper) {
        alert('here');
        helper.showSpinner(component, event, helper);
       
    },
    
    hideSpinner: function (component, event, helper) {
        helper.hideSpinner(component, event, helper);
    }
})