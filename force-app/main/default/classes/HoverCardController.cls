/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class HoverCardController {
    
    @AuraEnabled(cacheable=true)
    public static FieldWrapper getFields(String objectApiName, String fieldSetName) {
        try{
            List<String> fieldDescriptions = new List<String>(); 
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectApiName);
            Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
            Map<String,Schema.FieldSet> fieldSetObj = describeSObjectResultObj.FieldSets.getMap();
            Schema.FieldSet aFieldSet = fieldSetObj.get(fieldSetName);
            FieldWrapper fWrapper = new FieldWrapper();
            if(aFieldSet != null && aFieldSet.getFields() != null && !aFieldSet.getFields().isEmpty()){
                fWrapper.masterField =  aFieldSet.getFields()[0].getFieldPath();
                for(Integer i = 1 ; i < aFieldSet.getFields().size() ; i++) {
                    Schema.FieldSetMember f = aFieldSet.getFields()[i];
                    fieldDescriptions.Add(f.getFieldPath());
                } 
            }
            fWrapper.fieldData = fieldDescriptions;
            //system.assert(false , fWrapper);
            return fWrapper;
        }
        catch(Exception e){
            throw new AuraHandledException('Error occurred: ' + e.getMessage());
        }
        
    }
    
    
    @AuraEnabled(cacheable=true)
    public static TaskWrapper getTaskRecord(String taskId){
        try {    
            List<Task> tsk = [Select Id, Subject, Status, Outcome__c, Description, Description__c , Owner.Name, CreatedBy.Name, LastModifiedBy.Name, ActivityDate FROM Task WHERE Id = :taskId LIMIT 1];
            TaskWrapper tWrapper = new TaskWrapper();
            
            if(tsk != null && !tsk.isEmpty()){
                Task t = tsk[0];
                tWrapper.status = t.Status != null ? t.Status : Constant_Util.EMPTY_STRING;
                tWrapper.subject = t.Subject != null ? t.Subject : Constant_Util.EMPTY_STRING;
                tWrapper.activityDate = t.ActivityDate != null ? t.ActivityDate.format() : Constant_Util.EMPTY_STRING;
                tWrapper.lastModifiedBy = t.LastModifiedBy.Name != null ? t.LastModifiedBy.Name : Constant_Util.EMPTY_STRING;
                tWrapper.createdBy = t.CreatedBy.Name != null ? t.CreatedBy.Name : Constant_Util.EMPTY_STRING;
                tWrapper.owner = t.Owner.Name != null ? t.Owner.Name : Constant_Util.EMPTY_STRING;
                tWrapper.description = t.Description__c != null ? (t.Description__c.length() > 50 ? t.Description__c.subString(0 , 50) + '...' : t.Description__c) : Constant_Util.EMPTY_STRING;
                tWrapper.comment = t.Description != null ? (t.Description.length() > 50 ? t.Description.subString(0 , 50) + '...' : t.Description) : Constant_Util.EMPTY_STRING;
                tWrapper.outcome = t.Outcome__c != null ? t.Outcome__c : Constant_Util.EMPTY_STRING;
            }
            return tWrapper;
        }
        catch(Exception e){
            throw new AuraHandledException('Error occurred: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static EmailMessageWrapper getEmailMessageRecord(String emailMsgId){
        try {    
            List<EmailMessage> emailMsg = [SELECT Id , ToAddress, FromName, Subject, FromAddress, CcAddress, Status, MessageDate, HtmlBody FROM EmailMessage WHERE Id = :emailMsgId LIMIT 1];
            EmailMessageWrapper emailMessageWrapper = new EmailMessageWrapper();
            Map<String,String> mapEmailStatus = new Map<String,String>{'0'=>'New','1'=>'Read','2'=>'Replied','3'=>'Sent','4'=>'Forwarded','5'=>'Draft'};
                if(emailMsg != null && !emailMsg.isEmpty()){
                    EmailMessage e = emailMsg[0];
                    String emailStatus = null;   
                    if(mapEmailStatus.containsKey(e.status)){
                        emailStatus = mapEmailStatus.get(e.status);
                    }
                    
                    emailMessageWrapper.status = e.Status != null ? emailStatus : Constant_Util.EMPTY_STRING;
                    emailMessageWrapper.subject = e.Subject != null ? e.Subject : Constant_Util.EMPTY_STRING;
                    emailMessageWrapper.fromName = e.FromName != null ? e.FromName : Constant_Util.EMPTY_STRING;
                    emailMessageWrapper.fromAddress = e.FromAddress != null ? e.FromAddress : Constant_Util.EMPTY_STRING;
                    emailMessageWrapper.ccAddress = e.CcAddress != null ? e.CcAddress : Constant_Util.EMPTY_STRING;
                    emailMessageWrapper.messageDate = e.MessageDate != null ? e.MessageDate.format() : Constant_Util.EMPTY_STRING;
                    emailMessageWrapper.toAddress = e.ToAddress != null ? e.ToAddress : Constant_Util.EMPTY_STRING;
                    emailMessageWrapper.htmlBody = e.htmlBody != null ? e.htmlBody : Constant_Util.EMPTY_STRING;
                    
                }
            return emailMessageWrapper;
        }
        catch(Exception e){
            throw new AuraHandledException('Error occurred: ' + e.getMessage());
        }
    }
    
    public class FieldWrapper{
        @AuraEnabled
        public List<String> fieldData{get; set;}
        @AuraEnabled
        public String masterField{get; set;}
    }
    
    public class TaskWrapper{
        @AuraEnabled
        public String status{get; set;}
        @AuraEnabled
        public String subject{get; set;}
        @AuraEnabled
        public String activityDate{get; set;}
        @AuraEnabled
        public String createdBy{get; set;}
        @AuraEnabled
        public String lastModifiedBy{get; set;}
        @AuraEnabled
        public String description{get; set;}
        @AuraEnabled
        public String comment{get; set;}
        @AuraEnabled
        public String owner{get; set;}
        @AuraEnabled
        public String outcome{get; set;}
    }
    
    public class EmailMessageWrapper{
        @AuraEnabled
        public String status{get; set;}
        @AuraEnabled
        public String subject{get; set;}
        @AuraEnabled
        public String fromName{get; set;}
        @AuraEnabled
        public String fromAddress{get; set;}
        @AuraEnabled
        public String ccAddress{get; set;}
        @AuraEnabled
        public String messageDate{get; set;}
        @AuraEnabled
        public String toAddress{get; set;}
        @AuraEnabled
        public String htmlBody{get; set;}
    }
    
}