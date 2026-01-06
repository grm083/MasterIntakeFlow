/*Test class for BatchUpdateBusinessRules*/
@isTest
public class BatchUpdateBusinessRulesTest {
private static final string SYS_ADMIN = 'System Administrator';
private static final string NAME = 'test';
     @testSetup static void setup() {
         Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);  
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Business_Rule__c> brlst = TestDataFactory.createBusinessRule(NAME,acclist.get(0),locationlist.get(0));
            brlst[0].Active__c= True;
            brlst[0].Is_Auto_Email__c= False;         
            Database.insert(brlst);             
        }
          
      }
     
     @isTest static void updateBusRulesTest(){ 
         Test.startTest();
         Database.executeBatch(new BatchUpdateBusinessRules(),200);         
         Test.stopTest();
     
     }

}