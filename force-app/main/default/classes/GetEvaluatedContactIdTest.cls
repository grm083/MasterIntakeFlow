/**
* @author Accenture
* @date 
* @description : Test class for  GetEvaluatedContactId
**/

@isTest(seeAllData = false)
public class GetEvaluatedContactIdTest {
    public static final string SYS_ADMIN = 'System Administrator';
    private static final string PRODUCT = '8 yrd';
    private static final string KROGER = 'kroger';
    private static final string RITA = 'Rita';
    private static final string REPLY = 'Reply';
    // set the test data
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User currentUser = TestDataFactory.createUser(p);
        Database.insert(currentUser);
        
         system.runAs(currentUser){
            List<Account> accList = TestDataFactory.createAccount(KROGER, currentUser,Constant_Util.SUPPLIER);
            Database.insert(accList);
            List<Account> locationList = TestDataFactory.createLocation(Constant_Util.LOCATION, currentUser, accList.get(0).id);
            Database.insert(locationList);
            List<Contact> conList = TestDataFactory.createContact(RITA,REPLY, accList.get(0), currentUser);
            Database.insert(conList);
            AccountContactRelation testACR1 = 
            TestDataFactory.returnAccConRel(locationList[0].Id, conList[0], '2nd Dispatch Escalation-Rolloff');
            Database.insert(testACR1);
             
             
        }
    }
    
    @isTest static void getEvaluatedContactIdByRoles1(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
        List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
        GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
        evalContactId.numberOfAttempt = '1';
        evalContactId.productFamily = 'Rolloff';
        evalContactId.accountId = loc.Id;
        evalContactIdList.add(evalContactId);
        test.startTest();
        GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
     @isTest static void getEvaluatedContactIdByRoles2(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = '1st Dispatch Escalation-Rolloff';
         Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
     @isTest static void getEvaluatedContactIdByRoles3(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch - Rolloff';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '1';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
     @isTest static void getEvaluatedContactIdByRoles4(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = '2nd Dispatch Escalation-Commercial';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '3';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    @isTest static void getEvaluatedContactIdByRoles5(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = '1st Dispatch Escalation-Commercial';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
     @isTest static void getEvaluatedContactIdByRoles6(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch - Commercial';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '1';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    @isTest static void getEvaluatedContactIdByRoles7(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch - Commercial';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '3';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    @isTest static void getEvaluatedContactIdByRoles8(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = '1st Dispatch Escalation-Commercial';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '3';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
     @isTest static void getEvaluatedContactIdByRoles9(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '3';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    @isTest static void getEvaluatedContactIdByRoles10(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    @isTest static void getEvaluatedContactIdByRoles11(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch - Rolloff';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
	 @isTest static void getEvaluatedContactIdByRoles12(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch;Dispatch - Rolloff';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    } 
    
     @isTest static void getEvaluatedContactIdByRoles13(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '3';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    @isTest static void getEvaluatedContactIdByRoles14(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = '1st Dispatch Escalation-Rolloff';
         Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '3';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    
	 @isTest static void getEvaluatedContactIdByRoles15(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch - Rolloff';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '3';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
     @isTest static void getEvaluatedContactIdByRoles16(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '1';
			evalContactId.productFamily = 'Rolloff';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
    @isTest static void getEvaluatedContactIdByRoles17(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch - Commercial';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }
    
     @isTest static void getEvaluatedContactIdByRoles18(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name ='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        AccountContactRelation acr =  [SELECT id,Roles, AccountId,ContactId FROM AccountContactRelation
                            		    WHERE AccountId =: loc.Id];
         acr.roles = 'Dispatch';
          Database.update(acr);
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        test.stopTest();
        
    }

    @isTest static void getEvaluatedContactIdByRoles19(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name !='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name !='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Commercial';
			evalContactId.accountId = '0016t00000AJz1lAAD12';
			evalContactIdList.add(evalContactId);
        
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        	test.stopTest();
    }
    
     @isTest static void getEvaluatedContactIdByRoles20(){
        Account acc = [select id from Account  limit 1];
        
        Account supplier = [select id from Account where recordtype.name !='Vendor' Limit 1];
        Account loc = [Select id from account where recordtype.name !='Location' Limit 1];
        Contact cnt = [select id,No_Of_Locations_Assoc_With_Contact__c from Contact Limit 1];
        
         List<GetEvaluatedContactId.FlowInputsForContactId> evalContactIdList = new List<GetEvaluatedContactId.FlowInputsForContactId>();
        	
            GetEvaluatedContactId.FlowInputsForContactId evalContactId = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId.numberOfAttempt = '2';
			evalContactId.productFamily = 'Commercial';
			//evalContactId.accountId = loc.Id;
			evalContactIdList.add(evalContactId);
        
            GetEvaluatedContactId.FlowInputsForContactId evalContactId1 = new GetEvaluatedContactId.FlowInputsForContactId();
			evalContactId1.numberOfAttempt = '1';
			evalContactId1.productFamily = 'Commercial, Rolloff';
			//evalContactId1.accountId = loc.Id;
			evalContactIdList.add(evalContactId1);
        	test.startTest();
			GetEvaluatedContactId.getEvaluatedContactIdByRoles(evalContactIdList);
        	test.stopTest();
    }
}