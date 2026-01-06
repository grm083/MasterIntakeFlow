/*************************************************************
@Name: AttemptTasksCreation
@Author: Kalaiselvi R
@CreateDate: 05/09/2019
@Description: Daily Batch to create obtain schedule confirmation task.
**************************************************************/
global class AttemptTasksCreationBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    private Map<Id, String> errorMap = new Map<Id, String>();
    Datetime currentDateTime = System.now();
    private Map<Id, SObject> sObjectMap = new Map<Id, SObject>();
    private String processName = Constant_Util.Obtain_Schedule_Confirmation;
    private String processCSC = Constant_Util.CONFIRM_SERVICE_COMPLETION;
    private String outcome = Constant_Util.NO_OR_PENDING_RESPONSE;
    
    private static final String QUERY = 'SELECT Id, WhatId, Status, OwnerId, Profile_Number__c,PurchaseOrder_Number__c, ' 
        +'Process__c, Attempt__c, Next_Attempt_Date_Time__c, Is_Attempt_Created__c, Due_Date_Time__c, Subject, WhoId, '
        +'Contact_Email__c, Contact_Number__c, Contact_Title__c FROM Task WHERE ((Process__c =: processName AND '
        +'Next_Attempt_Date_Time__c <=: currentDateTime AND Outcome__c =: outcome AND Attempt__c <= 2 AND ' 
        +'Is_Attempt_Created__c = false) OR (Process__c =: processCSC AND Next_Attempt_Date_Time__c <=: currentDateTime ' 
        +'AND Outcome__c =: outcome AND Attempt__c <= 3 AND Is_Attempt_Created__c = false)) LIMIT 49999';
	
	/**@MethodName start
	* Method to return the case records for Batch Processing.
	**/        
    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(QUERY);
    }
  
  /*@MethodName execute
  * Method to insert obtain schedule confirmation tasks
  **/
    public void execute(Database.BatchableContext batchVariable, List<Task> taskLst) {
        try {
			List<Task> insertTaskLst = new List<Task>();
			Set<Id> caseIds = new Set<Id>();
            Set<Id> accIdSet = new Set<Id>();
			Map<Id, Case> caseMap = new Map<Id, Case>();
            Map<Id, AccountContactRelation> accConMap = new Map<Id, AccountContactRelation>();
            if(!taskLst.isEmpty()) {
				for(Task tsk : taskLst) {
					caseIds.add(tsk.WhatId);
				}
				 for(Case cse : [SELECT Id, Status, work_order__r.Service_Date__c, 
                                 Case_Sub_Status__c, Location__c 
                                 FROM Case 
                  				 WHERE Id IN: caseIds]){
                    caseMap.put(cse.Id, cse);
					accIdSet.add(cse.Location__c);
                 }
			}
            for(AccountContactRelation accCon : [SELECT Id, AccountId, ContactId, contact.Email, 
                                                 contact.phone, contact.Tech_Contact_Account_Title__c,  
                                                 Tech_Contact_Status__c, Tech_Contact_Created_Date__c, Roles
                                                 FROM AccountContactRelation 
                                                 WHERE AccountId IN: accIdSet 
                                                 AND Tech_Contact_Status__c =: Constant_Util.ACTIVE 
                                                 ORDER BY Tech_Contact_Created_Date__c DESC]) {
				accConMap.put(accCon.AccountId, accCon);                                          
			}
            Generic_Values__mdt genysysUser = [SELECT Id,Id__c 
                                               FROM Generic_Values__mdt 
                                               WHERE Label =: Constant_Util.GENYSYS_USER 
                                               LIMIT 1];

        	Id businessHoursId = [SELECT Id, FridayEndTime 
                                  FROM BusinessHours 
                                  WHERE Name =: Constant_Util.BUSINESSNAME 
                                  AND IsActive = true 
                                  LIMIT 1].Id;

            Long intervalMilliseconds = 
            Long.valueof(string.valueof((decimal.valueOf(0)*3600000).round(System.RoundingMode.HALF_UP))); 
			
            if(!taskLst.isEmpty()) {
				for(Task tsk : taskLst) {
					case cse = caseMap.get(tsk.WhatId);
					if(cse.status != 'Closed' 
                        && cse.work_order__r.Service_Date__c != null 
                        && (cse.Case_Sub_Status__c == Constant_Util.Pending_Schedule_Confirmation 
                        && System.today() >= cse.work_order__r.Service_Date__c.adddays(-14) 
                        && System.today() <= cse.work_order__r.Service_Date__c) 
                        || (cse.Case_Sub_Status__c == Constant_Util.Pending_Service_Confirmation)) {
						
                        Task t = new Task();
						t.ActivityDate = system.today();
						t.Description__c = Constant_Util.EMPTY_STRING;
						t.OwnerId = genysysUser.Id__c;
                        
                        if(tsk.Process__c == Constant_Util.CONFIRM_SERVICE_COMPLETION && tsk.Attempt__c == 3){
                        	t.Process__c = Constant_Util.CONFIRM_SERVICE_COMPLETION_LOCATION;
                            t.Attempt__c = 1;
                            t.Subject = Constant_Util.CONFIRM_SERVICE_COMPLETION_LOCATION;
                            DateTime businessDateTime = 
                            BusinessHours.addGmt(businessHoursId,cse.work_order__r.Service_Date__c.adddays(2),intervalMilliseconds);
                        	t.Due_Date_Time__c = businessDateTime.addHours(14);
                            
                            if(accConMap.containsKey(cse.Location__c)) {
                            	AccountContactRelation accCon = accConMap.get(cse.Location__c);
                                if(string.isNotBlank(accCon.contactId)){
                                    t.Contact_Email__c = accCon.contact.Email;
                                	t.Contact_Number__c = accCon.contact.phone;
                                }
                            }
                        } else {
                            t.Process__c = tsk.Process__c;
                            t.Attempt__c = tsk.Attempt__c +1;
                            t.Subject = tsk.subject;
                            t.WhoId = tsk.WhoId;
                            t.Contact_Email__c = tsk.Contact_Email__c;
                            t.Contact_Number__c = tsk.Contact_Number__c;
                            t.Contact_Title__c = tsk.Contact_Title__c;
                        }

						t.PurchaseOrder_Number__c = tsk.PurchaseOrder_Number__c;
						t.Profile_Number__c = tsk.Profile_Number__c;
						t.WhatId = tsk.WhatId;      
                        t.Is_Genesys_User__c = true;        
                        t.RecordTypeId = 
                        Schema.getGlobalDescribe().get(Constant_Util.OBJECT_TASK).getDescribe().getRecordTypeInfosByDeveloperName().get(Constant_Util.FOLLOW_UP_TASK).getRecordTypeId();
                        
                        if(tsk.Process__c == Constant_Util.CONFIRM_SERVICE_COMPLETION && tsk.Attempt__c != 3) {
                            DateTime businessDateTime = BusinessHours.addGmt(businessHoursId,cse.work_order__r.Service_Date__c.adddays(1),intervalMilliseconds);
                        	t.Due_Date_Time__c = businessDateTime.addHours(14);
                        }

                        if(tsk.Process__c == Constant_Util.Obtain_Schedule_Confirmation) {
                        	t.Due_Date_Time__c = system.now().addhours(4);
                        }
						insertTaskLst.add(t);
					}
				}
			}
			List<Database.SaveResult> dbrs = Database.insert(insertTaskLst, false);
            UTIL_LoggingService.logDmlResults(dbrs, null, insertTaskLst,
                                                UTIL_ErrorConstants.ERROR_APPLICATION,
                                                Constant_Util.ATTEMPT_BATCH,
                                                Constant_Util.EXECUTE,
                                                Constant_Util.EMPTY_STRING,
                                                LoggingLevel.ERROR);
			
            List<Task> updateTaskLst = new List<Task>();
			Integer index = 0;
            task t = null;
			for(Database.SaveResult sr : dbrs){
				if(sr.isSuccess()){
					t = new task(Id = taskLst[index].Id);
					t.Is_Attempt_Created__c = true;
					updateTaskLst.add(t);
				}
				index++;
			}
			update updateTaskLst;
        } catch(Exception e) {
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }   
	/*@MethodName finish
	* Method to send the notification email if batch finished with errors
	**/ 
    public void finish(Database.BatchableContext batchVariable) {     
        try{
            DateTime nextRunTime = DateTime.now().addMinutes(Integer.valueOf(System.Label.Attempt_Batch_Frequency));
            String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
                    nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
            if(!Test.isRunningTest()){
                System.scheduleBatch(new AttemptTasksCreationBatch(), 'SchdJob '+cronString, Integer.valueOf(System.Label.Attempt_Batch_Frequency), 200);
            } 
        }catch(Exception ex){
            UTIL_LoggingService.logHandledException(ex, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
	}  
}