({
    doInit : function(component, event, helper) {
        
        var dataColumns = component.get('v.wrappers');
       
        var today = new Date();
		var tomorrow = new Date();
		tomorrow.setDate(today.getDate()+1);
        today = $A.localizationService.formatDate(tomorrow ,"YYYY-MM-DD");
        component.set("v.today", today);
        
        helper.fetchPicklistValues(component ,dataColumns, helper);
         
    },
    
    doAction : function (component, event, helper) {
        var params = event.getParam('arguments');
        var wrappers=new Array();
        if (params) {
            wrappers = params.updatedWrapper;
            // add your code here
        }
        
        component.set('v.wrappers', wrappers);
    },
    
    /*submitDetails : function (component, event, helper) {
        var dataColumns = component.get('v.dataList');
        var currentTaskUpdatedId = component.get("v.selectedTaskId");
        var dataMap = [];
        
        for(var key in dataColumns){
            if(dataColumns[key].Id === currentTaskUpdatedId){
                dataColumns[key].Outcome = component.get("v.selectedPicklistValues");
            }
            dataMap.push(dataColumns[key]);
        }
        
        component.set('v.data', dataMap);
        component.set('v.isModalOpen', false);
    },*/
    
    closeModel : function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    updateSelectedText: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        if(selectedRows != undefined){
            component.set('v.isRowSelected', false);
            component.set('v.selectedRows', selectedRows);
        }
        var vx = component.get("v.method");
        //fire event from child and capture in parent
        $A.enqueueAction(vx);
        
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.dependentFieldMap");
        alert(controllerValueKey);
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        component.set('v.wrappers', component.get('v.finalDataList'));
        var listOfAllTasks = component.get("v.wrappers");
        
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllTasks.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllTasks[i].isChecked = true;
                component.set("v.selectedCount", listOfAllTasks.length);
            } else {
                listOfAllTasks[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllTasks[i]);
        }
        component.set("v.showTable", true);
        var allRecords = component.get("v.wrappers");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        
        if(component.get('v.selectedRows') != undefined){
            var previouslySelectedRecord = component.get('v.selectedRows');
            for (var i = 0; i < previouslySelectedRecord.length; i++) {
                if (previouslySelectedRecord[i].isChecked && !selectedRecords.includes(previouslySelectedRecord[i])) {
                    selectedRecords.push(previouslySelectedRecord[i]);
                }
            }
        }
        
        if(selectedRecords != undefined){
            component.set('v.isRowSelected', false);
            component.set('v.selectedRows', selectedRecords);
        }
        var vx = component.get("v.method");
        $A.enqueueAction(vx);
        
        component.set("v.finalDataList", updatedAllRecords);
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        component.set('v.wrappers', component.get('v.finalDataList'));
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
        var allRecords = component.get("v.wrappers");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        
        if(component.get('v.selectedRows') != undefined){
            var previouslySelectedRecord = component.get('v.selectedRows');
            for (var i = 0; i < previouslySelectedRecord.length; i++) {
                if (previouslySelectedRecord[i].isChecked && !selectedRecords.includes(previouslySelectedRecord[i])) {
                    selectedRecords.push(previouslySelectedRecord[i]);
                }
            }
        }
        
        if(selectedRecords != undefined){
            component.set('v.isRowSelected', false);
            component.set('v.selectedRows', selectedRecords);
        }
        var vx = component.get("v.method");
        $A.enqueueAction(vx);
    },
    
    /*getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.wrappers");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        if(selectedRecords != undefined){
            component.set('v.isRowSelected', false);
            component.set('v.selectedRows', selectedRecords);
        }
        var vx = component.get("v.method");
        //fire event from child and capture in parent
        $A.enqueueAction(vx);
        alert(JSON.stringify(selectedRecords));
        //alert((selectedRecords));
    },*/
    
    export : function(component, event, helper) {
        
        //helper.fnExcelReport(component, event, helper);
        
        var lstPositions = component.get("v.wrappers");
        var PositionTitle = 'Selected Position';
        var data = [];
        var headerArray = [];
        
        headerArray.push("S.NO"); 
        var headerLabel = component.get("v.columns");
        
        var table  = "<table border='2px'>";
        
        for(var key in headerLabel){
            if(headerLabel[key].label == "Task Link"){
                headerArray.push("SUBJECT");
                table = table+ '<tr><th bgcolor= "#229954">S.NO</th><th bgcolor= "#229954">SUBJECT</th>';
            }
            else{
                var header = headerLabel[key].label ;
                
                headerArray.push(header.toUpperCase());
                table = table + '<th bgcolor= "#229954">'+header.toUpperCase()+'</th>';
            }
            
        }
        table = table +'</tr>';
        var csvContentArray = [];
        //Provide the title 
        var CSV = "Account Name :"+component.get("v.AccountName");
        
        data.push(headerArray);
        
        var sno = 0;
        for(var i=0;i<lstPositions.length;i++){
            
            var ServiceDate = '';
            var Outcome = '';
            var AccountNumber = '';
            var AccStatus = '';
            var ParentId = '';
            var vendorRelationship = '';
            var MarketArea = '';
            var Unit = '';
            var WmVendor = '';
            var description = '';
            var AssetCategory = '';
            var Position = '';
            var ContactEmail = '';
            var ContactNumber = '';
            var ContactTitle = '';
            var ContactMethod = '';
            var LocationAccount = '';
            var MarketArea = '';
            var VendorBU = '';
            var Comments = '';
            var TaskType = '';
            var Attempt = '';
            var AssetEquipmentSize = '';
            var AssetMaterialType = '';
            var CaseType = '';
            var CaseSubType = '';
            var AssetMASAccountNumber = '';
            var AssetVendorAccountNumber = '';
            var AcornWONumber='';
            var LocationAddress = '';
            var LocationCity = '';
            var LocationState = '';
            var LocationZipCode = '';
            var AssetName = '';
            
            if(lstPositions[i].isChecked)  {
                if(lstPositions[i].AssetName != undefined){
                    AssetName = lstPositions[i].acc.AssetName ;
                }
                if(lstPositions[i].ServiceDate != undefined){
                    ServiceDate = lstPositions[i].ServiceDate ;
                }
                if(lstPositions[i].Outcome != undefined){
                    Outcome = lstPositions[i].Outcome ;
                }
                if(lstPositions[i].acc.CompanyCategory != undefined){
                    AssetCategory = lstPositions[i].acc.CompanyCategory ;
                }
                if(lstPositions[i].acc.Position != undefined){
                    Position = lstPositions[i].acc.Position;
                }
                if(lstPositions[i].acc.TaskAttempt!= undefined ){
                    Attempt = lstPositions[i].acc.TaskAttempt ;
                }
                if(lstPositions[i].acc.ContactEmail != undefined){
                    ContactEmail = lstPositions[i].acc.ContactEmail;
                }
                if(lstPositions[i].acc.ContactNumber != undefined){
                    ContactNumber = lstPositions[i].acc.ContactNumber;
                }
                if(lstPositions[i].acc.ContactTitle != undefined){
                    ContactTitle = lstPositions[i].acc.ContactTitle;
                }
                if(lstPositions[i].acc.ContactMethod != undefined){
                    ContactMethod = lstPositions[i].acc.ContactMethod;
                }
                if(lstPositions[i].acc.AcornWONumber != undefined){
                    AcornWONumber = lstPositions[i].acc.AcornWONumber;
                }
                if(lstPositions[i].acc.LocationAccount != undefined){
                    LocationAccount = lstPositions[i].acc.LocationAccount;
                }
                if(lstPositions[i].acc.LocationAddress != undefined){
                    LocationAddress = lstPositions[i].acc.LocationAddress;
                }
                if(lstPositions[i].acc.LocationCity != undefined){
                    LocationCity = lstPositions[i].acc.LocationCity;
                }
                if(lstPositions[i].acc.LocationState != undefined){
                    LocationState = lstPositions[i].acc.LocationState;
                }
                if(lstPositions[i].acc.LocationZipCode != undefined){
                    LocationZipCode = lstPositions[i].acc.LocationZipCode;
                }
                if(lstPositions[i].acc.MarketArea != undefined){
                    MarketArea = lstPositions[i].acc.MarketArea;
                }
                if(lstPositions[i].acc.VendorBU != undefined){
                    VendorBU = lstPositions[i].acc.VendorBU;
                }
                if(lstPositions[i].Comment != undefined){
                    Comments = lstPositions[i].Comment;
                }
                if(lstPositions[i].acc.AssetEquipmentSize != undefined){
                    AssetEquipmentSize = lstPositions[i].acc.AssetEquipmentSize;
                }
                if(lstPositions[i].acc.AssetMaterialType != undefined){
                    AssetMaterialType = lstPositions[i].acc.AssetMaterialType;
                }
                if(lstPositions[i].acc.CaseType != undefined){
                    CaseType = lstPositions[i].acc.CaseType;
                }
                if(lstPositions[i].acc.CaseSubType != undefined){
                    CaseSubType = lstPositions[i].acc.CaseSubType;
                }
                if(lstPositions[i].acc.AssetMASAccountNumber != undefined){
                    AssetMASAccountNumber = lstPositions[i].acc.AssetMASAccountNumber;
                }
                if(lstPositions[i].acc.AssetVendorAccountNumber != undefined){
                    AssetVendorAccountNumber = lstPositions[i].acc.AssetVendorAccountNumber;
                }
                if(lstPositions[i].acc.AccountType != 'Construction and Demolition' && lstPositions[i].acc.AssetProject == null){
                    TaskType = 'CS';
                }else{
                    TaskType = 'PS';
                }
                
                var dueDateTimeFormat = lstPositions[i].acc.DueDateTime;
                dueDateTimeFormat = $A.localizationService.formatDateTime(dueDateTimeFormat,"MM/dd/yyyy, hh:mm:ss a");
                var localeDueDateTime = new Date(dueDateTimeFormat).toLocaleString("en-US", {timeZone: $A.get("$Locale.timezone")});
                localeDueDateTime = new Date(localeDueDateTime);
                
                sno = parseInt(sno) + parseInt(1);
                table = table +'<tr>';
                
                table = table +'<td>'+sno+'</td>';
                table = table +'<td>'+lstPositions[i].acc.TaskName+'</td>';
                table = table +'<td>'+lstPositions[i].acc.CaseNumber+'</td>';
                table = table +'<td>'+AssetName+'</td>';
                table = table +'<td>'+CaseType+'</td>';
                table = table +'<td>'+CaseSubType+'</td>';
                table = table +'<td>'+ServiceDate+'</td>';
                //table = table +'<td>'+lstPositions[i].acc.Process+'</td>';
                table = table +'<td>'+Outcome+'</td>';
                table = table +'<td>'+localeDueDateTime.toLocaleString()+'</td>';
                table = table +'<td>'+AssetCategory+'</td>';
                table = table +'<td>'+Position+'</td>';
                table = table +'<td>'+AssetMASAccountNumber+'</td>';
                table = table +'<td>'+ContactEmail+'</td>';
                table = table +'<td>'+ContactNumber+'</td>';
                table = table +'<td>'+ContactTitle+'</td>';
                table = table +'<td>'+ContactMethod+'</td>';
                table = table +'<td>'+lstPositions[i].acc.AccountName+'</td>';
                table = table +'<td>'+lstPositions[i].acc.AccountNumber+'</td>';
                table = table +'<td>'+AcornWONumber+'</td>';
                table = table +'<td>'+lstPositions[i].acc.Status+'</td>';
                table = table +'<td>'+lstPositions[i].acc.ParentVendor+'</td>';
                table = table +'<td>'+LocationAccount+'</td>';
                table = table +'<td>'+LocationAddress+'</td>';
                table = table +'<td>'+LocationCity+'</td>';
                table = table +'<td>'+LocationState+'</td>';
                table = table +'<td>'+LocationZipCode+'</td>';
                table = table +'<td>'+MarketArea+'</td>';
                table = table +'<td>'+VendorBU+'</td>';
                table = table +'<td>'+lstPositions[i].acc.WMVendor+'</td>';
                table = table +'<td>'+AssetVendorAccountNumber+'</td>';
                table = table +'<td>'+AssetEquipmentSize+'</td>';
                table = table +'<td>'+AssetMaterialType+'</td>';
                table = table +'<td>'+Comments+'</td>';
                table = table +'<td>'+lstPositions[i].acc.AssignedToName+'</td>';
                table = table +'<td>'+TaskType+'</td>';
                table = table +'<td>'+Attempt+'</td>';
                table = table +'</tr>';
            }}
        
        table = table +'</table>';
        var heading = "Account Name :"+component.get("v.AccountName");
        //var imgsrc1='https://wmsbs--dev--c.documentforce.com/servlet/servlet.ImageServer?id=0152a000000FAiR&oid=00D2a00000096PP&lastMod=1569580423000';
        var imgsrc1 = $A.get("$Label.c.WM_LOGO_URL");
        var template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--><meta http-equiv="content-type" content="text/plain; charset=UTF-8"/></head><body><img src="{imgsrc1}" style="float:left;clear:none;margin-right:50px " height=80 width=100/><br></br><h4 style="display:inline-block">{heading}</h4><br>{table}</body></html>'
        , base64 = function(s) { return window.btoa(unescape(encodeURIComponent(s))) }
        , format = function(s, c) { return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; }) } 
        
        var ctx = {worksheet: 'Tasks' || 'Worksheet',imgsrc1: imgsrc1,table: table , heading: heading}
        var blob = new Blob([format(template, ctx)]);
        var blobURL = window.URL.createObjectURL(blob);
        
        var link = document.createElement("a");
        
        
        var fileName = "Task Bundling Report.xls";
        link.setAttribute('download',fileName);
        
        link.href = blobURL;
        
        
        link.style = "visibility:hidden";
        
        
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
    },
    handleDropdownOnclickEvent : function(component, event, helper) {
        //helper.handleDropdownOnclickEventHelper(component, event, helper); 
        var dataColumns = component.get('v.wrappers');
        component.set('v.finalDataList', dataColumns);
    },
    
    checkForServiceDate : function(component, event, helper) {
        var changedOutcome = event.getSource().get("v.value");
        var selectedTaskRowId = event.getSource().get("v.title");
        component.set('v.wrappers', component.get('v.finalDataList'));
        var allRecords = component.get("v.wrappers");
        var selectedRecords = [];
        var today = new Date();
        /*var hours = today.getHours();
        if(hours > 12){
            hours = hours-12+':'+today.getMinutes()+'PM';
        }
        else{
            hours = hours+':'+today.getMinutes()+'AM';
        }*/
        var updatedDate = $A.localizationService.formatDate(today, "yyyy-MM-dd");
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].acc.TaskId == selectedTaskRowId) {
                if((changedOutcome == 'Vendor Unavailable' && allRecords[i].acc.Process == 'Confirm Vendor Availability') 
                   || (changedOutcome == 'Service Rescheduled' && (allRecords[i].acc.Process == 'Obtain Schedule Confirmation' ||
                                                                   allRecords[i].acc.Process == 'Confirm Service Completion' ||
                                                                   allRecords[i].acc.Process == 'Manually Dispatch'))){
                    
                    
                    if(allRecords[i].acc.ServiceDate == null || allRecords[i].acc.ServiceDate <= updatedDate){
                        allRecords[i].acc.ShowServiceDateAsEdit = true;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Warning!",
                            "message": "Proposed Service Date is Mandatory and cannot be in past."
                        });
                        toastEvent.fire();
                    }
                }
                else{
                    allRecords[i].acc.ShowServiceDateAsEdit = false;
                }
            }
            else{
                allRecords[i].acc.ShowServiceDateAsEdit = false;
            }
            selectedRecords.push(allRecords[i]);
        }
        component.set("v.finalDataList", selectedRecords);
    },
    
    CheckLength : function(component,event,helper)
    {
        var changedComment = event.getSource().get("v.value");
        if(changedComment.length >= 4000)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": "Maximum Length Exceeded."
            });
            toastEvent.fire();  
        }
    },
})