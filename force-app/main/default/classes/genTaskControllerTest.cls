@isTest
public class genTaskControllerTest {
	public static final string CUSTOMER_SERVICE = 'Customer Service';
    @testSetup
    static void setup(){
        
        /*Profile p = [SELECT Id FROM Profile WHERE Name = :Constant_Util.SYSTEM_ADMINISTRATOR];
        
        User u = new User(Alias = 'tester', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1522@testorg.com');
        u.IsActive = true;
        insert u;*/ //Commented for SDT-33466
        
        //Modified for SDT-33466 Start
        Profile p = TestDataFactory.getProfile(CUSTOMER_SERVICE);
        User usr = TestDataFactory.createUser(p);
        usr.IsActive = true;
        usr.Alias = 'tester';
        Database.insert(usr);
        //Modified for SDT-33466 End
        
        List<Account> accObjList = new List<Account>(); //Modified for SDT-33466
        Account acc = new Account();
        acc.OwnerId = usr.id; //Modified for SDT-33466
        acc.Name = 'TestAccount';
       	accObjList.add(acc); //Modified for SDT-33466
        Database.insert(accObjList); //Modified for SDT-33466
        
List<Case> caseList = new List<Case>(); //Modified for SDT-33466
        Case ca = new Case();
        ca.AccountId = acc.id;
        ca.OwnerId = usr.id; //Modified for SDT-33466
        ca.Reference_Number__c = 'Ref12345';
        ca.Last_Customer_Interaction_ID__c = 'Int12345';
        ca.Last_Customer_Interaction_Type__c = 'Phone';
        ca.Subject = 'Test';
        caseList.add(ca); //Modified for SDT-33466
        Database.insert(caseList); //Modified for SDT-33466
        
        //System.debug('Account: '+ acc);

    }
    
    @isTest
    static void runTest(){
        
        User u = [SELECT Id FROM User WHERE alias='tester' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' Limit 1];
        Case ca = [SELECT Id FROM Case Where Reference_Number__c = 'Ref12345'];
        //System.debug('Case: '+ca);
        
        GenTaskController gentask = new GenTaskController();
        PageReference pageRef = Page.GenTaskPage;
        pageRef.getParameters().put('id',ca.id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        
        System.runAs(u){
        genTask.taskCheck();
        //System.debug('Page Reference: '+PageRef);
        }
        
        Test.stopTest();
            
    }
}