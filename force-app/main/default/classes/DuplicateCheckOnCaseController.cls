/*************************************************************       
@Name: DuplicateCheckOnCaseController
@Modified By: Urvashi Chauhan
@Modified Date: 14/04/2020
@Description: To fetch Duplicate WorkOrder for Single Asset and Multi Asset Cases.
@UsedBy: DuplicateCheckOnCase Component
*************************************************************/

public without sharing class DuplicateCheckOnCaseController {
    
    @AuraEnabled
    public static List<WorkOrder> checkForDuplicate(String caseId){
        List<WorkOrder> duplicateList = new List<WorkOrder>();
        Case createdCase = [SELECT id,Location__c,assetId,Asset_Material__c,Service_Date__c,Case_Type__c,Case_Sub_Type__c,CaseNumber FROM Case 
                            WHERE id =: caseId LIMIT 1];
        Date beforeDate = createdCase.Service_Date__c - 3;
        Date afterDate = createdCase.Service_Date__c + 3;
        
        for(WorkOrder wrkOdr : [SELECT id,WorkOrderNumber,Asset_Material__c,Case_Type__c,Case_Subtype__c,Customer_Location__c,Asset.Name,CaseId,Service_Date__c,CreatedBy.Name FROM WorkOrder WHERE Customer_Location__c =: createdCase.Location__c AND AssetId =: createdCase.AssetId AND Service_Date__c >=: beforeDate AND Service_Date__c <=: afterDate AND Case_Type__c =: createdCase.Case_Type__c AND Status != 'Closed' AND Acorn_WorkOrder_Number__c != NULL]){
            duplicateList.add(wrkOdr);
        }
        return duplicateList;
    }
    
    @AuraEnabled
    public static ParentMultiAssetWrapper fetchMultiAssetWrapper(String caseId) {
        
        List <MultiAssetWrapper> returnWrapperList = new List <MultiAssetWrapper> ();
        ParentMultiAssetWrapper objDT = new ParentMultiAssetWrapper();
        List<WorkOrder> duplicateList = new List<WorkOrder>();
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        Map<ID, List<WorkOrder>> duplicateMap = new Map<ID, List<WorkOrder>>();
        Set<ID> multiAssetIDSet = new Set<ID>();
        Set<ID> multiCaseLocationSet = new Set<ID>();
        Set<String> multiCasesCaseType = new Set<String>();
        Map<Id,Id> assetCasesMap = new Map<Id,Id>();
        Map<Id,String> assetNameMap = new Map<Id,String>();
        map<string,Date> caseMap = new map<string,Date>();
        string casekey = null;
        
        Case createdCase = [SELECT Id,Location__c,assetId,Asset.Name,Asset_Material__c,ParentId,Service_Date__c,Case_Type__c,Case_Sub_Type__c,CaseNumber,Is_Multiple_Asset__c,Reference_Number__c,Status,Is_Clone__c,Ignore_Duplicate__c FROM Case
                                WHERE Id =: caseId LIMIT 1];
            String referenceNumber = createdCase.Reference_Number__c;
            String caseNo = createdCase.Id;
            String parentId = createdCase.ParentId;
            Date beforeDate = createdCase.Service_Date__c - 3;
            Date afterDate = createdCase.Service_Date__c + 3;
            
            if(createdCase.Is_Multiple_Asset__c != true)
            {
                MultiAssetWrapper wrprrObj = new MultiAssetWrapper();
                //case.status__c added for SDT-41633
                for(WorkOrder wrkOdr : [SELECT Id,WorkOrderNumber,Asset_Material__c,Case_Type__c,Case_Subtype__c,Customer_Location__c,Case.Status__c,Asset.Name,CaseId,Service_Date__c,CreatedBy.Name,Status,Acorn_WorkOrder_Number__c,AssetId FROM WorkOrder 
                                        WHERE Customer_Location__c =: createdCase.Location__c AND AssetId =: createdCase.AssetId AND Service_Date__c >=: beforeDate AND Service_Date__c <=: afterDate AND Case_Type__c =: createdCase.Case_Type__c ])
                {
                     //check added in condition  for SDT-41633
                    if(wrkOdr.Status != Constant_Util.CLOSED && wrkOdr.Acorn_WorkOrder_Number__c != null && wrkOdr.Case.Status__c !=Constant_Util.CLOSED)
                    {
                        duplicateList.add(wrkOdr);
                    }
                }
                if(duplicateList != null && !duplicateList.isEmpty()){
                    wrprrObj.assetID = createdCase.AssetId;
                    wrprrObj.caseID = createdCase.Id;
                    wrprrObj.AssetName = createdCase.Asset.Name;
                    wrprrObj.WOList = duplicateList;
                    returnWrapperList.add(wrprrObj);
                }
                
            }
            else
            {
                String con;
                Date serviceDate;
                Date beforeDte;
                Date afterDte ;
                for(Case thisCase : [SELECT Id,Location__c,AssetId,Asset.Name,Asset_Material__c,ParentId,Service_Date__c,Case_Type__c,Case_Sub_Type__c,CaseNumber,Is_Multiple_Asset__c,Reference_Number__c,Status,Ignore_Duplicate__c,Is_Clone__c  From Case 
                                     where Reference_Number__c = :referenceNumber AND Case_Type__c = 'Pickup' ORDER BY CaseNumber desc ])
                {
                    if(thisCase.Case_Sub_Type__c != null && thisCase.Service_Date__c != null && thisCase.Location__c != null  && thisCase.AssetId != null)
                    {    
                        multiAssetIDSet.add(thisCase.AssetId);
                        multiCaseLocationSet.add(thisCase.Location__c);
                        multiCasesCaseType.add(thisCase.Case_Type__c);
                        assetCasesMap.put(thisCase.AssetId,thisCase.Id);
                        assetNameMap.put(thisCase.AssetId,thisCase.Asset.Name);
                        
                        casekey = thisCase.AssetId + Constant_Util.STAR + thisCase.Location__c + Constant_Util.STAR + thisCase.Case_Type__c;
                        caseMap.put(casekey,thisCase.Service_Date__c);
                        
                    }
                }
                //case.status__C added for SDT-41633
                for(WorkOrder wrkOdr : [SELECT Id,WorkOrderNumber,Asset_Material__c,Case_Type__c,Status,Case_Subtype__c,Customer_Location__c,Asset.Name,CaseId,Case.Status__c,Service_Date__c,CreatedBy.Name,AssetId,Acorn_WorkOrder_Number__c FROM WorkOrder 
                                        WHERE AssetId IN :multiAssetIDSet AND Customer_Location__c IN :multiCaseLocationSet AND Case_Type__c IN :multiCasesCaseType Limit 49999])
                {
                    //check added in condition  for SDT-41633
                    if(wrkOdr.Status != Constant_Util.CLOSED && wrkOdr.Acorn_WorkOrder_Number__c != null && wrkOdr.Case.Status__c !=Constant_Util.CLOSED)
                    {
                        con = wrkOdr.AssetId + Constant_Util.STAR + wrkOdr.Customer_Location__c + Constant_Util.STAR + wrkOdr.Case_Type__c;
                        
                        if(caseMap.ContainsKey(con))  
                        {
                            serviceDate = caseMap.get(con);
                            beforeDte = serviceDate - 3;
                            afterDte = serviceDate + 3;
                            if(wrkOdr.Service_Date__c >= beforeDte && wrkOdr.Service_Date__c <= afterDte )
                            {
                                if(duplicateMap.ContainsKey(wrkOdr.AssetId))
                    			{
                                    List<WorkOrder> exitingWorkOdrList = new List<WorkOrder>();
                                    exitingWorkOdrList  = duplicateMap.get(wrkOdr.Asset.Id);
                                    exitingWorkOdrList.add(wrkOdr);
                                    duplicateMap.put(wrkOdr.AssetId,exitingWorkOdrList);
                                }
                                else
                                {
                                    List<WorkOrder> WorkOdrList = new List<WorkOrder>();
                                    WorkOdrList.add(wrkOdr);
                                    duplicateMap.put(wrkOdr.AssetId,WorkOdrList);
                                }
                            }   
                        }
                    }
                }
                
                for(Id assetId : duplicateMap.KeySet()){
                    if(duplicateMap.get(assetID) != null && !duplicateMap.get(assetID).isEmpty()){
                        MultiAssetWrapper wrprrObj = new MultiAssetWrapper();
                        wrprrObj.assetID = assetId;
                        wrprrObj.caseID = assetCasesMap.get(assetId);
                        wrprrObj.AssetName = assetNameMap.get(assetId);
                        wrprrObj.WOList = duplicateMap.get(assetID);
                        returnWrapperList.add(wrprrObj);
                    }
                }
            }
            
            objDT.multiAssetWrapperList = returnWrapperList;
            return objDT;
   }
    
    @AuraEnabled
    public static void updateCaseWithComments(String caseId,Boolean ignoreCheck,String caseComments,List<WorkOrder> dupList){
        try{
            List<Case> updtCaseList = new List<Case>();
            Case createdCase = [SELECT id,Ignore_Duplicate__c,Bypass_WO_Duplicate__c,Status FROM Case 
                                WHERE id =: caseId LIMIT 1];
            CaseComment cmmnt = new CaseComment();
            cmmnt.ParentId = createdCase.Id;
            cmmnt.CommentBody = caseComments;
            String ignrMessage = 'Duplicate WorkOrders found : ';
            for(WorkOrder wrkodr : dupList){
                ignrMessage = ignrMessage+wrkodr.WorkOrderNumber+',';
                Case cse = new Case();
                cse.Id = wrkodr.CaseId;
                if(!cse.Ignore_Duplicate__c){
                    cse.Ignore_Duplicate__c = true;
                    cse.Bypass_WO_Duplicate__c = true;
                    updtCaseList.add(cse);
                }
            }
            cmmnt.CommentBody = cmmnt.CommentBody+'\n'+ignrMessage;
            if(ignoreCheck){
                createdCase.Ignore_Duplicate__c = true;
                createdCase.Bypass_WO_Duplicate__c = true;
            }else{
                createdCase.Status = 'Closed';
            }
            updtCaseList.add(createdCase);
            Database.insert(cmmnt);
            Database.update(updtCaseList);
        }
        catch(Exception ex){
        }
    }
    
    @AuraEnabled
    public static void updateSingleAssetCases(Boolean ignoreCheck,String caseComments,List<MultiAssetWrapper> dupList){
        try{
            
            List<Case> updtCaseList = new List<Case>();
            Case cse;
			Set<Case> caseSet = new Set<Case>();
            List<Case> updtedCaseList = new List<Case>();
            
            if(dupList != null && !dupList.isEmpty())
            {
                Case createdCase = [SELECT Id,Ignore_Duplicate__c,Bypass_WO_Duplicate__c,Status FROM Case 
                                    WHERE Id =: dupList[0].caseID LIMIT 1];
                CaseComment cmmnt = new CaseComment();
                cmmnt.ParentId = createdCase.Id;
                cmmnt.CommentBody = caseComments;
                String ignrMessage = Constant_Util.IGNORE_CASE_MSG;
                
                for(WorkOrder wrkodr : dupList[0].WOList){
                    ignrMessage = ignrMessage+wrkodr.WorkOrderNumber+',';
                    cse = new Case();
                    cse.Id = wrkodr.CaseId;
                    if(!cse.Ignore_Duplicate__c){
                        cse.Ignore_Duplicate__c = true;
                        cse.Bypass_WO_Duplicate__c = true;
                        updtCaseList.add(cse);
                    }
                }
				
				//logic to remove duplicate               
                for (Case cs : updtCaseList) {
                    if (caseSet.add(cs)) {
                        updtedCaseList.add(cs);
                    }
                }
				
                cmmnt.CommentBody = cmmnt.CommentBody+'\n'+ignrMessage;
                if(ignoreCheck){
                    createdCase.Ignore_Duplicate__c = true;
                    createdCase.Bypass_WO_Duplicate__c = true;
                }else{
                    createdCase.Status = Constant_Util.CLOSED ;
                }
                //updtCaseList.add(createdCase);
				updtedCaseList.add(createdCase);
                Database.insert(cmmnt);
                //Database.update(updtCaseList);
				Database.update(updtedCaseList);
            }
        }
        catch(Exception e){
            System.debug('Exception::::'+ e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateMultiAssetCases(List<Id> selectedCaseIds,List<Id> unSelectedCaseId){
        try{
            List<Case> updateList = new List<Case>();
            List<Case> ignoreList = new List<Case>();
            List<CaseComment> cmmntList = new List<CaseComment>();
            
            if(selectedCaseIds != null && !selectedCaseIds.isEmpty())
            {
                for(Case cases: [SELECT Id,Ignore_Duplicate__c,Bypass_WO_Duplicate__c,Status FROM Case where Id IN: selectedCaseIds])
                {
                    cases.Status = Constant_Util.CLOSED;
                    updateList.add(cases);
                    cmmntList.add(new CaseComment(ParentId = cases.Id, CommentBody = Constant_Util.MULTI_ASSET_CASE_CLOSED));
                }
            }
            if(unSelectedCaseId != null && !unSelectedCaseId.isEmpty())
            {
                for(Case cases: [SELECT Id,Ignore_Duplicate__c,Bypass_WO_Duplicate__c,Status FROM Case where Id IN: unSelectedCaseId])
                {
                    ignoreList.add(cases);
                    cmmntList.add(new CaseComment(ParentId = cases.Id, CommentBody = Constant_Util.MULTI_ASSET_CASE_IGNORED));
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
        catch(Exception e){
            System.debug('Exception::::'+ e.getMessage());
        } 
        
    } 
    
    
    public inherited sharing class ParentMultiAssetWrapper{
        
        @AuraEnabled
        public List<MultiAssetWrapper> multiAssetWrapperList {get;set;}
        
    }
    
    public inherited sharing class MultiAssetWrapper{
        
        @AuraEnabled
        public Id assetID {get;set;}
        @AuraEnabled
        public Id caseID {get;set;} 
        @AuraEnabled
        public String AssetName {get;set;}
        @AuraEnabled
        public list<WorkOrder> WOList{get;set;}
        
        public MultiAssetWrapper(){
            
        }
    }
}