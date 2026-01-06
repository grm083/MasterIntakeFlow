public class EntitlementTriggerHelper {
    
    public static void validateNewSeviceEntitlement(List<Entitlement> triggerNew){
        for(Entitlement En :triggerNew){
            if(En.Request_Type__c == 'New Service' && En.Project_Code__c == null && En.service__c != En.Schedule_Type__c){
                En.Type.adderror('For New Service entitlements, the selected Schedule Type must match the selected Service');
            }
        }
    }

     //added as part of SDT-42452
    public static void validateOverrideCheckbox(List<Entitlement> triggerNew) {
        for(Entitlement en : triggerNew) {
            try {
                if(en.Service_Guarantee_Category__c == 'Hours' && en.Override_Business_Hours__c) {
                    en.addError('Business hours are not considered when Service Guarantee is in hours. Please uncheck the Override Business hours checkbox.');
                }
            }
            catch(Exception e) {
                System.debug('msg >> ' + e.getMessage());
            }
        }
    }
}