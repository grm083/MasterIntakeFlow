public without sharing class assetCustomTreeGridController {
    @AuraEnabled
    public static List<Asset> getAssetRecords(string locationRecordId){
        set<Id> idList = new Set<Id> ();
        for(Asset assetRec : [select Id,ParentId from Asset where Location__c =:locationRecordId AND ParentId = Null ]){
            idList.add(assetRec.Id);
        }
        List<Asset> assestListToReturn = [select Id,Name,Acorn_SID__c,Cost__c,Price__c,Material_Type__c,Service_Type__c,Duration__c,Occurrence_Type__c,Schedule__c,
                                  Has_Extra_Pickup__c,Quantity__c,Supplier__r.Name,Container_Position__c,Vendor_ID__c,Sensitivity_Code__c,Vendor_Account_Number__c,
                                  MAS_Company_Account_Number__c,MAS_Unique_Text__c,MAS_Library__c,Start_Date__c,End_Date__c,Category__c,Equipment_Owner__c,Active__c, Supplier__c,
                                  (select Id,Name,Cost__c,Price__c,Material_Type__c,Service_Type__c,Duration__c,Occurrence_Type__c,Schedule__c, Supplier__c,
                                   Has_Extra_Pickup__c,Quantity__c,Supplier__r.Name,Container_Position__c,Vendor_ID__c,Sensitivity_Code__c,Vendor_Account_Number__c,
                                   MAS_Company_Account_Number__c,MAS_Unique_Text__c,MAS_Library__c,Start_Date__c,End_Date__c,Category__c,Equipment_Owner__c,Active__c
                                   from ChildAssets ORDER BY Service_Type__c, End_Date__c DESC) from Asset where Id IN:idList ORDER BY End_Date__c DESC];
        return assestListToReturn;
    }
    
     /*@AuraEnabled
    public static string getlocationId(string locationRecordId){
    
    return locationRecordId ;
    
    
}*/
}