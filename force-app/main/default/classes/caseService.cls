public with sharing class caseService {
    
    public inherited sharing class CaseSuccess{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<WorkOrder> dupList = new List<WorkOrder>();
        @AuraEnabled public List<Case> childCases = new List<Case>();
    }
    
    
    public static CaseSuccess createMultipleCasesInvoke(string caseRecId) {
         //System.debug('createMultipleCasesInvokee>>>');
        list<case> caseList= new list<case>();
        DateTime slaDateTime = null;
      
        CaseSuccess wrap = new CaseSuccess();
        try{
            Case selectedCase = [SELECT id, SLA_Service_Date_Time__c,Chargeable__c, SLA_Service_DateTime__c,Is_MultiCase_TaskBundling__c, AccountId,CaseNumber,Case_Information__c,Override_PO_Create_Task__c,User_Input_Work_Order_Instructions__c,recordTypeId, Location__c, Reference_Number__c, AssetId, Client__c, ContactId,Case_Type__c,Case_Sub_Type__c,Case_Reason__c,Origin,Emergency__c,Site_Contact__c,Site_Contact_Phone__c,SalesMeet_Container_Position__c,Supplier__c,PurchaseOrder_Number__c,PSI__c,Profile_Number__c,PSI_Required__c,Override_Profile_Number_Task__c,PurchaseOrder_Required__c,SLA_Override_Reason__c,/*Work_Order_Instructions__c,*/isMultiCalendarChecked__c,
                                 Company_Category__c,Override_Company_Category_Create_Task__c 
                                 FROM Case 
                                 WHERE id=:caseRecId]; 
            //System.debug('>>>selectedCase-->'+ selectedCase );
         Id standardRecType = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Standard Case').getRecordTypeId();
        Case newCase= new case();
                newCase = selectedCase.clone(false, false, false, false);
        //newCase.Check_Case__c = false;
         newCase.ParentId = selectedCase.Id; 
         newCase.Is_Clone__c = true;
         newCase.RecordTypeId = standardRecType;
         newCase.Case_Type__c = 'General';
         newCase.Case_Sub_Type__c = 'Other';
         newCase.Case_Reason__c = 'All Other Inquiries';
         newCase.Chargeable__c = selectedCase.Chargeable__c;
         caseList.add(newCase);      
            if(!caseList.isEmpty()){
                insert caseList;
                for(Case caseObj : caseList){
                    copyEmailToChildCase(selectedCase.Id,caseObj);
                    createObtainInternalRespoTask(caseObj.id);
                    
                }
            }
         
            wrap.success = true;
            return wrap;
        }catch(Exception ex){  // Catch block to catch error messages  
            wrap.success = false;
            wrap.message = ex.getMessage()+'\n'+ex.getStackTraceString();
            return wrap;
        }
    }
    
     public static void createObtainInternalRespoTask(String whatId){
        case caseRec = [Select Id,CheckReassignment__c, Tracking_Number__c FROM Case where Id =:whatId ];
         User u = [SELECT Id, name from user where name = 'Compliance Team' limit 1];
        caseRec.CheckReassignment__c = true;
        update caseRec;
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Initiate_Task').getRecordTypeId();
        //  Initiate_Task
        Boolean sfdcTeamuserAssingment = false ;
        Boolean createGeneysisRouting = false ;
        Boolean updateTaskOwner = false ;
        String userGrServiceFlag = null ;
        Task ObtainInternalRespoTask = new Task();
        ObtainInternalRespoTask.RecordTypeId = recordTypeId ;
          ObtainInternalRespoTask.OwnerId = u.Id ;
        ObtainInternalRespoTask.Subject = 'Obtain Internal Response' ;
        ObtainInternalRespoTask.Description = 'test' ;
        ObtainInternalRespoTask.Process__c = 'Case Assignment' ;
        ObtainInternalRespoTask.WhatId = whatId;
        ObtainInternalRespoTask.Due_Date_Time__c = system.now() ;
        ObtainInternalRespoTask.ActivityDate = date.valueOf(system.now());
        insert ObtainInternalRespoTask ; 
       
    }
    
     public static void copyEmailToChildCase(string recordId, Case caseObj){
        List<EmailMessage> updatedEmailList = new List<EmailMessage>();
        List<EmailMessage> emailList = [SELECT id,Subject,FromAddress,HtmlBody,TextBody,ToAddress,ParentId,RelatedToId from EmailMessage where ParentId =: recordId LIMIT 49999];
        if(emailList.size()>0) {
            for(EmailMessage email : emailList){
                EmailMessage newEmail= new EmailMessage();
                newEmail = email.clone(false, false, false, false);
                newEmail.ParentId = caseObj.Id;
                newEmail.RelatedToId = caseObj.Id;
                updatedEmailList.add(newEmail);                    
            }
        }else{}
        try {
            database.insert(updatedEmailList);
        } catch(Exception e) {
            System.debug('Exception ::: '+ e.getMessage()+' '+e.getLineNumber());
        }
                    
    }
}