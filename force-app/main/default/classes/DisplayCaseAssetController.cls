/**
* @author Accenture
* @date 06/18/2020
* @description : Controller class for DisplayCaseAsset lightning component
**/
public Without Sharing class DisplayCaseAssetController {
	/**
    * @author Accenture
    * @date 6/18/2020
    * @description : Method to query CaseAsset which is to be displayed in DisplayCaseAsset lightning component
    **/
    @AuraEnabled
   	public static List<SBS_Case_Asset__c> getCaseAsset(Id caseId){
        try {  
         	return [SELECT Id, AssetId__r.Name, Asset_Service_Type__c, Occurrence__c, AssetId__r.Material_Type__c, AssetId__r.Price__c, 
                    New_Client_Price__c, Reason_Code__c, Reason_Description__c, Quantity__c, Quantity_Override__c FROM SBS_Case_Asset__c 
                    WHERE CaseId__c =: caseId];
        } Catch(Exception ex){
			return null;
		}
        
        //To remove "Scheduled" type components or to include them, within the SOQL script above we should include
        // AND Occurrence__c != 'Scheduled' on line 17 above
        // This will make the Scheduled Occurrence type non-actionable from within the modify price/quantity component.
        // - George Martin - 8/12/2020
    }
    /**
    * @author Accenture
    * @date 6/18/2020
    * @description : Method to udpate CaseAsset from DisplayCaseAsset lightning component
    **/
    @AuraEnabled
   	public static void updateCaseAsset(List<SBS_Case_Asset__c> caseAssetLst){
        
        List<SBS_Case_Asset__c> caUpdateLst = new List<SBS_Case_Asset__c>();
        for(SBS_Case_Asset__c ca: caseAssetLst){
            ca.original_client_price__c = ca.AssetId__r.Price__c;
            ca.Reason_Code__c = ca.Reason_Code__c == 'None'? '':ca.Reason_Code__c;
            caUpdateLst.add(ca);
        }
        try{
            if(caUpdateLst != null && !caUpdateLst.isEmpty()){
                update caUpdateLst;
            }
        } catch(DMLException e){
            string msg = Constant_Util.EMPTY_STRING;
            //Get All DML Messages
            for (Integer i = 0; i < e.getNumDml(); i++) {
                //Get Validation Rule & Trigger Error Messages
                msg =+ e.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }
    }
}