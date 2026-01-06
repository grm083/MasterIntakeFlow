global with sharing class SupervisorDashboardCls {
    
    Private static final String GROUP_TYPE = 'Regular';
    
    @AuraEnabled
    public static String fetchUserSessionId(){
        
        String sessionId = '';
        
        if(Test.isRunningTest()){
            return 'SESSION_ID';
        } 
        else{
            PageReference reportPage = Page.GetSessionIdVF;
            String vfContent = reportPage.getContent().toString();
            
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
            sessionId = vfContent.substring(startP, endP);
        }
        return sessionId;
    }
    
    @AuraEnabled
    public static Map<String,String> getDatasetAPIReference(String datasetFetched){
        
        String response = '';
        Map<String, Object> datasetMapResponse = new Map<String, Object>();
        Map<String,String> datasetIdVSVersionIdMap = new Map<String,String>();
        List<Object> listOfDatasets = new List<Object>();
        String datasetId = '';
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        //callout:Analytics_Api
        String sessionId = fetchUserSessionId();
        //Get the most recent required dataset version id from the analytics.
        List<EA_Dataset__mdt> listOfEADataset= [Select Dataset_Id__c, DeveloperName, MasterLabel 
                                                                from EA_Dataset__mdt where DeveloperName =: datasetFetched];
        
        for(EA_Dataset__mdt eaDS : listOfEADataset ){
            datasetId = eaDS.Dataset_Id__c;
        }
        String restAPIURL = sfdcURL + '/services/data/v42.0/wave/datasets/'+datasetId;  
        
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');   
        httpRequest.setHeader('Authorization', 'OAuth ' + sessionId);        
        httpRequest.setHeader('Authorization', 'Bearer ' + sessionId); 
        httpRequest.setEndpoint(restAPIURL);  
        
        if(test.isRunningTest()) {
            if(datasetFetched == 'InteractionDuration'){
                datasetIdVSVersionIdMap.put('VersionId',System.Label.CurrentDatasetVersionIdForTestWorkflow);
                datasetIdVSVersionIdMap.put('DatasetId',System.Label.DatasetIdForTestWorkflow);
            }
            else if(datasetFetched == 'NoCaseTask'){
                datasetIdVSVersionIdMap.put('VersionId',System.Label.CurrentDatasetVersionIdForTestCase);
                datasetIdVSVersionIdMap.put('DatasetId',System.Label.DatasetIdForTestCase);
            }
            else if(datasetFetched == 'TicketCaseComment'){
                datasetIdVSVersionIdMap.put('VersionId',System.Label.CurrentDatasetVersionIdForTestTicket);
                datasetIdVSVersionIdMap.put('DatasetId',System.Label.DatasetIdForTestTicket);
            }
        }
        
        else {
            try {  
                Http http = new Http();   
                HttpResponse httpResponse = http.send(httpRequest);  
                if (httpResponse.getStatusCode() == 200 ) {  
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );  
                    datasetMapResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
                    system.debug('::datasetMapResponse'+datasetMapResponse);
                    if(datasetMapResponse.get('name') == datasetFetched){
                        datasetIdVSVersionIdMap.put('VersionId',(String)datasetMapResponse.get('currentVersionId'));
                        datasetIdVSVersionIdMap.put('DatasetId',(String)datasetMapResponse.get('id'));
                    }
                    /*
                    for(String str : datasetMapResponse.keySet()){
                        if(str == 'datasets'){
                            system.debug('::datasetresponse'+str);
                            listOfDatasets = (List<Object>)datasetMapResponse.get(str);  
                            
                            for(Object datasetName : listOfDatasets){
                                system.debug('::datasetnameresponse'+datasetName);
                                Map<String, Object> supervisorDataset = (Map<String, Object>)datasetName;
                                if(supervisorDataset.get('name') == datasetFetched){
                                    system.debug('::datasetnameresponse'+supervisorDataset.get('name'));
                                    datasetIdVSVersionIdMap.put('VersionId',(String)supervisorDataset.get('currentVersionId'));
                                    datasetIdVSVersionIdMap.put('DatasetId',(String)supervisorDataset.get('id'));
                                }
                            }
                        }
                    }*/
                } else {  
                    System.debug(' httpResponse ' + httpResponse.getBody() );  
                    System.debug('ERROR: '+ httpResponse.getStatus());  
                    throw new CalloutException( httpResponse.getBody() );  
                }   
            } catch( System.Exception e) {  
                System.debug('ERROR: '+ e.getMessage());  
                throw e;  
            }
        }
        
        return datasetIdVSVersionIdMap;
    }
    
    
    @AuraEnabled
    public static List<workflowDataset> getTaskList(String taskTab, Map<String,String> dashboardFilter){
        List<workflowDataset> dataList = new List<workflowDataset>();
        Map<String,String> versionDatasetId = getDatasetAPIReference(System.Label.WorkflowTaskAssignmentDataset);
        Map<Id,workflowDataset> taskIdVSTaskDetails = new Map<Id,workflowDataset>();
        List<Task> taskList = new List<Task>();
        List<String> loggedInSupervisorTeamMemberId = new List<String>();
        List<String> dashboardTableFilter = new List<String>();
        String dashboardClientTaskFilter = '';
        String dashboardLocationTaskFilter = '';
        String dashboardParentTaskFilter = '';
        String dashboardVendorTaskFilter = '';
        String dashboardTypeTaskFilter = '';
        String dashboardSubTypeTaskFilter = '';
        String dashboardProcessTaskFilter = ''; 
        String dashboardSubjectTaskFilter = '';
        String dashboardOwnerTaskFilter = ''; 
        String dashboardCaseNumberFilter = ''; 
        
        dashboardTableFilter.add('\'InteractionType\' == "Task"');
        dashboardTableFilter.add('\'Status\' == "Open"');
        dashboardTableFilter.add(' date(\'CreatedDate_Year\', \'CreatedDate_Month\', \'CreatedDate_Day\') in ["'+System.Label.TaskCreated+'".."current day"]');
        
        for(String fieldName : dashboardFilter.keySet()){
            if(fieldName.equalsIgnoreCase('Case.ClientName')){
                dashboardClientTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardClientTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case.LocationName')){
                dashboardLocationTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardLocationTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case.VendorName')){
                dashboardVendorTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardVendorTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case.ParentVendorName')){
                dashboardParentTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardParentTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case.Case_Sub_Type__c')){
                dashboardSubTypeTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardSubTypeTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case.Case_Type__c')){
                dashboardTypeTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardTypeTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Process__c')){
                dashboardProcessTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardProcessTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Subject')){
                dashboardSubjectTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardSubjectTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('TaskOwnerName')){
                dashboardOwnerTaskFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardOwnerTaskFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case.Case_CSPS_Flag')){
                if(dashboardFilter.get(fieldName) == 'Customer Services'){
                    dashboardTableFilter.add('\'Case.Case_CSPS_Flag\' == "CS"');
                }
                else if(dashboardFilter.get(fieldName) == 'Project Services'){
                    dashboardTableFilter.add('\'Case.Case_CSPS_Flag\' == "PS"');
                }
            }
            else if(fieldName.equalsIgnoreCase('Case.CaseNumber')){
                dashboardCaseNumberFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardCaseNumberFilter);
            }
        }
        
        for(User uObj : getFewUsers()){
            if(!loggedInSupervisorTeamMemberId.contains(uObj.Id)){
                loggedInSupervisorTeamMemberId.add(uObj.Id);    
            }
        }
        
        String userLoggedInIds ='';
        for(integer i = 0; i< loggedInSupervisorTeamMemberId.size();i++){
            if(userLoggedInIds != null && i != (loggedInSupervisorTeamMemberId.size()-1)){
                userLoggedInIds = userLoggedInIds + '"'+loggedInSupervisorTeamMemberId[i]+'",';
            }
            else if (userLoggedInIds != null && i == (loggedInSupervisorTeamMemberId.size()-1)){
                userLoggedInIds = userLoggedInIds + '"'+loggedInSupervisorTeamMemberId[i]+'"';
            }
            else{
                userLoggedInIds = '"'+loggedInSupervisorTeamMemberId[i]+'",';
            }
        }
        
        Wave.ProjectionNode[] projs = new Wave.ProjectionNode[]{
            Wave.QueryBuilder.get('\'Case.CaseNumber\'').alias('CaseNumber'),
                Wave.QueryBuilder.get('\'Due_Date_Time__c\'').alias('DueDate'),
                Wave.QueryBuilder.get('\'Process__c\'').alias('Process'),
                Wave.QueryBuilder.get('\'Id\'').alias('TaskId'),
                Wave.QueryBuilder.get('\'TaskAgeBucket\'').alias('TaskAge'),
                Wave.QueryBuilder.get('\'TaskOwnerName\'').alias('AssignedTo'),
                Wave.QueryBuilder.get('OwnerId').alias('OwnerId'),
                Wave.QueryBuilder.get('\'Subject\'').alias('Subject'),
                Wave.QueryBuilder.get('\'Attempt__c\'').alias('Attempt'),
                Wave.QueryBuilder.get('\'Case.Case_CSPS_Flag\'').alias('TaskType'),
                Wave.QueryBuilder.get('\'Case.Case_Type__c\'').alias('CaseType'),
                Wave.QueryBuilder.get('\'Case.Case_Sub_Type__c\'').alias('CaseSubType'),
                Wave.QueryBuilder.get('\'Case.SLA_Service_Date_Time__c\'').alias('CaseSLADate'),
                Wave.QueryBuilder.get('\'Case.Service_Date__c\'').alias('CaseServiceDate'),
                Wave.QueryBuilder.get('\'Case.Asset.Container_Position__c\'').alias('Position'),
                Wave.QueryBuilder.get('\'Case.Asset.Category__c\'').alias('CompanyCategory'),
                Wave.QueryBuilder.get('\'Case.Asset.MAS_Account_Number__c\'').alias('MASAccountNumber'),
                Wave.QueryBuilder.get('\'Case.Tracking_Number__c\'').alias('AcornWONumber'),
                Wave.QueryBuilder.get('\'Case.VendorName\'').alias('VendorName'),
                Wave.QueryBuilder.get('\'Case.ParentVendorName\'').alias('ParentVendor'),
                Wave.QueryBuilder.get('\'Case.Asset.Vendor_BU__c\'').alias('VendorBU'),
                Wave.QueryBuilder.get('\'Case.Vendor.WM_Vendor__c\'').alias('WMVendor'),
                Wave.QueryBuilder.get('\'Case.Asset.Vendor_Account_Number__c\'').alias('VendorAccountNumber'),
                Wave.QueryBuilder.get('\'Case.ClientName\'').alias('ClientName'),
                Wave.QueryBuilder.get('\'Case.Client.Customer_Code__c\'').alias('ClientCode'),
                Wave.QueryBuilder.get('\'Case.LocationName\'').alias('Location'),
                Wave.QueryBuilder.get('\'Case.Location.ShippingStreet\'').alias('LocationAddress'),
                Wave.QueryBuilder.get('\'Case.Location.ShippingCity\'').alias('LocationCity'),
                Wave.QueryBuilder.get('\'Case.Location.ShippingState\'').alias('LocationState'),
                Wave.QueryBuilder.get('\'Case.Location.ShippingPostalCode\'').alias('LocationZipCode'),
                Wave.QueryBuilder.get('\'Case.Asset.Name\'').alias('AssetName'),
                Wave.QueryBuilder.get('\'Case.Asset.Equipment_Size__c\'').alias('EquipmentSize'),
                Wave.QueryBuilder.get('\'Case.Asset.Material_Type__c\'').alias('MaterialType')};
                    
                    String workflowDataResponseJSON = '';
        Map<String, Object> workflowDataResponseMap = new Map<String, Object>();
        system.debug('::versionDatasetId::'+versionDatasetId);
        
        if(test.isRunningTest()){
            String jsonMock = '{"results" : {"records" :[{"CaseNumber": "1234","TaskId": "00T2a00000NShenEAD","DueDate": "1234","Process": "1234", "Attempt": 1234,"AccountPrimarySegment": "Construction ","AssetProject": "1234","CaseSLADate": "1234","CompanyCategory": "1234","CaseType": "1234","CaseSubType": "1234","CaseServiceDate": "1234","Position": "1234","MASAccountNumber": "1234","ClientName": "1234","ClientCode": "1234","AcornWONumber": "1234","ParentVendor": "1234","VendorBU": "1234","WMVendor": "1234","VendorAccountNumber": "1234","Location": "1234","LocationAddress": "1234","LocationCity": "1234","LocationState": "1234","LocationZipCode": "1234","AssetName": "1234","EquipmentSize": "1234","MaterialType": "1234"},{"CaseNumber": "1234","TaskId": "00T2a00000NShenEAD","DueDate": "1234","Process": "1234", "Attempt": 123,"AccountPrimarySegment": "Construction ","AssetProject": "1234","CaseSLADate": "1234","CompanyCategory": "1234","CaseType": "1234","CaseSubType": "1234","CaseServiceDate": "1234","Position": "1234","MASAccountNumber": "1234","ClientName": "1234","ClientCode": "1234","AcornWONumber": "1234","ParentVendor": "1234","VendorBU": "1234","WMVendor": "1234","VendorAccountNumber": "1234","Location": "1234","LocationAddress": "1234","LocationCity": "1234","LocationState": "1234","LocationZipCode": "1234","AssetName": "1234","EquipmentSize": "1234","MaterialType": "1234"}]}}';
            workflowDataResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonMock);
        }else{
            if(taskTab != 'workflow'){
                system.debug('::'+versionDatasetId);
                dashboardTableFilter.add('\'OwnerId\' in ['+userLoggedInIds+']');
                dashboardTableFilter.add('\'TaskOwnerName\' != "Genesys Integration"');
                ConnectApi.LiteralJson workflowDataResponse = Wave.QueryBuilder.load(versionDatasetId.get('DatasetId'), versionDatasetId.get('VersionId'))
                    .filter(dashboardTableFilter)
                    .foreach(projs)
                    .cap(Integer.valueOf(System.Label.AnalyticsDataLimit))
                    .execute('q');
                workflowDataResponseJSON = workflowDataResponse.json;
            }
            else{
                system.debug('::'+versionDatasetId);
                dashboardTableFilter.add('\'TaskOwnerName\' == "Genesys Integration"');
                ConnectApi.LiteralJson workflowDataResponse = Wave.QueryBuilder.load(versionDatasetId.get('DatasetId'), versionDatasetId.get('VersionId'))
                    .filter(dashboardTableFilter)
                    .foreach(projs)
                    .cap(Integer.valueOf(System.Label.AnalyticsDataLimit))
                    .execute('q');
                workflowDataResponseJSON = workflowDataResponse.json;
            }                      
            
            workflowDataResponseMap = (Map<String, Object>)JSON.deserializeUntyped(workflowDataResponseJSON);
        }
        system.debug('::'+workflowDataResponseJSON);
        for(String str : workflowDataResponseMap.keySet()){
            if(str == 'results'){
                Map<String, Object> workflowDataMap = (Map<String, Object>)workflowDataResponseMap.get(str);        
                List<Object> workflowDataList = (List<Object>)workflowDataMap.get('records');     
                system.debug('::'+workflowDataMap);
                for(Object tickets : workflowDataList){
                    workflowDataset workflowData = new workflowDataset();
                    Map<String, Object> workflowMap = (Map<String, Object>)tickets;  
                    if(workflowMap.get('CaseNumber') != null){
                        workflowData.CaseNumber = (String)workflowMap.get('CaseNumber');
                    }
                    if(workflowMap.get('Subject') != null){
                        workflowData.Subject = (String)workflowMap.get('Subject');
                    }
                    if(workflowMap.get('TaskId') != null){
                        workflowData.TaskId = (String)workflowMap.get('TaskId');
                    }
                    if(workflowMap.get('TaskAge') != null){
                        workflowData.TaskAge = (String)workflowMap.get('TaskAge');
                    }
                    if(workflowMap.get('AssignedTo') != null){
                        workflowData.AssignedTo = (String)workflowMap.get('AssignedTo');
                    }
                    if(workflowMap.get('OwnerId') != null){
                        workflowData.OwnerId = (String)workflowMap.get('OwnerId');
                    }
                    if(workflowMap.get('VendorName') != null){
                        workflowData.VendorName = (String)workflowMap.get('VendorName');
                    }
                    if(workflowMap.get('DueDate') != null){
                        workflowData.DueDate = (String)workflowMap.get('DueDate');
                    }
                    if(workflowMap.get('Process') != null){
                        workflowData.Process = (String)workflowMap.get('Process');
                    }
                    if(workflowMap.get('Attempt') != null){
                        workflowData.Attempt = (Integer)workflowMap.get('Attempt');
                    }
                    if(workflowMap.get('TaskType') != null){
                        workflowData.TaskType = (String)workflowMap.get('TaskType');
                    }
                    if(workflowMap.get('CaseSLADate') != null){
                        workflowData.CaseSLADate = (String)workflowMap.get('CaseSLADate');
                    }
                    if(workflowMap.get('CompanyCategory') != null){
                        workflowData.CompanyCategory = (String)workflowMap.get('CompanyCategory');
                    }
                    if(workflowMap.get('CaseType') != null){
                        workflowData.CaseType = (String)workflowMap.get('CaseType');
                    }
                    if(workflowMap.get('CaseSubType') != null){
                        workflowData.CaseSubType = (String)workflowMap.get('CaseSubType');
                    }
                    if(workflowMap.get('CaseServiceDate') != null){
                        workflowData.CaseServiceDate = (String)workflowMap.get('CaseServiceDate');
                    }
                    if(workflowMap.get('Position') != null){
                        workflowData.Position = (String)workflowMap.get('Position');
                    }
                    if(workflowMap.get('MASAccountNumber') != null){
                        workflowData.MASAccountNumber = (String)workflowMap.get('MASAccountNumber');
                    }
                    if(workflowMap.get('ClientName') != null){
                        workflowData.ClientName = (String)workflowMap.get('ClientName');
                    }
                    if(workflowMap.get('ClientCode') != null){
                        workflowData.ClientCode = (String)workflowMap.get('ClientCode');
                    }
                    if(workflowMap.get('AcornWONumber') != null){
                        workflowData.AcornWONumber = (String)workflowMap.get('AcornWONumber');
                    }
                    if(workflowMap.get('ParentVendor') != null){
                        workflowData.ParentVendor = (String)workflowMap.get('ParentVendor');
                    }
                    if(workflowMap.get('VendorBU') != null){
                        workflowData.VendorBU = (String)workflowMap.get('VendorBU');
                    }
                    if(workflowMap.get('WMVendor') != null){
                        workflowData.WMVendor = (String)workflowMap.get('WMVendor');
                    }
                    if(workflowMap.get('VendorAccountNumber') != null){
                        workflowData.VendorAccountNumber = (String)workflowMap.get('VendorAccountNumber');
                    }
                    if(workflowMap.get('Location') != null){
                        workflowData.Location = (String)workflowMap.get('Location');
                    }
                    if(workflowMap.get('LocationAddress') != null){
                        workflowData.LocationAddress = (String)workflowMap.get('LocationAddress');
                    }
                    if(workflowMap.get('LocationCity') != null){
                        workflowData.LocationCity = (String)workflowMap.get('LocationCity');
                    }
                    if(workflowMap.get('LocationState') != null){
                        workflowData.LocationState = (String)workflowMap.get('LocationState');
                    }
                    if(workflowMap.get('LocationZipCode') != null){
                        workflowData.LocationZipCode = (String)workflowMap.get('LocationZipCode');
                    }
                    if(workflowMap.get('AssetName') != null){
                        workflowData.AssetName = (String)workflowMap.get('AssetName');
                    }
                    if(workflowMap.get('EquipmentSize') != null){
                        workflowData.EquipmentSize = (String)workflowMap.get('EquipmentSize');
                    }
                    if(workflowMap.get('MaterialType') != null){
                        workflowData.MaterialType = (String)workflowMap.get('MaterialType');
                    }
                    dataList.add(workflowData);
                    taskIdVSTaskDetails.put(workflowData.TaskId, workflowData);
                }
            }
        }
        
        if(taskTab == 'workflow'){
            taskList = [SELECT Id, WhatId, Owner.Name,Status FROM Task WHERE Id In :taskIdVSTaskDetails.keySet() and 
                        Owner.Name != 'Genesys Integration' and Status!='Open']; 
            
            for(Task t : taskList){
                taskIdVSTaskDetails.remove(t.Id);
            }
        }
        else{
            taskList = [SELECT Id, WhatId, Owner.Name,Status FROM Task WHERE Id In :taskIdVSTaskDetails.keySet() and 
                        Owner.Name = 'Genesys Integration' and Status!='Open']; 
            
            for(Task t : taskList){
                taskIdVSTaskDetails.remove(t.Id);
            }
            
            /*for(Id taskId : taskIdVSTaskDetails.keySet()){
                if(!loggedInSupervisorTeamMemberId.contains(taskIdVSTaskDetails.get(taskId).OwnerId)){
                    taskIdVSTaskDetails.remove(taskId);
                }
            }*/
        }
        
        return taskIdVSTaskDetails.values() ;
    }
    
    @AuraEnabled
    public static List<TicketDataset> getCaseList(){
        
        List<TicketDataset> dataList = new List<TicketDataset>();
        Map<Id,TicketDataset> caseIdVSCase = new Map<Id,TicketDataset>();
        system.debug('::System.Label.CaseDataset::'+System.Label.CaseDataset);
        Map<String,String> versionDatasetId = getDatasetAPIReference(System.Label.CaseDataset);
        List<Task> caseWithOpenTasks = new List<Task>();
        List<String> loggedInSupervisorTeamMemberId = new List<String>();
        List<String> dashboardTableFilter = new List<String>();
        
        dashboardTableFilter.add('\'CaseHasOpenTask\' == "N"');
        dashboardTableFilter.add('\'Status\' != "Closed"');
        dashboardTableFilter.add(' date(\'CreatedDate_Year\', \'CreatedDate_Month\', \'CreatedDate_Day\') in ["'+System.Label.CaseDateFilters+'".."current day"]');

        for(User uObj : getFewUsers()){
            if(!loggedInSupervisorTeamMemberId.contains(uObj.Id)){
                loggedInSupervisorTeamMemberId.add(uObj.Id);    
            }
        }
        
        String userLoggedInIds ='';
        for(integer i = 0; i< loggedInSupervisorTeamMemberId.size();i++){
            if(userLoggedInIds != null && i != (loggedInSupervisorTeamMemberId.size()-1)){
                userLoggedInIds = userLoggedInIds + '"'+loggedInSupervisorTeamMemberId[i]+'",';
            }
            else if (userLoggedInIds != null && i == (loggedInSupervisorTeamMemberId.size()-1)){
                userLoggedInIds = userLoggedInIds + '"'+loggedInSupervisorTeamMemberId[i]+'"';
            }
            else{
                userLoggedInIds = '"'+loggedInSupervisorTeamMemberId[i]+'",';
            }
        }

        Wave.ProjectionNode[] projs = new Wave.ProjectionNode[]{
            Wave.QueryBuilder.get('CaseNumber').alias('CaseNumber'),
                Wave.QueryBuilder.get('Id').alias('CaseId'),
                Wave.QueryBuilder.get('\'NoTaskCaseOwner.Name\'').alias('CaseOwner'),
                Wave.QueryBuilder.get('OwnerId').alias('OwnerId'),
                Wave.QueryBuilder.get('Case_Type__c').alias('CaseType'),
                Wave.QueryBuilder.get('Case_Sub_Type__c').alias('CaseSubType'),
                Wave.QueryBuilder.get('SLA_Service_Date_Time__c').alias('CaseSLADate'),
                Wave.QueryBuilder.get('Service_Date__c').alias('CaseServiceDate'),
                Wave.QueryBuilder.get('\'Client.Name\'').alias('ClientName'),
                Wave.QueryBuilder.get('\'Client.Customer_Code__c\'').alias('ClientCode'),
                Wave.QueryBuilder.get('\'Location.Name\'').alias('Location'),
                Wave.QueryBuilder.get('\'Location.ShippingStreet\'').alias('LocationAddress'),
                Wave.QueryBuilder.get('\'Location.ShippingCity\'').alias('LocationCity'),
                Wave.QueryBuilder.get('\'Location.ShippingState\'').alias('LocationState'),
                Wave.QueryBuilder.get('\'Location.ShippingPostalCode\'').alias('LocationZipCode'),
                Wave.QueryBuilder.get('\'Asset.Name\'').alias('AssetName'),
                Wave.QueryBuilder.get('\'Asset.Equipment_Size__c\'').alias('EquipmentSize'),
                Wave.QueryBuilder.get('\'Asset.Material_Type__c\'').alias('MaterialType')};
                    
                    Map<String, Object> ticketDataResponseMap = new Map<String,Object>();
        
        system.debug('::versionDatasetId::'+versionDatasetId);
        if(test.isRunningTest()){
            String jsonMock = '{"results" : {"records" :[{"CaseNumber": "1234","OwnerId":"abc","CaseId": "5002a0000060bMaAAI","CaseOwner": "1234","CaseSLADate": "1234", "CaseType": "1234","CaseSubType": "Construction ","CaseServiceDate": "1234","ClientName": "1234","ClientCode": "1234","Location": "1234","LocationAddress": "1234","LocationCity": "1234","LocationState": "1234","LocationZipCode": "1234","AssetName": "1234","EquipmentSize": "1234","MaterialType": "1234"},{"CaseNumber": "1234","CaseId": "5002a0000060bMaAAI","CaseOwner": "1234","CaseSLADate": "1234", "CaseType": "1234","CaseSubType": "Construction ","OwnerId":"abc","CaseServiceDate": "1234","ClientName": "1234","ClientCode": "1234","Location": "1234","LocationAddress": "1234","LocationCity": "1234","LocationState": "1234","LocationZipCode": "1234","AssetName": "1234","EquipmentSize": "1234","MaterialType": "1234"}]}}';
            ticketDataResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonMock);
        }else{
            dashboardTableFilter.add('\'OwnerId\' in ['+userLoggedInIds+']');
            ConnectApi.LiteralJson ticketDataResponse = Wave.QueryBuilder.load(versionDatasetId.get('DatasetId'), versionDatasetId.get('VersionId'))
            .filter(dashboardTableFilter)
                .foreach(projs)
                .cap(Integer.valueOf(System.Label.AnalyticsDataLimit))
                .execute('q');
            ticketDataResponseMap = (Map<String, Object>)JSON.deserializeUntyped(ticketDataResponse.json);
        }

        for(String str : ticketDataResponseMap.keySet()){
            if(str == 'results'){
                Map<String, Object> ticketDataMap = (Map<String, Object>)ticketDataResponseMap.get(str);        
                List<Object> ticketDataList = (List<Object>)ticketDataMap.get('records');                
                for(Object tickets : ticketDataList){
                    TicketDataset caseData = new TicketDataset();
                    Map<String, Object> ticketsMap = (Map<String, Object>)tickets;  
                    if(ticketsMap.get('CaseNumber') != null){
                        caseData.CaseNumber = (String)ticketsMap.get('CaseNumber');
                    }
                    if(ticketsMap.get('CaseId') != null){
                        caseData.CaseId = (String)ticketsMap.get('CaseId');
                    }
                    if(ticketsMap.get('OwnerId') != null){
                        caseData.OwnerId = (String)ticketsMap.get('OwnerId');
                    }
                    if(ticketsMap.get('CaseOwner') != null){
                        caseData.CaseOwner = (String)ticketsMap.get('CaseOwner');
                    }
                    if(ticketsMap.get('CaseSLADate') != null){
                        caseData.CaseSLADate = (String)ticketsMap.get('CaseSLADate');
                    }
                    if(ticketsMap.get('CaseType') != null){
                        caseData.CaseType = (String)ticketsMap.get('CaseType');
                    }
                    if(ticketsMap.get('CaseSubType') != null){
                        caseData.CaseSubType = (String)ticketsMap.get('CaseSubType');
                    }
                    if(ticketsMap.get('CaseServiceDate') != null){
                        caseData.CaseServiceDate = (String)ticketsMap.get('CaseServiceDate');
                    }
                    if(ticketsMap.get('ClientName') != null){
                        caseData.ClientName = (String)ticketsMap.get('ClientName');
                    }
                    if(ticketsMap.get('ClientCode') != null){
                        caseData.ClientCode = (String)ticketsMap.get('ClientCode');
                    }
                    if(ticketsMap.get('Location') != null){
                        caseData.Location = (String)ticketsMap.get('Location');
                    }
                    if(ticketsMap.get('LocationAddress') != null){
                        caseData.LocationAddress = (String)ticketsMap.get('LocationAddress');
                    }
                    if(ticketsMap.get('LocationCity') != null){
                        caseData.LocationCity = (String)ticketsMap.get('LocationCity');
                    }
                    if(ticketsMap.get('LocationState') != null){
                        caseData.LocationState = (String)ticketsMap.get('LocationState');
                    }
                    if(ticketsMap.get('LocationZipCode') != null){
                        caseData.LocationZipCode = (String)ticketsMap.get('LocationZipCode');
                    }
                    if(ticketsMap.get('AssetName') != null){
                        caseData.AssetName = (String)ticketsMap.get('AssetName');
                    }
                    if(ticketsMap.get('EquipmentSize') != null){
                        caseData.EquipmentSize = (String)ticketsMap.get('EquipmentSize');
                    }
                    if(ticketsMap.get('MaterialType') != null){
                        caseData.MaterialType = (String)ticketsMap.get('MaterialType');
                    }
                    dataList.add(caseData);
                    caseIdVSCase.put(caseData.CaseId,caseData);
                }
            }
        }
        
        caseWithOpenTasks = [SELECT Id, whatId, Status FROM Task WHERE whatId In :caseIdVSCase.keySet()
                             and Status='Open']; 
                             
        for(Task t : caseWithOpenTasks){
            caseIdVSCase.remove(t.whatId);
        }

        /*for(Id caseId : caseIdVSCase.keySet()){
            if(!loggedInSupervisorTeamMemberId.contains(caseIdVSCase.get(caseId).OwnerId)){
                caseIdVSCase.remove(caseId);
            }
        }*/
        
        return caseIdVSCase.values();
    }
    
    @AuraEnabled
    public static List<TicketDataset> getTicketList(Map<String,String> dashboardFilter,String ticketTabSelection){
        
        Map<Id,TicketDataset> caseIdVSTicketComment = new Map<Id,TicketDataset>();
        Map<String,String> versionDatasetId = getDatasetAPIReference(System.Label.TicketCaseCommentDataset);
        List<Task> caseWithOpenTasks = new List<Task>();
        List<Id> loggedInSupervisorTeamMemberId = new List<Id>();
        List<String> dashboardTableFilter = new List<String>();
        String dashboardClientTicketFilter = '';
        String dashboardLocationTicketFilter = '';
        String dashboardParentTicketFilter = '';
        String dashboardVendorTicketFilter = '';
        String dashboardTypeTicketFilter = '';
        String dashboardSubTypeTicketFilter = '';
        String dashboardQueueTicketFilter = ''; 
        String dashboardTimeZoneTicketFilter = '';
        String dashboardWorkOrderTicketFilter = ''; 
        String dashboardCaseReasonTicketFilter = '';
        String dashboardSegmentTicketFilter = '';
        String dashboardServiceDateTicketFilter = '';
        String dashboardOwnerTicketFilter = '';
        String dashboardTicketAgeTicketFilter = '';
        
        List<String> teamQueueValues = getQueuePicklistvalues();
        String teamQueues ='';
        
        for(integer i = 1; i< teamQueueValues.size();i++){
            if(teamQueues != null && i != (teamQueueValues.size()-1)){
                teamQueues = teamQueues + '"'+teamQueueValues[i]+'",';
            }
            else if (teamQueues != null && i == (teamQueueValues.size()-1)){
                teamQueues = teamQueues + '"'+teamQueueValues[i]+'"';
            }
            else{
                teamQueues = '"'+teamQueueValues[i]+'",';
            }
        }
        
        if(ticketTabSelection == 'allCases'){
            dashboardTableFilter.add('\'TicketOpenTask.Subject\' not in ['+teamQueues+']');
            dashboardTableFilter.add('\'TicketOpenTask.Status\' != "Open"');
        } else{
            dashboardTableFilter.add('\'HasOpenTask\' == "No"');
        }
		
        //dashboardTableFilter.add('\'HasOpenTask\' == "No"');
        dashboardTableFilter.add('\'QueueOrUser_Flag\' == "Queue"');
        dashboardTableFilter.add('\'Status\' != "Closed"');
        dashboardTableFilter.add(' date(\'CreatedDate_Year\', \'CreatedDate_Month\', \'CreatedDate_Day\') in ["'+System.Label.CaseDateFilters+'".."current day"]');
        
        system.debug('::'+dashboardFilter);
        for(String fieldName : dashboardFilter.keySet()){
            if(fieldName.equalsIgnoreCase('ClientName')){
                dashboardClientTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardClientTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('LocationName')){
                dashboardLocationTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardLocationTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('VendorName')){
                dashboardVendorTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardVendorTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('ParentVendorName')){
                dashboardParentTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardParentTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case_Sub_Type__c')){
                dashboardSubTypeTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardSubTypeTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case_Type__c')){
                dashboardTypeTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardTypeTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('CaseComment.Workflow_TeamQueue__c')){
                dashboardQueueTicketFilter = '\''+ fieldName +'\' in ['+ dashboardFilter.get(fieldName) +']';
                dashboardTableFilter.add(dashboardQueueTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('Location.tz__Timezone__c')){
                dashboardQueueTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardTimeZoneTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('Acorn_Work_order__c')){
                dashboardQueueTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardWorkOrderTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('Case_Reason__c')){
                dashboardQueueTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardCaseReasonTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('Client.Primary_Segment__c')){
                dashboardQueueTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardSegmentTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('Service_Date__c')){
                dashboardQueueTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardServiceDateTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('TeamUser.Name')){
                dashboardQueueTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardOwnerTicketFilter);
            }
            else if(fieldName.equalsIgnoreCase('CaseComment.TicketAgeRange')){
                dashboardTicketAgeTicketFilter = '\''+ fieldName +'\' == "'+ dashboardFilter.get(fieldName) +'"';
                dashboardTableFilter.add(dashboardTicketAgeTicketFilter);
            }
        }
        
        system.debug('::'+dashboardTableFilter);
        Wave.ProjectionNode[] projs = new Wave.ProjectionNode[]{
            Wave.QueryBuilder.get('CaseNumber').alias('CaseNumber'),
			Wave.QueryBuilder.get('\'CreatedDate\'').alias('CreatedDate'),//added for 18165
                Wave.QueryBuilder.get('Id').alias('CaseId'),
                Wave.QueryBuilder.get('\'CaseComment.Workflow_TeamQueue__c\'').alias('TeamQueue'),
                Wave.QueryBuilder.get('Tracking_Number__c').alias('AcornTrackingNumber'),
                Wave.QueryBuilder.get('\'TicketOpenTask.Subject\'').alias('TicketTaskSubject'),
                Wave.QueryBuilder.get('\'TicketOpenTask.Status\'').alias('TicketTaskStatus'),
                Wave.QueryBuilder.get('OwnerId').alias('OwnerId'),
                Wave.QueryBuilder.get('\'TeamUser.Name\'').alias('TicketOwner'),
				Wave.QueryBuilder.get('TicketCommentAgeRange').alias('TicketAge'),
				Wave.QueryBuilder.get('Acorn_Work_order__c').alias('AcornWorkOrder'),
                Wave.QueryBuilder.get('Case_Type__c').alias('CaseType'),
                Wave.QueryBuilder.get('Case_Sub_Type__c').alias('CaseSubType'),
				Wave.QueryBuilder.get('Case_Reason__c').alias('CaseReason'),
                Wave.QueryBuilder.get('SLA_Service_Date_Time__c').alias('CaseSLADate'),
                Wave.QueryBuilder.get('\'VendorName\'').alias('VendorName'),
                Wave.QueryBuilder.get('\'ParentVendorName\'').alias('ParentVendor'),
                Wave.QueryBuilder.get('Service_Date__c').alias('CaseServiceDate'),
                Wave.QueryBuilder.get('\'ClientName\'').alias('ClientName'),
                Wave.QueryBuilder.get('\'Client.Customer_Code__c\'').alias('ClientCode'),
				Wave.QueryBuilder.get('\'Client.Primary_Segment__c\'').alias('ClientPrimarySegment'),
                Wave.QueryBuilder.get('\'LocationName\'').alias('Location'),
                Wave.QueryBuilder.get('\'Location.ShippingStreet\'').alias('LocationAddress'),
                Wave.QueryBuilder.get('\'Location.ShippingCity\'').alias('LocationCity'),
                Wave.QueryBuilder.get('\'Location.ShippingState\'').alias('LocationState'),
				Wave.QueryBuilder.get('\'Location.ShippingPostalCode\'').alias('LocationZipCode'),
                Wave.QueryBuilder.get('\'Location.tz__Timezone__c\'').alias('LocationTimeZone'),
                Wave.QueryBuilder.get('\'Asset.Name\'').alias('AssetName'),
                Wave.QueryBuilder.get('\'Asset.Equipment_Size__c\'').alias('EquipmentSize'),
                Wave.QueryBuilder.get('\'Asset.Material_Type__c\'').alias('MaterialType')};
                    
                    Map<String, Object> ticketDataResponseMap = new Map<String,Object>();
        
        system.debug('::versionDatasetId::'+versionDatasetId);
        if(test.isRunningTest()){
            String jsonMock = '{"results" : {"records" :[{"CaseNumber": "1234","LocationTimeZone":"123","AcornWorkOrder":"123","ClientPrimarySegment":"abc","CaseReason":"test","TicketAge":"2","CaseId": "5002a0000060bMaAAI","CaseOwner": "1234","CaseSLADate": "1234", "CaseType": "1234","CaseSubType": "Construction ","CaseServiceDate": "1234","ClientName": "1234","ClientCode": "1234","Location": "1234","LocationAddress": "1234","LocationCity": "1234","LocationState": "1234","LocationZipCode": "1234","AssetName": "1234","EquipmentSize": "1234","MaterialType": "1234","OwnerId":"abc","TeamQueue":"abcd","VendorName":"vendor","ParentVendor":"PVendor","AcornTrackingNumber":"ATN"},{"CaseNumber": "1234","CaseId": "5002a0000060bMaAAI","CaseOwner": "1234","CaseSLADate": "1234", "CaseType": "1234","CaseSubType": "Construction ","CaseServiceDate": "1234","ClientName": "1234","ClientCode": "1234","Location": "1234","LocationAddress": "1234","LocationCity": "1234","LocationState": "1234","LocationZipCode": "1234","AssetName": "1234","EquipmentSize": "1234","MaterialType": "1234","OwnerId":"abc","TeamQueue":"abcd","VendorName":"vendor","ParentVendor":"PVendor","AcornTrackingNumber":"ATN"}]}}';
            ticketDataResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonMock);
        }else{
            ConnectApi.LiteralJson ticketDataResponse = Wave.QueryBuilder.load(versionDatasetId.get('DatasetId'), versionDatasetId.get('VersionId'))
                .filter(dashboardTableFilter)
                .foreach(projs)
                .cap(Integer.valueOf(System.Label.AnalyticsDataLimit))
                .execute('q');
            ticketDataResponseMap = (Map<String, Object>)JSON.deserializeUntyped(ticketDataResponse.json);
        }                    
        
        for(String str : ticketDataResponseMap.keySet()){
            if(str == 'results'){
                Map<String, Object> ticketDataMap = (Map<String, Object>)ticketDataResponseMap.get(str);        
                List<Object> ticketDataList = (List<Object>)ticketDataMap.get('records');                
                for(Object tickets : ticketDataList){
                    TicketDataset ticketData = new TicketDataset();
                    Map<String, Object> ticketsMap = (Map<String, Object>)tickets;  
                    if(ticketsMap.get('CaseNumber') != null){
                        ticketData.CaseNumber = (String)ticketsMap.get('CaseNumber');
                    }
                    if(ticketsMap.get('CaseId') != null){
                        ticketData.CaseId = (String)ticketsMap.get('CaseId');
                    }
                    if(ticketsMap.get('TicketTaskSubject') != null){
                        ticketData.TicketTaskSubject = (String)ticketsMap.get('TicketTaskSubject');
                    }
                    if(ticketsMap.get('TicketTaskStatus') != null){
                        ticketData.TicketTaskStatus = (String)ticketsMap.get('TicketTaskStatus');
                    }
                    if(ticketsMap.get('TicketOwner') != null){
                        ticketData.TicketOwner = (String)ticketsMap.get('TicketOwner');
                    }
                    if(ticketsMap.get('OwnerId') != null){
                        ticketData.OwnerId = (String)ticketsMap.get('OwnerId');
                    }
                    if(ticketsMap.get('CaseReason') != null){
                        ticketData.CaseReason = (String)ticketsMap.get('CaseReason');
                    }
                    if(ticketsMap.get('TeamQueue') != null){
                        ticketData.TeamQueue = (String)ticketsMap.get('TeamQueue');
                    }
                    if(ticketsMap.get('TicketAge') != null){
                        ticketData.TicketAge = (String)ticketsMap.get('TicketAge');
                    }
                    if(ticketsMap.get('VendorName') != null){
                        ticketData.VendorName = (String)ticketsMap.get('VendorName');
                    }
                    if(ticketsMap.get('ParentVendor') != null){
                        ticketData.ParentVendor = (String)ticketsMap.get('ParentVendor');
                    }
                    if(ticketsMap.get('CaseSLADate') != null){
                        ticketData.CaseSLADate = (String)ticketsMap.get('CaseSLADate');
                    }
					 if(ticketsMap.get('CreatedDate') != null){//added for 18165
                        ticketData.CreatedDate = (String)ticketsMap.get('CreatedDate');
                    }
                    if(ticketsMap.get('AcornTrackingNumber') != null){
                        ticketData.AcornTrackingNumber = (String)ticketsMap.get('AcornTrackingNumber');
                    }
                    if(ticketsMap.get('AcornWorkOrder') != null){
                        ticketData.AcornWorkOrder = (String)ticketsMap.get('AcornWorkOrder');
                    }
                    if(ticketsMap.get('CaseType') != null){
                        ticketData.CaseType = (String)ticketsMap.get('CaseType');
                    }
                    if(ticketsMap.get('CaseSubType') != null){
                        ticketData.CaseSubType = (String)ticketsMap.get('CaseSubType');
                    }
                    if(ticketsMap.get('CaseServiceDate') != null){
                        ticketData.CaseServiceDate = (String)ticketsMap.get('CaseServiceDate');
                    }
                    if(ticketsMap.get('ClientName') != null){
                        ticketData.ClientName = (String)ticketsMap.get('ClientName');
                    }
                    if(ticketsMap.get('ClientCode') != null){
                        ticketData.ClientCode = (String)ticketsMap.get('ClientCode');
                    }
                    if(ticketsMap.get('ClientPrimarySegment') != null){
                        ticketData.ClientPrimarySegment = (String)ticketsMap.get('ClientPrimarySegment');
                    }
                    if(ticketsMap.get('Location') != null){
                        ticketData.Location = (String)ticketsMap.get('Location');
                    }
                    if(ticketsMap.get('LocationAddress') != null){
                        ticketData.LocationAddress = (String)ticketsMap.get('LocationAddress');
                    }
                    if(ticketsMap.get('LocationCity') != null){
                        ticketData.LocationCity = (String)ticketsMap.get('LocationCity');
                    }
                    if(ticketsMap.get('LocationState') != null){
                        ticketData.LocationState = (String)ticketsMap.get('LocationState');
                    }
                    if(ticketsMap.get('LocationZipCode') != null){
                        ticketData.LocationZipCode = (String)ticketsMap.get('LocationZipCode');
                    }
                    if(ticketsMap.get('LocationTimeZone') != null){
                        ticketData.LocationTimeZone = (String)ticketsMap.get('LocationTimeZone');
                    }
                    if(ticketsMap.get('AssetName') != null){
                        ticketData.AssetName = (String)ticketsMap.get('AssetName');
                    }
                    if(ticketsMap.get('EquipmentSize') != null){
                        ticketData.EquipmentSize = (String)ticketsMap.get('EquipmentSize');
                    }
                    if(ticketsMap.get('MaterialType') != null){
                        ticketData.MaterialType = (String)ticketsMap.get('MaterialType');
                    }
                    caseIdVSTicketComment.put(ticketData.CaseId,ticketData);
                }
            }
        }
        
        if(ticketTabSelection == 'allCases'){
            caseWithOpenTasks = [SELECT Id, whatId FROM Task WHERE whatId In :caseIdVSTicketComment.keySet()
                                 and Subject In : teamQueueValues and Status='Open'];
        } else{
            caseWithOpenTasks = [SELECT Id, whatId FROM Task WHERE whatId In :caseIdVSTicketComment.keySet()
                                 and Status='Open'];
        } 
        
        for(Task t : caseWithOpenTasks){
            caseIdVSTicketComment.remove(t.whatId);
        }
        
        return caseIdVSTicketComment.values();
    }
    
    @AuraEnabled
    public static List<User> getFewUsers(){
        
        String userID = UserInfo.getUserId();              
        set<Id> userIdSet = new set<Id>{userID};
        set<Id> groupset  =  getGroupsForUserIds(userIdSet);
        set<Id> teamMemberset  =  getUsersForGroupIds(groupset) ;
        
        return [SELECT Id,Name from User where Id in :teamMemberset and Profile.Name != 'Deactivated Users' and isActive= true ];
    }
    
    @AuraEnabled
    public static String updateTheObjectList(List<Id> updateItemList, DateTime dueDate, String prioritySelected, String primaryTab, Id selectedUser, String taskComment){
        List<Task> createNewTaskFromCaseAssignment = new List<Task>();
        List<Case> updateCaseOwner = new List<Case>();
        String returnMessage = '';
        system.debug('::'+updateItemList+''+primaryTab);
        if(primaryTab == 'case'){
            if(selectedUser != null){
                for(Case cs : [Select Id, OwnerId from Case where Id=: updateItemList]){
                    Task tObj = new Task();
                    tObj.whatId = cs.Id;
                    tObj.Subject = 'Case Assignment';
                    tObj.Status = 'Open';
                    tObj.Priority = prioritySelected;
                    tObj.ActivityDate = dueDate.date();
                    tObj.Due_Date_Time__c = dueDate;
                    tObj.OwnerId = cs.OwnerId;
                    tObj.Description = taskComment;
                    
                    createNewTaskFromCaseAssignment.add(tObj);
                }
            }
            else{
                for(Case cs : [Select Id, OwnerId from Case where Id=: updateItemList]){
                    Task tObj = new Task();
                    tObj.whatId = cs.Id;
                    tObj.Subject = 'Case Assignment';
                    tObj.Status = 'Open';
                    tObj.Priority = prioritySelected;
                    tObj.ActivityDate = dueDate.date();
                    tObj.Due_Date_Time__c = dueDate;
                    tObj.OwnerId = selectedUser;
                    tObj.Description = taskComment;
                    
                    createNewTaskFromCaseAssignment.add(tObj);
                }
            }
            try{
                insert createNewTaskFromCaseAssignment;
                returnMessage = 'SUCCESS';
            }
            catch(Exception e) {
                returnMessage = e.getMessage();
            }
        }
        
        else if(primaryTab == 'task'){
            if(selectedUser != null){    
                for(Task tObj : [Select Id, Priority, Description, WhatId, Subject, ActivityDate, OwnerId, Proposed_Service_Date__c,
                                Outcome__c, Is_a_New_Work_Order_Needed__c, Attempt__c, Non_Chargeable_Recovery__c, Root_Cause__c,
                                Reached_out_to_Contact__c, WhoId, Contact_Number__c, Contact_Email__c, Contact_Title__c,
                                Completion_Date_Time__c, Process__c from Task where Id=: updateItemList]){
                    
                    Task newTask = new Task();
                    newTask.whatId = tObj.WhatId;
                    newTask.Subject = tObj.Subject;
                    newTask.Status = 'Open';
                    newTask.Proposed_Service_Date__c = tObj.Proposed_Service_Date__c;
                    newTask.Outcome__c = tObj.Outcome__c;
                    newTask.Is_a_New_Work_Order_Needed__c = tObj.Is_a_New_Work_Order_Needed__c;
                    newTask.Attempt__c = tObj.Attempt__c;
                    newTask.Non_Chargeable_Recovery__c = tObj.Non_Chargeable_Recovery__c;
                    newTask.Root_Cause__c = tObj.Root_Cause__c;
                    newTask.Reached_out_to_Contact__c = tObj.Reached_out_to_Contact__c;
                    newTask.WhoId = tObj.WhoId;
                    newTask.Contact_Number__c = tObj.Contact_Number__c;
                    newTask.Contact_Email__c = tObj.Contact_Email__c;
                    newTask.Contact_Title__c = tObj.Contact_Title__c;
                    newTask.Completion_Date_Time__c = tObj.Completion_Date_Time__c;
                    newTask.Process__c = tObj.Process__c;
                    newTask.Priority = prioritySelected;
                    newTask.ActivityDate = dueDate.date();
                    newTask.Due_Date_Time__c = dueDate;
                    newTask.OwnerId = selectedUser;
                    if(taskComment != null && tObj.Description != null){
                        newTask.Description = tObj.Description + '\n' + '\n' +  System.now() + '\n' + taskComment;
                    }
                    else if(taskComment != null && tObj.Description == null){
                        newTask.Description = taskComment;
                    }
                    else if(taskComment == null && tObj.Description != null){
                        newTask.Description = tObj.Description;
                    }
                    
                    createNewTaskFromCaseAssignment.add(newTask);
                }
            }
            try{
                insert createNewTaskFromCaseAssignment;
                delete [Select Id from Task where Id=: updateItemList];
                returnMessage = 'SUCCESS';
            }
            
            catch (Exception e) {
                returnMessage = e.getMessage();
            }
        }
        
        return returnMessage;
    }
    
    //Create Task for Tickets in Acorn based on NLTCS-128 and NLTCS-115
    @AuraEnabled
    public static String updateTheTicketList(Map<Id,String> updateItemMap, DateTime dueDate, String teamName,String teamQueue, String prioritySelected, String primaryTab, Id selectedUser, String taskComment){
        List<Task> createNewTaskFromCaseAssignment = new List<Task>();
        Set<Id> teamNewTaskIds = new Set<Id>();
        List<Task> updateTaskFromTaskAssignment = new List<Task>();
        List<Case> updateCaseOwner = new List<Case>();
        String returnMessage = '';
        system.debug('::'+updateItemMap);
        if(primaryTab == 'ticket'){
            if(selectedUser != null && teamName != null && teamQueue != null){
                for(Case cs : [Select Id, OwnerId from Case where Id=: updateItemMap.keySet()]){
                    Task tObj = new Task();
                    tObj.whatId = cs.Id;
                    tObj.Subject = updateItemMap.get(cs.Id);
                    tObj.Status = 'Open';
                    tObj.Task_Team_Name__c = teamName;
                    tObj.Task_Team_Queue__c = teamQueue;
                    tObj.Priority = prioritySelected;
                    tObj.ActivityDate = dueDate.date();
                    tObj.Due_Date_Time__c = dueDate;
                    tObj.OwnerId = selectedUser;
                    tObj.Description = taskComment;
                    
                    createNewTaskFromCaseAssignment.add(tObj);
                }
            }
            else if(selectedUser != null && teamName == null && teamQueue == null){
                for(Case cs : [Select Id, OwnerId from Case where Id=: updateItemMap.keySet()]){
                    Task tObj = new Task();
                    tObj.whatId = cs.Id;
                    tObj.Subject = updateItemMap.get(cs.Id);
                    tObj.Status = 'Open';
                    tObj.Priority = prioritySelected;
                    tObj.ActivityDate = dueDate.date();
                    tObj.Due_Date_Time__c = dueDate;
                    tObj.OwnerId = selectedUser;
                    tObj.Description = taskComment;
                    
                    createNewTaskFromCaseAssignment.add(tObj);
                }
            }
            else{
                for(Case cs : [Select Id, OwnerId from Case where Id=: updateItemMap.keySet()]){
                    Task tObj = new Task();
                    tObj.whatId = cs.Id;
                    tObj.Process__c = Constant_Util.CASE_ASSIGNMENT;
                    tObj.Subject = updateItemMap.get(cs.Id);
                    tObj.Task_Team_Name__c = teamName;
                    tObj.Task_Team_Queue__c = teamQueue;
                    tObj.Status = 'Completed';
                    tObj.Priority = prioritySelected;
                    tObj.ActivityDate = dueDate.date();
                    tObj.Due_Date_Time__c = dueDate;
                    tObj.OwnerId = UserInfo.getUserId();
                    tObj.Description = taskComment;

                    createNewTaskFromCaseAssignment.add(tObj);
                }
            }
            try{
                if(!createNewTaskFromCaseAssignment.isEmpty()){
                    insert createNewTaskFromCaseAssignment;
                }
                
                returnMessage = 'SUCCESS';
            }
            
            catch(Exception e) {
                returnMessage = e.getMessage();
            }
        }
        
        return returnMessage;
    }
	
    //NLTCS-144 - Task Management Dashboard: Tickets tab case assignment task creation.
    //NLTCS-149 - Task Management Dashboard: Required to create the completed task.
    /*@Future
    public static void teamAssignedTaskMarkComplete(Set<Id> teamNewTaskIds){
        
        List<Task> teamNewTaskFromCaseAssignment = new List<Task>();
        
        for(Task tObj : [SELECT Id,Status from Task where Id=:teamNewTaskIds]){
            tObj.Status = 'Complete';
        }
        
        update teamNewTaskFromCaseAssignment;
    }*/
    
    @AuraEnabled
    public static List<String> getQueuePicklistvalues(){
        String objectName = 'Task' ;
        String field_apiname = 'Task_Team_Queue__c';
        List<String> optionlist = new List<String>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();             
        optionlist.add('--None--');    
        for (Schema.PicklistEntry pv : picklistValues) {
            if(pv.getValue().contains('\'')){
                String teamName = pv.getValue().remove('\'');
                optionlist.add(teamName);
            }
            else{
            	optionlist.add(pv.getValue());    
            }
        }
        optionlist.sort();
        return optionlist;
        
    }

    @AuraEnabled
    public static List<User> getAllActiveUsers(){
        List<String> systemUsersList = new List<String>();
        List<User> activeUsersList = new List<User>();
        String systemUser = '';

        List<Dashboard_Component_Data__mdt> systemUserNameList= [Select Value__c, DeveloperName from Dashboard_Component_Data__mdt where 
                                                             DeveloperName=: 'TaskManagementSystemUser'];
        
        for(Dashboard_Component_Data__mdt dash : systemUserNameList){
            if(dash.Value__c != null){
                systemUser = dash.Value__c;
            }
        }
        
        systemUsersList = systemUser.split(',');
        
        for(User uObj : [Select Id,Email,Name from User where Profile.Name != 'Deactivated Users' and isActive= true and Name Not In : systemUsersList order by Lastname]){
            //userEmailAliasVSUserId.put(uObj.Email.substringBefore('@'),uObj.Id);
            activeUsersList.add(uObj);
        }
        
        return activeUsersList;
    }
    
    @AuraEnabled
    public static String updateWorkflowTaskClose(List<Id> updateItemList){
        
        String returnMessage = '';
        List<Task> updateTaskClose = new List<Task>();
        
        if(updateItemList.size() > 0){
            for(Task tObj : [Select Status from Task where Id=: updateItemList]){
                tObj.Status = 'Closed';
                updateTaskClose.add(tObj);
            }
            try{
                update updateTaskClose;
                returnMessage = 'Success';
            }
            
            catch(Exception e) {
                returnMessage = e.getMessage();
            }
            
        }
        else{
            returnMessage = 'No Rows Selected';
        }
        
        return returnMessage;
    }
    
    
    /*
    * Method to return groupId's for input userId's
    * @owner : Ganesh ram s
    * @param : set<Id>
    */   
    public static set<Id> getUsersForGroupIds(set<Id> groupIds) {
        set<Id> retVal = new set<Id>();
        set<Id> nestedIds = new set<Id>();
        
        for (GroupMember member : [SELECT Id, GroupId, UserOrGroupId
                                   FROM GroupMember
                                   WHERE GroupId = :groupIds
                                   AND UserOrGroupId != null
                                   AND Group.Type =: GROUP_TYPE Limit 1500]) {
                                       if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
                                           nestedIds.add(member.UserOrGroupId);   
                                       } else {
                                           retVal.add(member.UserOrGroupId);
                                       }
                                   }
        // Recursive call.
        if (nestedIds.size() > 0) {
            retVal.addAll(getUsersForGroupIds(nestedIds));
        }
        return retVal;  
    }
    
    /*
    * Method to return group Id's for input userId
    * @owner : Ganesh ram s
    * @param : set<Id>
    */
    public static set<Id> getGroupsForUserIds(set<Id> userOrGroupIds) {
        
        set<Id> retVal = new set<Id>();
        set<Id> nestedIds = new set<Id>();
        
        try {
            for (GroupMember member : [SELECT Id, GroupId, UserOrGroupId
                                       FROM GroupMember
                                       WHERE UserOrGroupId = :userOrGroupIds
                                       AND UserOrGroupId != null
                                       AND Group.Type =: GROUP_TYPE Limit 1500]) {
                                           // If UserOrGroupId is not a user, then add it to the list for recursion.
                                           if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
                                               nestedIds.add(member.UserOrGroupId);   
                                           } else {
                                               // We found a user, so add that group to the list.
                                               retVal.add(member.GroupId);
                                           }
                                       }
            // Recursive call.
            if (nestedIds.size() > 0) {
                // Relies on the uniqueness property of sets to prevent duplicates.
                retVal.addAll(getGroupsForUserIds(nestedIds));
            }
            if(Test.isRunningTest() && retVal.isEmpty())
            {
                throw new ListException();
            }
        }
        catch(Exception e){
            System.debug('Exception occured:'+e);
        }
        return retVal;
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
         
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        } 
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits; 
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
  
  public inherited sharing class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }

  public inherited sharing class workflowDataset {
        @AuraEnabled 
        public String DueDate {get;set;}
        @AuraEnabled 
        public String AssignedTo {get;set;}
        @AuraEnabled
        public String OwnerId {get;set;}
        @AuraEnabled 
        public String TaskAge {get;set;}
        @AuraEnabled 
        public String VendorName {get;set;}
        @AuraEnabled 
        public String TaskId {get;set;}
        @AuraEnabled 
        public String CaseSLADate {get;set;}
        @AuraEnabled
        public String Process {get;set;}
        @AuraEnabled
        public Integer Attempt {get;set;}
        @AuraEnabled
        public String TaskType {get;set;}
        @AuraEnabled
        public String CaseNumber {get;set;}
        @AuraEnabled
        public String CaseType {get;set;}
        @AuraEnabled
        public String CaseSubType {get;set;}
        @AuraEnabled
        public String CaseServiceDate {get;set;}
        @AuraEnabled
        public String CompanyCategory {get;set;}
        @AuraEnabled
        public String Position {get;set;}
        @AuraEnabled
        public String MASAccountNumber {get;set;}
        @AuraEnabled
        public String ClientName {get;set;}
        @AuraEnabled
        public String ClientCode {get;set;}
        @AuraEnabled
        public String AcornWONumber {get;set;}
        @AuraEnabled
        public String ParentVendor {get;set;}
        @AuraEnabled
        public String VendorBU {get;set;}
        @AuraEnabled
        public String WMVendor {get;set;}
        @AuraEnabled
        public String VendorAccountNumber {get;set;}
        @AuraEnabled
        public String Location {get;set;}
        @AuraEnabled
        public String LocationAddress {get;set;}
        @AuraEnabled
        public String LocationCity {get;set;}
        @AuraEnabled
        public String LocationState {get;set;}
        @AuraEnabled
        public String LocationZipCode {get;set;}
        @AuraEnabled
        public String AssetName {get;set;}
        @AuraEnabled
        public String EquipmentSize {get;set;}
        @AuraEnabled
        public String MaterialType {get;set;}
        @AuraEnabled
        public String Subject {get;set;}
		@AuraEnabled//added for 18165
        public String CreatedDate {get;set;}
    }
    
    public inherited sharing class TicketDataset {
        
        @AuraEnabled 
        public String CaseSLADate {get;set;}
        @AuraEnabled
        public String CaseOwner {get;set;}
        @AuraEnabled
        public String TicketTaskSubject {get;set;}
        @AuraEnabled
        public String CaseNumber {get;set;}
        @AuraEnabled
        public String TicketTaskStatus {get;set;}
        @AuraEnabled
        public String CaseId {get;set;}
        @AuraEnabled
        public String TicketOwner {get;set;}
        @AuraEnabled
        public String OwnerId {get;set;}
        @AuraEnabled
        public String TeamQueue {get;set;}
		@AuraEnabled
        public String TicketAge {get;set;}
        @AuraEnabled
        public String AcornTrackingNumber {get;set;}
        @AuraEnabled
        public String VendorName {get;set;}
        @AuraEnabled
        public String ParentVendor {get;set;}
        @AuraEnabled
        public String CaseType {get;set;}
        @AuraEnabled
        public String CaseSubType {get;set;}
        @AuraEnabled
        public String CaseServiceDate {get;set;}
        @AuraEnabled
        public String ClientName {get;set;}
        @AuraEnabled
        public String ClientCode {get;set;}
        @AuraEnabled
        public String Location {get;set;}
        @AuraEnabled
        public String LocationAddress {get;set;}
        @AuraEnabled
        public String LocationCity {get;set;}
        @AuraEnabled
        public String LocationState {get;set;}
        @AuraEnabled
        public String LocationZipCode {get;set;}
        @AuraEnabled
        public String AssetName {get;set;}
        @AuraEnabled
        public String EquipmentSize {get;set;}
        @AuraEnabled
        public String MaterialType {get;set;}
        @AuraEnabled
        public String LocationTimeZone {get;set;}
		@AuraEnabled
        public String ClientPrimarySegment {get;set;}
		@AuraEnabled
        public String AcornWorkOrder {get;set;}
		@AuraEnabled
        public String CaseReason {get;set;}
		@AuraEnabled//added for 18165
        public String CreatedDate {get;set;}
    }
}