public class SendBusinessRuleData {
    public static void businessRuleData() {
        // Query for business rule Business Rules
        List<Business_Rule__c> BusinessRuleList = [
            SELECT Id, Name, RecordTypeId, AccountId__c, Account_Group_Location_Project_Asset__c,EffectiveDate_RecordType_Active__c ,
            Active__c, Container__c, Effective_Date__c, End_Date__c, LocationId__c, Request_Type__c,
            Required_Information__c, Schedule_Type__c, Service__c, Alias__c, AssetId__c,Case_Reason__c,
            Category_Type__c, Channel_Req__c, Channel_Requirements__c, Channel__c, Group__c,
            Is_Channel_Requirements__c, Is_Special_Instructions__c,
            Multiple_Mandatory_Approvers__c, Occurrence_Limit__c, Process__c, Project__c,
            Role__c, Special_Ins__c, Special_Instructions__c,
            No_Approval_Required__c, Project_Code__c,
            Material__c, Special_Instructions_Approval__c, Is_Auto_Email__c,
            Object_Type__c, NTE_Rules__c,
            (SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, CreatedDate, Business_Rule__c, Account__c,
             Account_Team_Member__c, Account_Title__c, Approver_Contact__c, Location__c,
             Approver_Type__c, Approver__c, External_Approver_Email__c, External_Approver_Name__c,
             External_Approver_Phone_Number__c, Preferred_Method__c,
             Title__c, Approver_Email__c, Approver_Phone__c, Email__c,
             User__c, Department__c, ServiceApprover__c, SortBy__c, Active__c, Requester_Only__c,
             Request_Type_Service__c, is_Auto_Email__c, NTE_Amount__c, Fuzzy_Search__c,
             Service_Type__c, NTE_Rule_ExtId__c FROM Approver_Entities__r
            )
            FROM Business_Rule__c 
            WHERE Request_Type__c = 'Pickup'
            and Service__c = 'Haul Away - No Equipment' and Active__c = true
            
        ];
        // Total number of records fetched from the query
        system.debug('BusinessRuleList' + BusinessRuleList.size());
        
        List<Business_Rule__c> HaulBusinessRule = new List<Business_Rule__c>();
        List<Service_Approver__c> HaulServiceApprover = new List<Service_Approver__c>();
        // Get duplicate BR records
        List<Business_Rule__c> DuplicateBR = findDuplicateRecords(BusinessRuleList);
        system.debug('DuplicateBR' + DuplicateBR.size());
        system.debug('DuplicateBR' + DuplicateBR);
        // Get Unique BR records
        List<Business_Rule__c> UniqueBR = findUniqueRecords(BusinessRuleList);
        system.debug('UniqueBR' + UniqueBR.size());
        system.debug('UniqueBR' + UniqueBR);
        
        // Prepare HaulBusinessRule for Unique records
        for (Business_Rule__c BR1 : UniqueBR) {
            BR1.Service__c = 'Temporary';
            BR1.Request_Type__c = 'New Service';
            BR1.Container__c = 'Haul Away Service';
            BR1.Schedule_Type__c = 'Temporary';
            BR1.Effective_Date__c = Date.today();
            BR1.id = null; 
            HaulBusinessRule.add(BR1);
        }
        // Size before inserting BR records.
        system.debug('Size' + HaulBusinessRule.size());
        
        // Insert HaulBusinessRule
        if (!HaulBusinessRule.isEmpty()) {
            system.debug('Size' + HaulBusinessRule.size());
            insertRecords(HaulBusinessRule, 'HaulBusinessRule');
        }
        List<Business_Rule__c> InsertedBRule = [
            SELECT Id, Active__c
            FROM Business_Rule__c 
            WHERE Service__c = 'Temporary'
            and Request_Type__c = 'New Service' and Container__c = 'Haul Away Service' and Schedule_Type__c = 'Temporary'
            and Effective_Date__c = TODAY and Active__c = true   
        ];
        //number of records of inserted Business rules
        system.debug('Inserted BR' + InsertedBRule.size());
        Integer Counter = 0;
        
        // create HaulServiceApprover
        for (Business_Rule__c BR2 : UniqueBR) {
            for (Service_Approver__c SA1 : BR2.Approver_Entities__r) {
                
                SA1.id = null; 
                SA1.Business_Rule__c = HaulBusinessRule[Counter].id;
                SA1.Location__c = BR2.LocationId__c;
                SA1.Account__c = BR2.AccountId__c;
                HaulServiceApprover.add(SA1);
            }
            Counter++;
        }
        //Size before inserting HaulServiceApprover records.
        System.debug('Size before inserting HaulServiceApprover records.' + HaulServiceApprover.size());
        
        if (!HaulServiceApprover.isEmpty()) {
            
            insertRecords(HaulServiceApprover, 'HaulServiceApprover');
        }
        List<Service_Approver__c> InsertedServiceApprover = [
            SELECT Id, Active__c
            FROM Service_Approver__c 
            WHERE Business_Rule__r.Service__c = 'Temporary'
            and Business_Rule__r.Request_Type__c = 'New Service' and Business_Rule__r.Container__c = 'Haul Away Service' 
            and Business_Rule__r.Schedule_Type__c = 'Temporary'
            and Business_Rule__r.Effective_Date__c = TODAY and Active__c = true   
        ];
        //numberof records of inserted service approvers
        system.debug('InsertedServiceApprover' + InsertedServiceApprover.size());
        
        
        // Logic for email with old and new service approvers==>
        
        String BusinessRuleData = JSON.Serialize(BusinessRuleList); //-> Email fetched records
        String newHaulBusinessRule = JSON.Serialize(HaulBusinessRule); //-> Email new inserted business rule
        String newHaulServiceApprover = JSON.Serialize(HaulServiceApprover); //-> Email new inserted service approvers
        String ExistingDuplicateBR = JSON.Serialize(DuplicateBR); //-> Email duplicate rule available in org
        List<User> user = [select Id, Email, FirstName,  IsActive from User where IsActive = true and Id = :UserInfo.getUserId() LIMIT 1];
        system.debug('Email data -->' + user);
        
        //subject and body of the email
        String subject = ' Existing Business Rule Data and New Business Rule Data';
        String body = 'Hi ' + user[0].FirstName + ',' +
            '\n\n I hope this email finds you well.' +
            '\n\n Please find the existing Business Rule data and new Business Rule data regarding HaulAway.' 
            +'\n\n\n\n These are the new Business Rule data for Haul Away product:- \n\n\n\n' + newHaulBusinessRule +
            '\n\n\n\n These are Service approvers data for new business rules based on existing business rules:- \n\n\n\n'
            + newHaulServiceApprover + 
            '\n\n\n\n These are existing duplicate business rules in the ORG:- \n\n\n\n' + ExistingDuplicateBR
            + '\n\n\n\n Thanks & regards' +
            +'\n WM Dev-Team';
        
        
        // Create a new SingleEmailMessage object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { user[0].Email });
        email.setSubject(subject);
        email.setPlainTextBody(body);
        email.setReplyTo(user[0].Email);  
        email.setSenderDisplayName('WM Dev-Team');  
        
        try {
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }, false);  
            System.debug('Email successfully sent to: '+ user[0].FirstName + '->' + user[0].Email);
        } catch (Exception e) {
            System.debug('Failed to send email to: ' + user[0].Email + ' due to: ' + e.getMessage());
            
        }
    }
    
    private static void insertRecords(List<SObject> records, String recordType) {
        List<Id> insertedIds = new List<Id>();  // List to track inserted Ids
        List<Id> failedIds = new List<Id>();    // List to track failed record IDs
        Database.SaveResult[] results = Database.insert(records, false);  // Insert with partial insertion
        
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                insertedIds.add(result.getId());
            } 
            else {
                System.debug('Insert failed for ' + recordType + ': ' + result.getErrors()[0].getMessage());
                
                // Collect the IDs of the records that failed
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error: ' + error.getMessage());
                }
                
                failedIds.add(records[results.indexOf(result)].Id);  // Add the failed record's ID
                System.debug(failedIds);
                System.debug('failedIds' +failedIds.size());
                System.debug('Successfully inserted ' + recordType + ' records: ' + insertedIds.size() + '-->' + insertedIds);
                
                return;  
                
            }
            
        }
        String insertedId = 'Inserted records : ' + JSON.Serialize(insertedIds); // inserted Ids
        String failedId = 'Failed records : ' + JSON.Serialize(failedIds); // failed inserted records
        //String insertionError = 'Insert failed for ' + recordType + ': ' + result.getErrors()[0].getMessage();
        
        
        
        //Email logic for the error and inserted data===>
        
        List<User> user = [select Id, Email, FirstName,  IsActive from User where IsActive = true and Id = :UserInfo.getUserId() LIMIT 1];
        system.debug('Email data -->' + user);
        
        String subject = ' Existing Business Rule Data and New Business Rule Data';
        String body = 'Hi ' + user[0].FirstName + ',' +
            '\n\n I hope this email finds you well.' +
            '\n\n Error Message =>' 
            +
            '\n\n\n\n These are the succesfully inserted Ids before the error:- \n\n\n\n'
            + insertedId +
            '\n\n\n\n These are the record ids which did not insert :- \n\n\n\n'
            + failedId
            + '\n\n\n\n Thanks & regards' +
            +'\n WM Dev-Team';
        
        
        // Create a new SingleEmailMessage object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { user[0].Email});
        email.setSubject(subject);
        email.setPlainTextBody(body);
        email.setReplyTo(user[0].Email);  
        email.setSenderDisplayName('WM Dev-Team');  
        
        try {
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            System.debug('Email successfully sent to: '+ user[0].FirstName + '->' + user[0].Email);
        } catch (Exception e) {
            System.debug('Failed to send email to: ' + user[0].Email + ' due to: ' + e.getMessage());
            
        }
        
        
    }
    
    public static List<Business_Rule__c> findDuplicateRecords(List<Business_Rule__c> rules) {
        List<Business_Rule__c> duplicates = new List<Business_Rule__c>();
        Set<String> keyFields = new Set<String>(); // To store concatenated unique key values for each record
        
        // Iterate through the provided list of rules
        for (Business_Rule__c rule : rules) {
            // Create a unique key based on relevant fields
            String key = rule.Account_Group_Location_Project_Asset__c + '-' + rule.EffectiveDate_RecordType_Active__c + '-' + rule.Container__c +
                '-' + rule.Schedule_Type__c + '-' + rule.Service__c + '-' + rule.Request_Type__c +
                '-' + rule.Category_Type__c + '-' + rule.Case_Reason__c + '-' + rule.Material__c;
            
            // Debugging the key to see if it is right
            System.debug('Generated Key: ' + key);
            
            // Check if the key does NOT already exist in the set 
            if (!keyFields.contains(key)) {
                // If it's not a duplicate, add the key to the set
                keyFields.add(key);
            } else {
                // If it's a duplicate, add it to the duplicates list
                duplicates.add(rule);
            }
        }
        
        // Output the size of duplicates list
        System.debug('Number of duplicates: ' + duplicates.size());
        return duplicates;
    }
    
    public static List<Business_Rule__c> findUniqueRecords(List<Business_Rule__c> rules) {
        List<Business_Rule__c> uniqueRecords = new List<Business_Rule__c>();
        Set<String> keyFields = new Set<String>(); 
        
        // Iterate through the provided list of rules
        for (Business_Rule__c rule : rules) {
            // Create a unique key based on relevant fields
            String key = rule.Account_Group_Location_Project_Asset__c + '-' + rule.EffectiveDate_RecordType_Active__c + '-' + rule.Container__c +
                '-' + rule.Schedule_Type__c + '-' + rule.Service__c + '-' + rule.Request_Type__c +
                '-' + rule.Category_Type__c + '-' + rule.Case_Reason__c + '-' + rule.Material__c;
            
            // Debugging the key to see if it is right
            System.debug('Generated Key: ' + key);
            
            // If the key is not already in keyFields, it's unique so far
            if (!keyFields.contains(key)) {
                // If it's unique, add it to the uniqueRecords list
                uniqueRecords.add(rule);
                // Add the key to the set so that duplicates won't be added later
                keyFields.add(key);
            }
        }
        
        // Output the size of unique records list
        System.debug('Number of unique records: ' + uniqueRecords.size());
        return uniqueRecords;
    }
    
    
    
    
}