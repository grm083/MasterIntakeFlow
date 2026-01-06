/**
* @author - WM
* @date 5/29/2020
* @description : Apex class CaseAssetControllerPopUp - This covers funtionality of Insertion of Case Assets for Non Pickup cases where WorkOrder is being Created.
**/

Public with sharing class CaseAssetControllerPopUp{
    
    @AuraEnabled 
    public static List<Asset> serviceAssetDetail(string recId){
        string assetId = '';
        string locationId = '';
        Map<Id,Asset> childAssetMap = new Map<Id,Asset>();
        List<Asset>assetdetails = new List<Asset>();
        List <Asset> availableAssetList = new List<Asset>();
        
        
        List<case> caseList = [select id,Service_Date__c,AssetId,Location__c,client__c from case where id=:recId limit 1];       
        
        if(caselist != null && !caseList.isEmpty() && caseList.size()>0){
            assetId = caseList[0].AssetId;
            locationId = caseList[0].Location__c;               
        }
        
        if(!string.isBlank(assetId) && !string.isBlank(locationId) && caselist != null ){
            for(Asset asst : [select id,Name,Service_Type__c,Schedule__c,Material_Type__c,Duration__c,Occurrence_Type__c,Sensitivity_Code__c,Vendor_ID__c,
                              Supplier__r.Name,Start_Date__c,End_Date__c,Category__c,
                              Container_Position__c,Equipment_Owner__c,Quantity__c,Has_Extra_Pickup__c,Vendor_Account_Number__c,MAS_Customer_Unique_Id__c,
                              MAS_Library__c,Frequency__c,Is_Active__c,Service_Header_Id__c
                              from Asset 
                              where RootAssetId =:assetId AND RecordType.DeveloperName =: Constant_Util.SERVICE_DETAILS  AND Start_Date__c <=: caseList[0].Service_Date__c AND (End_Date__c = null OR End_Date__c >=: caseList[0].Service_Date__c) AND (Occurrence_Type__c =: Constant_Util.ON_CALL OR Occurrence_Type__c =: Constant_Util.SCHEDULED_ON_CALL ) AND Location__c=:locationId limit 500]){
                                  childAssetMap.put(asst.Id,asst);
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
        List<Asset> lstToBeInsert = new List<Asset>();
        List<SBS_Case_Asset__c> cseAsstList = new List<SBS_Case_Asset__c>();
        
        Map<Id,Asset> childAssetMap = new Map<Id,Asset>();
        List<SBS_Case_Asset__c>lstToBeDel = new List<SBS_Case_Asset__c>();
        selectedAssetList = (List<Asset>)JSON.deserialize(assetString,List<Asset>.class);
        
        // Delete Existing Case Assets and Create New Case Assets from Selected Service Details
        List<SBS_Case_Asset__c> caseAssetList = [Select id,AssetId__c,CaseId__c From SBS_Case_Asset__c where CaseId__c =: CaseId ];       
        Database.Delete(caseAssetList);
        
        if(selectedAssetList  != null && !selectedAssetList.isEmpty()){
            for(Asset asst : selectedAssetList){
                SBS_Case_Asset__c cseAsst = new SBS_Case_Asset__c();
                cseAsst.CaseId__c = CaseId;
                cseAsst.Asset_Header__c = asst.Service_Header_Id__c;
                cseAsst.AssetId__c = asst.Id;
                cseAsst.IsManual__c = true;
                cseAsstList.add(cseAsst);
            }
            database.insert(cseAsstList);
        }
    }
}