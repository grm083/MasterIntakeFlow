public class updateAcornAssetLocation {

    public static void updateAsset(List<Asset> assets){
        Set<Id> assetIds = new Set<Id>();
        for(Asset a: assets){
           assetIds.add(a.id);
        }
        sendToAcorn(assetIds);
    }
    
    @future(callout=true)
    public static void sendToAcorn(Set<Id> assetsIds){
        Id assetDetailRecId = Schema.SobjectType.Asset.getRecordTypeInfosByDeveloperName().get('Service_Detail').getRecordTypeId();
        Map<Id,Asset> revertedAssets = new Map<Id,Asset>();
        List<Asset> assetDetails = new List<Asset>();
        Set<Id> successAssets = new Set<Id>();
        List<Asset> assetLst = [SELECT Id, Acorn_SID__c, Container_Position__c FROM Asset WHERE Id IN :assetsIds];
   
        for(Asset a : assetLst){
                String result = IntegrationHandlerUtil.getMetadataDetails(Constant_Util.Update_Asset_Position, a);
                RestHelper.AcornResponse jsonresp = (RESTHelper.AcornResponse) JSON.deserialize(result,RESTHelper.AcornResponse.class);
                
                if (jsonResp.hasProblems() || Test.isRunningTest()){
                  revertedAssets.put(a.id, a.clone(true,true,false,true));  
                } else{
                  successAssets.add(a.id);
                }            
            	}
        //updating Asset Detail container position if callout is success
			for(Asset a :  [SELECT Id, Container_Position__c, Service_Header_Id__r.Container_Position__c FROM Asset WHERE RecordTypeId = :assetDetailRecId AND Service_Header_Id__c IN :successAssets]){
            a.Container_Position__c = a.Service_Header_Id__r.Container_Position__c;
           	assetDetails.add(a);
        	}
        
        	if(assetDetails.size()>0){
            update assetDetails;
       		}
        
        if(revertedAssets.size()>0){
            revertAssets(revertedAssets);
        }
    }
    
    
    public static void revertAssets(Map<Id,Asset> revertedAssets){
        try {
            Boolean POSITION_REVERT_COMPLETE = false;
            Map<Id, Asset> updatedAssets = new Map<Id, Asset>();        
            
            List<Asset> revertedAssetHistory = [select Id, Container_Position__c, LastModifiedDate, (select Field, OldValue, NewValue, CreatedDate from Histories where Field in ('Container_Position__c') order by CreatedDate DESC limit 2) from Asset where Id in:revertedAssets.keySet()];
            
            for (Asset a: revertedAssetHistory) {
                Asset revertedAsset = (Asset) revertedAssets.get(a.Id);
                List<AssetHistory> itr = new List<AssetHistory>();
                if(a.Histories!=null || !a.Histories.isEmpty() ){
                    itr = a.Histories ;
                } 
               
                if(Test.isRunningTest()){  //if TEST, create dummy AssetHistory
                    list<AssetHistory> ahList = TestDataFactory.AssetHistory(a.id);
                    itr = ahList ;        
                }
				

                for (AssetHistory ah: itr) {
                    if ( Test.isRunningTest() ||a.LastModifiedDate.date() == ah.CreatedDate.date()) {
                        System.debug('ah '+ah);
                        if (ah.Field == 'Container_Position__c') { 
                            revertedAsset.Container_Position__c = String.valueOf(ah.OldValue); POSITION_REVERT_COMPLETE  = true;
                        } 
                    }
                    if (POSITION_REVERT_COMPLETE){ updatedAssets.put(revertedAsset.Id, revertedAsset); }
                }
            }
            if (POSITION_REVERT_COMPLETE){ update updatedAssets.values(); }    
        } catch(Exception e) {
            System.debug('An Error Occurred While Trying to Revert The Case: ' + e.getMessage());
        }
    }
    }