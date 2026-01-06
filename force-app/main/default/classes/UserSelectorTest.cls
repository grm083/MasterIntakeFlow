//Class: UserSelectorTest
//Purpose: Test class for the UserSelector
//Author: TCS
//Date: 4-Nov-2024

@isTest(seeAllData = false)
public class UserSelectorTest 
{
    static void createData() 
    {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr= TestDataFactory.createUser(p);
        usr.User_categorization_code__c = 'SALESGEN';
        INSERT usr;
    }
    
    @isTest static void testgetUserRecord()
    {
        User salesGenUser = [SELECT Id, User_categorization_code__c FROM User WHERE User_categorization_code__c =: 'SALESGEN' LIMIT 1];
        User retrievedUser = UserSelector.getUserRecord(salesGenUser.Id);
        system.assertEquals('SALESGEN', retrievedUser.User_categorization_code__c, 'Error in Assertion: UserSelectorTest.testgetUserRecord()');
    }
    
    @isTest static void testgetSSMUser()
    {
        List<User> userList = UserSelector.getSSMUser();
        system.assertEquals(true, userList.size() > 0 ? true : false, 'Error in Assertion: UserSelectorTest.testgetSSMUser()');
    }

    @isTest static void testgetUserByEmailId()
    {
        List<String> toEmail = new  List<String>{'cct_SBS_test_23@wm.com','test@wm.com'};
        List<CSR_User_Data_Setup__mdt> usrCSRRecord = new List<CSR_User_Data_Setup__mdt>();

        usrCSRRecord = UserSelector.getUserByEmailId(toEmail);
        system.assert(usrCSRRecord != null, 'Error in Assertion: UserSelector.getUserByEmailId');
    }
    
    // Owner : TCS-AnjaliChalase
    // Story : SDT-45079
     @isTest static void testgetCSResolutionTeamUser()
    {
        List<User> userList = UserSelector.getCSResolutionTeamUser();
        system.assertEquals(true, userList.size() > 0 ? true : false, 'Error in Assertion: UserSelectorTest.testgetCSResolutionTeamUser()');
    }
}
