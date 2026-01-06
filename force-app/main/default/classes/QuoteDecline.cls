/*
Author: Rishiraj Singh
Requirement Id/Story: SDT-20076
FC: Anmoal Bharti
Module: Asset Management/Quote Lifecycle
Description: Class would be used to perform actions when Quote would be on Declined status.
-----------------------------------------------------------------
Story             Sprint             Modified By           Description
SDT-20076         AM-MVP3            Rishi                 Created createEmailMessage() to send one time notification to user when Declined.
*/
public with sharing class QuoteDecline {

    public static Messaging.SingleEmailMessage createEmailMessage(Id quoteId, Id templateId, Id contactId, Id fromAddressId){
    
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactId);
        mail.setTemplateId(templateId);
        //mail.setToAddresses(toAddresses);
        mail.setWhatId(quoteId);
        mail.setOrgWideEmailAddressId(fromAddressId);
        mail.setTreatTargetObjectAsRecipient(true);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);
        mails.add(mail);
        try{
            Messaging.sendEmail(mails);
        } catch(Exception e){
            System.debug(e);
        }
        return mail;
    }

    /*
    *Developer  : Aliasgher
    *Description : SDT-20835 This method is used to send Declined Quote Notification
    *Test Coverage: QuoteDeclineTest class.
    *Date : 9/6/2022
    */
    public static void sendDeclineQuoteNotification(Id quoteId)
    {
        System.debug('<------------In sendDeclineQuoteNotification---------->');

        EmailTemplate template = [SELECT Id FROM emailTemplate WHERE DeveloperName = 'Declined_Quote_Email_Template'];
        
        //Changes for SDT-26208
        List<OrgWideEmailAddress> oweaList = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: Constant_Util.EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.PS_EMAIL_TO_QUOTE OR DisplayName =: Constant_Util.CANADA_VRM_EMAIL_TO_QUOTE ORDER BY DisplayName ASC];
        SBQQ__Quote__c quoteRec = [SELECT Id,SBQQ__PrimaryContact__c,SBQQ__PrimaryContact__r.Email,LastModifiedBy.UserName,LastModifiedBy.Genesys_Enabled__c,Priority__c
        ,LastModifiedById,SBQQ__Account__r.Parent.Customer_Code__c,SBQQ__Account__r.Location_Code__c,SBQQ__Account__r.tz__Timezone__c,SBQQ__Opportunity2__r.Case__r.CaseNumber
        ,SBQQ__Opportunity2__r.Case__r.Reference_Number__c,SBQQ__Opportunity2__r.Case__r.Case_Type__c,SBQQ__Opportunity2__r.Case__r.Case_Reason__c,SBQQ__Opportunity2__r.Case__r.createdby.userRole.name
        ,SBQQ__Account__r.Parent.Primary_Segment__c,SBQQ__Opportunity2__r.Case__r.Asset.Project_Code__c,SBQQ__Status__c,Next_Action_Due_Date__c,Project__c, Project_Services_Request__c
        , CreatedBy.userRole.name, SBQQ__ShippingCountry__c  FROM SBQQ__Quote__c WHERE Id =: quoteId];
        
        System.debug('quoteRec data---------->' + quoteRec);

        if(quoteRec != null)
        {
            //Changes for SDT-26208
            if(!String.isempty(quoteRec.SBQQ__ShippingCountry__c) && quoteRec.SBQQ__ShippingCountry__c == Constant_Util.Canada_Shipping_Country)
            {
                QuoteDecline.createEmailMessage(quoteRec.Id, template.Id, quoteRec.SBQQ__PrimaryContact__c, oweaList[2].Id);
            } 
            else{
                if( ( (quoteRec.CreatedBy.userRole != null && quoteRec.CreatedBy.userRole.name.startsWithIgnoreCase('Project Service'))
                || quoteRec.SBQQ__Account__r.Parent.Primary_Segment__c == 'Construction and Demolition' || quoteRec.Project__c != null 
                || quoteRec.Project_Services_Request__c) && quoteRec.SBQQ__PrimaryContact__c!=null && quoteRec.SBQQ__PrimaryContact__r.Email !=null)
                {
                    QuoteDecline.createEmailMessage(quoteRec.Id, template.Id, quoteRec.SBQQ__PrimaryContact__c, oweaList[1].Id);
                }
                
                else if(quoteRec.SBQQ__PrimaryContact__c!=null && quoteRec.SBQQ__PrimaryContact__r.Email !=null)
                {
                    QuoteDecline.createEmailMessage(quoteRec.Id, template.Id, quoteRec.SBQQ__PrimaryContact__c, oweaList[0].Id);
                }
            }
        }
    }
}