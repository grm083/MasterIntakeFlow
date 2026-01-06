public with sharing class HoverOverCardsCntrl {
    public static Map<String,Asset> assetdetails = new Map<String,Asset>();
    public static set<String> serviceTypeSet;
    @AuraEnabled(cacheable=true)
    public static Wrapper getServiceDetails(Case caserec){
        Wrapper wrapperclass = new Wrapper();
        set<String> serviceSet = new set<String>();
        String asskey = null;
        Map<String,Integer> assetcount = new Map<String,Integer>();
        try{
            if(caserec != null && String.isNotBlank(caserec.AssetId)){
                serviceTypeSet = new Set<String>{Constant_Util.PICKUP_CSTYPE,Constant_Util.HAUL,Constant_Util.DISPOSAL};
                    for(Asset a : [select id,Service_Type__c,Occurrence_Type__c,Cost__c,Price__c,Has_Extra_Pickup__c,Quantity__c from Asset where Service_Header_Id__c =: caserec.AssetId and Service_Type__c IN: serviceTypeSet and Is_Active__c = true and RecordType.DeveloperName =: Constant_Util.SERVICE_DETAILS LIMIT 49999]){
                        asskey = (Constant_Util.PICKUP_CSTYPE).Equals(a.Service_Type__c) ? String.valueOf(a.Service_Type__c) + String.valueOf(a.Occurrence_Type__c) : String.valueOf(a.Service_Type__c);
                        if((assetdetails.IsEmpty() && serviceSet.IsEmpty())|| ((assetdetails.IsEmpty() || (!assetdetails.IsEmpty() && !assetdetails.containsKey(asskey)))&& (!serviceSet.IsEmpty() && !serviceSet.contains(asskey)))){
                            assetdetails.put(asskey,a);
                            serviceSet.add(asskey);
                        }
                        else if(assetdetails.containsKey(asskey) && serviceSet.contains(asskey)){
                            assetdetails.remove(asskey);
                        }
                    }
            }
            if(assetdetails != null && assetdetails.size() > 0){
                if(String.isNotBlank(caserec.Asset.ProductFamily) && (Constant_Util.COMMERCIAL).Equals(caserec.Asset.ProductFamily)){
                    wrapperclass.assetQuantity = assetdetails.containsKey(Constant_Util.PICKUP_SCHEDULED) ? String.valueOf(assetdetails.get(Constant_Util.PICKUP_SCHEDULED).Quantity__c) : null;
                   	wrapperclass.extraPickUpCost = assetdetails.containsKey(Constant_Util.PICKUP_ONCALL) ? String.valueOf(assetdetails.get(Constant_Util.PICKUP_ONCALL).Cost__c) : null;
                    wrapperclass.extraPickUpPrice = assetdetails.containsKey(Constant_Util.PICKUP_ONCALL) ? String.valueOf(assetdetails.get(Constant_Util.PICKUP_ONCALL).Price__c) : null;
                    wrapperclass.pickUpCost = assetdetails.containsKey(Constant_Util.PICKUP_SCHEDULED) && assetdetails.get(Constant_Util.PICKUP_SCHEDULED).Has_Extra_Pickup__c ? String.valueOf(assetdetails.get(Constant_Util.PICKUP_SCHEDULED).Cost__c) : null;
                    wrapperclass.pickUpPrice = assetdetails.containsKey(Constant_Util.PICKUP_SCHEDULED) && assetdetails.get(Constant_Util.PICKUP_SCHEDULED).Has_Extra_Pickup__c ? String.valueOf(assetdetails.get(Constant_Util.PICKUP_SCHEDULED).Price__c) : null;
                    
                    wrapperclass.haulCost = null;
                    wrapperclass.haulPrice = null;
                    wrapperclass.disposalCost = null;
                    wrapperclass.disposalPrice = null;
                }
                else if(String.isNotBlank(caserec.Asset.ProductFamily) && (Constant_Util.ROLLOFF).Equals(caserec.Asset.ProductFamily)){
                    wrapperclass.haulCost = assetdetails.containsKey(Constant_Util.HAUL) ? String.valueOf(assetdetails.get(Constant_Util.HAUL).Cost__c) : null;
                    wrapperclass.haulPrice = assetdetails.containsKey(Constant_Util.HAUL) ? String.valueOf(assetdetails.get(Constant_Util.HAUL).Price__c) : null;
                    wrapperclass.disposalCost = assetdetails.containsKey(Constant_Util.DISPOSAL) ? String.valueOf(assetdetails.get(Constant_Util.DISPOSAL).Cost__c) : null;
                    wrapperclass.disposalPrice = assetdetails.containsKey(Constant_Util.DISPOSAL) ? String.valueOf(assetdetails.get(Constant_Util.DISPOSAL).Price__c) : null;
                    wrapperclass.pickUpCost = null;
                    wrapperclass.pickUpPrice = null;
                    wrapperclass.extraPickUpPrice = null;
                    wrapperclass.extraPickUpCost = null;
                }
            }
        }catch(exception e){
            system.debug('Exception:::::'+e.getStackTraceString());
        }
        return wrapperclass;
    }
    @AuraEnabled(cacheable=true)
    public static Wrapper getHoverServiceDetails(string caseid){
    	case ca = [Select id,AssetId,Asset.ProductFamily from case where Id =: caseid Limit 1];
        Wrapper result = HoverOverCardsCntrl.getServiceDetails(ca);
        return result;
    }
    public with sharing class Wrapper {
		@AuraEnabled public string assetQuantity {get;set;}
        @AuraEnabled public string pickUpCost {get;set;}
        @AuraEnabled public string pickUpPrice {get;set;}
        @AuraEnabled public string extraPickUpPrice {get;set;}
        @AuraEnabled public string extraPickUpCost {get;set;} 
        @AuraEnabled public string haulCost {get;set;} 
        @AuraEnabled public string haulPrice {get;set;}
        @AuraEnabled public string disposalCost {get;set;} 
        @AuraEnabled public string disposalPrice {get;set;}
    } 
}