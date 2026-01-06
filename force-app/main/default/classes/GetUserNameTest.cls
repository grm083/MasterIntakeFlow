/*************************************************************
@Name: SplitStringToListCntrlrTest
@Author: Kalaiselvi
@CreateDate: 28/03/2019
@Description: Test class of SplitStringToListCntrlr
@UsedBy: 
**************************************************************/
@isTest
public class GetUserNameTest {

    //Method to test split string   
    public static testMethod void testGetUserName() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            List<string> inputStrLst = new List<string>();
           inputStrLst.add(Constant_Util.TEST_USERNAME);
            Test.startTest();
            	GetUsername.getName(inputStrLst);
            Test.stopTest();
            system.assert(inputStrLst.size() != 0);
        }
    }
}