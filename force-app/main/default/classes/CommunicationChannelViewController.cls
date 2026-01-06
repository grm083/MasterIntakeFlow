public without sharing class CommunicationChannelViewController {
    
    public static final string BLANKSTR = '';
    public static final string CASESTARTID = '500';
    public static final string WORK_ORDER_START_ID = '0WO';
    public static final string UNDEFINED = 'undefined';
    
    @AuraEnabled(cacheable=true)
    public static ComTableResponse communicationData(String vendorRecordId)
    {
        System.debug('@@recid'+vendorRecordId);
        Set<String> lstComFun = new Set<String>();
        Set<String> lstComTypeData = new Set<String>();
        Map<String,String> comChannelMap = new Map<String,String>();
        Map<String,String> comChannelNotesMap = new Map<String,String>();
        String accountId = BLANKSTR;
        
        if(vendorRecordId != null && vendorRecordId != BLANKSTR && vendorRecordId != UNDEFINED){
        if(vendorRecordId.startsWith(CASESTARTID)){
                    List<case> caseList = new List<case>();
                    caseList = [Select Id,AccountId,Supplier__c,Client__c,Location__c from Case where Id=:vendorRecordId limit 1];
                    if(caseList != null && !caseList.isEmpty()){
                        for(case caseRec : caseList){
                            if(caseRec.Supplier__c != null){
                                accountId = caseRec.Supplier__c;
                            }
                        }
                    }
                } else  if(vendorRecordId.startsWith(WORK_ORDER_START_ID)){
                    List<WorkOrder> woList = new List<WorkOrder>();
                    woList = [Select Id, Vendor_Account_Id__c from WorkOrder where Id=:vendorRecordId limit 1];
                    if(!woList.isEmpty() && woList[0].Vendor_Account_Id__c != null){
                        accountId = woList[0].Vendor_Account_Id__c;
                    }
                }
                else{
                    accountId = vendorRecordId;
                }
        }
        for(Communication_Channel__c com : [SELECT id,toLabel(Channel_Function__c), toLabel(Channel_Type__c), Channel_Value__c,Notes__c from Communication_Channel__c where AccountId__c =: accountId and isActive__c = true])
        {
            if(com.Channel_Function__c != null)
            {
               lstComFun.add('Comm');
               lstComFun.add(com.Channel_Function__c); 
            }
            if(com.Channel_Type__c != null)
            {
               lstComTypeData.add(com.Channel_Type__c); 
            }
            if(com.Channel_Function__c!= null && com.Channel_Type__c != null)
            {
                comChannelMap.put(com.Channel_Function__c+'-'+com.Channel_Type__c,com.Channel_Value__c);
            }
            if(com.Channel_Function__c!= null && com.Channel_Type__c != null)
            {
                comChannelNotesMap.put(com.Channel_Function__c+'-'+com.Channel_Type__c,com.Notes__c);
            }
        }
        ComTableResponse finalComData = new ComTableResponse();
        finalComData.lstComFunction = lstComFun;
        finalComData.lstComType = lstComTypeData;
        finalComData.comDataMap = comChannelMap;
        finalComData.comDataNotesMap = comChannelNotesMap;
        return finalComData;
    }
    
    public class ComTableResponse {
        @AuraEnabled
        public Set<String> lstComFunction {get;set;}
        @AuraEnabled
        public Set<String> lstComType {get;set;}
        @AuraEnabled
        public Map<String,String> comDataMap {get;set;}
        @AuraEnabled
        public Map<String,String> comDataNotesMap {get;set;}
    }
}