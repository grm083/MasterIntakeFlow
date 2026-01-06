public with sharing class ProgressCaseComponentController {
    
    private static boolean isAutoApproved;		
    private static boolean ruleMatched;
    private static boolean occurenceLimit;
    
    @AuraEnabled
    public static String openCase(String caseId){
        try{
            // SNP 9566 changes starts
            Case cseRcd = [select id,Status,Case_Type__c, CaseNumber,Reference_Number__c,Case_Sub_Type__c,Source_System__c,ParentId,Parent.Case_Type__c from case where id=:caseId limit 1];
            cseRcd.Status = Constant_Util.OPEN;

            //added as part of SDT 32806
            cseRcd.Integrate_with_Acorn__c = TRUE;
             
             if(cseRcd.Case_Type__c == Constant_Util.STATUS_CSTYPE){  
                if((Constant_Util.SOURCE_SALESFORCE.equalsIgnoreCase(cseRcd.Source_System__c) || Constant_Util.ACORN.equalsIgnoreCase(cseRcd.Source_System__c)) && cseRcd.Case_Sub_Type__c ==Constant_Util.SERVICE_NOT_PERFORMED){  
                      cseRcd.Case_Sub_Status__c = Constant_Util.PENDING_SERVICE_ISSUE_RESOLUTION;               
                }else {
                    cseRcd.Case_Sub_Status__c = Constant_Util.PENDING_VENDOR_FOLLOW_UP;  
                }
            }
            // SNP 9566 changes ends
            Database.update(cseRcd);
            return Constant_Util.SUCCESS;
        }
        catch(Exception ex){
            return ex.getStackTraceString()+'\n'+ex.getLineNumber();
        }
    }
    
    @AuraEnabled
    public static String closeCase(String caseId){
        try{
            Case cseRcd = [select id,Status,Case_Type__c from case where id=:caseId limit 1];
            cseRcd.Status = Constant_Util.CLOSED;
            if(cseRcd.Case_Type__c == Constant_Util.STATUS_CSTYPE){
                cseRcd.Case_Sub_Status__c = Constant_Util.STATUS_PROVIDED;
            }
            Database.update(cseRcd);
            return Constant_Util.SUCCESS;
        }catch(Exception ex){
            return ex.getStackTraceString()+'\n'+ex.getLineNumber();
        }
    }
    
    /**		
* @author Accenture		
* @date 21/3/2019		
* @description : wrapper Class.		
**/		
    @AuraEnabled		
    public static Wrapper getServiceApprovers(String caseId){		
    	set<Id> accountIdset = new set<Id>();
        set<string> requestTypeSet = new Set<string>();
        set<string> ServiceTypeSet = new Set<string>();
        List<Id> relatedCaseIdList = new List<Id>();
        set<Id> recordTypeIdSet = new set<Id>();
        map<Id,Business_Rule__c> approvalmap = new map<Id,Business_Rule__c>();
        map<Id,Business_Rule__c> reqInfomap = new map<Id,Business_Rule__c>();
        Business_Rule__c thisBusinessRule = new Business_Rule__c();
        Set<String> workOrderStatus = new Set<String>{Constant_Util.IN_PROGRESS,Constant_Util.STATUS_NEW,Constant_Util.COMPLETED,Constant_Util.CLOSED};
        
        List<Case> myCases = [SELECT Id, Client__c,accountId,CaseNumber,Reference_Number__c,Location__c,ContactId, Contact_Title__c,Case_Type__c,Case_Sub_type__c,		
                              AssetId,Status,Case_Sub_Status__c,EmailofContact__c,SLA_Service_Date_Time__c,Override_PO_Create_Task__c,SuppliedEmail,		
                              PSI_Override_Reason__c,PSI_Comments__c,Show_Multiple_Asset_Cases__c,Is_Multiple_Asset__c,Service_Date__c,Origin,PSI__c,OwnerId,		
                              PurchaseOrder_Number__c,SlaStartDate,ContactDepartment__c,Case_Reason__c 		
                              FROM CASE WHERE id =:caseId and RecordType.DeveloperName != 'New_Service_Case' LIMIT 1];
        Wrapper wrapperClass = new Wrapper();		
        If(myCases != null && myCases.size() > 0){
        wrapperClass.caseId = myCases[0].Id;		
        If( myCases[0].Status.equals(Constant_Util.STATUS_New) || (myCases[0].Status.equals(Constant_Util.PENDING) && (Constant_Util.PENDING_CUSTOMER_INFORMATION.equals(myCases[0].Case_Sub_Status__c) || Constant_Util.PENDING_REQUEST_APPROVAL.equals(myCases[0].Case_Sub_Status__c)) ) ){		
		Id approvalRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
                Id reqInfoRecTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.REQUIRED_INFORMATION).getRecordTypeId();
                recordTypeIdSet.add(approvalRecTypeId);
				accountIdset.add(myCases[0].Client__c); 
				requestTypeSet.add(myCases[0].Case_Type__c);
				ServiceTypeSet.add(myCases[0].Case_Sub_type__c);
				
				for(Asset a : [SELECT Id,Product2.ProductTypeSelected__c,Duration__c,Project_Code__c,Active__c,End_Date_Based_on_Project_code__c
							   FROM Asset 
							   WHERE Id =: myCases[0].AssetId LIMIT 49999]){
								   CaseTriggerHelper.casewithContainer.put(a.Id,a);
				}
				for(Account loc: [SELECT Id,Brand__c,Geography__c,Division__c,Location_Type__c 
								  FROM Account
								  WHERE Id =: myCases[0].Location__c LIMIT 49999]){
									  CaseTriggerHelper.casewithLocation.put(loc.Id,Loc);
				}
            	string woKey = null;
                if(myCases[0].Service_Date__c != null){
                    Date startDate = (myCases[0].Service_Date__c).toStartOfMonth();
                    Date endDate = (myCases[0].Service_Date__c).addMonths(1).toStartofMonth().addDays(-1);
                    for(AggregateResult wo : [Select COUNT(Id)num,AssetId,Customer_Location__c,Case.Case_Sub_Type__c  from WorkOrder where AssetId IN:CaseTriggerHelper.casewithContainer.keySet()  and Customer_Location__c IN:CaseTriggerHelper.casewithLocation.keySet() and StatusCategory IN:workOrderStatus and Case_Subtype__c =: myCases[0].Case_Sub_type__c and Is_Bypass__c = false and Service_Date__c >=: startDate and Service_Date__c <=: endDate Group by AssetId,Customer_Location__c,Case.Case_Sub_Type__c]){
                        woKey = (String)wo.get('AssetId') + (String)wo.get('Customer_Location__c') + (String)wo.get('Case_Sub_Type__c');
                        CaseTriggerHelper.caseWorkOrderCount.put(woKey,(Integer)wo.get('num'));
                    }
                }
                if(myCases[0].Status.equals(Constant_Util.STATUS_New)){
                	recordTypeIdSet.add(reqInfoRecTypeId);
                }
                //List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCases,recordTypeIdSet,accountIdset,requestTypeSet,ServiceTypeSet,CaseTriggerHelper.casewithContainer,CaseTriggerHelper.casewithLocation);
                List<BusinessRuleHelper.BusinessRulewrapper> businessRulewrapperlst = BusinessRuleHelper.businessRuleSelection(myCases[0].Id,recordTypeIdSet);
                if(businessRulewrapperlst != null && businessRulewrapperlst.size() > 0){
                    for(BusinessRuleHelper.BusinessRulewrapper brw : businessRulewrapperlst){
                        if(reqInfoRecTypeId.equals(brw.bRule.RecordTypeId)){
                            reqInfomap.put(brw.caseId,brw.bRule);
                        }else if( approvalRecTypeId.equals(brw.bRule.RecordTypeId)){
                            approvalmap.put(brw.caseId,brw.bRule);
                        }
                    }
                } 
            /*//Flow.Interview.Approval_Business_Rule approvalFlow;// = CaseTriggerHelper.getApprovalStatus(myCases[0]);		
            Business_Rule__c thisBusinessRule  = null; //(Business_Rule__c)(approvalFlow.getVariableValue(Constant_Util.FLOW_OBTAINEDBR));		
            isAutoApproved = true; //(Boolean)(approvalFlow.getVariableValue(Constant_Util.FLOW_ISAUTOAPPROVED));		
            ruleMatched = true; //(Boolean)(approvalFlow.getVariableValue(Constant_Util.FLOW_RULEMATCHED));		
            wrapperClass.approvalInfo = Constant_Util.EMPTY_STRING;		
            wrapperClass.enableapprovalInfo = (String.isNotBlank(myCases[0].Client__c) && String.isNotBlank(myCases[0].Case_Sub_type__c)) ? true : false;*/
			
			BusinessRuleHelper.wrapperResult brwrapper = null;
			map<Id,Boolean> autoApprovalmap = new map<Id,Boolean>();
			map<Id,Boolean> rulematchedmap = new map<Id,Boolean>();
            		map<Id,Boolean> occurenceLimitmap = new map<Id,Boolean>();
			if(approvalmap != null && approvalmap.size() > 0){
				brwrapper = BusinessRuleHelper.getapprovallog(approvalmap,myCases,CaseTriggerHelper.caseWorkOrderCount);
				autoApprovalmap = brwrapper.autoApprovemap;
				rulematchedmap = brwrapper.rulematchedmap;
                		occurenceLimitmap = brwrapper.occurenceLimitmap;
			}
			system.debug('brwrapper'+brwrapper);
			thisBusinessRule = approvalmap != null && approvalmap.size() > 0 && approvalmap.containskey(myCases[0].Id) ? approvalmap.get(myCases[0].Id) : null;
			isAutoApproved = autoApprovalmap != null && autoApprovalmap.size() > 0 ? autoApprovalmap.containskey(myCases[0].Id) ? autoApprovalmap.get(myCases[0].Id) : true : true;
			ruleMatched = rulematchedmap != null && rulematchedmap.size() > 0 && rulematchedmap.containskey(myCases[0].Id) ? rulematchedmap.get(myCases[0].Id) : false;
			occurenceLimit = occurenceLimitmap != null && occurenceLimitmap.size() > 0 && occurenceLimitmap.containskey(myCases[0].Id) ? occurenceLimitmap.get(myCases[0].Id) : false;
            		wrapperClass.approvalInfo = Constant_Util.EMPTY_STRING;
			wrapperClass.enableapprovalInfo = (String.isNotBlank(myCases[0].Client__c) && String.isNotBlank(myCases[0].Case_Sub_type__c)) ? true : false;
                	String requestorOnlyAppr = Constant_Util.EMPTY_STRING;
			String notRequestorOnlyAppr = Constant_Util.EMPTY_STRING;
            		
            if(isAutoApproved && !ruleMatched  && String.isNotBlank(myCases[0].Client__c) && String.isNotBlank(myCases[0].Case_Sub_type__c)){		
                wrapperClass.approvalInfo += Constant_Util.NO_APPROVAL_REQUIRED;		
            }		
            else if(thisBusinessRule != null){		
                //wrapperClass.occurrenceLimit = Integer.valueof(thisBusinessRule.Occurrence_Limit__c);		
                List<Service_Approver__c> serviceapproverlst = (List<Service_Approver__c>) thisBusinessRule.Approver_Entities__r;		
                Boolean flag = false;		
                string approver ='';
                Boolean isRequestor = false;
                if(isAutoApproved && ruleMatched){		
                    wrapperClass.approvalInfo += Constant_Util.AUTO_APPROVED;		
                }		
                else if(thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null){		
                    
                    for(Service_Approver__c sap :serviceapproverlst){
                            approver = (sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName;
                            if(!sap.Requester_Only__c){
                                if(!flag){
                                    notRequestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                    flag= true;
                                }else{
                                    notRequestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                            	}
                            }else if(sap.Requester_Only__c){
                                if(!isRequestor){
                                    isRequestor = true;
                                    requestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                }else{
                                    requestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                                }
                            }
                        }
					if(flag){
						wrapperClass.approvalInfo += notRequestorOnlyAppr;
						wrapperClass.approvalInfo += isRequestor ? Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_AND + '<div style="color: #3c8a2e;">' + RequestorOnlyAppr + '</div>': ''; 
					}
                }else if(!thisBusinessRule.Multiple_Mandatory_Approvers__c && serviceapproverlst!= null ){		
                    for(Service_Approver__c sap :serviceapproverlst){
                            approver = (sap.Account_Team_Member__c == null )?((sap.Approver_Contact__c == null)? ((sap.Title__c == null) ?((sap.Account_Department__c == null) ? ((sap.Email__c == null)?((sap.User__c == null)? null: sap.User__r.FirstName + Constant_Util.EMPTY_SPACE + sap.User__r.LastName ): sap.Email__c ) : sap.Account_Department__c ) : sap.Title__r.Name ) :sap.Approver_Contact__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Approver_Contact__r.LastName) : sap.Account_Team_Member__r.FirstName + Constant_Util.EMPTY_SPACE + sap.Account_Team_Member__r.LastName;
                            if(!sap.Requester_Only__c){
                                if(!flag){
                                    notRequestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                    flag= true;
                                }else{
                                    notRequestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                            	}
                            }else if(sap.Requester_Only__c){
                                if(!isRequestor){
                                    isRequestor = true;
                                    requestorOnlyAppr += approver +  Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c; 
                                }else{
                                    requestorOnlyAppr += Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + Constant_Util.NEW_LINE + approver + Constant_Util.EMPTY_SPACE + Constant_Util.HYPHEN + Constant_Util.EMPTY_SPACE + sap.Approver_Type__c;
                                }
                            }
                        }
					if(flag){
						wrapperClass.approvalInfo += notRequestorOnlyAppr;
						wrapperClass.approvalInfo += isRequestor ? Constant_Util.EMPTY_SPACE + Constant_Util.CONSTANT_OR + '<div style="color: #3c8a2e;">' + RequestorOnlyAppr + '</div>': ''; 
					}	
                }		
                else{		
                    //Nova cop fix		
                }
                If(isRequestor){
                        wrapperClass.approvalInfo += '<div class = "spl">' + system.Label.ForRequestorOnly + '</div>';
                }
                If(!occurenceLimit && thisBusinessRule.Occurrence_Limit__c != null && !isAutoApproved && thisBusinessRule.Occurrence_Limit__c > 0){
                    wrapperClass.approvalInfo += '<div class = "spl">'+ 'The account has Occurrence Limit of ' + String.valueof(thisBusinessRule.Occurrence_Limit__c) + '. Approval is required' + '</div>';
                }
                If(String.isNotBlank(thisBusinessRule.Special_Instructions_Approval__c)){
                        wrapperClass.approvalInfo += '<div class = "spl">' + '<strong>' + 'Approval Instructions' + '</strong>' + '</div>';
                        wrapperClass.approvalInfo += '<div>' + thisBusinessRule.Special_Instructions_Approval__c + '</div>';
                }
            }		
        }	
        }
        return wrapperClass;		
    }		
    
    /**		
* @author Accenture		
* @date 21/3/2019		
* @description : wrapper Class.		
**/		
    public with sharing class Wrapper {		
        @AuraEnabled public string approvalInfo {get;set;}		
        //@AuraEnabled public Integer occurrenceLimit {get;set;}		
        @AuraEnabled public Boolean enableapprovalInfo {get;set;}
        @AuraEnabled public Id caseId {get;set;}		
    }	
    
    
}