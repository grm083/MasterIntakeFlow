Global with sharing class TableListCmpCls {
    
    public static String parentVendorAccount = 'Vendor';
    public static String locationAccount = 'Location';
    public static String isSupervisorAboveRole ; 
    
    @AuraEnabled
    public static Map<String,List<Object>> getParentAccountDetails(){
        Map<String,List<Object>> accountTypeVsAccountList = new Map<String,List<Object>>();
        String parentVendorResponse = '';
        
        Map<Id,AggregateResult> caseIdCheck = new Map<id,AggregateResult>([SELECT whatId Id, COUNT(Id) Task FROM Task WHERE Status = 'Open' and What.Type = 'Case' and Process__c IN('Confirm Vendor Availability','Obtain Schedule Confirmation','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch' ,'Confirm Service Completion with Location','Notify Customer of Delay','Notify Customer of Decline','Notify Customer of Service Update') GROUP BY WhatId Limit 49999]);
        List<ParentDataset> parentAccountList =  getListOfParentAccount(caseIdCheck);
        List<String> columnListNames = getListOfColumnName('Column_Name');
        List<String> fieldAPIName = getListOfColumnAPIName('FieldName');
        
        accountTypeVsAccountList.put('column',columnListNames);
        accountTypeVsAccountList.put('fieldAPIName',fieldAPIName);
        accountTypeVsAccountList.put('parentVendor',parentAccountList);
        //parentVendorResponse = JSON.serialize(accountTypeVsAccountList);
        
        return accountTypeVsAccountList;
    }
    
    @AuraEnabled
    public static Map<String,List<Object>> getAccountDetails(){
        Map<String,List<Object>> accountTypeVsAccountList = new Map<String,List<Object>>();
        Map<Id,AggregateResult> caseIdCheck = new Map<id,AggregateResult>([SELECT whatId Id, COUNT(Id) Task FROM Task WHERE Status = 'Open' and What.Type = 'Case' and Process__c IN('Confirm Vendor Availability','Obtain Schedule Confirmation','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch' ,'Confirm Service Completion with Location','Notify Customer of Delay','Notify Customer of Decline','Notify Customer of Service Update') GROUP BY WhatId Limit 49999]);
        Map<Id,Case> allOpenCases = new Map<Id,Case>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        String vendorResponse = '';
        
        for(Case cObj : [Select Id ,Supplier__c,Location__c,Location__r.Name,Location__r.ShippingStreet,Location__r.ShippingCity,Location__r.ShippingState,
                         Location__r.ShippingPostalCode,Acorn_Work_Order__c,Service_Date__c,Client__r.Name,Client__r.Primary_Segment__c,
                         Client__c, AssetId, Supplier__r.Market_Area__c, Case_Type__c, Case_Sub_Type__c, Supplier__r.Vendor_Business_Unit__c, 
                         Supplier__r.WM_Vendor__c, Client__r.AccountNumber, Client__r.Status__c, Supplier__r.Parent.Name, 
                         Supplier__r.ParentId From Case where Status !=: Constant_Util.CLOSED and Id in: caseIdCheck.keyset() Limit 49999]){
                             allOpenCases.put(cObj.Id,cObj);
                             assetIds.add(cObj.AssetId);
                             accountIds.add(cObj.Supplier__c);
                             accountIds.add(cObj.Location__c);
                         }
        List<dataSet> vendorAccountList = getListOfVendorAccount(caseIdCheck,allOpenCases,assetIds,accountIds);
        //Map<Id,AggregateResult> caseIdCheck = new Map<id,AggregateResult>([SELECT whatId Id, COUNT(Id) Task FROM Task WHERE What.Type = 'Case' and Process__c IN('Obtain Schedule Confirmation','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch' ,'Confirm Service Completion with Location','Notify Customer of Delay','Notify Customer of Decline','Notify Customer of Service Update') GROUP BY WhatId Limit 49999]);
        //List<dataSet> vendorAccountList = getListOfVendorAccount(caseIdCheck);
        List<String> columnListNames = getListOfColumnName('Column_Name');
        List<String> fieldAPIName = getListOfColumnAPIName('FieldName');
        
        accountTypeVsAccountList.put('column',columnListNames);
        accountTypeVsAccountList.put('fieldAPIName',fieldAPIName);
        accountTypeVsAccountList.put('vendor',vendorAccountList);
        //vendorResponse =  JSON.serialize(accountTypeVsAccountList);
        
        return accountTypeVsAccountList;
    }
    
    @AuraEnabled
    public static Map<String,List<Object>> getLocationAccountDetails(){
        Map<String,List<Object>> accountTypeVsAccountList = new Map<String,List<Object>>();
        Map<Id,Case> allOpenCases = new Map<Id,Case>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        String locationResponse = '';
        
        Map<Id,AggregateResult> caseIdCheck = new Map<id,AggregateResult>([SELECT whatId Id, COUNT(Id) Task FROM Task WHERE Status = 'Open' and What.Type = 'Case' and Process__c IN('Confirm Vendor Availability','Obtain Schedule Confirmation','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch' ,'Confirm Service Completion with Location','Notify Customer of Delay','Notify Customer of Decline','Notify Customer of Service Update') GROUP BY WhatId Limit 49999]);
        for(Case cObj : [Select Id ,Supplier__c,Location__c,Location__r.Name,Location__r.ShippingStreet,Location__r.ShippingCity,Location__r.ShippingState,
                         Location__r.ShippingPostalCode,Acorn_Work_Order__c,Service_Date__c,Client__r.Name,Client__r.Primary_Segment__c,
                         Client__c, AssetId, Supplier__r.Market_Area__c, Case_Type__c, Case_Sub_Type__c, Supplier__r.Vendor_Business_Unit__c, 
                         Supplier__r.WM_Vendor__c, Client__r.AccountNumber, Client__r.Status__c, Supplier__r.Parent.Name, 
                         Supplier__r.ParentId From Case where Status !=: Constant_Util.CLOSED and Id in: caseIdCheck.keyset() Limit 49999]){
                             allOpenCases.put(cObj.Id,cObj);
                             assetIds.add(cObj.AssetId);
                             accountIds.add(cObj.Supplier__c);
                             accountIds.add(cObj.Location__c);
                         }
        
        List<dataSet> locationAccountList = getListOfLocationAccount(caseIdCheck,allOpenCases,assetIds,accountIds);
        //Map<Id,AggregateResult> caseIdCheck = new Map<id,AggregateResult>([SELECT whatId Id, COUNT(Id) Task FROM Task WHERE What.Type = 'Case' and Process__c IN('Obtain Schedule Confirmation','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch' ,'Confirm Service Completion with Location','Notify Customer of Delay','Notify Customer of Decline','Notify Customer of Service Update') GROUP BY WhatId Limit 49999]);
        //List<dataSet> locationAccountList = getListOfLocationAccount(caseIdCheck);
        List<String> columnListNames = getListOfColumnName('Column_Name');
        List<String> fieldAPIName = getListOfColumnAPIName('FieldName');
        
        accountTypeVsAccountList.put('column',columnListNames);
        accountTypeVsAccountList.put('fieldAPIName',fieldAPIName);
        accountTypeVsAccountList.put('location',locationAccountList);
        //locationResponse =  JSON.serialize(accountTypeVsAccountList);
        
        return accountTypeVsAccountList;
    }
    
    @AuraEnabled
    public static Map<String,String> getCurrentLoggedInUser(Id currentUserId){
        
        Map<String,String> currentUserVSRole = new Map<String,String>();
        
        User userDetails = [SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:currentUserId ];
        system.debug('userDetails:'+userDetails.UserRole.Name);
        
        if(userDetails.UserRole.Name.contains('Representative')){
            isSupervisorAboveRole = 'false';
        }
        else{
            isSupervisorAboveRole = 'true';
        }
        currentUserVSRole.put('currentUserRole', isSupervisorAboveRole);
        
        return currentUserVSRole;
    }
    
    
    
    @AuraEnabled
    public static String updateSelectedTasks(List<TaskTableWrapper> taskList){
        
        String message = '';
        List<Task> updatedTaskList = new List<Task>();
        try
        { 
            if(taskList.isEmpty()){
                message = 'No records Selected';
            }
            else{
                for(TaskTableWrapper taskTable : taskList){
                    Task ts = new Task();
                    ts.Id = taskTable.TaskId;
                    ts.Outcome__c = taskTable.Outcome;
                    ts.Description = taskTable.Comments;
                    ts.OwnerId = taskTable.AssignedTo;
                    ts.Proposed_Service_Date__c = taskTable.ServiceDate;
                    
                    updatedTaskList.add(ts);
                }
                update updatedTaskList;
                message = 'Records Updated';
            }
        }
        catch(Exception e){
            System.debug('New Error:'+ e.getMessage());
            throw new AuraHandledException(e.getMessage());            
        }
        return message;
    }
    
    public static List<String> getListOfColumnName(String columnName){
        List<String> listOfColumnDisplayed = new List<String>();
        String columnHeaders = '';
        List<Dashboard_Component_Data__mdt> columnNameList= [Select Value__c, DeveloperName from Dashboard_Component_Data__mdt where 
                                                             DeveloperName=: columnName];
        
        for(Dashboard_Component_Data__mdt dash : columnNameList){
            if(dash.Value__c != null){
                columnHeaders = dash.Value__c;
            }
        }
        
        listOfColumnDisplayed = columnHeaders.split(',');
        
        return listOfColumnDisplayed;
    }
    
    public static List<String> getListOfColumnAPIName(String fieldName){
        List<String> listOfColumnAPIName = new List<String>();
        String columnHeadersAPI = '';
        List<Dashboard_Component_Data__mdt> columnNameList= [Select Value__c, DeveloperName from Dashboard_Component_Data__mdt where 
                                                             DeveloperName=: fieldName];
        
        for(Dashboard_Component_Data__mdt dash : columnNameList){
            if(dash.Value__c != null){
                columnHeadersAPI = dash.Value__c;
            }
        }
        
        listOfColumnAPIName = columnHeadersAPI.split(',');
        
        return listOfColumnAPIName;
    }
    
    public static Map<String,Id> getListOfRecordType(){
        Map<String,Id> recordTypeNameVsRecordTypeId = new Map<String,Id>();
        List<AccountRecordType__mdt> listOfAccountRecordType= [Select RecordTypeId__c, DeveloperName, MasterLabel 
                                                               from AccountRecordType__mdt];
        
        for(AccountRecordType__mdt accRcrdType : listOfAccountRecordType ){
            recordTypeNameVsRecordTypeId.put(accRcrdType.MasterLabel,accRcrdType.RecordTypeId__c);
        }
        return recordTypeNameVsRecordTypeId;
    }
    
    public static List<ParentDataset> getListOfParentAccount(Map<Id,AggregateResult> taskrecCheck){
        
        List<Account> listOfAccount = getListOfAccounts(parentVendorAccount,null);
        List<Account> listOfParentAccount = new List<Account>();
        List<ParentDataset> parentAccountCaseOpenTask = new List<ParentDataset>();
        String TaskByParentVendor = 'Vendor';
        
        for(Account acc : listOfAccount){
            if(acc.ParentId == null){
                listOfParentAccount.add(acc);
            }
        }
        
        system.debug('::listOfParentAccount::'+listOfParentAccount.size());
        
        if(listOfParentAccount.size() > 0){
            parentAccountCaseOpenTask = getAllTasksByParentVendor(listOfParentAccount, parentVendorAccount,taskrecCheck);    
        }
        
        system.debug('::parentAccountCaseOpenTask::'+parentAccountCaseOpenTask.size());
        
        return parentAccountCaseOpenTask;
    }
    
    public static List<dataSet> getListOfVendorAccount(Map<Id,AggregateResult> taskrecCheck,Map<Id,Case> allOpenCases, Set<Id> assetIds,Set<Id> accountIds){
        
        List<Account> listOfAccount = getListOfAccounts(parentVendorAccount, accountIds);
        List<Account> listOfVendorAccount = new List<Account>();
        List<dataSet> vendorAccountCaseOpenTask = new List<dataSet>();
        String TaskByVendor = 'Vendor';
        
        for(Account acc : listOfAccount){
            if(acc.ParentId != null){
                listOfVendorAccount.add(acc);
            }
        }
        
        system.debug('::listOfVendorAccount::'+listOfVendorAccount.size());
        
        if(listOfVendorAccount.size() > 0){
            vendorAccountCaseOpenTask = getAllTasksByVendor(listOfVendorAccount, parentVendorAccount,taskrecCheck,allOpenCases, assetIds);    
        }
        
        system.debug('::vendorAccountCaseOpenTask::'+vendorAccountCaseOpenTask.size());
        
        return vendorAccountCaseOpenTask;
    }
    
    public static List<dataSet> getListOfLocationAccount(Map<Id,AggregateResult> taskrecCheck,Map<Id,Case> allOpenCases, Set<Id> assetIds,Set<Id> accountIds){
        
        List<Account> listOfAccount = getListOfAccounts(locationAccount,accountIds);
        List<Account> listOfLocationAccount = new List<Account>();
        List<dataSet> locationAccountCaseOpenTask = new List<dataSet>();
        
        
        for(Account acc : listOfAccount){
            if(acc.ParentId != null){
                listOfLocationAccount.add(acc);
            }
        }
        
        system.debug('::listOfLocationAccount::'+listOfLocationAccount.size());
        
        if(listOfLocationAccount.size() > 0){
            locationAccountCaseOpenTask = getAllTasksByVendor(listOfLocationAccount, locationAccount , taskrecCheck, allOpenCases, assetIds);    
        }
        
        system.debug('::locationAccountCaseOpenTask::'+locationAccountCaseOpenTask.size());
        
        return locationAccountCaseOpenTask;
    }
    
    public static List<ParentDataset> getAllTasksByParentVendor(List<Account> accountLists, String Selection ,Map<Id,AggregateResult> taskrecCheck){
        Map<Id,Case> allOpenCases = new Map<Id,Case>();
        Map<Id,Case> childtaskIdVsChildCase = new Map<Id,Case>();
        Map<Id,Case> allChildAccountOpenCases = new Map<Id,Case>();
        Map<String,String> columnNames = new Map<String,String>();
        Map<Id,List<Task>> accountIdVsTaskList = new Map<Id,List<Task>>();
        Map<Id,List<Task>> childAccountIdVsChildTaskList = new Map<Id,List<Task>>();
        Map<Id,List<TaskTableWrapper>> parentAccountIdVsChildAccountDataset = new Map<Id,List<TaskTableWrapper>>();
        Map<Id,Asset> caseIdVsAsset = new Map<Id,Asset>();
        Map<Id,Asset> childCaseIdVsAsset = new Map<Id,Asset>();
        Map<String,Id> recordTypeNameVsRecordTypeId = getListOfRecordType();
        List<Task> openTaskByCases = new List<Task>();
        List<Task> openTaskByChildCases = new List<Task>();
        List<Account> childAccountList = new List<Account>();
        Map<Id,Asset> idVsAsset = new Map<Id,Asset>();
        Map<Id,List<Id>> parentIdVSChildIds = new Map<Id,List<Id>>();
        Map<Id,Asset> idVsChildAsset = new Map<Id,Asset>();
        List<ParentDataset> parentAccountCaseOpenTask = new List<ParentDataset>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> childAccountIds = new Set<Id>();
        Set<Id> childAssetIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        
        getCurrentLoggedInUser(UserInfo.getUserId());
        
        for(Account acc : accountLists){
            accountIds.add(acc.Id);
        } 
        system.debug('accountIds::'+accountIds);
        childAccountList = [Select Id,Status__c,Primary_Segment__c,AccountNumber,Vendor_Relationship_Manager__c,Market_Area__c,Vendor_Business_Unit__c,
                            WM_Vendor__c,Parent_Vendor_ID__c,ParentId, Parent.Name, Name from Account where parentId =: accountIds 
                            and Acorn_Account_Id__c != 27 and Status__c = 'Active'];
        
        for(Account acc : childAccountList){
            childAccountIds.add(acc.Id);    
        }
        system.debug('childAccountIds::'+childAccountIds);
        if(!childAccountIds.isEmpty()){
            
            for(Case cObj : [Select Id ,Supplier__c,Location__c,Location__r.ShippingStreet,Location__r.ShippingCity,Location__r.ShippingState,
                             Location__r.ShippingPostalCode,Acorn_Work_Order__c,Client__c,Location__r.Name,Client__r.Name,Client__r.Primary_Segment__c,
                             AssetId,Service_Date__c, Supplier__r.Market_Area__c, Case_Sub_Type__c, Case_Type__c, Supplier__r.Vendor_Business_Unit__c, 
                             Supplier__r.WM_Vendor__c, Client__r.AccountNumber, Client__r.Status__c, Supplier__r.Parent.Name, Supplier__r.ParentId 
                             From Case where Status !=: Constant_Util.CLOSED and (Supplier__c =: childAccountIds or Location__c =: childAccountIds) and Id in: taskrecCheck.keyset() Limit 49999]){
                                 allChildAccountOpenCases.put(cObj.Id,cObj);
                                 childAssetIds.add(cObj.AssetId);                
                             }
            
            if (Selection == 'Vendor')
            {
                if(isSupervisorAboveRole == 'false')
                {
                    openTaskByChildCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                            Process__c,Owner.Name,Proposed_Service_Date__c, OwnerId, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                            Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allChildAccountOpenCases.keyset() and OwnerId =: UserInfo.getUserId()
                                            and ((Process__c IN('Confirm Vendor Availability','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch')) or (Process__c = 'Obtain Schedule Confirmation' and Due_Date_Time__c <= NEXT_N_DAYS:14)) order by Due_Date_Time__c desc Limit 49999];
                }
                
                else{
                    openTaskByChildCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                            Process__c,Owner.Name,Proposed_Service_Date__c, OwnerId, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                            Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allChildAccountOpenCases.keyset() 
                                            and ((Process__c IN('Confirm Vendor Availability','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch')) or (Process__c = 'Obtain Schedule Confirmation' and Due_Date_Time__c <= NEXT_N_DAYS:14)) order by Due_Date_Time__c desc Limit 49999];
                }
            }
            
            for(Asset ast : [Select Id, Category__c, Equipment_Size__c, Material_Type__c, MAS_Account_Number__c, Vendor_Account_Number__c
                             , Container_Position__c, Project__c, Name from Asset where Id in : childAssetIds Limit 49999]){
                idVsChildAsset.put(ast.Id,ast);
            }
            
            for(Task ar : openTaskByChildCases){
                Case taskRelatedChildCase = new Case();
                taskRelatedChildCase = allChildAccountOpenCases.get(ar.whatId);
                Id AccountId = null;
                if (Selection == 'Vendor'){
                    AccountId = taskRelatedChildCase.Supplier__c;
                }
                Id relatedAssetId = taskRelatedChildCase.AssetId;
                if(childAccountIdVsChildTaskList.containsKey(AccountId) && childAccountIdVsChildTaskList.get(AccountId) != null){
                    List<Task> taskrec = childAccountIdVsChildTaskList.get(AccountId);
                    taskrec.add(ar);
                    childAccountIdVsChildTaskList.put(AccountId,taskrec);
                }
                else {
                    childAccountIdVsChildTaskList.put(AccountId ,new List<Task>{ar} );  
                }
                childCaseIdVsAsset.put(ar.Id,idVsChildAsset.get(relatedAssetId));
            }
            
            system.debug('::childAccountIdVsChildTaskList::'+childAccountIdVsChildTaskList.size());
            
            for (Account ac : childAccountList){
                List<TaskTableWrapper> childAccountCaseOpenTask = new List<TaskTableWrapper>();
                List<Task> childOpenTaskList = new List<Task>();
                Integer size  =  0 ;
                if(childAccountIdVsChildTaskList.get(ac.id)!= null){
                    childOpenTaskList = childAccountIdVsChildTaskList.get(ac.id);
                    if(childOpenTaskList.size()!=null){
                        for(Task ts : childOpenTaskList){
                            Case taskRelatedChildCase = new Case();
                            taskRelatedChildCase = allChildAccountOpenCases.get(ts.whatId);
                            TaskTableWrapper taskTable = new TaskTableWrapper();
                            taskTable.TaskId = ts.Id;
                            taskTable.TaskName = ts.Subject;
                            taskTable.CaseNumber = ts.What.Name;
                            taskTable.CaseId = ts.WhatId;
                            taskTable.ServiceDate = ts.Proposed_Service_Date__c;
                            taskTable.Process = ts.Process__c;
                            taskTable.Outcome = ts.Outcome__c;
                            taskTable.DueDateTime = ts.Due_Date_Time__c;
                            if(childCaseIdVsAsset.get(ts.Id) != null){
                                taskTable.AssetId = childCaseIdVsAsset.get(ts.Id).Id;
                                taskTable.AssetName = childCaseIdVsAsset.get(ts.Id).Name;
                                taskTable.CompanyCategory = childCaseIdVsAsset.get(ts.Id).Category__c;
                                taskTable.Position = childCaseIdVsAsset.get(ts.Id).Container_Position__c; 
                                taskTable.AssetProject = childCaseIdVsAsset.get(ts.Id).Project__c;
                                taskTable.AssetEquipmentSize = childCaseIdVsAsset.get(ts.Id).Equipment_Size__c;
                                taskTable.AssetMaterialType = childCaseIdVsAsset.get(ts.Id).Material_Type__c;
                                taskTable.AssetMASAccountNumber = childCaseIdVsAsset.get(ts.Id).MAS_Account_Number__c;
                                taskTable.AssetVendorAccountNumber = childCaseIdVsAsset.get(ts.Id).Vendor_Account_Number__c;
                            }
                            taskTable.ContactEmail = ts.Contact_Email__c;
                            taskTable.ContactNumber = ts.Contact_Number__c;
                            taskTable.ContactTitle = ts.Contact_Title__c;
                            taskTable.ContactMethod = ts.Preferred_Contact_Method__c;
                            taskTable.AccountName = taskRelatedChildCase.Client__r.Name;
                            taskTable.AccountId = taskRelatedChildCase.Client__c;
                            taskTable.AccountNumber = ac.AccountNumber;
                            taskTable.AcornWONumber = taskRelatedChildCase.Acorn_Work_Order__c;
                            taskTable.Status = ac.Status__c;
                            taskTable.ParentVendor = ac.Parent.Name;
                            taskTable.ParentVendorId = ac.ParentId;
                            taskTable.LocationAccount = taskRelatedChildCase.Location__r.Name;
                            taskTable.LocationAccountId = taskRelatedChildCase.Location__c;
                            taskTable.LocationAddress = taskRelatedChildCase.Location__r.ShippingStreet;
                            taskTable.LocationCity = taskRelatedChildCase.Location__r.ShippingCity;
                            taskTable.LocationState = taskRelatedChildCase.Location__r.ShippingState;
                            taskTable.LocationZipCode = taskRelatedChildCase.Location__r.ShippingPostalCode;
                            taskTable.CaseType = taskRelatedChildCase.Case_Type__c;
                            taskTable.CaseSubType = taskRelatedChildCase.Case_Sub_Type__c;
                            taskTable.MarketArea = taskRelatedChildCase.Supplier__r.Market_Area__c;
                            taskTable.VendorBU = taskRelatedChildCase.Supplier__r.Vendor_Business_Unit__c;
                            taskTable.WMVendor = taskRelatedChildCase.Supplier__r.WM_Vendor__c;
                            taskTable.Comments = ts.Description;
                            taskTable.AssignedTo = ts.OwnerId;
                            taskTable.AssignedToName = ts.Owner.Name;
                            taskTable.AccountType = taskRelatedChildCase.Client__r.Primary_Segment__c;
                            taskTable.TaskAttempt = ts.Attempt__c;
                            taskTable.ShowServiceDateAsEdit = false;
                            
                            childAccountCaseOpenTask.add(taskTable);
                        }
                        parentAccountIdVsChildAccountDataset.put(ac.Id,childAccountCaseOpenTask);
                    }
                }
                if(parentIdVSChildIds.containsKey(ac.ParentId) && parentIdVSChildIds.get(ac.ParentId) != null){
                    List<Id> childAccIds = parentIdVSChildIds.get(ac.ParentId);
                    childAccIds.add(ac.Id);
                    parentIdVSChildIds.put(ac.ParentId,childAccIds);
                }
                else {
                    parentIdVSChildIds.put(ac.ParentId,new List<Id>{ac.Id});
                }
            }
        }
        
        system.debug('::parentAccountIdVsChildAccountDataset::'+parentAccountIdVsChildAccountDataset);
        
        for(Case cObj : [Select Id ,Supplier__c,Location__c,Location__r.ShippingStreet,Location__r.ShippingCity,Location__r.ShippingState,
                         Location__r.ShippingPostalCode,Acorn_Work_Order__c,Client__c,Location__r.Name,Client__r.Name,Client__r.Primary_Segment__c,
                         AssetId,Service_Date__c, Supplier__r.Market_Area__c, Case_Type__c, Case_Sub_Type__c, Supplier__r.Vendor_Business_Unit__c,
                         Supplier__r.WM_Vendor__c, Client__r.AccountNumber, Client__r.Status__c,Supplier__r.Parent.Name, Supplier__r.ParentId From Case where 
                         Status !=: Constant_Util.CLOSED and (Supplier__c =: accountIds or Location__c =: accountIds) and Id in: taskrecCheck.keyset() Limit 49999]){
                             allOpenCases.put(cObj.Id,cObj);
                             assetIds.add(cObj.AssetId);                
                         }
        
        if (Selection == 'Vendor')
        {
            if(isSupervisorAboveRole == 'false')
            {
                openTaskByCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                   Process__c,Owner.Name,Proposed_Service_Date__c, OwnerId, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                   Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allOpenCases.keyset() and OwnerId =: UserInfo.getUserId()
                                   and ((Process__c IN('Confirm Vendor Availability','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch')) or (Process__c = 'Obtain Schedule Confirmation' and Due_Date_Time__c <= NEXT_N_DAYS:14)) order by Due_Date_Time__c desc Limit 49999];
            }
            
            else{
                openTaskByCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                   Process__c,Owner.Name,Proposed_Service_Date__c, OwnerId, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                   Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allOpenCases.keyset() 
                                   and ((Process__c IN('Confirm Vendor Availability','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch')) or (Process__c = 'Obtain Schedule Confirmation' and Due_Date_Time__c <= NEXT_N_DAYS:14)) order by Due_Date_Time__c desc Limit 49999];
            }
        }
        
        for(Asset ast : [Select Id, Category__c, Equipment_Size__c, Material_Type__c, MAS_Account_Number__c, Vendor_Account_Number__c
                         , Container_Position__c, Project__c, Name from Asset where Id in : assetIds Limit 49999]){
            idVsAsset.put(ast.Id,ast);
        }
        
        for(Task ar : openTaskByCases){
            Case taskRelatedCase = new Case();
            taskRelatedCase = allOpenCases.get(ar.whatId);
            Id AccountId = null;
            if (Selection == 'Vendor'){
                AccountId = taskRelatedCase.Supplier__c;
            }
            Id relatedAssetId = taskRelatedCase.AssetId;
            if(accountIdVsTaskList.containsKey(AccountId) && accountIdVsTaskList.get(AccountId) != null){
                List<Task> taskrec = accountIdVsTaskList.get(AccountId);
                taskrec.add(ar);
                accountIdVsTaskList.put(AccountId,taskrec);
            }
            else {
                accountIdVsTaskList.put(AccountId ,new List<Task>{ar} );  
            }
            caseIdVsAsset.put(ar.Id,idVsAsset.get(relatedAssetId));
        }
        
        system.debug('::accountIdVsTaskList::'+accountIdVsTaskList.size());
        
        for (Account ac : accountLists){
            List<TaskTableWrapper> openTableTaskList = new List<TaskTableWrapper>();
            List<Task> openTaskList = new List<Task>();
            Integer size  =  0 ;
            ParentDataset pds = new ParentDataset();
            if(accountIdVsTaskList.get(ac.id)!= null){
                openTaskList = accountIdVsTaskList.get(ac.id);
                if(openTaskList.size()!=null){
                    for(Task ts : openTaskList){
                        Case taskRelatedCase = new Case();
                        taskRelatedCase = allOpenCases.get(ts.whatId);
                        TaskTableWrapper taskTable = new TaskTableWrapper();
                        taskTable.TaskId = ts.Id;
                        taskTable.TaskName = ts.Subject;
                        taskTable.CaseNumber = ts.What.Name;
                        taskTable.CaseId = ts.WhatId;
                        taskTable.ServiceDate = ts.Proposed_Service_Date__c;
                        taskTable.Process = ts.Process__c;
                        taskTable.Outcome = ts.Outcome__c;
                        taskTable.DueDateTime = ts.Due_Date_Time__c;
                        if(caseIdVsAsset.get(ts.Id) != null){
                            taskTable.AssetId = caseIdVsAsset.get(ts.Id).Id;
                            taskTable.AssetName = caseIdVsAsset.get(ts.Id).Name;
                            taskTable.CompanyCategory = caseIdVsAsset.get(ts.Id).Category__c;
                            taskTable.Position = caseIdVsAsset.get(ts.Id).Container_Position__c; 
                            taskTable.AssetProject = caseIdVsAsset.get(ts.Id).Project__c;
                            taskTable.AssetEquipmentSize = caseIdVsAsset.get(ts.Id).Equipment_Size__c;
                            taskTable.AssetMaterialType = caseIdVsAsset.get(ts.Id).Material_Type__c;
                            taskTable.AssetMASAccountNumber = caseIdVsAsset.get(ts.Id).MAS_Account_Number__c;
                            taskTable.AssetVendorAccountNumber = caseIdVsAsset.get(ts.Id).Vendor_Account_Number__c;
                        }
                        taskTable.ContactEmail = ts.Contact_Email__c;
                        taskTable.ContactNumber = ts.Contact_Number__c;
                        taskTable.ContactTitle = ts.Contact_Title__c;
                        taskTable.ContactMethod = ts.Preferred_Contact_Method__c;
                        taskTable.AccountName = taskRelatedCase.Client__r.Name;
                        taskTable.AccountId = taskRelatedCase.Client__c;
                        taskTable.AccountNumber = ac.AccountNumber;
                        taskTable.AcornWONumber = taskRelatedCase.Acorn_Work_Order__c;
                        taskTable.Status = ac.Status__c;
                        taskTable.ParentVendor = ac.Name;
                        taskTable.ParentVendorId = ac.Id;
                        taskTable.LocationAccount = taskRelatedCase.Location__r.Name;
                        taskTable.LocationAccountId = taskRelatedCase.Location__c;
                        taskTable.LocationAddress = taskRelatedCase.Location__r.ShippingStreet;
                        taskTable.LocationCity = taskRelatedCase.Location__r.ShippingCity;
                        taskTable.LocationState = taskRelatedCase.Location__r.ShippingState;
                        taskTable.LocationZipCode = taskRelatedCase.Location__r.ShippingPostalCode;
                        taskTable.CaseType = taskRelatedCase.Case_Type__c;
                        taskTable.CaseSubType = taskRelatedCase.Case_Sub_Type__c;
                        taskTable.MarketArea = taskRelatedCase.Supplier__r.Market_Area__c;
                        taskTable.VendorBU = taskRelatedCase.Supplier__r.Vendor_Business_Unit__c;
                        taskTable.WMVendor = taskRelatedCase.Supplier__r.WM_Vendor__c;
                        taskTable.Comments = ts.Description;
                        taskTable.AssignedTo = ts.OwnerId;
                        taskTable.AssignedToName = ts.Owner.Name;
                        taskTable.AccountType = taskRelatedCase.Client__r.Primary_Segment__c;
                        taskTable.TaskAttempt = ts.Attempt__c;
                        taskTable.ShowServiceDateAsEdit = false;
                        
                        openTableTaskList.add(taskTable);
                    }
                    for(Id accId : parentIdVSChildIds.keySet()){
                        if(ac.Id == accId){
                            for(Id childAccId : parentIdVSChildIds.get(accId)){
                                if(parentAccountIdVsChildAccountDataset.get(childAccId) != null){
                                    openTableTaskList.addAll(parentAccountIdVsChildAccountDataset.get(childAccId));
                                }        
                            }
                        }
                    }
                    size = openTableTaskList.size();
                    pds.isChecked = false;
                    pds.accRecord = ac;
                    pds.tasklist = openTableTaskList;
                    pds.count = size;
                    pds.AccountName = ac.Name ;
                    if(!parentAccountCaseOpenTask.contains(pds)){
                        parentAccountCaseOpenTask.add(pds);
                    }
                    //parentAccountCaseOpenTask.add(pds);
                }
            }
            else{
                if(parentIdVSChildIds.containsKey(ac.id)){
                    for(Id accId : parentIdVSChildIds.keySet()){
                        if(ac.Id == accId){
                            for(Id childAccId : parentIdVSChildIds.get(accId)){
                                if(parentAccountIdVsChildAccountDataset.get(childAccId) != null){
                                    openTableTaskList.addAll(parentAccountIdVsChildAccountDataset.get(childAccId));
                                    size = openTableTaskList.size();
                                    pds.isChecked = false;
                                    pds.accRecord = ac;
                                    pds.tasklist = openTableTaskList;
                                    pds.count = size;
                                    pds.AccountName = ac.Name ;
                                    if(!parentAccountCaseOpenTask.contains(pds)){
                                        parentAccountCaseOpenTask.add(pds);
                                    }
                                    
                                }        
                            }
                        }
                    }
                }
            }
        }
        system.debug('::parentAccountCaseOpenTask::'+parentAccountCaseOpenTask);
        
        parentAccountCaseOpenTask.sort();
        return parentAccountCaseOpenTask; 
    }
    
    public static List<dataSet> getAllTasksByVendor(List<Account> accountLists, String Selection ,Map<Id,AggregateResult> taskrecCheck, Map<Id,Case> allOpenCases, Set<Id> assetIds){
        Map<String,String> columnNames = new Map<String,String>();
        Map<Id,List<Task>> accountIdVsTaskList = new Map<Id,List<Task>>();
        Map<Id,Asset> caseIdVsAsset = new Map<Id,Asset>();
        List<Task> openTaskByCases = new List<Task>();
        Map<Id,Asset> idVsAsset = new Map<Id,Asset>();
        List<dataSet> parentAccountCaseOpenTask = new List<dataSet>();
        Set<Id> accountIds = new Set<Id>();
        
        getCurrentLoggedInUser(UserInfo.getUserId());
        
        if (Selection == 'Vendor')
        {
            if(isSupervisorAboveRole == 'false')
            {
                openTaskByCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                   Process__c,Owner.Name,Proposed_Service_Date__c, OwnerId, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                   Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allOpenCases.keyset() and OwnerId =: UserInfo.getUserId()
                                   and ((Process__c IN('Confirm Vendor Availability','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch')) or (Process__c = 'Obtain Schedule Confirmation' and Due_Date_Time__c <= NEXT_N_DAYS:14)) order by Due_Date_Time__c desc Limit 49999];
            }
            
            else{
                openTaskByCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                   Process__c,Owner.Name,Proposed_Service_Date__c, OwnerId, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                   Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allOpenCases.keyset() 
                                   and ((Process__c IN('Confirm Vendor Availability','Confirm Service Completion','Obtain Vendor Update','Manually Dispatch')) or (Process__c = 'Obtain Schedule Confirmation' and Due_Date_Time__c <= NEXT_N_DAYS:14)) order by Due_Date_Time__c desc Limit 49999];
            }
        }
        
        if (Selection == 'Location')
        {
            if(isSupervisorAboveRole == 'false')
            {  openTaskByCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                  Process__c,Owner.Name,OwnerId,Proposed_Service_Date__c, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                  Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allOpenCases.keyset() and OwnerId =: UserInfo.getUserId()
                                  and Process__c IN('Confirm Service Completion with Location','Notify Customer of Delay','Notify Customer of Decline','Notify Customer of Service Update') Limit 49999];
            }
            else {
                openTaskByCases = [Select Id ,WhatId,What.Name,Status, Description, Subject,Type,Due_Date_Time__c,Outcome__c,Approver_Type__c,
                                   Process__c,Owner.Name,OwnerId,Proposed_Service_Date__c, Contact_Email__c,Contact_Number__c,Contact_Title__c,
                                   Preferred_Contact_Method__c,Attempt__c from Task where Status = 'Open' and WhatId in : allOpenCases.keyset()
                                   and Process__c IN('Confirm Service Completion with Location','Notify Customer of Delay','Notify Customer of Decline','Notify Customer of Service Update') Limit 49999];
            }
        }
        
        for(Asset ast : [Select Id, Category__c, Equipment_Size__c, Material_Type__c, MAS_Account_Number__c, Vendor_Account_Number__c
                         , Container_Position__c, Project__c, Name from Asset where Id in : assetIds LIMIT 49999]){
            idVsAsset.put(ast.Id,ast);
        }
        
        for(Task ar : openTaskByCases){
            Case taskRelatedCase = new Case();
            taskRelatedCase = allOpenCases.get(ar.whatId);
            Id AccountId = null;
            if (Selection == 'Vendor'){
                AccountId = taskRelatedCase.Supplier__c;
            }
            else if (Selection == 'Location'){
                AccountId = taskRelatedCase.Location__c;
            }
            Id relatedAssetId = taskRelatedCase.AssetId;
            if(accountIdVsTaskList.containsKey(AccountId) && accountIdVsTaskList.get(AccountId) != null){
                List<Task> taskrec = accountIdVsTaskList.get(AccountId);
                taskrec.add(ar);
                accountIdVsTaskList.put(AccountId,taskrec);
            }
            else {
                accountIdVsTaskList.put(AccountId ,new List<Task>{ar} );  
            }
            caseIdVsAsset.put(ar.Id,idVsAsset.get(relatedAssetId));
        }
        
        for (Account ac : accountLists){
            List<TaskTableWrapper> openTableTaskList = new List<TaskTableWrapper>();
            List<Task> openTaskList = new List<Task>();
            Integer size  =  0 ;
            if(accountIdVsTaskList.get(ac.id)!= null){
                openTaskList = accountIdVsTaskList.get(ac.id);
                if(openTaskList.size()!=null){
                    for(Task ts : openTaskList){
                        Case taskRelatedCase = new Case();
                        taskRelatedCase = allOpenCases.get(ts.whatId);
                        TaskTableWrapper taskTable = new TaskTableWrapper();
                        taskTable.TaskId = ts.Id;
                        taskTable.TaskName = ts.Subject;
                        taskTable.CaseNumber = ts.What.Name;
                        taskTable.CaseId = ts.WhatId; 
                        taskTable.ServiceDate = ts.Proposed_Service_Date__c;
                        taskTable.Process = ts.Process__c;
                        taskTable.Outcome = ts.Outcome__c;
                        taskTable.DueDateTime = ts.Due_Date_Time__c;
                        if(caseIdVsAsset.get(ts.Id) != null){
                            taskTable.AssetId = caseIdVsAsset.get(ts.Id).Id;
                            taskTable.AssetName = caseIdVsAsset.get(ts.Id).Name;
                            taskTable.CompanyCategory = caseIdVsAsset.get(ts.Id).Category__c;
                            taskTable.Position = caseIdVsAsset.get(ts.Id).Container_Position__c; 
                            taskTable.AssetProject = caseIdVsAsset.get(ts.Id).Project__c;
                            taskTable.AssetEquipmentSize = caseIdVsAsset.get(ts.Id).Equipment_Size__c;
                            taskTable.AssetMaterialType = caseIdVsAsset.get(ts.Id).Material_Type__c;
                            taskTable.AssetMASAccountNumber = caseIdVsAsset.get(ts.Id).MAS_Account_Number__c;
                            taskTable.AssetVendorAccountNumber = caseIdVsAsset.get(ts.Id).Vendor_Account_Number__c;
                        }
                        taskTable.ContactEmail = ts.Contact_Email__c;
                        taskTable.ContactNumber = ts.Contact_Number__c;
                        taskTable.ContactTitle = ts.Contact_Title__c;
                        taskTable.ContactMethod = ts.Preferred_Contact_Method__c;
                        taskTable.AccountName = taskRelatedCase.Client__r.Name;
                        taskTable.AccountId = taskRelatedCase.Client__c;
                        taskTable.AccountNumber = taskRelatedCase.Client__r.AccountNumber;
                        taskTable.AcornWONumber = taskRelatedCase.Acorn_Work_Order__c;
                        taskTable.Status = taskRelatedCase.Client__r.Status__c;
                        taskTable.ParentVendor = taskRelatedCase.Supplier__r.Parent.Name;
                        taskTable.ParentVendorId = taskRelatedCase.Supplier__r.ParentId;
                        taskTable.LocationAccount = taskRelatedCase.Location__r.Name;
                        taskTable.LocationAccountId = taskRelatedCase.Location__c;
                        taskTable.LocationAddress = taskRelatedCase.Location__r.ShippingStreet;
                        taskTable.LocationCity = taskRelatedCase.Location__r.ShippingCity;
                        taskTable.LocationState = taskRelatedCase.Location__r.ShippingState;
                        taskTable.LocationZipCode = taskRelatedCase.Location__r.ShippingPostalCode;
                        taskTable.CaseType = taskRelatedCase.Case_Type__c;
                        taskTable.CaseSubType = taskRelatedCase.Case_Sub_Type__c;
                        taskTable.MarketArea = taskRelatedCase.Supplier__r.Market_Area__c;
                        taskTable.VendorBU = taskRelatedCase.Supplier__r.Vendor_Business_Unit__c;
                        taskTable.WMVendor = taskRelatedCase.Supplier__r.WM_Vendor__c;
                        taskTable.Comments = ts.Description;
                        taskTable.AssignedTo = ts.OwnerId;
                        taskTable.AssignedToName = ts.Owner.Name;
                        taskTable.AccountType = taskRelatedCase.Client__r.Primary_Segment__c;
                        taskTable.TaskAttempt = ts.Attempt__c;
                        taskTable.ShowServiceDateAsEdit = false;
                        
                        openTableTaskList.add(taskTable);
                    }
                    size = openTableTaskList.size();
                    Dataset ds = new Dataset();
                    ds.isChecked = false;
                    ds.accRecord  = ac ;
                    ds.tasklist = openTableTaskList;
                    ds.count = size;
                    ds.AccountName = ac.Name ;
                    parentAccountCaseOpenTask.add(ds);
                    //parentAccountCaseOpenTask.add(new Dataset(false,ac,openTaskList,accountIdVsAsset.get(ac.id),size));    
                }
            }
            
        }
        system.debug('::parentAccountCaseOpenTask::'+parentAccountCaseOpenTask);
        
        parentAccountCaseOpenTask.sort();
        return parentAccountCaseOpenTask;  
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
    
    public static List<Account> getListOfAccounts(String typeOfAccount, Set<Id> accountIds){
        
        Map<String,Id> recordTypeNameVsRecordTypeId = getListOfRecordType();
        system.debug('recordTypeNameVsRecordTypeId.get(typeOfAccount):'+recordTypeNameVsRecordTypeId.get(typeOfAccount));
        List<Account> listOfRequiredAccount = new List<Account>();
        if(accountIds != null){
            listOfRequiredAccount = [Select Id,Status__c,Primary_Segment__c, Type,AccountNumber,Vendor_Relationship_Manager__c,Market_Area__c,Vendor_Business_Unit__c,
                                     WM_Vendor__c,Parent_Vendor_ID__c,ParentId, Parent.Name, Name from Account where 
                                     recordTypeId =:recordTypeNameVsRecordTypeId.get(typeOfAccount) and Status__c = 'Active' 
                                     and Acorn_Account_Id__c != 27 and Id=: accountIds Limit 49999];
        }
        else{
            listOfRequiredAccount = [Select Id,Status__c,Primary_Segment__c, Type,AccountNumber,Vendor_Relationship_Manager__c,Market_Area__c,Vendor_Business_Unit__c,
                                     WM_Vendor__c,Parent_Vendor_ID__c,ParentId, Parent.Name, Name from Account where 
                                     recordTypeId =:recordTypeNameVsRecordTypeId.get(typeOfAccount) and Status__c = 'Active' 
                                     and Acorn_Account_Id__c != 27 Limit 49999];
        }
        
        system.debug(listOfRequiredAccount.size());
        
        return listOfRequiredAccount;
    }
    
    
    
    Global inherited sharing class ParentDataset implements Comparable{
        @AuraEnabled 
        public boolean isChecked {get;set;}
        @AuraEnabled
        public Account accRecord {get;set;}
        @AuraEnabled
        public List<TaskTableWrapper> tasklist {get;set;}
        @AuraEnabled
        public Integer  count {get;set;}
        @AuraEnabled
        public String AccountName {get;set;}
        
        public ParentDataset(){
            this.isChecked = false;
            this.accRecord  = null;
            this.tasklist = null;
            this.count = 0;
        }
        
        global Integer compareTo(Object objToCompare) {
            return Integer.valueOf((((ParentDataset)objToCompare).Count) - Count);
            
        }  
    }
    
    Global inherited sharing class Dataset implements Comparable{
        @AuraEnabled 
        public boolean isChecked {get;set;}
        @AuraEnabled
        public Account accRecord {get;set;}
        @AuraEnabled
        public Case taskRelatedCase {get;set;}
        @AuraEnabled
        public List<TaskTableWrapper> tasklist {get;set;}
        @AuraEnabled
        public Asset ast {get;set;}
        @AuraEnabled
        public Integer  count {get;set;}
        @AuraEnabled
        public String AccountName {get;set;}
        
        public Dataset(){
            this.isChecked = false;
            this.accRecord  = null ;
            this.tasklist = null;
            this.ast = null;
            this.count = 0;
            this.taskRelatedCase = null;
            
        }
        
        global Integer compareTo(Object objToCompare) {
            return Integer.valueOf((((Dataset)objToCompare).Count) - Count);
            
        }  
    }   
    
    public inherited sharing class PicklistEntryWrapper{
        //public String active {get;set;}
        //public String defaultValue {get;set;}
        public String label {get;set;}
        // public String value {get;set;}
        public String validFor {get;set;}
        
        
    }
}