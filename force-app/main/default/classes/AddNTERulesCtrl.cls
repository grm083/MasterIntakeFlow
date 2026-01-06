/**
 * @description       : Add NTE Rules
 * @author            : Arvind Kumar
 * @Created Date  : 11-02-2023
**/

public class AddNTERulesCtrl {
    
    @AuraEnabled
    public static void saveNTERulesData(String nTERulesData){
        NTERulesDataWrapper wrapper = (NTERulesDataWrapper) JSON.deserialize(nTERulesData ,  NTERulesDataWrapper.class);
        Id rtId = Schema.SObjectType.Service_Approver__c.getRecordTypeInfosByDeveloperName().get('NTE_Approval').getRecordTypeId();
        List<Service_Approver__c> newSAList = new List<Service_Approver__c>();
        Service_Approver__c newSA = new Service_Approver__c();
        newSA.Service_Type__c = wrapper.serviceType;
        newSA.RecordTypeId = rtId;
        newSA.Business_Rule__c = wrapper.businessRuleId;
        newSA.NTE_Rule_ExtId__c = wrapper.serviceType + '-'+wrapper.businessRuleId;
        newSA.NTE_Amount__c = wrapper.nteAmount;
        newSA.Account__c = wrapper.accountId;
        newSA.Location__c = wrapper.locationId;
        newSA.Active__c = True;
        newSAList.add(newSA);
        try {
            if(!newSAList.isEmpty()){
        		upsert newSAList NTE_Rule_ExtId__c;
            }
        } catch (DmlException e) {
            //SDT-31225
        	System.debug('DML Error : ' + e.getMessage());
            string errorMsg = e.getMessage(); 
            string pureErrorMsg = errorMsg.substringAfter('_EXCEPTION,');
            pureErrorMsg = pureErrorMsg.Substring(0,(pureErrorMsg.length()-4)); 
            throw new AuraHandledException(pureErrorMsg);
    	}
    }
    
    public class NTERulesDataWrapper{
        @AuraEnabled
        public String businessRuleId {set; get;}
        @AuraEnabled
        public String serviceType {set; get;}
        @AuraEnabled
        public Decimal nteAmount {set; get;}
        @AuraEnabled
        public String accountId {set; get;}
        @AuraEnabled
        public String locationId {set; get;}
    }

}