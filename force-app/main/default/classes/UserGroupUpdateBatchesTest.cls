/*************************************************************
@Name: UserGroupUpdateBatchesTest
@Author: Ganesh ram S
@CreateDate: 07/02/2019
@Description: Test class for BatchToUpdateUsersGroupId
**************************************************************/
@isTest(seeAllData = false)
public class UserGroupUpdateBatchesTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string OTHER ='Other';
    private static final string REPORTING_TEAM ='Test';
    private static User usr{get;set;}
    
    /*@methodName setup
     *  Method to set Test Data
     **/
    @testSetup static void setup() {
        /*Profile adminProfile = TestDataFactory.getProfile(SYS_ADMIN);
        UserRole role = new UserRole();
        role.Name = SYS_ADMIN ;
        Database.insert(role);
        usr = TestDataFactory.createUser(adminProfile);
        usr.UserRoleId = role.id ;
        Database.insert(usr); */
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name=:SYS_ADMIN];
        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = adminProfile.Id, Acorn_SUser_ID__c = 999,
                            TimeZoneSidKey='America/Los_Angeles', UserName='SystemAdministrator'+ String.valueof(system.now().millisecond())+'@testorg.com',IsActive = true);        
       
        system.runAs(usr){
            
            String csRep = Constant_Util.CS_REP ;
        UserRole csrRole = [select id, name from UserRole where name = :csRep limit 1];        
       User usrRec1 = TestDataFactory.createUser(adminProfile);
       usrRec1.UserRoleId = csrRole.id ;
       Database.insert(usrRec1, false);
       User usrRec2 = TestDataFactory.createUser(adminProfile);
       usrRec2.UserRoleId = csrRole.id ;
       usrRec2.Reporting_Team__c = REPORTING_TEAM;
       Database.insert(usrRec2, false);
        list<Group> grp = TestDataFactory.createGroup(usrRec1);              
        }}
    
    /*@MethodName BatchToUpdateUsersGroupIDTest
     * Test method to validate BatchToUpdateUsersGroupID batch class
     **/
    @isTest static void batchToUpdateUsersGroupIDTest(){
        //test class errors - SDT - 33363
        List<user> currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive = TRUE  LIMIT 2];
       
        system.runAs(currentuser.get(1)){
        String cronexp = '0 0 0 15 3 ? *';
        
        Test.startTest();

            String jobId = System.schedule('BatchToUpdateUsersGroupId',  cronexp, new BatchToUpdateUsersGroupIdScheduler());
            CronTrigger cronTrgr = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId Limit 1];

        Test.stopTest();
            System.assertEquals(0, cronTrgr.TimesTriggered);
        
    }
            
        }
    
    }