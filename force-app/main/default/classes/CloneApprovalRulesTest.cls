/*************************************************************
@Name: CloneApprovalRulesTest
@Author: Soham Datta
@CreateDate: 24/01/20125
@Description: Test class for CloneApprovalRules
@Coverage: 96%
**************************************************************/

@isTest(seeAllData = false)
private class CloneApprovalRulesTest {
    
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
            
            Business_Rule__c parentApprovalRule = new Business_Rule__c(AccountId__c = parentAccount.Id, Container__c = 'Equipment', Service__c = 'Extra Pickup', 
                                                             Request_Type__c = 'Pickup', Schedule_Type__c = 'Temporary', Material__c = '',
                                                             Active__c = true, Effective_Date__c = System.today() - 1, Case_Reason__c = '',
                                                             Channel_Req__c= 'Test Channel Requirements', Channel__c = 'WM Portal',
                                                             RecordTypeId = approvalRecordTypeId, LocationId__c = null, Category_Type__c = '', Group__c = null);
            Database.insert(parentApprovalRule);
        }
    }
    
    /* test method to test testInsertApprovalRecords()*/
    @isTest 
    private static void testInsertApprovalRecords1(){
        
        //Fetch System Admin User
        user currentuser = [select Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name =: SYS_ADMIN limit 1];
        
        //Preparing inputs
        List<CloneApprovalRules.InputWrapper> inputs = new List<CloneApprovalRules.InputWrapper>();
        CloneApprovalRules.InputWrapper input = new CloneApprovalRules.InputWrapper();
        input.loopCount = '1';
        input.parentApprovalRule = [Select Id, AccountId__c, Effective_Date__c, Container__c, Service__c, Material__c, 
                                    Request_Type__c, Schedule_Type__c, RecordTypeId, Active__c ,Project_Code__c,
                                    AssetId__c, LocationId__c, Category_Type__c, Group__c, Case_Reason__c
                                    From Business_Rule__c
                                    Where RecordType.DeveloperName = 'Approval' 
                                    limit 1];
        inputs.add(input);
        
        Test.startTest();
        system.runAs(currentuser){
                        
            List<CloneApprovalRules.DataList> outputWrapper = CloneApprovalRules.insertApprovalRecords(inputs);
            System.assert(true, outputWrapper.size()>0);
        }
        Test.stopTest();
    }
    
    /* test method to test testInsertApprovalRecords()*/
    @isTest 
    private static void testInsertApprovalRecords2(){
        
        //Fetch System Admin User
        user currentuser = [select Id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name =: SYS_ADMIN limit 1];
        
        //Preparing inputs
        List<CloneApprovalRules.InputWrapper> inputs = new List<CloneApprovalRules.InputWrapper>();
        CloneApprovalRules.InputWrapper input = new CloneApprovalRules.InputWrapper();
        input.loopCount = '2';
        input.parentApprovalRule = [Select Id, AccountId__c, Effective_Date__c, Container__c, Service__c, Material__c, 
                                    Request_Type__c, Schedule_Type__c, RecordTypeId, Active__c ,Project_Code__c,
                                    AssetId__c, LocationId__c, Category_Type__c, Group__c, Case_Reason__c
                                    From Business_Rule__c
                                    Where RecordType.DeveloperName = 'Approval' 
                                    limit 1];
        inputs.add(input);
        
        Test.startTest();
        system.runAs(currentuser){
            
            List<CloneApprovalRules.DataList> outputWrapper = CloneApprovalRules.insertApprovalRecords(inputs);
            System.assert(true, outputWrapper.size()>0);
        }
        Test.stopTest();
    }

}