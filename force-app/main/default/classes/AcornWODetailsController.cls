/* 
* Apex Class : AcornWODetailsController
* Description : This class is used for AcornWODetails LWC
* Developer : Arvind Kumar
* Date : 30/June/2021
* Edit Comments :
*/
public with sharing class AcornWODetailsController {
    @AuraEnabled(cacheable=true)
    public static string getWorkOrderDetails(Id quoteId){
        List<SBQQ__Quote__c> quoteList = [Select Id,Acorn_Work_Order_Details__c from SBQQ__Quote__c where Id =: quoteId];
        return quoteList[0].Acorn_Work_Order_Details__c;
    }
}