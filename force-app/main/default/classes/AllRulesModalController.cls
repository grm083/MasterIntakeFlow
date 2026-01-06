/**
 * @description       : 
 * @author            : Adil Aleem
 * @group             : 
 * @last modified on  : 09-19-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class AllRulesModalController {

    public static final String NONE = 'None';
    public static final String NO_APPROVAL_REQUIRED = 'No Approval Required';
    public static final string Haul_Away_Service = 'Haul Away - New Service Case';

    @AuraEnabled(cacheable=true)
    public static List<CaseRecordTypeWrapper> fetchAllBusinessRules(String locationId){
        List<CaseRecordTypeWrapper> wrapperList = new List<CaseRecordTypeWrapper>();
        String source;
        Id businessNotificationRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
        Id approvalRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        String parentAccountId;
        List<Business_Rule__c> brList = CaseRulesModalCtrl.getBrRecordsByLocation(locationId);

        Map<String , List<String>> brMap = new Map<String , List<String>>();
        Set<String> approvalBRSet = new Set<String>();
        for(Business_Rule__c br : brList){
            //SDT-30949 - removing business notification condition
            if(!br.Approver_Entities__r.isEmpty() && br.RecordTypeId == approvalRecordTypeId)
                {
                String caseReason  = ( br.Case_Reason__c == null ||  br.Case_Reason__c == '') ? NONE :  br.Case_Reason__c;
                String key = br.Request_Type__c + '~' + br.Service__c + '~' + caseReason;

                //modified as part of SDT-46918 to seperate out Haul Away New Service rules from the New Service rules
                //and add it as a new key in the brMap
                if(br.Container__c != null && br.Container__c.equalsIgnoreCase(Constant_Util.Haul_Away_Service)) {
                    key = key + '~' + br.Container__c;
                }
                
                if(!brMap.containsKey(key)){
                    brMap.put(key , new List<String>{br.id});
                } else {
                    brMap.get(key).add(br.id);
                }
                if(br.RecordTypeId == approvalRecordTypeId){
                    approvalBRSet.add(key);
                }
            }    
        }

        List<CaseTypeByRecordType__mdt> caseTypesList = [Select Id, MasterLabel, CaseTypes__c, Order__c from CaseTypeByRecordType__mdt order by Order__c]; 
        Map<String, List<String>> caseTypeToCaseSubType = FieldDescribeUtil.getDependentPicklistValues(Business_Rule__c.Service__c);
        Map<String, List<String>> caseSubTypeTypeToCaseReason = FieldDescribeUtil.getDependentPicklistValues(Business_Rule__c.Case_Reason__c);

        for(CaseTypeByRecordType__mdt c : caseTypesList){
            CaseRecordTypeWrapper wrapper = new CaseRecordTypeWrapper();
            wrapper.caseRecordType = c.MasterLabel;
            wrapper.approvalNeeded = false;
            wrapper.caseTypes = new  List<CaseTypeWrapper>();
            List<String> caseTypeList = new List<String>();

            //added as part of SDT-46918 
            Boolean isHaulAwayService = false;

            //added as part of SDT-46918 - workaround for the issue of modification of CaseTypes__c field for haul away metadata record
            if(c.MasterLabel.equalsIgnoreCase(Constant_Util.Haul_Away_Service)) {
                isHaulAwayService = true;
                caseTypeList.add(Constant_Util.NEW_SERVICE);
            }
            //modified as part of SDT-46918
            else {
                isHaulAwayService = false;
                caseTypeList = c.CaseTypes__c != null ? c.CaseTypes__c.split(',') : null;
            }

            for(String ct :  caseTypeList) {
                CaseTypeWrapper ctWrapper = new CaseTypeWrapper();
                ctWrapper.caseType = ct;
                ctWrapper.caseSubTypes = new  List<CaseSubTypeWrapper>();
                List<String> caseSubTypeList = caseTypeToCaseSubType != null && caseTypeToCaseSubType.containsKey(ct) 
                                               ? caseTypeToCaseSubType.get(ct)  : null;
                //Sprint 11 - Test class error fix
                if(caseSubTypeList != null){ 
                for(String cst :  caseSubTypeList) {
                    CaseSubTypeWrapper cstWrapper = new CaseSubTypeWrapper();
                    cstWrapper.caseSubType = cst;
                    cstWrapper.caseReasons = new  List<CaseReasonWrapper>();
                    List<String> caseReasonList = caseSubTypeTypeToCaseReason != null && caseSubTypeTypeToCaseReason.containsKey(cst) 
                                                   ? caseSubTypeTypeToCaseReason.get(cst)  : null;

                    if(caseReasonList != null) {
                        for(String cr : caseReasonList) {
                            Integer count = 0;

                            //added as part of SDT-46918 - check and additional logic needed for haul away rules with case reason
                            if(brMap.containsKey(ct + '~' + cst + '~' + cr + '~' + Constant_Util.Haul_Away_Service) && isHaulAwayService) {
                                count = brMap.get(ct + '~'  + cst + '~' + cr + '~' + Constant_Util.Haul_Away_Service).size();
                            }
                            //modified as part SDT-46918
                            else if(brMap.containsKey(ct + '~' + cst + '~' + cr) && !isHaulAwayService) {
                                count = brMap.get(ct + '~'  + cst + '~' + cr).size();
                            }
                            if(count >0 ){
                                String csReasonStr = ct + ' - '  +  cst + ' - ' + cr + '(' + count + ')';
                                CaseReasonWrapper crWrapper = new CaseReasonWrapper();
                                crWrapper.caseTypeSubTypeReasonStr = csReasonStr;
                                crWrapper.caseReason = cr;
                                crWrapper.isHaulAwayContainer = isHaulAwayService;//SDT-46918
                                cstWrapper.caseReasons.add(crWrapper);
                                wrapper.approvalNeeded = true;
                            }        
                        }
                    }
                    Integer noneCount = 0;

                    //added as part of SDT-46918 - check and additional logic needed for haul away rules without case reason
                    if(brMap.containsKey(ct + '~' + cst + '~' + NONE + '~' + Constant_Util.Haul_Away_Service) && isHaulAwayService) {
                        noneCount = brMap.get(ct + '~'  + cst + '~' + NONE + '~' + Constant_Util.Haul_Away_Service).size();
                    }
                    //modifed as part of SDT-46918
                    else if(brMap.containsKey(ct + '~' + cst + '~' + NONE) && !isHaulAwayService){
                        noneCount = brMap.get(ct + '~'  + cst + '~' + NONE).size();
                    }
                    if(noneCount > 0) {
                        String caseTypeSubTypeReasonStr = ct + ' - '  +  cst + '(' + noneCount + ')';
                        CaseReasonWrapper crWrapper = new CaseReasonWrapper();
                        crWrapper.caseTypeSubTypeReasonStr = caseTypeSubTypeReasonStr;
                        crWrapper.caseReason = '';
                        crWrapper.isHaulAwayContainer = isHaulAwayService;//SDT-46918
                        cstWrapper.caseReasons.add(crWrapper);
                        wrapper.approvalNeeded = true;
                    } 
                    ctWrapper.caseSubTypes.add(cstWrapper);
                }
                }     
                wrapper.caseTypes.add(ctWrapper);
            }
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }

    public class CaseReasonWrapper{
        @AuraEnabled
        public String caseReason{get; set;} 
        @AuraEnabled
        public String caseTypeSubTypeReasonStr{get; set;}
        @AuraEnabled
        public Boolean isHaulAwayContainer{get; set;}//SDT-46918
    }

    public class CaseSubTypeWrapper{
        @AuraEnabled
        public List<CaseReasonWrapper> caseReasons{get; set;} 
        @AuraEnabled
        public String caseSubType{get; set;}
    }

    public class CaseTypeWrapper{
        @AuraEnabled
        public List<CaseSubTypeWrapper> caseSubTypes{get; set;} 
        @AuraEnabled
        public String caseType{get; set;}
    }

    public class CaseRecordTypeWrapper{
        @AuraEnabled
        public List<CaseTypeWrapper> caseTypes{get; set;} 
        @AuraEnabled
        public Boolean approvalNeeded{get; set;}    
        @AuraEnabled
        public String caseRecordType{get; set;}
    }

}