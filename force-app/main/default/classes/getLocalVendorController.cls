public class getLocalVendorController {

	/*
	* Story: SDT-20786
	* Sprint: AM Sprint6
	* FC: Rahul Rana Singh
	* Dev: Rishiraj Singh
	*/
    @AuraEnabled
    public static Map<String, List<Asset>> getDetails(String quoteId) {
		SBQQ__Quote__c quoteObj= [SELECT Id, SBQQ__ShippingPostalCode__c FROM SBQQ__Quote__c WHERE Id =: quoteId];
        String wasteStream = 'Waste Stream';
        String wasteCategory= 'Waste Category';
        Map<String,String> materialWCMap= new Map<String,String>();
        Set<String> materialSet= new Set<String>();
        List<Asset> assetList = [SELECT Id, Material_Type__c, Supplier__r.Name, Supplier__r.AccountNumber,Supplier__r.Vendor_Business_Unit__c,Supplier__r.Legacy_Ranking__c, MAS_Company_Code__c, MAS_Library__c FROM Asset WHERE Material_Type__c!=null AND RecordType.Name = 'Service Header' AND Location__r.ShippingPostalCode =: quoteObj.SBQQ__ShippingPostalCode__c AND Start_Date__c <= TODAY AND (End_Date__c >= TODAY OR End_Date__c = Null) AND Supplier__r.Status__c = 'Active' ORDER BY Supplier__r.Legacy_Ranking__c ASC];
        if(!assetList.isEmpty()){
            for(Asset ass: assetList){
                materialSet.add(ass.Material_Type__c);
            }
        }

        List<SBQQ__ProductOption__c> wasteCategoryPOList=[SELECT Id, Name, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Name, SBQQ__ConfiguredSKU__c,SBQQ__ConfiguredSKU__r.Name  FROM SBQQ__ProductOption__c Where SBQQ__OptionalSKU__r.Name IN : materialSet AND SBQQ__OptionalSKU__r.Family =: wasteStream AND SBQQ__ConfiguredSKU__r.Family=:wasteCategory];
        for(SBQQ__ProductOption__c poObj: wasteCategoryPOList){
            materialWCMap.put(poObj.SBQQ__OptionalSKU__r.Name, poObj.SBQQ__ConfiguredSKU__r.Name);
        }

        Map<String, List<Asset>> wcVendorListMap = new Map<String, List<Asset>>();	
        if(!assetList.isEmpty()){
			for (Asset assObj : assetList) {
                if(materialWCMap.containsKey(assObj.Material_Type__c)){
                    if(wcVendorListMap.containskey(materialWCMap.get(assObj.Material_Type__c))){
                        List<Asset> asstList= wcVendorListMap.get(materialWCMap.get(assObj.Material_Type__c));
                        asstList.add(assObj);
                        wcVendorListMap.put(materialWCMap.get(assObj.Material_Type__c),asstList);
                    }else{
                        List<Asset> asstList= new List<Asset>();
                        asstList.add(assObj);
                        wcVendorListMap.put(materialWCMap.get(assObj.Material_Type__c),asstList);
                    }
                }
            }
        }
        wcVendorListMap.put(Label.WasteCategory_ShowLocalVendorComp,assetList);
        return wcVendorListMap;
    }
}