/*************************************************************
@Name: ConcatenateTaskDetailForAcornTest
@Author: Niranjan
@CreateDate: 16/04/2019
@Description: Test class of ConcatenateTaskDetailForAcorn
@UsedBy: 
**************************************************************/
@isTest
public class ConcatenateTaskDetailForAcornTest {

    // method for setting up data    
    @testSetup static void setup() {
        Profile p = TestDataFactory.getProfile('System Administrator');
        User usr = TestDataFactory.createUser(p);
        Database.insert(usr);
        
        system.runAs(usr){
      list<Account> acclist = TestDataFactory.createAccount(Constant_Util.CONSTANT_FIRST, usr);
            Database.insert(acclist);
            list<Account> locationlist = TestDataFactory.createLocation(Constant_Util.LOCATION, usr, acclist.get(0).id);
            Database.insert(locationlist);
            list<Contact> conlist = TestDataFactory.createContact(Constant_Util.CONSTANT_FIRST,Constant_Util.CONSTANT_LAST, acclist.get(0), usr);
            Database.insert(conlist);
            list<product2> productlist = TestDataFactory.createProduct(Constant_Util.KEYWORD_TEST);
            Database.insert(productlist);
            list<Asset> assetlist = TestDataFactory.createAsset(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                                productlist.get(0), usr, locationlist.get(0));
            assetlist[0]. Supplier__c = acclist[1].Id;
            Database.insert(assetlist);
            list<Case> caselist = TestDataFactory.createCase(Constant_Util.CONSTANT_FIRST, acclist.get(0), conlist.get(0), 
                                                             usr, locationlist.get(0), assetlist.get(0));
            //Set<Id> caseId = new Set<Id>();
            Database.insert(caselist);
            //caseId.add(caselist.Id);
            list<WorkOrder> workOrderList = TestDataFactory.createWorkOrder(acclist.get(0), conlist.get(0), caselist.get(0), assetlist.get(0));
            Database.insert(workOrderList);
             list<Task> tasklist = TestDataFactory.createTask(caselist.get(0).id, usr);
            Database.insert(tasklist);
             /*Test.startTest();
             ConcatenateTaskDetailForAcorn.concatenateTaskDetail(tasklist);
            Test.stopTest();*/
    }
  }
    @isTest static void testTaskJSON() {
        user currentuser = [select id, Bypass_Validation__c,Profile.Name from user Where IsActive = true AND Profile.Name ='System Administrator'  limit 1]; //SDT-33363
        
        system.runAs(currentuser){
            list<Task> tasklist = [select Id,WhatId from Task limit 1];
            Test.startTest();
            	ConcatenateTaskDetailForAcorn.concatenateTaskDetail(tasklist);
            Test.stopTest();
        }
    }
}