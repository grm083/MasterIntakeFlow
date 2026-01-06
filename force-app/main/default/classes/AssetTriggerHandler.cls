/*************************************************************
@Name: AssetTriggerHandler
@Author: Satyabrata Nag
@CreateDate: 26/07/2019
@Description: This class is used handle AssetTrigger.
**************************************************************/

public  class AssetTriggerHandler {
    public static void onBeforeInsert(List<Asset> assetList,Map<Id,Asset> oldAssetmap){
        system.debug('isSkipAssetTrigger++'+RecurrsiveTriggerHandler.isSkipAssetTrigger);
		if(!RecurrsiveTriggerHandler.isSkipAssetTrigger){
            Boolean IsInsert = true;
            AssetTriggerHelper.populateProjectActiveFlag(assetList,IsInsert,oldAssetmap);
            RecurrsiveTriggerHandler.isSkipAssetTrigger=true;
        }
    }
    public static void onBeforeUpdate(List<Asset> assetList,Map<Id,Asset> oldAssetmap){
        system.debug('isSkipAssetTrigger++'+RecurrsiveTriggerHandler.isSkipAssetTrigger);
        if(!RecurrsiveTriggerHandler.isSkipAssetTrigger){
            Boolean IsInsert = false;
            AssetTriggerHelper.populateProjectActiveFlag(assetList,IsInsert,oldAssetmap);
            AssetTriggerHelper.updateContainerPosition(assetList, oldAssetMap);
            RecurrsiveTriggerHandler.isSkipAssetTrigger=true;
        }
    }
}