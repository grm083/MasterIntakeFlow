public class BusinessRuleUtility {
	//**Overview** A utility class that aides in preparing the data to identify appropriate business rules given a transaction.  It
	//aspires to serve as a central governing body in determining the appropriate fields, the appropriate priorities, and the 
	//most to least-specific rules needed to process a customer transaction.
	//**Problem Statement** Business Rules (approvals, notifications and required information) are difficult to work with and are 
	//decentralized, with code existing on both Case (BusinessRuleHelper) and Quote (QuoteApproval) Interfaces
	//**Author** George R Martin III - gmarti18@wm.com
	//**Date** February 20, 2025
	
	    // Adding a flag for stopping trigger for specific scenarios with BR 
     public static boolean skipTaskTriggerBR = true;
    
    //Constants used throughout the process to reduce variability
    static final String QUERY_INTRO = 'SELECT Id, RecordType.Name';
    //Constant for the type of "in scope" business rules
    static final List<String> BR_TYPES = new List<String>{'Approval', 'Required Information', 'Business Notification'};
    //Constant for the Service Approver portion of the BR Query
    static final String SERVICE_APPROVER_QUERY_STRING = ', (SELECT Id, Name, RecordType.Name, Approver__c, User__c, User__r.Name, Title__c, Account_Title__c, ' +
        'Approver_Contact__c, Approver_Contact__r.Name, Approver_Email__c, ServiceApprover__c,Service_Approver__c.Business_Rule__c,Email__c, Account_Department__c, Requester_Only__c, ' +
        'Approver_Contact__r.Account_Title__r.Name, Service_Type__c, NTE_Amount__c, Origin__c, Fuzzy_Search__c, Approver_Type__c, Account_Team_Member__c,Title__r.Name FROM Approver_Entities__r WHERE Active__c = TRUE) ';
    
    //Invocable method to identify the type of object passed into this class and ultimately how it should be handled
    //The purpose of this class is to provide scalability.  New objects governed by business rules can be added as nodes in
    //the ID switch below and given a dedicated class to populate the custom class and priority	 levels.
    @AuraEnabled
    public static Map<String, List<Business_Rule__c>> getPriorityBusinessRule(Id targetRecord) {
        List<priorityFields> priorityFieldList = new List<priorityFields>();
        
        //Reduce overhead by calling the metadata query once and passing it in as a method variable
        List<Business_Rule_Field_Mapping__mdt> mappedFields = new List<Business_Rule_Field_Mapping__mdt>();
        mappedFields = getFieldMappings();
        //system.debug('mappedFields: ' +mappedFields);
        
        String sObjectType = String.valueOf(targetRecord.getSobjectType());
        switch on sObjectType {
            when 'Case' {
                priorityFieldList = getCaseValues(targetRecord, mappedFields);
            }
            when 'SBQQ__Quote__c' {
                priorityFieldList = getQuoteValues(targetRecord, mappedFields);
            }
            when else {
                //Additional logic can be written as other 'when' nodes to scale to new object types
            }
        }
        
        //system.debug('priorityFieldList::'+priorityFieldList);

        //A list and map are instantiated to provide a full accounting of business rules
        //Conditional queries returns timebound instances of Business Rules + Record Types that are returned as a list
        //The list is then parsed into a map where the key is the record type of business rule
        //These are broken into two functions simply for clarity - one for DML (query) and the other for logic
        List<Business_Rule__c> businessRuleList = new List<Business_Rule__c>();
        Map<String, List<Business_Rule__c>> businessRuleMap = new Map<String, List<Business_Rule__c>>();
        if (priorityFieldList.isEmpty()) return businessRuleMap;
        
        businessRuleList = getBusinessRules(priorityFieldList, mappedFields);
        if (businessRuleList.isEmpty()) return businessRuleMap;

        businessRuleMap = parseBusinessRules(businessRuleList);
        //system.debug('businessRuleMap PARSING::'+businessRuleMap);

        businessRuleMap = prioritizeBusinessRules(priorityFieldList, businessRuleMap);
        //system.debug('businessRuleMap PRIORITIZATION::'+businessRuleMap);

        //Debugging only - will be removed prior to deployment
        for(String key : businessRuleMap.keyset()) {
            for(Business_Rule__c b : businessRuleMap.get(key)) {
                system.debug(key + ' Record Type is ' + b);
            }
        }
        
        return businessRuleMap;
    }
    
    //Major prioritization methods for this class
    public static Map<String, List<Business_Rule__c>> prioritizeBusinessRules(List<priorityFields> mappedFields, Map<String, List<Business_Rule__c>> businessRules){
        
        //Return the prioritized fieldsets for comparative purposes
        List<priorityFieldSets> fieldSets = new List<priorityFieldSets>();
        List<prioritizationResult> priorityResults = new List<prioritizationResult>();
        fieldSets = getPriorityFieldSets();
        
        Map<Id, prioritizationResult> prioritizedMap = new Map<Id, prioritizationResult>();
        Boolean removedItem = false;
        String debugString = '';
        
        //The looping - for each of the categories that we have 
        for (String key : businessRules.keyset()) {
            for(Business_Rule__c b : businessRules.get(key)) {
                if(b.Effective_Date__c <= Date.today() && !b.Active__c) {
                    if(prioritizedMap.get(b.Id) != null) prioritizedMap.remove(b.Id);
                }
                removedItem = false;
                for(Integer i = 0; i < mappedFields.size() && !removedItem; i++) {
                	priorityFields p = mappedFields[i];
                    Integer secondaryPriority = 0;
                    for(priorityFieldSets pfs : fieldSets) {
                        Schema.FieldSet fs = pfs.fieldSet;
                        for(Schema.FieldSetMember f : fs.getFields()) {
                            prioritizationResult pr = new prioritizationResult();
                            if(f.getFieldPath() == 'Category_Type__c') {
                                String categoryType = b.Category_Type__c;
                                String groupId = b.Group__c;
                                String district, geography, locationType, brand;
                                for(priorityFields pri : mappedFields) {
                                    if (pri.commonName == null) continue;
                                    if (pri.objectValue == null) continue;
                                    if (!pri.commonName.startsWith('Category')) continue;
                                    if (prioritizedMap.get(b.Id) != null) pr = prioritizedMap.get(b.Id);
                                    switch on pri.commonName {
                                        when 'Category - Division' {
                                            district = pri.objectValue;
                                        }
                                        when 'Category - Geography' {
                                            geography = pri.objectValue;
                                        }
                                        when 'Category - Location Type' {
                                            locationType = pri.objectValue;
                                        }
                                        when 'Category - Brand' {
                                            brand = pri.objectValue;
                                        }
                                    }
                                }
                                if (groupId != null && district == null && geography == null && locationType == null && brand == null && prioritizedMap.get(b.Id) != null) {
                                    prioritizedMap.remove(b.Id);
                                    removedItem = true;
                                }
                                switch on categoryType {
                                    when 'Division/Department' {
                                        if (groupId == district && groupId != null && (pr.customerRank == null || pr.customerRank > secondaryPriority)) {
                                            pr.businessRuleRecord = b;
                                            pr.customerRank = secondaryPriority;
                                            pr.customerIdentification = true;
                                        } else if (groupId != district && groupId != null && prioritizedMap.get(b.Id) != null) {
                                            prioritizedMap.remove(b.Id);
                                            removedItem = true;
                                        } else if (groupId != district && groupId != null && prioritizedMap.get(b.Id) == null) {
                                            removedItem = true;
                                        }
                                    }
                                    when 'Geography' {
                                        if (groupId == geography && groupId != null && (pr.customerRank == null || pr.customerRank > secondaryPriority)) {
                                            pr.businessRuleRecord = b;
                                            pr.customerRank = secondaryPriority;
                                            pr.customerIdentification = true;
                                        } else if (groupId != geography && groupId != null && prioritizedMap.get(b.Id) != null) {
                                            prioritizedMap.remove(b.Id);
                                            removedItem = true;
                                        } else if (groupId != geography && groupId != null && prioritizedMap.get(b.Id) == null) {
                                            removedItem = true;
                                        }
                                    }
                                    when 'Brand' {
                                        if (groupId == brand && groupId != null && (pr.customerRank == null || pr.customerRank > secondaryPriority)) {
                                            pr.businessRuleRecord = b;
                                            pr.customerRank = secondaryPriority;
                                            pr.customerIdentification = true;
                                        } else if (groupId != brand && groupId != null && prioritizedMap.get(b.Id) != null) {
                                            prioritizedMap.remove(b.Id);
                                            removedItem = true;
                                        } else if (groupId != brand && groupId != null && prioritizedMap.get(b.Id) == null) {
                                            removedItem = true;
                                        }
                                    }
                                    when 'Location Type' {
                                        if (groupId == locationType && groupId != null && (pr.customerRank == null || pr.customerRank > secondaryPriority)) {
                                            pr.businessRuleRecord = b;
                                            pr.customerRank = secondaryPriority;
                                            pr.customerIdentification = true;
                                        } else if (groupId != locationType && groupId != null && prioritizedMap.get(b.Id) != null) {
                                            prioritizedMap.remove(b.Id);
                                            removedItem = true;
                                        } else if (groupId != locationType && groupId != null && prioritizedMap.get(b.Id) == null) {
                                            removedItem = true;
                                        }
                                    }
                                }
                                if(prioritizedMap.get(b.Id) == null && pr.businessRuleRecord != null && !removedItem) {
                                    prioritizedMap.put(b.Id, pr);
                                }
                            } else if(f.getFieldPath() == p.businessRuleField && !p.commonName.startsWith('Category')) {
                                if(p.businessRuleField == 'Container__c') {
                                String assetValue = String.valueOf(p.objectValue); 
                                String ruleValue = String.valueOf(b.get(p.businessRuleField));
    
                                    if (String.isNotBlank(assetValue) && String.isNotBlank(ruleValue)) {
                                        if (!assetValue.toLowerCase().contains(ruleValue.toLowerCase())) {
                            
                                            if(prioritizedMap.get(b.Id) != null) {
                                                prioritizedMap.remove(b.Id);
                                                removedItem = true;
                                            } else {
                                                removedItem = true;
                                            }
                                        }
                                    }

                        } 
                        else if(p.businessRuleField != 'Container__c' && b.get(p.businessRuleField) != p.objectValue && b.get(p.businessRuleField) != null) {
                            if(prioritizedMap.get(b.Id) != null) {
                                //Chandu kari SDT-51136 changes
                                if(p.businessRuleField == 'Service__c'){
                                    if(b.Container__c != 'Haul Away Service'){
                                        prioritizedMap.remove(b.Id);
                                        removedItem = true;
                                    }else if(b.Service__c == 'Permanent'){
                                        prioritizedMap.remove(b.Id);
                                        removedItem = true;
                                    }
                                }else{
                                    prioritizedMap.remove(b.Id);
                                    removedItem = true;
                                }
                                //End
                                    } else {
                                        removedItem = true;
                                    }
                        } 
                                else if(b.get(p.businessRuleField) == p.objectValue || (b.get(p.businessRuleField) == null && p.objectValue != null)) {
                                 //  system.debug('Determining the appropriate secondary rank to apply to this business rule.');
				 //Chandu kari SDT-51136 changes   
                                 if(p.businessRuleField == 'Service__c'){
                                        if(b.Container__c == 'Haul Away Service' && b.Service__c == 'Permanent'){
                                            prioritizedMap.remove(b.Id);
                                            removedItem = true;
                                        } continue;
                                    }
                                    //End
                                    if(prioritizedMap.get(b.Id) != null) {
                                        pr = prioritizedMap.get(b.Id);
                                    }
                                    switch on pfs.fieldSetKey {
                                        when 'priority_1_fields_customer' {
                                            pr.businessRuleRecord = b;
                                            if (b.get(p.businessRuleField) != null && (pr.customerRank == null || pr.customerRank > secondaryPriority)) {
                                                pr.customerRank = secondaryPriority;
                                                pr.customerIdentification = true;
                                            }
                                        } 
                                        when 'priority_2_fields_service' {
                                            pr.businessRuleRecord = b;
                                            if (b.get(p.businessRuleField) != null && (pr.serviceRank == null || pr.serviceRank > secondaryPriority)) {
                                                pr.serviceRank = secondaryPriority;
                                                pr.serviceIdentification = true;
                                            }
                                        }
                                        when 'priority_3_fields_transaction' {
                                            pr.businessRuleRecord = b;
                                            if (b.get(p.businessRuleField) != null && (pr.transactionRank == null || pr.transactionRank > secondaryPriority)) {
                                                pr.transactionRank = secondaryPriority;
                                                pr.transactionIdentification = true;
                                            }
                                        }
                                    }
                                    if(prioritizedMap.get(b.Id) == null) {
                                        prioritizedMap.put(b.Id, pr);
                                    }
                                } 
                            }
                            secondaryPriority += 1;
                        }
                    }
                }
            }
        }	
        
        businessRules.clear();
        
        List<prioritizationResult> sortablePriorities = new List<prioritizationResult>();
        Boolean matchFound = false;
        Integer foundLevel = 7;
        Business_Rule__c b = new Business_Rule__c();
        for(Id key : prioritizedMap.keyset()) {         
            prioritizationResult pr = prioritizedMap.get(key);
            Boolean c = pr.customerIdentification;
            Boolean s = pr.serviceIdentification;
            Boolean t = pr.transactionIdentification;
            if(c && s && t) {
                pr.priorityRank = 0;
            } else if (c && s && !t) {
                pr.priorityRank = 1;
            } else if (c && !s && t) {
                pr.priorityRank = 2;
            } else if (c && !s && !t) {
                pr.priorityRank = 3;
            } else if (!c && s && t) {
                pr.priorityRank = 4;
            } else if (!c && s && !t) {
                pr.priorityRank = 5;
            } else if (!c && !s && t) {
                pr.priorityRank = 6;
            } else {
                pr.priorityRank = 7;
            }
            
            sortablePriorities.add(pr);
        }
        
        PrimaryPriorityCompare sortPrimaryPriority = new PrimaryPriorityCompare();
        CustomerPriorityCompare sortCustomerPriority = new CustomerPriorityCompare();
        ServicePriorityCompare sortServicePriority = new ServicePriorityCompare();
        TransactionPriorityCompare sortTransactionPriority = new TransactionPriorityCompare();
        
        sortablePriorities.sort(sortTransactionPriority);
        sortablePriorities.sort(sortServicePriority);
        sortablePriorities.sort(sortCustomerPriority);
        sortablePriorities.sort(sortPrimaryPriority);
        
        for(prioritizationResult pr : sortablePriorities) {
            List<Business_Rule__c> prioritizedBRList = new List<Business_Rule__c>();
            switch on pr.businessRuleRecord.RecordType.Name {
                when 'Approval' {
                    if (!matchFound) {
                        if(businessRules.get(pr.businessRuleRecord.RecordType.Name) != null) {
                			prioritizedBRList = businessRules.get(pr.businessRuleRecord.RecordType.Name);
                            prioritizedBRList.add(pr.businessRuleRecord);
                            matchFound = true;
                        } else {
                            prioritizedBRList.add(pr.businessRuleRecord);
                            businessRules.put(pr.businessRuleRecord.RecordType.Name, prioritizedBRList);
                            matchFound = true;
                        }
                    }
                }
                when else {
                    if(businessRules.get(pr.businessRuleRecord.RecordType.Name) != null) {
                        prioritizedBRList = businessRules.get(pr.businessRuleRecord.RecordType.Name);
                        prioritizedBRList.add(pr.businessRuleRecord);
                    } else {
                        prioritizedBRList.add(pr.businessRuleRecord);
                        businessRules.put(pr.businessRuleRecord.RecordType.Name, prioritizedBRList);
                    }
                }
            }
        }
        
        return businessRules;
    }


    //Parser method to convert a list of Business Rules into a map of business rules classified by type
    public static Map<String, List<Business_Rule__c>> parseBusinessRules(List<Business_Rule__c> businessRuleList) {
        
        Map<String, List<Business_Rule__c>> businessRuleMap = new Map<String, List<Business_Rule__c>>();
        
        for(Business_Rule__c b : businessRuleList) {
            List<Business_Rule__c> parsedList = new List<Business_Rule__c>();
            if (BR_TYPES.contains(b.RecordType.Name)) {
		//Simplified structure to reduce total line count, and added a check for active service approvers for Approval types
                if(businessRuleMap.get(b.RecordType.Name) != null)  parsedList = businessRuleMap.get(b.RecordType.Name);
                if(b.RecordType.Name == 'Approval' && !b.No_Approval_Required__c && (b.Approver_Entities__r == null || b.Approver_Entities__r.size()  == 0)) continue;
                parsedList.add(b);
                businessRuleMap.put(b.RecordType.Name, parsedList);
            }
            
        }
        
        return businessRuleMap;
    }
    
    /* 
	There are going to be multiple "getter" methods needed for this class.  Primarily they can be
	broken into three categories - getting case details, getting business rule details, and
	getting quote details.

	getBusinessRules utilizes similar inputs to the main method in this class - requiring the list of 
	fields for each object, the custom metadata for dynamic query, and the record type/process being
	invoked.

	Case Values and Quote Values only require the record Id and the list of custom metadata for dynamic
	query per object
	*/
    public static List<Business_Rule__c> getBusinessRules(List<priorityFields> priorityObject, List<Business_Rule_Field_Mapping__mdt> mappedFields) {
        List<Business_Rule__c> businessRuleList = new List<Business_Rule__c>();
        
        String queryString = QUERY_INTRO;
        Set<String> targetFields = new Set<String>();
        for(Business_Rule_Field_Mapping__mdt field : mappedFields) {
            targetFields.add(field.Business_Rule__c);
        }
        
        for(String s : targetFields) {
            queryString += ', ' + s;
        }
        
        queryString += SERVICE_APPROVER_QUERY_STRING;
        
        queryString += ' FROM Business_Rule__c Where Active__c = true ';
        
        Boolean queryStringFlag = false ;
        //On Business Rule, there are only two fields that receive a special treatment - account and effective date
        //These are handled as per the below in all circumstances prior to prioritization
        for(priorityFields f : priorityObject) {
            if (f.objectValue == null && f.commonName == 'Account Name') {
                return new List<Business_Rule__c>(); //This is to ensure that we're returning a blank list of business rules to exit the prioritization logic when case values are not of a certain caliber
            } else if (f.objectValue != null) {
                switch on f.commonName {
                    when 'Effective Date' {
                        if(f.objectValue == null) { // Not reachable code
                            queryString += ' AND Active__c = true ';
                        }
                        Date d = Date.valueOf(f.objectValue);
                        queryString += ' AND '+f.businessRuleField +  ' <= :d';
                        queryString += ' AND (End_Date__c >= :d OR End_Date__c = null) ';
                        queryStringFlag = true;
                    }
                    when 'Account Name' {
                        if(f.objectValue == null) {// Not reachable code
                            return businessRuleList;
                        }
                        String s = String.valueOf(f.objectValue);
                        queryString += 'AND '+ f.businessRuleField + ' = :s ';
                        queryStringFlag = true;
                    }
                    when else { // default block, optional
                        system.debug('when else');
                    }
                }
            }
        }

        if( !queryStringFlag ){
            queryString += 'LIMIT 1';
        }
        
        system.debug('queryString '+queryString);
        system.debug('queryString no');
        businessRuleList = Database.Query(queryString);
        
        return businessRuleList;
    }
    
    public static List<priorityFields> getCaseValues(Id caseId, List<Business_Rule_Field_Mapping__mdt> mappedFields) {
        //In order to construct the appropriate set of fields  
        List<priorityFields> caseFields = new List<priorityFields>();
        
        //As part of this acivity we want to construct a very specific query to return a case record with appropriate lookups
        //that can be used for the custom class Priority Fields and prevent the need for excessive or supplemental queries
        //further down the process.  This will be accomplished using the metadata records and Database.Query functions
        String queryString = QUERY_INTRO; //Select id, RecordType.Name
        
        //As some fields may be measured against similar items, we need to place these fields in a set to remove duplicates
        Set<String> targetFields = new Set<String>();
        
        for(Business_Rule_Field_Mapping__mdt field : mappedFields) {
            if(field.Case__c != null) targetFields.add(field.Case__c);
        }
        
        for(String s : targetFields) {
            queryString += ', ' + s;
        }
        
        //Finish the query string with FROM and WHERE clauses
        queryString += ' FROM Case WHERE Id = :caseId LIMIT 1';
        system.debug(queryString);
        
        sObject qCase = Database.query(queryString);
        
        for(Business_Rule_Field_Mapping__mdt field : mappedFields) {
            priorityFields priorityInstance = new priorityFields();
            
            Integer countOfRelationships = -1;
            if(field.Case__c != null) countOfRelationships = field.Case__c.countMatches('.');
            
            switch on countOfRelationships {
                when 0 {
                    if(field.MasterLabel == 'Account Name' && (String.valueOf(qCase.get(field.Case__c)) == null || String.valueOf(qCase.get(field.Case__c)) == '')) return new List<priorityFields>();
                    priorityInstance.priorityLevel = field.Priority_Value__c;
                    priorityInstance.commonName = field.MasterLabel;
                    priorityInstance.businessRuleField = field.Business_Rule__c;
                    priorityInstance.objectValue = String.valueOf(qCase.get(field.Case__c));
                    system.debug(priorityInstance);
                }
                when 1 {
                    String[] splitString = field.Case__c.split('\\.',2);
                    priorityInstance.priorityLevel = field.Priority_Value__c;
                    priorityInstance.commonName = field.MasterLabel;
                    priorityInstance.businessRuleField = field.Business_Rule__c;
                    try{
                    	priorityInstance.objectValue = String.valueOf(qCase.getSobject(splitString[0]).get(splitString[1]));
                    } catch (exception e) {
                        
                    }
                    system.debug(priorityInstance);
                }
                when 2 {
                    String[] splitString = field.Case__c.split('\\.',2);
                    priorityInstance.priorityLevel = field.Priority_Value__c;
                    priorityInstance.commonName = field.MasterLabel;
                    priorityInstance.businessRuleField = field.Business_Rule__c;
                    try{
                    	priorityInstance.objectValue = String.valueOf(qCase.getSobject(splitString[0]).getSobject(splitString[1]).get(splitString[2]));
                    } catch (exception e) {
                        
                    }
                    system.debug(priorityInstance);
                }
                when 3 {
                    String[] splitString = field.Case__c.split('\\.',2);
                    priorityInstance.priorityLevel = field.Priority_Value__c;
                    priorityInstance.commonName = field.MasterLabel;
                    priorityInstance.businessRuleField = field.Business_Rule__c;
                    try{
                    	priorityInstance.objectValue = String.valueOf(qCase.getSobject(splitString[0]).getSobject(splitString[1]).getSobject(splitString[2]).get(splitString[3]));
                    } catch (exception e) {
                        
                    }
                    system.debug(priorityInstance);
                }
                when else {
                    
                }
            }
            
            caseFields.add(priorityInstance);
        }
        
        return caseFields;
    }
    
    public static List<priorityFields> getQuoteValues(Id quoteId, List<Business_Rule_Field_Mapping__mdt> mappedFields) {
        List<priorityFields> quoteFields = new List<priorityFields>();
        QuoteProcurementController.ProductsWrapper productDesignations = new QuoteProcurementController.ProductsWrapper();
        
        productDesignations = QuoteProcurementController.buildQuoteWrapper(quoteId);
        
        for (QuoteProcurementController.HeaderWrapper hw : productDesignations.configuredProducts) {
            for (Business_Rule_Field_Mapping__mdt field : mappedFields) {
                system.debug('The field is ' + field.Business_Rule__c + ' which is compared against the node ' + field.Quote__c + ' and the quote value is ' + (String)hw.getField(field.Quote__c));
                priorityFields priorityInstance = new priorityFields();
                priorityInstance.priorityLevel = field.Priority_Value__c;
                priorityInstance.commonName = field.MasterLabel;
                priorityInstance.businessRuleField = field.Business_Rule__c;
                priorityInstance.objectValue = (String)hw.getField(field.Quote__c);
                quoteFields.add(priorityInstance);
            }
        }
        
        return quoteFields;
    }
    
	//Method to dynamically retrieve field sets created for the Business Rule object.  This method is intentionally
	//written to be not specific to predefined field set names in the event that these values change in the future.
	//However, it does require that all field sets returned contain the sub-string 'priority' in order to be considered.
    public static List<priorityFieldSets> getPriorityFieldSets() {
        List<priorityFieldSets> pFields = new List<priorityFieldSets>();
        Map<String, Schema.FieldSet> fieldSetMap = Schema.SobjectType.Business_Rule__c.fieldSets.getMap();
        
        //Iterate and store the returned field sets when they contain the word "Priority" in a list of field sets
        for (String key : fieldSetMap.keySet()){
            if(key.contains('priority') && !key.contains('0')) {
                priorityFieldSets pfs = new priorityFieldSets();
                pfs.fieldSetKey = key;
                pfs.fieldSet = fieldSetMap.get(key);
                pFields.add(pfs);
            }
        }
        
        //Return the field set custom class for iteration in other classes
        return pFields;
    }
    
    //Method to return the custom metadata object that contains the field level mappings for each object that is
    //govered by the Business Rule object.  If new objects are added to be governed by Business Rules, we will add
    //new field to the MDT, and the below SELECT statement should be updated to include those new fields.
    public static List<Business_Rule_Field_Mapping__mdt> getFieldMappings() {
        List<Business_Rule_Field_Mapping__mdt> fieldMapping = new List<Business_Rule_Field_Mapping__mdt>();
        
        fieldMapping = [SELECT MasterLabel, Priority_Value__c, Business_Rule__c, Case__c, Quote__c 
                       FROM Business_Rule_Field_Mapping__mdt
                       ORDER BY Priority_Value__c ASC];
        
        return fieldMapping;
    }
    
    //The class to store the list of field sets that are needed to prioritize the returned business rules
    public class priorityFieldSets {
        @AuraEnabled
        public string fieldSetKey {get; set;}
        @AuraEnabled
        public Schema.FieldSet fieldSet {get; set;}
    }
    //The class to store the list of fields that are needed to filter the returned business rules
    public class priorityFields {
        @AuraEnabled
        public string priorityLevel {get; set;}
        @AuraEnabled
        public string commonName {get; set;}
        @AuraEnabled
        public string businessRuleField {get; set;}
        @AuraEnabled
        public string objectValue {get; set;}
    }
    
    //The class to store the prioritization results
    public class prioritizationResult {
        
        private final prioritizationResult pr;
        
        //List of attributes
        @AuraEnabled
        public Business_Rule__c businessRuleRecord {get; set;}
        @AuraEnabled
        public Boolean customerIdentification {get; set;}
        @AuraEnabled
        public Boolean serviceIdentification {get; set;}
        @AuraEnabled
        public Boolean transactionIdentification {get; set;}
        @AuraEnabled
        public Integer priorityRank {get; set;}
        @AuraEnabled
        public Integer customerRank {get; set;}
        @AuraEnabled
        public Integer serviceRank {get; set;}
        @AuraEnabled
        public Integer transactionRank {get; set;}
        
        //Constructor
        public prioritizationResult(Business_Rule__c businessRuleRecord, Boolean customerIdentification, 
                                    Boolean serviceIdentification, Boolean transactionIdentification, 
                                    Integer priorityRank, Integer customerRank, Integer serviceRank, Integer transactionRank) {
                                        this.businessRuleRecord = businessRuleRecord;
                                        this.customerIdentification = customerIdentification;
                                        this.serviceIdentification = serviceIdentification;
                                        this.transactionIdentification = transactionIdentification;
                                        this.priorityRank = priorityRank;
                                        this.customerRank = customerRank;
                                        this.serviceRank = serviceRank;
                                        this.transactionRank = transactionRank;
        }
        
        //Simplified Constructor (default values)
        public prioritizationResult() {
            this.businessRuleRecord = null;
            this.customerIdentification = false;
            this.serviceIdentification = false;
            this.transactionIdentification = false;
            this.priorityRank = null;
            this.customerRank = null;
            this.serviceRank = null;
            this.transactionRank = null;
        }
        
        //Return methods for sorting
        public Integer getPriorityRank() {return priorityRank;}
        public Integer getCustomerRank() {return customerRank;}
        public Integer getServiceRank() {return serviceRank;}
        public Integer getTransactionRank() {return transactionRank;}
        
    }
    
    public class PrimaryPriorityCompare implements Comparator<prioritizationResult> {
        public Integer compare(prioritizationResult p1, prioritizationResult p2) {
            Integer returnValue = 0;
            
            Integer p1p = p1.priorityRank, p2p = p2.priorityRank;
            
            if ((p1p == null && p2p == null) || (p1p == p2p)) returnValue = 0;
            if ((p1p != null && p2p == null) || (p1p > p2p)) returnValue = 1;
            if ((p1p == null && p2p != null) || (p1p < p2p)) returnValue = -1;
            
            return returnValue;
            
        }
    }
    
    public class CustomerPriorityCompare implements Comparator<prioritizationResult> {
        public Integer compare(prioritizationResult p1, prioritizationResult p2) {
            Integer returnValue = 0;
            
            Integer p1p = p1.customerRank, p2p = p2.customerRank;
            
            if ((p1p == null && p2p == null) || (p1p == p2p)) returnValue = 0;
            if ((p1p != null && p2p == null) || (p1p > p2p)) returnValue = 1;
            if ((p1p == null && p2p != null) || (p1p < p2p)) returnValue = -1;
            
            return returnValue;
            
        }
    }
    
    public class ServicePriorityCompare implements Comparator<prioritizationResult> {
        public Integer compare(prioritizationResult p1, prioritizationResult p2) {
            Integer returnValue = 0;
            
            Integer p1p = p1.serviceRank, p2p = p2.serviceRank;
            
            if ((p1p == null && p2p == null) || (p1p == p2p)) returnValue = 0;
            if ((p1p != null && p2p == null) || (p1p > p2p)) returnValue = 1;
            if ((p1p == null && p2p != null) || (p1p < p2p)) returnValue = -1;
            
            return returnValue;
            
        }
    }
    
    public class TransactionPriorityCompare implements Comparator<prioritizationResult> {
        public Integer compare(prioritizationResult p1, prioritizationResult p2) {
            Integer returnValue = 0;
            
            Integer p1p = p1.transactionRank, p2p = p2.transactionRank;
            
            if ((p1p == null && p2p == null) || (p1p == p2p)) returnValue = 0;
            if ((p1p != null && p2p == null) || (p1p > p2p)) returnValue = 1;
            if ((p1p == null && p2p != null) || (p1p < p2p)) returnValue = -1;
            
            return returnValue;
            
        }
    }
    
}
