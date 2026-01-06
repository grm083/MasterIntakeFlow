public without sharing class UI_customLookUpController {
     @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String caseId) {
        String searchKey = searchKeyWord + '%';
        String sQuery;
        Id accountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId(); 
        List < sObject > returnList = new List < sObject > ();
        if(ObjectName.containsIgnoreCase('User') && string.isNotBlank(caseId)){
            case caseRec = [Select Id, Tracking_Number__c FROM Case where Id =:caseId ];
            if(caseRec.Tracking_Number__c == Null){
                 sQuery =  'select id,User_categorization_code__c, Name, Email from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND User_categorization_code__c !=NUll AND IsActive = true order by createdDate DESC limit 5'; 
            }else{
                 sQuery =  'select id,User_categorization_code__c, Name, Email from ' +String.escapeSingleQuotes(ObjectName) + ' where Name LIKE: searchKey AND IsActive = true order by createdDate DESC limit 5'; 
            }
        }else if(ObjectName.containsIgnoreCase('Account')){
            sQuery =  'select id, Name from ' +String.escapeSingleQuotes(ObjectName) + ' where RecordTypeId =: accountRTId AND Name LIKE: searchKey order by createdDate DESC limit 5'; 
        }
               // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}