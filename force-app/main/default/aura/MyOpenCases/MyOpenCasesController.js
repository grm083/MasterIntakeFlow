({
    doInit: function (component, event, helper) {
        
        component.set('v.isSending',true);
        component.set('v.columns', [
            
            {label: 'Case Id', fieldName: 'Id', type: 'url', 
             typeAttributes: {label: { fieldName: 'CaseNumber' } ,target: '_parent'}},
            {label: 'Type', fieldName: 'Case_Type__c', type: 'text', sortable : true},
            {label: 'Sub-Type', fieldName: 'Case_Sub_Type__c', type: 'text', sortable : true},
            {label: 'Service date', fieldName: 'Service_Date__c', type: 'Date', sortable : true},
        ]);
            component.set('v.options', [
            { id: 'Open', label: 'Open', selected: true },
            { id: 'New', label: 'New'},
            { id: 'Pending', label: 'Pending'},
            { id: 'Closed', label: 'Closed'}
        ]);
        
        helper.doFetchCase(component);
    },
    onStatusChange: function (component, event, helper){
        
        var statusDropdownValue =  component.find("selectCaseStatus").get("v.value");
        var caseList = component.get("v.CaseData");
        var onChange = component.set("v.startPage",0);
        var selectedCaseList = [];
        var selectedList =[];
        var pageSize = component.get("v.pageSize");
        
        if(component.get("v.CaseData")== null){
            component.set("v.hideNoRecordSection" , true);
        }    
        else
        {      
            for(var i = 0; i <caseList.length; i++){
                if (caseList[i].Status != undefined && caseList[i].Status == statusDropdownValue ){
                    selectedList.push(caseList[i]);
                }
       
            if (caseList[i].Status != undefined && caseList[i].Status == statusDropdownValue && selectedCaseList.length < 4){
                selectedCaseList.push(caseList[i]);
            }
        }
        if(selectedList!= undefined && selectedList.length >0){
            component.set("v.hideNoRecordSection" , false);
            component.set("v.totalRecords", selectedList.length);
            component.set('v.paginationList',selectedCaseList);
            component.set('v.pageLoadList',selectedList);
            component.set("v.endPage",pageSize);
        }
        else{
            component.set("v.hideNoRecordSection" , true);
        }
        }
    },   
    
    next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    },
    
    
    openTab : function(component, event, helper) {
        
        var taburl = component.get("v.OpenCaseTabUrl");
        var tabName = component.get("v.OpenCaseTabName");
        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.openTab({
            url: taburl,
            focus: true ,
            
        }).then(function(response) {
            workspaceAPI.setTabLabel({
                tabId: response,
                label: tabName
            }).then(function(tabInfo) {
                console.log("The Id for this tab is: " + tabInfo.recordId);
            });
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    
    
})