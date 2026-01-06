public with sharing class WorkOrderLineItemTriggerHelper {
    public static void updateAcornWOLineItem(Map<Id,WorkOrderLineItem> oldMap,  Map<Id,WorkOrderLineItem> newMap) {
        Map<Id,WorkOrderLineItem> updateWOLIMap = new Map<Id,WorkOrderLineItem>();
        Map<Id,WorkOrder> woMap = new Map<Id,WorkOrder>();
        set<Id> woIdSet = new set<Id>();
        for(WorkOrderLineItem WOLI : newMap.values()){
        	woIdSet.add(WOLI.WorkOrderId);
        }
        for(WorkOrder wo : [SELECT Id, Status FROM WorkOrder WHERE Id IN: woIdSet LIMIT 49999]){
            woMap.put(wo.Id, wo);
        }
        for(WorkOrderLineItem WOLI : newMap.values()){
            WorkOrderLineItem oldWOLI = (WorkOrderLineItem) oldMap.get(woLI.id);
            WorkOrder wo = (WorkOrder) woMap.get(woLI.WorkOrderId);
            
            if((oldWOLI.Quantity__c != WOLI.Quantity__c && (wo.Status == Constant_Util.WO_STATUS || wo.Status == Constant_Util.ISSUED)) ||
                  ((oldWOLI.New_Client_Price__c != WOLI.New_Client_Price__c || oldWOLI.Reason_Code__c != WOLI.Reason_Code__c || oldWOLI.Reason_Description__c != WOLI.Reason_Description__c)
                  && (wo.Status == Constant_Util.WO_STATUS || wo.Status == Constant_Util.ISSUED || wo.Status == Constant_Util.SENT))){
                updateWOLIMap.put(WOLI.id,WOLI);
            }
        }
        if(updateWOLIMap.size()>0 && updateWOLIMap != null){
            updateQuantityClientPrice.updateWOLineItem(oldMap,newMap);
        }
    }
    /**
	* @author Accenture
	* @date 8/5/2020
	* @description : Method to validate quantity based on service types
	**/
	public static void validateQuantityOverride(Map<Id,WorkOrderLineItem> oldMap,  Map<Id,WorkOrderLineItem> newMap) {
		List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> woliCpLst = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> woliCPQuanLst = new List<WorkOrderLineItem>();
		Map<Id, string> errorMap = new Map<Id,string>();
        set<string> serviceTypeSet = new set<string>();
		
		for(WorkOrderLineItem woli : newMap.values()){
			WorkOrderLineItem oldWOLI = (WorkOrderLineItem) oldMap.get(woLI.id);
			if(oldWOLI.Quantity__c != woli.Quantity__c && !string.isBlank(woli.Service_Type__c)){
				woliLst.add(woli);
                serviceTypeSet.add(woli.Service_Type__c.toLowerCase());
			}
            if(oldWOLI.New_Client_Price__c != woli.New_Client_Price__c){
                woliCpLst.add(woli);
            }
            if(oldWOLI.Quantity__c != woli.Quantity__c || oldWOLI.New_Client_Price__c != woli.New_Client_Price__c || oldWOLI.Reason_Code__c != woli.Reason_Code__c || oldWOLI.Reason_Description__c != woli.Reason_Description__c){
                woliCPQuanLst.add(woli);
            }
		}
        if(!serviceTypeSet.isEmpty()){
       		errorMap = ValidationUtility.validateQuantity(woliLst, serviceTypeSet, Constant_Util.SOBJ_ID, Constant_Util.QUANTITY_NAME, 
														Constant_Util.ASSET_QUANTITY_NAME, Constant_Util.SERVICE_TYPE_NAME);    
        }
        if(!woliCpLst.isEmpty() && woliCpLst != null){
        	errorMap = ValidationUtility.validateClientPrice(woliCpLst, Constant_Util.REASON_CODE_NAME, Constant_Util.SOBJ_ID);
        }
        if(!woliCPQuanLst.isEmpty() && woliCPQuanLst != null){
        	errorMap = ValidationUtility.validateCPQuantity(woliCPQuanLst, Constant_Util.OCCUR_TYPE_NAME, Constant_Util.SOBJ_ID);
        }
        for(WorkOrderLineItem woli : newMap.values()){
            if(errorMap != null && errorMap.containsKey(WOLI.Id)){
                woli.addError(errorMap.get(WOLI.Id));
            } 
		}
	}
}