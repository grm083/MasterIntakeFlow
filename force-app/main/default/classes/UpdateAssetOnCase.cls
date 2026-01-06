/*************************************************************
@Name: UpdateAssetOnCase
@Author: Kyle Homovec
@CreateDate: 11/12/2019
@Description: Handles Asset Update on Case and passes data to Acorn
@UsedBy: 
**************************************************************/
public class UpdateAssetOnCase {

    public static void updateAsset(List<Case> caselst, Map<Id,Case> oldCaseMap){
        Set<ID> setCaseIds = new Set<Id>();
                                
        String jsonOldMap = JSON.serialize(oldCaseMap);
        for(Case c : caselst){
            setCaseIds.add(c.id);
        }
        if(!setCaseIds.isEmpty() && !string.isBlank(jsonOldMap)){
            sendToAcorn(setCaseIds, jsonOldMap);
        }
    }

    @future(callout=true)
    public static void sendToAcorn(Set<Id> caseset, String jsonOldMap){
        String oldAssignment;
        Map<Id,Case> oldCaseMap = (Map<Id,Case>) JSON.deserialize(jsonOldMap,Map<Id,Case>.class);
        Map<Id,Case> assetCaseMap = new Map<Id,Case>();
        Map<Id,Case> revertedCases = new Map<Id,Case>();
        Set<Id> oldAssetIds = new Set<Id>();
        Map<Id,Case> assetDetailCaseMap = new Map<Id,Case>();
        Set<Id> assetDetailSet = new Set<Id>();
        
        //blankAssetFix
        Set<Id> blankAssetCases = new Set<Id>();
		//
		
        for(Case c : [SELECT Id,Tracking_Number__c, AssetId, AssetDetail__c, Case_Sub_Type__c FROM Case WHERE Id IN :caseset LIMIT 5000]){
            Case c2 = (Case) oldCaseMap.get(c.id);
            if(c2.AssetDetail__c != null && c.AssetDetail__c != null){
                assetDetailCaseMap.put(c2.AssetDetail__c,c);
                assetDetailSet.add(c2.AssetDetail__c);
			
            //blankAssetFix
            }else if(string.isBlank(c2.AssetId)){
                blankAssetCases.add(c.Id);
            }
            else{
            oldAssetIds.add(c2.AssetId);
            assetCaseMap.put(c2.AssetId,c);
            }
            //

        }
		
        System.debug('old asset ids size---' + oldAssetIds.size());
        System.debug('assetDetailset size-- ' + assetDetailSet.size());
        if(oldAssetIds.size()>0){
            for(Asset a : [SELECT Id, Is_Active__c, Acorn_SBID__c, Is_Core_Service__C, Service_Header_Id__c FROM Asset WHERE Service_Header_ID__c IN : oldAssetIds AND Is_Active__c = TRUE AND Is_Core_Service__c = TRUE LIMIT 5000]){
                Case c3 = (Case) assetCaseMap.get(a.Service_Header_ID__c);
                oldAssignment = string.valueof(a.Acorn_SBID__c);
                System.debug('c3 -- ' + c3);
                system.debug('oldassignment -- ' + oldAssignment);
                String result = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API,c3,oldAssignment);
                System.debug('Result: ' + result);

                RESTHelper.AcornResponse jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
                System.debug('jsonResp ' + jsonResp);
            }
        }

        if(assetDetailSet.size()>0){
            for(Asset a : [SELECT Id, Acorn_SBID__c FROM Asset WHERE Id IN :assetDetailSet]){
                Case c4 = (Case) assetDetailCaseMap.get(a.id);
                oldAssignment = string.valueof(a.Acorn_SBID__c);
                String result = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API,c4,oldAssignment);
                RESTHelper.AcornResponse jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
                System.debug('jsonResp ' + jsonResp);
            }
        }
        
        //BlankAssetFix
        if(blankAssetCases.size()>0){
            for(Case c : [SELECT Id, AssetId, AssetDetail__c, Case_Sub_Type__c FROM Case WHERE Id IN :blankAssetCases LIMIT 5000]){
                oldAssignment = null;
                String result = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.MODIFY_EXISTING_SERVICE_CASE_API,c,oldAssignment);
                RESTHelper.AcornResponse jsonResp = (RESTHelper.AcornResponse) JSON.deserialize(result, RESTHelper.AcornResponse.Class);
                System.debug('jsonResp ' + jsonResp);
            }
         //
        }

    }

}