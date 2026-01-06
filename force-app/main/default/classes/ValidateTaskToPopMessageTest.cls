/*************************************************************
@Name: ValidateTaskToPopMessageTest
@Author: Niranjan Kumar
@CreateDate:19/08/2019
@Description: Test Class for ValidateTaskToPopMessage
**************************************************************/
@isTest
public class ValidateTaskToPopMessageTest {
    
    public static final string SYS_ADMIN = 'System Administrator';
    /* set up the test data*/
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile(SYS_ADMIN);
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
            list<Account> acclist = TestDataFactory.createAccount(Constant_Util.KEYWORD_TEST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST, Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            caselist[0].Service_Date__c = system.today();
            Database.insert(caselist);
            //Changes related to SDT - 37977 - start 
            Test.startTest();
            //Changes related to SDT - 37977 - end
            //modified by av4 as part of SDT-41134
            List<Task> tskListToBeInserted = new List<Task>();
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist[0].WhatId = caselist[0].Id;
            tasklist[0].Process__c = 'Obtain Schedule Confirmation';
            tasklist[0].Outcome__c = 'Service Error';
            tskListToBeInserted.add(tasklist[0]);
            //Database.insert(tasklist);
            
            list<Task> tasklist2 = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist2[0].WhatId = caselist[0].Id;
            tasklist2[0].Process__c = 'Manually Dispatch';
            tasklist2[0].Outcome__c = 'Service Error';
            tskListToBeInserted.add(tasklist2[0]);
            //Database.insert(tasklist2);
            
            list<Task> tasklist4 = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist4[0].WhatId = caselist[0].Id;
            tasklist4[0].Process__c = 'Obtain Schedule Confirmation';
            tasklist4[0].Outcome__c = 'Service Not Performed';
            tskListToBeInserted.add(tasklist4[0]);
            //Database.insert(tasklist4);
            
            list<Task> tasklist5 = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist5[0].Process__c = 'Confirm Service Completion';
            tasklist5[0].Outcome__c = 'Service Not Performed';
            tskListToBeInserted.add(tasklist5[0]);
            //Database.insert(tasklist5);
            
            list<Task> tasklist6 = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist6[0].Process__c = 'Confirm Service Completion with Location';
            tasklist6[0].Outcome__c = 'Service Not Performed';
            tskListToBeInserted.add(tasklist6[0]);
            //Database.insert(tasklist6);
            
            list<Task> tasklist7 = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist7[0].Process__c = Constant_Util.RESOLVE_SERV_ISSUE;
            tasklist7[0].Outcome__c = 'Information Obtained';
            tasklist7[0].Proposed_Service_Date__c = system.today().adddays(2);
            tasklist7[0].RecordTypeId = TestDataFactory.getRecordType('Pending Information','Task');
            tskListToBeInserted.add(tasklist7[0]);
            Database.insert(tskListToBeInserted);
            //Changes related to SDT - 37977 - start  
            Test.stopTest();
            //Changes related to SDT - 37977 - end 
        }
    }
    //Test ValidateToPopUpMsg method   
    @isTest static void testValidateToPopUpMsg() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            Task taskList = [SELECT Id, WhatId FROM Task LIMIT 1]; 
            Test.startTest();
                ValidateTaskToPopMessage.ValidateToPopUpMsg(taskList.Id);
            Test.stopTest();
        }
    }
    
    //Test ValidateToPopUpMsg method   
    @isTest static void testValidateToPopUpMsg2() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            Task taskList = [SELECT Id FROM Task where Process__c = 'Manually Dispatch' LIMIT 1]; 
            Test.startTest();
                ValidateTaskToPopMessage.ValidateToPopUpMsg(taskList.Id);
            Test.stopTest();
        }
    }
    
    //Test ValidateToPopUpMsg method   
    @isTest static void testValidateToPopUpMsg4() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            Task taskList = [SELECT Id FROM Task where Process__c = 'Obtain Schedule Confirmation'  AND Outcome__c = 'Service Not Performed' LIMIT 1]; 
            Test.startTest();
                ValidateTaskToPopMessage.ValidateToPopUpMsg(taskList.Id);
            Test.stopTest();
        }
    }
    
    //Test ValidateToPopUpMsg method   
    @isTest static void testValidateToPopUpMsg5() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            Task taskList = [SELECT Id FROM Task where Process__c = 'Confirm Service Completion'  AND Outcome__c = 'Service Not Performed' LIMIT 1]; 
            Test.startTest();
                ValidateTaskToPopMessage.ValidateToPopUpMsg(taskList.Id);
            Test.stopTest();
        }
    }
    
    //Test ValidateToPopUpMsg method   
    @isTest static void testValidateToPopUpMsg7() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            Task taskList = [SELECT Id FROM Task where Process__c = 'Confirm Service Completion with Location'  AND Outcome__c = 'Service Not Performed' LIMIT 1]; 
            Test.startTest();
                ValidateTaskToPopMessage.ValidateToPopUpMsg(taskList.Id);
            Test.stopTest();
        }
    }
    
    //Test Get related case method   
    @isTest static void testgetRelatedCase() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c,isActive from user WHERE isActive =TRUE limit 1];
        system.runAs(currentuser){
            Task taskObj = [SELECT Id, WhatId FROM Task LIMIT 1];
            Test.startTest();
                ValidateTaskToPopMessage.getRelatedCase(taskObj.WhatId);
                ValidateTaskToPopMessage.getRelatedCase(taskObj.Id);
            Test.stopTest();
        }
    } 
	//Test ValidateOutcome method   
  /**  @isTest static void testValidateOutcome() {
        user currentuser = [select id, Bypass_Validation__c from user limit 1];
        system.runAs(currentuser){
            Task taskList = [SELECT Id, WhatId FROM Task WHERE Process__c =: Constant_Util.RESOLVE_SERV_ISSUE LIMIT 1]; 
            case cse = [SELECT Id, caseNumber FROM Case WHERE Id =: taskList.WhatId LIMIT 1];

            Test.startTest();
            	case caseObj = ValidateTaskToPopMessage.ValidateOutcome(taskList.Id);
            	system.assertEquals(caseObj.caseNumber, cse.caseNumber);
            Test.stopTest();
        }
    } **/
}