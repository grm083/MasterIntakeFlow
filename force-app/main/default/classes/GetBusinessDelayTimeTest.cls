/**
* @author Accenture
* @date 
* @description : Apex class GetBusinessDelayTime
**/

/* test class for GetBusinessDelayTime*/
@isTest(seeAllData = false)
public class GetBusinessDelayTimeTest {
    public static final string SYS_ADMIN = 'System Administrator';
    /* getting the business delay time test method*/
    @isTest static void getBusinessDelayTime(){
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
        String rec = String.valueof(System.now())+ Constant_Util.SEMI_COLON +String.valueof(233) ;
        List<String> reclst = new List<String>();
        reclst.add(rec);
        Test.startTest();
        GetBusinessDelayTime.getDelayBusinessHours(reclst);
        Test.stopTest();
        system.assert(reclst.size() != 0);
        }
    }
}