public without sharing class CaseDetailCardController {
    public static final String ORIGIN_STRING ='Origin';
    @AuraEnabled
    public static Case getCaseDetails(String caseId){
        String case_status = Constant_Util.STATUS_NEW;
        //format added in the query at 2 places as part of SDT 31280
        Case currentCase = Database.query('select id,CaseNumber,Status,RecordTypeId,Source_System__c,Last_Agent_ID__c,Origin,LastModifiedBy.Name,CreatedBy.Name,Owner.Name,format(CreatedDate) createdDt,format(LastModifiedDate) modifiedDt from case where id = :caseId limit 1'); 
        return currentCase;
    }
    
   @AuraEnabled
    public static string callinvoke(String caseId , string originField){
        String status = null;
// Modified for SDT-33446 Start
        try {
        Case currentCase = Database.query('select id,Source_System__c,Origin,LastModifiedBy.Name,CreatedBy.Name,Owner.Name,CreatedDate from case where id = :caseId limit 1');
        
        if(originField !=''){
          currentCase.Origin=originField;
        }else{
          currentCase.Origin='External System';
        }
      
if(currentCase != null) {
        update currentCase;
}
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
        }
        // Modified for SDT-33446 End        
        status = Constant_Util.SUCCESS;
        return status;
    }
    @AuraEnabled
   public static List < String > getselectOptions(String caseId) {
    string recordTypeId = [Select recordTypeId from Case where Id =: caseId].recordTypeId;
    //return DependentPickListValueController.getOriginBasedonRecordType(Constant_Util.KEYWORD_CASE,ORIGIN_STRING,recordTypeId);
    // Changes for SDT-38437	
    return DependentPickListValueController.getPicklistValues(recordTypeId);
   }
 
}