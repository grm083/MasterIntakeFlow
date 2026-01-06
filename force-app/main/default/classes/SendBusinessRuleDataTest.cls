@IsTest
public class SendBusinessRuleDataTest {
    private static final string SYS_ADMIN = 'System Administrator';
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr,Constant_Util.CLIENT);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Business_Rule__c> businessrulelist = TestDataFactory.createBusinessRule(Constant_Util.CONSTANT_FIRST, acclist.get(0), 
                                                                                         locationlist.get(0));
            for(Business_Rule__c br : businessrulelist){
                br.Request_Type__c = 'Pickup';
                br.Service__c = 'Haul Away - No Equipment'  ;
                br.Active__c = true;
            }
            
            // Create Business Rule
            Database.insert(businessrulelist);
            
            // Creating Approver list
            list<Service_Approver__c> approvers = new  list<Service_Approver__c>();
            
            for(Business_Rule__c br : businessrulelist){
                approvers.addAll(TestDataFactory.createServiceApprover(br));
                approvers.addAll(TestDataFactory.createEmailServiceApprover(br));
            }
             insert approvers; 
        }
    }
    
    @IsTest static void testMethod1() {
        List<Business_Rule__c> br = [SELECT Id, Name, RecordTypeId, AccountId__c,
                                     Active__c, Container__c, Effective_Date__c, End_Date__c, LocationId__c, Request_Type__c,
                                     Required_Information__c, Schedule_Type__c, Service__c, Alias__c, AssetId__c,
                                     Category_Type__c, Channel_Req__c, Channel_Requirements__c, Channel__c, Group__c,
                                     Is_Channel_Requirements__c, Is_Special_Instructions__c,
                                     Multiple_Mandatory_Approvers__c, Occurrence_Limit__c, Process__c, Project__c,
                                     Role__c, Special_Ins__c, Special_Instructions__c,
                                     No_Approval_Required__c, Project_Code__c,
                                     Material__c, Special_Instructions_Approval__c, Is_Auto_Email__c,
                                     Object_Type__c, NTE_Rules__c,
                                     (SELECT Id, Name, RecordTypeId, CreatedDate, Business_Rule__c, Account__c,
                                      Account_Team_Member__c, Account_Title__c, Approver_Contact__c,
                                      Approver_Type__c, Approver__c, External_Approver_Email__c, External_Approver_Name__c,
                                      External_Approver_Phone_Number__c, Preferred_Method__c,
                                      Title__c, Approver_Email__c, Approver_Phone__c, Email__c,
                                      User__c, Department__c, ServiceApprover__c, SortBy__c, Active__c, Requester_Only__c,
                                      Request_Type_Service__c, is_Auto_Email__c, NTE_Amount__c, Fuzzy_Search__c,
                                      Service_Type__c, NTE_Rule_ExtId__c FROM Approver_Entities__r)
                                     FROM Business_Rule__c limit 1];
        
        Test.startTest();
        SendBusinessRuleData.businessRuleData();
        Test.stopTest();
        //List<Business_Rule__c> BuRule = new List<Business_Rule__c>();
        //BuRule = [select id, Service__c, Request_Type__c from Business_Rule__c];
        //System.assertNotEquals(null, br, 'Business rule list should not be null');
        //System.assertEquals(0 , BuRule.size(), 'comparing size');
    }
    
}
