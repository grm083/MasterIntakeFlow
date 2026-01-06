/*************************************************************
@Name: RecordComparatorTest
@Author: Soham Datta
@CreateDate: 24/01/20125
@Description: Test class for RecordComparator
@Coverage: 100%
**************************************************************/
@isTest(seeAllData = false)
private class RecordComparatorTest {
    
    private static final string SYS_ADMIN = 'System Administrator';
    
    //Test Setup
    @testSetup 
    private static void setup() {

        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            Account parentAccount = TestDataFactory.returnAccount('The Home Depot', '1234ABCD1', 'Client', usr);
            Database.insert(parentAccount);
            
            Id approvalRecordTypeId = TestDataFactory.getRecordType('Approval', 'Business_Rule__c');
            List<Business_Rule__c> approvalRules = new List<Business_Rule__c>();
            
            Business_Rule__c approvalRule1 = new Business_Rule__c(AccountId__c = parentAccount.Id, Container__c = 'Equipment', Service__c = 'Extra Pickup', 
                                                                       Request_Type__c = 'Pickup', Schedule_Type__c = 'Temporary',
                                                                       Active__c = true, Effective_Date__c = System.today() - 1,
                                                                       Channel_Req__c= 'Test Channel Requirements', Channel__c = 'WM Portal',
                                                                       RecordTypeId = approvalRecordTypeId);
            
            Business_Rule__c approvalRule2 = new Business_Rule__c(AccountId__c = parentAccount.Id, Container__c = 'Equipment', Service__c = 'Extra Pickup', 
                                                                  Request_Type__c = 'Pickup', Schedule_Type__c = 'Temporary',
                                                                  Active__c = true, Effective_Date__c = System.today() - 1,
                                                                  Channel_Req__c= 'Test Channel Requirements', Channel__c = 'WM Portal',
                                                                  RecordTypeId = approvalRecordTypeId);
            
            Business_Rule__c approvalRule3 = new Business_Rule__c(AccountId__c = parentAccount.Id, Container__c = 'Equipment', Service__c = 'Extra Pickup', 
                                                                  Request_Type__c = 'Pickup', Schedule_Type__c = 'Permanent',
                                                                  Active__c = true, Effective_Date__c = System.today(),
                                                                  Channel__c = 'WM Portal', RecordTypeId = approvalRecordTypeId);
            
            approvalRules.add(approvalRule1);
            approvalRules.add(approvalRule2);
            approvalRules.add(approvalRule3);
            
            insert approvalRules;
        }
    }
    
    /* test method to test testInsertApprovalRecords()*/
    @isTest 
    private static void testCompareRecords(){
        
        Date today = System.today();
        
        //Fetch System Admin User
        user currentuser = [select Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name =: SYS_ADMIN limit 1];
        
        //Fetch Business Rules
        List<Business_Rule__c> approvalRules = [SELECT Id, Name, Alias__c, Record_Type_Name__c, RecordTypeId, AccountId__c, Container__c, Effective_Date__c, LocationId__c, 
                                                Schedule_Type__c, Service__c, AssetId__c, Category_Type__c, Group__c, 
                                                Project_Code__c, Case_Reason__c, Material__c 
                                                From Business_Rule__c
                                                Where RecordType.DeveloperName = 'Approval'];
        
        
        
        Test.startTest();
        
        System.runAs(currentuser){
            
            //Test 1
            List<RecordComparator.RecordComparisonInput> inputs1 = new List<RecordComparator.RecordComparisonInput>();
            
            RecordComparator.RecordComparisonInput input1 = new RecordComparator.RecordComparisonInput();
            input1.oldRecord = approvalRules[0];
            input1.newRecord = null;
            inputs1.add(input1);
            
            List<RecordComparator.ComparisonResult> outputs1 = RecordComparator.compareRecords(inputs1);
            System.assertEquals(1, outputs1.size());
            
            
            //Test 2
            List<RecordComparator.RecordComparisonInput> inputs2 = new List<RecordComparator.RecordComparisonInput>();
            
            RecordComparator.RecordComparisonInput input2 = new RecordComparator.RecordComparisonInput();
            input2.oldRecord = approvalRules[0];
            input2.newRecord = approvalRules[1];
            inputs2.add(input2);
            
            List<RecordComparator.ComparisonResult> outputs2 = RecordComparator.compareRecords(inputs2);
            System.assertEquals(1, outputs2.size());
            
        }
        
        Test.stopTest();
        
    }

}