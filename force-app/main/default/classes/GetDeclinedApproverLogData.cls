public class GetDeclinedApproverLogData {
    public SBQQ__Quote__c quoteId {get;set;}
    // public String approverName {get;set;}
    public Approval_Log__c decApprovalLg {get;set;}
    
    public Approval_Log__c getApprovalData(){ 
        decApprovalLg = [Select Id, Status__c,Approval_Comments__c, Email__c, Actual_Approver__r.Name, Actual_Approver_Contact__r.Name  from Approval_Log__c where Quote__c =: quoteId.Id AND Status__c = 'Declined' Limit 1];
        return decApprovalLg;
    }
}