/**
* @author Accenture
* @date 8/4/2020
* @description : Utility class for CaseAsset and WorkOrderLineItem triggers
**/

public without sharing class ValidationUtility {
    public static Map<Id, string> errorMap = new Map<Id,string>();
	/**
	* @author Accenture
	* @date 8/4/2020
	* @description : Method to validate quantity based on service types
	**/
	public static Map<Id, string> validateQuantity(List<SObject> sobjectLst, set<string> serviceTypeSet, string sobjId,
										  string quantityName, string assetQuantityName, string serviceTypeName) {                                      
        try {
            Map<String, Case_Service_Type__mdt> cstMetadataMap = new Map<String, Case_Service_Type__mdt>();
            for(Case_Service_Type__mdt cst : [SELECT Id, Service_Type__c FROM Case_Service_Type__mdt WHERE 
										   Service_Type__c IN: serviceTypeSet LIMIT 49999]){
				cstMetadataMap.put(cst.Service_Type__c, cst);
			}
            for (SObject sobj : sobjectLst) {
                Decimal quantity = (Decimal)sobj.get(quantityName);
                Decimal assetQuantity = (Decimal)sobj.get(assetQuantityName);
				string serviceType = (string)sobj.get(serviceTypeName);
                if(quantity == 0) {
					errorMap.put((string)sobj.get(sobjId), System.Label.Quantity_Error_Message_3);
				}
				else if(quantity < 0 ) {
					errorMap.put((string)sobj.get(sobjId), System.Label.Quantity_Error_Message_2);
				}				
				else {
					if(!cstMetadataMap.ContainsKey(serviceType)){
						if( quantity > assetQuantity){
							errorMap.put((string)sobj.get(sobjId), Constant_Util.SERVICE_TYPE_ERROR+serviceType+System.Label.Quantity_Error_Message_1);
						}
					}
				}
            }
            return errorMap;
        } catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
            return null;
        }
    }
	/**
	* @author Accenture
	* @date 8/4/2020
	* @description : Method to validate Client Price
	**/
	public static Map<Id, string> validateClientPrice(List<SObject> sobjectLst, string ReasonCodeName, string sobjId) {
		for (SObject sobj : sobjectLst) {
			string ReasonCode = (String)sobj.get(ReasonCodeName);
			if(String.isBlank(ReasonCode)){
				errorMap.put((string)sobj.get(sobjId), System.Label.ReasonCode_Error_Message);
			}
		}
		return errorMap;
	} 
	/**
	* @author Accenture
	* @date 8/4/2020
	* @description : Method to validate Client Price and Quantity
	**/
	public static Map<Id, string> validateCPQuantity(List<SObject> sobjectLst, string occuranceName, string sobjId) {
		for (SObject sobj : sobjectLst) {
			string occurance = (String)sobj.get(occuranceName);
			if(Constant_Util.SCHEDULED.equals(occurance)){
				errorMap.put((string)sobj.get(sobjId), System.Label.Quantity_Client_Price_Error_Message);
			}
		}
		return errorMap;
	}
}