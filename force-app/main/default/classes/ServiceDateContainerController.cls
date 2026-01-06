public with sharing class ServiceDateContainerController {
   
     /* Author- WM
	* Date- 04/30/2020
	* Description- method to get wm capacity planner visibility
	*/
	@AuraEnabled
    public static Boolean IsWMCapacityPlannerVisible(string caseRecId){
        boolean isGoldStdCheck = true;
        List<Case> cse= [SELECT id ,Client__c FROM CASE WHERE id =: caseRecId 
             		 AND Case_Type__c=: Constant_Util.PICKUP_CSTYPE AND Asset.Supplier__r.Parent_Vendor_ID__c='8' AND  Status=: Constant_Util.Case_New_Status AND Availability_Checked__c=false 
                     AND (Location_Code__c != null OR Location_Code__c !='') AND Asset.Product2.Family=: Constant_Util.ROLLOFF AND (SLA_Service_DateTime__c != null OR SLA_Service_DateTime__c !='') AND (Client__r.Name != null OR Client__r.Name !='')
                      LIMIT 1 ];
        if(cse != null && !cse.isEmpty()){
             List<Entitlement> entList = new List<Entitlement>(); 
	     entList = [SELECT id,Gold_Standard__c,AccountId, Contractual__c from Entitlement where AccountId =: cse[0].Client__c AND Status__c = 'Approved'];
        if(entList.size()>0){
            for(Entitlement ent : entList){
                if(ent.Gold_Standard__c || ent.Contractual__c){
                    isGoldStdCheck = false;
                    break;
                }
            }
            return isGoldStdCheck;
        }else{
            return true;
        }
            
        }
        return false;
    }   
    
    /* Author- WM
	* Date- 04/30/2020
	* Description- method to get mutlti date visibility
	*/
    @AuraEnabled
     public static GetCaseInformation.Wrapper IsMultiVisible(string caseRecId){
         string caseInfo='';
         GetCaseInformation.Wrapper wc= GetCaseInformation.getCaseMessages(caseRecId);
         caseInfo=wc.caseInfo;
         return wc;
     }
}
