public class QuoteOrderTriggerHelper {
    // update PO
    public static void updateCustPOonCase(List<Quote_Order__c> newQuoteOrderList, Map<Id,Quote_Order__c> oldQuoteOrderMap){
        Map<String,String> mapPO = new Map<String,String>();
        Map<String,String> mapQLIdVsRef = new Map<String,String>();
        for(Quote_Order__c newQO: newQuoteOrderList){
            if(oldQuoteOrderMap == null && newQO.Service_Type__c == 'Delivery' && String.isNotEmpty(newQO.Cust_Ref_Number__c)){
                mapQLIdVsRef.put(newQO.Service_Quote_Line__c,newQO.Cust_Ref_Number__c);
            }else if(oldQuoteOrderMap != null && newQO.Service_Type__c == 'Delivery'  
                    && String.isNotEmpty(newQO.Cust_Ref_Number__c) && newQO.Cust_Ref_Number__c != oldQuoteOrderMap.get(newQO.Id).Cust_Ref_Number__c ){
                mapQLIdVsRef.put(newQO.Service_Quote_Line__c,newQO.Cust_Ref_Number__c);
            }
        }
        if(!mapQLIdVsRef.isEmpty()){
            for(SBQQ__QuoteLine__c ql : [Select Id,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.Case_Number__c from SBQQ__QuoteLine__c WHERE ID IN : mapQLIdVsRef.keySet()]){
                if(ql.SBQQ__Quote__r.SBQQ__Status__c == 'Draft' || ql.SBQQ__Quote__r.SBQQ__Status__c == 'Product Configured'){
                    mapPO.put(ql.SBQQ__Quote__r.Case_Number__c,mapQLIdVsRef.get(ql.Id));
                }
            }
        }
        if(!mapPO.isEmpty()){
            List<Case> updateCase = new List<Case>();
            Map<Id,String> mapCasePO = new Map<Id,String>();
            for(Case cs : [Select Id,CaseNumber,PurchaseOrder_Number__c from Case WHERE CaseNumber IN : mapPO.KeySet()]){
                if(mapPO.containsKey(cs.CaseNumber) && cs.PurchaseOrder_Number__c != mapPO.get(cs.CaseNumber)){
                    cs.PurchaseOrder_Number__c = mapPO.get(cs.CaseNumber);
                    mapCasePO.put(cs.Id,cs.PurchaseOrder_Number__c);
                	updateCase.add(cs);
                }
            }
            List<Task> updateTask = new List<Task>();
            system.debug('updateTask mapCasePO : ' + mapCasePO);
            for(Task tsk : [Select Id,WhatId,PurchaseOrder_Number__c from Task WHERE WhatId =: mapCasePO.keySet() AND Subject = 'Obtain Customer Info' AND Status = 'Open']){
                system.debug('updateTask tsk : ' + tsk);
                if(tsk!=null){
                    system.debug('updateTask mapCasePO.get(tsk.WhatId) : ' + mapCasePO.get(tsk.WhatId));
                    tsk.PurchaseOrder_Number__c = mapCasePO.get(tsk.WhatId);
                    updateTask.add(tsk);
                }
            }
            if(!updateCase.isEmpty()){
                update updateCase;
            }system.debug('updateTask : ' + updateTask);
            if(!updateTask.isEmpty()){
                update updateTask;
            }
        }
    }

}