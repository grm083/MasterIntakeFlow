/*************************************************************
@Name: ConfirmServiceCompletionBatch
@Author: Saurav Dwivedi
@CreateDate: 09/09/2019
@Description: Daily Batch to create obtain Confirm service completion task.
**************************************************************/
global class ConfirmServiceCompletionBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private Map<Id, String> errorMap = new Map<Id, String>();
    private Map<Id, SObject> sObjectMap = new Map<Id, SObject>();
    String caseStatus = Constant_Util.CLOSED;

    private static final String QUERY = 'SELECT Id, Status, Case_Sub_Status__c,Supplier__c,work_order__r.Service_Date__c, Is_Case_CSC_Created__c, OwnerId, PurchaseOrder_Number__c, Profile_Number__c, Tech_Asset_ProductFamily__c FROM Case ' 
        +'WHERE status !=:caseStatus AND Case_Sub_Status__c = '+'\''+ 'Pending Service Confirmation' + '\''+' AND Case_Type__c = '+'\''+ 'Pickup' + '\'' +' AND work_order__r.Service_Date__c = YESTERDAY AND Is_Case_CSC_Created__c = false LIMIT 49999';

	/**@MethodName start
	* Method to return the case records for Batch Processing.
	**/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(QUERY);
    }
  
    /*@MethodName execute
    * Method to insert obtain Confirm service completion tasks
    **/
    public void execute(Database.BatchableContext batchVariable, List<Case> caseLst) {
        try {
            List<Task> insertTaskLst = new List<Task>();
            List<Case> updateCaseLst = new List<Case>();
            Integer index = 0;
            
            Generic_Values__mdt genysysUser = [SELECT Id, Id__c 
                                               FROM Generic_Values__mdt 
                                               WHERE Label =: Constant_Util.GENYSYS_USER LIMIT 1];
                                               
            Id businessHoursId = [SELECT Id, FridayEndTime 
                                  FROM BusinessHours 
                                  WHERE Name =: Constant_Util.BUSINESSNAME 
                                  AND IsActive = true 
                                  LIMIT 1].Id;
            
            Long intervalMilliseconds = 
            Long.valueof(String.valueof((Decimal.valueOf(0)*3600000).round(System.RoundingMode.HALF_UP)));

        	DateTime businessHrs = 
            BusinessHours.addGmt(businessHoursId, System.now(), intervalMilliseconds);

            Set<Id> accIdSet = new Set<Id>();
            for(Case c : caseLst) {
            	accIdSet.add(c.Supplier__c);
            }

            Map<Id, List<AccountContactRelation>> accConMap = new Map<Id, List<AccountContactRelation>>();

            List<AccountContactRelation> accConList = new List<AccountContactRelation>();
            accConList = [SELECT Id, AccountId, ContactId, Contact.Email, Contact.Phone, 
                          Contact.Tech_Contact_Account_Title__c, Tech_Contact_Status__c, 
                          Tech_Contact_Created_Date__c, Roles, CreatedDate  
                          FROM AccountContactRelation 
                          WHERE AccountId IN: accIdSet 
                          AND Tech_Contact_Status__c =: Constant_Util.ACTIVE 
                          ORDER BY Tech_Contact_Created_Date__c DESC];

            for(AccountContactRelation accCon : accConList){
				if(String.isNotBlank(accCon.AccountId)){
					if(!accConMap.containsKey(accCon.AccountId)) {
						accConMap.put(accCon.AccountId, new List<AccountContactRelation>());
                   	}
                    accConMap.get(accCon.AccountId).add(accCon);
                }
            }

            Task t = null;
            if(!caseLst.isEmpty()) {
				for(Case c : caseLst) {
					Datetime createdACR;
                    t = new Task();
                    t.ActivityDate = System.today();
                    t.Attempt__c = 1;
                    t.Description__c = Constant_Util.EMPTY_STRING;
                    t.OwnerId = genysysUser.Id__c;
                    t.Process__c = Constant_Util.CONFIRM_SERVICE_COMPLETION;
                    t.Subject = Constant_Util.CONFIRM_SERVICE_COMPLETION;
                    t.PurchaseOrder_Number__c = c.PurchaseOrder_Number__c;
                    t.Profile_Number__c = c.Profile_Number__c;
                    t.WhatId = c.Id;
                    t.Is_Genesys_User__c = true;

                    DateTime closingBusinessTime = 
                    BusinessHours.addGmt(businessHoursId, c.Work_Order__r.Service_Date__c.adddays(1),
                                            intervalMilliseconds);

                    t.Due_Date_Time__c = closingBusinessTime.addHours(14);

                    t.RecordTypeId = Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.FOLLOW_UP_TASK).getRecordTypeId();
                    
                    if(accConMap.containsKey(c.Supplier__c)) {
                        for(AccountContactRelation accCon : accConMap.get(c.Supplier__c)){
                            if(String.isNotBlank(accCon.Roles) &&( createdACR == null || accCon.CreatedDate  > createdACR)) {
                                
                                if((Constant_Util.ROLLOFF.equalsIgnoreCase(c.Tech_Asset_ProductFamily__c) 
                                    && accCon.Roles.Contains(Constant_Util.ROLLOFF_SERVICE_DISPATCH)) 
                                    || (Constant_Util.COMMERCIAL.equalsIgnoreCase(c.Tech_Asset_ProductFamily__c) 
                                        && accCon.Roles.Contains(Constant_Util.COMM_SERVICE_DISPATCH))) {
                                    
                                    t.WhoId = accCon.ContactId;
                                    t.Contact_Email__c = accCon.contact.Email;
                                    t.Contact_Number__c = accCon.contact.phone;
                                    t.Contact_Title__c = accCon.contact.Tech_Contact_Account_Title__c;
                                }
                                
                                else if(((!Constant_Util.ROLLOFF.equalsIgnoreCase(c.Tech_Asset_ProductFamily__c)) 
                                            && ((!Constant_Util.COMMERCIAL.equalsIgnoreCase(c.Tech_Asset_ProductFamily__c)) 
                                            && accCon.Roles.Contains(Constant_Util.DISPATCH)))) {
                                    t.WhoId = accCon.ContactId;
                                    t.Contact_Email__c = accCon.contact.Email;
                                    t.Contact_Number__c = accCon.contact.phone;
                                    t.Contact_Title__c = accCon.contact.Tech_Contact_Account_Title__c;
                                }
                                if(t.WhoId != null){
                                    createdACR = accCon.CreatedDate; 
                                }
                            }
                        }

                        if(t.WhoId == null){
                            for(AccountContactRelation accCon : accConMap.get(c.Supplier__c)){
                                if(String.isNotBlank(accCon.Roles) && (createdACR == null || accCon.CreatedDate  > createdACR)) {

                                    if((Constant_Util.ROLLOFF.equalsIgnoreCase(c.Tech_Asset_ProductFamily__c) 
                                        && accCon.Roles.Contains(Constant_Util.DISPATCH)) 
                                        || (Constant_Util.COMMERCIAL.equalsIgnoreCase(c.Tech_Asset_ProductFamily__c) 
                                        && accCon.Roles.Contains(Constant_Util.DISPATCH))) {

                                            t.WhoId = accCon.ContactId;
                                            t.Contact_Email__c = accCon.contact.Email;
                                            t.Contact_Number__c = accCon.contact.phone;
                                            t.Contact_Title__c = accCon.contact.Tech_Contact_Account_Title__c;
                                    }

                                    if(t.WhoId != null){
                                        createdACR = accCon.CreatedDate; 
                                    }
                                }
                            }
                        }
                    }
                    insertTaskLst.add(t);
				}
			}

			if(insertTaskLst.size() > 0){
				List<Database.SaveResult> dbrs = Database.insert(insertTaskLst, false);
                UTIL_LoggingService.logDmlResults(dbrs,null, insertTaskLst, 
                                                    UTIL_ErrorConstants.ERROR_APPLICATION,
                                                    Constant_Util.CSC_BATCH,
                                                    Constant_Util.EXECUTE,
                                                    Constant_Util.EMPTY_STRING,
                                                    LoggingLevel.ERROR);

				if(dbrs.size() > 0){
					for(Database.SaveResult sr : dbrs){
						if(sr.isSuccess()) {
							case c = new case(Id = insertTaskLst[index].WhatId);
							c.Is_Case_CSC_Created__c = true;
							updateCaseLst.add(c);
						}
						index++;
					}
                    
                    if(updateCaseLst.size() > 0){
                        List<Database.SaveResult> sr = Database.update(updateCaseLst, false);
                        UTIL_LoggingService.logDmlResults(sr,null,updateCaseLst,
                                                            UTIL_ErrorConstants.ERROR_APPLICATION,
                                                            Constant_Util.CSC_BATCH,
                                                            Constant_Util.EXECUTE,
                                                            Constant_Util.EMPTY_STRING,
                                                            LoggingLevel.ERROR);
                    }
                }
            }
        } catch(Exception e) {
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), 
                                                    UTIL_ErrorConstants.ERROR_APPLICATION,
                                                    LoggingLevel.ERROR);
        }
    }

	/*@MethodName finish
	* Method to send the notification email if batch finished with errors
	**/ 
    public void finish(Database.BatchableContext batchVariable) {     
	}

    /* @Method execute
     * Method to schedule the batch
    **/    
    public void execute(SchedulableContext ctx) {
        ConfirmServiceCompletionBatch jobApex = new ConfirmServiceCompletionBatch();
        Database.ExecuteBatch(jobApex);
   }
}