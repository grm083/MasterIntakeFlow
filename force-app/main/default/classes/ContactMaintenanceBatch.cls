global class ContactMaintenanceBatch implements Database.Batchable<sObject>,Database.Stateful,schedulable{

    private static string  query = 'Select Id, Name, Contact_Status__c, Last_Activity_Date__c, CreatedDate,  Phone, Location__c, Account.RecordType.Name from Contact WHERE Account.RecordType.Name != \'Supplier\' AND FirstName != \'Unspecified\'';

    public Database.QueryLocator start(Database.BatchableContext batchVariable) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new ContactMaintenanceBatch(),2000);   
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
        List<Contact> updateContacts = New List<Contact>();
        Set<Id> contactSet = new Set<Id>();
        Map<Id,Service_Approver__c> conActiveApproverMap = New Map<Id,Service_Approver__c>();

        try{
            for(Contact c : scope){
                contactSet.add(c.id);
            }

            for(Service_Approver__c sa : [SELECT Id, Business_Rule__c, Business_Rule__r.Active__c, Approver_Contact__c, Approver_Contact__r.Contact_Status__c FROM Service_Approver__c WHERE Approver_Contact__c IN :contactSet]){
                if(sa.Business_Rule__r.Active__c){
                    conActiveApproverMap.put(sa.Approver_Contact__c,sa);
                }
            }
            
            for(Contact c : scope){
                Date createdDateValue = date.newinstance(c.CreatedDate.year(),c.CreatedDate.month(),c.CreatedDate.day());
                //Date lastActivityDateValue = date.newinstance(c.Last_Activity_Date__c.year(),c.Last_Activity_Date__c.month(),c.Last_Activity_Date__c.day());

                if(!conActiveApproverMap.containsKey(c.id) && c.Contact_Status__c == 'Active' && (c.Last_Activity_Date__c==null && createdDateValue.daysBetween(Date.Today())>90) || (c.Last_Activity_Date__c != null && date.newinstance(c.Last_Activity_Date__c.year(),c.Last_Activity_Date__c.month(),c.Last_Activity_Date__c.day()).daysBetween(Date.Today())>90)){
                    c.Contact_Status__c = 'Inactive';
                    updateContacts.add(c);
                }else if(c.Contact_Status__c == 'Inactive' && c.Last_Activity_Date__c != null && date.newinstance(c.Last_Activity_Date__c.year(),c.Last_Activity_Date__c.month(),c.Last_Activity_Date__c.day()).daysBetween(Date.Today())<90){
                    c.Contact_Status__c = 'Active';
                    updateContacts.add(c);
                }
            }

            if(!updateContacts.isEmpty()){
                Database.SaveResult[] svRes = Database.update(updateContacts,false); 
            }
        }catch(Exception e){
            UTIL_LoggingService.logHandledException(e, UserInfo.getOrganizationId(), UTIL_ErrorConstants.ERROR_APPLICATION,LoggingLevel.ERROR);
        }
    }

    /*@MethodName finish - **/ 
    public void finish(Database.BatchableContext batchVariable) {

    } 
}