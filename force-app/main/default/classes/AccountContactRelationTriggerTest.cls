/**
* @author Adil Aleem
* @date 5/7/2021
* @description : Test class for AccountContactRelation
**/

/* test class for AccountContactRelation trigger*/
@isTest(seeAllData = false)
public class AccountContactRelationTriggerTest {
    private static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    /* set up the test data */
    @testSetup static void setup(){
         Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
            List<Account> accountList = new List<Account>();
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,Constant_Util.CLIENT);
            accountList .addAll(accList);
            List<Account> vendorList = TestDataFactory.createAccount('Vendor Acc', currentUser,'Vendor');
            accountList.addAll(vendorList);
            Database.insert(accountList );
        
            List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
            Database.insert(locationList);
            List<Contact> conList = TestDataFactory.createContact(RITA,REPLY, accList.get(0), currentUser);
            conList[0].Email = 'testfrom@test.com';
            Database.insert(conList);
            AccountContactRelation testACR1 = 
            TestDataFactory.returnAccConRel(locationList[0].Id, conList[0], 'Commercial Service/Dispatch');
            Database.insert(testACR1);
            // added new contact 
            List<Contact> conList2 = TestDataFactory.createContact('Fname','Lname', accList.get(0), currentUser);
            Database.insert(conList2);
        }
    }
    
    public static testmethod void updateNumberOfLocations(){
        string[] assetlist = new String[]{};
        Account client = [select id from Account where recordtype.name='Client' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id, AccountId,ContactId FROM AccountContactRelation
                                        WHERE AccountId =: loc.Id];
        
        test.startTest();
        Database.delete(acr);
        test.stopTest();
        system.assert(cnt.No_Of_Locations_Assoc_With_Contact__c != null);
        
    }
    
    public static testmethod void ValidateNPOfContTestUpdate(){         
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        try{
        system.runAs(currentUser){
          List<Account> accList = TestDataFactory.createAccount('The Home Depot', currentUser,Constant_Util.CLIENT);
          Database.insert(accList);
          List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
          Database.insert(locationList);
          List<Contact> conList = TestDataFactory.createContact('FirstNameTest','LastNameTest', accList.get(0), currentUser);
          Database.insert(conList);
          Account client = [SELECT id FROM Account WHERE recordtype.name=: Constant_Util.CLIENT Limit 1];
          Contact cnt = [SELECT id,No_Of_Locations_Assoc_With_Contact__c FROM Contact WHERE firstname='FirstNameTest' Limit 1];
          AccountContactRelation acrItem = new AccountContactRelation(AccountId=client.id , ContactId=cnt.id, Roles=Constant_Util.DISPATCH);
          database.insert(acrItem);
        }        
       
       AccountContactRelation acrList = [SELECT Id, Notification_Point_Of_Contact__c,Account_Record_Type__c FROM AccountContactRelation where roles = :Constant_Util.DISPATCH limit 1];
       acrList.Notification_Point_Of_Contact__c=true;
       
             test.startTest(); 
             Database.SaveResult result=database.update(acrList);
        }
        catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.NotiPointContactErrMsg), 'message=' + message);
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.NotiPointContactErrMsg) ? true : false;
            system.assertEquals(expectedExceptionThrown, true);  
        } finally{
          test.stopTest();
        }
    }
    
      public static testmethod void ValidateNPOfContTestInsert(){
        Profile prof = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(prof);
        Database.insert(currentUser);
        
        system.runAs(currentUser){
        try{
        List<Account> accList = TestDataFactory.createAccount('The Home Depot', currentUser,Constant_Util.CLIENT);
        Database.insert(accList);
        List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
        Database.insert(locationList);
        List<Contact> conList = TestDataFactory.createContact('FirstNameTest','LastNameTest', accList.get(0), currentUser);
        Database.insert(conList);
        Account client = [SELECT id FROM Account WHERE recordtype.name=: Constant_Util.CLIENT Limit 1];
        Contact cnt = [SELECT id,No_Of_Locations_Assoc_With_Contact__c FROM Contact WHERE firstname='FirstNameTest' Limit 1];
        AccountContactRelation acrItem = new AccountContactRelation(AccountId=client.id , ContactId=cnt.id, Roles=Constant_Util.DISPATCH,Notification_Point_Of_Contact__c=true );
         
             test.startTest();
             Database.SaveResult result=database.insert(acrItem);
         }
        catch(Exception e){
            String message = e.getMessage();
            system.assert(message.contains(System.Label.NotiPointContactErrMsg), 'message=' + message);
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.NotiPointContactErrMsg) ? true : false;
            system.assertEquals(expectedExceptionThrown, true);        
        }finally{
            test.stopTest();
        }
      }
    }
    
   public static testmethod void testUpdateDispatchEmail(){
        String vendorAccId;
        Account locationAcc;
        String clientAccId;
        for(Account acc : [SELECT Id, Name FROM Account WHERE NAME IN ('Vendor Acc' , :Constant_Util.LOCATION)]){
            if(acc.Name == 'Vendor Acc'){
                vendorAccId = acc.id;
            } else if(acc.Name == Constant_Util.LOCATION){
                locationAcc = acc;
            }
        }
        
        test.startTest();
        Contact con = [select id from contact where firstName = :RITA LIMIT 1];
        WorkOrder wrkodr = new WorkOrder(AccountId=locationAcc.id , ContactId=con.id);
        wrkodr.Vendor_Account_Id__c = vendorAccId;
        Database.insert(wrkodr);
        
        AccountContactRelation acr = new AccountContactRelation(AccountId = vendorAccId , ContactId = con.Id , Roles = 'Dispatch'); 
        Database.insert(acr);
        
        WorkOrder wo = [select id, Client__c, Dispatch_Email__c from workorder limit 1];
        system.assertEquals(wo.Dispatch_Email__c , 'testfrom@test.com' );
        test.stopTest();
    }
}