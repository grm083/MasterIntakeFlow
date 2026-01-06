@isTest(seeAllData = false)
public class ButtonAccessControllerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    
    /*@testmethodName- checkForCATUser
    *@description- Test returnButtonAccess method to check if it is returning the right button access. 
    */ 
    @isTest static void checkForCATUser(){
        Test.startTest();
        User catUser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :Constant_Util.CAT_RECORD_TYPE limit 1];
        User nonCatUser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE AND Profile.Name = :SYS_ADMIN limit 1];
        
        system.runAs(catUser){
            System.assertEquals(ButtonAccessController.returnButtonAccess(),FALSE);
        }
        system.runAs(nonCatUser){
            System.assertEquals(ButtonAccessController.returnButtonAccess(),TRUE);
        }
        
        Test.stopTest();
        
    }
    
}