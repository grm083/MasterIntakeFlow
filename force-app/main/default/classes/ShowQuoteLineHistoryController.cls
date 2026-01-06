public with sharing class ShowQuoteLineHistoryController {
   @AuraEnabled
   public static List<Quote_Line_History_Tracking__c> getQuoteLineHistories(Id quoteId) {
       List<Quote_Line_History_Tracking__c> histories = [SELECT Action__c,Product_Name__c,Quote_Line_Number__c,Quote_Number__c,User_Name__c,CreatedDate
                                                FROM Quote_Line_History_Tracking__c
                                                WHERE Quote_Id__c = :quoteId ORDER BY Timestamp__c DESC];
       return histories;
   }
}