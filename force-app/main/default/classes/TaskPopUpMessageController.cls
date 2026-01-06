public with sharing class TaskPopUpMessageController {
   
    @AuraEnabled
    public static Task getTask(string taskId){
        Task taskObj = [SELECT Id, Process__c, Outcome__c, WhatId FROM Task WHERE Id =: taskId];
        return taskObj;
    }
    @AuraEnabled
    public static List<case> getRelatedCase(string recordId){
        string caseId;
        List<Case> caseList = null;
        try{
                 if(recordId.startswith('500')){
                    caseId = recordId;
                    case caseObj = [SELECT Id, Reference_Number__c, CaseNumber FROM Case WHERE Id =: caseId];
                    caseList = [SELECT Id, Reference_Number__c,Tracking_Number__c,Case_Type__c,Case_Sub_Type__c,Asset.Name,Asset_Material__c,Service_Date__c,CaseNumber,isWorkOrderCreated__c,Status,Work_Order__r.WorkOrderNumber,Case_Sub_Status__c FROM Case WHERE Reference_Number__c =: caseObj.Reference_Number__c
                    AND Id !=: caseId];// removed the status retriction as part of SDT-10777
                    for(Integer i = 0; i < caseList.size(); i++){
                        if(caseList[i].Service_Date__c!= null){
                            caseList[i].Service_Date_Text__c = caseList[i].Service_Date__c.format();
                        }else{
                            //nova cop fix
                        }                
            		} 
               		return caseList;
       			 }
                else{
                        caseId = [SELECT Id, WhatId FROM Task WHERE Id =: recordId].WhatId;
                        if(caseId != null){
                            case caseObj = [SELECT Id, Reference_Number__c, CaseNumber FROM Case WHERE Id =: caseId];
                            caseList = [SELECT Id, Reference_Number__c,Tracking_Number__c,Case_Type__c,Case_Sub_Type__c,Asset.Name,Asset_Material__c,Service_Date__c,Status,Work_Order__r.WorkOrderNumber,CaseNumber FROM Case WHERE Reference_Number__c =: caseObj.Reference_Number__c
                            AND (Status =: Constant_Util.STATUS_NEW OR Status =: Constant_Util.OPEN) AND ((Case_Type__c =: Constant_Util.Change_Service 
                            AND Case_Sub_Type__c =: Constant_Util.Change_Correction) OR (Case_Sub_Type__c =:Constant_Util.Service_Not_Performed))  AND Id !=: caseId];
                            for(Integer i = 0; i < caseList.size(); i++){
                                if(caseList[i].Service_Date__c!= null){
                                    caseList[i].Service_Date_Text__c = caseList[i].Service_Date__c.format();
                                }else{
                                    //nova cop fix
                                }                
            				} 
                            return caseList;
                    }
                			
        }
            
        }catch(Exception e){}
        
        return null;
        
    }
}