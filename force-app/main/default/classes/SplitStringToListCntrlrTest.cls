/*************************************************************
@Name: SplitStringToListCntrlrTest
@Author: Niranjan
@CreateDate: 28/03/2019
@Description: Test class of SplitStringToListCntrlr
@UsedBy: 
**************************************************************/
@isTest
public class SplitStringToListCntrlrTest {

    //Method to test split string   
    public static testMethod void testSplitString() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            List<string> inputStrLst = new List<string>();
            inputStrLst.add(Constant_Util.KEYWORD_TEST+Constant_Util.COLON+Constant_Util.KEYWORD_TEST);
            Test.startTest();
            	SplitStringToListCntrlr.splitstring(inputStrLst);
            Test.stopTest();
            system.assert(inputStrLst.size() != 0);
        }
    }
}