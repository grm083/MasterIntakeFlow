/**
* @author Devendra Patel
* @date 08/23/2020
* @description : Wrapper class for Notification Tracking Data
**/
public with sharing class NotifTrackingWrapper{
  
     
    @AuraEnabled public String contactName;
    @AuraEnabled public String emailAddPhoneNum;
    @AuraEnabled public String emailSMSType;
    @AuraEnabled public String emailSubBody;
    @AuraEnabled public String imageURL;
    @AuraEnabled public String messageType;
    @AuraEnabled public String dateTimeSent;
    @AuraEnabled public String status;
     @AuraEnabled public String contactId;
    @AuraEnabled public String phoneNumber;
    @AuraEnabled public String emailAddress;
  
    

}