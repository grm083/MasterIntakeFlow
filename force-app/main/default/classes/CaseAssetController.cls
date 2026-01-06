Public with sharing class CaseAssetController{
    
    
    @AuraEnabled 
    public static List<Asset> serviceAssetDetail(string recId){
        string assetId = '';
        string locationId = '';
        Map<Id,Asset> childAssetMap = new Map<Id,Asset>();
        List <Asset> availableAssetList = new List<Asset>();
        List<case> caseList = [select id,AssetId,Location__c,client__c from case where id=:recId limit 1];
        if(caselist != null && !caseList.isEmpty() && caseList.size()>0){
            assetId = caseList[0].AssetId;
            locationId = caseList[0].Location__c;
        }
        List<Id> caseAssetIdList = new List<Id>();
        for(SBS_Case_Asset__c cseAsset : [Select id,AssetId__c,CaseId__c From SBS_Case_Asset__c where CaseId__c =: recId ]){
            caseAssetIdList.add(cseAsset.AssetId__c);
        }
        if(!string.isBlank(assetId) && !string.isBlank(locationId)){
            for(Asset asst : [select id,Name,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,
                              Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,
                              Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Customer_Unique_Id__c,
                              MAS_Library__c,Frequency__c,Is_Active__c,Service_Header_Id__c
                              from Asset 
                              where RootAssetId =:assetId AND RecordType.DeveloperName =: Constant_Util.SERVICE_DETAILS AND Is_Active__c = true and Location__c=:locationId
                              LIMIT 500]){
                                  childAssetMap.put(asst.Id,asst);
                              }
            if(childAssetMap != null && !childAssetMap.isEmpty()){
                if(caseAssetIdList != null && caseAssetIdList.size() > 0){
                    for(Id cseAssetId : caseAssetIdList){
                        if(childAssetMap.containskey(cseAssetId)){
                            childAssetMap.remove(cseAssetId);
                        }
                    }
                }
            }
        }
        if(childAssetMap != null && !childAssetMap.isEmpty()){
            availableAssetList.addAll(childAssetMap.values());
        }
        return availableAssetList;
    }
    
    @AuraEnabled
    public static void createAsset(String assetString,Id CaseId){
        List<Asset> selectedAssetList = new List<Asset>();
        List<SBS_Case_Asset__c> cseAsstList = new List<SBS_Case_Asset__c>();
        system.debug('json string'+assetString);
        selectedAssetList = (List<Asset>)JSON.deserialize(assetString,List<Asset>.class);
        if(selectedAssetList  != null && !selectedAssetList.isEmpty()){
            for(Asset asst : selectedAssetList){
                SBS_Case_Asset__c cseAsst = new SBS_Case_Asset__c();
                cseAsst.CaseId__c = CaseId;
                cseAsst.Asset_Header__c = asst.Service_Header_Id__c;
                cseAsst.AssetId__c = asst.Id;
                cseAsstList.add(cseAsst);
            }
            database.insert(cseAsstList);
        }
    }
}