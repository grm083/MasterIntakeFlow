global class GetSLAInformation {
    
     //input details that comes to apex from flow
	 global class FlowInputsForSLA{
        @InvocableVariable
        public string caseId;
        
        @InvocableVariable
        public String casetype;
        
        @InvocableVariable
        public String caseSubtype;
         
        @InvocableVariable
        public String caseReason;
        
        @InvocableVariable
        public String lob;
         
        @InvocableVariable
        public String duration; 
         
        @InvocableVariable
        public String equipmentTypeCode;
    }
    
	@InvocableMethod(label='Get SLA Date Time' description='Returns the list of SLA Date')
	public static List<DateTime> getSLADateTime (List<FlowInputsForSLA> request) {
       Map<Id,Account> casewithLocationMap = new Map<Id,Account>();
       List<Case> newCaseList = New List<Case>();
       List<Case> updatedCaseList = New List<Case>(); 
        
       String caseId = request[0].caseId;
       String caseReason  = request[0].caseReason;
       String Case_type = request[0].casetype;
       String case_Subtype = request[0].caseSubtype;
       String Duration 	 =request[0].caseSubtype;
       String EquipmentTypeCode = request[0].equipmentTypeCode;
       String lob = request[0].lob;
   	   List<Case> caseList =[SELECT Id,AccountId, Location__c, Equipment_Type_Code__c,Case_Type__c, Case_Sub_Type__c, Case_Reason__c,AssetId, SalesMeet_Duration__c,Status, Client__c,SlaStartDate,LOB__c FROM Case WHERE Id  =: caseId];
        
        	    Case objCase = null;
                objCase = new Case();
        		objCase.Id = caseId;
        		objCase.Status 			= caseList[0].Status;
				objCase.Location__c 	= caseList[0].Location__c;
                objCase.Client__c 		= caseList[0].Client__c;
				objCase.Case_Type__c 	= Case_type;
        		objCase.Case_Reason__c 	= caseReason;
                objCase.Case_Sub_Type__c= case_Subtype;
                objCase.LOB__c 			= lob;
        		objCase.Equipment_Type_Code__c = EquipmentTypeCode;
                
                newCaseList.add(objCase);
        Set<id> locationIdSet = new Set<id>();
    	//Business Hours Calculation for SLA
     for(BusinessHours b: [select id,TimeZoneSidKey from BusinessHours LIMIT 39999]){
                CaseTriggerHelper.businessIdMap.put(b.TimeZoneSidKey,b.Id);
            }  
     for(Case caseRecord : newCaseList){
    	  	  	if(String.isNotBlank(caseRecord.Location__c)
	    	  	  && String.isNotBlank(caseRecord.Case_Sub_Type__c) 
	    	  	  && String.isNotBlank(caseRecord.Status)  && Constant_Util.STATUS_NEW.equals(caseRecord.Status)  
	              && (String.isNotBlank(caseRecord.Client__c)) && sla_calculation__c.getValues(caseRecord.Case_type__c) != null  
	              && sla_calculation__c.getValues(caseRecord.Case_type__c).Enabled__c) {
              		
              		locationIdSet.add(caseRecord.Location__c); 
	            }
    	  }
     if(!locationIdSet.isEmpty()){
                casewithLocationMap = CaseTriggerHandler.getLocationRecordValue(locationIdSet);
          		CaseTriggerHelper.casewithLocation.putAll(casewithLocationMap);
          }
        
     updatedCaseList = CaseTriggerHelper.getServiceDate(newCaseList);
     List<DateTime> SLADates = new List<DateTime>();
        for (Case c :updatedCaseList){
            SLADates.add(c.SLA_Service_Date_Time__c);
        }  
	 return SLADates;    
  	}  
}