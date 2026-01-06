/*************************************************************
@Name: TaskPopUpMessageControllerTest
@Author: Kalaiselvi R
@CreateDate: 01/07/2019
@Description: Test Class for TaskPopUpMessageController
**************************************************************/
@isTest
public class TaskPopUpMessageControllerTest {
    
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
            caselist[0].Reference_Number__c = '1223445';
            caselist[0].Case_Type__c = Constant_Util.Change_Service;
            caselist[0].Case_Sub_Type__c = Constant_Util.Change_Correction;
            caselist[0].Recordtypeid = TestDataFactory.getRecordType('Integration Case','Case');
            caselist[0].Service_Date__c = system.today();
            Database.insert(caselist[0]);
            
            Case c = new Case();
            c.AssetId = caselist[0].assetid;
            c.Client__c = caselist[0].Client__c;
            c.origin = caselist[0].origin;
            c.ContactId = conlist[0].id;
            c.OwnerId = usr.id;
			c.Status = 'New';
            c.Reference_Number__c = '1223445';
            c.ParentId = caselist[0].Id;
            c.RecordTypeId = caselist[0].RecordTypeId;
            c.Location__c = caselist[0].Location__c;
            c.Case_Type__c = caselist[0].Case_Type__c;
            c.Case_Sub_Type__c = caselist[0].Case_Sub_Type__c;
            c.Service_Date__c = system.today() + 1;
            try{
            Database.insert(c,false);
            } catch(Exception ex){
                system.debug('Exception while inserting case:::'+ex.getStackTraceString());
            }            
            list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            tasklist[0].WhatId = caselist[0].Id;
            Database.insert(tasklist);
        }
    }
    //Test Get task method   
    @isTest static void testGetTask() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            List<Task> taskList = [SELECT Id FROM Task LIMIT 1]; 
            system.assertEquals(1,taskList.size());
            Test.startTest();
                TaskPopUpMessageController.getTask(taskList[0].Id);
            Test.stopTest();
        }
    }
    //Test Get related case method   
    @isTest static void testgetRelatedCase() {
        //test class errors - SDT - 33363
        user currentuser = [select id, Bypass_Validation__c from user WHERE isActive = TRUE limit 1];
        system.runAs(currentuser){
            Task taskObj = [SELECT Id, WhatId FROM Task LIMIT 1];
            Test.startTest();
            List<case> returncaselst1 =  TaskPopUpMessageController.getRelatedCase(taskObj.WhatId);
            List<case> returncaselst2 =  TaskPopUpMessageController.getRelatedCase(taskObj.Id);
            List<case> returncaselst3 =  TaskPopUpMessageController.getRelatedCase(null);
            system.assertEquals(1,returncaselst1.size());
            system.assertEquals(1,returncaselst2.size());
            Test.stopTest();
        }
    } 
}