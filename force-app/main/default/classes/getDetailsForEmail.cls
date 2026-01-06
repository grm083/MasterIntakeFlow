/**
* @author WM
* @date 10/9/2020
* @description : Apex Class for GetApproverName Visuaforce Component
**/

public with sharing class getDetailsForEmail {
    
    
    public Case cseDetail {get;set;}
       
    public String getApproverName(){
        
        String approverName;       
        List<Approval_Log__c>appLog = [Select id,Status__c,Approver_Type__c,Actual_Approver__c,Actual_Approver__r.FirstName,Actual_Approver__r.LastName,Actual_Approver_Contact__c,Actual_Approver_Contact__r.Name,Actual_Approver_Email__c,Actual_Approver_Title__c,Actual_External_Approver_Name__c from Approval_Log__c where CaseId__c =:cseDetail.id ];
        
        if(appLog != null){
        for(Approval_Log__c acl:appLog){
            if(acl.Status__c == 'Approved'){
                if(String.isNotBlank(acl.Actual_Approver_Contact__c)){
                    approverName= acl.Actual_Approver_Contact__r.Name;
                }
                else if(String.isNotBlank(acl.Actual_Approver__c)){
                   approverName=+ acl.Actual_Approver__r.FirstName+''+acl.Actual_Approver__r.LastName;                    
                }   
                else if(String.isNotBlank(acl.Actual_External_Approver_Name__c)){
                   approverName=+acl.Actual_External_Approver_Name__c;                    
                }  
                else if(String.isNotBlank(acl.Actual_Approver_Title__c)){
                   approverName=+ acl.Actual_Approver_Title__c;                    
                }  
                else if(String.isBlank(acl.Actual_Approver_Contact__c) && String.isNotBlank(acl.Actual_Approver_Email__c)){
                   approverName=+ acl.Actual_Approver_Email__c;                    
                } 
            } 
          } 
        }     
        	return approverName;
        }
      }