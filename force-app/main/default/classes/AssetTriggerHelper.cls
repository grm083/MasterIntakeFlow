/*************************************************************
@Name: AssetTriggerHelper
@Author: Satyabrata Nag
@CreateDate: 26/07/2019
@Description: Handler Class to Perform operations on Asset
@UsedBy: AssetTrigger
**************************************************************/    
public class AssetTriggerHelper {
    
    public class AccountMismatchException extends Exception {}
    
    public static void populateProjectActiveFlag(List<Asset> assetList,Boolean isInsert,Map<Id,Asset> oldAssetmap){
        
        try{
            Set<Id> ProjectCodeIds= new Set<Id>();
            Map<Id,Project_Code__c> detailProj = new Map<Id,Project_Code__c>();
            Set<Id> productIds = new Set<Id>();
            Map<Id,Product2> productMap = new Map<Id,Product2>();
            for(Asset a : assetList){
                if((!isInsert && a.Project_Code__c!=null && !oldAssetmap.isEmpty() && oldAssetmap.get(a.Id).Project_Code__c!=a.Project_Code__c) || (isInsert && a.Project_Code__c!=null)){
                    ProjectCodeIds.add(a.Project_Code__c);
                    productIds.add(a.Product2Id);
				}
                else if(a.Project_Code__c==null){
                    a.active__c=false;
                    a.end_date_based_on_project_code__c=null;
                }   
            }
            
            if(ProjectCodeIds != null && ProjectCodeIds.size() > 0 && productIds != null && productIds.size() > 0){
                for(Project_Code__c pCode: [select Id,Client_Account__c,Effective_Date__c,Project_Code_Header__c,container_type__c,duration__c,end_date__c,Length_of_Project_Days__c from Project_Code__c where Id IN :ProjectCodeIds LIMIT 49999]){
                    detailProj.put(pCode.Id,pCode);
                }
                for(Product2 prod: [select id,ProductTypeSelected__c from Product2 where Id IN : productIds LIMIT 49999]){
                    productMap.put(prod.Id,prod);
                }
            }
            if(assetList != null && assetList.size() > 0 && detailProj != null && detailProj.size() > 0 && productMap != null && productMap.size() > 0 && !RecurrsiveTriggerHandler.bypassValidation){
                string error = 'Container Type of the Project should Match with the Container Type of the Asset "'; 
                for(Asset a : assetList){
                    if(detailProj.get(a.Project_Code__c) != null && detailProj.get(a.Project_Code__c).Container_Type__c != null && productMap.get(a.Product2Id) != null && !(detailProj.get(a.Project_Code__c).Container_Type__c).Contains(productMap.get(a.Product2Id).ProductTypeSelected__c)){
                        error += productMap.get(a.Product2Id).ProductTypeSelected__c;
                        error += '"';
                        a.addError(error);
                    }
                }   
				ProjectCodeTriggerHelper.toUpdateProjectCodeStatusOnAsset(assetList,false,detailProj);
			}
        }
        catch(Exception e){
            System.debug('Exception::::'+e.getStackTraceString()); 
        }
    }

    
    public static void updateContainerPosition(List<Asset> assetList, Map<Id,Asset> oldAssetMap){
        List<Asset> updateAssets = new List<Asset>();
        Id assetHeaderRecId = Schema.SobjectType.Asset.getRecordTypeInfosByDeveloperName().get('Service_Header').getRecordTypeId();
        for(Asset a : assetList){
            if(a.RecordTypeId == assetHeaderRecId){
                Asset a2 = (Asset) oldAssetMap.get(a.id);
                if(a.Container_Position__c!=a2.Container_Position__c){
                    updateAssets.add(a);
                }
            }
        }
        if(updateAssets.size()>0){
            updateAcornAssetLocation.updateAsset(updateAssets);    
        }
    }
}