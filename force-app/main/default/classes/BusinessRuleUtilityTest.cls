@IsTest
public class BusinessRuleUtilityTest {

    //Test Class for the BusinessRuleUtility class
    //Author: George R Martin III, WM
    //Date: March 16, 2025
    
    @IsTest
    public static void TestPriorityFieldSets() {
        
        //Test of public class priorityFieldSets on BusinessRuleUtility
        Map<String, Schema.FieldSet> fieldSetMap = Schema.SobjectType.Business_Rule__c.fieldSets.getMap();
        Schema.FieldSet testFieldSet;
        String fieldSetMapKey;
        for(String key : fieldSetMap.keyset()) {
            fieldSetMapKey = key;
            testFieldSet = fieldSetMap.get(key);
        }
        BusinessRuleUtility.priorityFieldSets testPFS = new BusinessRuleUtility.priorityFieldSets();
        String testFieldSetKey = 'Test Field Set Key';
        testPFS.fieldSetKey = testFieldSetKey;
        testPFS.fieldSet = testFieldSet;
        
        System.assertEquals(testPFS.fieldSetKey, testFieldSetKey);
        System.assertEquals(testPFS.fieldSet, testFieldSet);
    }
    
    @IsTest
    public static void TestPriorityFields() {
        
        //Test of public class priorityFields on BusinessRuleUtility
        BusinessRuleUtility.priorityFields testPF = new BusinessRuleUtility.priorityFields();
        testPF.priorityLevel = 'TestPriority';
        testPF.commonName = 'TestName';
        testPF.businessRuleField = 'TestBRField__c';
        testPF.objectValue = 'TestObjectValue';
        
        System.assertEquals(testPF.priorityLevel, 'TestPriority');
        System.assertEquals(testPF.commonName, 'TestName');
        System.assertEquals(testPF.businessRuleField, 'TestBRField__c');
        System.assertEquals(testPF.objectValue, 'TestObjectValue');
        
        List<BusinessRuleUtility.priorityFieldSets> testPFS = new List<BusinessRuleUtility.priorityFieldSets>();
        testPFS = BusinessRuleUtility.getPriorityFieldSets();
        
        system.assertNotEquals(testPFS.size(), 0);
    }
    
    @IsTest
    public static void TestPrioritizationResult() {
        
        //Test of public class prioritizationResult on BusinessRuleUtility
        Business_Rule__c br = new Business_Rule__c();
        Boolean customerIdentificationTest1 = false;
        Boolean serviceIdentificationTest1 = false;
        Boolean transactionIdentificationTest1 = false;
        Boolean customerIdentificationTest2 = true;
        Boolean serviceIdentificationTest2 = true;
        Boolean transactionIdentificationTest2 = true;
        Integer priorityRankTest1 = 5;
        Integer priorityRankTest2 = 0;
        Integer customerRankTest1 = 1;
        Integer customerRankTest2 = 0;
        Integer serviceRankTest1 = 5;
        Integer serviceRankTest2 = 6;
        Integer transactionRankTest1 = 11;
        Integer transactionRankTest2 = 15;
        
        BusinessRuleUtility.prioritizationResult testPR1 = new BusinessRuleUtility.prioritizationResult();
        BusinessRuleUtility.prioritizationResult testPR2 = new BusinessRuleUtility.prioritizationResult(br, customerIdentificationTest1, serviceIdentificationTest1,
                                                                                                       transactionIdentificationTest1, priorityRankTest1,
                                                                                                       customerRankTest1, serviceRankTest1, transactionRankTest1);
        BusinessRuleUtility.prioritizationResult testPR3 = new BusinessRuleUtility.prioritizationResult(br, customerIdentificationTest2, serviceIdentificationTest2,
                                                                                                       transactionIdentificationTest2, priorityRankTest2,
                                                                                                       customerRankTest2, serviceRankTest2, transactionRankTest2);
        
        //Testing constructors
        System.assertEquals(testPR1.businessRuleRecord, null);
        System.assertEquals(testPR2.businessRuleRecord, br);
        System.assertEquals(testPR2.getCustomerRank(), customerRankTest1);
        System.assertEquals(testPR2.getServiceRank(), serviceRankTest1);
        System.assertEquals(testPR2.getTransactionRank(), transactionRankTest1);
        System.assertEquals(testPR2.getPriorityRank(), priorityRankTest1);
        
        //Testing sort functions
        List<BusinessRuleUtility.prioritizationResult> testPRList = new List<BusinessRuleUtility.prioritizationResult>();
        testPRList.add(testPR2);
        testPRList.add(testPR3);
        
        //Primary Sort Index
        BusinessRuleUtility.PrimaryPriorityCompare primarySort = new BusinessRuleUtility.PrimaryPriorityCompare();
        testPRList.sort(primarySort);
        system.assertEquals(testPRList[0].getPriorityRank(), priorityRankTest2);
        
        //Customer Sort Index
        BusinessRuleUtility.CustomerPriorityCompare customerSort = new BusinessRuleUtility.CustomerPriorityCompare();
        testPRList.sort(customerSort);
        system.assertEquals(testPRList[0].getCustomerRank(), customerRankTest2);
        
        //Service Sort Index
        BusinessRuleUtility.ServicePriorityCompare serviceSort = new BusinessRuleUtility.ServicePriorityCompare();
        testPRList.sort(serviceSort);
        system.assertEquals(testPRList[0].getServiceRank(), serviceRankTest1);
        
        //Transaction Sort Index
        BusinessRuleUtility.TransactionPriorityCompare transactionSort = new BusinessRuleUtility.TransactionPriorityCompare();
        testPRList.sort(transactionSort);
        system.assertEquals(testPRList[0].getTransactionRank(), transactionRankTest1);
    }
    
    @IsTest
    public static void testCustomMetadata() {
        List<Business_Rule_Field_Mapping__mdt> testFieldMapping = new List<Business_Rule_Field_Mapping__mdt>();
        testFieldMapping = BusinessRuleUtility.getFieldMappings();
        system.assertNotEquals(testFieldMapping.size(), 0);
    }

    @IsTest
    public static void testGetPriorityBusinessRule_Case() {
        List<Case> cases = TestDataFactory.createNewCase();
        insert cases;
        Case c = cases[0];
        Map<String, List<Business_Rule__c>> result = BusinessRuleUtility.getPriorityBusinessRule(c.Id);
    }

    @IsTest
    public static void testGetPriorityBusinessRule_Quote() {
        Profile adminProfile = TestDataFactory.getProfile('System Administrator');
        User testUser = TestDataFactory.createUser(adminProfile);
        List<Account> accounts = TestDataFactory.createAccount('Test Client', testUser);
        Account clientAcc = accounts[0];
        List<Contact> contacts = TestDataFactory.createContact('Test', 'Contact', clientAcc, testUser);
        Contact testContact = contacts[0];
        List<Opportunity> opportunities = TestDataFactory.createOpportunity(1, 'Test Opportunity', null, 'Temporary', clientAcc.Id);
        insert opportunities;
        List<SBQQ__Quote__c> quotes = TestDataFactory.createQuoteRecords(opportunities, clientAcc, testContact, Date.today(), false, false);
        insert quotes;
        SBQQ__Quote__c q = quotes[0];
        Map<String, List<Business_Rule__c>> result = BusinessRuleUtility.getPriorityBusinessRule(q.Id);
    }

    @IsTest
    public static void testGetPriorityBusinessRule_Else() {
        Profile adminProfile = TestDataFactory.getProfile('System Administrator');
        User testUser = TestDataFactory.createUser(adminProfile);
        List<Account> accounts = TestDataFactory.createAccount('Test Client', testUser);
        Account clientAcc = accounts[0];
        List<Opportunity> opportunities = TestDataFactory.createOpportunity(1, 'Test Opportunity', null, 'Temporary', clientAcc.Id);
        insert opportunities;
        Opportunity opp = opportunities[0];
        Map<String, List<Business_Rule__c>> result = BusinessRuleUtility.getPriorityBusinessRule(opp.Id);
    }

    @IsTest
    public static void testGetCaseValues_RelationshipDepths_Full() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acct.Id);
        insert con;
        Case c = new Case(
            Subject = 'Test Case',
            AccountId = acct.Id,
            ContactId = con.Id,
            Status = 'New'
        );
        insert c;
        List<Business_Rule_Field_Mapping__mdt> mdts = new List<Business_Rule_Field_Mapping__mdt>();
        mdts.add(new Business_Rule_Field_Mapping__mdt(
            MasterLabel = 'Case Subject',
            Case__c = 'Subject',
            Business_Rule__c = 'Field1',
            Priority_Value__c = String.valueOf(1)
        ));
        mdts.add(new Business_Rule_Field_Mapping__mdt(
            MasterLabel = 'Account Name',
            Case__c = 'Account.Name',
            Business_Rule__c = 'Field2',
            Priority_Value__c = String.valueOf(2)
        ));
        mdts.add(new Business_Rule_Field_Mapping__mdt(
            MasterLabel = 'Account Owner',
            Case__c = 'Account.Owner.Name',
            Business_Rule__c = 'Field3',
            Priority_Value__c = String.valueOf(3)
        ));
        mdts.add(new Business_Rule_Field_Mapping__mdt(
            MasterLabel = 'Account Owner Profile',
            Case__c = 'Account.Owner.Profile.Name',
            Business_Rule__c = 'Field4',
            Priority_Value__c = String.valueOf(4)
        ));
        Test.startTest();
        List<BusinessRuleUtility.priorityFields> pfList = BusinessRuleUtility.getCaseValues(c.Id, mdts);
        Test.stopTest();
    }

    @IsTest
    public static void testGetBusinessRules_EffectiveDateAndAccountName() {
        List<Business_Rule_Field_Mapping__mdt> mdts = BusinessRuleUtility.getFieldMappings();
        List<BusinessRuleUtility.priorityFields> pf = new List<BusinessRuleUtility.priorityFields>();
        BusinessRuleUtility.priorityFields effectiveDateField = new BusinessRuleUtility.priorityFields();
        effectiveDateField.commonName = 'Effective Date';
        effectiveDateField.businessRuleField = 'Effective_Date__c';
        effectiveDateField.objectValue = String.valueOf(Date.today());
        pf.add(effectiveDateField);
        BusinessRuleUtility.priorityFields accountNameField = new BusinessRuleUtility.priorityFields();
        accountNameField.commonName = 'Account Name';
        accountNameField.businessRuleField = 'AccountId__c';
        accountNameField.objectValue = 'NonExistentAccount';
        pf.add(accountNameField);
        List<Business_Rule__c> brList = BusinessRuleUtility.getBusinessRules(pf, mdts);
    }

    @IsTest
    public static void testParseBusinessRules_ApprovalNoApprovers() {
        Profile adminProfile = TestDataFactory.getProfile('System Administrator');
        User testUser = TestDataFactory.createUser(adminProfile);
        List<Account> accounts = TestDataFactory.createAccount('Test Client', testUser);
        Account clientAcc = accounts[0];
        List<Account> locations = TestDataFactory.createLocation('Test Location', testUser, clientAcc.Id);
        Account locationAcc = locations[0];
        List<Business_Rule__c> brList = [
            SELECT
                Id,
                Name,
                AccountId__c,
                locationid__c,
                Container__c,
                Service__c,
                Request_Type__c,
                Schedule_Type__c,
                Active__c,
                Effective_Date__c,
                Channel_Req__c,
                Channel__c,
                RecordTypeId,
                RecordType.Name
            FROM Business_Rule__c
            LIMIT 10
        ];
        Map<String, List<Business_Rule__c>> parsed = BusinessRuleUtility.parseBusinessRules(brList);
    }

    @IsTest
    public static void testGetPriorityBusinessRule_WithServiceApprovers() {
        User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Account> accounts = TestDataFactory.createAccount('Test Client', testUser);
        insert accounts;
        Account clientAcc = accounts[0];
        List<Account> locations = TestDataFactory.createLocation('Test Location', testUser, clientAcc.Id);
        insert locations;
        Account locationAcc = locations[0];
        Business_Rule__c br = new Business_Rule__c(
            AccountId__c = clientAcc.id,
            locationid__c = locationAcc.id,
            Container__c = 'Equipment',
            Service__c = 'Extra Pickup',
            Request_Type__c = 'Pickup',
            Schedule_Type__c = 'Temporary',
            Active__c = true,
            Effective_Date__c = System.today() - 1,
            Channel_Req__c = 'Test Channel Requirements',
            Channel__c = 'WM Portal',
            RecordTypeId = TestDataFactory.getRecordType(Constant_Util.BUSINESS_NOTIFICATION, 'Business_Rule__c')
        );
        insert br;
        List<Service_Approver__c> serviceApprovers = TestDataFactory.createServiceApprover(br);
        insert serviceApprovers;
        List<Case> cases = TestDataFactory.createNewCase();
        insert cases;
        Case c = cases[0];
        Map<String, List<Business_Rule__c>> result = BusinessRuleUtility.getPriorityBusinessRule(c.Id);
    }

    @IsTest
    public static void testGetPriorityBusinessRule_NoBusinessRules() {
        List<Case> cases = TestDataFactory.createNewCase();
        insert cases;
        Case c = cases[0];
        Map<String, List<Business_Rule__c>> result = BusinessRuleUtility.getPriorityBusinessRule(c.Id);
    }

    @IsTest(SeeAllData=true)
    public static void testParseBusinessRules() {
        List<Business_Rule__c> brList = [
            SELECT
                Id,
                Name,
                AccountId__c,
                locationid__c,
                Container__c,
                Service__c,
                Request_Type__c,
                Schedule_Type__c,
                Active__c,
                Effective_Date__c,
                Channel_Req__c,
                Channel__c,
                RecordTypeId,
                RecordType.Name,
                Business_Rule__c.No_Approval_Required__c
            FROM Business_Rule__c
            LIMIT 10
        ];
        System.debug('kkk inside test' + brList);
        Map<String, List<Business_Rule__c>> parsedMap = BusinessRuleUtility.parseBusinessRules(brList);
    }

    @IsTest(SeeAllData=true)
    public static void testPrioritizeBusinessRules_SwitchCoverage() {
        List<Business_Rule__c> brList = [
            SELECT
                Id,
                Category_Type__c,
                Group__c,
                RecordTypeId,
                RecordType.Name,
                Container__c,
                Service__c,
                Request_Type__c,
                Active__c,
                Effective_Date__c,
                LocationId__c
            FROM Business_Rule__c
            WHERE
                RecordType.Name = 'Approval' AND Active__c = true AND LocationId__c = null AND Group__c != null AND Category_Type__c IN ('Division/Department', 'Geography', 'Brand', 'Location Type')
            LIMIT 4
        ];
        if (brList.isEmpty()) return;
        List<BusinessRuleUtility.priorityFields> pfList = new List<BusinessRuleUtility.priorityFields>();
        BusinessRuleUtility.priorityFields pf;
        for (Business_Rule__c br : brList) {
            if (br.Group__c != null && br.Category_Type__c != null) {
                pf = new BusinessRuleUtility.priorityFields();
                switch on br.Category_Type__c {
                    when 'Division/Department' {
                        pf.commonName = 'Category - Division';
                    }
                    when 'Geography' {
                        pf.commonName = 'Category - Geography';
                    }
                    when 'Brand' {
                        pf.commonName = 'Category - Brand';
                    }
                    when 'Location Type' {
                        pf.commonName = 'Category - Location Type';
                    }
                }
                pf.objectValue = br.Group__c;
                pf.businessRuleField = 'Category_Type__c';
                pfList.add(pf);
            }
        }
        if (brList[0].Container__c != null) {
            pf = new BusinessRuleUtility.priorityFields();
            pf.commonName = 'Container';
            pf.objectValue = brList[0].Container__c;
            pf.businessRuleField = 'Container__c';
            pfList.add(pf);
        }
        if (brList[0].Service__c != null) {
            pf = new BusinessRuleUtility.priorityFields();
            pf.commonName = 'Service';
            pf.objectValue = brList[0].Service__c;
            pf.businessRuleField = 'Service__c';
            pfList.add(pf);
        }
        if (brList[0].Request_Type__c != null) {
            pf = new BusinessRuleUtility.priorityFields();
            pf.commonName = 'Request Type';
            pf.objectValue = brList[0].Request_Type__c;
            pf.businessRuleField = 'Request_Type__c';
            pfList.add(pf);
        }
        Map<String, List<Business_Rule__c>> brMap = new Map<String, List<Business_Rule__c>>();
        brMap.put('Approval', brList);
        Test.startTest();
        Map<String, List<Business_Rule__c>> prioritized = BusinessRuleUtility.prioritizeBusinessRules(pfList, brMap);
        Test.stopTest();
    }
}