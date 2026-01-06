/*************************************************************
@Name: MultiCaseTaskPopuCntrl
@Author: DineshKumar S
@CreateDate: 14/07/2019
@Description: Controller to display the related Case task
@UsedBy: ultiCaseTaskPopup
*************************************************************/
public without sharing class MultiCaseTaskPopuCntrl {
    Private Static List<Task> taskList = new List<Task>();
    Private Static Set<String> approvalTaskSet = new Set<String>{Constant_Util.OBTAIN_SERVICE_APPROVAL,Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL,Constant_Util.MULTI_CASE_APPROVAL_TASK};
    Private Static Set<String> customerInfoSet = new Set<String>{Constant_Util.OBTAIN_CUSTOMER_INFO,Constant_Util.ESCALATION_OBTAIN_CUSTOMER_INFO};
    Private Static Set<String> vendorInfoSet = new Set<String>{Constant_Util.Confirm_Vendor_Availability,Constant_Util.STR_ESCALATION_CONFIRM_VENDOR_AVAILABILITY};
        
    @AuraEnabled
    Public static wrapperResult getTaskList(Id taskId, Boolean isPopUp){
        set<Id> caseReferenceNum = new set<Id>();
        map<Id,Task> approvalTask = new map<Id,Task>();
		List<Task> returnTasklst = new List<Task>();
        Task tsk = [Select Id,WhatId,Attempt__c,Outcome__c,Subject,Process__c,Business_Rule__c,OwnerId,MultiCaseId__c,Approval_Log__r.Approver_Type__c,Approval_Log__r.CaseId__r.Reference_Number__c,whoId,ContactEmail__c,Contact_Title__c,Department_Name__c,Approver_Name__c,Approval_Log__c,RecordTypeId FROM Task where id =: taskId LIMIT 1];
        //get all Task list
        string approverType = tsk.Approval_Log__r.Approver_Type__c!=null ? (tsk.Approval_Log__r.Approver_Type__c).split(Constant_Util.HYPHEN)[0] : null;
        String newSearchText = approverType!=null ? Constant_Util.PERCENTAGE + approverType + Constant_Util.PERCENTAGE : null;
        string multicaseId = tsk.MultiCaseId__c;
        double attempt = tsk.Attempt__c;
        string osa = Constant_Util.OBTAIN_SERVICE_APPROVAL;
        string eosa = Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL;
        string noResponse = Constant_Util.NO_OR_PENDING_RESPONSE;
	string genesysUser = Constant_Util.GENESYS_INTEGRATION_USER;
	string groupUser = Constant_Util.GROUP_USERNAME;        
	Id tskWhatId = tsk.WhatId;
        EmailMessage msg = null;
        String query;
        wrapperResult wrapper;
        List<wrapper> wrlst = new List<wrapper>();
        Map<Id,Case> CaseMap = new Map<Id,Case>();
		if(approvalTaskSet.contains(tsk.Process__c)){
			query = 'SELECT Id,subject,whoId,Process__c,Business_Rule__r.Occurrence_Limit__c,Approval_Log__r.CaseId__r.Case_Sub_Type__c,Approval_Log__r.CaseId__r.Reference_Number__c,Approval_Log__r.CaseId__r.Service_Date__c,Approval_Log__r.CaseId__r.CaseNumber,Due_Date_Time__c,WhatId,OwnerId,Business_Rule__c,Business_Rule__r.Name,Outcome__c,Approval_Log__r.Approver_Type__c,ContactEmail__c,Contact_Title__c,Department_Name__c FROM Task where MultiCaseId__c != null and MultiCaseId__c =:multicaseId and (Process__c =: osa OR Process__c =: eosa) and Id !=:taskId ';
			if((isPopUp && !(Constant_Util.MULTI_CASE_APPROVAL_TASK).equals(tsk.Process__c) && !(Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE).equals(tsk.Process__c)) || (Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL.equals(tsk.Process__c) && string.isBlank(tsk.Outcome__c))) {
				query += 'AND Outcome__c = null AND (Owner.Name =: genesysUser OR Owner.Name =: groupUser)';
			}else if(isPopUp && (Constant_Util.MULTI_CASE_APPROVAL_TASK).equals(tsk.Process__c)){
				query += 'and (Outcome__c = null or (Outcome__c =: noResponse and Attempt__c =:attempt) )';
			}else if(isPopUp && (Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE).equals(tsk.Process__c)){
				query += 'and WhatId !=: tskWhatId and Outcome__c = null';
			}else if(!isPopUp && (Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE).equals(tsk.Process__c)){
				
			}else {
				query += 'and Outcome__c !=: noResponse';
			}
			query += ' Order by Attempt__c DESC';
			for(Task tk : Database.query(query)){
				if(String.isNotBlank(tk.Approval_Log__c) && String.isNotBlank(tsk.Approval_Log__c) && (approvalTask.isEmpty() || (!approvalTask.containskey(tk.Approval_Log__c) || (Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL.equals(approvalTask.get(tk.Approval_Log__c).Process__c))) ) ){
					if(String.IsBlank(tk.Approval_Log__r.Approver_Type__c) && string.IsBlank(tsk.Approval_Log__r.Approver_Type__c)){
						approvalTask.put(tk.Approval_Log__c,tk);
					}else if((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.CONTACT_RECORD_TYPE) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.CONTACT_RECORD_TYPE) && String.isNotBlank(tk.whoId) && tk.whoId.equals(tsk.whoId) ){
						approvalTask.put(tk.Approval_Log__c,tk);
					// }else if((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ORIGIN_EMAIL) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ORIGIN_EMAIL) && String.isNotBlank(tk.ContactEmail__c) && tk.ContactEmail__c.equals(tsk.ContactEmail__c) ){
                    //SDT-39648
                    }else if((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ORIGIN_EMAIL) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ORIGIN_EMAIL)){
						approvalTask.put(tk.Approval_Log__c,tk);
					}else if((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.DEPARTMENT_RECORDTYPE) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.DEPARTMENT_RECORDTYPE) && String.isNotBlank(tk.Department_Name__c) && tk.Department_Name__c.equals(tsk.Department_Name__c) ){
						approvalTask.put(tk.Approval_Log__c,tk);
					}else if((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.FLOW_TITLE) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.FLOW_TITLE) && String.isNotBlank(tk.Contact_Title__c) && tk.Contact_Title__c.equals(tsk.Contact_Title__c) ){
						approvalTask.put(tk.Approval_Log__c,tk);
			                //SDT-39652    
			                }else if((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ORIGIN) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ORIGIN) ){ //(Need to change commect logic for Origin) && String.isNotBlank(tk.Contact_Title__c) && tk.Contact_Title__c.equals(tsk.Contact_Title__c)
						approvalTask.put(tk.Approval_Log__c,tk);
					}else if((((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.USER_RECORDTYPE) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.USER_RECORDTYPE))|| ((tk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ATM_RECORD_TYPE) && (tsk.Approval_Log__r.Approver_Type__c).contains(Constant_Util.ATM_RECORD_TYPE)) ) && tk.Approval_Log__r.Approver_Type__c.equals(tsk.Approval_Log__r.Approver_Type__c) ){
						approvalTask.put(tk.Approval_Log__c,tk);
					}
				}
			}
			
			if((Constant_Util.MULTI_CASE_APPROVAL_TASK).equals(tsk.Process__c)){
				for(EmailMessage em :[Select Id,TextBody from EmailMessage where ParentId =: tsk.WhatId and Subject like '%Mixed:%' and FromAddress =: tsk.ContactEmail__c]){
					msg = em;
				}
			}
			returnTasklst.addAll(approvalTask.values());
            if(returnTasklst != null && returnTasklst.size() == 1 
            && (((Constant_Util.OBTAIN_SERVICE_APPROVAL).equals(tsk.Process__c) && (Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL).equals(returnTasklst[0].Process__c)) 
            || ((Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL).equals(tsk.Process__c) && (Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL).equals(returnTasklst[0].Process__c))))
            {
                returnTasklst.clear();
            }
           
            for(Task t: returnTasklst){
                wrapper wr = new wrapper(t,null);
                wrlst.add(wr);
            }
			wrapper = new wrapperResult(wrlst,tsk,msg);
		}else{ 
			String vendorAvail = Constant_Util.Confirm_Vendor_Availability;
			String escVendorAvail = Constant_Util.STR_ESCALATION_CONFIRM_VENDOR_AVAILABILITY;
			String customInfo = Constant_Util.OBTAIN_CUSTOMER_INFO;
			String escCustomInfo = Constant_Util.ESCALATION_OBTAIN_CUSTOMER_INFO;
			Map<Id,Task> alltasks = new Map<Id,Task>();
			query = 'SELECT Id,Subject,whoId,Process__c,Proposed_Service_Date__c,Description__c,PurchaseOrder_Number__c,Profile_Number__c,whatId,Outcome__c,Description FROM Task where MultiCaseId__c != null and MultiCaseId__c =:multicaseId and Id !=:taskId and whatId !=: tskWhatId';
			if(vendorInfoSet.contains(tsk.Process__c)){
				query += ' and (Process__c =: vendorAvail OR Process__c =: escVendorAvail)';
			}else if(customerInfoSet.contains(tsk.Process__c)){
				query += ' and (Process__c =: customInfo OR Process__c =: escCustomInfo)';
			}
            if(isPopUp){
                query +=' and Outcome__c = null';
            }
			for(Task tk : Database.query(query)){
				alltasks.put(tk.whatId,tk);
			}
			returnTasklst.addAll(alltasks.values());
            
			for(Case c: [select id,Service_Date__c,Case_Sub_Type__c,CaseNumber from Case where Id IN: alltasks.keySet() LIMIT 49999]){
				CaseMap.put(alltasks.get(c.Id).Id,c);
			}
            wrapper wr = null;
            for(Task t: returnTasklst){
                wr = new wrapper(t,CaseMap.get(t.Id));
                wrlst.add(wr);
            }
			wrapper = new wrapperResult(wrlst,tsk,null);
		}
        return wrapper;
    }
    /*************************************************************
	@MethodName: populateOutcome
	@Author: DineshKumar S
	@CreateDate: 014/07/2019
	@Description: Controller to update the Related Task
	@UsedBy: ultiCaseTaskPopup
	@Parameter: List<Task>, Id
	*************************************************************/
    @AuraEnabled
    Public static String populateOutcome(List<Task> drafTasklst,Id taskId){
        String result;
        List<Task> updateTasklst = new List<Task>();
        
        Task tsk = [Select Id,WhatId,Outcome__c,MultiCaseId__c,Subject,Business_Rule__c,Owner.Name,Process__c,Preferred_Contact_Method__c,OwnerId,Approval_Log__r.Approver_Type__c,Approval_Log__r.CaseId__r.Reference_Number__c,whoId,ContactEmail__c,Contact_Title__c,Department_Name__c,Approver_Name__c FROM Task where id =: taskId LIMIT 1];
        
        for(Task t : drafTasklst){
            if(approvalTaskSet.contains(tsk.Process__c)){
                If((Constant_Util.NO_OR_PENDING_RESPONSE).Equals(t.Outcome__c)){
                    t.MultiCaseId__c = t.WhatId;
                }else {
                    if(!Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL.equals(tsk.Process__c) && !(Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE).equals(tsk.Process__c)){
                        t.WhoId = String.isNotBlank(tsk.WhoId) ? tsk.WhoId : null ;
                        t.ContactEmail__c = String.isNotBlank(tsk.ContactEmail__c) ? tsk.ContactEmail__c : null;
                        t.Preferred_Contact_Method__c = String.isNotBlank(tsk.Preferred_Contact_Method__c) ? tsk.Preferred_Contact_Method__c : null;
                    }
                    t.OwnerId = tsk.OwnerId;
                    t.Approver_Name__c = String.isNotBlank(tsk.Approver_Name__c) ? tsk.Approver_Name__c :  Constant_Util.ESCALATION_OBTAIN_SERVICE_APPROVAL.equals(tsk.Process__c) || (Constant_Util.VALIDATE_EMAIL_APPROVAL_RESPONSE).equals(tsk.Process__c) ? tsk.Owner.Name : null;
                }
            }else if(customerInfoSet.contains(tsk.Process__c)){
                if((Constant_Util.INFORMATION_NOT_OBTAIN).Equals(t.Outcome__c)){
                    t.MultiCaseId__c = t.WhatId;
                    t.Description = null;
                }
                    t.OwnerId = tsk.OwnerId;
            }else if(vendorInfoSet.contains(tsk.Process__c)){
                if((Constant_Util.STR_VENDOR_UNAVAILABLE_OUTCOME).Equals(t.Outcome__c)){
                	t.MultiCaseId__c = String.isNotBlank(t.WhoId) ? t.WhatId + Constant_Util.HYPHEN + t.WhoId : null;
                	t.Description = null;
                }
                	t.OwnerId = tsk.OwnerId;
            }
            updateTasklst.add(t);
        }
        try{
            Database.update(updateTasklst);
            result = Constant_Util.SUCCESS;
        }catch(System.DmlException e){  // Catch block to catch error messages 
            system.debug('Exception:'+e.getStackTraceString());
            result = e.getdmlMessage(0);
        }
        catch(Exception ex){  // Catch block to catch error messages 
            system.debug('Exception:'+ex.getStackTraceString());
            result = ex.getMessage()+Constant_Util.NEW_LINE+ex.getStackTraceString();
        }
        system.debug('Result'+result);
        return result;
    }
   Public inherited sharing class wrapperResult {
        @auraEnabled Public List<wrapper> wrapperlist{get;set;}
        @auraEnabled Public Task multiCaseTask{get;set;}
        @auraEnabled Public EmailMessage emailMsg{get;set;}
        public wrapperResult(List<wrapper> wrapperlst,Task multiCaseTsk,EmailMessage msg){
            this.wrapperlist = wrapperlst;
            this.multiCaseTask = multiCaseTsk;
            this.emailMsg = msg; 
        }  
    }
    public inherited sharing class wrapper {
        @auraEnabled Public Task resultTask{get;set;}
        @auraEnabled Public Case caseDetail{get;set;}
        public wrapper(Task resultTsk,Case cse){
            this.resultTask = resultTsk;
            this.caseDetail = cse; 
        }
    }
}