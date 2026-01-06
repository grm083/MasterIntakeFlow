/**
* @author Accenture
* @date 2/6/2019
* @description : Apex class CaseTriggerHelperTest 
**/

/* test class for CaseTriggerHelper*/
@isTest(seeAllData = false)
public class AvoidProcessBuilderTest {
    private static final string SYS_ADMIN = 'System Administrator';
/* set the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        usr.bypass_validation__c = true;
        Database.insert(usr);
    }
    /* test method if Service Guarantee Category is days in entitlement*/
    @isTest static void avoidPBTest(){
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){   
            AvoidProcessBuilder.avoidPB();
        }
    }
}