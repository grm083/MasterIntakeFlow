@isTest(SeeAllData = false)
public class GetSFDCServiceFlagTest {
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(Constant_Util.SYSTEM_ADMINISTRATOR);
        User usr = TestDataFactory.createUser(p);
        usr.User_categorization_code__c = 'CSGEN';
        usr.FirstName = 'Testuser#9999';
        Database.insert(usr);
    }
    
    @isTest static void itShouldHaveServiceFlag()
    {
        User us = [Select id,username from user where User_categorization_code__c = 'CSGEN' and FirstName = 'Testuser#9999' limit 1];
        List<String> splitStrList = us.username.split('@');
        List<String> strList = new List<String>{splitStrList[0]};
        List<String> result =GetSFDCServiceFlag.getServiceFlag(strList);
        System.assertEquals('CS', result[0]);
    }
}