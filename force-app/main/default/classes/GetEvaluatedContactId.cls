/**************************************************
* ClassName:GetEvaluatedContactId
* Author:WM
* CreatedDate:05/07/2019
* Updated by : Anup Dey
* Updated Date: 18/11/2021
* Updated Comment: Converting method to bulky method to handle flow error
* **************************************************/
global class GetEvaluatedContactId {
    private static final string STR_ACTIVE = 'Active';
    private static final string STR_ROLLOFF = 'Rolloff';
    private static final string STR_SECOND_ESC_ROLLOFF = '2nd Dispatch Escalation-Rolloff';
    private static final string STR_FIRST_ESC_ROLLOFF = '1st Dispatch Escalation-Rolloff';
    private static final string STR_DISPATCH_ROLLOFF = 'Dispatch - Rolloff';
    private static final string STR_COMMERCIAL = 'Commercial';
    private static final string STR_SECOND_ESC_COMMERCIAL = '2nd Dispatch Escalation-Commercial';
    private static final string STR_FIRST_ESC_COMMERCIAL = '1st Dispatch Escalation-Commercial';
    private static final string STR_DISPATCH_COMMERCIAL = 'Dispatch - Commercial';
    private static final string STR_DISPATCH = 'Dispatch';
    
    
    //input details that comes to apex from flow
	 global class FlowInputsForContactId{
        @InvocableVariable
        public String numberOfAttempt;
        
        @InvocableVariable
        public String accountId;
         
        @InvocableVariable
        public String productFamily;
    }
	
	@InvocableMethod(label='GetEvaluatedContactId' description='Returns the list of evaluated contact id')
    public static List<String> getEvaluatedContactIdByRoles(List<FlowInputsForContactId> request) {
	
		List<String> results= new List<String>();
		try
		{
			Set<Id> accountIds = new Set<Id>();
			// get Unique Account Ids from request
			if(!request.isEmpty())
			{
				accountIds = getListOfAccountsFromRequest(request);
			}
			
			//system.debug('*****accountIds'+ accountIds);
			
			// get all AccountContact which are active status based on Account Ids
			List<AccountContactRelation> acrList = [SELECT Id, Tech_Contact_Status__c, Tech_Contact_Created_Date__c,
														AccountId, ContactId, Roles FROM AccountContactRelation
														WHERE Tech_Contact_Status__c =: STR_ACTIVE AND AccountId IN: accountIds ORDER BY Tech_Contact_Created_Date__c DESC];
			
			//system.debug('*****acrList'+ acrList.size());
			
			if(!acrList.isEmpty() && acrList.size() > 0)
			{
				// Looping Over all requests to get the respective contact Id
				for(FlowInputsForContactId flowInputsForContactId : request){
					
					//system.debug('*****flowInputsForContactId'+ flowInputsForContactId);
					List<AccountContactRelation> accContactList = getAccountRelationForParticularRequest(flowInputsForContactId, acrList);
					//system.debug('*****accContactList'+ accContactList);
					List<FlowInputsForContactId> singleRequest = new List<FlowInputsForContactId>();
					singleRequest.add(flowInputsForContactId);
					String singleRequestResponse = getEvaluatedContactIdByRoles(singleRequest,accContactList);
					//system.debug('*****singleRequestResponse'+ singleRequestResponse);
					results.add(singleRequestResponse);
				}
			}
			else{
				// Case when none of AccountId has any AccountContactRelation 
				for(FlowInputsForContactId idValue : request){
					results.add(Null);
				}
			}
			//system.debug('*****final results'+ results);
		}
		catch(Exception ex){
			 system.debug('>>>Exception-->error in GetEvaluatedContactId: getEvaluatedContactIdByRoles: ' + ex.getMessage());
             UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(),UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
			 //this logic will handle specific case when none of the request is processed
			 if(request.size() != results.size())
			 {
				 Integer notProcessedRecords =request.size() - results.size();
				 system.debug('>>>notProcessedRecords '+ notProcessedRecords);
				 for(Integer i=0; i < notProcessedRecords; i++) {
					results.add(Null);
				 }
			 }
		}
		return results;	
	}
	
	//method to process the single request to get the contact Id
	public static String getEvaluatedContactIdByRoles (List<FlowInputsForContactId> request, List<AccountContactRelation> acrList) {
		try{
			
			String evaluatedContactId = '';
			Map<String,String> getContactIdByRoles = new Map<String,String>();
			if(acrList != Null && !acrList.isEmpty()){
				for(AccountContactRelation acr : acrList){
					// populating the Contact Id and Product Family Map
					getContactIdByRoles.putAll(getContactIdMapByRoles(acr,request));
				}
				
				if(!getContactIdByRoles.isEmpty()){
					// get the contact Id from Contact Role Map
					evaluatedContactId= getContactId(getContactIdByRoles,request);
					return evaluatedContactId;
				}
            }
        } 
		catch(Exception e){ 
			System.debug('>>>Exception-->'+e.getMessage()+'At Line Number-->'+e.getLineNumber());
		}
		return Null;      
	}
	
	// method to get account Contact Relationship based on AccountId
	private static List<AccountContactRelation> getAccountRelationForParticularRequest(FlowInputsForContactId request, List<AccountContactRelation> acrList){
		List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
		
		for(AccountContactRelation acr: acrList)
		{
			if(!string.isEmpty(request.accountId) && !string.isEmpty(acr.AccountId))
			{
				if(acr.AccountId == request.accountId)
				{
					accountContactRelations.add(acr);
				}
			}
		}
		
		return accountContactRelations;
	}

	// method to get the AccountIds based on Coming request
	private static Set<Id> getListOfAccountsFromRequest(List<FlowInputsForContactId> request){
		Set<Id> accountIds = new Set<Id>();
		for(FlowInputsForContactId flowContact: request)
		{
			if(!string.isEmpty(flowContact.accountId))
				accountIds.add(flowContact.accountId);
		}
		return accountIds;
	}
	
	// method to get the Product and Contact Key Map 
	private static Map<String,String> getContactIdMapByRoles(AccountContactRelation acr, List<FlowInputsForContactId> request){
		Map<String,String> contactIdMapByRoles = new Map<String,String>();
		
		if(acr.Roles != Null){
			// Rolloff
			//2nd Dispatch Escalation-Rolloff
			if(STR_ROLLOFF.equalsIgnoreCase(request[0].productFamily) && acr.Roles.contains(STR_SECOND_ESC_ROLLOFF)){
			
				if(!contactIdMapByRoles.containsKey(STR_SECOND_ESC_ROLLOFF)){
					contactIdMapByRoles.put(STR_SECOND_ESC_ROLLOFF,String.valueOf(acr.ContactId));
					
				}
			}
			 
			//1st Dispatch Escalation-Rolloff
			if(STR_ROLLOFF.equalsIgnoreCase(request[0].productFamily) && acr.Roles.contains(STR_FIRST_ESC_ROLLOFF)){
				if(!contactIdMapByRoles.containsKey(STR_FIRST_ESC_ROLLOFF)){
					contactIdMapByRoles.put(STR_FIRST_ESC_ROLLOFF,String.valueOf(acr.ContactId));	
					
				}
			}
			
			//Dispatch - Rolloff
			if(STR_ROLLOFF.equalsIgnoreCase(request[0].productFamily) && acr.Roles.contains(STR_DISPATCH_ROLLOFF)){
				if(!contactIdMapByRoles.containsKey(STR_DISPATCH_ROLLOFF)){
					contactIdMapByRoles.put(STR_DISPATCH_ROLLOFF,String.valueOf(acr.ContactId));
					
				}
			}
			
			//Commercial 
			//2nd Dispatch Escalation-Commercial
			if(STR_COMMERCIAL.equalsIgnoreCase(request[0].productFamily) && acr.Roles.contains(STR_SECOND_ESC_COMMERCIAL)){
				if(!contactIdMapByRoles.containsKey(STR_SECOND_ESC_COMMERCIAL)){
					contactIdMapByRoles.put(STR_SECOND_ESC_COMMERCIAL,String.valueOf(acr.ContactId));
					
				}   
			}
			
			//1st Dispatch Escalation-Commercial
			if(STR_COMMERCIAL.equalsIgnoreCase(request[0].productFamily) && acr.Roles.contains(STR_FIRST_ESC_COMMERCIAL)){
				if(!contactIdMapByRoles.containsKey(STR_FIRST_ESC_COMMERCIAL)){
					contactIdMapByRoles.put(STR_FIRST_ESC_COMMERCIAL,String.valueOf(acr.ContactId));
					
				}
			}
			
			//Dispatch - Commercial
			if(STR_COMMERCIAL.equalsIgnoreCase(request[0].productFamily) && acr.Roles.contains(STR_DISPATCH_COMMERCIAL)){
				if(!contactIdMapByRoles.containsKey(STR_DISPATCH_COMMERCIAL)){
					contactIdMapByRoles.put(STR_DISPATCH_COMMERCIAL,String.valueOf(acr.ContactId));
					
				}
			} 
			
			Boolean isDispatch = false;
			 
			//System.debug('>>>acr.Roles.contains'+acr.Roles.contains(';'));
			if(acr.Roles.contains(';')){
				String[] rolesStr = acr.Roles.split(';');
				
				for(String s : rolesStr){
					  
					if(s == STR_DISPATCH){
						isDispatch = true;
					}
				}
			}
			else{
				if(acr.Roles == STR_DISPATCH){
					isDispatch = true;
				}
			}
			
			//Dispatch
			if(acr.Roles.contains(STR_DISPATCH) && isDispatch){
				if(!contactIdMapByRoles.containsKey(STR_DISPATCH)){
					contactIdMapByRoles.put(STR_DISPATCH,String.valueOf(acr.ContactId));
					
				}  
			}
		} 
		return contactIdMapByRoles;
	}

	// get Contact Id from ContactRole Map and coming request
	private static String getContactId(Map<String,String> getContactIdByRoles, List<FlowInputsForContactId> request){
		String evaluatedContactId = '';
		//Rolloff
		//Dispatch - Rolloff
		if(request[0].numberOfAttempt == '1'){
			if(getContactIdByRoles.containsKey(STR_DISPATCH_ROLLOFF)){
				
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH_ROLLOFF);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH) && String.isBlank(evaluatedContactId)){
				
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH);
			}
		}	 
		
		//1st Dispatch Escalation-Rolloff
		if(request[0].numberOfAttempt == '2'){
			if(getContactIdByRoles.containsKey(STR_FIRST_ESC_ROLLOFF)){
				evaluatedContactId = getContactIdByRoles.get(STR_FIRST_ESC_ROLLOFF);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH_ROLLOFF) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH_ROLLOFF);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH);
			}
		}
		
		//2nd Dispatch Escalation-Rolloff
		if(request[0].numberOfAttempt == '3' || request[0].numberOfAttempt == '4'){
			if(getContactIdByRoles.containsKey(STR_SECOND_ESC_ROLLOFF)){
				evaluatedContactId = getContactIdByRoles.get(STR_SECOND_ESC_ROLLOFF);
			}
			else if(getContactIdByRoles.containsKey(STR_FIRST_ESC_ROLLOFF) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_FIRST_ESC_ROLLOFF);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH_ROLLOFF) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH_ROLLOFF);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH);
			}
		}
		
		//Commercial
		//Dispatch - Commercial
		if(request[0].numberOfAttempt == '1'){
			if(getContactIdByRoles.containsKey(STR_DISPATCH_COMMERCIAL)){
				
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH_COMMERCIAL);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH) && String.isBlank(evaluatedContactId)){
				
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH);
			}
		}	
		
		//1st Dispatch Escalation-Commercial
		if(request[0].numberOfAttempt == '2'){
			if(getContactIdByRoles.containsKey(STR_FIRST_ESC_COMMERCIAL)){
				evaluatedContactId = getContactIdByRoles.get(STR_FIRST_ESC_COMMERCIAL);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH_COMMERCIAL) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH_COMMERCIAL);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH);
			}
		}
		
		//2nd Dispatch Escalation-Commercial
		if(request[0].numberOfAttempt == '3' || request[0].numberOfAttempt == '4'){
			if(getContactIdByRoles.containsKey(STR_SECOND_ESC_COMMERCIAL)){
				evaluatedContactId = getContactIdByRoles.get(STR_SECOND_ESC_COMMERCIAL);
			}
			else if(getContactIdByRoles.containsKey(STR_FIRST_ESC_COMMERCIAL) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_FIRST_ESC_COMMERCIAL);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH_COMMERCIAL) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH_COMMERCIAL);
			}
			else if(getContactIdByRoles.containsKey(STR_DISPATCH) && String.isBlank(evaluatedContactId)){
				evaluatedContactId = getContactIdByRoles.get(STR_DISPATCH);
			}
		}
		
		  if(evaluatedContactId == ''){
			evaluatedContactId = Null;
			  
			}
		//system.debug('*****response'+ evaluatedContactId);
		//return new List<String>{evaluatedContactId}; 
		return evaluatedContactId; 
	}
}