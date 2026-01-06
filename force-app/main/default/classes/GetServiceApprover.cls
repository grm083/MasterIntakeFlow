/*************************************************************
@Name: GetServiceApprover
@Author: DineshKumar S
@CreateDate: 07/02/2019
@Description: This class is used to fetch the Service Approver for the Respective Task.
@UsedBy: GetApproverDetails
**************************************************************/
public without sharing class GetServiceApprover {
    /* This method is used to fetch the Service Approver for the Respective Task.
    * @owner : DineshKumar S
    * @param : TaskId
    */
        @AuraEnabled
        public static List<ServiceApproverWrapper> getApprover(Id taskId){
            List<Service_Approver__c> salst = new List<Service_Approver__c>();
            List<ServiceApproverWrapper> srAprWrapList = new List<ServiceApproverWrapper>();
            try{
                Task tsk = [SELECT id,Approval_Log__c,Business_Rule__c,Approver_Name__c,Approval_Log__r.Approver_Type__c
                            FROM Task WHERE Id =:taskId LIMIT 1];
                string approverType = tsk.Approval_Log__r.Approver_Type__c;
                If(string.IsBlank(approverType) ){
                    salst = [SELECT Id,Name,Approver_Type__c,Approver__c,Approver_Email__c,Approver_Phone__c,
                             user__r.Name,Approver_Contact__c,Approver_Contact__r.Name,Origin__c 
                             FROM Service_Approver__c WHERE Business_Rule__c =: tsk.Business_Rule__c and Active__c = true and Requester_Only__c = false LIMIT 49999];
                } else If( (approverType).contains(Constant_Util.HYPHEN)){
                    List<string> descrp = approverType.split(Constant_Util.HYPHEN);
                    salst = [SELECT Id,Name,Approver_Type__c,Approver__c,Approver_Email__c,Approver_Phone__c,
                             user__r.Name,Approver_Contact__c,Approver_Contact__r.Name, Origin__c 
                             FROM Service_Approver__c WHERE Business_Rule__c =: tsk.Business_Rule__c 
                             AND Approver_Type__c =:descrp [0] AND id =: descrp[1] and Active__c = true and Requester_Only__c = false LIMIT 49999];
                }else{
                    //Novafix
                }
                system.debug('tsk.Business_Rule__c : ' + tsk.Business_Rule__c);
                 
                Map<String,Out_of_Office__c> mapOOOApprovers = BusinessRuleCtrl.getBRsApproversDetails(new Set<Id>{tsk.Business_Rule__c});
                if(mapOOOApprovers!=null && !mapOOOApprovers.isEmpty()){
                    for(Service_Approver__c srAppr : salst){
                        String uniqueKey;
                        String type = 'Email';
                        String approverName = '';
                        String approverEmail = '';
                        String approverPhone = '';
                        if(srAppr.user__c!=null && srAppr.user__r.Name !=null){
                            uniqueKey = srAppr.user__c;
                        } else if(srAppr.Approver_Contact__c!=null && srAppr.Approver_Contact__r.Name!=null){
                            uniqueKey = srAppr.Approver_Contact__c;
                        } else{
                            uniqueKey = srAppr.Approver_Email__c;
                        } 
                        ServiceApproverWrapper wrap = new ServiceApproverWrapper();
                        if(mapOOOApprovers!=null && mapOOOApprovers.ContainsKey(uniqueKey) ){
                            Out_of_Office__c ooo =  mapOOOApprovers.get(uniqueKey);
                            if(ooo != null && ooo.New_User_Approver__c != null && String.valueOf(ooo.New_User_Approver__c).startsWith('005')){
                                type = 'User';
                                approverName = ooo.New_User_Approver__r.Name;
                                approverEmail = ooo.New_User_Approver__r.Email;
                            } else if(ooo != null && ooo.New_Contact_Approver__c != null && String.valueOf(ooo.New_Contact_Approver__c).startsWith('003')){
                                type = 'Contact';
                                approverName = ooo.New_Contact_Approver__r.Name;
                                approverEmail = ooo.New_Contact_Approver__r.Email;
                                approverPhone = ooo.New_Contact_Approver__r.Phone;
                            } else {
                                type = 'Email';
                                approverName = ooo.New_Email_Approver__c;
                                approverEmail = ooo.New_Email_Approver__c;
                            }
                            wrap.Approver = approverName;
                            wrap.ApproverType = type;
                            wrap.ApproverEmail = approverEmail; 
                            wrap.ApproverPhone = String.isNotBlank(approverPhone) ? approverPhone : '';
                            srAprWrapList.add(wrap);
                        } else {
                            wrap.Approver = srAppr.Approver__c;
                            wrap.ApproverType = srAppr.Approver_Type__c != 'Origin' ? srAppr.Approver_Type__c:
                                srAppr.Approver_Type__c+'-'+ srAppr.Origin__c ;
                            wrap.ApproverEmail = srAppr.Approver_Email__c; 
                            wrap.ApproverPhone = srAppr.Approver_Phone__c;
                            srAprWrapList.add(wrap);
                        }
                    }
                    
                }else{
                    for(Service_Approver__c srAppr : salst){
                        ServiceApproverWrapper wrap = new ServiceApproverWrapper();
                        wrap.Approver = srAppr.Approver__c;
                        wrap.ApproverType = srAppr.Approver_Type__c != 'Origin' ? srAppr.Approver_Type__c:
                                srAppr.Approver_Type__c+'-'+ srAppr.Origin__c ;
                        wrap.ApproverEmail = srAppr.Approver_Email__c; 
                        wrap.ApproverPhone = srAppr.Approver_Phone__c;
                        srAprWrapList.add(wrap);
                    }
                }
            }
            catch(Exception e){
                System.debug('@@@ Ex : @@ : ' + e.getMessage());
            }
            return srAprWrapList;
            //return salst;
        }
        
        public class ServiceApproverWrapper{
            @AuraEnabled
            public String Approver;
            @AuraEnabled
            public String ApproverType;
            @AuraEnabled
            public String ApproverEmail;
            @AuraEnabled
            public String ApproverPhone;
        }
        /*
    * This method is used to fetch WhatId of the respective case.
    * @owner : DineshKumar S
    * @param : TaskId
    */
        @AuraEnabled
        public static string getcaseId(Id taskId){
            Id caseId = null;
            try{
                caseId = [Select Id,WhatId from Task where Id =: taskId Limit 1].WhatId;
            }
            catch (Exception e){
                // Novacop fix
            }
            return string.valueOf(caseId); 
           
        }
    }