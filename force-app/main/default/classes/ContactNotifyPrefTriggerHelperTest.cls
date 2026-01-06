/**
* @author WM
* @date 7/21/2020
* @description : Apex class ContactNotifyPrefTriggerHelperTest 
**/

/* test class for ContactNotifyPrefTriggerHelperTest*/

@isTest(seeAllData = false)
public class ContactNotifyPrefTriggerHelperTest {
   public static final string SYS_ADMIN = 'System Administrator';
    private static final string KROGER = 'kroger';
    private static final string NY_TIMEZONE = 'America/New_York';
    private static final string ON_OUR_WAY= 'On Our Way';
    private static final string NEGATIVE_HOC= 'Negative HOC';
    private static final string EMAIL= 'Email';
       private static final string SMS= 'SMS';
     /* set up the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
         
            
             List<Account> acclist = TestDataFactory.createAccount(KROGER, usr,Constant_Util.CLIENT);
            acclist[0].AccountNumber = 'HMD';
            Test.startTest();
            Database.insert(acclist);
            
            List<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            
            locationlist[0].tz__Timezone_SFDC__c = NY_TIMEZONE;
            locationlist[0].tz__UTF_Offset__c = -4;
            Database.insert(locationlist);
            
            List<Contact> conlist = TestDataFactory.createContact('RITA', 'REPLY', acclist.get(0), usr);
            conlist[0].Preferred_Method__c=EMAIL;
            Database.insert(conlist);
            
             List<Contact> conlist2 = TestDataFactory.createContact('Fname', 'Lname', acclist.get(0), usr);
            conlist2[0].Preferred_Method__c=EMAIL;
            Database.insert(conlist2);
            
            Contact_Notification_Preference__c cnpRec1 = new Contact_Notification_Preference__c(Contact_Name__c= conlist[0].id,Notification_Type__c=ON_OUR_WAY,Notification_Preference__c=EMAIL);
            database.insert(cnpRec1);
            
            Contact_Notification_Preference__c cnpRec2 = new Contact_Notification_Preference__c(Contact_Name__c= conlist[0].id,Notification_Type__c=NEGATIVE_HOC,Notification_Preference__c=EMAIL);
            database.insert(cnpRec2);
             
            Contact_Notification_Preference__c cnpRec3 = new Contact_Notification_Preference__c(Contact_Name__c= conlist2[0].id,Notification_Type__c=NEGATIVE_HOC,Notification_Preference__c=SMS);
            database.insert(cnpRec3);
            Test.stopTest();
        }
    }
    
     @isTest static void CNPOnInsertDuplicateTest(){
         List<contact> conlist = [SELECT id FROM contact LIMIT 1];
         Contact_Notification_Preference__c cnpRec = new Contact_Notification_Preference__c(Contact_Name__c= conlist[0].id,Notification_Type__c=ON_OUR_WAY,Notification_Preference__c=EMAIL);
         try{
             test.startTest();
             database.insert(cnpRec);
             Test.stopTest();
         }
          catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.DupContSameNotiErrMsg), 'message=' + message);
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.DupContSameNotiErrMsg) ? true : false;
            system.assertEquals(expectedExceptionThrown, true);
        }
     }
    
         
       @isTest static void CNPOnUpdateDuplicateTest(){
         List<contact> conlist = [SELECT id FROM contact LIMIT 1];
         List<Contact_Notification_Preference__c> cnpRec = [SELECT id, notification_type__C FROM contact_notification_Preference__c WHERE notification_type__C=: NEGATIVE_HOC limit 1 ];
         try{
             cnpRec[0].notification_type__C=ON_OUR_WAY;
             Test.startTest();
             Database.SaveResult result= database.update(cnpRec[0]);
             Test.stopTest();
             System.assert(result.isSuccess() == false);
      
            }catch(Exception e){
        
                String message = e.getMessage();
                system.assert(message.contains(System.Label.DupContSameNotiErrMsg), 'message=' + message);
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.DupContSameNotiErrMsg) ? true : false;
                system.assertEquals(expectedExceptionThrown, true);
            }
        }
    
    @isTest static void CNPOnUpdateDuplicateTestCase2(){
        List<contact> conlist = [SELECT id FROM contact LIMIT 2];
        List<Contact_Notification_Preference__c> cnpRec= [SELECT id, contact_name__c, notification_type__C FROM contact_notification_Preference__c WHERE notification_type__C=: NEGATIVE_HOC AND Notification_Preference__c =: SMS  LIMIT 1 ];
        try{
            cnpRec[0].notification_type__c= ON_OUR_WAY;
            Test.startTest();
            Database.SaveResult result= database.update(cnpRec[0]);
            Test.stopTest();
													   
        }catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.DupContSameNotiErrMsg), 'message=' + message);
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.DupContSameNotiErrMsg) ? true : false;
            system.assertEquals(expectedExceptionThrown, true);            
        }
    }
}