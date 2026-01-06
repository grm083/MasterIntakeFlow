/**
 * @description   : Get NTE Approval Business Rules
 * @Created Date  : 06-11-2023
**/
public class NTEBRRulesModalCtrl {
    
    @AuraEnabled
    public static List<BRWrapper> getBRData(String caseRT,String accountId,String locationId, String caseType, String caseSubType, String caseReason){
        List<BRWrapper> brWrapperList = new List<BRWrapper>();
        Integer brCaseCount = 0;  
        Id approvalRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        List<Business_Rule__c> brList = getBrRecordsByLocation(accountId,locationId,caseType,caseSubType);
        System.debug('caseRT : ' + caseRT + ' accountId : ' + accountId + ' locationId : ' + locationId);
        System.debug('caseType : ' + caseType + ' caseSubType : ' + caseSubType + ' caseReason : ' + caseReason);
         System.debug('brList : ' + brList );
        for(Business_Rule__c br : brList){
			List<BRApprover> brApproverList = new List<BRApprover>();        
            if(((!br.Approver_Entities__r.isEmpty()))
               && caseRT == 'Pickup Case'
               && ( String.isNotBlank(br.Request_Type__c) && br.Request_Type__c == 'Pickup' && br.Request_Type__c == caseType )
               && ( String.isNotBlank(br.Service__c) && (br.Service__c.equals('Bulk') || br.Service__c.equals('Haul Away - No Equipment')) && br.Service__c == caseSubType )
                )
                {
                    system.debug('br :: ' + br);
                    BRWrapper newWrap = new BRWrapper();
                    newWrap.brId = br.Id;
                    newWrap.brCount = brCaseCount+1;
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
                    for(Service_Approver__c sr : br.Approver_Entities__r){
                        BRApprover apr = new BRApprover();
                        apr.approverId = sr.Id;
                        apr.approverName = sr.Approver_Contact__r.Name!=null ? sr.Approver_Contact__r.Name : 
                            sr.Account_Title__c!=null ? sr.Account_Title__c : 
                            sr.User__c !=null ? sr.User__r.Name :  
                         	sr.Account_Department__c !=null ? sr.Account_Department__c : 
                         	sr.RecordType.Name =='NTE Approval' ? sr.Name : sr.Approver__c;
                        apr.recordTypeName = sr.RecordType.Name;
                        apr.approverRecId = sr.Approver_Contact__c!=null ? sr.Approver_Contact__c : 
                            sr.Title__c!=null ? sr.Title__c : 
                            sr.User__c !=null ? sr.User__c : sr.Id;
                        apr.accTitleName = sr.Approver_Contact__c!=null && sr.Approver_Contact__r.Account_Title__c !=null ? sr.Approver_Contact__r.Account_Title__r.Name : 
                            sr.Account_Title__c!=null ? sr.Account_Title__c : '';
                        apr.reqOnly = sr.Requester_Only__c;
                        apr.serviceType = sr.Service_Type__c;
                        apr.nteAmount =  String.valueOf(sr.NTE_Amount__c);
                        brApproverList.add(apr);
                    }
                    System.debug('Serv brApproverList :: ' + brApproverList);
                    newWrap.brApprovers = brApproverList;
                    brWrapperList.add(newWrap);
                    brCaseCount=newWrap.brCount;
                }
            }
        return brWrapperList;    
    }
    
    public static List<Business_Rule__c> getBrRecordsByLocation(String accountId,String locationId,String caseType, String caseSubType){
        Id approvalRecordTypeId = Schema.SObjectType.Business_Rule__c.getRecordTypeInfosByName().get(Constant_Util.APPROVAL).getRecordTypeId();
        List<Business_Rule__c> brRecords = [SELECT Id,Name,Alias__c,AccountId__c,Request_Type__c,Service__c,Case_Reason__c,RecordTypeId,
                                                    Special_Instructions_Approval__c,LocationId__c,LocationId__r.Name,
                                                    AssetId__c,AssetId__r.Name,Material__c,Schedule_Type__c,Category_Type__c,
                                                    Group__c,Group__r.Name,Project_Code__c,Project_Code__r.Name,
                                                    Occurrence_Limit__c,Multiple_Mandatory_Approvers__c,NTE_Rules__c,No_Approval_Required__c, //SDT-31225 No_Approval_Required__c added
                                                        (SELECT Id,Name,RecordType.Name,Approver__c,User__c,User__r.Name,Title__c,
                                                        Account_Title__c,Approver_Contact__c,Approver_Contact__r.Name,Approver_Email__c,ServiceApprover__c,
                                                        Account_Department__c, Requester_Only__c,Approver_Contact__r.Account_Title__r.Name,Service_Type__c,NTE_Amount__c  
                                                        FROM Approver_Entities__r 
                                                        WHERE Active__c = True) 
                                                    FROM Business_Rule__c 
                                                    WHERE Active__c = TRUE  
                                            		AND NTE_Rules__c = TRUE 
                                            		AND AccountId__c =:accountId        
                                            		AND LocationId__c =:locationId
                                            		AND Request_Type__c =: caseType
                                            		AND Service__c =: caseSubType
                                                    AND RecordTypeId =: approvalRecordTypeId];
        System.debug('brRecords : ' + brRecords);
                return brRecords;

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
        public List<BRApprover> brApprovers;
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
    }
    
}