/**
 * @description   : Get Business Rules
 * @Created Date  : 04-02-2023
 * @Last Updated Date  : 20-01-2025
 * @Last Updated By    : Srishti Gupta
 * @description   : Modified methods as per BRE-1 || Update Business Rule Pop Up Screen - Approver & Requestor Table
**/
public class CaseRulesModalCtrl {    
public static final String TEMPLATE_APPROVAL_REQUEST = 'Customer or Internal: PM / Customer Approval Request (Use for Business Rules)';
    
    // Case Rules
    @AuraEnabled
    public static List<BRWrapper> getCase(String caseId){
list<BRWrapper> brlistfinal = new List<BRWrapper> ();
        integer intcount = 1 ;
        List<BRWrapper> brList;
        List<Case> caseList = [Select Id, Location__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c from Case where Id =: caseId];
        if(caseList != null && !caseList.isEmpty() 
            && String.isNotEmpty(caseList[0].Location__c)
            && String.isNotEmpty(caseList[0].Case_Type__c) 
            && String.isNotEmpty(caseList[0].Case_Sub_Type__c)){
                brList = getBRData(caseList[0].Location__c, caseList[0].Case_Type__c,caseList[0].Case_Sub_Type__c,caseList[0].Case_Reason__c,caseId);
               for(BRWrapper br : brList){
                   if(br.recordTypeName == 'Approval'){
                       br.brCount =  intcount ;
                       intcount ++ ;
                       brlistfinal.add(br);
                   }else{
                       brlistfinal.add(br);
                   }
               }
               
               
        }
        return brList; 
    }
        
    
        //Created By - Harsha
        //Purpose - To fetch business rule on case and quotes based out of record id.
        //Last Updated by = 10/15/2025
        @AuraEnabled
public static List<BRWrapper> getCaseRules(String recordId) {
    List<BRWrapper> brListFinal = new List<BRWrapper>();
    Integer intCount = 1;
    List<BRWrapper> brList;
    String caseId;
    String quoteId;

    List<Case> caseCheck = [SELECT Id FROM Case WHERE Id = :recordId LIMIT 1];
    if (!caseCheck.isEmpty()) {
        caseId = recordId;
    } else {
        quoteId = recordId;
        SBQQ__Quote__c q = [SELECT Id, SBQQ__Opportunity2__r.Case__c 
        FROM SBQQ__Quote__c 
        WHERE Id = :quoteId LIMIT 1];
        caseId = q.SBQQ__Opportunity2__r.Case__c;
    }

    if (String.isNotBlank(caseId)) {
        List<Case> caseList = [
            SELECT Id, Location__c, Case_Type__c, Case_Sub_Type__c, Case_Reason__c
            FROM Case
            WHERE Id = :caseId
        ];

        if (!caseList.isEmpty() 
            && String.isNotEmpty(caseList[0].Location__c)
            && String.isNotEmpty(caseList[0].Case_Type__c)
            && String.isNotEmpty(caseList[0].Case_Sub_Type__c)) {

            String caseType = caseList[0].Case_Type__c;
                String caseSubType = caseList[0].Case_Sub_Type__c;
                
                //Added for SDT-49569 to display haulaway quotes on pickup type of cases
                // Defect SDT- 50605 -> To display haul away quote to any record type
                String idForBRData;
                 if (((caseType == 'Pickup' && caseSubType == 'Haul Away - No Equipment') || caseType != 'New Service') && quoteId != null) {
                    idForBRData = null;
                    caseList[0].Case_Type__c = 'New Service';
                    caseList[0].Case_Sub_Type__c = 'Temporary';

                } else {
                    idForBRData = String.isNotBlank(quoteId) ? quoteId : caseId;
                }

            brList = getBRData(caseList[0].Location__c, caseList[0].Case_Type__c, caseList[0].Case_Sub_Type__c, caseList[0].Case_Reason__c, idForBRData);
            if(idForBRData == null){
                for (BRWrapper br : brList) {
                    if (br.caseType == 'New Service' &&
                        br.caseSubType == 'Temporary' &&
                        br.recordTypeName == 'Approval' && 
                        br.container == 'Haul Away Service') {
                        br.brCount = intCount;
                        intCount++;
                        brListFinal.add(br);
                    } 
                }
            }else {
            for (BRWrapper br : brList) {
                if (br.recordTypeName == 'Approval') {
                    br.brCount = intCount;
                    intCount++;
                }
                brListFinal.add(br);
                }
            }
        }
    }

    return brListFinal;
}
    
    @AuraEnabled
    public static Boolean sendEmailButtonDisabled(String caseId){
        Boolean isSendEmailDisabled = false;
        for(Case caseObj : [Select Id,Status,RecordType.Name from Case where Id =: caseId]){
            if(caseObj.RecordType.Name == Constant_Util.Pickup_Case_Rec_Type || caseObj.RecordType.Name == Constant_Util.New_Service_Case || caseObj.Status == Constant_Util.Case_Closed_Status){
                isSendEmailDisabled = true;
            }
        }
        return isSendEmailDisabled;
    }
    
        // Method updated as per BRE-1, BRE-7
    @AuraEnabled
    public static List<BRWrapper> getBRData(String locationId, String caseType, String caseSubType, String caseReason, Id caseIdRec){
        List<BRWrapper> brWrapperList = new List<BRWrapper>();
        Integer brCaseCount = 0;  
	Id approvalRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        Id businessNotificationRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
        List<Business_Rule__c> brList =   new List<Business_Rule__c>();
        if(caseIdRec == null){
            brList = getBrRecordsByLocation(locationId);
        }
        else
        {
            Map<String, List<Business_Rule__c>> getBrMap = BusinessRuleUtility.getPriorityBusinessRule(caseIdRec);
            System.debug('Map is::'+ getBrMap);
            
            for (List<Business_Rule__c> variable : getBrMap.values()) {
                brList.addAll(variable);
            }
        }
           
        for(Business_Rule__c br : brList){
			List<BRApprover> brApproverList = new List<BRApprover>();  
            List<BRRequestor> brRequestorList = new List<BRRequestor>();
                //System.debug('70 . br::' + br.Alias__c + '-'+br.RecordTypeId + '-'+approvalRecordTypeId );
                if(
                    (caseIdRec !=null 
                            && ((!br.Approver_Entities__r.isEmpty() && br.RecordTypeId == approvalRecordTypeId) || br.RecordTypeId == businessNotificationRecordTypeId)
                            )
                     || (caseIdRec == null 
                            && ((!br.Approver_Entities__r.isEmpty() && br.RecordTypeId == approvalRecordTypeId) || br.RecordTypeId == businessNotificationRecordTypeId)
                            && (br.Request_Type__c != null && br.Request_Type__c == caseType ||  br.Request_Type__c == null && br.LocationId__c == null && br.Special_Ins__c !=null )
                            && (br.Service__c != null &&(br.Service__c == caseSubType || br.Service__c != caseSubType) || br.Service__c == null && br.LocationId__c == null && br.Special_Ins__c !=null)
                            && (br.Case_Reason__c == null || (br.Case_Reason__c != null && br.Case_Reason__c == caseReason)||(br.Case_Reason__c == null && br.LocationId__c == null && br.Special_Ins__c !=null))
                        )
                    )
                    {
		    //Chandu kari SDT-51136 changes line 165 (br.Service__c == caseSubType || br.Service__c != caseSubType)
                    BRWrapper newWrap = new BRWrapper();
                    newWrap.brId = br.Id;
                    newWrap.recordTypeName =    br.RecordType.Name ;
                    newWrap.brCount = brCaseCount+1;
                    newWrap.alias = br.Alias__c ;
                    newWrap.specialInstruction = br.Special_Ins__c ;
                    newWrap.container = br.Container__c ;
                    newWrap.channel = br.Channel__c;
                    newWrap.channelRequirement = br.Channel_Req__c ;
                    newWrap.projectCode = br.Project_Code__r.Name;
                    newWrap.brName = String.isNotBlank(br.Alias__c) ? br.Alias__c : br.Name;
                    newWrap.caseType = br.Request_Type__c;
                    newWrap.caseSubType = br.Service__c;
                    newWrap.caseReason = br.Case_Reason__c;
                    newWrap.approval = ((br.RecordTypeId == approvalRecordTypeId)&&!(br.No_Approval_Required__c)) //SDT-31225
                    ? 'Approval Needed'
                    : 'No Approval Needed';
                    newWrap.isApproval = br.RecordTypeId == approvalRecordTypeId ? true : false;
                    newWrap.approvalInstructions = br.Special_Instructions_Approval__c;
                    newWrap.locationName = br.LocationId__c!=null ? br.LocationId__r.Name : '';
                    newWrap.asset = br.AssetId__c!=null ? br.AssetId__r.Name : '';
                    newWrap.material = br.Material__c;
                    newWrap.duration = br.Schedule_Type__c;
                    newWrap.categoryType = br.Category_Type__c;
                    newWrap.groupName = br.Group__c!=null ? br.Group__r.Name : '';
                    newWrap.projectType = br.Project_Code__c!=null ? br.Project_Code__r.Name : '';
                    newWrap.noOfOccurance = String.valueOf(br.Occurrence_Limit__c);
                    newWrap.multiApprovers = br.Multiple_Mandatory_Approvers__c ? 'Yes' : 'No';
                    newWrap.isNTERule = br.NTE_Rules__c ? 'Yes' : 'No';
		    newWrap.companyCategory = br.Company_Category__c;
                    for(Service_Approver__c sr : br.Approver_Entities__r){
                        if(sr.Requester_Only__c != true) { 
                        BRApprover apr = new BRApprover();
                        apr.approverId = sr.Id;
                        apr.approverName = sr.Approver_Contact__r.Name!=null ? sr.Approver_Contact__r.Name : 
                            sr.Account_Title__c!=null ? sr.Account_Title__c : 
                            sr.User__c !=null ? sr.User__r.Name :  
                            sr.Account_Department__c !=null ? sr.Account_Department__c :

                             sr.RecordType.Name =='NTE Approval' ? sr.Name :
                            sr.RecordType.Name =='Origin' ? sr.Name : sr.Approver__c;

                        apr.recordTypeName = sr.RecordType.Name != 'Origin' ? sr.RecordType.Name: sr.RecordType.Name +'-' + sr.Origin__c ; //BRE-13 changes
                        apr.approverRecId = sr.Approver_Contact__c!=null ? sr.Approver_Contact__c : 
                            sr.Title__c!=null ? sr.Title__c : 
                            sr.User__c !=null ? sr.User__c : sr.Id;
                        apr.accTitleName = sr.Approver_Contact__c!=null && sr.Approver_Contact__r.Account_Title__c !=null ? sr.Approver_Contact__r.Account_Title__r.Name : 
                            sr.Account_Title__c!=null ? sr.Account_Title__c : '';
                        apr.reqOnly = sr.Requester_Only__c;
                        apr.serviceType = sr.Service_Type__c;
                        apr.nteAmount =  String.valueOf(sr.NTE_Amount__c);
                        apr.approverEmail = sr.Approver_Email__c;
                        apr.acctTitle = sr.Account_Title__c;

                        brApproverList.add(apr); }

                    else {

                    BRRequestor req = new BRRequestor();
                    req.approverId = sr.Id;
                    req.approverName = sr.Approver_Contact__r.Name!=null ? sr.Approver_Contact__r.Name : 
                                        sr.Account_Title__c!=null ? sr.Account_Title__c : 
                                        sr.User__c !=null ? sr.User__r.Name :  
                                        sr.Account_Department__c !=null ? sr.Account_Department__c :

                                                sr.RecordType.Name =='NTE Approval' ? sr.Name  :
                                        sr.RecordType.Name =='Origin' ? sr.Name : sr.Approver__c;
    
                    req.recordTypeName = sr.RecordType.Name != 'Origin' ? sr.RecordType.Name: sr.RecordType.Name +'-' +sr.Origin__c ; //BRE-13 changes
                    req.approverRecId = sr.Approver_Contact__c!=null ? sr.Approver_Contact__c : sr.Title__c!=null ? sr.Title__c : sr.User__c !=null ? sr.User__c : sr.Id;


                    req.accTitleName = sr.Approver_Contact__c!=null && sr.Approver_Contact__r.Account_Title__c !=null ? sr.Approver_Contact__r.Account_Title__r.Name : 
                                       sr.Account_Title__c!=null ? sr.Account_Title__c : '';
                    req.reqOnly = sr.Requester_Only__c;
                    req.serviceType = sr.Service_Type__c;
                    req.nteAmount =  String.valueOf(sr.NTE_Amount__c);
                    req.approverEmail = sr.Approver_Email__c;
                    req.acctTitle = sr.Account_Title__c;
        System.debug('requestor approverName::'+ req.approverName +'approver id ::'+ req.approverId +'Acct title::'+ req.acctTitle + 'email'+req.approverEmail);
                    brRequestorList.add(req);
            
                    }

                }
                newWrap.brApprovers = brApproverList;
                newWrap.brRequestors = brRequestorList;
                brWrapperList.add(newWrap);
                brCaseCount=newWrap.brCount;
            }
        }
            
    return brWrapperList;    
}
    public class BRWrapper{
        @AuraEnabled
        public string brId;
        @AuraEnabled
        public Integer brCount;
        @AuraEnabled
        public string caseType;
        @AuraEnabled
        public string caseSubType;
        @AuraEnabled
        public string caseReason;
        @AuraEnabled
        public String approval;
        @AuraEnabled
        public string approvalInstructions;
        @AuraEnabled
        public string locationName;
        @AuraEnabled
        public string asset;
        @AuraEnabled
        public string material;
        @AuraEnabled
        public string duration;
        @AuraEnabled
        public string categoryType;
        @AuraEnabled
        public string groupName;
        @AuraEnabled
        public string projectType;
        @AuraEnabled
        public string noOfOccurance;
        @AuraEnabled
        public string multiApprovers;
        @AuraEnabled
        public string brName;
        @AuraEnabled
        public Boolean isApproval;
        @AuraEnabled
    	public string isNTERule;
        @AuraEnabled
        public string recordTypeName;
        @AuraEnabled
        public string alias;
        @AuraEnabled
        public string specialInstruction;
        @AuraEnabled
        public string container;
        @AuraEnabled
        public string channel;
        @AuraEnabled
        public string channelRequirement;
        @AuraEnabled
        public string projectCode;
        @AuraEnabled
        public string locationId;
	@AuraEnabled
	public string companyCategory;
    	@AuraEnabled
        public List<BRApprover> brApprovers; // Added as per BRE-1
        @AuraEnabled
        public List<BRRequestor> brRequestors; // Added as per BRE-1
    }
    
    public class BRApprover{
        @AuraEnabled
        public string approverId;
        @AuraEnabled
        public string approverName;
        @AuraEnabled
        public string recordTypeName;
        @AuraEnabled
        public string approverRecId;
        @AuraEnabled
        public string accTitleName;
        @AuraEnabled
        public Boolean reqOnly;
        @AuraEnabled
        public String serviceType;
        @AuraEnabled
        public String nteAmount;

            @AuraEnabled
            public string approverEmail; // Added as per BRE-1
            @AuraEnabled
            public string acctTitle; // Added as per BRE-1

    }

    //Added as per BRE-1
    public class BRRequestor{
        @AuraEnabled
        public string approverId;
        @AuraEnabled
        public string approverName;
        @AuraEnabled
        public string recordTypeName;
        @AuraEnabled
        public string approverRecId;
        @AuraEnabled
        public string accTitleName;
        @AuraEnabled
        public Boolean reqOnly;
        @AuraEnabled
        public String serviceType;
        @AuraEnabled
        public String nteAmount;

            @AuraEnabled
            public string approverEmail; // Added as per BRE-1
            @AuraEnabled
            public string acctTitle; // Added as per BRE-1

    }
    
    @AuraEnabled
    public static Boolean sendEmail(List<Id> brlst, List<Id> cselst){
        
        List<Messaging.SingleEmailMessage> msgList=new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        
        //Fetch Service Approvers Mail Id's
        List<String> approversEmail = new List<String>();
        Id contactId;
        system.debug('brlst + ' + brlst + 'cselst ;'+ cselst);
        for(Service_Approver__c sa: [SELECT Id, Active__c, Requester_Only__c, Email__c, Approver_Contact__c,
                                     Approver_Contact__r.Preferred_Method__c, Approver_Contact__r.Email,
                                     User__r.Email,User__r.IsActive, Business_Rule__c 
                                     FROM Service_Approver__c WHERE Business_Rule__c IN: brlst AND Active__c = true LIMIT 49999]){
                                         if(sa.Email__c != null){
                                             approversEmail.add(sa.Email__c);    
                                         }
                                         
                                         if((sa.User__r.IsActive) && sa.User__r.Email != null){
                                             approversEmail.add(sa.User__r.Email);    
                                         }
                                         
                                         if(sa.Approver_Contact__c != null 
                                            && sa.Approver_Contact__r.Email != null){
                                                contactId = sa.Approver_Contact__c;
                                                approversEmail.add(sa.Approver_Contact__r.Email);
                                            } 
                                     }
        
        Id templateId; 
        
        for(EmailTemplate e : [SELECT Id, Name FROM EmailTemplate WHERE Name =:TEMPLATE_APPROVAL_REQUEST LIMIT 1]){
            templateId = e.Id;
        }
        
        System.debug('approversEmail ; '+approversEmail);
        if(!approversEmail.isEmpty()){
            if(templateId != null &&  templateId != null ){
                msg = Messaging.renderStoredEmailTemplate(String.valueof(templateId), null, String.valueof(cselst.get(0)));
                if(approversEmail!=null && !approversEmail.isEmpty()){
                    msg.setToAddresses(approversEmail);   
                }
               // msg.setTargetObjectId(contactId);
                msg.setWhatId(cselst.get(0));
                msg.setTemplateId(templateId);
                msg.saveAsActivity = true;
                msgList.add(msg);
                RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = true;
                Messaging.sendEmail(msgList);
                RecurrsiveTriggerHandler.isSkipEmailMessageTrigger = false;
            }
            return true;
        }  else {
            return false;
        }       
    }

    @AuraEnabled
    public static List<Business_Rule__c> getBrRecordsByLocation(String locationId){
        Id parentAccId ;
        set<Id> categoryIdset = new set<Id> ();
        List<Business_Rule__c> brList =  new List<Business_Rule__c>();
        Id businessNotificationRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
        Id approvalRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        for(Account loc: [Select Id,ParentId,Brand__c,Division__c,Geography__c,Location_Type__c from account where Id =:locationId]){
            if(loc.ParentId == null) {
                    List<Business_Rule__c> brRecords = [SELECT Id,Name,Alias__c,Is_Auto_Email__c,Request_Type__c,Service__c,Case_Reason__c,RecordTypeId,
                                                    Special_Instructions_Approval__c, RecordType.Name,Special_Ins__c,LocationId__c,LocationId__r.Name,
                                                    AssetId__c,AssetId__r.Name,Material__c,Schedule_Type__c,Category_Type__c,Container__c,Channel__c,Channel_Req__c, Company_Category__c, //BRE-12 Company Category Added
                                                    Group__c,Group__r.Name,Project_Code__c,Project_Code__r.Name,No_Approval_Required__c, //SDT-31225 No_Approval_Required__c added
                                                    Occurrence_Limit__c,Multiple_Mandatory_Approvers__c,NTE_Rules__c,
                                                    (SELECT Id,Name,RecordType.Name,Approver__c,User__c,User__r.Name,Title__c, Origin__c,
                                                    Account_Title__c,Approver_Contact__c,Approver_Contact__r.Name,Approver_Email__c,ServiceApprover__c,
                                                    Account_Department__c, Requester_Only__c,Approver_Contact__r.Account_Title__r.Name,Service_Type__c,NTE_Amount__c  
                                                    FROM Approver_Entities__r 
                                                    WHERE Active__c = True) 
                                                    FROM Business_Rule__c 
                                                    WHERE Active__c = TRUE  
                                                    AND AccountId__c = :loc.id
                                                    AND RecordTypeId IN (:approvalRecordTypeId,:businessNotificationRecordTypeId) ORDER BY LocationId__c NULLS FIRST];
                return brRecords;
            } else {
                parentAccId = loc.ParentId ;
                if(loc.Brand__c != null){
                    categoryIdset.add(loc.Brand__c);
                }
                 if(loc.Division__c != null){
                    categoryIdset.add(loc.Division__c);
                }
                 if(loc.Geography__c != null){
                    categoryIdset.add(loc.Geography__c);
                }
                 if(loc.Location_Type__c != null){
                    categoryIdset.add(loc.Location_Type__c);
                }
            }   
        }
            for(Business_Rule__c br : [SELECT Id,Name,Alias__c,Is_Auto_Email__c,Request_Type__c,Service__c,Case_Reason__c,RecordTypeId,
                                    Special_Instructions_Approval__c,RecordType.Name,Special_Ins__c,LocationId__c,LocationId__r.Name,
                                    AssetId__c,AssetId__r.Name,Material__c,Schedule_Type__c,Category_Type__c,Container__c,Channel__c,Channel_Req__c,
                                    Group__c,Group__r.Name,Project_Code__c,Project_Code__r.Name, Company_Category__c, //BRE-12 - Company Category Added
                                    Occurrence_Limit__c,Multiple_Mandatory_Approvers__c,NTE_Rules__c,No_Approval_Required__c, //SDT-31225 No_Approval_Required__c added 
                                    (SELECT Id,Name,RecordType.Name,Approver__c,User__c,User__r.Name,Title__c, Origin__c,
                                    Account_Title__c,Approver_Contact__c,Approver_Contact__r.Name,Approver_Email__c,ServiceApprover__c,
                                    Account_Department__c,Requester_Only__c,Approver_Contact__r.Account_Title__r.Name,Service_Type__c,NTE_Amount__c  
                                    FROM Approver_Entities__r 
                                    WHERE Active__c = True) 
                                    FROM Business_Rule__c 
                                    WHERE Active__c = TRUE  
                                    AND AccountId__c = :parentAccId
                                    AND RecordTypeId IN (:approvalRecordTypeId,:businessNotificationRecordTypeId)
                                    ORDER BY LocationId__c NULLS FIRST]){
                                       if((br.LocationId__c != Null && br.LocationId__c == locationId)
                                          || (br.LocationId__c == Null && br.Group__c == NULL) 
                                          || (br.LocationId__c == Null && categoryIdset.size() > 0 && categoryIdset.contains( br.Group__c) ) ){
                                           brList.add(br)  ;
                                       }
                                     
                                   }
       return brList ;
    } 


    //SDT-32090 
    @AuraEnabled
    public static List<BRWrapper> getBrNotificationRecordsByLocation(String locationId){
        List<Business_Rule__c> brRecords = New List<Business_Rule__c> ();
        Id parentAccountId;
        List<Business_Rule__c> brList =  new List<Business_Rule__c>();
        List<BRWrapper> brWrapperList = new List<BRWrapper>();
        Integer brCaseCount = 0;  
        Id businessNotificationRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.BUSINESS_NOTIFICATION).getRecordTypeId();
        for(Account loc: [Select Id,ParentId,Brand__c,Division__c,Geography__c,Location_Type__c from account where Id =:locationId]){
            if(loc.ParentId == null) {
                brRecords = [SELECT Id,Name,Alias__c,Request_Type__c,Service__c,Case_Reason__c,RecordTypeId,Special_Ins__c,
                             LocationId__c,LocationId__r.Name,AssetId__c,AssetId__r.Name,Material__c,Schedule_Type__c,Category_Type__c,
                             Group__c,Group__r.Name,Project_Code__c,Project_Code__r.Name,Container__c,Channel__c,Channel_Req__c, Company_Category__c
                             FROM Business_Rule__c 
                             WHERE Active__c = TRUE  
                             AND AccountId__c = :loc.Id
                             AND RecordTypeId IN (:businessNotificationRecordTypeId)
                             ORDER BY LocationId__c NULLS FIRST];
                
                
            }else{
                List<Business_Rule__c> listwithoutfilter = New List<Business_Rule__c> ();
                parentAccountId = loc.ParentId;
                listwithoutfilter = [SELECT Id,Name,Alias__c,Request_Type__c,Service__c,Case_Reason__c,RecordTypeId,Special_Ins__c,
                                     LocationId__c,LocationId__r.Name,AssetId__c,AssetId__r.Name,Material__c,Schedule_Type__c,Category_Type__c,
                                     Group__c,Group__r.Name,Project_Code__c,Project_Code__r.Name,Container__c,Channel__c,Channel_Req__c, Company_Category__c 
                                     FROM Business_Rule__c 
                                     WHERE Active__c = TRUE  
                                     AND AccountId__c = :parentAccountId
                                     AND RecordTypeId IN (:businessNotificationRecordTypeId)
                                     ORDER BY LocationId__c NULLS FIRST];
                
                for(Business_Rule__c br : listwithoutfilter){
                    if((br.LocationId__c != Null && br.LocationId__c == locationId) ||(br.LocationId__c == Null)) {
                        brRecords.add(br) ;
                    }
                }
                
                
                
            }
            
            
            for(Business_Rule__c br :brRecords){
                BRWrapper newWrap = new BRWrapper();
                newWrap.brId = br.Id;
                newWrap.brCount = brCaseCount+1;
                newWrap.alias = br.Alias__c ;
                newWrap.specialInstruction = br.Special_Ins__c ;
                newWrap.container = br.Container__c ;
                newWrap.brName = String.isNotBlank(br.Alias__c) ? br.Alias__c : br.Name;
                newWrap.caseType = br.Request_Type__c;
                newWrap.caseSubType = br.Service__c;
                newWrap.caseReason = br.Case_Reason__c;
                newWrap.locationName = br.LocationId__c!=null ? br.LocationId__r.Name : '';
                newWrap.asset = br.AssetId__c!=null ? br.AssetId__r.Name : '';
                newWrap.material = br.Material__c;
                newWrap.duration = br.Schedule_Type__c;
                newWrap.categoryType = br.Category_Type__c;
                newWrap.groupName = br.Group__c!=null ? br.Group__r.Name : '';
                newWrap.projectType = br.Project_Code__c!=null ? br.Project_Code__r.Name : '';
                newWrap.channel = br.Channel__c;
                newWrap.companyCategory = br.Company_Category__c;
                newWrap.channelRequirement = br.Channel_Req__c;
                newWrap.projectCode = br.Project_Code__r.Name;
                
                brWrapperList.add(newWrap);
                brCaseCount=newWrap.brCount;
            }
        }   
        return brWrapperList;
        
    }
    //SDT-32090 - to retrieve selected business notification
    @AuraEnabled
    public static List<BRWrapper> getSelectedBrNotification(String locationId,String businessId){
        List<BRWrapper> allBusinessNotification = getBrNotificationRecordsByLocation(locationId);
        List<BRWrapper> selectedBusinessNotification = new List<BRWrapper>();
        for(BRWrapper brNotification:allBusinessNotification){
            if(brNotification.brId == businessId){
                selectedBusinessNotification.add(brNotification);
            }
        }
        return selectedBusinessNotification;
    }    
    
    
}
