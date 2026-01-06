/**
* @author Accenture
* @date 3/25/2019
* @description : Controller class for CustomCalendar lightning component
**/
public with sharing class CaseController {
    
    /**
* @author Accenture
* @date 3/25/2019
* @description : Wrapper class to return data to the CustomCalendar lightning component
**/
    public inherited sharing class CaseSuccess{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<WorkOrder> dupList = new List<WorkOrder>();
        @AuraEnabled public List<Case> childCases = new List<Case>();
    }
    
    /**
* @author Accenture
* @date 3/25/2019
* @description : method to create multiple cases
**/
    @AuraEnabled
    public static CaseSuccess createMultipleCasesInvoke(list<string> selectedDueDateStr, string caseRecId, Boolean doNotReturn, Boolean Create_AM_PM_Pickup) {
        list<case> caseList= new list<case>();
        DateTime slaDateTime = null;
      
        CaseSuccess wrap = new CaseSuccess();
        try{
            Case selectedCase = [SELECT id, SLA_Service_Date_Time__c, SLA_Service_DateTime__c,Is_MultiCase_TaskBundling__c, AccountId,CaseNumber,Case_Information__c,Override_PO_Create_Task__c,User_Input_Work_Order_Instructions__c,recordTypeId, Location__c, Reference_Number__c, AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,Site_Contact_Phone__c,SalesMeet_Container_Position__c,Supplier__c,PurchaseOrder_Number__c,PSI__c,Profile_Number__c,PSI_Required__c,Override_Profile_Number_Task__c,PurchaseOrder_Required__c,SLA_Override_Reason__c,/*Work_Order_Instructions__c,*/isMultiCalendarChecked__c,
				Company_Category__c,Override_Company_Category_Create_Task__c  
                                 FROM Case 
                                 WHERE id=:caseRecId]; 
            //System.debug('>>>selectedCase-->'+ selectedCase );
            
            If(selectedCase.SLA_Service_Date_Time__c != null){ 
                slaDateTime = DateTime.newInstanceGmt(selectedCase.SLA_Service_Date_Time__c.dateGmt(), selectedCase.SLA_Service_Date_Time__c.TimeGmt());
                slaDateTime =  casetriggerhelper.getservicedatetime(slaDateTime,selectedCase);
            }
			
            
            for(string strObj :selectedDueDateStr){
                Case newCase= new case();
                newCase = selectedCase.clone(false, false, false, false);
                
                string str= strObj;
                string [] strlist = str.split('/');
                newCase.Service_Date__c = Date.newInstance(Integer.valueof(strlist[2]), 
                                                           Integer.valueof(strlist[0]), 
                                                           Integer.valueof(strlist[1]));    
             
                
               
             if(newCase.Service_Date__c != null && slaDateTime != null && newCase.Service_Date__c < slaDateTime.dateGmt()){
                    newCase.Check_Case__c = false;                     
                }
                else{
                   newCase.Check_Case__c = true;                    
                }
				            
                
                newCase.ParentId = selectedCase.Id; 
                newCase.Is_Clone__c = true;

		            newCase.Is_MultiCase_TaskBundling__c = true;

                //newCase.Is_Multiple_Asset__c = true;  //commenting out this flag will change the case behavior entirely 

               
                if(doNotReturn && selectedDueDateStr.indexOf(strObj) == selectedDueDateStr.size()-1){
                    newCase.Case_Sub_Type__c = Constant_Util.EMPTY_AND_DONOT_RETURN;
                }
                caseList.add(newCase);
                
            }
           
            if(!caseList.isEmpty()){
                insert caseList;
                for(Case caseObj : caseList){
                    copyEmailToChildCase(selectedCase.Id,caseObj);
                    copyAcornCommentsToChildCase(selectedCase.Id,caseObj);
                }
            }
            
            selectedCase.isMultiCalendarChecked__c = true; 

		      selectedCase.Is_MultiCase_TaskBundling__c = true;
			
			    //selectedCase.Is_Multiple_Asset__c = true; //commenting out this flag will change the case behavior entirely 

            selectedCase.Create_AM_and_PM_pickups__c = Create_AM_PM_Pickup;
// Modified for SDT-33443 Start
            if(selectedCase != null){
            update selectedCase;
            }
            // Modified for SDT-33443 End
            
            //System.debug('selectedCase-->'+ selectedCase );
            List<WorkOrder> duplicates = new List<WorkOrder>();
             
            if(!caseList.isEmpty()){
            	duplicates = multidateDuplicateCheck(caseList);
            }
           
            if(!duplicates.isEmpty()){
                wrap.dupList = duplicates;
                wrap.childCases = caseList;
                
            }
            
            wrap.success = true;
            return wrap;
        }catch(Exception ex){  // Catch block to catch error messages  
            wrap.success = false;
            wrap.message = ex.getMessage()+'\n'+ex.getStackTraceString();
            return wrap;
        }
    }
    
    public static List<WorkOrder> multidateDuplicateCheck(List<Case> checkList){
        String assetId = checkList[0].assetId;
        String locationId = checkList[0].Location__c;
        String caseType = checkList[0].Case_Type__c;
        List<Date> serviceDates = new List<Date>();
        Map<Date,Id> caseDateMap = new Map<Date,Id>();
        Set<Id> caseIds = new Set<Id>();
        List<WorkOrder> returnList = new List<WorkOrder>();
        for(Case cse : checkList){
            serviceDates.add(cse.Service_Date__c);
            caseDateMap.put(cse.Service_Date__c,cse.Id);
        }
        for(WorkOrder wrkOdr : [SELECT id,WorkOrderNumber,Asset_Material__c,Case_Type__c,Case_Subtype__c,Customer_Location__c,Asset.Name,CaseId,Service_Date__c,CreatedBy.Name FROM WorkOrder WHERE Customer_Location__c =: locationId AND AssetId =: assetId AND Service_Date__c IN: serviceDates AND Case_Type__c =: caseType AND Status != 'Closed' AND Acorn_WorkOrder_Number__c != NULL]){
            if(!caseDateMap.isEmpty() && caseDateMap.containsKey(wrkOdr.Service_Date__c) ){
                //caseIds.add(caseDateMap.get(wrkOdr.Service_Date__c));
                returnList.add(wrkOdr);
            }
        }
        //system.debug('dup list'+returnList);
        return returnList;
        
    }
    
    @AuraEnabled
    public static void updateClosehandler(List<Case> childCases,List<WorkOrder> dupWorkOrders,List<WorkOrder> selectedList){
        List<Case> updateList = new List<Case>();
        List<Case> ignoreList = new List<Case>();
        List<Date> selectedDates = new List<Date>();
        Map<Date,Id> duplicateMap = new Map<Date,Id>();
        Map<Date,String> wrkOrdrDateMap = new Map<Date,String>();
        List<CaseComment> cmmntList = new List<CaseComment>();
        for(WorkOrder wrkordr : selectedList){
            selectedDates.add(wrkordr.Service_Date__c);
        }
        for(WorkOrder duplicate : dupWorkOrders){
            duplicateMap.put(duplicate.Service_Date__c,duplicate.CaseId);
            wrkOrdrDateMap.put(duplicate.Service_Date__c,duplicate.WorkOrderNumber);
        }
        for(Case cse : childCases){
            if(!selectedDates.isEmpty() && selectedDates.contains(cse.Service_Date__c)){
                cse.Status = Constant_Util.CLOSED;
                updateList.add(cse);
                cmmntList.add(new CaseComment(ParentId = cse.Id, CommentBody = Constant_Util.MULTIDATE_COMMENT+wrkOrdrDateMap.get(cse.Service_Date__c)));
            }else{
                if(duplicateMap.containsKey(cse.Service_Date__c)){
                    ignoreList.add(cse);
                    cmmntList.add(new CaseComment(ParentId = cse.Id, CommentBody = Constant_Util.MULTIDATE_COMMENT+wrkOrdrDateMap.get(cse.Service_Date__c)));
                    Case dupCase = new Case(Id = duplicateMap.get(cse.Service_Date__c));
                    ignoreList.add(dupCase);
                }
            }
        }
        for(Case cases : ignoreList){
            cases.Bypass_WO_Duplicate__c = true;
            cases.Ignore_Duplicate__c = true;
            updateList.add(cases);
        }
        if(updateList.size() > 0 ){
            Database.update(updateList);
        }
        if(cmmntList.size() > 0){
            Database.insert(cmmntList);
        }
    }
    
    
    @AuraEnabled
    public static CaseSuccess cloSeMultiCase()
    {
        CaseSuccess wrap = new CaseSuccess();
       	wrap.success = true;
        return wrap;
    }
    
     @AuraEnabled
    public static void copyEmailtoAnotherCase(string sourceCaseId, string TargetCaseNumber)
    {
        Case selectedCase = [SELECT id,CaseNumber 
                                 FROM Case 
                                 WHERE CaseNumber=:TargetCaseNumber LIMIT 1];
        copyEmailToChildCase(sourceCaseId, selectedCase);
    }
    
    public static void copyEmailToChildCase(string recordId, Case caseObj){
        List<EmailMessage> updatedEmailList = new List<EmailMessage>();
        List<EmailMessage> emailList = [SELECT id,Subject,FromAddress,HtmlBody,TextBody,ToAddress,ParentId,RelatedToId from EmailMessage where ParentId =: recordId LIMIT 49999];
        if(emailList.size()>0) {
            for(EmailMessage email : emailList){
                EmailMessage newEmail= new EmailMessage();
                newEmail = email.clone(false, false, false, false);
                newEmail.ParentId = caseObj.Id;
                newEmail.RelatedToId = caseObj.Id;
                updatedEmailList.add(newEmail);                    
            }
        }else{}
        try {
        	database.insert(updatedEmailList);
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
        }
                    
    }
    
    public static void copyAcornCommentsToChildCase(string recordId, Case caseObj){
        List<Comment__c> updatedCommentsList = new List<Comment__c>();
        Id recordTypeId = Schema.getGlobalDescribe().get('Comment__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Acorn_Ticket_Comment').getRecordTypeId();
        List<Comment__c> notes= [SELECT Id, Name, Communication_Log_Type_Name__c,Case_Number__c,Case__c,Acorn_SUser_ID__c,Comment__c, CreatedDate,Workflow_Action__c,recordTypeId,Workflow_TeamUser__c from Comment__c 
                                              where Case__r.Id =: recordId and RecordTypeId =: recordTypeId order by CreatedDate DESC];
        if(notes.size()>0) {
            for(Comment__c comments : notes){
                Comment__c newComments= new Comment__c();
                newComments = comments.clone(false, false, false, false);
                newComments.Case__c = caseObj.Id;
                newComments.Case_Number__c = caseObj.CaseNumber;
                updatedCommentsList.add(newComments);                    
            }
        }else{}
        try {
        	database.insert(updatedCommentsList);
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
        }
                    
    }
    @AuraEnabled
    public static LocationAssetWrapperPagination fetchAccountAssetWrapper(String searchKeyWord, Boolean selectedFilter, integer pageNumber, integer pageSize,Boolean assetFilter, ID CaseId ) {
        
        List<list<SObject>> accountSerachResults = new List<list<SObject>>();
        case cs = [select id , RecordType.Name from case where id  =: caseId];
        list<string> accIdList= new list<string>();
        
        Integer pSize = pageSize;
        Integer pNumber = pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        Integer totalRecords;
        
        if(!selectedFilter){
            accountSerachResults= [FIND :searchKeyWord IN ALL FIELDS RETURNING Account (id, RecordType.DeveloperName Where RecordType.DeveloperName='Location' AND status__c='Active') ];
        }
        else{
            accountSerachResults= [FIND :searchKeyWord IN ALL FIELDS RETURNING Account (id, RecordType.DeveloperName Where RecordType.DeveloperName='Location') ];
        }
        if(accountSerachResults.size() > 0){
            list<Account> accList= new list<Account>();
            accList = accountSerachResults[0];
            totalRecords= accList.size();
            for(Account acc : accList){
                accIdList.add(acc.id);   
            }            
        }
        
        //system.debug(' **** '+ accIdList);
        
        List <LocationAssetWrapper> returnWrapperList = new List <LocationAssetWrapper> ();
        List <Account> lstOfAccount;
        
        if(!assetFilter){
            //lstOfAccount = [select id, Name, Type, Industry, Phone, Fax, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ParentId, Parent.Name, shippingAddress, (select id, name, Location__c, Material_Type__c, Duration__c, Occurrence__c, AccountId, Account.Name from Assets_Location__r where RecordType.DeveloperName='Service_Header') from account
            //where (Name LIKE :searchStrList OR ShippingStreet LIKE :searchStrList OR ShippingCity LIKE :searchStrList OR ShippingState LIKE :searchStrList OR ShippingCountry LIKE :searchStrList ) AND RecordType.DeveloperName='Location' AND status__c='Active' LIMIT 500];
            //If-Else added for story SDT-24993 start. Additional filter CPQ_Product__c != null for Update asset case.
            //Changes for SDT-26868
            if(cs.RecordType.Name== Constant_Util.New_Service_Case){
                lstOfAccount = [select id, Name,Customer_Location_Code__c, Type, Industry, Phone, Fax, Location_Code__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId, Parent.Name, shippingAddress, (select id,Name,Acorn_SID__c,End_Dated_Asset__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Active__c from Assets_Location__r where RecordType.DeveloperName='Service_Header' AND Is_Active__c=true) from account
                            where ID IN :accIdList  LIMIT :pSize OFFSET :offset];    
            }
            else{
                // Changes for SDT-26868 HotFix
                //if(GetCaseInformation.getActiveAssetUserDetail())
                //    lstOfAccount = [select id, Name,Customer_Location_Code__c, Type, Industry, Phone, Fax, Location_Code__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId, Parent.Name, shippingAddress, (select id,Name,Acorn_SID__c,End_Dated_Asset__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Active__c from Assets_Location__r where RecordType.DeveloperName='Service_Header' AND Is_Active__c=true AND CPQ_Product__c  != null ) from account
                //            where ID IN :accIdList  LIMIT :pSize OFFSET :offset];
                //else
                    lstOfAccount = [select id, Name,Customer_Location_Code__c, Type, Industry, Phone, Fax, Location_Code__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId, Parent.Name, shippingAddress, (select id,Name,Acorn_SID__c,End_Dated_Asset__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Active__c from Assets_Location__r where RecordType.DeveloperName='Service_Header' AND Is_Active__c=true) from account
                    where ID IN :accIdList  LIMIT :pSize OFFSET :offset];
            }
        }else{
            /*lstOfAccount = [select id, Name, Type, Industry, Phone, Fax, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ParentId, Parent.Name, shippingAddress, (select id, name, Location__c, Material_Type__c, Duration__c, Occurrence__c, AccountId, Account.Name from Assets_Location__r where RecordType.DeveloperName='Service_Header') from account
where (Name IN :searchStrList OR ShippingStreet IN :searchStrList OR ShippingCity IN :searchStrList OR ShippingState IN :searchStrList OR ShippingCountry IN :searchStrList ) AND RecordType.DeveloperName='Location' LIMIT 500];*/
            
            //If-Else added for story SDT-24993 start. Additional filter CPQ_Product__c != null for Update asset case.            
            //Changes for SDT-26868
            if(cs.RecordType.Name== Constant_Util.New_Service_Case){
                lstOfAccount = [select id, Name,Customer_Location_Code__c, Type, Industry, Phone, Fax, Location_Code__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId, Parent.Name, shippingAddress, (select id,Name,Acorn_SID__c,End_Dated_Asset__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Active__c from Assets_Location__r where RecordType.DeveloperName='Service_Header' AND (Is_Active__c=true OR Is_Active__c=false)) from account
                             where ID IN :accIdList LIMIT :pSize OFFSET :offset];
            }
            else{
                // Changes for SDT-29408 HotFix
                if(GetCaseInformation.getActiveAssetUserDetail())
                    lstOfAccount = [select id, Name,Customer_Location_Code__c, Type, Industry, Phone, Fax, Location_Code__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId, Parent.Name, shippingAddress, (select id,Name,Acorn_SID__c,End_Dated_Asset__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Active__c from Assets_Location__r where RecordType.DeveloperName='Service_Header' AND (Is_Active__c=true OR Is_Active__c=false) AND CPQ_Product__c  != null) from account
                        where ID IN :accIdList LIMIT :pSize OFFSET :offset];    
                else
                    lstOfAccount = [select id, Name,Customer_Location_Code__c, Type, Industry, Phone, Fax, Location_Code__c, ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ParentId, Parent.Name, shippingAddress, (select id,Name,Acorn_SID__c,End_Dated_Asset__c,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Company_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Active__c from Assets_Location__r where RecordType.DeveloperName='Service_Header' AND (Is_Active__c=true OR Is_Active__c=false)) from account
                        where ID IN :accIdList LIMIT :pSize OFFSET :offset];    
            }
        }
        	
        Integer recordEnd = pSize * pNumber;
        
        for (Account acc: lstOfAccount) {
            //if(acc.Assets_Location__r.size() > 0){
                /* string address;
if(acc.ShippingStreet !='' && acc.ShippingStreet !=NULL){
address= acc.ShippingStreet + ''; 
}else if(acc.ShippingCity !='' && acc.ShippingCity !=NULL){
address= address+ acc.ShippingCity + '';    
}else if(acc.ShippingState !='' && acc.ShippingState !=NULL){
address= address+ acc.ShippingState + '';    
}else if(acc.ShippingCountry !='' && acc.ShippingCountry !=NULL){
address= address+ acc.ShippingCountry + '';
}*/
               
                LocationAssetWrapper wrprrObj = new LocationAssetWrapper(acc,acc.Assets_Location__r,''); 
                List<Asset> assetDetail = null;
                String detailRecordType = Constant_Util.SERVICE_DETAILS;
                Integer count = 0;
                if(!wrprrObj.assetList.isEmpty()){
                    for(Asset asset : wrprrObj.assetList){
                        String AssetId = asset.Id;
                        if(count == 99){
                            assetDetail = Database.query('select id, MAS_Customer_Unique_Id__c,Schedule__c,Quantity__c from asset where RootAssetId =: AssetId and Is_Active__c = true and Is_Core_Service__c = true and RecordType.DeveloperName = :detailRecordType limit 1');
                            if(!assetDetail.isEmpty()){
                                asset.MAS_Customer_Unique_Id__c = assetDetail[0].MAS_Customer_Unique_Id__c;
                                asset.Schedule__c = assetDetail[0].Schedule__c;
                                asset.Quantity__c = assetDetail[0].Quantity__c;
                            }
                        }
                        count++;  
            		} 
                }
                returnWrapperList.add(wrprrObj);
            //}            
        } 
        
        LocationAssetWrapperPagination objDT = new LocationAssetWrapperPagination();
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.assetWrapperList = returnWrapperList;
        
        //system.debug(' **** objDT '+ objDT);  
        return objDT;
    }
    
    
    @AuraEnabled
    public static LocationAssetWrapperPagination fetchVendorOrClientWrapper(String searchKeyWord, Boolean selectedFilter, integer pageNumber, integer pageSize, ID CaseId, String recordType ) {
        
        List<list<SObject>> accountSerachResults = new List<list<SObject>>();
        case cs = [select id , RecordType.Name from case where id  =: caseId];
        list<string> accIdList= new list<string>();
        
        Integer pSize = pageSize;
        Integer pNumber = pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        Integer totalRecords;
        
        if(!selectedFilter){
            accountSerachResults= [FIND :searchKeyWord IN ALL FIELDS RETURNING Account (id, RecordType.DeveloperName Where RecordType.DeveloperName = :recordType AND status__c = 'Active') ];
        }
        else{
            accountSerachResults= [FIND :searchKeyWord IN ALL FIELDS RETURNING Account (id, RecordType.DeveloperName Where RecordType.DeveloperName = :recordType) ];
        }
        
        if(accountSerachResults.size() > 0){
            list<Account> accList= new list<Account>();
            accList = accountSerachResults[0];
            totalRecords= accList.size();
            for(Account acc : accList){
                accIdList.add(acc.id);   
            }            
        }
        
        //system.debug(' **** '+ accIdList);
        
        List <LocationAssetWrapper> returnWrapperList = new List <LocationAssetWrapper> ();
        List <Account> lstOfAccount;
        
        
          lstOfAccount = [select id, Name,Customer_Location_Code__c, Type, Location_Code__c, ParentId, Parent.Name, Vendor_Id__c, Customer_Code__c
                             from account where ID IN :accIdList  LIMIT :pSize OFFSET :offset];    	
        Integer recordEnd = pSize * pNumber;
        
        for (Account acc: lstOfAccount) {
    
               
                LocationAssetWrapper wrprrObj = new LocationAssetWrapper(acc,acc.Assets_Location__r,''); 
                List<Asset> assetDetail = null;
                String detailRecordType = Constant_Util.SERVICE_DETAILS;
                Integer count = 0;
                returnWrapperList.add(wrprrObj);
            //}            
        } 
        
        LocationAssetWrapperPagination objDT = new LocationAssetWrapperPagination();
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.assetWrapperList = returnWrapperList;
        
        //system.debug(' **** objDT '+ objDT);  
        return objDT;
    }
    
	

    
    @AuraEnabled
    public static list<LocationAssetWrapper> fetchAssetRecs(string locationId, List<LocationAssetWrapper> wrapperList){
        List <Asset> returnAssetList = new List <Asset> ();
        List<Asset> assetDetail = null;
        List <Asset> lstOfAsset = [select id,Name,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Customer_Unique_Id__c,MAS_Library__c,Frequency__c,Is_Active__c,Active__C from Asset where Location__c =:locationId AND RecordType.DeveloperName='Service_Header' AND Is_Active__c = true LIMIT 500];	    
        //system.debug(' wrapperList '+ wrapperList.size());
        
        if(lstOfAsset.size() > 0){
            for(LocationAssetWrapper wrpObj : wrapperList){
                if(wrpObj.objAcc.id == locationId && wrpObj.assetList.size() ==0){
                    wrpObj.assetList.addAll(lstOfAsset);    
                }    
            }        
        }
        //system.debug(' ****list '+ wrapperList);
        return wrapperList;
    }
    
    @AuraEnabled
    public static string updateCase(string clientId, string locationId, string[] assetId, string caseId){
        Case currentCase = null;
        Case caseObj = null;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MultiAsset');
        List<String> assetSelections = new List<String>();
        list<Case> caseList = new list<Case>();
        try{
            currentCase = Database.query('select Id,AssetId,ParentId,RecordTypeId,Case_Sub_Status__c,Client__c,Location__c,Reference_Number__c,ContactId from case where id = :caseId limit 1'); 
            currentCase.Client__c = clientId;
            currentCase.Location__c = locationId;
            //Added By Saurav Dwivedi - SDT-11659 -- start
            Boolean isAvail = checkContactAvailableOnLocation(locationId, currentCase.ContactId);
            if(!isAvail){
            	currentCase.ContactId = Null; 
            }
            //Added by saurav -- end
            if(!assetId.isEmpty()){
                currentCase.AssetId = assetId[0];
                for(Integer i = 1; i < assetId.size(); i++){
          			assetSelections.add(assetId[i]);
                }
            }else{
                currentCase.AssetId = null;
            }
            if(assetSelections!=null){
                sessionPart.put(caseId, assetSelections,3600,Cache.Visibility.ALL,true);
            }

            //TCS-pkulkarn-SDT-42417-20-Nov-2024-Added to capture Selected Assets (quote creation) on Case
            currentCase.Selected_Asset_Header_Ids__c = AssetQuerySelector.covertStringArrayToDelimiterSeparatedString(assetId, ';');
            //TCS-pkulkarn-SDT-42417-20-Nov-2024-End
            
            caseList.add(currentCase);
            Database.UpsertResult[] srList = Database.upsert(caseList,false);
            return Constant_Util.SUCCESS;
        }catch(exception ex){
            return Constant_Util.FAILURE;
        }
    }
	
    
     @AuraEnabled
    public static string updateCaseOnVendorClientSelection( string accountId, string caseId, String recordType){
        Case currentCase = null;
        Case caseObj = null;
        list<Case> caseList = new list<Case>();
        try{
            currentCase = new Case(Id = caseId);     
            if(recordType == 'Vendor'){
                currentCase.Supplier__c = accountId;
            } else {
                currentCase.Location__c = null;
                currentCase.Client__c = accountId;
            }
            caseList.add(currentCase);
            Database.UpsertResult[] srList = Database.upsert(caseList,false);
            return Constant_Util.SUCCESS;
        }catch(exception ex){
            return Constant_Util.FAILURE;
        }
    }
	
    //Added By Saurav Dwivedi - SDT-11659 -- start
    //Check contact is available or not on the new Location.
    public static Boolean checkContactAvailableOnLocation(string locationId, Id ContactId){
    	Boolean isAvailable = false;
    	Set<Id> contactIds = new Set<Id>();
    	if(String.isNotBlank(locationId) && String.isNotBlank(ContactId)){    		
            List<AccountContactRelation> AcctContRel = [SELECT id, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: locationId];
        	for(AccountContactRelation acr: AcctContRel){
        		contactIds.add(acr.ContactId);
        	}                    	
        	if(contactIds.contains(contactId)){
        		isAvailable = true;
        	}	    
    	} 
    	
    	return isAvailable;
    }
    //added by saurav -- end
    
    public inherited sharing class LocationAssetWrapperPagination{
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<LocationAssetWrapper> assetWrapperList {get;set;}
    }
    
    public inherited sharing class LocationAssetWrapper{
        
        @AuraEnabled
        public Account objAcc{get;set;}
        @AuraEnabled
        public list<Asset> assetList{get;set;}
        @AuraEnabled
        public string addressStr {get; set;}
        
        public LocationAssetWrapper(){
            
        }
        
        public LocationAssetWrapper(Account accTmp, list<Asset> assListTmp, string addressStrTmp){
            this.objAcc = accTmp;
            this.assetList = assListTmp;
            this.addressStr = addressStrTmp;
        }
    }
}