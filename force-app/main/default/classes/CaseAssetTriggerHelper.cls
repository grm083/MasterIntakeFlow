/*
 * @author: Accenture
 * @date: 4/16/2019
 * @description: Helper class to handle operations on Case Assets
 * @usedby: SDT 2979
 */ 
public without sharing class CaseAssetTriggerHelper {

    //updating Case values from trigger action on CaseAsset
   public static void updateCase(Map<Id,SBS_Case_Asset__c> newCaseAssetMap, Map<Id,SBS_Case_Asset__c> oldCaseAssetMap){
    	//Changes related to SDT-41503 & SDT-41502
        Set<Id> caseIds = new Set<Id>();
        Set<Id> coreCaseAssets = new Set<Id>();
        List<Case> updatedCase = new List <Case>();
        Set<Id> caseAssetSet = new Set <Id>();
        Set<Id> casesWithCoreAsset = new Set<Id>();
		

        for(SBS_Case_Asset__c ca : newCaseAssetMap.values()){
            caseAssetSet.add(ca.Id);
            
        }
		
        //populate case asset set
        for(SBS_Case_Asset__c ca : [SELECT Id, AssetId__r.Is_Core_Service__c,AssetId__r.supplier__c,CaseId__c, CaseId__r.RecordType.Name, CaseId__r.Is_Clone__c,CaseId__r.Is_Multivendor__c FROM SBS_Case_Asset__c WHERE Id IN :caseAssetSet LIMIT 4999]){
            if(ca.CaseId__r.Is_Clone__c != true || ca.CaseId__r.Is_Multivendor__c != true ){
                if(ca.AssetId__r.Is_Core_Service__c == TRUE){
                    coreCaseAssets.add(ca.id);
                    casesWithCoreAsset.add(ca.CaseId__c);
                }
                
            } 
        }
       System.debug('>>>> core case assets: ' + casesWithCoreAsset.size());
        
       //set Case quantity override equal to core asset detail, if the Case has a case asset that is related to a core asset detail
        for(SBS_Case_Asset__c ca: [SELECT Id, CaseId__c, AssetId__r.Is_Core_Service__c, AssetId__r.Quantity__c,CaseId__r.Case_Sub_Type__c,CaseId__r.Is_Clone__c,CaseId__r.Is_Multivendor__c, AssetId__r.supplier__c FROM SBS_Case_Asset__c WHERE ID In :coreCaseAssets  LIMIT 4999]){
            if(ca.CaseId__r.Is_Clone__c != true || ca.CaseId__r.Is_Multivendor__c != true ){
                Case c = new Case();
                c.Id = ca.CaseId__c;
                if(ca.CaseId__r.Case_Sub_Type__c == 'Extra Pickup'){
                c.Quantity_Override__c = 1;
                }
                else{
                c.Quantity_Override__c = ca.AssetId__r.Quantity__c;
                }    
                c.AssetDetail__c = ca.AssetId__c;
                c.Supplier__c = ca.AssetId__r.supplier__c;
                If(!caseIds.contains(ca.CaseId__c)){
                    updatedCase.add(c);
                	//Changes related to SDT-41503 & SDT-41502
                	caseIds.add(ca.CaseId__c); 
                }

            }
        }
        //set Case quantity override equal to the case asset's related asset detail, if a non core asset detail exists.  Populate AssetDetail field on Case with the asset detail's Id.  
        for(SBS_Case_Asset__c ca : [SELECT Id,CaseId__c, CaseId__r.AssetDetail__c, CaseId__r.AssetDetail__r.is_Core_Service__c, AssetId__r.Is_Core_Service__c, AssetId__r.Quantity__c , CaseId__r.Is_Multivendor__c,CaseId__r.Case_Sub_Type__c,CaseId__r.Is_Clone__c, AssetId__r.supplier__c FROM SBS_Case_Asset__c WHERE CaseId__c NOT In :casesWithCoreAsset AND Id IN :caseAssetSet LIMIT 4999]){
            if(ca.CaseId__r.Is_Clone__c != true || ca.CaseId__r.Is_Multivendor__c != true){
                Case c = new Case();
                c.Id = ca.CaseId__c;
                if(ca.CaseId__r.Case_Sub_Type__c == 'Extra Pickup'){
                c.Quantity_Override__c = 1;
                }
                else{
                c.Quantity_Override__c = ca.AssetId__r.Quantity__c;
                }    
                c.AssetDetail__c = ca.AssetId__c;
                c.Supplier__c = ca.AssetId__r.supplier__c;
				updatedCase.add(c);
                System.debug('>>>>>>> case asset non core' + ca.Id + ' case: ' + c.Id );
                System.debug('>>>>>>> asset detail id: '+ ca.CaseId__r.AssetDetail__c + ' core service: ' + ca.CaseId__r.AssetDetail__r.Is_Core_Service__c);
            }
        }
       	
        
	Database.update(updatedCase);
    } 
    
    /**
	* @author Accenture
	* @date 8/6/2020
	* @description : Method to validate quantity based on service types
	**/
	public static void populateQuantityOverride(List<SBS_Case_Asset__c> caLst) {
        Set<Id> caseIds = new Set<Id>();
        Map<Id, case> caseMap = new Map<Id, case>();
        for(SBS_Case_Asset__c ca : caLst){
            caseIds.add(ca.CaseId__c);
        }
        for(Case cse: [SELECT Id, Is_Multivendor__c FROM Case WHERE Id IN: caseIds]){
            caseMap.put(cse.Id, cse);
        }
        for(SBS_Case_Asset__c ca : caLst){
            if(caseMap.containsKey(ca.CaseId__c)){
                case c = caseMap.get(ca.CaseId__c);
                ca.Quantity_Override__c = c.Is_Multivendor__c ? ca.Quantity_Override__c : ca.Quantity__c;
            }            
        }
    }
    /**
	* @author Accenture
	* @date 8/6/2020
	* @description : SDT-15310: Method to validate quantity based on service types
	**/
	public static void validateQuantityOverride(Map<Id,SBS_Case_Asset__c> oldMap,  Map<Id,SBS_Case_Asset__c> newMap) {
		List<SBS_Case_Asset__c> caLst = new List<SBS_Case_Asset__c>();
        List<SBS_Case_Asset__c> caCPLst = new List<SBS_Case_Asset__c>();
        List<SBS_Case_Asset__c> caCPQuanLst = new List<SBS_Case_Asset__c>();
		Map<Id, string> errorMap = new Map<Id,string>();
        set<string> serviceTypeSet = new set<string>();
		
		for(SBS_Case_Asset__c ca : newMap.values()){
			SBS_Case_Asset__c oldCA = (SBS_Case_Asset__c) oldMap.get(ca.id);
			if(oldCA.Quantity_Override__c != ca.Quantity_Override__c && !string.isBlank(ca.Asset_Service_Type__c)){
				caLst.add(ca);
                serviceTypeSet.add(ca.Asset_Service_Type__c.toLowerCase());
			}
            if(oldCA.New_Client_Price__c != ca.New_Client_Price__c){
                caCPLst.add(ca);
            }
            //Validate Client Price and Quantity
            if(oldCA.Quantity_Override__c != ca.Quantity_Override__c || oldCA.Reason_Code__c != ca.Reason_Code__c || oldCA.Reason_Description__c != ca.Reason_Description__c){
                caCPQuanLst.add(ca);
            }
		}
        if(!serviceTypeSet.isEmpty()){
			errorMap = ValidationUtility.validateQuantity(caLst, serviceTypeSet, Constant_Util.SOBJ_ID, Constant_Util.QUANT_OVERRIDE_NAME, 
														Constant_Util.QUANTITY_NAME, Constant_Util.CA_SERV_TYPE_NAME);
        }
        if(!caCPLst.isEmpty() && caCPLst != null){
        	errorMap = ValidationUtility.validateClientPrice(caCPLst, Constant_Util.REASON_CODE_NAME, Constant_Util.SOBJ_ID);
        }
        if(!caCPQuanLst.isEmpty() && caCPQuanLst != null){
        	errorMap = ValidationUtility.validateCPQuantity(caCPQuanLst, Constant_Util.OCCUR_NAME, Constant_Util.SOBJ_ID);
        }
        for(SBS_Case_Asset__c ca : newMap.values()){
            if(errorMap != null && errorMap.containsKey(ca.Id)){
                ca.addError(errorMap.get(ca.Id));
            } 
		}
	}
    
}